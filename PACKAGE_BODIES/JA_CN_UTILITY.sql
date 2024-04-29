--------------------------------------------------------
--  DDL for Package Body JA_CN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_UTILITY" AS
  --$Header: JACNCUYB.pls 120.2.12010000.3 2008/11/04 02:41:42 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNCUYB.pls
  --|
  --| DESCRIPTION
  --|
  --|      This package is to provide share procedures for CNAO programs
  --|
  --| PROCEDURE LIST
  --|
  --|   FUNCTION  Check_Profile
  --|   PROCEDURE Get_SOB_And_COA
  --|   FUNCTION  Get_SOB
  --|   FUNCTION  Get_COA
  --|   FUNCTION  Get_Lookup_Meaning
  --|   FUNCTION  Check_Nat_Number
  --|   PROCEDURE OUtput_Conc
  --|   FUNCTION  Check_Account_Level
  --|   PROCEDURE Change_Output_Filename
  --|   PROCEDURE Submit_Charset_Conversion
  --|   FUNCTION  Get_Lookup_Code
  --| HISTORY
  --|   02-Mar-2006     Donghai Wang Created
  --|   09-Mar-2006     Joseph Wang added the function Get_Chart_Of_Account_ID
  --|   21-Mar-2006     Joseph Wang replace the function Get_Chart_Of_Account_ID by
  --|                   procedure Get_SOB_And_COA to make it return both Set Of Book
  --|                   and Chart Of Account ID
  --|   31-Mar-2006     Joseph Wang added functions Get_SOB and Get_COA
  --|   11-Apr-2006     Jackey Li   added functions Get_Lookup_Meaning and Check_Nat_Number
  --|   27-Apr-2006     Andrew Liu  added Procedure Output_Conc
  --|   18-May-2006     Andrew Liu  added function Check_Account_Level
  --|   30-May-2006     Donghai Wang added the new function Check_Cash_Related_Account
  --|   20-Jun-2006     Shujuan Yan  added the new procedure Change_Output_Filename,
  --|                   Get_Lookup_Code and Submit_Charset_Conversion
  --|   04-July-2006    Joseph Wang added the function Check_Accounting_Period_Range
  --|   29-Aug-2008     Chaoqun Wu added the function Get_Balancing_Segment_Value
  --|   1-Sep-2008      Chaoqun Wu added the function Get_Balancing_Segment_Value
  --|   31-OCT-2008:    Yao Zhang  Fix bug 7524912 changed
  --+======================================================================*//

  l_Module_Prefix VARCHAR2(100) := 'JA_CN_UTILITY';

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Profile                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to check if all required profiles has been properly set
  --    for current responsibility. If No, the function will return FALSE to caller and .
  --    raise error message. Those required profiles include ' JG: Product', which should
  --    be set to 'Asia/Pacific Localizations','JG: Territory', which should be set
  --     to 'China' and 'JA: CNAO Legal Entity', which should be NOT NULL
  --
  --
  --  PARAMETERS:
  --      In:
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      02-Mar-2006     Donghai Wang Created
  --
  --===========================================================================

  FUNCTION Check_Profile RETURN BOOLEAN IS
    l_False_Flag VARCHAR2(1) := 'N';
    l_Error_Msg  VARCHAR2(2000);
    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'Check_Profile';
  BEGIN

    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level)
    THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
    END IF; --(l_proc_level >= l_dbg_level)

    --To check if the profile  JG: Product' is set to 'Asia/Pacific Localizations'
    --and the profile 'JG: Territory' is set to 'China'
    IF (Fnd_Profile.VALUE(NAME => 'JGZZ_PRODUCT_CODE') <> 'JA' OR
       Fnd_Profile.VALUE(NAME => 'JGZZ_PRODUCT_CODE') IS NULL)
       OR (Fnd_Profile.VALUE(NAME => 'JGZZ_COUNTRY_CODE') <> 'CN' OR
       Fnd_Profile.VALUE(NAME => 'JGZZ_COUNTRY_CODE') IS NULL)
    THEN
      --Raise error message for caller
      l_False_Flag := 'Y';
      Fnd_Message.Set_Name(Application => 'JA',
                           NAME        => 'JA_CN_PROFILE_NOT_ENABLE');
      l_Error_Msg := Fnd_Message.Get;

      --Output error message
      Fnd_File.Put_Line(Fnd_File.Output, l_Error_Msg);
    END IF;

    --To check if current responsibility has profile 'JA: CNAO Legal Entity'
    IF Fnd_Profile.VALUE(NAME => 'JA_CN_LEGAL_ENTITY') IS NULL
    THEN
      --Raise error message for caller
      l_False_Flag := 'Y';
      Fnd_Message.Set_Name(Application => 'JA',
                           NAME        => 'JA_CN_NO_LEGAL_ENTITY');
      l_Error_Msg := Fnd_Message.Get;

      --Output error message
      Fnd_File.Put_Line(Fnd_File.Output, l_Error_Msg);
    END IF; -- FND_PROFILE.Value(NAME => 'JA_CN_LEGAL_ENTITY')IS NULL

    IF l_False_Flag = 'N'
    THEN
      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level)
      THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name || '.end',
                       'Exit procedure');
      END IF; --( l_proc_level >= l_dbg_level )
      RETURN TRUE;
    ELSE
      --log for debug
      IF (l_Proc_Level >= l_Dbg_Level)
      THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name || '.end',
                       'Exit procedure');
      END IF; --( l_proc_level >= l_dbg_level )
      RETURN FALSE;
    END IF; --l_false_flage='N'

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level)
      THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
  END Check_Profile;
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Get_SOB_And_COA                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get chart of account id and set of book id
  --    by legal entity, if no data found or exception occurs, x_flag will be
  --    returned with -1
  --
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --      Out:       x_sob_id               Set of book ID
  --      Out:       x_coa_id               Chart of account ID
  --      Out:       x_flag                 Return flag
  --
  --  RETURN:
  --      Flag, -1 for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      09-Mar-2006     Joseph Wang Created
  --
  --===========================================================================

  PROCEDURE Get_Sob_And_Coa(p_Legal_Entity_Id NUMBER,
                            x_Sob_Id          OUT NOCOPY NUMBER,
                            x_Coa_Id          OUT NOCOPY NUMBER,
                            x_Flag            OUT NOCOPY NUMBER) IS

    l_Module_Name CONSTANT VARCHAR2(100) := l_Module_Prefix ||
                                            '.Get_SOB_And_COA';
    l_Runtime_Level   NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Procedure_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Statement_Level NUMBER := Fnd_Log.Level_Statement;
    l_Exception_Level NUMBER := Fnd_Log.Level_Exception;
    l_Message         VARCHAR2(300);

    l_Chart_Of_Accounts_Id Gl_Sets_Of_Books.Chart_Of_Accounts_Id%TYPE;
    l_Ledger_Id            Gl_Ledgers.Ledger_Id%TYPE;
  BEGIN

    --log the parameters
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN

      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Name,
                     'Start to run ' || l_Module_Name ||
                     'with parameter: p_legal_entity_id=' ||
                     Nvl(To_Char(p_Legal_Entity_Id), 'null'));

    END IF; --l_procedure_level >= l_runtime_level

    BEGIN
      /*      SELECT l_ledger_id
              INTO l_ledger_id
              FROM ja_cn_system_parameters_all
             WHERE legal_entity_id = p_legal_entity_id;
      */ --log the SOB
      IF (l_Statement_Level >= l_Runtime_Level)
      THEN
        Fnd_Log.STRING(l_Statement_Level,
                       l_Module_Name,
                       'Fetched: l_set_of_books_id=' ||
                       Nvl(To_Char(l_Ledger_Id), 'null'));
      END IF; --l_statement_level >= l_runtime_level

    EXCEPTION
      WHEN No_Data_Found THEN
        Fnd_Message.Set_Name('JA', 'JA_CN_MISSING_BOOK_INFO');
        l_Message := Fnd_Message.Get();
        Fnd_File.Put_Line(Fnd_File.Output, l_Message);
        IF (l_Exception_Level >= l_Runtime_Level)
        THEN
          Fnd_Log.STRING(l_Exception_Level, l_Module_Name, l_Message);
        END IF; --l_exception_level >= l_runtime_level
        x_Flag := -1;
        RETURN;
    END;
    --fetch chart_of_accounts_id
    SELECT Chart_Of_Accounts_Id
      INTO l_Chart_Of_Accounts_Id
      FROM Gl_Sets_Of_Books
     WHERE Set_Of_Books_Id = l_Ledger_Id;
    IF (l_Statement_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Statement_Level,
                     l_Module_Name,
                     'Fetched: l_chart_of_accounts_id=' ||
                     Nvl(To_Char(l_Chart_Of_Accounts_Id), 'null'));
    END IF; --l_statement_level >= l_runtime_level
    x_Sob_Id := l_Ledger_Id;
    x_Coa_Id := l_Chart_Of_Accounts_Id;
    x_Flag   := 0;
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Name,
                     'Stop running ' || l_Module_Name);
    END IF; --l_procedure_level >= l_runtime_level

  EXCEPTION
    WHEN OTHERS THEN
      x_Flag := -1;
      RETURN;
  END;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_SOB                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get set of book id within SQL statements
  --    by legal entity. Actually it invokes the procedure Get_SOB_And_COA
  --    to get return value. If no data found or exception occurs, -9 will be
  --    returned.
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --
  --  RETURN:
  --      Set of book ID, -9 for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      31-Mar-2006     Joseph Wang Created
  --
  --===========================================================================
  FUNCTION Get_Sob(p_Legal_Entity_Id NUMBER) RETURN NUMBER IS
    l_Sob_Id NUMBER;
    l_Coa_Id NUMBER;
    l_Flag   NUMBER;
  BEGIN
    Get_Sob_And_Coa(p_Legal_Entity_Id => p_Legal_Entity_Id,
                    x_Sob_Id          => l_Sob_Id,
                    x_Coa_Id          => l_Coa_Id,
                    x_Flag            => l_Flag);
    IF l_Flag = -1
    THEN
      RETURN - 9;
    ELSE
      RETURN l_Sob_Id;
    END IF;
  END;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_COA                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get chart of account id within SQL statements
  --    by legal entity. Actually it invokes the procedure Get_SOB_And_COA
  --    to get return value. If no data found or exception occurs, -9 will be
  --    returned.
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --
  --  RETURN:
  --      Chart of account ID, -9 for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      31-Mar-2006     Joseph Wang Created
  --
  --===========================================================================
  /*
    FUNCTION Get_Coa(p_Legal_Entity_Id NUMBER) RETURN NUMBER IS
      l_Sob_Id NUMBER;
      l_Coa_Id NUMBER;
      l_Flag   NUMBER;
    BEGIN
      Get_Sob_And_Coa(p_Legal_Entity_Id => p_Legal_Entity_Id,
                      x_Sob_Id          => l_Sob_Id,
                      x_Coa_Id          => l_Coa_Id,
                      x_Flag            => l_Flag);
      IF l_Flag = -1
      THEN
        RETURN - 9;
      ELSE
        RETURN l_Coa_Id;
      END IF;
    END;
  */
  --added  by lyb, Get chart_of_accounts_id by current_access_id
  FUNCTION Get_Coa(p_Access_Set_Id NUMBER) RETURN NUMBER IS
    l_Ret_Coa NUMBER;

    CURSOR c_Get_Coa IS
      SELECT Chart_Of_Accounts_Id
        FROM Gl_Access_Sets
       WHERE Access_Set_Id = p_Access_Set_Id;

  BEGIN
    --Get Chart of Accounts Id
    OPEN c_Get_Coa;
    FETCH c_Get_Coa
      INTO l_Ret_Coa;
    CLOSE c_Get_Coa;

    RETURN l_Ret_Coa;

  END Get_Coa;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_Lookup_Meaning                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get lookup meaning under one lookup code
  --        according to lookup type.
  --
  --
  --  PARAMETERS:
  --      In:        p_lookup_code     lookup code
  --
  --  RETURN:
  --      Lookup_meaning Varchar2
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      24-Mar-2006     Jackey Li   Created
  --
  --===========================================================================
  FUNCTION Get_Lookup_Meaning(p_Lookup_Code IN VARCHAR2) RETURN VARCHAR2 IS

    l_Procedure_Name  VARCHAR2(30) := 'Get_Lookup_Meaning';
    l_Lookup_Meaning  Fnd_Lookup_Values.Meaning%TYPE := NULL;
    l_Runtime_Level   NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Procedure_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Statement_Level NUMBER := Fnd_Log.Level_Statement;
    l_Exception_Level NUMBER := Fnd_Log.Level_Exception;

    -- this cursor is to get looup_meaning under some lookup_code
    CURSOR c_Lookup IS
      SELECT Flv.Meaning
        FROM Fnd_Lookup_Values Flv
       WHERE Flv.LANGUAGE = Userenv('LANG')
         AND Flv.Lookup_Type = 'JA_CN_DUPOBJECTS_TOKENS'
         AND Flv.View_Application_Id = 0
         AND Flv.Security_Group_Id = 0
         AND Flv.Lookup_Code = p_Lookup_Code;

  BEGIN
    --log
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.begin',
                     'begin procedure');
    END IF; --l_procedure_level >= l_runtime_level

    IF p_Lookup_Code IS NULL
    THEN
      l_Lookup_Meaning := NULL;
    ELSE
      OPEN c_Lookup;
      FETCH c_Lookup
        INTO l_Lookup_Meaning;
      IF c_Lookup%NOTFOUND
      THEN
        l_Lookup_Meaning := NULL;
      END IF;
      CLOSE c_Lookup;
    END IF; --IF p_lookup_code IS NULL

    --log
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.end',
                     'end procedure');
    END IF; --l_procedure_level >= l_runtime_level

    RETURN l_Lookup_Meaning;

  END Get_Lookup_Meaning;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Nat_Number                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to check if the given string is a natual number.
  --
  --
  --  PARAMETERS:
  --      In:        p_subject     the string need to check
  --
  --  RETURN:
  --      BOOLEAN
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --      11-Apr-2006     Jackey Li   Created
  --
  --===========================================================================
  FUNCTION Check_Nat_Number(p_Subject IN VARCHAR2) RETURN BOOLEAN IS
    l_Tmp    VARCHAR2(100);
    l_Number NUMBER;
    l_Mod    NUMBER;
  BEGIN
    l_Tmp    := p_Subject;
    l_Number := To_Number(l_Tmp);
    IF l_Number < 0
    THEN
      RETURN FALSE;
    END IF;
    l_Mod := MOD(l_Number, 2);
    IF l_Mod = 1
       OR l_Mod = 0
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;

  END Check_Nat_Number;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Output_Conc                        Public
  --
  --  DESCRIPTION:
  --
  --      This procedure write data to concurrent output file
  --      the data can be longer than 4000
  --
  --  PARAMETERS:
  --      In:  p_clob         the content which need output to concurrent output
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qugen.hu   Created.
  --           27-APR-2005: Andrew.liu imported.
  --           31-OCT-2008: Yao Zhang  Fix bug 7524912 changed
  --===========================================================================
  PROCEDURE Output_Conc(p_Clob IN CLOB) IS
    Max_Linesize NUMBER := 254;
    l_Pos_Tag    NUMBER;
    l_Pos        NUMBER;
    l_Len        NUMBER;
    l_Tmp        NUMBER;
    l_Tmp1       NUMBER;
    l_Substr     CLOB;
  BEGIN
    NULL;
    --initalize
    l_Pos := 1;
    l_Len := Length(p_Clob);

    WHILE l_Pos <= l_Len
    LOOP
      --get the XML tag from reverse direction
      l_Tmp     := l_Pos + Max_Linesize - 2 - l_Len;
      --l_Pos_Tag := Instr(p_Clob, '>', l_Tmp);--fix bug 	7524912 delete
      l_Pos_Tag := Instr(p_Clob, '><', l_Tmp);--fix bug 7524912 add
      --the pos didnot touch the end of string
      l_Tmp1 := l_Pos - 1;

      IF (l_Pos_Tag > l_Tmp1)
         AND (l_Tmp < 0)
      THEN
        l_Tmp := l_Pos_Tag - l_Pos + 1;
        --Fnd_File.Put(Fnd_File.Output, Substr(p_Clob, l_Pos, l_Tmp));--fix bug 7524912 delete
        Fnd_File.PUT_LINE(Fnd_File.Output, Substr(p_Clob, l_Pos, l_Tmp));--fix bug 7524912 add
        l_Pos := l_Pos_Tag + 1;
      ELSE
        l_Substr := Substr(p_Clob, l_Pos);
        --Fnd_File.Put(Fnd_File.Output, l_Substr);--fix bug 7524912 delete
        Fnd_File.PUT_LINE(Fnd_File.Output, l_Substr);--fix bug 7524912 add
        l_Pos := l_Len + 1;

      END IF;

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Output_Conc;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Account_Level                Public
  --
  --  DESCRIPTION:
  --
  --      This procedure check the account level of an account. If the account
  --      level is not null, and is a natural number and less than 16 than return
  --      TRUE, else FALSE.
  --
  --  PARAMETERS:
  --      In:  P_LEVEL        the account level
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           18-MAY-2005: Andrew.liu Created.
  --
  --===========================================================================
  FUNCTION Check_Account_Level(p_Level IN VARCHAR2) RETURN BOOLEAN IS
    l_Na_Level VARCHAR2(100) := p_Level;
    l_Number   NUMBER;
  BEGIN
    l_Number := To_Number(l_Na_Level);
    IF Instr(l_Na_Level, '.', 1, 1) > 0 --not a integer
       OR Instr(To_Char(l_Number), '.', 1, 1) > 0 --not a integer
       OR l_Number < 1 --less than 1
    THEN
      RETURN FALSE;
    END IF;

    IF l_Na_Level IS NOT NULL
       AND l_Number < 16
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END Check_Account_Level;

  --==========================================================================
  --  FUNCTION NAME:
  --      get_lookup_code                   Public
  --
  --  DESCRIPTION:
  --      This function is used to get lookup code of lookup meaning,
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
  --       06/03/2006     Shujuan Yan          Created
  --==========================================================================
  FUNCTION Get_Lookup_Code(p_Lookup_Meaning      IN VARCHAR2,
                           p_Lookup_Type         IN VARCHAR2,
                           p_View_Application_Id IN NUMBER DEFAULT 0,
                           p_Security_Group_Id   IN NUMBER DEFAULT 0)
    RETURN VARCHAR2 IS

    l_Procedure_Name  VARCHAR2(30) := 'Get_Lookup_Code';
    l_Lookup_Code     Fnd_Lookup_Values.Lookup_Code%TYPE := NULL;
    l_Runtime_Level   NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Procedure_Level NUMBER := Fnd_Log.Level_Procedure;
    --l_statement_level NUMBER := fnd_log.level_statement;
    --l_exception_level NUMBER := fnd_log.level_exception;

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
    --log for debug
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.begin',
                     'begin procedure');
    END IF; --l_procedure_level >= l_runtime_level

    IF p_Lookup_Meaning IS NULL
    THEN
      l_Lookup_Code := NULL;
    ELSE
      OPEN c_Lookup;
      FETCH c_Lookup
        INTO l_Lookup_Code;
      IF c_Lookup%NOTFOUND
      THEN
        l_Lookup_Code := NULL;
      END IF;
      CLOSE c_Lookup;
    END IF; --IF p_lookup_code IS NULL

    --log for debug
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.end',
                     'end procedure');
    END IF; --l_procedure_level >= l_runtime_level

    RETURN l_Lookup_Code;

  END Get_Lookup_Code;
  --==========================================================================
  --  PROCEDURE NAME:
  --      Submit_Charset_Conversion                   Public
  --
  --  DESCRIPTION:
  --      This function is used to submit charset conversion concurrent.
  --  PARAMETERS:
  --      In:   p_xml_request_id       xml publisher concurrent request id
  --            p_source_charset       source charset
  --            p_destination_charset  destination charset
  --            p_source_separator     source separator
  --      Out:  x_charset_request_id   charset conversion request id
  --            x_result_flag          result flag
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --       06/03/2006     Shujuan Yan          Created
  --==========================================================================
  PROCEDURE Submit_Charset_Conversion(p_Xml_Request_Id      IN NUMBER,
                                      p_Source_Charset      IN VARCHAR2,
                                      p_Destination_Charset IN VARCHAR2,
                                      p_Source_Separator    IN VARCHAR2,
                                      x_Charset_Request_Id  OUT NOCOPY NUMBER,
                                      x_Result_Flag         OUT NOCOPY VARCHAR2) IS

    l_Procedure_Name  VARCHAR2(30) := 'Submit_Charset_Conversion ';
    l_Runtime_Level   NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Procedure_Level NUMBER := Fnd_Log.Level_Procedure;
    --l_statement_level    NUMBER := fnd_log.level_statement;
    --l_exception_level    NUMBER := fnd_log.level_exception;
    l_Complete_Flag BOOLEAN;
    l_Phase         VARCHAR2(100);
    l_Status        VARCHAR2(100);
    l_Del_Phase     VARCHAR2(100);
    l_Del_Status    VARCHAR2(100);
    l_Message       VARCHAR2(1000);

  BEGIN
    --log for debug
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.begin',
                     'begin procedure');
    END IF; --l_procedure_level >= l_runtime_level
    -- submit charset conversion concurrent program
    x_Charset_Request_Id := Fnd_Request.Submit_Request('JA',
                                                       'JACNCCCP',
                                                       NULL,
                                                       SYSDATE,
                                                       FALSE,
                                                       p_Xml_Request_Id,
                                                       p_Source_Charset,
                                                       p_Destination_Charset,
                                                       p_Source_Separator);

    IF (x_Charset_Request_Id <= 0 OR x_Charset_Request_Id IS NULL)
    THEN
      x_Result_Flag := 'Error';
    ELSE
      COMMIT;
      --Wait for concurrent complete
      l_Complete_Flag := Fnd_Concurrent.Wait_For_Request(x_Charset_Request_Id,
                                                         1,
                                                         0,
                                                         l_Phase,
                                                         l_Status,
                                                         l_Del_Phase,
                                                         l_Del_Status,
                                                         l_Message);
      IF l_Complete_Flag = FALSE
         OR Get_Lookup_Code(p_Lookup_Meaning => l_Status,
                            p_Lookup_Type    => 'CP_STATUS_CODE') <> 'C'
      THEN
        x_Result_Flag := 'Error';
      ELSE
        x_Result_Flag := 'Success';
      END IF; -- l_complete_flag = false
    END IF; -- (x_xml_request_id <= 0 OR x_xml_request_id IS NULL)

    --log for debug
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.end',
                     'end procedure');
    END IF; --l_procedure_level >= l_runtime_level
  EXCEPTION
    WHEN OTHERS THEN
      --log for debug
      IF (Fnd_Log.Level_Unexpected >= Fnd_Log.g_Current_Runtime_Level)
      THEN
        Fnd_Log.STRING(Fnd_Log.Level_Unexpected,
                       l_Module_Prefix || l_Procedure_Name ||
                       '. OTHER_EXCEPTION ',
                       SQLCODE || SQLERRM);
      END IF; -- fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
      RAISE;
  END Submit_Charset_Conversion;
  --==========================================================================
  --  PROCEDURE NAME:
  --      Change_Output_Filename                   Public
  --
  --  DESCRIPTION:
  --      This function is used to submit the concurrent program of change output file name
  --  PARAMETERS:
  --      In:   p_xml_request_id       xml publisher concurrent request id
  --            p_destination_charset  destination charset
  --            p_destination_filename destination filename
  --      Out:  x_charset_request_id   charset conversion request id
  --            x_result_flag          result flag
  --
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --       06/03/2006     Shujuan Yan          Created
  --==========================================================================
  PROCEDURE Change_Output_Filename(p_Xml_Request_Id       IN NUMBER,
                                   p_Destination_Charset  IN VARCHAR2,
                                   p_Destination_Filename IN VARCHAR2,
                                   x_Filename_Request_Id  OUT NOCOPY NUMBER,
                                   x_Result_Flag          OUT NOCOPY VARCHAR2) IS

    l_Procedure_Name  VARCHAR2(30) := 'Change_Output_Filename';
    l_Runtime_Level   NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Procedure_Level NUMBER := Fnd_Log.Level_Procedure;
    --l_statement_level NUMBER := fnd_log.level_statement;
    --l_exception_level NUMBER := fnd_log.level_exception;
    l_Complete_Flag BOOLEAN;
    l_Phase         VARCHAR2(100);
    l_Status        VARCHAR2(100);
    l_Del_Phase     VARCHAR2(100);
    l_Del_Status    VARCHAR2(100);
    l_Message       VARCHAR2(1000);

  BEGIN
    --log for debug
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.begin',
                     'begin procedure');
    END IF; --l_procedure_level >= l_runtime_level
    -- submit change file name concurrent program
    x_Filename_Request_Id := Fnd_Request.Submit_Request('JA',
                                                        'JACNFNCP',
                                                        NULL,
                                                        SYSDATE,
                                                        FALSE,
                                                        p_Xml_Request_Id,
                                                        p_Destination_Charset,
                                                        p_Destination_Filename);

    IF (x_Filename_Request_Id <= 0 OR x_Filename_Request_Id IS NULL)
    THEN
      x_Result_Flag := 'Error';
    ELSE
      COMMIT;
      --Wait for concurrent complete
      l_Complete_Flag := Fnd_Concurrent.Wait_For_Request(x_Filename_Request_Id,
                                                         1,
                                                         0,
                                                         l_Phase,
                                                         l_Status,
                                                         l_Del_Phase,
                                                         l_Del_Status,
                                                         l_Message);
      IF l_Complete_Flag = FALSE
         OR Get_Lookup_Code(p_Lookup_Meaning => l_Status,
                            p_Lookup_Type    => 'CP_STATUS_CODE') <> 'C'
      THEN
        x_Result_Flag := 'Error';
      ELSE
        x_Result_Flag := 'Success';
      END IF; -- l_complete_flag = false
    END IF; -- (x_xml_request_id <= 0 OR x_xml_request_id IS NULL)

    --log for debug
    IF (l_Procedure_Level >= l_Runtime_Level)
    THEN
      Fnd_Log.STRING(l_Procedure_Level,
                     l_Module_Prefix || '.' || l_Procedure_Name || '.end',
                     'end procedure');
    END IF; --l_procedure_level >= l_runtime_level
  EXCEPTION
    WHEN OTHERS THEN
      --log for debug
      IF (Fnd_Log.Level_Unexpected >= Fnd_Log.g_Current_Runtime_Level)
      THEN
        Fnd_Log.STRING(Fnd_Log.Level_Unexpected,
                       l_Module_Prefix || l_Procedure_Name ||
                       '. OTHER_EXCEPTION ',
                       SQLCODE || SQLERRM);
      END IF; -- fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
      RAISE;
  END Change_Output_Filename;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Cash_Related_Account           Public
  --
  --  DESCRIPTION:
  --
  --     This function is used to check if the gl code combination passed in is --     Cash Related.
  --
  --  PARAMETERS:
  --      In:  p_set_of_bks_id      Identifier of GL set of book
  --           p_acc_flex           GL code combination
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-MAY-2005: Donghai Wang Created
  --
  --===========================================================================
  FUNCTION Check_Cash_Related_Account(p_Set_Of_Bks_Id IN NUMBER,
                                      p_Acc_Flex      IN VARCHAR2)
    RETURN BOOLEAN IS
    l_Id_Flex_Num          Fnd_Id_Flex_Structures.Id_Flex_Num%TYPE;
    l_Delimiter            Fnd_Id_Flex_Structures.Concatenated_Segment_Delimiter%TYPE;
    l_Seq_Account          NUMBER;
    l_Account_Segment_Flag Fnd_Segment_Attribute_Values.Attribute_Value%TYPE;
    l_Account_Segment      Fnd_Id_Flex_Segments.Segment_Name%TYPE;

    l_Cash_Related_Flag BOOLEAN;
    l_Cash_Acct_Count   NUMBER;

    CURSOR c_Coa_Infor IS
      SELECT Id_Flex_Num,
             Concatenated_Segment_Delimiter
        FROM Fnd_Id_Flex_Structures
       WHERE Application_Id = '101'
         AND Id_Flex_Code = 'GL#'
         AND Id_Flex_Num =
             (SELECT Chart_Of_Accounts_Id
                FROM Gl_Sets_Of_Books
               WHERE Set_Of_Books_Id = p_Set_Of_Bks_Id);

    CURSOR c_Coa_Segments IS
      SELECT Application_Column_Name
        FROM Fnd_Id_Flex_Segments
       WHERE Application_Id = 101
         AND Id_Flex_Code = 'GL#'
         AND Id_Flex_Num = l_Id_Flex_Num
         AND Enabled_Flag = 'Y'
         AND Display_Flag = 'Y'
       ORDER BY Segment_Num;

    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'Check_Cash_Related_Account';

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level)
    THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameter',
                     'p_set_of_bks_id ' || p_Set_Of_Bks_Id);
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameter',
                     'p_acc_flex ' || p_Acc_Flex);

    END IF; --(l_proc_level >= l_dbg_level)

    --To get coa id of current gl books and delimiter for gl account accordingly.
    OPEN c_Coa_Infor;
    FETCH c_Coa_Infor
      INTO l_Id_Flex_Num, l_Delimiter;
    CLOSE c_Coa_Infor;

    --To evaluate the sequence of account segment in gl account
    l_Seq_Account := 0;
    FOR l_Coa_Segment IN c_Coa_Segments
    LOOP
      l_Seq_Account := l_Seq_Account + 1;

      SELECT Attribute_Value
        INTO l_Account_Segment_Flag
        FROM Fnd_Segment_Attribute_Values
       WHERE Application_Id = 101
         AND Id_Flex_Code = 'GL#'
         AND Id_Flex_Num = l_Id_Flex_Num
         AND Application_Column_Name =
             l_Coa_Segment.Application_Column_Name
         AND Segment_Attribute_Type = 'GL_ACCOUNT';

      EXIT WHEN l_Account_Segment_Flag = 'Y';
    END LOOP; --l_coa_segment IN c_coa_segments

    --Extract account segment from GL account
    SELECT Substr(p_Acc_Flex,
                  Instr(p_Acc_Flex, l_Delimiter, 1, l_Seq_Account - 1) + 1,
                  (Instr(p_Acc_Flex, l_Delimiter, 1, l_Seq_Account) -
                  Instr(p_Acc_Flex, l_Delimiter, 1, l_Seq_Account - 1) - 1))
      INTO l_Account_Segment
      FROM Dual;

    --To check if current account segment is cash related.
    /*    SELECT COUNT(account_segment_value)
     INTO l_cash_acct_count
     FROM ja_cn_cash_accounts_all
    WHERE set_of_books_id = p_set_of_bks_id
      AND account_segment_value = l_account_segment;*/

    IF l_Cash_Acct_Count > 0
    THEN
      l_Cash_Related_Flag := TRUE;
    ELSE
      l_Cash_Related_Flag := FALSE;
    END IF; --l_cash_acct_count>0

    IF (l_Proc_Level >= l_Dbg_Level)
    THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

    RETURN(l_Cash_Related_Flag);

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level)
      THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

      RETURN(FALSE);

  END Check_Cash_Related_Account;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Check_Accounting_Period_Range                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to check whether all the periods' status within
  --    the range are 'C' or 'P'
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --      In:        p_start_period_name    Start period name
  --      In:        p_end_period_name      End period name
  --
  --  RETURN:
  --      True for success, otherwise False
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      04-July-2006     Joseph Wang Created
  --
  --===========================================================================
  FUNCTION Check_Accounting_Period_Range(p_Start_Period_Name IN VARCHAR2,
                                         p_End_Period_Name   IN VARCHAR2,
                                         p_Legal_Entity_Id   NUMBER,
                                         p_ledger_id         IN NUMBER--added by lyb
                                         )
    RETURN BOOLEAN IS
    l_Start_Date           DATE;
    l_End_Date             DATE;
    l_All_Period_Number    INTEGER;
    l_Closed_Period_Number INTEGER;

    l_Sob_Id     NUMBER;
    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'Check_Accounting_Period_Range';
  BEGIN

   -- l_Sob_Id := Ja_Cn_Utility.Get_Sob(p_Legal_Entity_Id);--updated by lyb
    SELECT Start_Date
      INTO l_Start_Date
      FROM Gl_Period_Statuses
     WHERE ledger_id=p_ledger_id--Set_Of_Books_Id = l_Sob_Id,--updated by lyb
       AND Application_Id = 101
       AND Period_Name = p_Start_Period_Name;

    SELECT End_Date
      INTO l_End_Date
      FROM Gl_Period_Statuses
     WHERE ledger_id=p_ledger_id--Set_Of_Books_Id = l_Sob_Id--updated by lyb
       AND Application_Id = 101
       AND Period_Name = p_End_Period_Name;

    SELECT COUNT(*)
      INTO l_All_Period_Number
      FROM Gl_Period_Statuses
     WHERE ledger_id=p_ledger_id--Set_Of_Books_Id = l_Sob_Id--updated by lyb
       AND Application_Id = 101
       AND ((Start_Date BETWEEN l_Start_Date AND l_End_Date) AND
           (End_Date BETWEEN l_Start_Date AND l_End_Date));

    SELECT COUNT(*)
      INTO l_Closed_Period_Number
      FROM Gl_Period_Statuses
     WHERE ledger_id=p_ledger_id--Set_Of_Books_Id = l_Sob_Id,--updated by lyb
       AND Application_Id = 101
       AND ((Start_Date BETWEEN l_Start_Date AND l_End_Date) AND
           (End_Date BETWEEN l_Start_Date AND l_End_Date))
       AND (Closing_Status = 'C' OR Closing_Status = 'P');

    IF (l_All_Period_Number <> l_Closed_Period_Number)
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level)
      THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

      RETURN(FALSE);
  END Check_Accounting_Period_Range;

  FUNCTION Fetch_Account_Structure(p_Le_Id IN NUMBER) RETURN VARCHAR2 IS
    l_Acc_Stru_Tablename VARCHAR2(100) := 'JA_CN_ACCOUNT_STRUCTURES_KFV';
    l_Sql                VARCHAR2(1000);
    l_Result             VARCHAR2(2000);
  BEGIN
    l_Sql := 'SELECT nvl(jcask.concatenated_segments, '''')
        FROM ' || l_Acc_Stru_Tablename ||
             ' jcask
           ,ja_cn_system_parameters_all  jcsp
      WHERE jcask.account_structure_id = jcsp.account_structure_id
        AND jcsp.legal_entity_id = :1';
    EXECUTE IMMEDIATE l_Sql
      INTO l_Result
      USING p_Le_Id;
    RETURN l_Result;
  END Fetch_Account_Structure;
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Populate_Ledger_Le_Bsv_Gt                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to populate the balance segment of currenct
  --    legal entity and ledger into temporary table ja_cn_ledger_le_bsv_gt
  --
  --
  --  PARAMETERS:
  --      In:        p_legal_entity_id      Legal entity ID
  --      In:        p_ledger_id            Ledger ID
  --
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      12-Mar-07     Qingjun Zhao Created
  --
  FUNCTION Populate_Ledger_Le_Bsv_Gt(p_Ledger_Id       IN NUMBER,
                                     p_Legal_Entity_Id IN NUMBER)
    RETURN VARCHAR2 IS
    l_Ledger_Category VARCHAR2(30);
    l_Bsv_Option      VARCHAR2(1);
    l_Bsv_Vset_Id     NUMBER;

    l_Fv_Table   Fnd_Flex_Validation_Tables.Application_Table_Name%TYPE;
    l_Fv_Col     Fnd_Flex_Validation_Tables.Value_Column_Name%TYPE;
    l_Fv_Type    Fnd_Flex_Value_Sets.Validation_Type%TYPE;
    l_Insertsql  Dbms_Sql.Varchar2s;
    l_Line_No    NUMBER := 0;
    l_Cursorid   INTEGER;
    l_Return_No  NUMBER;
    l_Dbg_Level  NUMBER := Fnd_Log.g_Current_Runtime_Level;
    l_Proc_Level NUMBER := Fnd_Log.Level_Procedure;
    l_Proc_Name  VARCHAR2(100) := 'Populate_Ledger_Le_Bsv_Gt';

  BEGIN
    --log for debug
    IF (l_Proc_Level >= l_Dbg_Level)
    THEN
      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.begin',
                     'Enter procedure');

      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_ledger_id ' || p_ledger_Id);

      Fnd_Log.STRING(l_Proc_Level,
                     l_Module_Prefix || '.' || l_Proc_Name || '.parameters',
                     'p_legal_entity_id ' || p_legal_entity_id);

    END IF; --(l_proc_level >= l_dbg_level)
    IF (p_Ledger_Id IS NULL)
    THEN
      -- Ledger ID is not passed, so return F (i.e. FAIL)
      RETURN 'F1';

    END IF;

    -- First, get its ledger category code and BSV option code
    SELECT Ledger_Category_Code,
           Nvl(Bal_Seg_Value_Option_Code, 'A'),
           Bal_Seg_Value_Set_Id
      INTO l_Ledger_Category,
           l_Bsv_Option,
           l_Bsv_Vset_Id
      FROM Gl_Ledgers
     WHERE Ledger_Id = p_Ledger_Id;

    IF (l_Ledger_Category <> 'PRIMARY' AND l_Ledger_Category <> 'SECONDARY' AND
       l_Ledger_Category <> 'ALC')
    THEN
      -- We don't handle NONE ledgers, which haven't been set up properly yet.
      -- Or, invalid ledger cateogry codes of the passed ledger.
      RETURN 'F2';



    END IF; -- IF (l_ledger_category <> 'PRIMARY' ...

    --
    -- Insert segment values from GL_LEDGER_NORM_SEG_VALS if the BSV option is
    -- Specific (i.e. I)
    --
    IF (l_Bsv_Option = 'I')
    THEN
      -- Insert rows for the passed ledger and its associated ALC Ledgers
      INSERT INTO Ja_Cn_Ledger_Le_Bsv_Gt
        (Ledger_Id,
         Ledger_Category_Code,
         Chart_Of_Accounts_Id,
         Bal_Seg_Value_Option_Code,
         Bal_Seg_Value_Set_Id,
         Bal_Seg_Value,
         Legal_Entity_Id,
         Start_Date,
         End_Date)
      -- XLE uptake: Changed to get the LE name from the new XLE tables
        SELECT Lg.Ledger_Id,
               Lg.Ledger_Category_Code,
               Lg.Chart_Of_Accounts_Id,
               Lg.Bal_Seg_Value_Option_Code,
               Lg.Bal_Seg_Value_Set_Id,
               Bsv.Segment_Value,
               Bsv.Legal_Entity_Id,
               Bsv.Start_Date,
               Bsv.End_Date
          FROM Gl_Ledgers              Lg,
               Gl_Ledger_Relationships Rs,
               Gl_Ledger_Norm_Seg_Vals Bsv,
               Gl_Ledgers              Lgr_c
         WHERE ((Rs.Relationship_Type_Code = 'NONE' AND
               Rs.Target_Ledger_Id = p_Ledger_Id) OR
               (Rs.Target_Ledger_Category_Code = 'ALC' AND
               Rs.Relationship_Type_Code IN ('SUBLEDGER', 'JOURNAL') AND
               Rs.Source_Ledger_Id = p_Ledger_Id))
           AND Rs.Application_Id = 101
           AND Lg.Ledger_Id = Rs.Target_Ledger_Id
           AND Bsv.Ledger_Id = p_Ledger_Id
           AND Rs.Target_Ledger_Id = Lgr_c.Ledger_Id
           AND Nvl(Lgr_c.Complete_Flag, 'Y') = 'Y'
           AND Bsv.Segment_Type_Code = 'B'
              -- We should exclude segment values with status code = 'D' since they
              -- will be deleted by the flatten program when config is confirmed
              --       AND bsv.status_code IS NULL
           AND Nvl(Bsv.Status_Code, 'I') <> 'D'
           AND Bsv.Legal_Entity_Id = p_Legal_Entity_Id;



    ELSIF (l_Bsv_Option = 'A')
    THEN
      --
      -- Insert segment values from the balancing flex value set if the BSV option is
      -- All (i.e. A)
      --
      SELECT Nvl(Fvt.Application_Table_Name, 'FND_FLEX_VALUES'),
             Nvl(Fvt.Value_Column_Name, 'FLEX_VALUE'),
             Fvs.Validation_Type
        INTO l_Fv_Table,
             l_Fv_Col,
             l_Fv_Type
        FROM Fnd_Flex_Value_Sets        Fvs,
             Fnd_Flex_Validation_Tables Fvt
       WHERE Fvs.Flex_Value_Set_Id = l_Bsv_Vset_Id
         AND Fvt.Flex_Value_Set_Id(+) = Fvs.Flex_Value_Set_Id;

      -- Build INSERT statement of the dynamic INSERT SQL
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := 'INSERT INTO JA_CN_LEDGER_LE_BSV_GT';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := '(LEDGER_ID, LEDGER_CATEGORY_CODE, ';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := ' CHART_OF_ACCOUNTS_ID, BAL_SEG_VALUE_OPTION_CODE, BAL_SEG_VALUE_SET_ID, ';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := ' BAL_SEG_VALUE, LEGAL_ENTITY_ID, ';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := ' START_DATE, END_DATE) ';

      -- Build SELECT statement of the dynamic INSERT SQL

      -- Columns: LEDGER_ID,  LEDGER_CATEGORY_CODE
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := 'SELECT lg.LEDGER_ID, lg.LEDGER_CATEGORY_CODE, ';

      -- Columns: CHART_OF_ACCOUNTS_ID, BAL_SEG_VALUE_OPTION_CODE
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := '       lg.CHART_OF_ACCOUNTS_ID, lg.BAL_SEG_VALUE_OPTION_CODE, ';

      -- Columns: BAL_SEG_VALUE_SET_ID, BAL_SEG_COLUMNE_NAME, BAL_SEG_VALUE
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := '       lg.BAL_SEG_VALUE_SET_ID, bsv.' ||
                                l_Fv_Col || ', ';

      -- Columns: LEGAL_ENTITY_ID, LEGAL_ENTITY_NAME, START_DATE, END_DATE
      -- Note: LE ID and Name are always NULL for ALL BSV option.
      l_Line_No := l_Line_No + 1;
      IF (l_Fv_Type <> 'F')
      THEN
        l_Insertsql(l_Line_No) :=  p_Legal_Entity_Id ||
                                  ', bsv.START_DATE_ACTIVE, bsv.END_DATE_ACTIVE  ';
      ELSE
        l_Insertsql(l_Line_No) :=  p_Legal_Entity_Id ||
                                  ', NULL, NULL  ';
      END IF;

      -- Column: RELATIONSHIP_ENABLED_FLAG
      --l_Line_No := l_Line_No + 1;
      --l_Insertsql(l_Line_No) := '       DECODE(lg.LEDGER_CATEGORY_CODE, ''PRIMARY'', ''Y'', ''N'') ';

      -- Build FROM statement of the dynamic INSERT SQL
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := 'FROM GL_LEDGERS lg, ' || l_Fv_Table ||
                                ' bsv ';

      -- Build WHERE statement of the dynamic INSERT SQL
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := 'WHERE (lg.ledger_id = :lg_id1 ';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := '       OR lg.ledger_id IN ( ';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := '           SELECT ledger_id FROM GL_ALC_LEDGER_RSHIPS_V ';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := '           WHERE application_id = 101 ';
      l_Line_No := l_Line_No + 1;
      l_Insertsql(l_Line_No) := '           AND source_ledger_id = :lg_id2)) ';

      IF (l_Fv_Type <> 'F')
      THEN
        l_Line_No := l_Line_No + 1;
        l_Insertsql(l_Line_No) := 'AND bsv.flex_value_set_id = lg.bal_seg_value_set_id ';
        l_Line_No := l_Line_No + 1;
        l_Insertsql(l_Line_No) := 'AND bsv.summary_flag = ''N'' ';
      END IF;

      -- Open cursor
      l_Cursorid := Dbms_Sql.Open_Cursor;
      Dbms_Sql.Parse(l_Cursorid,
                     l_Insertsql,
                     1,
                     l_Line_No,
                     TRUE,
                     Dbms_Sql.Native);

      -- Bind variables
      Dbms_Sql.Bind_Variable(l_Cursorid, ':lg_id1', p_Ledger_Id);
      Dbms_Sql.Bind_Variable(l_Cursorid, ':lg_id2', p_Ledger_Id);

      -- Execute INSERT SQL
      l_Return_No := Dbms_Sql.EXECUTE(l_Cursorid);

      -- Close cursor
      Dbms_Sql.Close_Cursor(l_Cursorid);

    ELSE
      -- Invalid BSV option code for the passed ledger
      RETURN 'S';

    END IF; -- IF (l_bsv_option = 'I')
    RETURN 'S';
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_Proc_Level >= l_Dbg_Level)
      THEN
        Fnd_Log.STRING(l_Proc_Level,
                       l_Module_Prefix || '.' || l_Proc_Name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
  END Populate_Ledger_Le_Bsv_Gt;

    --==========================================================================
  --  FUNCTION NAME:
  --
  --    Get_Balancing_Segment_Value                    Public
  --
  --  DESCRIPTION:
  --
  --    This function is used to get balancing segment value for the specified key flexfield segments.
  --
  --
  --  PARAMETERS:
  --      In:        p_coa_id                     Chart of account ID
  --      In:        p_concatenated_segments      Concatenated segments
  --
  --  RETURN:
  --      Balancing segment value, NULL for abnormal cases.
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      29-Aug-2008     Chaoqun Wu Created
  --
  --===========================================================================
  FUNCTION Get_Balancing_Segment_Value(
                                 p_coa_id IN NUMBER,
                                 p_concatenated_segments   IN  VARCHAR2)
  RETURN VARCHAR2 IS
    l_delimiter VARCHAR2(1);
    l_segments  FND_FLEX_EXT.SEGMENTARRAY;
    l_total_num NUMBER;
    l_num       NUMBER;
  BEGIN
    l_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL', 'GL#', p_coa_id);
    l_total_num := FND_FLEX_EXT.BREAKUP_SEGMENTS(p_concatenated_segments,
                                       l_delimiter,
                                       l_segments);
    SELECT NUM+1 INTO l_num
      FROM FND_SEGMENT_ATTRIBUTE_VALUES FSAV,
           (SELECT ROWNUM NUM, APPLICATION_COLUMN_NAME
              FROM (SELECT APPLICATION_COLUMN_NAME, SEGMENT_NUM
                      FROM FND_ID_FLEX_SEGMENTS
                     WHERE ID_FLEX_NUM = p_coa_id
                       AND ID_FLEX_CODE = 'GL#'
                       AND APPLICATION_ID = 101
                       AND ENABLED_FLAG = 'Y'
                     ORDER BY SEGMENT_NUM)) FIFS
     WHERE FSAV.APPLICATION_ID = 101
       AND FSAV.ID_FLEX_NUM = p_coa_id
       AND ID_FLEX_CODE = 'GL#'
       AND FSAV.ATTRIBUTE_VALUE = 'Y'
       AND FSAV.SEGMENT_ATTRIBUTE_TYPE = 'GL_BALANCING'
       AND FSAV.APPLICATION_COLUMN_NAME = FIFS.APPLICATION_COLUMN_NAME;

      IF l_num <= l_total_num THEN
        RETURN l_segments(l_num);
      ELSE
        RETURN NULL;
      END IF;

  END Get_Balancing_Segment_Value;


END Ja_Cn_Utility;

/
