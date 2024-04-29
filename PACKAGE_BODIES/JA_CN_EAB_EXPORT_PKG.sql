--------------------------------------------------------
--  DDL for Package Body JA_CN_EAB_EXPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_EAB_EXPORT_PKG" AS
--$Header: JACNVBEB.pls 120.1.12000000.1 2007/08/13 14:09:53 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNVBEB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used to export electronic accounting book         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE  Execute_Export                                        |
--|      PROCEDURE  Query_System_Options                                  |
--|      PROCEDURE  Parse_Account_Structure                               |
--|      PROCEDURE  Query_Currency                                        |
--|      PROCEDURE  Query_Software_Infor                                  |
--|                                                                       |
--| HISTORY                                                               |
--|      03/13/2006     Jackey Li     Created                             |
--|      2006-7-10      Jackey Li     Update the way how to get account   |
--|                                     structure  due to Bug 5380368     |
--+======================================================================*/

  --==== Golbal Variables ============
  g_module_name         VARCHAR2(30) := 'JA_CN_EAB_EXPORT_PKG';
  g_dbg_level           NUMBER := FND_LOG.G_Current_Runtime_Level;
  g_proc_level          NUMBER := FND_LOG.Level_Procedure;
  g_stmt_level          NUMBER := FND_LOG.Level_Statement;
  g_ledger_id           GL_LEDGERS.Ledger_Id%TYPE;
  g_book_num            JA_CN_SYSTEM_PARAMETERS_ALL.BOOK_NUM%TYPE;
  g_book_name           JA_CN_SYSTEM_PARAMETERS_ALL.BOOK_NAME%TYPE;
  g_company_name        JA_CN_SYSTEM_PARAMETERS_ALL.COMPANY_NAME%TYPE;
  g_organization_id     JA_CN_SYSTEM_PARAMETERS_ALL.ORGANIZATION_ID%TYPE;
  g_ent_quality         JA_CN_SYSTEM_PARAMETERS_ALL.ENT_QUALITY%TYPE;
  g_ent_industry        JA_CN_SYSTEM_PARAMETERS_ALL.ENT_INDUSTRY%TYPE;
  g_account_structure   VARCHAR2(2000);
  g_functional_currency VARCHAR2(1000) := NULL;
  g_software_name       VARCHAR2(100) := NULL;
  g_software_version    VARCHAR2(100) := NULL;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Query_Account_Structure                      Private
  --
  --  DESCRIPTION:
  --        This procedure is used to parse the account structure defined in
  --               the 'JA_CN_SYSTEM_PARAMETERS_ALL' table
  --
  --  PARAMETERS:
  --      N/A
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006     Jackey Li          Created
  --===========================================================================
  PROCEDURE Query_Account_Structure (P_COA_ID IN NUMBER
                                     )IS
    l_procedure_name VARCHAR2(30) := 'Parse_Account_Structure';

    l_coa_id                            NUMBER := P_COA_ID;
    l_sql                               varchar2(1000);
    l_account_structures_kfv            VARCHAR2(100) := 'ja_cn_account_structures_kfv';
    l_comma_position                    NUMBER;

  BEGIN
    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    --Get Chart of Accounts ID from DAS


    --Get the account structure from Source form
    l_sql :=
      'SELECT '
     ||'     nvl(ACC_STR_V.concatenated_segments, '''')  acc_str   '
     ||' FROM Ja_Cn_Sub_Acc_Sources_All                        SOURCE      '
     ||'     ,' || l_account_structures_kfv || '       ACC_STR_V   '
     ||'WHERE ACC_STR_V.account_structure_id = SOURCE.ACCOUNTING_STRUCT_ID'
     ||'  AND SOURCE.CHART_OF_ACCOUNTS_ID =  ' || l_coa_id   --using variable l_coa_id
         ;
    EXECUTE IMMEDIATE l_sql into g_account_structure;

    --Validation
    LOOP
      l_comma_position := Instr(g_account_structure, ',,', 0, 1);
      IF l_comma_position > 0
      THEN
         g_account_structure := Replace(g_account_structure, ',,',',');
      END IF;

    EXIT WHEN l_comma_position<=0 ;
    END LOOP;


    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  END Query_Account_Structure;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Query_System_Options                    Private
  --
  --  DESCRIPTION:
  --        This procedure is used to fetch data
  --            from the 'JA_CN_SYSTEM_PARAMETERS_ALL' table
  --
  --  PARAMETERS:
  --      In: p_le_id                      legal entity ID
  --      In:P_COA_ID                      chart of accounts id
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006     Jackey Li     Created
  --      2006-7-10      Jackey Li     Update the way how to get account
  --                                     structure due to Bug 5380368
  --===========================================================================
  PROCEDURE Query_System_Options(p_le_id  IN NUMBER
                                ,P_COA_ID IN NUMBER) IS

    l_procedure_name       VARCHAR2(30) := 'Query_System_Options';
    l_err_msg              VARCHAR2(1000) := NULL;
    l_account_structure_id JA_CN_SUB_ACC_SOURCES_ALL.ACCOUNTING_STRUCT_ID%TYPE;

    JA_CN_MISSING_BOOK_INFO             exception;
    l_msg_miss_book_info                varchar2(2000);

    l_le_id                             JA_CN_SYSTEM_PARAMETERS_ALL.LEGAL_ENTITY_ID%TYPE :=  p_le_id;
    l_coa_id                            JA_CN_SUB_ACC_SOURCES_ALL.Chart_Of_Accounts_Id%TYPE := P_COA_ID;
  BEGIN
    --log for debug
    IF (g_proc_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    -- fetch data from the 'JA_CN_SYSTEM_PARAMETERS_ALL' table
    SELECT jcsp.BOOK_NAME
          ,jcsp.COMPANY_NAME
          ,jcsp.book_num
          ,jcsp.ORGANIZATION_ID
          ,jcsp.ENT_QUALITY
          ,jcsp.ENT_INDUSTRY
      INTO g_book_name
          ,g_company_name
          ,g_book_num
          ,g_organization_id
          ,g_ent_quality
          ,g_ent_industry
     FROM  JA_CN_SYSTEM_PARAMETERS_ALL  jcsp
     WHERE jcsp.legal_entity_id = l_le_id ;

    select sasc.accounting_struct_id
     into  l_account_structure_id
     from  JA_CN_SUB_ACC_SOURCES_ALL    sasc
    where  sasc.chart_of_accounts_id=l_coa_id;

    IF g_book_name is null OR g_company_name    is null  OR
       g_book_num  is null OR g_organization_id is null  OR
       g_ent_quality is null OR g_ent_industry  is null   OR
       l_account_structure_id is null
    THEN
      RAISE JA_CN_MISSING_BOOK_INFO;
    END IF;

 /* -- ??  NOT SURE
   g_account_structure := JA_CN_UTILITY.Fetch_Account_Structure(p_le_id);

    -- to valide the account_structure
    Parse_Account_Structure;*/

    --log for debug
    IF (g_proc_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  EXCEPTION
   /* WHEN NO_DATA_FOUND THEN
      RAISE;

    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_dbg_level)
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_name || l_procedure_name ||
                       '.OTHER_EXCEPTION',
                       SQLCODE || ':' || SQLERRM);
      END IF;
      RAISE;*/
      WHEN JA_CN_MISSING_BOOK_INFO THEN
        FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                             ,NAME => 'JA_CN_MISSING_BOOK_INFO'
                            );
        l_msg_miss_book_info := FND_MESSAGE.Get;

        FND_FILE.put_line(FND_FILE.output, l_msg_miss_book_info);

        IF (g_proc_level >= g_dbg_level)
        THEN
          FND_LOG.String( g_proc_level,
                     g_module_name || '.' || l_procedure_name||'.JA_CN_MISSING_BOOK_INFO '
                         ,l_msg_miss_book_info);
        END IF;
        RAISE;
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                             ,NAME => 'JA_CN_MISSING_BOOK_INFO'
                            );
        l_msg_miss_book_info := FND_MESSAGE.Get;

        FND_FILE.put_line(FND_FILE.output, l_msg_miss_book_info);

        IF (g_proc_level >= g_dbg_level)
        THEN
          FND_LOG.String( g_proc_level,
                     g_module_name || '.' || l_procedure_name||'.JA_CN_MISSING_BOOK_INFO '
                         ,l_msg_miss_book_info);
        END IF;
        RAISE;
        --retcode := 1;
        --errbuf  := l_msg_miss_book_info;
      WHEN OTHERS THEN
        IF (g_proc_level >= g_dbg_level)
        THEN
          FND_LOG.String( g_proc_level,
                     g_module_name || '.' || l_procedure_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        --retcode := 2;
        --errbuf  := SQLCODE||':'||SQLERRM;

  END Query_System_Options;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Query_Currency                     Private
  --
  --  DESCRIPTION:
  --        This procedure is used to fetch currency for the current SOB
  --
  --  PARAMETERS:
  --      In: p_ledger_id                      legal entity ID
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006     Jackey Li          Created
  --===========================================================================
  PROCEDURE Query_Currency(P_LEDGER_ID IN NUMBER) IS
    l_procedure_name VARCHAR2(30) := 'Query_Currency';
    l_ledger_id      NUMBER ;

  BEGIN
    --log for debug
    l_ledger_id      := P_LEDGER_ID;
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    -- the sql is used to get functional_currency
    SELECT fct.NAME
      INTO g_functional_currency
      FROM Gl_LEDGERS ledger, FND_CURRENCIES_TL fct
     WHERE ledger.currency_code = fct.currency_code
       AND fct.LANGUAGE = userenv('lang')
       AND ledger.ledger_id = P_LEDGER_ID;

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_dbg_level)
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_name || l_procedure_name ||
                       '.NO_DATA_FOUND',
                       SQLCODE || ':' || SQLERRM);
      END IF;
      RAISE;
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_dbg_level)
      THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_name || l_procedure_name ||
                       '.OTHER_EXCEPTION',
                       SQLCODE || ':' || SQLERRM);
      END IF;
      RAISE;

  END Query_Currency;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Query_Software_Infor                     Private
  --
  --  DESCRIPTION:
  --        This procedure is used to fetch information about the name and version
  --             for this erp software vendor.
  --
  --  PARAMETERS:
  --      N/A
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006     Jackey Li          Created
  --===========================================================================
  PROCEDURE Query_Software_Infor IS
    l_procedure_name VARCHAR2(30) := 'Query_Software_Infor';
  BEGIN
    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    g_software_name := 'ORACLE';

    --the newest version, which should be the max of the 3 sub versions
    SELECT major_version || '.' || minor_version || '.' || tape_version
      INTO g_software_version
      FROM ad_releases
     WHERE tape_version IN
          (SELECT MAX(tape_version)
             FROM ad_releases
             WHERE minor_version IN
                  (SELECT MAX(minor_version)
                     FROM ad_releases
                    WHERE major_version IN (SELECT MAX(major_version) FROM ad_releases)
                  )
               AND major_version IN (SELECT MAX(major_version) FROM ad_releases)
          )
       AND minor_version IN
          (SELECT MAX(minor_version)
             FROM ad_releases
            WHERE major_version IN (SELECT MAX(major_version) FROM ad_releases)
          )
       AND major_version IN (SELECT MAX(major_version) FROM ad_releases);

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- set default value with '11i'
      g_software_version := '11i';
    WHEN TOO_MANY_ROWS THEN
      -- set default value with '11i'
      g_software_version := '11i';

  END Query_Software_Infor;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Execute_Export                     Public
  --
  --  DESCRIPTION:
  --        It is a main procedure used to implement the export functionality
  --
  --  PARAMETERS:
  --      In: P_COA_ID                    chart of accounts ID
  --          p_le_id                     legal entity ID
  --          P_LEDGER_ID                 Ledger id
  --          p_fiscal_year               fiscal_year
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006      Jackey Li          Created
  --      04/30/2007      Yucheng Sun        Updated
  --===========================================================================
  PROCEDURE Execute_Export(P_COA_ID      IN NUMBER
                          ,p_le_id       IN NUMBER
                          ,P_LEDGER_ID   IN NUMBER
                          ,p_fiscal_year IN VARCHAR2) IS

    l_procedure_name VARCHAR2(30) := 'Execute_Export';
    l_output_string  VARCHAR2(1000) := NULL;
    l_separator      VARCHAR2(1) := FND_GLOBAL.Local_Chr(9);
    l_quotation      VARCHAR2(1) := '"';
  BEGIN
    --TODO:
    -- check parameter

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name ||
                     '.p_le_id is',
                     to_char(p_le_id));
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name ||
                     '.p_fiscal_year is',
                     p_fiscal_year);
    END IF; --( g_proc_level >= g_dbg_level)

    -- to get information from the table JA_CN_SYSTEM_PARAMETERS_ALL
    Query_System_Options(p_le_id,P_COA_ID);

    -- Get account structure from the Source Form
    Query_Account_Structure(P_COA_ID);

    -- to get Currency code
    Query_Currency(P_LEDGER_ID);

    -- to get information about erp vendor and its version
    Query_Software_Infor;

    l_output_string := l_quotation || g_book_num || l_quotation ||
                       l_separator || l_quotation || g_book_name ||
                       l_quotation || l_separator || l_quotation ||
                       g_company_name || l_quotation || l_separator ||
                       l_quotation ||
                       g_organization_id || l_quotation || l_separator ||
                       l_quotation || g_ent_quality || l_quotation ||
                       l_separator || l_quotation || g_ent_industry ||
                       l_quotation || l_separator || l_quotation ||
                       g_software_name || l_quotation || l_separator ||
                       l_quotation || g_software_version || l_quotation ||
                       l_separator || l_quotation || p_fiscal_year ||
                       l_quotation || l_separator || l_quotation ||
                       g_functional_currency || l_quotation || l_separator ||
                       l_quotation || g_account_structure || l_quotation;

    FND_FILE.PUT_LINE(Fnd_File.OUTPUT,
                      l_output_string
                      );
    --Dbms_Output.put_line('SYC TEST & TEST AND TEST1');

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  END Execute_Export;

END JA_CN_EAB_EXPORT_PKG;






/
