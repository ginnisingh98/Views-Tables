--------------------------------------------------------
--  DDL for Package Body PAP_CMERGE_BB2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAP_CMERGE_BB2" AS
-- $Header: PAPCMR2B.pls 120.1 2005/08/05 00:29:59 rgandhi noship $
--
-- function to retrieve new and old customer id's.
--
  FUNCTION RETRIEVE_CUSTOMER_ID(
           set_no IN NUMBER,
           var_customer_id IN pa_project_contacts.customer_id%TYPE,
           var_new_customer_id OUT NOCOPY ra_customer_merges.customer_id%TYPE,/*File.sql.39*/
           var_old_customer_id OUT NOCOPY ra_customer_merges.customer_id%TYPE /*File.sql.39*/ )
--
           RETURN BOOLEAN IS
  BEGIN
--
     var_new_customer_id := NULL;
     var_old_customer_id := NULL;
--
     SELECT DISTINCT RACM.CUSTOMER_ID, RACM.DUPLICATE_ID INTO
            var_new_customer_id, var_old_customer_id
                FROM RA_CUSTOMER_MERGES RACM
               WHERE RACM.DUPLICATE_ID = var_customer_id
                 AND RACM.PROCESS_FLAG = 'N'
                 AND RACM.SET_NUMBER = set_no;
--
     RETURN TRUE;
--
  EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   RETURN FALSE;
              WHEN OTHERS THEN
                   RETURN FALSE;
--
  END RETRIEVE_CUSTOMER_ID;
--
  FUNCTION CHECK_FOR_MUL_BILLING_CON(
     var_project_id      IN pa_project_contacts.project_id%TYPE,
     var_new_customer_id IN pa_project_contacts.customer_id%TYPE )
--
     RETURN BOOLEAN IS
--
   dummy_project_id         pa_project_contacts.project_id%TYPE;
   dummy_customer_id        pa_project_contacts.customer_id%TYPE;
   dummy_contact_id         pa_project_contacts.contact_id%TYPE;
   dummy_proj_con_type_code pa_project_contacts.project_contact_type_code%TYPE;
--
  BEGIN
--
     SELECT DISTINCT PROJECT_ID, CUSTOMER_ID, CONTACT_ID,
                     PROJECT_CONTACT_TYPE_CODE
            INTO dummy_project_id, dummy_customer_id, dummy_contact_id,
                 dummy_proj_con_type_code
            FROM PA_PROJECT_CONTACTS PC
                 WHERE PC.PROJECT_ID = var_project_id
                 AND   PC.CUSTOMER_ID = var_new_customer_id
                 AND   PC.CONTACT_ID >= 0
                 AND   PC.PROJECT_CONTACT_TYPE_CODE = 'BILLING';
--
     RETURN TRUE;
--
  EXCEPTION
--
           WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
           WHEN OTHERS THEN
                RETURN FALSE;
--
  END CHECK_FOR_MUL_BILLING_CON;
--
  FUNCTION DELETE_BILLING_CONTACTS(
         var_project_id       IN pa_project_contacts.project_id%TYPE,
         var_old_customer_id  IN pa_project_contacts.customer_id%TYPE,
         var_new_customer_id  IN pa_project_contacts.customer_id%TYPE,
         var_cust_merge_head_id  IN ra_customer_merges.customer_merge_header_id%TYPE,
         request_id IN NUMBER)
--

--
     RETURN BOOLEAN IS
--
  BEGIN
--
/* Added for Tca audit*/
    IF pap_cmerge.g_audit_profile = 'Y' THEN
--
--  Inserting the data into HZ_CUSTOMER_MERGE_LOG table for
--  PA_PROJECT_CONTACTS table. All rows are inserted that are going
--  to be deleted for old customer.
--
/*DEL_COL11 added for customer account relation enhancement*/
     INSERT INTO hz_customer_merge_log
     (      MERGE_LOG_ID,
            MERGE_HEADER_ID   ,
            REQUEST_ID,
            TABLE_NAME,
            PRIMARY_KEY1,
            PRIMARY_KEY2,
            PRIMARY_KEY3,
            PRIMARY_KEY4,
            ACTION_FLAG,
            DEL_COL1,
            DEL_COL2,
            DEL_COL3,
            DEL_COL4,
            DEL_COL5,
            DEL_COL6,
            DEL_COL7,
            DEL_COL8,
            DEL_COL9,
            DEL_COL10,
            DEL_COL11,
            CREATED_BY,
            CREATION_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN )
     (select
            HZ_CUSTOMER_MERGE_LOG_S.nextval,
            var_cust_merge_head_id,
            request_id,
            'PA_PROJECT_CONTACTS',
            var_project_id,
            var_new_customer_id,
            PC.contact_id,
            PC.project_contact_type_code,
            'D',
            PC.PROJECT_ID,
            PC.CUSTOMER_ID,
            PC.CONTACT_ID,
            PC.PROJECT_CONTACT_TYPE_CODE,
            PC.LAST_UPDATE_DATE ,
            PC.LAST_UPDATED_BY,
            PC.CREATION_DATE,
            PC.CREATED_BY,
            PC.LAST_UPDATE_LOGIN ,
            PC.RECORD_VERSION_NUMBER ,
            PC.BILL_SHIP_CUSTOMER_ID,
            hz_utility_pub.CREATED_BY,
            hz_utility_pub.CREATION_DATE,
            hz_utility_pub.LAST_UPDATE_LOGIN,
            hz_utility_pub.LAST_UPDATE_DATE,
            hz_utility_pub.LAST_UPDATED_BY
            FROM PA_PROJECT_CONTACTS PC
            WHERE PC.PROJECT_ID = var_project_id
              AND PC.CUSTOMER_ID = var_old_customer_id
              AND PC.CONTACT_ID >= 0
              AND PC.PROJECT_CONTACT_TYPE_CODE = 'BILLING');
    END IF;
/* End for Tca Audit */

     DELETE PA_PROJECT_CONTACTS PC
                 WHERE PC.PROJECT_ID = var_project_id
                 AND   PC.CUSTOMER_ID = var_old_customer_id
                 AND   PC.CONTACT_ID >= 0
                 AND   PC.PROJECT_CONTACT_TYPE_CODE = 'BILLING';
--
     RETURN TRUE;
--
  EXCEPTION
--
           WHEN OTHERS THEN
                RETURN FALSE;
--
  END DELETE_BILLING_CONTACTS;
--
  PROCEDURE  MERGE_PA_PROJECT_CONTACTS ( req_id IN NUMBER, set_no IN NUMBER ) IS
      /*CURSOR cursor_3 IS SELECT PROJECT_ID, CUSTOMER_ID FROM pa_project_contacts;*/

        /*Cursor_3 fetches all those records for which the
          primary customer has been merged.
          Cursor_4 will fetch all those records for which
          bill_ship_customer has been merged*/

 CURSOR cursor_3 IS SELECT DISTINCT pc.project_id,
                                    PC.CUSTOMER_ID,
                                    PC.CONTACT_ID,
                                    PC.PROJECT_CONTACT_TYPE_CODE,
                                  RACM.CUSTOMER_ID,
                                  RACM.CUSTOMER_MERGE_HEADER_ID,
                                  PC.BILL_SHIP_CUSTOMER_ID /*For customer account relationship*/
                          FROM pa_project_contacts pc,ra_customer_merges RACM
                         WHERE RACM.DUPLICATE_ID =  PC.CUSTOMER_ID
                           AND RACM.PROCESS_FLAG = 'N'
                           AND RACM.SET_NUMBER = set_no
                           AND RACM.CUSTOMER_ID <> RACM.DUPLICATE_ID
	/* Bug 3891382. Added the condition so that the cursor picks projects specific to the
               org_id where customer merge has taken place. */
                           AND  EXISTS ( SELECT NULL FROM PA_PROJECTS
                                          WHERE PROJECT_ID = PC.PROJECT_ID );

CURSOR cursor_4 IS SELECT DISTINCT pc.project_id,
                                    PC.CUSTOMER_ID,
                                    PC.CONTACT_ID,
                                    PC.PROJECT_CONTACT_TYPE_CODE,
                                  RACM.CUSTOMER_ID,
                                  RACM.CUSTOMER_MERGE_HEADER_ID,
                                  PC.BILL_SHIP_CUSTOMER_ID /*For customer account relationship*/
                          FROM pa_project_contacts pc,ra_customer_merges RACM
                         WHERE RACM.DUPLICATE_ID =  PC.BILL_SHIP_CUSTOMER_ID
                           AND RACM.PROCESS_FLAG = 'N'
                           AND RACM.SET_NUMBER = set_no
                           AND RACM.CUSTOMER_ID <> RACM.DUPLICATE_ID
	/* Bug 3891382. Added the condition so that the cursor picks projects specific to the
               org_id where customer merge has taken place. */
			   AND  EXISTS ( SELECT NULL FROM PA_PROJECTS
                                          WHERE PROJECT_ID = PC.PROJECT_ID );

--

      var_project_id            pa_project_contacts.project_id%TYPE;
      var_customer_id           pa_project_contacts.customer_id%TYPE;
      var_contact_id            pa_project_contacts.contact_id%TYPE;
      var_contact_type_code     pa_project_contacts.project_contact_type_code%TYPE;
      var_bill_ship_customer_id pa_project_contacts.bill_ship_customer_id%TYPE;/*Added for customer account*/
      var_old_customer_id       pa_project_contacts.customer_id%TYPE;    /*uncommented for customer account relation*/
  --  var_new_customer_id       pa_project_contacts.customer_id%TYPE;
      var_racm_customer_id    ra_customer_merges.customer_id%TYPE;/*Added for TCA AUDIT */
      var_cust_merge_header_id ra_customer_merges.CUSTOMER_MERGE_HEADER_ID%TYPE;/*Added for TCA AUDIT */

      data_found                BOOLEAN;
      total_record_upd_count    NUMBER := 0;
      total_record_del_count    NUMBER := 0;
--
  BEGIN
--
-- update log file for entering this module successfully.
--
     ARP_MESSAGE.SET_LINE( 'PAP_CMERGE_BB1.MERGE_PA_PROJECT_CONTACTS()+' );
--
-- update log file to indicate table name being updated.
--
     ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
     ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJECT_CONTACTS' );
--
     OPEN cursor_3;
--
     LOOP
--
--  fetch each row from pa_project_contacts table.
--
        FETCH cursor_3 INTO var_project_id,
                            var_customer_id,
                            var_contact_id,
                            var_contact_type_code,
                            var_racm_customer_id,
                            var_cust_merge_header_id,
                            var_bill_ship_customer_id;
--
        EXIT WHEN cursor_3%NOTFOUND;
--
-- verify whether customer merge is necessary.
--
        /*data_found := RETRIEVE_CUSTOMER_ID( set_no,
                                            var_customer_id,
                                            var_new_customer_id,
                                            var_old_customer_id );
--
        if data_found then Commented for TCA audit */
--
-- check for multiple billing contact.
--
           data_found := CHECK_FOR_MUL_BILLING_CON( var_project_id,
                                                    var_racm_customer_id );
--
--                         /*Following AND condition added for bug 2646936 */
           if data_found then /*AND (var_new_customer_id <> var_old_customer_id ) then Commented for Tca audit */
--
-- delete the second billing contact since we need only one billing contact.
--
              data_found := DELETE_BILLING_CONTACTS( var_project_id,
                                                     var_customer_id,
                                                     var_racm_customer_id,
                                                     var_cust_merge_header_id,
                                                     req_id);
--
              if data_found then
--
                 total_record_del_count := total_record_del_count + 1;
--
              end if;
--
           end if;
/* Added for TCA audit */
--  Checking for the profile flag for audit.
--
      IF pap_cmerge.g_audit_profile = 'Y' THEN
--
--  Inserting data into HZ_CUSTOMER_MERGE_LOG table for
--  PA_PROJECT_CONTACTS table the new and old contact id.
--
         INSERT INTO hz_customer_merge_log
         (
                MERGE_LOG_ID,
                MERGE_HEADER_ID,
                REQUEST_ID,
                TABLE_NAME,
                PRIMARY_KEY1,
                PRIMARY_KEY2,
                PRIMARY_KEY3,
                PRIMARY_KEY4,
                NUM_COL1_ORIG,
                NUM_COL1_NEW ,
                ACTION_FLAG,
                CREATED_BY,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN )
          (SELECT
                 HZ_CUSTOMER_MERGE_LOG_S.nextval,
                 var_cust_merge_header_id,
                 req_id,
                 'PA_PROJECT_CONTACTS',
                 var_project_id,
                 var_racm_customer_id,
                 PC.contact_id,
                 PC.project_contact_type_code,
                 var_customer_id,
                 var_racm_customer_id,
                 'U',
                 hz_utility_pub.CREATED_BY,
                 hz_utility_pub.CREATION_DATE,
                 hz_utility_pub.LAST_UPDATE_LOGIN,
                 hz_utility_pub.LAST_UPDATE_DATE,
                 hz_utility_pub.LAST_UPDATED_BY
           FROM  pa_project_contacts PC
          WHERE  PC.PROJECT_ID  = var_project_id
            AND  PC.CUSTOMER_ID = var_customer_id);


    END IF; -- end if of IF pap_cmerge.g_audit_profile = 'Y' THEN
--
/* end of Tca audit*/
--
-- update table pa_project_contacts with new customer_id.
--
           UPDATE pa_project_contacts PC
                  SET CUSTOMER_ID       = var_racm_customer_id,
                      LAST_UPDATE_DATE  = SYSDATE,
                      LAST_UPDATED_BY   = ARP_STANDARD.PROFILE.USER_ID,
                      LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
                  WHERE
                      PC.PROJECT_ID  = var_project_id
                  AND PC.CUSTOMER_ID = var_customer_id;
--
           total_record_upd_count := total_record_upd_count + SQL%ROWCOUNT;
--
        /*end if; Commented for Tca Audit */
        var_customer_id :=var_racm_customer_id; /*Added for customer account */
--
END LOOP; /*FOR CURSOR_3*/

    CLOSE cursor_3;
/*Done with the update of primary customer.The code to follow will take care
  of the cases where the bill_ship_customer has been merged  */
     OPEN cursor_4;
--
     LOOP
--
--  fetch each row from pa_project_contacts table.
--
        FETCH cursor_4 INTO var_project_id,
                            var_customer_id,
                            var_contact_id,
                            var_contact_type_code,
                            var_racm_customer_id,
                            var_cust_merge_header_id,
                            var_bill_ship_customer_id;
--
        EXIT WHEN cursor_4%NOTFOUND;

 /* Added for customer account*/
/*          data_found := RETRIEVE_CUSTOMER_ID( set_no,
                                            var_bill_ship_customer_id,
                                            var_racm_customer_id,
                                            var_old_customer_id );
         if data_found then

commenting out this code as the new bill_ship_customer_id will
be present in var_racm_customer_id fetched from cursor_4*/

          IF pap_cmerge.g_audit_profile = 'Y' THEN
--
--  Inserting data into HZ_CUSTOMER_MERGE_LOG table for
--  PA_PROJECT_CONTACTS table the new and old contact id.
--
/*The new customer_id will be present in var_customer_id*/
         INSERT INTO hz_customer_merge_log
         (
                MERGE_LOG_ID,
                MERGE_HEADER_ID,
                REQUEST_ID,
                TABLE_NAME,
                PRIMARY_KEY1,
                PRIMARY_KEY2,
                PRIMARY_KEY3,
                PRIMARY_KEY4,
                NUM_COL2_ORIG,
                NUM_COL2_NEW ,
                ACTION_FLAG,
                CREATED_BY,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN )
          (SELECT
                 HZ_CUSTOMER_MERGE_LOG_S.nextval,
                 var_cust_merge_header_id,
                 req_id,
                 'PA_PROJECT_CONTACTS',
                 var_project_id,
                 var_customer_id,
                 PC.contact_id,
                 PC.project_contact_type_code,
                 var_bill_ship_customer_id,
                 var_racm_customer_id,
                 'U',
                 hz_utility_pub.CREATED_BY,
                 hz_utility_pub.CREATION_DATE,
                 hz_utility_pub.LAST_UPDATE_LOGIN,
                 hz_utility_pub.LAST_UPDATE_DATE,
                 hz_utility_pub.LAST_UPDATED_BY
           FROM  pa_project_contacts PC
          WHERE  PC.PROJECT_ID  = var_project_id
            AND  PC.CUSTOMER_ID = var_customer_id
            AND  PC.BILL_SHIP_CUSTOMER_ID=var_bill_ship_customer_id);


    END IF; -- end if of IF pap_cmerge.g_audit_profile = 'Y' THEN

            UPDATE pa_project_contacts PC
                  SET BILL_SHIP_CUSTOMER_ID = var_racm_customer_id,
                      LAST_UPDATE_DATE      = SYSDATE,
                      LAST_UPDATED_BY       = ARP_STANDARD.PROFILE.USER_ID,
                      LAST_UPDATE_LOGIN     = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
                  WHERE
                      PC.PROJECT_ID  = var_project_id
                  AND PC.CUSTOMER_ID = var_customer_id
                  AND PC.BILL_SHIP_CUSTOMER_ID=var_bill_ship_customer_id;

           total_record_upd_count := total_record_upd_count + SQL%ROWCOUNT;


     END LOOP;

     CLOSE cursor_4;
--
-- close the opened cursor.
--
/*     CLOSE cursor_3;    commented out for CACR*/
--
--  update log file for total records updated.
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;
--
--  update log file for total records deleted.
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_DELETED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_del_count ));
    total_record_del_count := 0;
--
--  update log file for exiting this module successfully.
--
    ARP_MESSAGE.SET_LINE( 'PAP_CMERGE_BB1.MERGE_PA_PROJECT_CONTACTS()-' );
--
   EXCEPTION
--
      WHEN OTHERS THEN
           ARP_MESSAGE.SET_ERROR( 'PAP_CMERGE_BB1.MERGE_PA_PROJECT_CONTACTS' );
           RAISE;

  END MERGE_PA_PROJECT_CONTACTS;
--
END PAP_CMERGE_BB2;

/
