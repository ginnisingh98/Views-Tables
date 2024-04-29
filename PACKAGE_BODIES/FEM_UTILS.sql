--------------------------------------------------------
--  DDL for Package Body FEM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_UTILS" AS
--$Header: FEMUTILB.pls 120.0.12010000.2 2008/10/10 22:23:00 huli ship $
--=============================================================================


   --                                          000000000111111111122222222223333333333444444444455555555556
   --                                          123456789012345678901234567890123456789012345678901234567890
   G_APP_NAME        CONSTANT VARCHAR2(4)  := 'FEM';
   G_PKG_NAME        CONSTANT VARCHAR2(25) := 'FEM_UTILS';
   G_MODULE_NAME     CONSTANT VARCHAR2(40) := 'fem.plsql.' || G_PKG_NAME  ||  '.';

   G_LOG_STATEMENT   CONSTANT NUMBER := fnd_log.level_statement;
   G_LOG_PROCEDURE   CONSTANT NUMBER := fnd_log.level_procedure;
   G_LOG_EVENT       CONSTANT NUMBER := fnd_log.level_event;
   G_LOG_EXCEPTION   CONSTANT NUMBER := fnd_log.level_exception;
   G_LOG_ERROR       CONSTANT NUMBER := fnd_log.level_error;
   G_LOG_UNEXPECTED  CONSTANT NUMBER := fnd_log.level_unexpected;


   -- *******************************************************************************************
   -- name        :  set_master_err_state
   -- Function    :  provide simple mechanism for updating master error state..
   --                the idea behind the error state is that it can only be
   --                >increased<.  when the value of the error state is increased, it indicates
   --                a more fatal condition.  So the smallest error code should be the most
   --                innocuous, the largest number the most fatal.
   --                this function also acts as a wrapper for calls to the error message API
   --                to force use of this function for all errors generated.
   -- Parameters
   -- IN
   --                err_state IN NUMBER
   --                   -  current error state we wish to set..
   --
   -- HISTORY
   --    22-Apr-2004    rjking   created
   --
   -- *******************************************************************************************
   PROCEDURE set_master_err_state(  p_master_err_state   IN OUT NOCOPY  NUMBER,
                                    err_state            IN             NUMBER,
                                    p_app_name           IN             VARCHAR2,
                                    p_msg_name           IN             VARCHAR2,
                                    p_token1             IN             VARCHAR2 DEFAULT NULL,
                                    p_value1             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans1             IN             VARCHAR2 DEFAULT NULL,
                                    p_token2             IN             VARCHAR2 DEFAULT NULL,
                                    p_value2             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans2             IN             VARCHAR2 DEFAULT NULL,
                                    p_token3             IN             VARCHAR2 DEFAULT NULL,
                                    p_value3             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans3             IN             VARCHAR2 DEFAULT NULL,
                                    p_token4             IN             VARCHAR2 DEFAULT NULL,
                                    p_value4             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans4             IN             VARCHAR2 DEFAULT NULL,
                                    p_token5             IN             VARCHAR2 DEFAULT NULL,
                                    p_value5             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans5             IN             VARCHAR2 DEFAULT NULL,
                                    p_token6             IN             VARCHAR2 DEFAULT NULL,
                                    p_value6             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans6             IN             VARCHAR2 DEFAULT NULL,
                                    p_token7             IN             VARCHAR2 DEFAULT NULL,
                                    p_value7             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans7             IN             VARCHAR2 DEFAULT NULL,
                                    p_token8             IN             VARCHAR2 DEFAULT NULL,
                                    p_value8             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans8             IN             VARCHAR2 DEFAULT NULL,
                                    p_token9             IN             VARCHAR2 DEFAULT NULL,
                                    p_value9             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans9             IN             VARCHAR2 DEFAULT NULL ) IS

      l_module_name          VARCHAR2(70) := G_MODULE_NAME || 'set_master_err_state';
   BEGIN


      fem_engines_pkg.tech_message( p_severity=>G_LOG_PROCEDURE ,
                                    p_module=> l_module_name,
                                    p_msg_text=> 'ENTRY');

      IF p_master_err_state <  err_state THEN
         p_master_err_state := err_state; -- incoming state is at a higher priority.. update our master state.
      END IF;

      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_master_err_state := ' || p_master_err_state);
      fem_engines_pkg.tech_message(p_severity=>G_LOG_STATEMENT ,
                                   p_module=> l_module_name,
                                   p_msg_text=> 'p_msg_name := ' || p_msg_name);

      -- generate our message.
      fem_engines_pkg.put_message(  p_app_name,
                                    p_msg_name,
                                    p_token1  ,
                                    p_value1  ,
                                    p_trans1  ,
                                    p_token2  ,
                                    p_value2  ,
                                    p_trans2  ,
                                    p_token3  ,
                                    p_value3  ,
                                    p_trans3  ,
                                    p_token4  ,
                                    p_value4  ,
                                    p_trans4  ,
                                    p_token5  ,
                                    p_value5  ,
                                    p_trans5  ,
                                    p_token6  ,
                                    p_value6  ,
                                    p_trans6  ,
                                    p_token7  ,
                                    p_value7  ,
                                    p_trans7  ,
                                    p_token8  ,
                                    p_value8  ,
                                    p_trans8  ,
                                    p_token9  ,
                                    p_value9  ,
                                    p_trans9  );

      fem_engines_pkg.tech_message( p_severity=>G_LOG_PROCEDURE ,
                                    p_module=> l_module_name,
                                    p_msg_text=> 'EXIT');
   END set_master_err_state;


  Procedure GetObjNameandFolderUsingObj(p_Object_ID in NUMBER
				       ,x_Object_Name OUT NOCOPY VARCHAR2
                                       ,x_Folder_Name OUT NOCOPY VARCHAR2) IS
  cursor getObjandFolderName is
  select
   a.object_name
  ,b.folder_name
  from
   fem_object_catalog_vl a
  ,fem_folders_vl b
  where
      a.object_id = p_Object_ID
  and a.folder_id = b.folder_id;
  l_Object_Name FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
  l_Folder_Name FEM_FOLDERS_VL.FOLDER_NAME%TYPE;
  Begin
   OPEN getObjandFolderName;
   FETCH getObjandFolderName into
   l_Object_Name
  ,l_Folder_Name;
   CLOSE getObjandFolderName;
     x_Object_Name := l_Object_Name;
     x_Folder_Name := l_Folder_Name;

  End GetObjNameandFolderUsingObj;

  Procedure GetObjNameandFolderUsingDef(p_Obj_Def_ID IN NUMBER
				       ,x_Object_Name OUT NOCOPY VARCHAR2
				       ,x_Folder_Name OUT NOCOPY VARCHAR2) IS
  CURSOR getObjandFolderName IS
  select
   a.object_name
  ,b.folder_name
  from
   fem_object_definition_b c
  ,fem_object_catalog_vl a
  ,fem_folders_vl b
  where
  c.object_definition_id = p_Obj_Def_ID
  and c.object_id = a.object_id
  and a.folder_id = b.folder_id;
  l_Object_Name FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
  l_Folder_Name FEM_FOLDERS_VL.FOLDER_NAME%TYPE;
  Begin
  OPEN getObjandFolderName;
  FETCH getObjandFolderName into
   l_Object_Name
  ,l_Folder_name;
  CLOSE getObjandFolderName;
     x_Object_Name := l_Object_Name;
     x_Folder_Name := l_Folder_Name;

  End GetObjNameandFolderUsingDef;

  Function getVersionCount(X_Object_ID NUMBER)
  RETURN NUMBER IS
  st_count NUMBER := 0;
  Begin

    Begin
    select count(*) into st_count
    from fem_object_definition_b
    where object_id = X_Object_ID
    and approval_status_code <> 'SUBMIT_DELETE' ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
 		st_count := 0;
   End;
      return st_count;
  End getVersionCount;

----------------------------------------------------------------
-- Function get_user_name returns the user_name stored in FND_USER
-- when passed a user_id
--
 FUNCTION get_user_name(l_user_id IN NUMBER)
     RETURN VARCHAR2
 IS
     l_user_name fnd_user.user_name%TYPE := '';

     cursor l_user_cursor is
       select user_name
       from   fnd_user
       where  user_id = l_user_id;

 BEGIN

     open l_user_cursor;
     fetch l_user_cursor into l_user_name;
     close l_user_cursor;

     RETURN(l_user_name);

 END get_user_name;

----------------------------------------------------------------
Function migrationEnabledForUser RETURN VARCHAR2 IS
        v_enabled VARCHAR2(255);
    Begin
        v_enabled := FND_PROFILE.VALUE_SPECIFIC('FEM_RULE_MIGRATION_ACCESS');
        If v_enabled = 'Y' then
            RETURN 'Y';
        Else
            RETURN 'N';
        End If;
--   l_userCount NUMBER := 0;
--
--   cursor l_migrateEnabled_Cursor is
--   select count(user_id)
--   from FEM_DB_LINK_USERS
--   where user_id = FND_GLOBAL.USER_ID;--1002894
--Begin
--   OPEN l_migrateEnabled_Cursor;
--   FETCH l_migrateEnabled_Cursor into l_userCount;
--   CLOSE l_migrateEnabled_Cursor;
--
--       If l_userCount = 0 then
--          RETURN 'N';
--       Else
--          RETURN 'Y';
--       End If;
End migrationEnabledForUser;

----------------------------------------------------------------
Function getRuleSetObjectDefID(X_RULE_SET_OBJECT_ID IN NUMBER) RETURN NUMBER IS

 cursor l_getMultipleDefnFlag IS
 select
 multiple_definitions_flag
 from
  Fem_Object_Types a
 ,Fem_object_catalog_b b
 where
     b.object_id = X_RULE_SET_OBJECT_ID
 and b.object_type_code = a.object_type_code;

 l_MultipleDefn_Flag VARCHAR2(1) := NULL;

 cursor l_getObjectDefId is
 select object_definition_id
 from FEM_OBJECT_DEFINITION_B
 where object_id = X_RULE_SET_OBJECT_ID ;

 l_Object_Def_ID NUMBER := 0;

Begin
 OPEN l_getMultipleDefnFlag;
 FETCH l_getMultipleDefnFlag into
 l_MultipleDefn_Flag;
 CLOSE l_getMultipleDefnFlag;

 If (l_MultipleDefn_Flag = 'Y') then
  l_Object_Def_ID := NULL ;
 Else
   OPEN l_getObjectDefId;
   FETCH l_getObjectDefId into l_Object_Def_ID;
   CLOSE l_getObjectDefId;
 End If;

   RETURN l_Object_Def_ID;

End getRuleSetObjectDefID;

Function getFolderPrivilege(X_Object_ID IN NUMBER) RETURN VARCHAR2 IS

 l_UserID NUMBER := 0;
 l_Count NUMBER := 0;
 l_Folder_ID FEM_FOLDERS_B.FOLDER_ID%TYPE := NULL;

 cursor l_getUserID is
  select FND_GLOBAL.USER_ID() from dual;

 cursor l_getFolderID is
  select a.Folder_ID
  from FEM_OBJECT_CATALOG_B a
  where a.object_id = X_Object_ID;

 cursor l_getCount is
  select count(user_id)
  from FEM_USER_FOLDERS
  where user_id = l_UserID
  and folder_id = l_Folder_ID;

Begin

 OPEN l_getUserID;
 FETCH l_getUserID into l_UserID;
 CLOSE l_getUserID;

 OPEN l_getFolderID;
 FETCH l_getFolderID into l_Folder_ID;
 CLOSE l_getFolderID;

 OPEN l_getCount;
 FETCH l_getCount INTO l_Count;
 CLOSE l_getCount;

 If l_Count > 0 then
   return 'Y';
 Else
   return 'N';
 End If;

End getFolderPrivilege;


----------------------------------------------------------------
FUNCTION getLookupMeaning(p_Application_ID IN NUMBER
			 ,p_Lookup_Type IN VARCHAR2
			 ,p_Lookup_Code IN VARCHAR2
                         ) RETURN VARCHAR2  IS
X_Meaning VARCHAR2(80);
Begin
 Begin
  select
   meaning
  into
   X_Meaning
  from
  FND_LOOKUP_VALUES
  WHERE LANGUAGE = userenv('LANG')
  and VIEW_APPLICATION_ID = p_Application_ID
  and LOOKUP_TYPE = p_Lookup_Type
  and LOOKUP_CODE = p_Lookup_Code
  and SECURITY_GROUP_ID = fnd_global.lookup_security_group(LOOKUP_TYPE, VIEW_APPLICATION_ID);

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_Meaning := '['||p_Lookup_Code||']';
 End;

   RETURN X_Meaning;

End getLookupMeaning;

end FEM_UTILS;

/
