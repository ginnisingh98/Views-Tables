--------------------------------------------------------
--  DDL for Package Body GMA_COMMON_LOGGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_COMMON_LOGGING" as
/*$Header: GMAMCLB.pls 120.11 2006/10/05 20:54:59 txdaniel noship $*/
Procedure Gma_Migration_CentraL_Log(
                       P_Run_Id         VARCHAR2,
                       P_log_level      VARCHAR2,
                       P_App_short_name VARCHAR2,
                       P_Message_Token  VARCHAR2,
                       P_context	VARCHAR2,
                       P_Table_Name     VARCHAR2,
                       P_Param1         VARCHAR2,
                       P_Param2         VARCHAR2,
                       P_Param3         VARCHAR2,
                       P_Param4         VARCHAR2,
                       P_Param5         VARCHAR2,
                       P_Db_Error       VARCHAR2,
                       P_Token1         VARCHAR2,
                       P_Token2         VARCHAR2,
                       P_Token3         VARCHAR2,
                       P_Token4         VARCHAR2,
                       P_Token5         VARCHAR2,
                       P_Param6				  VARCHAR2,
                       P_Token6         VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
  l_log_level      VARCHAR2(4000);
  l_app_short_name VARCHAR2(40);
  l_table_name     VARCHAR2(200);
  l_param1         VARCHAR2(2000);
  l_token1         VARCHAR2(80);
  l_param2         VARCHAR2(2000);
  l_token2         VARCHAR2(80);
  l_param3         VARCHAR2(2000);
  l_token3         VARCHAR2(80);
  l_param4         VARCHAR2(2000);
  l_token4         VARCHAR2(80);
  l_param5         VARCHAR2(2000);
  l_token5         VARCHAR2(80);
  l_param6         VARCHAR2(2000);
  l_token6         VARCHAR2(80);
  l_message_token  VARCHAR2(200);
  l_db_error       VARCHAR2(2000);
  l_message_type   VARCHAR2(1);
BEGIN

  if P_Message_Token IN ('GMA_MIGRATION_FAIL',
                         'GMA_MIGRATION_TABLE_FAIL') then
     l_log_level:=FND_LOG.LEVEL_ERROR;
     l_app_short_name := 'GMA';
     IF p_message_token = 'GMA_MIGRATION_TABLE_FAIL' THEN
       l_table_name := p_table_name;
     END IF;
  elsif P_Message_Token IN ('GMA_MIGRATION_DB_ERROR') then
     l_log_level:=FND_LOG.LEVEL_UNEXPECTED;
     l_app_short_name := 'GMA';
  elsif P_Message_Token IN ('GMA_MIGRATION_STARTED',
                            'GMA_MIGRATION_COMPLETED',
                            'GMA_MIGRATION_TABLE_STARTED') then
     l_log_level:=FND_LOG.LEVEL_EVENT;
     l_app_short_name := 'GMA';
     IF p_message_token = 'GMA_MIGRATION_TABLE_STARTED' THEN
       l_table_name := p_table_name;
     END IF;
  elsif P_Message_Token IN ('GMA_MIGRATION_TABLE_SUCCESS', 'GMA_MIGRATION_TABLE_SUCCESS_RW') then
     l_log_level:=FND_LOG.LEVEL_PROCEDURE;
     l_app_short_name := 'GMA';
     l_table_name := p_table_name;
  else
     l_log_level:=P_log_level;
     l_app_short_name := p_app_short_name;
  end if;

  IF (l_log_level = FND_LOG.LEVEL_UNEXPECTED) THEN
    l_message_token := 'GMD_UNEXPECTED_ERROR';
    l_app_short_name := 'GMD';
    l_token1 := 'ERROR';
    l_db_error := SUBSTR(p_db_error, 1,2000);
  ELSE
    l_message_token := p_message_token;
    l_db_error := NULL;
  END IF;

  IF l_table_name IS NOT NULL THEN
    l_token1 := 'TABLE_NAME';
    l_param1 := l_table_name;
    IF P_param1 IS NOT NULL THEN
      l_token2 := NVL(P_token1, 'SUCCESS');
      l_param2 := P_param1;
    END IF;
    IF P_param2 IS NOT NULL THEN
      l_token3 := NVL(P_token2, 'FAILURE');
      l_param3 := P_param2;
    END IF;
  ELSE
    IF P_param1 IS NOT NULL THEN
      l_token1 := NVL(P_token1, 'PARAM1');
      l_param1 := P_param1;
    END IF;

    IF P_param2 IS NOT NULL THEN
      l_token2 := NVL(P_token2, 'PARAM2');
      l_param2 := P_param2;
    END IF;

    IF P_param3 IS NOT NULL THEN
      l_token3 := NVL(P_token3, 'PARAM3');
      l_param3 := P_param3;
    END IF;

    IF P_param4 IS NOT NULL THEN
      l_token4 := NVL(P_token4, 'PARAM4');
      l_param4 := P_param4;
    END IF;

    IF P_param5 IS NOT NULL THEN
      l_token5 := NVL(P_token5, 'PARAM5');
      l_param5 := P_param5;
    END IF;

    IF P_param6 IS NOT NULL THEN
      l_token6 := NVL(P_token6, 'PARAM6');
      l_param6 := P_param6;
    END IF;
  END IF;

  IF l_log_level = 1 THEN
    l_message_type := 'I';
  ELSIF l_log_level IN (2,3) THEN
    l_message_type := 'P';
  ELSIF l_log_level IN (4,5) THEN
    l_message_type := 'E';
  ELSIF l_log_level = 6 THEN
    l_message_type := 'D';
  END IF;

  INSERT INTO GMA_MIGRATION_LOG (TABLE_NAME, LINE_NO, RUN_ID, MSG_APP_SHORT_NAME, MESSAGE_TOKEN,
                                 MESSAGE_TYPE, TOKEN1, TOKEN2, TOKEN3, TOKEN4, TOKEN5, TOKEN6,
                                 PARAM1, PARAM2, PARAM3, PARAM4, PARAM5, PARAM6,
                                 DB_ERROR, TIMESTAMP, CONTEXT)
  VALUES (p_table_name, gma_upgrade_id_s.nextval, p_run_id, l_app_short_name, l_message_token,l_message_type,
          l_token1, l_token2, l_token3, l_token4, l_token5, l_token6,
          l_param1, l_param2, l_param3, l_param4, l_param5, l_param6,
          l_db_error, SYSDATE, p_context);

  COMMIT;

End Gma_Migration_CentraL_Log;

END GMA_COMMON_LOGGING;

/
