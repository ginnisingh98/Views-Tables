--------------------------------------------------------
--  DDL for Package Body JA_CN_ETC_CONC_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_ETC_CONC_PROG" AS
  --$Header: JACNETCB.pls 120.1.12000000.1 2007/08/13 14:09:32 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNETCB.pls
  --|
  --| DESCRIPTION
  --|
  --|   This is a wrapper package for submission of export
  --|   statement related concurrent programs
  --|
  --|
  --| PROCEDURE LIST
  --|   itemize_ap_journals;
  --|   itemize_ar_journals;
  --|   itemize_pa_journals;
  --|   itemize_po_journals;
  --|   itemize_inv_journals;
  --|   itemize_fa_journals;
  --|   transfer_gl_journals;
  --|   get_description_from_gis;
  --|   post_journal_itemized;
  --|   EAB_Export;
  --|   MultiOrg_Maintain;
  --|   Export_Coa
  --|   Ent_GSSM_Export
  --|   Pub_GSSM_Export
  --|   JOURNAL_ENTRY_EXPORT
  --|   ACCOUNT_BALANCE_EXPORT
  --|   JOURNAL_ENTRY_GENERATION
  --|   ACCOUNT_BALANCE_GENERATION
  --|
  --| HISTORY
  --|   29-Mar-2006     Qingjun Zhao Created
  --|    29-Mar-2006     Jackey  Li   Added two procedures
  --|                                 EAB_Export and MultiOrg_Maintain
  --|   29-Mar-2006     Andrew  Liu  Added Export_Coa
  --|   17-May-2006     Andrew  Liu  Added Ent_GSSM_Export and Pub_GSSM_Export
  --|   19-Jun-2006     Joseph Wang added JOURNAL_ENTRY_EXPORT and ACCOUNT_BALANCE_EXPORT
  --|   20-Jun-2006     Jackey Li    added one procedure EAB_Export_Wrapper
  --|   21-Jun-2006     Joseph Wang added JOURNAL_ENTRY_GENERATION and ACCOUNT_BALANCE_GENERATION
  --|   05-July-2006    Joseph Wang modified the procedure JOURNAL_ENTRY_GENERATION, ACCOUNT_BALANCE_GENERATION
  --|                            JOURNAL_ENTRY_EXPORT and ACCOUNT_BALANCE_EXPORT for adding report range support
  --+======================================================================*/
  l_Module_Prefix VARCHAR2(100) := 'JA_CN_ETC_CONC_PROG';

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    transfer_gl_sla_to_cnao                 Public
  --
  --  DESCRIPTION:
  --
  --      The 'transfer_gl_sla_to_cnao' procedure accepts parameters from
  --      concurrent program 'Account and Journal Itemization Program' and
  --      calls another procedure
  --      'JA_CN_ACC_JE_ITEMIZATION_PKG.transfer_gl_sla_to_cnao'
  --      with parameters after processing.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id           Identifier of legal entity
  --                                      parameter for FSG report
  --          p_period_name               GL period Name
  --
  --     Out: errbuf
  --          retcode
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      29-Mar-2006     Qingjun Zhao Created
  --
  --===========================================================================

  PROCEDURE Transfer_Gl_Sla_To_Cnao(Errbuf                 OUT NOCOPY VARCHAR2,
                                    Retcode                OUT NOCOPY VARCHAR2,
                                    p_Chart_Of_Accounts_Id IN NUMBER,
                                    p_Ledger_Id            IN NUMBER,
                                    p_Legal_Entity_Id      IN NUMBER,
                                    p_Period_Name          IN VARCHAR2) IS

    l_Flag         NUMBER;
    l_Error_Flag   VARCHAR2(1) := 'N';
    l_Error_Status BOOLEAN;

    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'transfer_gl_sla_to_cnao';

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_period_name:' || p_Period_Name);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_legal_entity_id:' || p_Legal_Entity_Id);
    END IF; --(l_proc_level >= l_dbg_level)

    IF Ja_Cn_Utility.Check_Profile THEN
      Ja_Cn_Acc_Je_Itemization_Pkg.Transfer_Gl_Sla_To_Cnao(Errbuf                 => Errbuf,
                                                           Retcode                => Retcode,
                                                           p_Chart_Of_Accounts_Id => p_Chart_Of_Accounts_Id,
                                                           p_Ledger_Id            => p_Ledger_Id,
                                                           p_Legal_Entity_Id      => p_Legal_Entity_Id,
                                                           p_Period_Name          => p_Period_Name);
    ELSE
      l_Error_Flag := 'Y';
    END IF; --JA_CN_UTILITY.Check_Profile

    --If above check failed, then set status of concurrent program as warning

    IF l_Error_Flag = 'Y' THEN
      l_Error_Status := Fnd_Concurrent.Set_Completion_Status(Status  => 'WARNING',
                                                             Message => '');

    END IF; --l_error_flag = 'Y'

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
  END Transfer_Gl_Sla_To_Cnao;

  --==========================================================================
  --  PROCEDURE NAME:
  --    post_journal_itemized                     Public
  --
  --  DESCRIPTION:
  --      The ' post_journal_itemized' procedure accepts parameters from
  --      concurrent program 'Post itemized journals'
  --      and calls another procedure
  --      'JA_CN_POST_UTILITY_PK.post_journal_itemized'
  --      with parameters after processing.
  --
  --  PARAMETERS:
  --     Out: errbuf          Mandatory parameter for PL/SQL concurrent programs
  --     Out: retcode         Mandatory parameter for PL/SQL concurrent programs
  --     In: p_period_name    the end period name in which
  --                          the CNAO journal should be processed
  --        p_ledger_id       ledger ID
  --        p_legal_entity_ID Legal entity id

  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      29-Mar-2006     Qingjun Zhao          Created
  --===========================================================================
  PROCEDURE Post_Journal_Itemized(Errbuf            OUT NOCOPY VARCHAR2,
                                  Retcode           OUT NOCOPY VARCHAR2,
                                  p_Period_Name     IN VARCHAR2,
                                  p_ledger_Id       IN NUMBER,
                                  p_Legal_Entity_Id IN NUMBER) IS
    l_Flag         NUMBER;
    l_Error_Flag   VARCHAR2(1) := 'N';
    l_Error_Status BOOLEAN;

    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'post_journal_itemized';

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_period_name:' || p_Period_Name);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_Ledger_id :' || P_ledger_Id);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_legal_entity_ID:' || p_Legal_Entity_Id);
    END IF; --(l_proc_level >= l_dbg_level)

    IF Ja_Cn_Utility.Check_Profile THEN
      Ja_Cn_Post_Utility_Pkg.Post_Journal_Itemized(p_Period_Name     => p_Period_Name,
                                                   p_ledger_Id       => p_ledger_Id,
                                                   p_Legal_Entity_Id => p_Legal_Entity_Id);
    ELSE
      l_Error_Flag := 'Y';
    END IF; --JA_CN_UTILITY.Check_Profile

    --If above check failed, then set status of concurrent program as warning
    IF l_Error_Flag = 'Y' THEN
      l_Error_Status := Fnd_Concurrent.Set_Completion_Status(Status  => 'WARNING',
                                                             Message => '');

    END IF; --l_error_flag = 'Y'

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Post_Journal_Itemized;

  --==========================================================================
  --  PROCEDURE NAME:
  --    EAB_Export                  Public
  --
  --  DESCRIPTION:
  --      This procedure accepts parameters from concurrent program
  --      'Electronic Accounting Book Export'
  --      and calls another procedure 'JA_CN_EAB_EXPORT_PKG.Execute_Export'
  --       with parameters after processing.
  --
  --  PARAMETERS:
  --      In: P_COA_ID                Current chart of accounts ID
  --          p_le_id                 current legal entity ID
  --          P_LEDGER_ID             Current ledger ID
  --          p_fiscal_year           fiscal year under current sob
  --
  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/29/2006      Jackey Li          Created
  --      05/09/2007      Yucheng Sun        Updated
  --===========================================================================

    PROCEDURE EAB_Export(ERRBUF        OUT NOCOPY VARCHAR2
                        ,RETCODE       OUT NOCOPY VARCHAR2
                        ,P_COA_ID      IN NUMBER
                        ,P_LE_ID       IN NUMBER
                        ,P_LEDGER_ID   IN NUMBER
                        ,p_fiscal_year VARCHAR2) IS

      l_ledger_id    NUMBER:= P_LEDGER_ID ;
      l_le_id        NUMBER:=P_LE_ID;
      l_coa_id       NUMBER:=P_COA_ID;

      l_flag         NUMBER:=0;
      l_error_flag   VARCHAR2(1) := 'N';
      l_error_status BOOLEAN;

      l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
      l_proc_level NUMBER := FND_LOG.Level_Procedure;
      l_proc_name  VARCHAR2(100) := 'EAB_Export';

    BEGIN
      --log for debug
      IF (l_proc_level >= l_dbg_level)
      THEN
        FND_LOG.STRING(l_proc_level,
                       l_module_prefix || '.' || l_proc_name || '.begin',
                       'Enter procedure');
        FND_LOG.STRING(l_proc_level,
                       l_module_prefix || '.' || l_proc_name || '.parameters',
                       'p_le_id is ' || p_le_id);
        FND_LOG.STRING(l_proc_level,
                       l_module_prefix || '.' || l_proc_name || '.parameters',
                       'p_fiscal_year is ' || p_fiscal_year);
      END IF; --(l_proc_level >= l_dbg_level)

      IF JA_CN_UTILITY.Check_Profile THEN
          JA_CN_EAB_EXPORT_PKG.Execute_Export(P_COA_ID => l_coa_id
                                             ,p_le_id  => l_le_id
                                             ,P_LEDGER_ID =>  l_ledger_id
                                             ,p_fiscal_year => p_fiscal_year);
      ELSE
        l_error_flag := 'Y';
        retcode := 1;
        errbuf  := '';
        RETURN;
      END IF; --JA_CN_UTILITY.Check_Profile

      --If above check failed, then set status of concurrent program as warning

/*      IF l_error_flag = 'Y'
      THEN
        l_error_status := FND_CONCURRENT.Set_Completion_Status(status  => 'WARNING',
                                                               message => '');
      END IF; --l_error_flag = 'Y'
  */
      --log for debug
      IF (l_proc_level >= l_dbg_level)
      THEN
        FND_LOG.STRING(l_proc_level,
                       l_module_prefix || '.' || l_proc_name || '.end',
                       'Exit procedure');
      END IF; --( l_proc_level >= l_dbg_level )

    EXCEPTION
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.STRING(l_proc_level,
                         l_module_prefix || '.' || l_proc_name ||
                         '. Other_Exception ',
                         SQLCODE || ':' || SQLERRM);
        END IF; --(l_proc_level >= l_dbg_level)
        RAISE;

    END EAB_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --    EAB_Export_Wrapper                  Public
  --
  --  DESCRIPTION:
  --
  --
  --  PARAMETERS:
  --      In: P_COA_ID                current chart of accounts ID
  --          p_ledger_id             current ledger ID
  --          p_le_id                 current legal entity ID
  --          p_fiscal_year           fiscal year under current sob
  --          p_src_charset
  --          p_dest_charset
  --          p_separator
  --          p_file_name
  --
  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --      CNAO_Electronic_Accounting_Book_Export.doc
  --
  --  CHANGE HISTORY:
  --      03/29/2006      Jackey Li          Created
  --      05/09/2007      Yucheng Sun        Updated
  --===========================================================================
  PROCEDURE Eab_Export_Wrapper(Errbuf         OUT NOCOPY VARCHAR2,
                               Retcode        OUT NOCOPY VARCHAR2,
                               P_COA_Id       IN NUMBER,
                               p_Le_Id        IN NUMBER,
                               p_ledger_id    IN NUMBER,
                               p_Fiscal_Year  IN VARCHAR2,
                               p_Src_Charset  IN VARCHAR2,
                               p_Dest_Charset IN VARCHAR2,
                               p_Separator    IN VARCHAR2,
                               p_File_Name    IN VARCHAR2) IS

    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'EAB_Export_Wrapper';

    l_Reqid      NUMBER(15); -- Request id for the 'EAB export'
    l_Chr_Reqid  NUMBER(15); -- Request id for the 'Charset Convert'
    l_Fn_Reqid   NUMBER(15); -- Request id for the 'Change filename'
    l_Chr_Result VARCHAR2(10);
    l_Fn_Result  VARCHAR2(10);

    l_Err_Msg  VARCHAR2(1000) := NULL;
    l_Err_Code VARCHAR(1) := 'N';

    l_Req_Phase   Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Req_Status  Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_User_Phase  Fnd_Lookup_Values.Meaning%TYPE;
    l_User_Status Fnd_Lookup_Values.Meaning%TYPE;

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)

    -- submit EAB export CP
    l_Reqid := Fnd_Request.Submit_Request(Application => 'JA',
                                          Program     => 'JACNEABE',
                                          Argument1   => P_COA_Id,
                                          Argument2   => p_Le_Id,
                                          Argument3   => p_ledger_id,
                                          argument4   => p_Fiscal_Year);
    COMMIT;

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name,
                     'submit EAB export CP');
    END IF; --( g_stmt_level >= g_dbg_level)

    IF l_Reqid <> 0 THEN
      IF Fnd_Concurrent.Wait_For_Request(Request_Id => l_Reqid,
                                         INTERVAL   => 5,
                                         Phase      => l_User_Phase,
                                         Status     => l_User_Status,
                                         Dev_Phase  => l_Req_Phase,
                                         Dev_Status => l_Req_Status,
                                         Message    => l_Err_Msg) THEN
        IF l_Req_Status = 'NORMAL' THEN
          -- submit charset conversiong
          Ja_Cn_Utility.Submit_Charset_Conversion(p_Xml_Request_Id      => l_Reqid,
                                                  p_Source_Charset      => p_Src_Charset,
                                                  p_Destination_Charset => p_Dest_Charset,
                                                  p_Source_Separator    => p_Separator,
                                                  x_Charset_Request_Id  => l_Chr_Reqid,
                                                  x_Result_Flag         => l_Chr_Result);
          IF l_Chr_Result = 'Success' THEN
            -- submit change output filename
            Ja_Cn_Utility.Change_Output_Filename(p_Xml_Request_Id       => l_Reqid,
                                                 p_Destination_Charset  => p_Dest_Charset,
                                                 p_Destination_Filename => p_File_Name,
                                                 x_Filename_Request_Id  => l_Fn_Reqid,
                                                 x_Result_Flag          => l_Fn_Result);
            IF l_Fn_Result = 'Success' THEN
              l_Err_Code := 'N';
              Retcode    := 0;
            ELSIF l_Fn_Result = 'Warning' THEN
              l_Err_Code := 'W';
              Retcode    := 1;
            ELSE
              l_Err_Code := 'E';
              Retcode    := 2;
            END IF; -- IF l_fn_result = 'Success'

          ELSIF l_Chr_Result = 'Warning' THEN
            l_Err_Code := 'W';
            Retcode    := 1;
          ELSE
            l_Err_Code := 'E';
            Retcode    := 2;
          END IF; --l_chr_result = 'Success'

        ELSIF l_Req_Status = 'WARNING' THEN
          l_Err_Code := 'W';
          Retcode    := 1;
          Errbuf     := l_Err_Msg;
        ELSE
          l_Err_Code := 'E';
          Retcode    := 2;
          Errbuf     := l_Err_Msg;
        END IF; -- IF l_user_status = 'NORMAL'
      END IF; --FND_CONCURRENT.Wait_For_Request
    END IF; --l_reqid <> 0

    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;

  END Eab_Export_Wrapper;


  --==========================================================================
  --  PROCEDURE NAME:
  --    Export_Coa                    Public
  --
  --  DESCRIPTION:
  --      This procedure checks profile and General Information of
  --      System Options Form, then calls program of COA Export, including
  --      Natural Account and 4 Subsidiary Account of "Project", "Third Party",
  --      "Cost Center" and "Personnel".
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER      Chart of accounts ID
  --      In: P_LE_ID                 NUMBER      ID of Legal Entity
  --      In: P_LEDGER_ID             NUMBER      ID of ledger
  --      In: P_ACCOUNT_TYPE          VARCHAR2    Type of the account
  --      In: P_XML_TEMPLATE_LANGUAGE   VARCHAR2  template language of NA exception report
  --      In: P_XML_TEMPLATE_TERRITORY  VARCHAR2  template territory of NA exception report
  --      In: P_XML_OUTPUT_FORMAT       VARCHAR2  output format of NA exception report
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --      04/24/2007     Yucheng Sun         Updated
  --===========================================================================

  PROCEDURE Export_Coa(errbuf                   OUT NOCOPY VARCHAR2,
                       retcode                  OUT NOCOPY VARCHAR2,
                       P_COA_ID                 IN NUMBER,
                       P_LE_ID                  IN NUMBER,
                       P_Ledger_Id              IN NUMBER,
                       P_ACCOUNT_TYPE           IN VARCHAR2,
                       P_XML_TEMPLATE_LANGUAGE  IN VARCHAR2 default 'zh',
                       P_XML_TEMPLATE_TERRITORY IN VARCHAR2 default '00',
                       P_XML_OUTPUT_FORMAT      IN VARCHAR2 default 'RTF') IS
    l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level NUMBER := FND_LOG.Level_Procedure;
    l_proc_name  VARCHAR2(100) := 'Export_Coa';

    JA_CN_MISSING_BOOK_INFO exception;
    l_msg_miss_book_info varchar2(2000);

    l_le_id        NUMBER := P_LE_ID;
    l_ledger_id    NUMBER := P_Ledger_Id;
    l_sob_id       NUMBER;
    l_coa_id       NUMBER := P_COA_ID;
    l_sob_coa_flag NUMBER;

    l_flag      NUMBER;
    l_book_name JA_CN_SYSTEM_PARAMETERS_ALL.BOOK_NAME%TYPE;
    l_book_num  JA_CN_SYSTEM_PARAMETERS_ALL.BOOK_NUM%TYPE;
    l_com_name  JA_CN_SYSTEM_PARAMETERS_ALL.COMPANY_NAME%TYPE;
    l_org_id    JA_CN_SYSTEM_PARAMETERS_ALL.ORGANIZATION_ID%TYPE;
    l_ent_qty   JA_CN_SYSTEM_PARAMETERS_ALL.ENT_QUALITY%TYPE;
    l_ent_ind   JA_CN_SYSTEM_PARAMETERS_ALL.ENT_INDUSTRY%TYPE;
    --l_acc_str                           JA_CN_SYSTEM_PARAMETERS_ALL..ACCOUNT_STRUCTURE_ID%TYPE;
    --l_ent_flg                           JA_CN_SYSTEM_PARAMETERS_ALL.ENT_FLAG%TYPE;

    --Cursor to get General Information from table JA_CN_SYSTEM_PARAMETERS_ALL of current SOB.
    CURSOR c_general_info IS
      SELECT BOOK_NAME,
             BOOK_NUM,
             COMPANY_NAME,
             ORGANIZATION_ID,
             ENT_QUALITY,
             ENT_INDUSTRY
      --,ACCOUNT_STRUCTURE_ID
      --,ENT_FLAG
        FROM JA_CN_SYSTEM_PARAMETERS_ALL
       WHERE LEGAL_ENTITY_ID = l_le_id;

  BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LE_ID ' || P_LE_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_ACCOUNT_TYPE ' || P_ACCOUNT_TYPE);
    END IF; --(l_proc_level >= l_dbg_level)

    l_flag := 0;
    --Call the function JA_CN_CFS_UTILITY.Check_Profile to check if all required profiles has been
    -- properly set for current responsibility. If No, the function will raise corresponding error
    -- messages, and the concurrent program will not continue performing next logics,these required
    -- profiles include ' JG: Product', which should be set to 'Asia/Pacific Localizations',
    -- 'JG: Territory', which should be set to 'China' and 'JA: CNAO Legal Entity', which should be
    -- NOT NULL.
    IF JA_CN_UTILITY.Check_Profile THEN
      /*--Get sob id
      JA_CN_UTILITY.Get_SOB_And_COA(l_le_id,
                                    l_sob_id,
                                    l_coa_id,
                                    l_sob_coa_flag);

      IF l_sob_coa_flag = -1 THEN
        retcode := 1;
        errbuf  := '';
        RETURN;
      END IF;*/

      --Check whether any field in the "Accounting Book information" area of tab
      --  "General Information" of form "System options" defined or not
      OPEN c_general_info;
      FETCH c_general_info
        INTO l_book_name, l_book_num, l_com_name, l_org_id, l_ent_qty, l_ent_ind
      --,l_acc_str
      --,l_ent_flg
      ;
      IF c_general_info%NOTFOUND OR l_book_name is null OR
         l_book_num is null OR l_com_name is null OR l_org_id is null OR
         l_ent_qty is null OR l_ent_ind is null
      -- OR l_acc_str is null   --OR l_ent_flg is null
       THEN
        l_flag := 1;
        RAISE JA_CN_MISSING_BOOK_INFO;
      END IF;
      CLOSE c_general_info;
    ELSE
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF; -- JA_CN_UTILITY.Check_Profile

    IF l_flag = 0 THEN
      JA_CN_COA_EXP_PKG.Coa_Export(errbuf                   => errbuf,
                                   retcode                  => retcode,
                                   p_COA_ID                 => l_coa_id,
                                   P_LEDGER_ID              => l_ledger_id,
                                   P_LE_ID                  => l_le_id,
                                   P_ACCOUNT_TYPE           => P_ACCOUNT_TYPE,
                                   P_XML_TEMPLATE_LANGUAGE  => P_XML_TEMPLATE_LANGUAGE,
                                   P_XML_TEMPLATE_TERRITORY => P_XML_TEMPLATE_TERRITORY,
                                   P_XML_OUTPUT_FORMAT      => P_XML_OUTPUT_FORMAT);
    END IF;


    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.end',
                     'Exit procedure');
    END IF; --(l_proc_level >= l_dbg_level)

  EXCEPTION
    WHEN JA_CN_MISSING_BOOK_INFO THEN
      FND_MESSAGE.Set_Name(APPLICATION => 'JA',
                           NAME        => 'JA_CN_MISSING_BOOK_INFO');
      l_msg_miss_book_info := FND_MESSAGE.Get;

      FND_FILE.put_line(FND_FILE.output, l_msg_miss_book_info);
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '.JA_CN_MISSING_BOOK_INFO ',
                       l_msg_miss_book_info);
      END IF;
      retcode := 1;
      errbuf  := l_msg_miss_book_info;
    WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '.Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      retcode := 2;
      errbuf  := SQLCODE || ':' || SQLERRM;
  END Export_Coa;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Export_Coa_Entry              Public
  --
  --  DESCRIPTION:
  --      This procedure submits the program of COA Exports, and then changes
  --      the output file's CharSet and file name.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NUMBER      Chart of accounts ID
  --      In: P_LE_ID                 NUMBER      ID of Legal Entity
  --      In: P_ACCOUNT_TYPE          VARCHAR2    Type of the account
  --      In: P_SOURCE_CHARSET          VARCHAR2  source charset for convert
  --      In: P_DESTINATION_CHARSET     VARCHAR2  destination charset for convert
  --      In: P_SOURCE_SEPARATOR        VARCHAR2  source separator for replacement
  --      In: P_DESTINATION_FILENAME    VARCHAR2  output file name
  --      In: P_XML_TEMPLATE_LANGUAGE   VARCHAR2  template language of NA exception report
  --      In: P_XML_TEMPLATE_TERRITORY  VARCHAR2  template territory of NA exception report
  --      In: P_XML_OUTPUT_FORMAT       VARCHAR2  output format of NA exception report
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Export_Coa_Entry(Errbuf                   OUT NOCOPY VARCHAR2,
                             Retcode                  OUT NOCOPY VARCHAR2,
                             P_COA_ID                 IN NUMBER,
                             p_Le_Id                  IN NUMBER,
                             p_Ledger_Id              IN NUMBER,
                             p_Account_Type           IN VARCHAR2,
                             p_Source_Charset         IN VARCHAR2,
                             p_Destination_Charset    IN VARCHAR2,
                             p_Source_Separator       IN VARCHAR2,
                             p_Destination_Filename   IN VARCHAR2,
                             p_Xml_Template_Language  IN VARCHAR2 DEFAULT 'zh',
                             p_Xml_Template_Territory IN VARCHAR2 DEFAULT '00',
                             p_Xml_Output_Format      IN VARCHAR2 DEFAULT 'RTF') IS
    l_Reqid     NUMBER;
    l_Chr_Reqid NUMBER; -- Request id for the 'Charset Convert'
    l_Fn_Reqid  NUMBER; -- Request id for the 'Change filename'

    l_Chr_Result VARCHAR2(10);
    l_Fn_Result  VARCHAR2(10);

    l_Req_Phase   Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Req_Status  Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_User_Phase  Fnd_Lookup_Values.Meaning%TYPE;
    l_User_Status Fnd_Lookup_Values.Meaning%TYPE;
    l_Err_Msg     VARCHAR2(1000) := NULL;

    --
    l_program_name varchar(100) := '';

  BEGIN

    IF P_ACCOUNT_TYPE = 'NA' THEN
      l_program_name := 'JACNNAGN';
    ELSIF P_ACCOUNT_TYPE = 'PJ' THEN
      l_program_name := 'JACNPJGN';
    ELSIF P_ACCOUNT_TYPE = 'TP' THEN
      l_program_name := 'JACNTPGN';
    ELSIF P_ACCOUNT_TYPE = 'CC' THEN
      l_program_name := 'JACNCCGN';
    ELSIF P_ACCOUNT_TYPE = 'PERSON' THEN
      l_program_name := 'JACNPSGN';
    END IF;

    l_reqid := FND_REQUEST.Submit_Request(application => 'JA',
                                          program     => l_program_name,
                                          argument1   => P_COA_ID,
                                          argument2   => P_LE_ID,
                                          argument3   => P_LEDGER_ID,
                                          argument4   => P_ACCOUNT_TYPE,
                                          argument5   => P_XML_TEMPLATE_LANGUAGE,
                                          argument6   => P_XML_TEMPLATE_TERRITORY,
                                          argument7   => P_XML_OUTPUT_FORMAT);
    COMMIT;

    IF l_Reqid <> 0 THEN
      IF Fnd_Concurrent.Wait_For_Request(Request_Id => l_Reqid,
                                         INTERVAL   => 5,
                                         Phase      => l_User_Phase,
                                         Status     => l_User_Status,
                                         Dev_Phase  => l_Req_Phase,
                                         Dev_Status => l_Req_Status,
                                         Message    => l_Err_Msg) THEN

       /* fnd_file.PUT_LINE(fnd_file.LOG,'l_user_phase: '||l_user_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_user_status: '||l_user_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_phase: '||l_req_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_status: '||l_req_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_err_msg: '||l_err_msg);*/

        IF l_Req_Status = 'NORMAL' THEN
          -- submit charset conversiong
          Ja_Cn_Utility.Submit_Charset_Conversion(p_Xml_Request_Id      => l_Reqid,
                                                  p_Source_Charset      => p_Source_Charset,
                                                  p_Destination_Charset => p_Destination_Charset,
                                                  p_Source_Separator    => p_Source_Separator,
                                                  x_Charset_Request_Id  => l_Chr_Reqid,
                                                  x_Result_Flag         => l_Chr_Result);

          IF l_Chr_Result = 'Success' THEN
            -- submit change output filename
            Ja_Cn_Utility.Change_Output_Filename(p_Xml_Request_Id       => l_Reqid,
                                                 p_Destination_Charset  => p_Destination_Charset,
                                                 p_Destination_Filename => p_Destination_Filename,
                                                 x_Filename_Request_Id  => l_Fn_Reqid,
                                                 x_Result_Flag          => l_Fn_Result);
            IF l_Fn_Result = 'Success' THEN
              Retcode := 0;
              RETURN;
            ELSIF l_Fn_Result = 'Warning' THEN
              Retcode := 1;
            ELSE
              Retcode := 2;
            END IF;
          ELSIF l_Chr_Result = 'Warning' THEN
            Retcode := 1;
          ELSE
            Retcode := 2;
          END IF;
        END IF;
      END IF;
    END IF;
    Retcode := 1;
  END Export_Coa_Entry;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Ent_GSSM_Export               Public
  --
  --  DESCRIPTION:
  --      This procedure calls GSSM Export program to export GSSM for
  --      Enterprise.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/17/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Ent_Gssm_Export(Errbuf  OUT NOCOPY VARCHAR2,
                            Retcode OUT NOCOPY VARCHAR2) IS
  BEGIN
    Ja_Cn_Gssm_Exp_Pkg.Gssm_Export(Errbuf      => Errbuf,
                                   Retcode     => Retcode,
                                   p_Gssm_Type => 'ENT');
  END Ent_Gssm_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Ent_GSSM_Export_Entry         Public
  --
  --  DESCRIPTION:
  --      This procedure submits the program of Enterprise's GSSM Export, and
  --      then changes the output file's CharSet and file name.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_SOURCE_CHARSET        VARCHAR2  source charset for convert
  --      In: P_DESTINATION_CHARSET   VARCHAR2  destination charset for convert
  --      In: P_SOURCE_SEPARATOR      VARCHAR2  source separator for replacement
  --      In: P_DESTINATION_FILENAME  VARCHAR2  output file name
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Ent_Gssm_Export_Entry(Errbuf                 OUT NOCOPY VARCHAR2,
                                  Retcode                OUT NOCOPY VARCHAR2,
                                  p_Source_Charset       IN VARCHAR2,
                                  p_Destination_Charset  IN VARCHAR2,
                                  p_Source_Separator     IN VARCHAR2,
                                  p_Destination_Filename IN VARCHAR2) IS
    l_Reqid     NUMBER;
    l_Chr_Reqid NUMBER; -- Request id for the 'Charset Convert'
    l_Fn_Reqid  NUMBER; -- Request id for the 'Change filename'

    l_Chr_Result VARCHAR2(10);
    l_Fn_Result  VARCHAR2(10);

    l_Req_Phase   Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Req_Status  Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_User_Phase  Fnd_Lookup_Values.Meaning%TYPE;
    l_User_Status Fnd_Lookup_Values.Meaning%TYPE;
    l_Err_Msg     VARCHAR2(1000) := NULL;

  BEGIN
    --Call Concurrent of 'Ent_GSSM_Export'
    l_Reqid := Fnd_Request.Submit_Request(Application => 'JA',
                                          Program     => 'JACNEGSG');
    COMMIT;

    IF l_Reqid <> 0 THEN
      IF Fnd_Concurrent.Wait_For_Request(Request_Id => l_Reqid,
                                         INTERVAL   => 5,
                                         Phase      => l_User_Phase,
                                         Status     => l_User_Status,
                                         Dev_Phase  => l_Req_Phase,
                                         Dev_Status => l_Req_Status,
                                         Message    => l_Err_Msg) THEN
        /*fnd_file.PUT_LINE(fnd_file.LOG,'l_user_phase: '||l_user_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_user_status: '||l_user_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_phase: '||l_req_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_status: '||l_req_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_err_msg: '||l_err_msg);*/
        IF l_Req_Status = 'NORMAL' THEN
          -- submit charset conversiong
          Ja_Cn_Utility.Submit_Charset_Conversion(p_Xml_Request_Id      => l_Reqid,
                                                  p_Source_Charset      => p_Source_Charset,
                                                  p_Destination_Charset => p_Destination_Charset,
                                                  p_Source_Separator    => p_Source_Separator,
                                                  x_Charset_Request_Id  => l_Chr_Reqid,
                                                  x_Result_Flag         => l_Chr_Result);
          IF l_Chr_Result = 'Success' THEN
            -- submit change output filename
            Ja_Cn_Utility.Change_Output_Filename(p_Xml_Request_Id       => l_Reqid,
                                                 p_Destination_Charset  => p_Destination_Charset,
                                                 p_Destination_Filename => p_Destination_Filename,
                                                 x_Filename_Request_Id  => l_Fn_Reqid,
                                                 x_Result_Flag          => l_Fn_Result);
            IF l_Fn_Result = 'Success' THEN
              Retcode := 0;
              RETURN;
            ELSIF l_Fn_Result = 'Warning' THEN
              Retcode := 1;
            ELSE
              Retcode := 2;
            END IF;
          ELSIF l_Chr_Result = 'Warning' THEN
            Retcode := 1;
          ELSE
            Retcode := 2;
          END IF;
        END IF;
      END IF;
    END IF;
    Retcode := 1;
  END Ent_Gssm_Export_Entry;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Pub_GSSM_Export               Public
  --
  --  DESCRIPTION:
  --      This procedure calls GSSM Export program to export GSSM for
  --      Public Sector.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/17/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Pub_Gssm_Export(Errbuf  OUT NOCOPY VARCHAR2,
                            Retcode OUT NOCOPY VARCHAR2) IS
  BEGIN
    Ja_Cn_Gssm_Exp_Pkg.Gssm_Export(Errbuf      => Errbuf,
                                   Retcode     => Retcode,
                                   p_Gssm_Type => 'PUB');
  END Pub_Gssm_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Pub_GSSM_Export_Entry         Public
  --
  --  DESCRIPTION:
  --      This procedure submits the program of Public Sector's GSSM Export, and
  --      then changes the output file's CharSet and file name.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_SOURCE_CHARSET        VARCHAR2  source charset for convert
  --      In: P_DESTINATION_CHARSET   VARCHAR2  destination charset for convert
  --      In: P_SOURCE_SEPARATOR      VARCHAR2  source separator for replacement
  --      In: P_DESTINATION_FILENAME  VARCHAR2  output file name
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/03/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE Pub_Gssm_Export_Entry(Errbuf                 OUT NOCOPY VARCHAR2,
                                  Retcode                OUT NOCOPY VARCHAR2,
                                  p_Source_Charset       IN VARCHAR2,
                                  p_Destination_Charset  IN VARCHAR2,
                                  p_Source_Separator     IN VARCHAR2,
                                  p_Destination_Filename IN VARCHAR2) IS
    l_Reqid     NUMBER;
    l_Chr_Reqid NUMBER; -- Request id for the 'Charset Convert'
    l_Fn_Reqid  NUMBER; -- Request id for the 'Change filename'

    l_Chr_Result VARCHAR2(10);
    l_Fn_Result  VARCHAR2(10);

    l_Req_Phase   Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Req_Status  Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_User_Phase  Fnd_Lookup_Values.Meaning%TYPE;
    l_User_Status Fnd_Lookup_Values.Meaning%TYPE;
    l_Err_Msg     VARCHAR2(1000) := NULL;

  BEGIN
    --Call Concurrent of 'Pub_GSSM_Export'
    l_Reqid := Fnd_Request.Submit_Request(Application => 'JA',
                                          Program     => 'JACNPGSG');
    COMMIT;

    IF l_Reqid <> 0 THEN
      IF Fnd_Concurrent.Wait_For_Request(Request_Id => l_Reqid,
                                         INTERVAL   => 5,
                                         Phase      => l_User_Phase,
                                         Status     => l_User_Status,
                                         Dev_Phase  => l_Req_Phase,
                                         Dev_Status => l_Req_Status,
                                         Message    => l_Err_Msg) THEN
        /*fnd_file.PUT_LINE(fnd_file.LOG,'l_user_phase: '||l_user_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_user_status: '||l_user_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_phase: '||l_req_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_status: '||l_req_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_err_msg: '||l_err_msg);*/
        IF l_Req_Status = 'NORMAL' THEN
          -- submit charset conversiong
          Ja_Cn_Utility.Submit_Charset_Conversion(p_Xml_Request_Id      => l_Reqid,
                                                  p_Source_Charset      => p_Source_Charset,
                                                  p_Destination_Charset => p_Destination_Charset,
                                                  p_Source_Separator    => p_Source_Separator,
                                                  x_Charset_Request_Id  => l_Chr_Reqid,
                                                  x_Result_Flag         => l_Chr_Result);
          IF l_Chr_Result = 'Success' THEN
            -- submit change output filename
            Ja_Cn_Utility.Change_Output_Filename(p_Xml_Request_Id       => l_Reqid,
                                                 p_Destination_Charset  => p_Destination_Charset,
                                                 p_Destination_Filename => p_Destination_Filename,
                                                 x_Filename_Request_Id  => l_Fn_Reqid,
                                                 x_Result_Flag          => l_Fn_Result);
            IF l_Fn_Result = 'Success' THEN
              Retcode := 0;
              RETURN;
            ELSIF l_Fn_Result = 'Warning' THEN
              Retcode := 1;
            ELSE
              Retcode := 2;
            END IF;
          ELSIF l_Chr_Result = 'Warning' THEN
            Retcode := 1;
          ELSE
            Retcode := 2;
          END IF;
        END IF;
      END IF;
    END IF;
    Retcode := 1;
  END Pub_Gssm_Export_Entry;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    ACCOUNT_BALANCE_EXPORT                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the account balances.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf              Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode             Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity      Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --      In: P_XML_TEMPLATE_LANGUAGE    template language of exception report
  --      In: P_XML_TEMPLATE_TERRITORY   template territory of exception report
  --      In: P_XML_OUTPUT_FORMAT        output format of exception report
  --      In: P_SOURCE_CHARSET           source charset for convert
  --      In: P_DESTINATION_CHARSET      destination charset for convert
  --      In: P_SOURCE_SEPARATOR         source separator for replacement
  --      In: P_DESTINATION_FILENAME     output file name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      19-Jun-2006     Joseph Wang Created
  --      05-July-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --===========================================================================
  PROCEDURE Account_Balance_Export(Errbuf                   OUT NOCOPY VARCHAR2,
                                   Retcode                  OUT NOCOPY VARCHAR2,
                                   p_coa_id                 IN NUMBER,
                                   p_ledger_id              IN NUMBER,
                                   p_Legal_Entity           IN NUMBER,
                                   p_Start_Period           IN VARCHAR2,
                                   p_End_Period             IN VARCHAR2,
                                   p_Xml_Template_Language  IN VARCHAR2,
                                   p_Xml_Template_Territory IN VARCHAR2,
                                   p_Xml_Output_Format      IN VARCHAR2,
                                   p_Source_Charset         VARCHAR2,
                                   p_Destination_Charset    VARCHAR2,
                                   p_Source_Separator       VARCHAR2,
                                   p_Destination_Filename   VARCHAR2) IS

    l_Reqid     NUMBER;
    l_Chr_Reqid NUMBER; -- Request id for the 'Charset Convert'
    l_Fn_Reqid  NUMBER; -- Request id for the 'Change filename'

    l_Chr_Result VARCHAR2(10);
    l_Fn_Result  VARCHAR2(10);

    l_Req_Phase   Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Req_Status  Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_User_Phase  Fnd_Lookup_Values.Meaning%TYPE;
    l_User_Status Fnd_Lookup_Values.Meaning%TYPE;
    l_Err_Msg     VARCHAR2(1000) := NULL;

  BEGIN

    l_Reqid := Fnd_Request.Submit_Request(Application => 'JA',
                                          Program     => 'JACNABGE',
                                          Argument1   => p_coa_id,
                                          Argument2   => p_Ledger_Id, --added by lyb
                                          Argument3   => p_Legal_Entity, --added by lyb
                                          Argument4   => p_Start_Period,
                                          Argument5   => p_End_Period,
                                          Argument6   => p_Xml_Template_Language,
                                          Argument7   => p_Xml_Template_Territory,
                                          Argument8   => p_Xml_Output_Format);
    COMMIT;

    IF l_Reqid <> 0 THEN
      IF Fnd_Concurrent.Wait_For_Request(Request_Id => l_Reqid,
                                         INTERVAL   => 5,
                                         Phase      => l_User_Phase,
                                         Status     => l_User_Status,
                                         Dev_Phase  => l_Req_Phase,
                                         Dev_Status => l_Req_Status,
                                         Message    => l_Err_Msg) THEN
        /*fnd_file.PUT_LINE(fnd_file.LOG,'l_user_phase: '||l_user_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_user_status: '||l_user_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_phase: '||l_req_phase);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_req_status: '||l_req_status);
        fnd_file.PUT_LINE(fnd_file.LOG,'l_err_msg: '||l_err_msg);*/
        IF l_Req_Status = 'NORMAL' THEN
          -- submit charset conversiong
          Ja_Cn_Utility.Submit_Charset_Conversion(p_Xml_Request_Id      => l_Reqid,
                                                  p_Source_Charset      => p_Source_Charset,
                                                  p_Destination_Charset => p_Destination_Charset,
                                                  p_Source_Separator    => p_Source_Separator,
                                                  x_Charset_Request_Id  => l_Chr_Reqid,
                                                  x_Result_Flag         => l_Chr_Result);
          IF l_Chr_Result = 'Success' THEN
            -- submit change output filename
            Ja_Cn_Utility.Change_Output_Filename(p_Xml_Request_Id       => l_Reqid,
                                                 p_Destination_Charset  => p_Destination_Charset,
                                                 p_Destination_Filename => p_Destination_Filename,
                                                 x_Filename_Request_Id  => l_Fn_Reqid,
                                                 x_Result_Flag          => l_Fn_Result);
            IF l_Fn_Result = 'Success' THEN
              Retcode := 0;
              RETURN;
            ELSIF l_Fn_Result = 'Warning' THEN
              Retcode := 1;
            ELSE
              Retcode := 2;
            END IF;
          ELSIF l_Chr_Result = 'Warning' THEN
            Retcode := 1;
          ELSE
            Retcode := 2;
          END IF;
        END IF;
      END IF;
    END IF;
    Retcode := 1;

  END Account_Balance_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    ACCOUNT_BALANCE_GENERATION                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to generate the account balances.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf              Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode             Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity      Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --      In: P_XML_TEMPLATE_LANGUAGE    template language of exception report
  --      In: P_XML_TEMPLATE_TERRITORY   template territory of exception report
  --      In: P_XML_OUTPUT_FORMAT        output format of exception report
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      19-Jun-2006     Joseph Wang Created
  --      05-July-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --===========================================================================

  PROCEDURE Account_Balance_Generation(Errbuf                   OUT NOCOPY VARCHAR2,
                                       Retcode                  OUT NOCOPY VARCHAR2,
                                       p_coa_id                 IN NUMBER,
                                       p_ledger_id              IN NUMBER,
                                       p_Legal_Entity           IN NUMBER,
                                       p_Start_Period           IN VARCHAR2,
                                       p_End_Period             IN VARCHAR2,
                                       p_Xml_Template_Language  IN VARCHAR2,
                                       p_Xml_Template_Territory IN VARCHAR2,
                                       p_Xml_Output_Format      IN VARCHAR2) IS
  BEGIN
    Ja_Cn_Ab_Exp_Pkg.Run_Export(Errbuf                   => Errbuf,
                                Retcode                  => Retcode,
                                p_coa_id                 => p_coa_id,
                                p_ledger_id              => p_ledger_id,
                                p_Legal_Entity           => p_Legal_Entity,
                                p_Start_Period           => p_Start_Period,
                                p_End_Period             => p_End_Period,
                                p_Xml_Template_Language  => p_Xml_Template_Language,
                                p_Xml_Template_Territory => p_Xml_Template_Territory,
                                p_Xml_Output_Format      => p_Xml_Output_Format);
  END Account_Balance_Generation;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    JOURNAL_ENTRY_EXPORT                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the journal entries.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                     Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                    Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity             Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --      In:        P_SOURCE_CHARSET           source charset for convert
  --      In:        P_DESTINATION_CHARSET      destination charset for convert
  --      In:        P_SOURCE_SEPARATOR         source separator for replacement
  --      In:        P_DESTINATION_FILENAME     output file name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      01-Mar-2006     Joseph Wang Created
  --      15-Jun-2006     Add parameters P_XML_TEMPLATE_LANGUAGE, P_XML_TEMPLATE_TERRITORY, P_XML_OUTPUT_FORMAT
  --      19-Jun-2006     Add parameters P_SOURCE_CHARSET, P_DESTINATION_CHARSET,P_SOURCE_SEPARATOR,
  --                      P_DESTINATION_FILENAME
  --      05-July-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --
  --===========================================================================

  PROCEDURE Journal_Entry_Export(Errbuf                 OUT NOCOPY VARCHAR2,
                                 Retcode                OUT NOCOPY VARCHAR2,
                                 p_coa_id               IN NUMBER, --added by lyb
                                 p_ledger_id            IN NUMBER, --added by lyb
                                 p_Legal_Entity         IN NUMBER,
                                 p_Start_Period         IN VARCHAR2,
                                 p_End_Period           IN VARCHAR2,
                                 p_Source_Charset       VARCHAR2,
                                 p_Destination_Charset  VARCHAR2,
                                 p_Source_Separator     VARCHAR2,
                                 p_Destination_Filename VARCHAR2) IS

    l_Reqid     NUMBER;
    l_Chr_Reqid NUMBER; -- Request id for the 'Charset Convert'
    l_Fn_Reqid  NUMBER; -- Request id for the 'Change filename'

    l_Chr_Result VARCHAR2(10);
    l_Fn_Result  VARCHAR2(10);

    l_Req_Phase   Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Req_Status  Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_User_Phase  Fnd_Lookup_Values.Meaning%TYPE;
    l_User_Status Fnd_Lookup_Values.Meaning%TYPE;
    l_Err_Msg     VARCHAR2(1000) := NULL;

  BEGIN
    l_Reqid := Fnd_Request.Submit_Request(Application => 'JA',
                                          Program     => 'JACNJEGE',
                                          Argument1   => p_coa_id,
                                          argument2   => p_ledger_id,
                                          Argument3   => p_Legal_Entity,
                                          Argument4   => p_Start_Period,
                                          Argument5   => p_End_Period);
    COMMIT;

    IF l_Reqid <> 0 THEN
      IF Fnd_Concurrent.Wait_For_Request(Request_Id => l_Reqid,
                                         INTERVAL   => 5,
                                         Phase      => l_User_Phase,
                                         Status     => l_User_Status,
                                         Dev_Phase  => l_Req_Phase,
                                         Dev_Status => l_Req_Status,
                                         Message    => l_Err_Msg) THEN
        IF l_Req_Status = 'NORMAL' THEN
          -- submit charset conversiong
          Ja_Cn_Utility.Submit_Charset_Conversion(p_Xml_Request_Id      => l_Reqid,
                                                  p_Source_Charset      => p_Source_Charset,
                                                  p_Destination_Charset => p_Destination_Charset,
                                                  p_Source_Separator    => p_Source_Separator,
                                                  x_Charset_Request_Id  => l_Chr_Reqid,
                                                  x_Result_Flag         => l_Chr_Result);
          IF l_Chr_Result = 'Success' THEN
            -- submit change output filename
            Ja_Cn_Utility.Change_Output_Filename(p_Xml_Request_Id       => l_Reqid,
                                                 p_Destination_Charset  => p_Destination_Charset,
                                                 p_Destination_Filename => p_Destination_Filename,
                                                 x_Filename_Request_Id  => l_Fn_Reqid,
                                                 x_Result_Flag          => l_Fn_Result);
            IF l_Fn_Result = 'Success' THEN
              Retcode := 0;
              RETURN;
            ELSIF l_Fn_Result = 'Warning' THEN
              Retcode := 1;
            ELSE
              Retcode := 2;
            END IF;
          ELSIF l_Chr_Result = 'Warning' THEN
            Retcode := 1;
          ELSE
            Retcode := 2;
          END IF;
        END IF;
      END IF;
    END IF;
    Retcode := 1;
  END Journal_Entry_Export;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    JOURNAL_ENTRY_GENERATION                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to generate the journal entries.
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                     Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                    Mandatory parameter for PL/SQL concurrent programs
  --      In:        p_legal_entity             Legal entity ID
  --      In:        p_start_period             start period name
  --      In:        P_end_period               end period name
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      01-Mar-2006     Joseph Wang Created
  --      15-Jun-2006     Add parameters P_XML_TEMPLATE_LANGUAGE, P_XML_TEMPLATE_TERRITORY, P_XML_OUTPUT_FORMAT
  --      19-Jun-2006     Add parameters P_SOURCE_CHARSET, P_DESTINATION_CHARSET,P_SOURCE_SEPARATOR,
  --                      P_DESTINATION_FILENAME
  --      15-Jun-2006     Add parameters p_start_period and P_end_period
  --                      remove the parameter p_period
  --
  --===========================================================================

  PROCEDURE JOURNAL_ENTRY_GENERATION(errbuf         OUT NOCOPY VARCHAR2,
                                     retcode        OUT NOCOPY VARCHAR2,
                                     p_coa_id       IN NUMBER,
                                     p_ledger_id    IN NUMBER ,
                                     p_legal_entity IN NUMBER,
                                     p_start_period IN VARCHAR2,
                                     p_end_period   IN VARCHAR2) IS

  BEGIN

    JA_CN_JE_EXP_PKG.Run_Export(errbuf         => errbuf,
                                retcode        => retcode,
                                p_coa_id       => p_coa_id,
                                p_ledger_id    => p_ledger_id,
                                p_legal_entity_id => p_legal_entity,
                                p_start_period => p_start_period,
                                p_end_period   => p_end_period);

  END JOURNAL_ENTRY_GENERATION;

END Ja_Cn_Etc_Conc_Prog;


/
