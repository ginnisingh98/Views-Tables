--------------------------------------------------------
--  DDL for Package Body XLA_XLAABACR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_XLAABACR_XMLP_PKG" AS
/* $Header: XLAABACRB.pls 120.0 2007/12/27 08:44:44 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_AAD1 IS
      SELECT
        PRB.APPLICATION_ID,
        PRB.AMB_CONTEXT_CODE,
        PRB.PRODUCT_RULE_TYPE_CODE,
        PRB.PRODUCT_RULE_CODE
      FROM
        XLA_PRODUCT_RULES_B PRB
      WHERE PRB.COMPILE_STATUS_CODE in ( 'E' , 'N' , DECODE(P_UNCOMPILE_ONLY_FLAG
            ,'N'
            ,'Y'
            ,'') )
        AND PRB.PRODUCT_RULE_TYPE_CODE = NVL(P_PRODUCT_RULE_TYPE_CODE
         ,PRB.PRODUCT_RULE_TYPE_CODE)
        AND PRB.AMB_CONTEXT_CODE = NVL(FND_PROFILE.VALUE('XLA_AMB_CONTEXT')
         ,'DEFAULT');
    CURSOR C_AAD2 IS
      SELECT
        PRB.APPLICATION_ID,
        PRB.AMB_CONTEXT_CODE,
        PRB.PRODUCT_RULE_TYPE_CODE,
        PRB.PRODUCT_RULE_CODE
      FROM
        XLA_PRODUCT_RULES_B PRB
      WHERE PRB.COMPILE_STATUS_CODE in ( 'E' , 'N' , DECODE(P_UNCOMPILE_ONLY_FLAG
            ,'N'
            ,'Y'
            ,'') )
        AND PRB.PRODUCT_RULE_TYPE_CODE = NVL(P_PRODUCT_RULE_TYPE_CODE
         ,PRB.PRODUCT_RULE_TYPE_CODE)
        AND PRB.APPLICATION_ID = P_APPLICATION_ID
        AND PRB.AMB_CONTEXT_CODE = NVL(FND_PROFILE.VALUE('XLA_AMB_CONTEXT')
         ,'DEFAULT');
    CURSOR C_AAD3 IS
      SELECT
        PRB.APPLICATION_ID,
        PRB.AMB_CONTEXT_CODE,
        PRB.PRODUCT_RULE_TYPE_CODE,
        PRB.PRODUCT_RULE_CODE
      FROM
        XLA_PRODUCT_RULES_B PRB
      WHERE PRB.COMPILE_STATUS_CODE in ( 'E' , 'N' , DECODE(P_UNCOMPILE_ONLY_FLAG
            ,'N'
            ,'Y'
            ,'') )
        AND PRB.PRODUCT_RULE_TYPE_CODE = NVL(P_PRODUCT_RULE_TYPE_CODE
         ,PRB.PRODUCT_RULE_TYPE_CODE)
        AND PRB.APPLICATION_ID = P_APPLICATION_ID
        AND PRB.PRODUCT_RULE_CODE = P_PRODUCT_RULE_CODE
        AND PRB.AMB_CONTEXT_CODE = NVL(FND_PROFILE.VALUE('XLA_AMB_CONTEXT')
         ,'DEFAULT');
    CURSOR C_AAD4 IS
      SELECT
        PRB.APPLICATION_ID,
        PRB.AMB_CONTEXT_CODE,
        PRB.PRODUCT_RULE_TYPE_CODE,
        PRB.PRODUCT_RULE_CODE
      FROM
        XLA_PRODUCT_RULES_B PRB,
        XLA_GL_LEDGERS_V LE,
        XLA_ACCTG_METHOD_RULES AMR,
        XLA_LEDGER_RELATIONSHIPS_V LR
      WHERE PRB.PRODUCT_RULE_TYPE_CODE = AMR.PRODUCT_RULE_TYPE_CODE
        AND PRB.PRODUCT_RULE_CODE = AMR.PRODUCT_RULE_CODE
        AND PRB.APPLICATION_ID = AMR.APPLICATION_ID
        AND AMR.ACCOUNTING_METHOD_TYPE_CODE = LE.SLA_ACCOUNTING_METHOD_TYPE
        AND AMR.ACCOUNTING_METHOD_CODE = LE.SLA_ACCOUNTING_METHOD_CODE
        AND LE.LEDGER_ID = LR.LEDGER_ID
        AND LR.PRIMARY_LEDGER_ID = P_LEDGER_ID
        AND PRB.COMPILE_STATUS_CODE in ( 'E' , 'N' , DECODE(P_UNCOMPILE_ONLY_FLAG
            ,'N'
            ,'Y'
            ,'') )
        AND PRB.PRODUCT_RULE_TYPE_CODE = NVL(P_PRODUCT_RULE_TYPE_CODE
         ,PRB.PRODUCT_RULE_TYPE_CODE)
        AND PRB.APPLICATION_ID = NVL(P_APPLICATION_ID
         ,PRB.APPLICATION_ID)
        AND PRB.AMB_CONTEXT_CODE = NVL(FND_PROFILE.VALUE('XLA_AMB_CONTEXT')
         ,'DEFAULT');
    CURSOR C_AAD5 IS
      SELECT
        PRB.APPLICATION_ID,
        PRB.AMB_CONTEXT_CODE,
        PRB.PRODUCT_RULE_TYPE_CODE,
        PRB.PRODUCT_RULE_CODE
      FROM
        XLA_PRODUCT_RULES_B PRB,
        XLA_GL_LEDGERS_V LE,
        XLA_ACCTG_METHOD_RULES AMR
      WHERE PRB.PRODUCT_RULE_TYPE_CODE = AMR.PRODUCT_RULE_TYPE_CODE
        AND PRB.PRODUCT_RULE_CODE = AMR.PRODUCT_RULE_CODE
        AND PRB.APPLICATION_ID = AMR.APPLICATION_ID
        AND AMR.ACCOUNTING_METHOD_TYPE_CODE = LE.SLA_ACCOUNTING_METHOD_TYPE
        AND AMR.ACCOUNTING_METHOD_CODE = LE.SLA_ACCOUNTING_METHOD_CODE
        AND LE.LEDGER_ID = P_LEDGER_ID
        AND PRB.COMPILE_STATUS_CODE in ( 'E' , 'N' , DECODE(P_UNCOMPILE_ONLY_FLAG
            ,'N'
            ,'Y'
            ,'') )
        AND PRB.PRODUCT_RULE_TYPE_CODE = NVL(P_PRODUCT_RULE_TYPE_CODE
         ,PRB.PRODUCT_RULE_TYPE_CODE)
        AND PRB.APPLICATION_ID = NVL(P_APPLICATION_ID
         ,PRB.APPLICATION_ID)
        AND PRB.AMB_CONTEXT_CODE = NVL(FND_PROFILE.VALUE('XLA_AMB_CONTEXT')
         ,'DEFAULT');
    L_APPLICATION_ID INTEGER;
    L_AMB_CONTEXT_CODE VARCHAR2(30);
    L_PROD_RULE_CODE VARCHAR2(30);
    L_PROD_RULE_TYPE_CODE VARCHAR2(30);
    L_VALIDATION_STATUS_CODE VARCHAR2(1);
    L_COMPILE_STATUS_CODE VARCHAR2(1);
    L_HASH_ID INTEGER;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    XLA_UTILITY_PKG.ACTIVATE('SRS_DBP'
                            ,'XLAABACR');
    XLA_ENVIRONMENT_PKG.REFRESH;
    SET_REPORT_CONSTANTS;
    IF (P_REPORT_ONLY_MODE < 'Y') THEN
      IF (P_LEDGER_ID IS NULL) THEN
        IF (P_APPLICATION_ID IS NULL) THEN
          XLA_UTILITY_PKG.TRACE('use c_aad1'
                               ,30);
          OPEN C_AAD1;
          LOOP
            FETCH C_AAD1
             INTO
               L_APPLICATION_ID
               ,L_AMB_CONTEXT_CODE
               ,L_PROD_RULE_TYPE_CODE
               ,L_PROD_RULE_CODE;
            EXIT WHEN C_AAD1%NOTFOUND;
            XLA_UTILITY_PKG.TRACE('l_application_id = ' || L_APPLICATION_ID
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_amb_context_code = ' || L_AMB_CONTEXT_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_type_code = ' || L_PROD_RULE_TYPE_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_code = ' || L_PROD_RULE_CODE
                                 ,30);
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = 'R'
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
            XLA_AMB_AAD_PKG.VALIDATE_AND_COMPILE_AAD(P_APPLICATION_ID => L_APPLICATION_ID
                                                    ,P_AMB_CONTEXT_CODE => L_AMB_CONTEXT_CODE
                                                    ,P_PRODUCT_RULE_TYPE_CODE => L_PROD_RULE_TYPE_CODE
                                                    ,P_PRODUCT_RULE_CODE => L_PROD_RULE_CODE
                                                    ,X_VALIDATION_STATUS_CODE => L_VALIDATION_STATUS_CODE
                                                    ,X_COMPILATION_STATUS_CODE => L_COMPILE_STATUS_CODE
                                                    ,X_HASH_ID => L_HASH_ID);
            IF (L_VALIDATION_STATUS_CODE = 'E' OR L_COMPILE_STATUS_CODE = 'E') THEN
              CP_RET_CODE := 1;
              L_COMPILE_STATUS_CODE := 'E';
            ELSE
              L_COMPILE_STATUS_CODE := 'Y';
            END IF;
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = L_COMPILE_STATUS_CODE
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
          END LOOP;
          CLOSE C_AAD1;
        ELSIF (P_PRODUCT_RULE_CODE IS NULL) THEN
          XLA_UTILITY_PKG.TRACE('use c_aad2'
                               ,30);
          OPEN C_AAD2;
          LOOP
            FETCH C_AAD2
             INTO
               L_APPLICATION_ID
               ,L_AMB_CONTEXT_CODE
               ,L_PROD_RULE_TYPE_CODE
               ,L_PROD_RULE_CODE;
            EXIT WHEN C_AAD2%NOTFOUND;
            XLA_UTILITY_PKG.TRACE('l_application_id = ' || L_APPLICATION_ID
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_amb_context_code = ' || L_AMB_CONTEXT_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_type_code = ' || L_PROD_RULE_TYPE_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_code = ' || L_PROD_RULE_CODE
                                 ,30);
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = 'R'
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
            XLA_AMB_AAD_PKG.VALIDATE_AND_COMPILE_AAD(P_APPLICATION_ID => L_APPLICATION_ID
                                                    ,P_AMB_CONTEXT_CODE => L_AMB_CONTEXT_CODE
                                                    ,P_PRODUCT_RULE_TYPE_CODE => L_PROD_RULE_TYPE_CODE
                                                    ,P_PRODUCT_RULE_CODE => L_PROD_RULE_CODE
                                                    ,X_VALIDATION_STATUS_CODE => L_VALIDATION_STATUS_CODE
                                                    ,X_COMPILATION_STATUS_CODE => L_COMPILE_STATUS_CODE
                                                    ,X_HASH_ID => L_HASH_ID);
            IF (L_VALIDATION_STATUS_CODE = 'E' OR L_COMPILE_STATUS_CODE = 'E') THEN
              CP_RET_CODE := 1;
              L_COMPILE_STATUS_CODE := 'E';
            ELSE
              L_COMPILE_STATUS_CODE := 'Y';
            END IF;
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = L_COMPILE_STATUS_CODE
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
          END LOOP;
          CLOSE C_AAD2;
        ELSE
          XLA_UTILITY_PKG.TRACE('use c_aad3'
                               ,30);
          OPEN C_AAD3;
          LOOP
            FETCH C_AAD3
             INTO
               L_APPLICATION_ID
               ,L_AMB_CONTEXT_CODE
               ,L_PROD_RULE_TYPE_CODE
               ,L_PROD_RULE_CODE;
            EXIT WHEN C_AAD3%NOTFOUND;
            XLA_UTILITY_PKG.TRACE('l_application_id = ' || L_APPLICATION_ID
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_amb_context_code = ' || L_AMB_CONTEXT_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_type_code = ' || L_PROD_RULE_TYPE_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_code = ' || L_PROD_RULE_CODE
                                 ,30);
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = 'R'
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
            XLA_AMB_AAD_PKG.VALIDATE_AND_COMPILE_AAD(P_APPLICATION_ID => L_APPLICATION_ID
                                                    ,P_AMB_CONTEXT_CODE => L_AMB_CONTEXT_CODE
                                                    ,P_PRODUCT_RULE_TYPE_CODE => L_PROD_RULE_TYPE_CODE
                                                    ,P_PRODUCT_RULE_CODE => L_PROD_RULE_CODE
                                                    ,X_VALIDATION_STATUS_CODE => L_VALIDATION_STATUS_CODE
                                                    ,X_COMPILATION_STATUS_CODE => L_COMPILE_STATUS_CODE
                                                    ,X_HASH_ID => L_HASH_ID);
            IF (L_VALIDATION_STATUS_CODE = 'E' OR L_COMPILE_STATUS_CODE = 'E') THEN
              CP_RET_CODE := 1;
              L_COMPILE_STATUS_CODE := 'E';
            ELSE
              L_COMPILE_STATUS_CODE := 'Y';
            END IF;
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = L_COMPILE_STATUS_CODE
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
          END LOOP;
          CLOSE C_AAD3;
        END IF;
      ELSE
        IF (CP_LEDGER_CATEGORY = 'SECONDARY') THEN
          XLA_UTILITY_PKG.TRACE('use c_aad5'
                               ,30);
          OPEN C_AAD5;
          LOOP
            FETCH C_AAD5
             INTO
               L_APPLICATION_ID
               ,L_AMB_CONTEXT_CODE
               ,L_PROD_RULE_TYPE_CODE
               ,L_PROD_RULE_CODE;
            EXIT WHEN C_AAD5%NOTFOUND;
            XLA_UTILITY_PKG.TRACE('l_application_id = ' || L_APPLICATION_ID
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_amb_context_code = ' || L_AMB_CONTEXT_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_type_code = ' || L_PROD_RULE_TYPE_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_code = ' || L_PROD_RULE_CODE
                                 ,30);
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = 'R'
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
            XLA_AMB_AAD_PKG.VALIDATE_AND_COMPILE_AAD(P_APPLICATION_ID => L_APPLICATION_ID
                                                    ,P_AMB_CONTEXT_CODE => L_AMB_CONTEXT_CODE
                                                    ,P_PRODUCT_RULE_TYPE_CODE => L_PROD_RULE_TYPE_CODE
                                                    ,P_PRODUCT_RULE_CODE => L_PROD_RULE_CODE
                                                    ,X_VALIDATION_STATUS_CODE => L_VALIDATION_STATUS_CODE
                                                    ,X_COMPILATION_STATUS_CODE => L_COMPILE_STATUS_CODE
                                                    ,X_HASH_ID => L_HASH_ID);
            IF (L_VALIDATION_STATUS_CODE = 'E' OR L_COMPILE_STATUS_CODE = 'E') THEN
              CP_RET_CODE := 1;
              L_COMPILE_STATUS_CODE := 'E';
            ELSE
              L_COMPILE_STATUS_CODE := 'Y';
            END IF;
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = L_COMPILE_STATUS_CODE
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
          END LOOP;
          CLOSE C_AAD5;
        ELSE
          XLA_UTILITY_PKG.TRACE('use c_aad4'
                               ,30);
          OPEN C_AAD4;
          LOOP
            FETCH C_AAD4
             INTO
               L_APPLICATION_ID
               ,L_AMB_CONTEXT_CODE
               ,L_PROD_RULE_TYPE_CODE
               ,L_PROD_RULE_CODE;
            EXIT WHEN C_AAD4%NOTFOUND;
            XLA_UTILITY_PKG.TRACE('l_application_id = ' || L_APPLICATION_ID
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_amb_context_code = ' || L_AMB_CONTEXT_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_type_code = ' || L_PROD_RULE_TYPE_CODE
                                 ,30);
            XLA_UTILITY_PKG.TRACE('l_prod_rule_code = ' || L_PROD_RULE_CODE
                                 ,30);
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = 'R'
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
            XLA_AMB_AAD_PKG.VALIDATE_AND_COMPILE_AAD(P_APPLICATION_ID => L_APPLICATION_ID
                                                    ,P_AMB_CONTEXT_CODE => L_AMB_CONTEXT_CODE
                                                    ,P_PRODUCT_RULE_TYPE_CODE => L_PROD_RULE_TYPE_CODE
                                                    ,P_PRODUCT_RULE_CODE => L_PROD_RULE_CODE
                                                    ,X_VALIDATION_STATUS_CODE => L_VALIDATION_STATUS_CODE
                                                    ,X_COMPILATION_STATUS_CODE => L_COMPILE_STATUS_CODE
                                                    ,X_HASH_ID => L_HASH_ID);
            IF (L_VALIDATION_STATUS_CODE = 'E' OR L_COMPILE_STATUS_CODE = 'E') THEN
              CP_RET_CODE := 1;
              L_COMPILE_STATUS_CODE := 'E';
            ELSE
              L_COMPILE_STATUS_CODE := 'Y';
            END IF;
            UPDATE
              XLA_PRODUCT_RULES_B
            SET
              COMPILE_STATUS_CODE = L_COMPILE_STATUS_CODE
            WHERE APPLICATION_ID = L_APPLICATION_ID
              AND AMB_CONTEXT_CODE = L_AMB_CONTEXT_CODE
              AND PRODUCT_RULE_TYPE_CODE = L_PROD_RULE_TYPE_CODE
              AND PRODUCT_RULE_CODE = L_PROD_RULE_CODE;
          END LOOP;
          CLOSE C_AAD4;
        END IF;
      END IF;
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101
                             ,NULL);
  END BEFOREREPORT;

  PROCEDURE SET_REPORT_CONSTANTS IS
    CURSOR C_LEDGER IS
      SELECT
        LEDGER_CATEGORY_CODE
      FROM
        XLA_GL_LEDGERS_V
      WHERE LEDGER_ID = P_LEDGER_ID;
  BEGIN
    XLA_UTILITY_PKG.TRACE('> XLA_XLAABACR_XMLP_PKG.set_report_constants'
                         ,20);
    CP_DEBUG_FLAG := NVL(FND_PROFILE.VALUE('XLA_DEBUG_TRACE')
                        ,'N');
    CP_DEFAULT_MODULE := 'xla.reports.XLAABACR';
    IF (P_REPORT_ONLY_MODE = 'N') THEN
      CP_QUERY := ' AND ERR.REQUEST_ID = ' || P_CONC_REQUEST_ID;
      CP_JLD_SELECT := ' ';
      CP_JLD_WHERE := ' ';
      CP_JLD_FROM := ' ';
    ELSIF (P_REPORT_ONLY_MODE < 'N' AND P_APPLICATION_ID IS NOT NULL AND P_PRODUCT_RULE_CODE IS NOT NULL AND P_PRODUCT_RULE_TYPE_CODE IS NOT NULL) THEN
      CP_QUERY := ' AND ERR.APPLICATION_ID         = ' || P_APPLICATION_ID || '
                                     AND ERR.AMB_CONTEXT_CODE       = fnd_profile.value(''XLA_AMB_CONTEXT'')
                                     AND ERR.PRODUCT_RULE_TYPE_CODE = ''' || P_PRODUCT_RULE_TYPE_CODE || '''
                                     AND ERR.PRODUCT_RULE_CODE      = ''' || P_PRODUCT_RULE_CODE || '''';
      CP_JLD_SELECT := ' UNION
                       select app.application_name
                       ,lk11.meaning amb_context_dsp
                       ,err.amb_context_code
                       ,err.product_rule_code
                       ,null product_rule_name
                       ,err.product_rule_type_code
                       ,null product_rule_type_dsp
                       ,err.line_definition_owner_code
                       ,lk12.meaning line_definition_owner
                       ,err.line_definition_code
                       ,xld.name line_definition_name
                       ,err.category_sequence_num
                       ,err.message_category_code
                       ,lk2.meaning message_category_dsp
                       ,msg.message_number
                       ,err.message_type_flag
                       ,lk1.meaning message_type_dsp
                       ,ect.event_class_code
                       ,ect.name event_class_name
                       ,ett.event_type_code
                       ,ett.name event_type_name
                       ,err.description_code
                       ,dt.name description_name
                       ,err.description_type_code
                       ,lk5.meaning description_type_dsp
                       ,err.extract_object_name
                       ,err.extract_object_type_code
                       ,null extract_object_type_dsp
                       ,err.source_code
                       ,st.name source_name
                       ,err.source_type_code
                       ,lk9.meaning source_type_dsp
                       ,err.analytical_criterion_code
                       ,act.name analytical_criterion_name
                       ,err.analytical_criterion_type_code
                       ,lk6.meaning analytical_criterion_type_dsp
                       ,err.accounting_line_code
                       ,acb.name accounting_line_name
                       ,err.accounting_line_type_code
                       ,lk7.meaning accounting_line_type_dsp
                       ,err.mapping_set_code
                       ,mst.name mapping_set_name
                       ,err.segment_rule_code
                       ,srt.name segment_rule_name
                       ,err.segment_rule_type_code
                       ,lk8.meaning segment_rule_type_dsp
                       ,err.accounting_source_code
                       ,err.mapping_group_code
                       ,lk10.meaning mapping_group_dsp
                       ,ast1.name accounting_source_name
                       ,err.mpa_accounting_line_code
                       ,malt.name mpa_accounting_line_name
                       ,err.mpa_accounting_line_type_code
                       ,lk13.meaning mpa_accounting_line_type_dsp
                       ,msg.message_text ';
      CP_JLD_FROM := ' from
                      xla_amb_setup_errors        err
                     ,xla_aad_line_defn_assgns    xal
                     ,xla_line_definitions_tl     xld
                     ,xla_event_classes_tl        ect
                     ,xla_event_types_tl          ett
                     ,xla_descriptions_tl         dt
                     ,xla_analytical_hdrs_tl      act
                     ,xla_acct_line_types_tl      acb
                     ,xla_acct_line_types_tl      malt
                     ,xla_sources_tl              st
                     ,xla_acct_attributes_tl      ast
                     ,xla_mapping_sets_tl         mst
                     ,xla_seg_rules_tl            srt
                     ,fnd_new_messages            msg
                     ,fnd_application_vl          app
                     ,xla_lookups                 lk1
                     ,xla_lookups                 lk2
                     ,xla_lookups                 lk5
                     ,xla_lookups                 lk6
                     ,xla_lookups                 lk7
                     ,xla_lookups                 lk8
                     ,xla_lookups                 lk9
                     ,xla_lookups                 lk10
                     ,xla_lookups                 lk11
                     ,xla_lookups                 lk12
                     ,xla_lookups                 lk13 ';
      CP_JLD_WHERE := ' where
                          msg.message_name                    = err.message_name
                      and msg.application_id                  = 602
                      and msg.language_code                   = USERENV(''LANG'')
                      and app.application_id                  = err.application_id
                      and xld.application_id(+)               = err.application_id
                      and xld.amb_context_code(+)             = err.amb_context_code
                      and xld.event_class_code(+)             = err.event_class_code
                      and xld.event_type_code(+)              = err.event_type_code
                      and xld.line_definition_owner_code(+)   = err.line_definition_owner_code
                      and xld.line_definition_code(+)         = err.line_definition_code
                      and xld.language(+)                     = USERENV(''LANG'')
                      and ect.application_id(+)               = err.application_id
                      and ect.event_class_code(+)             = err.event_class_code
                      and ect.language(+)                     = USERENV(''LANG'')
                      and ett.application_id(+)               = err.application_id
                      and ett.event_class_code (+)            = err.event_class_code
                      and ett.event_type_code(+)              = err.event_type_code
                      and ett.language(+)                     = USERENV(''LANG'')
                      and dt.application_id(+)                = err.application_id
                      and dt.amb_context_code (+)             = err.amb_context_code
                      and dt.description_type_code(+)         = err.description_type_code
                      and dt.description_code(+)              = err.description_code
                      and dt.language(+)                      = USERENV(''LANG'')
                      and st.application_id(+)                = err.application_id
                      and st.source_type_code(+)              = err.source_type_code
                      and st.source_code(+)                   = err.source_code
                      and st.language(+)                      = USERENV(''LANG'')
                      and ast1.accounting_attribute_code(+)    = err.accounting_source_code
                      and ast1.language(+)                     = USERENV(''LANG'')
                      and acb.application_id(+)               = err.application_id
                      and acb.event_class_code(+)             = err.event_class_code
                      and acb.amb_context_code (+)            = err.amb_context_code
                      and acb.accounting_line_type_code(+)    = err.accounting_line_type_code
                      and acb.accounting_line_code(+)         = err.accounting_line_code
                      and acb.language(+)                     = USERENV(''LANG'')
                      and malt.application_id(+)               = err.application_id
                      and malt.event_class_code(+)             = err.event_class_code
                      and malt.amb_context_code (+)            = err.amb_context_code
                      and malt.accounting_line_type_code(+)    = err.mpa_accounting_line_type_code
                      and malt.accounting_line_code(+)         = err.mpa_accounting_line_code
                      and malt.language(+)                     = USERENV(''LANG'')
                      and act.analytical_criterion_code(+)    = err.analytical_criterion_code
                      and act.analytical_criterion_type_code(+) = err.analytical_criterion_type_code
                      and act.amb_context_code(+)             = err.amb_context_code
                      and act.language(+)                     = USERENV(''LANG'')
                      and mst.mapping_set_code(+)             = err.mapping_set_code
                      and mst.amb_context_code(+)             = err.amb_context_code
                      and mst.language(+)                     = USERENV(''LANG'')
                      and srt.application_id(+)               = err.application_id
                      and srt.amb_context_code(+)             = err.amb_context_code
                      and srt.segment_rule_type_code(+)       = err.segment_rule_type_code
                      and srt.segment_rule_code(+)            = err.segment_rule_code
                      and srt.language(+)                     = USERENV(''LANG'')';
      CP_JLD_WHERE2 := '
                       and lk1.lookup_code                     = err.message_type_flag
                       and lk1.lookup_type                     = ''XLA_ERROR_TYPE''
                       and lk2.lookup_code                     = err.message_category_code
                       and lk2.lookup_type                     = ''XLA_AB_MESSAGE_CATEGORY''
                       and lk5.lookup_code(+)                  = err.description_type_code
                       and lk5.lookup_type(+)                  = ''XLA_OWNER_TYPE''
                       and lk6.lookup_code(+)                  = err.analytical_criterion_type_code
                       and lk6.lookup_type(+)                  = ''XLA_OWNER_TYPE''
                       and lk7.lookup_code(+)                  = err.accounting_line_type_code
                       and lk7.lookup_type(+)                  = ''XLA_OWNER_TYPE''
                       and lk8.lookup_code(+)                  = err.segment_rule_type_code
                       and lk8.lookup_type(+)                  = ''XLA_OWNER_TYPE''
                       and lk9.lookup_code(+)                  = err.source_type_code
                       and lk9.lookup_type(+)                  = ''XLA_SOURCE_TYPE''
                       and lk10.lookup_code(+)                 = err.mapping_group_code
                       and lk10.lookup_type(+)                 = ''XLA_ACCT_ATTR_ASSGN_GROUP''
                       and lk11.lookup_code                    = err.amb_context_code
                       and lk11.lookup_type                    = ''XLA_AMB_CONTEXT_TYPE''
                       and lk12.lookup_code(+)                 = err.line_definition_owner_code
                       and lk12.lookup_type(+)                 = ''XLA_OWNER_TYPE''
                       and lk13.lookup_code(+)                  = err.mpa_accounting_line_type_code
                       and lk13.lookup_type(+)                  = ''XLA_OWNER_TYPE''
                                          AND err.application_id             = xal.application_id
                                          AND err.amb_context_code           = xal.amb_context_code
                                          AND err.event_class_code           = xal.event_class_code
                                          AND err.event_type_code            = xal.event_type_code
                                          AND err.line_definition_owner_code = xal.line_definition_owner_code
                                          AND err.line_definition_code       = xal.line_definition_code
                                          AND XAL.APPLICATION_ID             = ' || P_APPLICATION_ID || '
                                          AND XAL.AMB_CONTEXT_CODE           = fnd_profile.value(''XLA_AMB_CONTEXT'')
                                          AND XAL.PRODUCT_RULE_TYPE_CODE     = ''' || P_PRODUCT_RULE_TYPE_CODE || '''
                                          AND XAL.PRODUCT_RULE_CODE          = ''' || P_PRODUCT_RULE_CODE || '''';
    ELSIF (P_REPORT_ONLY_MODE < 'N' AND P_APPLICATION_ID IS NOT NULL AND P_EVENT_CLASS_CODE IS NOT NULL AND P_EVENT_TYPE_CODE IS NOT NULL AND P_LINE_DEFINITION_OWNER_CODE IS NOT NULL AND P_LINE_DEFINITION_CODE IS NOT NULL) THEN
      CP_QUERY := 'AND ERR.APPLICATION_ID             = ' || P_APPLICATION_ID || '
                                    AND ERR.AMB_CONTEXT_CODE           = FND_PROFILE.VALUE(''XLA_AMB_CONTEXT'')
                                    AND ERR.EVENT_CLASS_CODE           = ''' || P_EVENT_CLASS_CODE || '''
                                    AND ERR.EVENT_TYPE_CODE            = ''' || P_EVENT_TYPE_CODE || '''
                                    AND ERR.LINE_DEFINITION_OWNER_CODE = ''' || P_LINE_DEFINITION_OWNER_CODE || '''
                                    AND ERR.LINE_DEFINITION_CODE       = ''' || P_LINE_DEFINITION_CODE || '''';
      CP_JLD_SELECT := ' ';
      CP_JLD_WHERE := ' ';
      CP_JLD_FROM := ' ';
    ELSE
      CP_QUERY := ' ';
      CP_JLD_SELECT := ' ';
      CP_JLD_WHERE := ' ';
      CP_JLD_FROM := ' ';
    END IF;
    IF (P_PRODUCT_RULE_TYPE_CODE IS NOT NULL) THEN
      CP_AAD_QUERY := CP_AAD_QUERY || ' and prb.product_rule_type_code = ''' || P_PRODUCT_RULE_TYPE_CODE || ''' ';
    END IF;
    IF (P_APPLICATION_ID IS NOT NULL) THEN
      CP_AAD_QUERY := CP_AAD_QUERY || ' and prb.application_id = ' || P_APPLICATION_ID;
    END IF;
    IF (P_PRODUCT_RULE_CODE IS NOT NULL) THEN
      CP_AAD_QUERY := CP_AAD_QUERY || ' and prb.product_rule_code = ''' || P_PRODUCT_RULE_CODE || ''' ';
      CP_AAD_QUERY := CP_AAD_QUERY || ' and prb.amb_context_code = fnd_profile.value(''XLA_AMB_CONTEXT'') ';
    END IF;
    IF (P_LEDGER_ID IS NOT NULL) THEN
      OPEN C_LEDGER;
      FETCH C_LEDGER
       INTO
         CP_LEDGER_CATEGORY;
      CLOSE C_LEDGER;
      IF (CP_LEDGER_CATEGORY = 'PRIMARY') THEN
        CP_AAD_WHERE := ' ,xla_gl_ledgers_v le, xla_acctg_method_rules amr, xla_ledger_relationships_v lr ';
        CP_AAD_QUERY := CP_AAD_QUERY || '
                                                   and    prb.product_rule_type_code       = amr.product_rule_type_code
                                                   and    prb.product_rule_code            = amr.product_rule_code
                                                   and    prb.application_id               = amr.application_id
                                                   and    amr.accounting_method_type_code  = le.sla_accounting_method_type
                                                   and    amr.accounting_method_code       = le.sla_accounting_method_code
                                                   and    le.ledger_id                     = lr.ledger_id
                                                   and    lr.primary_ledger_id             = ' || P_LEDGER_ID;
      ELSE
        CP_AAD_WHERE := ' ,xla_gl_ledgers_v le,xla_acctg_method_rules amr ';
        CP_AAD_QUERY := CP_AAD_QUERY || '
                                                   and    prb.product_rule_type_code       = amr.product_rule_type_code
                                                   and    prb.product_rule_code            = amr.product_rule_code
                                                   and    prb.application_id               = amr.application_id
                                                   and    amr.accounting_method_type_code  = le.sla_accounting_method_type
                                                   and    amr.accounting_method_code       = le.sla_accounting_method_code
                                                   and    le.ledger_id                     = ' || P_LEDGER_ID;
      END IF;
    END IF;
    XLA_UTILITY_PKG.TRACE('CP_QUERY      = ' || CP_QUERY
                         ,30);
    XLA_UTILITY_PKG.TRACE('CP_AAD_QUERY  = ' || CP_AAD_QUERY
                         ,30);
    XLA_UTILITY_PKG.TRACE('CP_AAD_WHERE  = ' || CP_AAD_WHERE
                         ,30);
    XLA_UTILITY_PKG.TRACE('< XLA_XLAABACR_XMLP_PKG.set_report_constants'
                         ,20);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101
                             ,NULL);
  END SET_REPORT_CONSTANTS;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
    L_TEMP BOOLEAN;
  BEGIN
    IF CP_RET_CODE = 1 OR P_REPORT_ONLY_MODE = 'Y' THEN
      XLA_UTILITY_PKG.TRACE('setting completion status to WARNING'
                           ,30);
      L_TEMP := FND_CONCURRENT.SET_COMPLETION_STATUS(STATUS => 'WARNING'
                                                    ,MESSAGE => NULL);
    ELSIF CP_RET_CODE = 0 THEN
      NULL;
    ELSE
      XLA_UTILITY_PKG.TRACE('setting completion status to ERROR'
                           ,30);
      L_TEMP := FND_CONCURRENT.SET_COMPLETION_STATUS(STATUS => 'ERROR'
                                                    ,MESSAGE => NULL);
    END IF;
    XLA_UTILITY_PKG.DEACTIVATE('XLAABACR');
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      XLA_UTILITY_PKG.DEACTIVATE('XLAABACR');
      RAISE_APPLICATION_ERROR(-20101
                             ,NULL);
  END AFTERREPORT;

  FUNCTION CP_RET_CODE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_RET_CODE;
  END CP_RET_CODE_P;

  FUNCTION CP_QUERY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_QUERY;
  END CP_QUERY_P;

  FUNCTION CP_DEBUG_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DEBUG_FLAG;
  END CP_DEBUG_FLAG_P;

  FUNCTION CP_LOG_LEVEL_P RETURN NUMBER IS
  BEGIN
    RETURN CP_LOG_LEVEL;
  END CP_LOG_LEVEL_P;

  FUNCTION CP_DEFAULT_MODULE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DEFAULT_MODULE;
  END CP_DEFAULT_MODULE_P;

  FUNCTION CP_AAD_QUERY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN nvl(CP_AAD_QUERY,' ');
  END CP_AAD_QUERY_P;

  FUNCTION CP_AAD_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN nvl(CP_AAD_WHERE,' ');
  END CP_AAD_WHERE_P;

  FUNCTION CP_LEDGER_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LEDGER_CATEGORY;
  END CP_LEDGER_CATEGORY_P;

  FUNCTION CP_JLD_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_JLD_WHERE;
  END CP_JLD_WHERE_P;

  FUNCTION CP_JLD_SELECT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_JLD_SELECT;
  END CP_JLD_SELECT_P;

  FUNCTION CP_JLD_FROM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_JLD_FROM;
  END CP_JLD_FROM_P;

  FUNCTION CP_JLD_WHERE2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_JLD_WHERE2;
  END CP_JLD_WHERE2_P;

END XLA_XLAABACR_XMLP_PKG;


/
