--------------------------------------------------------
--  DDL for Package Body ASO_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PURGE_PVT" AS
  /* $Header: asopurgeb.pls 120.0.12010000.18 2016/10/04 21:43:14 vidsrini noship $ */
  -- Start of Comments
  -- Start of Comments
  -- Package name     : ASO_PURGE_PVT
  -- Purpose          :
  -- This is a new API to purge the ASO tables based on the parameters passed from the concurrent program 'Purge Quote'
  G_PKG_NAME CONSTANT VARCHAR2 (30):= 'ASO_PURGE_PVT';
PROCEDURE PURGE_ASO_QUOTE_DETAILS(
    errbuf OUT NOCOPY  VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_review_candidate_quotes IN VARCHAR2,
    p_dummy                   IN VARCHAR2,
    p_operating_unit          IN NUMBER,
    p_quote_expiration_days   IN NUMBER,
    p_last_update_days        IN NUMBER,
    p_istore_cart             IN VARCHAR2 )
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'PURGECC';
  l_api_version_number CONSTANT NUMBER       := 1.0;
  l_usage_exists       NUMBER;
  l_error_message      VARCHAR2(2000);
  l_return_value       NUMBER;
  l_return_status      VARCHAR2(10);
  x_msg_count          NUMBER;
  x_msg_data           VARCHAR2(2000);
  l_max_request_id     NUMBER;
  l_pos                NUMBER := 1;
  n                    NUMBER;
  t_output             VARCHAR2(2000);
  t_msg_dummy          NUMBER;
  p_msg                VARCHAR2(2000);
  v_msg                VARCHAR2(2000);
  l_purge_hook_enabled VARCHAR2(1);
  TYPE t_arr      IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
    t_cfg_id        t_arr;
    t_cfg_nbr       t_arr;
  CURSOR print_query
  IS
    SELECT org_id ,
      hou.name o_name,
      MIN(quote_expiration_date) min_qed,
      MAX(quote_expiration_date) max_qed,
      MIN(last_update_date) min_lud ,
      MAX(last_update_date) max_lud ,
      COUNT(quote_header_id) l_cnt
    FROM aso_quote_headers aqh ,
      hr_operating_units hou
    WHERE aqh.org_id     = hou.organization_id
    AND quote_header_id IN
      (SELECT quote_header_id FROM aso_purge_quotes
      )
  GROUP BY org_id,
    hou.name;
  l_min_quote_expiration_date DATE;
  l_max_quote_expiration_date DATE;
  l_min_last_update_date      DATE ;
  l_max_last_update_date      DATE ;
  CURSOR qte_header
  IS
    SELECT quote_header_id FROM ASO_PURGE_QUOTES;
 /* CURSOR del_config
  IS
    SELECT DISTINCT aqld.config_header_id ,
      aqld.config_revision_num
    FROM aso_quote_line_details aqld,
      aso_quote_lines aqla ,
      aso_purge_quotes apq
    WHERE aqld.quote_line_id = aqla.quote_line_id
    AND aqla.quote_header_id = apq.quote_header_id ; */
  CURSOR notes
  IS
    SELECT JTF_NOTE_ID
    FROM JTF_NOTES_B
    WHERE source_object_code LIKE 'ASO_QUOTE'
    AND source_object_id IN
      (SELECT quote_header_id FROM ASO_PURGE_QUOTES
      );
  CURSOR tasks
  IS
    SELECT TASK_ID,
      OBJECT_VERSION_NUMBER
    FROM JTF_TASKS_B
    WHERE source_object_type_code LIKE 'ASO_QUOTE'
    AND source_object_id IN
      (SELECT quote_header_id FROM ASO_PURGE_QUOTES
      );
  CURSOR Max_request_id
  IS
    SELECT MAX(request_id)
    FROM fnd_concurrent_requests
    WHERE status_code          = 'C'
    AND Argument1              = 'Y'
    AND concurrent_program_id IN
      (SELECT concurrent_program_id
      FROM fnd_concurrent_programs
      WHERE concurrent_program_name = 'ASOPURGE'
      AND EXECUTABLE_APPLICATION_ID = 697
      )
  ORDER BY request_id DESC ;
  CURSOR Con_param(p_con_id NUMBER)
  IS
    SELECT argument1,
      argument2,
      argument3,
      argument4,
      argument5
    FROM fnd_concurrent_requests
    WHERE request_id= p_con_id;
  la_operating_unit         NUMBER;
  la_quote_expiration_days  NUMBER;
  la_last_update_days       NUMBER;
  la_istore_cart            VARCHAR2(20);
  la_review_quote           VARCHAR2(20);
  cntmp                     NUMBER;
  rc                        NUMBER:=0;
  l_cnt                     NUMBER;
  error_code                NUMBER;
  error_msg                 VARCHAR2(2000);
  v_table_name              VARCHAR2(255) := 'aso_purge_quotes';
  l_oracle_schema           VARCHAR2(30)  := 'aso';
  use_name                  VARCHAR2(20);
  hook_purge_quote_count    NUMBER;
  ln_aso_purge_quotes_count NUMBER;
  p_review_cand_quote_mean  VARCHAR2(240);
  l_temp                    BOOLEAN;
  l_date                    VARCHAR(50);
  l_date_format             VARCHAR2(50);
  l_date_format1            VARCHAR2(50);
BEGIN
  --This is for the view output in the concurrent program
  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('ASO_PURGE_PVT : PURGECC api p_Operating_unit: '|| p_operating_unit);
    aso_debug_pub.add('ASO_PURGE_PVT : PURGECC api p_quote_expiration_days: '|| p_quote_expiration_days);
    aso_debug_pub.add('ASO_PURGE_PVT : PURGECC api p_last_update_days: '|| p_last_update_days);
    aso_debug_pub.add('ASO_PURGE_PVT : PURGECC api p_istore_cart: '|| p_istore_cart);
    aso_debug_pub.add('ASO_PURGE_PVT : PURGECC api p_review_candidate_quotes: ' || p_review_candidate_quotes);
  END IF;
  SELECT user_name
  INTO use_name
  FROM fnd_user
  WHERE user_id = FND_GLOBAL.User_Id;
  IF NOT fnd_function.test('QOT_PURGE_QUOTES') THEN
    FND_MESSAGE.SET_NAME('ASO','ASO_NO_PERMISSION_PURGE_QUOTES');
    FND_MESSAGE.SET_TOKEN('QOTUSER', use_name , true);
    P_msg := FND_MESSAGE.GET;
    Fnd_file.put_line(FND_FILE.LOG ,P_MSG); -->For View Log
    l_temp  := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
    errbuf  := P_msg;
    retcode := '2'; -->Setting the CC program status to 'Error'
    /*** Concurrent program should stop here with Status set as Error ***/
  ELSE
    aso_debug_pub.add(use_name ||' has access to the function Purge Quotes.');
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := 0;
    --Everytime set the purge_flag to null if the parameter p_review_candidate_quotes is yes
    IF upper(p_review_candidate_quotes) = 'Y' THEN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.ASO_PURGE_QUOTES';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC after the table ASO_QUOTE_PURGE is truncated ');
      END IF;
    END IF;
    BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC before calling the aso hook package p_operating_unit'|| p_operating_unit);
      END IF;
      IF upper(p_review_candidate_quotes) = 'Y' THEN
        ASO_QUOTE_HOOK.Populate_Purge_Quotes_temp(p_operating_unit,P_quote_expiration_days, P_last_update_days, P_istore_cart, p_review_candidate_quotes,l_purge_hook_enabled );
      END IF;
      SELECT COUNT(*) INTO cntmp FROM ASO_PURGE_QUOTES;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC After calling ASO_QUOTE_HOOK.Populate_Purge_Quotes_temp API: Record count :' || cntmp);
      END IF;
    EXCEPTION
    WHEN no_data_found THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC no_data_found in customer temporary table ');
      END IF;
      NULL;
    END;
    IF p_operating_unit IS NOT NULL THEN
      MO_GLOBAL.set_policy_context('S',p_operating_unit);
    END IF;
    IF upper(p_review_candidate_quotes) = 'Y' THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag     = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC before first Insert condition p_review_candidate_quotes ' || p_review_candidate_quotes);
      END IF;
      IF l_PURGE_HOOK_ENABLED         = 'Y' THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('P_PURGE_HOOK_ENABLED is Y ');
          aso_debug_pub.add('p_operating_unit '|| p_operating_unit );
          aso_debug_pub.add('User hook is enabled and data will be inserted into ASO_PURGE_QUOTES based on hook conditions' );
        END IF;
        --Insert into ASO_PURGE_QUOTES (Quote_header_id) select quote_header_id from ASO_PURGE_QUOTES_TEMP;
        SELECT COUNT(*)
        INTO Hook_Purge_quote_count
        FROM ASO_PURGE_QUOTES;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PURGE_PVT : PURGECC after First Insert condition count ' || Hook_Purge_quote_count);
        END IF;
      ELSE
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_PURGE_PVT : PURGECC before second Insert condition ');
        END IF;
        aso_debug_pub.add('p_operating_unit '|| p_operating_unit );
        IF p_istore_cart = 'Y' THEN
          aso_debug_pub.add('p_istore_cart = Y ');
          INSERT INTO ASO_PURGE_QUOTES
            (Quote_header_id
            )
          SELECT quote_header_id
          FROM aso_quote_headers
          WHERE
            --commenting as per bug 18758627 upper(substr(quote_source_code , 1, 6)) like 'ISTORE'
            (Sysdate   - NVL(QUOTE_EXPIRATION_DATE , SYSDATE + 1 )) >= NVL(p_quote_expiration_days , 0)
          AND (Sysdate - LAST_UPDATE_DATE)                          >= NVL(p_last_update_days , 0) ;
        ELSE
          aso_debug_pub.add('p_istore_cart = N ');
          INSERT INTO ASO_PURGE_QUOTES
            (Quote_header_id
            )
          SELECT quote_header_id
          FROM aso_quote_headers
          WHERE upper(SUBSTR(NVL(quote_source_code,'XXX') , 1, 6))  <> 'ISTORE'
          AND (Sysdate - NVL(QUOTE_EXPIRATION_DATE , SYSDATE + 1 )) >= NVL(p_quote_expiration_days , 0)
          AND (Sysdate - LAST_UPDATE_DATE)                          >= NVL(p_last_update_days , 0) ;
        END IF;
      END IF;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC after second Insert condition count ' || SQL%ROWCOUNT);
      END IF;
    END IF;
    BEGIN
      SELECT COUNT(*) INTO LN_ASO_PURGE_QUOTES_COUNT FROM ASO_PURGE_QUOTES ;
    EXCEPTION
    WHEN no_data_found THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC no_data_found in ASO_PURGE_QUOTES ');
      END IF;
      NULL;
    END;
    IF p_review_candidate_quotes = 'Y' THEN
      p_review_cand_quote_Mean  := 'Yes';
    ELSE
      p_review_cand_quote_Mean := 'No';
    END IF;
    l_date_format := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
    l_date_format := l_date_format ||' HH24:MI:SS';
    /*** For View output in concurrent program ***/
    SELECT TO_CHAR(sysdate, l_date_format)
    INTO l_date
    FROM DUAL;
    /*** For View output in concurrent program ***/
    Fnd_file.put_line(FND_FILE.OUTPUT, 'Date: '|| l_date);
    fnd_file.new_line(FND_FILE.OUTPUT,2);
    Fnd_file.put_line(FND_FILE.OUTPUT , 'Parameters');
    Fnd_file.put_line(FND_FILE.OUTPUT,'Review Candidate Quotes to be Purged: ' || p_review_cand_quote_Mean);
    Fnd_file.put_line(FND_FILE.OUTPUT,'Operating Unit: '|| p_operating_unit);
    Fnd_file.put_line(FND_FILE.OUTPUT,'Number of Days after Quote Expiration Date: '|| p_quote_expiration_days );
    Fnd_file.put_line(FND_FILE.OUTPUT,'Number of Days after the Last Update Date: '||p_last_update_days );
    Fnd_file.put_line(FND_FILE.OUTPUT,'iStore Carts: '|| p_istore_cart);
    Fnd_file.new_line(FND_FILE.OUTPUT,1);
    Fnd_file.put_line(FND_FILE.OUTPUT,'Quote Summary');
    IF (UPPER(p_review_candidate_quotes) = 'Y') THEN
      IF LN_ASO_PURGE_QUOTES_COUNT       = 0 THEN
        Fnd_file.put_line(FND_FILE.OUTPUT ,'Number of quotes to be purged: 0');
      END IF;
      l_date_format1 := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');
      FOR i IN print_query
      LOOP
        Fnd_file.put_line(FND_FILE.OUTPUT ,'Expiration Date: '|| TO_CHAR(i. min_qed , l_date_format1) || ' To ' || TO_CHAR(i.max_qed, l_date_format1) );
        Fnd_file.put_line(FND_FILE.OUTPUT ,'Last Update Date: '|| TO_CHAR(i.min_lud , l_date_format1) || ' To ' || TO_CHAR(i.max_lud , l_date_format1));
        Fnd_file.put_line(FND_FILE.OUTPUT ,'Number of quotes to be purged: '||i.l_cnt);
        Fnd_file.new_line(FND_FILE.OUTPUT,1);
      END LOOP;
    Elsif (UPPER(p_review_candidate_quotes) = 'N') THEN
      Fnd_file.put_line(FND_FILE.OUTPUT ,'Number of quotes purged: '||LN_ASO_PURGE_QUOTES_COUNT);
    END IF;
    BEGIN
      fnd_file.put_line(FND_FILE.LOG ,'*****************Processing of Asopurge Program Concurrent log begins  *******************' );
      IF UPPER(p_review_candidate_quotes) = 'Y' THEN
        Fnd_file.put_line(FND_FILE.LOG , 'Date: '|| l_date);
        Fnd_file.put_line(FND_FILE.LOG ,'Review Candidate Quotes to be Purged: ' || p_review_cand_quote_Mean);
        Fnd_file.put_line(FND_FILE.LOG ,'Operating Unit: '|| p_operating_unit);
        Fnd_file.put_line(FND_FILE.LOG ,'Number of Days after Quote Expiration Date: '|| p_quote_expiration_days );
        Fnd_file.put_line(FND_FILE.LOG ,'Number of Days after the Last Update Date: '||p_last_update_days );
        Fnd_file.put_line(FND_FILE.LOG ,'iStore Carts: '|| p_istore_cart);
        Fnd_file.put_line(FND_FILE.LOG ,'User Hook Enabled: '||l_PURGE_HOOK_ENABLED);
      Elsif UPPER(p_review_candidate_quotes) = 'N' THEN
        OPEN Max_request_id;
        FETCH Max_request_id INTO l_Max_request_id;
        CLOSE Max_request_id;
        OPEN Con_param(l_Max_request_id);
        FETCH Con_param
        INTO la_review_quote,
		     la_istore_cart ,
          la_operating_unit,
          la_quote_expiration_days,
          la_last_update_days ;

        IF la_review_quote          = 'Y' THEN
          p_review_cand_quote_Mean := 'Yes';
        ELSE
          p_review_cand_quote_Mean := 'No';
        END IF;
        Fnd_file.put_line(FND_FILE.LOG ,'Date: '|| l_date);
        Fnd_file.put_line(FND_FILE.LOG ,'Review Candidate Quotes to be Purged: ' || p_review_cand_quote_Mean);
        Fnd_file.put_line(FND_FILE.LOG ,'Operating Unit: '|| la_operating_unit);
        Fnd_file.put_line(FND_FILE.LOG ,'Number of Days after Quote Expiration Date: '|| la_quote_expiration_days );
        Fnd_file.put_line(FND_FILE.LOG ,'Number of Days after the Last Update Date: '||la_last_update_days );
        Fnd_file.put_line(FND_FILE.LOG ,'iStore Carts: '|| la_istore_cart);
        Fnd_file.put_line(FND_FILE.LOG ,'User Hook Enabled: '||l_PURGE_HOOK_ENABLED);
        CLOSE Con_param;
      END IF;
    END;
    BEGIN
      aso_debug_pub.add('*****************Processing of Asopurge Program Concurrent log begins  *******************');
      FOR i IN print_query
      LOOP
        aso_debug_pub.add('Date: '|| CURRENT_TIMESTAMP);
        aso_debug_pub.add('Operating Unit: '|| i.o_name || '(' || i.org_id || ')' );
        aso_debug_pub.add('Expiration Date: '|| TO_CHAR(i. min_qed ,l_date_format1) || ' To ' || TO_CHAR(i.max_qed ,l_date_format1));
        aso_debug_pub.add('Last Update Date: '|| TO_CHAR(i.min_lud ,l_date_format1) || ' To ' || TO_CHAR(i.max_lud , l_date_format1) );--l_cnt
        IF UPPER(p_review_candidate_quotes) = 'Y' THEN
          aso_debug_pub.add('Number of quotes to be purged: '||SQL%ROWCOUNT );
        Elsif UPPER(p_review_candidate_quotes) = 'N' THEN
          aso_debug_pub.add('Number of quotes purged: '|| i.l_cnt);
        END IF;
        aso_debug_pub.add('User Hook Enabled: '||l_PURGE_HOOK_ENABLED);
      END LOOP;
    END;
    aso_debug_pub.add('LN_ASO_PURGE_QUOTES_COUNT: '||LN_ASO_PURGE_QUOTES_COUNT);
    --Delete tables
    IF (lower(p_review_candidate_quotes) LIKE 'n' ) AND (LN_ASO_PURGE_QUOTES_COUNT > 0 ) THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag                                                = 'Y' THEN
        aso_debug_pub.add('Before Purging the tables');
      END IF;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_APR_APPROVAL_DETAILS');
        DELETE
        FROM ASO_APR_APPROVAL_DETAILS
        WHERE object_approval_id IN
          (SELECT object_approval_id
          FROM ASO_APR_OBJ_APPROVALS
          WHERE object_id IN
            (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
            )
          );
        --aso_debug_pub.add('Number of records deleted in ASO_APR_APPROVAL_DETAILS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_APR_APPROVAL_DETAILS is: '|| SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_APR_APPROVAL_DETAILS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_APR_APPROVAL_DETAILS rows so Rollback');
        ROLLBACK;
      END;
      --bug20287129 moving the delete of table ASO_APR_OBJ_APPROVALS after deleting ASO_APR_APPROVAL_DETAILS
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_APR_OBJ_APPROVALS');
        DELETE
        FROM ASO_APR_OBJ_APPROVALS
        WHERE object_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        --aso_debug_pub.add('Number of records deleted in ASO_APR_OBJ_APPROVALS is: ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_APR_OBJ_APPROVALS is: '|| SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_APR_OBJ_APPROVALS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_APR_OBJ_APPROVALS rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_CHANGED_QUOTES');
        DELETE
        FROM ASO_CHANGED_QUOTES
        WHERE quote_number IN
          (SELECT quote_number
          FROM aso_quote_headers
          WHERE quote_header_id IN
            (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
            )
          ) ;
        -- aso_debug_pub.add('Number of records deleted in ASO_CHANGED_QUOTES is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_CHANGED_QUOTES is: '|| SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_CHANGED_QUOTES table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_CHANGED_QUOTES rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_FREIGHT_CHARGES');
        DELETE
        FROM ASO_FREIGHT_CHARGES
        WHERE quote_shipment_id IN
          (SELECT shipment_id
          FROM ASO_SHIPMENTS
          WHERE quote_header_id IN
            (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
            )
          );
        -- aso_debug_pub.add('Number of records deleted in ASO_FREIGHT_CHARGES is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_FREIGHT_CHARGES is: '||SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_FREIGHT_CHARGES table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_FREIGHT_CHARGES rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_SHIPMENTS');
        DELETE
        FROM ASO_SHIPMENTS
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        --aso_debug_pub.add('Number of records deleted in ASO_SHIPMENTS is: ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_SHIPMENTS is: '||SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_SHIPMENTS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete  ASO_SHIPMENTS rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_HEADER_RELATIONSHIPS');
        DELETE
        FROM ASO_HEADER_RELATIONSHIPS
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        --aso_debug_pub.add('Number of records deleted in ASO_HEADER_RELATIONSHIPS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_HEADER_RELATIONSHIPS is: '|| SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_HEADER_RELATIONSHIPS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete  ASO_HEADER_RELATIONSHIPS rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_PARTY_RELATIONSHIPS');
        DELETE
        FROM ASO_PARTY_RELATIONSHIPS
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        --aso_debug_pub.add('Number of records deleted in ASO_PARTY_RELATIONSHIPS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_PARTY_RELATIONSHIPS is: '|| SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_PARTY_RELATIONSHIPS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete  ASO_PARTY_RELATIONSHIPS rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_PAYMENTS');
        DELETE
        FROM ASO_PAYMENTS
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        -- aso_debug_pub.add('Number of records deleted in ASO_PAYMENTS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_PAYMENTS is: '|| SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_PAYMENTS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_PAYMENTS  rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_PRICE_ADJ_ATTRIBS');
        DELETE
        FROM ASO_PRICE_ADJ_ATTRIBS
        WHERE price_adjustment_id IN
          (SELECT price_adjustment_id
          FROM ASO_PRICE_ADJUSTMENTS
          WHERE quote_header_id IN
            (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
            )
          );
        --  aso_debug_pub.add('Number of records deleted in ASO_PRICE_ADJ_ATTRIBS is: ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_PRICE_ADJ_ATTRIBS is: '|| SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_PRICE_ADJ_ATTRIBS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete  ASO_PRICE_ADJ_ATTRIBS rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_PRICE_ADJ_RELATIONSHIPS');
        DELETE
        FROM ASO_PRICE_ADJ_RELATIONSHIPS
        WHERE price_adjustment_id IN
          (SELECT price_adjustment_id
          FROM ASO_PRICE_ADJUSTMENTS
          WHERE quote_header_id IN
            (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
            )
          );
        -- aso_debug_pub.add('Number of records deleted in ASO_PRICE_ADJ_RELATIONSHIPS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_PRICE_ADJ_RELATIONSHIPS is: ' || SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_PRICE_ADJ_RELATIONSHIPS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete  ASO_PRICE_ADJ_RELATIONSHIPS rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_PRICE_ADJUSTMENTS');
        DELETE
        FROM ASO_PRICE_ADJUSTMENTS
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        --aso_debug_pub.add('Number of records deleted in ASO_PRICE_ADJUSTMENTS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_PRICE_ADJUSTMENTS is: ' || SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_PRICE_ADJUSTMENTS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_PRICE_ADJUSTMENTS rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_PRICE_ATTRIBUTES');
        DELETE
        FROM ASO_PRICE_ATTRIBUTES
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        -- aso_debug_pub.add('Number of records deleted in ASO_PRICE_ATTRIBUTES is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_PRICE_ATTRIBUTES is: ' || SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_PRICE_ATTRIBUTES table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_PRICE_ATTRIBUTES  rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_QUOTE_ACCESSES');
        --bug20287129
        DELETE
        FROM ASO_QUOTE_ACCESSES
        WHERE quote_number IN
          (SELECT quote_number
          FROM aso_quote_headers
          WHERE quote_header_id IN
            (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
            )
          ) ;
        --aso_debug_pub.add('Number of records deleted in ASO_QUOTE_ACCESSES is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_QUOTE_ACCESSES is: ' || SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_QUOTE_ACCESSES table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_QUOTE_ACCESSES  rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_QUOTE_LINE_ATTRIBS_EXT');
        DELETE
        FROM ASO_QUOTE_LINE_ATTRIBS_EXT
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        -- aso_debug_pub.add('Number of records deleted in ASO_QUOTE_LINE_ATTRIBS_EXT is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_QUOTE_LINE_ATTRIBS_EXT is: ' || SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_QUOTE_LINE_ATTRIBS_EXT table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_QUOTE_LINE_ATTRIBS_EXT rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_LINE_RELATIONSHIPS');
        DELETE
        FROM ASO_LINE_RELATIONSHIPS
        WHERE quote_line_id IN
          (SELECT quote_line_id
          FROM aso_quote_lines
          WHERE quote_header_id IN
            (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
            )
          );
        -- aso_debug_pub.add('Number of records deleted in ASO_LINE_RELATIONSHIPS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_LINE_RELATIONSHIPS is ' || SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_LINE_RELATIONSHIPS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_LINE_RELATIONSHIPS  rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_QUOTE_PARTIES');
        DELETE
        FROM ASO_QUOTE_PARTIES
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        --  aso_debug_pub.add('Number of records deleted in ASO_QUOTE_PARTIES is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_QUOTE_PARTIES is ' || SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_QUOTE_PARTIES table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_QUOTE_PARTIES  rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_SALES_CREDITS');
        DELETE
        FROM ASO_SALES_CREDITS
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        --aso_debug_pub.add('Number of records deleted in ASO_SALES_CREDITS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_SALES_CREDITS is: ' || SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_SALES_CREDITS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_SALES_CREDITS rows so Rollback');
        ROLLBACK;
      END;


	   Begin
   aso_debug_pub.add('Before Purging the table ASO_QUOTE_RELATED_OBJECTS');
  DELETE
FROM ASO_QUOTE_RELATED_OBJECTS
WHERE QUOTE_OBJECT_ID IN
  (SELECT
    /*+ cardinality(ASO_PURGE_QUOTES,1) */
    QUOTE_HEADER_ID
  FROM ASO_PURGE_QUOTES
  );
     Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_QUOTE_RELATED_OBJECTS is: ' || SQL%ROWCOUNT );
     EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_QUOTE_RELATED_OBJECTS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_QUOTE_RELATED_OBJECTS rows so Rollback');
        ROLLBACK;
   End;

      Begin
   aso_debug_pub.add('Before Purging the table ASO_TAX_DETAILS ');

  DELETE
FROM ASO_TAX_DETAILS
WHERE QUOTE_HEADER_ID IN
  (SELECT
    /*+ cardinality(ASO_PURGE_QUOTES,1) */
    QUOTE_HEADER_ID
  FROM ASO_PURGE_QUOTES
  );
     Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_TAX_DETAILS  is: ' || SQL%ROWCOUNT );
     EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_TAX_DETAILS  table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_TAX_DETAILS  rows so Rollback');
        ROLLBACK;
   End;

   BEGIN
      aso_debug_pub.add('Before Purging the table ASO_SUP_INSTANCE_VALUE ');
        DELETE
FROM ASO_SUP_INSTANCE_VALUE where template_instance_id =  (Select template_instance_id from  ASO_SUP_TMPL_INSTANCE
WHERE owner_table_id  IN
  (SELECT
    /*+ cardinality(ASO_PURGE_QUOTES,1) */
    QUOTE_HEADER_ID
  FROM ASO_PURGE_QUOTES
  ) and ASO_SUP_TMPL_INSTANCE.owner_table_name = 'ASO_QUOTE_HEADERS');
     Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_SUP_INSTANCE_VALUE  is: ' || SQL%ROWCOUNT );
     EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_SUP_INSTANCE_VALUE  table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_SUP_INSTANCE_VALUE rows so Rollback');
        ROLLBACK;
   End;


   BEGIN
   aso_debug_pub.add('Before Purging the table ASO_SUP_TMPL_INSTANCE  ');
     DELETE
FROM ASO_SUP_TMPL_INSTANCE
WHERE  owner_table_name = 'ASO_QUOTE_HEADERS' AND owner_table_id  IN
  (SELECT
    /*+ cardinality(ASO_PURGE_QUOTES,1) */
    QUOTE_HEADER_ID
  FROM ASO_PURGE_QUOTES
  );
     Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_SUP_TMPL_INSTANCE is: ' || SQL%ROWCOUNT );
     EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_SUP_TMPL_INSTANCE  table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_SUP_TMPL_INSTANCE rows so Rollback');
        ROLLBACK;
   End;

 --Start Bug 20474788
   Begin
    aso_debug_pub.add('Before Purging the table IBE_ACTIVE_QUOTES_ALL');

    Delete from IBE_ACTIVE_QUOTES_ALL where quote_header_id IN (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES);
    Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in IBE_ACTIVE_QUOTES_ALL is: ' || SQL%ROWCOUNT );

EXCEPTION
    WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete IBE_ACTIVE_QUOTES_ALL  table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete IBE_ACTIVE_QUOTES_ALL  rows so Rollback');
        ROLLBACK;
End;

Begin
    aso_debug_pub.add('Before Purging the table IBE_SH_QUOTE_ACCESS');
    Delete from IBE_SH_QUOTE_ACCESS where quote_header_id IN (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES);
    Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in IBE_SH_QUOTE_ACCESS   is: ' || SQL%ROWCOUNT );
EXCEPTION
    WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete IBE_SH_QUOTE_ACCESS   table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete IBE_SH_QUOTE_ACCESS   rows so Rollback');
        ROLLBACK;
End;
--End Bug Bug 20474788
 Begin

    SELECT /*+ cardinality(APQ,1) */ aqld.config_header_id ,
      aqld.config_revision_num
     BULK COLLECT INTO t_cfg_id,t_cfg_nbr
      FROM aso_quote_line_details aqld,
      aso_quote_lines aqla ,
      aso_purge_quotes apq
    WHERE aqld.quote_line_id = aqla.quote_line_id
    AND aqla.quote_header_id = apq.quote_header_id ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      Fnd_file.put_line(FND_FILE.LOG,'No Records fetched for CZ Purge');
     null;
  END;
         IF (t_cfg_id.COUNT > 0) THEN
      FOR i IN t_cfg_id.FIRST..t_cfg_id.LAST LOOP
      Fnd_file.put_line(FND_FILE.LOG,'Before calling cz_cf_api.delete_configuration for config_header_id = '||t_cfg_id(i)|| ' config_revision_num = '||t_cfg_nbr(i));
	  Begin
        cz_cf_api.delete_configuration (
          t_cfg_id(i),
          t_cfg_nbr(i),
          l_usage_exists,
          l_error_message,
          l_Return_value
        );
		Exception
	When others then
	Fnd_file.put_line(FND_FILE.LOG ,t_cfg_id(i)); -->For View Log
	end;
        IF (l_Return_value <> 1) THEN
        Fnd_file.put_line(FND_FILE.LOG,'After calling cz_cf_api.delete_configuration l_Return_value ' || l_Return_value);
             FND_MESSAGE.Set_Name('ASO', 'ASO_CZ_DELETE_ERR');
              FND_MESSAGE.Set_token('MSG_TXT' , l_error_message,FALSE);
              P_msg := FND_MESSAGE.GET;
              Fnd_file.put_line(FND_FILE.LOG ,P_MSG); -->For View Log
        END IF;
      END LOOP;
    END IF;


      BEGIN
        aso_debug_pub.add('Before Purging the fnd_attachments Table');
        --To delete fnd_attachments
        FOR i IN qte_header
        LOOP
          fnd_attached_documents2_pkg.delete_attachments (
		  x_entity_name => 'ASO_QUOTE_HEADERS_ALL',
		  x_pk1_value => i.quote_header_id,
		  x_pk2_value => NULL, x_pk3_value => NULL,
		  x_pk4_value => NULL, x_pk5_value => NULL,
		  x_delete_document_flag => 'Y',
		  x_automatically_added_flag => 'N' );
        END LOOP;
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete fnd_attachments table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete fnd_attachments rows so Rollback');
        ROLLBACK;
      END;
      --aso_debug_pub.add('Number of records deleted in fnd_attachments Table is ' || SQL%ROWCOUNT );
      Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in fnd_attachments Table is ' || SQL%ROWCOUNT );
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_QUOTE_LINE_DETAILS');
        DELETE
        FROM ASO_QUOTE_LINE_DETAILS
        WHERE quote_line_id IN
          (SELECT quote_line_id
          FROM aso_quote_lines
          WHERE quote_header_id IN
           (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          ));
        -- aso_debug_pub.add('Number of records deleted in ASO_QUOTE_LINE_DETAILS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_QUOTE_LINE_DETAILS is ' || SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_QUOTE_LINE_DETAILS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_QUOTE_LINE_DETAILS  rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_QUOTE_LINES');
        DELETE
        FROM ASO_QUOTE_LINES
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          );
        -- aso_debug_pub.add('Number of records deleted in ASO_QUOTE_LINES_ALL is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_QUOTE_LINES_ALL is: ' || SQL%ROWCOUNT);
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_QUOTE_LINES table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_QUOTE_LINES rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the table ASO_QUOTE_HEADERS');
        DELETE
        FROM ASO_QUOTE_HEADERS
        WHERE quote_header_id IN
          (SELECT /*+ cardinality(ASO_PURGE_QUOTES,1) */ QUOTE_HEADER_ID FROM ASO_PURGE_QUOTES
          ) ;
        -- aso_debug_pub.add('Number of records deleted in ASO_QUOTE_HEADERS is ' || SQL%ROWCOUNT );
        Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in ASO_QUOTE_HEADERS is ' || SQL%ROWCOUNT );
      EXCEPTION
      WHEN OTHERS THEN
        Error_code := SQLCODE;
        Error_msg  := SUBSTR(SQLERRM, 1, 200);
        aso_debug_pub.add ('Exception raised in delete ASO_QUOTE_HEADERS table : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
        aso_debug_pub.add('Exception: Unable to delete ASO_QUOTE_HEADERS  rows so Rollback');
        ROLLBACK;
      END;
      BEGIN
        aso_debug_pub.add('Before Purging the Notes Table');
        --To delete Notes
        FOR i IN notes
        LOOP
          jtf_notes_pub.secure_delete_note( p_api_version => 1.0 , x_return_status => l_return_status , x_msg_count => x_msg_count , x_msg_data => x_msg_data , p_jtf_note_id => i.jtf_note_id , p_use_AOL_security => fnd_api.g_false );
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_msg_count      := fnd_msg_pub.count_msg;
            FOR j IN 1 .. fnd_msg_pub.count_msg
            LOOP
              fnd_msg_pub.get ( j , FND_API.G_FALSE , x_msg_data , t_msg_dummy );
              t_output                             := ( 'Msg' || TO_CHAR ( j ) || ': ' || x_msg_data );
              l_pos                                :=0;
              WHILE (LENGTH(x_msg_data) - l_pos + 1 > 255)
              LOOP
                aso_debug_pub.add(SUBSTR(x_msg_data, l_pos, 255));
                l_pos := l_pos + 255;
              END LOOP;
              aso_debug_pub.add(SUBSTR(x_msg_data, l_pos));
            END LOOP;
            ROLLBACK;
          END IF;
        END LOOP;
      END;
      --aso_debug_pub.add('Number of records deleted in Notes Table is ' || SQL%ROWCOUNT );
      Fnd_file.put_line(FND_FILE.LOG,'Number of records deleted in Notes Table is ' || SQL%ROWCOUNT );
      BEGIN
        aso_debug_pub.add('Before Purging the Tasks Table');
        --To delete Tasks
        FOR i IN tasks
        LOOP
		Begin
          jtf_tasks_pub.delete_task( p_api_version => 1.0 ,x_return_status => l_return_status ,x_msg_count => x_msg_count , x_msg_data => x_msg_data , p_task_id => i.task_id , p_object_version_number => i.object_version_number );
		  Exception
	        When others then
			Fnd_file.put_line(FND_FILE.LOG ,x_msg_data); -->For View Log
			end;
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            x_msg_count      := fnd_msg_pub.count_msg;
            FOR j IN 1 .. fnd_msg_pub.count_msg
            LOOP
              fnd_msg_pub.get ( j , FND_API.G_FALSE , x_msg_data , t_msg_dummy );
              t_output                             := ( 'Msg' || TO_CHAR ( j ) || ': ' || x_msg_data );
              l_pos                                :=0;
              WHILE (LENGTH(x_msg_data) - l_pos + 1 > 255)
              LOOP
                aso_debug_pub.add(SUBSTR(x_msg_data, l_pos, 255));
                l_pos := l_pos + 255;
              END LOOP;
              aso_debug_pub.add(SUBSTR(x_msg_data, l_pos));
            END LOOP;
            ROLLBACK;
          END IF;
        END LOOP;
      END;
      EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_oracle_schema||'.ASO_PURGE_QUOTES';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_PURGE_PVT : PURGECC Review Candidate as "N" -- After ASO tables are purged then ASO_PURGE_QUOTES table is truncated ');
      END IF;
    END IF;
  END IF;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  Error_code := SQLCODE;
  Error_msg  := SUBSTR(SQLERRM, 1, 200);
  aso_debug_pub.add ('Exception raised in Main Procedure  : Error Code:  '||Error_code||' Error Msg  '|| Error_msg );
  aso_debug_pub.add('In others exception ');
  ROLLBACK;
END PURGE_ASO_QUOTE_DETAILS;
END;


/
