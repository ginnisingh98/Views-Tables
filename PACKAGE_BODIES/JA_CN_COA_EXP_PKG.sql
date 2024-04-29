--------------------------------------------------------
--  DDL for Package Body JA_CN_COA_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_COA_EXP_PKG" AS
--$Header: JACNCAEB.pls 120.5.12010000.2 2009/05/25 08:27:47 shyan ship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNCAEB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used for Chart of Accout Export, including        |
--|     Natural Account and 4 Subsidiary Account of "Project",            |
--|     "Third Party", "Cost Center" and "Personnel", in the CNAO Project.|
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      FUNCTION  Is_Natural_Number                PRIVATE               |
--|      PROCEDURE Get_Acc_Subs_View                PRIVATE               |
--|      PROCEDURE Coa_NA_Export                    PRIVATE               |
--|      PROCEDURE Coa_PJ_Export                    PRIVATE               |
--|      PROCEDURE Coa_TP_Export                    PRIVATE               |
--|      PROCEDURE Coa_CC_Export                    PRIVATE               |
--|      PROCEDURE Coa_Person_Export                PRIVATE               |
--|      PROCEDURE Coa_Export                       PUBLIC                |
--|                                                                       |
--| HISTORY                                                               |
--|      03/03/2006     Andrew Liu          Created                       |
--+======================================================================*/

  l_module_prefix                VARCHAR2(100) :='JA_CN_COA_EXP_PKG';
  JA_CN_NO_DATA_FOUND            exception;
  l_msg_no_data_found            varchar2(2000); --'*****No data found*****';

  --==========================================================================
  --  FUNCTION NAME:
  --    Is_Natural_Number             private
  --
  --  DESCRIPTION:
  --      This function checks the input string is a nutural number or not.
  --
  --  PARAMETERS:
  --      In: P_NUM                   VARCHAR2            String of a number
  --  RETURN:
  --      NUMBER
  --         It is a nutural number when returns 1, else not when returns 0
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --==========================================================================
  FUNCTION  Is_Natural_Number( P_NUM IN varchar2)
  RETURN VARCHAR2  IS
    l_number                            NUMBER;
  BEGIN
    l_number := TO_NUMBER(P_NUM);
    IF instr(P_NUM, '.', 1, 1) > 0                --not a integer
       OR instr(TO_CHAR(l_number), '.', 1, 1) > 0 --not a integer
       OR l_number <1                             --less than 1
    THEN
      RETURN 0;
    END IF;

    RETURN 1;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
  End Is_Natural_Number;


  --==========================================================================
  --  PROCEDURE NAME:
  --    Get_Acc_Subs_View             private
  --
  --  DESCRIPTION:
  --      This procedure gets account number, level, subsidiary account flag,
  --      and item of project, third party, cost center and personnel, and
  --      Balance Side of all accounts INTO view 'JA_CN_ACC_SUBS_V'.
  --
  --  PARAMETERS:
  --      In: P_LEDGER_ID                NUMBER              ID of Ledger
  --      In: P_COA_ID                   NUMBER              chart of accounts ID
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu
  --      04/27/2007     Yucheng Sun
  --==========================================================================
  PROCEDURE  Get_Acc_Subs_View( P_LEDGER_ID IN number
                               ,P_COA_ID    IN NUMBER ) IS
    l_ledger_id                            NUMBER := P_LEDGER_ID;
    l_coa_id                               NUMBER := P_COA_ID;
    l_sql_str                           varchar2(30000):='';
    l_acc_level_context                 JA_CN_DFF_ASSIGNMENTS.CONTEXT_CODE%TYPE;
    l_acc_sub_context                   JA_CN_DFF_ASSIGNMENTS.CONTEXT_CODE%TYPE;
    l_acc_bal_context                   JA_CN_DFF_ASSIGNMENTS.CONTEXT_CODE%TYPE;
    l_acc_level_position                JA_CN_DFF_ASSIGNMENTS.ATTRIBUTE_COLUMN%TYPE;
    l_sub_pj_position                   JA_CN_DFF_ASSIGNMENTS.ATTRIBUTE_COLUMN%TYPE;
    l_sub_tp_position                   JA_CN_DFF_ASSIGNMENTS.ATTRIBUTE_COLUMN%TYPE;
    l_sub_cc_position                   JA_CN_DFF_ASSIGNMENTS.ATTRIBUTE_COLUMN%TYPE;
    l_sub_person_position               JA_CN_DFF_ASSIGNMENTS.ATTRIBUTE_COLUMN%TYPE;
    l_acc_bal_position                  JA_CN_DFF_ASSIGNMENTS.ATTRIBUTE_COLUMN%TYPE;

  BEGIN
    --Get positions of
    --   account level, project, third party, cost center and personnel,and Balance Side
    --Generally speaking, the context code of these 6 item are the same one ('subsidary').
    SELECT nvl(DFF1.CONTEXT_CODE,'')           acc_level_context
          ,nvl(DFF2.CONTEXT_CODE,'')           acc_sub_context
          ,nvl(DFF6.CONTEXT_CODE,'')           acc_bal_context
          ,nvl(DFF1.ATTRIBUTE_COLUMN, '')      acc_level_position
          ,nvl(DFF2.ATTRIBUTE_COLUMN, '')      sub_pj_position
          ,nvl(DFF3.ATTRIBUTE_COLUMN, '')      sub_tp_position
          ,nvl(DFF4.ATTRIBUTE_COLUMN, '')      sub_cc_position
          ,nvl(DFF5.ATTRIBUTE_COLUMN, '')      sub_person_position
          ,nvl(DFF6.ATTRIBUTE_COLUMN, '')      acc_bal_position
      INTO l_acc_level_context
          ,l_acc_sub_context
          ,l_acc_bal_context
          ,l_acc_level_position
          ,l_sub_pj_position
          ,l_sub_tp_position
          ,l_sub_cc_position
          ,l_sub_person_position
          ,l_acc_bal_position
      FROM JA_CN_DFF_ASSIGNMENTS               DFF1
          ,JA_CN_DFF_ASSIGNMENTS               DFF2
          ,JA_CN_DFF_ASSIGNMENTS               DFF3
          ,JA_CN_DFF_ASSIGNMENTS               DFF4
          ,JA_CN_DFF_ASSIGNMENTS               DFF5
          ,JA_CN_DFF_ASSIGNMENTS               DFF6
     WHERE DFF1.DFF_TITLE_CODE = 'ACLE'        -- Account Level
       AND DFF2.DFF_TITLE_CODE = 'SAPA'        -- Project
       AND DFF3.DFF_TITLE_CODE = 'SATP'        -- Third party
       AND DFF4.DFF_TITLE_CODE = 'SACC'        -- Cost center
       AND DFF5.DFF_TITLE_CODE = 'SAEE'        -- Personnel
       AND DFF6.DFF_TITLE_CODE = 'ACBS'        -- Balance Side
           -- Check whether the flexfields had been set for current COA_ID
       AND DFF1.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF2.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF3.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF4.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF5.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF6.CHART_OF_ACCOUNTS_ID=l_coa_id
          ;

    --Combine sql of view. The view will get account number, level, subsidiary account flag,
    --  and item of project, third party, cost center and personnel and Balance Side
    --  of all accounts.

    -- add Global Data Elements supporting
    -- while using Global Data Elements, the value of FND_FLEX_VALUES.VALUE_CATEGORY will be null
    IF 'Global Data Elements'=nvl(l_acc_level_context,'') THEN
        l_sql_str :=
          'SELECT DISTINCT '
          ||'     FFV.FLEX_VALUE                       acc_number       '
          ||'    ,nvl(FFV.' || l_acc_level_position ||', '''')          '
          ||'                                          acc_level        '
          ||'    ,DECODE(                                               '
          ||'           nvl(FFV.' || l_sub_pj_position || ', ''N'') ||  '
          ||'           nvl(FFV.' || l_sub_tp_position || ', ''N'') ||  '
          ||'           nvl(FFV.' || l_sub_cc_position || ', ''N'') ||  '
          ||'           nvl(FFV.' || l_sub_person_position || ', ''N'') '
          ||'           , ''NNNN'', ''0'', ''1'')      sub_flag         '
          ||'    ,nvl(  DECODE(nvl(FFV.' || l_sub_pj_position || ', ''N''),'
          ||'              ''Y'', ''Project/'', '''')||                 '
          ||'           DECODE(nvl(FFV.' || l_sub_tp_position || ', ''N''),'
          ||'              ''S'', ''Supplier/'',''C'', ''Customer/'', '''')|| '
          ||'           DECODE(nvl(FFV.' || l_sub_cc_position || ', ''N''),'
          ||'              ''Y'', ''Cost Center/'', '''')||             '
          ||'           DECODE(nvl(FFV.' || l_sub_person_position || ', '
          ||'                    ''N''), ''Y'', ''Personnel/'', ''''),  '
          ||'        ''/'')                            sub_item         '
          ||'    ,nvl(FFV.' || l_acc_bal_position ||', '''')           '
          ||'                                          acc_bal          '
          ||' FROM FND_ID_FLEX_SEGMENTS                FIFS             '
          ||'     ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV             '
          ||'     ,FND_FLEX_VALUE_SETS                 FFVS             '
          ||'     ,FND_FLEX_VALUES                     FFV              '
          --||'     ,GL_LEDGERS                          LEDGER           '
          ||' WHERE                                                     '
          --Get all correct row of FFV
          --||'       LEDGER.ledger_id = ' || l_LEDGER_id
          ||'       FIFS.id_flex_num =  '|| l_coa_id ||'                '
          ||'   AND FIFS.id_flex_num = FSAV.id_flex_num                 '
          ||'   AND FIFS.application_id = 101                           '
          ||'   AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME '
          ||'   AND FIFS.application_id = FSAV.application_id           '
          ||'   AND FSAV.SEGMENT_ATTRIBUTE_TYPE = ''GL_ACCOUNT''        '
          ||'   AND FSAV.ATTRIBUTE_VALUE = ''Y''                        '
          ||'   AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID     '
          ||'   AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID      '
          --||'   AND FFV.VALUE_CATEGORY IS NULL                          '
          ||'   ORDER BY FFV.FLEX_VALUE                                 '
          ;
    ELSE
        l_sql_str :=
          'SELECT DISTINCT '
          ||'     FFV.FLEX_VALUE                       acc_number       '
          ||'    ,DECODE(FFV.VALUE_CATEGORY,'''|| l_acc_level_context ||''','
          ||'        nvl(FFV.' || l_acc_level_position ||', ''''),      '
          ||'        '''')                             acc_level        '
          ||'    ,DECODE(FFV.VALUE_CATEGORY,'''||l_acc_sub_context||''','
          ||'        DECODE(                                            '
          ||'           nvl(FFV.' || l_sub_pj_position || ', ''N'') ||  '
          ||'           nvl(FFV.' || l_sub_tp_position || ', ''N'') ||  '
          ||'           nvl(FFV.' || l_sub_cc_position || ', ''N'') ||  '
          ||'           nvl(FFV.' || l_sub_person_position || ', ''N'') '
          ||'           , ''NNNN'', ''0'', ''1''),                      '
          ||'        ''0'')                            sub_flag         '
          ||'    ,DECODE(FFV.VALUE_CATEGORY,'''|| l_acc_sub_context ||''','
          ||'           nvl(DECODE(nvl(FFV.' || l_sub_pj_position || ', ''N''),'
          ||'              ''Y'', ''Project/'', '''')||             '
          ||'           DECODE(nvl(FFV.' || l_sub_tp_position || ', ''N''),'
          ||'              ''S'', ''Supplier/'',''C'', ''Customer/'', '''')|| '
          ||'           DECODE(nvl(FFV.' || l_sub_cc_position || ', ''N''),'
          ||'              ''Y'', ''Cost Center/'', '''')||             '
          ||'           DECODE(nvl(FFV.' || l_sub_person_position || ', '
          ||'                    ''N''), ''Y'', ''Personnel/'', ''''),  '
          ||'        ''/''), ''/'')                    sub_item         '
          ||'    ,DECODE(FFV.VALUE_CATEGORY,'''|| l_acc_bal_context ||''','
          ||'        nvl(FFV.' || l_acc_bal_position ||', ''''),        '
          ||'        '''')                             acc_bal          '
          ||' FROM FND_ID_FLEX_SEGMENTS                FIFS             '
          ||'     ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV             '
          ||'     ,FND_FLEX_VALUE_SETS                 FFVS             '
          ||'     ,FND_FLEX_VALUES                     FFV              '
          --||'     ,GL_LEDGERS                          LEDGER           '
          ||' WHERE                                                     '
          --Get all correct row of FFV
          --||'       LEDGER.ledger_id = ' || l_LEDGER_id
          ||'       FIFS.id_flex_num =  '|| l_coa_id ||'                '
          ||'   AND FIFS.id_flex_num = FSAV.id_flex_num                 '
          ||'   AND FIFS.application_id = 101                           '
          ||'   AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME '
          ||'   AND FIFS.application_id = FSAV.application_id           '
          ||'   AND FSAV.SEGMENT_ATTRIBUTE_TYPE = ''GL_ACCOUNT''        '
          ||'   AND FSAV.ATTRIBUTE_VALUE = ''Y''                        '
          ||'   AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID     '
          ||'   AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID      '
          ||'   ORDER BY FFV.FLEX_VALUE                                 '
          ;
    END IF;


    l_sql_str := 'CREATE OR REPLACE VIEW JA_CN_ACC_SUBS_V AS ' ||
                     l_sql_str;

/*    l_sql :=
      'SELECT DISTINCT ' --For porject of 'N' or 'COA'
      ||'     FFV.FLEX_VALUE                       acc_number       '
      ||'    ,DECODE(FFV.VALUE_CATEGORY,'''||l_acc_level_context||''','
      ||'        nvl(FFV.' || l_acc_level_position ||', ''''),      '
      ||'        '''')                             acc_level        '
      ||'    ,DECODE(FFV.VALUE_CATEGORY,'''||l_acc_sub_context||''','
      ||'        DECODE(                                            '
      ||'           DECODE(nvl(SOB.GLOBAL_ATTRIBUTE1, ''N''),       '
      ||'             ''N'', ''N'',                                 '
      ||'             ''COA'', nvl(FFV.' || l_sub_pj_position
      ||'                           , ''N'') ) ||                   '
      ||'           nvl(FFV.' || l_sub_tp_position || ', ''N'') ||  '
      ||'           nvl(FFV.' || l_sub_cc_position || ', ''N'') ||  '
      ||'           nvl(FFV.' || l_sub_person_position || ', ''N'') '
      ||'           , ''NNNN'', ''0'', ''1''),                      '
      ||'        ''0'')                            sub_flag         '
      ||'    ,DECODE(FFV.VALUE_CATEGORY,'''||l_acc_sub_context||''','
      ||'        nvl(DECODE(nvl(SOB.GLOBAL_ATTRIBUTE1, ''N''),      '
      ||'           ''N'', '''',                                    '--Leave Blank
      ||'           ''COA'', DECODE(nvl(FFV.' || l_sub_pj_position
      ||'                   , ''N''), ''Y'', ''Project-COA/'', '''')'
      ||'              )||                                          '
      ||'           DECODE(nvl(FFV.' || l_sub_tp_position || ', ''N''),'
      ||'              ''Y'', ''Third Party/'', '''')||             '
      ||'           DECODE(nvl(FFV.' || l_sub_cc_position || ', ''N''),'
      ||'              ''Y'', ''Cost Center/'', '''')||             '
      ||'           DECODE(nvl(FFV.' || l_sub_person_position || ', '
      ||'                    ''N''), ''Y'', ''Personnel/'', ''''),  '
      ||'        ''/''), ''/'')                    sub_item         '
      ||' FROM FND_ID_FLEX_SEGMENTS                FIFS             '
      ||'     ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV             '
      ||'     ,FND_FLEX_VALUE_SETS                 FFVS             '
      ||'     ,FND_FLEX_VALUES                     FFV              '
      ||'     ,GL_SETS_OF_BOOKS                    SOB              '
      ||' WHERE                                                     '
            --Get all correct row of FFV
      ||'       SOB.set_of_books_id = ' || l_sob_id
      ||'   AND SOB.global_attribute_category = ''JA.CN.GLXSTBKS.BOOKS'' '
      ||'   AND SOB.chart_of_accounts_id = FIFS.id_flex_num         '
      ||'   AND FIFS.id_flex_num = FSAV.id_flex_num                 '
      ||'   AND FIFS.application_id = 101                           '
      ||'   AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME '

      ||'   AND FIFS.application_id = FSAV.application_id           '
      ||'   AND FSAV.SEGMENT_ATTRIBUTE_TYPE = ''GL_ACCOUNT''        '
      ||'   AND FSAV.ATTRIBUTE_VALUE = ''Y''                        '
      ||'   AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID     '
      ||'   AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID      '

      \*--for all. --The context code may be null or others!
      ||'   AND (FFV.VALUE_CATEGORY is null OR                      '
                 ||' FFV.VALUE_CATEGORY = ''Subsidiary'')           '*\

      --for Subsidiary account item of project
      ||'   AND (   nvl(SOB.GLOBAL_ATTRIBUTE1, ''N'') = ''N''       '
      ||'        OR nvl(SOB.GLOBAL_ATTRIBUTE1, ''N'') = ''COA''     '
                     --AND DFF2.DFF_TITLE_CODE = ''SAPA''
      ||'       )                                                   '
      ;

    l_sql := l_sql || ' UNION ';

    l_sql := l_sql ||  --For porject of 'PA'(Project Module)
      'SELECT DISTINCT '
      ||'     FFV.FLEX_VALUE                       acc_number       '
      ||'    ,DECODE(FFV.VALUE_CATEGORY,'''||l_acc_level_context||''','
      ||'        nvl(FFV.' || l_acc_level_position ||', ''''),      '
      ||'        '''')                             acc_level        '
      ||'    ,DECODE(FFV.VALUE_CATEGORY,'''||l_acc_sub_context||''','
      ||'        DECODE(                                            '
      ||'           DECODE(nvl(SOB.GLOBAL_ATTRIBUTE1, ''N''),       '
      ||'             ''PA'', DECODE(nvl(BAL.PROJECT_NUMBER, ''''), '
      ||'                           '''', ''N'', ''Y'')            '
    \*||'             ''PA'', DECODE(                               '
      ||'                 decode(nvl(BAL.SET_OF_BOOKS_ID, ''-1''), SOB.set_of_books_id, '
      ||'                   decode(nvl(BAL.account_segment, ''@@''), FFV.FLEX_VALUE,    '
      ||'                     decode(nvl(BAL.project_source, ''@@''), ''PA'',           '
      ||'                     nvl(BAL.PROJECT_NUMBER, ''''), ''''), '
      ||'                 ''''), ''''),'''', ''N'', ''Y'')          '*\
      ||'             ) ||                                          '
      ||'           nvl(FFV.' || l_sub_tp_position || ', ''N'') ||  '
      ||'           nvl(FFV.' || l_sub_cc_position || ', ''N'') ||  '
      ||'           nvl(FFV.' || l_sub_person_position || ', ''N'') '
      ||'           , ''NNNN'', ''0'', ''1''),                      '
      ||'        ''0'')                            sub_flag         '
      ||'    ,DECODE(FFV.VALUE_CATEGORY,'''||l_acc_sub_context||''','
      ||'        nvl(DECODE(nvl(SOB.GLOBAL_ATTRIBUTE1, ''N''),      '
      ||'           ''PA'', DECODE(nvl(BAL.PROJECT_NUMBER, ''''),   '
      ||'                     '''', '''', ''Project-PM/'')         '
    \*||'           ''PA'', DECODE(                                 '
      ||'                 decode(nvl(BAL.SET_OF_BOOKS_ID, ''-1''), SOB.set_of_books_id, '
      ||'                   decode(nvl(BAL.account_segment, ''@@''), FFV.FLEX_VALUE,    '
      ||'                     decode(nvl(BAL.project_source, ''@@''), ''PA'',           '
      ||'                     nvl(BAL.PROJECT_NUMBER, ''''), ''''), '
      ||'                 ''''), ''''),'''', '''', ''Project-PM/'') '*\
      ||'              )||                                          '
      ||'           DECODE(nvl(FFV.' || l_sub_tp_position || ', ''N''),'
      ||'              ''Y'', ''Third Party/'', '''')||             '
      ||'           DECODE(nvl(FFV.' || l_sub_cc_position || ', ''N''),'
      ||'              ''Y'', ''Cost Center/'', '''')||             '
      ||'           DECODE(nvl(FFV.' || l_sub_person_position || ', '
      ||'                    ''N''), ''Y'', ''Personnel/'', ''''),  '
      ||'        ''/''), ''/'')                    sub_item         '
      ||' FROM FND_ID_FLEX_SEGMENTS                FIFS             '
      ||'     ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV             '
      ||'     ,FND_FLEX_VALUE_SETS                 FFVS             '
      ||'     ,FND_FLEX_VALUES                     FFV              '
      ||'     ,GL_SETS_OF_BOOKS                    SOB              '
      --Balane table used here only for project from Project Module
    --||'     ,JA_CN_ACCOUNT_BALANCES              BAL              '
      ||'     ,(SELECT * FROM JA_CN_ACCOUNT_BALANCES WHERE          '
      ||'        project_source = ''PA'' AND set_of_books_id =      '
                               || l_sob_id || ')   BAL              '
      ||' WHERE                                                     '
            --Get all correct row of FFV
      ||'       SOB.set_of_books_id = ' || l_sob_id
      ||'   AND SOB.global_attribute_category = ''JA.CN.GLXSTBKS.BOOKS'' '
      ||'   AND SOB.chart_of_accounts_id = FIFS.id_flex_num         '
      ||'   AND FIFS.id_flex_num = FSAV.id_flex_num                 '
      ||'   AND FIFS.application_id = 101                           '
      ||'   AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME '

      ||'   AND FIFS.application_id = FSAV.application_id           '
      ||'   AND FSAV.SEGMENT_ATTRIBUTE_TYPE = ''GL_ACCOUNT''        '
      ||'   AND FSAV.ATTRIBUTE_VALUE = ''Y''                        '
      ||'   AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID     '
      ||'   AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID      '

      \*--for all. --The context code may be null or others!
      ||'   AND (FFV.VALUE_CATEGORY is null OR                      '
                 ||' FFV.VALUE_CATEGORY = ''Subsidiary'')           '*\

      --for Subsidiary account item of project
      ||'   AND nvl(SOB.GLOBAL_ATTRIBUTE1, ''N'') = ''PA''          '
      ||'   AND BAL.account_segment(+) = FFV.FLEX_VALUE             '
      ;

    l_sql := 'CREATE OR REPLACE VIEW JA_CN_ACC_SUBS_V AS ' ||
                     l_sql;*/

    --dbms_output.put_line(l_sql);
    EXECUTE IMMEDIATE l_sql_str;

  End Get_Acc_Subs_View;


  --==========================================================================
  --  PROCEDURE NAME:
  --    Coa_NA_Export                 Private
  --
  --  DESCRIPTION:
  --      This procedure expots Natural Accounts, if there are invalid
  --      Natural Accounts then output an exceptions's report.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              Chart of account ID
  --      In: P_LEDGER_ID             NUMBER              ID of ledger
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_XML_TEMPLATE_LANGUAGE   VARCHAR2  template language of exception report
  --      In: P_XML_TEMPLATE_TERRITORY  VARCHAR2  template territory of exception report
  --      In: P_XML_OUTPUT_FORMAT       VARCHAR2  output format of exception report
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated
  --===========================================================================
  PROCEDURE  Coa_NA_Export( errbuf          OUT NOCOPY VARCHAR2
                           ,retcode         OUT NOCOPY VARCHAR2
                           ,P_COA_ID        IN NUMBER
                           ,P_LEDGER_ID     IN NUMBER
                           ,P_LE_ID         IN NUMBER
                           ,P_XML_TEMPLATE_LANGUAGE    IN VARCHAR2
                           ,P_XML_TEMPLATE_TERRITORY   IN VARCHAR2
                           ,P_XML_OUTPUT_FORMAT        IN VARCHAR2
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Coa_NA_Export';

    l_coa_id                           NUMBER := P_COA_ID;
    l_ledger_id                         NUMBER := P_LEDGER_ID;
    l_le_id                             NUMBER := P_LE_ID;
    JA_CN_INCOMPLETE_DFF_ASSIGN         exception;
    JA_CN_INVALID_ACCOUNT_STRU          exception;
    l_msg_incomplete_dff_assign         varchar2(2000);
    l_msg_invalid_account_stru          varchar2(2000);
    l_seperator                         varchar2(1) := FND_GLOBAL.Local_Chr(9); --' ';

    l_na_curr_req_id                    NUMBER;  --Request id of current request
    l_xml_layout                        boolean;
    l_template_language                 VARCHAR2(10) := P_XML_TEMPLATE_LANGUAGE;
    l_template_territory                VARCHAR2(10) := P_XML_TEMPLATE_TERRITORY;
    l_output_format                     VARCHAR2(10) := P_XML_OUTPUT_FORMAT;
    l_na_req_id                         NUMBER;  --Request id for concurrent program 'Generating Natural Account Export Exception Report'
    l_na_req_phase                      fnd_lookup_values.meaning%TYPE;
    l_na_req_status                     fnd_lookup_values.meaning%TYPE;
    l_na_req_dev_phase                  VARCHAR2(30);
    l_na_req_dev_status                 VARCHAR2(30);
    l_na_req_message                    VARCHAR2(100);

    l_dff                               VARCHAR2(6);
    l_sql                               varchar2(10000);
    l_account_structures_kfv            VARCHAR2(100) := 'ja_cn_account_structures_kfv';
    l_na_acc_str                        VARCHAR2(2000);
    l_na_acc_str_2                      VARCHAR2(2000);
    --l_ent_flag                          JA_CN_SYSTEM_PARAMETERS_ALL.ENT_FLAG%TYPE;
    l_ent_acc_type                      VARCHAR2(100);
    l_delimiter_label                   FND_ID_FLEX_STRUCTURES.Concatenated_Segment_Delimiter%TYPE;
    l_acc_segment                       VARCHAR2(100);
    TYPE t_acc_level_segments IS TABLE OF NUMBER;
    l_acc_segments                      t_acc_level_segments;
    l_acc_seg_serial                    NUMBER;
    TYPE t_level_seg_lens IS TABLE OF NUMBER;
    l_acc_seg_lens                      t_level_seg_lens;

    l_na_number                         FND_FLEX_VALUES.FLEX_VALUE%TYPE;
    l_na_name                           FND_FLEX_VALUES_TL.description%TYPE;
    l_na_parent                         VARCHAR2(1);
    l_na_level                          VARCHAR2(100);
    l_na_sub_flag                       VARCHAR2(1);
    l_na_sub_item                       VARCHAR2(100);
    l_acc_type_code                     VARCHAR2(1);
    l_acc_bal_code                      VARCHAR2(100);
    l_na_mea                            GL_STAT_ACCOUNT_UOM.UNIT_OF_MEASURE%TYPE;

    l_project_meaning                   VARCHAR2(100);
    l_thirdparty_meaning                VARCHAR2(100);
    l_supplier_meaning                  VARCHAR2(100);
    l_customer_meaning                  VARCHAR2(100);
    l_costcenter_meaning                VARCHAR2(100);
    l_personnel_meaning                 VARCHAR2(100);

    l_na_type                           VARCHAR2(50);
    l_na_bal                            VARCHAR2(10);

    l_length                            NUMBER;
    l_expected_length                   NUMBER;

    l_exceptions_count                  NUMBER;  --count of invalid account rows
    l_row_count                         NUMBER;  --count of correct account rows



    --Cursor to get DFF assignment status of Account Level, Project, Third Party,
    --  Cost Center and Personnel, and Balance Side.
    --Only a record of 'YYYYYY' expresses that all 6 DFFs have been set.
    CURSOR c_dff IS
    SELECT DECODE(nvl(DFF1.CONTEXT_CODE, ''), '', 'N',
                    DECODE(nvl(DFF1.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
             || DECODE(nvl(DFF2.CONTEXT_CODE, ''), '', 'N',
                    DECODE(nvl(DFF2.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
             || DECODE(nvl(DFF3.CONTEXT_CODE, ''), '', 'N',
                    DECODE(nvl(DFF3.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
             || DECODE(nvl(DFF4.CONTEXT_CODE, ''), '', 'N',
                    DECODE(nvl(DFF4.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
             || DECODE(nvl(DFF5.CONTEXT_CODE, ''), '', 'N',
                    DECODE(nvl(DFF5.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
             || DECODE(nvl(DFF6.CONTEXT_CODE, ''), '', 'N',
                    DECODE(nvl(DFF6.ATTRIBUTE_COLUMN, ''), '', 'N', 'Y'))
                                               dff_assign
      FROM JA_CN_DFF_ASSIGNMENTS               DFF1
          ,JA_CN_DFF_ASSIGNMENTS               DFF2
          ,JA_CN_DFF_ASSIGNMENTS               DFF3
          ,JA_CN_DFF_ASSIGNMENTS               DFF4
          ,JA_CN_DFF_ASSIGNMENTS               DFF5
          ,JA_CN_DFF_ASSIGNMENTS               DFF6
     WHERE DFF1.DFF_TITLE_CODE = 'ACLE'        -- Account Level
       AND DFF2.DFF_TITLE_CODE = 'SAPA'        -- Project
       AND DFF3.DFF_TITLE_CODE = 'SATP'        -- Third party
       AND DFF4.DFF_TITLE_CODE = 'SACC'        -- Cost center
       AND DFF5.DFF_TITLE_CODE = 'SAEE'        -- Personnel
       AND DFF6.DFF_TITLE_CODE = 'ACBS'        -- Balance Side
           -- Check whether the flexfields had been set for current COA_ID
       AND DFF1.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF2.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF3.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF4.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF5.CHART_OF_ACCOUNTS_ID=l_coa_id
       AND DFF6.CHART_OF_ACCOUNTS_ID=l_coa_id
          ;

    --Cursor to get natural account's Number, Name, Parent flag, Type Code;
    --AND account level, subsidiary account flag and item of project,
    --  third party, cost center and personnel, and balance side
    CURSOR c_na_info IS
    SELECT DISTINCT
           --FFV.FLEX_VALUE                          acc_number  -- replace with sub.acc_number
           sub.acc_number
          ,nvl(FFVT.description, '')               acc_name
          ,DECODE(FFV.summary_flag, 'Y', 'Y', 'N') acc_parent
          ,SUBSTR(TO_CHAR(FFV.COMPILED_VALUE_ATTRIBUTES)      --such as 'Y Y L'
                  ,5,1)                            acc_type_code
          ,nvl(sub.acc_level, '')                  acc_level
          ,nvl(sub.sub_flag, '0')                  sub_flag
          ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             nvl(sub.sub_item, '/'), 'Project', l_project_meaning
             ), 'Third Party',   l_thirdparty_meaning
             ), 'Supplier',      l_supplier_meaning
             ), 'Customer',      l_customer_meaning
             ), 'Cost Center',   l_costcenter_meaning
             ), 'Personnel',     l_personnel_meaning
           )                                        sub_item
          ,nvl(sub.acc_bal, '')                acc_bal
      FROM JA_CN_ACC_SUBS_V                    sub
          ,FND_ID_FLEX_SEGMENTS                FIFS
          ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV
          ,FND_FLEX_VALUE_SETS                 FFVS
          ,FND_FLEX_VALUES                     FFV
          ,FND_FLEX_VALUES_TL                  FFVT
          ,GL_LEDGERS                          ledger
     WHERE --Get all correct row of FFV
           ledger.ledger_id = l_ledger_id      --using variable l_sob_id
       AND ledger.chart_of_accounts_id = FIFS.id_flex_num
       AND FIFS.id_flex_num = FSAV.id_flex_num
       AND FIFS.application_id = 101
       AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME
       AND FIFS.application_id = FSAV.application_id
       AND FSAV.SEGMENT_ATTRIBUTE_TYPE = 'GL_ACCOUNT'
       AND FSAV.ATTRIBUTE_VALUE = 'Y'
       AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
       AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
       --AND nvl(FFV.ENABLED_FLAG, 'N') = 'Y'  --Including disabled accounts
       AND FFVT.FLEX_VALUE_ID = FFV.FLEX_VALUE_ID
       AND nvl(FFVT.LANGUAGE, userenv('LANG')) = userenv('LANG')
       --For account level, subsidiary account flag and item
       AND sub.acc_number(+) = FFV.FLEX_VALUE
       order by sub.acc_number
          ;

  BEGIN
    --1. Check whether any DFF assignment of Account Level, Project, Third Party,
    --     Cost Center and Personnel, and Balance Side has been set or not.
    --
    OPEN c_dff;
      FETCH c_dff INTO l_dff;
      IF c_dff%NOTFOUND OR
         l_dff <> 'YYYYYY'
      THEN
        RAISE JA_CN_INCOMPLETE_DFF_ASSIGN;
      END IF;
    CLOSE c_dff;

    --Get meaning of Subsidiary Accounts
    -- project meaning
    SELECT FLV.meaning
      INTO l_project_meaning
      FROM FND_LOOKUP_VALUES                   FLV
     WHERE FLV.lookup_code = 'PJ'
       and FLV.lookup_type = 'JA_CN_SUBSIDIARY_GROUP'
       and FLV.LANGUAGE = userenv('LANG')
          ;
    -- third party meaning
    SELECT FLV.meaning
      INTO l_thirdparty_meaning
      FROM FND_LOOKUP_VALUES                   FLV
     WHERE FLV.lookup_code = 'TP'
       and FLV.lookup_type = 'JA_CN_SUBSIDIARY_GROUP'
       and FLV.LANGUAGE = userenv('LANG')
          ;
    -- supplier meaning
    SELECT FLV.meaning
      INTO l_supplier_meaning
      FROM FND_LOOKUP_VALUES                   FLV
     WHERE FLV.lookup_code = 'S'
       and FLV.lookup_type = 'JA_CN_THIRDPARTY_TYPE'
       and FLV.LANGUAGE = userenv('LANG')
          ;
    -- custmor meaning
    SELECT FLV.meaning
      INTO l_customer_meaning
      FROM FND_LOOKUP_VALUES                   FLV
     WHERE FLV.lookup_code = 'C'
       and FLV.lookup_type = 'JA_CN_THIRDPARTY_TYPE'
       and FLV.LANGUAGE = userenv('LANG')
          ;

    -- cost center meaning
    SELECT FLV.meaning
      INTO l_costcenter_meaning
      FROM FND_LOOKUP_VALUES                   FLV
     WHERE FLV.lookup_code = 'CC'
       and FLV.lookup_type = 'JA_CN_SUBSIDIARY_GROUP'
       and FLV.LANGUAGE = userenv('LANG')
          ;
    -- person meaning
    SELECT FLV.meaning
      INTO l_personnel_meaning
      FROM FND_LOOKUP_VALUES                   FLV
     WHERE FLV.lookup_code = 'PERSON'
       and FLV.lookup_type = 'JA_CN_SUBSIDIARY_GROUP'
       and FLV.LANGUAGE = userenv('LANG')
          ;
    --get the coa ID from the DNS
    -- chart of accounts ID from the parameter.
    /*    IF l_access_set_id >= 0 THEN
        l_coa_id := ja_cn_utility.Get_Coa(p_Access_Set_Id => l_access_set_id);
    END IF;*/




    --2. Get account structure from system form and get its segments' length.
    --Get account structure , and enterprise flag
/*    SELECT nvl(SYS_PAR.ACCOUNT_STRUCTURE, '')  acc_str
          \*,nvl(SYS_PAR.ENT_FLAG, 'ENT')        ent_flag*\
      INTO l_na_acc_str
          \*,l_ent_flag*\
      FROM JA_CN_SYSTEM_PARAMETERS_ALL         SYS_PAR
     WHERE SYS_PAR.LEGAL_ENTITY_ID = P_LE_ID   --using parameter P_LE_ID*/

     --Using dynamitc sql to fetch account structure. The view
     --  'ja_cn_account_structures_kfv' doesn't exist when creating patch.
/*    SELECT nvl(ACC_STR_V.concatenated_segments, '')  acc_str
      INTO l_na_acc_str
      FROM JA_CN_SYSTEM_PARAMETERS_ALL         SYS_PAR
          ,ja_cn_account_structures_kfv        ACC_STR_V
     WHERE ACC_STR_V.account_structure_id = SYS_PAR.ACCOUNT_STRUCTURE_ID
       AND SYS_PAR.LEGAL_ENTITY_ID = P_LE_ID   --using parameter P_LE_ID
          ;*/
    l_sql :=
      'SELECT '
     ||'     nvl(ACC_STR_V.concatenated_segments, '''')  acc_str   '
     ||' FROM Ja_Cn_Sub_Acc_Sources_All                SYS_PAR     '
     ||'     ,' || l_account_structures_kfv || '       ACC_STR_V   '
     ||'WHERE ACC_STR_V.account_structure_id = SYS_PAR.ACCOUNTING_STRUCT_ID'
     ||'  AND SYS_PAR.CHART_OF_ACCOUNTS_ID =  ' || l_coa_id  --using parameter P_LE_ID
          ;
    EXECUTE IMMEDIATE l_sql into l_na_acc_str;

    --Get delimiter label
    BEGIN
    SELECT distinct FIFStr.Concatenated_Segment_Delimiter
      INTO l_delimiter_label
      FROM FND_ID_FLEX_STRUCTURES              FIFStr
     WHERE FIFStr.APPLICATION_ID=7000
       AND FIFStr.ID_FLEX_CODE='ACCT'          --JA_CN_ACCOUNT_STRUCTURES
/*      FROM GL_SETS_OF_BOOKS                    SOB
          ,FND_ID_FLEX_STRUCTURES              FIFStr
     WHERE SOB.set_of_books_id = l_sob_id      --using variable l_sob_id
       AND FIFStr.APPLICATION_ID=7000
       AND FIFStr.ID_FLEX_CODE='ACCT'          --JA_CN_ACCOUNT_STRUCTURES
       AND FIFStr.ID_FLEX_NUM = SOB.chart_of_accounts_id*/
          ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_delimiter_label := ',';
          /*IF(l_proc_level >= l_dbg_level)
          THEN
            FND_LOG.string( l_proc_level
                           ,l_module_prefix||'.'||l_proc_name||'.NO_DATA_FOUND'
                           ,'The delimiter of account structure has not defined.'
                          );
          END IF;
          RAISE;*/
       WHEN OTHERS THEN
         l_delimiter_label := ',';
    END;

    --Get account segments' length
    l_na_acc_str_2 := l_na_acc_str || l_delimiter_label; --l_na_acc_str has at least 1 segment.
    l_acc_seg_serial := 1;
    l_acc_segments := t_acc_level_segments();
    l_acc_segments.EXTEND(15);
    l_acc_seg_lens := t_level_seg_lens();
    l_acc_seg_lens.EXTEND(15);
    WHILE l_na_acc_str_2 is not null LOOP
      l_acc_segment := trim(substr(l_na_acc_str_2, 1,
                              instr(l_na_acc_str_2, l_delimiter_label, 1)-1
                             ));
      l_na_acc_str_2 := substr(l_na_acc_str_2,
                               instr(l_na_acc_str_2, l_delimiter_label, 1)+1,
                               length(l_na_acc_str_2)
                              );

      --Do not check the segment is natural number or not here.
      l_acc_segments(l_acc_seg_serial) := TO_NUMBER(l_acc_segment);
      IF l_acc_seg_serial = 1
      THEN
        l_acc_seg_lens(l_acc_seg_serial) := l_acc_segments(l_acc_seg_serial);
      ELSE
        l_acc_seg_lens(l_acc_seg_serial) := l_acc_seg_lens(l_acc_seg_serial -1 ) +
                                            l_acc_segments(l_acc_seg_serial);
      END IF;
      l_acc_seg_serial := l_acc_seg_serial + 1;
    END LOOP; --WHILE l_na_acc_str_2 is not null LOOP
    -- dbms_output.put_line(l_acc_seg_lens.count); --l_acc_seg_lens.count=15!!!
    l_acc_seg_serial := l_acc_seg_serial - 1; --count of segments of account structure

    --3. Generate the account level and subsidiary flag and items
    Get_Acc_Subs_View(P_LEDGER_ID => l_ledger_id
                     ,P_COA_ID    => l_coa_id);

    /*-----for test----------------------------------------
    FND_FILE.put_line(FND_FILE.output,'==Get_Acc_Subs_View:P_COA_ID=='||P_COA_ID ||'==P_LEDGER_ID='||P_LEDGER_ID);
    -----for test----------------------------------------*/

    --4. Go through all the natural accounts with a natural number marked in
    --  "Level" field and lists all invalid accounts in invalid account table
    --  JA_CN_COA_NA_EXCEPTION.
    l_na_curr_req_id := FND_GLOBAL.CONC_REQUEST_ID; --id of current request

    OPEN c_na_info;
    LOOP -- Loop for all natural accounts
      FETCH c_na_info INTO l_na_number
                          ,l_na_name
                          ,l_na_parent
                          ,l_acc_type_code
                          ,l_na_level
                          ,l_na_sub_flag
                          ,l_na_sub_item
                          ,l_acc_bal_code
                          ;
      EXIT WHEN c_na_info%NOTFOUND;

      --Only consider accounts with level, and the level should be a natural number and <16
      IF  JA_CN_UTILITY.Check_Account_Level(l_na_level)/*l_na_level is not null AND Is_Natural_Number(l_na_level) = 1 and l_na_level < 16*/
      THEN
        l_length := LENGTH(TO_CHAR(l_na_number)); --length of l_na_number

        IF l_acc_seg_serial >= l_na_level THEN    --l_na_acc_str has l_na_level segments
          --l_expected_length is sum first l_na_level segements of l_na_acc_str
          l_expected_length := l_acc_seg_lens(l_na_level);
        ELSE
          l_expected_length := -1;
        END IF;

        IF l_length <> l_expected_length
        THEN
          --Insert a row of account number, level, length, expected length,
          --  account structure, and current request id into invalid account
          --  table JA_CN_COA_NA_EXCEPTIONS
          INSERT INTO JA_CN_COA_NA_EXCEPTIONS
                ( ACCOUNT_SEGMENT
                 ,ACCOUNT_LEVEL
                 ,VALUE_LENGTH
                 ,EXPECTED_LENGTH
                 ,ACCOUNT_STRUCTURE
                 ,NA_REQUEST_ID
                 ,CREATED_BY
                 ,CREATION_DATE
                 ,LAST_UPDATED_BY
                 ,LAST_UPDATE_DATE
                 ,LAST_UPDATE_LOGIN
                )
          VALUES( l_na_number
                 ,l_na_level
                 ,l_length
                 ,l_expected_length
                 ,l_na_acc_str
                 ,l_na_curr_req_id
                 ,fnd_global.user_id
                 ,SYSDATE
                 ,fnd_global.user_id
                 ,SYSDATE
                 ,fnd_global.LOGIN_ID
                );
        END IF; --Value length
      END IF; --Account Level should not null and be a natural number and <16
    END LOOP;
    CLOSE c_na_info;

    -- 3. Checks if the invalid account table JA_CN_COA_NA_EXCEPTIONS has any row.
    --   If YES then records error in output and submits a request to generate
    --      exception report;
    --   ELSE goes on to collect all natural accounts. <NOT all lowest level ones>
    SELECT count(*)
      INTO l_exceptions_count
      FROM JA_CN_COA_NA_EXCEPTIONS
     WHERE NA_REQUEST_ID = l_na_curr_req_id
          ;

    IF l_exceptions_count > 0 --JA_CN_COA_NA_EXCEPTIONS has row
    THEN
      l_xml_layout := FND_REQUEST.ADD_LAYOUT( template_appl_name  => 'JA'
                                             ,template_code       => 'JACNNAER'
                                             ,template_language   => l_template_language --'zh' ('en')
                                             ,template_territory  => l_template_territory--'00' ('US')
                                             ,output_format       => l_output_format     --'RTF'('PDF')
                                            );
      /*IF NOT(l_xml_layout) THEN --failded to add layout, report it.
        RAISE JA_CN_ADD_LAYOUT_FAILED;
      END IF;*/

      --Submit the concurrent program 'Generating Natural Account Export Exception Report'
      l_na_req_id := FND_REQUEST.Submit_Request( application=> 'JA'
                                                ,program    => 'JACNNAER'
                                                ,argument1  => to_number(l_na_curr_req_id)
                                               );
      COMMIT;

      /*------------for test---------------------------------
      FND_FILE.put_line(FND_FILE.output,'===='||l_na_curr_req_id ||'==='||l_na_req_id||'=--'||l_exceptions_count||'-----------submit request');
      ------------for test---------------------------------*/

      --Waiting for the 'Generating Natural Account Export Exception Report' completed.
      IF l_na_req_id <> 0
      THEN
        IF FND_CONCURRENT.Wait_For_Request( request_id   => l_na_req_id
                                           ,interval     => 5
                                           ,max_wait     => 0
                                           ,phase        => l_na_req_phase
                                           ,status       => l_na_req_status
                                           ,dev_phase    => l_na_req_dev_phase
                                           ,dev_status   => l_na_req_dev_status
                                           ,message      => l_na_req_message
                                          )
        THEN
          IF l_na_req_phase = 'Completed'
          THEN
            null;
          END IF; --l_na_req_phase = 'Completed'
        END IF; -- FND_CONCURRENT.Wait_For_Request ...
      END IF; --l_na_req_id<>0

     /* ------------for test---------------------------------
      FND_FILE.put_line(FND_FILE.output,l_na_req_phase ||'-----------Wait_For_Request');
      ------------for test---------------------------------*/

      --DELETE rows with l_na_curr_req_id in TABLE JA_CN_COA_NA_EXCEPTIONS;
      DELETE
        FROM JA_CN_COA_NA_EXCEPTIONS
       WHERE NA_REQUEST_ID = l_na_curr_req_id;
      COMMIT;

      --Report that there have invalid accounts
      RAISE JA_CN_INVALID_ACCOUNT_STRU;

    ELSE --The invalid account table has no row, so outputs all natural accounts <NOT all lowest level ones>
      /*FND_FILE.put_line(FND_FILE.output,
                        RPAD('Number',10, ' ')
                        ||'|  '|| RPAD('Name',40,' ')
                        ||'|  '|| RPAD('Level',10,' ')
                        ||'|  '|| RPAD('Subsidiary account flag',1,' ')
                        ||'|  '|| RPAD('Subsidiary account item',50,' ')
                        ||'|  '|| RPAD('Account type',20,' ')
                        ||'|  '|| RPAD('Measurement',20,' ')
                        ||'|  '|| RPAD('Balance side',10,' '));*/

    	l_row_count := 0;

      /*IF l_ent_flag = 'ENT'
      THEN
        l_ent_acc_type := 'JA_CN_ENT_ACCOUNT_TYPE';
      ELSIF l_ent_flag = 'PUB'
      THEN
        l_ent_acc_type := 'JA_CN_PS_ACCOUNT_TYPE';
      END IF;*/
      l_ent_acc_type := 'ACCOUNT_TYPE';

      OPEN c_na_info;
      LOOP -- Loop for all natural accounts
        FETCH c_na_info INTO l_na_number
                            ,l_na_name
                            ,l_na_parent
                            ,l_acc_type_code
                            ,l_na_level
                            ,l_na_sub_flag
                            ,l_na_sub_item
                            ,l_acc_bal_code
                            ;
        EXIT WHEN c_na_info%NOTFOUND;

        --Only consider accounts with level, and the level should be a natural number and <16
        IF JA_CN_UTILITY.Check_Account_Level(l_na_level)/*l_na_level is not null AND Is_Natural_Number(l_na_level) = 1 and l_na_level < 16*/
        THEN
          /*IF l_na_parent = 'N' THEN --Only export lowest level (not parent) accounts*/
            l_row_count := l_row_count + 1; --This account will be outputed

            --Get rid of '/' at the last position of subsidiary item
            l_na_sub_item := substr(l_na_sub_item, 1, length(l_na_sub_item)-1);

            --Get UOM
            BEGIN
            SELECT DISTINCT
                   nvl(UOM.UNIT_OF_MEASURE, '')        acc_uom
              INTO l_na_mea
              FROM GL_LEDGERS                          LEDGER
                  ,GL_STAT_ACCOUNT_UOM                 UOM
             WHERE LEDGER.ledger_id = l_ledger_id          --using variable l_sob_id
               AND UOM.CHART_OF_ACCOUNTS_ID = LEDGER.CHART_OF_ACCOUNTS_ID
               AND UOM.ACCOUNT_SEGMENT_VALUE = l_na_number --using variable l_na_number
                  ;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_na_mea := '';
            END;

            --Get Account type and Balance side
            IF l_acc_type_code is not null
            THEN
              BEGIN
              SELECT nvl(FLV.meaning,'')                 acc_type
                    ,FLV1.meaning                        acc_bal_side
                INTO l_na_type
                    ,l_na_bal
                FROM FND_LOOKUP_VALUES                   FLV
                    ,FND_LOOKUP_VALUES                   FLV1
               WHERE --Get meaning of account type
                     FLV.lookup_code = l_acc_type_code   --using variable l_acc_type_code
                 AND FLV.lookup_type = l_ent_acc_type    --'ACCOUNT_TYPE'
                 and FLV.LANGUAGE = userenv('LANG')
                 --The following 3 conditions should be remained
                 AND ( nvl('', FLV.territory_code) = FLV.territory_code
                       or FLV.territory_code is null )
                 AND FLV.VIEW_APPLICATION_ID = 0
                 AND FLV.SECURITY_GROUP_ID = 0
                 --Get meaning of balance side
                 AND FLV1.lookup_code = DECODE(
                        l_acc_type_code,                            --using variable l_acc_type_code
                        'A', DECODE(l_acc_bal_code, 'C', 'C', 'D'), --using variable l_acc_bal_code
                        'E', DECODE(l_acc_bal_code, 'C', 'C', 'D'),
                        'L', DECODE(l_acc_bal_code, 'D', 'D', 'C'),
                        'O', DECODE(l_acc_bal_code, 'D', 'D', 'C'),
                        'R', DECODE(l_acc_bal_code, 'D', 'D', 'C')
                     )
                 AND FLV1.lookup_type = 'JA_CN_DEBIT_CREDIT'--'DEBIT_CREDIT'
                 AND FLV1.LANGUAGE = userenv('LANG')
                 /*and ( nvl('', FLV1.territory_code) = FLV1.territory_code
                       or FLV1.territory_code is null )
                 and FLV1.VIEW_APPLICATION_ID = 3
                 and FLV1.SECURITY_GROUP_ID = 0*/
                    ;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_na_type := '';
                  l_na_bal := '';
              END;
            ELSE
              l_na_type := '';
              l_na_bal := '';
            END IF; --l_acc_type_code is null or not

            --Output a row of account in TXT file with columns account number,
            --  name, level, sub flag, sub item, type, measurement, balance side
            /*FND_FILE.put_line(FND_FILE.output,
                              RPAD(l_na_number,10, ' ')
                              ||'|  '|| RPAD(nvl(l_na_name,' '),40,' ')
                              ||'|  '|| RPAD(nvl(l_na_level,' '),10,' ')
                              ||'|  '|| RPAD(nvl(l_na_sub_flag,' '),1,' ')
                              ||'|  '|| RPAD(nvl(l_na_sub_item,' '),50,' ')
                              ||'|  '|| RPAD(nvl(l_na_type,' '),20,' ')
                              ||'|  '|| RPAD(nvl(l_na_mea,' '),20,' ')
                              ||'|  '|| RPAD(nvl(l_na_bal,' '),10,' '));*/
            FND_FILE.put_line(FND_FILE.output,
                                              '"' ||l_na_number   || '"'
                              ||l_seperator|| '"' ||l_na_name     || '"'
                              ||l_seperator||       l_na_level
                              ||l_seperator|| '"' ||l_na_sub_flag || '"'
                              ||l_seperator|| '"' ||l_na_sub_item || '"'
                              ||l_seperator|| '"' ||l_na_type     || '"'
                              ||l_seperator|| '"' ||l_na_mea      || '"'
                              ||l_seperator|| '"' ||l_na_bal      || '"'
                             );
        END IF; --Account Level should not null and be a natural number and <16
      END LOOP;
      CLOSE c_na_info;

    	IF l_row_count = 0 --No account been outputed
      THEN
    	  raise JA_CN_NO_DATA_FOUND;
    	END IF;

    END IF; --The invalid account table has row or not

    retcode := 0;
    errbuf  := '';
    EXCEPTION
      WHEN JA_CN_NO_DATA_FOUND THEN
        --FND_FILE.put_line(FND_FILE.output, l_msg_no_data_found);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_NO_DATA_FOUND '
                         ,l_msg_no_data_found);
        END IF;
        retcode := 1;
        errbuf  := l_msg_no_data_found;

      WHEN JA_CN_INCOMPLETE_DFF_ASSIGN THEN
        FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                             ,NAME => 'JA_CN_INCOMPLETE_DFF_ASSIGN'
                            );
        l_msg_incomplete_dff_assign := FND_MESSAGE.Get;

        FND_FILE.put_line(FND_FILE.output, l_msg_incomplete_dff_assign);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_INCOMPLETE_DFF_ASSIGN '
                         ,l_msg_incomplete_dff_assign);
        END IF;
        retcode := 1;
        errbuf  := l_msg_incomplete_dff_assign;

      WHEN JA_CN_INVALID_ACCOUNT_STRU THEN
        FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                             ,NAME => 'JA_CN_INVALID_ACCOUNT_STRU'
                            );
        FND_MESSAGE.SET_TOKEN('REQUEST_ID', TO_CHAR(l_na_req_id));
        l_msg_invalid_account_stru := FND_MESSAGE.Get;

        FND_FILE.put_line(FND_FILE.output, l_msg_invalid_account_stru);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_INVALID_ACCOUNT_STRU '
                         ,l_msg_invalid_account_stru);
        END IF;
        retcode := 1;
        errbuf  := l_msg_invalid_account_stru;

    /*  ------------for test---------------------------------
      FND_FILE.put_line(FND_FILE.output,l_msg_invalid_account_stru ||'-----------exception');
      ------------for test---------------------------------
      */
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM);
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;
  END  Coa_NA_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Coa_PJ_Export                 Private
  --
  --  DESCRIPTION:
  --      This procedure exporting the Project list as "subsidiary account"
  --      into format predefined flat file.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              Chart of account ID
  --      In: P_LEDGER_ID             NUMBER              ID of Set Of Book
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated:
  --                                             REPLACE TABLE:SOB WITH TABLE: LEDGER AND SOURCE
  --===========================================================================
  PROCEDURE  Coa_PJ_Export( errbuf          OUT NOCOPY VARCHAR2
                           ,retcode         OUT NOCOPY VARCHAR2
                           ,P_COA_ID        IN NUMBER
                           ,P_LEDGER_ID     IN NUMBER
                           ,P_LE_ID         IN NUMBER
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Coa_PJ_Export';

    l_ledger_id                         NUMBER := P_LEDGER_ID;
    l_le_id                             NUMBER := P_LE_ID;
    l_seperator                         varchar2(1) := FND_GLOBAL.Local_Chr(9); --' ';

    /*JA_CN_PROJ_NOT_CONSIDER             exception;
    --JA_CN_NO_PROJ_DEFINED               exception;
    l_msg_proj_not_consider             varchar2(2000);
    --l_msg_no_proj_defined               varchar2(2000);*/

    l_row_count                         NUMBER;       --count of rows
    --l_pj_source                         VARCHAR2(150);--VARCHAR2(3);  --project data source set in GL GDF
    --l_pj_ps                             VARCHAR2(150);--VARCHAR2(2);  --project segment in GL GDF set or not

    l_pj_number                         JA_CN_ACCOUNT_BALANCES.project_number%TYPE;
    l_pj_name                           VARCHAR2(240);

    /*--Cursor to get project data source, set in GDF, from table GL_SETS_OF_BOOKS
    CURSOR c_pj_setup IS
    SELECT nvl(GLOBAL_ATTRIBUTE1, 'N')
          ,nvl(GLOBAL_ATTRIBUTE3, '')  --DECODE(nvl(GLOBAL_ATTRIBUTE3, ''), '', '', 'PS')
      FROM GL_SETS_OF_BOOKS
     WHERE set_of_books_id = l_sob_id
       AND global_attribute_category = 'JA.CN.GLXSTBKS.BOOKS';*/

    --Cursor to get project_number from table JA_CN_ACCOUNT_BALANCES, and name from table
    --  PA_PROJECTS_ALL or FND_FLEX_VALUES_TL.
    --If two projects from PA and COA are with a same number and same name then
    --  only show them one time.
    CURSOR c_pj IS
      SELECT *
      FROM (
        --Get name for projects from project module
        SELECT DISTINCT
               BAL.project_number                  pj_number
              ,nvl(PPA.name, '')                   pj_name    --name for project from PA
          FROM JA_CN_ACCOUNT_BALANCES              BAL
              ,PA_PROJECTS_ALL                     PPA
         WHERE BAL.Ledger_Id= l_ledger_id                 --using variable l_sob_id
           AND BAL.account_segment IS NOT NULL
           AND nvl(BAL.project_source, 'N') = 'PA'
           and BAL.project_number IS NOT NULL
           --AND PPA.project_id = BAL.PROJECT_ID --PROJECT_ID is no use here, replaced it.
           AND PPA.SEGMENT1 = BAL.project_number

        UNION

        --Get name for projects from COA
        SELECT DISTINCT
               BAL.project_number                  pj_number
              ,nvl(FFVT.description, '')           pj_name    --name for project from COA
          FROM JA_CN_ACCOUNT_BALANCES              BAL
              ,GL_LEDGERS                          LEDGER
              ,Ja_Cn_Sub_Acc_Sources_All           SUBAS
              ,FND_ID_FLEX_SEGMENTS                FIFS
              ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV
              ,FND_FLEX_VALUE_SETS                 FFVS
              ,FND_FLEX_VALUES_TL                  FFVT
              ,FND_FLEX_VALUES                     FFV
         WHERE BAL.Ledger_Id= l_ledger_id                                --using variable l_sob_id
           AND BAL.account_segment IS NOT NULL
           AND nvl(BAL.project_source, 'N') = 'COA'
           and BAL.project_number IS NOT NULL
           --Get project name. --PROJECT_ID is no use here, replaced it.
           AND FFV.FLEX_VALUE = BAL.project_number
           AND LEDGER.ledger_id = BAL.ledger_id
           AND LEDGER.chart_of_accounts_id = FIFS.id_flex_num
           AND FIFS.id_flex_num = FSAV.id_flex_num
           AND SUBAS.CHART_OF_ACCOUNTS_ID = LEDGER.CHART_OF_ACCOUNTS_ID  -- ?? NOT SURE
           AND ( ( nvl(SUBAS.PROJECT_SOURCE_FLAG, 'N') = 'COA'           --Currently it's from COA
                  and SUBAS.COA_SEGMENT = FSAV.APPLICATION_COLUMN_NAME
                )
                OR --It's a old one
                ( (nvl(SUBAS.PROJECT_SOURCE_FLAG, 'N') = 'N' OR nvl(SUBAS.PROJECT_SOURCE_FLAG, 'N') = 'PA')
                  and SUBAS.HISTORY_COA_SEGMENT = FSAV.APPLICATION_COLUMN_NAME
                )
              )
           AND FIFS.application_id = 101
           AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME
           AND FIFS.application_id = FSAV.application_id
           AND FSAV.ATTRIBUTE_VALUE = 'Y'
           AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
           AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
           AND FFVT.flex_value_id = FFV.flex_value_id
           AND nvl(FFVT.LANGUAGE, userenv('LANG')) = userenv('LANG')
        ) tmp_pj_tbl
    -- add order by to keep the output item's seqence
    order by tmp_pj_tbl.pj_number
          ;

  BEGIN
  	--1. Check setups
  	/*OPEN c_pj_setup;
  	  FETCH c_pj_setup INTO l_pj_source
                           ,l_pj_ps
                           ;
  	CLOSE c_pj_setup;
  	IF l_pj_source = 'N' THEN             --'Project not considered'
  	  RAISE JA_CN_PROJ_NOT_CONSIDER;
    \*ELSIF l_pj_source = 'COA' THEN        --'Chart of account'
      IF l_pj_ps <> 'PS' THEN             --'Project segment'
  	    RAISE JA_CN_NO_PROJ_DEFINED;
  	  END IF;*\
  	END IF;*/

  	/*FND_FILE.put_line(FND_FILE.output,
                      RPAD('Number',10, ' ')
                      ||'|  '|| RPAD('Description',40,' '));*/

  	--2. Export all projects into the format predefined flat file
  	l_row_count := 0;
  	OPEN c_pj;
  	LOOP        -- Loop for all projects
  	  FETCH c_pj INTO l_pj_number
                     ,l_pj_name
                     ;
  	  EXIT WHEN c_pj%NOTFOUND;
	    l_row_count := l_row_count+1;
	    --Output a row of project in TXT file with columns project number, description
    	/*FND_FILE.put_line(FND_FILE.output,
                        RPAD(l_pj_number,10, ' ')
                        ||'|  '|| RPAD(l_pj_name,40,' '));*/
      FND_FILE.put_line(FND_FILE.output,
                                        '"' ||l_pj_number   || '"'
                        ||l_seperator|| '"' ||l_pj_name     || '"'
                       );
  	END LOOP;
  	CLOSE c_pj;
  	IF l_row_count = 0  --No data found
    THEN
  	  RAISE JA_CN_NO_DATA_FOUND;
  	END IF;

    retcode := 0;
    errbuf  := '';
  	EXCEPTION
      WHEN JA_CN_NO_DATA_FOUND THEN
        --FND_FILE.put_line(FND_FILE.output, l_msg_no_data_found);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_NO_DATA_FOUND '
                         ,l_msg_no_data_found);
        END IF;
        retcode := 1;
        errbuf  := l_msg_no_data_found;
      /*WHEN JA_CN_PROJ_NOT_CONSIDER THEN
        FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                             ,NAME => 'JA_CN_PROJ_NOT_CONSIDER'
                            );
        l_msg_proj_not_consider := FND_MESSAGE.Get;

        FND_FILE.put_line(FND_FILE.output, l_msg_proj_not_consider);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_PROJ_NOT_CONSIDER '
                         ,l_msg_proj_not_consider);
        END IF;
        retcode := 1;
        errbuf  := l_msg_proj_not_consider;*/
    	/*WHEN JA_CN_NO_PROJ_DEFINED THEN
        FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                             ,NAME => 'JA_CN_NO_PROJ_DEFINED'
                            );
        l_msg_no_proj_defined := FND_MESSAGE.Get;
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_NO_PROJ_DEFINED '
                         ,l_msg_no_proj_defined);
        END IF;
        retcode := 1;
        errbuf  := l_msg_no_proj_defined;*/
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;
  END  Coa_PJ_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Coa_TP_Export                 Private
  --
  --  DESCRIPTION:
  --      This procedure exporting the Third Party list as "subsidiary account"
  --      into format predefined flat file.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              Chart of account ID
  --      In: P_LEDGER_ID             NUMBER              ID of Set Of Book
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated
  --      05/19/2009     Chaoqun Wu          Updated for fixing bug#8420682
  --===========================================================================
  PROCEDURE  Coa_TP_Export( errbuf          OUT NOCOPY VARCHAR2
                           ,retcode         OUT NOCOPY VARCHAR2
                           ,P_COA_ID        IN NUMBER
                           ,P_LEDGER_ID     IN NUMBER
                           ,P_LE_ID         IN NUMBER
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Coa_TP_Export';

	  l_ledger_id                         NUMBER := P_LEDGER_ID;                  -- LEDGER ID
    l_le_id                             NUMBER := P_LE_ID;                      -- LEGAL ENTITY ID
    l_coa_id                            NUMBER := P_COA_ID;                     -- CHART OF ACCOUT ID
    l_seperator                         varchar2(1) := FND_GLOBAL.Local_Chr(9); --' ';

    l_sup_meaning                       VARCHAR2(50);
    l_cust_meaning                      VARCHAR2(50);

    l_row_count                         NUMBER;        --count of rows
    l_tp_number                         VARCHAR2(100);
    l_tp_name                           VARCHAR2(360);
    l_tp_ctg_number                     VARCHAR2(60);
    l_tp_territory                      VARCHAR2(100);
    l_tp_phonenumber                    VARCHAR2(100);
    l_tp_address                        VARCHAR2(240);
    l_tp_credit_level                   VARCHAR2(60);

    --For supplier
    l_vender_id                         PO_VENDORS.VENDOR_ID%TYPE;
    --For city and address of supplier
    TYPE t_sup_city_addr IS RECORD     ( city      PO_VENDOR_SITES_ALL.CITY%TYPE
                                        ,addr      PO_VENDOR_SITES_ALL.ADDRESS_LINE1%TYPE
                                        );
    TYPE t_sup_city_addr_array IS TABLE OF t_sup_city_addr;
    l_all_sup_city_addr                    t_sup_city_addr_array;
    l_sup_city_addr                        t_sup_city_addr;
    --For phone number of supplier
    TYPE t_sup_phone_array IS TABLE OF     VARCHAR2(100);
    l_all_sup_phone                        t_sup_phone_array;

    --For Customer
    l_cust_account_id                      HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE;
    l_party_id                             HZ_CUST_ACCOUNTS.PARTY_ID%TYPE;
    --For city and address of Customer
    TYPE t_cust_city_addr IS RECORD       ( city      HZ_LOCATIONS.CITY%TYPE
                                           ,addr      HZ_LOCATIONS.address1%TYPE
                                           );
    TYPE t_cust_city_addr_array IS TABLE OF t_cust_city_addr;
    l_all_cust_city_addr                   t_cust_city_addr_array;
    l_cust_city_addr                       t_cust_city_addr;
    --For phone number of Customer
    TYPE t_cust_phone IS RECORD           ( priority  VARCHAR2(10)
                                           ,phone     VARCHAR2(100)
                                           );
    TYPE t_cust_phone_array IS TABLE OF    t_cust_phone;
    l_all_cust_phone                       t_cust_phone_array;
    l_cust_phone                           t_cust_phone;

    --Cursor to get basic info for suppliers included in table JA_CN_ACCOUNT_BALANCES
    --Except Territory, Phone number, and Address
    CURSOR c_tp_sup IS
      SELECT *
      FROM (
          SELECT DISTINCT
                 PV.vendor_id                        vender_id
                /*,'S'||nvl(PV.SEGMENT1, '')           sup_number*/
--??                ,nvl(PV.SEGMENT1, '')                sup_number --column vendor_number of view AP_VENDORS_V
                ,nvl(BAL.Third_Party_Number,'')      sup_number     -- temp solutin ????
                ,nvl(PV.VENDOR_NAME, '')             sup_name
                /*,nvl(LC_TYPE.DISPLAYED_FIELD, '')    sup_type   --vendor_type_disp*/
                ,''
            FROM JA_CN_ACCOUNT_BALANCES              BAL
                ,PO_VENDORS                          PV
                /*,PO_LOOKUP_CODES                     LC_TYPE*/
           WHERE BAL.Ledger_Id = l_ledger_id                 --using variable l_sob_id
             AND BAL.account_segment IS NOT NULL
             AND BAL.THIRD_PARTY_ID IS NOT NULL
             AND nvl(BAL.THIRD_PARTY_TYPE, 'X') = 'S'
             AND BAL.THIRD_PARTY_ID = PV.vendor_id
          ) tmp_sup_tbl
       -- add order by to keep the output item's seqence
       ORDER BY tmp_sup_tbl.sup_number
       /*-- Type
       AND LC_TYPE.LOOKUP_CODE(+) = PV.VENDOR_TYPE_LOOKUP_CODE
       and LC_TYPE.LOOKUP_TYPE(+) = 'VENDOR TYPE'*/
          ;

    --Cursor to get basic info for customers of current SOB
    --Except Territory, Phone number, and Address
    CURSOR c_tp_cust IS
       SELECT *
       FROM (
           SELECT DISTINCT
                 CUST.CUST_ACCOUNT_ID                cust_account_id
                ,CUST.PARTY_ID                       party_id
                /*,'C'||nvl(CUST.ACCOUNT_NUMBER, '')   cust_number*/
--??               ,nvl(CUST_PARTY.Party_Number, '')    cust_number   -- take hz_parties.Party_Number to keep consistency with sla export
                --,nvl(BAL.Third_Party_Number,'')      cust_number     -- temp solutin ???? --Deleted by Chaoqun for fixing bug#8420682 on 19-May-2009
                ,nvl(CUST_PARTY.PARTY_NUMBER,'')     cust_number  --Updated by Chaoqun for fixing bug#8420682 on 19-May-2009
                ,nvl(CUST_PARTY.PARTY_NAME, '')      cust_name
                /*,nvl(L_CLASS.MEANING, '')            cust_class  --CUSTOMER_CLASS_MEANING*/
                ,nvl(CP.CREDIT_RATING, '')           cust_credit
            FROM JA_CN_ACCOUNT_BALANCES              BAL
                ,HZ_CUST_ACCOUNTS                    CUST
                ,HZ_PARTIES                          CUST_PARTY
                /*,AR_LOOKUPS                          L_CLASS*/
                ,HZ_CUSTOMER_PROFILES                CP
           WHERE BAL.Ledger_Id = l_ledger_id                 --using variable l_ledger_id
             AND BAL.LEGAL_ENTITY_ID=l_le_id                 --using variable l_le_id
             AND BAL.account_segment IS NOT NULL
             AND BAL.THIRD_PARTY_ID IS NOT NULL
             AND nvl(BAL.THIRD_PARTY_TYPE, 'X') = 'C'
             AND BAL.THIRD_PARTY_ID = CUST.CUST_ACCOUNT_ID
             AND CUST.PARTY_ID = CUST_PARTY.PARTY_ID
             /*-- Class
             AND CUST.CUSTOMER_CLASS_CODE = L_CLASS.LOOKUP_CODE(+)
             and L_CLASS.LOOKUP_TYPE(+) = 'CUSTOMER CLASS'*/
             -- Credit rating
             AND CP.CUST_ACCOUNT_ID(+) = CUST.CUST_ACCOUNT_ID
             and CP.site_use_id is null
         )  tmp_cst_tbl
     -- add order by to keep the output item's seqence
     order by tmp_cst_tbl.cust_number
          ;

  BEGIN
  	/*FND_FILE.put_line(FND_FILE.output,
                      RPAD('Number',10, ' ')
                      ||'|  '|| RPAD('Name',40,' ')
                      ||'|  '|| RPAD('Category',20,' ')
                      ||'|  '|| RPAD('Territory',20,' ')
                      ||'|  '|| RPAD('Phone',20,' ')
                      ||'|  '|| RPAD('Address',40,' ')
                      ||'|  '|| RPAD('Credit Level',20,' '));*/

    --Get meaning of Supplier and Customer
    SELECT nvl(FLV.meaning,'')                 sup_meaning
          ,nvl(FLV1.meaning,'')                cust_meaning
      INTO l_sup_meaning
          ,l_cust_meaning
      FROM FND_LOOKUP_VALUES                   FLV
          ,FND_LOOKUP_VALUES                   FLV1
     WHERE FLV.lookup_code = 'S'
       AND FLV.lookup_type = 'JA_CN_THIRDPARTY_TYPE'
       AND FLV.LANGUAGE = userenv('LANG')
       AND FLV1.lookup_code = 'C'
       AND FLV1.lookup_type = 'JA_CN_THIRDPARTY_TYPE'
       AND FLV1.LANGUAGE = userenv('LANG')
          ;

  	l_row_count := 0;

  	--Export all third parties from Payable into the format predefined flat file
    l_tp_ctg_number:= l_sup_meaning;
  	OPEN c_tp_sup;
  	LOOP
  	  FETCH c_tp_sup INTO l_vender_id
                         ,l_tp_number
                         ,l_tp_name
                         /*,l_tp_ctg_number */
                         ,l_tp_credit_level
                         ;
  	  EXIT WHEN c_tp_sup%NOTFOUND;

      --Get Sup Territory/Address
      l_all_sup_city_addr := null;
      BEGIN
      SELECT DISTINCT
             nvl(PVSA.CITY, '')                  sup_city
             /* --JiaQian make it sure that get city from column 'city'
               nvl(PVSA.PROVINCE,
               nvl(PVSA.STATE, ''))              sup_city
             */
            ,nvl(PVSA.ADDRESS_LINE1, '')         sup_addr
        BULK COLLECT INTO                        l_all_sup_city_addr
        FROM PO_VENDOR_SITES_ALL                 PVSA
            ,HR_ORGANIZATION_INFORMATION         HOI
       WHERE --Check "Primary Pay" Vendor site of OUs under current LE
             HOI.org_information_context = 'Operating Unit Information'
         AND HOI.Org_Information2 = l_le_id                 --using variable l_le_id
         AND HOI.Org_Information3 = l_ledger_id             --using variable l_ledger_id
         AND PVSA.Org_id = HOI.ORGANIZATION_ID
         AND PVSA.vendor_id = l_vender_id                   --using variable l_vender_id
         and nvl(PVSA.PRIMARY_PAY_SITE_FLAG, 'N') = 'Y'
            ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_all_sup_city_addr := null;
      END;

      --Use city/addr only when there is just 1 record, otherwise leave blanks
      IF l_all_sup_city_addr.count = 1
      THEN
        l_sup_city_addr := l_all_sup_city_addr(1);
        l_tp_territory  := l_sup_city_addr.city;
        l_tp_address    := l_sup_city_addr.addr;
      ELSE
        l_tp_territory := '';
        l_tp_address := '';
      END IF; --sup city/addr

      --Get Sup Phone
      l_all_sup_phone := null;
      BEGIN
      /*--The "Primary Pay" site contact number defined under Contacts tab of supplier Site define page.
        SELECT DISTINCT
             '0' || DECODE(nvl(PVC.AREA_CODE, ''), '', '', PVC.AREA_CODE || '-')
                 || nvl(PVC.PHONE, '')           sup_phone
        BULK COLLECT INTO                        l_all_sup_phone
        FROM PO_VENDOR_CONTACTS                  PVC
            ,PO_VENDOR_SITES_ALL                 PVSA
            ,HR_ORGANIZATION_INFORMATION         HOI
       WHERE PVC.vendor_site_id = PVSA.vendor_site_id
             --Check "Primary Pay" Vendor site of OUs under current LE
         AND HOI.org_information_context = 'Operating Unit Information'
         AND HOI.Org_Information2 = l_le_id                 --using variable l_le_id
         AND HOI.Org_Information3 = l_sob_id                --using variable l_sob_id
         AND PVSA.Org_id = HOI.ORGANIZATION_ID
         AND PVSA.vendor_id = l_vender_id                   --using variable l_vender_id
         and nvl(PVSA.PRIMARY_PAY_SITE_FLAG, 'N') = 'Y'
            ;*/

        --The "Primary Pay" site Communication Voice number defined under General tab of supplier Site define page.
        -- relationship : ASSA.vendor_id-->ASSA.vendor_site_id-->PVC.vendor_site_id-->PVC.PHONE
        SELECT DISTINCT
               nvl(PVC.AREA_CODE, '')
                 || DECODE(NVL(PVC.AREA_CODE, ''),'','','-')
                 || nvl(PVC.PHONE, '')             sup_phone
        BULK COLLECT INTO                        l_all_sup_phone
        FROM  PO_VENDOR_CONTACTS                  PVC
             ,AP_SUPPLIER_SITES_ALL               ASSA
        WHERE PVC.VENDOR_SITE_ID=ASSA.VENDOR_SITE_ID
        AND   ASSA.VENDOR_ID=l_vender_id                   --using variable l_vender_id
        AND   nvl(ASSA.PRIMARY_PAY_SITE_FLAG, 'N') = 'Y';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_all_sup_phone := null;
      END;

      --Use phone number only when there is just 1 record, otherwise leave blank
      IF l_all_sup_phone.count = 1
      THEN
        l_tp_phonenumber := l_all_sup_phone(1);
      ELSE
        l_tp_phonenumber := '';
      END IF; --sup phone

	    l_row_count := l_row_count+1;
	    --Output a row of third party in TXT file with columns number, name,
      --  category, territory, phone number, address, credit_level
      /*FND_FILE.put_line(FND_FILE.output,
                        RPAD(l_tp_number,10, ' ')
                        ||'|  '|| RPAD(nvl(l_tp_name, ' '),40,' ')
                        ||'|  '|| RPAD(nvl(l_tp_ctg_number, ' '),20,' ')
                        ||'|  '|| RPAD(nvl(l_tp_territory, ' '),20,' ')
                        ||'|  '|| RPAD(nvl(l_tp_phonenumber, ' '),20,' ')
                        ||'|  '|| RPAD(nvl(l_tp_address, ' '),40,' ')
                        ||'|  '|| l_tp_credit_level);*/
      FND_FILE.put_line(FND_FILE.output,
                                        '"' ||l_tp_number       || '"'
                        ||l_seperator|| '"' ||l_tp_name         || '"'
                        ||l_seperator|| '"' ||l_tp_ctg_number   || '"'
                        ||l_seperator|| '"' ||l_tp_territory    || '"'
                        ||l_seperator|| '"' ||l_tp_phonenumber  || '"'
                        ||l_seperator|| '"' ||l_tp_address      || '"'
                        ||l_seperator|| '"' ||l_tp_credit_level || '"'
                       );
  	END LOOP;
  	CLOSE c_tp_sup;

  	--Export all third parties from Receivable into the format predefined flat file
    l_tp_ctg_number:= l_cust_meaning;
  	OPEN c_tp_cust;
  	LOOP
  	  FETCH c_tp_cust INTO l_cust_account_id
                          ,l_party_id
                          ,l_tp_number
                          ,l_tp_name
                          /*,l_tp_ctg_number*/
                          ,l_tp_credit_level
                          ;
  	  EXIT WHEN c_tp_cust%NOTFOUND;

      --Get Customer Territory/Address
      l_all_cust_city_addr := null;
      BEGIN
      SELECT DISTINCT
             nvl(LOC.CITY, '')                   cust_city
             /* --JiaQian make it sure that get city from column 'city'
               nvl(LOC.PROVINCE,
               nvl(LOC.STATE, ''))               sup_city
             */
            ,nvl(LOC.ADDRESS1, '')               cust_addr
        BULK COLLECT INTO                        l_all_cust_city_addr
        FROM HZ_CUST_ACCT_SITES_ALL              ADDR
            ,HZ_LOCATIONS                        LOC
            ,HZ_PARTY_SITES                      PARTY_SITE
            ,HZ_LOC_ASSIGNMENTS                  LOC_ASSIGN
            ,HZ_CUST_SITE_USES_ALL               SU
            ,HR_ORGANIZATION_INFORMATION         HOI
       WHERE --ADDR.CUST_ACCOUNT_ID alias CUSTOMER_ID in AR_ADDRESSES_V
             ADDR.CUST_ACCOUNT_ID = l_cust_account_id       --using variable l_cust_account_id
         and ADDR.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
         and LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
         and nvl(LOC.LANGUAGE, userenv('LANG')) = userenv('LANG')
         and LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
         and NVL(ADDR.ORG_ID,-99) = NVL(LOC_ASSIGN.ORG_ID,-99)
         --Check Customer site of OUs under current LE
         AND HOI.org_information_context = 'Operating Unit Information'
         AND HOI.Org_Information2 = l_le_id                 --using variable l_le_id
         AND HOI.Org_Information3 = l_ledger_id             --using variable l_ledger_id
         AND ADDR.org_id = HOI.ORGANIZATION_ID
         -- Check "Primary Bill To"
         and SU.CUST_ACCT_SITE_ID= ADDR.CUST_ACCT_SITE_ID   --alias address_id in HZ_SITE_USES_V
         and SU.SITE_USE_CODE = 'BILL_TO'
         and nvl(SU.PRIMARY_FLAG, 'N') = 'Y'
            ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_all_cust_city_addr := null;
      END;

      --Use city/addr only when there is just 1 record, otherwise leave blanks
      IF l_all_cust_city_addr.count = 1
      THEN
        l_cust_city_addr := l_all_cust_city_addr(1);
        l_tp_territory  := l_cust_city_addr.city;
        l_tp_address    := l_cust_city_addr.addr;
      ELSE
        l_tp_territory := '';
        l_tp_address := '';
      END IF; --customer city/addr

      --Get Customer Phone which are Active status and Telephone type,
      --Order by PRIMARY flag and Preferred flag.
      --1. The PRIMARY one and Preferred one can both only have 1 record for telcommunications(telphone,mobile,...).
      --2. The first one, or the one has set to be the PRIMARY one will be set as PRIMARY if
      --   there no PRIMARY one selected by user.
      l_all_cust_phone := null;
      BEGIN
          SELECT
                  DECODE(HCP.PRIMARY_FLAG, 'Y', 'PRIMARY',
                      DECODE(HCP.PRIMARY_BY_PURPOSE, 'Y', 'PREFERRED', 'NORMAL')
                   )                              cust_phone_priority
                ,NVL(HCP.PHONE_COUNTRY_CODE,'')
                   || DECODE(NVL(HCP.PHONE_COUNTRY_CODE,''),'','','-')
                   || NVL(HCP.PHONE_AREA_CODE,'')
                   || DECODE(NVL(HCP.PHONE_AREA_CODE,''),'','','-')
                   || HCP.PHONE_NUMBER             cust_phone
          BULK COLLECT INTO                        l_all_cust_phone
          FROM HZ_CONTACT_POINTS      HCP
              ,HZ_PARTY_SITES         HPS
          WHERE HCP.OWNER_TABLE_ID(+)=HPS.PARTY_SITE_ID
          AND   HCP.OWNER_TABLE_NAME='HZ_PARTY_SITES'
          AND   NVL(HCP.PRIMARY_FLAG,'')='Y'
          AND   NVL(HCP.STATUS,'')='A'                 --only 'Active' one
          AND   NVL(HCP.CONTACT_POINT_TYPE,'')='PHONE'
          AND   NVL(HCP.PHONE_LINE_TYPE,'')='GEN'      --only 'Telephone' type, just the code 'GEN'
          AND   HPS.PARTY_ID = l_party_id              --using variable l_cust_account_id
          ORDER BY  HCP.primary_flag desc,
                HCP.primary_by_purpose desc
            ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_all_cust_phone := null;
      END;

      --If multiple, the selection priority is base on "Primary", then "Preferred", then sequence.
      --  Return blank if not defined or multiple.
      IF l_all_cust_phone.count = 1
      THEN
        l_tp_phonenumber := l_all_cust_phone(1).phone;
      ELSIF l_all_cust_phone.count>1
      THEN
        l_cust_phone := l_all_cust_phone(1);
        IF l_cust_phone.priority = 'PRIMARY' OR l_cust_phone.priority = 'PREFERRED'
        THEN
          l_tp_phonenumber := l_cust_phone.phone;
        ELSE --surely two NORMAL ones and thus leave it blank
          l_tp_phonenumber := '';
        END IF;
      ELSE --not defined
        l_tp_phonenumber := '';
      END IF; --customer phone

	    l_row_count := l_row_count+1;
	    --Output a row of l_tp_number, l_tp_name, l_tp_ctg_number,
      --       l_tp_territory, l_tp_phonenumber, l_tp_address, l_tp_credit_level in TXT file;
      /*FND_FILE.put_line(FND_FILE.output, l_tp_number ||'|  '|| l_tp_name ||'|  '|| l_tp_ctg_number
                          ||'|  '|| l_tp_territory ||'|  '|| l_tp_phonenumber ||'|  '|| l_tp_address
                          ||'|  '|| l_tp_credit_level);*/
      /*FND_FILE.put_line(FND_FILE.output,
                        RPAD(l_tp_number,10, ' ')
                        ||'|  '|| RPAD(nvl(l_tp_name, ' '),40,' ')
                        ||'|  '|| RPAD(nvl(l_tp_ctg_number, ' '),20,' ')
                        ||'|  '|| RPAD(nvl(l_tp_territory, ' '),20,' ')
                        ||'|  '|| RPAD(nvl(l_tp_phonenumber, ' '),20,' ')
                        ||'|  '|| RPAD(nvl(l_tp_address, ' '),40,' ')
                        ||'|  '|| l_tp_credit_level);*/
      FND_FILE.put_line(FND_FILE.output,
                                        '"' ||l_tp_number       || '"'
                        ||l_seperator|| '"' ||l_tp_name         || '"'
                        ||l_seperator|| '"' ||l_tp_ctg_number   || '"'
                        ||l_seperator|| '"' ||l_tp_territory    || '"'
                        ||l_seperator|| '"' ||l_tp_phonenumber  || '"'
                        ||l_seperator|| '"' ||l_tp_address      || '"'
                        ||l_seperator|| '"' ||l_tp_credit_level || '"'
                       );
  	END LOOP;
  	CLOSE c_tp_cust;

  	IF l_row_count = 0 --No data found
    THEN
  	  raise JA_CN_NO_DATA_FOUND;
  	END IF;

    retcode := 0;
    errbuf  := '';
  	EXCEPTION
      WHEN JA_CN_NO_DATA_FOUND THEN
        --FND_FILE.put_line(FND_FILE.output, l_msg_no_data_found);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_NO_DATA_FOUND '
                         ,l_msg_no_data_found);
        END IF;
        retcode := 1;
        errbuf  := l_msg_no_data_found;
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;

  END Coa_TP_Export;



  --==========================================================================
  --  PROCEDURE NAME:
  --    Coa_CC_Export                 Private
  --
  --  DESCRIPTION:
  --      This procedure exporting the Cost Center list as "subsidiary account"
  --      into format predefined flat file.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              Chart of account ID
  --      In: P_LEDGER_ID             NUMBER              ID of Set Of Book
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated
  --===========================================================================
  PROCEDURE  Coa_CC_Export( errbuf          OUT NOCOPY VARCHAR2
                           ,retcode         OUT NOCOPY VARCHAR2
                           ,P_COA_ID        IN NUMBER
                           ,P_LEDGER_ID     IN NUMBER
                           ,P_LE_ID         IN NUMBER
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Coa_CC_Export';

  	l_ledger_id                         NUMBER := P_LEDGER_ID;
    l_le_id                             NUMBER := P_LE_ID;
    l_coa_id                            NUMBER := P_COA_ID;
    l_seperator                         varchar2(1) := FND_GLOBAL.Local_Chr(9); --' ';

    l_row_count                         NUMBER;  --count of rows
    l_cc_number                         JA_CN_ACCOUNT_BALANCES.cost_center%TYPE;
    l_cc_name                           FND_FLEX_VALUES_TL.description%TYPE;

    --Cursor to get cost_center from table JA_CN_ACCOUNT_BALANCES and description from table
    --  FND_FLEX_VALUES_TL, as Department number and name.
    --Because the value set of cost center can be changed manually as natural account, it is
    --  no sense to store cost center id in table JA_CN_ACCOUNT_BALANCES. Thus the name should
    --  be gotten with the full flow.
    CURSOR c_cc IS
      SELECT *
      FROM (
          SELECT DISTINCT
                 FFV.FLEX_VALUE                      cc_number
                ,nvl(FFVT.description, '')           cc_name
            FROM JA_CN_ACCOUNT_BALANCES              BAL
                ,FND_ID_FLEX_SEGMENTS                FIFS
                ,FND_SEGMENT_ATTRIBUTE_VALUES        FSAV
                ,FND_FLEX_VALUE_SETS                 FFVS
                ,FND_FLEX_VALUES_TL                  FFVT
                ,FND_FLEX_VALUES                     FFV
                ,GL_LEDGERS                          LEDGER
           WHERE BAL.Ledger_Id = l_ledger_id         --using variable l_sob_id
             AND BAL.account_segment IS NOT NULL
             and BAL.cost_center IS NOT NULL
                 --for name. OR: FFVT.flex_value_meaning = BAL.cost_center
             AND FFV.FLEX_VALUE = BAL.cost_center
             AND LEDGER.Ledger_Id = l_ledger_id      --using variable l_ledger_id
             AND LEDGER.chart_of_accounts_id = FIFS.id_flex_num
             AND FIFS.id_flex_num = FSAV.id_flex_num
             AND FIFS.application_id = 101
             AND FIFS.application_id = FSAV.application_id
             AND FIFS.APPLICATION_COLUMN_NAME = FSAV.APPLICATION_COLUMN_NAME
             AND FSAV.SEGMENT_ATTRIBUTE_TYPE = 'FA_COST_CTR'
             AND FSAV.ATTRIBUTE_VALUE = 'Y'
             AND FFVS.FLEX_VALUE_SET_ID = FIFS.FLEX_VALUE_SET_ID
             AND FFVS.FLEX_VALUE_SET_ID = FFV.FLEX_VALUE_SET_ID
             AND FFVT.FLEX_VALUE_ID = FFV.FLEX_VALUE_ID
             AND nvl(FFVT.LANGUAGE, userenv('LANG')) = userenv('LANG')
         )  tmp_cc_tbl
      ORDER BY tmp_cc_tbl.cc_number
          ;

  BEGIN
  	/*FND_FILE.put_line(FND_FILE.output,
                      RPAD('Department number',20, ' ')
                      ||'|  '|| RPAD('Department name',40,' '));*/

  	--Export all cost centers into the format predefined flat file
  	l_row_count := 0;
  	OPEN c_cc;
  	LOOP
  	  FETCH c_cc INTO l_cc_number
                     ,l_cc_name
                     ;
  	  EXIT WHEN c_cc%NOTFOUND;
	    l_row_count := l_row_count+1;
	    --Output a row of cost center in TXT file with columns number, name
    	/*FND_FILE.put_line(FND_FILE.output,
                        RPAD(l_cc_number,20, ' ')
                        ||'|  '|| RPAD(l_cc_name,40,' '));*/
      FND_FILE.put_line(FND_FILE.output,
                                        '"' ||l_cc_number   || '"'
                        ||l_seperator|| '"' ||l_cc_name     || '"'
                       );
  	END LOOP;
  	CLOSE c_cc;

  	IF l_row_count = 0 --No data found
    THEN
  	  raise JA_CN_NO_DATA_FOUND;
  	END IF;

    retcode := 0;
    errbuf  := '';
  	EXCEPTION
      WHEN JA_CN_NO_DATA_FOUND THEN
        --FND_FILE.put_line(FND_FILE.output, l_msg_no_data_found);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_NO_DATA_FOUND '
                         ,l_msg_no_data_found);
        END IF;
        retcode := 1;
        errbuf  := l_msg_no_data_found;
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;

  END Coa_CC_Export;


  --==========================================================================
  --  PROCEDURE NAME:
  --    Coa_Person_Export             Private
  --
  --  DESCRIPTION:
  --      This procedure exporting the Personnel list as "subsidiary account"
  --      into format predefined flat file.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER              Chart of accounts ID
  --      In: P_LEDGER_ID                NUMBER           ID of Set Of Book
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated
  --===========================================================================
  PROCEDURE  Coa_Person_Export( errbuf          OUT NOCOPY VARCHAR2
                               ,retcode         OUT NOCOPY VARCHAR2
                               ,P_COA_ID        IN NUMBER
                               ,P_LEDGER_ID     IN NUMBER
                               ,P_LE_ID         IN NUMBER
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='Coa_Person_Export';

  	l_ledger_id                         NUMBER := P_LEDGER_ID;
    l_le_id                             NUMBER := P_LE_ID;
    l_coa_id                            NUMBER := P_COA_ID;
    l_seperator                         varchar2(1) := FND_GLOBAL.Local_Chr(9); --' ';

    l_row_count                         NUMBER;  --count of rows
    l_person_number                     JA_CN_ACCOUNT_BALANCES.personnel_number%TYPE;
    l_person_name                       VARCHAR2(50);

    --Cursor to get personnel_number from table JA_CN_ACCOUNT_BALANCES,
    --  and personnel name from table PER_ALL_PEOPLE_F
    CURSOR c_person IS
        SELECT *
        FROM (
            SELECT DISTINCT
                   BAL.personnel_number                person_number
                  ,nvl(PER.last_name||PER.first_name, '') person_name
              FROM JA_CN_ACCOUNT_BALANCES              BAL
                  ,PER_ALL_PEOPLE_F                    PER
             WHERE BAL.Ledger_Id = l_ledger_id      --using variable l_ledger_id
               AND BAL.account_segment IS NOT NULL
               and BAL.personnel_id IS NOT NULL
               AND PER.person_id = BAL.personnel_id
           ) tmp_psn_tbl
        ORDER BY tmp_psn_tbl.person_number
          ;

  BEGIN
  	/*FND_FILE.put_line(FND_FILE.output,
                      RPAD('Number',10, ' ')
                      ||'|  '|| RPAD('Name',40,' '));*/

  	--Export all persons into the format predefined flat file
  	l_row_count := 0;
  	OPEN c_person;
  	LOOP
  	  FETCH c_person INTO l_person_number
                         ,l_person_name
                         ;
  	  EXIT WHEN c_person%NOTFOUND;
	    l_row_count := l_row_count+1;
	    --Output a row of person in TXT file with columns number, name;
      /*FND_FILE.put_line(FND_FILE.output,
                        RPAD(l_person_number,10, ' ')
                        ||'|  '|| l_person_name);*/
      FND_FILE.put_line(FND_FILE.output,
                                        '"' ||l_person_number   || '"'
                        ||l_seperator|| '"' ||l_person_name     || '"'
                       );
  	END LOOP;
  	CLOSE c_person;

  	IF l_row_count = 0 --No data found
    THEN
  	  raise JA_CN_NO_DATA_FOUND;
  	END IF;

    retcode := 0;
    errbuf  := '';
  	EXCEPTION
      WHEN JA_CN_NO_DATA_FOUND THEN
        --FND_FILE.put_line(FND_FILE.output, l_msg_no_data_found);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_NO_DATA_FOUND '
                         ,l_msg_no_data_found);
        END IF;
        retcode := 1;
        errbuf  := l_msg_no_data_found;
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        RAISE;

  END  Coa_Person_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Coa_Export                    Public
  --
  --  DESCRIPTION:
  --      This procedure calls COA Export programs according to
  --      the specified account type.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER      chart of accounts ID
  --      In: P_LEDGER_ID             NUMBER      ID of LEDGER
  --      In: P_LE_ID                 NUMBER      ID of Legal Entity
  --      In: P_ACCOUNT_TYPE          VARCHAR2    Type of the account
  --      In: P_XML_TEMPLATE_LANGUAGE   VARCHAR2  template language of NA exception report
  --      In: P_XML_TEMPLATE_TERRITORY  VARCHAR2  template territory of NA exception report
  --      In: P_XML_OUTPUT_FORMAT       VARCHAR2  output format of NA exception report
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated
  --===========================================================================
  PROCEDURE Coa_Export( errbuf          OUT NOCOPY VARCHAR2
                       ,retcode         OUT NOCOPY VARCHAR2
                       ,P_COA_ID        IN NUMBER
                       ,P_LEDGER_ID     IN NUMBER
                       ,P_LE_ID         IN NUMBER
                       ,P_ACCOUNT_TYPE  IN VARCHAR2
                       ,P_XML_TEMPLATE_LANGUAGE    IN VARCHAR2
                       ,P_XML_TEMPLATE_TERRITORY   IN VARCHAR2
                       ,P_XML_OUTPUT_FORMAT        IN VARCHAR2
  ) IS

  l_account_type                                   varchar2(30):=P_ACCOUNT_TYPE;

  BEGIN
 /*
   		Coa_Person_export( errbuf   => errbuf
                        ,retcode  => retcode
                        ,P_COA_ID => P_COA_ID
                        ,P_LEDGER_ID => P_LEDGER_ID
                        ,P_LE_ID  => P_LE_ID
                       );
                           */
    IF P_ACCOUNT_TYPE = 'NA'
    THEN
  		Coa_NA_Export( errbuf   => errbuf
                    ,retcode  => retcode
                    ,P_COA_ID => P_COA_ID
                    ,P_LEDGER_ID => P_LEDGER_ID
                    ,P_LE_ID  => P_LE_ID
                    ,P_XML_TEMPLATE_LANGUAGE  => P_XML_TEMPLATE_LANGUAGE
                    ,P_XML_TEMPLATE_TERRITORY => P_XML_TEMPLATE_TERRITORY
                    ,P_XML_OUTPUT_FORMAT      => P_XML_OUTPUT_FORMAT
                   );

  	ELSIF P_ACCOUNT_TYPE = 'PJ'
    THEN
  		Coa_PJ_export( errbuf   => errbuf
                    ,retcode  => retcode
                    ,P_COA_ID => P_COA_ID
                    ,P_LEDGER_ID => P_LEDGER_ID
                    ,P_LE_ID  => P_LE_ID
                   );

  	ELSIF P_ACCOUNT_TYPE = 'TP'
    THEN
  		Coa_TP_export( errbuf   => errbuf
                    ,retcode  => retcode
                    ,P_COA_ID => P_COA_ID
                    ,P_LEDGER_ID => P_LEDGER_ID
                    ,P_LE_ID  => P_LE_ID
                   );

  	ELSIF P_ACCOUNT_TYPE = 'CC'
    THEN
  		Coa_CC_export( errbuf   => errbuf
                    ,retcode  => retcode
                    ,P_COA_ID => P_COA_ID
                    ,P_LEDGER_ID => P_LEDGER_ID
                    ,P_LE_ID  => P_LE_ID
                   );

  	ELSIF P_ACCOUNT_TYPE = 'PERSON'
    THEN
  		Coa_Person_export( errbuf   => errbuf
                        ,retcode  => retcode
                        ,P_COA_ID => P_COA_ID
                        ,P_LEDGER_ID => P_LEDGER_ID
                        ,P_LE_ID  => P_LE_ID
                       );
    END IF;
  END Coa_Export;

BEGIN
  -- Initialization
  FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                       ,NAME => 'JA_CN_NO_DATA_FOUND'
                      );
  l_msg_no_data_found := FND_MESSAGE.Get;
END JA_CN_COA_EXP_PKG;




/
