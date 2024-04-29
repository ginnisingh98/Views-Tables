--------------------------------------------------------
--  DDL for Package Body CSD_MIGRATE_FROM_115X_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MIGRATE_FROM_115X_PKG3" 
/* $Header: csdmig3b.pls 120.4 2008/02/15 04:03:09 takwong ship $ */
AS

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_ACT_HDR_MIG3                                       */
/* description   : procedure for migrating ACTUALS Headers data                  */
/*                 from 11.5.9 to 11.5.10                                        */
/* purpose      :  Create Repair Actual header record in CSD_REPAIR_ACTUALS      */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_repair_act_hdr_mig3(p_slab_number IN NUMBER DEFAULT 1)
        IS

        TYPE ACT_HDR_REC_ARRAY_TYPE IS VARRAY(1000) OF NUMBER;
        act_hdr_arr          ACT_HDR_REC_ARRAY_TYPE;
        v_min                NUMBER;
        v_max                NUMBER;
        v_error_text         VARCHAR2(2000);
        MAX_BUFFER_SIZE      NUMBER                 := 500;
        l_repair_actual_id   NUMBER;
        error_process         EXCEPTION;

        CURSOR get_act_hdr(p_start_rep_line_id number, p_end_rep_line_id number)
        IS
          -- gilam: changed the EXISTS query part so that the lines are not getting from
          --        csd_repair_estimate_lines_v since the view only has lines of
          --        charge line type = ESTIMATE, but we want lines that have type ACTUAL
          SELECT distinct cr.repair_line_id repair_line_id
            FROM  csd_repairs cr
                , csd_repair_estimate cre
          WHERE  cr.repair_line_id      = cre.repair_line_id
            AND EXISTS ( SELECT 'x'
                           FROM csd_repair_estimate_lines crel, cs_estimate_details ced
                          WHERE cre.repair_estimate_id = crel.repair_estimate_id
                            AND crel.estimate_detail_id = ced.estimate_detail_id
                            AND ced.order_line_id is not null)
            AND NOT EXISTS ( SELECT 'x'
                               FROM csd_repair_actuals cra
                              WHERE cr.repair_line_id = cra.repair_line_id)
            AND cr.repair_line_id >= p_start_rep_line_id
            AND cr.repair_line_id <= p_end_rep_line_id;

    BEGIN
        -- Get the Slab Number for the table

        BEGIN

            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIRS',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);

            IF v_min IS NULL
                THEN
                    RETURN;
            END IF;

        END;

        -- Migration code for creating Actual Header
        OPEN get_act_hdr(v_min, v_max);

        LOOP
            FETCH get_act_hdr BULK COLLECT INTO act_hdr_arr LIMIT MAX_BUFFER_SIZE;
            FOR j IN 1..act_hdr_arr.COUNT
                LOOP
                    SAVEPOINT CSD_ACTUAL_HEADER;

                    BEGIN
                        -- gilam: clearing out repair actual id for creaing new header
                        l_repair_actual_id := null;

                        APPS.CSD_REPAIR_ACTUALS_PKG.INSERT_ROW( px_REPAIR_ACTUAL_ID       => l_repair_actual_id
                                                               ,p_OBJECT_VERSION_NUMBER   => 1
                                                               ,p_REPAIR_LINE_ID          => act_hdr_arr(j)
                                                               ,P_CREATED_BY              => fnd_global.user_id
                                                               ,P_CREATION_DATE           => sysdate
                                                               ,P_LAST_UPDATED_BY         => fnd_global.user_id
                                                               ,P_LAST_UPDATE_DATE        => sysdate
                                                               ,P_LAST_UPDATE_LOGIN       => fnd_global.login_id
                                                               ,p_ATTRIBUTE_CATEGORY      => null
                                                               ,p_ATTRIBUTE1              => null
                                                               ,p_ATTRIBUTE2              => null
                                                               ,p_ATTRIBUTE3              => null
                                                               ,p_ATTRIBUTE4              => null
                                                               ,p_ATTRIBUTE5              => null
                                                               ,p_ATTRIBUTE6              => null
                                                               ,p_ATTRIBUTE7              => null
                                                               ,p_ATTRIBUTE8              => null
                                                               ,p_ATTRIBUTE9              => null
                                                               ,p_ATTRIBUTE10             => null
                                                               ,p_ATTRIBUTE11             => null
                                                               ,p_ATTRIBUTE12             => null
                                                               ,p_ATTRIBUTE13             => null
                                                               ,p_ATTRIBUTE14             => null
                                                               ,p_ATTRIBUTE15             => null);



                        IF SQL%NOTFOUND
                            THEN
                                RAISE error_process;
                        END IF;

                        EXCEPTION
                            WHEN error_process THEN
                                ROLLBACK TO CSD_ACTUAL_HEADER;
                                v_error_text := substr(sqlerrm, 1, 1000)
                                                || 'Actual Repair Line Id:'
                                                || act_hdr_arr(j);

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_REPAIR_ACTUALS',
                                            'CSD_REPAIR_ACTUALS',
                                            act_hdr_arr(j),
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');

						        commit;

                           		raise_application_error( -20000, 'Error while migrating ACTUALS Headers data: Error while inserting into CSD_REPAIR_ACTUALS. '|| v_error_text);

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_act_hdr%NOTFOUND;
        END LOOP;

        IF get_act_hdr%ISOPEN
            THEN
                CLOSE get_act_hdr;
        END IF;
        COMMIT;
    END csd_repair_act_hdr_mig3;


/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_CHARGE_ESTIMATE_LINES_MIG3                                */
/* description   : procedure for migrating ESTIMATES data in CS_ESTIMATE_DETAILS */
/*                 table from 11.5.9 to 11.5.10                                  */
/* purpose      :  Step 1 Data Migration document for Actuals                    */
/*                 Update all the 1159 not interfaced to OM charge lines in      */
/*                 cs_estimate_details table to charge_line_type = ESTIMATE      */
/*                 from charge_line_type = ACTUAL                                */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_charge_estimate_lines_mig3(p_slab_number IN NUMBER DEFAULT 1)
      IS

        TYPE EST_LINES_REC_ARRAY_TYPE IS VARRAY(1000) OF NUMBER;
        est_lines_arr          EST_LINES_REC_ARRAY_TYPE;
        v_min                  NUMBER;
        v_max                  NUMBER;
        v_error_text           VARCHAR2(2000);
        MAX_BUFFER_SIZE        NUMBER                 := 500;
        error_process           EXCEPTION;

        -- gilam: bug 3410383 - changed query to use repair line id instead
        /*
        CURSOR get_est_lines(p_start_est_det_id number, p_end_est_det_id number)
        IS
           SELECT ced.estimate_detail_id
            FROM cs_estimate_details ced
               , csd_repair_estimate_lines cr
           WHERE cr.estimate_detail_id    = ced.estimate_detail_id
             AND ced.charge_line_type     = 'ACTUAL'
             AND ced.order_line_id        is null
             AND ced.original_source_code = 'DR'
             AND ced.source_code          = 'DR'
             AND NOT EXISTS ( SELECT 'x'
                                FROM csd_repair_actual_lines cral
                               WHERE cral.estimate_detail_id  = cr.estimate_detail_id)
             AND ced.estimate_detail_id >= p_start_est_det_id
             AND ced.estimate_detail_id <= p_end_est_det_id;
        */

        CURSOR get_est_lines(p_start_rep_line_id number, p_end_rep_line_id number)
        IS
           SELECT ced.estimate_detail_id
            FROM cs_estimate_details ced
               , csd_repairs cr
               , csd_repair_estimate cre
               , csd_repair_estimate_lines crel
           WHERE cr.repair_line_id = cre.repair_line_id
             AND cre.repair_estimate_id = crel.repair_estimate_id
             AND crel.estimate_detail_id    = ced.estimate_detail_id
             AND ced.charge_line_type     = 'ACTUAL'
             AND ced.order_line_id        is null
             AND ced.original_source_code = 'DR'
             AND ced.source_code          = 'DR'
             AND NOT EXISTS ( SELECT 'x'
                                FROM csd_repair_actual_lines cral
                               WHERE cral.estimate_detail_id  = crel.estimate_detail_id)
            AND cr.repair_line_id >= p_start_rep_line_id
            AND cr.repair_line_id <= p_end_rep_line_id;
        -- gilam: end bug fix 3410303 - changed query

    BEGIN

        -- Get the Slab Number for the table

        BEGIN

            -- gilam: bug 3410383 - changed slab table to csd_repairs
            /*
            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CS_ESTIMATE_DETAILS',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);
            */

            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIRS',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);
            -- gilam: end bug fix 3410383

            IF v_min IS NULL
                THEN
                    RETURN;
            END IF;

        END;

        -- Migration code for Repair Estimate Lines

        OPEN get_est_lines(v_min, v_max);

        LOOP
            FETCH get_est_lines BULK COLLECT INTO est_lines_arr LIMIT MAX_BUFFER_SIZE;
            FOR j IN 1..est_lines_arr.COUNT
                LOOP
                    SAVEPOINT CSD_ESTIMATE_LINES;

                    BEGIN

                        UPDATE CS_ESTIMATE_DETAILS
                           SET CHARGE_LINE_TYPE = 'ESTIMATE'
                         WHERE ESTIMATE_DETAIL_ID = est_lines_arr(j);

                        IF SQL%NOTFOUND
                            THEN
                                RAISE error_process;
                        END IF;

                        EXCEPTION
                            WHEN error_process THEN
                                ROLLBACK TO CSD_ESTIMATE_LINES;
                                v_error_text := substr(sqlerrm, 1, 1000)
                                                || 'Estimate Detail Id:'
                                                || est_lines_arr(j);

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_REPAIR_ESTIMATE_LINES',
                                            'CS_ESTIMATE_DETAILS',
                                            est_lines_arr(j),
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');

						        commit;

                           		raise_application_error( -20000, 'Error while migrating ESTIMATES data in CS_ESTIMATE_DETAILS: Error while Updating CS_ESTIMATE_DETAILS. '|| v_error_text);

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_est_lines%NOTFOUND;
        END LOOP;

        IF get_est_lines%ISOPEN
            THEN
                CLOSE get_est_lines;
        END IF;
        COMMIT;
    END csd_charge_estimate_lines_mig3;

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_ESTIMATE_LINES_MIG3                                */
/* description   : procedure for migrating ESTIMATES data in CS_ESTIMATE_DETAILS */
/*                 table from 11.5.9 to 11.5.10                                  */
/* purpose      :  Mandatory Step for all CSD_REPAIR_ESTIMATE_LINES records      */
/*                 Update all records in 1159 CSD_REPAIR_ESTIMATE_LINES table for*/
/*                 New Cols Added :  EST_LINE_SOURCE_TYPE_CODE = 'MANUAL'        */
/*                         , EST_LINE_SOURCE_ID1       = NULL                    */
/*                         , EST_LINE_SOURCE_ID2       = NULL                    */
/*                         , RO_SERVICE_CODE_ID        = NULL                    */
/*                                                                               */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_repair_estimate_lines_mig3(p_slab_number IN NUMBER DEFAULT 1)
      IS

        TYPE REP_EST_LINES_REC_ARRAY_TYPE IS VARRAY(1000) OF NUMBER;
        rep_est_lines_arr      REP_EST_LINES_REC_ARRAY_TYPE;
        v_min                  NUMBER;
        v_max                  NUMBER;
        v_error_text           VARCHAR2(2000);
        MAX_BUFFER_SIZE        NUMBER                 := 500;
        error_process           EXCEPTION;

        -- gilam: bug 3410383 - changed query to use repair line id instead
        /*
        CURSOR get_rep_est_lines(p_start_rep_est_lin_id number, p_end_rep_est_lin_id number)
        IS
          SELECT cr.repair_estimate_line_id
            FROM csd_repair_estimate_lines cr
           WHERE cr.est_line_source_type_code is null
             AND cr.repair_estimate_line_id >= p_start_rep_est_lin_id
             AND cr.repair_estimate_line_id <= p_end_rep_est_lin_id;
        */

        CURSOR get_rep_est_lines(p_start_rep_line_id number, p_end_rep_line_id number)
        IS
           SELECT crel.repair_estimate_line_id
            FROM csd_repairs cr
               , csd_repair_estimate cre
               , csd_repair_estimate_lines crel
           WHERE cr.repair_line_id = cre.repair_line_id
             AND cre.repair_estimate_id = crel.repair_estimate_id
             AND crel.est_line_source_type_code is null
             AND cr.repair_line_id >= p_start_rep_line_id
             AND cr.repair_line_id <= p_end_rep_line_id;
        -- gilam: end bug fix 3410303 - changed query

    BEGIN

        -- Get the Slab Number for the table

        BEGIN

            -- gilam: bug 3410383 - changed slab table to csd_repairs
            /*
            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIR_ESTIMATE_LINES',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);
           */

            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIRS',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);
            -- gilam: end bug fix 3410383

            IF v_min IS NULL
                THEN
                    RETURN;
            END IF;

        END;

        -- Migration code for Repair Estimate Lines

        OPEN get_rep_est_lines(v_min, v_max);

        LOOP
            FETCH get_rep_est_lines BULK COLLECT INTO rep_est_lines_arr LIMIT MAX_BUFFER_SIZE;
            FOR j IN 1..rep_est_lines_arr.COUNT
                LOOP
                    SAVEPOINT CSD_ESTIMATE_LINES;

                    BEGIN

                        UPDATE CSD_REPAIR_ESTIMATE_LINES
                           SET EST_LINE_SOURCE_TYPE_CODE = 'MANUAL'
                             , EST_LINE_SOURCE_ID1       = NULL
                             , EST_LINE_SOURCE_ID2       = NULL
                             , RO_SERVICE_CODE_ID        = NULL
                         WHERE REPAIR_ESTIMATE_LINE_ID   = rep_est_lines_arr(j);

                        IF SQL%NOTFOUND
                            THEN
                                RAISE error_process;
                        END IF;

                        EXCEPTION
                            WHEN error_process THEN
                                ROLLBACK TO CSD_ESTIMATE_LINES;
                                v_error_text := substr(sqlerrm, 1, 1000)
                                                || 'Repair Estimate Line Id:'
                                                || rep_est_lines_arr(j);

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_REPAIR_ESTIMATE_LINES',
                                            'CSD_REPAIR_ESTIMATE_LINES',
                                            rep_est_lines_arr(j),
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');
						        commit;

                           		raise_application_error( -20000, 'Error while migrating ESTIMATES data in CS_ESTIMATE_DETAILS: Error while Updating CSD_REPAIR_ESTIMATE_LINES. '|| v_error_text);

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_rep_est_lines%NOTFOUND;
        END LOOP;

        IF get_rep_est_lines%ISOPEN
            THEN
                CLOSE get_rep_est_lines;
        END IF;
        COMMIT;
    END csd_repair_estimate_lines_mig3;

/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_ACTTOEST_CHARGE_LINE_MIG3                                 */
/* description   : procedure for copying the ACTUAL CHARGE LINE TO ESTIMATE      */
/*                 CHARGE LINE and linking the Actual charge line to Depot Actuals*/
/*                 and Estimate charge line to Depot Estimate line               */
/*                 for the CSD_REPAIR_ESTIMATE_LINES table data                  */
/*                 during migration from 11.5.9 to 11.5.10                       */
/*                 Update all records in 1159 CSD_REPAIR_ESTIMATE_LINES table for*/
/* purpose      :  Step 2A and 2B of 11510 Actuals Data Migration Steps          */
/*                 creates new Estimate charge line                              */
/*                 1. linking the new Estimate charge line to Depot Estimate line*/
/*                 2. create a new Depot Actual line and                         */
/*                 3. link the Actual line created to old Estimate charge line   */
/*                                                                               */
/*-------------------------------------------------------------------------------*/

  PROCEDURE csd_acttoest_charge_line_mig3(p_slab_number IN NUMBER DEFAULT 1)
      IS

--      TYPE EST_DET_REC_ARRAY_TYPE IS VARRAY(1000) OF CS.CS_ESTIMATE_DETAILS%ROWTYPE;
--      est_det_arr            EST_DET_REC_ARRAY_TYPE;

      	-- gilam: bug 3362408/3362418 - commented out all the columns that are not used in insert_row
      	-- as some of the columns have been dropped in 11.5.10 by Charges

        -- gilam: define each column individually
    	TYPE NumTabTypeI IS TABLE OF NUMBER
         INDEX by Binary_Integer;
      	v_LINE_NUMBER                NumTabTypeI ;
      	v_QUANTITY_REQUIRED          NumTabTypeI ;
      	v_SELLING_PRICE              NumTabTypeI ;
      	v_AFTER_WARRANTY_COST        NumTabTypeI ;
      	v_TRANSACTION_TYPE_ID        NumTabTypeI ;
      	v_ORDER_HEADER_ID            NumTabTypeI ;
      	--v_ORGANIZATION_ID            NumTabTypeI ;
      	v_COVERAGE_BILL_RATE_ID      NumTabTypeI ;
      	v_ORIGINAL_SOURCE_ID         NumTabTypeI ;
      	v_CONTRACT_ID                NumTabTypeI ;
      	v_COVERAGE_ID                NumTabTypeI ;
      	v_COVERAGE_TXN_GROUP_ID      NumTabTypeI ;
      	v_CONVERSION_RATE            NumTabTypeI ;
      	v_ORDER_LINE_ID              NumTabTypeI ;
      	v_PRICE_LIST_HEADER_ID       NumTabTypeI ;
      	--v_FUNC_CURR_AFT_WARR_COST    NumTabTypeI ;
      	v_OBJECT_VERSION_NUMBER      NumTabTypeI ;
     	--v_SECURITY_GROUP_ID          NumTabTypeI ;
      	--v_ORIG_SYSTEM_REFERENCE_ID   NumTabTypeI ;
      	v_ORG_ID                     NumTabTypeI ;
      	--v_TRANS_INV_ORGANIZATION_ID  NumTabTypeI ;
      	v_TRANSACTION_INVENTORY_ORG  NumTabTypeI ;
      	v_SHIP_TO_CONTACT_ID         NumTabTypeI ;
      	v_BILL_TO_CONTACT_ID         NumTabTypeI ;
      	v_SHIP_TO_ACCOUNT_ID         NumTabTypeI ;
      	v_INVOICE_TO_ACCOUNT_ID      NumTabTypeI ;
      	v_LIST_PRICE                 NumTabTypeI ;
      	v_CONTRACT_DISCOUNT_AMOUNT   NumTabTypeI ;
      	v_BILL_TO_PARTY_ID           NumTabTypeI ;
      	v_SHIP_TO_PARTY_ID           NumTabTypeI ;
	--sangigup 4610625
        v_contract_line_id          NumTabTypeI;
        --sangigup 4610625


    	TYPE NumTabTypeII IS TABLE OF NUMBER(15,0)
         INDEX by Binary_Integer;
      	--v_TECHNICIAN_ID              NumTabTypeII ;
      	--v_ESTIMATE_ID                NumTabTypeII ;
      	v_SOURCE_ID                  NumTabTypeII ;
      	--v_SYSTEM_ID                  NumTabTypeII ;
      	--v_RMA_HEADER_ID              NumTabTypeII ;
      	--v_ESTIMATE_BUSINESS_GROUP_ID NumTabTypeII ;
      	v_INVENTORY_ITEM_ID          NumTabTypeII ;
	v_LAST_UPDATE_BY             NumTabTypeII ;
      	--v_EST_TAX_AMOUNT             NumTabTypeII ;
      	v_CREATED_BY                 NumTabTypeII ;
      	v_LAST_UPDATE_LOGIN          NumTabTypeII ;
      	--v_RMA_LINE_ID                NumTabTypeII ;
      	--v_DIAGNOSIS_ID               NumTabTypeII ;
      	--v_TIME_ZONE_ID               NumTabTypeII ;
      	v_TXN_BILLING_TYPE_ID        NumTabTypeII ;
      	v_INVOICE_TO_ORG_ID          NumTabTypeII ;
      	v_SHIP_TO_ORG_ID             NumTabTypeII ;
      	v_COVERAGE_BILLING_TYPE_ID   NumTabTypeII ;
	v_ESTIMATE_DETAIL_ID         NumTabTypeII ;
      	v_CUSTOMER_PRODUCT_ID        NumTabTypeII ;
      	v_BUSINESS_PROCESS_ID        NumTabTypeII ;
      	v_INCIDENT_ID                NumTabTypeII ;
      	v_LINE_TYPE_ID               NumTabTypeII ;

    	--TYPE NumTabTypeIII IS TABLE OF NUMBER(30,0)
        -- INDEX by Binary_Integer;
      	--v_RMA_NUMBER                 NumTabTypeIII ;
      	--v_RMA_LINE_NUMBER            NumTabTypeIII ;

     	TYPE DateTabType IS TABLE OF DATE
        INDEX by Binary_Integer;
      	v_LAST_UPDATE_DATE           DateTabType ;
      	v_CREATION_DATE              DateTabType ;
      	v_INSTALLED_CP_RETURN_BY_DATE  DateTabType ;
      	v_NEW_CP_RETURN_BY_DATE      DateTabType ;
      	--v_TXN_START_TIME             DateTabType ;
      	--v_TXN_END_TIME               DateTabType ;
      	v_CONVERSION_RATE_DATE       DateTabType ;
      	--v_ACTIVITY_DATE              DateTabType ;
      	--v_ACTIVITY_START_TIME        DateTabType ;
      	--v_ACTIVITY_END_TIME          DateTabType ;
      	v_ACTIVITY_START_DATE_TIME   DateTabType ;
      	v_ACTIVITY_END_DATE_TIME     DateTabType ;

     	TYPE VCharTabTypeI IS TABLE OF VARCHAR2(1)
        INDEX by Binary_Integer;
      	v_INTERFACE_TO_OE_FLAG       VCharTabTypeI ;
      	v_ROLLUP_FLAG                VCharTabTypeI ;
      	--v_ADD_TO_ORDER               VCharTabTypeI ;
      	v_ADD_TO_ORDER_FLAG          VCharTabTypeI ;
      	--v_EXCEPTION_COVERAGE_USED    VCharTabTypeI ;
      	--v_UPGRADED_STATUS_FLAG       VCharTabTypeI ;
      	v_NO_CHARGE_FLAG             VCharTabTypeI ;
      	v_GENERATED_BY_BCA_ENGINE_FLAG   VCharTabTypeI ;
      	v_LINE_SUBMITTED             VCharTabTypeI ;

     	TYPE VCharTabTypeII IS TABLE OF VARCHAR2(3)
        INDEX by Binary_Integer;
      	v_UNIT_OF_MEASURE_CODE       VCharTabTypeII ;
      	v_ITEM_REVISION              VCharTabTypeII ;

     	TYPE VCharTabTypeIII IS TABLE OF VARCHAR2(10)
        INDEX by Binary_Integer;
      	v_ORIGINAL_SOURCE_CODE       VCharTabTypeIII ;
      	v_SOURCE_CODE                VCharTabTypeIII ;
      	--v_TRANS_SUBINVENTORY         VCharTabTypeIII ;
      	v_TRANSACTION_SUB_INVENTORY  VCharTabTypeIII ;

     	TYPE VCharTabTypeIV IS TABLE OF VARCHAR2(15)
        INDEX by Binary_Integer;
      	v_CURRENCY_CODE              VCharTabTypeIV ;

     	TYPE VCharTabTypeV IS TABLE OF VARCHAR2(30)
        INDEX by Binary_Integer;
      	v_SERIAL_NUMBER              VCharTabTypeV ;
      	v_PRICING_CONTEXT            VCharTabTypeV ;
      	v_CONTEXT                    VCharTabTypeV ;
      	v_LINE_CATEGORY_CODE         VCharTabTypeV ;
      	v_CONVERSION_TYPE_CODE       VCharTabTypeV ;
      	v_RETURN_REASON_CODE         VCharTabTypeV ;
      	--v_TAX_CODE                   VCharTabTypeV ;
      	v_CHARGE_LINE_TYPE           VCharTabTypeV ;
      	v_SUBMIT_FROM_SYSTEM         VCharTabTypeV ;

     	TYPE VCharTabTypeVI IS TABLE OF VARCHAR2(50)
        INDEX by Binary_Integer;
      	--v_ORIGINAL_SYSTEM_REFERENCE  VCharTabTypeVI ;
      	--v_ORIGINAL_SYS_LINE_REFERENCE VCharTabTypeVI ;
      	v_PURCHASE_ORDER_NUM         VCharTabTypeVI ;
      	--v_ORIG_SYSTEM_REFERENCE      VCharTabTypeVI ;
      	--v_ORIG_SYSTEM_LINE_REFERENCE VCharTabTypeVI ;
	--sangigup 4610625
	 v_rate_type_Code   VCharTabTypeVI;
        --sangigup

     	TYPE VCharTabTypeVII IS TABLE OF VARCHAR2(150)
        INDEX by Binary_Integer;
      	v_ATTRIBUTE1                 VCharTabTypeVII ;
      	v_ATTRIBUTE2                 VCharTabTypeVII ;
      	v_ATTRIBUTE3                 VCharTabTypeVII ;
      	v_ATTRIBUTE4                 VCharTabTypeVII ;
      	v_ATTRIBUTE5                 VCharTabTypeVII ;
      	v_ATTRIBUTE6                 VCharTabTypeVII ;
      	v_ATTRIBUTE7                 VCharTabTypeVII ;
      	v_ATTRIBUTE8                 VCharTabTypeVII ;
      	v_ATTRIBUTE9                 VCharTabTypeVII ;
      	v_ATTRIBUTE10                VCharTabTypeVII ;
      	v_ATTRIBUTE11                VCharTabTypeVII ;
      	v_ATTRIBUTE12                VCharTabTypeVII ;
      	v_ATTRIBUTE13                VCharTabTypeVII ;
      	v_ATTRIBUTE14                VCharTabTypeVII ;
      	v_ATTRIBUTE15                VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE1         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE2         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE3         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE4         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE5         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE6         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE7         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE8         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE9         VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE10        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE11        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE12        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE13        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE14        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE15        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE16        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE17        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE18        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE19        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE20        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE21        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE22        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE23        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE24        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE25        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE26        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE27        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE28        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE29        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE30        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE31        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE32        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE33        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE34        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE35        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE36        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE37        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE38        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE39        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE40        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE41        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE42        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE43        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE44        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE45        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE46        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE47        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE48        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE49        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE50        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE51        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE52        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE53        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE54        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE55        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE56        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE57        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE58        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE59        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE60        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE61        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE62        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE63        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE64        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE65        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE66        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE67        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE68        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE69        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE70        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE71        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE72        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE73        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE74        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE75        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE76        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE77        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE78        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE79        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE80        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE81        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE82        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE83        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE84        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE85        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE86        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE87        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE88        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE89        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE90        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE91        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE92        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE93        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE94        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE95        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE96        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE97        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE98        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE99        VCharTabTypeVII ;
      	v_PRICING_ATTRIBUTE100       VCharTabTypeVII ;

     	TYPE VCharTabTypeVIII IS TABLE OF VARCHAR2(2000)
        INDEX by Binary_Integer;
      	v_SUBMIT_RESTRICTION_MESSAGE VCharTabTypeVIII ;
      	v_SUBMIT_ERROR_MESSAGE       VCharTabTypeVIII ;

        v_min                  NUMBER;
        v_max                  NUMBER;
        v_error_text           VARCHAR2(2000);
        MAX_BUFFER_SIZE        NUMBER                 := 500;
        error_process           EXCEPTION;
        l_Array_Size           Number  ;

        l_old_est_detail_id    NUMBER;
        l_new_est_detail_id    NUMBER;
        l_rep_est_line_id      NUMBER;
        l_actual_id            NUMBER;
        x_actual_line_id       NUMBER;

        l_line_num             NUMBER                  := 1 ;
        l_ed_id                NUMBER;
        x_object_version_number NUMBER;

        -- gilam: changed sql to list out all the columns
        -- get all the OM interfaced charge lines created from Depot Repair

      	-- gilam: bug 3362408/3362418 - commented out all the columns that are not used in insert_row
      	-- as some of the columns have been dropped in 11.5.10 by Charges

        -- gilam: bug 3410383 - changed query to use repair line id instead
        /*
        CURSOR get_charge_est_details(p_start_est_det_id number, p_end_est_det_id number)
        IS
          SELECT ced.estimate_detail_id,
          ced.last_update_date,
          ced.last_updated_by,
          ced.creation_date,
          ced.created_by,
          ced.last_update_login,
          --ced.estimate_id,
          ced.line_number,
          ced.inventory_item_id,
          ced.serial_number,
          ced.quantity_required,
          ced.unit_of_measure_code,
          ced.selling_price,
          ced.after_warranty_cost,
          ced.pricing_context,
          ced.pricing_attribute1,
          ced.pricing_attribute2,
          ced.pricing_attribute3,
          ced.pricing_attribute4,
          ced.pricing_attribute5,
          ced.pricing_attribute6,
          ced.pricing_attribute7,
          ced.pricing_attribute8,
          ced.pricing_attribute9,
          ced.pricing_attribute10,
          ced.pricing_attribute11,
          ced.pricing_attribute12,
          ced.pricing_attribute13,
          ced.pricing_attribute14,
          ced.pricing_attribute15,
          ced.attribute1,
          ced.attribute2,
          ced.attribute3,
          ced.attribute4,
          ced.attribute5,
          ced.attribute6,
          ced.attribute7,
          ced.attribute8,
          ced.attribute9,
          ced.attribute10,
          ced.attribute11,
          ced.attribute12,
          ced.attribute13,
          ced.attribute14,
          ced.attribute15,
          ced.context,
          --ced.organization_id,
          --ced.diagnosis_id,
          --ced.estimate_business_group_id,
          ced.transaction_type_id,
          ced.customer_product_id,
          ced.order_header_id,
          --ced.original_system_reference,
          --ced.original_system_line_reference,
          ced.installed_cp_return_by_date,
          ced.new_cp_return_by_date,
          ced.interface_to_oe_flag,
          ced.rollup_flag,
          --ced.add_to_order,
          --ced.system_id,
          --ced.rma_header_id,
          --ced.rma_number,
          --ced.rma_line_id,
          --ced.rma_line_number,
          --ced.technician_id,
          --ced.txn_start_time,
          --ced.txn_end_time,
          ced.coverage_bill_rate_id,
          ced.coverage_billing_type_id,
          --ced.time_zone_id,
          ced.txn_billing_type_id,
          ced.business_process_id,
          ced.incident_id,
          ced.original_source_id,
          ced.original_source_code,
          ced.source_id,
          ced.source_code,
          ced.contract_id,
          ced.coverage_id,
          ced.coverage_txn_group_id,
          ced.invoice_to_org_id,
          ced.ship_to_org_id,
          ced.purchase_order_num,
          ced.line_type_id,
          ced.line_category_code,
          ced.currency_code,
          ced.conversion_rate,
          ced.conversion_type_code,
          ced.conversion_rate_date,
          ced.return_reason_code,
          ced.order_line_id,
          ced.price_list_header_id,
          --ced.func_curr_aft_warr_cost,
          --ced.orig_system_reference,
          --ced.orig_system_line_reference,
          ced.add_to_order_flag,
          --ced.exception_coverage_used,
          --ced.tax_code,
          --ced.est_tax_amount,
          ced.object_version_number,
          ced.pricing_attribute16,
          ced.pricing_attribute17,
          ced.pricing_attribute18,
          ced.pricing_attribute19,
          ced.pricing_attribute20,
          ced.pricing_attribute21,
          ced.pricing_attribute22,
          ced.pricing_attribute23,
          ced.pricing_attribute24,
          ced.pricing_attribute25,
          ced.pricing_attribute26,
          ced.pricing_attribute27,
          ced.pricing_attribute28,
          ced.pricing_attribute29,
          ced.pricing_attribute30,
          ced.pricing_attribute31,
          ced.pricing_attribute32,
          ced.pricing_attribute33,
          ced.pricing_attribute34,
          ced.pricing_attribute35,
          ced.pricing_attribute36,
          ced.pricing_attribute37,
          ced.pricing_attribute38,
          ced.pricing_attribute39,
          ced.pricing_attribute40,
          ced.pricing_attribute41,
          ced.pricing_attribute42,
          ced.pricing_attribute43,
          ced.pricing_attribute44,
          ced.pricing_attribute45,
          ced.pricing_attribute46,
          ced.pricing_attribute47,
          ced.pricing_attribute48,
          ced.pricing_attribute49,
          ced.pricing_attribute50,
          ced.pricing_attribute51,
          ced.pricing_attribute52,
          ced.pricing_attribute53,
          ced.pricing_attribute54,
          ced.pricing_attribute55,
          ced.pricing_attribute56,
          ced.pricing_attribute57,
          ced.pricing_attribute58,
          ced.pricing_attribute59,
          ced.pricing_attribute61,
          ced.pricing_attribute62,
          ced.pricing_attribute63,
          ced.pricing_attribute64,
          ced.pricing_attribute65,
          ced.pricing_attribute66,
          ced.pricing_attribute67,
          ced.pricing_attribute68,
          ced.pricing_attribute69,
          ced.pricing_attribute70,
          ced.pricing_attribute71,
          ced.pricing_attribute72,
          ced.pricing_attribute73,
          ced.pricing_attribute74,
          ced.pricing_attribute75,
          ced.pricing_attribute76,
          ced.pricing_attribute77,
          ced.pricing_attribute78,
          ced.pricing_attribute79,
          ced.pricing_attribute80,
          ced.pricing_attribute81,
          ced.pricing_attribute82,
          ced.pricing_attribute83,
          ced.pricing_attribute84,
          ced.pricing_attribute85,
          ced.pricing_attribute86,
          ced.pricing_attribute87,
          ced.pricing_attribute88,
          ced.pricing_attribute89,
          ced.pricing_attribute90,
          ced.pricing_attribute91,
          ced.pricing_attribute92,
          ced.pricing_attribute93,
          ced.pricing_attribute94,
          ced.pricing_attribute95,
          ced.pricing_attribute96,
          ced.pricing_attribute97,
          ced.pricing_attribute98,
          ced.pricing_attribute99,
          ced.pricing_attribute100,
          ced.pricing_attribute60,
          --ced.security_group_id,
          --ced.upgraded_status_flag,
          --ced.orig_system_reference_id,
          ced.no_charge_flag,
          ced.org_id,
          ced.item_revision,
          --ced.trans_inv_organization_id,
          --ced.trans_subinventory,
          --ced.activity_date,
          --ced.activity_start_time,
          --ced.activity_end_time,
          ced.generated_by_bca_engine_flag,
          ced.transaction_inventory_org,
          ced.transaction_sub_inventory,
          ced.activity_start_date_time,
          ced.activity_end_date_time,
          ced.charge_line_type,
          ced.ship_to_contact_id,
          ced.bill_to_contact_id,
          ced.ship_to_account_id,
          ced.invoice_to_account_id,
          ced.list_price,
          ced.contract_discount_amount,
          ced.bill_to_party_id,
          ced.ship_to_party_id,
          ced.submit_restriction_message,
          ced.submit_error_message,
          ced.line_submitted,
          ced.submit_from_system
	  FROM cs_estimate_details ced
             , csd_repair_estimate_lines cr
          WHERE cr.estimate_detail_id    = ced.estimate_detail_id
             AND ced.charge_line_type     = 'ACTUAL'
             AND ced.order_line_id        is not null
             AND ced.original_source_code = 'DR'
             AND ced.source_code          = 'DR'
             AND NOT EXISTS ( SELECT 'x'
                                FROM csd_repair_actual_lines cral
                               WHERE cral.estimate_detail_id  = cr.estimate_detail_id)
             AND ced.estimate_detail_id >= p_start_est_det_id
             AND ced.estimate_detail_id <= p_end_est_det_id;
        */

        CURSOR get_charge_est_details(p_start_rep_line_id number, p_end_rep_line_id number)
        IS
          SELECT ced.estimate_detail_id,
          ced.last_update_date,
          ced.last_updated_by,
          ced.creation_date,
          ced.created_by,
          ced.last_update_login,
          --ced.estimate_id,
          ced.line_number,
          ced.inventory_item_id,
          ced.serial_number,
          ced.quantity_required,
          ced.unit_of_measure_code,
          ced.selling_price,
          ced.after_warranty_cost,
          ced.pricing_context,
          ced.pricing_attribute1,
          ced.pricing_attribute2,
          ced.pricing_attribute3,
          ced.pricing_attribute4,
          ced.pricing_attribute5,
          ced.pricing_attribute6,
          ced.pricing_attribute7,
          ced.pricing_attribute8,
          ced.pricing_attribute9,
          ced.pricing_attribute10,
          ced.pricing_attribute11,
          ced.pricing_attribute12,
          ced.pricing_attribute13,
          ced.pricing_attribute14,
          ced.pricing_attribute15,
          ced.attribute1,
          ced.attribute2,
          ced.attribute3,
          ced.attribute4,
          ced.attribute5,
          ced.attribute6,
          ced.attribute7,
          ced.attribute8,
          ced.attribute9,
          ced.attribute10,
          ced.attribute11,
          ced.attribute12,
          ced.attribute13,
          ced.attribute14,
          ced.attribute15,
          ced.context,
          --ced.organization_id,
          --ced.diagnosis_id,
          --ced.estimate_business_group_id,
          ced.transaction_type_id,
          ced.customer_product_id,
          ced.order_header_id,
          --ced.original_system_reference,
          --ced.original_system_line_reference,
          ced.installed_cp_return_by_date,
          ced.new_cp_return_by_date,
          ced.interface_to_oe_flag,
          ced.rollup_flag,
          --ced.add_to_order,
          --ced.system_id,
          --ced.rma_header_id,
          --ced.rma_number,
          --ced.rma_line_id,
          --ced.rma_line_number,
          --ced.technician_id,
          --ced.txn_start_time,
          --ced.txn_end_time,
          ced.coverage_bill_rate_id,
          ced.coverage_billing_type_id,
          --ced.time_zone_id,
          ced.txn_billing_type_id,
          ced.business_process_id,
          ced.incident_id,
          ced.original_source_id,
          ced.original_source_code,
          ced.source_id,
          ced.source_code,
          ced.contract_id,
          ced.coverage_id,
          ced.coverage_txn_group_id,
          ced.invoice_to_org_id,
          ced.ship_to_org_id,
          ced.purchase_order_num,
          ced.line_type_id,
          ced.line_category_code,
          ced.currency_code,
          ced.conversion_rate,
          ced.conversion_type_code,
          ced.conversion_rate_date,
          ced.return_reason_code,
          ced.order_line_id,
          ced.price_list_header_id,
          --ced.func_curr_aft_warr_cost,
          --ced.orig_system_reference,
          --ced.orig_system_line_reference,
          ced.add_to_order_flag,
          --ced.exception_coverage_used,
          --ced.tax_code,
          --ced.est_tax_amount,
          ced.object_version_number,
          ced.pricing_attribute16,
          ced.pricing_attribute17,
          ced.pricing_attribute18,
          ced.pricing_attribute19,
          ced.pricing_attribute20,
          ced.pricing_attribute21,
          ced.pricing_attribute22,
          ced.pricing_attribute23,
          ced.pricing_attribute24,
          ced.pricing_attribute25,
          ced.pricing_attribute26,
          ced.pricing_attribute27,
          ced.pricing_attribute28,
          ced.pricing_attribute29,
          ced.pricing_attribute30,
          ced.pricing_attribute31,
          ced.pricing_attribute32,
          ced.pricing_attribute33,
          ced.pricing_attribute34,
          ced.pricing_attribute35,
          ced.pricing_attribute36,
          ced.pricing_attribute37,
          ced.pricing_attribute38,
          ced.pricing_attribute39,
          ced.pricing_attribute40,
          ced.pricing_attribute41,
          ced.pricing_attribute42,
          ced.pricing_attribute43,
          ced.pricing_attribute44,
          ced.pricing_attribute45,
          ced.pricing_attribute46,
          ced.pricing_attribute47,
          ced.pricing_attribute48,
          ced.pricing_attribute49,
          ced.pricing_attribute50,
          ced.pricing_attribute51,
          ced.pricing_attribute52,
          ced.pricing_attribute53,
          ced.pricing_attribute54,
          ced.pricing_attribute55,
          ced.pricing_attribute56,
          ced.pricing_attribute57,
          ced.pricing_attribute58,
          ced.pricing_attribute59,
          ced.pricing_attribute61,
          ced.pricing_attribute62,
          ced.pricing_attribute63,
          ced.pricing_attribute64,
          ced.pricing_attribute65,
          ced.pricing_attribute66,
          ced.pricing_attribute67,
          ced.pricing_attribute68,
          ced.pricing_attribute69,
          ced.pricing_attribute70,
          ced.pricing_attribute71,
          ced.pricing_attribute72,
          ced.pricing_attribute73,
          ced.pricing_attribute74,
          ced.pricing_attribute75,
          ced.pricing_attribute76,
          ced.pricing_attribute77,
          ced.pricing_attribute78,
          ced.pricing_attribute79,
          ced.pricing_attribute80,
          ced.pricing_attribute81,
          ced.pricing_attribute82,
          ced.pricing_attribute83,
          ced.pricing_attribute84,
          ced.pricing_attribute85,
          ced.pricing_attribute86,
          ced.pricing_attribute87,
          ced.pricing_attribute88,
          ced.pricing_attribute89,
          ced.pricing_attribute90,
          ced.pricing_attribute91,
          ced.pricing_attribute92,
          ced.pricing_attribute93,
          ced.pricing_attribute94,
          ced.pricing_attribute95,
          ced.pricing_attribute96,
          ced.pricing_attribute97,
          ced.pricing_attribute98,
          ced.pricing_attribute99,
          ced.pricing_attribute100,
          ced.pricing_attribute60,
          --ced.security_group_id,
          --ced.upgraded_status_flag,
          --ced.orig_system_reference_id,
          ced.no_charge_flag,
          ced.org_id,
          ced.item_revision,
          --ced.trans_inv_organization_id,
          --ced.trans_subinventory,
          --ced.activity_date,
          --ced.activity_start_time,
          --ced.activity_end_time,
          ced.generated_by_bca_engine_flag,
          ced.transaction_inventory_org,
          ced.transaction_sub_inventory,
          ced.activity_start_date_time,
          ced.activity_end_date_time,
          ced.charge_line_type,
          ced.ship_to_contact_id,
          ced.bill_to_contact_id,
          ced.ship_to_account_id,
          ced.invoice_to_account_id,
          ced.list_price,
          ced.contract_discount_amount,
          ced.bill_to_party_id,
          ced.ship_to_party_id,
          ced.submit_restriction_message,
          ced.submit_error_message,
          ced.line_submitted,
          ced.submit_from_system
	  --sangigup 4610625
          ,ced.contract_line_id
          ,ced.rate_type_code
          --sangigup

     FROM cs_estimate_details ced
        , csd_repairs cr
        , csd_repair_estimate cre
        , csd_repair_estimate_lines crel
     WHERE cr.repair_line_id = cre.repair_line_id
       AND cre.repair_estimate_id = crel.repair_estimate_id
       AND crel.estimate_detail_id    = ced.estimate_detail_id
       AND ced.charge_line_type     = 'ACTUAL'
       AND ced.order_line_id        is not null
       AND ced.original_source_code = 'DR'
       AND ced.source_code          = 'DR'
       AND NOT EXISTS ( SELECT 'x'
                          FROM csd_repair_actual_lines cral
                         WHERE cral.estimate_detail_id  = crel.estimate_detail_id)
       AND cr.repair_line_id >= p_start_rep_line_id
       AND cr.repair_line_id <= p_end_rep_line_id;
    -- gilam: end bug fix 3410303 - changed query

    BEGIN

        -- Get the Slab Number for the table

        BEGIN

            -- gilam: bug 3410383 - changed slab table to csd_repairs
            /*
            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CS_ESTIMATE_DETAILS',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);
            */

            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIRS',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);
            -- gilam: end bug fix 3410383

            IF v_min IS NULL
                THEN
                    RETURN;
            END IF;

        END;

        -- Migration code for Repair Estimate Lines

        OPEN get_charge_est_details(v_min, v_max);

        LOOP

      	-- gilam: bug 3362408/3362418 - commented out all the columns that are not used in insert_row
      	-- as some of the columns have been dropped in 11.5.10 by Charges

            -- gilam: changed FETCH stmt to fetch into individual tables
            FETCH get_charge_est_details BULK COLLECT
              INTO
              v_ESTIMATE_DETAIL_ID	   ,
       	      v_LAST_UPDATE_DATE           ,
    	      v_LAST_UPDATE_BY             ,
       	      v_CREATION_DATE              ,
       	      v_CREATED_BY                 ,
       	      v_LAST_UPDATE_LOGIN          ,
       	      --v_ESTIMATE_ID                ,
       	      v_LINE_NUMBER                ,
       	      v_INVENTORY_ITEM_ID          ,
       	      v_SERIAL_NUMBER              ,
      	      v_QUANTITY_REQUIRED          ,
      	      v_UNIT_OF_MEASURE_CODE       ,
              v_SELLING_PRICE              ,
              v_AFTER_WARRANTY_COST        ,
       	      v_PRICING_CONTEXT            ,
       	      v_PRICING_ATTRIBUTE1         ,
       	      v_PRICING_ATTRIBUTE2         ,
       	      v_PRICING_ATTRIBUTE3         ,
       	      v_PRICING_ATTRIBUTE4         ,
       	      v_PRICING_ATTRIBUTE5         ,
       	      v_PRICING_ATTRIBUTE6         ,
       	      v_PRICING_ATTRIBUTE7         ,
       	      v_PRICING_ATTRIBUTE8         ,
       	      v_PRICING_ATTRIBUTE9         ,
       	      v_PRICING_ATTRIBUTE10        ,
       	      v_PRICING_ATTRIBUTE11        ,
       	      v_PRICING_ATTRIBUTE12        ,
       	      v_PRICING_ATTRIBUTE13        ,
       	      v_PRICING_ATTRIBUTE14        ,
       	      v_PRICING_ATTRIBUTE15        ,
       	      v_ATTRIBUTE1                 ,
       	      v_ATTRIBUTE2                 ,
      	      v_ATTRIBUTE3                 ,
       	      v_ATTRIBUTE4                 ,
       	      v_ATTRIBUTE5                 ,
       	      v_ATTRIBUTE6                 ,
       	      v_ATTRIBUTE7                 ,
       	      v_ATTRIBUTE8                 ,
       	      v_ATTRIBUTE9                 ,
       	      v_ATTRIBUTE10                ,
       	      v_ATTRIBUTE11                ,
       	      v_ATTRIBUTE12                ,
       	      v_ATTRIBUTE13                ,
       	      v_ATTRIBUTE14                ,
       	      v_ATTRIBUTE15                ,
       	      v_CONTEXT                    ,
       	      --v_ORGANIZATION_ID            ,
              --v_DIAGNOSIS_ID               ,
      	      --v_ESTIMATE_BUSINESS_GROUP_ID ,
       	      v_TRANSACTION_TYPE_ID        ,
       	      v_CUSTOMER_PRODUCT_ID        ,
       	      v_ORDER_HEADER_ID            ,
      	      --v_ORIGINAL_SYSTEM_REFERENCE  ,
      	      --v_ORIGINAL_SYS_LINE_REFERENCE  ,
       	      v_INSTALLED_CP_RETURN_BY_DATE  ,
       	      v_NEW_CP_RETURN_BY_DATE      ,
       	      v_INTERFACE_TO_OE_FLAG       ,
       	      v_ROLLUP_FLAG                ,
       	      --v_ADD_TO_ORDER               ,
       	      --v_SYSTEM_ID                  ,
       	      --v_RMA_HEADER_ID              ,
       	      --v_RMA_NUMBER                 ,
       	      --v_RMA_LINE_ID                ,
       	      --v_RMA_LINE_NUMBER            ,
       	      --v_TECHNICIAN_ID              ,
       	      --v_TXN_START_TIME             ,
       	      --v_TXN_END_TIME               ,
       	      v_COVERAGE_BILL_RATE_ID      ,
       	      v_COVERAGE_BILLING_TYPE_ID   ,
       	      --v_TIME_ZONE_ID               ,
       	      v_TXN_BILLING_TYPE_ID        ,
       	      v_BUSINESS_PROCESS_ID        ,
       	      v_INCIDENT_ID                ,
       	      v_ORIGINAL_SOURCE_ID         ,
       	      v_ORIGINAL_SOURCE_CODE       ,
       	      v_SOURCE_ID                  ,
       	      v_SOURCE_CODE                ,
              v_CONTRACT_ID                ,
       	      v_COVERAGE_ID                ,
       	      v_COVERAGE_TXN_GROUP_ID      ,
       	      v_INVOICE_TO_ORG_ID          ,
       	      v_SHIP_TO_ORG_ID             ,
      	      v_PURCHASE_ORDER_NUM         ,
              v_LINE_TYPE_ID               ,
   	      v_LINE_CATEGORY_CODE         ,
              v_CURRENCY_CODE              ,
      	      v_CONVERSION_RATE            ,
       	      v_CONVERSION_TYPE_CODE       ,
       	      v_CONVERSION_RATE_DATE       ,
       	      v_RETURN_REASON_CODE         ,
       	      v_ORDER_LINE_ID              ,
       	      v_PRICE_LIST_HEADER_ID       ,
       	      --v_FUNC_CURR_AFT_WARR_COST    ,
      	      --v_ORIG_SYSTEM_REFERENCE      ,
       	      --v_ORIG_SYSTEM_LINE_REFERENCE ,
       	      v_ADD_TO_ORDER_FLAG          ,
       	      --v_EXCEPTION_COVERAGE_USED    ,
       	      --v_TAX_CODE                   ,
       	      --v_EST_TAX_AMOUNT             ,
       	      v_OBJECT_VERSION_NUMBER      ,
       	      v_PRICING_ATTRIBUTE16        ,
       	      v_PRICING_ATTRIBUTE17        ,
       	      v_PRICING_ATTRIBUTE18        ,
       	      v_PRICING_ATTRIBUTE19        ,
       	      v_PRICING_ATTRIBUTE20        ,
       	      v_PRICING_ATTRIBUTE21        ,
       	      v_PRICING_ATTRIBUTE22        ,
       	      v_PRICING_ATTRIBUTE23        ,
       	      v_PRICING_ATTRIBUTE24        ,
       	      v_PRICING_ATTRIBUTE25        ,
       	      v_PRICING_ATTRIBUTE26        ,
       	      v_PRICING_ATTRIBUTE27        ,
       	      v_PRICING_ATTRIBUTE28        ,
       	      v_PRICING_ATTRIBUTE29        ,
       	      v_PRICING_ATTRIBUTE30        ,
       	      v_PRICING_ATTRIBUTE31        ,
       	      v_PRICING_ATTRIBUTE32        ,
       	      v_PRICING_ATTRIBUTE33        ,
       	      v_PRICING_ATTRIBUTE34        ,
       	      v_PRICING_ATTRIBUTE35        ,
       	      v_PRICING_ATTRIBUTE36        ,
       	      v_PRICING_ATTRIBUTE37        ,
       	      v_PRICING_ATTRIBUTE38        ,
       	      v_PRICING_ATTRIBUTE39        ,
       	      v_PRICING_ATTRIBUTE40        ,
       	      v_PRICING_ATTRIBUTE41        ,
       	      v_PRICING_ATTRIBUTE42        ,
       	      v_PRICING_ATTRIBUTE43        ,
       	      v_PRICING_ATTRIBUTE44        ,
       	      v_PRICING_ATTRIBUTE45        ,
       	      v_PRICING_ATTRIBUTE46        ,
       	      v_PRICING_ATTRIBUTE47        ,
       	      v_PRICING_ATTRIBUTE48        ,
       	      v_PRICING_ATTRIBUTE49        ,
       	      v_PRICING_ATTRIBUTE50        ,
       	      v_PRICING_ATTRIBUTE51        ,
       	      v_PRICING_ATTRIBUTE52        ,
       	      v_PRICING_ATTRIBUTE53        ,
       	      v_PRICING_ATTRIBUTE54        ,
       	      v_PRICING_ATTRIBUTE55        ,
       	      v_PRICING_ATTRIBUTE56        ,
       	      v_PRICING_ATTRIBUTE57        ,
       	      v_PRICING_ATTRIBUTE58        ,
       	      v_PRICING_ATTRIBUTE59        ,
       	      v_PRICING_ATTRIBUTE61        ,
       	      v_PRICING_ATTRIBUTE62        ,
       	      v_PRICING_ATTRIBUTE63        ,
       	      v_PRICING_ATTRIBUTE64        ,
       	      v_PRICING_ATTRIBUTE65        ,
       	      v_PRICING_ATTRIBUTE66        ,
       	      v_PRICING_ATTRIBUTE67        ,
       	      v_PRICING_ATTRIBUTE68        ,
       	      v_PRICING_ATTRIBUTE69        ,
       	      v_PRICING_ATTRIBUTE70        ,
       	      v_PRICING_ATTRIBUTE71        ,
       	      v_PRICING_ATTRIBUTE72        ,
       	      v_PRICING_ATTRIBUTE73        ,
       	      v_PRICING_ATTRIBUTE74        ,
       	      v_PRICING_ATTRIBUTE75        ,
       	      v_PRICING_ATTRIBUTE76        ,
       	      v_PRICING_ATTRIBUTE77        ,
       	      v_PRICING_ATTRIBUTE78        ,
       	      v_PRICING_ATTRIBUTE79        ,
       	      v_PRICING_ATTRIBUTE80        ,
       	      v_PRICING_ATTRIBUTE81        ,
       	      v_PRICING_ATTRIBUTE82        ,
       	      v_PRICING_ATTRIBUTE83        ,
       	      v_PRICING_ATTRIBUTE84        ,
       	      v_PRICING_ATTRIBUTE85        ,
       	      v_PRICING_ATTRIBUTE86        ,
       	      v_PRICING_ATTRIBUTE87        ,
       	      v_PRICING_ATTRIBUTE88        ,
       	      v_PRICING_ATTRIBUTE89        ,
       	      v_PRICING_ATTRIBUTE90        ,
       	      v_PRICING_ATTRIBUTE91        ,
       	      v_PRICING_ATTRIBUTE92        ,
       	      v_PRICING_ATTRIBUTE93        ,
       	      v_PRICING_ATTRIBUTE94        ,
       	      v_PRICING_ATTRIBUTE95        ,
       	      v_PRICING_ATTRIBUTE96        ,
       	      v_PRICING_ATTRIBUTE97        ,
       	      v_PRICING_ATTRIBUTE98        ,
       	      v_PRICING_ATTRIBUTE99        ,
       	      v_PRICING_ATTRIBUTE100       ,
       	      v_PRICING_ATTRIBUTE60        ,
       	      --v_SECURITY_GROUP_ID          ,
              --v_UPGRADED_STATUS_FLAG       ,
              --v_ORIG_SYSTEM_REFERENCE_ID   ,
              v_NO_CHARGE_FLAG             ,
              v_ORG_ID                     ,
              v_ITEM_REVISION              ,
              --v_TRANS_INV_ORGANIZATION_ID  ,
              --v_TRANS_SUBINVENTORY         ,
              --v_ACTIVITY_DATE              ,
              --v_ACTIVITY_START_TIME        ,
              --v_ACTIVITY_END_TIME          ,
              v_GENERATED_BY_BCA_ENGINE_FLAG   ,
              v_TRANSACTION_INVENTORY_ORG  ,
              v_TRANSACTION_SUB_INVENTORY  ,
              v_ACTIVITY_START_DATE_TIME   ,
              v_ACTIVITY_END_DATE_TIME     ,
              v_CHARGE_LINE_TYPE           ,
              v_SHIP_TO_CONTACT_ID         ,
              v_BILL_TO_CONTACT_ID         ,
              v_SHIP_TO_ACCOUNT_ID         ,
              v_INVOICE_TO_ACCOUNT_ID      ,
              v_LIST_PRICE                 ,
              v_CONTRACT_DISCOUNT_AMOUNT   ,
              v_BILL_TO_PARTY_ID           ,
              v_SHIP_TO_PARTY_ID           ,
              v_SUBMIT_RESTRICTION_MESSAGE ,
              v_SUBMIT_ERROR_MESSAGE       ,
              v_LINE_SUBMITTED             ,
              v_SUBMIT_FROM_SYSTEM
	      --sangigup 4610625
              , v_contract_line_id
              , v_rate_type_Code
              --sangigup

              LIMIT MAX_BUFFER_SIZE;

            -- gilam: added array size for looping
            -- Loop through each of the arrays to get values for other variables
            l_Array_size := v_ESTIMATE_DETAIL_ID.Count ;
		  If l_Array_Size = 0 Then
		    Exit;
		  End If;

            --FOR j IN 1..est_det_arr.COUNT
            FOR j IN 1..l_Array_Size

                LOOP
                    SAVEPOINT CSD_COPY_ESTIMATE_DETAILS;

                    BEGIN
                          -- This is interfaced Charge lines (type - Actual) estimate_detail_id
                          l_old_est_detail_id := v_ESTIMATE_DETAIL_ID(j);

                          -- charges display sequence number
                          SELECT max(line_number) + 1
                            INTO l_line_num
                            FROM CS_ESTIMATE_DETAILS
                           WHERE incident_id = v_INCIDENT_ID(j);

                         l_line_num := NVL(l_line_num,1);

                          -- This is newly created Charge lines (type - Estimate) estimate_detail_id
                          -- l_ed_id is our l_new_est_detail_id
                          SELECT cs_estimate_details_s.nextval
                            INTO l_new_est_detail_id
                            FROM SYS.DUAL;

                          -- get the actual header id : only one actual header for each repair line
                          SELECT repair_actual_id
                            INTO l_actual_id
                            FROM CSD_REPAIR_ACTUALS
                           WHERE repair_line_id = v_ORIGINAL_SOURCE_ID(j);

                          -- gilam: add this query to get repair estimate line id for creating actual line
                          -- get the repair estimate line id : to set as the source id of the new actual line
                          SELECT repair_estimate_line_id
                            INTO l_rep_est_line_id
                            FROM CSD_REPAIR_ESTIMATE_LINES
                           WHERE estimate_detail_id = l_old_est_detail_id;

                          BEGIN
                              -- Now copy the Actual line to Estimate charge line

                             CS_ESTIMATE_DETAILS_PKG.Insert_Row(
                                    p_org_id                           => v_ORG_ID(j),
                                    p_incident_id                      => v_INCIDENT_ID(j),
                                    p_original_source_id               => v_ORIGINAL_SOURCE_ID(j),
                                    p_original_source_code             => v_ORIGINAL_SOURCE_CODE(j),
                                    p_source_id                        => v_SOURCE_ID(j),
                                    p_source_code                      => v_SOURCE_CODE(j),
                                    p_contract_id                      => v_CONTRACT_ID(j),
                                    p_coverage_id                      => v_COVERAGE_ID(j),
                                    p_coverage_txn_group_id            => v_COVERAGE_TXN_GROUP_ID(j),
                                    p_CURRENCY_CODE                    => v_CURRENCY_CODE(j),
                                    p_CONVERSION_RATE                  => v_CONVERSION_RATE(j),
                                    p_CONVERSION_TYPE_CODE             => v_CONVERSION_TYPE_CODE(j),
                                    p_CONVERSION_RATE_DATE             => v_CONVERSION_RATE_DATE(j),
                                    p_invoice_to_org_id                => v_INVOICE_TO_ORG_ID(j),
                                    p_ship_to_org_id                   => v_SHIP_TO_ORG_ID(j),
                                    p_purchase_order_num               => v_PURCHASE_ORDER_NUM(j),
                                    p_order_line_id                    => NULL,                              -- changed
                                    p_line_type_id                     => v_LINE_TYPE_ID(j),
                                    p_LINE_CATEGORY_CODE               => v_LINE_CATEGORY_CODE(j),
                                    p_price_list_header_id             => v_PRICE_LIST_HEADER_ID(j),         -- changed
                                    p_line_number                      => v_LINE_NUMBER(j),
                                    p_inventory_item_id                => v_INVENTORY_ITEM_ID(j),
                                    p_item_revision	               => v_ITEM_REVISION(j),
                                    p_SERIAL_NUMBER                    => v_SERIAL_NUMBER(j),
                                    p_quantity_required                => v_QUANTITY_REQUIRED(j),
                                    p_unit_of_measure_code             => v_UNIT_OF_MEASURE_CODE(j),
                                    p_selling_price                    => v_SELLING_PRICE(j),
                                    p_after_warranty_cost              => v_AFTER_WARRANTY_COST(j),
                                    p_business_process_id              => v_BUSINESS_PROCESS_ID(j),
                                    p_transaction_type_id              => v_TRANSACTION_TYPE_ID(j),
                                    p_customer_product_id              => v_CUSTOMER_PRODUCT_ID(j),
                                    p_order_header_id                  => NULL,                                 -- changed
                                    p_installed_cp_return_by_date      => v_INSTALLED_CP_RETURN_BY_DATE(j),
                                    p_new_cp_return_by_date            => v_NEW_CP_RETURN_BY_DATE(j),
                                    p_interface_to_oe_flag             => 'N',                                  -- changed
                                    p_rollup_flag                      => v_ROLLUP_FLAG(j),
                                    p_no_charge_flag                   => v_NO_CHARGE_FLAG(j),
                                    p_add_to_order_flag                => 'N',                                  -- changed
                                    p_return_reason_code               => v_RETURN_REASON_CODE(j),
                                    p_generated_by_bca_engine_flag     => NULL,                                 -- changed
                                    p_transaction_inventory_org        => v_TRANSACTION_INVENTORY_ORG(j),
                                    p_transaction_sub_inventory	       => v_TRANSACTION_SUB_INVENTORY(j),
                                    p_charge_line_type                 => 'ESTIMATE',                           -- changed
                                    p_ship_to_account_id               => v_SHIP_TO_ACCOUNT_ID(j),
                                    p_invoice_to_account_id            => v_INVOICE_TO_ACCOUNT_ID(j),       -- changed
                                    p_ship_to_contact_id               => v_SHIP_TO_CONTACT_ID(j),
                                    p_bill_to_contact_id               => v_BILL_TO_CONTACT_ID(j),
                                    p_list_price                       => v_LIST_PRICE(j),
                                    p_activity_start_date_time         => v_ACTIVITY_START_DATE_TIME(j),
                                    p_activity_end_date_time           => v_ACTIVITY_END_DATE_TIME(j),
                                    p_contract_discount_amount         => v_CONTRACT_DISCOUNT_AMOUNT(j),
                                    p_bill_to_party_id                 => v_BILL_TO_PARTY_ID(j),
                                    p_ship_to_party_id                 => v_SHIP_TO_PARTY_ID(j),
                                    p_pricing_context                  => v_PRICING_CONTEXT(j),
                                    p_pricing_attribute1               => v_PRICING_ATTRIBUTE1(j),
                                    p_pricing_attribute2               => v_PRICING_ATTRIBUTE2(j),
                                    p_pricing_attribute3               => v_PRICING_ATTRIBUTE3(j),
                                    p_pricing_attribute4               => v_PRICING_ATTRIBUTE4(j),
                                    p_pricing_attribute5               => v_PRICING_ATTRIBUTE5(j),
                                    p_pricing_attribute6               => v_PRICING_ATTRIBUTE6(j),
                                    p_pricing_attribute7               => v_PRICING_ATTRIBUTE7(j),
                                    p_pricing_attribute8               => v_PRICING_ATTRIBUTE8(j),
                                    p_pricing_attribute9               => v_PRICING_ATTRIBUTE9(j),
                                    p_pricing_attribute10              => v_PRICING_ATTRIBUTE10(j),
                                    p_pricing_attribute11              => v_PRICING_ATTRIBUTE11(j),
                                    p_pricing_attribute12              => v_PRICING_ATTRIBUTE12(j),
                                    p_pricing_attribute13              => v_PRICING_ATTRIBUTE13(j),
                                    p_pricing_attribute14              => v_PRICING_ATTRIBUTE14(j),
                                    p_pricing_attribute15              => v_PRICING_ATTRIBUTE15(j),
                                    p_pricing_attribute16              => v_PRICING_ATTRIBUTE16(j),
                                    p_pricing_attribute17              => v_PRICING_ATTRIBUTE17(j),
                                    p_pricing_attribute18              => v_PRICING_ATTRIBUTE18(j),
                                    p_pricing_attribute19              => v_PRICING_ATTRIBUTE19(j),
                                    p_pricing_attribute20              => v_PRICING_ATTRIBUTE20(j),
                                    p_pricing_attribute21              => v_PRICING_ATTRIBUTE21(j),
                                    p_pricing_attribute22              => v_PRICING_ATTRIBUTE22(j),
                                    p_pricing_attribute23              => v_PRICING_ATTRIBUTE23(j),
                                    p_pricing_attribute24              => v_PRICING_ATTRIBUTE24(j),
                                    p_pricing_attribute25              => v_PRICING_ATTRIBUTE25(j),
                                    p_pricing_attribute26              => v_PRICING_ATTRIBUTE26(j),
                                    p_pricing_attribute27              => v_PRICING_ATTRIBUTE27(j),
                                    p_pricing_attribute28              => v_PRICING_ATTRIBUTE28(j),
                                    p_pricing_attribute29              => v_PRICING_ATTRIBUTE29(j),
                                    p_pricing_attribute30              => v_PRICING_ATTRIBUTE30(j),
                                    p_pricing_attribute31              => v_PRICING_ATTRIBUTE31(j),
                                    p_pricing_attribute32              => v_PRICING_ATTRIBUTE32(j),
                                    p_pricing_attribute33              => v_PRICING_ATTRIBUTE33(j),
                                    p_pricing_attribute34              => v_PRICING_ATTRIBUTE34(j),
                                    p_pricing_attribute35              => v_PRICING_ATTRIBUTE35(j),
                                    p_pricing_attribute36              => v_PRICING_ATTRIBUTE36(j),
                                    p_pricing_attribute37              => v_PRICING_ATTRIBUTE37(j),
                                    p_pricing_attribute38              => v_PRICING_ATTRIBUTE38(j),
                                    p_pricing_attribute39              => v_PRICING_ATTRIBUTE39(j),
                                    p_pricing_attribute40              => v_PRICING_ATTRIBUTE40(j),
                                    p_pricing_attribute41              => v_PRICING_ATTRIBUTE41(j),
                                    p_pricing_attribute42              => v_PRICING_ATTRIBUTE42(j),
                                    p_pricing_attribute43              => v_PRICING_ATTRIBUTE43(j),
                                    p_pricing_attribute44              => v_PRICING_ATTRIBUTE44(j),
                                    p_pricing_attribute45              => v_PRICING_ATTRIBUTE45(j),
                                    p_pricing_attribute46              => v_PRICING_ATTRIBUTE46(j),
                                    p_pricing_attribute47              => v_PRICING_ATTRIBUTE47(j),
                                    p_pricing_attribute48              => v_PRICING_ATTRIBUTE48(j),
                                    p_pricing_attribute49              => v_PRICING_ATTRIBUTE49(j),
                                    p_pricing_attribute50              => v_PRICING_ATTRIBUTE50(j),
                                    p_pricing_attribute51              => v_PRICING_ATTRIBUTE51(j),
                                    p_pricing_attribute52              => v_PRICING_ATTRIBUTE52(j),
                                    p_pricing_attribute53              => v_PRICING_ATTRIBUTE53(j),
                                    p_pricing_attribute54              => v_PRICING_ATTRIBUTE54(j),
                                    p_pricing_attribute55              => v_PRICING_ATTRIBUTE55(j),
                                    p_pricing_attribute56              => v_PRICING_ATTRIBUTE56(j),
                                    p_pricing_attribute57              => v_PRICING_ATTRIBUTE57(j),
                                    p_pricing_attribute58              => v_PRICING_ATTRIBUTE58(j),
                                    p_pricing_attribute59              => v_PRICING_ATTRIBUTE59(j),
                                    p_pricing_attribute60              => v_PRICING_ATTRIBUTE60(j),
                                    p_pricing_attribute61              => v_PRICING_ATTRIBUTE61(j),
                                    p_pricing_attribute62              => v_PRICING_ATTRIBUTE62(j),
                                    p_pricing_attribute63              => v_PRICING_ATTRIBUTE63(j),
                                    p_pricing_attribute64              => v_PRICING_ATTRIBUTE64(j),
                                    p_pricing_attribute65              => v_PRICING_ATTRIBUTE65(j),
                                    p_pricing_attribute66              => v_PRICING_ATTRIBUTE66(j),
                                    p_pricing_attribute67              => v_PRICING_ATTRIBUTE67(j),
                                    p_pricing_attribute68              => v_PRICING_ATTRIBUTE68(j),
                                    p_pricing_attribute69              => v_PRICING_ATTRIBUTE69(j),
                                    p_pricing_attribute70              => v_PRICING_ATTRIBUTE70(j),
                                    p_pricing_attribute71              => v_PRICING_ATTRIBUTE71(j),
                                    p_pricing_attribute72              => v_PRICING_ATTRIBUTE72(j),
                                    p_pricing_attribute73              => v_PRICING_ATTRIBUTE73(j),
                                    p_pricing_attribute74              => v_PRICING_ATTRIBUTE74(j),
                                    p_pricing_attribute75              => v_PRICING_ATTRIBUTE75(j),
                                    p_pricing_attribute76              => v_PRICING_ATTRIBUTE76(j),
                                    p_pricing_attribute77              => v_PRICING_ATTRIBUTE77(j),
                                    p_pricing_attribute78              => v_PRICING_ATTRIBUTE78(j),
                                    p_pricing_attribute79              => v_PRICING_ATTRIBUTE79(j),
                                    p_pricing_attribute80              => v_PRICING_ATTRIBUTE80(j),
                                    p_pricing_attribute81              => v_PRICING_ATTRIBUTE81(j),
                                    p_pricing_attribute82              => v_PRICING_ATTRIBUTE82(j),
                                    p_pricing_attribute83              => v_PRICING_ATTRIBUTE83(j),
                                    p_pricing_attribute84              => v_PRICING_ATTRIBUTE84(j),
                                    p_pricing_attribute85              => v_PRICING_ATTRIBUTE85(j),
                                    p_pricing_attribute86              => v_PRICING_ATTRIBUTE86(j),
                                    p_pricing_attribute87              => v_PRICING_ATTRIBUTE87(j),
                                    p_pricing_attribute88              => v_PRICING_ATTRIBUTE88(j),
                                    p_pricing_attribute89              => v_PRICING_ATTRIBUTE89(j),
                                    p_pricing_attribute90              => v_PRICING_ATTRIBUTE90(j),
                                    p_pricing_attribute91              => v_PRICING_ATTRIBUTE91(j),
                                    p_pricing_attribute92              => v_PRICING_ATTRIBUTE92(j),
                                    p_pricing_attribute93              => v_PRICING_ATTRIBUTE93(j),
                                    p_pricing_attribute94              => v_PRICING_ATTRIBUTE94(j),
                                    p_pricing_attribute95              => v_PRICING_ATTRIBUTE95(j),
                                    p_pricing_attribute96              => v_PRICING_ATTRIBUTE96(j),
                                    p_pricing_attribute97              => v_PRICING_ATTRIBUTE97(j),
                                    p_pricing_attribute98              => v_PRICING_ATTRIBUTE98(j),
                                    p_pricing_attribute99              => v_PRICING_ATTRIBUTE99(j),
                                    p_pricing_attribute100             => v_PRICING_ATTRIBUTE100(j),
                                    p_attribute1                       => v_ATTRIBUTE1(j),
                                    p_attribute2                       => v_ATTRIBUTE2(j),
                                    p_attribute3                       => v_ATTRIBUTE3(j),
                                    p_attribute4                       => v_ATTRIBUTE4(j),
                                    p_attribute5                       => v_ATTRIBUTE5(j),
                                    p_attribute6                       => v_ATTRIBUTE6(j),
                                    p_attribute7                       => v_ATTRIBUTE7(j),
                                    p_attribute8                       => v_ATTRIBUTE8(j),
                                    p_attribute9                       => v_ATTRIBUTE9(j),
                                    p_attribute10                      => v_ATTRIBUTE10(j),
                                    p_attribute11                      => v_ATTRIBUTE11(j),
                                    p_attribute12                      => v_ATTRIBUTE12(j),
                                    p_attribute13                      => v_ATTRIBUTE13(j),
                                    p_attribute14                      => v_ATTRIBUTE14(j),
                                    p_attribute15                      => v_ATTRIBUTE15(j),
                                    p_context                          => v_CONTEXT(j),
                                    p_coverage_bill_rate_id            => v_COVERAGE_BILL_RATE_ID(j),
                                    p_coverage_billing_type_id         => null,
                                    p_txn_billing_type_id              => v_TXN_BILLING_TYPE_ID(j),
                                    p_submit_restriction_message       => v_SUBMIT_RESTRICTION_MESSAGE(j),
                                    p_submit_error_message             => v_SUBMIT_ERROR_MESSAGE(j),
                                    p_submit_from_system               => v_SUBMIT_FROM_SYSTEM(j),
                                    p_line_submitted                   => null,
				      --sangigup 4610625
                                    p_contract_line_id                 => null,
                                    p_rate_type_Code                   => null,
                                    --sangigup
                                    p_last_update_date                 => sysdate,
                                    --p_last_update_login              => p_user_id,
                                    p_last_update_login                => null,                  -- changed to null for create
                                    p_last_updated_by                  => FND_GLOBAL.USER_ID,
                                    p_creation_date                    => sysdate,
                                    p_created_by                       => FND_GLOBAL.USER_ID,
                                    p_estimate_detail_id               => l_new_est_detail_id,
                                    x_object_version_number            => x_object_version_number
                                    );

                                    -- changed values
                                    --p_estimate_detail_id               => l_ed_id,
                                    --p_interface_to_oe_flag             => est_det_arr(j).interface_to_oe_flag,
                                    --p_order_header_id                  => est_det_arr(j).order_header_id,
                                    --p_order_line_id                    => est_det_arr(j).order_line_id,
                                    --p_add_to_order_flag                => est_det_arr(j).add_to_order_flag,
                                    --p_charge_line_type                 => est_det_arr(j).charge_line_type,
                                    --p_price_list_header_id             => est_det_arr(j).price_list_id,
                                    --p_inventory_item_id                => est_det_arr(j).inventory_item_id_in,
                                    --p_generated_by_bca_engine_flag     => est_det_arr(j).generated_by_bca_engine,
                                    --p_invoice_to_account_id            => est_det_arr(j).bill_to_account_id,

                          EXCEPTION
                              WHEN OTHERS THEN
                                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'CS_ESTIMATE_DETAILS_PKG.Insert_Row Failed - For Estimate Detail Id:'
                                || v_ESTIMATE_DETAIL_ID(j);
                                RAISE error_process;
                          END;

                          BEGIN

                            -- Call table handler CSD_REPAIR_ACTUALS_LINES_PKG.Insert_Row to
                            -- insert the record into CSD_REPAIR_ACTUAL_LINES
                            -- this is Depot Actual line created from the Estimate line

                            -- gilam: clear out actual line id when creating new row
                            x_actual_line_id := null;

                            -- gilam: changed actual source code to ESTIMATE and
                            --        actual source id to repair estimate line id
                            CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row(
                                   px_REPAIR_ACTUAL_LINE_ID  => x_actual_line_id
                                  ,p_OBJECT_VERSION_NUMBER   => 1
                                  ,p_ESTIMATE_DETAIL_ID      => l_old_est_detail_id
                                  ,p_REPAIR_ACTUAL_ID        => l_actual_id
                                  ,p_REPAIR_LINE_ID          => v_ORIGINAL_SOURCE_ID(j)
                                  ,p_CREATED_BY              => FND_GLOBAL.USER_ID
                                  ,p_CREATION_DATE           => SYSDATE
                                  ,p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID
                                  ,p_LAST_UPDATE_DATE        => SYSDATE
                                  ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID
                                  ,p_ITEM_COST               => null
                                  ,p_JUSTIFICATION_NOTES     => null
                                  ,p_RESOURCE_ID             => null
                                  ,p_OVERRIDE_CHARGE_FLAG    => null
                                  ,p_ACTUAL_SOURCE_CODE      => 'ESTIMATE'
                                  ,p_ACTUAL_SOURCE_ID        => l_rep_est_line_id
                                  ,p_WARRANTY_CLAIM_FLAG     => null
                                  ,p_WARRANTY_NUMBER         => null
                                  ,p_WARRANTY_STATUS_CODE    => null
                                  ,p_REPLACED_ITEM_ID        => null
                                  ,p_ATTRIBUTE_CATEGORY      => null
                                  ,p_ATTRIBUTE1              => null
                                  ,p_ATTRIBUTE2              => null
                                  ,p_ATTRIBUTE3              => null
                                  ,p_ATTRIBUTE4              => null
                                  ,p_ATTRIBUTE5              => null
                                  ,p_ATTRIBUTE6              => null
                                  ,p_ATTRIBUTE7              => null
                                  ,p_ATTRIBUTE8              => null
                                  ,p_ATTRIBUTE9              => null
                                  ,p_ATTRIBUTE10             => null
                                  ,p_ATTRIBUTE11             => null
                                  ,p_ATTRIBUTE12             => null
                                  ,p_ATTRIBUTE13             => null
                                  ,p_ATTRIBUTE14             => null
                                  ,p_ATTRIBUTE15             => null
                                  ,p_LOCATOR_ID              => null
                                  ,p_LOC_SEGMENT1            => null
                                  ,p_LOC_SEGMENT2            => null
                                  ,p_LOC_SEGMENT3            => null
                                  ,p_LOC_SEGMENT4            => null
                                  ,p_LOC_SEGMENT5            => null
                                  ,p_LOC_SEGMENT6            => null
                                  ,p_LOC_SEGMENT7            => null
                                  ,p_LOC_SEGMENT8            => null
                                  ,p_LOC_SEGMENT9            => null
                                  ,p_LOC_SEGMENT10           => null
                                  ,p_LOC_SEGMENT11           => null
                                  ,p_LOC_SEGMENT12           => null
                                  ,p_LOC_SEGMENT13           => null
                                  ,p_LOC_SEGMENT14           => null
                                  ,p_LOC_SEGMENT15           => null
                                  ,p_LOC_SEGMENT16           => null
                                  ,p_LOC_SEGMENT17           => null
                                  ,p_LOC_SEGMENT18           => null
                                  ,p_LOC_SEGMENT19           => null
                                  ,p_LOC_SEGMENT20           => null);

                          EXCEPTION
                              WHEN OTHERS THEN
                                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row Failed - For Estimate Detail Id:'
                                || l_old_est_detail_id
                                || ' Loop for Estimate Detail Id: '
                                || v_ESTIMATE_DETAIL_ID(j);
                                RAISE error_process;
                          END;

                          BEGIN

                               -- Update the Depot Estimate line to point to new charge line (type - Estimate)
                               -- where it is pointing to the old charge line (type - Actual)
                               UPDATE CSD_REPAIR_ESTIMATE_LINES
                                  SET ESTIMATE_DETAIL_ID = l_new_est_detail_id
                                WHERE ESTIMATE_DETAIL_ID = l_old_est_detail_id;

                          EXCEPTION
                              WHEN OTHERS THEN
                                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'UPDATE CSD_REPAIR_ESTIMATE_LINES Failed - To update Estimate Detail Id to :'
                                || l_new_est_detail_id
                                || ' from Estimate Detail Id: '
                                || l_old_est_detail_id;
                                RAISE error_process;
                          END;

                        IF SQL%NOTFOUND
                            THEN
                                RAISE error_process;
                        END IF;

                        EXCEPTION
                            WHEN error_process THEN
                                ROLLBACK TO CSD_COPY_ESTIMATE_DETAILS;
                                -- check if v_error_text is null, if yes then set the value
                                -- else the value is propagated from the error sources above
                                if (v_error_text is null) then
                                    v_error_text := substr(sqlerrm, 1, 1000)
                                                   || 'Actual Estimate Detail Id:'
                                                   || v_ESTIMATE_DETAIL_ID(j);
                                end if;

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_REPAIR_ESTIMATE_LINES',
                                            'CS_ESTIMATE_DETAILS',
                                            v_ESTIMATE_DETAIL_ID(j),
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');

						            commit;

                           		    raise_application_error( -20000, v_error_text);

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_charge_est_details%NOTFOUND;
        END LOOP;

/*  gilam: commented out the varray rowtype code
                          -- This is interfaced Charge lines (type - Actual) estimate_detail_id
                          l_old_est_detail_id := est_det_arr(j).estimate_detail_id;

                          -- charges display sequence number
                          SELECT max(line_number) + 1
                            INTO l_line_num
                            FROM CS_ESTIMATE_DETAILS
                           WHERE incident_id = est_det_arr(j).incident_id;

                         l_line_num := NVL(l_line_num,1);

                          -- This is newly created Charge lines (type - Estimate) estimate_detail_id
                          -- l_ed_id is our l_new_est_detail_id
                          SELECT cs_estimate_details_s.nextval
                            INTO l_new_est_detail_id
                            FROM SYS.DUAL;

                          -- get the actual header id : only one actual header for each repair line
                          SELECT repair_actual_id
                            INTO l_actual_id
                            FROM CSD_REPAIR_ACTUALS
                           WHERE repair_line_id = est_det_arr(j).original_source_id;

                          -- gilam: add this query to get repair estimate line id for creating actual line
                          -- get the repair estimate line id : to set as the source id of the new actual line
                          SELECT repair_estimate_line_id
                            INTO l_rep_est_line_id
                            FROM CSD_REPAIR_ESTIMATE_LINES
                           WHERE estimate_detail_id = l_old_est_detail_id;

                          BEGIN
                              -- Now copy the Actual line to Estimate charge line
                              CS_ESTIMATE_DETAILS_PKG.Insert_Row(
                                    p_org_id                           => est_det_arr(j).org_id,
                                    p_incident_id                      => est_det_arr(j).incident_id,
                                    p_original_source_id               => est_det_arr(j).original_source_id,
                                    p_original_source_code             => est_det_arr(j).original_source_code,
                                    p_source_id                        => est_det_arr(j).source_id,
                                    p_source_code                      => est_det_arr(j).source_code,
                                    p_contract_id                      => est_det_arr(j).contract_id,
                                    p_coverage_id                      => est_det_arr(j).coverage_id,
                                    p_coverage_txn_group_id            => est_det_arr(j).coverage_txn_group_id,
                                    p_CURRENCY_CODE                    => est_det_arr(j).currency_code,
                                    p_CONVERSION_RATE                  => est_det_arr(j).conversion_rate,
                                    p_CONVERSION_TYPE_CODE             => est_det_arr(j).conversion_type_code,
                                    p_CONVERSION_RATE_DATE             => est_det_arr(j).conversion_rate_date,
                                    p_invoice_to_org_id                => est_det_arr(j).invoice_to_org_id,
                                    p_ship_to_org_id                   => est_det_arr(j).ship_to_org_id,
                                    p_purchase_order_num               => est_det_arr(j).purchase_order_num,
                                    p_order_line_id                    => NULL,                              -- changed
                                    p_line_type_id                     => est_det_arr(j).line_type_id,
                                    p_LINE_CATEGORY_CODE               => est_det_arr(j).LINE_CATEGORY_CODE,
                                    p_price_list_header_id             => est_det_arr(j).price_list_header_id,  -- changed
                                    p_line_number                      => l_line_num,
                                    p_inventory_item_id                => est_det_arr(j).inventory_item_id,
                                    p_item_revision	                   => est_det_arr(j).item_revision,
                                    p_SERIAL_NUMBER                    => est_det_arr(j).SERIAL_NUMBER,
                                    p_quantity_required                => est_det_arr(j).quantity_required,
                                    p_unit_of_measure_code             => est_det_arr(j).unit_of_measure_code,
                                    p_selling_price                    => est_det_arr(j).selling_price,
                                    p_after_warranty_cost              => est_det_arr(j).after_warranty_cost,
                                    p_business_process_id              => est_det_arr(j).business_process_id,
                                    p_transaction_type_id              => est_det_arr(j).transaction_type_id,
                                    p_customer_product_id              => est_det_arr(j).customer_product_id,
                                    p_order_header_id                  => NULL,                                 -- changed
                                    p_installed_cp_return_by_date      => est_det_arr(j).installed_cp_return_by_date,
                                    p_new_cp_return_by_date            => est_det_arr(j).new_cp_return_by_date,
                                    p_interface_to_oe_flag             => 'N',                                  -- changed
                                    p_rollup_flag                      => est_det_arr(j).rollup_flag,
                                    p_no_charge_flag                   => est_det_arr(j).no_charge_flag,
                                    p_add_to_order_flag                => 'N',                                  -- changed
                                    p_return_reason_code               => est_det_arr(j).return_reason_code,
                                    p_generated_by_bca_engine_flag     => NULL,                                 -- changed
                                    p_transaction_inventory_org        => est_det_arr(j).transaction_inventory_org,
                                    p_transaction_sub_inventory	       => est_det_arr(j).transaction_sub_inventory,
                                    p_charge_line_type                 => 'ESTIMATE',                           -- changed
                                    p_ship_to_account_id               => est_det_arr(j).ship_to_account_id,
                                    p_invoice_to_account_id            => est_det_arr(j).bill_to_party_id,       -- changed
                                    p_ship_to_contact_id               => est_det_arr(j).ship_to_contact_id,
                                    p_bill_to_contact_id               => est_det_arr(j).bill_to_contact_id,
                                    p_list_price                       => est_det_arr(j).list_price,
                                    p_activity_start_date_time         => est_det_arr(j).activity_start_time,
                                    p_activity_end_date_time           => est_det_arr(j).activity_end_time,
                                    p_contract_discount_amount         => est_det_arr(j).contract_discount_amount,
                                    p_bill_to_party_id                 => est_det_arr(j).bill_to_party_id,
                                    p_ship_to_party_id                 => est_det_arr(j).ship_to_party_id,
                                    p_pricing_context                  => est_det_arr(j).pricing_context,
                                    p_pricing_attribute1               => est_det_arr(j).pricing_attribute1,
                                    p_pricing_attribute2               => est_det_arr(j).pricing_attribute2,
                                    p_pricing_attribute3               => est_det_arr(j).pricing_attribute3,
                                    p_pricing_attribute4               => est_det_arr(j).pricing_attribute4,
                                    p_pricing_attribute5               => est_det_arr(j).pricing_attribute5,
                                    p_pricing_attribute6               => est_det_arr(j).pricing_attribute6,
                                    p_pricing_attribute7               => est_det_arr(j).pricing_attribute7,
                                    p_pricing_attribute8               => est_det_arr(j).pricing_attribute8,
                                    p_pricing_attribute9               => est_det_arr(j).pricing_attribute9,
                                    p_pricing_attribute10              => est_det_arr(j).pricing_attribute10,
                                    p_pricing_attribute11              => est_det_arr(j).pricing_attribute11,
                                    p_pricing_attribute12              => est_det_arr(j).pricing_attribute12,
                                    p_pricing_attribute13              => est_det_arr(j).pricing_attribute13,
                                    p_pricing_attribute14              => est_det_arr(j).pricing_attribute14,
                                    p_pricing_attribute15              => est_det_arr(j).pricing_attribute15,
                                    p_pricing_attribute16              => est_det_arr(j).pricing_attribute16,
                                    p_pricing_attribute17              => est_det_arr(j).pricing_attribute17,
                                    p_pricing_attribute18              => est_det_arr(j).pricing_attribute18,
                                    p_pricing_attribute19              => est_det_arr(j).pricing_attribute19,
                                    p_pricing_attribute20              => est_det_arr(j).pricing_attribute20,
                                    p_pricing_attribute21              => est_det_arr(j).pricing_attribute21,
                                    p_pricing_attribute22              => est_det_arr(j).pricing_attribute22,
                                    p_pricing_attribute23              => est_det_arr(j).pricing_attribute23,
                                    p_pricing_attribute24              => est_det_arr(j).pricing_attribute24,
                                    p_pricing_attribute25              => est_det_arr(j).pricing_attribute25,
                                    p_pricing_attribute26              => est_det_arr(j).pricing_attribute26,
                                    p_pricing_attribute27              => est_det_arr(j).pricing_attribute27,
                                    p_pricing_attribute28              => est_det_arr(j).pricing_attribute28,
                                    p_pricing_attribute29              => est_det_arr(j).pricing_attribute29,
                                    p_pricing_attribute30              => est_det_arr(j).pricing_attribute30,
                                    p_pricing_attribute31              => est_det_arr(j).pricing_attribute31,
                                    p_pricing_attribute32              => est_det_arr(j).pricing_attribute32,
                                    p_pricing_attribute33              => est_det_arr(j).pricing_attribute33,
                                    p_pricing_attribute34              => est_det_arr(j).pricing_attribute34,
                                    p_pricing_attribute35              => est_det_arr(j).pricing_attribute35,
                                    p_pricing_attribute36              => est_det_arr(j).pricing_attribute36,
                                    p_pricing_attribute37              => est_det_arr(j).pricing_attribute37,
                                    p_pricing_attribute38              => est_det_arr(j).pricing_attribute38,
                                    p_pricing_attribute39              => est_det_arr(j).pricing_attribute39,
                                    p_pricing_attribute40              => est_det_arr(j).pricing_attribute40,
                                    p_pricing_attribute41              => est_det_arr(j).pricing_attribute41,
                                    p_pricing_attribute42              => est_det_arr(j).pricing_attribute42,
                                    p_pricing_attribute43              => est_det_arr(j).pricing_attribute43,
                                    p_pricing_attribute44              => est_det_arr(j).pricing_attribute44,
                                    p_pricing_attribute45              => est_det_arr(j).pricing_attribute45,
                                    p_pricing_attribute46              => est_det_arr(j).pricing_attribute46,
                                    p_pricing_attribute47              => est_det_arr(j).pricing_attribute47,
                                    p_pricing_attribute48              => est_det_arr(j).pricing_attribute48,
                                    p_pricing_attribute49              => est_det_arr(j).pricing_attribute49,
                                    p_pricing_attribute50              => est_det_arr(j).pricing_attribute50,
                                    p_pricing_attribute51              => est_det_arr(j).pricing_attribute51,
                                    p_pricing_attribute52              => est_det_arr(j).pricing_attribute52,
                                    p_pricing_attribute53              => est_det_arr(j).pricing_attribute53,
                                    p_pricing_attribute54              => est_det_arr(j).pricing_attribute54,
                                    p_pricing_attribute55              => est_det_arr(j).pricing_attribute55,
                                    p_pricing_attribute56              => est_det_arr(j).pricing_attribute56,
                                    p_pricing_attribute57              => est_det_arr(j).pricing_attribute57,
                                    p_pricing_attribute58              => est_det_arr(j).pricing_attribute58,
                                    p_pricing_attribute59              => est_det_arr(j).pricing_attribute59,
                                    p_pricing_attribute60              => est_det_arr(j).pricing_attribute60,
                                    p_pricing_attribute61              => est_det_arr(j).pricing_attribute61,
                                    p_pricing_attribute62              => est_det_arr(j).pricing_attribute62,
                                    p_pricing_attribute63              => est_det_arr(j).pricing_attribute63,
                                    p_pricing_attribute64              => est_det_arr(j).pricing_attribute64,
                                    p_pricing_attribute65              => est_det_arr(j).pricing_attribute65,
                                    p_pricing_attribute66              => est_det_arr(j).pricing_attribute66,
                                    p_pricing_attribute67              => est_det_arr(j).pricing_attribute67,
                                    p_pricing_attribute68              => est_det_arr(j).pricing_attribute68,
                                    p_pricing_attribute69              => est_det_arr(j).pricing_attribute69,
                                    p_pricing_attribute70              => est_det_arr(j).pricing_attribute70,
                                    p_pricing_attribute71              => est_det_arr(j).pricing_attribute71,
                                    p_pricing_attribute72              => est_det_arr(j).pricing_attribute72,
                                    p_pricing_attribute73              => est_det_arr(j).pricing_attribute73,
                                    p_pricing_attribute74              => est_det_arr(j).pricing_attribute74,
                                    p_pricing_attribute75              => est_det_arr(j).pricing_attribute75,
                                    p_pricing_attribute76              => est_det_arr(j).pricing_attribute76,
                                    p_pricing_attribute77              => est_det_arr(j).pricing_attribute77,
                                    p_pricing_attribute78              => est_det_arr(j).pricing_attribute78,
                                    p_pricing_attribute79              => est_det_arr(j).pricing_attribute79,
                                    p_pricing_attribute80              => est_det_arr(j).pricing_attribute80,
                                    p_pricing_attribute81              => est_det_arr(j).pricing_attribute81,
                                    p_pricing_attribute82              => est_det_arr(j).pricing_attribute82,
                                    p_pricing_attribute83              => est_det_arr(j).pricing_attribute83,
                                    p_pricing_attribute84              => est_det_arr(j).pricing_attribute84,
                                    p_pricing_attribute85              => est_det_arr(j).pricing_attribute85,
                                    p_pricing_attribute86              => est_det_arr(j).pricing_attribute86,
                                    p_pricing_attribute87              => est_det_arr(j).pricing_attribute87,
                                    p_pricing_attribute88              => est_det_arr(j).pricing_attribute88,
                                    p_pricing_attribute89              => est_det_arr(j).pricing_attribute89,
                                    p_pricing_attribute90              => est_det_arr(j).pricing_attribute90,
                                    p_pricing_attribute91              => est_det_arr(j).pricing_attribute91,
                                    p_pricing_attribute92              => est_det_arr(j).pricing_attribute92,
                                    p_pricing_attribute93              => est_det_arr(j).pricing_attribute93,
                                    p_pricing_attribute94              => est_det_arr(j).pricing_attribute94,
                                    p_pricing_attribute95              => est_det_arr(j).pricing_attribute95,
                                    p_pricing_attribute96              => est_det_arr(j).pricing_attribute96,
                                    p_pricing_attribute97              => est_det_arr(j).pricing_attribute97,
                                    p_pricing_attribute98              => est_det_arr(j).pricing_attribute98,
                                    p_pricing_attribute99              => est_det_arr(j).pricing_attribute99,
                                    p_pricing_attribute100             => est_det_arr(j).pricing_attribute100,
                                    p_attribute1                       => est_det_arr(j).attribute1,
                                    p_attribute2                       => est_det_arr(j).attribute2,
                                    p_attribute3                       => est_det_arr(j).attribute3,
                                    p_attribute4                       => est_det_arr(j).attribute4,
                                    p_attribute5                       => est_det_arr(j).attribute5,
                                    p_attribute6                       => est_det_arr(j).attribute6,
                                    p_attribute7                       => est_det_arr(j).attribute7,
                                    p_attribute8                       => est_det_arr(j).attribute8,
                                    p_attribute9                       => est_det_arr(j).attribute9,
                                    p_attribute10                      => est_det_arr(j).attribute10,
                                    p_attribute11                      => est_det_arr(j).attribute11,
                                    p_attribute12                      => est_det_arr(j).attribute12,
                                    p_attribute13                      => est_det_arr(j).attribute13,
                                    p_attribute14                      => est_det_arr(j).attribute14,
                                    p_attribute15                      => est_det_arr(j).attribute15,
                                    p_context                          => est_det_arr(j).context,
                                    p_coverage_bill_rate_id            => est_det_arr(j).coverage_bill_rate_id,
                                    p_coverage_billing_type_id         => null,
                                    p_txn_billing_type_id              => est_det_arr(j).txn_billing_type_id,
                                    p_submit_restriction_message       => est_det_arr(j).submit_restriction_message,
                                    p_submit_error_message             => est_det_arr(j).submit_error_message,
                                    p_submit_from_system               => est_det_arr(j).submit_from_system,
                                    p_line_submitted                   => null,
                                    p_last_update_date                 => sysdate,
                                    --p_last_update_login              => p_user_id,
                                    p_last_update_login                => null,                  -- changed to null for create
                                    p_last_updated_by                  => FND_GLOBAL.USER_ID,
                                    p_creation_date                    => sysdate,
                                    p_created_by                       => FND_GLOBAL.USER_ID,
                                    p_estimate_detail_id               => l_new_est_detail_id,
                                    x_object_version_number            => x_object_version_number );

                                    -- changed values
                                    --p_estimate_detail_id               => l_ed_id,
                                    --p_interface_to_oe_flag             => est_det_arr(j).interface_to_oe_flag,
                                    --p_order_header_id                  => est_det_arr(j).order_header_id,
                                    --p_order_line_id                    => est_det_arr(j).order_line_id,
                                    --p_add_to_order_flag                => est_det_arr(j).add_to_order_flag,
                                    --p_charge_line_type                 => est_det_arr(j).charge_line_type,
                                    --p_price_list_header_id             => est_det_arr(j).price_list_id,
                                    --p_inventory_item_id                => est_det_arr(j).inventory_item_id_in,
                                    --p_generated_by_bca_engine_flag     => est_det_arr(j).generated_by_bca_engine,
                                    --p_invoice_to_account_id            => est_det_arr(j).bill_to_account_id,

                          EXCEPTION
                              WHEN OTHERS THEN
                                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'CS_ESTIMATE_DETAILS_PKG.Insert_Row Failed - For Estimate Detail Id:'
                                || est_det_arr(j).estimate_detail_id;
                                RAISE error_process;
                          END;

                          BEGIN

                            -- Call table handler CSD_REPAIR_ACTUALS_LINES_PKG.Insert_Row to
                            -- insert the record into CSD_REPAIR_ACTUAL_LINES
                            -- this is Depot Actual line created from the Estimate line

                            -- gilam: clear out actual line id when creating new row
                            x_actual_line_id := null;

                            -- gilam: changed actual source code to ESTIMATE and
                            --        actual source id to repair estimate line id
                            CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row(
                                   px_REPAIR_ACTUAL_LINE_ID  => x_actual_line_id
                                  ,p_OBJECT_VERSION_NUMBER   => 1
                                  ,p_ESTIMATE_DETAIL_ID      => l_old_est_detail_id
                                  ,p_REPAIR_ACTUAL_ID        => l_actual_id
                                  ,p_REPAIR_LINE_ID          => est_det_arr(j).original_source_id
                                  ,p_CREATED_BY              => FND_GLOBAL.USER_ID
                                  ,p_CREATION_DATE           => SYSDATE
                                  ,p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID
                                  ,p_LAST_UPDATE_DATE        => SYSDATE
                                  ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID
                                  ,p_ITEM_COST               => null
                                  ,p_JUSTIFICATION_NOTES     => null
                                  ,p_RESOURCE_ID             => null
                                  ,p_OVERRIDE_CHARGE_FLAG    => null
                                  ,p_ACTUAL_SOURCE_CODE      => 'ESTIMATE'
                                  ,p_ACTUAL_SOURCE_ID        => l_rep_est_line_id
                                  ,p_WARRANTY_CLAIM_FLAG     => null
                                  ,p_WARRANTY_NUMBER         => null
                                  ,p_WARRANTY_STATUS_CODE    => null
                                  ,p_REPLACED_ITEM_ID        => null
                                  ,p_ATTRIBUTE_CATEGORY      => null
                                  ,p_ATTRIBUTE1              => null
                                  ,p_ATTRIBUTE2              => null
                                  ,p_ATTRIBUTE3              => null
                                  ,p_ATTRIBUTE4              => null
                                  ,p_ATTRIBUTE5              => null
                                  ,p_ATTRIBUTE6              => null
                                  ,p_ATTRIBUTE7              => null
                                  ,p_ATTRIBUTE8              => null
                                  ,p_ATTRIBUTE9              => null
                                  ,p_ATTRIBUTE10             => null
                                  ,p_ATTRIBUTE11             => null
                                  ,p_ATTRIBUTE12             => null
                                  ,p_ATTRIBUTE13             => null
                                  ,p_ATTRIBUTE14             => null
                                  ,p_ATTRIBUTE15             => null
                                  ,p_LOCATOR_ID              => null
                                  ,p_LOC_SEGMENT1            => null
                                  ,p_LOC_SEGMENT2            => null
                                  ,p_LOC_SEGMENT3            => null
                                  ,p_LOC_SEGMENT4            => null
                                  ,p_LOC_SEGMENT5            => null
                                  ,p_LOC_SEGMENT6            => null
                                  ,p_LOC_SEGMENT7            => null
                                  ,p_LOC_SEGMENT8            => null
                                  ,p_LOC_SEGMENT9            => null
                                  ,p_LOC_SEGMENT10           => null
                                  ,p_LOC_SEGMENT11           => null
                                  ,p_LOC_SEGMENT12           => null
                                  ,p_LOC_SEGMENT13           => null
                                  ,p_LOC_SEGMENT14           => null
                                  ,p_LOC_SEGMENT15           => null
                                  ,p_LOC_SEGMENT16           => null
                                  ,p_LOC_SEGMENT17           => null
                                  ,p_LOC_SEGMENT18           => null
                                  ,p_LOC_SEGMENT19           => null
                                  ,p_LOC_SEGMENT20           => null);

                          EXCEPTION
                              WHEN OTHERS THEN
                                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'CSD_REPAIR_ACTUAL_LINES_PKG.Insert_Row Failed - For Estimate Detail Id:'
                                || l_old_est_detail_id
                                || ' Loop for Estimate Detail Id: '
                                || est_det_arr(j).estimate_detail_id;
                                RAISE error_process;
                          END;

                          BEGIN

                               -- Update the Depot Estimate line to point to new charge line (type - Estimate)
                               -- where it is pointing to the old charge line (typa - Actual)
                               UPDATE CSD_REPAIR_ESTIMATE_LINES
                                  SET ESTIMATE_DETAIL_ID = l_new_est_detail_id
                                WHERE ESTIMATE_DETAIL_ID = l_old_est_detail_id;

                          EXCEPTION
                              WHEN OTHERS THEN
                                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'UPDATE CSD_REPAIR_ESTIMATE_LINES Failed - To update Estimate Detail Id to :'
                                || l_new_est_detail_id
                                || ' from Estimate Detail Id: '
                                || l_old_est_detail_id;
                                RAISE error_process;
                          END;

                        IF SQL%NOTFOUND
                            THEN
                                RAISE error_process;
                        END IF;

                        EXCEPTION
                            WHEN error_process THEN
                                ROLLBACK TO CSD_COPY_ESTIMATE_DETAILS;
                                -- check if v_error_text is null, if yes then set the value
                                -- else the value is propagated from the error sources above
                                if (v_error_text is null) then
                                    v_error_text := substr(sqlerrm, 1, 1000)
                                                   || 'Actual Estimate Detail Id:'
                                                   || est_det_arr(j).estimate_detail_id;
                                end if;

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_REPAIR_ESTIMATE_LINES',
                                            'CS_ESTIMATE_DETAILS',
                                            est_det_arr(j).estimate_detail_id,
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_charge_est_details%NOTFOUND;
        END LOOP;
*/

        IF get_charge_est_details%ISOPEN
            THEN
                CLOSE get_charge_est_details;
        END IF;
        COMMIT;
    END csd_acttoest_charge_line_mig3;

    /*-------------------------------------------------------------------------------*/

    /* procedure name: CSD_REPAIR_JOB_XREF_MIG3                                      */

    /* description   : procedure for migrating CSD_REPAIR_JOB_XREF table data        */

    /*                 from 11.5.9 to 11.5.10                                        */

    /*                                                                               */

    /*-------------------------------------------------------------------------------*/

    PROCEDURE csd_repair_job_xref_mig3(p_slab_number IN NUMBER)
    IS

        TYPE NumTabType IS VARRAY(1000) OF NUMBER;
        repair_job_xref_id_mig NumTabType;

        TYPE RowidTabType IS VARRAY(1000) OF VARCHAR2(30);
        rowid_mig       RowidTabtype;
        v_min           NUMBER;
        v_max           NUMBER;
        v_error_text    VARCHAR2(2000);
        MAX_BUFFER_SIZE NUMBER         := 500;
        error_process EXCEPTION;


        -- Cursor to get all rows where wip_entity_id has the same value
        -- as the group_id

        CURSOR get_job_name_id_rows_cursor (p_start number, p_end number)
        IS
          SELECT repair_job_xref_id, rowid
          FROM   csd_repair_job_xref
          WHERE  wip_entity_id = group_id AND repair_job_xref_id >= p_start
             AND repair_job_xref_id <= p_end;


        -- Cursor to get all rows where source_type_code is NULL

        CURSOR get_source_type_rows_cursor (p_start number, p_end number)
        IS
          SELECT repair_job_xref_id, rowid
          FROM   csd_repair_job_xref
          WHERE  source_type_code IS NULL AND repair_job_xref_id >= p_start
             AND repair_job_xref_id <= p_end;

    BEGIN

        -- Get the Slab Number for the table

        BEGIN
            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIR_JOB_XREF',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);

            IF v_min IS NULL
                THEN
                    RETURN;
            END IF;

        END;

        -- Migration code for Job_name and WIP_entity_id in CSD_REPAIR_JOB_XREF

        OPEN get_job_name_id_rows_cursor (v_min, v_max);

        LOOP

            -- Get all rows where wip_entity_id has the same value
            -- as the group_id

            FETCH get_job_name_id_rows_cursor BULK COLLECT INTO repair_job_xref_id_mig,
                                                                rowid_mig LIMIT MAX_BUFFER_SIZE;
            FOR j IN 1..repair_job_xref_id_mig.COUNT
                LOOP
                    SAVEPOINT CSD_REPAIR_JOB_XREF;

                    BEGIN

                        -- Update wip_entity_id to NULL and
                        -- job name to CSD||group_id

                        UPDATE csd_repair_job_xref
                        SET    wip_entity_id = NULL,
                               job_name = 'CSD' || group_id
                        WHERE  rowid = rowid_mig(j);

                        IF SQL%NOTFOUND
                            THEN
                                RAISE error_process;
                        END IF;

                        EXCEPTION
                            WHEN error_process THEN
                                ROLLBACK TO CSD_REPAIR_JOB_XREF;
                                v_error_text := substr(sqlerrm, 1, 1000)
                                                || 'Repair Job Xref Id:'
                                                || repair_job_xref_id_mig(j);

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_REPAIR_JOB_XREF',
                                            'CSD_REPAIR_JOB_XREF',
                                            repair_job_xref_id_mig(j),
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');

						        commit;

                           		raise_application_error( -20000, 'Error while migrating CSD_REPAIR_JOB_XREF table data: Error while updating csd_repair_job_xref. '|| v_error_text);

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_job_name_id_rows_cursor%NOTFOUND;
        END LOOP;

        IF get_job_name_id_rows_cursor%ISOPEN
            THEN
                CLOSE get_job_name_id_rows_cursor;
        END IF;

        -- Migration code for SOURCE_TYPE_CODE in CSD_REPAIR_JOB_XREF

        OPEN get_source_type_rows_cursor (v_min, v_max);

        LOOP

            -- Get all rows where source_type_code is NULL

            FETCH get_source_type_rows_cursor BULK COLLECT INTO repair_job_xref_id_mig,
                                                                rowid_mig LIMIT MAX_BUFFER_SIZE;
            FOR j IN 1..repair_job_xref_id_mig.COUNT
                LOOP
                    SAVEPOINT CSD_REPAIR_JOB_XREF;

                    BEGIN

                        -- Update source_type_code to MANUAL

                        UPDATE csd_repair_job_xref
                        SET    source_type_code = 'MANUAL'
                        WHERE  rowid = rowid_mig(j);

                        IF SQL%NOTFOUND
                            THEN
                                RAISE error_process;
                        END IF;

                        EXCEPTION
                            WHEN error_process THEN
                                ROLLBACK TO CSD_REPAIR_JOB_XREF;
                                v_error_text := substr(sqlerrm, 1, 1000)
                                                || 'Repair Job Xref Id:'
                                                || repair_job_xref_id_mig(j);

                                INSERT INTO CSD_UPG_ERRORS
                                           (ORIG_SYSTEM_REFERENCE,
                                            TARGET_SYSTEM_REFERENCE,
                                            ORIG_SYSTEM_REFERENCE_ID,
                                            UPGRADE_DATETIME,
                                            ERROR_MESSAGE,
                                            MIGRATION_PHASE)
                                    VALUES ('CSD_REPAIR_JOB_XREF',
                                            'CSD_REPAIR_JOB_XREF',
                                            repair_job_xref_id_mig(j),
                                            sysdate,
                                            v_error_text,
                                            '11.5.10');

						        commit;

                           		raise_application_error( -20000, 'Error while migrating CSD_REPAIR_JOB_XREF table data: Error while updating csd_repair_job_xref. '|| v_error_text);

                    END;
                END LOOP;
            COMMIT;
            EXIT WHEN get_source_type_rows_cursor%NOTFOUND;
        END LOOP;

        IF get_job_name_id_rows_cursor%ISOPEN
            THEN
                CLOSE get_source_type_rows_cursor;
        END IF;
        COMMIT;
    END csd_repair_job_xref_mig3;


/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_REPAIR_TYPE_MIG3                                           */
/* description   : procedure for migrating repair_type_ref table data            */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/* Repair Types. - In the 11.5.10, we will changed the repair type ref for       */
/* the seeeded repair type - "Walk-In Repair" to  "Repair and Return",           */
/* and the repair type ref for the seed repair type -                            */
/* "Walk-In Repair with Loaner" to "Loaner, Repair and Return".                  */
/*-------------------------------------------------------------------------------*/

    PROCEDURE csd_repair_type_mig3
    IS

    BEGIN

        BEGIN

            Update csd_repair_types_b set repair_type_ref = 'RR' where repair_type_ref = 'WR';
/*
        EXCEPTION
            WHEN error_process THEN
                ROLLBACK TO CSD_MASS_RO_SN_ERRORS;
                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'Not able to update Repair type from RR to WR';

                INSERT INTO CSD_UPG_ERRORS
                           (ORIG_SYSTEM_REFERENCE,
                            TARGET_SYSTEM_REFERENCE,
                            ORIG_SYSTEM_REFERENCE_ID,
                            UPGRADE_DATETIME,
                            ERROR_MESSAGE,
                            MIGRATION_PHASE)
                    VALUES ('CSD_REPAIR_TYPE_ERROR',
                            'CSD_REPAIR_TYPE_UPDATE',
                            null,
                            sysdate,
                            v_error_text,
                            '11.5.10');
*/
        END;

        BEGIN
            Update csd_repair_types_b set repair_type_ref = 'ARR' where repair_type_ref = 'WRL';
/*
        EXCEPTION
            WHEN error_process THEN
                ROLLBACK TO CSD_MASS_RO_SN_ERRORS;
                v_error_text := substr(sqlerrm, 1, 1000)
                                || 'Not able to update Repair type from ARR to WRL';

                INSERT INTO CSD_UPG_ERRORS
                           (ORIG_SYSTEM_REFERENCE,
                            TARGET_SYSTEM_REFERENCE,
                            ORIG_SYSTEM_REFERENCE_ID,
                            UPGRADE_DATETIME,
                            ERROR_MESSAGE,
                            MIGRATION_PHASE)
                    VALUES ('CSD_REPAIR_TYPE_ERROR',
                            'CSD_REPAIR_TYPE_UPDATE',
                            null,
                            sysdate,
                            v_error_text,
                            '11.5.10');
*/
        END;

    COMMIT;

    end csd_repair_type_mig3;


/*-------------------------------------------------------------------------------*/
/* procedure name: CSD_COST_DATA_MIG3                                            */
/* description   : procedure for migrating csd_repair_estimate_lines             */
/*                 table cost data                                               */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/* If item_cost is not null and in differnt currency from the estimate line,     */
/* we convert it to charges currency and stamp it back on the table.             */
/*-------------------------------------------------------------------------------*/
Procedure      CSD_Cost_data_mig3(p_slab_number IN NUMBER)
   IS

-- ---------   ------  -------------------------------------------
Type NumTabType is VARRAY(10000) OF NUMBER;
repair_estimate_line_id_mig    NumTabType;
estimate_detail_id_mig	       NumTabType;
item_cost_mig                  NumTabType;
original_cost_mig              NumTabType;
resource_id_mig                NumTabType;


Type VarCharTabType is VARRAY(10000) OF Varchar2(3);
chg_currency_code_mig       VarcharTabType;
chg_uom_code_mig	    VarcharTabType;

Type DateTabType  is VARRAY(10000) of Date;
chg_creation_date_mig        DateTabType;

Type RowidTabType is VARRAY(10000) of VARCHAR2(30);
rowid_mig       RowidTabType;

v_min           NUMBER;
v_max           NUMBER;
v_error_text    Varchar2(2000);
MAX_BUFFER_SIZE Number := 500;
skip_process    Exception;

--4/26/04, Shiv Ragunathan, Introduced the following exception. When this exception is raised,
-- an error is raised and the process is stopped. This does not happen for skip_process.
error_process   Exception;

     l_cost_currency_code      VARCHAR2(30);

     l_item_cost               NUMBER;
     l_original_cost           NUMBER;
     l_organization_id         NUMBER;
     l_creation_Date           DATE;
     l_conversion_type         varchar2(30);
     l_max_roll_days            number;
     l_inventory_item_id        NUMBER;
     l_user_rate                NUMBER;
     l_rate                     number;
     x_conv_amount              number;
     l_denominator              number;
     l_numerator                number;
     l_orig_or_item_cost        number;
     l_est_line_uom_code        varchar2(3);
     l_billing_category_type   varchar2(10);
     l_res_cost                 number;
     l_res_uom_code             varchar2(3);
-- Added a new column ORIGINAL_COST to CSD_REPAIR_ESTIMATE_LINES table.
-- This column will be updated with the item_cost during migration. If conversion goes through
-- succesfully then item_cost is updated with the converted value and original_Cost is
--updated with the original item_cost. IF conversion does not go through then item_cost is
--updated with null and original_cost is updated with the old item_cost. Thus we pick only those
--records for which either item_cost or original_cost are null. If they are both null then we ignore
--those records.
-- Select rows from csd_repair_estimate_lines. Also get the currency code, uom for each line
Cursor cur_getEstimateLines(p_start number, p_end number)
IS
    SELECT rel.repair_estimate_line_id estimate_line_id, rel.item_cost item_cost,
           rel.original_cost original_cost, ced.currency_code, ced.creation_date ,
           ced.unit_of_measure_code, ced.estimate_detail_id, rel.resource_id, rel.rowid
    FROM csd_repair_estimate_lines rel, cs_estimate_details ced
    WHERE rel.estimate_detail_id = ced.estimate_detail_id
     and (
        ( rel.item_cost is not null and  rel.original_cost is null)
        OR ( rel.item_cost is  null and  rel.original_cost is not null)
        )
    and rel.repair_Estimate_line_id >= p_start
    and rel.repair_Estimate_line_id <= p_end;

-- Get GL currency code
 CURSOR cur_getGLCode ( p_org_id NUMBER)
  IS
  SELECT gl.currency_code
  FROM gl_sets_of_books gl, hr_operating_units hr
  WHERE hr.set_of_books_id = gl.set_of_books_id
  AND hr.organization_id = p_org_id;

--Cursor to get primary_uom_code for the estimate line item.
 CURSOR cur_getUOMForEstLineItem(p_estimate_detail_id NUMBER)
   IS
   SELECT primary_uom_code
   FROM mtl_system_items MSI, cs_estimate_details ced
   WHERE CED.estimate_detail_id = p_estimate_detail_id
   AND MSI.inventory_item_id = CED.inventory_item_id
   AND MSI.organization_id =  cs_std.get_item_valdn_orgzn_id;

   -- Cursor to get the estimate line category for a given estimate line id
  CURSOR cur_getBillCategoryType (p_estimate_detail_id number)
  IS
  SELECT BCAT.billing_category
  FROM csd_repair_estimate_lines ESTL,
        cs_estimate_details ESTD,
        cs_txn_billing_types TXNT,
        cs_billing_type_categories BCAT
  WHERE ESTL.repair_estimate_line_id = p_estimate_detail_id
  AND   ESTD.estimate_detail_id = ESTL.estimate_detail_id
  AND   TXNT.txn_billing_type_id = ESTD.txn_billing_type_id
  AND   BCAT.billing_type = TXNT.billing_type;

  --Cursor to get resource cost for a resource id. We only consider standard/frozen costing type.
   CURSOR cur_getResCost(p_bom_resource_id NUMBER,
   			 p_organization_id NUMBER)
   IS
   SELECT CRC.resource_rate
   FROM   cst_resource_costs CRC
   WHERE  CRC.resource_id = p_bom_resource_id
   AND CRC.organization_id   = p_organization_id
   AND CRC.cost_type_id      = 1; -- standard/frozen cost

       --Cursor to get resource UOM code for the given resource id
       CURSOR cur_getResUOMCode (p_bom_resource_id NUMBER)
       IS
       SELECT BR.unit_of_measure
       FROM BOM_RESOURCES BR
       WHERE BR.resource_id = p_bom_resource_id;
BEGIN

  --Get the slab number for the table
  Begin
    CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIR_ESTIMATE_LINES',
                                    'CSD',
				    p_slab_number,
                                    v_min,
                                    v_max);
     IF v_min is null then
      return;
     end if;
   end;

   begin

    -- Get the organization id from service validation org profile.
   fnd_profile.get('CS_INV_VALIDATION_ORG',l_organization_id);
         -- Derive conversion type and max roll days from the profile.
         --If these do not exist then default those.
         l_conversion_type := FND_PROFILE.value('CSD_CURRENCY_CONVERSION_TYPE');
         If (l_conversion_type is null) then
         l_conversion_type :='Corporate';
         end if;
        --Get the max roll days from the profile.
	l_max_roll_days := FND_PROFILE.value('CSD_CURRENCY_MAX_ROLL');
        If (l_max_roll_Days is null) then
         l_max_roll_days := 300;
        end if;
   -- Get item cost currency code
   OPEN cur_getGLCode( l_organization_id);
   FETCH cur_getGLCode into l_cost_currency_code;
   Close cur_getGLCode;
   Exception
   WHEN no_data_found then
   Close cur_getGLCode;
   when others then
   Close cur_getGLCode;
   End;

   OPEN cur_getEstimateLines(v_min, v_max);
   LOOP
      FETCH cur_getEstimateLines bulk collect into
            repair_estimate_line_id_mig,
             item_cost_mig,
	     original_cost_mig,
             chg_currency_code_mig ,
             chg_creation_date_mig,
	     chg_uom_code_mig,
	     estimate_detail_id_mig,
	     resource_id_mig,
             rowid_mig
             LIMIT MAX_BUFFER_SIZE;

           FOR j in 1..repair_estimate_line_id_mig.count
             LOOP
             SAVEPOINT CSD_REPAIR_ESTIMATE_LINES;

             Begin
		--populate l_orig_or_item_cost variable. If item_cost is null then
		--l_orig_or_item_cost = original_cost else = item_cost
		IF (item_cost_mig(j) IS NULL ) THEN
		  l_orig_or_item_cost := original_cost_mig(j);
		ELSE
		  l_orig_or_item_cost := item_cost_mig(j);
		END IF;

		--Check if the chg line uom is same as the item uom.

		--Get the primary uom code for the estimate line item.
                OPEN cur_getUOMForEstLineItem(repair_estimate_line_id_mig(j));
		FETCH cur_getUOMForEstLineItem into l_est_line_uom_code;
		CLOSE cur_getUOMForEstLineItem;

		if (l_est_line_uom_code <> chg_uom_code_mig(j) ) then
		-- If not then stamp item_cost with null and log the message in upg_errors.

 	              Update csd_repair_Estimate_lines
                      set original_cost = item_cost,
		      item_cost = null
                      where repair_estimate_line_id = repair_estimate_line_id_mig(j);
		      --skip the record
		      RAISE skip_process;
		      --log_error(repair_estimate_line_id_mig(j),item_cost_mig(j), l_cost_currency_code);
	        end if;

		-- Check if the charge line is a labor line
                OPEN cur_getBillCategoryType(repair_estimate_line_id_mig(j));
		FETCH cur_getBillCategoryType into l_billing_category_type;
		CLOSE cur_getBillCategoryType;

		-- if it is a labor line, find resource and resource cost.
		IF ( (l_billing_category_type ='L')
		 and (resource_id_mig(j) is not null )) THEN
		  -- get the resource cost
                  OPEN cur_getResCost(resource_id_mig(j),l_organization_id);
                  FETCH cur_getResCost into l_res_cost;
		  CLOSE cur_getResCost;

		  --get the resource UOM
		  OPEN cur_getResUOMCode(resource_id_mig(j));
                  FETCH cur_getResUOMCode into l_res_uom_code;
		  CLOSE cur_getResUOMCode;
		  --check if the reosurce uom = charge line uom
                  if (l_res_uom_code <> chg_uom_code_mig(j) ) then
		  -- If not then stamp item_cost with null and log the message in upg_errors.
                      Update csd_repair_Estimate_lines
                      set original_cost = item_cost,
		      item_cost = null
                      where repair_estimate_line_id = repair_estimate_line_id_mig(j);
		      -- skip the record
		      raise skip_process;
		     -- log_error(repair_estimate_line_id_mig(j),item_cost_mig(j), l_cost_currency_code);
		     else
		     -- resource and estimate line UOM matched. Stamp item_cost, original_cost with resource_cost
                     Update csd_repair_Estimate_lines
                      set original_cost = l_res_cost,
		      item_cost = l_res_cost
                      where repair_estimate_line_id = repair_estimate_line_id_mig(j);
		      --Update the variable l_orig_or_item_cost with l_res_cost so
		      --that if currency codes are different, we send the updated
		      --value to the GL API.
		      l_orig_or_item_cost := l_res_cost;
	         end if;

		END IF;

                  IF (chg_currency_code_mig(j) <> l_cost_currency_code) THEN

                     --Call GL API to convert the amount.
	             GL_CURRENCY_API.CONVERT_CLOSEST_AMOUNT
		                  (
		                     x_from_currency => l_cost_currency_code,
		                     x_to_currency => chg_currency_code_mig(j),
		                     x_conversion_date => chg_creation_date_mig(j),
		                     x_conversion_type => l_conversion_type,
		                     x_user_rate => l_user_rate,
		                     x_amount => l_orig_or_item_cost , --item_cost_mig(j),
		                     x_max_roll_days => l_max_roll_days,
		                     x_converted_amount => x_conv_amount,
	                             x_denominator => l_denominator,
		                     x_numerator => l_numerator,
		                     x_rate => l_rate
		                   );
                    -- If l_rate is -1 or -2 then conversion did not happen.
		    -- Update original_cost with the item_cost and item_cost
                    --with null and save this info in CSD_UPG_ERRORS table.
                    IF l_rate < 0 then
                      Update csd_repair_Estimate_lines
                      set original_cost = item_cost,
		              item_cost = null
                      where repair_estimate_line_id = repair_estimate_line_id_mig(j);
                     --Log the item_cost for the estimate that is being reset to null
		     raise error_process;
                     --log_error(repair_estimate_line_id_mig(j),item_cost_mig(j), l_cost_currency_code);

                  else
                   -- Update original_cost with the item_cost and item_cost with the converted value since conversion
                   --went thru fine.
                    Update csd_repair_Estimate_lines
                    set original_cost = item_cost,
		        item_cost = x_conv_amount
                    where repair_estimate_line_id =
                          repair_estimate_line_id_mig(j);

		    IF sql%notfound then
		     raise error_process;
		    end if;
		 end if;
	ELSE
           -- No need to convert because charge and cost currencies were the same. Just update
           -- original_cost with the item_cost so that the row does not get picked during reruns.
           Update csd_repair_Estimate_lines
           set original_cost = item_cost
           where repair_estimate_line_id =
                    repair_estimate_line_id_mig(j);

	   IF sql%notfound then
             raise error_process;
	   end if;
	END IF;

    Exception
                when Skip_process then
    -- 4/26/04, Shiv Ragunathan,
    -- Commented out the following line as this would undo the null updates done to the cost line
    -- ROLLBACK to CSD_REPAIR_ESTIMATE_LINES;

    -- 4/26/04, Shiv ragunathan, Commented out following line as log_error itself has an error_text
    -- v_error_text := substr(sqlerrm,1,1000)||'Estimate_Line_id:'||repair_estimate_line_id_mig(j) ;

                        log_error(repair_estimate_line_id_mig(j),item_cost_mig(j), l_cost_currency_code);

   /* INSERT INTO CSD_UPG_ERRORS
      (ORIG_SYSTEM_REFERENCE,
      TARGET_SYSTEM_REFERENCE,
      ORIG_SYSTEM_REFERENCE_ID,
      UPGRADE_DATETIME,
      ERROR_MESSAGE,
      MIGRATION_PHASE)
    VALUES('CSD_REPAIR_ESTIMATE_LINES',
           'CSD_REPAIR_ESTIMATE_LINES',
           repair_estimate_line_id_mig(j),
           sysdate,
           v_error_text,
           '11.5.10');*/

        -- 4/26/04, Shiv Ragunathan, Introduced following exception handling to handle case where process should
        -- stop immediately

                   WHEN error_process THEN
                                v_error_text := substr(sqlerrm,1,1000)||'Estimate_Line_id:'||repair_estimate_line_id_mig(j) ;

                                INSERT INTO CSD_UPG_ERRORS
                                (ORIG_SYSTEM_REFERENCE,
                                 TARGET_SYSTEM_REFERENCE,
                                 ORIG_SYSTEM_REFERENCE_ID,
                                 UPGRADE_DATETIME,
                                 ERROR_MESSAGE,
                                 MIGRATION_PHASE)
                                VALUES('CSD_REPAIR_ESTIMATE_LINES',
                                'CSD_REPAIR_ESTIMATE_LINES',
                                repair_estimate_line_id_mig(j),
                                sysdate,
                                v_error_text,
                                '11.5.10');

						        commit;

                           		raise_application_error( -20000, 'Error while migrating CSD_REPAIR_ESTIMATE_LINES cost data. '|| v_error_text);


           END;
           END LOOP;

    --
    -- End API Body
    --


   COMMIT;
   EXIT WHEN cur_getEstimateLines%notfound;
   END LOOP;
   IF cur_getEstimateLines%isopen then
   close cur_getEstimateLines;
   end if;
   END CSD_Cost_data_mig3;
/*-------------------------------------------------------------------------------*/
/* procedure name: LOG_ERROR                                                     */
/* description   : procedure for logging errors while migrating                  */
/*                 csd_repair_estimate_lines table cost data                     */
/*                 from 11.5.9 to 11.5.10                                        */
/*                                                                               */
/* This procedure will log the item_cost in CSD_UPG_ERRORS table                 */
/*-------------------------------------------------------------------------------*/
   procedure log_Error( p_estimate_line_id number,p_item_cost number, p_cost_currency_code varchar2)
   IS
    v_error_text varchar2(2000);
   BEGIN
    --Log the item_cost for the estimate that is being reset to null
                      v_error_text := substr(sqlerrm,1,1000)||'Estimate_Line_id:'||p_estimate_line_id
                                        || 'item_cost:'|| p_item_cost ||p_cost_currency_code ;

                     INSERT INTO CSD_UPG_ERRORS
                     (ORIG_SYSTEM_REFERENCE,
                      TARGET_SYSTEM_REFERENCE,
                      ORIG_SYSTEM_REFERENCE_ID,
                      UPGRADE_DATETIME,
                      ERROR_MESSAGE,
                      MIGRATION_PHASE)
                      VALUES('CSD_REPAIR_ESTIMATE_LINES',
                             'CSD_REPAIR_ESTIMATE_LINES',
                             p_estimate_line_id,
                             sysdate,
                            v_error_text,
                           '11.5.10');

                if( FND_LOG.LEVEL_PROCEDURE >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'CSD.PLSQL.CSD_COST_DATA_MIG3.ADD',
                          v_error_text);
                 end if;

    END;-- log_error;


    /*------------------------------------------------------------------------*/
    /* procedure name: CSD_REPAIR_HISTORY_MIG3                                */
    /* description   : procedure for migrating CSD_REPAIR_HISTORY table data  */
    /*                 from 11.5.9 to 11.5.10                                 */
    /* Created : vkjain on SEPT-30-2003                                       */
    /*                                                                        */
    /* Here are the details for the migration -                               */
    /* Event Code (New field(s) populated)      Comments
    /* RR         Receiving Org Name (paramc3)  Using receiving transactions
    /*                                          Id to determine values.
    /*
    /* RSC        Receiving Subinv Name(paramc1)Using receiving transactions
    /*                                          Id to determine values.
    /*
    /* JS         <None>                        Job Name, Item Name,
    /*                                          Quantity allocated, Group Id
    /*                                          and Concurrent Request Number
    /*                                          fields not populated  unable
    /*                                          to determine values.
    /*                                          The event code will be
    /*                                          renamed to JSU.
    /*
    /* TC         Task Name (paramc7)           Unable to determine values
    /*                                          for the other new fields.
    /*
    /* TOC        Task Name (paramc7)           Unable to determine values
    /*                                          for the other new fields.
    /*
    /* TSC        Task Name (paramc7)           Unable to determine values
    /*                                          for the other new fields.
    /*
    /* PS         Shipping Org Name (paramc3),  Using delivery detail Id
    /*            Shipping SubinvName (paramc4) to determine values.
    /*
    /* A          <None>                        Event Code renamed to ESU.
    /*                                          Estimate total field not
    /*                                          populated unable to
    /*                                          determine value.
    /*
    /* R          <None>                        Event Code renamed to ESU.
    /*                                          Estimate total field not
    /*                                          populated unable to
    /*                                          determine value.
    /*
    /* Points to note
    /*
    /* 1. New events do not need data migration effort.
    /* 2. JC is the only event that exists in 11.5.9 and has new fields for
    /*    11.5.10 but does not appear in the list above. This is because we are
    /*    unable to determine the value for the new field 'Quantity Allocated'.
    /* 3. As a pre-upgrade step, we expect the users to fully complete all the
    /*    pending wip jobs and run the update program.
    /*                                                                        */
    /*                                                                        */
    /*------------------------------------------------------------------------*/

    PROCEDURE csd_repair_history_mig3(p_slab_number IN NUMBER)
    IS

        -- Table type definitions

        -- Shiv Ragunathan, 12/10/03, Changed VARRAY to TABLE, as prior to
	   -- oracle 9.0.1, rowid is not recognized as a supported datatype
	   -- for VARRAY, due to which we get PLS-00531 error at compile
	   -- time.( This was due to a PLSQL bug, fixed in versions 9.0.1
	   -- and beyond ). Changed VartabType as well to be consistent.

        -- TYPE RowidTabType IS VARRAY(1000) OF ROWID;
        -- TYPE VarTabType IS VARRAY(1000) OF VARCHAR2(240);


        TYPE RowidTabType IS TABLE OF ROWID INDEX by Binary_Integer;
	   Type VarTabType IS TABLE OF VARCHAR2(240) INDEX by Binary_Integer;



        -- Following variables will be used for the
        -- the event code 'PS'.
        shipping_org_name_arr VarTabType;
        shipping_subinv_name_arr VarTabType;
        rowid_arr       RowidTabtype;

        -- Stores the minimum and maximum repair history id
        -- values for the slab.
        v_min           NUMBER;
        v_max           NUMBER;

        -- Stores the array size for each iteration.
        l_array_size    NUMBER;
        v_error_text    VARCHAR2(2000);

        -- The buffer size limits the fetch size to the
        -- constant value.
        MAX_BUFFER_SIZE CONSTANT NUMBER         := 500;

        -- The following exception will be thrown to stop
        -- further processing.
        STOP_PROCESS EXCEPTION;

        -- The following cursor gets the desired information from
        -- deliveries and HR for the event 'Shipment Completed'.
        CURSOR c_get_PS_event_details IS
        SELECT HIST.rowid,
               HROU.name,
               WSH.subinventory
        FROM   CSD_REPAIR_HISTORY HIST,
               WSH_DELIVERY_DETAILS WSH,
               HR_ALL_ORGANIZATION_UNITS_VL HROU
        WHERE HIST.EVENT_CODE = 'PS'
          AND HIST.REPAIR_HISTORY_ID >= v_min
          AND HIST.REPAIR_HISTORY_ID <= v_max
          AND HIST.PARAMN1 IS NOT NULL
          AND WSH.delivery_detail_id = HIST.paramn1
          AND HROU.organization_id = WSH.organization_id;

    BEGIN

       -- Establish a save point for the procedure.
       SAVEPOINT CSD_REPAIR_HISTORY_SP;

        -- Get the Slab Number for the table
        BEGIN
            CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIR_HISTORY',
                                              'CSD',
                                              p_slab_number,
                                              v_min,
                                              v_max);

            IF v_min IS NULL THEN
               RETURN;
            END IF;
        END;

        -- Error message text to label the processing event.
        v_error_text := ',while processing event code ''RR''';

        -- Processing event 'RR'. We simply use an update
        -- statement to update all lines.
        -- We update the field with organization_name.
        UPDATE CSD_REPAIR_HISTORY HIST
        SET HIST.PARAMC3 = ( SELECT hrou.name
                               FROM hr_all_organization_units_vl HROU,
                                    RCV_TRANSACTIONS RCV
                              WHERE RCV.transaction_id = HIST.paramn1
                                AND HROU.organization_id = RCV.organization_id
                            )
        WHERE HIST.EVENT_CODE = 'RR'
          AND HIST.REPAIR_HISTORY_ID >= v_min
          AND HIST.REPAIR_HISTORY_ID <= v_max
          AND HIST.PARAMN1 IS NOT NULL;

        -- Error message text to label the processing event.
        v_error_text := ',while processing event code ''RSC''';

        -- Processing event 'RSC'. We simply use an update
        -- statement to update all lines.
        -- We update the field with subinventory.
        UPDATE CSD_REPAIR_HISTORY HIST
        SET HIST.PARAMC1 = ( SELECT rcv.subinventory
                               FROM RCV_TRANSACTIONS RCV
                              WHERE RCV.transaction_id = HIST.paramn1
                            )
        WHERE HIST.EVENT_CODE = 'RSC'
          AND HIST.REPAIR_HISTORY_ID >= v_min
          AND HIST.REPAIR_HISTORY_ID <= v_max
          AND HIST.PARAMN1 IS NOT NULL;

        -- Error message text to label the processing event.
        v_error_text := ',while processing event code ''JSU''';
-- sangigup
-- Need to move group_id from paramc5 to paramn6
-- We use an update statement to update all lines
-- Pre 11.5 we used to append group_id with 'CSD'. Now, we remove 'CSD' prefix before
--updating the table. Or else the update will fail.
	UPDATE  CSD_REPAIR_HISTORY HIST
	SET HIST.paramn6 =
	nvl( to_number(decode(instr(hist.paramc5,'CSD',1),0,hist.paramc5, substr(hist.paramc5,4,length(hist.paramc5)) ) ),''),

	--nvl(to_number(hist.paramc5),''),
	hist.paramc5 = NULL
	WHERE HIST.EVENT_CODE = 'JS'
	AND HIST.REPAIR_HISTORY_ID >= v_min
          AND HIST.REPAIR_HISTORY_ID <= v_max;
--sangigup
        -- Processing event 'JS'. We simply use an update
        -- statement to update all lines.
        -- We update the event code to 'JSU'.
        UPDATE CSD_REPAIR_HISTORY HIST
        SET HIST.EVENT_CODE = 'JSU'
        WHERE HIST.EVENT_CODE = 'JS'
          AND HIST.REPAIR_HISTORY_ID >= v_min
          AND HIST.REPAIR_HISTORY_ID <= v_max;

        -- Error message text to label the processing event.
        v_error_text := ',while processing event code ''TC,TOC,TSC''';

        -- Processing event "TC, TOC and TSC". We simply use an update
        -- statement to update all lines.
        -- We update the field task name.
        UPDATE CSD_REPAIR_HISTORY HIST
        SET HIST.PARAMC7 = ( SELECT task_name
                               FROM JTF_TASKS_VL
                              WHERE task_id = HIST.paramn1
                            )
        WHERE HIST.EVENT_CODE IN ('TC', 'TOC', 'TSC')
          AND HIST.REPAIR_HISTORY_ID >= v_min
          AND HIST.REPAIR_HISTORY_ID <= v_max
          AND HIST.PARAMN1 IS NOT NULL;

        -- Error message text to label the processing event.
        v_error_text := ',while processing event code ''ESU''';

        -- Processing event "A and R". We simply use an update
        -- statement to update all lines.
        -- We update the event code to 'ESU'.
        UPDATE CSD_REPAIR_HISTORY HIST
        SET HIST.EVENT_CODE = 'ESU'
        WHERE HIST.EVENT_CODE IN ('A', 'R')
          AND HIST.REPAIR_HISTORY_ID >= v_min
          AND HIST.REPAIR_HISTORY_ID <= v_max;

        -- Error message text to label the processing event.
        v_error_text := ',while processing event code ''PS''';

        -- Processing event 'PS'. We use a cursor to fetch the
        -- desired values in BULK. We also use BULK update for
        -- updating all eligible lines.
        -- We update the fields - shipping org name and shipping subinvtory.
        OPEN c_get_PS_event_details;

        LOOP
            -- Get all rows where repair_history_id is between v_min and
            -- v_max for the event 'PS'.
            FETCH c_get_PS_event_details
            BULK COLLECT
            INTO rowid_arr,
                 shipping_org_name_arr,
                 shipping_subinv_name_arr
            LIMIT MAX_BUFFER_SIZE;

            l_array_size := rowid_arr.COUNT;  -- Number of VARRAY elements

            -- BULK update for all lines
            FORALL i IN 1..l_array_size
            UPDATE CSD_REPAIR_HISTORY
            SET paramc3 = shipping_org_name_arr(i),
                paramc4 = shipping_subinv_name_arr(i)
            WHERE rowid = rowid_arr(i);

            EXIT WHEN c_get_PS_event_details%NOTFOUND;
        END LOOP;

        IF c_get_PS_event_details%ISOPEN THEN
           CLOSE c_get_PS_event_details;
        END IF;

        COMMIT;

     EXCEPTION
        WHEN OTHERS THEN
           ROLLBACK TO CSD_REPAIR_HISTORY_SP;
           IF c_get_PS_event_details%ISOPEN THEN
              CLOSE c_get_PS_event_details;
           END IF;
           v_error_text := 'Encountered fatal error ' ||
                           SQLCODE || substr(sqlerrm, 1, 1000)||
                           v_error_text || -- ', while processing event code ''<EVENT_CODE>''
                           'for the repair history id between ' ||
                           v_min || ' and ' || v_max;

           INSERT INTO CSD_UPG_ERRORS
                       (ORIG_SYSTEM_REFERENCE,
                        TARGET_SYSTEM_REFERENCE,
                        ORIG_SYSTEM_REFERENCE_ID,
                        UPGRADE_DATETIME,
                        ERROR_MESSAGE,
                        MIGRATION_PHASE)
                VALUES ('CSD_REPAIR_HISTORY',
                        'CSD_REPAIR_HISTORY',
                        NULL,
                        sysdate,
                        v_error_text,
                        '11.5.10');
          COMMIT;
          -- We should throw exception to stall the process
          -- as we do not know what went wrong.
		-- 12/1/03, sragunat, Commenting out the following line,
		-- as do not want the migration to fail due to an error here
	     -- Later, if needed, can uncomment it after further
		-- investigation

          -- RAISE STOP_PROCESS;


          raise_application_error( -20000,  'Error while migrating CSD_REPAIR_HISTORY table data. ' || v_error_text);


    END csd_repair_history_mig3;


    /*------------------------------------------------------------------------*/
    /* procedure name: CSD_PRODUCT_TRANS_MIG3(p_slab_Number Number)
    /* description   : procedure for migrating CSD_PRODUCT_TRANSACTIONS data  */
    /*                 from 11.5.9 to 11.5.10                                 */
    /* Created : saupadhy SEPT-30-2003                                       */
    /*                                                                        */
    /* Here are the details for the migration -                               */
    /* Prod Txn Status  (New field(s) populated)      Comments
    /* RECEIVED         Quantity_Received,                                   */
    /*                  source_serial_number                                 */
    /*                  source_instance_id                                   */
    /*                  sub_inventory                                        */
    /*                  lot_Number                                           */
    /*                  locator_id                                           */
    /* SHIPPED          Quantity_Shipped                                     */
    /*                  source_serial_number                                 */
    /*                  source_instance_id                                   */
    /*                  non_source_serial_number                             */
    /*                  non_source_instance_id                               */
    /*                  sub_inventory                                        */
    /*                  lot_Number                                           */
    /*                  locator_id                                           */
    /* BOOKED     action_type is 'RMA' and order line qty is > 1             */
    /*            Only qty that is captured in csd_repair_history is         */
    /*            updated in csd_product_txns table                          */
    /*RELEASED   action_type is 'SHIP' and order line qty is > 1             */
    /*           Only qty that is captured in csd_repair_history is          */
    /*           updated in csd_product_txns table.                          */
    /************************************************************************/
    procedure CSD_PRODUCT_TRANS_MIG3(p_slab_Number Number) IS

   TYPE NumTabType IS TABLE OF NUMBER
        INDEX by Binary_Integer;
      v_repair_line_id             NumTabType;
      v_product_trans_id           NumTabType ;
      v_Estimate_Detail_Id         NumTabType ;
      v_Order_Header_Id            NumTabType ;
      v_Order_Line_Id              NumTabType ;
      v_Order_Line_Qty             NumTabType ;
      v_Transacted_Qty             NumTabType ;
      v_Inventory_Item_Id          NumTabType ;
      v_Ship_To_Org_Id             NumTabType ;
      v_Ship_From_Org_Id           NumTabType ;
      v_serial_Number_control_code NumTabType ;
      v_lot_control_code           NumTabType ;
      v_Locator_Id                 NumTabType ;
      v_Source_Instance_Id         NumTabType ;
      v_Non_Source_Instance_Id     NumTabType ;
      v_Quantity_Received          NumTabType ;
      v_Quantity_Shipped           NumTabType ;
      v_Quantity_Required          NumTabType ;
      v_customer_product_id        NumTabType ;
      v_Location_Control_Code      NumTabType ;


   TYPE RowidTabType IS TABLE OF ROWID
        INDEX by Binary_Integer;
      v_rowid        RowidTabtype;

   TYPE VCharTabType IS TABLE OF VARCHAR2(30)
        INDEX by Binary_Integer;
      v_ActionType                VCharTabType  ;
      v_ActionCode                VCharTabType ;
      v_comms_Nls_trackable_flag  VCharTabType ;
      v_Source_Serial_Number      VCharTabType ;
      v_Non_SOurce_Serial_Number  VCharTabType ;
	 --Bug: 3622825 Commenting following columns
      -- v_Sub_Inventory             VCharTabType ;
      -- v_Lot_Number                VCharTabType ;
      v_Prod_Txn_Status           VCharTabType ;
      v_repair_type_ref           VCharTabType ;
	 v_serial_number             VCharTabType ;
	 v_Shipped_Serial_Number     VCharTabType ;


   -- Flag to track multiple Sub Inventory, Lot Number, Locator_id
   -- These variable are no more used so commenting them. 3742767
   -- l_One_SubInventory       Varchar2(1)  ;
   -- l_One_LocationId         Varchar2(1) ;
   -- l_One_LotNumber          Varchar2(1) ;
   -- l_SubInventory           Varchar2(30);
   l_locator_id             Number ;
   -- l_Lot_Number             Varchar2(30) ; 3742767
   l_Quantity               Number ;


   -- Declare local variables
   l_Table_Name    Varchar2(30) := 'CSD_PRODUCT_TRANSACTIONS' ;
   l_Module        Varchar2(30) := 'CSD' ;
   l_start_slab    Number       ;
   l_End_Slab      Number       ;
   l_error_text    VARCHAR2(2000);
   l_Array_Size    Number  ;
   l_Procedure_Event Varchar2(100);

   MAX_BUFFER_SIZE CONSTANT  NUMBER         := 500;

   error_process_excep EXCEPTION;
   -- 1.Make sure that main cursor  does not pick up once processed records.
   -- This can be made sure by checking that newly introduced columns has null values
   -- while selecting records for processing
   -- 2. Should pick up all the records i.e that are recieived, shipped, released or in
   --  any status
   -- and cpt.quantity_received is NULL
   -- and cpt.quantity_shipped is NULL
   -- and cpt.source_instance_id is Null
   -- and cpt.non_source_instance_id is NUll
   -- and cpt.source_serial_number is Null
   -- and cpt.non_source_serial_number is null
   -- and cpt.locator_id is null

   -- Added NULL columns to initialize the collection
   Cursor Prod_txns_cur( p_Start_Slab Number, p_End_Slab Number) IS
      Select cpt.rowid,
         cpt.product_transaction_Id ,
         cpt.Action_TYpe,
         cpt.Action_Code,
         cpt.estimate_detail_id,
         cpt.repair_line_id,
         cpt.Prod_txn_Status,
         oola.header_id ,
         oola.line_id ,
         (oola.ordered_quantity - Nvl(oola.cancelled_quantity,0) ) Line_quantity,
         oola.shipped_quantity Transacted_Qty,
         oola.inventory_item_id ,
         oola.ship_to_org_id ,
	    oola.ship_from_org_id,
         msi.serial_Number_control_code,
         msi.comms_Nl_trackable_flag ,
         msi.lot_control_code ,
         msi.location_control_code ,
         ced.quantity_required ,
         ced.customer_product_id ,
	    ced.serial_number,
	    cpt.shipped_serial_number,
         crt.repair_type_ref,
	    NULL, -- locator_id
	    NULL, -- source_instance_id
	    NULL, -- non_source_instance_id
	    NULL, -- quantity_received
	    NULL, -- Quantity_shipped
	    NULL, -- source_serial_number
	    NULL  -- non_source_serial_number
      From csd_product_transactions cpt ,
          csd_repairs  cr ,
          csd_repair_types_b crt,
          cs_estimate_details ced ,
          oe_order_headers_all ooha,
          oe_order_lines_all oola ,
          mtl_system_items_b msi
       Where cpt.product_transaction_id >= p_Start_Slab
       and cpt.product_transaction_id <= p_End_Slab
       and cpt.repair_line_id = cr.repair_line_id
       and cr.repair_type_id  = crt.repair_type_id
       and cpt.estimate_detail_id = ced.estimate_detail_id
       and cpt.quantity_received is NULL
       and cpt.quantity_shipped is NULL
	  and cpt.source_instance_id is Null
	  and cpt.non_source_instance_id is NUll
	  and cpt.source_serial_number is Null
	  and cpt.non_source_serial_number is null
	  and cpt.locator_id is null
       and ced.order_header_id = ooha.header_id
       and ooha.header_id  = oola.header_id
	  and ced.order_line_id = oola.line_id
       and oola.inventory_item_id = msi.inventory_item_id
       and oola.ship_from_org_id = msi.organization_id ;

       -- Define a cursor which gets all receiving transaction records for parent order line id
       Cursor Rcv_transactions_cur (p_order_header_Id Number, p_Order_Line_Id Number) IS
       Select rcvt.transaction_id, rcvt.quantity, rcvt.locator_id
       From Rcv_Transactions Rcvt
       Where rcvt.Transaction_Type = 'DELIVER'
       and rcvt.oe_order_header_id = p_order_header_Id
       and rcvt.oe_order_line_id   in ( Select line_id from oe_order_lines_all
          start with line_id = p_Order_Line_Id
          connect by prior line_id = split_from_line_id ) ;

      -- Define a cursor which gets receiving transactions records for given order line id
      -- Following cursor definition is used when order line quantity is 1
       Cursor Single_Rcv_transactions_cur (p_order_header_Id Number, p_Order_Line_Id Number) IS
       Select rcvt.transaction_id,  rcvt.quantity, rcvt.locator_id
       From Rcv_Transactions Rcvt
       Where rcvt.Transaction_Type = 'DELIVER'
       and rcvt.oe_order_header_id = p_order_header_Id
       and rcvt.oe_order_line_id   =  p_Order_Line_Id ;

       -- Define a cursor which gets all delivery details records for parent order line id
	  -- Included wsh_serial_numbers table in from clause as serial_number may not be captured
	  -- in wsh_delivery_details.
       Cursor Delivery_details_cur (p_order_header_Id Number, p_Order_Line_Id Number) IS
       Select wdt.delivery_detail_id, wdt.shipped_quantity,wdt.locator_id ,
              Nvl(wdt.serial_number, wsn.fm_serial_number) serial_number
       From wsh_delivery_details wdt,
	       Wsh_Serial_Numbers wsn
       Where wdt.Released_Status in ( 'C', 'I')
       and wdt.source_header_id = p_order_header_Id
       and wdt.source_line_id   in ( Select line_id from oe_order_lines_all
          start with line_id = p_Order_Line_Id
          connect by prior line_id = split_from_line_id )
       and wdt.delivery_detail_id = wsn.delivery_detail_id(+);

      -- Define a cursor which gets delivery details records  for given order line id
      -- Following cursor definition is used when order line quantity is 1
       Cursor Single_Delivery_details_cur (p_order_header_Id Number, p_Order_Line_Id Number) IS
       Select wdt.delivery_detail_id, wdt.shipped_quantity, wdt.locator_id ,
              Nvl(wdt.serial_number, wsn.fm_serial_number) serial_number
       From wsh_delivery_details wdt,
	       wsh_serial_numbers wsn
       Where wdt.Released_Status in ( 'C', 'I')
       and wdt.source_header_id = p_order_header_Id
       and wdt.source_line_id   = p_Order_Line_Id
	  and wdt.delivery_detail_id = wsn.delivery_detail_id(+);

    BEGIN
        -- Dbms_Output.Put_line('Procedure :csd_product_trans_mig:  Begin ');
        -- Dbms_Output.Put_line('Table Name is :' || l_Table_Name ) ;
        -- Dbms_Output.Put_line('Module Name is :' || l_Module ) ;
        -- Do we need to Verify if P_Slab_Number is NUll
         -- Get the Slab Number for the table
	   l_procedure_Event := 'At the begining of the procedure';
        BEGIN

           CSD_MIG_SLABS_PKG.Get_Table_Slabs(p_table_name    =>   l_Table_Name ,
              p_module        =>   l_Module ,
              p_slab_number   =>   p_Slab_Number,
              x_start_slab    =>   l_Start_Slab ,
              x_end_slab      =>   l_End_Slab );
           -- Migration script for CSD_Product_Transactions
           -- Dbms_Output.Put_line('Start Slab :' || l_Start_Slab );
           -- Dbms_Output.Put_line('End Slab :' || l_End_Slab );
           -- Return if l_Start_Slab variable has null value
           IF l_Start_Slab IS NULL  OR l_End_Slab IS NULL THEN
              RETURN;
           END IF;
        END;
	   l_procedure_Event := 'After calling csd_mig_slabs_pkg.get_table_slabs procedure' ;

        -- Migration script for CSD_Product_Transactions

        OPEN Prod_txns_cur(l_Start_Slab, l_End_Slab);
        LOOP
        Begin
           -- Every fetch it will atmost fetch MAX_BUFFER_SIZE number of records.
           -- Loops until all the records fetched by cursor are processed.

           FETCH Prod_txns_cur BULK COLLECT
              INTO v_rowid ,
              v_product_trans_Id ,
              v_ActionType,
              v_ActionCode,
              v_estimate_detail_id,
              v_repair_line_id,
              v_Prod_Txn_Status,
              v_order_header_id ,
              v_order_line_id ,
              v_order_Line_qty,
              v_Transacted_Qty,
              v_inventory_item_id ,
              v_ship_to_org_id ,
		    v_ship_from_org_id,
              v_serial_Number_control_code,
              v_comms_Nls_trackable_flag ,
              v_lot_control_code ,
              v_Location_Control_Code,
              v_Quantity_Required,
              v_customer_product_id,
	         v_serial_number,
	         v_shipped_serial_number,
              v_repair_type_ref,
	         v_locator_id,
	         v_source_instance_id,
	         v_non_source_instance_id,
	         v_quantity_received,
	         v_Quantity_shipped,
	         v_source_serial_number,
	         v_non_source_serial_number
            LIMIT MAX_BUFFER_SIZE;

            -- Loop through each of the arrays to get values for other variables
	       l_procedure_Event := 'After fetching rows from main cursor';

            l_Array_size := v_Product_trans_id.Count ;
		  If l_Array_Size = 0 Then
		    Exit;
		  End If;
            FOR j IN 1..l_Array_Size
            LOOP
            Begin
               SavePoint Update_prod_Txns ;
	          l_procedure_Event := 'Begining of processing fetched rows' ;
               -- Assign Null Value to all varialbes that are used for migrating data to 11.5.10 release
               -- This is to make sure that if a record is skipped for what ever reasons, its corresponding
               -- variables are assigned null value.
			/************
			No need to initialize to Null they are initialize to null in the begining
               v_Locator_Id(j)               := Null;
               v_Source_Serial_Number(j)     := Null;
               v_Source_Instance_Id(j)       := Null;
               v_Non_Source_Serial_Number(j) := Null;
               v_Non_Source_Instance_Id(j)   := Null;
               v_Quantity_Shipped(j)         := Null;
               v_Quantity_Received(j)        := Null;
			************/

               If v_ActionType(j) in ('RMA','WALK_IN_RECEIPT') Then
	             l_procedure_Event := 'Processing RMA record';
			   -- Note for RMA line following columns will always have Null value
			   -- v_Non_SOurce_Serial_Number(j)
                  -- v_Non_Source_Instance_Id(j)
                  -- v_Quantity_Shipped(j)
                  -- Check if item is serial Number controlled or not
                  If v_Serial_Number_Control_Code(j) = 1 Then
	                l_procedure_Event := 'Processing RMA non serial record';
                     -- Get all receiving transaction records for given order_header_id and order_line_id
                     If (v_Quantity_Required(j) = 1) and (V_Prod_txn_status(j) = 'RECEIVED' )Then
	                   l_procedure_Event := 'Processing RMA non serial qty 1 and received';
                        For Rcv_txn_rec In Single_Rcv_transactions_cur (v_order_header_id(j), v_order_line_id(j)) Loop
                            v_Quantity_Received(j) := Rcv_txn_rec.quantity ;
                            v_Locator_Id(j)        := Rcv_txn_rec.locator_id ;
                        End Loop ;
                     Else
	                   l_procedure_Event := 'Processing RMA non serial qty > 1 or not received';
                        -- Initialize following variables
                        l_locator_id    := NUll ;
                        l_Quantity      := NUll ;
                        -- Check Product Transaction Status , if it is 'RECEIVED' then
                        -- Quantity Received is total quantity received against that RMA
                        -- Else Quantity Received is what is recorded in csd_repair_history table
                        If v_Prod_txn_Status(j) = 'RECEIVED' Then
	                      l_procedure_Event := 'Processing RMA non serial qty > 1 and received';
                           For Rcv_txn_rec In Rcv_transactions_cur (v_order_header_id(j), v_order_line_id(j)) Loop
                              -- Cumulate quantity value for all lines split from parent line id
                              v_Quantity_Received(j) := Nvl(v_Quantity_Received(j),0) + Rcv_txn_rec.Quantity ;
                              v_Locator_id(j) := Rcv_Txn_Rec.Locator_Id;
                           End Loop ;
                        Else
	                      l_procedure_Event := 'Processing RMA non serial qty > 1 or not received';
                           For Rcv_txn_rec In Rcv_transactions_cur (v_order_header_id(j), v_order_line_id(j)) Loop
                              -- Check if current receving transaction id record information is updated
                              -- in csd_repair_history table
                              Begin
                                 Select Quantity
                                 Into l_Quantity
                                 From csd_repair_history
                                 Where event_code = 'RR'
                                 and paramn1      = rcv_txn_rec.transaction_id
						   and repair_line_id = V_Repair_Line_Id(j);
                              Exception
                                 When No_Data_Found Then
                                    l_Quantity := 0 ;
                              End;
                              V_locator_id(j) := Rcv_txn_rec.locator_id ;
                              v_Quantity_Received(j) := Nvl(v_Quantity_Received(j),0) + l_Quantity ;
                            End Loop ;
                        End If; -- v_Prod_txn_Status(j) = 'RECEIVED'
                     End If; -- v_Quantity_Required(j) = 1 Then

                     -- Check if Item is IB Trackable, if so then source_instance_id column is populated with
                     -- customer_product_id information
                     If v_comms_Nls_trackable_flag(j) = 'Y' Then
                        v_Source_Instance_Id(j) := v_Customer_Product_Id(j);
                     Else
                        v_Source_Instance_Id(j) := Null;
                     End If;
                  Elsif (v_Serial_Number_Control_Code(j) <> 1) and (V_Prod_txn_status(j) = 'RECEIVED') Then
                     Begin
				    -- To fix bug 3842957/4140451 saupadhy
				    -- In pre 11i RMA returns were handled by inventory module not receiving module.
				    -- In 11i this functionality is handled by PO module.During migration from pre 11i
				    -- to 11i, PO creates lines in rcv_Transactions and rcv_serial_transactions for those
				    -- records that exist in SO_RMA interface table. There is a possibility that customer
				    -- might have deleted records from SO_RMA interface table after those records are
				    -- successfully received in inventory. In such cases there will be no record created
				    -- in rcv_transactions table.So Depot has changed the logic for finding
				    -- serial number for recevied items, it looks for serial number information in
				    -- rcv_transactions table but if the record does not exist it looks for the info in
				    -- csd_repairs table, if the record is not found there too then Depot will assign
				    -- blank values to source serial number column.
				    -- This strategy will help upgrade process not to stop because of missing records in
				    -- rcv_transactions table.
                        -- Item is serial controlled
	                   l_procedure_Event := 'Delivery info for serial and received item';
				    Begin
                           Select rcvt.quantity, rcvt.locator_id , rst.serial_num
                           Into v_Quantity_Received(j), v_Locator_Id(j),v_Source_Serial_Number(j)
                           From Rcv_Transactions Rcvt ,
                             Rcv_Serial_Transactions rst
                           Where rcvt.Transaction_Type = 'DELIVER'
                           and rcvt.oe_order_header_id = v_order_header_id(j)
                           and rcvt.oe_order_line_id   = v_order_line_id(j)
                           and rcvt.transaction_id = rst.transaction_id
				       and rownum = 1;
				    Exception
				       When No_Data_Found Then
				            -- To fix bug 3842957/4140451 saupadhy
					       -- look for serial number information in csd_repairs table,
						  -- As this case will arise only for pre 11i transactions and in pre 11i
						  -- Depot creates RO only after an item is received, if the item is serial
						  -- controlled, Depot captures serial number information in csd_repairs table.
						  V_Quantity_Received(j) := 1;
						  v_Locator_ID(j)        := Null;
						  Begin
						     Select Serial_Number Into V_Source_Serial_Number(j)
							From CSD_Repairs
							Where Repair_line_Id = V_Repair_Line_ID(j);
						  Exception
						     When No_Data_Found THen
							    -- Assign Null value to Serial Number array and move on.
							    v_Source_Serial_Number(j) := Null;
						  End;
		              End;

                        -- If Item is IB Trackable Then get IB Ref Number from csi_item_instances
				    -- To fix bug 3842957/4140451 saupadhy
				    -- Added check for not null value for source_Serial_Number
                        If v_comms_Nls_trackable_flag(j) = 'Y'
				      and v_Source_Serial_Number(j) is Not Null Then
				       Begin
	                         l_procedure_Event := 'IB info for serial and received item';
                              select instance_id
                              Into v_Source_Instance_Id(j)
                              from csi_item_instances
                              where inventory_item_id = v_inventory_item_id(j)
                              and serial_number =  v_Source_Serial_Number(j) ;
					     -- Following statement is incorrect and not required so commenting it.
					     -- and inv_master_organization_id = cs_std.get_item_valdn_orgzn_id;
					     ---??????? 3742767
					  Exception
					     When No_Data_Found Then
						   V_Source_Instance_Id(j) := V_Customer_Product_id(j);
					  End;
                        Else
                           v_Source_Instance_Id(j) := Null;
                        End If;

                     Exception
                        When Others Then
                           Raise error_process_Excep ;
                     End ;
                  Elsif (v_Serial_Number_Control_Code(j) <> 1) and (V_Prod_txn_status(j) <> 'RECEIVED') Then
                     v_Source_Instance_Id(j)   := v_Customer_Product_Id(j);
				 -- v_Quantity_Received(j)    := Null;
				 -- v_Locator_Id(j)           := Null;
				 v_Source_Serial_Number(j) := v_Serial_Number(j);
                  End If;
               Elsif V_ActionType(j)in ('SHIP','WALK_IN_ISSUE') Then
                  -- Check if item is serial Number controlled or not
                  If v_Serial_Number_Control_Code(j) = 1 Then

                     -- Get all receiving transaction records for given order_header_id and order_line_id
                     If (v_Quantity_Required(j) = 1) and (V_Prod_txn_status(j) = 'SHIPPED' ) Then

                        For Delv_Detl_rec In Single_Delivery_Details_cur (v_order_header_id(j), v_order_line_id(j)) Loop
                            v_Quantity_shipped(j)  := Delv_Detl_rec.Shipped_quantity ;
                            v_Locator_Id(j)        := Delv_Detl_rec.locator_id ;
                        End Loop ;
                     Else
                        -- Initialize following variables
                        l_Locator_Id    := NUll ;
                        l_Quantity      := NUll ;
                        -- Check Product Transaction Status , if it is 'SHIPPED' then
                        -- Quantity shipped is total quantity shipped against that SO
                        -- Else Quantity shipped is what is recorded in csd_repair_history table
                        If v_Prod_txn_Status(j) = 'SHIPPED' Then
                           For Delv_Detl_rec In Delivery_Details_cur (v_order_header_id(j), v_order_line_id(j)) Loop
                              -- Cumulate quantity value for all lines split from parent line id
                              v_Quantity_Shipped(j) := Nvl(v_Quantity_Shipped(j),0) + Delv_Detl_rec.Shipped_Quantity ;
                              v_locator_id(j) := Delv_Detl_rec.locator_id ;
                           End Loop ;
                           -- Since Item is Non-Serialized, Source instance Id will be always NULL
                           --
                        Else
                           For Delv_Detl_rec In Delivery_Details_cur (v_order_header_id(j), v_order_line_id(j)) Loop
                              -- Check if current delivery_detail_id record information is updated
                              -- in csd_repair_history table
                              Begin
	                            l_procedure_Event := 'Getting Quantity from repair history table';
                                 Select Quantity
                                 Into l_Quantity
                                 From csd_repair_history
                                 Where event_code = 'PS'
                                 and paramn1      = Delv_Detl_rec.Delivery_Detail_id
						   and repair_line_id = v_Repair_Line_Id(j);
                              Exception
                                 When No_Data_Found Then
                                    l_Quantity := 0 ;
                              End;
                              If l_Quantity > 0 Then
                                 -- Add l_Quantity to existing quantity value in v_quantity_shipped variable
                                 v_Quantity_Shipped(j) := Nvl(v_Quantity_Shipped(j),0) + l_Quantity ;
                                 v_locator_id(j) := Delv_Detl_rec.locator_id ;
                               End If; -- If l_Quantity > 0 Then
                            End Loop ;
                        End If; -- v_Prod_txn_Status(j) = 'SHIPPED'
                     End If; -- v_Quantity_Required(j) = 1 Then

                     -- Check if Item is IB Trackable, if so then source_instance_id column is populated with
                     -- customer_product_id information
                     If v_comms_Nls_trackable_flag(j) = 'Y' Then
                        -- Check if Repair Type Ref is in Advace Exchange, Exchange, Replacement
                        if v_repair_type_ref(j) in ('AE','E','R') Then
                           v_Non_Source_instance_id(j)  :=  v_Customer_Product_Id(j) ;
					  /******************************* 3742767
					  Following code is not required as item is non serialized
                           Begin
                              select Serial_Number
                              Into v_Non_Source_Serial_Number(j)
                              from csi_item_instances
                              where inventory_item_id = v_inventory_item_id(j)
                              and instance_id =  v_Customer_Product_Id(j)
						and inv_master_organization_Id = cs_std.get_item_valdn_orgzn_id;

                              v_Non_Source_instance_id(j)  :=  v_Customer_Product_Id(j) ;
                           Exception
                              When No_Data_Found Then
                                 -- v_Non_Source_Serial_Number(j):= Null;
                                 v_Non_Source_instance_id(j)  :=  v_Customer_Product_Id(j) ;
				             -- v_Source_Instance_id(j) := Null ;
					        -- v_Source_Serial_Number(j) := Null;
                           End;
					  *************** 3742767****************/
					  --  3742767 Else statment is commented as there will be no value for
					  -- source_instance_id column in case ship line , since item is
					  -- non-serial controlled
				       -- Else
				       -- v_Non_Source_Instance_id(j) := Null ;
					  -- v_Non_Source_Serial_Number(j) := Null;
					  -- v_Source_Serial_Number(j) := Null
					  -- v_Source_Instance_Id(j) := v_Customer_Product_Id(j);
                        End If ;
                     End If;
                  Elsif (v_Serial_Number_Control_Code(j) <> 1) and (V_Prod_txn_status(j) = 'SHIPPED') Then
                     Begin
                        -- Item is serial controlled

	                   l_procedure_Event := ' Getting Shipping details for serial controlled item' ;
                        Select wdt.shipped_quantity, wdt.locator_id ,
				       Nvl(wdt.serial_number, wsn.fm_serial_number) Serial_number
                        Into v_Quantity_Shipped(j), v_Locator_Id(j) , v_Source_Serial_Number(j)
                        From wsh_delivery_details wdt,
				         wsh_serial_numbers wsn
                        Where wdt.Released_Status in ( 'C', 'I')
                        and wdt.source_header_id = v_order_header_id(j)
                        and wdt.source_line_id   = v_order_line_id(j)
				    and wdt.delivery_detail_id = wsn.delivery_detail_id(+)
				    and rownum = 1;

                        -- If Item is IB Trackable Then get Corresponding IB Ref Number from csi_item_instances
                        If v_comms_Nls_trackable_flag(j) = 'Y' Then
                           Begin
	                         l_procedure_Event := 'Getting IB info for a serial item-Ship line';
                              select instance_id
                              Into v_Source_Instance_Id(j)
                              from csi_item_instances
                              where inventory_item_id = v_inventory_item_id(j)
                              and serial_number =  v_Source_Serial_Number(j) ;
                           Exception
                              When No_Data_Found Then
                                 v_Source_Instance_Id(j) := Null;
                           End;

                           -- Get Non_source Column Names
                           if v_repair_type_ref(j) in ('AE','E','R') Then
                              Begin
                                 select Serial_Number
                                 Into v_Non_Source_Serial_Number(j)
                                 from csi_item_instances
                                 where inventory_item_id = v_inventory_item_id(j)
                                 and instance_id =  v_Customer_Product_Id(j);
						   -- and inv_master_organization_Id = cs_std.get_item_valdn_orgzn_id;
						   -- Commented above line 3742767
                                 v_Non_Source_instance_id(j)  :=  v_Customer_Product_Id(j) ;
                              Exception
                                 When No_Data_Found Then
                                    v_Non_Source_Serial_Number(j):= Null;
                                    v_Non_Source_instance_id(j)  :=  v_Customer_Product_Id(j) ;
                              End;
                           End If ;
                        End If;

                     Exception
                        When Others Then
                           Raise error_process_Excep ;
                     End ;
                  End If; --v_Serial_Number_Control_Code(j) = 1

               End if; --V_Action_Type in ('SHIP','WALK_IN_ISSUE')
           Exception
              WHEN error_process_Excep THEN
                 l_error_text := substr(sqlerrm, 1, 1000) || 'Product Transaction Id:'||
			      v_product_trans_id(j);
                 ROLLBACK TO Update_prod_Txns;

                 INSERT INTO CSD_UPG_ERRORS
                    (ORIG_SYSTEM_REFERENCE,
                    TARGET_SYSTEM_REFERENCE,
                    ORIG_SYSTEM_REFERENCE_ID,
                    UPGRADE_DATETIME,
                    ERROR_MESSAGE,
                    MIGRATION_PHASE)
                 VALUES ('CSD_PRODUCT_TRANSACTIONS',
                    'CSD_PRODUCT_TRANSACTIONS',
                    v_Product_Trans_id(j),
                    sysdate,
                    l_error_text,
                    '11.5.10');

		          commit;

                  raise_application_error( -20000, 'Error while migrating CSD_PRODUCT_TRANSACTIONS. '|| l_error_text);

           End;
           End Loop; -- j IN 1..l_Array_Size.COUNT
           -- Now use bulck collect to update csd_product_transactions_table
           ForAll i in 1..v_product_trans_Id.COUNT
              Update Csd_Product_Transactions
                 Set source_serial_number = v_Source_Serial_Number(i) ,
                     source_instance_id   = v_source_instance_id(i) ,
                     non_source_serial_number = v_non_source_serial_number(i) ,
                     non_source_instance_id   = v_non_source_instance_id(i) ,
                     locator_id               = v_locator_id(i) ,
                     -- sub_inventory            = v_sub_inventory(i), bug#3622825
                     -- Lot_Number               = v_Lot_Number(i), bug#3622825
                     Quantity_Received        = v_Quantity_Received(i) ,
                     Quantity_Shipped         = v_Quantity_Shipped(i),
                     last_update_date         = sysdate,
                     last_updated_by          = fnd_global.user_id,
                     last_update_login        = fnd_global.login_id
              Where rowid = v_rowid(i)
		    And ( v_Source_serial_number(i) is not null
		    Or v_Source_Instance_id(i) is Not Null
		    Or V_Non_Source_Serial_Number(i) is Not Null
		    or V_Non_Source_Instance_id(i) is Not Null
		    or V_Quantity_Shipped(i) is Not Null
		    or V_Quantity_Received(i) is Not Null
		    or V_Locator_Id(i) is Not Null );

           EXCEPTION
              When Others Then
                 ROLLBACK TO Update_prod_Txns;
                 l_error_text := 'Event :' || l_procedure_event ||' -Error Code :' || sqlcode || 'Error Message:' || substr(sqlerrm, 1, 1000) ;

                 INSERT INTO CSD_UPG_ERRORS
                     (ORIG_SYSTEM_REFERENCE,
                      TARGET_SYSTEM_REFERENCE,
                      ORIG_SYSTEM_REFERENCE_ID,
                      UPGRADE_DATETIME,
                      ERROR_MESSAGE,
                      MIGRATION_PHASE)
                  VALUES ('CSD_PRODUCT_TRANSACTIONS',
                     'CSD_PRODUCT_TRANSACTIONS',
                     NULL,
                     sysdate,
                     l_error_text,
                    '11.5.10');

			      commit;

                  raise_application_error( -20000, 'Error while migrating CSD_PRODUCT_TRANSACTIONS. '|| l_error_text);


           END;

		 EXIT WHEN Prod_txns_cur%NOTFOUND ;

       END LOOP;

       IF Prod_txns_cur%ISOPEN   THEN
          CLOSE Prod_txns_cur;
       END IF;
       COMMIT;
    Exception
       When Others Then
          l_error_text := 'Error Code :' || sqlcode || 'Error Message:' || substr(sqlerrm, 1, 1000) ;
		-- Rollback the changes
          ROLLBACK;

          INSERT INTO CSD_UPG_ERRORS
              (ORIG_SYSTEM_REFERENCE,
               TARGET_SYSTEM_REFERENCE,
               ORIG_SYSTEM_REFERENCE_ID,
               UPGRADE_DATETIME,
               ERROR_MESSAGE,
               MIGRATION_PHASE)
             VALUES ('CSD_PRODUCT_TRANSACTIONS',
              'CSD_PRODUCT_TRANSACTIONS',
               NULL,
               sysdate,
               l_error_text,
              '11.5.10');

          Commit;
          raise_application_error( -20000, 'Event:' || l_Procedure_Event || '-Error while migrating CSD_PRODUCT_TRANSACTIONS. '|| l_error_text);

    END csd_product_trans_mig3;

END CSD_Migrate_From_115X_PKG3;

/
