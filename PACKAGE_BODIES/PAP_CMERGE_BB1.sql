--------------------------------------------------------
--  DDL for Package Body PAP_CMERGE_BB1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAP_CMERGE_BB1" AS
-- $Header: PAPCMR1B.pls 120.1 2005/08/05 00:27:56 rgandhi noship $
--
-- function to retrieve new and old customer id's.
--
  FUNCTION RETRIEVE_AGMT_CUSTOMER_ID(
           set_no IN NUMBER,
           var_agmt_customer_id IN pa_agreements.customer_id%TYPE,
           agmt_new_customer_id OUT NOCOPY pa_agreements.customer_id%TYPE,/*file.sql.39*/
           agmt_old_customer_id OUT NOCOPY pa_agreements.customer_id%TYPE /*file.sql.39*/)
           RETURN BOOLEAN IS
  BEGIN
--
     agmt_new_customer_id := NULL;
     agmt_old_customer_id := NULL;
--
     SELECT DISTINCT RACM.CUSTOMER_ID, RACM.DUPLICATE_ID INTO
                     agmt_new_customer_id, agmt_old_customer_id
                FROM RA_CUSTOMER_MERGES RACM
               WHERE RACM.DUPLICATE_ID = var_agmt_customer_id
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
  END RETRIEVE_AGMT_CUSTOMER_ID;
--
  FUNCTION CHECK_FOR_DUPLICATE_INDEX(
           agmt_new_customer_id IN pa_agreements.customer_id%TYPE,
           var_agmt_agreement_num IN pa_agreements.agreement_num%TYPE,
           var_agmt_agreement_type IN pa_agreements.agreement_type%TYPE )
--
     RETURN BOOLEAN IS
   dummy_customer_id pa_agreements.customer_id%TYPE;
   dummy_agreement_num pa_agreements.agreement_num%TYPE;
   dummy_agreement_type pa_agreements.agreement_type%TYPE;
--
  BEGIN
--
     SELECT CUSTOMER_ID, AGREEMENT_NUM, AGREEMENT_TYPE
                 INTO  dummy_customer_id, dummy_agreement_num, dummy_agreement_type
                 FROM PA_AGREEMENTS PA
                 WHERE PA.CUSTOMER_ID = agmt_new_customer_id
                 AND   PA.AGREEMENT_NUM = var_agmt_agreement_num
                 AND   PA.AGREEMENT_TYPE = var_agmt_agreement_type;
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
  END CHECK_FOR_DUPLICATE_INDEX;
--
  FUNCTION UPDATE_FOR_DUPLICATE_INDEX(
     agmt_new_customer_id IN pa_agreements.customer_id%TYPE,
     var_agmt_agreement_num IN pa_agreements.agreement_num%TYPE,
     var_agmt_agreement_id IN pa_agreements.agreement_id%TYPE,
     var_agmt_agreement_type IN pa_agreements.agreement_type%TYPE,
     seq_index IN NUMBER,
     duplicate_index_value OUT NOCOPY BOOLEAN ,/*file.sql.39*/
     request_id   IN Number,
     cust_merge_head_id IN ra_customer_merges.CUSTOMER_MERGE_HEADER_ID%TYPE)/*Added for TCA AUDIT */
--
     RETURN BOOLEAN IS
--
     /*  Commented for enhancement 1593520
       trunc_agreement_num VARCHAR2(20);
 */
     length_trunc_agreement_num NUMBER;
    /*  Commented for enhancement 1593520
     final_agreement_num VARCHAR2(20);
 */

 /* Code change for enhancement 1593520 */
     final_agreement_num PA_AGREEMENTS.agreement_num%TYPE;
     trunc_agreement_num PA_AGREEMENTS.agreement_num%TYPE;
  /* till here */
--
  BEGIN
--
     duplicate_index_value := FALSE;
     trunc_agreement_num := RTRIM( var_agmt_agreement_num );
     length_trunc_agreement_num := LENGTHB( trunc_agreement_num );
--
   /* Commented out for enhancement 1593520 and rewritten just below this

     if length_trunc_agreement_num <= 15 then
       final_agreement_num := CONCAT(
              SUBSTR(trunc_agreement_num, 1, length_trunc_agreement_num ), '???');
       length_trunc_agreement_num := LENGTHB( final_agreement_num );
       final_agreement_num := CONCAT(
             SUBSTR(final_agreement_num, 1, length_trunc_agreement_num ),
             TO_CHAR( seq_index) );
     else
       final_agreement_num := CONCAT(
             SUBSTR( trunc_agreement_num,1, 15 ), '???' );
       final_agreement_num := CONCAT(
             SUBSTR(final_agreement_num, 1, 18 ), TO_CHAR( seq_index) );
     end if;

     Till here */

/* Changes starts from here for enhancement 1593520 */

     if length_trunc_agreement_num <= 45 then
       final_agreement_num := CONCAT(
              SUBSTR(trunc_agreement_num, 1, length_trunc_agreement_num ), '???');
       length_trunc_agreement_num := LENGTHB( final_agreement_num );
       final_agreement_num := CONCAT(
             SUBSTR(final_agreement_num, 1, length_trunc_agreement_num ),
             TO_CHAR( seq_index) );
     else
       final_agreement_num := CONCAT(
             SUBSTR( trunc_agreement_num,1, 45 ), '???' );
       final_agreement_num := CONCAT(
             SUBSTR(final_agreement_num, 1, 48 ), TO_CHAR( seq_index) );
     end if;
/* till here */
--
/* Added for TCA audit */
    IF pap_cmerge.g_audit_profile = 'Y' THEN
--
--  It inserts the data into HZ_CUSTOMER_MERGE_LOG table
--  for PA_AGREEMENTS table and stamps the new agreement
--  number and old agreement number.
--
     INSERT INTO hz_customer_merge_log
        (   MERGE_LOG_ID,
            MERGE_HEADER_ID,
            REQUEST_ID,
            TABLE_NAME,
            PRIMARY_KEY_ID,
            VCHAR_COL1_ORIG,
            VCHAR_COL1_NEW ,
            ACTION_FLAG,
            CREATED_BY,
            CREATION_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN )
     VALUES(
            HZ_CUSTOMER_MERGE_LOG_S.nextval,
            cust_merge_head_id,
            request_id,
            'PA_AGREEMENTS_ALL',
            var_agmt_agreement_id,
            var_agmt_agreement_num,
            final_agreement_num,
            'U',
            hz_utility_pub.CREATED_BY,
            hz_utility_pub.CREATION_DATE,
            hz_utility_pub.LAST_UPDATE_LOGIN,
            hz_utility_pub.LAST_UPDATE_DATE,
            hz_utility_pub.LAST_UPDATED_BY);
    END IF;
/* End of TCA Audit */

     UPDATE PA_AGREEMENTS PA       	 -- bug 3891382.
            SET PA.AGREEMENT_NUM = final_agreement_num
                 WHERE PA.CUSTOMER_ID = agmt_new_customer_id
                 AND   PA.AGREEMENT_NUM = var_agmt_agreement_num
                 AND   PA.AGREEMENT_TYPE = var_agmt_agreement_type;
--
     RETURN TRUE;
--
  EXCEPTION
--
           WHEN DUP_VAL_ON_INDEX THEN
                duplicate_index_value := TRUE;
                RETURN FALSE;
           WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
           WHEN OTHERS THEN
                RETURN FALSE;
--
  END UPDATE_FOR_DUPLICATE_INDEX;
--
  PROCEDURE  MERGE_PA_AGREEMENTS ( req_id IN NUMBER, set_no IN NUMBER ) IS
      CURSOR cursor_2 IS SELECT DISTINCT AG.CUSTOMER_ID,
                                ag.AGREEMENT_ID,
                                ag.AGREEMENT_NUM,
                                ag.AGREEMENT_TYPE,
                                RACM.CUSTOMER_ID,
                                RACM.CUSTOMER_MERGE_HEADER_ID
                     FROM pa_agreements ag,ra_customer_merges RACM  --bug3891382
                     WHERE RACM.DUPLICATE_ID =  AG.CUSTOMER_ID
                         AND RACM.PROCESS_FLAG = 'N'
                         AND RACM.SET_NUMBER = set_no
                         AND RACM.CUSTOMER_ID <> RACM.DUPLICATE_ID;
--

      var_agmt_customer_id    pa_agreements.customer_id%TYPE;
      var_racm_customer_id    ra_customer_merges.customer_id%TYPE;/*Added for TCA AUDIT */
      var_cust_merge_header_id ra_customer_merges.CUSTOMER_MERGE_HEADER_ID%TYPE;/*Added for TCA AUDIT */
      var_agmt_agreement_id   pa_agreements.agreement_id%TYPE; /* Added for Tca Audit*/
      var_agmt_agreement_num  pa_agreements.agreement_num%TYPE;
      var_agmt_agreement_type pa_agreements.agreement_type%TYPE;
  --  agmt_new_customer_id    pa_agreements.customer_id%TYPE;
  --  agmt_old_customer_id    pa_agreements.customer_id%TYPE;
      data_found              BOOLEAN;
      duplicate_index_value   BOOLEAN;
      seq_index               NUMBER;
      out_of_limit            EXCEPTION;
      total_record_upd_count  NUMBER := 0;
--
  BEGIN
--
-- update log file to indicate the module being executed.
--
     ARP_MESSAGE.SET_LINE( 'PAP_CMERGE_BB2.MERGE_PA_AGREEMENTS()+' );
--
-- update log file to indicate the table being updated.
--
     ARP_MESSAGE.SET_NAME( 'AR', 'AR_UPDATING_TABLE' );
     ARP_MESSAGE.SET_TOKEN( 'TABLE_NAME', 'PA_AGREEMENTS' );
--
     OPEN cursor_2;
--
     LOOP
--
--  fetch each row from pa_agreements table.
--
        FETCH cursor_2 INTO var_agmt_customer_id,
                            var_agmt_agreement_id,
                            var_agmt_agreement_num,
                            var_agmt_agreement_type,
                            var_racm_customer_id,
                            var_cust_merge_header_id;
--
        EXIT WHEN cursor_2%NOTFOUND;
--
        seq_index := 0;
--
        /*data_found := RETRIEVE_AGMT_CUSTOMER_ID( set_no,
                                                 var_agmt_customer_id,
                                                 agmt_new_customer_id,
                                                 agmt_old_customer_id );
--
        if data_found then COMMENTED for TCA audit */
--
           data_found := CHECK_FOR_DUPLICATE_INDEX( var_racm_customer_id,
                                                    var_agmt_agreement_num,
                                                    var_agmt_agreement_type );
           if data_found then
--
     <<loop_until_no_dup_index>>
--
              seq_index := seq_index + 1;
--
              if seq_index > 99 then
--
                 RAISE out_of_limit;
--
              end if;
--
              data_found := UPDATE_FOR_DUPLICATE_INDEX( var_racm_customer_id,
                                                        var_agmt_agreement_num,
                                                        var_agmt_agreement_id,
                                                        var_agmt_agreement_type,
                                                        seq_index,
                                                        duplicate_index_value ,
                                                        req_id,
                                                        var_cust_merge_header_id);/* Added for TCA audit */
              if duplicate_index_value then
--
                 goto loop_until_no_dup_index;
--
              end if;
--
           end if;
--
/* Added for TCA audit */
--
        IF pap_cmerge.g_audit_profile = 'Y' THEN
--
--  Inserts data into HZ_CUSTOMER_MERGE_LOG table for
--  PA_AGREEMENTS table and stamps agreement id with old
--  and new customer id .

           INSERT INTO hz_customer_merge_log
           (        MERGE_LOG_ID,
                    MERGE_HEADER_ID   ,
                    REQUEST_ID,
                    TABLE_NAME,
                    PRIMARY_KEY_ID,
                    NUM_COL1_ORIG,
                    NUM_COL1_NEW ,
                    ACTION_FLAG,
                    CREATED_BY,
                    CREATION_DATE ,
                    LAST_UPDATED_BY ,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN )
           VALUES(
                    HZ_CUSTOMER_MERGE_LOG_S.nextval,
                    var_cust_merge_header_id,
                    req_id,
                    'PA_AGREEMENTS',	 -- bug 3891382.
                    var_agmt_agreement_id,
                    var_agmt_customer_id,
                    var_racm_customer_id,
                    'U',
                    hz_utility_pub.CREATED_BY,
                    hz_utility_pub.CREATION_DATE,
                    hz_utility_pub.LAST_UPDATE_LOGIN,
                    hz_utility_pub.LAST_UPDATE_DATE,
                    hz_utility_pub.LAST_UPDATED_BY);
         END IF;

/*End of TCA audit*/

           UPDATE pa_agreements PA	   -- bug 3891382.
                  SET CUSTOMER_ID = var_racm_customer_id,
                      LAST_UPDATE_DATE = SYSDATE,
                      LAST_UPDATED_BY = ARP_STANDARD.PROFILE.USER_ID,
                      LAST_UPDATE_LOGIN = ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN
           WHERE
                PA.CUSTOMER_ID = var_agmt_customer_id
           AND  PA.AGREEMENT_NUM = var_agmt_agreement_num
           AND  PA.AGREEMENT_TYPE = var_agmt_agreement_type;
--
           total_record_upd_count := total_record_upd_count + SQL%ROWCOUNT;
--
        /*end if; Commented for TCA audit*/
--
--
     END LOOP;
--
     CLOSE cursor_2;
--
-- update log file to indicate the total rows updated.
--
    ARP_MESSAGE.SET_NAME( 'AR', 'AR_ROWS_UPDATED' );
    ARP_MESSAGE.SET_TOKEN( 'NUM_ROWS', TO_CHAR( total_record_upd_count ));
    total_record_upd_count := 0;
--
-- update log file to indicate successful exit of this module.
--
    ARP_MESSAGE.SET_LINE( 'PAP_CMERGE_BB2.MERGE_PA_AGREEMENTS()-' );
--
   EXCEPTION
--
      WHEN out_of_limit THEN
           ARP_MESSAGE.SET_ERROR( 'Duplicate agreement number exceeding 99' );
           ARP_MESSAGE.SET_ERROR( 'PAP_CMERGE_BB1.MERGE_PA_AGREEMENTS' );
           RAISE;
      WHEN OTHERS THEN
           ARP_MESSAGE.SET_ERROR( 'PAP_CMERGE_BB1.MERGE_PA_AGREEMENTS' );
           RAISE;
--
  END MERGE_PA_AGREEMENTS;
--
END PAP_CMERGE_BB1;

/
