--------------------------------------------------------
--  DDL for Package Body PO_GML_CONV_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_GML_CONV_MIG" AS
/* $Header: POXMGGMB.pls 120.0 2005/06/08 13:20:28 pbamb noship $ */
/*===========================================================================
--  PROCEDURE:
--    PO_MIG_GML_DATA
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to all the PO entities for Inv Convergence
--    project. Main Procedure that calls the other 4 procedures.
--
--  PARAMETERS:
--    None
--
--  SYNOPSIS:
--    po_mig_gml_data;
--
--  HISTORY
--    P. Bamb  10-May-2005   Created
--=========================================================================== */
Procedure po_mig_gml_data IS

BEGIN

   -- Call proc to update the po_line_locations for quantity shipped.
   Update_po_shipment;

END po_mig_gml_data;

/*===========================================================================
--  PROCEDURE:
--    update_po_shipment
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to Update secondary_quantity_shipped
--    and secondary_quantity_shipped in PO_LINE_LOCATIONS_ALL by converting
--    respective transaction quantities.
--  PARAMETERS:
--    None
--
--  SYNOPSIS:
--    update_po_shipment;
--
--  HISTORY
--    P. Bamb  10-May-2005   Created
--=========================================================================== */
PROCEDURE update_po_shipment   IS

CURSOR CR_SHIPMENTS IS
 Select pll.secondary_quantity_shipped,
        pll.unit_meas_lookup_code,
        pl.item_id,
        pll.secondary_unit_of_measure,
        pll.po_header_id,
        pll.po_line_id,
        pll.line_location_id,
        pll.quantity_shipped,
        pll.quantity_cancelled
 from   po_line_locations_all pll,
        po_lines_all pl,
        mtl_parameters mp
 where  pll.secondary_unit_of_measure is not null
 AND    pll.po_header_id = pll.po_header_id
 AND    pll.po_line_id = pl.po_line_id
 AND    pll.ship_to_organization_id = mp.organization_id
 AND    pll.shipment_type in ('STANDARD', 'PLANNED', 'BLANKET')
 AND    (
           (nvl(pll.secondary_quantity_shipped,0) = 0 and nvl(pll.quantity_shipped,0) <> 0)
           OR
           (nvl(pll.secondary_quantity_cancelled,0) = 0 and nvl(pll.quantity_cancelled,0) <> 0)
        )
 AND    mp.process_enabled_flag = 'Y'
 FOR UPDATE OF secondary_quantity_shipped;

l_secondary_quantity_shipped  NUMBER;
l_secondary_quantity_cancelled NUMBER;

po_shipment_data_err  EXCEPTION;

cr_rec cr_shipments%ROWTYPE;

BEGIN

  FOR cr_rec in cr_shipments LOOP
    BEGIN

       l_secondary_quantity_shipped   := NULL;
       l_secondary_quantity_cancelled := NULL;

       IF cr_rec.quantity_shipped IS NOT NULL and cr_rec.quantity_shipped <> 0 THEN

          l_secondary_quantity_shipped := INV_CONVERT.inv_um_convert(
                                                  item_id        =>  cr_rec.item_id,
                                                  precision      =>  6,
                                                  from_quantity  =>  cr_rec.quantity_shipped,
                                                  from_unit      =>  NULL,
                                                  to_unit        =>  NULL,
                                                  from_name      =>  cr_rec.unit_meas_lookup_code ,
                                                  to_name        =>  cr_rec.secondary_unit_of_measure );

          IF l_secondary_quantity_shipped <=0 THEN
             raise po_shipment_data_err;
          End If;
       END IF;

       IF cr_rec.quantity_cancelled IS NOT NULL and cr_rec.quantity_cancelled <> 0 THEN

          l_secondary_quantity_cancelled := INV_CONVERT.inv_um_convert(
                                                  item_id        =>  cr_rec.item_id,
                                                  precision      =>  6,
                                                  from_quantity  =>  cr_rec.quantity_cancelled,
                                                  from_unit      =>  NULL,
                                                  to_unit        =>  NULL,
                                                  from_name      =>  cr_rec.unit_meas_lookup_code ,
                                                  to_name        =>  cr_rec.secondary_unit_of_measure );

          IF l_secondary_quantity_cancelled <=0 THEN
             raise po_shipment_data_err;
          End If;
       END IF;

       UPDATE po_line_locations_all
       SET    secondary_quantity_shipped    = nvl(l_secondary_quantity_shipped,secondary_quantity_shipped),
              secondary_quantity_cancelled  = nvl(l_secondary_quantity_cancelled,secondary_quantity_cancelled)
       WHERE  CURRENT OF cr_shipments;

     EXCEPTION
        WHEN PO_SHIPMENT_DATA_ERR THEN
           insert into gml_po_mig_errors
				(migration_type,po_header_id,po_line_id,line_location_id,
				 transaction_id, shipment_header_id,shipment_line_id,
				 column_name,table_name,error_message,
				 creation_date,last_update_date)
			values ('CONVERGENCE',cr_rec.po_header_id,cr_rec.po_line_id,cr_rec.line_location_id,
				NULL, NULL, NULL,
				'SECONDARY_QUANTITY_SHIPPED','PO_LINE_LOCATIONS_ALL',
				'ERROR DERIVING SECONDARY QUANTITY SHIPPED FROM QUANTITY SHIPPED',sysdate,sysdate);
   END;
  END LOOP;
Commit;
END update_po_shipment;

/*===========================================================================
--  PROCEDURE:
--    migrate_hazard_classes
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate hazard classes from the Regulatory property
--    values table to the po_hazard_classes tables.
--
--  PARAMETERS:
--    p_migration_run_id  - Migration run id to be used for writing  to the message log
--    p_commit            - Indicates if commit should be issued after logical unit is migrated
--    x_failure_count     - Returns the number of failures that occurred during migration
--
--  SYNOPSIS:
--    migrate_hazard_classes(
--                         p_migration_run_id => migration_id,
--                         p_commit           => 'Y',
--                         x_failure_count    => failure_count );
--
--  HISTORY
--    M. Grosser  10-May-2005   Created
--=========================================================================== */
  PROCEDURE migrate_hazard_classes
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  ) IS

   /*  ------------- LOCAL VARIABLES ------------------- */
     l_temp                NUMBER;
     l_rowid               VARCHAR2(2000);
     l_seq                 NUMBER;
     l_mig_status          NUMBER;
     l_migration_count     NUMBER:=0;
     l_exists_count        NUMBER:=0;
     l_hazard_description  VARCHAR2(240);

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used retrieve the hazard classification codes  */
     CURSOR c_get_hazard_classes IS
        SELECT *
          FROM gr_property_values_tl
        WHERE language = userenv('LANG') and
              property_id = 'UNCLSS';
     l_hazard_class_rec   c_get_hazard_classes%ROWTYPE;

     /* Cursor used to check if the hazard class is already in the table  */
     CURSOR c_check_existence (v_hazard_class VARCHAR2) IS
        SELECT 1
        FROM   sys.dual
        WHERE  EXISTS (SELECT 1
                       FROM   po_hazard_classes_tl
                       WHERE  hazard_class = v_hazard_class);

     /* Cursor used to retrieve the next sequence number  */
     CURSOR c_get_seq IS
        SELECT PO_HAZARD_CLASSES_S.nextval
        FROM   sys.dual;

     /* Cursor used to retrieve translated descriptions for installed languages  */
     CURSOR c_get_translated (v_hazard_class VARCHAR2) IS
         SELECT *
          FROM gr_property_values_tl
         WHERE language in (SELECT language_code
                              FROM fnd_languages
                             WHERE language_code <> userenv('LANG')
                               AND installed_flag in ('I','B'))
           AND value = v_hazard_class;
     l_translated_rec   c_get_translated%ROWTYPE;

  BEGIN

     x_failure_count := 0;

     GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'PO_HAZARD_CLASSES',
       p_context         => 'HAZARD_CLASSES',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');


     /* Select hazard classes that have not yet been migrated */
     OPEN c_get_hazard_classes;
     FETCH c_get_hazard_classes into l_hazard_class_rec;

     /* While there are results that have not been migrated */
     WHILE c_get_hazard_classes%FOUND LOOP

       BEGIN

         SAVEPOINT Hazard_Class;

         /* Check to see if the hazard class already exists in the table */
         OPEN c_check_existence(l_hazard_class_rec.value);
         FETCH c_check_existence into l_temp;

         IF c_check_existence%NOTFOUND THEN

            l_mig_status := 1;

            /* Retrieve next sequence value */
            OPEN  c_get_seq;
            FETCH c_get_seq INTO l_seq;
            CLOSE c_get_seq;

	    PO_HAZARD_CLASSES_PKG.insert_row (
              X_ROWID              => l_rowid,
              X_HAZARD_CLASS_ID    => l_seq,
              X_HAZARD_CLASS	   => l_hazard_class_rec.value,
              X_DESCRIPTION        => l_hazard_class_rec.meaning,
              X_INACTIVE_DATE      => NULL,
              X_CREATION_DATE      => l_hazard_class_rec.CREATION_DATE,
              X_CREATED_BY         => l_hazard_class_rec.CREATED_BY,
              X_LAST_UPDATE_DATE   => l_hazard_class_rec.LAST_UPDATE_DATE,
              X_LAST_UPDATED_BY    => l_hazard_class_rec.LAST_UPDATED_BY,
              X_LAST_UPDATE_LOGIN  => l_hazard_class_rec.LAST_UPDATE_LOGIN,
              X_ATTRIBUTE_CATEGORY => NULL,
              X_ATTRIBUTE1	   => NULL,
              X_ATTRIBUTE2	   => NULL,
              X_ATTRIBUTE3	   => NULL,
              X_ATTRIBUTE4	   => NULL,
              X_ATTRIBUTE5	   => NULL,
              X_ATTRIBUTE6	   => NULL,
              X_ATTRIBUTE7	   => NULL,
              X_ATTRIBUTE8	   => NULL,
              X_ATTRIBUTE9	   => NULL,
              X_ATTRIBUTE10	   => NULL,
              X_ATTRIBUTE11	   => NULL,
              X_ATTRIBUTE12	   => NULL,
              X_ATTRIBUTE13	   => NULL,
              X_ATTRIBUTE14	   => NULL,
              X_ATTRIBUTE15	   => NULL,
              X_REQUEST_ID         => NULL );


            OPEN c_get_translated(l_hazard_class_rec.value);
            FETCH c_get_translated INTO l_translated_rec;

            WHILE c_get_translated%FOUND LOOP

               /* Update the descriptions with the values from Regulatory */
	       UPDATE po_hazard_classes_tl
                  SET description = l_translated_rec.meaning,
                      source_lang = l_translated_rec.source_lang,
                      creation_date = l_translated_rec.creation_date,
                      created_by = l_translated_rec.created_by,
                      last_update_date = l_translated_rec.last_update_date,
                      last_updated_by = l_translated_rec.last_updated_by,
                      last_update_login = l_translated_rec.last_update_login
	        WHERE language = l_translated_rec.language
                  AND hazard_class_id = l_seq;

               FETCH c_get_translated INTO l_translated_rec;
	    END LOOP;
            CLOSE c_get_translated;

         ELSE
            l_mig_status := 0;

            GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => P_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_STATEMENT,
              p_message_token   => 'GR_HAZARD_CLASS_EXISTS',
              p_table_name      => 'PO_HAZARD_CLASSES',
              p_context         => 'HAZARD_CLASSES',
              p_param1          => l_hazard_class_rec.value,
              p_param2          => NULL,
              p_param3          => NULL,
              p_param4          => NULL,
              p_param5          => NULL,
              p_db_error        => NULL,
              p_app_short_name  => 'GR');

         END IF;

         CLOSE c_check_existence;

         /* Issue commit if required */
         IF p_commit = 'Y' THEN
            COMMIT;
         END IF;

         /* Increment appropriate counter */
         IF l_mig_status = 1 THEN
            l_migration_count := l_migration_count + 1;
         ELSE
            l_exists_count := l_exists_count + 1;
         END IF;


       EXCEPTION
         WHEN OTHERS THEN
            x_failure_count := x_failure_count + 1;

            GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => P_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
              p_message_token   => 'GMA_MIGRATION_DB_ERROR',
              p_table_name      => 'PO_HAZARD_CLASSES',
              p_context         => 'HAZARD_CLASSES',
              p_param1          => NULL,
              p_param2          => NULL,
              p_param3          => NULL,
              p_param4          => NULL,
              p_param5          => NULL,
              p_db_error        => SQLERRM,
              p_app_short_name  => 'GMA');

         ROLLBACK to SAVEPOINT Hazard_Class;

       END;

       FETCH c_get_hazard_classes into l_hazard_class_rec;

    END LOOP;  /* Number or records selected */

    CLOSE c_get_hazard_classes;


    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'PO_HAZARD_CLASSES',
       p_context         => 'HAZARD_CLASSES',
       p_param1          => l_migration_count,
       p_param2          => x_failure_count,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');


  EXCEPTION
     WHEN OTHERS THEN
        x_failure_count := x_failure_count + 1;

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'PO_HAZARD_CLASSES',
          p_context         => 'HAZARD_CLASSES',
          p_param1          => NULL,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_table_name      => 'PO_HAZARD_CLASSES',
          p_context         => 'HAZARD_CLASSES',
          p_param1          => x_failure_count,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMA');

        ROLLBACK to SAVEPOINT Hazard_Class;

  END migrate_hazard_classes;


/*===========================================================================
--  PROCEDURE:
--    migrate_un_numbers
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate UN Number values from the Regulatory item
--    properties table to the po_hazard_classes tables.
--
--  PARAMETERS:
--    p_migration_run_id  - Migration run id to be used for writing  to the message log
--    p_commit            - Indicates if commit should be issued after logical unit is migrated
--    x_failure_count     - Returns the number of failures that occurred during migration
--
--  SYNOPSIS:
--    migrate_un_numbers(
--                         p_migration_run_id => migration_id,
--                         p_commit           => 'Y',
--                         x_failure_count    => failure_count );
--
--  HISTORY
--    M. Grosser  10-May-2005   Created
--=========================================================================== */
  PROCEDURE migrate_un_numbers
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  ) IS

   /*  ------------- LOCAL VARIABLES ------------------- */
     l_temp                NUMBER;
     l_rowid               VARCHAR2(2000);
     l_seq                 NUMBER;
     l_mig_status          NUMBER;
     l_migration_count     NUMBER:=0;
     l_exists_count        NUMBER:=0;
     l_hazard_class_id     NUMBER;
     l_return_status       VARCHAR2(2);
     l_msg_data            VARCHAR2(2000);
     l_un_number           NUMBER;

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used retrieve the un number values  */
     CURSOR c_get_un_numbers IS
        SELECT DISTINCT(number_value)
          FROM gr_item_properties
        WHERE  migration_ind IS NULL and
               property_id = 'UNNUMB' and
               label_code = '14001';

     CURSOR c_get_un_number_details IS
        SELECT *
          FROM gr_item_properties
        WHERE  migration_ind IS NULL and
               number_value = l_un_number and
               property_id = 'UNNUMB' and
               label_code = '14001'
      ORDER BY creation_date;
     l_un_number_rec   c_get_un_number_details%ROWTYPE;

     /* Cursor used to check if the un number is already in the table  */
     CURSOR c_check_existence (v_un_number VARCHAR2) IS
        SELECT 1
        FROM   sys.dual
        WHERE  EXISTS (SELECT 1
                       FROM   po_un_numbers_tl
                       WHERE  un_number = 'UN'||v_un_number);

     /* Cursor used to retrieve the next sequence number  */
     CURSOR c_get_seq IS
        SELECT PO_UN_NUMBERS_S.nextval
        FROM   sys.dual;

  BEGIN

     x_failure_count := 0;

     GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'PO_UN_NUMBERS',
       p_context         => 'UN_NUMBERS',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');


     /* Select un numbers that have not yet been migrated */
     OPEN c_get_un_numbers;
     FETCH c_get_un_numbers into l_un_number;

     /* While there are un numbers that have not been migrated */
     WHILE c_get_un_numbers%FOUND LOOP

       BEGIN

         SAVEPOINT UN_Number;

         /* Check to see if the un number already exists in the table */
         IF c_check_existence%ISOPEN THEN
            CLOSE c_check_existence;
         END IF;

         OPEN c_check_existence(TO_CHAR(l_un_number));
         FETCH c_check_existence into l_temp;

         IF c_check_existence%NOTFOUND THEN

            l_mig_status := 1;

            /* Retrieve next sequence value */
            OPEN  c_get_seq;
            FETCH c_get_seq INTO l_seq;
            CLOSE c_get_seq;

            /* Retrieve un number details */
            OPEN  c_get_un_number_details;
            FETCH c_get_un_number_details INTO l_un_number_rec;
            CLOSE c_get_un_number_details;

            l_hazard_class_id := NULL;

            l_hazard_class_id := GR_MIGRATE_TO_12.get_hazard_class_id(
                         p_item_code        => l_un_number_rec.item_code,
                         x_return_status    => l_return_status,
                         x_msg_data         => l_msg_data );


	    PO_UN_NUMBERS_PKG.insert_row (
              X_ROWID              => l_rowid,
              X_UN_NUMBER_ID       => l_seq,
              X_UN_NUMBER          => 'UN'||TO_CHAR(l_un_number_rec.number_value),
              X_DESCRIPTION        => 'UN'||TO_CHAR(l_un_number_rec.number_value),
              X_HAZARD_CLASS_ID    => l_hazard_class_id,
              X_INACTIVE_DATE      => NULL,
              X_CREATION_DATE      => l_un_number_rec.CREATION_DATE,
              X_CREATED_BY         => l_un_number_rec.CREATED_BY,
              X_LAST_UPDATE_DATE   => l_un_number_rec.LAST_UPDATE_DATE,
              X_LAST_UPDATED_BY    => l_un_number_rec.LAST_UPDATED_BY,
              X_LAST_UPDATE_LOGIN  => l_un_number_rec.LAST_UPDATE_LOGIN,
              X_ATTRIBUTE_CATEGORY => NULL,
              X_ATTRIBUTE1	   => NULL,
              X_ATTRIBUTE2	   => NULL,
              X_ATTRIBUTE3	   => NULL,
              X_ATTRIBUTE4	   => NULL,
              X_ATTRIBUTE5	   => NULL,
              X_ATTRIBUTE6	   => NULL,
              X_ATTRIBUTE7	   => NULL,
              X_ATTRIBUTE8	   => NULL,
              X_ATTRIBUTE9	   => NULL,
              X_ATTRIBUTE10	   => NULL,
              X_ATTRIBUTE11	   => NULL,
              X_ATTRIBUTE12	   => NULL,
              X_ATTRIBUTE13	   => NULL,
              X_ATTRIBUTE14	   => NULL,
              X_ATTRIBUTE15	   => NULL,
              X_REQUEST_ID         => NULL );

         ELSE
            l_mig_status := 0;

            GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => P_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_STATEMENT,
              p_message_token   => 'GR_UN_NUMBER_EXISTS',
              p_table_name      => 'PO_UN_NUMBERS',
              p_context         => 'UN_NUMBERS',
              p_param1          => TO_CHAR(l_un_number_rec.number_value),
              p_param2          => NULL,
              p_param3          => NULL,
              p_param4          => NULL,
              p_param5          => NULL,
              p_db_error        => NULL,
              p_app_short_name  => 'GR');

         END IF;

         CLOSE c_check_existence;

         /* Set record status to migrated */
         UPDATE gr_item_properties
          SET migration_ind = l_mig_status
         WHERE number_value = l_un_number_rec.number_value and
               property_id = 'UNNUMB' and
               label_code = '14001';

         /* Issue commit if required */
         IF p_commit = 'Y' THEN
            COMMIT;
         END IF;

         /* Increment appropriate counter */
         IF l_mig_status = 1 THEN
            l_migration_count := l_migration_count + 1;
         ELSE
            l_exists_count := l_exists_count + 1;
         END IF;


       EXCEPTION
         WHEN OTHERS THEN
            x_failure_count := x_failure_count + 1;

            ROLLBACK to SAVEPOINT UN_Number;

            GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => P_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
              p_message_token   => 'GMA_MIGRATION_DB_ERROR',
              p_table_name      => 'PO_UN_NUMBERS',
              p_context         => 'UN_NUMBERS',
              p_param1          => NULL,
              p_param2          => NULL,
              p_param3          => NULL,
              p_param4          => NULL,
              p_param5          => NULL,
              p_db_error        => SQLERRM,
              p_app_short_name  => 'GMA');

       END;

       FETCH c_get_un_numbers into l_un_number;

    END LOOP;  /* Number or records selected */

    CLOSE c_get_un_numbers;


    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'PO_UN_NUMBERS',
       p_context         => 'UN_NUMBERS',
       p_param1          => l_migration_count,
       p_param2          => x_failure_count,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');


  EXCEPTION
     WHEN OTHERS THEN
        x_failure_count := x_failure_count + 1;

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'PO_UN_NUMBERS',
          p_context         => 'UN_NUMBERS',
          p_param1          => NULL,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_TABLE_MIGRATION_TABLE_FAIL',
          p_table_name      => 'PO_UN_NUMBERS',
          p_context         => 'UN_NUMBERS',
          p_param1          => x_failure_count,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMA');

  END migrate_un_numbers;

END PO_GML_CONV_MIG;


/
