--------------------------------------------------------
--  DDL for Package Body PAP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAP_CMERGE" AS
-- $Header: PAPCMR3B.pls 120.2.12010000.4 2008/08/29 14:26:45 arbandyo ship $
/*                                                         */
--
-- function to retrieve new customer id for pa_project_customers table
-- using current customer id only.
--
        FUNCTION RETRIEVE_CUSTOMER_ID( set_no IN NUMBER ) RETURN BOOLEAN IS
         BEGIN
--
              SELECT DISTINCT RACM.CUSTOMER_ID, RACM.DUPLICATE_ID INTO new_customer_id,
                                                              old_customer_id
                FROM RA_CUSTOMER_MERGES RACM
               WHERE RACM.DUPLICATE_ID = var_customer_id
                 AND RACM.PROCESS_FLAG = 'N'
                 AND RACM.SET_NUMBER = set_no;
--
              RETURN FALSE;
         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   RETURN TRUE;
              WHEN OTHERS THEN
                   RETURN TRUE;
         END RETRIEVE_CUSTOMER_ID;
--
-- function to verify whether duplicate index record ( project_id + customer_id )
-- exist in pa_project_customers.
--
        FUNCTION CHECK_DUPLICATE_INDEX RETURN BOOLEAN IS
        BEGIN
             SELECT CUSTOMER_BILL_SPLIT
             INTO new_customer_bill_split
                    FROM PA_PROJECT_CUSTOMERS PC
                    WHERE PC.PROJECT_ID = var_project_id
                    AND PC.CUSTOMER_ID = new_customer_id;
             RETURN FALSE;
         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   RETURN TRUE;
              WHEN OTHERS THEN
                   RETURN TRUE;
        END CHECK_DUPLICATE_INDEX;
--
-- this is the main procedure that updates all the necessary tables affecting Project
-- accounting.
--
  PROCEDURE MERGE ( req_id IN NUMBER, set_no IN NUMBER, process_mode IN VARCHAR2 ) IS
--
/*      CURSOR cursor_1 IS SELECT DISTINCT PA.PROJECT_ID, PA.CUSTOMER_ID, PA.BILL_TO_ADDRESS_ID,
                                PA.SHIP_TO_ADDRESS_ID,PA.BILL_TO_CUSTOMER_ID,PA.SHIP_TO_CUSTOMER_ID, DEFAULT_TOP_TASK_CUST_FLAG -- FP_M Changes
                           FROM pa_project_customers PA,RA_CUSTOMER_MERGES RACM
                          WHERE    RACM.PROCESS_FLAG = 'N'
                            AND    RACM.SET_NUMBER = set_no
                            AND    (PA.CUSTOMER_ID=RACM.DUPLICATE_ID
                            OR    PA.BILL_TO_CUSTOMER_ID=RACM.DUPLICATE_ID
                            OR    PA.SHIP_TO_CUSTOMER_ID=RACM.DUPLICATE_ID )
	 Bug 3891382. Added the condition so that the cursor picks projects specific to the
               org_id where customer merge has taken place.
			    AND  EXISTS ( SELECT NULL FROM PA_PROJECTS
                                          WHERE PROJECT_ID = PA.PROJECT_ID ); commented for 3938428*/

/* Modified cursor for bug 3938428*/
CURSOR cursor_1 IS SELECT PA.PROJECT_ID, PA.CUSTOMER_ID, PA.BILL_TO_ADDRESS_ID,
                                PA.SHIP_TO_ADDRESS_ID,PA.BILL_TO_CUSTOMER_ID,PA.SHIP_TO_CUSTOMER_ID , DEFAULT_TOP_TASK_CUST_FLAG -- FP_M Changes
                           FROM pa_project_customers PA
                          WHERE   EXISTS (
					SELECT	1 FROM RA_CUSTOMER_MERGES RACM
					WHERE	RACM.PROCESS_FLAG = 'N'
					AND    RACM.SET_NUMBER = set_no
					AND	RACM.request_id = req_id
					AND    (PA.CUSTOMER_ID=RACM.DUPLICATE_ID
					OR    PA.BILL_TO_CUSTOMER_ID=RACM.DUPLICATE_ID
					OR    PA.SHIP_TO_CUSTOMER_ID=RACM.DUPLICATE_ID ))
                            AND  EXISTS ( SELECT NULL FROM PA_PROJECTS
                                          WHERE PROJECT_ID = PA.PROJECT_ID );

    /* Bug 3891382. Added the cursor to select the delete_duplicate_flag */
      CURSOR cursor_2 IS SELECT DUPLICATE_ID,DELETE_DUPLICATE_FLAG,CUSTOMER_ID /* for bug 6732730*/
			   FROM RA_CUSTOMER_MERGES
			  WHERE   PROCESS_FLAG = 'N'
			    AND   SET_NUMBER = set_no;
--
      CURSOR cursor_lock_1 IS
       SELECT CUSTOMER_ID FROM pa_project_customers PC
         WHERE
               PC.CUSTOMER_ID IN ( SELECT DISTINCT RACM.DUPLICATE_ID
                                    FROM  RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no )
               FOR UPDATE NOWAIT;
--
      CURSOR cursor_lock_2 IS
       SELECT SHIP_TO_ADDRESS_ID FROM pa_draft_invoice_items PDII
           WHERE
               PDII.SHIP_TO_ADDRESS_ID IN ( SELECT RACM.DUPLICATE_ADDRESS_ID
                                     FROM   RA_CUSTOMER_MERGES RACM
                                     WHERE  RACM.PROCESS_FLAG = 'N'
                                     AND    RACM.SET_NUMBER = set_no
                                     AND    RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' )
               FOR UPDATE NOWAIT;

      CURSOR cursor_lock_3 IS
       SELECT ADDRESS_ID FROM pa_tasks PT
           WHERE
               PT.ADDRESS_ID IN  ( SELECT RACM.DUPLICATE_ADDRESS_ID
                           FROM   RA_CUSTOMER_MERGES RACM
                          WHERE   RACM.PROCESS_FLAG = 'N'
                            AND   RACM.SET_NUMBER = set_no
                            AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' )
               FOR UPDATE NOWAIT;
--
      CURSOR cursor_lock_4 IS
       SELECT CUSTOMER_ID FROM pa_project_contacts PC
           WHERE
               PC.CUSTOMER_ID IN ( SELECT RACM.DUPLICATE_ID
                            FROM   RA_CUSTOMER_MERGES RACM
                           WHERE   RACM.PROCESS_FLAG = 'N'
                             AND   RACM.SET_NUMBER = set_no )
               FOR UPDATE NOWAIT;
--
      CURSOR cursor_lock_5 IS
       SELECT CUSTOMER_ID FROM pa_agreements PA
           WHERE
               PA.CUSTOMER_ID IN ( SELECT RACM.DUPLICATE_ID
                            FROM   RA_CUSTOMER_MERGES RACM
                           WHERE   RACM.PROCESS_FLAG = 'N'
                             AND   RACM.SET_NUMBER = set_no )
               FOR UPDATE NOWAIT;
--
      CURSOR cursor_lock_6 IS
       SELECT CUSTOMER_ID FROM pa_implementations PA  -- bug 3891382
           WHERE
               PA.CUSTOMER_ID IN ( SELECT RACM.DUPLICATE_ID
                            FROM   RA_CUSTOMER_MERGES RACM
                           WHERE   RACM.PROCESS_FLAG = 'N'
                             AND   RACM.SET_NUMBER = set_no )
               FOR UPDATE NOWAIT;
--
      CURSOR cursor_lock_7 IS
       SELECT CUSTOMER_ID FROM pa_proj_retn_rules PA
           WHERE
               PA.CUSTOMER_ID IN ( SELECT RACM.DUPLICATE_ID
                            FROM   RA_CUSTOMER_MERGES RACM
                           WHERE   RACM.PROCESS_FLAG = 'N'
                             AND   RACM.SET_NUMBER = set_no )
               FOR UPDATE NOWAIT;
--
      CURSOR cursor_lock_8 IS
       SELECT CUSTOMER_ID FROM pa_proj_retn_bill_rules PA
           WHERE
               PA.CUSTOMER_ID IN ( SELECT RACM.DUPLICATE_ID
                            FROM   RA_CUSTOMER_MERGES RACM
                           WHERE   RACM.PROCESS_FLAG = 'N'
                             AND   RACM.SET_NUMBER = set_no )
               FOR UPDATE NOWAIT;
--
      CURSOR cursor_lock_9 IS
       SELECT CUSTOMER_ID FROM pa_summary_project_retn PA
           WHERE
               PA.CUSTOMER_ID IN ( SELECT RACM.DUPLICATE_ID
                            FROM   RA_CUSTOMER_MERGES RACM
                           WHERE   RACM.PROCESS_FLAG = 'N'
                             AND   RACM.SET_NUMBER = set_no )
               FOR UPDATE NOWAIT;
--
      var_bill_to_address_id  pa_project_customers.bill_to_address_id%TYPE;
      var_ship_to_address_id  pa_project_customers.ship_to_address_id%TYPE;
      var_bill_to_cust_id     pa_project_customers.bill_to_customer_id%TYPE;
      var_ship_to_cust_id     pa_project_customers.ship_to_customer_id%TYPE;
      var_Default_Top_Task_Cust_Flag pa_project_customers.DEFAULT_TOP_TASK_CUST_FLAG%TYPE;
      not_found_flag          BOOLEAN;
      records_locked          EXCEPTION;
      total_record_upd_count  NUMBER := 0;
      total_record_del_count  NUMBER := 0;
      PRAGMA EXCEPTION_INIT( records_locked, -00054 );
      var_dup_id	      ra_customer_merges.duplicate_id%TYPE;
      var_dup_flag	      ra_customer_merges.delete_duplicate_flag%TYPE;
      var_count1	      NUMBER := 0;
      var_count2	      NUMBER := 0;
      /* Begin for Bug 	6732730 */
      var_cust_id         ra_customer_merges.customer_id%TYPE; /* Modified to var_cust_id for bug 7341412 */
      /* End for Bug 6732730 */

/*                                                         */
    BEGIN
/*                                                         */
-- to indicate what package name is being executed.
--
-- update log file to indicate the module being executed.
--
   ARP_MESSAGE.SET_LINE( 'PAP_CMERGE.MERGE()+' );
--
--Get the profile option for audit of customer merge
    g_audit_profile :=NVL(FND_PROFILE.value('HZ_AUDIT_ACCT_MERGE'),'N');

-- Lock the rows for the current set_no to avoid indefinate wait
--
    IF process_mode = 'LOCK' THEN
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJECT_CUSTOMERS', FALSE );
--
       open cursor_lock_1;
       close cursor_lock_1;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_DRAFT_INVOICE_ITEMS', FALSE );
--
       open cursor_lock_2;
       close cursor_lock_2;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_TASKS', FALSE );
--
       open cursor_lock_3;
       close cursor_lock_3;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJECT_CONTACTS', FALSE );
--
       open cursor_lock_4;
       close cursor_lock_4;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_AGREEMENTS', FALSE );
--
       open cursor_lock_5;
       close cursor_lock_5;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_IMPLEMENTATIONS', FALSE );
							--bug3891382
--
       open cursor_lock_6;
       close cursor_lock_6;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJ_RETN_RULES', FALSE );
--
       open cursor_lock_7;
       close cursor_lock_7;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJ_RETN_BILL_RULES', FALSE );
--
       open cursor_lock_8;
       close cursor_lock_8;
--
       ARP_MESSAGE.SET_NAME( 'AR', 'AR_LOCKING_TABLE' );
       ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_SUMMARY_PROJECT_RETN', FALSE );
--
       open cursor_lock_9;
       close cursor_lock_9;
--
       GOTO done_locking;
--
    END IF;
--
     ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
     ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJECT_CUSTOMERS' );
--
/* Added for Bug 3891382. The logic prevents deletion of the customer being
   merged, if the customer is having sites in single org unit and is being
   referenced in other org units. */

     OPEN cursor_2;

     LOOP

  	FETCH cursor_2 INTO var_dup_id, var_dup_flag ,var_cust_id; /* for bug 6732730*/
  	/* Modified to var_cust_id for bug 7341412 */
	EXIT WHEN cursor_2%NOTFOUND;

	IF var_dup_flag = 'Y' and var_cust_id <> var_dup_id THEN  /* for bug 6732730*/
/* Modified to var_cust_id for bug 7341412 */
	     SELECT count(*) INTO var_count1 FROM pa_project_customers
 	     WHERE customer_id = var_dup_id
	       AND project_id NOT IN (
				SELECT project_id FROM pa_projects);

             SELECT count(*) INTO var_count2 FROM pa_implementations_all
             WHERE customer_id = var_dup_id
               AND org_id NOT IN (
                                SELECT DISTINCT org_id FROM pa_projects);

	     var_count1 := var_count1 + var_count2;

             SELECT count(*) INTO var_count2 FROM pa_agreements_all
             WHERE customer_id = var_dup_id
               AND org_id NOT IN (
                                SELECT DISTINCT org_id FROM pa_projects);

             var_count1 := var_count1 + var_count2;

             SELECT count(*) INTO var_count2 FROM pa_project_contacts
             WHERE customer_id = var_dup_id
               AND project_id NOT IN (
                                SELECT project_id FROM pa_projects);

             var_count1 := var_count1 + var_count2;

		IF var_count1 > 0 THEN
		 ARP_CMERGE_MASTER.veto_delete(req_id,set_no,var_dup_id,'Customer
is referenced in other organizational units.');
		END IF;
	 END IF;

     END LOOP;

     CLOSE cursor_2;

 /* End of code for Bug 3891382 */

     OPEN cursor_1;
--
--
--  this loop fetches each row from pa_project_customers table and verifies whether
--  duplicate index ( project_id + customer_id ) exist and if it does then it would
--  delete the duplicate index row and add the customer bill split to the updated
--  row so that sum of the customer bill split for all the customers for that project
--  equals 100%.
--
     LOOP
--
--  fetch each row from pa_project_customers table.
--
        FETCH cursor_1 INTO var_project_id, var_customer_id,
                            var_bill_to_address_id,
                            var_ship_to_address_id,
                            var_bill_to_cust_id,
                            var_ship_to_cust_id,
			    var_Default_Top_Task_Cust_Flag; -- FP_M Changes
--
        EXIT WHEN cursor_1%NOTFOUND;
--
--  initialize the old and new customer id.
--
        old_customer_id := 0;
        new_customer_id := 0;
--  retrieve new and old customer id.
        not_found_flag := RETRIEVE_CUSTOMER_ID( set_no );
--
--  if old and new customer id is equal which means that it's not
--  customer merge, it could be address or site use is merge.
--
        IF old_customer_id <> new_customer_id THEN
           not_found_flag := CHECK_DUPLICATE_INDEX;

           SELECT CUSTOMER_BILL_SPLIT
           INTO   var_customer_bill_split
           FROM   PA_PROJECT_CUSTOMERS PC
           WHERE  PC.PROJECT_ID = var_project_id
           AND    PC.CUSTOMER_ID = old_customer_id;

           /*Bug5462389*/
           Update pa_tasks
    	   Set  Customer_ID = new_customer_id
    	   Where Project_ID = var_project_id
    	   And   Customer_ID = old_customer_id;
        ELSE
           not_found_flag := TRUE;
        END IF;
--
        IF NOT not_found_flag THEN
/*Added for Tca audit */
IF g_audit_profile='Y' THEN

   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
              MERGE_LOG_ID,
              TABLE_NAME,
              MERGE_HEADER_ID,
              PRIMARY_KEY1,
              PRIMARY_KEY2,
              ACTION_FLAG,
              REQUEST_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
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
	      DEL_COL12,
	      DEL_COL13,
	      DEL_COL14,
	      DEL_COL15,
	      DEL_COL16,
	      DEL_COL17,
	      DEL_COL18,
	      DEL_COL19,
	      DEL_COL20,
	      DEL_COL21,
              DEL_COL22,
              DEL_COL23,
	      DEL_COL24   -- FP_M Changes
         )
        ( SELECT
              HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'PA_PROJECT_CUSTOMERS',
             RACM.CUSTOMER_MERGE_HEADER_ID,
             var_project_id,
             new_customer_id,
             'D',
             req_id,
             hz_utility_pub.CREATED_BY,
             hz_utility_pub.CREATION_DATE,
             hz_utility_pub.LAST_UPDATE_LOGIN,
             hz_utility_pub.LAST_UPDATE_DATE,
             hz_utility_pub.LAST_UPDATED_BY,
             PC.PROJECT_ID
	    ,PC.CUSTOMER_ID
	    ,PC.LAST_UPDATE_DATE
	    ,PC.LAST_UPDATED_BY
	    ,PC.CREATION_DATE
	    ,PC.CREATED_BY
	    ,PC.LAST_UPDATE_LOGIN
	    ,PC.PROJECT_RELATIONSHIP_CODE
	    ,PC.CUSTOMER_BILL_SPLIT
	    ,PC.BILL_TO_ADDRESS_ID
	    ,PC.SHIP_TO_ADDRESS_ID
	    ,PC.INV_CURRENCY_CODE
	    ,PC.INV_RATE_TYPE
	    ,PC.INV_RATE_DATE
	    ,PC.INV_EXCHANGE_RATE
	    ,PC.ALLOW_INV_USER_RATE_TYPE_FLAG
	    ,PC.BILL_ANOTHER_PROJECT_FLAG
	    ,PC.RECEIVER_TASK_ID
	    ,PC.RECORD_VERSION_NUMBER
	    ,PC.PROJECT_PARTY_ID
	    ,PC.RETENTION_LEVEL_CODE
            ,PC.BILL_TO_CUSTOMER_ID
            ,PC.SHIP_TO_CUSTOMER_ID
	    ,PC.Default_Top_Task_Cust_Flag	-- FP_M Changes
             FROM PA_PROJECT_CUSTOMERS pc,ra_customer_merges RACM
            WHERE RACM.DUPLICATE_ID = var_customer_id
              AND  PC.PROJECT_ID=var_project_id
              AND  PC.CUSTOMER_ID = var_customer_id
              AND  RACM.PROCESS_FLAG = 'N'
              AND  RACM.SET_NUMBER = set_no
              AND  ROWNUM=1);
END IF;
/* End for tca audit*/
--
-- if duplicate index row exist then we need to delete this row
-- and update the customer bill split accordingly.
--
             DELETE FROM pa_project_customers PC
                    WHERE PC.PROJECT_ID = var_project_id
                    AND PC.CUSTOMER_ID = var_customer_id;
--
             total_record_del_count := total_record_del_count + 1;
--
/*Added for Tca audit */
IF g_audit_profile='Y' THEN

   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
              MERGE_LOG_ID,
              TABLE_NAME,
              MERGE_HEADER_ID,
              PRIMARY_KEY1,
              PRIMARY_KEY2,
              NUM_COL4_ORIG,
              NUM_COL4_NEW,
              ACTION_FLAG,
              REQUEST_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
           )
          ( SELECT
              HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'PA_PROJECT_CUSTOMERS',
              RACM.CUSTOMER_MERGE_HEADER_ID,
              PC.project_id,
              PC.customer_id,
              PC.customer_bill_split,
              PC.customer_bill_split+ var_customer_bill_split,
              'U',
              req_id,
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
              FROM PA_PROJECT_CUSTOMERS PC, ra_customer_merges RACM
             WHERE  PC.PROJECT_ID = var_project_id
               AND  PC.CUSTOMER_ID = new_customer_id
               AND  RACM.DUPLICATE_ID = var_customer_id
               AND  RACM.PROCESS_FLAG = 'N'
               AND  RACM.SET_NUMBER = set_no
               AND  ROWNUM=1);

END IF;
/* End of Tca audit*/

             UPDATE pa_project_customers PC
                  SET PC.CUSTOMER_BILL_SPLIT = PC.CUSTOMER_BILL_SPLIT +
                                               var_customer_bill_split
                  WHERE
                      PC.PROJECT_ID = var_project_id
                  AND
                      PC.CUSTOMER_ID = new_customer_id;
	  -- FP_M Changes
	  -- If the Top_Task customer flag is enabled then update
	  -- the Default_Top_task_Cust_Flag column also in Project Customers table
	  -- and
	  -- update the customer with new customer id in Project Tasks table
	     If var_Default_Top_Task_Cust_Flag = 'Y' then
		UPDATE pa_project_customers PC
                SET PC.Default_Top_Task_Cust_Flag  = 'Y'
		WHERE	PC.PROJECT_ID = var_project_id
		AND PC.CUSTOMER_ID = new_customer_id;
             End IF; /* Added for bug 4218767*/

		/*Bug5462389:moved the update on pa_tasks before the IF condition*/
	  -- End of FP_M Changes
        ELSE
--
-- update pa_project_customers table for bill to address id, this is necessary
-- because if we update customer id also then we would not be able to update
-- ship to address id.
--

/*Added for tca audit*/
IF g_audit_profile='Y' THEN

    INSERT INTO HZ_CUSTOMER_MERGE_LOG (
               MERGE_LOG_ID,
               TABLE_NAME,
               MERGE_HEADER_ID,
               PRIMARY_KEY1,
               PRIMARY_KEY2,
               NUM_COL2_ORIG,
               NUM_COL2_NEW,
               ACTION_FLAG,
               REQUEST_ID,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATE_LOGIN,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY)
     ( SELECT
               HZ_CUSTOMER_MERGE_LOG_s.nextval,
              'PA_PROJECT_CUSTOMERS',
              RACM.CUSTOMER_MERGE_HEADER_ID,
              PC.project_id,
              PC.customer_id,
              PC.bill_to_address_id,
              RACM.CUSTOMER_ADDRESS_ID,
              'U',
              req_id,
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
              FROM  PA_PROJECT_CUSTOMERS PC, RA_CUSTOMER_MERGES RACM
             WHERE RACM.DUPLICATE_ID = var_bill_to_cust_id /*CACR*/
               AND   RACM.DUPLICATE_ADDRESS_ID = PC.BILL_TO_ADDRESS_ID
               AND   RACM.PROCESS_FLAG = 'N'
               AND   RACM.SET_NUMBER = set_no
               AND   RACM.CUSTOMER_SITE_CODE = 'BILL_TO'
               AND   PC.PROJECT_ID = var_project_id
               AND   PC.CUSTOMER_ID = var_customer_id);

END IF;
/* End of TCA audit*/

        UPDATE pa_project_customers PC
        SET ( BILL_TO_ADDRESS_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ADDRESS_ID
                                       FROM RA_CUSTOMER_MERGES RACM
                                       WHERE RACM.DUPLICATE_ID = var_bill_to_cust_id /*CACR*/
                                       AND   RACM.DUPLICATE_ADDRESS_ID = PC.BILL_TO_ADDRESS_ID
                                       AND   RACM.PROCESS_FLAG = 'N'
                                       AND   RACM.SET_NUMBER = set_no
                                       AND   RACM.CUSTOMER_SITE_CODE = 'BILL_TO' ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               PC.BILL_TO_ADDRESS_ID IN ( SELECT DISTINCT RACM.DUPLICATE_ADDRESS_ID
                                    FROM  RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = var_bill_to_cust_id /*CACR*/
                                     AND RACM.PROCESS_FLAG = 'N'
                                     AND RACM.SET_NUMBER = set_no
                                     AND RACM.CUSTOMER_SITE_CODE = 'BILL_TO' )
           AND PC.PROJECT_ID = var_project_id
           AND PC.CUSTOMER_ID = var_customer_id;
--
-- update pa_project_customers table for customer_id and ship_to_address_id.
--
IF g_audit_profile='Y' THEN

    INSERT INTO HZ_CUSTOMER_MERGE_LOG (
               MERGE_LOG_ID,
               TABLE_NAME,
               MERGE_HEADER_ID,
               PRIMARY_KEY1,
               PRIMARY_KEY2,
               NUM_COL3_ORIG,
               NUM_COL3_NEW,
               ACTION_FLAG,
               REQUEST_ID,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATE_LOGIN,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY)
     ( SELECT
               HZ_CUSTOMER_MERGE_LOG_s.nextval,
               'PA_PROJECT_CUSTOMERS',
               RACM.CUSTOMER_MERGE_HEADER_ID,
               PC.project_id,
               PC.customer_id,
               PC.ship_to_address_id,
               RACM.CUSTOMER_ADDRESS_ID,
               'U',
               req_id,
               hz_utility_pub.CREATED_BY,
               hz_utility_pub.CREATION_DATE,
               hz_utility_pub.LAST_UPDATE_LOGIN,
               hz_utility_pub.LAST_UPDATE_DATE,
               hz_utility_pub.LAST_UPDATED_BY
               FROM    PA_PROJECT_CUSTOMERS PC, RA_CUSTOMER_MERGES RACM
             WHERE RACM.DUPLICATE_ID = var_ship_to_cust_id /*CACR*/
                AND   RACM.DUPLICATE_ADDRESS_ID = PC.SHIP_TO_ADDRESS_ID
                AND   RACM.PROCESS_FLAG = 'N'
                AND   RACM.SET_NUMBER = set_no
                AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO'
                AND   PC.PROJECT_ID = var_project_id
                AND   PC.CUSTOMER_ID = var_customer_id);

END IF;

        UPDATE pa_project_customers PC
        SET ( SHIP_TO_ADDRESS_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ADDRESS_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                           WHERE RACM.DUPLICATE_ID = var_ship_to_cust_id /*CACR*/
                                          AND   RACM.DUPLICATE_ADDRESS_ID = PC.SHIP_TO_ADDRESS_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no
                                          AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               PC.SHIP_TO_ADDRESS_ID IN ( SELECT RACM.DUPLICATE_ADDRESS_ID
                                    FROM  RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = var_ship_to_cust_id /*CACR*/
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no
                                    AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' )
           AND PC.PROJECT_ID = var_project_id
           AND PC.CUSTOMER_ID = var_customer_id;

/*For customer account relation enhancement*/

IF g_audit_profile='Y' THEN

    INSERT INTO HZ_CUSTOMER_MERGE_LOG (
               MERGE_LOG_ID,
               TABLE_NAME,
               MERGE_HEADER_ID,
               PRIMARY_KEY1,
               PRIMARY_KEY2,
               NUM_COL5_ORIG,
               NUM_COL5_NEW,
               ACTION_FLAG,
               REQUEST_ID,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATE_LOGIN,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY)
     ( SELECT
               HZ_CUSTOMER_MERGE_LOG_s.nextval,
               'PA_PROJECT_CUSTOMERS',
               RACM.CUSTOMER_MERGE_HEADER_ID,
               PC.project_id,
               PC.customer_id,
               PC.bill_to_customer_id,
               RACM.CUSTOMER_ID,
               'U',
               req_id,
               hz_utility_pub.CREATED_BY,
               hz_utility_pub.CREATION_DATE,
               hz_utility_pub.LAST_UPDATE_LOGIN,
               hz_utility_pub.LAST_UPDATE_DATE,
               hz_utility_pub.LAST_UPDATED_BY
               FROM   PA_PROJECT_CUSTOMERS PC, RA_CUSTOMER_MERGES RACM
              WHERE   RACM.DUPLICATE_ID = var_bill_to_cust_id /*CACR*/
                AND   RACM.PROCESS_FLAG = 'N'
                AND   RACM.SET_NUMBER = set_no
                AND   PC.PROJECT_ID = var_project_id
                AND   PC.CUSTOMER_ID = var_customer_id
                AND   RACM.CUSTOMER_ID<>RACM.DUPLICATE_ID
                AND   ROWNUM=1);
END IF;

     UPDATE pa_project_customers PC
        SET ( BILL_TO_CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = var_bill_to_cust_id
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               EXISTS ( SELECT NULL FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = PC.BILL_TO_CUSTOMER_ID
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no )
           AND PC.PROJECT_ID = var_project_id
           AND PC.CUSTOMER_ID = var_customer_id;

IF g_audit_profile='Y' THEN

    INSERT INTO HZ_CUSTOMER_MERGE_LOG (
               MERGE_LOG_ID,
               TABLE_NAME,
               MERGE_HEADER_ID,
               PRIMARY_KEY1,
               PRIMARY_KEY2,
               NUM_COL6_ORIG,
               NUM_COL6_NEW,
               ACTION_FLAG,
               REQUEST_ID,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATE_LOGIN,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY)
     ( SELECT
               HZ_CUSTOMER_MERGE_LOG_s.nextval,
               'PA_PROJECT_CUSTOMERS',
               RACM.CUSTOMER_MERGE_HEADER_ID,
               PC.project_id,
               PC.customer_id,
               PC.ship_to_customer_id,
               RACM.CUSTOMER_ID,
               'U',
               req_id,
               hz_utility_pub.CREATED_BY,
               hz_utility_pub.CREATION_DATE,
               hz_utility_pub.LAST_UPDATE_LOGIN,
               hz_utility_pub.LAST_UPDATE_DATE,
               hz_utility_pub.LAST_UPDATED_BY
               FROM   PA_PROJECT_CUSTOMERS PC, RA_CUSTOMER_MERGES RACM
              WHERE   RACM.DUPLICATE_ID = var_ship_to_cust_id /*CACR*/
                AND   RACM.PROCESS_FLAG = 'N'
                AND   RACM.SET_NUMBER = set_no
                AND   PC.PROJECT_ID = var_project_id
                AND   PC.CUSTOMER_ID = var_customer_id
                AND   RACM.CUSTOMER_ID<>RACM.DUPLICATE_ID
                AND   ROWNUM=1);
END IF;

     UPDATE pa_project_customers PC
        SET ( SHIP_TO_CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = var_ship_to_cust_id
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               EXISTS ( SELECT NULL FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = PC.SHIP_TO_CUSTOMER_ID
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no )
           AND PC.PROJECT_ID = var_project_id
           AND PC.CUSTOMER_ID = var_customer_id;
--
-- update pa_project_customers for customer_id only, this is necessary because
-- if in the previous update if ship_to_address_id is null then customer_id
-- would not get updated.
--

IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
 ( select  HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'PA_PROJECT_CUSTOMERS',
         RACM.CUSTOMER_MERGE_HEADER_ID,
         PC.project_id,
         RACM.CUSTOMER_ID,
         PC.customer_id,
         RACM.CUSTOMER_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
	 FROM    PA_PROJECT_CUSTOMERS PC, ra_customer_merges RACM
    WHERE    RACM.DUPLICATE_ID = var_customer_id
         AND   RACM.PROCESS_FLAG = 'N'
         AND   RACM.SET_NUMBER = set_no
         AND   PC.PROJECT_ID = var_project_id
         AND   PC.CUSTOMER_ID = var_customer_id
         AND   RACM.CUSTOMER_ID<>RACM.DUPLICATE_ID
         AND   ROWNUM=1 );

END IF;
        UPDATE pa_project_customers PC
        SET ( CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = var_customer_id
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               EXISTS ( SELECT NULL FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = PC.CUSTOMER_ID
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no )
           AND PC.PROJECT_ID = var_project_id
           AND PC.CUSTOMER_ID = var_customer_id;
--
        END IF;

        total_record_upd_count := total_record_upd_count + 1;
--
    END LOOP;
--
    CLOSE cursor_1;
--
-- update log file to indicate the total records deleted.
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;
--
-- update log file to indicate the total records updated.
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_DELETED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_del_count ));
    total_record_del_count := 0;
--
-- update log file to indicate the table being updated.
--
IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           NUM_COL3_ORIG,
           NUM_COL3_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      )
     (SELECT
         HZ_CUSTOMER_MERGE_LOG_S.nextval,
        'PA_DRAFT_INVOICES_ALL',
         RACM.CUSTOMER_MERGE_HEADER_ID,
         PDI.PROJECT_ID,
         PDI.DRAFT_INVOICE_NUM,
         PDI.CUSTOMER_ID,
         RACM.CUSTOMER_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
        FROM PA_DRAFT_INVOICES PDI,(SELECT DISTINCT CUSTOMER_MERGE_HEADER_ID,
                                                        CUSTOMER_ID,
                                                        DUPLICATE_ID
                                          FROM RA_CUSTOMER_MERGES
                                         WHERE PROCESS_FLAG = 'N'
                                           AND SET_NUMBER = set_no
                                           AND CUSTOMER_ID<>DUPLICATE_ID ) RACM
       WHERE
             RACM.DUPLICATE_ID = PDI.CUSTOMER_ID
      );

END IF;

     UPDATE pa_draft_invoices PC   -- bug 3891382
        SET ( CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = PC.CUSTOMER_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               PC.CUSTOMER_ID IN ( SELECT DUPLICATE_ID FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no );

IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           NUM_COL4_ORIG,
           NUM_COL4_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      )
     (SELECT
         HZ_CUSTOMER_MERGE_LOG_S.nextval,
        'PA_DRAFT_INVOICES_ALL',
         RACM.CUSTOMER_MERGE_HEADER_ID,
         PDI.PROJECT_ID,
         PDI.DRAFT_INVOICE_NUM,
         PDI.BILL_TO_CUSTOMER_ID,
         RACM.CUSTOMER_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
        FROM PA_DRAFT_INVOICES PDI,(SELECT DISTINCT CUSTOMER_MERGE_HEADER_ID,
                                                        CUSTOMER_ID,
                                                        DUPLICATE_ID
                                          FROM RA_CUSTOMER_MERGES
                                         WHERE PROCESS_FLAG = 'N'
                                           AND SET_NUMBER = set_no
                                           AND CUSTOMER_ID<>DUPLICATE_ID ) RACM
       WHERE
             RACM.DUPLICATE_ID = PDI.BILL_TO_CUSTOMER_ID
     );

END IF;

       UPDATE pa_draft_invoices PC	-- bug 3891382
        SET ( BILL_TO_CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = PC.BILL_TO_CUSTOMER_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               PC.BILL_TO_CUSTOMER_ID IN ( SELECT DUPLICATE_ID FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no );

IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           NUM_COL5_ORIG,
           NUM_COL5_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      )
     (SELECT
         HZ_CUSTOMER_MERGE_LOG_S.nextval,
        'PA_DRAFT_INVOICES_ALL',
         RACM.CUSTOMER_MERGE_HEADER_ID,
         PDI.PROJECT_ID,
         PDI.DRAFT_INVOICE_NUM,
         PDI.SHIP_TO_CUSTOMER_ID,
         RACM.CUSTOMER_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
        FROM PA_DRAFT_INVOICES PDI,(SELECT DISTINCT CUSTOMER_MERGE_HEADER_ID,
                                                        CUSTOMER_ID,
                                                        DUPLICATE_ID
                                          FROM RA_CUSTOMER_MERGES
                                         WHERE PROCESS_FLAG = 'N'
                                           AND SET_NUMBER = set_no
                                           AND CUSTOMER_ID<>DUPLICATE_ID ) RACM
       WHERE
             RACM.DUPLICATE_ID = PDI.SHIP_TO_CUSTOMER_ID
      );

END IF;

      UPDATE pa_draft_invoices PC	-- bug 3891382
        SET ( SHIP_TO_CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = PC.SHIP_TO_CUSTOMER_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               PC.SHIP_TO_CUSTOMER_ID IN ( SELECT DUPLICATE_ID FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no );


IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      )
     (SELECT
         HZ_CUSTOMER_MERGE_LOG_S.nextval,
        'PA_DRAFT_INVOICES_ALL',
         RACM.CUSTOMER_MERGE_HEADER_ID,
         PDI.PROJECT_ID,
         PDI.DRAFT_INVOICE_NUM,
         PDI.BILL_TO_ADDRESS_ID,
         RACM.CUSTOMER_ADDRESS_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
       FROM PA_DRAFT_INVOICES PDI,RA_CUSTOMER_MERGES RACM
      WHERE
             RACM.DUPLICATE_ADDRESS_ID = PDI.BILL_TO_ADDRESS_ID
         AND RACM.PROCESS_FLAG = 'N'
         AND RACM.SET_NUMBER = set_no
         AND RACM.CUSTOMER_SITE_CODE = 'BILL_TO'
      );

END IF;

UPDATE pa_draft_invoices PDI	-- bug 3891382
    SET ( BILL_TO_ADDRESS_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ADDRESS_ID
                    FROM RA_CUSTOMER_MERGES RACM
                    WHERE
                        RACM.DUPLICATE_ADDRESS_ID = PDI.BILL_TO_ADDRESS_ID
                    AND RACM.PROCESS_FLAG = 'N'
                    AND RACM.SET_NUMBER = set_no
                    AND RACM.CUSTOMER_SITE_CODE = 'BILL_TO' ),
        LAST_UPDATE_DATE  = SYSDATE,
        LAST_UPDATED_BY   = ARP_STANDARD.PROFILE.USER_ID,
        LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
    WHERE
        PDI.BILL_TO_ADDRESS_ID IN ( SELECT RACM.DUPLICATE_ADDRESS_ID
                                     FROM   RA_CUSTOMER_MERGES RACM
                                     WHERE  RACM.PROCESS_FLAG = 'N'
                                     AND    RACM.SET_NUMBER = set_no
                                     AND    RACM.CUSTOMER_SITE_CODE = 'BILL_TO' );

IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      )
     (SELECT
         HZ_CUSTOMER_MERGE_LOG_s.nextval,
        'PA_DRAFT_INVOICES_ALL',
         RACM.CUSTOMER_MERGE_HEADER_ID,
         PDI.PROJECT_ID,
         PDI.DRAFT_INVOICE_NUM,
         PDI.SHIP_TO_ADDRESS_ID,
         RACM.CUSTOMER_ADDRESS_ID,
        'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
       FROM PA_DRAFT_INVOICES PDI,RA_CUSTOMER_MERGES RACM
      WHERE
             RACM.DUPLICATE_ADDRESS_ID = PDI.SHIP_TO_ADDRESS_ID
         AND RACM.PROCESS_FLAG = 'N'
         AND RACM.SET_NUMBER = set_no
         AND RACM.CUSTOMER_SITE_CODE = 'SHIP_TO'
      );

END IF;

    UPDATE pa_draft_invoices PDI	-- bug 3891382
    SET ( SHIP_TO_ADDRESS_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ADDRESS_ID
                    FROM RA_CUSTOMER_MERGES RACM
                    WHERE
                        RACM.DUPLICATE_ADDRESS_ID = PDI.SHIP_TO_ADDRESS_ID
                    AND RACM.PROCESS_FLAG = 'N'
                    AND RACM.SET_NUMBER = set_no
                    AND RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' ),
        LAST_UPDATE_DATE  = SYSDATE,
        LAST_UPDATED_BY   = ARP_STANDARD.PROFILE.USER_ID,
        LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
    WHERE
        PDI.SHIP_TO_ADDRESS_ID IN ( SELECT RACM.DUPLICATE_ADDRESS_ID
                                     FROM   RA_CUSTOMER_MERGES RACM
                                     WHERE  RACM.PROCESS_FLAG = 'N'
                                     AND    RACM.SET_NUMBER = set_no
                                     AND    RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' );

    ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
    ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_DRAFT_INVOICE_ITEMS' );
--
-- update pa_draft_invoice_items for ship_to_address_id only.
--
IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           PRIMARY_KEY3,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
 ( select  HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'PA_DRAFT_INVOICE_ITEMS',
         RACM.CUSTOMER_MERGE_HEADER_ID,
         PDII.project_id,
         PDII.draft_invoice_num,
         PDII.line_num,
         PDII.ship_to_address_id,
         RACM.CUSTOMER_ADDRESS_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
	   FROM   PA_DRAFT_INVOICE_ITEMS PDII, ra_customer_merges RACM
          WHERE   RACM.DUPLICATE_ADDRESS_ID = PDII.SHIP_TO_ADDRESS_ID
            AND   RACM.PROCESS_FLAG = 'N'
            AND   RACM.SET_NUMBER = set_no
            AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO');

END IF;

    UPDATE pa_draft_invoice_items PDII
    SET ( SHIP_TO_ADDRESS_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ADDRESS_ID
                    FROM RA_CUSTOMER_MERGES RACM
                    WHERE
                        RACM.DUPLICATE_ADDRESS_ID = PDII.SHIP_TO_ADDRESS_ID
                    AND RACM.PROCESS_FLAG = 'N'
                    AND RACM.SET_NUMBER = set_no
                    AND RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' ),
        LAST_UPDATE_DATE  = SYSDATE,
        LAST_UPDATED_BY   = ARP_STANDARD.PROFILE.USER_ID,
        LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
    WHERE
        PDII.SHIP_TO_ADDRESS_ID IN ( SELECT RACM.DUPLICATE_ADDRESS_ID
                                     FROM   RA_CUSTOMER_MERGES RACM
                                     WHERE  RACM.PROCESS_FLAG = 'N'
                                     AND    RACM.SET_NUMBER = set_no
                                     AND    RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' );
--
-- update log file to indicate the total records being updated.
--
    total_record_upd_count := SQL%ROWCOUNT;
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;
--
-- update log file to indicate the table being updated.
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
    ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_TASKS' );
--
-- update pa_tasks for address_id ( ship address id ).
--
IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
	   NUM_COL7_ORIG,
	   NUM_COL7_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
 ( select  HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'PA_TASKS',
          RACM.CUSTOMER_MERGE_HEADER_ID,
          PT.TASK_ID,
         PT. address_id,
         RACM.CUSTOMER_ADDRESS_ID,
	 PT.Customer_ID,
	 New_customer_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
          FROM    PA_TASKS PT, ra_customer_merges RACM
         WHERE  RACM.DUPLICATE_ADDRESS_ID = PT.ADDRESS_ID
           AND   RACM.PROCESS_FLAG = 'N'
           AND   RACM.SET_NUMBER = set_no
           AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO');
END IF;

    UPDATE pa_tasks PT
    SET ( ADDRESS_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ADDRESS_ID
                           FROM RA_CUSTOMER_MERGES RACM
                           WHERE RACM.DUPLICATE_ADDRESS_ID = PT.ADDRESS_ID
                           AND   RACM.PROCESS_FLAG = 'N'
                           AND   RACM.SET_NUMBER = set_no
                           AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' ),
        LAST_UPDATE_DATE  = SYSDATE,
        LAST_UPDATED_BY   = ARP_STANDARD.PROFILE.USER_ID,
        LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
    WHERE
        PT.ADDRESS_ID IN  ( SELECT RACM.DUPLICATE_ADDRESS_ID
                            FROM RA_CUSTOMER_MERGES RACM
                            WHERE RACM.PROCESS_FLAG = 'N'
                            AND   RACM.SET_NUMBER = set_no
                            AND   RACM.CUSTOMER_SITE_CODE = 'SHIP_TO' );
--
-- update log file to indicate the total records being updated.
--
    total_record_upd_count := SQL%ROWCOUNT;
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;
--
-- update log file to indicate the table being updated. For bug# 1676538
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
    ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_IMPLEMENTATIONS' );
--
-- update pa_implementations for customer_id (duplicate_id ).
--
IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
 ( select  HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'PA_IMPLEMENTATIONS_ALL',
          RACM.CUSTOMER_MERGE_HEADER_ID,
          PI.ORG_ID,
         PI.CUSTOMER_ID,
         RACM.CUSTOMER_ID,
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
       FROM    PA_IMPLEMENTATIONS PI, (SELECT DISTINCT CUSTOMER_MERGE_HEADER_ID,
                                                           CUSTOMER_ID,
                                                           DUPLICATE_ID
                                             FROM RA_CUSTOMER_MERGES
                                            WHERE PROCESS_FLAG = 'N'
                                              AND SET_NUMBER = set_no
                                              AND CUSTOMER_ID<>DUPLICATE_ID ) RACM
      WHERE    RACM.DUPLICATE_ID = PI.CUSTOMER_ID);

END IF;

        UPDATE PA_IMPLEMENTATIONS PI      -- Bug 3891382
        SET ( CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = PI.CUSTOMER_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
               LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
               EXISTS ( SELECT NULL FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = PI.CUSTOMER_ID
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no );
--
-- update log file to indicate the total records being updated.
--
    total_record_upd_count := SQL%ROWCOUNT;
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;

/* Added by sbsivara for retention related tables */
--
-- update log file to indicate the table being updated. For bug# 1676538
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
    ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJ_RETN_RULES' );
--
-- update pa_proj_retn_rules for customer_id (duplicate_id ).

IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
 ( select  HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'PA_PROJ_RETN_RULES',
          RACM.CUSTOMER_MERGE_HEADER_ID,
          PR.RETENTION_RULE_ID,
          PR.CUSTOMER_ID,
          RACM.CUSTOMER_ID,
         'U',
          req_id,
          hz_utility_pub.CREATED_BY,
          hz_utility_pub.CREATION_DATE,
          hz_utility_pub.LAST_UPDATE_LOGIN,
          hz_utility_pub.LAST_UPDATE_DATE,
          hz_utility_pub.LAST_UPDATED_BY
          FROM    PA_PROJ_RETN_RULES PR, (SELECT DISTINCT CUSTOMER_MERGE_HEADER_ID,
                                                         CUSTOMER_ID,
                                                         DUPLICATE_ID FROM RA_CUSTOMER_MERGES
                                          WHERE  PROCESS_FLAG = 'N'
                                            AND  SET_NUMBER = set_no
                                            AND  CUSTOMER_ID<>DUPLICATE_ID) RACM
        WHERE RACM.DUPLICATE_ID = PR.CUSTOMER_ID
/* bug 3891382 */
	AND EXISTS ( SELECT NULL FROM PA_PROJECTS
		     WHERE PROJECT_ID = PR.PROJECT_ID ));
/* end 3891382 */


END IF;
--
        UPDATE PA_PROJ_RETN_RULES PR
        SET ( CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = PR.CUSTOMER_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID
           WHERE
               EXISTS ( SELECT NULL FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = PR.CUSTOMER_ID
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no
			/* bug 3891382 */
				    AND   EXISTS ( SELECT NULL FROM PA_PROJECTS
						     WHERE PROJECT_ID = PR.PROJECT_ID ));
			/* end 3891382 */

--
-- update log file to indicate the total records being updated.
--
    total_record_upd_count := SQL%ROWCOUNT;
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;

--
-- update log file to indicate the table being updated. For bug# 1676538
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
    ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_PROJ_RETN_BILL_RULES' );
--
-- update pa_proj_retn_bill_rules for customer_id (duplicate_id ).
--
IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
 ( select  HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'PA_PROJ_RETN_BILL_RULES',
          RACM.CUSTOMER_MERGE_HEADER_ID,
          PB. RETN_BILLING_RULE_ID,
          PB.CUSTOMER_ID,
          RACM.CUSTOMER_ID,
          'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
       FROM    PA_PROJ_RETN_BILL_RULES PB,(SELECT DISTINCT CUSTOMER_MERGE_HEADER_ID,
                                                           CUSTOMER_ID,
                                                           DUPLICATE_ID FROM  RA_CUSTOMER_MERGES
                                            WHERE PROCESS_FLAG ='N'
                                              AND SET_NUMBER = set_no
                                              AND CUSTOMER_ID<>DUPLICATE_ID) RACM
      WHERE RACM.DUPLICATE_ID = PB.CUSTOMER_ID
/* bug 3891382 */
	AND EXISTS ( SELECT NULL FROM PA_PROJECTS
		     WHERE PROJECT_ID = PB.PROJECT_ID ));
/* end 3891382 */


END IF;

        UPDATE PA_PROJ_RETN_BILL_RULES PB
        SET ( CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = PB.CUSTOMER_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID
           WHERE
               EXISTS ( SELECT NULL FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = PB.CUSTOMER_ID
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no
			/* bug 3891382 */
				    AND   EXISTS ( SELECT NULL FROM PA_PROJECTS
						     WHERE PROJECT_ID = PB.PROJECT_ID ));
			/* end 3891382 */

--
-- update log file to indicate the total records being updated.
--
    total_record_upd_count := SQL%ROWCOUNT;
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;

--
-- update log file to indicate the table being updated. For bug# 1676538
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
    ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_SUMMARY_PROJECT_RETN' );
--
-- update pa_summary_project_retn for customer_id (duplicate_id ).
--
IF g_audit_profile='Y' THEN

INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           PRIMARY_KEY3,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
 ( select  HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'PA_SUMMARY_PROJECT_RETN',
          RACM.CUSTOMER_MERGE_HEADER_ID,
          PS.PROJECT_ID,
          PS.TASK_ID,
          PS.AGREEMENT_ID,
          PS.CUSTOMER_ID,
          RACM.CUSTOMER_ID,
          'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
       FROM    PA_SUMMARY_PROJECT_RETN PS, (SELECT DISTINCT CUSTOMER_MERGE_HEADER_ID,
                                                            CUSTOMER_ID,
                                                            DUPLICATE_ID FROM RA_CUSTOMER_MERGES
                                            WHERE PROCESS_FLAG = 'N'
                                              AND SET_NUMBER = set_no
                                              AND DUPLICATE_ID<>CUSTOMER_ID)RACM
      WHERE RACM.DUPLICATE_ID = PS.CUSTOMER_ID
/* bug 3891382 */
	AND EXISTS ( SELECT NULL FROM PA_PROJECTS
		     WHERE PROJECT_ID = PS.PROJECT_ID ));
/* end 3891382 */


END IF;
        UPDATE PA_SUMMARY_PROJECT_RETN PS
        SET ( CUSTOMER_ID ) = ( SELECT DISTINCT RACM.CUSTOMER_ID
                                          FROM RA_CUSTOMER_MERGES RACM
                                          WHERE RACM.DUPLICATE_ID = PS.CUSTOMER_ID
                                          AND   RACM.PROCESS_FLAG = 'N'
                                          AND   RACM.SET_NUMBER = set_no ),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID
           WHERE
               EXISTS ( SELECT NULL FROM RA_CUSTOMER_MERGES RACM
                                    WHERE RACM.DUPLICATE_ID = PS.CUSTOMER_ID
                                    AND   RACM.PROCESS_FLAG = 'N'
                                    AND   RACM.SET_NUMBER = set_no
			/* bug 3891382 */
				    AND   EXISTS ( SELECT NULL FROM PA_PROJECTS
						     WHERE PROJECT_ID = PS.PROJECT_ID ));
			/* end 3891382 */

--
-- update log file to indicate the total records being updated.
--
    total_record_upd_count := SQL%ROWCOUNT;
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;

/* END Added by sbsivara for retention related tables */
--
-- update pa_agreements for customer_id only.
--
    PAP_CMERGE_BB1.MERGE_PA_AGREEMENTS( req_id, set_no );
--
-- update pa_project_contacts for customer_id only.
--
    PAP_CMERGE_BB2.MERGE_PA_PROJECT_CONTACTS( req_id, set_no );
--
--
 <<done_locking>>
--
-- update log file to indicate the successful exit of this module.
--
    ARP_MESSAGE.SET_LINE( 'PAP_CMERGE.MERGE()-' );
--
--
  EXCEPTION

    WHEN OTHERS THEN
          ARP_MESSAGE.SET_ERROR( 'PAP_CMERGE.MERGE' );
          RAISE;

  END MERGE;
--
--
/*********************    End of Mission     ***********************/
END PAP_CMERGE;

/
