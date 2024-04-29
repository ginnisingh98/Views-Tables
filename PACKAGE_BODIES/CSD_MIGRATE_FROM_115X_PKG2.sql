--------------------------------------------------------
--  DDL for Package Body CSD_MIGRATE_FROM_115X_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MIGRATE_FROM_115X_PKG2" AS
/* $Header: csdmig2b.pls 115.5 2004/06/22 18:49:20 sragunat noship $ */

PROCEDURE csd_repairs_mig2(p_slab_number IN NUMBER) IS

  Type NumTabType is VARRAY(10000) of  NUMBER;
  repair_line_id_mig                   NumTabType;

  Type RowidTabType is VARRAY(1000) of VARCHAR2(30);
  rowid_mig                            RowidTabtype;

  v_min                                NUMBER;
  v_max                                NUMBER;
  v_error_text                         VARCHAR2(2000);
  MAX_BUFFER_SIZE                      NUMBER := 500;

  l_currency_code                      VARCHAR2(15);

  error_process                         exception;

  CURSOR csd_repairs_cursor (p_start number, p_end number) is
  select cr.repair_line_id,
         cr.rowid
  from   csd_repairs cr
  where  cr.currency_code IS NULL
   and   cr.repair_line_id >= p_start
   and   cr.repair_line_id <= p_end;

BEGIN

  -- Get the Slab Number for the table
  Begin
	   CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIRS'
      							  ,'CSD'
							       ,p_slab_number
							       ,v_min
							       ,v_max);
        if v_min is null then
            return;
    	   end if;
  End;

-- Commented for the bug 3054706. Forward Ported as part of Bug 3714442
/*
  BEGIN

    select gl.currency_code
      into l_currency_code
    from   gl_sets_of_books gl, hr_operating_units ou
    where  ou.organization_id = cs_std.get_item_valdn_orgzn_id
    and    ou.set_of_books_id = gl.set_of_books_id;

  exception
    when no_data_found then
      null;
    when others then
      null;
  END;
*/

  -- Migration code for CSD_REPAIRS
   OPEN csd_repairs_cursor(v_min,v_max);
   LOOP
      FETCH csd_repairs_cursor bulk collect into
                     repair_line_id_mig,
                     rowid_mig
                     LIMIT MAX_BUFFER_SIZE;

        FOR j in 1..repair_line_id_mig.count
	   LOOP
          SAVEPOINT CSD_REPAIRS;

          -- Added for the bug 3054706. Forward Ported as part of Bug 3714442
           BEGIN

              select distinct currency_code
              into   l_currency_code
              from   cs_estimate_details
              where  source_id = repair_line_id_mig(j)
              and    source_code = 'DR';

           exception
              when no_data_found then
                 -- Meaning no charge lines exists for the repair order
                 l_currency_code := NULL;
              when too_many_rows then
                 -- Meaning charge lines for the repair order are
                 -- in more than one distinct currencies.
                 l_currency_code := NULL;
              when others then
                 l_currency_code := NULL;
           END;

          IF l_currency_code IS NOT NULL THEN


             Begin

               UPDATE csd_repairs
               SET   currency_code       = l_currency_code,
                     last_update_date    = sysdate,
				 last_updated_by     = fnd_global.user_id,
				 last_update_login   = fnd_global.login_id
               WHERE  rowid = rowid_mig(j);

               IF SQL%NOTFOUND then
                  Raise error_process;
		    End If;

             Exception

		  When error_process then
                 ROLLBACK to CSD_REPAIRS;
                 v_error_text := substr(sqlerrm,1,1000)||'Repair Line Id:'||repair_line_id_mig(j);
                 INSERT INTO CSD_UPG_ERRORS
		          (ORIG_SYSTEM_REFERENCE,
          	      TARGET_SYSTEM_REFERENCE,
		           ORIG_SYSTEM_REFERENCE_ID,
		           UPGRADE_DATETIME,
		           ERROR_MESSAGE,
		           MIGRATION_PHASE)
                 VALUES( 'CSD_REPAIRS'
          	     ,'CSD_REPAIRS'
	     	     ,repair_line_id_mig(j)
		          ,sysdate
	               ,v_error_text
	      	     ,'11.5.9'  );

                  commit;
                  raise_application_error( -20000, 'Error while migrating CSD_REPAIRS table data: Error while updating CSD_REPAIRS. '|| v_error_text);


               End;
           END IF; -- l_currency_code IS NOT NULL

	   END LOOP;

      COMMIT;
      EXIT WHEN csd_repairs_cursor%notfound;
    END LOOP;

    if csd_repairs_cursor%isopen then
       close csd_repairs_cursor;
    end if;

    COMMIT;

END csd_repairs_mig2;


/*-------------------------------------------------------------------------------*/
/* procedure name: insert_rep_typ_sar                                            */
/* description   : procedure for inserting Material , Labor and Expense SAR      */
/*                 data into CSD_REPAIR_TYPES_SAR table in 11.5.9                */
/*-------------------------------------------------------------------------------*/
  PROCEDURE insert_rep_typ_sar( p_repair_type_id          IN NUMBER
                               ,p_txn_billing_type_id IN NUMBER
                               ,p_created_by              IN NUMBER
                               ,p_creation_date           IN DATE)
  IS
    l_user_id                NUMBER := fnd_global.user_id;
    l_count                  NUMBER;
    v_error_text             VARCHAR2(2000);

  BEGIN

     begin

       -- check if the repair type and billing txn type id not yet inserted into CSD_REPAIR_TYPES_SAR
       select count(*)
         into l_count
         from CSD_REPAIR_TYPES_SAR
        where REPAIR_TYPE_ID = p_repair_type_id
          and TXN_BILLING_TYPE_ID = p_txn_billing_type_id;
     exception
        WHEN OTHERS THEN
          l_count := 2; -- error handling can be anything but zero
     end;

     -- if l_count = 0 then it is not yet inserted
     if (l_count = 0) then

        SAVEPOINT REPAIR_TYPES_SAR;

        BEGIN

        -- inserted into CSD_REPAIR_TYPES_SAR
        insert into CSD_REPAIR_TYPES_SAR
                    ( REPAIR_TXN_BILLING_TYPE_ID
                     ,REPAIR_TYPE_ID
                     ,TXN_BILLING_TYPE_ID
                     ,CREATED_BY
                     ,CREATION_DATE
                     ,LAST_UPDATED_BY
                     ,LAST_UPDATE_DATE
                     ,OBJECT_VERSION_NUMBER
                     ) VALUES
                    ( CSD_REPAIR_TYPES_SAR_S1.NEXTVAL
                     ,p_repair_type_id
                     ,p_txn_billing_type_id
                     ,p_created_by
                     ,p_creation_date
                     ,l_user_id
                     ,SYSDATE
                     ,1
                     );

        EXCEPTION
          WHEN OTHERS THEN
            v_error_text := substr(SQLERRM,2000);
            ROLLBACK to REPAIR_TYPES_SAR;
            INSERT INTO csd_upg_errors
                        (orig_system_reference,
                        target_system_reference,
                        orig_system_reference_id,
                        upgrade_datetime,
                        error_message,
                        migration_phase)
                VALUES ('CS_REPAIR_TYPES_B',
                        'CSD_REPAIR_TYPES_SAR',
                        p_repair_type_id,
                        sysdate,
                        v_error_text,
                        '11.5.9');

				commit;

                raise_application_error( -20000, 'Error while migrating CSD_REPAIR_TYPES_B table data: Error while inserting into CSD_REPAIR_TYPES_SAR. '|| v_error_text);

        END;

     end if;

    COMMIT;

  END insert_rep_typ_sar;

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_TYPES_B_MIG2                                       */
/* description   : procedure for migrating Material , Labor and Expense SAR      */
/*                 data in CSD_REPAIR_TYPES_B table in 11.5.8                    */
/*                 to CSD_REPAIR_TYPES_SAR table in 11.5.9                       */
/*-------------------------------------------------------------------------------*/

  PROCEDURE CSD_REPAIR_TYPES_B_MIG2 IS

    l_repair_type_id          CSD_REPAIR_TYPES_B.REPAIR_TYPE_ID%TYPE;
    l_mtl_txn_billing_type_id CSD_REPAIR_TYPES_B.MTL_TXN_BILLING_TYPE_ID%TYPE;
    l_lbr_txn_billing_type_id CSD_REPAIR_TYPES_B.LBR_TXN_BILLING_TYPE_ID%TYPE;
    l_exp_txn_billing_type_id CSD_REPAIR_TYPES_B.EXP_TXN_BILLING_TYPE_ID%TYPE;
    l_created_by              CSD_REPAIR_TYPES_B.CREATED_BY%TYPE;
    l_creation_date           CSD_REPAIR_TYPES_B.CREATION_DATE%TYPE;

  -- select repairs types which have material or
  -- Labor or Expense SAR set up in Repair Types table
  CURSOR csd_repair_types_b_cursor is
  select crtb.REPAIR_TYPE_ID,
         crtb.MTL_TXN_BILLING_TYPE_ID,
         crtb.LBR_TXN_BILLING_TYPE_ID,
         crtb.EXP_TXN_BILLING_TYPE_ID,
         crtb.CREATED_BY,
         crtb.CREATION_DATE
  from   csd_repair_types_b crtb
  where  ((crtb.MTL_TXN_BILLING_TYPE_ID IS NOT NULL) OR
           (crtb.LBR_TXN_BILLING_TYPE_ID IS NOT NULL) OR
           (crtb.EXP_TXN_BILLING_TYPE_ID IS NOT NULL))
    and  trunc(sysdate) between nvl(trunc(crtb.start_date_active),trunc(sysdate))
         and nvl(trunc(crtb.end_date_active),trunc(sysdate));

  l_error_text           VARCHAR2(2000);

  BEGIN

  -- Open the cursor and update the table
  OPEN csd_repair_types_b_cursor;

  LOOP

     FETCH csd_repair_types_b_cursor
      INTO l_repair_type_id
          ,l_mtl_txn_billing_type_id
          ,l_lbr_txn_billing_type_id
          ,l_exp_txn_billing_type_id
          ,l_created_by
          ,l_creation_date;

     EXIT WHEN csd_repair_types_b_cursor%NOTFOUND;

     -- check if the repair type and billing txn type id not yet inserted in to CSD_REPAIR_TYPES_SAR



     if (l_mtl_txn_billing_type_id is not null) then

         -- insert into CSD_REPAIR_TYPES_SAR
         insert_rep_typ_sar( l_repair_type_id
                            ,l_mtl_txn_billing_type_id
                            ,l_created_by
                            ,l_creation_date);
     end if;

     if (l_lbr_txn_billing_type_id is not null) then

         -- insert into CSD_REPAIR_TYPES_SAR
         insert_rep_typ_sar( l_repair_type_id
                            ,l_lbr_txn_billing_type_id
                            ,l_created_by
                            ,l_creation_date);
     end if;

     if (l_exp_txn_billing_type_id is not null) then

         -- insert into CSD_REPAIR_TYPES_SAR
         insert_rep_typ_sar( l_repair_type_id
                            ,l_exp_txn_billing_type_id
                            ,l_created_by
                            ,l_creation_date);
     end if;

  END LOOP;

  END CSD_REPAIR_TYPES_B_MIG2;

END CSD_Migrate_From_115X_PKG2;


/
