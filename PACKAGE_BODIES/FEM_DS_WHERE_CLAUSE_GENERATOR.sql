--------------------------------------------------------
--  DDL for Package Body FEM_DS_WHERE_CLAUSE_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DS_WHERE_CLAUSE_GENERATOR" AS
   --$Header: FEMDSWGB.pls 120.3.12010000.2 2008/10/10 22:25:55 huli ship $

   z_Dup_Entries_Tab Skipped_Data_List_Entries_Tab;
   z_Dup_Entries_Ctr BINARY_INTEGER := 0;

   z_No_Eff_Cal_Entries_Tab Skipped_Data_List_Entries_Tab;
   z_No_Eff_Cal_Entries_Ctr BINARY_INTEGER := 0;


   G_LOG_STATEMENT   CONSTANT NUMBER := fnd_log.level_statement;
   G_LOG_PROCEDURE   CONSTANT NUMBER := fnd_log.level_procedure;
   G_LOG_EVENT       CONSTANT NUMBER := fnd_log.level_event;
   G_LOG_EXCEPTION   CONSTANT NUMBER := fnd_log.level_exception;
   G_LOG_ERROR       CONSTANT NUMBER := fnd_log.level_error;
   G_LOG_UNEXPECTED  CONSTANT NUMBER := fnd_log.level_unexpected;
   --                                          000000000111111111122222222223333333333444444444455555555556
   --                                          123456789012345678901234567890123456789012345678901234567890
   G_APP_NAME        CONSTANT VARCHAR2(4)  := 'FEM';
   G_PKG_NAME        CONSTANT VARCHAR2(35) := 'FEM_DS_WHERE_CLAUSE_GENERATOR';
   G_MODULE_NAME     CONSTANT VARCHAR2(70) := 'fem.plsql.' || G_PKG_NAME  ||  '.';

   -- these variables must be kept in numerical order, with the lowest number indicating 'no error',
   -- and each variable after indicating a higher level of error (with the highest being utterly fatal..
   z_master_err_state      NUMBER          := FEM_UTILS.G_RSM_NO_ERR;

   G_ERRMSG_NO_ODS_FOR_DSG          CONSTANT varchar2(40) := 'FEM_DSWG_NO_ODS_FOR_DSG ';
   G_ERRMSG_UNEXPECTED_SQLERROR     CONSTANT varchar2(40) := 'FEM_RSM_UNEXPECTED_SQLERROR';
   G_ERRMAC_ROUTINE_NAME            CONSTANT varchar2(40) := 'ROUTINE_NAME';
   G_ERRMAC_SQL_ERROR               CONSTANT varchar2(40) := 'SQL_ERROR';



   -- *******************************************************************************************
   -- name          reset_master_err_state
   -- Function      set master_err_state to no error on entry to master API calls.
   -- Parameters
   --
   -- HISTORY
   --    22-Apr-2004    rjking   created
   --
   -- *******************************************************************************************
   PROCEDURE reset_master_err_state IS
   BEGIN
      z_master_err_state := FEM_UTILS.G_RSM_NO_ERR;
   END reset_master_err_state;


   ---------------------------------------------------------------
   Function DoesTableRequireChaining(X_Table_Name IN VARCHAR2)RETURN VARCHAR2 IS

      CURSOR c1 is
         SELECT
               tc.table_classification_code
            FROM
               fem_table_class_assignmt tc
            WHERE
                     tc.table_name = X_Table_Name
               and   tc.table_classification_code = 'DATASET_IO_WCLAUSE';

      l_Table_Classification_Code VARCHAR2(30) := 'X';


                                                --        1234567890123456789012345
      l_api_name              CONSTANT VARCHAR2(30)   := 'DoesTableRequireChaining';
      l_module_name           VARCHAR2(70)            := G_MODULE_NAME || l_api_name;
   Begin
      -- *******************************************************************************************
      -- name          DoesTableRequireChaining
      -- Function      Look up the table classification code for the table name
      --                passed into this function..
      --
      -- Parameters
      --
      -- IN
      --                X_Table_Name IN VARCHAR2
      --                   -  Table name for lookup..
      --
      -- OUT
      --
      -- Returns
      --                The table classification code.
      --
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      OPEN c1;
      FETCH c1 into l_Table_Classification_Code;
      CLOSE c1;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      RETURN l_Table_Classification_Code;

      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
   End DoesTableRequireChaining;


   Function No_Entry_For_IDS_ECP(p_Input_Dataset_Code IN NUMBER
                                 ,p_Input_Period_ID IN NUMBER
                                 ,p_List_B IN List_B
                                 ,p_List_B_Ctr IN BINARY_INTEGER) RETURN BOOLEAN IS
                                                --                 1         2
                                                --        1234567890123456789012345
      l_api_name              CONSTANT VARCHAR2(30)   := 'No_Entry_For_IDS_ECP';
      l_module_name           VARCHAR2(70)            := G_MODULE_NAME || l_api_name;
      l_retval                BOOLEAN                 := TRUE;
      l_curr_list_b           NUMBER;
   Begin
      -- *******************************************************************************************
      -- name          No_Entry_For_IDS_ECP
      -- Function      Search the p_List_B for an entry that matches the input dataset code and
      --                input period ID passed into this routine.
      --
      --
      -- Parameters
      --
      -- IN
      --                p_Input_Dataset_Code IN NUMBER
      --                   -  input dataset code to search for..
      --                ,p_Input_Period_ID IN NUMBER
      --                   -  input period id to search for..
      --                ,p_List_B IN List_B
      --                   -  The data structure to search
      --                ,p_List_B_Ctr IN BINARY_INTEGER
      --                   -  count of valid entries in the data structure p_List_B
      -- OUT
      --
      -- Returns
      --                FALSE if an entry was found matching p_Input_Dataset_Code and p_Input_Period_ID
      --                TRUE  if NO entry was found matching p_Input_Dataset_Code and p_Input_Period_ID
      --
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      -- look for a match in p_List_B
      l_curr_list_b := 0;
      WHILE       (l_curr_list_b <= p_List_B_Ctr)
            AND   l_retval                         LOOP

         If  (       p_List_B(l_curr_list_b).X_Dataset_Code = p_Input_Dataset_Code
               AND   p_List_B(l_curr_list_b).X_Cal_Period_ID = p_Input_Period_ID    ) then
            -- if found..
            l_retval := FALSE;
         End If;

         l_curr_list_b := l_curr_list_b + 1;
      END LOOP;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      RETURN l_retval;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- if not found
            RETURN TRUE;

         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);

   End No_Entry_For_IDS_ECP;


   Procedure Add_IDS_ECP_Entry_To_List_B
            (p_Input_Dataset_Code IN NUMBER
             ,p_Input_Calendar_Period_ID IN NUMBER
             ,p_List_B IN OUT NOCOPY List_B
             ,p_List_B_Ctr IN OUT NOCOPY BINARY_INTEGER) IS
                                                --                 1         2
                                                --        1234567890123456789012345
      l_api_name              CONSTANT VARCHAR2(30)   := 'Add_IDS_ECP_Entry_To_List_B';
      l_module_name           VARCHAR2(70)            := G_MODULE_NAME || l_api_name;
   Begin
      -- *******************************************************************************************
      -- name          Add_IDS_ECP_Entry_To_List_B
      -- Function      as the name suggests.. add the current p_Input_Dataset_Code/p_Input_Calendar_Period_ID
      --                tuple to p_List_B, and increment the count of valid entries.
      --
      --
      --
      -- Parameters
      --
      -- IN
      --                p_Input_Dataset_Code IN NUMBER
      --                   -  input data set code to add to p_List_B
      --                p_Input_Calendar_Period_ID IN NUMBER
      --                   -  input calendar period to add to p_List_B
      --
      -- OUT
      --                x_Err_Code OUT NUMBER
      --                   -  error code..
      --                x_Err_Msg  OUT VARCHAR2) IS
      --                   -  error message.
      --
      -- IN OUT
      --                p_List_B IN OUT NOCOPY List_B
      --                   -  data structure receiving the tuple.
      --                p_List_B_Ctr IN OUT NOCOPY BINARY_INTEGER
      --                   -  count of valid elements in p_List_B.
      --
      --
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      p_List_B(p_List_B_Ctr).X_DATASET_CODE := p_Input_Dataset_Code;
      p_List_B(p_List_B_Ctr).X_CAL_PERIOD_ID := p_Input_Calendar_Period_ID;
      p_List_B_Ctr := p_List_B_Ctr +1;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);

   End Add_IDS_ECP_Entry_To_List_B;



   Procedure Add_Missing_Entries
      (  p_Input_Dataset_Name IN DEF_DATASET_NAME%TYPE
         ,p_Abs_Cal_Period_Flag IN FEM_DS_INPUT_LISTS.ABSOLUTE_CAL_PERIOD_FLAG%TYPE
         ,p_Abs_Cal_Period_Name IN DEF_CAL_PERIOD_NAME%TYPE
         ,p_Rel_Dim_Grp_Name IN DEF_DIM_GRP_NAME%TYPE
         ,p_Rel_Cal_Period_Offset IN DEF_REL_CAL_PERIOD_OFFSET%TYPE
         ,p_Eff_Cal_Period_Name IN DEF_CAL_PERIOD_NAME%TYPE
         ,p_Missing_Entry_Type IN VARCHAR2) IS

                                                      --           1         2
                                                      --  1234567890123456789012345
      l_api_name              CONSTANT VARCHAR2(30)   := 'Add_Missing_Entries';
      l_module_name           VARCHAR2(70) := G_MODULE_NAME || l_api_name;
   Begin
      -- *******************************************************************************************
      -- name          Add_Missing_Entries
      -- Function      Add a missing entry to the correct data structure.
      --
      --
      -- Parameters
      --
      -- IN
      --                p_Input_Dataset_Name IN DEF_DATASET_NAME%TYPE
      --                   -
      --                p_Abs_Cal_Period_Flag IN FEM_DS_INPUT_LISTS.ABSOLUTE_CAL_PERIOD_FLAG%TYPE
      --                   -
      --                p_Abs_Cal_Period_Name IN DEF_CAL_PERIOD_NAME%TYPE
      --                   -
      --                p_Rel_Dim_Grp_Name IN DEF_DIM_GRP_NAME%TYPE
      --                   -
      --                p_Rel_Cal_Period_Offset IN DEF_REL_CAL_PERIOD_OFFSET%TYPE
      --                   -
      --                p_Eff_Cal_Period_Name IN DEF_CAL_PERIOD_NAME%TYPE
      --                   -
      --                p_Missing_Entry_Type IN VARCHAR2
      --                   -
      --
      -- OUT
      --                x_Err_Code OUT NUMBER
      --                   -
      --                x_Err_Msg  OUT VARCHAR2
      --                   -
      --
      -- Returns
      --
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      If (p_Missing_Entry_Type = 'DUP_ENTRY') then

         -- add it to the duplicate entries table..

         z_Dup_Entries_Tab(z_Dup_Entries_Ctr).Input_Dataset_Name
            := p_Input_Dataset_Name;
         z_Dup_Entries_Tab(z_Dup_Entries_Ctr).Absolute_Cal_Period_Flag
            := p_Abs_Cal_Period_Flag;
         z_Dup_Entries_Tab(z_Dup_Entries_Ctr).Abs_Cal_Period_Name
            := p_Abs_Cal_Period_Name;
         z_Dup_Entries_Tab(z_Dup_Entries_Ctr).Relative_Dim_Grp_Name
            := p_Rel_Dim_Grp_Name;
         z_Dup_Entries_Tab(z_Dup_Entries_Ctr).Relative_Cal_Period_Offset
            := p_Rel_Cal_Period_Offset;
         z_Dup_Entries_Tab(z_Dup_Entries_Ctr).Eff_Cal_Period_Name
            := p_Eff_Cal_Period_Name;
         z_Dup_Entries_Ctr
            := z_Dup_Entries_Ctr + 1;

      Elsif (p_Missing_Entry_Type = 'NO_EFF_CAL_PER') then
         -- add it to the 'we are missing a calendar period' table

         z_No_Eff_Cal_Entries_Tab(z_No_Eff_Cal_Entries_Ctr).Input_Dataset_Name
            := p_Input_Dataset_Name;
         z_No_Eff_Cal_Entries_Tab(z_No_Eff_Cal_Entries_Ctr).Absolute_Cal_Period_Flag
            := p_Abs_Cal_Period_Flag;
         z_No_Eff_Cal_Entries_Tab(z_No_Eff_Cal_Entries_Ctr).Abs_Cal_Period_Name
            := p_Abs_Cal_Period_Name;
         z_No_Eff_Cal_Entries_Tab(z_No_Eff_Cal_Entries_Ctr).Relative_Dim_Grp_Name
              := p_Rel_Dim_Grp_Name;
         z_No_Eff_Cal_Entries_Tab(z_No_Eff_Cal_Entries_Ctr).Relative_Cal_Period_Offset
            := p_Rel_Cal_Period_Offset;
         z_No_Eff_Cal_Entries_Tab(z_No_Eff_Cal_Entries_Ctr).Eff_Cal_Period_Name
              := p_Eff_Cal_Period_Name;
         z_No_Eff_Cal_Entries_Ctr
            := z_No_Eff_Cal_Entries_Ctr + 1;

      End If;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
   End Add_Missing_Entries;

   Procedure GetDatasetGroupNameandFolder( p_DS_IO_Def_ID IN DEF_IODD_DEF_ID%TYPE
                                           ,p_Dataset_Group_Name OUT NOCOPY DEF_OBJECT_NAME%TYPE
                                           ,p_Dataset_Group_Folder_Name OUT NOCOPY DEF_FOLDER_NAME%TYPE) IS

      l_IODD_Name DEF_OBJECT_NAME%TYPE;
      l_Folder_Name DEF_FOLDER_NAME%TYPE;

      cursor getIODDNameandFolder is
         select
               a.object_name
               ,b.folder_name
            from
               fem_object_definition_b c
               ,fem_object_catalog_vl a
               ,fem_folders_vl b
            where
                     c.object_definition_id = p_DS_IO_Def_ID
               and   c.object_id = a.object_id
               and   b.folder_id = a.folder_id;
                                                --           1         2
                                                --  1234567890123456789012345
      l_api_name        CONSTANT VARCHAR2(30)   := 'GetDatasetGroupNameandFolder';
      l_module_name     VARCHAR2(75)            := G_MODULE_NAME || l_api_name;
   Begin
      -- *******************************************************************************************
      -- name          GetDatasetGroupNameandFolder
      -- Function      retrieve the data set group name and the folder it is stored in based on the
      --                definition ID passed to us.
      --
      --
      -- Parameters
      --
      -- IN
      --                p_DS_IO_Def_ID IN DEF_IODD_DEF_ID%TYPE
      --                   -  The definition ID to translate to a group name/folder tuple.
      --
      -- OUT
      --                p_Dataset_Group_Name OUT DEF_OBJECT_NAME%TYPE
      --                   -  the group name found.
      --                p_Dataset_Group_Folder_Name OUT DEF_FOLDER_NAME%TYPE) IS
      --                   -  the folder name where the group name is stored.
      --
      -- Returns
      --
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      OPEN getIODDNameandFolder;
      FETCH getIODDNameandFolder INTO
         l_IODD_Name
         ,l_Folder_Name;
      CLOSE getIODDNameandFolder;

      p_Dataset_Group_Name := l_IODD_Name;
      p_Dataset_Group_Folder_Name := l_Folder_Name;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
   End GetDatasetGroupNameandFolder;

   Function GetDimensionGroupName(p_Dim_Group_ID IN NUMBER) RETURN VARCHAR2 IS
      cursor getName is
         select
               Dimension_Group_Name
            from
               Fem_Dimension_Grps_Vl
            where Dimension_Group_ID = p_Dim_Group_ID;

      l_Dim_Grp_Name DEF_DIM_GRP_NAME%TYPE;

                                                --           1         2
                                                --  1234567890123456789012345
      l_api_name        CONSTANT VARCHAR2(30)   := 'GetDatasetName';
      l_module_name     VARCHAR2(75)            := G_MODULE_NAME || l_api_name;
   Begin
      -- *******************************************************************************************
      -- name          GetDimensionGroupName
      -- Function      retrieve the dimension group name based on the
      --                dimension group ID passed to us.
      --
      --
      -- Parameters
      --
      -- IN
      --                p_Dim_Group_ID IN NUMBER
      --                   -  The dimension group ID to translate to a group name
      --
      -- OUT
      --
      -- Returns
      --                The group name.
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      OPEN getName;
      Fetch getName into l_Dim_Grp_Name;
      CLOSE getName;


      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      RETURN l_Dim_Grp_Name;

      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);

   End GetDimensionGroupName;

   Function GetDatasetName(p_Dataset_Code IN NUMBER) RETURN VARCHAR2 IS
      cursor getName is
         select
               Dataset_Name
            from
               Fem_Datasets_Vl
            where Dataset_Code = p_Dataset_Code;

      l_Dataset_Name DEF_DATASET_NAME%TYPE;

                                                --           1         2
                                                --  1234567890123456789012345
      l_api_name        CONSTANT VARCHAR2(30)   := 'GetDatasetName';
      l_module_name     VARCHAR2(75)            := G_MODULE_NAME || l_api_name;
   Begin
      -- *******************************************************************************************
      -- name          GetDatasetName
      -- Function      retrieve the data set name based on the
      --                data set code passed to us.
      --
      --
      -- Parameters
      --
      -- IN
      --                p_Dataset_Code IN NUMBER
      --                   -  The data set code to translate to a data set name
      --
      -- OUT
      --
      -- Returns
      --                The data set name.
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      OPEN getName;
      Fetch getName into l_Dataset_Name;
      CLOSE getName;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      RETURN l_Dataset_Name;

      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
   End GetDatasetName;

   Function GetCalPeriodName(p_Cal_Period_ID IN NUMBER) RETURN VARCHAR2 IS
      cursor getName is
         select
               Cal_Period_Name
            from
               Fem_Cal_Periods_Vl
            where cal_Period_id = p_Cal_Period_ID;

      l_Cal_Period_Name DEF_CAL_PERIOD_NAME%TYPE;

                                                --           1         2
                                                --  1234567890123456789012345
      l_api_name        CONSTANT VARCHAR2(30)   := 'GetCalPeriodName';
      l_module_name     VARCHAR2(75)            := G_MODULE_NAME || l_api_name;

   Begin
      -- *******************************************************************************************
      -- name          GetCalPeriodName
      -- Function      retrieve the calendar period name based on the
      --                calendar period id passed to us.
      --
      --
      -- Parameters
      --
      -- IN
      --                p_Cal_Period_ID IN NUMBER
      --                   -  The calendar period id to translate to a calendar period name
      --
      -- OUT
      --
      -- Returns
      --                The calendar period name.
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      OPEN getName;
      Fetch getName into l_Cal_Period_Name;
      CLOSE getName;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      RETURN l_Cal_Period_Name;

      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);

   End GetCalPeriodName;

   Procedure Log_Missing_Entries(p_DS_IO_Def_ID IN NUMBER) IS
      l_Dataset_Group_Name DEF_OBJECT_NAME%TYPE;
      l_Dataset_Group_Folder_Name DEF_FOLDER_NAME%TYPE;

                                                --           1         2
                                                --  1234567890123456789012345
      l_api_name        CONSTANT VARCHAR2(30)   := 'Log_Missing_Entries';
      l_module_name     VARCHAR2(75)            := G_MODULE_NAME || l_api_name;

   Begin
      -- *******************************************************************************************
      -- name          Log_Missing_Entries
      -- Function      Generate a report of all duplicate entries  and
      --                all entries that are relative that are missing  effective calendar periods.
      --
      -- Parameters
      --
      -- IN
      --                p_DS_IO_Def_ID IN NUMBER
      --                   -  The data set group Definition ID for the report..
      --
      -- OUT
      --
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      /*--Get Dataset Group Name and Folder Name--*/
      GetDatasetGroupNameandFolder
            (p_DS_IO_Def_ID => p_DS_IO_Def_ID
             ,p_Dataset_Group_Name => l_Dataset_Group_Name
             ,p_Dataset_Group_Folder_Name => l_Dataset_Group_Folder_Name);

      fnd_file.put_line(FND_FILE.OUTPUT,'Dataset Group : '||l_Dataset_Group_Name);
      fnd_file.put_line(FND_FILE.OUTPUT,'Dataset Group Folder : '||l_Dataset_Group_Folder_Name);

      /*----Log Duplicate Entries-----*/
      fnd_file.put_line(FND_FILE.OUTPUT,'Duplicate Entries');
      fnd_file.put_line(FND_FILE.OUTPUT,'-----------------');
      fnd_file.put_line(FND_FILE.OUTPUT,
                           RPAD('Input Dataset',40,' ')
                        || RPAD('Absolute Period',40,' ')
                        || RPAD('Relative Dimension Group',50,' ')
                        || RPAD('Relative Offset',5,' ')
                        || RPAD('Effective Period',40,' ')
                       );
      fnd_file.put_line(FND_FILE.OUTPUT,
                           RPAD('-------------',40,' ')
                        || RPAD('---------------',40,' ')
                        || RPAD('------------------------',50,' ')
                        || RPAD('---------------',5,' ')
                        || RPAD('----------------',40,' ')
                       );
      For i in 0..z_Dup_Entries_Ctr-1 LOOP
         fnd_file.put_line(FND_FILE.OUTPUT,
                              RPAD(z_Dup_Entries_Tab(i).Input_Dataset_Name,40,' ')
                           || RPAD(z_Dup_Entries_Tab(i).Abs_Cal_Period_Name,40,' ')
                           || RPAD(z_Dup_Entries_Tab(i).Relative_Dim_Grp_Name,50,' ')
                           || RPAD(z_Dup_Entries_Tab(i).Relative_Cal_Period_Offset,5,' ')
                           || RPAD(z_Dup_Entries_Tab(i).Eff_Cal_Period_Name,40,' ')
                          );
      End LOOP;


      ---Log entries that are relative and
      ---did not have an Effective Cal Period

      fnd_file.put_line(FND_FILE.OUTPUT,'Entries with no Effective Cal Period');
      fnd_file.put_line(FND_FILE.OUTPUT,'------------------------------------');
      fnd_file.put_line(FND_FILE.OUTPUT,
                           RPAD('Input Dataset',40,' ')
                        || RPAD('Relative Dimension Group',50,' ')
                        || RPAD('Relative Offset',5,' ')
                       );
      fnd_file.put_line(FND_FILE.OUTPUT,
                           RPAD('-------------',40,' ')
                        || RPAD('------------------------',50,' ')
                        || RPAD('---------------',5,' ')
                       );
      For i in 0..z_No_Eff_Cal_Entries_Ctr-1 LOOP
         fnd_file.put_line(FND_FILE.OUTPUT,
                              RPAD(z_No_Eff_Cal_Entries_Tab(i).Input_Dataset_Name,40,' ')
                           || RPAD(z_No_Eff_Cal_Entries_Tab(i).Relative_Dim_Grp_Name,50,' ')
                           || RPAD(z_No_Eff_Cal_Entries_Tab(i).Relative_Cal_Period_Offset,5,' ')
                          );
      End LOOP;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);

   End Log_Missing_Entries;

   Procedure Populate_WhereClause_List( p_DS_IO_Def_ID IN NUMBER
                                       ,p_Output_Period_ID IN NUMBER
                                       ,p_Ledger_ID IN NUMBER
                                       ,p_List_B IN OUT NOCOPY List_B
                                       ,p_List_B_Ctr IN OUT NOCOPY  BINARY_INTEGER
                                       ,p_output_ds_code IN NUMBER                  )  IS
      cursor get_Input_List is
         Select
               a.INPUT_DATASET_CODE
               ,b.DATASET_NAME
               ,a.ABSOLUTE_CAL_PERIOD_FLAG
               ,a.ABSOLUTE_CAL_PERIOD_ID
               ,c.CAL_PERIOD_NAME
               ,a.RELATIVE_DIMENSION_GROUP_ID
               ,d.dimension_group_name
               ,a.RELATIVE_CAL_PERIOD_OFFSET
            from
                FEM_DS_INPUT_LISTS a
               ,FEM_DATASETS_VL b
               ,FEM_CAL_PERIODS_TL c
               ,FEM_DIMENSION_GRPS_TL d
            where
                   a.DATASET_IO_OBJ_DEF_ID = p_DS_IO_Def_ID
               and a.INPUT_DATASET_CODE = b.DATASET_CODE
               and a.ABSOLUTE_CAL_PERIOD_ID= c.CAL_PERIOD_ID(+)
               and c.language(+) = USERENV('LANG')
               and a.relative_dimension_group_id = d.dimension_group_id(+)
               and d.language(+) = USERENV('LANG');

      l_Input_Dataset_Code       DEF_DATASET_CODE%TYPE;
      l_Input_Dataset_Name       DEF_DATASET_NAME%TYPE;
      l_Absolute_Cal_Period_Flag DEF_ABS_CAL_PERIOD_FLAG%TYPE;
      l_Absolute_Cal_Period_ID   DEF_CAL_PERIOD_ID%TYPE;
      l_Absolute_Cal_Period_Name DEF_CAL_PERIOD_NAME%TYPE;
      l_Rel_Dimension_Group_ID   DEF_DIM_GRP_ID%TYPE;
      l_Rel_Dimension_Group_Name DEF_DIM_GRP_NAME%TYPE;
      l_Rel_Cal_Period_Offset    DEF_REL_CAL_PERIOD_OFFSET%TYPE;

      l_Effective_Cal_Period_ID  DEF_CAL_PERIOD_ID%TYPE;
      l_Effective_Cal_Period_Name DEF_CAL_PERIOD_NAME%TYPE;
      l_TEMP NUMBER;
      x_Err_Code NUMBER;

      l_return_status           VARCHAR2(10);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2(4000);

                                                --           1         2
                                                --  1234567890123456789012345
      l_api_name        CONSTANT VARCHAR2(30)   := 'Populate_WhereClause_List';
      l_module_name     VARCHAR2(75)            := G_MODULE_NAME || l_api_name;

   Begin
      -- *******************************************************************************************
      -- name          Populate_WhereClause_List
      -- Function      As it states, populate the where clause with all appropriate predicates.
      --
      --
      -- Parameters
      -- IN
      --                p_DS_IO_Def_ID IN NUMBER
      --                   -
      --                p_Output_Period_ID IN NUMBER
      --                   -
      --                p_Ledger_ID IN NUMBER
      --                   -
      --
      -- OUT
      --                x_Err_Code OUT NUMBER
      --                   -
      --                x_Err_Msg OUT VARCHAR2
      --                   -
      --
      -- IN OUT
      --                p_List_B IN OUT NOCOPY List_B
      --                   -
      --                p_List_B_Ctr IN OUT NOCOPY  BINARY_INTEGER
      --                   -
      --
      -- Returns
      -- HISTORY
      --    09-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      ------------------------------------------------
      ------------------------------------------------
      -- add the output_ds/cal_period tuple first..
      ------------------------------------------------
      ------------------------------------------------
      If No_Entry_For_IDS_ECP(p_output_ds_code
                              ,p_Output_Period_ID
                              ,p_List_B
                              ,p_List_B_Ctr              ) then

         -- add it.
         Add_IDS_ECP_Entry_To_List_B(  p_output_ds_code
                                       ,p_Output_Period_ID
                                       ,p_List_B
                                       ,p_List_B_Ctr);

      END IF;
      ------------------------------------------------
      ------------------------------------------------
      -- now add all the input list tuples..
      ------------------------------------------------
      ------------------------------------------------
      OPEN get_Input_List;
      LOOP
         FETCH get_Input_List INTO
            l_Input_Dataset_Code
            ,l_Input_Dataset_Name
            ,l_Absolute_Cal_Period_Flag
            ,l_Absolute_Cal_Period_ID
            ,l_Absolute_Cal_Period_Name
            ,l_Rel_Dimension_Group_ID
            ,l_Rel_Dimension_Group_Name
            ,l_Rel_Cal_Period_Offset;

         EXIT WHEN get_Input_List%NOTFOUND;

         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> '========loop execution==============');

         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Input_Dataset_Code(' || l_Input_Dataset_Code || ')');

         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Input_Dataset_Name(' || l_Input_Dataset_Name || ')');
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Absolute_Cal_Period_Flag(' || l_Absolute_Cal_Period_Flag || ')');
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Absolute_Cal_Period_ID(' || l_Absolute_Cal_Period_ID || ')');
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Absolute_Cal_Period_Name(' || l_Absolute_Cal_Period_Name || ')');
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Rel_Dimension_Group_ID(' || l_Rel_Dimension_Group_ID || ')');
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Rel_Dimension_Group_Name(' || l_Rel_Dimension_Group_Name || ')');
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Rel_Cal_Period_Offset(' || l_Rel_Cal_Period_Offset || ')');


         If (l_Absolute_Cal_Period_Flag = 'Y') then
            l_Effective_Cal_Period_ID := l_Absolute_Cal_Period_ID;
         Else
            fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                         p_module=> l_module_name,
                                         p_msg_text=> 'before fem_dimension_util_pkg.Effective_Cal_Period_ID');
            fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                         p_module=> l_module_name,
                                         p_msg_text=> 'p_Ledger_ID(' || p_Ledger_ID || ')');
            fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                         p_module=> l_module_name,
                                         p_msg_text=> 'p_Output_Period_ID(' || p_Output_Period_ID || ')');

            l_Effective_Cal_Period_ID :=
               fem_dimension_util_pkg.Relative_Cal_Period_ID (
                  p_api_version        =>  1.0                       ,
                  x_return_status      =>  l_return_status           ,
                  x_msg_count          =>  l_msg_count               ,
                  x_msg_data           =>  l_msg_data                ,
                  p_per_num_offset     =>  l_Rel_Cal_Period_Offset   ,
                  p_base_cal_period_id =>  p_Output_Period_ID);

            fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                         p_module=> l_module_name,
                                         p_msg_text=> 'l_Effective_Cal_Period_ID(' || l_Effective_Cal_Period_ID || ')');


            If (l_Effective_Cal_Period_ID = -1) then
               -- we couldn't find an effective cal period ID for the relative..
               Add_Missing_Entries
                  (p_Input_Dataset_Name => l_Input_Dataset_Name
                   ,p_Abs_Cal_Period_Flag => l_Absolute_Cal_Period_Flag
                   ,p_Abs_Cal_Period_Name => l_Absolute_Cal_Period_Name
                   ,p_Rel_Dim_Grp_Name => l_Rel_Dimension_Group_Name
                   ,p_Rel_Cal_Period_Offset => l_Rel_Cal_Period_Offset
                   ,p_Eff_Cal_Period_Name => 'No Eff Cal Period Found'
                   ,p_Missing_Entry_Type => 'NO_EFF_CAL_PER'
                   );

               FEM_UTILS.set_master_err_state( z_master_err_state,
                                                   FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                   G_APP_NAME,
                                                   G_NO_EFFECTIVE_CAL_PERIOD );
               -- The following offset information in the Dataset Input List doesn't
               -- resolve to an Effective Input Calendar Period
               --
               -- Dataset Group                  p_DS_IO_Def_ID
               -- Reference Period               p_Output_Period_ID
               -- Input Dataset                  l_Input_Dataset_Code
               -- Relative Dimension Group ID    l_Rel_Dimension_Group_ID
               -- Relative Cal Period Offset     l_Rel_Cal_Period_Offset

            End If; -- (l_Effective_Cal_Period_ID = -1)
         End If; -- (l_Absolute_Cal_Period_Flag = 'Y')

         If (        (l_Effective_Cal_Period_ID IS NOT NULL )
               AND   (l_Effective_Cal_Period_ID <> -1       )  ) then
            -- seems valid. so if it hasn't been added to p_List_B...
            If No_Entry_For_IDS_ECP(l_Input_Dataset_Code
                                    ,l_Effective_Cal_Period_ID
                                    ,p_List_B
                                    ,p_List_B_Ctr              ) then

               -- add it.
               Add_IDS_ECP_Entry_To_List_B(  l_Input_Dataset_Code
                                             ,l_Effective_Cal_Period_ID
                                             ,p_List_B
                                             ,p_List_B_Ctr);

               -- If ((l_Pft_Eng_Write_Flg = 1) and (p_Chaining_Enabled = 'Y')) then
               null;
               -- End If;
            Else
               -- otherwise show it as a duplicate entry..
               l_Effective_Cal_Period_Name
                  := GetCalPeriodName (p_Cal_Period_ID => l_Effective_Cal_Period_ID);

               Add_Missing_Entries( p_Input_Dataset_Name => l_Input_Dataset_Name
                                    ,p_Abs_Cal_Period_Flag => l_Absolute_Cal_Period_Flag
                                    ,p_Abs_Cal_Period_Name => l_Absolute_Cal_Period_Name
                                    ,p_Rel_Dim_Grp_Name => l_Rel_Dimension_Group_Name
                                    ,p_Rel_Cal_Period_Offset => l_Rel_Cal_Period_Offset
                                    ,p_Eff_Cal_Period_Name => l_Effective_Cal_Period_Name
                                    ,p_Missing_Entry_Type => 'DUP_ENTRY' );

               FEM_UTILS.set_master_err_state( z_master_err_state,
                                                   FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                   G_APP_NAME,
                                                   G_DUPLICATE_INPUT_LIST_ENTRY,
                                                   G_MACRO_DATASET,
                                                   l_Input_Dataset_Name,
                                                   NULL,
                                                   G_MACRO_EFF_CAL_PERIOD,
                                                   l_Effective_Cal_Period_Name);
               -- Dataset Group                     p_DS_IO_Def_ID
               -- Reference Period                  p_Output_Period_ID
               --   Input Dataset                   l_Input_Dataset_Code
               --   Absolute Cal Period Flag        l_Absolute_Cal_Period_Flag
               --      Absolute Cal Period          l_Absolute_Cal_Period_ID
               --      Relative Dimension Group ID  l_Rel_Dimension_Group_ID
               --      Relative Cal Period Offset   l_Rel_Cal_Period_Offset
               --      Effective Cal Period         l_Effective_Cal_Period_ID

            End If;

         End If;

      END LOOP;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      EXCEPTION
         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);


   End Populate_WhereClause_List;


   PROCEDURE FEM_GetOutputDS_PVT(p_api_version                 IN             NUMBER
                                ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                                ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                                ,x_return_status               OUT   NOCOPY   VARCHAR2
                                ,x_msg_count                   OUT   NOCOPY   NUMBER
                                ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                                ,p_DSGroup_Def_ID              IN             NUMBER
                                ,x_Output_DS_ID                OUT   NOCOPY   NUMBER
                                ,p_pop_messages_at_exit        IN             VARCHAR2 := FND_API.G_TRUE)
   IS
      l_api_version     NUMBER := 1.0;
      l_api_name        CONSTANT VARCHAR2(30)   := 'FEM_GetOutputDS_PVT';
      l_module_name     VARCHAR2(70)            := G_MODULE_NAME || l_api_name;

      cursor GetOutputDS is
         Select
            a.output_dataset_code
         from
            fem_ds_input_output_defs a
         where
            a.DATASET_IO_OBJ_DEF_ID = p_DSGroup_Def_ID;

   BEGIN
      -- *******************************************************************************************
      -- API name     FEM_GetOutputDS_PVT
      -- Type         Private
      -- Pre-reqs     None
      -- Function      1) convert a rule set into a flat structure prior to engine processing
      --                2) Report all errors that occur during the conversion that are not
      --                   covered by the UI validation routines
      --
      --
      -- Parameters
      -- IN
      --                p_api_version                 IN    NUMBER
      --                      Current version of this API
      --                p_init_msg_list               IN    VARCHAR2 := FND_API.G_FALSE
      --                      If set to
      --                         FND_API.G_TRUE    - Initialize FND_MSG_PUB
      --                         FND_API.G_FALSE   - DO NOT Initialize FND_MSG_PUB
      --                p_encoded                     IN    VARCHAR2 := FND_API.G_TRUE
      --                      If set to
      --                         FND_API.G_TRUE    - return error messages in encoded format
      --                         FND_API.G_FALSE   - return error messages in non-encoded (natural language) format

      --                p_DSGroup_Def_ID IN NUMBER
      --                   -  dataset group's object_definition_id
      --                x_Output_DS_ID OUT NOCOPY NUMBER
      --                   -  the output dataset in use by the p_DSGroup_Def_ID
      --
      -- OUT
      --                x_return_status               OUT   VARCHAR2
      --                      Possible return status
      --                         FND_API.G_RET_STS_SUCCESS        -  Call was successful, msgs may
      --                                                             still be present (check x_msg_count)
      --                         FND_API.G_RET_STS_ERROR          -  Call was not successful, msgs should
      --                                                             be present (check x_msg_count)
      --                         FND_API.G_RET_STS_UNEXP_ERROR    -  Unexpected errors occurred which are
      --                                                             unrecoverable (check x_msg_count)
      --
      --                x_msg_count                   OUT   NUMBER
      --                      Count of messages returned.  If x_msg_count = 1, then the message is returned
      --                      in x_msg_data.  If x_msg_count > 1, then messages are returned via FND_MSG_PUB.
      --
      --                x_msg_data                    OUT   VARCHAR2
      --                      Error message returned.
      --
      -- Version Current Version   1.0
      --
      --                            Previous version  N/A
      --                            Initial version   1.0
      -- *******************************************************************************************

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      reset_master_err_state;

      -- initialize our status to 'we are good!'
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- initialize msg stack?
      IF fnd_api.to_Boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      -- check API version...
      IF NOT fnd_api.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      OPEN GetOutputDS;
      FETCH GetOutputDS INTO
            x_Output_DS_ID;

      IF  GetOutputDS%NOTFOUND THEN
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                         FEM_UTILS.G_RSM_FATAL_ERR,
                                         G_APP_NAME,
                                         G_ERRMSG_NO_ODS_FOR_DSG );
         -- this one and only error is utterly fatal if we get it (no output ds!!!)
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         CLOSE GetOutputDS;
      END IF;

      IF fnd_api.to_Boolean(p_pop_messages_at_exit) THEN
         FND_MSG_PUB.Count_And_Get ( p_encoded,
                                     x_msg_count,
                                     x_msg_data );
      END IF;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');


      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            IF fnd_api.to_Boolean(p_pop_messages_at_exit) THEN
               FND_MSG_PUB.Count_And_Get ( p_encoded,
                                           x_msg_count,
                                           x_msg_data );
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;


         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF fnd_api.to_Boolean(p_pop_messages_at_exit) THEN
               FND_MSG_PUB.Count_And_Get ( p_encoded,
                                           x_msg_count,
                                           x_msg_data );
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         WHEN OTHERS THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);

            IF fnd_api.to_Boolean(p_pop_messages_at_exit) THEN
               FND_MSG_PUB.Count_And_Get ( p_encoded,
                                           x_msg_count,
                                           x_msg_data );
            END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END FEM_GetOutputDS_PVT;



   -- *******************************************************************************************
   -- API name     FEM_Gen_DS_WClause_By_TblNm_PVT
   -- Type         Private
   -- Pre-reqs     None
   -- Function      1) convert a rule set into a flat structure prior to engine processing
   --                2) Report all errors that occur during the conversion that are not
   --                   covered by the UI validation routines
   --
   --
   -- Parameters
   -- IN
   --                p_api_version                 IN    NUMBER
   --                      Current version of this API
   --                p_init_msg_list               IN    VARCHAR2 := FND_API.G_FALSE
   --                      If set to
   --                         FND_API.G_TRUE    - Initialize FND_MSG_PUB
   --                         FND_API.G_FALSE   - DO NOT Initialize FND_MSG_PUB
   --                p_encoded                     IN    VARCHAR2 := FND_API.G_TRUE
   --                      If set to
   --                         FND_API.G_TRUE    - return error messages in encoded format
   --                         FND_API.G_FALSE   - return error messages in non-encoded (natural language) format

   --                p_DS_IO_Def_ID IN NUMBER
   --                   -  dataset group's object_definition_id
   --                p_Output_Period_ID OUT NUMBER
   --                   -  period we are using for all relative references.
   --                p_Table_Alias IN VARCHAR2 DEFAULT NULL
   --                   -  table alias to use for 'p_Table_Name'
   --                p_Table_Name IN VARCHAR2
   --                   -  table name where data is coming from.
   --                p_Ledger_ID IN NUMBER DEFAULT NULL
   --                   -  the ledger_id that is being processed.
   --
   --
   -- OUT
   --                x_return_status               OUT   VARCHAR2
   --                      Possible return status
   --                         FND_API.G_RET_STS_SUCCESS        -  Call was successful, msgs may
   --                                                             still be present (check x_msg_count)
   --                         FND_API.G_RET_STS_ERROR          -  Call was not successful, msgs should
   --                                                             be present (check x_msg_count)
   --                         FND_API.G_RET_STS_UNEXP_ERROR    -  Unexpected errors occurred which are
   --                                                             unrecoverable (check x_msg_count)
   --
   --                x_msg_count                   OUT   NUMBER
   --                      Count of messages returned.  If x_msg_count = 1, then the message is returned
   --                      in x_msg_data.  If x_msg_count > 1, then messages are returned via FND_MSG_PUB.
   --
   --                x_msg_data                    OUT   VARCHAR2
   --                      Error message returned.
   --
   -- Version Current Version   1.0
   --
   --                            Previous version  N/A
   --                            Initial version   1.0
   -- *******************************************************************************************
   PROCEDURE FEM_Gen_DS_WClause_PVT(
                                 p_api_version                 IN             NUMBER
                                ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                                ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                                ,x_return_status               OUT   NOCOPY   VARCHAR2
                                ,x_msg_count                   OUT   NOCOPY   NUMBER
                                ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                                ,p_DS_IO_Def_ID                IN             NUMBER
                                ,p_Output_Period_ID            IN             NUMBER
                                ,p_Table_Alias                 IN             VARCHAR2 DEFAULT NULL
                                ,p_Table_Name                  IN             VARCHAR2
                                ,p_Ledger_ID                   IN             NUMBER DEFAULT NULL
                                ,p_where_clause                OUT   NOCOPY   LONG
                                ) IS

            -- STANDARD STUFF
      l_api_version     NUMBER := 1.0;
      l_api_name        CONSTANT VARCHAR2(30)   := 'FEM_Gen_DS_WClause_PVT';
      l_module_name     VARCHAR2(70)            := G_MODULE_NAME || l_api_name;
      l_output_ds_code  NUMBER := 0;

      p_List_B          List_B;  -- List used to keep track of Dataset_Code and Cal_Period_Combinations
                                 -- that have been already added to the whereclause

      p_List_B_Ctr      BINARY_INTEGER := 0;
      X_WhereClause     LONG := NULL;

      l_return_status               VARCHAR2(20);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2(2000);

   BEGIN
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      reset_master_err_state;

      -- initialize our status to 'we are good!'
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- initialize msg stack?
      IF fnd_api.to_Boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      -- check API version...
      IF NOT fnd_api.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- ===============================================================
      -- =========imported from first version call======================
      -- ===============================================================

      /*---Reinitialize Global PLSQL tables------------*/
      z_No_Eff_Cal_Entries_Tab.DELETE;
      z_No_Eff_Cal_Entries_Ctr := 0;

      z_Dup_Entries_Tab.DELETE;
      z_Dup_Entries_Ctr := 0;
      /*-----------------------------------------------*/

      FEM_GetOutputDS_PVT( p_api_version           => 1.0
                          ,p_init_msg_list         => FND_API.G_FALSE
                          ,p_encoded               => p_encoded
                          ,x_return_status         => l_return_status
                          ,x_msg_count             => l_msg_count
                          ,x_msg_data              => l_msg_data
                          ,p_DSGroup_Def_ID        => p_DS_IO_Def_ID
                          ,x_Output_DS_ID          => l_output_ds_code
                          ,p_pop_messages_at_exit  => FND_API.G_FALSE  );

      IF l_return_status =  FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      If (p_Ledger_Id is NULL) then
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_LEDGER_REQD_FOR_LEDG_TABS );
      ELSE


         Populate_WhereClause_List( p_DS_IO_Def_ID
                                    ,p_Output_Period_ID
                                    ,p_Ledger_ID
                                    ,p_List_B
                                    ,p_List_B_Ctr
                                    ,l_output_ds_code
                                    );


         Begin
            For i in 0 ..p_List_B_Ctr LOOP
               If (p_Table_Alias is NOT NULL) then
                  X_WhereClause :=
                     X_WhereClause
                        || '('
                        || '('||p_Table_Alias||'.DATASET_CODE ='||p_List_B(i).X_Dataset_Code||')'
                        || 'and'
                        || '('||p_Table_Alias||'.CAL_PERIOD_ID ='||p_List_B(i).X_Cal_Period_ID||')'
                        || ') OR';
               Else
                  X_WhereClause :=
                     X_WhereClause
                        || '('
                        || '(DATASET_CODE ='||p_List_B(i).X_Dataset_Code||')'
                        || 'and'
                        || '(CAL_PERIOD_ID ='|| p_List_B(i).X_Cal_Period_ID||')'
                        || ') OR';
               End If;

            End LOOP;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
         End;

         Begin
            x_WhereClause := '('||rtrim(x_WhereClause,'OR')||')';
         End;
      End If; --(p_Ledger_Id is NULL)

      Log_Missing_Entries(p_DS_IO_Def_ID => p_DS_IO_Def_ID);

      -- ===============================================================
      -- =========end of imported from first version call===============
      -- ===============================================================



      p_where_clause := x_WhereClause;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');


      IF (z_master_err_state = FEM_UTILS.G_RSM_FATAL_ERR) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FND_MSG_PUB.Count_And_Get ( p_encoded,
                                  x_msg_count,
                                  x_msg_data );
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         FND_MSG_PUB.Count_And_Get ( p_encoded,
                                     x_msg_count,
                                     x_msg_data );
         x_return_status := FND_API.G_RET_STS_ERROR;


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         FND_MSG_PUB.Count_And_Get ( p_encoded,
                                     x_msg_count,
                                     x_msg_data );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_FATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_UNEXPECTED_SQLERROR,
                                             G_ERRMAC_ROUTINE_NAME,
                                             l_module_name,
                                             NULL,
                                             G_ERRMAC_SQL_ERROR,
                                             SQLERRM);

         FND_MSG_PUB.Count_And_Get ( p_encoded,
                                     x_msg_count,
                                     x_msg_data );

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


   END FEM_Gen_DS_WClause_PVT;



End FEM_DS_WHERE_CLAUSE_GENERATOR;
--End FEM_DS_WHERE_CLAUSE_G_RJK;

/
