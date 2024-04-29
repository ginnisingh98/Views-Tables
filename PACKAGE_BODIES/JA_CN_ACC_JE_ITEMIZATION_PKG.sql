--------------------------------------------------------
--  DDL for Package Body JA_CN_ACC_JE_ITEMIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_ACC_JE_ITEMIZATION_PKG" AS
  --$Header: JACNAJIB.pls 120.9.12010000.4 2009/10/10 05:36:48 wuwu ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|       JACNAJIB.pls                                                    |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used in account and journal itemizatoin to        |
  --|     generate                                                          |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE populate_journal_of_period                             |
  --|      PROCEDURE unitemize_journal_lines                                |
  --|      PROCEDURE generate_code_combination_view                         |
  --|      PROCEDURE get_period_range                                       |
  --|      PROCEDURE transfer_gl_sla_to_cnao                                |
  --|      PROCEDURE generate_journal_and_line_num                          |
  --|      PROCEDURE purge_unmatch_lines                                    |
  --|      PROCEDURE get_journal_approver                                   |
  --|      PROCEDURE get_lookup_code                                        |
  --|                                                                       |
  --| HISTORY                                                               |
  --|    02/21/2006   Qingjun Zhao     Created                              |
  --|    04/10/2006   Qingjun Zhao     update generate_code_combiantion_view|
  --|    05/16/2006   Qingjun Zhao     Add procedure get_journal_approver   |
  --|    05/24/2006   Qingjun Zhao     Add procedure purge_unmatch_lines    |
  --|    04/12/2007   Qingjun Zhao     Update for Release 12,extract project|
  --|                                  ,third party by using Supporting     |
  --|                                  Reference functionality
  --|    07/09/2009   Chaoqun Wu       Fixing bug#8670470              |
  --|    10/10/2009   Chaoqun Wu       Fix bug 8970684, "CHART OF ACCOUNTS  |
  --|                                  EXPORT - SUBSIDIARY ACCOUNT -        |
  --|                                  PERSONNEL" IS NULL                   |
  --+========================================================================
  l_Module_Prefix VARCHAR2(100) := 'JA_CN_ACC_JE_ITEMIZATION_PKG';
  --  l_Ledger_Id            NUMBER;
  l_Chart_Of_Accounts_Id NUMBER;
  l_Legal_Entity_Id      NUMBER;
  l_ledger_id            number;
  l_Project_Option       VARCHAR2(240);
  PROCEDURE Test_Concurrent_Conflict IS
    l_Message VARCHAR2(1000) := 'This concurrent is used to test both concurrents call procedure in same package';
  BEGIN
    Fnd_File.Put_Line(Fnd_File.Log, l_Message);
  END;
  --==========================================================================
  --  PROCEDURE NAME:
  --    get_journal_approver                   Private
  --
  --  DESCRIPTION:
  --        This procedure is used to get approver of journal in General Ledger
  --        if the journal has been appoved
  --  PARAMETERS:
  --      In: p_request_id                  identifier of current session
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/16/2006     Qingjun Zhao          Created
  --      04/29/2006     Qingjun Zhao          Change for
  --==========================================================================
  PROCEDURE Get_Journal_Approver(p_Request_Id IN NUMBER) IS
    l_Request_Id      NUMBER := p_Request_Id;
    l_Je_Header_Id    NUMBER;
    l_Batch_Name      Gl_Je_Batches.NAME%TYPE;
    l_Period_Name     Gl_Periods.Period_Name%TYPE;
    l_Approver        VARCHAR2(100);
    l_Approval_Status VARCHAR2(1);
    l_Approver_Name   VARCHAR2(100);
    l_Step            VARCHAR2(100);
    l_Proc_Name       VARCHAR2(30) := 'get_journal_approver';
    l_Dbg_Level       NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level      NUMBER := Fnd_Log.Level_Procedure;
    l_Statement_Level NUMBER := Fnd_Log.Level_Statement;
    l_Exception_Level NUMBER := Fnd_Log.Level_Exception;
    CURSOR c_Journal IS
      SELECT DISTINCT Jop.Je_Header_Id
        FROM Ja_Cn_Journals_Of_Period Jop, Gl_Je_Sources_Tl Gjs
       WHERE Jop.Request_Id = l_Request_Id
         AND Gjs.Je_Source_Name = Jop.Je_Source
         AND Gjs.Source_Lang = Userenv('LANG')
         AND Gjs.LANGUAGE = Userenv('LANG')
         AND Gjs.Journal_Approval_Flag = 'Y';
    CURSOR c_Batch_Status IS
      SELECT Jeb.Default_Period_Name, Jeb.NAME, Jeb.Approval_Status_Code
        FROM Gl_Je_Headers Jeh, Gl_Je_Batches Jeb
       WHERE Jeb.Je_Batch_Id = Jeh.Je_Batch_Id
         AND Jeh.Je_Header_Id = l_Je_Header_Id;

    CURSOR c_Batch_Approver IS
      SELECT d.Text_Value
        FROM Wf_Items t, Wf_Item_Attribute_Values d
       WHERE d.Item_Key = t.Item_Key
         AND d.NAME = 'APPROVER_NAME'
         AND t.User_Key = l_Batch_Name
         AND d.Item_Type = 'GLBATCH'
         AND t.Begin_Date IN
             (SELECT MAX(It.Begin_Date)
                FROM Wf_Items                 It,
                     Wf_Item_Attribute_Values T1,
                     Wf_Item_Attribute_Values t
               WHERE It.User_Key = l_Batch_Name
                 AND It.Item_Key = t.Item_Key
                 AND T1.Item_Type = 'GLBATCH'
                 AND T1.Item_Key = t.Item_Key
                 AND t.Item_Type = 'GLBATCH'
                 AND t.NAME = 'BATCH_NAME'
                 AND t.Text_Value = l_Batch_Name
                 AND T1.NAME = 'PERIOD_NAME'
                 AND T1.Text_Value = l_Period_Name);
    --                               group by it.item_key);

    CURSOR c_Approver_Name IS
      SELECT Last_Name || First_Name Full_Name
        FROM Per_All_People_f
       WHERE Person_Id =
             (SELECT Employee_Id FROM Fnd_User WHERE User_Name = l_Approver);

  BEGIN
    --log
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'begin procedure');

    END IF; --l_procedure_level >= l_runtime_level

    OPEN c_Journal;
    LOOP
      FETCH c_Journal
        INTO l_Je_Header_Id;
      EXIT WHEN c_Journal%NOTFOUND;
      --get batch name and period name
      l_Step := To_Char(l_Je_Header_Id);
      OPEN c_Batch_Status;
      FETCH c_Batch_Status
        INTO l_Period_Name, l_Batch_Name, l_Approval_Status;
      l_Step := l_Period_Name || l_Batch_Name || l_Approval_Status;

      IF Nvl(l_Approval_Status, 'N') = 'A' THEN
        -- get approver
        OPEN c_Batch_Approver;
        FETCH c_Batch_Approver
          INTO l_Approver;
        l_Step := l_Approver;

        IF c_Batch_Approver%FOUND THEN

          OPEN c_Approver_Name;
          FETCH c_Approver_Name
            INTO l_Approver_Name;

          IF c_Approver_Name%FOUND THEN
            UPDATE Ja_Cn_Journal_Lines_Req t
               SET t.Journal_Approver = l_Approver_Name
             WHERE t.Je_Header_Id = l_Je_Header_Id;
          END IF; --c_approver_name%found

          CLOSE c_Approver_Name;
        END IF; --c_batch_approver%found

        CLOSE c_Batch_Approver;
      END IF; --nvl(l_approval_status,'N') = 'A'
      CLOSE c_Batch_Status;
    END LOOP; --c_journal

    CLOSE c_Journal;
    -- log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_File.Put_Line(Fnd_File.Log, 'l_step:' || l_Step);
      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Get_Journal_Approver;
  --==========================================================================
  --  FUNCTION NAME:
  --    get_lookup_code                   Private
  --
  --  DESCRIPTION:
  --        This function is used to get lookup code of lookup meaning,
  --  PARAMETERS:
  --      In: p_lookup_meaning      lookup meaning
  --          p_lookup_type         lookup code
  --          p_view_application_id view application, DEFAULT 0
  --          p_security_group_id   security group
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --==========================================================================
  FUNCTION Get_Lookup_Code(p_Lookup_Meaning      IN VARCHAR2,
                           p_Lookup_Type         IN VARCHAR2,
                           p_View_Application_Id IN NUMBER DEFAULT 0,
                           p_Security_Group_Id   IN NUMBER DEFAULT 0)
    RETURN VARCHAR2 IS

    l_Procedure_Name  VARCHAR2(30) := 'get_lookup_code';
    l_Lookup_Code     Fnd_Lookup_Values.Lookup_Code%TYPE := NULL;
    l_Runtime_Level   NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Procedure_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Statement_Level NUMBER := Fnd_Log.Level_Statement;
    l_Exception_Level NUMBER := Fnd_Log.Level_Exception;

    -- this cursor is to get looup_meaning under some lookup_code
    CURSOR c_Lookup IS
      SELECT Flv.Lookup_Code
        FROM Fnd_Lookup_Values Flv
       WHERE Flv.LANGUAGE = Userenv('LANG')
         AND Flv.Lookup_Type = p_Lookup_Type
         AND Flv.Meaning = p_Lookup_Meaning
         AND Flv.View_Application_Id = p_View_Application_Id
         AND Flv.Security_Group_Id = p_Security_Group_Id;

  BEGIN
    --log
    IF (l_Procedure_Level >= l_Runtime_Level) THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.begin',
                     'begin procedure');
    END IF; --l_procedure_level >= l_runtime_level

    IF p_Lookup_Meaning IS NULL THEN
      l_Lookup_Code := NULL;
    ELSE
      OPEN c_Lookup;
      FETCH c_Lookup
        INTO l_Lookup_Code;
      IF c_Lookup%NOTFOUND THEN
        l_Lookup_Code := NULL;
      END IF;
      CLOSE c_Lookup;
    END IF; --IF p_lookup_code IS NULL

    --log
    IF (l_Procedure_Level >= l_Runtime_Level) THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.end',
                     'end procedure');
    END IF; --l_procedure_level >= l_runtime_level

    RETURN l_Lookup_Code;

  END Get_Lookup_Code;
  --==========================================================================
  --  PROCEDURE NAME:
  --    populate_journal_of_period                   Private
  --
  --  DESCRIPTION:
  --        This procedure is used to populate journal with period ,journal
  --        soruce and category, which company segment is possessed by current
  --        legal entity into table JA_CN_JOURNALS_OF_PERIOD
  --  PARAMETERS:
  --      In: p_start_period               the start period name from which
  --                                       current SOB is start-up
  --         p_end_period                  the till period name to which
  --                                       the CNAO journal should be processed
  --         p_request_id                  identifier of current session
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --      07/09/2009     Chaoqun Wu            Fixing bug#8670470
  --==========================================================================
  PROCEDURE Populate_Journal_Of_Period(p_Start_Period    IN VARCHAR2,
                                       p_ledger_id       in number,
                                       p_legal_entity_id in number,
                                       p_End_Period      IN VARCHAR2,
                                       p_Request_Id      IN NUMBER) IS
    l_Populate_Journal_Sql VARCHAR2(4000);
    l_Company_Column_Name  VARCHAR2(30);
    l_Start_Period         VARCHAR2(15);
    l_End_Period           VARCHAR2(15);
    l_Request_Id           NUMBER;
    l_ledger_id            number;
    l_legal_entity_id      number;
    --    l_Populate_Bsv_Flag    number;
    --    l_Populate_Bsv_F       varchar2(1);
    l_Dbg_Level         NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level        NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name         VARCHAR2(100) := 'populate_journal_of_period';
    l_Populate_Bsv_Flag VARCHAR2(1);
  BEGIN

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_start_period: ' || p_Start_Period);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_end_period: ' || p_End_Period);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_request_id: ' || p_Request_Id);
    END IF; --(l_proc_level >= l_dbg_level)

    l_Start_Period    := p_Start_Period;
    l_End_Period      := p_End_Period;
    l_Request_Id      := p_Request_Id;
    l_ledger_id       := p_ledger_id;
    l_legal_entity_id := P_legal_entity_id;
    --populate BSV for current legal entity and ledger
    l_Populate_Bsv_Flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt(l_Ledger_Id,
                                                                   l_Legal_Entity_Id);
    IF l_Populate_Bsv_Flag = 'F' THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name,
                       'fail to populate BSV');
      END IF; --(l_proc_level >= l_dbg_level)
    END IF;

    --get application column name of company segment
    SELECT Fsav.Application_Column_Name
      INTO l_Company_Column_Name
      FROM Fnd_Id_Flex_Segments         Fifs,
           Fnd_Segment_Attribute_Values Fsav,
           Gl_Ledgers                   Led
     WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
       AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
       AND Fsav.Segment_Attribute_Type = 'GL_BALANCING'
       AND Fsav.Attribute_Value = 'Y'
       AND Fifs.Application_Id = 101
       and fifs.id_flex_code = fsav.id_flex_code
       and fifs.id_flex_code = 'GL#'
       AND Fifs.Application_Id = Fsav.Application_Id
       AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
       AND Led.Ledger_Id = l_Ledger_Id;

    --generate dynamic sql to populate journal into ja_cn_journals_of_period,
    --which will be itemized.
    l_Populate_Journal_Sql := 'INSERT INTO ja_cn_journals_of_period' ||
                              '(je_header_id' || ',je_line_num' ||
                              ',period_name' || ',je_category' ||
                              ',je_source' || ',legal_entity_id' ||
                              ',request_id,effective_date)' ||
                              'SELECT /*+index(jop,ja_cn_journals_of_period_n3)+*/ ' ||
                              '       jeh.je_header_id' ||
                              '      ,jel.je_line_num' ||
                              '      ,jeh.period_name' ||
                              '      ,jeh.je_category' ||
                              '      ,jeh.je_source' ||
                              '      ,bsv.legal_entity_id' || ',' ||
                              l_Request_Id ||
                              ',jeh.default_effective_date ' ||
                              ' FROM gl_je_headers             jeh' ||
                              '   ,gl_je_lines               jel' ||
                              '   ,gl_code_combinations      gcc' ||
                              '   ,gl_periods                gp' ||
                              '   ,gl_ledgers                 led' ||
                              '   ,ja_cn_ledger_le_bsv_gt bsv' ||
                              ' WHERE jeh.je_header_id = jel.je_header_id' ||
                              '   AND jeh.status = ''P''' ||
                              '   AND jeh.period_name = gp.period_name' ||
                              '  AND jel.code_combination_id = gcc.code_combination_id' ||
                              '   AND jeh.LEDGER_ID = ' || l_Ledger_Id ||
                              '   AND gcc.' || l_Company_Column_Name ||
                              ' = bsv.BAL_SEG_VALUE' ||
                              '   AND bsv.legal_entity_id = ' ||
                              l_Legal_Entity_Id ||
                              '   AND gp.start_date BETWEEN' ||
                              '       (SELECT start_date' ||
                              '          FROM gl_periods' ||
                              '         WHERE period_name =''' ||
                              l_Start_Period || '''' ||
                              '           AND period_set_name = led.period_set_name)' ||
                              '   AND (SELECT start_date' ||
                              '          FROM gl_periods' ||
                              '         WHERE period_name =''' ||
                              l_End_Period || '''' ||
                              '           AND period_set_name = led.period_set_name)' ||
                              '   AND gp.period_set_name = led.period_set_name' ||
                              '   AND gp.period_type = led.accounted_period_type' ||
                              '   AND led.ledger_id = jeh.ledger_id' ||
                              '   AND nvl(jel.global_attribute2' ||
                              '          ,''U'') <> ''P''' ||
                              '   AND jeh.ACTUAL_FLAG <> ''E'''; --Added for fixing bug#8670470 by Chaoqun on 09-JUL-2009

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name,
                     'l_populate_journal_sql:' || l_Populate_Journal_Sql);
    END IF; --(l_proc_level >= l_dbg_level)

    EXECUTE IMMEDIATE l_Populate_Journal_Sql;
    COMMIT;
    -- log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)
  EXCEPTION
    WHEN OTHERS THEN

      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Populate_Journal_Of_Period;

  --==========================================================================
  --  PROCEDURE NAME:
  --    generate_code_combination_view                   private
  --
  --  DESCRIPTION:
  --        This procedure is used to populate account segment, company segment
  --        cost center segment and project number if project option as 'COA'
  --        into view JA_CN_CODE_COMBINATION_V
  --  PARAMETERS:
  --
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --      04/10/2006     Qingjun Zhao          Deal with this situation which Cost
  --                                           segment is NULL in current Chart of
  --                                           account
  --===========================================================================
  PROCEDURE Generate_Code_Combination_View(p_ledger_id in number) IS

    l_Create_View_Sql       VARCHAR2(4000);
    l_Company_Column_Name   VARCHAR2(30);
    l_Account_Column_Name   VARCHAR2(30);
    l_Cost_Column_Name      VARCHAR2(30);
    l_Project_Column_Name   VARCHAR2(30);
    l_Dbg_Level             NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level            NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name             VARCHAR2(100) := 'generate_code_combination_view';
    l_Second_Track_Col_Name VARCHAR2(30);
    l_Other_Cols_Name       VARCHAR2(200);
    l_ledger_id             number;

    cursor c_company_segment is
      SELECT led.bal_seg_column_name
        from gl_ledgers led
       where Led.Ledger_Id = l_Ledger_Id;

    CURSOR c_Cost_Center IS
      SELECT Fsav.Application_Column_Name
        FROM Fnd_Id_Flex_Segments         Fifs,
             Fnd_Segment_Attribute_Values Fsav,
             Gl_Ledgers                   Led
       WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
         AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
         AND Fsav.Segment_Attribute_Type = 'FA_COST_CTR'
         AND Fsav.Attribute_Value = 'Y'
         AND Fifs.Application_Id = 101
         and fsav.id_flex_code = fifs.id_flex_code
         and fsav.id_flex_code = 'GL#'
         AND Fifs.Application_Id = Fsav.Application_Id
         AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
         AND Led.Ledger_Id = l_Ledger_Id;

    --jogen
    CURSOR c_Segements IS
      SELECT Fsav.Application_Column_Name
        FROM Fnd_Id_Flex_Segments         Fifs,
             Fnd_Segment_Attribute_Values Fsav,
             Gl_Ledgers                   Led
       WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
         AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
         AND Fsav.Segment_Attribute_Type = 'GL_GLOBAL'
         AND Fsav.Attribute_Value = 'Y'
         AND Fifs.Application_Id = 101
         and fifs.id_flex_code = fsav.id_flex_code
         and fifs.id_flex_code = 'GL#'
         AND Fifs.Application_Id = Fsav.Application_Id
         AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
         AND Led.Ledger_Id = l_Ledger_Id;

    --jogen
  BEGIN

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)
    l_ledger_id := p_ledger_id;
    --get application column name of company segment
    SELECT led.bal_seg_column_name
      INTO l_Company_Column_Name
      from gl_ledgers led
     where Led.Ledger_Id = l_Ledger_Id;

    --get application column name of account segment
    SELECT Fsav.Application_Column_Name
      INTO l_Account_Column_Name
      FROM Fnd_Id_Flex_Segments         Fifs,
           Fnd_Segment_Attribute_Values Fsav,
           Gl_Ledgers                   Led
     WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
       AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
       AND Fsav.Segment_Attribute_Type = 'GL_ACCOUNT'
       AND Fsav.Attribute_Value = 'Y'
       AND Fifs.Application_Id = 101
       and fsav.id_flex_code = fifs.id_flex_code
       and fsav.id_flex_code = 'GL#'
       AND Fifs.Application_Id = Fsav.Application_Id
       AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
       AND Led.Ledger_Id = l_Ledger_Id;
    l_Create_View_Sql := 'select GCC.CODE_COMBINATION_ID,led.ledger_id,' ||
                         'gcc.' || l_Company_Column_Name ||
                         ' company_segment,';
    l_Create_View_Sql := l_Create_View_Sql || 'gcc.' ||
                         l_Account_Column_Name || ' account_segment,';

    --get application column name of cost center segment
    OPEN c_Cost_Center;
    FETCH c_Cost_Center
      INTO l_Cost_Column_Name;

    IF c_Cost_Center%NOTFOUND THEN
      CLOSE c_Cost_Center;
      l_Create_View_Sql := l_Create_View_Sql ||
                           ' to_char(null)  cost_segment,';
    ELSE
      l_Create_View_Sql := l_Create_View_Sql || 'gcc.' ||
                           l_Cost_Column_Name || ' cost_segment,';
      CLOSE c_Cost_Center;
    END IF; --c_cost_center%NOTFOUND

    IF l_Project_Option = 'COA' THEN
      --get application column name of project segment
      SELECT Coa_Segment
        INTO l_Project_Column_Name
        FROM Ja_Cn_Sub_Acc_Sources_All
       WHERE Chart_Of_Accounts_Id = l_Chart_Of_Accounts_Id;
      l_Create_View_Sql := l_Create_View_Sql || 'gcc.' ||
                           l_Project_Column_Name || ' project_number,';
    ELSE
      l_Create_View_Sql := l_Create_View_Sql || 'to_char(null)' ||
                           ' project_number,';
    END IF; --l_project_option = 'COA'

    ---jogen
    BEGIN
      SELECT Fsav.Application_Column_Name
        INTO l_Second_Track_Col_Name
        FROM Fnd_Id_Flex_Segments         Fifs,
             Fnd_Segment_Attribute_Values Fsav,
             Gl_Ledgers                   Led
       WHERE Fifs.Id_Flex_Num = Fsav.Id_Flex_Num
         AND Fifs.Application_Column_Name = Fsav.Application_Column_Name
         AND Fsav.Segment_Attribute_Type = 'GL_SECONDARY_TRACKING'
         AND Fsav.Attribute_Value = 'Y'
         AND Fifs.Application_Id = 101
         and fifs.id_flex_code = fsav.id_flex_code
         and fsav.id_flex_code = 'GL#'
         AND Fifs.Application_Id = Fsav.Application_Id
         AND Led.Chart_Of_Accounts_Id = Fifs.Id_Flex_Num
         AND Led.Ledger_Id = l_Ledger_Id;
    EXCEPTION
      WHEN No_Data_Found THEN
        NULL;
    END;

    IF l_Second_Track_Col_Name IS NULL THEN
      l_Second_Track_Col_Name := 'NULL';
    END IF;

    FOR Rec_Segment IN c_Segements LOOP
      IF Rec_Segment.Application_Column_Name NOT IN
         (l_Company_Column_Name, l_Account_Column_Name, l_Cost_Column_Name,
          l_Second_Track_Col_Name) THEN
        l_Other_Cols_Name := l_Other_Cols_Name || '||''.''||' ||
                             Rec_Segment.Application_Column_Name;
      END IF;
    END LOOP;

    IF l_Other_Cols_Name IS NULL THEN
      l_Other_Cols_Name := 'NULL';
    ELSE
      l_Other_Cols_Name := Substr(l_Other_Cols_Name, 8);
    END IF;

    l_Create_View_Sql := l_Create_View_Sql || l_Second_Track_Col_Name ||
                         ' second_tracking_col,' || l_Other_Cols_Name ||
                         ' other_columns,';
    --jogen
    l_Create_View_Sql := l_Create_View_Sql ||
                         'to_number(null)  project_id from gl_code_combinations gcc,' ||
                         ' GL_LEDGERS led where led.chart_of_accounts_id ' ||
                         ' = gcc.chart_of_accounts_id';

    l_Create_View_Sql := 'create or replace view ja_cn_code_combination_v as ' ||
                         l_Create_View_Sql;

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name,
                     'l_create_view_sql:' || l_Create_View_Sql);
    END IF; --(l_proc_level >= l_dbg_level)

    EXECUTE IMMEDIATE l_Create_View_Sql;

    --log for dubug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.put_line(FND_FILE.OUTPUT,SQLCODE || ':' || SQLERRM);
      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Generate_Code_Combination_View;
  --==========================================================================
  --  PROCEDURE NAME:
  --    get_period_range                   private
  --
  --  DESCRIPTION:
  --        This procedure is used to get range of period in which journal lines
  --        will be itemized
  --  PARAMETERS:
  --        p_period_name         period inputted by user
  --        p_start_period_name   start period
  --        p_end_period_name     end period
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --===========================================================================
  PROCEDURE Get_Period_Range(p_Period_Name       IN VARCHAR2,
                             p_ledger_id         in number,
                             p_Start_Period_Name OUT NOCOPY VARCHAR2,
                             p_End_Period_Name   OUT NOCOPY VARCHAR2) IS

    l_Period_Name VARCHAR2(15);
    l_Dbg_Level   NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level  NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name   VARCHAR2(100) := 'get_period_range';
    l_ledger_id   number;
  BEGIN

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.prameter',
                     'P_period_name:' || p_Period_Name);
    END IF; --(l_proc_level >= l_dbg_level)

    l_Period_Name := p_Period_Name;
    l_ledger_id   := p_ledger_id;
    --get the first period of current led
    SELECT Gp.Period_Name
      INTO p_Start_Period_Name
      FROM Gl_Periods Gp, Gl_Ledgers Led
     WHERE Led.Ledger_Id = l_Ledger_Id
       AND Led.Period_Set_Name = Gp.Period_Set_Name
       AND Led.Accounted_Period_Type = Gp.Period_Type
       AND Gp.Start_Date IN
           (SELECT MIN(Start_Date)
              FROM Gl_Periods Gp
             WHERE Led.Period_Set_Name = Gp.Period_Set_Name
               AND Led.Accounted_Period_Type = Gp.Period_Type);

    -- if parameter period is null then pick up last open period as end period
    IF l_Period_Name IS NULL THEN
      SELECT Gp.Period_Name
        INTO p_End_Period_Name
        FROM Gl_Periods Gp, Gl_Ledgers Led
       WHERE Led.Ledger_Id = l_Ledger_Id
         AND Led.Period_Set_Name = Gp.Period_Set_Name
         AND Led.Accounted_Period_Type = Gp.Period_Type
         AND Gp.Start_Date IN
             (SELECT MAX(Start_Date)
                FROM Gl_Periods Gp
               WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                 AND Led.Accounted_Period_Type = Gp.Period_Type);
    ELSE
      p_End_Period_Name := l_Period_Name;
    END IF; --l_period_name IS NULL

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameter',
                     'p_start_period_name: ' || p_Start_Period_Name);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameter',
                     'p_end_period_name: ' || p_End_Period_Name);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN

      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Get_Period_Range;

  --==========================================================================
  --  PROCEDURE NAME:
  --    purge_unmatch_lines                   Private
  --
  --  DESCRIPTION:
  --        This procedure is used to populate the journals which cannot be
  --        drill down into possible sub legder or which is inputed directly
  --        in  manual way in Oracle General Ledger Module
  --  PARAMETERS:
  --      In: p_request_id              identifier of current session
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --===========================================================================
  PROCEDURE Purge_Unmatch_Lines(p_Request_Id IN NUMBER) IS
    l_Request_Id   NUMBER;
    l_Je_Line_Num  NUMBER;
    l_Je_Header_Id NUMBER;
    l_Error_Msg    VARCHAR2(2000);
    l_Dbg_Level    NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level   NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name    VARCHAR2(100) := 'purge_unmatch_lines';
    CURSOR c_Unmatch_Lines IS
      SELECT /*+ index(jel,gl_je_lines_u1)*/
       Req.Je_Header_Id, Req.Je_Line_Num
        FROM (SELECT SUM(Nvl(Req.Accounted_Dr, 0) - Nvl(Req.Accounted_Cr, 0)) Accounted_Amount,
                     SUM(Nvl(Req.Entered_Dr, 0) - Nvl(Req.Entered_Cr, 0)) Entered_Amount,
                     Req.Je_Header_Id,
                     Req.Je_Line_Num
                FROM Ja_Cn_Journal_Lines_Req Req
               WHERE Req.Request_Id = l_Request_Id
               GROUP BY Req.Je_Header_Id, Req.Je_Line_Num) Req,
             Gl_Je_Lines Jel
       WHERE (Nvl(Jel.Accounted_Dr, 0) - Nvl(Jel.Accounted_Cr, 0) <>
             Req.Accounted_Amount OR
             Nvl(Jel.Entered_Dr, 0) - Nvl(Jel.Entered_Cr, 0) <>
             Req.Entered_Amount)
         AND Jel.Je_Line_Num = Req.Je_Line_Num
         AND Jel.Je_Header_Id = Req.Je_Header_Id;
  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.prameter',
                     'P_request_id:' || p_Request_Id);
    END IF; --(l_proc_level >= l_dbg_level)

    l_Request_Id := p_Request_Id;
    OPEN c_Unmatch_Lines;

    LOOP
      FETCH c_Unmatch_Lines
        INTO l_Je_Header_Id, l_Je_Line_Num;
      EXIT WHEN c_Unmatch_Lines%NOTFOUND;
      --Raise error message for caller
      Fnd_Message.Set_Name(Application => 'JA', NAME => 'JA_CN_XXXX');
      Fnd_Message.Set_Token('header id', l_Je_Header_Id, TRUE);
      Fnd_Message.Set_Token('line num', l_Je_Line_Num, TRUE);
      l_Error_Msg := Fnd_Message.Get;

      --Output error message
      Fnd_File.Put_Line(Fnd_File.Log, l_Error_Msg);

      -- log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name,
                       l_Error_Msg);
      END IF; --(l_proc_level >= l_dbg_level)

      DELETE FROM Ja_Cn_Journal_Lines_Req
       WHERE Je_Header_Id = l_Je_Header_Id
         AND Je_Line_Num = l_Je_Line_Num;

    END LOOP;

    CLOSE c_Unmatch_Lines;

    -- log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)
  EXCEPTION
    WHEN OTHERS THEN

      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Purge_Unmatch_Lines;
  --==========================================================================
  --  PROCEDURE NAME:
  --    unitemize_journal_lines                   Private
  --
  --  DESCRIPTION:
  --        This procedure is used to populate the journals which cannot be
  --        drill down into possible sub legder or which is inputed directly
  --        in  manual way in Oracle General Ledger Module
  --  PARAMETERS:
  --      In: p_project_option          porject option
  --          p_request_id              identifier of current session
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --      07/12/2007     Yanbo Liu             Updated
  --===========================================================================

  PROCEDURE Unitemize_Journal_Lines(p_Project_Option IN VARCHAR2,
                                    p_Request_Id     IN NUMBER) IS

    l_Request_Id     NUMBER;
    l_Project_Option Ja_Cn_Sub_Acc_Sources_All.Project_Source_Flag%TYPE;
    l_Dbg_Level      NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level     NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name      VARCHAR2(100) := 'unitemize_journal_lines';

  BEGIN

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.prameter',
                     'P_request_id:' || p_Request_Id);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.prameter',
                     'p_project_option:' || p_Project_Option);

    END IF; --(l_proc_level >= l_dbg_level)

    l_Request_Id     := p_Request_Id;
    l_Project_Option := p_Project_Option;
    INSERT INTO Ja_Cn_Journal_Lines_Req
      (Je_Header_Id,
       Ledger_Id,
       Legal_Entity_Id,
       Journal_Number,
       Je_Category,
       Default_Effective_Date,
       Period_Name,
       Currency_Code,
       Currency_Conversion_Rate,
       Je_Line_Num,
       Line_Number,
       Description,
       Company_Segment,
       Code_Combination_Id,
       Cost_Center,
       Third_Party_Id,
       Third_Party_Number,
       Personnel_Id,
       Personnel_Number,
       Project_Number,
       Project_Source,
       Account_Segment,
       Entered_Dr,
       Entered_Cr,
       Accounted_Dr,
       Accounted_Cr,
       Status,
       Created_By,
       Creation_Date,
       Last_Updated_By,
       Last_Update_Date,
       Last_Update_Login,
       Populate_Code,
       Request_Id,
       Journal_Created_By,
       Journal_Posted_By)
      SELECT Jel.Je_Header_Id Je_Header_Id,
             Jeh.Ledger_Id Ledger_Id,
             Jop.Legal_Entity_Id Legal_Entity_Id,
             To_Number(NULL) Journal_Number,
             Jeh.Je_Category Je_Category,
             Jeh.Default_Effective_Date Default_Effective_Date,
             Jeh.Period_Name Period_Name,
             Jeh.Currency_Code Currency_Code,
             Jeh.Currency_Conversion_Rate Currency_Conversion_Rate,
             Jel.Je_Line_Num Je_Line_Num,
             To_Number(NULL) Line_Number,
             Nvl(Jel.Description, Jeh.Description) Description,
             Jcc.Company_Segment Company_Segment,
             Jcc.Code_Combination_Id Code_Combination_Id,
             Jcc.Cost_Segment Cost_Segment,
             To_Number(NULL) Third_Party_Id,
             To_Char(NULL) Third_Party_Number,
             To_Number(NULL) Personnel_Id,
             To_Char(NULL) Personnel_Number,
             Decode(Nvl(l_Project_Option, 'N'),
                    'N',
                    To_Char(NULL),
                    'COA',
                    Jcc.Project_Number,
                    To_Char(NULL)) Project_Number,
             Nvl(l_Project_Option, 'N') Project_Source,
             Jcc.Account_Segment Account_Segment,
             Jel.Entered_Dr,
             Jel.Entered_Cr,
             Jel.Accounted_Dr,
             Jel.Accounted_Cr,
             'U' Status,
             Fnd_Global.User_Id Created_Gy,
             SYSDATE Creation_Date,
             Fnd_Global.User_Id Last_Updated_By,
             SYSDATE Last_Update_Date,
             Fnd_Global.Login_Id Last_Update_Login,
             'NO ITEMIZATION',
             l_Request_Id,
             Jeh.Created_By,
             Jeb.Posted_By --added by lyb, for bug for bug 6654734
    --         Decode(Nvl(Jeh.Accrual_Rev_Status, 'N'),
    --                'R',
    --                To_Number(NULL),
    --                Jeh.Last_Updated_By)
        FROM Gl_Je_Headers            Jeh,
             Gl_Je_Lines              Jel,
             Ja_Cn_Code_Combination_v Jcc,
             Ja_Cn_Journals_Of_Period Jop,
             Gl_Je_Batches            Jeb--added by lyb, for bug 6654734
       WHERE Jeh.Je_Header_Id = Jel.Je_Header_Id
         AND Jcc.Ledger_Id = Jeh.Ledger_Id
         AND Jcc.Code_Combination_Id = Jel.Code_Combination_Id
         AND Jeh.Je_Header_Id = Jop.Je_Header_Id
         AND Jel.Je_Line_Num = Jop.Je_Line_Num
         AND Jop.Request_Id = l_Request_Id
         AND Jel.Je_Line_Num NOT IN
             (SELECT Je_Line_Num
                FROM Ja_Cn_Journal_Lines_Req
               WHERE Je_Header_Id = Jeh.Je_Header_Id)
         AND Jeb.Je_Batch_Id=Jeh.Je_Batch_Id;--added by lyb, for bug 6654734

    -- log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Unitemize_Journal_Lines;

  --==========================================================================
  --  PROCEDURE NAME:
  --    generate_journal_and_line_num                   Private
  --
  --  DESCRIPTION:
  --        This procedure is used to generate journal number
  --        and journal line number based on legal entity level and period
  --  PARAMETERS:
  --      In: p_period_name             period
  --          p_request_id              identifier of current session
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --===========================================================================

  PROCEDURE Generate_Journal_Num(p_Period_Name IN VARCHAR2,
                                 p_Request_Id  IN NUMBER,
                                 p_ledger_id   in number,
                                 P_legal_entity_id in number) IS
    l_Request_Id      NUMBER;
    l_Period_Name     Gl_Periods.Period_Name%TYPE;
    l_Je_Header_Id    NUMBER;
    l_Journal_Number  NUMBER;
    l_Je_Appending_Id NUMBER;
    l_Line_Num_m      NUMBER;
    l_ledger_id       number;
    l_legal_entity_id number;
    l_Dbg_Level       NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level      NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name       VARCHAR2(100) := 'generate_journal_num';

    CURSOR c_Journal IS
      SELECT Je_Header_Id
        FROM (SELECT DISTINCT Effective_Date, Je_Header_Id
                FROM Ja_Cn_Journals_Of_Period
               WHERE Request_Id = l_Request_Id
                 AND Period_Name = l_Period_Name)
       ORDER BY Effective_Date ASC, Je_Header_Id ASC;

    CURSOR c_Journal_Appending IS
      SELECT DISTINCT Je_Header_Id, Journal_Number
        FROM Ja_Cn_Journal_Lines Jl
       WHERE Je_Header_Id = l_Je_Header_Id
         AND Journal_Number IS NOT NULL
         AND Company_Segment IN
             (SELECT bsv.bal_seg_value
                FROM ja_cn_ledger_le_bsv_gt bsv
               WHERE Legal_Entity_Id = l_Legal_Entity_Id
                 and ledger_id = l_ledger_id);

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)

    l_Request_Id  := p_Request_Id;
    l_Period_Name := p_Period_Name;
    l_legal_entity_id:=p_legal_entity_id;
    l_ledger_id:=p_ledger_id;
    OPEN c_Journal;

    LOOP
      FETCH c_Journal
        INTO l_Je_Header_Id;
      EXIT WHEN c_Journal%NOTFOUND;

      OPEN c_Journal_Appending;
      FETCH c_Journal_Appending
        INTO l_Je_Appending_Id, l_Journal_Number;

      IF c_Journal_Appending%FOUND THEN
        CLOSE c_Journal_Appending;
        UPDATE Ja_Cn_Journal_Lines jop
           SET Journal_Number = l_Journal_Number
         WHERE Je_Header_Id = l_Je_Header_Id
           AND Journal_Number IS NULL
           AND Company_Segment IN
               (SELECT bsv.bal_seg_value
                  FROM ja_cn_ledger_le_bsv_gt bsv
                 WHERE Legal_Entity_Id = l_Legal_Entity_Id
                   and ledger_id = l_ledger_id);
      ELSE
        CLOSE c_Journal_Appending;
      END IF; --c_journal_appending%FOUND

      --get journal number based on legal entity and period

      l_Journal_Number := Ja_Cn_Update_Jl_Seq_Pkg.Fetch_Jl_Seq(p_Legal_Entity_Id => l_Legal_Entity_Id,
                                                               p_ledger_id=>l_ledger_id,
                                                               p_Period_Name     => l_Period_Name);

      IF Nvl(l_Journal_Number, 0) > 0 THEN
        UPDATE Ja_Cn_Journal_Lines
           SET Journal_Number = l_Journal_Number
         WHERE Je_Header_Id = l_Je_Header_Id
           AND Company_Segment IN
               (SELECT bsv.bal_seg_value
                  FROM ja_cn_ledger_le_bsv_gt bsv
                 WHERE Legal_Entity_Id = l_Legal_Entity_Id
                   and ledger_id = l_ledger_id);
      END IF;

    END LOOP;
    CLOSE c_Journal;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Generate_Journal_Num;

  --==========================================================================
  --  PROCEDURE NAME:
  --    generate_journal_and_line_num                   Private
  --
  --  DESCRIPTION:
  --        This procedure is used to generate journal number
  --        and journal line number based on legal entity level and period
  --  PARAMETERS:
  --      In: p_period_name             period
  --          p_request_id              identifier of current session
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --      10/10/2009     Chaoqun Wu            Fix bug 8970684
  --===========================================================================

  PROCEDURE Itemize_Journals_Sla(p_chart_of_accounts_id in number,
                                 p_Request_Id           IN NUMBER) IS
    l_Request_Id             NUMBER;
    l_Dbg_Level              NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level             NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name              VARCHAR2(100) := 'ITEMIZE_JOURNALS_SLA';
    l_Project_Source_Flag    VARCHAR2(15);
    l_Project_Ac_Code        VARCHAR2(30);
    l_Project_Ac_Detail_Code VARCHAR2(30);
    l_Grouping_Order         NUMBER;
    l_Insertsql              Dbms_Sql.Varchar2s;
    l_Line_No                NUMBER := 0;
    l_Chart_Of_Accounts_Id   number;
    l_sql                    varchar2(4000);
    CURSOR c_Sub_Acc_Sources IS
      SELECT Sas.Project_Source_Flag,
             Sas.Project_Ac_Code,
             Sas.Project_Ac_Detail_Code,
             Sas.Ac_Grouping_Order--added for bug 6669665
        FROM Ja_Cn_Sub_Acc_Sources_All Sas
       WHERE Sas.Chart_Of_Accounts_Id = l_Chart_Of_Accounts_Id;

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)
    l_Chart_Of_Accounts_Id := p_chart_of_accounts_id;
    l_Request_Id           := p_Request_Id;

    OPEN c_Sub_Acc_Sources;
    FETCH c_Sub_Acc_Sources
      INTO l_Project_Source_Flag, l_Project_Ac_Code, l_Project_Ac_Detail_Code,l_Grouping_Order;--added for bug 6669665
    CLOSE c_Sub_Acc_Sources;

    /*    l_Line_No:=l_line_no+1;
    l_Insertsql:='*/
    if nvl(l_Project_Source_Flag, 'N') = 'PA' then
      --get the detail code's group order  in the analytical criterion

     --deleted for bug 6669665
     -- SELECT Dtl.Grouping_Order
     --   INTO l_Grouping_Order
      --  FROM Xla_Analytical_Dtls_b Dtl
      -- WHERE Dtl.Analytical_Criterion_Code = l_Project_Ac_Code
      --   AND Dtl.Analytical_Detail_Code = l_Project_Ac_Detail_Code;

        l_sql:='INSERT INTO Ja_Cn_Journal_Lines_Req';
        l_sql:=l_sql||' (Je_Header_Id,';
        l_sql:=l_sql||' Ledger_Id,';
        l_sql:=l_sql||' Legal_Entity_Id,';
        l_sql:=l_sql||' Journal_Number,';
        l_sql:=l_sql||' Je_Category,';
        l_sql:=l_sql||' Default_Effective_Date,';
        l_sql:=l_sql||' Period_Name,';
        l_sql:=l_sql||' Currency_Code,';
        l_sql:=l_sql||' Currency_Conversion_Rate,';
        l_sql:=l_sql||' Je_Line_Num,';
        l_sql:=l_sql||' Line_Number,';
        l_sql:=l_sql||' Description,';
        l_sql:=l_sql||' Company_Segment,';
        l_sql:=l_sql||' Code_Combination_Id,';
        l_sql:=l_sql||' Cost_Center,';
        l_sql:=l_sql||' Third_Party_Id,';
        l_sql:=l_sql||' Third_Party_Number,';
        l_sql:=l_sql||' third_party_type,';
        l_sql:=l_sql||' Personnel_Id,';
        l_sql:=l_sql||' Personnel_Number,';
        l_sql:=l_sql||' Project_Number,';
        l_sql:=l_sql||' Project_Source,';
        l_sql:=l_sql||' Account_Segment,';
        l_sql:=l_sql||' Entered_Dr,';
        l_sql:=l_sql||' Entered_Cr,';
        l_sql:=l_sql||' Accounted_Dr,';
        l_sql:=l_sql||' Accounted_Cr,';
        l_sql:=l_sql||' Status,';
        l_sql:=l_sql||' Created_By,';
        l_sql:=l_sql||' Creation_Date,';
        l_sql:=l_sql||' Last_Updated_By,';
        l_sql:=l_sql||' Last_Update_Date,';
        l_sql:=l_sql||' Last_Update_Login,';
        l_sql:=l_sql||' Populate_Code,';
        l_sql:=l_sql||' Request_Id,';
        --for test
--        l_sql:='';
        l_sql:=l_sql||' Journal_Created_By,';
        l_sql:=l_sql||' Journal_Posted_By)';
        l_sql:=l_sql||' SELECT /*+index(ael,xla_ae_lines_n4)+*/';
        l_sql:=l_sql||' Jel.Je_Header_Id Je_Header_Id,';
        l_sql:=l_sql||' Jeh.Ledger_Id Ledger_Id,';
        l_sql:=l_sql||' Jop.Legal_Entity_Id Legal_Entity_Id,';
        l_sql:=l_sql||' To_Number(NULL) Journal_Number,';
        l_sql:=l_sql||' Jeh.Je_Category Je_Category,';
        l_sql:=l_sql||' Jeh.Default_Effective_Date Default_Effective_Date,';
        l_sql:=l_sql||' Jeh.Period_Name Period_Name,';
        l_sql:=l_sql||' Jeh.Currency_Code Currency_Code,';
        l_sql:=l_sql||' Jeh.Currency_Conversion_Rate Currency_Conversion_Rate,';
        l_sql:=l_sql||' Jel.Je_Line_Num Je_Line_Num,';
        l_sql:=l_sql||' To_Number(NULL) Line_Number,';
        l_sql:=l_sql||' Nvl(Ael.Description, Nvl(Jel.Description, Jeh.Description)) Description,';
        l_sql:=l_sql||' Jcc.Company_Segment Company_Segment,';
        l_sql:=l_sql||' Jcc.Code_Combination_Id Code_Combination_Id,';
        l_sql:=l_sql||' Jcc.Cost_Segment Cost_Segment,';
        l_sql:=l_sql||' decode(vendor_type_lookup_code,';   --Updated for fixing bug 8970684
        l_sql:=l_sql||'''EMPLOYEE'''||',';
        l_sql:=l_sql||'        to_number(null),';
        l_sql:=l_sql||'        ael.party_id) Third_Party_Id,';
--        l_sql:=l_sql||' to_char(null) third_party_number,';
        l_sql:=l_sql||'      Decode(Nvl(Ael.Party_Type_Code, ';
--        l_sql:='';
        l_sql:=l_sql||'''D'''||'), ';
        l_sql:=l_sql||'''C'''||',Part.Party_Number, ';
        l_sql:=l_sql||'''S'''||',Sup.Segment1,To_Char(NULL)) Third_Party_Number, ';
        l_sql:=l_sql||' decode(vendor_type_lookup_code,';   --Updated for fixing bug 8970684
        l_sql:=l_sql||'        ''EMPLOYEE'''||',';
        l_sql:=l_sql||'        to_char(null),';
        l_sql:=l_sql||'        ael.party_type_code) third_party_type,';
        l_sql:=l_sql||' decode(vendor_type_lookup_code,';   --Updated for fixing bug 8970684
        l_sql:=l_sql||'''EMPLOYEE'''||',';
        l_sql:=l_sql||'        sup.employee_id,';
        l_sql:=l_sql||'        to_number(null)) Personnel_Id,';
        l_sql:=l_sql||' to_char(null) Personnel_Number,';
        l_sql:=l_sql||'        acs.ac'||l_grouping_order;
        l_sql:=l_sql||' Project_Number,'''||l_Project_Option||''' Project_Source,';
        l_sql:=l_sql||' Jcc.Account_Segment Account_Segment,';
        l_sql:=l_sql||' Ael.Entered_Dr,';
        l_sql:=l_sql||' Ael.Entered_Cr,';
        l_sql:=l_sql||' Ael.Accounted_Dr,';
        l_sql:=l_sql||' Ael.Accounted_Cr,';
        l_sql:=l_sql||'''U'''||' Status,';
        l_sql:=l_sql||' Fnd_Global.User_Id Created_Gy,';
        l_sql:=l_sql||' SYSDATE Creation_Date,';
        l_sql:=l_sql||' Fnd_Global.User_Id Last_Updated_By,';
        l_sql:=l_sql||' SYSDATE Last_Update_Date,';
        l_sql:=l_sql||' Fnd_Global.Login_Id Last_Update_Login,';
        l_sql:=l_sql||'''FSAH'''||',';
        l_sql:=l_sql||l_Request_Id||',';
        l_sql:=l_sql||' Jeh.Created_By,';
        l_sql:=l_sql||' jeb.posted_by';
 /* for bug 6654734
        l_sql:=l_sql||' Decode(Nvl(Jeh.Accrual_Rev_Status, '||'''N'''||'),';
        l_sql:=l_sql||'''R'''||',';
---for test
--        l_sql:='';

        l_sql:=l_sql||'        To_Number(NULL),';
        l_sql:=l_sql||'        Jeh.Last_Updated_By)';*/
        l_sql:=l_sql||'  FROM Gl_Je_Lines              Jel,';
        l_sql:=l_sql||'       Gl_Je_Headers            Jeh,';
        l_sql:=l_sql||'       Gl_Je_Batches            Jeb,';
        l_sql:=l_sql||'       Xla_Ae_Lines             Ael,';
        l_sql:=l_sql||'       Xla_Ae_Headers           Aeh,';
        l_sql:=l_sql||'       Gl_Import_References     Gir,';
        l_sql:=l_sql||'       Ja_Cn_Code_Combination_v Jcc,';
        l_sql:=l_sql||'       xla_ae_line_acs          acs,';
        l_sql:=l_sql||'       ap_suppliers             sup,';
        l_sql:=l_sql||'       Ja_Cn_Journals_Of_Period Jop,';
        l_sql:=l_sql||'       Hz_Cust_Accounts         Cust,';
        l_sql:=l_sql||'       Hz_Parties               Part ';
        l_sql:=l_sql||' WHERE Jel.Je_Header_Id = Jeh.Je_Header_Id';
        l_sql:=l_sql||'   AND Jeb.Je_Batch_Id=jeh.je_batch_id ';
        l_sql:=l_sql||'   AND Gir.Gl_Sl_Link_Id = Ael.Gl_Sl_Link_Id';
        l_sql:=l_sql||'   AND Gir.Gl_Sl_Link_Table = Ael.Gl_Sl_Link_Table';
        l_sql:=l_sql||'   AND Ael.Ae_Header_Id = Aeh.Ae_Header_Id';
        l_sql:=l_sql||'   AND Gir.Je_Header_Id = Jeh.Je_Header_Id';
        l_sql:=l_sql||'   and sup.vendor_id(+) = ael.party_id';
        l_sql:=l_sql||'   AND Gir.Je_Line_Num = Jel.Je_Line_Num';
        --for test
--        l_sql:='';
        l_sql:=l_sql||'   AND Jop.Je_Header_Id = Jel.Je_Header_Id';
        l_sql:=l_sql||'   AND Jop.Je_Line_Num = Jel.Je_Line_Num';
        l_sql:=l_sql||'   AND Jcc.Code_Combination_Id = Jel.Code_Combination_Id';
        l_sql:=l_sql||'   and jop.request_id = '||l_request_id;
        l_sql:=l_sql||'   AND Acs.Ae_Header_Id(+) = Ael.Ae_Header_Id';
        l_sql:=l_sql||'   and jcc.ledger_id=jeh.ledger_id ';
        l_sql:=l_sql||'   AND Acs.Ae_Line_Num(+) = Ael.Ae_Line_Num ';
        l_sql:=l_sql||'   and cust.cust_account_id(+)=ael.party_id ';
        l_sql:=l_sql||'   and cust.party_id=part.party_id(+) ';
        l_sql:=l_sql||'   AND Acs.analytical_criterion_code(+)='''||l_Project_Ac_Code||''' ';

        execute immediate l_sql;
    else
      INSERT INTO Ja_Cn_Journal_Lines_Req
        (Je_Header_Id,
         Ledger_Id,
         Legal_Entity_Id,
         Journal_Number,
         Je_Category,
         Default_Effective_Date,
         Period_Name,
         Currency_Code,
         Currency_Conversion_Rate,
         Je_Line_Num,
         Line_Number,
         Description,
         Company_Segment,
         Code_Combination_Id,
         Cost_Center,
         Third_Party_Id,
         Third_Party_Type,
         Third_Party_Number,
         Personnel_Id,
         Personnel_Number,
         Project_Number,
         Project_Source,
         Account_Segment,
         Entered_Dr,
         Entered_Cr,
         Accounted_Dr,
         Accounted_Cr,
         Status,
         Created_By,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Populate_Code,
         Request_Id,
         Journal_Created_By,
         Journal_Posted_By)
        SELECT /*+index(ael,xla_ae_lines_n4)+*/
         Jel.Je_Header_Id Je_Header_Id
        ,Jeh.Ledger_Id Ledger_Id
        ,Jop.Legal_Entity_Id Legal_Entity_Id
        ,To_Number(NULL) Journal_Number
        ,Jeh.Je_Category Je_Category
        ,Jeh.Default_Effective_Date Default_Effective_Date
        ,Jeh.Period_Name Period_Name
        ,Jeh.Currency_Code Currency_Code
        ,Jeh.Currency_Conversion_Rate Currency_Conversion_Rate
        ,Jel.Je_Line_Num Je_Line_Num
        ,To_Number(NULL) Line_Number
        ,Nvl(Ael.Description,
             Nvl(Jel.Description,
                 Jeh.Description)) Description
        ,Jcc.Company_Segment Company_Segment
        ,Jcc.Code_Combination_Id Code_Combination_Id
        ,Jcc.Cost_Segment Cost_Segment
        ,Decode(vendor_type_lookup_code, --Pay_Group_Lookup_Code,  --Updated for fixing bug 8970684
                'EMPLOYEE',
                To_Number(NULL),
                Ael.Party_Id) Third_Party_Id
        ,Decode(vendor_type_lookup_code, --Pay_Group_Lookup_Code,  --Updated for fixing bug 8970684
                'EMPLOYEE',
                To_Char(NULL),
                Ael.Party_Type_Code) Third_Party_Type
        ,Decode(Nvl(Ael.Party_Type_Code,
                    'D'),
                'C',
                Part.Party_Number,
                'S',
                Sup.Segment1,
                To_Char(NULL)) Third_Party_Number
        ,Decode(vendor_type_lookup_code, --Pay_Group_Lookup_Code,  --Updated for fixing bug 8970684
                'EMPLOYEE',
                Sup.Employee_Id,
                To_Number(NULL)) Personnel_Id
        ,To_Char(NULL) Personnel_Number
        ,Decode(Nvl(l_Project_Option,
                    'N'),
                'N',
                To_Char(NULL),
                'COA',
                Jcc.Project_Number,
                To_Char(NULL)) Project_Number
        ,Nvl(l_Project_Option,
             'N') Project_Source
        ,Jcc.Account_Segment Account_Segment
        ,Ael.Entered_Dr
        ,Ael.Entered_Cr
        ,Ael.Accounted_Dr
        ,Ael.Accounted_Cr
        ,'U' Status
        ,Fnd_Global.User_Id Created_Gy
        ,SYSDATE Creation_Date
        ,Fnd_Global.User_Id Last_Updated_By
        ,SYSDATE Last_Update_Date
        ,Fnd_Global.Login_Id Last_Update_Login
        ,'FSAH'
        ,l_Request_Id
        ,Jeh.Created_By
        ,jeb.posted_by
      ----deleted by lyb, for bug 6654734
      --  ,Decode(Nvl(Jeh.Accrual_Rev_Status,
      --              'N'),
      --          'R',
      --          To_Number(NULL),
      --         Jeh.Last_Updated_By)
          FROM Gl_Je_Lines              Jel
              ,Gl_Je_Headers            Jeh
              ,Gl_Je_Batches            Jeb --added by lyb, for bug 6654734
              ,Xla_Ae_Lines             Ael
              ,Xla_Ae_Headers           Aeh
              ,Gl_Import_References     Gir
              ,Ja_Cn_Code_Combination_v Jcc
              ,Ap_Suppliers             Sup
              ,
               --             per_all_people_f             per,
               Ja_Cn_Journals_Of_Period Jop
              ,Hz_Cust_Accounts         Cust
              ,Hz_Parties               Part
         WHERE Jel.Je_Header_Id = Jeh.Je_Header_Id
           AND Jeb.Je_Batch_Id=jeh.je_batch_id --added by lyb, for bug 6654734
           AND Gir.Gl_Sl_Link_Id = Ael.Gl_Sl_Link_Id
           AND Gir.Gl_Sl_Link_Table = Ael.Gl_Sl_Link_Table
           AND Ael.Ae_Header_Id = Aeh.Ae_Header_Id
           AND Gir.Je_Header_Id = Jeh.Je_Header_Id
           AND Sup.Vendor_Id(+) = Ael.Party_Id
              --         and sup.pay_group_lookup_code='EMPLOYEE'
              --         AND nvl(pv.employee_id, -1) = per.person_id(+)
           AND Gir.Je_Line_Num = Jel.Je_Line_Num
           AND Jop.Je_Header_Id = Jel.Je_Header_Id
           AND Jop.Je_Line_Num = Jel.Je_Line_Num
           AND Jcc.Ledger_Id = Jeh.Ledger_Id
           AND Jcc.Code_Combination_Id = Jel.Code_Combination_Id
           AND Jop.Request_Id = l_Request_Id
           AND Cust.Cust_Account_Id(+) = Ael.Party_Id
           AND Cust.Party_Id = Part.Party_Id(+);

    end if;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      RAISE;
  END Itemize_Journals_Sla;

  --=========================================================================
  --  PROCEDURE NAME:
  --    transfer_gl_sla_to_cnao                   Public
  --
  --  DESCRIPTION:
  --        This is main procedure through which other procedures are called
  --        according to source and category of journal.Then call generate
  --        journal number and journal line number procedure and call post
  --        program
  --  PARAMETERS:
  --     Out: errbuf         Mandatory parameter for PL/SQL concurrent programs
  --     Out: retcode        Mandatory parameter for PL/SQL concurrent programs
  --     In:  p_period_name   Accounting period name
  --     In:  p_legal_entity_ID            Legal entity id
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/21/2006     Qingjun Zhao          Created
  --===========================================================================

  PROCEDURE Transfer_Gl_Sla_To_Cnao(Errbuf                 OUT NOCOPY VARCHAR2,
                                    Retcode                OUT NOCOPY VARCHAR2,
                                    p_Chart_Of_Accounts_Id IN NUMBER,
                                    p_Ledger_Id            IN NUMBER,
                                    p_Legal_Entity_Id      IN NUMBER,
                                    p_Period_Name          IN VARCHAR2) IS

    l_Error_Msg             VARCHAR2(2000);
    l_Dbg_Level             NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level            NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name             VARCHAR2(100) := 'transfer_gl_sla_to_cnao';
    l_Phase                 VARCHAR2(100);
    l_Status                VARCHAR2(100);
    l_Dev_Phase             VARCHAR2(100);
    l_Dev_Status            VARCHAR2(100);
    l_Message               VARCHAR2(100);
    l_Till_Period_Name      Gl_Periods.Period_Name%TYPE;
    l_Period_Name           Gl_Periods.Period_Name%TYPE;
    l_Start_Period_Name     Gl_Periods.Period_Name%TYPE;
    l_End_Period_Name       Gl_Periods.Period_Name%TYPE;
    l_Conc_Succ             BOOLEAN;
    l_Request_Id            NUMBER;
    l_Chart_Of_Account_Id   NUMBER;
    l_Ledger_Id             NUMBER;
    l_Result                BOOLEAN;
    l_Submit_Fail_Module    VARCHAR2(100);
    l_Execution_Fail_Module VARCHAR2(100);
    l_Post_Con_Req_Id       NUMBER := 0;
    l_Phase_Code            Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Status_Code           Fnd_Lookup_Values.Lookup_Code%TYPE;
    l_Request_Submit_Fail EXCEPTION;
    l_Request_Execution_Fail EXCEPTION;
    l_Post_Fail EXCEPTION;

    CURSOR c_Project_Option IS
      SELECT Project_Source_Flag
        FROM Ja_Cn_Sub_Acc_Sources_All
       WHERE Chart_Of_Accounts_Id = l_Chart_Of_Accounts_Id;

    CURSOR c_Period_Name IS
      SELECT Gp.Period_Name
        FROM Gl_Periods Gp, Gl_Ledgers Led
       WHERE Led.Ledger_Id = l_Ledger_Id
         AND Led.Period_Set_Name = Gp.Period_Set_Name
         AND Led.Accounted_Period_Type = Gp.Period_Type
         AND Gp.Start_Date BETWEEN
             (SELECT Start_Date
                FROM Gl_Periods Gp
               WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                 AND Led.Accounted_Period_Type = Gp.Period_Type
                 AND Gp.Period_Name = l_Start_Period_Name)
         AND (SELECT Start_Date
                FROM Gl_Periods Gp
               WHERE Led.Period_Set_Name = Gp.Period_Set_Name
                 AND Led.Accounted_Period_Type = Gp.Period_Type
                 AND Gp.Period_Name = l_End_Period_Name)
       ORDER BY Gp.Start_Date;
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

    --call JA_CN_UTILITY.Check_Profile, if it doesn't return true, exit
    /*    IF Ja_Cn_Utility.Check_Profile() <> TRUE THEN

      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level, l_Dbg_Level, 'Check profile failed!');
      END IF; --(l_proc_level >= l_dbg_level)
      l_Conc_Succ := Fnd_Concurrent.Set_Completion_Status(Status  => 'WARNING',
                                                          Message => '');
      RETURN;
    END IF; */ --JA_CN_UTILITY.Check_Profile() != TRUE

    l_Till_Period_Name := p_Period_Name;
    l_Legal_Entity_Id  := p_Legal_Entity_Id;
    l_ledger_id        := p_Ledger_Id;

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name ||
                     '.current set of books id',
                     'set of book id is ' || l_Ledger_Id);
    END IF; --l_exception_level >= l_runtime_level

    l_chart_of_accounts_id := p_chart_of_accounts_id;
    --Get "Project" definition in global_attribute1 of led
    OPEN c_Project_Option;
    FETCH c_Project_Option
      INTO l_Project_Option;

    --if "Project" isn't defined,then consider "Project"
    --as "Project Not considered"--'N'
    IF (c_Project_Option%NOTFOUND) THEN
      l_Project_Option := 'N';
    END IF; --(c_project_option%NOTFOUND)

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name ||
                     '.setup information',
                     'project option is ' || l_Project_Option);
    END IF; --l_exception_level >= l_runtime_level

    CLOSE c_Project_Option;

    --generate current session identifier
    SELECT Ja_Cn_Journal_Lines_Req_s.NEXTVAL INTO l_Request_Id FROM Dual;

    --generate code combination view
    Generate_Code_Combination_View(p_ledger_id => l_ledger_id);

    --Get effective begin period and end period;
    Get_Period_Range(p_Period_Name       => l_Till_Period_Name,
                     p_ledger_id         => l_ledger_id,
                     p_Start_Period_Name => l_Start_Period_Name,
                     p_End_Period_Name   => l_End_Period_Name);

    --Populate journal lines which will be itemized by possible subsidiary
    -- between start period and end period

    Populate_Journal_Of_Period(p_Start_Period    => l_Start_Period_Name,
                               p_ledger_id       => l_ledger_id,
                               p_legal_entity_id => l_legal_entity_id,
                               p_End_Period      => l_End_Period_Name,
                               p_Request_Id      => l_Request_Id);

    Itemize_Journals_Sla(p_chart_of_accounts_id => l_chart_of_accounts_id,
                         p_request_id           => l_request_id);
    Purge_Unmatch_Lines(p_Request_Id => l_Request_Id);

    --Transfer directly journal lines, which cannt be itmized by above
    --Itemization concurrent programs, into CNAO system
    Unitemize_Journal_Lines(p_Request_Id     => l_Request_Id,
                            p_Project_Option => l_Project_Option);
    --get approver of journals that have been approved in General Ledger
    Get_Journal_Approver(p_Request_Id => l_Request_Id);

    --get creator's name of journal
    UPDATE JA_CN_JOURNAL_LINES_REQ REQ
       SET REQ.JOURNAL_CREATOR = (SELECT LAST_NAME || FIRST_NAME FULL_NAME
                                    FROM PER_ALL_PEOPLE_F
                                   WHERE PERSON_ID =
                                         (SELECT EMPLOYEE_ID
                                            FROM FND_USER
                                           WHERE USER_ID =
                                                 REQ.JOURNAL_CREATED_BY)
                                     AND REQ.DEFAULT_EFFECTIVE_DATE BETWEEN
                                         EFFECTIVE_START_DATE AND
                                         EFFECTIVE_END_DATE)
     WHERE REQ.REQUEST_ID = L_REQUEST_ID
       AND REQ.JE_HEADER_ID > 0;
    --get poster's name of journals
    UPDATE JA_CN_JOURNAL_LINES_REQ REQ
       SET REQ.JOURNAL_POSTER = (SELECT LAST_NAME || FIRST_NAME FULL_NAME
                                   FROM PER_ALL_PEOPLE_F
                                  WHERE PERSON_ID =
                                        (SELECT EMPLOYEE_ID
                                           FROM FND_USER
                                          WHERE USER_ID =
                                                REQ.JOURNAL_POSTED_BY)
                                    AND REQ.DEFAULT_EFFECTIVE_DATE BETWEEN
                                        EFFECTIVE_START_DATE AND
                                        EFFECTIVE_END_DATE)
     WHERE REQ.REQUEST_ID = L_REQUEST_ID
       AND REQ.JE_HEADER_ID > 0;
    COMMIT;

    --update journal line into status of itemizated
    UPDATE Gl_Je_Lines Jel
       SET Jel.Global_Attribute2 = 'P'
     WHERE Jel.Je_Line_Num IN
           (SELECT Je_Line_Num
              FROM Ja_Cn_Journals_Of_Period
             WHERE Request_Id = l_Request_Id
               AND Je_Header_Id = Jel.Je_Header_Id)
       AND Jel.Je_Header_Id IN
           (SELECT Je_Header_Id
              FROM Ja_Cn_Journals_Of_Period
             WHERE Request_Id = l_Request_Id);

    --transfer itemized data into ja_cn_journal_lines in this session
    INSERT INTO Ja_Cn_Journal_Lines
      (Je_Header_Id,
       Ledger_Id,
       Legal_Entity_Id,
       Journal_Number,
       Je_Category,
       Default_Effective_Date,
       Period_Name,
       Currency_Code,
       Currency_Conversion_Rate,
       Je_Line_Num,
       Line_Number,
       Description,
       Company_Segment,
       Code_Combination_Id,
       Cost_Center,
       Third_Party_Id,
       Third_Party_Number,
       Third_Party_Type,
       Personnel_Id,
       Personnel_Number,
       Project_Number,
       Project_Source,
       Account_Segment,
       Entered_Dr,
       Entered_Cr,
       Accounted_Dr,
       Accounted_Cr,
       Status,
       Created_By,
       Creation_Date,
       Last_Updated_By,
       Last_Update_Date,
       Last_Update_Login,
       Populate_Code,
       Journal_Creator,
       Journal_Approver,
       Journal_Poster)
      SELECT Je_Header_Id,
             Ledger_Id,
             Legal_Entity_Id,
             Journal_Number,
             Je_Category,
             Default_Effective_Date,
             Period_Name,
             Currency_Code,
             Currency_Conversion_Rate,
             Je_Line_Num,
             Line_Number,
             Description,
             Company_Segment,
             Code_Combination_Id,
             Cost_Center,
             Third_Party_Id,
             Third_Party_Number,
             Third_Party_Type,
             Personnel_Id,
             Personnel_Number,
             Project_Number,
             Project_Source,
             Account_Segment,
             Entered_Dr,
             Entered_Cr,
             Accounted_Dr,
             Accounted_Cr,
             Status,
             Created_By,
             Creation_Date,
             Last_Updated_By,
             Last_Update_Date,
             Last_Update_Login,
             Populate_Code,
             Journal_Creator,
             Journal_Approver,
             Journal_Poster
        FROM Ja_Cn_Journal_Lines_Req
       WHERE Request_Id = l_Request_Id
         AND Je_Header_Id > 0;

    --get journal approver for itemized journal lines
    --which journal source need been approved

    --generate journal number and journal line number
    --based on legal entity level
    OPEN c_Period_Name;

    LOOP
      FETCH c_Period_Name
        INTO l_Period_Name;
      EXIT WHEN c_Period_Name%NOTFOUND;
      -- generate journal number and journal line number
      Generate_Journal_Num(p_Period_Name => l_Period_Name,
                           p_Request_Id  => l_Request_Id,
                           p_ledger_id   =>p_ledger_id,
                           p_legal_entity_id =>p_legal_entity_id);

    END LOOP;

    --commit itemized journal lines with journal number and journal line number
    COMMIT;

    --Delete temparory data of current session
/*    DELETE FROM Ja_Cn_Journals_Of_Period
     WHERE Request_Id = l_Request_Id
       AND Je_Header_Id > 0;*/

    DELETE FROM Ja_Cn_Journal_Lines_Req
     WHERE Request_Id = l_Request_Id
       AND Je_Header_Id > 0;
    COMMIT;
    Fnd_File.Put_Line(Fnd_File.Log, 'l_period_name:' || l_Period_Name);
    Fnd_File.Put_Line(Fnd_File.Log, 'l_ledger_id:' || l_Ledger_Id);
    Fnd_File.Put_Line(Fnd_File.Log,
                      'l_legal_entity_id:' || l_Legal_Entity_Id);
    --call post program to post these journals itemized
    l_Post_Con_Req_Id := Fnd_Request.Submit_Request('JA',
                                                    'JACNPOST',
                                                    NULL,
                                                    To_Date(NULL),
                                                    FALSE,
                                                    l_Period_Name,
                                                    l_Ledger_Id,
                                                    l_Legal_Entity_Id);

    IF (l_Post_Con_Req_Id = 0) THEN
      Errbuf               := Fnd_Message.Get;
      Retcode              := 2;
      l_Submit_Fail_Module := 'General Legder';
      RAISE l_Post_Fail;
    END IF; --(l_gl_con_req_id = 0)
    --submit post request
    COMMIT;
    IF l_Post_Con_Req_Id <> 0 THEN
      l_Result := Fnd_Concurrent.Wait_For_Request(l_Post_Con_Req_Id,
                                                  60,
                                                  -1,
                                                  l_Phase,
                                                  l_Status,
                                                  l_Dev_Phase,
                                                  l_Dev_Status,
                                                  l_Message);

      IF l_Result = FALSE THEN
        Errbuf                  := Fnd_Message.Get;
        Retcode                 := 2;
        l_Execution_Fail_Module := 'Post';

        --log for debug
        IF (l_Proc_Level >= l_Dbg_Level) THEN
          Fnd_Log.STRING(l_Proc_Level,
                         l_Module_Prefix || '.' || l_Proc_Name ||
                         '.JACNGLJT.EXECUTION',
                         'l_status.' || l_Status || '--' || 'l_phase.' ||
                         l_Phase);
        END IF; --l_exception_level >= l_runtime_level

      END IF; --l_result = FALSE

    END IF; --l_post_con_req_id <> 0

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level) THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN l_Post_Fail THEN
      -- dbms_output.put_line('Post Program fails,please connect your system ');
      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      l_Conc_Succ := Fnd_Concurrent.Set_Completion_Status(Status  => 'ERROR',
                                                          Message => SQLCODE || ':' ||
                                                                     SQLERRM);
    WHEN OTHERS THEN
      ROLLBACK;
      DELETE FROM Ja_Cn_Journals_Of_Period
       WHERE Request_Id = l_Request_Id
         AND Je_Header_Id > 0;

      DELETE FROM Ja_Cn_Journal_Lines_Req
       WHERE Request_Id = l_Request_Id
         AND Je_Header_Id > 0;
      COMMIT;
      Fnd_File.Put_Line(Fnd_File.Log, SQLCODE || ':' || SQLERRM);
      l_Conc_Succ := Fnd_Concurrent.Set_Completion_Status(Status  => 'ERROR',
                                                          Message => SQLCODE || ':' ||
                                                                     SQLERRM);
      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level) THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

  END Transfer_Gl_Sla_To_Cnao;

END Ja_Cn_Acc_Je_Itemization_Pkg;





/
