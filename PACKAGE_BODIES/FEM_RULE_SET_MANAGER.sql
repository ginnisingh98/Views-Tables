--------------------------------------------------------
--  DDL for Package Body FEM_RULE_SET_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_RULE_SET_MANAGER" AS
--$Header: FEMRSMANB.pls 120.5.12010000.3 2008/12/18 22:56:06 huli ship $

   z_global_counter        NUMBER := 0;
   z_conc_request_id       NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   z_user_id               NUMBER := FND_GLOBAL.USER_ID;
   z_login_id              NUMBER := FND_GLOBAL.LOGIN_ID;
   z_local_vs_for_session  NUMBER ;
   z_Err_Code              NUMBER := NULL;
   z_Err_Msg               VARCHAR2(30) := NULL;
   z_continue_on_error     BOOLEAN := TRUE;
   z_dataset_error         BOOLEAN := FALSE;

   g_max_rule_set_depth NUMBER := FND_PROFILE.VALUE('FEM_RULE_SET_DEPTH');

   --   TECH MESSAGE FORMAT (debugging oriented)
   --   procedure/function definition for I/F
   --   l_module_name VARCHAR2(70) := G_MODULE_NAME || 'Mem_Obj_Prev_Processed';
   --   fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
   --                                p_module=> l_module_name,
   --                                p_msg_text=> 'something happened here msg');
   --   fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
   --                                p_module=> l_module_name,
   --                                p_msg_text=> 'something happened here msg');
   G_LOG_STATEMENT   CONSTANT NUMBER := fnd_log.level_statement;
   G_LOG_PROCEDURE   CONSTANT NUMBER := fnd_log.level_procedure;
   G_LOG_EVENT       CONSTANT NUMBER := fnd_log.level_event;
   G_LOG_EXCEPTION   CONSTANT NUMBER := fnd_log.level_exception;
   G_LOG_ERROR       CONSTANT NUMBER := fnd_log.level_error;
   G_LOG_UNEXPECTED  CONSTANT NUMBER := fnd_log.level_unexpected;
   --                                          000000000111111111122222222223333333333444444444455555555556
   --                                          123456789012345678901234567890123456789012345678901234567890
   G_APP_NAME        CONSTANT VARCHAR2(4)  := 'FEM';
   G_PKG_NAME        CONSTANT VARCHAR2(25) := 'fem_rule_set_manager';
   G_MODULE_NAME     CONSTANT VARCHAR2(40) := 'fem.plsql.' || G_PKG_NAME  ||  '.';

   z_master_err_state      NUMBER          := FEM_UTILS.G_RSM_NO_ERR;



   -- error messages and their macro replacement strings
   --                                                         000000000111111111122222222223333333333444444444455555555556
   --                                                         123456789012345678901234567890123456789012345678901234567890
   G_FEMRSM_NOVALID_DEP_DEF         CONSTANT VARCHAR2(40) := 'FEM_RSM_NOVALID_DEP_DEFINITION';
   G_ERRMSG_NO_VALID_DEFINITION     CONSTANT varchar2(40) := 'FEM_RSM_NO_VALID_DEFINITION';
   G_ERRMSG_UNEXPECTED_SQLERROR     CONSTANT varchar2(40) := 'FEM_RSM_UNEXPECTED_SQLERROR';
   G_ERRMSG_DUP_RULE_OCC            CONSTANT varchar2(40) := 'FEM_RSM_DUP_RULE_OCC';
   G_ERRMSG_DUPLICATE_OCCURRENCE    CONSTANT varchar2(40) := 'FEM_RSM_DUPLICATE_OCCURRENCE';
   G_ERRMSG_DEPTH_CHECK_FAILURE     CONSTANT varchar2(40) := 'FEM_RSM_DEPTH_CHECK_FAILURE';
   G_ERRMSG_NO_VALID_VALSETS        CONSTANT varchar2(40) := 'FEM_RSM_NO_VALID_VALSETS';
   G_ERRMSG_DEFN_NOT_APPROVED       CONSTANT varchar2(40) := 'FEM_RSM_DEFN_NOT_APPROVED';
   G_ERRMSG_DSGRP_NOT_FOUND         CONSTANT varchar2(40) := 'FEM_RSM_DATASETGROUP_NOT_FOUND';
   G_ERRMSG_NO_DSG_FOR_LID          CONSTANT varchar2(40) := 'FEM_RSM_NO_DSG_FOR_LID';
   G_ERRMSG_NO_ODS                  CONSTANT varchar2(40) := 'FEM_RSM_NO_ODS';
   G_ERRMSG_NO_ODSPRODFLAG          CONSTANT varchar2(40) := 'FEM_RSM_NO_PRODFLAG_FOR_ODS';
   G_ERRMSG_INVALID_ODS_PRODFLAG    CONSTANT varchar2(40) := 'FEM_RSM_INVALID_ODS_PRODFLAG';

   G_ERRMAC_ROUTINE_NAME            CONSTANT varchar2(40) := 'ROUTINE_NAME';
   G_ERRMAC_SQL_ERROR               CONSTANT varchar2(40) := 'SQL_ERROR';
   G_ERRMAC_RULE_SET                CONSTANT varchar2(40) := 'RULE_SET';
   G_ERRMAC_RULE_NAME               CONSTANT varchar2(40) := 'RULE_NAME';
   G_ERRMAC_DUP_RS                  CONSTANT varchar2(40) := 'DUP_RS';
   G_ERRMAC_CONTAIN_RS              CONSTANT varchar2(40) := 'CONTAIN_RS';
   G_ERRMAC_VALUE                   CONSTANT varchar2(40) := 'VALUE';


   Function getProcedureVersionFromDB RETURN VARCHAR2
      IS
      l_revString       VARCHAR2(100);
      l_start_of_string NUMBER;
      l_charcount       NUMBER;

   Begin
      -- return the current version of this file...
      l_revString := '$Revision: 120.5.12010000.3 $';
      l_start_of_string := instr(l_revString,':') + 1;
      l_charcount := instr(l_revString,'$',-1) - l_start_of_string;

      RETURN substr(l_revString,l_start_of_string,l_charcount);

   End getProcedureVersionFromDB;


   Procedure Get_ValidDefinition_Priv(p_Object_ID IN DEF_OBJECT_ID%TYPE
                                     ,p_Rule_Effective_Date IN DATE
                                     ,x_Object_Definition_ID OUT NOCOPY DEF_OBJECT_DEFINITION_ID%TYPE
                                     ,x_Approval_Status_Code OUT NOCOPY DEF_APPROVAL_STATUS_CODE%TYPE
                                     ) IS

      l_Object_Definition_ID DEF_OBJECT_DEFINITION_ID%TYPE;
      l_Approval_Status_Code DEF_APPROVAL_STATUS_CODE%TYPE;
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Get_ValidDefinition_Priv';

   BEGIN
      -- *******************************************************************************************
      -- name        :  Get_ValidDefinition_Priv
      -- Function    :  retrieve a valid object_definition_id using the passed
      --                object_id and effective_date
      -- Parameters
      -- IN
      --                p_Object_ID IN DEF_OBJECT_ID%TYPE
      --                   -  the object_id to convert to an object_definition_id
      --                p_Rule_Effective_Date IN DATE
      --                   -  the effective date to use during the conversion
      --
      --
      -- OUT
      --                x_Object_Definition_ID OUT DEF_OBJECT_DEFINITION_ID%TYPE
      --                   -  set to either a valid object_definition_id, or -1 if none found
      --                x_Approval_Status_Code OUT DEF_APPROVAL_STATUS_CODE%TYPE
      --                   -  set to the value of the same named column in fem_object_definition_vl
      --                      if we found a valid definition, NULL otherwise
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************

      -- retrieve a valid object-definition-id for the passed object-id
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');


      open getValidDefForObject(  p_Object_ID
                                 ,p_Rule_Effective_Date);
      FETCH getValidDefForObject
      INTO
          l_Object_Definition_ID
         ,l_Approval_Status_Code;

      -- return -1 if we didn't find any valid definition for the current
      -- effective date.
      If getValidDefForObject%NOTFOUND then
         x_Object_Definition_ID := -1;
         x_Approval_Status_Code := NULL;
      Else
         x_Object_Definition_ID := l_Object_Definition_ID;
         x_Approval_Status_Code := l_Approval_Status_Code;
      End If;

      CLOSE getValidDefForObject;


      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
   End Get_ValidDefinition_Priv;





   -- *******************************************************************************************
   -- name        :  reset_master_err_state
   -- Function    :  set master_err_state to no error on entry to master API calls.
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



   Function GetObjectDisplayName(p_Obj_ID IN DEF_OBJECT_ID%TYPE) RETURN VARCHAR2 IS

      l_Object_Display_Name DEF_OBJECT_DISPLAY_NAME%TYPE;
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'GetObjectDisplayName';

      Cursor getObjectDisplayName(p_Obj_ID IN DEF_OBJECT_ID%TYPE) IS
         select   o.object_name
            from  fem_object_catalog_vl o
            where o.object_id = p_Obj_ID;

   Begin
      -- *******************************************************************************************
      -- name        :  GetObjectDisplayName
      -- Function    :  lookup the display name for a passed object_id
      -- Parameters
      -- IN
      --                p_Obj_ID
      --                   -  the object_id for the name we are looking up
      --
      -- OUT
      --                none
      --
      -- Return value
      --                the display name for the object.
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                             p_module=> l_module_name,
                             p_msg_text=> 'ENTRY');

      OPEN getObjectDisplayName(p_Obj_ID);
      FETCH getObjectDisplayName
         INTO l_Object_Display_Name;

      -- Bug 6972946: Instead of showing a hard coded string of "Not Valid
      -- Object" (which is a translation issue anyway), we should just
      -- show the actual missing Object ID.
      If getObjectDisplayName%NOTFOUND then
         -- l_Object_Display_Name := '[Not Valid Object]';
         l_Object_Display_Name := '['||p_Obj_ID||']';
      End If;

      CLOSE getObjectDisplayName;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      RETURN l_Object_Display_Name;

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
            RAISE;

   End GetObjectDisplayName;





   Procedure Get_ValidDefinition_Pub(p_Object_ID IN DEF_OBJECT_ID%TYPE
                                    ,p_Rule_Effective_Date IN VARCHAR2
                                    ,x_Object_Definition_ID OUT NOCOPY FEM_OBJECT_DEFINITION_B.OBJECT_DEFINITION_ID%TYPE
                                    ,x_Err_Code OUT NOCOPY NUMBER
                                    ,x_Err_Msg  OUT NOCOPY VARCHAR2) IS
      l_Rule_Effective_Date DATE;
      l_Approval_Status_Code DEF_APPROVAL_STATUS_CODE%TYPE;
      l_module_name VARCHAR2(70) := G_MODULE_NAME || 'Get_ValidDefinition_Pub';

   Begin
      -- *******************************************************************************************
      -- name        :  Get_ValidDefinition_Pub
      -- Function    :  retrieve a valid object_definition_id using the passed
      --                object_id and effective_date
      -- Parameters
      -- IN
      --                p_Object_ID IN DEF_OBJECT_ID%TYPE
      --                   -  the object_id to convert to an object_definition_id
      --                p_Rule_Effective_Date IN DATE
      --                   -  the effective date to use during the conversion
      --
      --
      -- OUT
      --                x_Object_Definition_ID OUT DEF_OBJECT_DEFINITION_ID%TYPE
      --                   -  set to either a valid object_definition_id, or -1 if none found
      --                x_Approval_Status_Code OUT DEF_APPROVAL_STATUS_CODE%TYPE
      --                   -  set to the value of the same named column in fem_object_definition_vl
      --                      if we found a valid definition, NULL otherwise
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************


      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY: p_Object_ID = '||p_Object_ID||'; p_Rule_Effective_Date = '||p_Rule_Effective_Date);

      l_Rule_Effective_Date := FND_DATE.CANONICAL_TO_DATE(p_Rule_Effective_Date);

      Get_ValidDefinition_Priv(p_Object_ID
                              ,l_Rule_Effective_Date
                              ,x_Object_Definition_ID
                              ,l_Approval_Status_Code);

      -- remember, -1 means 'no valid definition'..
      If (x_Object_Definition_ID = -1) then
         -- we had an error.. no valid object_definition for p_Object_ID
         -- error codes maintained right now for backwards compatibility..
         z_Err_Code := 1;
         -- todo:: setup error message here..
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_NO_VALID_DEFINITION ,
                                             G_ERRMAC_RULE_NAME,
                                             GetObjectDisplayName(p_Object_ID));
      Else
         z_Err_Code := 0;
      End If;


      x_Err_Code := z_Err_Code;
      x_Err_Msg  := z_Err_Msg ;

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
            RAISE;

   End Get_ValidDefinition_Pub;


   Function GetErrMsgText(p_Msg_Name IN VARCHAR2
                         ,p_Token_Name IN VARCHAR2 DEFAULT NULL
                         ,p_Token_Value IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
      x_Msg_Text VARCHAR2(2000);
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'GetErrMsgText';
   Begin
      -- *******************************************************************************************
      -- name        :  GetErrMsgText
      -- Function    :  Do simple lookup of message.  Support for one token only
      -- Parameters
      -- IN
      --                p_Msg_Name
      --                   -  Name of message to look up
      --                p_Token_Name
      --                   -  either token name, or NULL if no token
      --                p_Token_Value
      --                   -  value for token.
      --
      -- OUT
      --                none
      --
      -- Return value
      --                set to message text
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                             p_module=> l_module_name,
                             p_msg_text=> 'ENTRY');


      FND_MESSAGE.SET_NAME('FEM',p_Msg_Name);

      If (p_Token_Name IS NOT NULL) then
         FND_MESSAGE.SET_TOKEN(p_Token_Name,p_Token_Value );
      End If;

      x_Msg_Text := FND_MESSAGE.GET();

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      RETURN x_Msg_Text;

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
            RAISE;
   End GetErrMsgText;


   Function GetObjectIDFromDefID(p_Obj_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE) RETURN NUMBER IS
      l_Object_ID DEF_OBJECT_ID%TYPE;
      l_module_name VARCHAR2(70) := G_MODULE_NAME || 'GetObjectIDFromDefID';

      Cursor getObjectID(p_Obj_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE) IS
         SELECT o.object_id
            from   fem_object_catalog_b o
                  ,fem_object_definition_b od
            where       o.object_id = od.object_id
                  and   od.object_definition_id = p_Obj_Def_ID;

   Begin
      -- *******************************************************************************************
      -- name        :  GetObjectIDFromDefID
      -- Function    :  Lookup an object_id from the passed object_definition_id
      -- Parameters
      -- IN
      --                p_Obj_Def_ID
      --                   -  the object_definition_id to lookup
      --
      -- OUT
      --                none
      --
      -- Return value
      --                the object_id_found
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      OPEN getObjectID(p_Obj_Def_ID);
      FETCH getObjectID
         INTO l_Object_ID;
      CLOSE getObjectID;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      RETURN l_Object_ID;

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
            RAISE;
   End GetObjectIDFromDefID;



   Procedure GetObjectDisplayNameandFolder(p_Obj_ID IN DEF_OBJECT_ID%TYPE
                                          ,l_Object_Display_Name OUT NOCOPY DEF_OBJECT_DISPLAY_NAME%TYPE
                                          ,l_Object_Folder_Name  OUT NOCOPY DEF_FOLDER_NAME%TYPE) IS

      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'GetObjectDisplayNameandFolder';

      Cursor getNameAndFolder(p_Obj_ID IN DEF_OBJECT_ID%TYPE) IS
         select    o.object_name
                  ,f.folder_name
            from   fem_object_catalog_vl o
                  ,fem_folders_vl f
            where       o.object_id = p_Obj_ID
                  and   f.folder_id = o.folder_id;

   Begin
      -- *******************************************************************************************
      -- name        :  GetObjectDisplayNameandFolder
      -- Function    :  lookup the display name and folder name
      --                for a passed object_id
      -- Parameters
      -- IN
      --                p_Obj_ID
      --                   -  the object_id for the name we are looking up
      --
      -- OUT
      --                l_Object_Display_Name OUT DEF_OBJECT_DISPLAY_NAME%TYPE
      --                   -  the display name found.
      --                l_Object_Folder_Name  OUT DEF_FOLDER_NAME%TYPE) IS
      --                   -  the folder name found.
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                             p_module=> l_module_name,
                             p_msg_text=> 'ENTRY');

      OPEN getNameAndFolder(p_Obj_ID);
      FETCH getNameAndFolder
          INTO     l_Object_Display_Name
                  ,l_Object_Folder_Name;

      If getNameAndFolder%NOTFOUND then
         l_Object_Display_Name := '[Not Valid Object]';
         l_Object_Folder_Name  := '[*****]';
      End If;

      CLOSE getNameAndFolder;

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
            RAISE;

   End GetObjectDisplayNameandFolder;


   Procedure Pop_Invalid_MmbrFlags_Tbl
                           (p_Member_Flags_Tab IN OUT NOCOPY Members_Validation_Status_Tab
                            ,p_Member_Flags_Count IN OUT NOCOPY BINARY_INTEGER
                            ,p_Folder_Name_Of_Member IN VARCHAR2
                            ,p_Owning_RS_Name_Of_Member IN VARCHAR2
                            ,p_Member_Object_ID IN DEF_OBJECT_ID%TYPE
                            ,p_Member_Name IN VARCHAR2
                            ,p_Member_Type IN VARCHAR2
                            ,p_Valid_Member_Enabled_Status IN VARCHAR2
                            ,p_Valid_Rule_Def_Status IN VARCHAR2
                            ,p_Valid_Lock_Status IN  VARCHAR2
                            ,p_Valid_Approval_Status IN VARCHAR2
                            ,p_Valid_Dep_Obj_Status IN VARCHAR2
                            ,p_Valid_Local_VS_Status IN VARCHAR2
                            ,p_Other_Error_Status IN VARCHAR2) IS
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Pop_Invalid_MmbrFlags_Tbl';
   Begin
      -- *******************************************************************************************
      -- name        :  Pop_Invalid_MmbrFlags_Tbl
      -- Function    :  Initialize entry in p_Member_Flags_Tab that is
      --                pointed to by p_Member_Flags_Count.
      -- Parameters
      -- IN
      --                p_Folder_Name_Of_Member
      --                   -  folder where member is stored..
      --                p_Owning_RS_Name_Of_Member
      --                   -  rule set that owns this rule entry
      --                p_Member_Object_ID
      --                   -  object of this rule entry
      --                p_Member_Name
      --                   -  display name of this rule entry
      --                p_Member_Type
      --                   -  type of this rule entry (i.e. 'MAPPING_RULE')
      --                p_Valid_Member_Enabled_Status
      --                   -  valid values:?
      --                p_Valid_Rule_Def_Status
      --                   -  ?
      --                p_Valid_Lock_Status
      --                   -  ?
      --                p_Valid_Approval_Status
      --                   -  ?
      --                p_Valid_Dep_Obj_Status
      --                   -  ?
      --                p_Valid_Local_VS_Status
      --                   -  ?
      --                p_Other_Error_Status
      --                   -  ?
      --
      -- OUT
      --                none.
      --
      -- In Out
      --                p_Member_Flags_Tab
      --                   -  the table containing the current members (processed?)
      --                p_Member_Flags_Count
      --                   -  current index into p_Member_Flags_Tab
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      p_Member_Flags_Tab(p_Member_Flags_Count).Folder_Name                       := p_Folder_Name_Of_Member;
      p_Member_Flags_Tab(p_Member_Flags_Count).Owning_RuleSet_Name         := p_Owning_RS_Name_Of_Member;
      p_Member_Flags_Tab(p_Member_Flags_Count).Object_Name                       := p_Member_Name;
      p_Member_Flags_Tab(p_Member_Flags_Count).Object_Type                      := p_Member_Type;
      p_Member_Flags_Tab(p_Member_Flags_Count).Object_ID                         := p_Member_Object_ID;

      If (     (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Member_Enabled_Status = ' ')
            OR (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Member_Enabled_Status IS NULL) ) then
         p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Member_Enabled_Status := p_Valid_Member_Enabled_Status;
      End If;

      If (     (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Rule_Def_Status = ' ')
            OR (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Rule_Def_Status IS NULL) ) then
         p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Rule_Def_Status       := p_Valid_Rule_Def_Status;
      End If;

      If (     (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Lock_Status = ' ')
            OR (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Lock_Status IS NULL) ) then
         p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Lock_Status           := p_Valid_Lock_Status;
      End If;

      If (     (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Approval_Status = ' ')
            OR (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Approval_Status IS NULL) ) then
         p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Approval_Status       := p_Valid_Approval_Status;
      End If;

      If (     (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Dep_Obj_Status = ' ')
            OR (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Dep_Obj_Status IS NULL) ) then
         p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Dep_Obj_Status        := p_Valid_Dep_Obj_Status;
      End If;

      If (     (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Local_VS_Status = ' ')
            OR (p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Local_VS_Status IS NULL) ) then
         p_Member_Flags_Tab(p_Member_Flags_Count).Valid_Local_VS_Status := p_Valid_Local_VS_Status;
      End If;

      IF (     (p_Member_Flags_Tab(p_Member_Flags_Count).Other_Error_Status = ' ')
            OR (p_Member_Flags_Tab(p_Member_Flags_Count).Other_Error_Status IS NULL) ) then
         p_Member_Flags_Tab(p_Member_Flags_Count).Other_Error_Status          := p_Other_Error_Status;
      End If;

      -- move pointer to next free cell.
      p_Member_Flags_Count := p_Member_Flags_Count + 1;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      EXCEPTION
         WHEN OTHERS THEN
            -- todo:: useful?? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE;

   End Pop_Invalid_MmbrFlags_Tbl;


   Procedure Populate_Valid_Member_Tab(p_Valid_Invalid_Members_Tab IN OUT NOCOPY Valid_Invalid_Members_Inst_Tab
                                       ,p_Valid_Invalid_Members_Count IN OUT  NOCOPY BINARY_INTEGER
                                       ,p_Folder_Name_Of_Member IN VARCHAR2
                                       ,p_Owning_RS_Name_Of_Member IN VARCHAR2
                                       ,p_Member_Object_ID IN DEF_OBJECT_ID%TYPE
                                       ,p_Member_Name IN VARCHAR2
                                       ,p_Member_Type IN VARCHAR2
                                       ,p_Member_Status IN VARCHAR2) IS
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Populate_Valid_Member_Tab';
   Begin
      -- *******************************************************************************************
      -- name        :  Populate_Valid_Member_Tab
      -- Function    :  Initialize entry in p_Valid_Invalid_Members_Tab that is
      --                pointed to by p_Valid_Invalid_Members_Count.
      -- Parameters
      -- IN
      --                p_Folder_Name_Of_Member
      --                   -  folder name of current object pointed to by p_Valid_Invalid_Members_Count
      --                p_Owning_RS_Name_Of_Member
      --                   -  owning rule set of current object pointed to by p_Valid_Invalid_Members_Count
      --                p_Member_Object_ID
      --                   -  object_id of current object pointed to by p_Valid_Invalid_Members_Count
      --                p_Member_Name
      --                   -  display name of current object pointed to by p_Valid_Invalid_Members_Count
      --                p_Member_Type
      --                   -  type of current object (i.e. 'MAPPING_RULE') pointed to by p_Valid_Invalid_Members_Count
      --                p_Member_Status
      --                   -  ?
      --
      -- OUT
      --                none.
      --
      -- In Out
      --                p_Valid_Invalid_Members_Tab
      --                   - ?
      --                p_Valid_Invalid_Members_Count
      --                   -  current indext into p_Valid_Invalid_Members_Tab
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      p_Valid_Invalid_Members_Tab(p_Valid_Invalid_Members_Count).Folder_Name := p_Folder_Name_Of_Member;
      p_Valid_Invalid_Members_Tab(p_Valid_Invalid_Members_Count).Owning_RuleSet_Name := p_Owning_RS_Name_Of_Member;
      p_Valid_Invalid_Members_Tab(p_Valid_Invalid_Members_Count).Object_ID := p_Member_Object_ID;
      p_Valid_Invalid_Members_Tab(p_Valid_Invalid_Members_Count).Object_Name := p_Member_Name;
      p_Valid_Invalid_Members_Tab(p_Valid_Invalid_Members_Count).Object_Type := p_Member_Type;
      p_Valid_Invalid_Members_Tab(p_Valid_Invalid_Members_Count).Validation_Status := p_Member_Status;

      -- move pointer to next free cell.
      p_Valid_Invalid_Members_Count := p_Valid_Invalid_Members_Count +1;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      EXCEPTION
         WHEN OTHERS THEN
            -- todo:: useful? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE;


   End Populate_Valid_Member_Tab;


   Procedure Log_Dependent_Object_Status(p_Parent_Object_ID IN DEF_OBJECT_ID%TYPE
                                        ,p_Dependent_Objects_Tab IN Dependent_Objects_Tab
                                        ,p_Dependent_Objects_Count IN BINARY_INTEGER) IS
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Log_Dependent_Object_Status';
   Begin
      -- *******************************************************************************************
      -- name        :  Log_Dependent_Object_Status
      -- Function    :  Log dependent object status to the fnd_file output file.
      --                ?? this may be where we output invalid rules found in rulesets rjk ??
      -- Parameters
      -- IN
      --                p_Parent_Object_ID
      --                   -  object_id of owning object
      --                p_Dependent_Objects_Tab
      --                   -  table of dependent objects??
      --                p_Dependent_Objects_Count
      --                   -  count of object in table.
      --
      -- OUT
      --                none.
      --
      --

      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      -- implemented as linear search.
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      For i in 0..p_Dependent_Objects_Count-1 LOOP
         if (p_Dependent_Objects_Tab(i).Parent_Object_ID = p_Parent_Object_ID) then

            fnd_file.put_line(FND_FILE.OUTPUT,
                                 '=>'
                              || RPAD(p_Dependent_Objects_Tab(i).Dependent_Object_Display_Name,40,' ')
                              || RPAD(p_Dependent_Objects_Tab(i).Dependent_Object_Type_Code,32,' ')
                              || RPAD(p_Dependent_Objects_Tab(i).Dependent_Object_Folder_Name,32,' ')
                              || RPAD('***',42,' ')
                              || RPAD('***',16,' ')
                              || RPAD('***',22,' ')
                              || RPAD(G_RSM_NO_VALID_DEFN,12,' ')
                              || RPAD('***',13,' ')
                              || RPAD('***',17,' ')
                              || RPAD('***',18,' ')
                             );
         end if;
      End LOOP;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
   End Log_Dependent_Object_Status;


   Procedure Log_Dep_Status_For_Single_Rule(p_Parent_Object_ID IN DEF_OBJECT_ID%TYPE
                                           ,p_Dependent_Objects_Tab IN Dependent_Objects_Tab
                                           ,p_Dependent_Objects_Count IN BINARY_INTEGER) IS
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Log_Dep_Status_For_Single_Rule';
   Begin
      -- *******************************************************************************************
      -- name        :  Log_Dep_Status_For_Single_Rule
      -- Function    :  Log dependent object status to the fnd_file output file.
      --                ?? this may be where we output invalid rules found in rulesets rjk ??
      -- Parameters
      -- IN
      --                p_Parent_Object_ID
      --                   -  object_id of owning object
      --                p_Dependent_Objects_Tab
      --                   -  table of dependent objects??
      --                p_Dependent_Objects_Count
      --                   -  count of object in table.
      --
      -- OUT
      --                none.
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');


      -- implemented as linear search
      For i in 0..p_Dependent_Objects_Count-1 LOOP
         if (p_Dependent_Objects_Tab(i).Parent_Object_ID = p_Parent_Object_ID) then

            fnd_file.put_line(FND_FILE.OUTPUT,
                              '=>'
                              || RPAD(p_Dependent_Objects_Tab(i).Dependent_Object_Display_Name,40,' ')
                              || RPAD(p_Dependent_Objects_Tab(i).Dependent_Object_Folder_Name,32,' ')
                              || RPAD(G_RSM_NO_VALID_DEFN,32,' ')
                              || RPAD('***',13,' ')
                              || RPAD('***',17,' ')
                              || RPAD('***',18,' ')
                             );

         end if;
      End LOOP;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

   End Log_Dep_Status_For_Single_Rule;



   Procedure Write_Flagged_Members_Output( p_Flagged_Members_Tab IN OUT NOCOPY Members_Validation_Status_Tab
                                          ,p_Flagged_Members_Count IN OUT NOCOPY BINARY_INTEGER
                                          ,p_Dependent_Objects_Tab IN OUT NOCOPY Dependent_Objects_Tab
                                          ,p_Dependent_Objects_Count IN OUT NOCOPY BINARY_INTEGER) IS
      s_Err_Msg_Text VARCHAR2(2000);
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Write_Flagged_Members_Output';

   Begin
      -- *******************************************************************************************
      -- name        :  Write_Flagged_Members_Output
      -- Function    :  Log entire contents of p_Flagged_Members_Tab table.  Also log
      --                dependent objects entries if the status of the current entry is
      --                'G_RSM_DEP_OBJECTS_INVALID'
      -- Parameters
      -- IN
      --                p_Flagged_Members_Tab
      --                   -  table to log..
      --                p_Flagged_Members_Count
      --                   -  count of entries in p_Flagged_Members_Tab
      --                p_Dependent_Objects_Tab
      --                   -  table containing objects that are dependent objects of objects in p_Flagged_Members_Tab
      --                p_Dependent_Objects_Count
      --                   -  count of entries in p_Dependent_Objects_Tab
      --
      -- OUT
      --                none.
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      For i in 0..p_Flagged_Members_Count -1 LOOP

         fnd_file.put_line(FND_FILE.OUTPUT,
                              RPAD(p_Flagged_Members_Tab(i).Object_Name,42,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Object_Type,32,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Folder_Name,32,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Owning_RuleSet_Name,42,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Valid_Member_Enabled_Status,16,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Other_Error_Status,22,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Valid_Rule_Def_Status,12,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Valid_Lock_Status,13,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Valid_Local_VS_Status,17,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Valid_Approval_Status,17,' ')
                           || RPAD(p_Flagged_Members_Tab(i).Valid_Dep_Obj_Status,18,' ')
                      );

         If (p_Flagged_Members_Tab(i).Valid_Dep_Obj_Status = G_RSM_DEP_OBJECTS_INVALID) then
            Log_Dependent_Object_Status(p_Flagged_Members_Tab(i).Object_ID
                                       ,p_Dependent_Objects_Tab
                                       ,p_Dependent_Objects_Count);

         End If;
    End LOOP;
    fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                 p_module=> l_module_name,
                                 p_msg_text=> 'EXIT');

   End Write_Flagged_Members_Output;



   Procedure Write_Valid_Invalid_Mem_Output(p_Valid_Invalid_Members_Tab IN OUT NOCOPY Valid_Invalid_Members_Inst_Tab
                                           ,p_Valid_Invalid_Members_Count IN OUT NOCOPY  BINARY_INTEGER
                                           ,p_Dependent_Objects_Tab IN OUT NOCOPY Dependent_Objects_Tab  -- looks dead..
                                           ,p_Dependent_Objects_Count IN OUT NOCOPY BINARY_INTEGER) IS   -- looks dead..
      s_Err_Msg_Text VARCHAR2(2000);
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Write_Valid_Invalid_Mem_Output';

   Begin
      -- *******************************************************************************************
      -- name        :  Write_Valid_Invalid_Mem_Output
      -- Function    :  Log entire contents of p_Valid_Invalid_Members_Tab table.
      --
      -- Parameters
      -- IN
      --                p_Valid_Invalid_Members_Tab
      --                   -  table to log..
      --                p_Valid_Invalid_Members_Count
      --                   -  count of entries in p_Valid_Invalid_Members_Tab
      --
      --              -----------the two parameters below appear to be deprecated------------
      --                p_Dependent_Objects_Tab
      --                   -  table containing objects that are dependent objects of objects in p_Flagged_Members_Tab
      --                p_Dependent_Objects_Count
      --                   -  count of entries in p_Dependent_Objects_Tab
      --
      -- OUT
      --                none.
      --
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');


      For i in 0..p_Valid_Invalid_Members_Count-1 LOOP
         fnd_file.put_line(FND_FILE.OUTPUT,
                              RPAD(p_Valid_Invalid_Members_Tab(i).Object_Name,40,' ')
                           || RPAD(p_Valid_Invalid_Members_Tab(i).Object_Type,30,' ')
                           || RPAD(p_Valid_Invalid_Members_Tab(i).Folder_Name,30,' ')
                           || RPAD(p_Valid_Invalid_Members_Tab(i).Owning_RuleSet_Name,40,' ')
                           || RPAD(p_Valid_Invalid_Members_Tab(i).Validation_Status,12,' ')
                          );

      End LOOP;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');
      EXCEPTION
         WHEN OTHERS THEN
            -- todo:: useful? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE;

   End Write_Valid_Invalid_Mem_Output;


   Procedure Write_Output(p_Valid_Members_Tab IN OUT NOCOPY Valid_Invalid_Members_Inst_Tab
                         ,p_Valid_Members_Count IN OUT NOCOPY BINARY_INTEGER
                         ,p_Flagged_Members_Tab IN OUT NOCOPY Members_Validation_Status_Tab
                         ,p_Flagged_Members_Count IN OUT NOCOPY BINARY_INTEGER
                         ,p_Dependent_Objects_Tab IN OUT NOCOPY Dependent_Objects_Tab
                         ,p_Dependent_Objects_Count IN OUT NOCOPY BINARY_INTEGER
                         ,p_Orig_RuleSet_Object_ID IN NUMBER
                         ,p_Rule_Effective_Date IN DATE
                         ,p_Output_Dataset_Name IN VARCHAR2
                         ,p_IsProductionODS IN BOOLEAN
                         ,p_Execution_Mode IN VARCHAR2) IS
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Write_Output';
      l_IsProductionODSstr   VARCHAR2(6)  := NULL;
   Begin
      -- *******************************************************************************************
      -- name        :  Write_Output
      -- Function    :  write a report to the fnd_file output file.
      --
      -- Parameters
      -- IN
      --
      -- OUT
      --                none.
      --
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');


      fnd_file.put_line(FND_FILE.OUTPUT,'Procedure Name    : Fem_Rule_Set_Manager.Preprocess_RuleSet');
      fnd_file.put_line(FND_FILE.OUTPUT,'Package Version');
      fnd_file.put_line(FND_FILE.OUTPUT,'                  : '||getProcedureVersionFromDB);
      fnd_file.put_line(FND_FILE.OUTPUT,'Run Date          : '||to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
      fnd_file.put_line(FND_FILE.OUTPUT,'----------------------------------------------------------');

      fnd_file.put_line(FND_FILE.OUTPUT
                       ,'Rule Set being validated    : '||GetObjectDisplayName(p_Orig_RuleSet_Object_ID));

      fnd_file.put_line(FND_FILE.OUTPUT
                       ,'Rule Effective Date         : '||p_Rule_Effective_Date);

      fnd_file.put_line(FND_FILE.OUTPUT
                       ,'Output Dataset              : '||p_Output_Dataset_Name);

      IF p_IsProductionODS THEN
         l_IsProductionODSstr := 'Y';
      ELSE
         l_IsProductionODSstr := 'N';
      END IF;

      fnd_file.put_line(FND_FILE.OUTPUT
                       ,'Is Output Dataset Production: '||l_IsProductionODSstr);

      fnd_file.put_line(FND_FILE.OUTPUT,'----------------------------------------------------------');

      If (NOT z_dataset_error) then

         --***********************************************************************
         -- p_Execution_Mode valid values......................
         -- E=Engine Execution Mode (used by engines only)
         -- A=All Rules     (report on all rules whether they are valid or not)
         -- I=Invalid Rules (report on invalid rules only)
         -- V=Valid Rules   (report on valid rules only)
         --***********************************************************************
         If (p_Execution_Mode = 'V' OR p_Execution_Mode = 'A' OR p_Execution_Mode = 'E') then
            fnd_file.put_line(FND_FILE.OUTPUT,' ');
            fnd_file.put_line(FND_FILE.OUTPUT,'Valid Rules/Rule Sets');
            fnd_file.put_line(FND_FILE.OUTPUT,'=====================');
            fnd_file.put_line(FND_FILE.OUTPUT,
                                 RPAD('Rule Name',40,' ')
                              || RPAD('Type',30,' ')
                              || RPAD('Folder',30,' ')
                              || RPAD('Owning RuleSet',40,' ')
                              || RPAD('Status',12,' ')
                             );
            fnd_file.put_line(FND_FILE.OUTPUT,
                                 RPAD('---------',40,' ')
                              || RPAD('----',30,' ')
                              || RPAD('------',30,' ')
                              || RPAD('--------------',40,' ')
                              || RPAD('------',12,' ')
                             );

            Write_Valid_Invalid_Mem_Output(p_Valid_Members_Tab
                                          ,p_Valid_Members_Count
                                          ,p_Dependent_Objects_Tab
                                          ,p_Dependent_Objects_Count);
              --If (z_Err_Code = -1) then
              --        RETURN;
              -- End If;

         End If;

         --***********************************************************************
         -- p_Execution_Mode valid values......................
         -- E=Engine Execution Mode (used by engines only)
         -- A=All Rules     (report on all rules whether they are valid or not)
         -- I=Invalid Rules (report on invalid rules only)
         -- V=Valid Rules   (report on valid rules only)
         --***********************************************************************
         If (     p_Execution_Mode = 'I'
             OR   p_Execution_Mode = 'A'
             OR   p_Execution_Mode = 'E') then
            fnd_file.put_line(FND_FILE.OUTPUT,' ');
            fnd_file.put_line(FND_FILE.OUTPUT,'Invalid Rules/Rule Sets');
            fnd_file.put_line(FND_FILE.OUTPUT,'=======================');

            fnd_file.put_line(FND_FILE.OUTPUT,
                                 RPAD('Rule Name',42,' ')
                              || RPAD('Type',32,' ')
                              || RPAD('Folder',32,' ')
                              || RPAD('Owning RuleSet',42,' ')
                              || RPAD('Enabled Status',16,' ')
                              || RPAD('Other Error',22,' ')
                              || RPAD('Rule Def',12,' ')
                              || RPAD('Lock Status',13,' ')
                              || RPAD('Local VS Status',17,' ')
                              || RPAD('Approval Status',17,' ')
                              || RPAD('Dependent Status',18,' ')
                             );

            fnd_file.put_line(FND_FILE.OUTPUT,
                                 RPAD('---------',42,' ')
                              || RPAD('----',32,' ')
                              || RPAD('------',32,' ')
                              || RPAD('--------------',42,' ')
                              || RPAD('--------------',16,' ')
                              || RPAD('----------',22,' ')
                              || RPAD('--------',12,' ')
                              || RPAD('-----------',13,' ')
                              || RPAD('---------------',17,' ')
                              || RPAD('---------------',17,' ')
                              || RPAD('----------------',18,' ')
                             );

            Write_Flagged_Members_Output( p_Flagged_Members_Tab
                                        ,p_Flagged_Members_Count
                                        ,p_Dependent_Objects_Tab
                                        ,p_Dependent_Objects_Count);

         End If;

      End If;

      fnd_file.put_line(FND_FILE.OUTPUT,' ');
      fnd_file.put_line(FND_FILE.OUTPUT,'                    -----------------End of Report-----------------');

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      EXCEPTION
      WHEN OTHERS THEN
         -- todo:: useful? z_Err_Code := -1;
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_FATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_UNEXPECTED_SQLERROR,
                                             G_ERRMAC_ROUTINE_NAME,
                                             l_module_name,
                                             NULL,
                                             G_ERRMAC_SQL_ERROR,
                                             SQLERRM);
         RAISE;

   End Write_Output;


   FUNCTION Mem_Obj_Prev_Processed(p_currRuleSet IN Rule_Set_Instance_Rec
                                  ,p_Child_Object_ID IN DEF_OBJECT_ID%TYPE
                                  ,p_Child_Folder_Name IN DEF_FOLDER_NAME%TYPE
                                  ,p_Child_Object_Name IN DEF_OBJECT_DISPLAY_NAME%TYPE
                                  ,x_Members_Processed_Tab IN OUT NOCOPY Members_Processed_Instance_Tab
                                  ,x_Members_Processed_Count IN OUT NOCOPY BINARY_INTEGER
                                  ,p_Child_Object_Type_Code IN DEF_OBJECT_TYPE_CODE%TYPE) RETURN BOOLEAN IS

      --                                              000000000111111111122222222223333333333444444444455555555556
      --                                              123456789012345678901234567890123456789012345678901234567890
      l_module_name           VARCHAR2(70) := G_MODULE_NAME || 'Mem_Obj_Prev_Processed';
      l_found_error           BOOLEAN      := FALSE;

   BEGIN
      -- *******************************************************************************************
      -- name        :  Mem_Obj_Prev_Processed
      -- Function    :  Search for a previously processed Object_ID in the x_Members_Processed_Tab table.
      --                If it was previously processed, raise a user exception and return TRUE..
      --                Otherwise add the current member to the x_Members_Processed_Tab and return FALSE
      --
      -- Parameters
      -- IN
      --                p_Child_Object_ID
      --                   -  The OBJECT_ID we are searching for in the x_Members_Processed_Tab table.
      --                p_Child_Folder_Name IN DEF_FOLDER_NAME%TYPE
      --                   -  The Folder name associated with p_Child_Object_ID
      --                p_Child_Object_Name IN DEF_OBJECT_DISPLAY_NAME%TYPE
      --                   -  The Display name associated with p_Child_Object_ID
      -- In OUT
      --                x_Members_Processed_Tab
      --                   -  The previously processed member table.
      --                x_Members_Processed_Count
      --                   -  The count of entries stored in the x_Members_Processed_Tab table
      --
      -- returns
      --                TRUE -  we found the object ID, this may be bad...
      --                FALSE - object ID not found, things are normal (no error)...
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Child_Object_ID->' || p_Child_Object_ID);
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Child_Folder_Name->' || p_Child_Folder_Name);
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Child_Object_Name->' || p_Child_Object_Name);
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_currRuleSet.RuleSet_Object_Name->' || p_currRuleSet.RuleSet_Object_Name);

      If (x_Members_Processed_Count > 0) then
         For l_current_member in 0..x_Members_Processed_Count - 1 LOOP

            If (x_Members_Processed_Tab(l_current_member).Member_Object_ID = p_Child_Object_ID) then

               fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                            p_module=> l_module_name,
                                            p_msg_text=> 'match found.. failing');
               z_Err_Code := 4;
               -- todo:: fix to new standards..
               IF p_Child_Object_Type_Code  = 'RULE_SET' THEN

                  FEM_UTILS.set_master_err_state( z_master_err_state,
                                                      FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                      G_APP_NAME,
                                                      G_ERRMSG_DUPLICATE_OCCURRENCE,
                                                      G_ERRMAC_DUP_RS,
                                                      p_Child_Object_Name,
                                                      NULL,
                                                      G_ERRMAC_CONTAIN_RS,
                                                      p_currRuleSet.RuleSet_Object_Name
                                                      );
               ELSE

                  FEM_UTILS.set_master_err_state( z_master_err_state,
                                                      FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                      G_APP_NAME,
                                                      G_ERRMSG_DUP_RULE_OCC,
                                                      G_ERRMAC_RULE_SET,
                                                      p_currRuleSet.RuleSet_Object_Name,
                                                      NULL,
                                                      G_ERRMAC_RULE_NAME,
                                                      p_Child_Object_Name
                                                      );
               END IF;
               l_found_error := TRUE;
            End If;

         End LOOP;
      End If; /* If (x_Members_Processed_Count > 0) */

      IF NOT l_found_error THEN
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'match NOT found.. adding to list');
         /****Adding Member to Members_Processed_Tab*****/
         -- add it.
         x_Members_Processed_Tab(x_Members_Processed_Count).Member_Object_ID := p_Child_Object_ID;
         -- increment the entry count..
         x_Members_Processed_Count := x_Members_Processed_Count + 1;

         /****************************************************/
         fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'NORMAL EXIT');
      END IF;

      RETURN l_found_error;


      EXCEPTION
         WHEN OTHERS THEN
            -- todo:: useful? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE;

   End Mem_Obj_Prev_Processed;


   FUNCTION RS_Cyclical_And_Depth_Check(
                            p_Child_RuleSet_Object_ID IN DEF_OBJECT_ID%TYPE
                           ,p_Child_Object_Display_Name  IN  DEF_OBJECT_DISPLAY_NAME%TYPE
                           ,x_Rule_Set_Level IN OUT NOCOPY NUMBER
                           ,x_Rule_Set_Count IN OUT NOCOPY BINARY_INTEGER
                           ,x_Rule_Set_Instance_Tab IN OUT NOCOPY Rule_Set_Instance_Tab
                           ,p_Other_Error_Status IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

      l_module_name           VARCHAR2(70)   := G_MODULE_NAME || 'RS_Cyclical_And_Depth_Check';
      l_ruleset_already_used  BOOLEAN        := FALSE;

   Begin
      -- *******************************************************************************************
      -- name        :  RS_Cyclical_And_Depth_Check
      -- Function    :  Search for a previously used Ruleset in the x_Rule_Set_Instance_Tab, and also check
      --                for max-depth of ruleset nesting.  If the ruleset was not found
      --                put its object_id into the x_Rule_Set_Instance_Tab.  If it was, return an error.  If max-nesting was
      --                exceeded, return an error.
      --
      -- Parameters
      -- IN
      --                p_Child_RuleSet_Object_ID
      --                   -  ruleset to search for..
      -- IN OUT
      --                x_Rule_Set_Level
      --                   -  current nesting level.
      --                x_Rule_Set_Count
      --                   -  count of rulesets we have processed.
      --                x_Rule_Set_Instance_Tab
      --                   -  table of previously used rulesets..
      --                p_Other_Error_Status
      --                   -  separate place to return an error (!)
      -- returns
      --                TRUE -  If we found a previous usage of this Ruleset object_id
      --                         *OR* we exceeded the maximum level for ruleset nesting.
      --                FALSE - If things went ok (no previous usage found)
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');


      /*************Cyclical check***********************/
      If (x_Rule_Set_Count > 0) then

         For i in 0..x_Rule_Set_Count LOOP

            If (x_Rule_Set_Instance_Tab(i).RuleSet_Object_ID = p_Child_RuleSet_Object_ID) then
               -- todo:: remove err code??
               z_Err_Code := 2;
               FEM_UTILS.set_master_err_state( z_master_err_state,
                                                   FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                   G_APP_NAME,
                                                   G_ERRMSG_DUPLICATE_OCCURRENCE,
                                                   G_ERRMAC_DUP_RS,
                                                   p_Child_Object_Display_Name,
                                                   NULL,
                                                   G_ERRMAC_CONTAIN_RS,
                                                   x_Rule_Set_Instance_Tab(x_Rule_Set_Count).RuleSet_Object_Name
                                                   );



               p_Other_Error_Status := G_RSM_CYCLICAL_FAILURE;
               -- soft error..
               l_ruleset_already_used := TRUE;
            End If;

         End LOOP;
      End If;

      IF NOT l_ruleset_already_used THEN
         /******Adding Rule Set to Rule_Set_Instance_Tab******/
         x_Rule_Set_Count := X_Rule_Set_Count +1;
         x_Rule_Set_Instance_Tab(X_Rule_Set_Count).RuleSet_Object_ID    := p_Child_RuleSet_Object_ID;
         x_Rule_Set_Instance_Tab(X_Rule_Set_Count).RuleSet_Object_Name  := p_Child_Object_Display_Name;
         x_Rule_Set_Instance_Tab(X_Rule_Set_Count).Owning_RuleSet_Name  := x_Rule_Set_Instance_Tab(X_Rule_Set_Count - 1).RuleSet_Object_Name;

         x_Rule_Set_Level := x_Rule_Set_Level +1;

         /***Level Check***/
         If (x_Rule_Set_Level > g_max_rule_set_depth) then
            -- todo:: fix to new standards..
            z_Err_Code := 3;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_DEPTH_CHECK_FAILURE
                                                );
            p_Other_Error_Status := G_RSM_DEPTH_FAILURE;

            -- hard error.. fail out..
            RAISE FND_API.G_EXC_ERROR;
         End If;
      END IF;


      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      RETURN l_ruleset_already_used;

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            -- top calling routine will handle this one.
            RAISE;
         WHEN OTHERS THEN
            -- todo:: useful? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE;

   End RS_Cyclical_And_Depth_Check;




   PROCEDURE Create_RuleSet_Process_Data(p_RuleSet_Object_ID IN DEF_OBJECT_ID%TYPE
                                        ,p_Child_Object_ID IN DEF_OBJECT_ID%TYPE
                                        ,p_Child_Object_Definition_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                                        ,p_Engine_Execution_Seq IN NUMBER) IS
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Create_RuleSet_Process_Data';
   Begin
      -- *******************************************************************************************
      -- name        :  Create_RuleSet_Process_Data
      -- Function    :  Insert a row into the fem_ruleset_process_data table.
      --
      -- Parameters
      -- IN
      --                p_RuleSet_Object_ID
      --                   -  owning ruleset?  Master Ruleset?
      --                p_Child_Object_ID
      --                   -  Object ID to be run.
      --                p_Child_Object_Definition_ID
      --                   -  Object Definition ID for the Object ID to be run
      --                p_Engine_Execution_Seq
      --                   -  run sequence for the rules (parallel rules all have same sequence #)
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      z_global_counter := z_global_counter+1;
      --Bug # 4283689
      --fnd_file.put_line(fnd_file.LOG,'Inserting row :'||GetObjectDisplayName(p_Child_Object_ID)||':'||p_RuleSet_Object_ID||':'||z_conc_request_id||':'||p_Child_Object_Definition_ID);

      insert into fem_ruleset_process_data
         (RULE_SET_OBJ_ID
         ,CHILD_OBJ_ID
         ,CHILD_OBJ_DEF_ID
         ,ENGINE_EXECUTION_SEQUENCE
         ,REQUEST_ID
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         )
         values
         (p_RuleSet_Object_ID
         ,p_Child_Object_ID
         ,p_Child_Object_Definition_ID
         ,p_Engine_Execution_Seq
         ,z_conc_request_id
         ,sysdate
         ,z_user_id
         ,sysdate
         ,z_user_id
         ,z_login_id
         );

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      EXCEPTION
         WHEN OTHERS THEN
            -- todo:: useful? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE;

   End Create_RuleSet_Process_Data;




   Function IsProductionODS(   p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                              ,p_Output_Dataset_Name OUT NOCOPY VARCHAR2
                              ,p_Output_Dataset_Code OUT NOCOPY DEF_DATASET_CODE%TYPE )
                              RETURN BOOLEAN IS

      l_module_name              VARCHAR2(70) := G_MODULE_NAME || 'IsProductionODS';
      l_ods_found                BOOLEAN := FALSE;
      l_ods_prodflag_found       BOOLEAN := FALSE;
      x_production_flag          VARCHAR2(1) := ' ';
      l_isProduction             BOOLEAN := FALSE;

      Cursor getOutputDataset(p_DS_IO_Def_ID IN NUMBER) IS
         SELECT   a.dataset_name
                  ,b.output_dataset_code
            from
                   fem_datasets_vl a
                  ,fem_ds_input_output_defs b
            where          b.output_dataset_code = a.dataset_code
                     and   b.dataset_io_obj_def_id = p_DS_IO_Def_ID;

      Cursor getProductionFlag(p_Output_Dataset_Code IN DEF_DATASET_CODE%TYPE) Is
         select   a.DIM_ATTRIBUTE_VARCHAR_MEMBER
            from  FEM_DATASETS_ATTR a
                  ,FEM_DIM_ATTRIBUTES_B b
            where          a.DATASET_CODE = p_Output_Dataset_Code
                  and      b.ATTRIBUTE_ID = a.ATTRIBUTE_ID
                  and      b.ATTRIBUTE_VARCHAR_LABEL = 'PRODUCTION_FLAG';

   Begin
      -- *******************************************************************************************
      -- name        :  IsProductionODS
      -- Function    :
      --
      -- Parameters
      -- IN
      --                p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
      --                   -  Data set IO Definition object_id in question..
      -- OUT
      --                p_Output_Dataset_Name OUT NOCOPY VARCHAR2
      --                   -  the name of the dataset associated with p_DS_IO_Def_ID
      --                p_Output_Dataset_Code OUT NOCOPY DEF_DATASET_CODE%TYPE
      --                   -  the output dataset specified for the DS_IO_Def_ID
      --
      -- RETURNS
      --                TRUE - is a production DS
      --                FALSE - is a non-production DS
      --                Exceptions:
      --                  OTHERS:     SQL/unknown exceptions only.
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      OPEN getOutputDataset(p_DS_IO_Def_ID);

      FETCH getOutputDataset
         into  p_Output_Dataset_Name
               ,p_Output_Dataset_Code;

         If getOutputDataset%NOTFOUND then
            -- we have no output data set, fail now.
            l_ods_found := FALSE;
         ELSE
            l_ods_found := TRUE;
         End If;

      CLOSE getOutputDataset;

      IF NOT l_ods_found THEN
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_NO_ODS
                                             );
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                             p_module=> l_module_name,
                             p_msg_text=> 'failed in output dataset query');
         z_dataset_error := TRUE;
      ELSE

         OPEN getProductionFlag(p_Output_Dataset_Code);
         FETCH getProductionFlag
            into  x_Production_Flag;

            If getProductionFlag%NOTFOUND then
               l_ods_prodflag_found := FALSE;
            ELSE
               l_ods_prodflag_found := TRUE;
            End If;
         CLOSE getProductionFlag;

         -- error...
         IF NOT l_ods_prodflag_found THEN
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_NO_ODSPRODFLAG
                                                );
            fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                p_module=> l_module_name,
                                p_msg_text=> 'failed in production flag query');
            z_dataset_error := TRUE;
         END IF;
      END IF;


      IF x_Production_Flag = 'Y' THEN
         l_isProduction := TRUE;
      ELSIF x_Production_Flag = 'N' THEN
         l_isProduction := FALSE;
      ELSE
         -- This case should not occur because PRODUCTION_FLAG is a
         -- required attribute.
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_NO_ODSPRODFLAG,
                                             G_ERRMAC_VALUE,
                                             x_Production_Flag             );
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                p_module=> l_module_name,
                                p_msg_text=> 'PRODUCTION_FLAG attribute is null');
         z_dataset_error := TRUE;

      END IF;


      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      RETURN l_isProduction;

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
            RAISE;

   End IsProductionODS;



   Procedure Validate_Dependent_Objects_Pvt(p_Top_Object_ID IN DEF_OBJECT_ID%TYPE
                       ,p_Top_Obj_Def_Id IN DEF_OBJECT_DEFINITION_ID%TYPE
                       ,p_Parent_Obj_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                       ,p_Rule_Effective_Date IN DATE
                       ,p_Dependent_Objects_Tab IN OUT NOCOPY Dependent_Objects_Tab
                       ,p_Dependent_Objects_Count IN OUT NOCOPY BINARY_INTEGER
                       ,p_Valid_Dep_Obj_Status IN OUT NOCOPY VARCHAR2) IS

      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Validate_Dependent_Objects_Pvt';
      cursor getDepObjects(p_Parent_Obj_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE) IS
      select
             a.required_object_id
            ,o.object_name
            ,f.folder_name
            ,o.object_type_code
            ,t.OBJECT_TYPE_NAME
         from
             fem_object_dependencies a
            ,fem_object_catalog_vl o
            ,fem_folders_vl f
            ,fem_object_types t
         where       a.object_definition_id = p_Parent_Obj_Def_Id
               and   a.required_object_id = o.object_id
               and   o.folder_id = f.folder_id
               and   t.object_type_code = o.object_type_code;

      l_Dependent_Obj_ID           DEF_OBJECT_ID%TYPE;
      l_Dependent_Obj_Display_Name DEF_OBJECT_DISPLAY_NAME%TYPE;
      l_Dependent_Obj_Folder_Name  DEF_FOLDER_NAME%TYPE;
      l_Dependent_Obj_Type_Code    DEF_OBJECT_TYPE_CODE%TYPE;


      l_Dependent_Obj_Def_ID DEF_OBJECT_DEFINITION_ID%TYPE := 0;
      l_Approval_Status_Code DEF_APPROVAL_STATUS_CODE%TYPE := 'XX';

      l_Dependent_Object_Count NUMBER;

      l_object_type_name fem_object_types_tl.OBJECT_TYPE_NAME%TYPE;

   Begin
      -- *******************************************************************************************
      -- name        :  Validate_Dependent_Objects_Pvt
      -- Function    :  Compile a list of all dependent objects that do NOT have valid object_definition_ids
      --                for the current p_Rule_Effective_Date into the p_Dependent_Objects_Tab table
      --
      -- Parameters
      -- IN
      --                p_Top_Object_ID
      --                   -
      --                p_Top_Obj_Def_Id
      --                   -
      --                p_Parent_Obj_Def_ID
      --                   -
      --                p_Rule_Effective_Date
      --                   -  Effective date for this run.
      --
      -- IN OUT
      --                p_Dependent_Objects_Tab
      --                   -  invalid dependents..
      --                p_Dependent_Objects_Count
      --                   -  count of invalid dependents..
      --                p_Valid_Dep_Obj_Status
      --                   -
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      Begin
         select count(required_object_id)
            into
               l_Dependent_Object_Count
            from fem_object_Dependencies
            where object_definition_id = p_Parent_Obj_Def_Id;

         If (l_Dependent_Object_Count = 0) then
            If (p_Valid_Dep_Obj_Status = 'NA') then
               p_Valid_Dep_Obj_Status := G_RSM_NO_DEP_OBJECTS;
            End If;
            -- RETURN;
         End If;
      End;

      If (l_Dependent_Object_Count > 0) then
         OPEN getDepObjects(p_Parent_Obj_Def_ID);
         LOOP
            Fetch getDepObjects
               into
                  l_Dependent_Obj_ID
                  ,l_Dependent_Obj_Display_Name
                  ,l_Dependent_Obj_Folder_Name
                  ,l_Dependent_Obj_Type_Code
                  ,l_object_type_name;
            EXIT WHEN getDepObjects%NOTFOUND;

            Begin
               Get_ValidDefinition_Priv(l_Dependent_Obj_ID
                                        ,p_Rule_Effective_Date
                                        ,l_Dependent_Obj_Def_ID
                                        ,l_Approval_Status_Code);
            End;

            If (l_Dependent_Obj_Def_ID = -1) then
               -- we DIDN'T find a def ID for this dependent object..
               -- todo:: fix to new standards
               z_Err_Code := 6;
               --FEM_UTILS.set_master_err_state( z_master_err_state,
               --                                    FEM_UTILS.G_RSM_NONFATAL_ERR,
               --                                    G_APP_NAME,
               --                                    G_ERRMSG_NO_VALID_DEFINITION,
               --                                    G_ERRMAC_RULE_NAME,
               --                                    l_Dependent_Obj_Display_Name);
               FEM_UTILS.set_master_err_state( z_master_err_state,
                                                   FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                   G_APP_NAME,
                                                   G_FEMRSM_NOVALID_DEP_DEF,
                                                   'RULE_NAME',
                                                   l_Dependent_Obj_Display_Name,
                                                   NULL,
                                                   'OBJECT_TYPE',
                                                   l_object_type_name,
                                                   NULL,
                                                   'EFFECTIVE_DATE',
                                                   to_char(p_Rule_Effective_Date));

               p_Valid_Dep_Obj_Status := G_RSM_DEP_OBJECTS_INVALID;

               -- show it in the dependent objects table...

               -- this next line could very easily become invalid if the dependency graph goes deeper than 1
               -- rjk
               p_Dependent_Objects_Tab(p_Dependent_Objects_Count).Parent_Object_ID              := p_Top_Object_ID;
               p_Dependent_Objects_Tab(p_Dependent_Objects_Count).Dependent_Object_ID           := l_Dependent_Obj_ID;
               p_Dependent_Objects_Tab(p_Dependent_Objects_Count).Dependent_Object_Display_Name := l_Dependent_Obj_Display_Name;
               p_Dependent_Objects_Tab(p_Dependent_Objects_Count).Dependent_Object_Folder_Name  := l_Dependent_Obj_Folder_Name;
               p_Dependent_Objects_Tab(p_Dependent_Objects_Count).Dependent_Object_Type_Code    := l_Dependent_Obj_Type_Code;
               p_Dependent_Objects_Tab(p_Dependent_Objects_Count).Status                        := 'I';
               p_Dependent_Objects_Tab(p_Dependent_Objects_Count).Message_If_Invalid            := z_Err_Msg ;


               p_Dependent_Objects_Count := p_Dependent_Objects_Count + 1;

            Else
               If (p_Valid_Dep_Obj_Status = 'NA') then
                  p_Valid_Dep_Obj_Status := G_RSM_MEMBER_VALID;
               End If;

               -- recurse..
               Validate_Dependent_Objects_Pvt(  p_Top_Object_ID
                                                ,p_Top_Obj_Def_Id
                                                ,l_Dependent_Obj_Def_ID
                                                ,p_Rule_Effective_Date
                                                ,p_Dependent_Objects_Tab
                                                ,p_Dependent_Objects_Count
                                                ,p_Valid_Dep_Obj_Status);
            End If;

         END LOOP;
         CLOSE getDepObjects;

      End If;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      EXCEPTION
         WHEN OTHERS THEN
            -- todo:: useful? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE;

   End Validate_Dependent_Objects_Pvt;



   Procedure Validate_Rule_Private(p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
                       ,p_Rule_Local_VS_Combo_ID IN DEF_LOCAL_VS_COMBO_ID%TYPE
                       ,p_Rule_Effective_Date IN DATE
                       ,p_IsProductionODS IN BOOLEAN
                       ,p_Reference_Period_ID IN NUMBER
                       ,p_Ledger_ID IN NUMBER
                       ,p_Dependent_Objects_Tab IN OUT NOCOPY Dependent_Objects_Tab
                       ,p_Dependent_Objects_Count IN OUT NOCOPY BINARY_INTEGER
                       ,p_Rule_Obj_Def_ID OUT NOCOPY DEF_OBJECT_DEFINITION_ID%TYPE
                       ,p_Valid_Rule_Def_Status IN OUT NOCOPY VARCHAR2
                       ,p_Valid_Lock_Status IN OUT NOCOPY VARCHAR2
                       ,p_Valid_Approval_Status IN OUT NOCOPY VARCHAR2
                       ,p_Valid_Dep_Obj_Status IN OUT NOCOPY VARCHAR2
                       ,p_Valid_Local_VS_Status IN OUT NOCOPY VARCHAR2) IS

      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Validate_Rule_Private';
      l_Rule_Obj_Def_ID           DEF_OBJECT_DEFINITION_ID%TYPE := 0;
      l_Rule_Approval_Status_Code DEF_APPROVAL_STATUS_CODE%TYPE := 'XX';

      l_Is_Rule_Locked BOOLEAN;

   Begin
      -- *******************************************************************************************
      -- name        :  Validate_Rule_Private
      -- Function    :
      --
      -- Parameters
      -- IN
      --                p_Rule_Object_ID
      --                   -
      --                p_Rule_Local_VS_Combo_ID
      --                   -
      --                p_Rule_Effective_Date
      --                   -
      --                p_Is_Output_DS_Production
      --                   -
      --                p_Reference_Period_ID
      --                   -
      --                p_Ledger_ID
      --                   -
      --
      -- OUT
      --                p_Rule_Obj_Def_ID
      --                   -
      -- IN OUT
      --                p_Dependent_Objects_Tab
      --                   -
      --                p_Dependent_Objects_Count
      --                   -
      --                p_Valid_Rule_Def_Status
      --                   -
      --                p_Valid_Lock_Status
      --                   -
      --                p_Valid_Approval_Status
      --                   -
      --                p_Valid_Dep_Obj_Status
      --                   -
      --                p_Valid_Local_VS_Status
      --                   -
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      z_Err_Code := 0;
      z_Err_Msg  := NULL;

      p_Valid_Rule_Def_Status := 'NA';
      p_Valid_Local_VS_Status := 'NA';
      p_Valid_Lock_Status := 'NA';
      p_Valid_Approval_Status := 'NA';
      p_Valid_Dep_Obj_Status := 'NA';

      /***** Check for Valid Definition of Rule for given Effective Date *****/

      Begin
         -- will return -1 if no object_definition_id for this object_id.
         Get_ValidDefinition_Priv(p_Rule_Object_ID
                                 ,p_Rule_Effective_Date
                                 ,l_Rule_Obj_Def_ID
                                 ,l_Rule_Approval_Status_Code);

         p_Rule_Obj_Def_ID := l_Rule_Obj_Def_ID;

      End;

      If (p_Rule_Obj_Def_ID = -1) then
         -- no valid definition ID!
         p_Valid_Rule_Def_Status := G_RSM_NO_VALID_DEFN;
         -- todo:: fix to new standards ... this one may be ok
         z_Err_Code := 1;
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_NO_VALID_DEFINITION,
                                             G_ERRMAC_RULE_NAME,
                                             GetObjectDisplayName(p_Rule_Object_ID)
                                             );
         RETURN;
      ELSE
         -- we are cool up to here.. continue..
         p_Valid_Rule_Def_Status := G_RSM_VALID_DEFN_EXISTS;
      End If;


      /****** Check for Process Locks on Object *************************/

      /*-----Waiting for code to be finalized---------

       FEM_PL_PKG.obj_execution_lock_exists
                  (p_request_id => z_conc_request_id
                  ,p_object_id => p_Rule_Object_ID
                  ,p_lock_exists => l_Is_Rule_Locked);
       If (l_Is_Rule_Locked) then
          p_Valid_Lock_Status := G_RSM_RULE_LOCKED;
          -- todo:: fix to new standards..
          z_Err_Code := 7;
          set_master_err_state(FEM_UTILS.G_RSM_NONFATAL_ERR,
                               G_APP_NAME,);
       Else
          p_Valid_Lock_Status := G_RSM_RULE_NOT_LOCKED;
       End If;
      --------------------------------------------------*/

      /******************************************************************/

      /*******Check the status of Local VS Combo ID on Rule *************/

      -- our general session LOCAL_VS must match the rule's LOCAL_VS, or we
      -- have SERIOUS problems (non-existant dimension values)
      If (p_Rule_Local_VS_Combo_ID <> z_local_vs_for_session) then
         p_Valid_Local_VS_Status := G_RSM_INVALID_STATUS;
         -- todo:: fix to new standards
         z_Err_Code := 8;
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_NO_VALID_VALSETS,
                                             G_ERRMAC_RULE_NAME,
                                             GetObjectDisplayName(p_Rule_Object_ID)
                                             );
      Else
         p_Valid_Local_VS_Status := G_RSM_MEMBER_VALID;
      End If;


      /****** Check for Approval Status of Rule Definition **************/

      -- if the output data set is a production data set, then
      -- EVERY rule that writes to it must also be approved, otherwise
      -- we have a FATAL on that rule and should NOT run it.
      If (p_IsProductionODS) then

         If ((l_Rule_Approval_Status_Code <> 'APPROVED')AND(l_Rule_Approval_Status_Code <> 'XX'))  then
            p_Valid_Approval_Status := G_RSM_RULE_NOT_APPROVED;
            -- todo:: fix to new standards
            z_Err_Code := 5;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_DEFN_NOT_APPROVED,
                                                G_ERRMAC_RULE_NAME,
                                                GetObjectDisplayName(p_Rule_Object_ID)
                                                );
         Elsif (l_Rule_Approval_Status_Code = 'APPROVED') then
            p_Valid_Approval_Status := G_RSM_RULE_APPROVED;
         End If;

      End If ;


      -- check all dependents for the rule object_id in question and
      -- verify that all dependents have a valid object_definition for
      -- this Rule_Effective_Date.
      Validate_Dependent_Objects_Pvt(p_Rule_Object_ID
                                    ,l_Rule_Obj_Def_Id
                                    ,l_Rule_Obj_Def_Id
                                    ,p_Rule_Effective_Date
                                    ,p_Dependent_Objects_Tab
                                    ,p_Dependent_Objects_Count
                                    ,p_Valid_Dep_Obj_Status);

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
            RAISE;

   End Validate_Rule_Private;



   PROCEDURE Process_RuleSet(  p_Orig_RuleSet_Object_ID IN DEF_OBJECT_ID%TYPE
                              ,p_Curr_RuleSet_Object_ID  IN DEF_OBJECT_ID%TYPE
                              ,x_Rule_Set_Instance_Tab IN OUT NOCOPY Rule_Set_Instance_Tab
                              ,x_Rule_Set_Count IN OUT NOCOPY BINARY_INTEGER
                              ,x_Rule_Set_Level IN OUT NOCOPY NUMBER
                              ,x_Members_Processed_Tab IN OUT NOCOPY Members_Processed_Instance_Tab
                              ,x_Members_Processed_Count IN OUT NOCOPY BINARY_INTEGER
                              ,p_Rule_Effective_Date IN DATE
                              ,p_IsProductionODS IN BOOLEAN
                              ,p_Engine_Execution_Sequence IN OUT NOCOPY NUMBER
                              ,p_Execution_Mode IN VARCHAR2
                              ,p_Valid_Members_Tab IN OUT NOCOPY Valid_Invalid_Members_Inst_Tab
                              ,p_Valid_Members_Count IN OUT NOCOPY BINARY_INTEGER
                              ,p_Invalid_Member_Flags_Tab IN OUT NOCOPY Members_Validation_Status_Tab
                              ,p_Invalid_Member_Flags_Count IN OUT NOCOPY BINARY_INTEGER
                              ,p_Dependent_Objects_Tab IN OUT NOCOPY Dependent_Objects_Tab
                              ,p_Dependent_Objects_Count IN OUT NOCOPY BINARY_INTEGER
                              ,p_Output_Dataset_Code IN DEF_DATASET_CODE%TYPE
                              ,p_Output_Period_ID IN NUMBER
                              ,p_Ledger_ID IN NUMBER
                              ,l_Maximum_Sequence IN OUT NOCOPY NUMBER
                              ,p_curr_RS IN Rule_Set_Instance_Rec
                               ) IS

      -- as it suggests.. get all the members for a given ruleset.
      CURSOR Get_Rule_Set_Members(p_Curr_RuleSet_Object_ID IN DEF_OBJECT_ID%TYPE) IS
         select
               rs.RULE_SET_OBJECT_TYPE_CODE        as Current_RuleSet_Obj_Type
               ,rsm.CHILD_EXECUTION_SEQUENCE       as Child_Execution_Sequence
               ,rsm.CHILD_OBJ_ID                   as Child_Object_ID
               ,cm_o.OBJECT_TYPE_CODE              as Child_Object_Type
               ,cm_o.OBJECT_NAME                   as Child_Object_Display_Name
               ,cm_f.FOLDER_NAME                   as Child_Folder_Name
               ,rsm.EXECUTE_CHILD_FLAG             as Execute_Child_Flag
               ,nvl(cm_o.LOCAL_VS_COMBO_ID,-1)     as Child_Local_VS_Combo_ID
            from
                FEM_RULE_SET_MEMBERS rsm
               ,FEM_RULE_SETS rs
               ,FEM_OBJECT_CATALOG_VL cm_o
               ,FEM_OBJECT_DEFINITION_B rsm_d
               ,FEM_FOLDERS_VL cm_f
            where
                     rsm.RULE_SET_OBJ_DEF_ID = rsm_d.OBJECT_DEFINITION_ID
               and   rsm_d.OBJECT_ID = p_Curr_RuleSet_Object_ID
               and   rsm.RULE_SET_OBJ_DEF_ID = rs.RULE_SET_OBJ_DEF_ID
               --and rsm.CHILD_ENABLED_FLAG = 'Y'
               and   rsm.CHILD_OBJ_ID = cm_o.OBJECT_ID
               and   cm_f.FOLDER_ID = cm_o.FOLDER_ID
            order by rsm.CHILD_EXECUTION_SEQUENCE;


      /*--Get_Rule_Set_Members Cursor Fetch variables--*/
      l_Current_RuleSet_Obj_Typ_Code   DEF_RULESET_OBJECT_TYPE_CODE%TYPE;
      l_Child_Sequence_From_DB         DEF_CHILD_EXEC_SEQUENCE%TYPE;
      l_Child_Object_ID                DEF_OBJECT_ID%TYPE;
      l_Child_Object_Type_Code         DEF_OBJECT_TYPE_CODE%TYPE;
      l_Child_Object_Display_Name      DEF_OBJECT_DISPLAY_NAME%TYPE;
      l_Child_Folder_Name              DEF_FOLDER_NAME%TYPE;
      l_Execute_Child_Flag             DEF_EXECUTE_CHILD_FLAG%TYPE;
      l_Child_Local_VS_Combo_ID        DEF_LOCAL_VS_COMBO_ID%TYPE;

      /* Rule and Rule Set Flags */
      l_Valid_Member_Enabled_Status VARCHAR2(30); -- := 'NA';
      l_Other_Error_Status VARCHAR2(30); -- := 'NA';

      /* Rule Validation Flags */
      l_Valid_Rule_Def_Status VARCHAR2(30); -- := 'NA';
      l_Valid_Lock_Status VARCHAR2(30); -- := 'NA';
      l_Valid_Approval_Status VARCHAR2(30); -- := 'NA';
      l_Valid_Dep_Obj_Status VARCHAR2(30) ; --:= 'NA';
      l_Valid_Local_VS_Status VARCHAR2(30);


      l_Child_Object_Definition_ID    DEF_OBJECT_DEFINITION_ID%TYPE := 0;

      l_Current_Rule_Set_Position BINARY_INTEGER := 0;

      l_Current_Sequence NUMBER := 0;
      l_Previous_Sequence NUMBER := 0;

      l_Current_RuleType VARCHAR2(30) := 'XX';
      l_Previous_RuleType VARCHAR2(30) := 'XX';

      l_Starting_Seq_For_RS_Members NUMBER := 0; /* This is used to ensure that two Rule Set members
                                                                             having the same sequence, have their children starting
                                                   at the same sequence */

      l_Current_RuleSet_Name  FEM_OBJECT_CATALOG_TL.object_name%TYPE := 'xxx';
      l_module_name           VARCHAR2(70) := G_MODULE_NAME || 'Process_RuleSet';

      l_curr_RS               Rule_Set_Instance_Rec;

   Begin
      -- *******************************************************************************************
      -- name        :  Process_RuleSet
      -- Function    :  Master processing loop for RSM.
      --
      -- Parameters
      --
      -- IN
      --                p_Orig_RuleSet_Object_ID
      --                   -
      --                p_Curr_RuleSet_Object_ID
      --                   -
      --                p_Rule_Effective_Date
      --                   -
      --                p_Is_Output_DS_Production
      --                   -
      --                p_Execution_Mode
      --                      execution mode definitions from 'FEM_LOOKUPS' where lookup_type = 'FEM_RS_VALIDATE_TYPE_DSC'
      --                      CODE  UI parameter name       UI Parameter Description
      --                      ====  =====================   ========================================================================================
      --                      A     All Rules               Will Report on Valid and Invalid Rules in a Rule Set
      --                      E     Engine Execution Mode   Will by default report on Valid and Invalid Rules. Same as 'A' but also launches Engine
      --                      I     Invalid Rules           Will Report on Invalid Rules in a Rule Set
      --                      V     Valid Rules             Will Report on Valid Rules in a Rule Set
      --
      --                p_Output_Dataset_Code
      --                   -
      --                p_Output_Period_ID
      --                   -
      --                p_Ledger_ID
      --                   -
      --
      -- OUT
      --
      -- IN OUT
      --                l_Maximum_Sequence
      --                   -
      --                x_Rule_Set_Instance_Tab
      --                   -
      --                x_Rule_Set_Count
      --                   -
      --                x_Rule_Set_Level
      --                   -
      --                x_Members_Processed_Tab
      --                   -
      --                x_Members_Processed_Count
      --                   -
      --                p_Engine_Execution_Sequence
      --                   -
      --                p_Valid_Members_Tab
      --                   -
      --                p_Valid_Members_Count
      --                   -
      --                p_Invalid_Member_Flags_Tab
      --                   -
      --                p_Invalid_Member_Flags_Count
      --                   -
      --                p_Dependent_Objects_Tab
      --                   -
      --                p_Dependent_Objects_Count
      --                   -
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      l_Current_Rule_Set_Position := x_Rule_Set_Count;

      -- verify that the ruleSet Members cursor is open and read for business.
      If NOT Get_Rule_Set_Members%ISOPEN then
         OPEN Get_Rule_Set_Members(p_Curr_RuleSet_Object_ID);
      End If;


      LOOP

         -- ************************************************************************************
         -- ** loop on rule set entries..
         -- ** this is the master processing loop for validating/preparing rules/contained rulesets
         -- ** shown in the master ruleset.
         -- ************************************************************************************
         <<PROCESS_NEXT_RULESET_MEMBER>>

         l_Valid_Member_Enabled_Status  := 'NA';
         l_Other_Error_Status     := 'NA';

         l_Valid_Rule_Def_Status  := 'NA';
         l_Valid_Lock_Status      := 'NA';
         l_Valid_Approval_Status  := 'NA';
         l_Valid_Dep_Obj_Status   := 'NA';
         l_Valid_Local_VS_Status  := 'NA';

         FETCH Get_Rule_Set_Members
         INTO
             l_Current_RuleSet_Obj_Typ_Code
            ,l_Child_Sequence_From_DB
            ,l_Child_Object_ID
            ,l_Child_Object_Type_Code
            ,l_Child_Object_Display_Name
            ,l_Child_Folder_Name
            ,l_Execute_Child_Flag
            ,l_Child_Local_VS_Combo_ID;

         EXIT WHEN Get_Rule_Set_Members%NOTFOUND;


         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Current_RuleSet_Obj_Typ_Code->' || l_Current_RuleSet_Obj_Typ_Code);
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Child_Sequence_From_DB->' || l_Child_Sequence_From_DB);
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Child_Object_ID->' || l_Child_Object_ID);
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Child_Object_Type_Code->' || l_Child_Object_Type_Code);
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Child_Object_Display_Name->' || l_Child_Object_Display_Name);
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Child_Folder_Name->' || l_Child_Folder_Name);
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Execute_Child_Flag->' || l_Execute_Child_Flag);
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'l_Child_Local_VS_Combo_ID->' || l_Child_Local_VS_Combo_ID);

         -- simple do NOT know why this wasn't in the original cursor.. rjk
         l_Current_RuleSet_Name := GetObjectDisplayName(p_Curr_RuleSet_Object_ID);

         -- ************************************************************************************
         -- ** makes sure that this rule/ruleset entry is actually enabled in the current ruleset.
         -- ************************************************************************************
         If l_Execute_Child_Flag = 'N' then

            l_Valid_Member_Enabled_Status := G_RSM_MEMBER_DISABLED;

            --***********************************************************************
            -- p_Execution_Mode valid values......................
            -- E=Engine Execution Mode (used by engines only)
            -- A=All Rules     (report on all rules whether they are valid or not)
            -- I=Invalid Rules (report on invalid rules only)
            -- V=Valid Rules   (report on valid rules only)
            --***********************************************************************
            If (     p_Execution_Mode = 'I'
                  OR p_Execution_Mode = 'A'
                  OR p_Execution_Mode = 'E') then
               -- slap this entry into the invalid member table, shown as disabled..
               Pop_Invalid_MmbrFlags_Tbl
                           ( p_Invalid_Member_Flags_Tab
                             ,p_Invalid_Member_Flags_Count
                             ,l_Child_Folder_Name
                             ,l_Current_RuleSet_Name
                             ,l_Child_Object_ID
                             ,l_Child_Object_Display_Name
                             ,l_Child_Object_Type_Code
                             ,l_Valid_Member_Enabled_Status
                             ,l_Valid_Rule_Def_Status
                             ,l_Valid_Lock_Status
                             ,l_Valid_Approval_Status
                             ,l_Valid_Dep_Obj_Status
                             ,l_Valid_Local_VS_Status
                             ,l_Other_Error_Status);

            End If;
            -- next member plz, since the current rule is not enabled.
            GOTO PROCESS_NEXT_RULESET_MEMBER;
         ELSE
            -- otherwise show it as 'enabled' and continue to next check.
            l_Valid_Member_Enabled_Status := G_RSM_MEMBER_ENABLED;
         End If;  -- If l_Execute_Child_Flag

         --**********************************************************************
         --*****Rule Set : Check for Member processed before in current run******
         --**********************************************************************

         If Mem_Obj_Prev_Processed(p_curr_RS
                                  ,l_Child_Object_ID
                                  ,l_Child_Folder_Name
                                  ,l_Child_Object_Display_Name
                                  ,x_Members_Processed_Tab
                                  ,x_Members_Processed_Count
                                  ,l_Child_Object_Type_Code   ) then
            l_Other_Error_Status := G_RSM_MEMBER_PREV_PROCESSED;

            --***********************************************************************
            -- p_Execution_Mode valid values......................
            -- E=Engine Execution Mode (used by engines only)
            -- A=All Rules     (report on all rules whether they are valid or not)
            -- I=Invalid Rules (report on invalid rules only)
            -- V=Valid Rules   (report on valid rules only)
            --***********************************************************************
            If (     p_Execution_Mode = 'I'
                OR   p_Execution_Mode = 'A'
                OR   p_Execution_Mode = 'E') then

               -- slap this entry into the invalid member flags table, shown as already processed..
               Pop_Invalid_MmbrFlags_Tbl
                           (p_Invalid_Member_Flags_Tab
                            ,p_Invalid_Member_Flags_Count
                            ,l_Child_Folder_Name
                            ,l_Current_RuleSet_Name
                            ,l_Child_Object_ID
                            ,l_Child_Object_Display_Name
                            ,l_Child_Object_Type_Code
                            ,l_Valid_Member_Enabled_Status
                            ,l_Valid_Rule_Def_Status
                            ,l_Valid_Lock_Status
                            ,l_Valid_Approval_Status
                            ,l_Valid_Dep_Obj_Status
                            ,l_Valid_Local_VS_Status
                            ,l_Other_Error_Status);

            End If;
            GOTO PROCESS_NEXT_RULESET_MEMBER;
         Else
            l_Other_Error_Status := 'NA';
         End If; /* If Mem_Obj_Prev_Processed */

         --**********************************************************************
         --** if we are currently processing a contained ruleset, then check:
         --**     1) has it been included before?
         --**     2) Is it the same as the master ruleset passed to us?
         --**     3) are we above the maximum nesting allowed?
         --**
         --** if any of the above conditions are true, show an error!
         --**********************************************************************
         If (l_Child_Object_Type_Code = 'RULE_SET') then

            If RS_Cyclical_And_Depth_Check(l_Child_Object_ID
                                          ,l_Child_Object_Display_Name
                                          ,x_Rule_Set_Level
                                          ,x_Rule_Set_Count
                                          ,x_Rule_Set_Instance_Tab
                                          ,l_Other_Error_Status) then

               -- l_Other_Error_Status := 'Cyclical or Depth Error';

               --***********************************************************************
               -- p_Execution_Mode valid values......................
               -- E=Engine Execution Mode (used by engines only)
               -- A=All Rules     (report on all rules whether they are valid or not)
               -- I=Invalid Rules (report on invalid rules only)
               -- V=Valid Rules   (report on valid rules only)
               --***********************************************************************
               If (     p_Execution_Mode = 'I'
                   OR   p_Execution_Mode = 'A'
                   OR   p_Execution_Mode = 'E') then

                  -- slap this entry into the invalid member flags table.. we either exceeded
                  -- nesting or this ruleset has been seen before.
                  Pop_Invalid_MmbrFlags_Tbl
                              ( p_Invalid_Member_Flags_Tab
                                ,p_Invalid_Member_Flags_Count
                                ,l_Child_Folder_Name
                                ,l_Current_RuleSet_Name
                                ,l_Child_Object_ID
                                ,l_Child_Object_Display_Name
                                ,l_Child_Object_Type_Code
                                ,l_Valid_Member_Enabled_Status
                                ,l_Valid_Rule_Def_Status
                                ,l_Valid_Lock_Status
                                ,l_Valid_Approval_Status
                                ,l_Valid_Dep_Obj_Status
                                ,l_Valid_Local_VS_Status
                                ,l_Other_Error_Status);


               End If;
               --RETURN ;
               GOTO PROCESS_NEXT_RULESET_MEMBER;
            ELSE
               -- we are ok, continue on..
               l_Other_Error_Status := 'NA';
            End If;
         End If; /* If (l_Child_Object_Type_Code = 'RULE_SET') */



         --**********************************************************************
         --** this is a rule, continue with validations..
         --**********************************************************************

         If (l_Child_Object_Type_Code <> 'RULE_SET') then
            -- we know this rule is 'enabled', and not been processed yet.
            -- so validate it..
            Validate_Rule_Private(l_Child_Object_ID
                                 ,l_Child_Local_VS_Combo_ID
                                 ,p_Rule_Effective_Date
                                 ,p_IsProductionODS
                                 ,p_Output_Period_ID
                                 ,p_Ledger_ID
                                 ,p_Dependent_Objects_Tab
                                 ,p_Dependent_Objects_Count
                                 ,l_Child_Object_Definition_ID
                                 ,l_Valid_Rule_Def_Status
                                 ,l_Valid_Lock_Status
                                 ,l_Valid_Approval_Status
                                 ,l_Valid_Dep_Obj_Status
                                 ,l_Valid_Local_VS_Status);

            -- z_Err_Code will be non-0 if something bad happened
            -- in Validate_Rule_Private

            -- todo:: rationalize...
            If (z_Err_Code = 0) then
               --***********************************************************************
               -- p_Execution_Mode valid values......................
               -- E=Engine Execution Mode (used by engines only)
               -- A=All Rules     (report on all rules whether they are valid or not)
               -- I=Invalid Rules (report on invalid rules only)
               -- V=Valid Rules   (report on valid rules only)
               --***********************************************************************
               If (     p_Execution_Mode = 'V'
                   OR   p_Execution_Mode = 'A'
                   OR   p_Execution_Mode = 'E') then

                  -- it is valid and we should report on it ...
                  Populate_Valid_Member_Tab(p_Valid_Members_Tab
                                            ,p_Valid_Members_Count
                                            ,l_Child_Folder_Name
                                            ,l_Current_RuleSet_Name
                                            ,l_Child_Object_ID
                                            ,l_Child_Object_Display_Name
                                            ,l_Child_Object_Type_Code
                                            ,G_RSM_MEMBER_VALID);
               End If;
            Elsif (z_Err_Code <> 0) then
               --***********************************************************************
               -- p_Execution_Mode valid values......................
               -- E=Engine Execution Mode (used by engines only)
               -- A=All Rules     (report on all rules whether they are valid or not)
               -- I=Invalid Rules (report on invalid rules only)
               -- V=Valid Rules   (report on valid rules only)
               --***********************************************************************
               If (     p_Execution_Mode = 'I'
                    OR  p_Execution_Mode = 'A'
                    OR  p_Execution_Mode = 'E') then
                  -- slap this entry into the invalid member flags table.. we just had a
                  -- validation error.
                  Pop_Invalid_MmbrFlags_Tbl
                                 ( p_Invalid_Member_Flags_Tab
                                   ,p_Invalid_Member_Flags_Count
                                   ,l_Child_Folder_Name
                                   ,l_Current_RuleSet_Name
                                   ,l_Child_Object_ID
                                   ,l_Child_Object_Display_Name
                                   ,l_Child_Object_Type_Code
                                   ,l_Valid_Member_Enabled_Status
                                   ,l_Valid_Rule_Def_Status
                                   ,l_Valid_Lock_Status
                                   ,l_Valid_Approval_Status
                                   ,l_Valid_Dep_Obj_Status
                                   ,l_Valid_Local_VS_Status
                                   ,l_Other_Error_Status);

                  If z_continue_on_error then
                     GOTO PROCESS_NEXT_RULESET_MEMBER;
                  Else
                     RETURN;
                  End If;
               End If;
            End If; /* pseudo case: (z_Err_Code = 0), (z_Err_Code <> 0) */

         End If; /* If (l_Child_Object_Type_Code <> 'RULE_SET') */


         -- current ruleset member settings.
         l_Current_Sequence := l_Child_Sequence_From_DB;
         l_Current_RuleType := l_Child_Object_Type_Code;


         -- ??
         If (p_Engine_Execution_Sequence > l_Maximum_Sequence) then
            l_Maximum_Sequence := p_Engine_Execution_Sequence;
         End If;


         If (l_Child_Object_Type_Code = 'RULE_SET') then

            If (l_Current_RuleType <> l_Previous_RuleType) then

               -- if the previous rule member WAS NOT a rule set..
               l_Starting_Seq_For_RS_Members := p_Engine_Execution_Sequence;

            ElsIf (        (l_Current_RuleType = l_Previous_RuleType)
                     and   (l_Current_Sequence = l_Previous_Sequence) ) then
               -- if the previous rule member WAS a rule set..

               p_Engine_Execution_Sequence := l_Starting_Seq_For_RS_Members;

            End If;
            l_curr_RS.RuleSet_Object_ID   :=l_Child_Object_ID;
            l_curr_RS.Owning_RuleSet_Name :=p_curr_RS.RuleSet_Object_Name;
            l_curr_RS.RuleSet_Object_Name :=l_Child_Object_Display_Name;

            Process_RuleSet( p_Orig_RuleSet_Object_ID
                            ,l_Child_Object_ID
                            ,x_Rule_Set_Instance_Tab
                            ,x_Rule_Set_Count
                            ,x_Rule_Set_Level
                            ,x_Members_Processed_Tab
                            ,x_Members_Processed_Count
                            ,p_Rule_Effective_Date
                            ,p_IsProductionODS
                            ,p_Engine_Execution_Sequence
                            ,p_Execution_Mode
                            ,p_Valid_Members_Tab
                            ,p_Valid_Members_Count
                            ,p_Invalid_Member_Flags_Tab
                            ,p_Invalid_Member_Flags_Count
                            ,p_Dependent_Objects_Tab
                            ,p_Dependent_Objects_Count
                            ,p_Output_Dataset_Code
                            ,p_Output_Period_ID
                            ,p_Ledger_ID
                            ,l_Maximum_Sequence
                            ,l_curr_RS                   );

            --    fnd_file.put_line(FND_FILE.LOG,'Error Code after internal Process Rule Set call is : '||z_Err_Code);

            -- capture error state and react accordingly
            If (z_master_err_state = FEM_UTILS.G_RSM_FATAL_ERR ) THEN
               -- this is a backstop err capture routine.. we (hopefully) should never get here..
               RAISE FND_API.G_EXC_ERROR;

            Elsif (z_master_err_state = FEM_UTILS.G_RSM_NONFATAL_ERR) then

               If NOT z_continue_on_error then
                  -- if the caller wants to stop on error, we stop..
                  RETURN;
               End If;

            End If;

         End If; /* If (l_Child_Object_Type_Code = 'RULE_SET') */


         If (l_Child_Object_Type_Code <> 'RULE_SET') then

            If (l_Current_Sequence <> l_Previous_Sequence) then

               If (    (l_Previous_RuleType = 'RULE_SET')
                   and (p_Engine_Execution_Sequence < l_Maximum_Sequence)) then

                  p_Engine_Execution_Sequence := l_Maximum_Sequence;

               End If;

               p_Engine_Execution_Sequence := p_Engine_Execution_Sequence + 1;

            Elsif (l_Current_Sequence = l_Previous_Sequence) then

               If (l_Previous_RuleType = 'RULE_SET') then
                  p_Engine_Execution_Sequence := p_Engine_Execution_Sequence + 1;
               End If;

            End If;

            --***********************************************************************
            -- p_Execution_Mode valid values......................
            -- E=Engine Execution Mode (used by engines only)
            -- A=All Rules     (report on all rules whether they are valid or not)
            -- I=Invalid Rules (report on invalid rules only)
            -- V=Valid Rules   (report on valid rules only)
            --***********************************************************************
            If (p_Execution_Mode = 'E') then
               Create_RuleSet_Process_Data(p_Orig_RuleSet_Object_ID
                                          ,l_Child_Object_ID
                                          ,l_Child_Object_Definition_ID
                                          ,p_Engine_Execution_Sequence);

            End If;

         End If; /* If (l_Child_Object_Type_Code <> 'RULE_SET') */
         --------------------------------------------------------------------

         l_Previous_Sequence := l_Current_Sequence;
         l_Previous_RuleType := l_Current_RuleType;

      END LOOP;  /* exit point for loop */

      /* Clearing out RuleSet entry from PLSQL table once the RuleSet is processed */
      /* so that a second occurance of the same Rule Set as a child of a different Parent */
      /* Rule Set is not misinterpreted as a recursive occurrance */

      x_Rule_Set_Instance_Tab(l_Current_Rule_Set_Position).RuleSet_Object_ID := -1;

      /* Decrementing Rule_Set_Level after Rule_Set is processed so that an occurrance of */
      /* another Rule_Set at a higher level is not misinterpreted as a Rule Set in the same tree */

      x_Rule_Set_Level := x_Rule_Set_Level -1;

      CLOSE Get_Rule_Set_Members;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');


      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            -- top caller will handle this one..
            RAISE;
         WHEN OTHERS THEN
            -- todo:: useful?? z_Err_Code := -1;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);
            RAISE ;

   End Process_RuleSet;




   Procedure Log_Rule_Status(p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
                             ,p_Valid_Rule_Def_Status IN VARCHAR2
                             ,p_Valid_Lock_Status IN VARCHAR2
                             ,p_Valid_Local_VS_Status IN VARCHAR2
                             ,p_Valid_Approval_Status IN VARCHAR2
                             ,p_Valid_Dep_Obj_Status IN VARCHAR2
                             ,p_Dependent_Objects_Tab IN Dependent_Objects_Tab
                             ,p_Dependent_Objects_Count IN BINARY_INTEGER) IS

      l_Rule_Display_Name DEF_OBJECT_DISPLAY_NAME%TYPE;
      l_Rule_Folder_Name       DEF_FOLDER_NAME%TYPE;
      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'Log_Rule_Status';

   Begin
      -- *******************************************************************************************
      -- name        :  Log_Rule_Status
      -- Function    :  print report to pertinent log.
      --
      -- Parameters
      -- IN
      --
      --                p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
      --                   -
      --                p_Valid_Rule_Def_Status IN VARCHAR2
      --                   -
      --                p_Valid_Lock_Status IN VARCHAR2
      --                   -
      --                p_Valid_Local_VS_Status IN VARCHAR2
      --                   -
      --                p_Valid_Approval_Status IN VARCHAR2
      --                   -
      --                p_Valid_Dep_Obj_Status IN VARCHAR2
      --                   -
      --                p_Dependent_Objects_Tab IN Dependent_Objects_Tab
      --                   -
      --                p_Dependent_Objects_Count IN BINARY_INTEGER
      --                   -
      -- OUT
      --
      -- IN OUT
      --
      --
      --
      -- HISTORY
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');

      GetObjectDisplayNameandFolder(p_Rule_Object_ID
                                   ,l_Rule_Display_Name
                                   ,l_Rule_Folder_Name);

      fnd_file.put_line(FND_FILE.OUTPUT
                         ,RPAD('Rule Name',42,' ')
                        ||RPAD('Folder',32,' ')
                        ||RPAD('Rule Def',32,' ')
                        ||RPAD('Lock Status',13,' ')
                        ||RPAD('Local VS Status',17,' ')
                        ||RPAD('Approval Status',17,' ')
                        ||RPAD('Dependent Status',18,' ')
                         );

      fnd_file.put_line(FND_FILE.OUTPUT
                         ,RPAD('---------',42,' ')
                        ||RPAD('------',32,' ')
                        ||RPAD('---------------------',32,' ')
                        ||RPAD('-----------',13,' ')
                        ||RPAD('---------------',17,' ')
                        ||RPAD('---------------',17,' ')
                        ||RPAD('----------------',18,' ')
                         );

      fnd_file.put_line(FND_FILE.OUTPUT
                         ,RPAD(l_Rule_Display_Name,42,' ')
                        ||RPAD(l_Rule_Folder_Name,32,' ')
                        ||RPAD(p_Valid_Rule_Def_Status,32,' ')
                        ||RPAD(p_Valid_Lock_Status,13,' ')
                        ||RPAD(p_Valid_Local_VS_Status,17,' ')
                        ||RPAD(p_Valid_Approval_Status,17,' ')
                        ||RPAD(p_Valid_Dep_Obj_Status,18,' ')
                         );

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

   End Log_Rule_Status;


   Procedure Validate_Rule_Public(x_Err_Code OUT NOCOPY NUMBER
                                 ,x_Err_Msg  OUT NOCOPY VARCHAR2
                                 ,p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
                                 ,p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                                 ,p_Rule_Effective_Date IN VARCHAR2
                                 ,p_Reference_Period_ID IN NUMBER
                                 ,p_Ledger_ID IN NUMBER) IS

      l_module_name           VARCHAR2(70) := G_MODULE_NAME || 'Validate_Rule_Public';
      l_Output_Dataset_Code   NUMBER(9):= NULL;
      l_Output_Dataset_Name   VARCHAR2(120) := NULL;
--      l_Is_Output_DS_Production VARCHAR2(1) := NULL;
      l_isProductionODS       BOOLEAN := FALSE;

      l_Dependent_Objects_Tab    Dependent_Objects_Tab;
      l_Dependent_Objects_Count  BINARY_INTEGER := 0;

      /* Rule Validation Flags */
      l_Valid_Rule_Def_Status VARCHAR2(30) := ' ';
      l_Valid_Lock_Status VARCHAR2(30) := ' ';
      l_Valid_Approval_Status VARCHAR2(30) := ' ';
      l_Valid_Dep_Obj_Status VARCHAR2(30) := ' ';
      l_Valid_Local_VS_Status VARCHAR2(30) := ' ';

      l_Rule_Obj_Def_ID DEF_OBJECT_DEFINITION_ID%TYPE;

      l_Rule_Local_VSCID DEF_LOCAL_VS_COMBO_ID%TYPE;

      l_Rule_Effective_Date   DATE;
      l_TEMP                  NUMBER;

   Begin
      -- *******************************************************************************************
      -- name        :  Validate_Rule_Public
      -- Function    :  Verify that:
      --                   1) Local VS Combo ID for LEDGER_ID matches the rule..
      --                   2) If the dataset in use is production, that the ruleis production.
      --                   3) call our internal private validation routine (Validate_Rule_Private)
      --                Log this via a call to Log_Rule_Status
      --
      -- Parameters
      --                p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
      --                   -
      --                p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
      --                   -
      --                p_Rule_Effective_Date IN VARCHAR2
      --                   -
      --                p_Reference_Period_ID IN NUMBER
      --                   -
      --                p_Ledger_ID IN NUMBER
      --                   -
      --
      -- OUT
      --
      --                x_Err_Code OUT NUMBER
      --                   -
      --                x_Err_Msg  OUT VARCHAR2
      --                   -
      -- IN OUT
      --
      --
      --
      -- HISTORY
      --    27-Jun-2006    dyung    removed 'raise' from the exception
      --                            handling and added a savepoint for the
      --                            rollback.
      --    05-Jan-2004    rjking   comment header added, reformatted and commented.
      --
      -- *******************************************************************************************
      SAVEPOINT Validate_Rule_Public_SvPt;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY: p_Rule_Object_ID = '||p_Rule_Object_ID);

      l_Rule_Effective_Date := FND_DATE.CANONICAL_TO_DATE(p_Rule_Effective_Date);

      z_Err_Code := 0;

      -- fetch the local value set associated with the p_Ledger_ID we were passed.
      Begin
         -- todo:: fix to new standards ??
         z_local_vs_for_session := fem_dimension_util_pkg.Local_VS_Combo_ID
                                          ( p_Ledger_ID
                                            , z_Err_Code
                                            ,l_TEMP);

         If (z_local_vs_for_session = -1) then
            -- todo:: fix to new standards..
            RAISE USER_EXCEPTION;
         End If;
      End;


      -- now compare the local value set combo ID of the rule in question with
      -- the fetched local value set combo ID associated with the p_Ledger_ID passed to us.
      Begin
         -- get rule's local value set combo ID
         select   local_vs_combo_id
            into  l_Rule_Local_VSCID
            from  Fem_Object_Catalog_B
            where object_id = p_Rule_Object_ID;

         -- if the rule's local value set id doesn't match the one for the ledger, its BAD.
         If (l_Rule_Local_VSCID <> z_local_vs_for_session) then
            z_Err_Code := 9;
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_NONFATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_NO_VALID_VALSETS,
                                                G_ERRMAC_RULE_NAME,
                                                GetObjectDisplayName(p_Rule_Object_ID)
                                                );
            z_Err_Msg  := G_INVALID_LVSCID_ON_OBJECT;
            -- todo:: fix to new standards..
            RAISE USER_EXCEPTION;
         End If;

      End;

      l_isProductionODS := IsProductionODS(   p_DS_IO_Def_ID
                                             ,l_Output_Dataset_Name
                                             ,l_Output_Dataset_Code  );

      -- if we found the output data set in question..
      If (NOT z_dataset_error) then

         -- then run further validations..
         Validate_Rule_Private(  p_Rule_Object_ID
                                 ,l_Rule_Local_VSCID
                                 ,l_Rule_Effective_Date
                                 ,l_isProductionODS
                                 ,p_Reference_Period_ID
                                 ,p_Ledger_ID
                                 ,l_Dependent_Objects_Tab
                                 ,l_Dependent_Objects_Count
                                 ,l_Rule_Obj_Def_ID
                                 ,l_Valid_Rule_Def_Status
                                 ,l_Valid_Lock_Status
                                 ,l_Valid_Approval_Status
                                 ,l_Valid_Dep_Obj_Status
                                 ,l_Valid_Local_VS_Status);

      Else
         z_Err_Code := 10;
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_DSGRP_NOT_FOUND );
         z_Err_Msg  := G_INVALID_DATASET_GROUP;
         -- todo:: fix to new standards..
         RAISE USER_EXCEPTION;
      End If;

      Log_Rule_Status(  p_Rule_Object_ID
                        ,l_Valid_Rule_Def_Status
                        ,l_Valid_Lock_Status
                        ,l_Valid_Local_VS_Status
                        ,l_Valid_Approval_Status
                        ,l_Valid_Dep_Obj_Status
                        ,l_Dependent_Objects_Tab
                        ,l_Dependent_Objects_Count);

      If (l_Valid_Dep_Obj_Status = G_RSM_DEP_OBJECTS_INVALID) then
         Log_Dep_Status_For_Single_Rule(  p_Rule_Object_ID
                                          ,l_Dependent_Objects_Tab
                                          ,l_Dependent_Objects_Count);
      End If;

      x_Err_Code := z_Err_Code;
      x_Err_Msg  := z_Err_Msg;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      EXCEPTION
         WHEN USER_EXCEPTION THEN
            x_Err_Code := z_Err_Code;
            x_Err_Msg  := z_Err_Msg;
           -- todo:: fix to new standards
            fem_engines_pkg.user_message(p_msg_text =>
z_Err_Code||':'||z_Err_Msg);
            fnd_file.put_line(FND_FILE.OUTPUT,z_Err_Msg);
            ROLLBACK TO Validate_Rule_Public_SvPt;
         WHEN OTHERS THEN
            x_Err_Code := -1;
            -- todo:: this is a main I/F procedure and should conform to the 'new way of thinking'.
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_UNEXPECTED_SQLERROR,
                                                G_ERRMAC_ROUTINE_NAME,
                                                l_module_name,
                                                NULL,
                                                G_ERRMAC_SQL_ERROR,
                                                SQLERRM);

   End Validate_Rule_Public;



   Procedure Validate_Rule_Public(p_api_version IN NUMBER
                                 ,p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
                                 ,p_encoded IN VARCHAR2 := FND_API.G_TRUE
                                 ,p_Rule_Object_ID IN DEF_OBJECT_ID%TYPE
                                 ,p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                                 ,p_Rule_Effective_Date IN VARCHAR2
                                 ,p_Reference_Period_ID IN NUMBER
                                 ,p_Ledger_ID IN NUMBER
                                 ,x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count OUT NOCOPY NUMBER
                                 ,x_msg_data OUT NOCOPY VARCHAR2) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Validate_Rule_Public';
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_Err_Code               NUMBER       := 0;
      l_Err_Msg                VARCHAR2(30) := NULL;

   Begin
      -- *******************************************************************************************
      -- name        :  Validate_Rule_Public
      -- Function    :  Standards-compliant wrapper around Validate_Rule_Public
      --
      -- HISTORY
      --    27-Jun-2006    dyung    initial version
      --
      -- *******************************************************************************************
      IF NOT FND_API.Compatible_API_Call(l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME)
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.to_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.Initialize;
      END IF;

      Validate_Rule_Public(l_Err_Code
                          ,l_Err_Msg
                          ,p_Rule_Object_ID
                          ,p_DS_IO_Def_ID
                          ,p_Rule_Effective_Date
                          ,p_Reference_Period_ID
                          ,p_Ledger_ID);

      -- any errors in Validate_Rule_Public should be on the message stack
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded, p_count => x_msg_count,
p_data => x_msg_data);

      IF (l_Err_Code > 0) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
	 IF (l_Err_Code = 0) THEN
	    x_return_status := FND_API.G_RET_STS_SUCCESS;
	 ELSE
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 END IF;
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded, p_count => x_msg_count, p_data => x_msg_data);

   End Validate_Rule_Public;




   Procedure Preprocess_RuleSet( x_Err_Code OUT NOCOPY NUMBER
                                ,x_Err_Msg OUT NOCOPY VARCHAR2
                                ,p_Orig_RuleSet_Object_ID IN DEF_OBJECT_ID%TYPE
                                ,p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
                                ,p_Rule_Effective_Date IN VARCHAR2
                                ,p_Output_Period_ID IN NUMBER
                                ,p_Ledger_ID IN NUMBER
                                ,p_Continue_Process_On_Err_Flg IN VARCHAR2
                                ,p_Execution_Mode IN VARCHAR2
                                ) IS

      l_Rule_Set_Instance_Tab          Rule_Set_Instance_Tab;
      l_Rule_Set_Count                BINARY_INTEGER := 0;
      l_Rule_Set_Level                NUMBER := 0;

      l_Members_Processed_Tab         Members_Processed_Instance_Tab;
      l_Members_Processed_Count       BINARY_INTEGER := 0;

      l_Valid_Members_Tab             Valid_Invalid_Members_Inst_Tab;
      l_Valid_Members_Count           BINARY_INTEGER := 0;

      l_Invalid_Member_Flags_Tab      Members_Validation_Status_Tab;
      l_Invalid_Member_Flags_Count    BINARY_INTEGER := 0;

      l_Dependent_Objects_Tab         Dependent_Objects_Tab;
      l_Dependent_Objects_Count       BINARY_INTEGER := 0;

      l_Engine_Execution_Sequence     NUMBER  := 0;

      l_Output_Dataset_Name           VARCHAR2(120) := NULL;
      l_Output_Dataset_Code           NUMBER(9) := NULL;
      l_IsProductionODS               BOOLEAN     := FALSE;

      l_Rule_Effective_Date           DATE;
      l_RuleSet_LocalVSComboID        NUMBER;

      l_Maximum_Sequence NUMBER := 0; /*---Keeps track of the maximum sequence of
                                           members of a given Rule Set member. */
      l_TEMP                          NUMBER;

      l_curr_RS                        Rule_Set_Instance_Rec;
   Begin
    -- *******************************************************************************************
    -- name        :  Preprocess_RuleSet
    -- Function    :  Entry point for RSM.
    --
    -- Parameters
    -- IN
    --                p_Orig_RuleSet_Object_ID IN DEF_OBJECT_ID%TYPE
    --                   -
    --                p_DS_IO_Def_ID IN DEF_OBJECT_DEFINITION_ID%TYPE
    --                   -
    --                p_Rule_Effective_Date IN VARCHAR2
    --                   -
    --                p_Output_Period_ID IN NUMBER
    --                   -
    --                p_Ledger_ID IN NUMBER
    --                   -
    --                p_Continue_Process_On_Err_Flg IN VARCHAR2
    --                   -
    --                p_Execution_Mode IN VARCHAR2
    --                   execution mode definitions from DB
    --                   CODE  UI parameter name       UI Parameter Description
    --                   ====  =====================   ========================================================================================
    --                   A     All Rules               Will Report on Valid and Invalid Rules in a Rule Set
    --                   E     Engine Execution Mode   Will by default report on Valid and Invalid Rules. Same as 'A' but also launches Engine
    --                   I     Invalid Rules           Will Report on Invalid Rules in a Rule Set
    --                   V     Valid Rules             Will Report on Valid Rules in a Rule Set
    --
    -- OUT
    --                x_Err_Code OUT NUMBER
    --                   -
    --                x_Err_Msg OUT VARCHAR2
    --                   -
    --
    -- IN OUT
    --
    --
    --
    -- HISTORY
    --    05-Jan-2004    rjking   comment header added, reformatted and commented.
    --
    -- *******************************************************************************************

      reset_master_err_state;
      z_Err_Code := 0;

      Begin
         z_local_vs_for_session := fem_dimension_util_pkg.Local_VS_Combo_ID
                                           (p_Ledger_ID
                                           ,z_Err_Code
                                           ,l_TEMP);
         If (z_local_vs_for_session = -1) then
            RAISE USER_EXCEPTION;
         End If;
      End;

      Begin /*--Check Local VS of Rule Set being run --*/
         select local_vs_combo_id
            into  l_RuleSet_LocalVSComboID
            from  Fem_Object_Catalog_B
            where object_id = p_Orig_RuleSet_Object_ID;
         If (l_RuleSet_LocalVSComboID <> z_local_vs_for_session) then
            z_Err_Code := 9;
            z_Err_Msg  := G_INVALID_LVSCID_ON_OBJECT;
            RAISE USER_EXCEPTION;
         End If;
      End;

      Begin
         l_Rule_Effective_Date := FND_DATE.CANONICAL_TO_DATE(p_Rule_Effective_Date);
      End;

      l_Rule_Set_Instance_Tab(l_Rule_Set_Count).RuleSet_Object_ID := p_Orig_RuleSet_Object_ID;
      l_Rule_Set_Instance_Tab(l_Rule_Set_Count).RuleSet_Object_Name := GetObjectDisplayName(p_Orig_RuleSet_Object_ID);
      l_Rule_Set_Instance_Tab(l_Rule_Set_Count).Owning_RuleSet_Name := '';

      l_curr_RS.RuleSet_Object_ID   :=p_Orig_RuleSet_Object_ID;
      l_curr_RS.RuleSet_Object_Name :=l_Rule_Set_Instance_Tab(l_Rule_Set_Count).RuleSet_Object_Name;
      l_curr_RS.Owning_RuleSet_Name :='';


      If (p_DS_IO_Def_ID is NOT NULL) then
         l_IsProductionODS := IsProductionODS
                                            (p_DS_IO_Def_ID
                                            ,l_Output_Dataset_Name
                                            ,l_Output_Dataset_Code
                                            );
      End If;

      If (NOT z_dataset_error) then
         Process_RuleSet (  p_Orig_RuleSet_Object_ID
                           ,p_Orig_RuleSet_Object_ID
                           ,l_Rule_Set_Instance_Tab
                           ,l_Rule_Set_Count
                           ,l_Rule_Set_Level
                           ,l_Members_Processed_Tab
                           ,l_Members_Processed_Count
                           ,l_Rule_Effective_Date
                           ,l_IsProductionODS
                           ,l_Engine_Execution_Sequence
                           ,p_Execution_Mode
                           ,l_Valid_Members_Tab
                           ,l_Valid_Members_Count
                           ,l_Invalid_Member_Flags_Tab
                           ,l_Invalid_Member_Flags_Count
                           ,l_Dependent_Objects_Tab
                           ,l_Dependent_Objects_Count
                           ,l_Output_Dataset_Code
                           ,p_Output_Period_ID
                           ,p_Ledger_ID
                           ,l_Maximum_Sequence
                           ,l_curr_RS);
      Else
         z_Err_Code := 10;
         z_Err_Msg  := G_INVALID_DATASET_GROUP;
         RAISE USER_EXCEPTION;
      End If;

      Write_Output(  l_Valid_Members_Tab
                     ,l_Valid_Members_Count
                     ,l_Invalid_Member_Flags_Tab
                     ,l_Invalid_Member_Flags_Count
                     ,l_Dependent_Objects_Tab
                     ,l_Dependent_Objects_Count
                     ,p_Orig_RuleSet_Object_ID
                     ,l_Rule_Effective_Date
                     ,l_Output_Dataset_Name
                     ,l_IsProductionODS
                     ,p_Execution_Mode);

      If (p_Continue_Process_On_Err_Flg = 'Y') then
         If (z_Err_Code <> -1 and z_Err_Code <> 2 and z_Err_Code <> 3) then
            z_Err_Code := 0;
            z_Err_Msg  := NULL;
         End If;
      End If;

      x_Err_Code := z_Err_Code;
      x_Err_Msg  := z_Err_Msg;

      EXCEPTION
         WHEN USER_EXCEPTION THEN
            x_Err_Code := z_Err_Code;
            x_Err_Msg  := z_Err_Msg;
            fem_engines_pkg.user_message(p_msg_text => z_Err_Code||':'||z_Err_Msg);
            fnd_file.put_line(FND_FILE.OUTPUT,z_Err_Code||':'||z_Err_Msg);
            rollback;
            RETURN;

         WHEN OTHERS THEN
            z_Err_Code := -1;
            z_Err_Msg  := 'Preprocess_RuleSet :'||SQLERRM;
            fem_engines_pkg.user_message(p_msg_text => z_Err_Msg);
            rollback;
            RAISE;

   End Preprocess_RuleSet;


   -- *******************************************************************************************
   -- API name    : FEM_DeleteFlatRuleList_PVT
   -- Type        : Private
   -- Pre-reqs    : None
   -- Function    :  1) delete all rules associated with the current request ID and ruleset ObjID
   --                2) Report all errors that occur during the conversion that are not
   --                   covered by the UI validation routines
   --
   --
   -- Parameters
   -- IN
   --                p_api_version                 IN    NUMBER
   --                      Current version of this API
   --                p_init_msg_list               IN    VARCHAR2 := FND_API.G_FALSE
   --                      If set to:
   --                         FND_API.G_TRUE    - Initialize FND_MSG_PUB
   --                         FND_API.G_FALSE   - DO NOT Initialize FND_MSG_PUB
   --                p_commit                      IN    VARCHAR2 := FND_API.G_FALSE
   --                      If set to:
   --                         FND_API.G_TRUE    - Commit data at exit of this routine
   --                         FND_API.G_FALSE   - DO NOT commit data at exit of this routine
   --                p_Orig_RuleSet_Object_ID      IN    DEF_OBJECT_ID%TYPE
   --                      the object id associated with the list to delete.
   --
   --
   -- OUT
   --                x_return_status               OUT   VARCHAR2
   --                      Possible return status:
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
   -- Version: Current Version   1.0
   --
   --                            Previous version  N/A
   --                            Initial version   1.0
   -- *******************************************************************************************
   PROCEDURE FEM_DeleteFlatRuleList_PVT(
                                 p_api_version                 IN             NUMBER
                                ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                                ,p_commit                      IN             VARCHAR2 := FND_API.G_FALSE
                                ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                                ,x_return_status               OUT   NOCOPY   VARCHAR2
                                ,x_msg_count                   OUT   NOCOPY   NUMBER
                                ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                                ,p_RuleSet_Object_ID  IN             DEF_OBJECT_ID%TYPE
                                )
   IS
      l_api_version                    NUMBER := 1.0;
      l_api_name                       CONSTANT VARCHAR2(27)   := 'FEM_Preprocess_RuleSet_PVT';
      l_module_name                    VARCHAR2(70)            := G_MODULE_NAME || l_api_name;

   BEGIN
      -- the infamous preamble..
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTER');

      -- initialize our status to 'we are good!'
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- setup save point for rollbacks..
      SAVEPOINT FEM_DeleteFlatRuleList_SvPt;

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

      -- and on to the real code...
      DELETE FROM fem_ruleset_process_DATA
            WHERE       request_id = FND_GLOBAL.CONC_REQUEST_ID
                  AND   rule_set_obj_id = p_RuleSet_Object_ID;


      -- and the required post work code...
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      FND_MSG_PUB.Count_And_Get ( p_encoded,
                                  x_msg_count,
                                  x_msg_data );

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

            ROLLBACK TO FEM_DeleteFlatRuleList_SvPt;

            FND_MSG_PUB.Count_And_Get ( p_encoded,
                                        x_msg_count,
                                        x_msg_data );

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END FEM_DeleteFlatRuleList_PVT;


   -- *******************************************************************************************
   -- API name    : FEM_Preprocess_RuleSet_PVT
   -- Type        : Private
   -- Pre-reqs    : None
   -- Function    :  1) convert a rule set into a flat structure prior to engine processing
   --                2) Report all errors that occur during the conversion that are not
   --                   covered by the UI validation routines
   --
   --
   -- Parameters
   -- IN
   --                p_api_version                 IN    NUMBER
   --                      Current version of this API
   --                p_init_msg_list               IN    VARCHAR2 := FND_API.G_FALSE
   --                      If set to:
   --                         FND_API.G_TRUE    - Initialize FND_MSG_PUB
   --                         FND_API.G_FALSE   - DO NOT Initialize FND_MSG_PUB
   --                p_commit                      IN    VARCHAR2 := FND_API.G_FALSE
   --                      If set to:
   --                         FND_API.G_TRUE    - Commit data at exit of this routine
   --                         FND_API.G_FALSE   - DO NOT commit data at exit of this routine
   --                p_Orig_RuleSet_Object_ID      IN    DEF_OBJECT_ID%TYPE
   --
   --                p_DS_IO_Def_ID                IN    DEF_OBJECT_DEFINITION_ID%TYPE
   --
   --                p_Rule_Effective_Date         IN    VARCHAR2
   --
   --                p_Output_Period_ID            IN    NUMBER
   --
   --                p_Ledger_ID                   IN    NUMBER
   --
   --                p_Continue_Process_On_Err_Flg IN    VARCHAR2
   --                      if set to:
   --                         'Y' - continue processing except on extreme fatal errors
   --                         'N' - stop on first non-fatal
   --
   --                p_Execution_Mode              IN    VARCHAR2
   --
   --                      execution mode definitions from 'FEM_LOOKUPS' where lookup_type = 'FEM_RS_VALIDATE_TYPE_DSC'
   --                      CODE  UI parameter name       UI Parameter Description
   --                      ====  =====================   ========================================================================================
   --                      A     All Rules               Will Report on Valid and Invalid Rules in a Rule Set
   --                      E     Engine Execution Mode   Will by default report on Valid and Invalid Rules. Same as 'A' but also launches Engine
   --                      I     Invalid Rules           Will Report on Invalid Rules in a Rule Set
   --                      V     Valid Rules             Will Report on Valid Rules in a Rule Set
   --
   --                      The value passed to this routine is the value from the CODE column.
   --
   --
   -- OUT
   --                x_return_status               OUT   VARCHAR2
   --                      Possible return status:
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
   -- Version: Current Version   1.0
   --
   --                            Previous version  N/A
   --                            Initial version   1.0
   -- *******************************************************************************************

   PROCEDURE FEM_Preprocess_RuleSet_PVT(
                                 p_api_version                 IN             NUMBER
                                ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                                ,p_commit                      IN             VARCHAR2 := FND_API.G_FALSE
                                ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                                ,x_return_status               OUT   NOCOPY   VARCHAR2
                                ,x_msg_count                   OUT   NOCOPY   NUMBER
                                ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                                ,p_Orig_RuleSet_Object_ID      IN             DEF_OBJECT_ID%TYPE
                                ,p_DS_IO_Def_ID                IN             DEF_OBJECT_DEFINITION_ID%TYPE
                                ,p_Rule_Effective_Date         IN             VARCHAR2
                                ,p_Output_Period_ID            IN             NUMBER
                                ,p_Ledger_ID                   IN             NUMBER
                                ,p_Continue_Process_On_Err_Flg IN             VARCHAR2
                                ,p_Execution_Mode              IN             VARCHAR2
                                )
   IS
      -- STANDARD STUFF
      l_api_version                    NUMBER := 1.0;
      l_api_name                       CONSTANT VARCHAR2(27)   := 'FEM_Preprocess_RuleSet_PVT';
      l_module_name                    VARCHAR2(70)            := G_MODULE_NAME || l_api_name;

      l_Rule_Set_Instance_Tab          Rule_Set_Instance_Tab;
      l_Rule_Set_Count                 BINARY_INTEGER := 0;
      l_Rule_Set_Level                 NUMBER := 0;

      l_Members_Processed_Tab          Members_Processed_Instance_Tab;
      l_Members_Processed_Count        BINARY_INTEGER := 0;

      l_Valid_Members_Tab              Valid_Invalid_Members_Inst_Tab;
      l_Valid_Members_Count            BINARY_INTEGER := 0;

      l_Invalid_Member_Flags_Tab       Members_Validation_Status_Tab;
      l_Invalid_Member_Flags_Count     BINARY_INTEGER := 0;

      l_Dependent_Objects_Tab          Dependent_Objects_Tab;
      l_Dependent_Objects_Count        BINARY_INTEGER := 0;

      l_Engine_Execution_Sequence      NUMBER  := 0;

      l_Output_Dataset_Name            VARCHAR2(120) := NULL;
      l_Output_Dataset_Code            NUMBER(9) := NULL;

      l_IsProductionODS                BOOLEAN     := FALSE;

      l_Rule_Effective_Date            DATE;
      l_RuleSet_LocalVSComboID         NUMBER;

      -- Keeps track of the maximum sequence of
      -- members of a given Rule Set member.
      l_Maximum_Sequence               NUMBER := 0;
      l_TEMP                           NUMBER;

      l_curr_RS                        Rule_Set_Instance_Rec;


   BEGIN
      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'ENTRY');
      reset_master_err_state;
      z_dataset_error := FALSE;

      -------------------------------------------------------
      -- standard API support header ------------------------
      -------------------------------------------------------

      -- initialize our status to 'we are good!'
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- setup save point for rollbacks..
      SAVEPOINT FEM_Preprocess_RuleSet_SvPt;


      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_api_version(' || p_api_version || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_init_msg_list(' || p_init_msg_list || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_commit(' || p_commit || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_encoded(' || p_encoded || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Orig_RuleSet_Object_ID(' || p_Orig_RuleSet_Object_ID || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_DS_IO_Def_ID(' || p_DS_IO_Def_ID || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Rule_Effective_Date(' || p_Rule_Effective_Date || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Output_Period_ID(' || p_Output_Period_ID || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Ledger_ID(' || p_Ledger_ID || ')');
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_Execution_Mode(' || p_Execution_Mode || ')');


      -- initialize msg stack?
      IF fnd_api.to_Boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      -- since this interface is PVT, this use is trusted and error capture
      -- is minimal..
      IF p_Continue_Process_On_Err_Flg = 'N' THEN
         z_continue_on_error := FALSE;
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'z_continue_on_error := FALSE');
      ELSE
         z_continue_on_error := TRUE;
         fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                      p_module=> l_module_name,
                                      p_msg_text=> 'z_continue_on_error := TRUE');
      END IF;

      -- check API version...
      IF NOT fnd_api.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -------------------------------------------------------
      -- end of standard API support header -----------------
      -------------------------------------------------------

      -- todo:: most likely bye-bye
      z_Err_Code := 0;

      z_local_vs_for_session := fem_dimension_util_pkg.Local_VS_Combo_ID
                                        (p_Ledger_ID
                                        ,z_Err_Code
                                        ,l_TEMP);
      If (z_local_vs_for_session = -1) then
         -- todo:: unknown error in Local_VS_Combo_ID call.. report as such

         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_FATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_NO_DSG_FOR_LID  );

         -- this one is bad.. our master rule/ruleset has an invalid VS combo ID.. bomb out now
         RAISE FND_API.G_EXC_ERROR;
      End If;

      Begin /*--Check Local VS of Rule Set being run --*/
         select local_vs_combo_id
            into  l_RuleSet_LocalVSComboID
            from  Fem_Object_Catalog_B
            where object_id = p_Orig_RuleSet_Object_ID;
         If (l_RuleSet_LocalVSComboID <> z_local_vs_for_session) then

            -- originally error number's 8 and 9.
            FEM_UTILS.set_master_err_state( z_master_err_state,
                                                FEM_UTILS.G_RSM_FATAL_ERR,
                                                G_APP_NAME,
                                                G_ERRMSG_NO_VALID_VALSETS,
                                                G_ERRMAC_RULE_NAME,
                                                GetObjectDisplayName(p_Orig_RuleSet_Object_ID));

            RAISE FND_API.G_EXC_ERROR;
         End If;
      End;

      l_Rule_Effective_Date := FND_DATE.CANONICAL_TO_DATE(p_Rule_Effective_Date);


      l_Rule_Set_Instance_Tab(l_Rule_Set_Count).RuleSet_Object_ID   := p_Orig_RuleSet_Object_ID;
      l_Rule_Set_Instance_Tab(l_Rule_Set_Count).RuleSet_Object_Name := GetObjectDisplayName(p_Orig_RuleSet_Object_ID);
      l_Rule_Set_Instance_Tab(l_Rule_Set_Count).Owning_RuleSet_Name := '';

      -- tracking for RS that is currently being processed.
      l_curr_RS.RuleSet_Object_ID   :=p_Orig_RuleSet_Object_ID;
      l_curr_RS.RuleSet_Object_Name :=l_Rule_Set_Instance_Tab(l_Rule_Set_Count).RuleSet_Object_Name;
      l_curr_RS.Owning_RuleSet_Name :='';

      If (p_DS_IO_Def_ID is NOT NULL) then
         l_IsProductionODS := IsProductionODS( p_DS_IO_Def_ID
                                                      ,l_Output_Dataset_Name
                                                      ,l_Output_Dataset_Code );
      End If;

      If (NOT z_dataset_error) then
         Process_RuleSet (  p_Orig_RuleSet_Object_ID
                           ,p_Orig_RuleSet_Object_ID
                           ,l_Rule_Set_Instance_Tab
                           ,l_Rule_Set_Count
                           ,l_Rule_Set_Level
                           ,l_Members_Processed_Tab
                           ,l_Members_Processed_Count
                           ,l_Rule_Effective_Date
                           ,l_IsProductionODS
                           ,l_Engine_Execution_Sequence
                           ,p_Execution_Mode
                           ,l_Valid_Members_Tab
                           ,l_Valid_Members_Count
                           ,l_Invalid_Member_Flags_Tab
                           ,l_Invalid_Member_Flags_Count
                           ,l_Dependent_Objects_Tab
                           ,l_Dependent_Objects_Count
                           ,l_Output_Dataset_Code
                           ,p_Output_Period_ID
                           ,p_Ledger_ID
                           ,l_Maximum_Sequence
                           ,l_curr_RS              );

         Write_Output(  l_Valid_Members_Tab
                        ,l_Valid_Members_Count
                        ,l_Invalid_Member_Flags_Tab
                        ,l_Invalid_Member_Flags_Count
                        ,l_Dependent_Objects_Tab
                        ,l_Dependent_Objects_Count
                        ,p_Orig_RuleSet_Object_ID
                        ,l_Rule_Effective_Date
                        ,l_Output_Dataset_Name
                        ,l_IsProductionODS
                        ,p_Execution_Mode);

      ELSE
         -- originally error # '10'
         FEM_UTILS.set_master_err_state( z_master_err_state,
                                             FEM_UTILS.G_RSM_NONFATAL_ERR,
                                             G_APP_NAME,
                                             G_ERRMSG_DSGRP_NOT_FOUND );
         RAISE FND_API.G_EXC_ERROR;
      End If;

      -- For fatal errors, force a rollback and get out..
      IF (z_master_err_state = FEM_UTILS.G_RSM_FATAL_ERR) THEN
         RAISE FND_API.G_EXC_ERROR;
      -- For nonfatal errors, report error if "continue to process on error"
      -- is set to No.  In either case, do not rollback what was stored
      -- in fem_ruleset_process_data so the engines can run.
      -- Ideally, we want to differentiate between a fatal and nonfatal error
      -- but since the FND API Standard has only one expected error code,
      -- we have to continue to report error for the same cases as before this
      -- change for backward compatability.
      ELSIF ((z_master_err_state = FEM_UTILS.G_RSM_NONFATAL_ERR) AND
             (NOT z_continue_on_error)) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      -------------------------------------------------------
      -- standard API support
      -------------------------------------------------------
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_PROCEDURE ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'EXIT');

      FND_MSG_PUB.Count_And_Get ( p_encoded,
                                  x_msg_count,
                                  x_msg_data );

      EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO FEM_Preprocess_RuleSet_SvPt;
            FND_MSG_PUB.Count_And_Get ( p_encoded,
                                        x_msg_count,
                                        x_msg_data );
            x_return_status := FND_API.G_RET_STS_ERROR;


         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO FEM_Preprocess_RuleSet_SvPt;
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

            ROLLBACK TO FEM_Preprocess_RuleSet_SvPt;

            FND_MSG_PUB.Count_And_Get ( p_encoded,
                                        x_msg_count,
                                        x_msg_data );

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


   END FEM_Preprocess_RuleSet_PVT;


End FEM_RULE_SET_MANAGER;

/
