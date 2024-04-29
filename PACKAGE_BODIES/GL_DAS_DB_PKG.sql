--------------------------------------------------------
--  DDL for Package Body GL_DAS_DB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DAS_DB_PKG" AS
/* $Header: gldefacb.pls 120.5 2005/09/02 10:51:14 adesu ship $ */

 --
 -- PUBLIC FUNCTIONS
 --

  PROCEDURE Insert_Super (
                       P_Rowid       IN OUT NOCOPY VARCHAR2,
                       P_Definition_Access_Set_Id  NUMBER,
                       P_Object_Type               VARCHAR2,
                       P_Object_Key                VARCHAR2,
                       P_User_Id                   NUMBER,
                       P_Login_Id                  NUMBER,
                       P_Date                      DATE) IS
  BEGIN

      GL_DEFAS_ACCESS_DETAILS_PKG.Insert_Row(
        X_Rowid                      =>   P_Rowid,
        X_Definition_Access_Set_Id   =>   P_Definition_Access_Set_id,
        X_Object_Type                =>   P_Object_Type,
        X_Object_Key                 =>   P_Object_Key,
        X_View_Access_Flag           =>   'Y',
        X_Use_Access_Flag            =>   'Y',
        X_Modify_Access_Flag         =>   'Y',
        X_User_Id                    =>   P_User_Id,
        X_Login_Id                   =>   P_Login_Id,
        X_Date                       =>   P_Date,
        X_Status_Code                =>   'I',
        X_Request_Id                 =>   NULL);

  END Insert_Super;

  PROCEDURE Insert_Default (
                       X_Object_Type               VARCHAR2,
                       X_Object_Key                VARCHAR2,
                       X_User_Id                   NUMBER,
                       X_Login_Id                  NUMBER,
                       X_Date                      DATE) IS
  BEGIN
     INSERT INTO GL_DEFAS_ASSIGNMENTS
     (definition_access_set_id,
      object_type,
      object_key,
      view_access_flag,
      use_access_flag,
      modify_access_flag,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      status_code)
    SELECT
      definition_access_set_id,
      X_Object_Type,
      X_Object_Key,
      default_view_access_flag,
      default_use_access_flag,
      default_modify_access_flag,
      X_Date,
      X_User_Id,
      X_Date,
      X_User_Id,
      X_Login_Id,
      'I'
    FROM gl_defas_resp_assign
    WHERE application_id = 101
    AND   responsibility_id = fnd_global.resp_id
    AND   security_group_id = fnd_global.security_group_id
    AND   default_flag = 'Y';
  END Insert_Default;

  FUNCTION Submit_Req RETURN NUMBER IS
    request_id NUMBER;
  BEGIN
    request_id := fnd_request.submit_request(
                  'SQLGL', 'GLDASF', '', '', FALSE,
                  'DEF', 'Y');

    return request_id;

  END Submit_Req;

END gl_das_db_pkg;

/
