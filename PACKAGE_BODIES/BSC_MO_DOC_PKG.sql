--------------------------------------------------------
--  DDL for Package Body BSC_MO_DOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MO_DOC_PKG" AS
/* $Header: BSCMODCB.pls 120.9.12000000.2 2007/02/13 09:02:00 rkumar ship $ */

gNameFileSTables VARCHAR2(1000);
g_error VARCHAR2(2000);
g_newline VARCHAR2(10):= '
';
g_stack VARCHAR2(32767);

g_mode NUMBER := 1;

TYPE cPerCalMap IS RECORD(
periodicity_name varchar2(200),
calendar_id number,
calendar_name    varchar2(200));
TYPE tab_cPerCalMap is table of cPerCalMap index by PLS_INTEGER;
gPeriod_CalName tab_cPerCalMap;
gPeriod_Cal_Init boolean := false;

PROCEDURE InitializePerCalMap IS
CURSOR perCal is
SELECT periodicity_id, per.name periodicity_name, cal.calendar_id, cal.NAME calendar_name
  FROM BSC_SYS_CALENDARS_VL cal
     , BSC_SYS_PERIODICITIES_VL per
    WHERE per.CALENDAR_ID = cal.calendar_id
    order by periodicity_id;
--TYPE l_record IS perCal%ROWTYPE;
TYPE l_table IS TABLE OF perCal%ROWTYPE;

l_records l_table;
BEGIN
  open perCal;
  fetch perCal BULK COLLECT INTO l_records;
  close perCal;
  for i in 1..l_records.count loop
    gPeriod_CalName(l_records(i).periodicity_id).periodicity_name := l_records(i).periodicity_name;
    gPeriod_CalName(l_records(i).periodicity_id).calendar_id := l_records(i).calendar_id;
    gPeriod_CalName(l_records(i).periodicity_id).calendar_name := l_records(i).calendar_name;
  end loop;
END;

PROCEDURE Initialize IS

BEGIN
    IF (g_mode = 2) then -- called from separate conc. program
        BSC_METADATA_OPTIMIZER_PKG.g_dir := null;
        BSC_METADATA_OPTIMIZER_PKG.g_dir:=fnd_profile.value('UTL_FILE_LOG');
        IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
            BSC_METADATA_OPTIMIZER_PKG.g_debug := TRUE;
            BSC_METADATA_OPTIMIZER_PKG.g_log_level := fnd_profile.value('AFLOG_LEVEL');
        ELSE -- IF BIS_PMF_DEBUG is set, then enable logging automatically
            BSC_METADATA_OPTIMIZER_PKG.g_log_level := FND_LOG.g_current_runtime_level;
        END IF;

        IF BSC_METADATA_OPTIMIZER_PKG.g_dir is null THEN
           BSC_METADATA_OPTIMIZER_PKG.g_dir:=BSC_METADATA_OPTIMIZER_PKG.getUtlFileDir;
        END IF;

        IF (FND_PROFILE.VALUE('BIS_PMF_DEBUG') = 'Y') THEN
            BSC_METADATA_OPTIMIZER_PKG.g_debug := true;
            BSC_METADATA_OPTIMIZER_PKG.g_log := true;
        END IF;

        IF (BSC_METADATA_OPTIMIZER_PKG.g_dir is null OR fnd_global.CONC_REQUEST_ID = -1) THEN -- run manually
               BSC_METADATA_OPTIMIZER_PKG.g_dir:=BSC_METADATA_OPTIMIZER_PKG.getUtlFileDir;
        END IF;
        BSC_METADATA_OPTIMIZER_PKG.g_log_level :=1;
        BSC_METADATA_OPTIMIZER_PKG.g_log:=true;
        fnd_file.put_names('META_DOC.log', 'META_DOC.out', BSC_METADATA_OPTIMIZER_PKG.g_dir);
        BSC_METADATA_OPTIMIZER_PKG.g_fileOpened := true;

        bsc_apps.init_bsc_apps;
    	bsc_message.init('Y');
        bsc_mo_helper_pkg.InitTablespaceNames;
        BSC_MO_HELPER_PKG.InitializePeriodicities;

        BSC_METADATA_OPTIMIZER_PKG.gAppsSchema := BSC_MO_HELPER_PKG.getAppsSchema;
    	BSC_METADATA_OPTIMIZER_PKG.gBSCSchema  := BSC_MO_HELPER_PKG.getBSCSchema;
        BSC_METADATA_OPTIMIZER_PKG.gApplsysSchema := BSC_MO_HELPER_PKG.getApplsysSchema;
        BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE := 0;
        BSC_METADATA_OPTIMIZER_PKG.initMVFlags ;

    END IF;

    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
	    BSC_MO_HELPER_PKG.writeTmp('---------------------------------------------------------'||g_newline);
		BSC_MO_HELPER_PKG.writeTmp('Database Generator Documentation start time is '||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	    BSC_MO_HELPER_PKG.writeTmp('---------------------------------------------------------'||g_newline);
	    BSC_MO_HELPER_PKG.writeTmp(g_newline);
    END IF;

    BSC_MO_HELPER_PKG.InitializeMasterTables;
    BSC_MO_HELPER_PKG.InitLOV;

    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
        BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.Initialize :' ||g_error);
        raise;
END;
--****************************************************************************
--  GetDbObjectType
--    DESCRIPTION:
--          Return object type after reading from database
--****************************************************************************

Function GetDbObjectType(objName IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cObjectType IS
    SELECT OBJECT_TYPE FROM USER_OBJECTS
    WHERE OBJECT_NAME = objName;
    l_type VARCHAR2(100);
BEGIN
    OPEN cObjectType;
    FETCH cObjectType INTO l_type;
    CLOSE cObjectType;
    return l_type;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
       BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.GetDbObjectType :' ||g_error);
        raise;
End ;



--****************************************************************************
--  GetSumTableMVName
--    DESCRIPTION:
--       Get the name of the summary MV.
--
--    PARAMETERS:
--       TableName: Summary Table Name
--****************************************************************************

Function GetSumTableMVName(TableName IN VARCHAR2) RETURN VARCHAR2 IS
    pos NUMBER;
    pos1 NUMBER;
    MVName VARCHAR2(30);
BEGIN
    pos := InStr(TableName, '_', -1);

    If pos > 0 Then
        MVName := substr(TableName, 1, pos) || 'MV';
    Else
        MVName := TableName || '_MV';
    End If;

    Return MVName;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
       BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.GetSumTableMVName :' ||g_error);
       bsc_mo_helper_pkg.writeTmp('TableName :' ||TableName||', pos='||pos, fnd_log.level_statement, true);
        raise;
End ;
--****************************************************************************
--  WRITELINETEXTFILE
--    DESCRIPTION:
--       Write to file
--****************************************************************************

PROCEDURE WRITELINETEXTFILE( text IN VARCHAR2) is
BEGIN
        --BSC_METADATA_OPTIMIZER_PKG.writeDoc(text);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, text);
END;


--****************************************************************************
--  EscribirEncabezado : WriteDocHeader
--
--    DESCRIPTION:
--       Write the header in text file
--****************************************************************************
PROCEDURE WriteDocHeader IS
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('Inside WriteDocHeader', FND_LOG.LEVEL_PROCEDURE);
	END IF;

    WriteLineTextFile( '+---------------------------------------------------------------------------+');
    WriteLineTextFile( 'Oracle Balanced Scorecard: Version : ' || BSC_METADATA_OPTIMIZER_PKG.VERSION);
    WriteLineTextFile( '');
    WriteLineTextFile( 'Copyright (c) Oracle Corporation 1999. All rights reserved.');
    WriteLineTextFile( '');
    -- Changed 'Metadata Optimizer' to 'Generated Database' in the following statement
    WriteLineTextFile( 'Module: Generate Database');
    WriteLineTextFile( '+---------------------------------------------------------------------------+');
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('Completed WriteDocHeader', FND_LOG.LEVEL_PROCEDURE);
	END IF;

End ;
--****************************************************************************
--  GetPeriodicityName : GetNombrePeriodicity
--    DESCRIPTION:
--       Get the name of the given periodicity.
--
--    PARAMETERS:
--       Periodicity: periodicity code
--****************************************************************************
Function GetPeriodicityName(Periodicity IN NUMBER) RETURN VARCHAR2 IS
CURSOR c1 IS
SELECT NAME FROM BSC_SYS_PERIODICITIES_VL
WHERE PERIODICITY_ID = Periodicity;
l_name varchar2(100) := null    ;

BEGIN
  IF (gPeriod_Cal_Init= false) then
    InitializePerCalMap;
    gPeriod_Cal_Init := true;
  END IF;

  return gPeriod_CalName(periodicity).periodicity_name;
  /*
    OPEN c1;
    FETCH c1 INTO l_name;
    CLOSE c1;
    return l_name;
  */
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
       BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.GetPeriodicityName :' ||g_error);
        raise;
End ;

    --****************************************************************************
Function GetPeriodicityCalendarName(periodicity_id IN NUMBER) RETURN VARCHAR2 IS
    --Fix bug#2436864 Do not use collection becasue the periodicity could
    -- be deleted
    --Fix bug#1928043
    --GetPeriodicityCalendarName = gCalendars(Trim(gPeriodicityes(Trim(periodicity_id)).Calendar_id)).Name

    CURSOR c1 (p1 NUMBER) IS
    SELECT NAME FROM BSC_SYS_CALENDARS_VL
    WHERE CALENDAR_ID = (
        SELECT CALENDAR_ID
        FROM BSC_SYS_PERIODICITIES_VL
        WHERE PERIODICITY_ID = p1);

    l_name VARCHAR2(100);
BEGIN
  IF (gPeriod_Cal_Init= false) then
    InitializePerCalMap;
    gPeriod_Cal_Init := true;
  END IF;

  return gPeriod_CalName(periodicity_id).calendar_name;

/*    OPEN c1(periodicity_id);
    FETCH c1 INTO l_name;
    CLOSE c1;
    return l_name;
*/
    EXCEPTION WHEN OTHERS THEN
       g_error := sqlerrm;
       BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.GetPeriodicityCalendarName, periodicity ='||periodicity_id||' :' ||g_error);
       raise;
End;



--****************************************************************************
--  StrX
--
--    DESCRIPTION:
--       Returns a string of the given lenght and made up of the given char.
--       Example: xcaracter = '-', p_length = 6
--                StrX = '------'
--    PARAMETERS:
--       xcaracter: char
--       p_length: lenght
--****************************************************************************
Function StrX(xcaracter IN VARCHAR2 , p_length IN NUMBER) RETURN VARCHAR2 IS
l_res VARCHAR2(4000) := null;
BEGIn

    For j IN 1..p_length LOOP
        l_res := l_res ||xcaracter;
    END LOOP;
    return l_res;

End ;
--****************************************************************************
--  DocResult : DocumentacionResult
--
--    DESCRIPTION:
--       Generate the result report
--****************************************************************************
PROCEDURE DocResult IS
  TABLELENGTH NUMBER := 40;
  INDENT NUMBER := 5;
  Indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
  msg VARCHAR2(1000);
  i NUMBER;
  j NUMBER;
  ShowITables Boolean;
  ShowOldITables Boolean;
  FirstTable Boolean;
  PeriodicityName VARCHAR2(100);
  CalendarName VARCHAR2(100);
  l_index1 NUMBER;
  l_index2 NUMBER;
  l_indic_table DBMS_SQL.NUMBER_TABLE;
  l_fields DBMS_SQL.VARCHAR2_TABLE;
  l_sumLevelChangedMsg VARCHAR2(1000);
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside DocResult', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  WriteLineTextFile (BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'METADATA_OPTIMIZER_RESULT'));
  WriteLineTextFile (StrX('-', Length(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'METADATA_OPTIMIZER_RESULT'))));
  --Bug#3306248
  --get message if summarization level was changed
  If BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0 Then
    l_sumLevelChangedMsg := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'SUM_LEVEL_CHANGE') ||
                            BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ' ||
                            BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_IVIEWER', 'FROM') || ' ';
    If BSC_METADATA_OPTIMIZER_PKG.g_Current_Adv_Sum_Level IS NULL Then
      l_sumLevelChangedMsg := l_sumLevelChangedMsg || 'NULL';
    Else
      l_sumLevelChangedMsg := l_sumLevelChangedMsg || BSC_METADATA_OPTIMIZER_PKG.g_Current_Adv_Sum_Level;
    End If;
    l_sumLevelChangedMsg := l_sumLevelChangedMsg || ' ' || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_IVIEWER', 'TO') || ' ';
    If BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level IS NULL Then
      l_sumLevelChangedMsg := l_sumLevelChangedMsg || 'NULL';
    Else
      l_sumLevelChangedMsg := l_sumLevelChangedMsg || BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level;
    End If;
  End If;
  IF (BSC_METADATA_OPTIMIZER_PKG.gIndicators.count=0) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Completed DocResult, gIndicators.count was zero');
    END IF;
    return;
  END IF;
  l_index1 := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('gIndicators.count = '||BSC_METADATA_OPTIMIZER_PKG.gIndicators.count);
  END IF;
  LOOP
    Indicator := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index1);
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Indicator.code = '||Indicator.code||', Indicator.Action_Flag = '||Indicator.Action_Flag);
    END IF;
    --Indicator code and name
    If Indicator.EDW_Flag = 0 Then
      WriteLineTextFile (Indicator.Code || ' ' || Indicator.Name);
    Else
      WriteLineTextFile (Indicator.Code || ' ' || Indicator.Name || ' (' ||BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'EDW') || ')');
    End If;
    IF (Indicator.Action_Flag = 0 OR Indicator.Action_Flag=6) THEN
      --Case 0, 6
      --No changes were made.
      --BSC-MV Note: Show if there was a summarization level change
      If BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change = 0 Then
        --No changes were made.
        fnd_message.set_name('BSC', 'BSC_NO_CHANGES_VERIF');
        msg := fnd_message.get;
        WriteLineTextFile (msg);
        ShowITables := False;
        ShowOldITables := False;
      Else
        --There was just a change in the summarization level
        --Input tables were not changed
        --Bug#3306248
        WriteLineTextFile (l_sumLevelChangedMsg);
        fnd_message.set_name('BSC', 'BSC_INPUT_TABLES_NO_CHANGED');
        msg := fnd_message.get;
        WriteLineTextFile (msg);
        ShowITables := False;
        ShowOldITables := False;
      End If;
    ELSIF (Indicator.Action_Flag = 1 OR Indicator.Action_Flag=3) THEN
      --Case 1, 3
      If BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.garrOldIndicators, Indicator.Code)>=0 Then
        --Structural changes: Add or drop a dimension, data set, analysis group, etc.
        msg := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'STRUCTURAL_CHANGE');
        msg := msg || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON');
        fnd_message.set_name('BSC', 'BSC_ADD_DROP_DIMENSION');
        msg := msg || ' ' ||fnd_message.get;
        WriteLineTextFile (msg);
        --Bug#3306248
        If BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0 Then
          WriteLineTextFile (l_sumLevelChangedMsg);
        End If;
        ShowITables := True;
        ShowOldITables := True;
      Else
        --New indicator
        WriteLineTextFile (BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'NEW_INDICATOR'));
        ShowITables := False;
        ShowOldITables := False;
      End If;
    ELSIF (Indicator.Action_Flag = 2) THEN
      --Case 2
      --Deleted
      WriteLineTextFile(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'DELETED'));
      ShowITables := False;
      ShowOldITables := True;
    ELSIF (Indicator.Action_Flag = 4 OR Indicator.Action_Flag = 5 OR Indicator.Action_Flag = 7) THEN
      --Case 4, 5, 7
      --Non-structural change(s):Change color or group functions.
      --Input tables were not changed
      msg := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'NONSTRUCTURAL_CHANGE');
      msg := msg || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON');
      msg := msg || ' ' || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'CHANGE_COLOR_OR_GROUP_FUNCTION');
      WriteLineTextFile (msg);
      --Bug#3306248
      If BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0 Then
        WriteLineTextFile (l_sumLevelChangedMsg);
      End If;
      fnd_message.set_name('BSC', 'BSC_INPUT_TABLES_NO_CHANGED');
      msg := fnd_message.get;
      WriteLineTextFile (msg);
      ShowITables := False;
      ShowOldITables := False;
    --Case Else
    ELSE
      ShowITables := False;
      ShowOldITables := False;
    END IF;
    --Input tables
    If ShowITables Then
      FirstTable := True;
      For i IN 0..BSC_METADATA_OPTIMIZER_PKG.gnumNewITables - 1 LOOP
        l_indic_table := BSC_MO_HELPER_PKG.decomposestringtonumber( BSC_METADATA_OPTIMIZER_PKG.garrNewITables(i).Indicators, ',');
        If BSC_MO_HELPER_PKG.findIndex(l_indic_table, Indicator.Code)>=0 Then
          If FirstTable Then
            --Write header
            WriteLineTextFile (BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'INPUT_TABLE'));
            WriteLineTextFile (StrX('-', Length(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'INPUT_TABLE'))));
            FirstTable := False;
          End If;
          --Table Name (Periodicity name)
          msg := BSC_METADATA_OPTIMIZER_PKG.garrNewITables(i).Name || ' (' ||
                            GetPeriodicityName(BSC_METADATA_OPTIMIZER_PKG.garrNewITables(i).periodicity) || ' (' ||
                            GetPeriodicityCalendarName(BSC_METADATA_OPTIMIZER_PKG.garrNewITables(i).periodicity) || '))';
          WriteLineTextFile (msg);
          l_fields := BSC_MO_HELPER_PKG.getDecomposedString(BSC_METADATA_OPTIMIZER_PKG.garrNewITables(i).fields, ',');
          --fields
          j := l_fields.first;
          LOOP
            EXIT WHEN l_fields.count=0;
            msg := StrX(' ', INDENT) || l_Fields(j);
            WriteLineTextFile (msg );
            EXIT WHEN j = l_fields.last;
            j := l_fields.next(j);
          END LOOP;
        End If;
      END LOOP;
    End If;
    --Old input tables
    If ShowOldITables Then
      FirstTable := True;
      i := BSC_METADATA_OPTIMIZER_PKG.garrOldBTables.first;
      LOOP
        EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.garrOldBTables.count = 0;
        l_indic_table := BSC_MO_HELPER_PKG.decomposestringtonumber( BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).Indicators, ',');
        If BSC_MO_HELPER_PKG.findIndex(l_indic_table, Indicator.Code)>=0 Then
          If FirstTable Then
            --Write header
            msg := StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'OLD_INPUT_TABLE'), TABLELENGTH) || StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'BACKUP_TABLE'), TABLELENGTH);
            WriteLineTextFile (msg);
            msg := StrFix(StrX('-', Length(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'OLD_INPUT_TABLE'))), TABLELENGTH) || StrFix(StrX('-', Length(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'BACKUP_TABLE'))), TABLELENGTH);
            WriteLineTextFile (msg);
            FirstTable := False;
          End If;


          --Input table        Backup table (Periodicity)
          --Fix bug#2436864 The peridiodicity or calendar of a old table could be deleted.
          --So show (Custom Periodicity) when that is the case.
          msg := StrFix(BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).InputTable, TABLELENGTH);
          -- Show B table backup only if it has really been created in this round
          IF BSC_MO_HELPER_PKG.findIndexVARCHAR2(BSC_METADATA_OPTIMIZER_PKG.gBackedUpBTables, BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).Name) >= 0 THEN
            msg := msg || BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).Name || '_BAK (';
            PeriodicityName := GetPeriodicityName(BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).periodicity);
            CalendarName := GetPeriodicityCalendarName(BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).periodicity);
            If (PeriodicityName IS NULL  Or CalendarName IS NULL) Then
              msg := msg || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_KPIDESIGNER', 'CUSTOM_PERIODICITY');
            Else
              msg := msg || PeriodicityName || ' (' || CalendarName || ')';
            End If;
            msg := msg || ')';
          END IF;
          WriteLineTextFile( msg);
          IF BSC_MO_HELPER_PKG.findIndexVARCHAR2(BSC_METADATA_OPTIMIZER_PKG.gBackedUpBTables, BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).Name) >= 0 THEN
            --fields
            l_fields := BSC_MO_HELPER_PKG.getDecomposedString(BSC_METADATA_OPTIMIZER_PKG.garrOldBTables(i).Fields, ',');
            j := l_fields.first;
            LOOP
              EXIT WHEN l_fields.count=0;
              msg := StrX(' ', TABLELENGTH) || StrX(' ', INDENT) || l_Fields(j);
              WriteLineTextFile (msg);
              EXIT WHEN j= l_fields.last;
              j := l_fields.next(j);
            END LOOP;
          END IF;
        End If;
        EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.garrOldBTables.last;
        i := BSC_METADATA_OPTIMIZER_PKG.garrOldBTables.next(i);
      END LOOP;
    End If;
    EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(l_index1);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed DocResult', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg(sqlerrm, 'DocResult');
    bsc_mo_helper_pkg.writeTmp('Exception in DocResult, g_stack = '||g_stack, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.TerminateWithError('BSC_RESULT_REPORT_FAILED', 'DocResult');
    raise;
End;

--****************************************************************************
--  GetMaxSubPeriodUsr
--
--    DESCRIPTION:
--       Returns the number of subperiods of the given periodicity.
--       It is read from BSC_SYS_PERIODICITIES table
--
--    PARAMETERS:
--       Periodicity: Periodicity code
--****************************************************************************
Function GetMaxSubPeriodUsr(Periodicity IN NUMBER) RETURN NUMBER IS

    CURSOR c1 IS
    SELECT NUM_OF_SUBPERIODS
    FROM BSC_SYS_PERIODICITIES
    WHERE PERIODICITY_ID = Periodicity;
    l_num NUMBER := null;
BEGIn
    OPEN c1;
    FETCH c1 INTO l_num;
    CLOSE c1;

    IF (l_num is null ) THEN
        return 0;
    ELSE
        return l_num;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
       BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.GetMaxSubPeriodUsr :' ||g_error);
        raise;
End ;

--****************************************************************************
--  GetMaxPeriod
--
--    DESCRIPTION:
--       Return the number of periods of the given periodicity.
--       It is read from BSC_SYS_PERIODICITIES table
--
--    PARAMETERS:
--       Periodicity: Periodicity code
--****************************************************************************
Function GetMaxPeriod(Periodicity IN NUMBER) RETURN NUMBER IS
    CURSOR c1 IS
    SELECT NUM_OF_PERIODS
    FROM BSC_SYS_PERIODICITIES
    WHERE PERIODICITY_ID = Periodicity;
    l_num NUMBER;
BEGIN
    OPEN c1;
    FETCH c1 INTO l_num;
    CLOSE c1;
    return l_num;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
       BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.GetMaxPeriod :' ||g_error);
        raise;
END;

--****************************************************************************
--  writeTableDescription
--
--    DESCRIPTION:
--       Write the description of the given table in the system tables
--       description file.
--
--    PARAMETERS:
--       Tabla: object with the information of the table
--****************************************************************************
PROCEDURE writeTableDescription(Tabla BSC_METADATA_OPTIMIZER_PKG.clsTable) IS

    TABLELENGTH NUMBER := 25;
    FIELDLENGTH NUMBER := 30;
    TYPELENGTH NUMBER := 15;
    SIZELENGTH NUMBER := 8;
    DESCLENGTH NUMBER := 60;

    l_periodicity_name VARCHAR2(100);
    Linea VARCHAR2(1000);
    l_period_column VARCHAR2(100);
    MaxPeriod NUMBER;
    l_subperiod_column VARCHAR2(100);
    MaxSubPeriod NUMBER;
    i NUMBER;

    l_stmt VARCHAR2(1000);
    rsColumn_Name VARCHAR2(100);
    rsData_Type VARCHAR2(100);
    rsData_Length VARCHAR2(100);
    rsData_Precision VARCHAR2(100);
    rsData_Scale VARCHAR2(100);
    descCodeZero VARCHAR2(100);
    msg VARCHAR2(100);
    TableName VARCHAR2(100);

    l_temp NUMBER;
    l_tempv VARCHAR2(1000);

    Table_Keys bsc_metadata_optimizer_pkg.tab_clsKeyField;
    Table_Data bsc_metadata_optimizer_pkg.tab_clsDataField;

    l_COLUMN_NAME VARCHAR2(30);
    l_DATA_TYPE VARCHAR2(106);
    l_DATA_LENGTH NUMBER;
    l_DATA_PRECISION NUMBER;
    l_DATA_SCALE NUMBER;
  l_source VARCHAR2(30);
    isBaseTable boolean;
    cv CurTyp;

   CURSOR cZeroMV(p_pattern varchar2) IS
   SELECT mview_name
     FROM all_mviews
    WHERE mview_name like p_pattern
      AND owner in (BSC_METADATA_OPTIMIZER_PKG.gBSCSchema,BSC_METADATA_OPTIMIZER_PKG.gAppsSchema);
   l_mvname VARCHAR2(100);

    /*CURSOR cProjTable IS
    SELECT DISTINCT projection_data
    FROM bsc_kpi_data_tables
    WHERE table_name = Tabla.name;*/
    CURSOR cProjTable(p_pt_table varchar2) IS
    SELECT table_name from all_tables
    WHERE owner = BSC_METADATA_OPTIMIZER_PKG.gBSCSchema
      AND table_name=p_pt_table;
    l_col_id NUMBER;

    l_bind_case number;
BEGIN

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('writeTableDescription, Table is : ');
    bsc_mo_helper_pkg.write_this(tabla);
  END IF;
  --BSC Multiple Optimizers
  --  Table_Keys := BSC_MO_HELPER_PKG.getAllKeyFields(Tabla.name);
  --  Table_Data := BSC_MO_HELPER_PKG.getAllDataFields(Tabla.name);
  Table_Keys := Tabla.keys;
  Table_Data := Tabla.data;
  If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
    isBaseTable := BSC_MO_LOADER_CONFIG_PKG.isBasicTable(Tabla.Name);
  End If;
  If Tabla.Type = 0 Then
    --input table
    l_periodicity_name := GetPeriodicityName(Tabla.Periodicity);
    l_periodicity_name := l_periodicity_name || ' (' || GetPeriodicityCalendarName(Tabla.Periodicity) || ')';
    l_period_column := BSC_MO_DB_PKG.GetPeriodColumnName(Tabla.Periodicity);
    MaxPeriod := GetMaxPeriod(Tabla.Periodicity);
    l_subperiod_column := BSC_MO_DB_PKG.GetSubperiodColumnName(Tabla.Periodicity);
    MaxSubPeriod := GetMaxSubPeriodUsr(Tabla.Periodicity);
    descCodeZero := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'REQUIRES_TOTALS_CODE_0');
  Else
    --system table
    l_periodicity_name := GetPeriodicityName(Tabla.Periodicity) ;
    l_periodicity_name := l_periodicity_name || ' (' || GetPeriodicityCalendarName(Tabla.Periodicity) || ')';
    l_period_column := 'PERIOD';
    MaxPeriod := GetMaxPeriod(Tabla.Periodicity);
    l_subperiod_column := null;
    MaxSubPeriod := 0;
  End If;
  --Table name and periodicity
  If Tabla.EDW_Flag = 1 Then
    TableName := Tabla.Name || ' (' || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'EDW') || ')';
  Else
    TableName := Tabla.Name;
  End If;
  --BSC-MV Note
  If (BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV And (Tabla.Type = 0 Or isBaseTable)) Or (Not BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV) Then
    WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'TABLE') || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) || TableName);
    If Tabla.IsTargetTable Then
      fnd_message.set_name('BSC', 'BSC_TABLE_FOR_BENCHMARKS');
      WriteLineTextFile (StrFix(' ', TABLELENGTH) || fnd_message.get);
    End If;
    WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'PERIODICITY') || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) || l_periodicity_name);
  Else
    If Tabla.dbObjectType = 'VIEW' Then
      WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'VIEW') || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) || Tabla.MVName);
    Else
      WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'TABLE') || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) || Tabla.MVName);
    End If;
  End If;
  --Bug3351483 Add reference to Zero code MVs and Projection Tabels in system.txt
  If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV And Tabla.Type <> 0 And (Not isBaseTable) Then
    --Only for MV architecture when the table is not an input table and it is not a base table
    OPEN cZeroMV(substr(tabla.name, 1, instr(tabla.name, '_', -1))||'%MV');
    FETCH cZeroMV INTO l_mvname;
    CLOSE cZeroMV;
    If l_mvname IS NOT NULL THEN
      WriteLineTextFile (bsc_mo_helper_pkg.Get_LookUp_Value('BSC_UI_BACKEND', 'ASSOCIATED_ZMV') || bsc_mo_helper_pkg.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ' || l_mvname);
    End If;
    --Get the associated Projection table
    OPEN cProjTable(substr(tabla.name,1, instr(tabla.name, '_', -1))||'PT');
    FETCH cProjTable into l_mvname;
    CLOSE cProjTable;
    If l_mvname is not null Then
      WriteLineTextFile(bsc_mo_helper_pkg.Get_LookUp_Value('BSC_UI_BACKEND', 'ASSOCIATED_PT') || bsc_mo_helper_pkg.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' '|| l_mvname);
    End If;
  End If;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Writing Headers');
  END IF;
  --Headers
  WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'FIELD'), FIELDLENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'TYPE'), TYPELENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'SIZE'), SIZELENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'DESCRIPTION'), DESCLENGTH));
  --BSC_MV Note
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Writing Columns');
  END IF;
  --Columns
  l_stmt := 'SELECT DISTINCT A.COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE, B.SOURCE, A.COLUMN_ID ';
  If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV And Tabla.dbObjectType = 'VIEW' Then
    l_bind_case := 1;
    l_stmt := l_stmt ||' FROM USER_TAB_COLUMNS A, BSC_DB_TABLES_COLS B WHERE A.TABLE_NAME = :1';
    --BSC Autogen
    l_stmt := l_stmt ||' AND B.TABLE_NAME(+) = :2 AND A.COLUMN_NAME=upper(B.COLUMN_NAME(+)) ';
  Else
    l_stmt := l_stmt ||' FROM ALL_TAB_COLUMNS A, BSC_DB_TABLES_COLS B ';
    If (BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV And (Tabla.Type = 0 Or isBaseTable))
        Or (Not BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV) Then
      l_bind_case := 2;
      l_stmt := l_stmt ||' WHERE A.TABLE_NAME = :1 ';
      --BSC Autogen
      l_stmt := l_stmt ||' AND A.TABLE_NAME = B.TABLE_NAME(+) AND A.COLUMN_NAME=upper(B.COLUMN_NAME(+)) ';
      l_stmt := l_stmt ||' AND A.OWNER = :2';
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp( 'table');
      END IF;
    Else
      l_bind_case := 3;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp( 'MV');
      END IF;
      l_stmt := l_stmt ||' WHERE A.TABLE_NAME = :1 ';
      --BSC Autogen
      l_stmt := l_stmt ||' AND B.TABLE_NAME(+) = :2 AND A.COLUMN_NAME=upper(B.COLUMN_NAME(+)) ';
      l_stmt := l_stmt ||' AND OWNER = :3 ';
    End If;
  End If;
  l_stmt := l_stmt ||' ORDER BY COLUMN_ID ';
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'l_stmt = '||l_stmt);
  END IF;
  IF (l_bind_case =1) THEN
    OPEN cv for l_stmt using UPPER(Tabla.MVName) ,UPPER(Tabla.Name);
  ELSIF l_bind_case=2 THEN
    OPEN cv for l_stmt using Upper(Tabla.Name),  UPPER(BSC_METADATA_OPTIMIZER_PKG.gBscSchema);
  ELSE
    OPEN cv for l_stmt using UPPER(Tabla.MVName) ,UPPER(Tabla.Name),  UPPER(BSC_METADATA_OPTIMIZER_PKG.gAppsSchema);
  END IF;
  LOOP
    FETCH cv INTO l_COLUMN_NAME, l_DATA_TYPE, l_DATA_LENGTH, l_DATA_PRECISION, l_DATA_SCALE, l_source, l_col_id;
    EXIT WHEN cv%NOTFOUND;
    rsColumn_Name := l_COLUMN_NAME;
    rsData_Type := l_DATA_TYPE;
    rsData_Length := l_DATA_LENGTH;
    If rsData_Length = 0 Then
      rsData_Length := null;
    End If;
    rsData_Precision := l_DATA_PRECISION;
    If rsData_Precision = 0 Then
      rsData_Precision := null;
    End If;
    rsData_Scale := l_DATA_SCALE;
    If rsData_Scale = 0 Then
      rsData_Scale := null;
    End If;
    Linea := StrFix(rsColumn_Name, FIELDLENGTH);
    Linea := Linea || StrFix(rsData_Type, TYPELENGTH);
    If UPPER(rsData_Type) = 'NUMBER' Then
      If rsData_Precision IS NULL Then
        rsData_Length := null;
        Linea := Linea || StrFix(' ', SIZELENGTH);
      Else
        If rsData_Scale IS NULL Then
          rsData_Length := rsData_Precision;
          Linea := Linea || StrFix(rsData_Length, SIZELENGTH);
        Else
          rsData_Length := rsData_Precision;-- || ',' || rsData_Scale
          IF (rsData_Length IS NOT NULL) THEN
            Linea := Linea || StrFix(rsData_Length||',' || rsData_Scale, SIZELENGTH);
          END IF;
        End If;
      End If;
    ELSE
      Linea := Linea || StrFix(rsData_Length, SIZELENGTH);
    End If;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Processing column:'||rsColumn_Name, FND_LOG.LEVEL_STATEMENT);
    END IF;
    If BSC_MO_INDICATOR_PKG.keyFieldExists(Table_Keys, rsColumn_Name) Then
      BSC_MO_HELPER_PKG.writeTmp('Its a key', FND_LOG.LEVEL_STATEMENT);
      If Tabla.Type = 0 Then -- input table
        Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'USER_CODE');
      Else
        Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'CODE');
      End If;
      l_temp := BSC_MO_HELPER_PKG.findKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, rsColumn_Name);
      fnd_message.set_name('BSC', 'BSC_SEE_TABLE_NAME');
      IF (l_temp <> -1) THEN
        fnd_message.set_token('TABLE_NAME', BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp).Name );
        msg := fnd_message.get;
        Linea := Linea || ' (' || msg || ')';
      END IF;
      If Tabla.Type = 0 Then --input table
        l_temp := BSC_MO_HELPER_PKG.findIndex(Table_Keys, rsColumn_Name);
        IF (l_temp <> -1) THEN
          If Table_Keys(l_temp).NeedsCode0 Then
            --If property NecesitaCod0 is TRUE the input table is for a precalculated indicator.
            --The input tables for no-precalculated indicators have this property in FALSE
            Linea := Linea || ' ' || descCodeZero;
          End If;
        END IF;
      End If;
    ElsIf BSC_MO_INDICATOR_PKG.dataFieldExists(Table_Data, rsColumn_Name) Then
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Data field exists, rsColumn_Name='||rsColumn_Name);
      END IF;
      If substr(rsColumn_Name, 1, 5) = 'BSCIC' Then
        Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INTERNAL_COLUMN');
      Else
        l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, rsColumn_name, l_source, true);
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp(' l_temp = '||l_temp);
        END IF;
        IF (l_temp <>-1) THEN
          Linea := Linea || BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).Description;
        END IF;
      End If;
    ElsIf UPPER(rsColumn_Name) = 'YEAR' Then
      Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'YEAR_1999_2000_ACTUAL_YEAR');
    ElsIf UPPER(rsColumn_Name) = 'TYPE' Then
      If (Tabla.EDW_Flag = 1 And Tabla.Type = 0) Or (Tabla.IsTargetTable) Then
        --If the input table is for EDW or is a targets input table, say 'Type: 1: Plan. Do not load actuals.'
        Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'TYPE_1_PLAN_EDW');
      Else
        Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'TYPE_0_ACTUAL_1_PLAN');
      End If;
    --added for bug 3919130
    ElsIf UPPER(rsColumn_Name) = 'TIME_FK' Then
      Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'DATE');
    ElsIf UPPER(rsColumn_Name) = UPPER(l_period_column) Then
      If (BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV And (Tabla.Type = 0 Or isBaseTable))
          Or (Not BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV) Then
        l_temp := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gperiodicities, Tabla.periodicity);
        IF (l_temp <> -1) THEN
          --I am doing this because the periodicity could not exist in the system.
          --Documentation can be run at anytime and the user could have deleted the periodicity
          If BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_temp).Yearly_Flag = 1 Then
            Linea := Linea || ' 0';   --bug#3980028
          Else
            Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'PERIOD');   --bug#3980028
            Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' 1 ' ||
               BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_IVIEWER', 'TO') || ' ' || MaxPeriod;
          End If;
        END IF;
      Else
        --Do not mention more info about period. MV has multiple periodicities.
        null;
        --Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'PERIOD');
      End If;
    ElsIf UPPER(rsColumn_Name) = UPPER(l_subperiod_column) Then
      Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'SUBPERIOD_1_TO') || ' ' || MaxSubPeriod;
    ElsIf UPPER(rsColumn_Name) = 'PERIODICITY_ID' OR UPPER(rsColumn_Name) = 'RECORD_TYPE'  Then
      Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INTERNAL_COLUMN');
    ELSE
      Linea := Linea || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INTERNAL_COLUMN');
    End If;
    WriteLineTextFile (Linea);
  END Loop;
  Close cv;
  WriteLineTextFile ('');
  WriteLineTextFile ('');
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.writeTableDescription :' ||sqlerrm);
    fnd_message.set_name ('BSC', 'BSC_TABLENAME_DESCR_FAILED');
    fnd_message.set_token('TABLE_NAME', Tabla.name);
    g_error := fnd_message.get;
    BSC_MO_HELPER_PKG.TerminateWithMsg(g_error);
    raise;
End ;
--****************************************************************************
--  WriteInputAndSystemTables : DocumentacionTablasDatos
--
--    DESCRIPTION:
--       Generate the description of the input and system tables
--****************************************************************************
PROCEDURE WriteInputAndSystemTables IS

    l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
    l_index1 NUMBER;
    dbObjectType VARCHAR2(106);
    mvName VARCHAR2(100);
    arrMvs DBMS_SQL.VARCHAR2_TABLE;
    numMVs NUMBER := 0;
BEGIn
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside WriteInputAndSystemTables', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  --Input tables
  WriteLineTextFile (BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INPUT_TABLES_DESCRIPTION'));
  WriteLineTextFile (StrX('-', Length(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INPUT_TABLES_DESCRIPTION'))));
  IF (BSC_METADATA_OPTIMIZER_PKG.gTables.count >0 ) THEN
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
    LOOP
      l_table := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1);
      If l_table.Type = 0 Then
        writeTableDescription (l_table);
      End If;
      EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
      l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index1);
    END LOOP;
  END IF;
  --System tables
  WriteLineTextFile (BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'SYSTEM_TABLES_DESCRIPTION'));
  WriteLineTextFile (StrX('-', Length(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'SYSTEM_TABLES_DESCRIPTION'))) );
  IF (BSC_METADATA_OPTIMIZER_PKG.gTables.count >0 ) THEN
    l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
    LOOP
      l_table := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1);
      If l_table.Type <> 0 Then
	    If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
          --BSC-MV Note: If the table is a base table then write the description of the table.
          --If not then write the description of the MV (if exists)
          If  BSC_MO_LOADER_CONFIG_PKG.isBasicTable(l_table.Name) Then
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              bsc_mo_helper_pkg.writeTmp('SYNONYM', FND_LOG.LEVEL_STATEMENT);
            END IF;
            writeTableDescription (l_table);
            l_table.dbObjectType := 'SYNONYM';
          Else
            MVName := GetSumTableMVName(l_table.Name);
            dbObjectType := GetDbObjectType(MVName);
            l_table.dbObjectType := dbObjectType;
            l_table.MVName := MVName;
            --Remember that 1 mv correespond to multiple summary tables (different periodicities)
            If Not BSC_MO_HELPER_PKG.searchStringExists(arrMvs, numMVs, MVName) Then
              If dbObjectType IS NOT NULL Then
                --It is a MV or View
                writeTableDescription (l_table);
              End If;
              arrMvs(numMVs) := MVName;
              numMVs := numMVs + 1;
            End If;
          End If;
        ELSE
          writeTableDescription (l_table);
        END IF;
      End If;
      EXIT WHEN l_index1 = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
      l_index1 := BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index1);
    END LOOP;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed WriteInputAndSystemTables', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg(sqlerrm);
    bsc_mo_helper_pkg.writeTmp('Exception in WriteInputAndSystemTables, g_stack = '||g_stack, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.TerminateWithError('BSC_DATATABLE_DOC_FAILED', 'WriteInputAndSystemTables');
    raise;
End ;
--****************************************************************************
--  SetNeedCod0InOriTables
--
--    DESCRIPTION:
--       Mark the property NecesitaCod0 in the origin tables of the given
--       tables according to the the values already marked in the tables.
--****************************************************************************
PROCEDURE SetNeedCod0InOriTables(arrTablesCod0 IN DBMS_SQL.VARCHAR2_TABLE, numTablesCod0 IN NUMBER) IS
    i NUMBER;
    arrTablesOri DBMS_SQL.VARCHAR2_TABLE;
    numTablesOri NUMBER;
    TablaOri VARCHAR2(100);
    keyColumn BSC_METADATA_OPTIMIZER_PKG.clsKeyField;

    l_origin_counter NUMBER;
    l_index2 NUMBER;
    l_table_index_in_gTables NUMBER;
    l_origin_index_in_gTables NUMBER;

    l_key_index NUMBER;
    l_originTable DBMS_SQL.varchar2_table;
    l_table_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
    l_origin_table_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;


BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside SetNeedCod0InOriTables', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  numTablesOri := 0;
  For i IN 0..numTablesCod0 - 1 LOOP
    l_table_index_in_gTables := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, arrTablesCod0(i));
    l_originTable := BSC_MO_HELPER_PKG.getDecomposedString(BSC_METADATA_OPTIMIZER_PKG.gTables(l_table_index_in_gTables).originTable, ',');
    l_origin_counter := l_originTable.first;
    LOOP
      EXIT WHEN l_originTable.count=0;
      TablaOri := l_originTable(l_origin_counter);
      l_table_keys := BSC_METADATA_OPTIMIZER_PKG.gTables(l_table_index_in_gTables).keys;
      l_origin_index_in_gTables := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, TablaOri);
      -- origin table keys
      l_origin_table_keys := BSC_METADATA_OPTIMIZER_PKG.gTables(l_origin_index_in_gTables).keys;
      l_index2 := l_origin_table_keys.first;
      LOOP
        EXIT WHEN l_origin_table_keys.count=0;
        keyColumn := l_origin_table_keys(l_index2);
        --Because this function is just for precalculated kpis,
        --we know that there is not change of dissagregation
        l_key_index := BSC_MO_HELPER_PKG.findIndex(l_table_keys, keyColumn.keyName);
        if (l_key_index<>-1) then
          keyColumn.NeedsCode0 := l_table_keys(l_key_index).NeedsCode0;
          l_origin_table_keys(l_index2) := keyColumn;
        end if;
        EXIT WHEN l_index2 = l_origin_table_keys.last;
        l_index2 := l_origin_table_keys.next(l_index2);
      END LOOP;
      BSC_METADATA_OPTIMIZER_PKG.gTables(l_origin_index_in_gTables).keys := l_origin_table_keys;
      If Not BSC_MO_HELPER_PKG.searchStringExists(arrTablesOri, numTablesOri, TablaOri) Then
        arrTablesOri(numTablesOri) := TablaOri;
        numTablesOri := numTablesOri + 1;
      End If;
      EXIT WHEN l_origin_counter = l_originTable.last;
      l_origin_counter := l_originTable.next(l_origin_counter);
    END LOOP;
  END LOOP;
  If numTablesOri > 0 Then
    SetNeedCod0InOriTables(arrTablesOri, numTablesOri);
  End If;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed SetNeedCod0InOriTables', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.writeTableDescription :' ||g_error);
    raise;
End ;


--****************************************************************************
--  GetLevelPKCol
--
--    DESCRIPTION:
--       Returns level pk column name for the given indicator, configuration
--       and dimension level index.
--****************************************************************************
Function GetLevelPKCol(Indicator IN NUMBER, Configuration IN NUMBER, DimLevelIndex IN NUMBER) return VARCHAR2 IS
    res VARCHAR2(100) := null;
    CURSOR c1 (p1 NUMBER, p2 NUMBER, p3 NUMBER) IS
    SELECT LEVEL_PK_COL
    FROM BSC_KPI_DIM_LEVELS_B
    WHERE INDICATOR = p1
    AND DIM_SET_ID = p2
    AND DIM_LEVEL_INDEX = p3;
    l_level_pk_col VARCHAR2(100);
BEGIN
  OPEN c1(Indicator, Configuration, DimLevelIndex);
  FETCH c1 INTO l_level_pk_col;
  If c1%FOUND Then
    If l_level_pk_col IS NOT NULL Then
      res:= l_level_pk_col;
    End If;
  End If;
  Close c1;
  return res;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.GetLevelPKCol :' ||g_error);
    raise;
End ;
--****************************************************************************
--  ReplaceStr : ReemplazarStr
--
--    DESCRIPTION:
--       Replace a given sub-string by other sub_string in the given main string
--
--    PARAMETERS:
--       p_string: main string
--       p_replace_from: sub-string to be replaced
--       p_replace_to: sub-string used to replace the previous one
--****************************************************************************
Function ReplaceStr(p_string IN VARCHAR2, p_replace_from IN VARCHAR2, p_replace_to IN VARCHAR2) RETURN VARCHAR2 IS
    l_temp_string VARCHAR2(100);
    l_result_string VARCHAR2(100);
    l_string VARCHAR2(100);
    l_position NUMBER;
BEGIn
  If p_string IS NULL Then
    return p_string;
  END IF;
  l_string := p_string;
  l_result_string := null;
  l_position := InStr(l_string, p_replace_from);
  While l_position > 0 LOOP
    l_temp_string := substr(l_string, 1, l_position - 1);
    l_result_string := l_result_string || l_temp_string || p_replace_to;
    l_string := substr(l_string, l_position + Length(p_replace_from), length(l_string));
    l_position := InStr(l_string, p_replace_from);
  END Loop;
  l_result_string := l_result_string || l_string;
  return l_result_string;
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in ReplaceStr, param1= '||p_string||', param2='||p_replace_from||',param3='||p_replace_to);
    BSC_MO_HELPER_PKG.TerminateWithMsg(sqlerrm);
    BSC_MO_HELPER_PKG.writeTmp(sqlerrm, fnd_log.level_statement, true);
    raise;
End ;

FUNCTION getIndicsForTable (l_tableName IN VARCHAR2, l_num OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

-- get the indicator number from the table_name
-- eg. bsc_s_3001_0_0_5 should give 3001

l_stmt varchar2(2000) :=
'WITH main_indics AS
(select distinct to_number(substr(table_name, instr(table_name, ''_'', 1, 2)+1,
 instr(table_name,''_'',1,3)-instr(table_name,''_'',1,2)-1)) indicator
 from
 ( select table_name from bsc_db_tables_rels
    where source_table_name not like ''BSC_S%''
      and table_name like ''BSC_S%''
  connect by source_table_name = prior table_name
    start with source_table_name = :l_table_name)
 where table_name like ''BSC_S%''
)
select indicator from
(
SELECT INDICATOR FROM main_indics
union -- get dependant child indicators after validating filters are same
select kpis.indicator
  from main_indics ind, bsc_kpis_vl kpis
 where ind.indicator = kpis.source_indicator
   and not exists
       (select 1 from bsc_kpi_dim_levels_b master, bsc_kpi_dim_levels_b child
         where master.indicator=kpis.source_indicator
           and child.indicator= ind.indicator
           and master.level_table_name = child.level_table_name
           and master.dim_level_index = child.dim_level_index
           and master.level_view_name <> child.level_view_name)
)';

cv CurTyp;
l_result VARCHAR2(32000) := null;
l_indicator NUMBER;
l_error VARCHAR2(1000);
BEGIN
  l_num := 0;
  if (g_mode=1) then -- Doc results
    if (BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE<>0) then
      l_stmt := l_stmt ||' where indicator in (select indicator from bsc_tmp_opt_ui_kpis where process_id =:2)';
    end if;
  end if;
  IF (g_mode=1) and  (BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE<>0) then
    bsc_mo_helper_pkg.writeTmp('Case1, g_mode='||g_mode||' run_mode='||BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE);
    OPEN cv FOR l_stmt using l_tableName, BSC_METADATA_OPTIMIZER_PKG.g_processid;
  else
    bsc_mo_helper_pkg.writeTmp('Case2, g_mode='||g_mode||' run_mode='||BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE);
    OPEN cv for l_stmt  using l_tableName;
  end if;
  LOOP
    FETCH CV INTO l_indicator;
    EXIT WHEN CV%NOTFOUND;
    IF (l_result IS NOT NULL) THEN
      l_result := l_result||',';
    END IF;
    l_result := l_result || to_char(l_indicator);
    l_num := l_num + 1;
  END LOOP;
  CLOSE cv;
  IF (l_num > 100) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('# of results = '||l_num);
    END IF;
  END IF;
  return l_result;
  exception when others then
    l_error := sqlerrm;
    bsc_mo_helper_pkg.writeTmp(l_stmt);
    BSC_MO_HELPER_PKG.TerminateWithMsg('exception in getIndicsForTable : '||l_error) ;
    raise;
END;

--****************************************************************************
--  InicAllTables
--
--    DESCRIPTION:
--       Initialize the collection gTablas with all tables
--****************************************************************************
PROCEDURE InicAllTables IS

    l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
    l_key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
    l_data BSC_METADATA_OPTIMIZER_PKG.clsDataField;
    TablaOri VARCHAR2(100);

    Indicator NUMBER;
    Configuration NUMBER;
    TableName VARCHAR2(100);
    Filter_Condition VARCHAR2(4000);
    arrFilterDims DBMS_SQL.VARCHAR2_TABLE;
    numFilterDims NUMBER;
    TotalSign VARCHAR2(100);
    Level_Comb VARCHAR2(100);
    KeyColumn VARCHAR2(100);
    i NUMBER;
    arrTablesCod0 DBMS_SQL.VARCHAR2_TABLE;
    numTablesCod0 NUMBER;
    Target_Flag NUMBER;
    l_temp NUMBER;
    l_temp2 NUMBER;

    l_stmt varchar2(1000) :=
    'SELECT TABLE_NAME, TABLE_TYPE, PERIODICITY_ID, EDW_FLAG, TARGET_FLAG
    FROM BSC_DB_TABLES
    WHERE TABLE_TYPE <> 2';

    l_table_name varchar2(100);
    l_table_type varchar2(100);
    l_periodicity_id number;
    l_edw_flag number;
    l_target_flag number;


    l_table_name_list dbms_sql.varchar2_table;
    l_table_type_list  dbms_sql.varchar2_table;
    l_periodicity_id_list  dbms_sql.number_table;
    l_edw_flag_list dbms_sql.number_table;
    l_target_flag_list dbms_sql.number_table;

    cv Curtyp;

    CURSOR c2(p1 VARCHAR2) IS
    SELECT COLUMN_TYPE, COLUMN_NAME, SOURCE
        FROM BSC_DB_TABLES_COLS
        WHERE TABLE_NAME = p1;
    cRow2 c2%ROWTYPE;

    CURSOR c3(p1 VARCHAR2, p2 IN NUMBER) IS
    SELECT SOURCE_TABLE_NAME
    FROM BSC_DB_TABLES_RELS
    WHERE TABLE_NAME = p1
    AND RELATION_TYPE = p2
    ORDER BY SOURCE_TABLE_NAME;
    cRow3 c3%ROWTYPE;

    CURSOR c4 (p1 IN VARCHAR2, p2 IN VARCHAR2) IS
    SELECT column_name
    FROM all_tab_columns
    WHERE table_name = p1
    AND owner = p2
    ORDER BY column_id;
    cRow4 c4%ROWTYPE;

    /*CURSOR c5 IS
    SELECT INDICATOR, DIM_SET_ID, LEVEL_COMB, TABLE_NAME, FILTER_CONDITION
    FROM BSC_KPI_DATA_TABLES_V T
    WHERE TABLE_NAME IS NOT NULL AND
    0 = (
    SELECT PROPERTY_VALUE
    FROM BSC_KPI_PROPERTIES P
    WHERE UPPER(PROPERTY_CODE) = 'DB_TRANSFORM'
    AND P.INDICATOR = T.INDICATOR);
    cRow5 c5%ROWTYPE;*/


    Table_Keys bsc_metadata_optimizer_pkg.tab_clsKeyField;
    Table_Data bsc_metadata_optimizer_pkg.tab_clsDataField;
    Tabla_originTable DBMS_SQL.VARCHAR2_TABLE;
    Tabla_originTable1 DBMS_SQL.VARCHAR2_TABLE;

    l_ind_list DBMS_SQL.NUMBER_TABLE;
    l_table_index NUMBER;
    l_key_index NUMBER;

BEGIN
  --Set gTablas = New Collection
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside inicalltables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  if (g_mode = 1) then --
    if (BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE<>0) then
      l_stmt := l_stmt||
      ' and table_name in
       (
       SELECT SOURCE_TABLE_NAME FROM BSC_DB_TABLES_RELS
      CONNECT BY TABLE_NAME=prior SOURCE_TABLE_NAME
        START WITH table_name in
        (
          select table_name from bsc_db_tables dbtbl, bsc_tmp_opt_ui_kpis
          where dbtbl.table_name like ''BSC_S%''||indicator||''%''
            and indicator in
         (select indicator from bsc_tmp_opt_ui_kpis where process_id=:1)
        )
      UNION -- Get the S tables which are not sources
      SELECT TABLE_NAME FROM BSC_DB_TABLES dbtbl, bsc_tmp_opt_ui_kpis
       where dbtbl.table_name like ''BSC_S_%''||indicator||''%''
         and indicator in
         (select indicator from bsc_tmp_opt_ui_kpis where process_id=:1)
      )';
     end if;
  end if;
  l_stmt := l_stmt || ' ORDER BY TABLE_NAME';

  --Since input tables for dimensions are in BSC_DB_TABLES
  --we dont want them in this query.
  --This array is used for result report.
  BSC_METADATA_OPTIMIZER_PKG.gnumNewITables := 0;
  IF (g_mode=1) and  (BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE<>0) then
    OPEN cv for l_stmt using BSC_METADATA_OPTIMIZER_PKG.g_processid, BSC_METADATA_OPTIMIZER_PKG.g_processid;
  else
    OPEN cv for l_stmt;
  end if;
  FETCH cv bulk collect into l_table_name_list, l_table_type_list, l_periodicity_id_list, l_edw_flag_list, l_target_flag_list;
  CLOSE cv;

  FOR i IN 1..l_table_name_list.count LOOP
    l_table_name := l_table_name_list(i);
    l_table_type := l_table_type_list(i);
    l_periodicity_id := l_periodicity_id_list(i);
    l_edw_flag := l_edw_flag_list(i);
    l_target_flag := l_target_flag_list(i);

    l_table := bsc_mo_helper_pkg.new_clsTable;
    Table_keys.delete;
    Table_data.delete;
    l_table.Name := l_TABLE_NAME;
    l_table.Type := l_TABLE_TYPE;
    l_table.Periodicity := l_PERIODICITY_ID;
    l_table.EDW_Flag :=l_EDW_FLAG;
    Target_Flag := l_TARGET_FLAG;
    If Target_Flag = 1 Then
      l_table.IsTargetTable := True;
    Else
      l_table.IsTargetTable := False;
    End If;

    OPEN c2 (Upper(l_table.Name));
    LOOP
      FETCH c2 INTO cRow2;
      EXIT WHEN c2%NOTFOUND;
      If UPPER(cRow2.COLUMN_TYPE) = 'P' Then
        --Key column
        l_key := bsc_mo_helper_pkg.new_clsKeyField;
        l_key.keyName := cRow2.COLUMN_NAME;
        l_key.Origin := null;
        l_key.NeedsCode0 := False;
        l_key.CalculateCode0 := False;
        l_key.FilterViewName := null;
        Table_Keys(Table_Keys.count) := l_key;
      Else
        --Data column
        l_data := bsc_mo_helper_pkg.new_clsDataField;
        l_data.fieldName := cRow2.COLUMN_NAME;
        l_data.source := cRow2.source;
        l_data.Origin := null;
        l_data.aggFunction := null;
        Table_Data(Table_Data.count) := l_data;
      End If;
    END LOOP;
    Close c2;

    --Source tables (Hard Relations)
    OPEN c3 (UPPER(l_table.Name), 0);
    LOOP
      FETCH c3 INTO cRow3;
      EXIT WHEN c3%NOTFOUND;
      TablaOri := cRow3.SOURCE_TABLE_NAME;
      IF (Tabla_originTable IS NOT NULL ) THEN
        l_table.originTable:= l_table.originTable||',';
      END IF;
      l_table.originTable:= l_table.originTable || TablaOri;
    END Loop;
    Close c3;
    --Source table (Soft Relations)
    OPEN c3(Upper(l_table.Name), 1);
    LOOP
      FETCH c3 INTO cRow3;
      EXIT WHEN c3%NOTFOUND;
      TablaOri := cRow3.SOURCE_TABLE_NAME;
      IF (l_table.originTable1 IS NOT NULL ) THEN
        l_table.originTable1 := l_table.originTable1||',';
      END IF;
      l_table.originTable1 := l_table.originTable1||TablaOri;
    END LOOP;
    Close C3;
    --I dont care about indicator and configuration
    l_table.Indicator := 0;
    l_table.Configuration := 0;
    --Add table to collection
    bsc_mo_helper_pkg.writeTmp('Adding '||Upper(l_table.Name)||' to collection');
    BSC_MO_HELPER_PKG.addTable(l_table, Table_Keys, Table_Data, 'InicAllTables');
    If l_table.Type = 0 Then
      --Add the input table to array garrNewITables()
      BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).Name := l_table.Name;
      BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).periodicity := l_table.Periodicity;
      --Fields

      OPEN c4 (Upper(l_table.Name), UPPER(BSC_METADATA_OPTIMIZER_PKG.gBSCSchema));
      BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).numFields := 0;
      LOOP
        FETCH c4 INTO cRow4;
        EXIT WHEN c4%NOTFOUND;
        IF BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).Fields IS NOT NULL THEN
          BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).Fields :=
               BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).Fields||',';
        END IF;
        BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).Fields :=
               BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).Fields||cRow4.COLUMN_NAME;
        BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).numFields :=
               BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).numFields + 1;
      END Loop;
      Close c4;
      --Indicators
      --The indicators array is initialized in the procedure -DocumentacionGrafo-
      --We do it there to avoid another recursive procedure

      BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).Indicators :=
                getIndicsForTable(l_table.name, BSC_METADATA_OPTIMIZER_PKG.garrNewITables(BSC_METADATA_OPTIMIZER_PKG.gnumNewITables).NumIndicators);

      BSC_METADATA_OPTIMIZER_PKG.gnumNewITables := BSC_METADATA_OPTIMIZER_PKG.gnumNewITables + 1;
    End If;
  END Loop;


  --Mark key columns which need cero code for precalculated indicators
  l_stmt := 'SELECT INDICATOR, DIM_SET_ID, LEVEL_COMB, TABLE_NAME, FILTER_CONDITION
    FROM BSC_KPI_DATA_TABLES_V T
    WHERE TABLE_NAME IS NOT NULL AND
    0 = (
    SELECT PROPERTY_VALUE
    FROM BSC_KPI_PROPERTIES P
    WHERE UPPER(PROPERTY_CODE) = ''DB_TRANSFORM''
    AND P.INDICATOR = T.INDICATOR)';
  if (g_mode=1 and BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE<>0) then
    l_stmt := l_stmt||' and indicator in (select indicator from bsc_tmp_opt_ui_kpis where process_id=:1)';
    OPEN cv for l_stmt using BSC_METADATA_OPTIMIZER_PKG.g_processid;
  else
    OPEN cv for l_stmt;
  end if;
  numTablesCod0 := 0;
  LOOP
    FETCH cv INTO Indicator, Configuration, level_comb, TableName, filter_condition;
    EXIT WHEN cv%NOTFOUND;
    Level_Comb := Trim(LEVEL_COMB);
    Filter_Condition := ReplaceStr(Filter_Condition, 'D', null);
    numFilterDims := BSC_MO_HELPER_PKG.DecomposeString(Filter_Condition, ',', arrFilterDims );
    For i IN 0..numFilterDims - 1 LOOP
      TotalSign := substr(Level_Comb, arrFilterDims(i) + 1, 1);
      If (TotalSign = '?' Or TotalSign = '1') Then
        --This dimension needs zero code
        If arrFilterDims(i) = 1 And BSC_MO_INDICATOR_PKG.IsIndicatorBalanceOrPnL(Indicator, false) Then
          --Drill 1 (Account) in a PL indicator does not need zero code
          null;
        Else
          KeyColumn := GetLevelPKCol(Indicator, Configuration, arrFilterDims(i));
          If KeyColumn IS NOT NULL Then
            l_table_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, TableName);
            l_key_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables(l_table_index).keys, keyColumn);
            BSC_METADATA_OPTIMIZER_PKG.gTables(l_table_index).keys(l_key_index).needsCode0 := true;
            --update BSC_TMP_OPT_key_cols set need_zero_code = 1 where table_name = TableName and key_name = keyColumn;
            If BSC_MO_HELPER_PKG.findIndexVARCHAR2(arrTablesCod0, TableName)<0 Then
              arrTablesCod0(numTablesCod0) := TableName;
              numTablesCod0 := numTablesCod0 + 1;
            End If;
          End If;
        End If;
      End If;
    END LOOP;
  END Loop;
  Close cv;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('numTablesCod0 = '||numTablesCod0 );
  END IF;
  If numTablesCod0 > 0 Then
    SetNeedCod0InOriTables( arrTablesCod0, numTablesCod0);
  End If;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed inicalltables '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_PROCEDURE);
  END IF;
  Exception when others then
    bsc_mo_helper_pkg.writeTmp('l_stmt='||l_stmt, fnd_log.level_exception, true);
    BSC_MO_HELPER_PKG.TerminateWithMsg(' Exception in inicalltables:'||sqlerrm||', dumping gTables ');
    bsc_mo_helper_pkg.write_this(bsc_metadata_optimizer_pkg.gTables, FND_LOG.LEVEL_EXCEPTION, true);
    raise;
End;

--****************************************************************************
--  InicAllIndicadores
--
--    DESCRIPTION:
--       Initialize the collection gIndicadores with all indicators
--****************************************************************************
PROCEDURE InicAllIndicadores IS

    l_stmt VARCHAR2(1000);
    Cod NUMBER;
    Name BSC_KPIS_VL.NAME%TYPE;
    l_indic_type NUMBER;
    l_config_type NUMBER;
    Per_Inter NUMBER;
    OptimizationMode NUMBER;
    Action_Flag NUMBER;
    Share_Flag NUMBER;
    Source_Indicator NUMBER;
    EDW_Flag NUMBER;
    CURSOR c1 IS
    SELECT DISTINCT INDICATOR, NAME, PROTOTYPE_FLAG,
    INDICATOR_TYPE, CONFIG_TYPE, PERIODICITY_ID, SHARE_FLAG,
    SOURCE_INDICATOR, EDW_FLAG FROM BSC_KPIS_VL
    ORDER BY INDICATOR;
    cRow c1%ROWTYPE;
    l_impl_type number;
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Inside InicAllIndicadores', FND_LOG.LEVEL_PROCEDURE);
	END IF;

    gDocIndicators.delete;
    OPEN C1;
    LOOP
        FETCH c1 INTO cRow;
        EXIT WHEN c1%NOTFOUND;
        Cod := cRow.INDICATOR;
        Name := Trim(cRow.NAME);
        l_indic_type := cRow.INDICATOR_TYPE;
        l_config_type := cRow.CONFIG_TYPE;
        Per_Inter := cRow.PERIODICITY_ID;
        OptimizationMode := BSC_MO_HELPER_PKG.getKPIPropertyValue(Cod, 'DB_TRANSFORM', 1);
        l_impl_type := BSC_MO_HELPER_PKG.getKPIPropertyValue(Cod, BSC_METADATA_OPTIMIZER_PKG.IMPL_TYPE, 1);
        Action_Flag := cRow.PROTOTYPE_FLAG;
        Share_Flag := cRow.SHARE_FLAG;
        If cRow.SOURCE_INDICATOR IS NULL Then
            Source_Indicator := 0;
        Else
            Source_Indicator := cRow.SOURCE_INDICATOR;
        End If;
        EDW_Flag := cRow.EDW_FLAG;

        BSC_MO_HELPER_PKG.AddIndicator(gDocIndicators, Cod, Name, l_indic_type,
                        l_config_type, Per_Inter, OptimizationMode, Action_Flag,
                        Share_Flag, Source_Indicator, EDW_Flag, l_impl_type);

    END Loop;
    Close c1;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed InicAllIndicadores', FND_LOG.LEVEL_PROCEDURE);
	END IF;
    EXCEPTION WHEN OTHERS THEN
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in InicAllIndicadores :'||sqlerrm);
      bsc_mo_helper_pkg.writeTmp('Exception in InicAllIndicadores, g_stack = '||g_stack, FND_LOG.LEVEL_UNEXPECTED, true);
      bsc_mo_helper_pkg.TerminateWithError('BSC_KPI_INIT_FAILED', 'InicAllIndicadores');
      raise;
End ;

--****************************************************************************
--  IndexCampoRelEnPadresTabladimTable : FindRelationIndex
--
--    DESCRIPTION:
--       Returns the index of the relation field name in the collection
--       of parents of the give dimension.
--
--    PARAMETERS:
--       dimTable: dimension name
--       CampoRel: relation field name
--****************************************************************************
Function FindRelationIndex(dimTable IN VARCHAR2, CampoRel IN VARCHAR2) RETURN NUMBER IS
    i NUMBER;
    l_temp NUMBER;
    l_return number := -1;

    l_parents_relcol DBMS_SQL.varchar2_table;
BEGIN

    l_temp := BSC_MO_HELPER_PKG.findIndex( BSC_METADATA_OPTIMIZER_PKG.gMasterTable, dimTable);
    l_parents_relcol := BSC_MO_HELPER_PKG.getDecomposedString(BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp).parent_rel_col, ',');

    IF (l_parents_relcol.count=0) THEN
        return -1;
    END IF;

    i := l_parents_relcol.first;
    LOOP
        If UPPER(l_parents_relcol(i)) = UPPER(CampoRel) Then
            l_return := i;
            EXIT;
        End If;

        EXIT WHEN i = l_parents_relcol.last;
        i := l_parents_relcol.next(i);
    END LOOP;

    return l_return;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp(sqlerrm, fnd_log.level_statement, true);
    bsc_mo_helper_pkg.WriteTmp ('Exception FindRelationIndex, dimTable is '||dimTable||', CampoRel='||CampoRel, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.TerminateWithError('BSC_DIMTABLE_DESCR_FAILED', 'FindAuxillaryIndex');
    raise;
End;


--****************************************************************************
--  FindAuxillaryIndex :IndexCampoAuxiliar
--
--    DESCRIPTION:
--       Returns the index of the auxiliar field in the collection
--       CamposAuxiliares of the given dimension table.
--       Returns 0 if it is not found.

--    PARAMETERS:
--       dimTable: dimension table name
--       campoauxiliar: auxiliar field name
--****************************************************************************
Function FindAuxillaryIndex(dimTable IN VARCHAR2, CampoAuxiliar IN VARCHAR2) RETURN NUMBER IS
    i NUMBER;
    l_temp NUMBER;
    l_auxillaryFields  DBMS_SQL.varchar2_table;
BEGIN

    l_temp := BSC_MO_HELPER_PKG.findIndex( BSC_METADATA_OPTIMIZER_PKG.gMasterTable, dimTable);

    IF l_temp = -1 THEN
        return -1;
    END IF;

    l_auxillaryFields := bsc_mo_helper_pkg.getDecomposedString(BSC_METADATA_OPTIMIZER_PKG.gMasterTable(L_TEMP).auxillaryFields, ',');
    IF (l_auxillaryFields.count=0) THEN
        return -1;
    END IF;

    i := l_AuxillaryFields.first;
    LOOP
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('looping...');
	END IF;

        IF UPPER(l_AuxillaryFields(i)) = UPPER(CampoAuxiliar) Then

                return i;
        END IF;
        EXIT WHEN i = l_AuxillaryFields.last;
        i := l_AuxillaryFields.next(i);
    END LOOP;

    Return -1;

    EXCEPTION WHEN OTHERS THEN
      bsc_mo_helper_pkg.writeTmp(sqlerrm, fnd_log.level_statement, true);
      bsc_mo_helper_pkg.WriteTmp ('Exception FindAuxillaryIndex, g_stack is '||g_stack, FND_LOG.LEVEL_UNEXPECTED,true);
      bsc_mo_helper_pkg.TerminateWithError('BSC_DIMTABLE_DESCR_FAILED', 'FindAuxillaryIndex');
      raise;
End;

--****************************************************************************
--  StrFix
--
--    DESCRIPTION:
--       Returns a string wich is the same as the given string but adding spaces
--       until complete the specified lenght.
--
--    PARAMETERS:
--       p_string: string
--       p_length: lenght
--       p_center: center the string in the new string
--****************************************************************************
Function StrFix(p_string IN VARCHAR2, p_length IN NUMBER, p_center IN BOOLEAN DEFAULT FALSE) RETURN VARCHAR2 IS
    l_remaining_string VARCHAR2(1000);
    l_string_left VARCHAR2(1000);
    centrar NUMBER;
    l_return VARCHAR2(1000);
    l_space VARCHAR2(2000);
BEGIN
  LOOP
    l_space := l_space || '                                                                                                    '; -- 100 spaces
    EXIT WHEN length(l_space) = 1000;
  END LOOP;
  If p_center Then
    If Length(p_string) >= p_length Then
      l_return := substr(p_string, 1, p_length);
    Else
      l_string_left := (p_length - Length(p_string)) / 2;
      l_remaining_string := p_length - Length(p_string) - l_string_left;
      l_return := substr(l_space, 1, l_string_left) || p_string ||substr(l_Space, 1, l_remaining_string);
    End If;
  Else
    If Length(p_string) >= p_length Then
      l_return := substr(p_string, 1, p_length);
    Else
      l_return := p_string || substr(l_Space, 1, p_length - Length(p_string));
    End If;
  End If;
  return l_return;
End;

--****************************************************************************
--  EscribirDescripcionTablaMaestraMN : WriteMNDescription
--
--    DESCRIPTION:
--       Write the description of the given MN dimension table in the system tables
--       description file.
--
--    PARAMETERS:
--       Tabla: object with the information of the MN dimension table
--       InputTableFlag: True: Write the description of the input table
--                       False: Write the description of the dimension table
--****************************************************************************
PROCEDURE WriteMNDescription(Tabla IN BSC_METADATA_OPTIMIZER_PKG.clsRelationMN, InputTableFlag IN Boolean) IS
  TABLELENGTH NUMBER := 25;
  FIELDLENGTH NUMBER := 30;
  TYPELENGTH NUMBER := 15;
  SIZELENGTH NUMBER := 8;
  DESCLENGTH NUMBER := 60;
  Linea VARCHAR2(1000);
  iRel NUMBER;
  l_stmt VARCHAR2(1000);
  rsColumn_Name VARCHAR2(100);
  rsData_Type VARCHAR2(100);
  rsData_Length NUMBER;
  rsData_Precision NUMBER;
  rsData_Scale NUMBER;
  msg VARCHAR2(100);
  TableName VARCHAR2(100);
  CURSOR c1 (p1 VARCHAR2, p2 VARCHAR2) IS
    SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE
    FROM ALL_TAB_COLUMNS
    WHERE TABLE_NAME = p1
    AND UPPER(OWNER) = p2
    ORDER BY COLUMN_ID;
  cRow c1%ROWTYPE;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.WriteTmp ('Inside WriteMNDescription', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  --Table name
  If InputTableFlag Then
    --Input table
    TableName := Tabla.InputTable;
  Else
    TableName := Tabla.TableRel;
  End If;
  WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'TABLE') ||
                      BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) ||
                      TableName);
  --Input table name.
  If Not InputTableFlag Then
    --This information is only when the description is for the dimension table
    WriteLineTextFile('');
    WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INPUT_TABLE_NAME') ||
                      BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) ||
                      Tabla.InputTable);
  End If;
  --Headers
  WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'FIELD'), FIELDLENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'TYPE'), TYPELENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'SIZE'), SIZELENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'DESCRIPTION'), DESCLENGTH));
  --Columns
  OPEN c1 (Upper(TableName), UPPER(BSC_METADATA_OPTIMIZER_PKG.gBSCSchema) );
  LOOP
    FETCH c1 INTO cRow;
    EXIT WHEN c1%NOTFOUND;
    rsColumn_Name := cRow.COLUMN_NAME;
    rsData_Type  := cRow.DATA_TYPE;
    If  cRow.DATA_LENGTH IS NULL Then
      rsData_Length := null;
    Else
      rsData_Length  := cRow.DATA_LENGTH;
      If rsData_Length = 0 Then
        rsData_Length := null;
      End If;
    End If;
    If cRow.DATA_PRECISION IS NULL Then
      rsData_Precision := null;
    Else
      rsData_Precision  := cRow.DATA_PRECISION;
      If rsData_Precision = 0 Then
        rsData_Precision := null;
      End If;
    End If;
    If cRow.DATA_SCALE IS NULL Then
      rsData_Scale := null;
    Else
      rsData_Scale := cRow.DATA_SCALE;
      If rsData_Scale = 0 Then
        rsData_Scale := null;
      End If;
    End If;
    Linea := StrFix(rsColumn_Name, FIELDLENGTH);
    Linea := Linea || StrFix(rsData_Type, TYPELENGTH);
    If rsData_Type = 'NUMBER' Then
      If rsData_Precision IS NULL Then
        rsData_Length := null;
        Linea := Linea || StrFix(' ', SIZELENGTH);
      Else
        If rsData_Scale IS NULL Then
          rsData_Length := rsData_Precision;
          Linea := Linea || StrFix(rsData_Length, SIZELENGTH);
        Else
          rsData_Length := rsData_Precision; -- ',' || rsData_Scale
          Linea := Linea || StrFix(rsData_Length||','||rsData_Scale, SIZELENGTH);
        End If;
      End If;
    ELSE
      Linea := Linea || StrFix(rsData_Length, SIZELENGTH);
    End If;
    If UPPER(substr(rsColumn_Name, -4)) = '_USR' Then
      iRel := BSC_MO_HELPER_PKG.findKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, substr(rsColumn_Name, 1, Length(rsColumn_Name) - 4));
      If iRel <> -1 Then
        fnd_message.set_name('BSC', 'BSC_SEE_TABLE_NAME');
        fnd_message.set_token('TABLE_NAME', BSC_METADATA_OPTIMIZER_PKG.gMasterTable(iRel).Name || '.USER_CODE');
        msg := fnd_message.get;
        Linea := Linea || StrFix(msg, DESCLENGTH);
      End If;
    Else
      iRel := BSC_MO_HELPER_PKG.findKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, rsColumn_Name);
      If iRel <> -1 Then
        fnd_message.set_name('BSC', 'BSC_SEE_TABLE_NAME');
        fnd_message.set_token('TABLE_NAME', BSC_METADATA_OPTIMIZER_PKG.gMasterTable(iRel).Name || '.CODE');
        msg := fnd_message.get;
        Linea := Linea || StrFix(msg, DESCLENGTH);
      End If;
    End If;
    WriteLineTextFile (Linea);
  END Loop;
  Close c1;
  WriteLineTextFile ('');
  WriteLineTextFile ('');
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.WriteTmp ('Completed WriteMNDescription', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.WriteMNDescription :' ||g_error);
    raise;
End ;
--****************************************************************************
--  EscribirDescripcionTablaMaestra : WriteDimDescription
--    DESCRIPTION:
--       Write the description of the given dimension table in the system tables
--       description file.
--    PARAMETERS:
--       Tabla: object with the information of the dimension table
--       InputTableFlag: True: Write the description of the input table
--                       False: Write the description of the dimension table
--****************************************************************************
PROCEDURE WriteDimDescription(Tabla IN BSC_METADATA_OPTIMIZER_PKG.clsMasterTable, InputTableFlag Boolean) IS
  TABLELENGTH NUMBER := 25;
  FIELDLENGTH NUMBER := 30;
  TYPELENGTH NUMBER := 15;
  SIZELENGTH NUMBER := 8;
  DESCLENGTH NUMBER := 60;
  Linea VARCHAR2(1000);
  iRel NUMBER;
  l_stmt VARCHAR2(1000);
  rsColumn_Name VARCHAR2(100);
  rsData_Type VARCHAR2(100);
  rsData_Length NUMBER;
  rsData_Precision NUMBER;
  rsData_Scale NUMBER;
  msg VARCHAR2(400);
  TableName VARCHAR2(100);
  l_value VARCHAR2(1000);
  cv CurTyp;
  l_msg VARCHAR2(1000);
  l_parents DBMS_SQL.varchar2_table;
  l_COLUMN_NAME VARCHAR2(30);
  l_DATA_TYPE VARCHAR2(30);
  l_DATA_LENGTH NUMBER;
  l_DATA_PRECISION NUMBER;
  l_DATA_SCALE NUMBER;
  l_bind_Case number;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside WriteDimDescription for '||Tabla.Name);
  END IF;
  l_parents := bsc_mo_helper_pkg.getDecomposedString(tabla.parent_name, ',');
  --BIS DIMENSIONS: We are going to print the documentation only if the view exists.
  --Also this procedure is never called with InputTableFlag=true for BIS dimensions
  --BIS DIMENSIONS: Check that the dimension view exists. BIS dimension views are created
  --only when it is used by a Kpi.
  If Tabla.Source = 'PMF' Then
     bsc_mo_helper_pkg.writeTmp('Source is PMF');
    l_bind_case := 1;
    --BIS dimension, the dimension table is a View
    l_stmt := 'SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE
                FROM USER_TAB_COLUMNS
                WHERE TABLE_NAME = :1 ORDER BY COLUMN_ID';
  Else
    bsc_mo_helper_pkg.writeTmp('Source is BSC');
    --BSC dimension
    -- Bug 3830308 : Added owner clause here itself new GSCC validation isnt smart enough
    l_stmt := 'SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE
                    FROM ALL_TAB_COLUMNS WHERE OWNER = :1 AND ';
    If InputTableFlag Then
      l_bind_case := 2;
      l_stmt := l_stmt||' TABLE_NAME = :2';
    Else
      l_bind_Case := 3;
      l_stmt := l_stmt||' TABLE_NAME = :2';
    End If;
    l_stmt := l_stmt|| ' ORDER BY COLUMN_ID';
  End If;
  bsc_mo_helper_pkg.writeTmp('Stmt is '||l_stmt);
  if (l_bind_case =1) THEN
    OPEN CV for l_stmt using UPPER(Tabla.Name);
  ELSIF l_bind_case=2 THEN
    OPEN CV for l_stmt using UPPER(BSC_METADATA_OPTIMIZER_PKG.gBscSchema), UPPER(Tabla.InputTable);
  ELSE
    OPEN CV for l_stmt using UPPER(BSC_METADATA_OPTIMIZER_PKG.gBscSchema), UPPER(Tabla.Name);
  END IF;
  bsc_mo_helper_pkg.writeTmp('Bind case is '||l_bind_case);
  FETCH cv INTO l_COLUMN_NAME, l_DATA_TYPE, l_DATA_LENGTH, l_DATA_PRECISION, l_DATA_SCALE;
  If CV%NOTFOUND Then
    --The table or view does not exist in the database.
    --So we cannot write the documentation
    Close CV;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Completed WriteDimDescription');
    END IF;
    return;
  End If;
  CLOSE CV;
  --Table name
  If InputTableFlag Then
    --Input table
    TableName := Tabla.InputTable;
  Else
    If Tabla.Source = 'BSC' Then
      fnd_message.set_name('BSC', 'BSC_SEE_TABLE_NAME');
      fnd_message.set_token('TABLE_NAME', Tabla.InputTable);
      msg := fnd_message.get;
      TableName := Tabla.Name || '(' || msg || ')';
    Else
      TableName := Tabla.Name;
    End If;
  End If;
  If InputTableFlag Then
    --Input table
    WriteLineTextFile('');
    WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INPUT_TABLE_NAME') ||
                      BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) ||
                      TableName);
  Else
    --BIS DIMENSIONS: Use View instead of Table in the title.
    If Tabla.Source = 'BSC' Then
      WriteLineTextFile( StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'TABLE') ||
                      BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) ||
                      TableName);
    Else
      WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'VIEW') ||
                          BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ', TABLELENGTH) ||
                          TableName);
    End If;
  End If   ;
  --Headers
  WriteLineTextFile (StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'FIELD'), FIELDLENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'TYPE'), TYPELENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'SIZE'), SIZELENGTH) ||
                      StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'DESCRIPTION'), DESCLENGTH));
  --Columns
   if (l_bind_case =1) THEN
    OPEN CV for l_stmt using UPPER(Tabla.Name);
  ELSIF l_bind_case=2 THEN
    OPEN CV for l_stmt using UPPER(BSC_METADATA_OPTIMIZER_PKG.gBscSchema), UPPER(Tabla.InputTable);
  ELSE
    OPEN CV for l_stmt using UPPER(BSC_METADATA_OPTIMIZER_PKG.gBscSchema), UPPER(Tabla.Name);
  END IF;

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Doc, writing columns ');
  END IF;
  LOOP
    FETCH cv INTO l_COLUMN_NAME, l_DATA_TYPE, l_DATA_LENGTH, l_DATA_PRECISION, l_DATA_SCALE;
    EXIT WHEN cv%NOTFOUND;
    rsColumn_Name := l_column_name;
    rsData_type := l_data_type;
    If (l_DATA_LENGTH IS NULL) Then
      rsData_Length := null;
    Else
      rsData_Length := l_DATA_LENGTH;
      If rsData_Length = 0 Then
        rsData_Length := null;
      End If;
    End If;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Columns Name is '||rsColumn_Name||', data type='||rsData_type);
    END IF;
    If l_DATA_PRECISION IS NULL Then
      rsData_Precision := null;
    Else
      rsData_Precision := l_DATA_PRECISION;
      If rsData_Precision = 0 Then
        rsData_Precision := null;
      End If;
    End If;
    If l_DATA_SCALE IS NULL Then
      rsData_Scale := null;
    Else
      rsData_Scale := l_DATA_SCALE;
      If rsData_Scale = 0 Then
        rsData_Scale := null;
      End If;
    End If;
    Linea := StrFix(rsColumn_Name, FIELDLENGTH);
    Linea := Linea || StrFix(rsData_Type, TYPELENGTH);
    If rsData_Type = 'NUMBER' Then
      If rsData_Precision IS NULL Then
        rsData_Length := null;
        Linea := Linea || StrFix(' ', SIZELENGTH);
      Else
        If rsData_Scale IS NULL Then
          rsData_Length := rsData_Precision;
          Linea := Linea || StrFix(rsData_Length, SIZELENGTH);
        Else
          rsData_Length := rsData_Precision; -- ',' || rsData_Scale
          Linea := Linea || StrFix(rsData_Length||','||rsData_Scale, SIZELENGTH);
        End If;
      End If;
    ELSE
      Linea := Linea || StrFix(rsData_Length, SIZELENGTH);
    End If;
    If UPPER(rsColumn_Name) = 'CODE' Then
      Linea := Linea || StrFix(BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'CODE'), DESCLENGTH);
    ElsIf UPPER(rsColumn_Name) = 'USER_CODE' Then
      l_value := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'USER_CODE');
      Linea := Linea || StrFix(l_value, DESCLENGTH);
    ElsIf UPPER(rsColumn_Name) = 'NAME' Then
      l_value := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'NAME');
      Linea := Linea || StrFix(l_value, DESCLENGTH);
    ElsIf FindAuxillaryIndex(Tabla.Name, rsColumn_Name) <> -1 Then
      l_value := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'AUXILIARY_FIELD');
      Linea := Linea || StrFix(l_value, DESCLENGTH);
    Else
      If UPPER(substr(rsColumn_Name, -4)) = '_USR' Then
        iRel := FindRelationIndex(Tabla.Name, substr(rsColumn_Name, 1, Length(rsColumn_Name) - 4));
        If iRel <> -1 Then
          fnd_message.set_name('BSC', 'BSC_SEE_TABLE_NAME');
          fnd_message.set_token('TABLE_NAME', l_Parents(iRel) ||'.USER_CODE');
          msg := fnd_message.get;
          Linea := Linea || StrFix(msg, DESCLENGTH);
        End If;
      Else
        iRel := FindRelationIndex(Tabla.Name, rsColumn_Name);
        If iRel <> -1 Then
          fnd_message.set_name('BSC', 'BSC_SEE_TABLE_NAME');
          fnd_message.set_token('TABLE_NAME', l_Parents(iRel) ||'.CODE');
          msg := fnd_message.get;
          Linea := Linea || StrFix(msg, DESCLENGTH);
        End If;
      End If;
    End If;
    WriteLineTextFile (Linea);
  END Loop;
  Close cv;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Doc, done writing columns ');
  END IF;
  If InputTableFlag Then
    --Input table
    WriteLineTextFile('');
    WriteLineTextFile('');
  Else
    If Tabla.Source = 'PMF' Then
      WriteLineTextFile('');
      WriteLineTextFile('');
    End If;
  End If;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed WriteDimDescription');
  END IF;
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.writeTmp('l_stmt = '||l_stmt, FND_LOG.LEVEL_UNEXPECTED, true);
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception WriteDimDescription, Error is '||sqlerrm);
    bsc_mo_helper_pkg.WriteTmp ('Exception WriteDimDescription, g_stack is '||g_stack, FND_LOG.LEVEL_UNEXPECTED, true);
    bsc_mo_helper_pkg.TerminateWithError('BSC_DIMTABLE_DESCR_FAILED', 'WriteDimDescription');
    raise;
End ;
--****************************************************************************
--  DocumentacionTablasMaestras: DocumentDimensionTables
--
--    DESCRIPTION:
--       Generates the description of the dimension tables
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE DocumentDimensionTables IS
  dim BSC_METADATA_OPTIMIZER_PKG.clsMasterTable;
  dimMN BSC_METADATA_OPTIMIZER_PKG.clsRelationMN;
  title VARCHAR2(300);
BEGIN
  --Description of dimension tables
  title := BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'DIMENSION_TABLES_DESCRIPTION');
  WriteLineTextFile(title);
  WriteLineTextFile(StrX('-', Length(title)));
  WriteLineTextFile ('');
  --1N Dimensions
  IF (BSC_METADATA_OPTIMIZER_PKG.gMasterTable.count>0) THEN
    For i IN BSC_METADATA_OPTIMIZER_PKG.gMasterTable.first..BSC_METADATA_OPTIMIZER_PKG.gMasterTable.last LOOP
      dim := BSC_METADATA_OPTIMIZER_PKG.gMasterTable(i);
      WriteDimDescription( dim, False);
      --BIS DIMENSIONS: BIS dimensions does not have input table.
      If dim.Source = 'BSC' Then
        --Only for BSC Dimensions
        WriteDimDescription(dim,  True);
      End If;
    END LOOP;
  END IF;
  --MN Dimensions
  IF (BSC_METADATA_OPTIMIZER_PKG.gRelationsMN.count>0) THEN
    For i IN BSC_METADATA_OPTIMIZER_PKG.gRelationsMN.first..BSC_METADATA_OPTIMIZER_PKG.gRelationsMN.last LOOP
      dimMN := BSC_METADATA_OPTIMIZER_PKG.gRelationsMN(i);
      WriteMNDescription(dimMN, False);
      WriteMNDescription(dimMN, True);
    END LOOP;
  END IF;
  WriteLineTextFile('');
  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithError('BSC_DIMTABLE_DOC_FAILED', 'DocumentDimensionTables');
    raise;
End ;
--****************************************************************************
--  Documentacion
--
--    DESCRIPTION:
--       Generates documention
-- pMode = 1 : write summary results for this run
-- pMode = 2 : write entire system info
--****************************************************************************
PROCEDURE Documentation(pMode IN NUMBER DEFAULT 1) IS
    res NUMBER;
    msg VARCHAR2(1000);
BEGIN
  --Open file of description of system tables (dimension, input and system tables)
  g_mode := pMode;
  Initialize;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Starting InicAllIndicadores', FND_LOG.LEVEL_STATEMENT);
  END IF;
  --Initialize collection gIndicadores with ALL indicators
  InicAllIndicadores;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Starting InicAllTables', FND_LOG.LEVEL_STATEMENT);
  END IF;
  --Initialize collection gTablas with ALL tables
  InicAllTables;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside Documentation', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  writeDocHeader;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Wrote Doc Header', FND_LOG.LEVEL_STATEMENT);
  END IF;
  WriteLineTextFile( '');
  WriteLineTextFile( BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'TIME') || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || to_Char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  WriteLineTextFile( '');
  --Description of data tables
  IF (pMode = 2) THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Calling DocumentDimensionTables', FND_LOG.LEVEL_STATEMENT);
    END IF;
    DocumentDimensionTables;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Calling WriteInputAndSystemTables', FND_LOG.LEVEL_STATEMENT);
    END IF;
    WriteInputAndSystemTables;
    return;
  END IF;
  If BSC_METADATA_OPTIMIZER_PKG.gGAA_RUN_MODE <> 9 And BSC_METADATA_OPTIMIZER_PKG.gSYSTEM_STAGE = 2 Then
    --Result report
    --Open the result report file
    WriteLineTextFile( '');
    WriteLineTextFile( BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'TIME') || BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_COMMON', 'SYMBOL_COLON') || ' ' || to_char(sysdate, 'MMMM DD, YYYY HH:MM:SS'));
    WriteLineTextFile( '');
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Starting DocResult '||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT);
    END IF;
    -- to be called from BSC_METADATA_OPTIMIZER_PKG.Documentation
    DocResult;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Done with DocResult', FND_LOG.LEVEL_STATEMENT);
    END IF;
  End If;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed Documentation', FND_LOG.LEVEL_PROCEDURE);
  END IF;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in Documentation.Documentation :' ||g_error);
    BSC_MO_HELPER_PKG.TerminateWithError('BSC_DOC_PRODUCT_FAILED' , 'Documentation');
    raise;
End;
END BSC_MO_DOC_PKG;

/
