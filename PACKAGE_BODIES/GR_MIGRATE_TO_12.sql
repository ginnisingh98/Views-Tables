--------------------------------------------------------
--  DDL for Package Body GR_MIGRATE_TO_12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_MIGRATE_TO_12" AS
/* $Header: GRMIG12B.pls 120.7.12010000.3 2008/11/21 15:23:53 plowe ship $  */

/*===========================================================================
--  FUNCTION:
--   get_inventory_item_id
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to retrieve an inventory_item_id after the item
--    has been migrated to the mtl_system_items_b table.
--
--  PARAMETERS:
--    p_organization_id - Organization id to use to retrieve the value
--    p_item_code       - Item_code to use to retrieve the value
--    x_return_status   - Returns the status of the function (success, failure, etc.)
--    x_msg_data        - Returns message data if an error occurred
--
--  RETURNS:
--    inventory_item_id    - ID of item in mtl_system_items_b table
--
--  SYNOPSIS:
--    l_item_id := get_inventory_item_id(
--                           p_organization_id  => l_org_id,
--                           p_item_code        => l_item_code,
--                           x_return_status    => l_return_status,
--                           x_msg_data         => l_msg_data );
--
--  HISTORY
--=========================================================================== */
  FUNCTION get_inventory_item_id
  (
     p_organization_id        IN          NUMBER,
     p_item_code              IN          VARCHAR2,
     x_return_status          OUT NOCOPY  VARCHAR2,
     x_msg_data               OUT NOCOPY  VARCHAR2
  )
  RETURN NUMBER IS

   /*  ------------- LOCAL VARIABLES ------------------- */
     l_inventory_item_id     NUMBER;

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used retrieve the inventory_item_ id  */
     CURSOR c_get_inventory_item_id IS
       SELECT inventory_item_id
          FROM  gr_item_general_mig
          WHERE item_code = p_item_code
            AND organization_id = p_organization_id;

   /*  ----------------- EXCEPTIONS -------------------- */
      INVALID_ORG_ITEM   EXCEPTION;

  BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*  Validate the inventory item id */
     OPEN c_get_inventory_item_id;
     FETCH c_get_inventory_item_id  INTO l_inventory_item_id;

      /* If inventory item not found */
      IF c_get_inventory_item_id %NOTFOUND THEN
         CLOSE c_get_inventory_item_id;
         RAISE INVALID_ORG_ITEM;
      END IF;

      CLOSE c_get_inventory_item_id;

      RETURN l_inventory_item_id;

  EXCEPTION

      WHEN INVALID_ORG_ITEM THEN
          x_msg_data := 'INVALID_ORG_ITEM';
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN NULL;

      WHEN OTHERS THEN
          x_msg_data := SQLERRM;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN NULL;

  END get_inventory_item_id;





/*===========================================================================
--  FUNCTION:
--   get_hazard_class_id
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to retrieve a hazard class id for a given item
--    after the hazard class has been migrated to the po_hazard_classes table.
--
--  RETURNS:
--    hazard_class_id      - ID of hazard class in po_hazard_classes table
--
--  PARAMETERS:
--    p_item_code       - Item_code to retrieve value for
--    x_return_status   - Returns the status of the function (success, failure, etc.)
--    x_msg_data        - Returns message data if an error occurred
--
--  SYNOPSIS:
--    l_haz_class_id := get_hazard_class_id(
--                         p_item_code        => l_item_code,
--                         x_return_status    => l_return_status,
--                         x_msg_data         => l_msg_data );
--
--  HISTORY
--=========================================================================== */
  FUNCTION get_hazard_class_id
  (
      p_item_code             IN          VARCHAR2,
      x_return_status         OUT NOCOPY  VARCHAR2,
      x_msg_data              OUT NOCOPY  VARCHAR2
  )
  RETURN  NUMBER IS

     /*  ------------- LOCAL VARIABLES ------------------- */
     l_hazard_class          VARCHAR2(25);
     l_hazard_class_id       NUMBER;

     /*  ------------------ CURSORS ---------------------- */
      /* Cursor used retrieve the hazard class  */
      CURSOR c_get_hazard_class IS
       SELECT alpha_value
         FROM gr_item_properties
        WHERE label_code = '14002'
          AND property_id = 'UNCLSS'
          AND item_code = p_item_code;

      /* Cursor used retrieve the hazard class_ id  */
      CURSOR c_get_hazard_class_id IS
        SELECT hazard_class_id
          FROM po_hazard_classes
         WHERE hazard_class = l_hazard_class;

     /*  ----------------- EXCEPTIONS -------------------- */
     INVALID_HAZARD_CLASS    EXCEPTION;

  BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*  Retrieve the hazard class */
     OPEN c_get_hazard_class;
     FETCH c_get_hazard_class  INTO l_hazard_class;

     /* If hazard class not found */
     IF c_get_hazard_class %NOTFOUND THEN
        CLOSE c_get_hazard_class;
        RETURN NULL;
     END IF;
     CLOSE c_get_hazard_class;

     /*  Retrieve the hazard class id */
     OPEN c_get_hazard_class_id;
     FETCH c_get_hazard_class_id  INTO l_hazard_class_id;

     /* If hazard class not found */
     IF c_get_hazard_class_id %NOTFOUND THEN
        CLOSE c_get_hazard_class_id;
        RAISE INVALID_HAZARD_CLASS;
     END IF;

     CLOSE c_get_hazard_class_id;
     RETURN l_hazard_class_id;

  EXCEPTION
     WHEN INVALID_HAZARD_CLASS THEN
          x_msg_data := 'INVALID_HAZARD_CLASS';
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN NULL;

     WHEN OTHERS THEN
          x_msg_data := SQLERRM;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN NULL;

  END get_hazard_class_id;



/*===========================================================================
--  FUNCTION:
--   get_un_number_id
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to retrieve a un number id for a given item
--    after the un number has been migrated to the po_un_numbers table.
--
--  PARAMETERS:
--    p_item_code       - Item_code to retrieve value for
--    x_return_status   - Returns the status of the function (success, failure, etc.)
--    x_msg_data        - Returns message data if an error occurred
--
--  RETURNS:
--    un_number_id      - ID of un_number in po_un_numbers_table
--
--  SYNOPSIS:
--    l_un_number_id := get_un_number_id(
--                         p_item_code        => l_item_code,
--                         x_return_status    => l_return_status,
--                         x_msg_data         => l_msg_data );
--
--  HISTORY
--=========================================================================== */
  FUNCTION get_un_number_id
  (
      p_item_code             IN         VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_data              OUT NOCOPY VARCHAR2
  )
  RETURN  NUMBER IS

     /*  ------------- LOCAL VARIABLES ------------------- */
     l_un_number          VARCHAR2(240);
     l_un_number_id       NUMBER;

     /*  ------------------ CURSORS ---------------------- */
      /* Cursor used retrieve the un_number */
     CURSOR c_get_un_number IS
       SELECT 'UN'||TO_CHAR(number_value)
         FROM gr_item_properties
        WHERE label_code = '14001'
          AND property_id = 'UNNUMB'
          AND item_code = p_item_code;

      /* Cursor used retrieve the un_number_ id  */
     CURSOR c_get_un_number_id IS
       SELECT un_number_id
         FROM po_un_numbers
        WHERE un_number = l_un_number;

     /*  ----------------- EXCEPTIONS -------------------- */
     INVALID_UN_NUMBER       EXCEPTION;


  BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*  Retrieve the un number */
     OPEN c_get_un_number;
     FETCH c_get_un_number INTO l_un_number;

     /* If un number not found */
     IF c_get_un_number %NOTFOUND THEN
        CLOSE c_get_un_number;
        RETURN NULL;
     END IF;
     CLOSE c_get_un_number;

     /*  Validate the un number */
     OPEN c_get_un_number_id;
     FETCH c_get_un_number_id INTO l_un_number_id;

     /* If un number id not found */
     IF c_get_un_number_id %NOTFOUND THEN
        CLOSE c_get_un_number_id;
        RAISE INVALID_UN_NUMBER;
     END IF;

     CLOSE c_get_un_number_id;
     RETURN l_un_number_id;

  EXCEPTION

     WHEN INVALID_UN_NUMBER THEN
        x_msg_data := 'INVALID_UN_NUMBER';
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN NULL;

     WHEN OTHERS THEN
        x_msg_data := SQLERRM;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN NULL;

  END get_un_number_id;



/*===========================================================================
--  PROCEDURE:
--    create_item_mig_records
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to insert records into the gr_item_general_mig table.
--    This table will be used to drive the migration of Regulatory items to the specified
--    organizations.
--
--  PARAMETERS:
--    p_migration_run_id  - Migration run id to be used for writing  to the message log
--    p_commit            - Indicates if commit should be issued after logical unit is migrated
--    x_failure_count     - Returns the number of failures that occurred during migration
--
--  SYNOPSIS:
--    create_item_mig_records(
--                         p_migration_run_id => migration_id,
--                         p_commit           => 'Y',
--                         x_failure_count    => failure_count );
--
--  HISTORY
--    M. Grosser 08-Dec-2005: Modified code to put out warning if Regulatory data
--               exists and no orgs are designated as Regulatory orgs
--=========================================================================== */
  PROCEDURE create_item_mig_records
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  ) IS

   /*  ------------- LOCAL VARIABLES ------------------- */
     l_temp                NUMBER;
     l_organization_id     NUMBER;
     l_seq                 NUMBER;
     l_mig_status          NUMBER;
     l_migration_count     NUMBER:=0;
     l_recs_inserted       NUMBER:=0;
     l_reg_orgs_found      NUMBER:=0;

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used retrieve the master organizations that will track Regulatory data  */
     CURSOR c_get_master_orgs IS
        SELECT organization_id
          FROM sy_orgn_mst_b
         WHERE master_organization_id IS NULL and
               regulatory_org_ind = 'Y'and
               organization_id is not null; --in case the org is not migrated then this indicates that

     /* Cursor used retrieve the child organizations that will track Regulatory data  */
     CURSOR c_get_child_orgs IS
        SELECT organization_id
          FROM sy_orgn_mst_b
         WHERE master_organization_id IS NOT NULL and
               regulatory_org_ind = 'Y' and
               organization_id is not null;

     /* Cursor used check if there is Regulatory data if no orgs are set as Regualtory orgs */
     CURSOR c_check_reg_data IS
        SELECT 1
          FROM gr_item_general;

   /*  ----------------- EXCEPTIONS -------------------- */
      NO_REG_ORG         EXCEPTION;

  BEGIN
     x_failure_count := 0;

     GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GR_ITEM_GENERAL_MIG',
       p_context         => 'GR_ITEM_MIGRATION_TABLE',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');

     /* Select master orgs that have not yet been migrated - master orgs get migrated first*/
     OPEN c_get_master_orgs;
     FETCH c_get_master_orgs into l_organization_id;

     /* While there are results that have not been migrated */
     WHILE c_get_master_orgs%FOUND LOOP

        l_reg_orgs_found := 1;

        INSERT INTO gr_item_general_mig
                   (
                    item_code,
                    organization_id,
                    inventory_item_id,
                    migration_ind
                    )
                SELECT
                    a.item_code,
                    l_organization_id,
                    NULL,
                    NULL
                FROM gr_item_general a
               WHERE NOT EXISTS (SELECT 1 from gr_item_general_mig b
                                  WHERE b.item_code = a.item_code and
                                        b.organization_id = l_organization_id);

        /* Issue commit if required */
        IF p_commit = FND_API.G_TRUE THEN
           COMMIT;
        END IF;

        l_migration_count:= l_migration_count + l_recs_inserted;

        FETCH c_get_master_orgs into l_organization_id;

     END LOOP;
     CLOSE c_get_master_orgs;

     /* Select master orgs that have not yet been migrated - master orgs get migrated first*/
     OPEN c_get_child_orgs;
     FETCH c_get_child_orgs into l_organization_id;

     /* While there are results that have not been migrated */
     WHILE c_get_child_orgs%FOUND LOOP

        l_reg_orgs_found := 1;

        INSERT INTO gr_item_general_mig
                   (
                    item_code,
                    organization_id,
                    inventory_item_id,
                    migration_ind
                    )
                SELECT
                    a.item_code,
                    l_organization_id,
                    NULL,
                    NULL
                FROM gr_item_general a
               WHERE NOT EXISTS (SELECT 1 from gr_item_general_mig b
                                  WHERE b.item_code = a.item_code and
                                        b.organization_id = l_organization_id);

        /* Issue commit if required */
        IF p_commit = FND_API.G_TRUE THEN
           COMMIT;
        END IF;

        FETCH c_get_child_orgs into l_organization_id;

    END LOOP;
    CLOSE c_get_child_orgs;

    /* If no organizations are designated as Regulatory orgs, raise an error if there is Regulatory data */
    IF l_reg_orgs_found = 0 THEN
       OPEN c_check_reg_data;
       FETCH c_check_reg_data into l_temp;
       IF c_check_reg_data%NOTFOUND THEN
         RAISE NO_REG_ORG;
       END IF;
    END IF;

    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'GR_ITEM_GENERAL_MIG',
       p_context         => 'GR_ITEM_MIGRATION_TABLE',
       p_param1          => l_migration_count,
       p_param2          => x_failure_count,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');


  EXCEPTION

    WHEN NO_REG_ORG THEN

      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GR_NO_REG_ORG',
          p_table_name      => 'GR_ITEM_GENERAL_MIG',
          p_context         => 'GR_ITEM_MIGRATION_TABLE',
          p_app_short_name  => 'GMA');

     WHEN OTHERS THEN

        x_failure_count := x_failure_count + 1;

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'GR_ITEM_GENERAL_MIG',
          p_context         => 'GR_ITEM_MIGRATION_TABLE',
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
          p_table_name      => 'GR_ITEM_GENERAL_MIG',
          p_context         => 'GR_ITEM_MIGRATION_TABLE',
          p_param1          => x_failure_count,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMA');

  END create_item_mig_records;



/*===========================================================================
--  PROCEDURE:
--    migrate_regulatory_items
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate Regulatory Items to the
--    mtl_system_items tables, migrate properties to organization_specific
--    tables, migrate attachments.
--
--  PARAMETERS:
--    p_migration_run_id  - Migration run id to be used for writing  to the message log
--    p_commit            - Indicates if commit should be issued after logical unit is migrated
--    x_failure_count     - Returns the number of failures that occurred during migration
--
--  SYNOPSIS:
--    migrate_regulatory_items(
--                         p_migration_run_id => migration_id,
--                         p_commit           => 'Y',
--                         x_failure_count    => failure_count );
--
--  HISTORY
--    M. Grosser  17-May-2005   Created
--=========================================================================== */
  PROCEDURE migrate_regulatory_items
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  ) IS

   /*  ------------- LOCAL VARIABLES ------------------- */
     l_temp                NUMBER;
     l_rowid               VARCHAR2(2000);
     l_inv_category_id     NUMBER;
     l_reg_category_id     NUMBER;
     l_inventory_item_id   NUMBER;
     l_un_number_id        NUMBER;
     l_hazard_class_id     NUMBER;
     l_mig_status          NUMBER;
     l_migration_count     NUMBER := 0;
     l_exists_count        NUMBER := 0;
     l_return_status       VARCHAR2(2);
     l_msg_data            VARCHAR2(2000);
     l_hazard_description  VARCHAR2(240);
     l_failure_count       NUMBER := 0;
     l_doc_category_id     NUMBER;
     l_attached_doc_id     NUMBER;
     l_media_id            NUMBER;
     l_related_item_id     NUMBER;

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used to retrieve record from migration table */
     CURSOR c_get_mig_rec IS
        SELECT item_code, organization_id
          FROM gr_item_general_mig
         WHERE migration_ind is NULL;
     l_mig_rec       c_get_mig_rec%ROWTYPE;

     /* Cursor used to retrieve document category ids  */
     CURSOR c_get_category_id(v_category_name VARCHAR2) IS
        SELECT category_id
          FROM fnd_document_categories
         WHERE name = v_category_name;

     /* Cursor used to check if item for organization is already in the table  */
     CURSOR c_check_exists IS
        SELECT inventory_item_id
          FROM mtl_system_items_b
         WHERE segment1 = l_mig_rec.item_code and
               organization_id = l_mig_rec.organization_id;

     /* Cursor used to retrieve regulatory item record  */
     CURSOR c_get_reg_item IS
        SELECT *
          FROM gr_item_general
         WHERE item_code = l_mig_rec.item_code;
     l_reg_item_rec       c_get_reg_item%ROWTYPE;

   /* Cursor used to retrieve the Regulatory item description*/
     CURSOR c_get_translated IS
        SELECT *
          FROM gr_multilingual_name_tl
         WHERE language in (SELECT language_code
                             FROM fnd_languages
                             WHERE language_code <> userenv('LANG')
                               AND installed_flag in ('I','B')) and
                  label_code = '11007' and
                  item_code = l_mig_rec.item_code;
     l_translated_rec   c_get_translated%ROWTYPE;

     /* Cursor used to retrieve related inventory items  */
     CURSOR c_get_related IS
        SELECT *
          FROM gr_generic_items_b
         WHERE item_code = l_mig_rec.item_code;
     l_related_rec     c_get_related%ROWTYPE;

     /* Cursor used to retrieve OPM item id  */
     CURSOR c_get_opm_item_id IS
        SELECT item_id
          FROM ic_item_mst_b
         WHERE item_no = l_related_rec.item_no;
    l_opm_item_id         NUMBER := NULL;

     /* Cursor used to retrieve document attached to Regulatory item  */
     CURSOR c_get_attachments IS
        SELECT *
          FROM fnd_attached_documents
         WHERE entity_name = 'GR_ITEM_GENERAL' and
               pk1_value = l_mig_rec.item_code;
     l_attachment_rec    c_get_attachments%ROWTYPE;


     /*  ----------------- EXCEPTIONS -------------------- */
         INVALID_REG_ITEM   EXCEPTION;
         ITEM_CREATE_ERROR  EXCEPTION;
         NO_CAS_NUMBER      EXCEPTION;
         PROC_CALL_ERROR    EXCEPTION;

  BEGIN

     x_failure_count := 0;

     GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GR_ITEM_GENERAL',
       p_context         => 'REGULATORY_ITEMS',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');


     /* Select item/organization combinations that have not yet been migrated */
     OPEN c_get_mig_rec;
     FETCH c_get_mig_rec into l_mig_rec;

     IF c_get_mig_rec%NOTFOUND THEN

        GMA_COMMON_LOGGING.gma_migration_central_log (
             p_run_id          => P_migration_run_id,
             p_log_level       => FND_LOG.LEVEL_PROCEDURE,
             p_message_token   => 'GR_NO_REGITEMS_TO_MIG',
             p_table_name      => 'GR_ITEM_GENERAL',
             p_context         => 'REGULATORY_ITEMS',
             p_param1          => NULL,
             p_param2          => NULL,
             p_param3          => NULL,
             p_param4          => NULL,
             p_param5          => NULL,
             p_db_error        => NULL,
             p_app_short_name  => 'GR');

     ELSE

        /* Retrieve category_id for document category MSDS_INV_ITEM */
        OPEN c_get_category_id('MSDS_INV_ITEM');
        FETCH c_get_category_id INTO l_inv_category_id;
        CLOSE c_get_category_id;

        /* Retrieve category_id for document category MSDS_REG_ITEM */
        OPEN c_get_category_id('MSDS_REG_ITEM');
        FETCH c_get_category_id INTO l_reg_category_id;
        CLOSE c_get_category_id;

        /* While there are results that have not been migrated */
        WHILE c_get_mig_rec%FOUND LOOP

         BEGIN

             SAVEPOINT Org_Item;

             /* Retrieve regulatory item info */
             --Bug# 5293938 - close cursor if open
             IF c_get_reg_item%ISOPEN THEN
                CLOSE c_get_reg_item;
             END IF;
             OPEN c_get_reg_item;
             FETCH c_get_reg_item INTO l_reg_item_rec;

             IF c_get_reg_item%NOTFOUND THEN
                CLOSE c_get_reg_item;
                RAISE INVALID_REG_ITEM;
             END IF;

             CLOSE c_get_reg_item;

             /* Make sure that there is a CAS number */
             IF l_reg_item_rec.primary_cas_number is NULL THEN
                RAISE NO_CAS_NUMBER;
             END IF;
                --Bug# 5293938 - close cursor if open
                IF c_check_exists%ISOPEN THEN
                   CLOSE c_check_exists;
                END IF;

                OPEN c_check_exists;
                FETCH c_check_exists INTO l_inventory_item_id;

                IF c_check_exists%NOTFOUND THEN

                   INV_OPM_ITEM_MIGRATION.get_ODM_regulatory_item
                         ( p_migration_run_id  => p_migration_run_id,
                           p_item_code         => l_mig_rec.item_code,
                           p_organization_id   => l_mig_rec.organization_id,
                           p_mode              => NULL,
                           p_commit            => 'T',
                           x_inventory_item_id => l_inventory_item_id,
                           x_failure_count     => l_failure_count);

                    IF l_failure_count > 0 THEN
                       x_failure_count := x_failure_count + l_failure_count;
                       RAISE ITEM_CREATE_ERROR;
                    END IF;

                ELSE

                  GMA_COMMON_LOGGING.gma_migration_central_log (
                        p_run_id          => P_migration_run_id,
                        p_log_level       => FND_LOG.LEVEL_PROCEDURE,
                        p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
                        p_table_name      => 'GR_ITEM_GENERAL',
                        p_context         => 'REGULATORY_ITEMS',
                        p_param1          => NULL,
                        p_param2          => NULL,
                        p_param3          => NULL,
                        p_param4          => NULL,
                        p_param5          => NULL,
                        p_db_error        => NULL,
                        p_app_short_name  => 'GMA');

                END IF; -- If Item already exists
                CLOSE c_check_exists;

                /* Retrieve items UN Number */
                l_un_number_id := get_un_number_id
                                (
                                 p_item_code         => l_mig_rec.item_code,
                                 x_return_status     =>  l_return_status,
                                 x_msg_data          =>  l_msg_data
                                 );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE PROC_CALL_ERROR;
                END IF;

                /* Retrieve items UN Class */
                l_hazard_class_id := get_hazard_class_id
                                (
                                 p_item_code         => l_mig_rec.item_code,
                                 x_return_status     =>  l_return_status,
                                 x_msg_data           =>  l_msg_data
                                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE PROC_CALL_ERROR;
                END IF;

                UPDATE mtl_system_items_b
                   SET hazardous_material_flag = 'Y',
                       cas_number      = l_reg_item_rec.primary_cas_number,
                       hazard_class_id = l_hazard_class_id,
                       un_number_id    = l_un_number_id
                 WHERE organization_id   = l_mig_rec.organization_id and
                       inventory_item_id = l_inventory_item_id;


                INSERT INTO gr_item_explosion_properties
                   (
                    organization_id,
                    inventory_item_id,
                    actual_hazard,
                    ingredient_flag,
                    explode_ingredient_flag,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login
                    )
                 VALUES
                   (
                    l_mig_rec.organization_id,
                    l_inventory_item_id,
                    l_reg_item_rec.ACTUAL_HAZARD,
                    l_reg_item_rec.INGREDIENT_FLAG,
                    l_reg_item_rec.EXPLODE_INGREDIENT_FLAG,
                    l_reg_item_rec.CREATED_BY,
                    l_reg_item_rec.CREATION_DATE,
                    l_reg_item_rec.LAST_UPDATED_BY,
                    l_reg_item_rec.LAST_UPDATE_DATE,
                    l_reg_item_rec.LAST_UPDATE_LOGIN
                   );

                  OPEN c_get_translated;
                  FETCH c_get_translated INTO l_translated_rec;

                  WHILE c_get_translated%FOUND LOOP

                     /* Update the descriptions with the values from Regulatory */
  	             UPDATE mtl_system_items_tl
                        SET description = l_translated_rec.name_description,
                            source_lang = l_translated_rec.source_lang,
                            creation_date = l_translated_rec.creation_date,
                            created_by = l_translated_rec.created_by,
                            last_update_date = l_translated_rec.last_update_date,
                            last_updated_by = l_translated_rec.last_updated_by,
                            last_update_login = l_translated_rec.last_update_login
	              WHERE language = l_translated_rec.language and
                            organization_id = l_mig_rec.organization_id and
                            inventory_item_id = l_inventory_item_id;

                     FETCH c_get_translated INTO l_translated_rec;

	          END LOOP; -- tranlated descriptions
                  CLOSE c_get_translated;


                  /* Copy all of the properties to the org/item combination */
                  INSERT INTO gr_inv_item_properties
                     (
                      organization_id,
                      inventory_item_id,
                      sequence_number,
                      property_id,
                      label_code,
                      number_value,
                      alpha_value,
                      date_value,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login
                     )
                   SELECT
                      l_mig_rec.organization_id,
                      l_inventory_item_id,
                      sequence_number,
                      property_id,
                      label_code,
                      number_value,
                      alpha_value,
                      date_value,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login
                  FROM gr_item_properties
                  WHERE label_code <> '14001' and
                        label_code <> '14002' and
                        item_code =  l_reg_item_rec.item_code;


                  --Bug# 5293938 Close cursor if open
                  IF c_get_attachments%ISOPEN THEN
                     CLOSE c_get_attachments;
                  END IF;
                  OPEN c_get_attachments;
                  FETCH c_get_attachments INTO l_attachment_rec;

                  WHILE c_get_attachments%FOUND LOOP

                     /* Retrieve category_id for document category */
                     OPEN c_get_category_id(l_attachment_rec.attribute_category);
                     FETCH c_get_category_id INTO l_doc_category_id;
                     CLOSE c_get_category_id;

                     IF l_doc_category_id = l_reg_category_id THEN

                        UPDATE fnd_documents
                          SET category_id = l_inv_category_id
                        WHERE document_id = l_attachment_rec.document_id;

                        UPDATE fnd_documents_tl
                          SET doc_attribute_category = 'MSDS_INV_ITEM'
                        WHERE document_id = l_attachment_rec.document_id;

                      END IF;

                      --Bug# 5293938 Attached Document Id has to be populated from the sequence.
                      select fnd_attached_documents_s.nextval
                      into l_attached_doc_id
                      from sys.dual;

                      FND_ATTACHED_DOCUMENTS_PKG.Insert_Row(
                             X_Rowid                      => l_rowid,
                             X_attached_document_id       => l_attached_doc_id,
                             X_document_id                => l_attachment_rec.document_id,
                             X_creation_date              => l_attachment_rec.creation_date,
                             X_created_by                 => l_attachment_rec.created_by,
                             X_last_update_date           => l_attachment_rec.last_update_date,
                             X_last_updated_by            => l_attachment_rec.last_updated_by,
                             X_last_update_login          => l_attachment_rec.last_update_login,
                             X_seq_num                    => l_attachment_rec.seq_num,
                             X_entity_name                => 'MTL_SYSTEM_ITEMS',
                             X_column1                    => NULL,
                             X_pk1_value                  => l_mig_rec.organization_id,
                             X_pk2_value                  => l_inventory_item_id,
                             X_pk3_value                  => NULL,
                             X_pk4_value                  => NULL,
                             X_pk5_value                  => NULL,
                             X_automatically_added_flag   => l_attachment_rec.automatically_added_flag,
                             X_request_id                 => l_attachment_rec.request_id,
                             X_datatype_id                => NULL,
                             X_category_id                => l_attachment_rec.category_id,
                             X_security_type              => NULL,
                             X_security_id                => NULL,
                             X_publish_flag               => NULL,
                             X_storage_type               => NULL,
                             X_usage_type                 => NULL,
                             X_language                   => NULL,
                             X_description                => NULL,
                             X_file_name                  => NULL,
                             X_media_id                   => l_media_id,
                             X_attribute_category         => l_attachment_rec.attribute_category,
                             X_attribute1                 => l_attachment_rec.attribute1,
                             X_attribute2                 => l_attachment_rec.attribute2,
                             X_attribute3                 => l_attachment_rec.attribute3,
                             X_attribute4                 => l_attachment_rec.attribute4,
                             X_attribute5                 => l_attachment_rec.attribute5,
                             X_attribute6                 => l_attachment_rec.attribute6,
                             X_attribute7                 => l_attachment_rec.attribute7,
                             X_attribute8                 => l_attachment_rec.attribute8,
                             X_attribute9                 => l_attachment_rec.attribute9,
                             X_attribute10                => l_attachment_rec.attribute10,
                             X_attribute11                => l_attachment_rec.attribute11,
                             X_attribute12                => l_attachment_rec.attribute12,
                             X_attribute13                => l_attachment_rec.attribute13,
                             X_attribute14                => l_attachment_rec.attribute14,
                             X_attribute15                => l_attachment_rec.attribute15,
                             X_create_doc                 => 'N');

                     FETCH c_get_attachments INTO l_attachment_rec;

                  END LOOP;  /* Item attachments */
                  CLOSE c_get_attachments;

                  --Bug# 5293938 Close cursor if open
                  IF c_get_related%ISOPEN THEN
                     CLOSE c_get_related;
                  END IF;
                  OPEN c_get_related;
                  FETCH c_get_related INTO l_related_rec;

                  WHILE c_get_related%FOUND LOOP
                      --Bug# 5293938 get opm item id of related item
                      OPEN c_get_opm_item_id;
                      FETCH c_get_opm_item_id into l_opm_item_id;
                      IF c_get_opm_item_id%NOTFOUND THEN
                         l_msg_data := 'Related item '||l_related_rec.item_no||' not found in ic_item_mst';
                         CLOSE c_get_opm_item_id;
                         RAISE PROC_CALL_ERROR;
                      END IF;
                      CLOSE c_get_opm_item_id;

                      INV_OPM_ITEM_MIGRATION.get_ODM_item
                         ( p_migration_run_id  => p_migration_run_id,
                           p_item_id           => l_opm_item_id, --Bug# 5293938
                           p_organization_id   => l_mig_rec.organization_id,
                           p_mode              => NULL,
                           p_commit            => 'T',
                           x_inventory_item_id => l_related_item_id,
                           x_failure_count     => l_failure_count);

                      MTL_RELATED_ITEMS_PKG.Insert_Row (
                           X_Rowid               => l_rowid,
                           X_Inventory_Item_Id   => l_inventory_item_id,
                           X_Organization_Id     => l_mig_rec.organization_id,
                           X_Related_Item_Id     => l_related_item_id,
                           X_Relationship_Type_Id => 19,
                           X_Reciprocal_Flag     => 'N',
                           X_Planning_Enabled_Flag => 'N',
                           X_Start_Date          => l_related_rec.creation_date,
                           X_End_Date            => NULL,
                           X_Attr_Context	 => NULL,
                           X_Attr_Char1          => NULL,
                           X_Attr_Char2          => NULL,
                           X_Attr_Char3          => NULL,
                           X_Attr_Char4          => NULL,
                           X_Attr_Char5          => NULL,
                           X_Attr_Char6          => NULL,
                           X_Attr_Char7          => NULL,
                           X_Attr_Char8          => NULL,
                           X_Attr_Char9          => NULL,
                           X_Attr_Char10         => NULL,
                           X_Attr_Num1           => NULL,
                           X_Attr_Num2           => NULL,
                           X_Attr_Num3           => NULL,
                           X_Attr_Num4           => NULL,
                           X_Attr_Num5           => NULL,
                           X_Attr_Num6           => NULL,
                           X_Attr_Num7           => NULL,
                           X_Attr_Num8           => NULL,
                           X_Attr_Num9           => NULL,
                           X_Attr_Num10          => NULL,
                           X_Attr_Date1		 => NULL,
                           X_Attr_Date2		 => NULL,
                           X_Attr_Date3		 => NULL,
                           X_Attr_Date4		 => NULL,
                           X_Attr_Date5		 => NULL,
                           X_Attr_Date6		 => NULL,
                           X_Attr_Date7		 => NULL,
                           X_Attr_Date8		 => NULL,
                           X_Attr_Date9		 => NULL,
                           X_Attr_Date10	 => NULL,
                           X_Last_Update_Date    => l_related_rec.last_update_date,
                           X_Last_Updated_By     => l_related_rec.last_updated_by,
                           X_Creation_Date       => l_related_rec.creation_date,
                           X_Created_By          => l_related_rec.created_by,
                           X_Last_Update_Login   => l_related_rec.last_update_login,
                           X_Object_Version_Number => NULL
                      );

                  FETCH c_get_related INTO l_related_rec;
            END LOOP; -- Related Items
            CLOSE c_get_related;

            UPDATE gr_item_general_mig
              SET migration_ind = 1,
                  inventory_item_id = l_inventory_item_id
            WHERE item_code = l_mig_rec.item_code and
                  organization_id = l_mig_rec. organization_id;

            /* Issue commit if required */
            IF p_commit = FND_API.G_TRUE THEN
               COMMIT;
            END IF;

            /* Increment appropriate counter */
            IF l_mig_status = 1 THEN
               l_migration_count := l_migration_count + 1;
            ELSE
               l_exists_count := l_exists_count + 1;
            END IF;

         EXCEPTION
            WHEN INVALID_REG_ITEM THEN
               x_failure_count := x_failure_count + 1;
               GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => P_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_EXCEPTION,
                   p_message_token   => 'GR_INVALID_REG_ITEM',
                   p_table_name      => 'GR_ITEM_GENERAL',
                   p_context         => 'REGULATORY_ITEMS',
                   p_param1          => l_mig_rec.item_code,
                   p_param2          => NULL,
                   p_param3          => NULL,
                   p_param4          => NULL,
                   p_param5          => NULL,
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GR');

              ROLLBACK to SAVEPOINT Org_Item;
            --Bug# 5293938 Add this exception handler
            WHEN NO_CAS_NUMBER THEN
               x_failure_count := x_failure_count + 1;
               GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => P_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_EXCEPTION,
                   p_message_token   => 'GR_NO_CAS_NUMBER',
                   p_table_name      => 'GR_ITEM_GENERAL',
                   p_context         => 'REGULATORY_ITEMS',
                   p_param1          => l_mig_rec.item_code,
                   p_param2          => NULL,
                   p_param3          => NULL,
                   p_param4          => NULL,
                   p_param5          => NULL,
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GR');

              ROLLBACK to SAVEPOINT Org_Item;


            WHEN ITEM_CREATE_ERROR THEN
               x_failure_count := x_failure_count + 1;
               GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => P_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_EXCEPTION,
                   p_message_token   => 'GR_INV_ITEM_ERROR',
                   p_table_name      => 'GR_ITEM_GENERAL',
                   p_context         => 'REGULATORY_ITEMS',
                   p_param1          => l_mig_rec.item_code,
                   p_param2          => NULL,
                   p_param3          => NULL,
                   p_param4          => NULL,
                   p_param5          => NULL,
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GR');

              ROLLBACK to SAVEPOINT Org_Item;

            WHEN PROC_CALL_ERROR THEN
               x_failure_count := x_failure_count + 1;
               GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => P_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_EXCEPTION,
                   p_message_token   => l_msg_data,
                   p_table_name      => 'GR_ITEM_GENERAL',
                   p_context         => 'REGULATORY_ITEMS',
                   p_param1          => NULL,
                   p_param2          => NULL,
                   p_param3          => NULL,
                   p_param4          => NULL,
                   p_param5          => NULL,
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GMA');

              ROLLBACK to SAVEPOINT Org_Item;

            WHEN OTHERS THEN
               x_failure_count := x_failure_count + 1;
               GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => P_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
                   p_message_token   => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name      => 'GR_ITEM_GENERAL',
                   p_context         => 'REGULATORY_ITEMS',
                   p_param1          => NULL,
                   p_param2          => NULL,
                   p_param3          => NULL,
                   p_param4          => NULL,
                   p_param5          => NULL,
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GMA');

              ROLLBACK to SAVEPOINT Org_Item;

           END; -- Subprogram

           FETCH c_get_mig_rec into l_mig_rec;

       END LOOP; -- Records in migration table
       CLOSE c_get_mig_rec;

    END IF; -- Unmigrated records found

    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'GR_ITEM_GENERAL',
       p_context         => 'REGULATORY_ITEMS',
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
          p_table_name      => 'GR_ITEM_GENERAL',
          p_context         => 'REGULATORY_ITEMS',
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
          p_table_name      => 'GR_ITEM_GENERAL',
          p_context         => 'REGULATORY_ITEMS',
          p_param1          => x_failure_count,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMA');

  END migrate_regulatory_items;


/*===========================================================================
--  PROCEDURE:
--    migrate_standalone_formulas
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate standalone Regulatory formulas
--    to the formula, recipe and validity rules table.
--
--  PARAMETERS:
--    p_migration_run_id  - Migration run id to be used for writing  to the message log
--    p_commit            - Indicates if commit should be issued after logical unit is migrated
--    x_failure_count     - Returns the number of failures that occurred during migration
--
--  SYNOPSIS:
--    migrate_standalone_formulas(
--                         p_migration_run_id => migration_id,
--                         p_commit           => 'Y',
--                         x_failure_count    => failure_count );
--
--  HISTORY
--    M. Grosser  17-May-2005   Created
--=========================================================================== */
  PROCEDURE migrate_standalone_formulas
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  ) IS

   /*  ------------- LOCAL VARIABLES ------------------- */
     l_temp                NUMBER;
     l_rowid               VARCHAR2(2000);
     l_migration_count     NUMBER := 0;
     l_failure_count       NUMBER := 0;
     l_exists_count        NUMBER := 0;
     l_item_code           VARCHAR2(32);
     l_uom_type            sy_uoms_typ.um_type%TYPE;
     l_uom                 VARCHAR2(4);
     l_owner_org           sy_orgn_mst.orgn_code%TYPE;
     l_owner_org_id        sy_orgn_mst.organization_id%TYPE;
     l_inventory_item_id   NUMBER;
     l_text                VARCHAR2(80);
     l_line_no             NUMBER;
     l_formula_id          NUMBER;
     l_formulaline_id      NUMBER;
     l_recipe_id           NUMBER;
     l_validity_rule_id    NUMBER;
     l_prod_primary_uom    VARCHAR2(4);
     l_ing_primary_uom     VARCHAR2(4);
     l_formula_vers        NUMBER;
     l_recipe_vers         NUMBER;
     l_prod_item_id        NUMBER;
     l_ing_item_id         NUMBER;
     l_mig_status          NUMBER;
     l_return_status       VARCHAR2(2);
     l_msg_data            VARCHAR2(2000);
     l_recipe_type         NUMBER;
     l_inv_qty             NUMBER;

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used to retrieve items with formula type of standalone that have formulas saved */
     CURSOR c_get_items IS
        SELECT a.item_code
          FROM gr_item_general a
         WHERE EXISTS (SELECT 1
                         FROM gr_item_concentrations b
                        WHERE b.item_code = a.item_code) and
               a.formula_source_indicator = 'S';

     /* Cursor used to retrieve profile value at site level  */
     CURSOR c_get_profile_value(v_profile_name VARCHAR2) IS
       SELECT profile_option_value
         FROM fnd_profile_options a, fnd_profile_option_values b
        WHERE b.level_id = 10001 and
              a.profile_option_id = b.profile_option_id and
              a.profile_option_name = v_profile_name;

     /* Cursor used to retrieve the std uom for FM_YIELD_TYPE class */
     CURSOR c_get_uom (v_um_type VARCHAR2) IS
           SELECT std_um
             FROM sy_uoms_typ
            WHERE um_type = v_um_type;

     /* Cursor used to retrieve concentration records for item */
     CURSOR c_get_item_concentrations IS
       SELECT *
         FROM gr_item_concentrations
        WHERE migration_ind is NULL and
              item_code = l_item_code;
     l_conc_rec       c_get_item_concentrations%ROWTYPE;

     /* Cursor used to retrieve next formula version */
     CURSOR c_get_formula_vers IS
        SELECT MAX(formula_vers) + 1
          FROM fm_form_mst_b
         WHERE formula_no = l_item_code;

     /* Cursor used to retrieve next recipe version */
     CURSOR c_get_recipe_vers IS
        SELECT MAX(recipe_version) + 1
         FROM gmd_recipes_b
         WHERE recipe_no = l_item_code;

     /* Cursor used to retrieve organization_id */
     CURSOR c_get_organization_id (v_org_code VARCHAR2) IS
        SELECT organization_id
         FROM sy_orgn_mst
         WHERE orgn_code = v_org_code;

     /* Cursor used to retrieve items primary_uom */
     CURSOR c_get_primary_uom (v_organization_id NUMBER, v_inventory_item_id NUMBER) IS
        SELECT primary_uom_code
          FROM mtl_system_items_b
         WHERE organization_id = v_organization_id and
               inventory_item_id = v_inventory_item_id;

     /* Cursor used to retrieve next formula_id value */
     CURSOR c_get_formula_id IS
        SELECT gem5_formula_id_s.NEXTVAL
         FROM SYS.DUAL;

     /* Cursor used to retrieve next formulaline_id value */
     CURSOR c_get_formulaline_id IS
        SELECT gem5_formulaline_id_s.NEXTVAL
         FROM SYS.DUAL;

     /* Cursor used to retrieve next recipe_id value */
     CURSOR c_get_recipe_id IS
        SELECT gmd_recipe_id_s.NEXTVAL
         FROM SYS.DUAL;

     /* Cursor used to retrieve next recipe_vr_id value */
     CURSOR c_get_recipe_vr_id IS
        SELECT gmd_recipe_validity_id_s.NEXTVAL
         FROM SYS.DUAL;

     /*  ------------------- EXCEPTIONS -------------------- */
     PROC_CALL_ERROR         EXCEPTION;
     ORGN_NOT_MIGRATED	     EXCEPTION;
     NO_UOM_CONVERSION       EXCEPTION;

  BEGIN

     x_failure_count := 0;

     GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GR_ITEM_CONCENTRATIONS',
       p_context         => 'STANDALONE_FORMULAS',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');

      /* Retrieve default Regulatory org to use as owner org for formulas */
      OPEN  c_get_profile_value('GR_ORGN_DEFAULT');
      FETCH c_get_profile_value INTO l_owner_org;
      CLOSE c_get_profile_value;

      /* Retrieve organization_id to use as owner org for formulas */
      OPEN  c_get_organization_id(l_owner_org);
      FETCH c_get_organization_id INTO l_owner_org_id;
      CLOSE c_get_organization_id;

      IF (l_owner_org_id IS NULL) THEN
         RAISE ORGN_NOT_MIGRATED;
      END IF;


      /* Retrieve yield type to use to retrieve default uom */
      OPEN  c_get_profile_value('FM_YIELD_TYPE');
      FETCH c_get_profile_value INTO l_uom_type;
      CLOSE c_get_profile_value;

      /* Retrieve default uom */
      OPEN  c_get_uom(l_uom_type);
      FETCH c_get_uom INTO l_uom;
      CLOSE c_get_uom;

      /* Retrieve description text for formula and recipe  */
      FND_MESSAGE.SET_NAME('GR','GR_DESC_TEXT');
      l_text := FND_MESSAGE.GET;

      /* Select items that have a formula source of Standalone */
      OPEN c_get_items;
      FETCH c_get_items into l_item_code;

      /* While items are found */
      WHILE c_get_items%FOUND LOOP
      BEGIN
         SAVEPOINT Standalone_Formula;

         /* Select items that have a formula source of Standalone */
          --Bug# 5293938 Since its in a loop close it before reopening it.
         IF c_get_item_concentrations%ISOPEN THEN
            CLOSE c_get_item_concentrations;
         END IF;
         OPEN c_get_item_concentrations;
         FETCH c_get_item_concentrations into l_conc_rec;

         IF c_get_item_concentrations%FOUND THEN

            l_prod_item_id := get_inventory_item_id
                            (
                              p_organization_id => l_owner_org_id,
                              p_item_code       => l_item_code,
                              x_return_status   => l_return_status,
                              x_msg_data        => l_msg_data
                             );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE PROC_CALL_ERROR;
            END IF;

            /* Retrieve product's primary uom */
            OPEN  c_get_primary_uom(l_owner_org_id, l_prod_item_id);
            FETCH c_get_primary_uom INTO l_prod_primary_uom;
            CLOSE  c_get_primary_uom;

            /* If the item's primary uom is not equal to the formula uom */
            IF l_prod_primary_uom <> l_uom THEN
               l_inv_qty := INV_CONVERT.inv_um_convert
                            (
                            item_id => l_prod_item_id,
                            precision => 5,
                            from_quantity => 100,
                            from_unit => l_prod_primary_uom,
                            to_unit => l_uom,
                            from_name => NULL,
                            to_name => NULL
                             );

               IF l_inv_qty = -99999 THEN
                  RAISE NO_UOM_CONVERSION;
               END IF;
             ELSE
               l_inv_qty := 100;
            END IF; -- Item's primary uom <> formula uom

            /* Retrieve formula version */
            OPEN  c_get_formula_vers;
            FETCH c_get_formula_vers INTO l_formula_vers;

            --Bug# 5293938 added is null condition since group functions do not raise notfound
            IF c_get_formula_vers%NOTFOUND OR l_formula_vers IS NULL THEN
               l_formula_vers := 1;
            END IF;
            CLOSE  c_get_formula_vers;

            /* Retrieve recipe version */
            OPEN  c_get_recipe_vers;
            FETCH c_get_recipe_vers INTO l_recipe_vers;
            --Bug# 5293938 added is null condition since group functions do not raise notfound
            IF c_get_recipe_vers%NOTFOUND OR l_recipe_vers IS NULL THEN
               l_recipe_vers := 1;
            END IF;
            CLOSE  c_get_recipe_vers;

            /* Retrieve formula id */
            OPEN c_get_formula_id;
            FETCH c_get_formula_id INTO l_formula_id;
            CLOSE c_get_formula_id;

            /* Create formula header record and translated records */
            FM_FORM_MST_MLS.INSERT_ROW(
                    X_ROWID                   => l_rowid,
                    X_FORMULA_ID              => l_formula_id,
                    X_MASTER_FORMULA_ID       => NULL,
                    X_OWNER_ORGANIZATION_ID   => l_owner_org_id,
                    X_TOTAL_INPUT_QTY         => 100,
                    X_TOTAL_OUTPUT_QTY        => 100,
                    X_YIELD_UOM               => l_uom,
                    X_FORMULA_STATUS          => '700',
                    X_OWNER_ID                => l_conc_rec.last_updated_by,
                    X_PROJECT_ID              => NULL,
                    X_TEXT_CODE               => NULL,
                    X_DELETE_MARK             => 0,
                    X_FORMULA_NO              => l_item_code,
                    X_FORMULA_VERS            => l_formula_vers,
                    X_FORMULA_TYPE            => 0,
                    X_IN_USE                  => NULL,
                    X_INACTIVE_IND            => 0,
                    X_SCALE_TYPE              => 0,
                    X_FORMULA_CLASS           => NULL,
                    X_FMCONTROL_CLASS         => NULL,
                    X_ATTRIBUTE_CATEGORY      => NULL,
                    X_ATTRIBUTE1              => NULL,
                    X_ATTRIBUTE2              => NULL,
                    X_ATTRIBUTE3              => NULL,
                    X_ATTRIBUTE4              => NULL,
                    X_ATTRIBUTE5              => NULL,
                    X_ATTRIBUTE6              => NULL,
                    X_ATTRIBUTE7              => NULL,
                    X_ATTRIBUTE8              => NULL,
                    X_ATTRIBUTE9              => NULL,
                    X_ATTRIBUTE10             => NULL,
                    X_ATTRIBUTE11             => NULL,
                    X_ATTRIBUTE12             => NULL,
                    X_ATTRIBUTE13             => NULL,
                    X_ATTRIBUTE14             => NULL,
                    X_ATTRIBUTE15             => NULL,
                    X_ATTRIBUTE16             => NULL,
                    X_ATTRIBUTE17             => NULL,
                    X_ATTRIBUTE18             => NULL,
                    X_ATTRIBUTE19             => NULL,
                    X_ATTRIBUTE20             => NULL,
                    X_ATTRIBUTE21             => NULL,
                    X_ATTRIBUTE22             => NULL,
                    X_ATTRIBUTE23             => NULL,
                    X_ATTRIBUTE24             => NULL,
                    X_ATTRIBUTE25             => NULL,
                    X_ATTRIBUTE26             => NULL,
                    X_ATTRIBUTE27             => NULL,
                    X_ATTRIBUTE28             => NULL,
                    X_ATTRIBUTE29             => NULL,
                    X_ATTRIBUTE30             => NULL,
                    X_FORMULA_DESC1           => l_text || ' ' || l_item_code,
                    X_FORMULA_DESC2           => NULL,
                    X_CREATION_DATE           => l_conc_rec.creation_date,
                    X_CREATED_BY              => l_conc_rec.created_by,
                    X_LAST_UPDATE_DATE        => l_conc_rec.last_update_date,
                    X_LAST_UPDATED_BY         => l_conc_rec.last_updated_by,
                    X_LAST_UPDATE_LOGIN       => l_conc_rec.last_update_login);

            IF l_rowid IS NULL THEN
                RAISE PROC_CALL_ERROR;
            END IF;

            /* Retrieve formula line id */
            OPEN c_get_formulaline_id;
            FETCH c_get_formulaline_id INTO l_formulaline_id;
            CLOSE c_get_formulaline_id;

            /* Create formula detail line for product */
            INSERT INTO fm_matl_dtl
                     (
                       FORMULALINE_ID,
                       FORMULA_ID,
                       LINE_TYPE,
                       LINE_NO,
                       INVENTORY_ITEM_ID,
                       ORGANIZATION_ID,
                       QTY,
                       DETAIL_UOM,
                       RELEASE_TYPE,
                       SCRAP_FACTOR,
                       SCALE_TYPE,
                       PHANTOM_TYPE,
                       REWORK_TYPE,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN,
                       CONTRIBUTE_STEP_QTY_IND,
                       CONTRIBUTE_YIELD_IND
                     )
                 VALUES
                     (
                       l_formulaline_id,
                       l_formula_id,
                       1,
                       1,
                       l_prod_item_id,
                       l_owner_org_id,
                       100,
                       l_uom,
                       0,
                       0,
                       1,
                       0,
                       0,
                       l_conc_rec.CREATED_BY,
                       l_conc_rec.CREATION_DATE,
                       l_conc_rec.LAST_UPDATE_DATE,
                       l_conc_rec.LAST_UPDATED_BY,
                       l_conc_rec.LAST_UPDATE_LOGIN,
                       'Y',
                       'Y'
                      );

            l_line_no := 0;

            WHILE c_get_item_concentrations%FOUND LOOP

               l_line_no := l_line_no +1;

               l_ing_item_id := get_inventory_item_id
                            (
                              p_organization_id => l_owner_org_id,
                              p_item_code       => l_conc_rec.ingredient_item_code,
                              x_return_status   => l_return_status,
                              x_msg_data        => l_msg_data
                             );

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE PROC_CALL_ERROR;
               END IF;

               /* Retrieve ingredient's primary uom */
               OPEN  c_get_primary_uom(l_owner_org_id, l_ing_item_id);
               FETCH c_get_primary_uom INTO l_ing_primary_uom;
               CLOSE  c_get_primary_uom;

               /* If the item's primary uom is not equal to the formula uom */
               IF l_prod_primary_uom <> l_uom THEN
                  l_temp := INV_CONVERT.inv_um_convert
                            (
                            item_id => l_ing_item_id,
                            precision => 5,
                            from_quantity => 1,
                            from_unit => l_ing_primary_uom,
                            to_unit => l_uom,
                            from_name => NULL,
                            to_name => NULL
                             );

                  IF l_temp = -99999 THEN
                    RAISE NO_UOM_CONVERSION;
                  END IF;

                END IF; -- Item's primary uom <> formula uom

               /* Retrieve formula line id */
               OPEN c_get_formulaline_id;
               FETCH c_get_formulaline_id INTO l_formulaline_id;
               CLOSE c_get_formulaline_id;

               INSERT INTO fm_matl_dtl
                     (
                       FORMULALINE_ID,
                       FORMULA_ID,
                       LINE_TYPE,
                       LINE_NO,
                       INVENTORY_ITEM_ID,
                       ORGANIZATION_ID,
                       QTY,
                       DETAIL_UOM,
                       RELEASE_TYPE,
                       SCRAP_FACTOR,
                       SCALE_TYPE,
                       PHANTOM_TYPE,
                       REWORK_TYPE,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN,
                       CONTRIBUTE_STEP_QTY_IND,
                       CONTRIBUTE_YIELD_IND
                     )
                  VALUES
                     (
                       l_formulaline_id,
                       l_formula_id,
                       -1,
                       l_line_no,
                       l_ing_item_id,
                       l_owner_org_id,
                       l_conc_rec.concentration_percentage,
                       l_uom,
                       0,
                       0,
                       1,
                       0,
                       0,
                       l_conc_rec.CREATED_BY,
                       l_conc_rec.CREATION_DATE,
                       l_conc_rec.LAST_UPDATE_DATE,
                       l_conc_rec.LAST_UPDATED_BY,
                       l_conc_rec.LAST_UPDATE_LOGIN,
                       'Y',
                       'Y'
                      );

            FETCH c_get_item_concentrations into l_conc_rec;

         END LOOP; -- Item concentration recs
         CLOSE c_get_item_concentrations;

         /* Retrieve recipe id */
         OPEN c_get_recipe_id;
         FETCH c_get_recipe_id INTO l_recipe_id;
         CLOSE c_get_recipe_id;

         /* Create the recipe */
         GMD_RECIPES_MLS.INSERT_ROW(
                    X_ROWID 		      => l_rowid,
                    X_RECIPE_ID 	      => l_recipe_id,
                    X_OWNER_ID 	              => l_conc_rec.last_updated_by,
                    X_OWNER_LAB_TYPE 	      => NULL,
                    X_DELETE_MARK 	      => 0,
                    X_TEXT_CODE               => NULL,
                    X_RECIPE_NO 	      => l_item_code,
                    X_RECIPE_VERSION 	      => l_recipe_vers,
                    X_OWNER_ORGANIZATION_ID   => l_owner_org_id,
                    X_CREATION_ORGANIZATION_ID => l_owner_org_id,
                    X_FORMULA_ID              => l_formula_id,
                    X_ROUTING_ID 	      => NULL,
                    X_PROJECT_ID 	      => NULL,
                    X_RECIPE_STATUS 	      => '700',
                    X_RECIPE_TYPE 	      => 1,
                    X_ENHANCED_PI_IND         => NULL,
                    X_CALCULATE_STEP_QUANTITY => 0,
                    X_PLANNED_PROCESS_LOSS    => NULL,
                    X_CONTIGUOUS_IND          => NULL,
                    X_RECIPE_DESCRIPTION      => l_text || ' ' || l_item_code,
                    X_ATTRIBUTE_CATEGORY      => NULL,
                    X_ATTRIBUTE1              => NULL,
                    X_ATTRIBUTE2              => NULL,
                    X_ATTRIBUTE3              => NULL,
                    X_ATTRIBUTE4              => NULL,
                    X_ATTRIBUTE5              => NULL,
                    X_ATTRIBUTE6              => NULL,
                    X_ATTRIBUTE7              => NULL,
                    X_ATTRIBUTE8              => NULL,
                    X_ATTRIBUTE9              => NULL,
                    X_ATTRIBUTE10             => NULL,
                    X_ATTRIBUTE11             => NULL,
                    X_ATTRIBUTE12             => NULL,
                    X_ATTRIBUTE13             => NULL,
                    X_ATTRIBUTE14             => NULL,
                    X_ATTRIBUTE15             => NULL,
                    X_ATTRIBUTE16             => NULL,
                    X_ATTRIBUTE17             => NULL,
                    X_ATTRIBUTE18             => NULL,
                    X_ATTRIBUTE19             => NULL,
                    X_ATTRIBUTE20             => NULL,
                    X_ATTRIBUTE21             => NULL,
                    X_ATTRIBUTE22             => NULL,
                    X_ATTRIBUTE23             => NULL,
                    X_ATTRIBUTE24             => NULL,
                    X_ATTRIBUTE25             => NULL,
                    X_ATTRIBUTE26             => NULL,
                    X_ATTRIBUTE27             => NULL,
                    X_ATTRIBUTE28             => NULL,
                    X_ATTRIBUTE29             => NULL,
                    X_ATTRIBUTE30             => NULL,
                    X_CREATION_DATE           => l_conc_rec.creation_date,
                    X_CREATED_BY              => l_conc_rec.created_by,
                    X_LAST_UPDATE_DATE        => l_conc_rec.last_update_date,
                    X_LAST_UPDATED_BY         => l_conc_rec.last_updated_by,
                    X_LAST_UPDATE_LOGIN       => l_conc_rec.last_update_login,
                    X_FIXED_PROCESS_LOSS      => 0 , /* 7582454*/
  									X_FIXED_PROCESS_LOSS_UOM  => NULL    /* 7582454*/
                   );

            IF l_rowid IS NULL THEN
                RAISE PROC_CALL_ERROR;
            END IF;

            /* Retrieve recipe validity rule id */
            OPEN c_get_recipe_vr_id;
            FETCH c_get_recipe_vr_id INTO l_validity_rule_id;
            CLOSE c_get_recipe_vr_id;

            /* Create validity rule for new recipe */
            INSERT INTO gmd_recipe_validity_rules
                     (
                       RECIPE_VALIDITY_RULE_ID,
                       RECIPE_ID,
                       ORGN_CODE,
                       RECIPE_USE,
                       PREFERENCE,
                       START_DATE,
                       END_DATE,
                       MIN_QTY,
                       MAX_QTY,
                       STD_QTY,
                       DETAIL_UOM,
                       INV_MIN_QTY,
                       INV_MAX_QTY,
                       DELETE_MARK,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_LOGIN,
                       VALIDITY_RULE_STATUS,
                       LAB_TYPE,
                       ORGANIZATION_ID,
                       INVENTORY_ITEM_ID
                      )
                   VALUES
                     (
                       l_validity_rule_id,
                       l_recipe_id,
                       NULL,
                       3,
                       1,
                       l_conc_rec.creation_date,
                       NULL,
                       100,
                       100,
                       100,
                       l_uom,
                       l_inv_qty,
                       l_inv_qty,
                       0,
                       l_conc_rec.CREATED_BY,
                       l_conc_rec.CREATION_DATE,
                       l_conc_rec.LAST_UPDATE_DATE,
                       l_conc_rec.LAST_UPDATED_BY,
                       l_conc_rec.LAST_UPDATE_LOGIN,
                       700,
                       NULL,
                       l_owner_org_id,
                       l_prod_item_id
                     );


         UPDATE gr_item_concentrations
           SET migration_ind = 1
         WHERE item_code = l_item_code;

         /* Issue commit if required */
         IF p_commit = FND_API.G_TRUE THEN
            COMMIT;
         END IF;

       END IF; -- If concentration record found

       EXCEPTION
            WHEN PROC_CALL_ERROR THEN
               x_failure_count := x_failure_count + 1;

               GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => P_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_EXCEPTION,
                   p_message_token   => l_msg_data,
                   p_table_name      => 'GR_ITEM_CONCENTRATIONS',
                   p_context         => 'STANDALONE_FORMULAS',
                   p_param1          => NULL,
                   p_param2          => NULL,
                   p_param3          => NULL,
                   p_param4          => NULL,
                   p_param5          => NULL,
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GMA');

              ROLLBACK to SAVEPOINT Standalone_Formula;

            WHEN NO_UOM_CONVERSION THEN
               x_failure_count := x_failure_count + 1;

               GMA_COMMON_LOGGING.gma_migration_central_log (
                   p_run_id          => P_migration_run_id,
                   p_log_level       => FND_LOG.LEVEL_EXCEPTION,
                   p_message_token   => l_msg_data,
                   p_table_name      => 'GR_ITEM_CONCENTRATIONS',
                   p_context         => 'STANDALONE_FORMULAS',
                   p_param1          => NULL,
                   p_param2          => NULL,
                   p_param3          => NULL,
                   p_param4          => NULL,
                   p_param5          => NULL,
                   p_db_error        => SQLERRM,
                   p_app_short_name  => 'GMA');

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

              ROLLBACK to SAVEPOINT Standalone_Formula;
      END; -- Subprogram

      FETCH c_get_items into l_item_code;

    END LOOP; -- Items with standalone formula source
    CLOSE c_get_items;

    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'GR_ITEM_CONCENTRATIONS',
       p_context         => 'STANDALONE_FORMULAS',
       p_param1          => l_migration_count,
       p_param2          => x_failure_count,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');


  EXCEPTION
    WHEN ORGN_NOT_MIGRATED THEN
      x_failure_count := x_failure_count + l_failure_count;
      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMA_ORG_NOT_MIGRATED',
          p_table_name      => 'GR_ITEM_CONCENTRATIONS',
          p_context         => 'STANDALONE_FORMULAS',
	  p_token1          => 'ORGANIZATION',
          p_param1          => l_owner_org,
          p_app_short_name  => 'GR');

     WHEN OTHERS THEN
        x_failure_count := x_failure_count + 1;

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'GR_ITEM_CONCENTRATIONS',
          p_context         => 'STANDALONE_FORMULAS',
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
          p_table_name      => 'GR_ITEM_CONCENTRATIONS',
          p_context         => 'STANDALONE_FORMULAS',
          p_param1          => x_failure_count,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMA');

  END migrate_standalone_formulas;



/*===========================================================================
--  PROCEDURE:
--    update_dispatch_history
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to update the organization_id and
--    inventory_item_id columns in the gr_dispatch_history table if the
--    values are NULL.
--
--  PARAMETERS:
--    p_migration_run_id  - Migration run id to be used for writing  to the message log
--    p_commit            - Indicates if commit should be issued after logical unit is migrated
--    x_failure_count     - Returns the number of failures that occurred during migration
--
--  SYNOPSIS:
--    update_dispatch_history(
--                         p_migration_run_id => migration_id,
--                         p_commit           => 'Y',
--                         x_failure_count    => failure_count );
--
--  HISTORY
--    M. Grosser  17-May-2005   Created
--=========================================================================== */
  PROCEDURE update_dispatch_history
  (
      p_migration_run_id    IN         NUMBER,
      p_commit              IN         VARCHAR2,
      x_failure_count       OUT NOCOPY NUMBER
  ) IS
   /*  ------------- LOCAL VARIABLES ------------------- */
     l_seq                 NUMBER;
     l_mig_status          NUMBER;
     l_migration_count     NUMBER := 0;
     l_default_org         VARCHAR2(4);
     l_default_org_id      NUMBER;
     l_doc_org             VARCHAR2(4);
     l_org_id              NUMBER;
     l_return_status       VARCHAR2(2);
     l_msg_data            VARCHAR2(2000);
     l_inv_item_id         NUMBER;

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used retrieve the default organization code  */
     CURSOR c_get_default_org IS
       SELECT profile_option_value
         FROM fnd_profile_options a, fnd_profile_option_values b
        WHERE b.level_id = 10001 and
              a.profile_option_id = b.profile_option_id and
              a.profile_option_name = 'GR_ORGN_DEFAULT';

     /* Cursor used retrieve organization id  */
     CURSOR c_get_org_id (v_orgn_code VARCHAR2) IS
       SELECT organization_id
         FROM sy_orgn_mst_b
        WHERE orgn_code = v_orgn_code;

     /* Cursor used retrieve the records that don't have an organization id */
     CURSOR c_get_disp_rec IS
       SELECT dispatch_history_id, item, document_id
         FROM gr_dispatch_history
        WHERE organization_id is NULL;
     l_dispatch_rec   c_get_disp_rec%ROWTYPE;

     /* Cursor used retrieve the organization_code from the document */
     CURSOR c_get_doc_org IS
       SELECT doc_attribute5
         FROM fnd_documents_tl
        WHERE language = userenv('LANG') and
              document_id = l_dispatch_rec.document_id;

     /*  ----------------- EXCEPTIONS -------------------- */
      INVALID_ORG_ITEM   EXCEPTION;

  BEGIN

     x_failure_count := 0;

     GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'GR_DISPATCH_HISTORY',
       p_context         => 'UPDATE_DISPATCH_HISTORY',
       p_param1          => NULL,
       p_param2          => NULL,
       p_param3          => NULL,
       p_param4          => NULL,
       p_param5          => NULL,
       p_db_error        => NULL,
       p_app_short_name  => 'GMA');

     /* Retrieve default org */
     OPEN c_get_default_org;
     FETCH c_get_default_org into l_default_org;
     CLOSE c_get_default_org;

     /* Retrieve organization id for default org */
     OPEN c_get_org_id(l_default_org);
     FETCH c_get_org_id into l_default_org_id;
     CLOSE c_get_org_id;

     /* Retrieve organization id for default org */
     OPEN c_get_disp_rec;
     FETCH c_get_disp_rec into l_dispatch_rec;

     WHILE c_get_disp_rec%FOUND LOOP

       BEGIN

          /* Retrieve organization id for default org */
          OPEN c_get_doc_org;
          FETCH c_get_doc_org into l_doc_org;
          CLOSE c_get_doc_org;

          /* Retrieve organization id for default org */
          OPEN c_get_org_id(l_doc_org);
          FETCH c_get_org_id into l_org_id;

          IF c_get_org_id%NOTFOUND THEN
             l_org_id := l_default_org_id;
          END IF;

          CLOSE c_get_org_id;

          l_inv_item_id := get_inventory_item_id
                         (
                          p_organization_id => l_org_id,
                          p_item_code       => l_dispatch_rec.item,
                          x_return_status   =>  l_return_status,
                          x_msg_data        =>  l_msg_data
                          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE INVALID_ORG_ITEM;
          END IF;

          UPDATE gr_dispatch_history
             SET organization_id = l_org_id,
                 inventory_item_id = l_inv_item_id
           WHERE dispatch_history_id = l_dispatch_rec.dispatch_history_id;

          /* Issue commit if required */
          IF p_commit = FND_API.G_TRUE THEN
             COMMIT;
          END IF;

          l_migration_count := l_migration_count + 1;

       EXCEPTION

         WHEN INVALID_ORG_ITEM THEN
            x_failure_count := x_failure_count + 1;

            GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => P_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_EXCEPTION,
              p_message_token   => 'GR_INVALID_ORG_ITEM',
              p_table_name      => 'GR_DISPATCH_HISTORY',
              p_context         => 'UPDATE_DISPATCH_HISTORY',
              p_param1          => l_org_id,
              p_param2          => l_dispatch_rec.item,
              p_param3          => NULL,
              p_param4          => NULL,
              p_param5          => NULL,
              p_db_error        => SQLERRM,
              p_app_short_name  => 'GR');

         WHEN OTHERS THEN
            x_failure_count := x_failure_count + 1;

            GMA_COMMON_LOGGING.gma_migration_central_log (
              p_run_id          => P_migration_run_id,
              p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
              p_message_token   => 'GMA_MIGRATION_DB_ERROR',
              p_table_name      => 'GR_DISPATCH_HISTORY',
              p_context         => 'UPDATE_DISPATCH_HISTORY',
              p_param1          => NULL,
              p_param2          => NULL,
              p_param3          => NULL,
              p_param4          => NULL,
              p_param5          => NULL,
              p_db_error        => SQLERRM,
              p_app_short_name  => 'GMA');

       END;

       FETCH c_get_disp_rec into l_dispatch_rec;

    END LOOP;

    CLOSE c_get_disp_rec;

    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => P_migration_run_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'GR_DISPATCH_HISTORY',
       p_context         => 'UPDATE_DISPATCH_HISTORY',
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
          p_table_name      => 'GR_DISPATCH_HISTORY',
          p_context         => 'UPDATE_DISPATCH_HISTORY',
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
          p_table_name      => 'GR_DISPATCH_HISTORY',
          p_context         => 'UPDATE_DISPATCH_HISTORY',
          p_param1          => x_failure_count,
          p_param2          => NULL,
          p_param3          => NULL,
          p_param4          => NULL,
          p_param5          => NULL,
          p_db_error        => NULL,
          p_app_short_name  => 'GMA');

  END update_dispatch_history;



END GR_MIGRATE_TO_12;

/
