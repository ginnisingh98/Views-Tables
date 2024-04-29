--------------------------------------------------------
--  DDL for Package Body IGS_SC_DATA_SEC_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SC_DATA_SEC_APIS_PKG" AS
/* $Header: IGSSC02B.pls 120.12 2006/04/19 02:13:02 gmaheswa ship $ */

/******************************************************************

    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
                         All rights reserved.

 Created By         : Don Shellito

 Date Created By    : April 8, 2003

 Purpose            : This package is to be used for the processing and
                      gathering of the security process for Oracle
                      Student System.

 remarks            : None

 Change History

Who             When           What
-----------------------------------------------------------
Don Shellito    08-Apr-2003    New Package created.
Uma Maheswari   24-Aug-2004    Bug 3828353 : Modified enable_upgrade_mode to unlock all grants for object_group_id = -1;
Uma Maheswari   13-Apr-2004    Bug 4068422 : Modified c_obj cursor to select objeect_id based on obj_name instead of datbase_object_name.
			       As obj_name and data_base_object_name will be same in security module, this change is done for using the index on the table.
mmkumar         28-Jun-2005    Bug 4431768 : Added a paqrameter for overwrite
                               Inside Update_Grant_Cond, removed code for cursor c_get_grant_cond.
prbhardw	18-Jul-2005    Inside Update_Grant_Cond, modified code to update condition number
mmkumar         21-JUL-2005    Closed the cursors whereever appropriate
gmaheswa	26-Jul-2005    Fnd Logging
pkpatel         10-Mar-2006    Bug 5081932 (Used wf_local_synch instead of private API wf_directory)
gmaheswa        19-Apr-2006    Bug: 4587521: Modified Modify_Policy to add long_predicate parameter to add_policy. this parameter allows max predicate where clause lenght to 32K
******************************************************************/

-- -----------------------------------------------------------------
-- Define the global variables to be used in this package.
-- -----------------------------------------------------------------
g_pkg_name         CONSTANT VARCHAR2(30) := 'IGS_SC_DATA_SEC_APIS_PKG';
g_upgrade_mode     VARCHAR2(1) := 'N';

l_prog_label CONSTANT VARCHAR2(500) :='igs.plsql.igs_sc_data_sec_apis_pkg';
l_label VARCHAR2(4000);
l_debug_str VARCHAR2(32000);

-- -----------------------------------------------------------------
-- Define other procedures that are to be used internally here.
-- -----------------------------------------------------------------
CURSOR c_table_name (v_object_id NUMBER) IS
  SELECT database_object_name
    FROM fnd_objects
   WHERE object_id = v_object_id;



PROCEDURE Get_Valid_Grant_Vals (p_grant_select_flag    IN VARCHAR2,
                                p_grant_insert_flag    IN VARCHAR2,
                                p_grant_delete_flag    IN VARCHAR2,
                                p_grant_update_flag    IN VARCHAR2,
                                x_grant_select_flag    OUT NOCOPY VARCHAR2,
                                x_grant_insert_flag    OUT NOCOPY VARCHAR2,
                                x_grant_delete_flag    OUT NOCOPY VARCHAR2,
                                x_grant_update_flag    OUT NOCOPY VARCHAR2
                               );

FUNCTION Validate_Function_ID (p_function_id    IN NUMBER) RETURN NUMBER;

FUNCTION Validate_Obj_Grp_ID (p_group_id   IN NUMBER) RETURN NUMBER;

FUNCTION Validate_User_Grp_ID (p_user_group_id    IN NUMBER) RETURN NUMBER;

FUNCTION Validate_Grant_ID (p_grant_id      IN NUMBER) RETURN NUMBER;

FUNCTION Validate_Obj_Attr_ID (p_obj_attr_id      IN NUMBER) RETURN NUMBER;

FUNCTION Validate_User_Attr_ID (p_user_attr_id      IN NUMBER) RETURN NUMBER;

FUNCTION Validate_Object_ID (p_object_id      IN NUMBER) RETURN NUMBER;

FUNCTION Validate_Static_Type (p_static_type   IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Validate_Obj_Attr_Type (p_obj_att_type    IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Validate_User_Attr_Type (p_usr_att_type   IN VARCHAR2) RETURN VARCHAR2;

FUNCTION check_attrib_text (
  p_table_name VARCHAR2,
  p_select_text VARCHAR2,
  p_obj_attrib_type VARCHAR2 )

RETURN BOOLEAN IS
BEGIN

  RETURN IGS_SC_GRANTS_PVT.check_attrib_text ( p_table_name , p_select_text , p_obj_attrib_type );

END check_attrib_text;



PROCEDURE modify_policy (
  p_database_object_name IN VARCHAR2,
  p_action VARCHAR2 DEFAULT 'CREATE'  );

/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : This procedure is designed for the handling of
                        data insertion into the igs_sc_grants table.
                        Validation is performed on the function_id,
                        user_group_id, and obj_group_id that these IDs
                        are currently in the IGS Security structure.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Insert_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN OUT NOCOPY igs_sc_grants.grant_id%TYPE,
                        p_function_id       IN igs_sc_grants.function_id%TYPE,
                        p_user_group_id     IN igs_sc_grants.user_group_id%TYPE,
                        p_obj_group_id      IN igs_sc_grants.obj_group_id%TYPE,
                        p_grant_name        IN igs_sc_grants.grant_name%TYPE,
                        p_grant_text        IN igs_sc_grants.grant_text%TYPE,
                        p_grant_select_flag IN igs_sc_grants.grant_select_flag%TYPE DEFAULT 'N',
                        p_grant_insert_flag IN igs_sc_grants.grant_insert_flag%TYPE DEFAULT 'N',
                        p_grant_update_flag IN igs_sc_grants.grant_update_flag%TYPE DEFAULT 'N',
                        p_grant_delete_flag IN igs_sc_grants.grant_delete_flag%TYPE DEFAULT 'N',
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
                       )
 IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name                CONSTANT VARCHAR2(30) := 'Insert_Grant';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_return_message          VARCHAR2(2000);
   l_message_count           NUMBER(15);
   l_return_status           VARCHAR2(30);
   l_grant_select_flag       igs_sc_grants.grant_select_flag%TYPE;
   l_grant_delete_flag       igs_sc_grants.grant_delete_flag%TYPE;
   l_grant_update_flag       igs_sc_grants.grant_update_flag%TYPE;
   l_grant_insert_flag       igs_sc_grants.grant_insert_flag%TYPE;
   l_locked_flag             igs_sc_grants.locked_flag%TYPE       := 'N';
   l_function_id             igs_sc_obj_functns.function_id%TYPE;
   l_obj_group_id            igs_sc_objects.object_id%TYPE;
   l_user_group_id           wf_local_roles.orig_system_id%TYPE;

BEGIN
   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant';
       l_debug_str := 'Grant ID: '||p_grant_id||','||'Role ID: '||','||p_user_group_id||','||' Object Group ID: '||p_obj_group_id
			||','||' Grant Name: '||p_grant_name||','||' Grant Text: '||p_grant_text||','||'Select Flag: '||p_grant_select_flag
			||','||' Insert Flag: '||p_grant_insert_flag||','||' Update Flag: '||p_grant_update_flag||','||' Delete Flag: '||p_grant_delete_flag;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Insert_Grant_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Ensure that the grant name is not null.
-- -----------------------------------------------------------------
   IF (p_grant_name IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_NO_GRANT_NAME');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Ensure that the grant values are correct.
-- -----------------------------------------------------------------
   Get_Valid_Grant_Vals (p_grant_select_flag => p_grant_select_flag,
                         p_grant_insert_flag => p_grant_insert_flag,
                         p_grant_delete_flag => p_grant_delete_flag,
                         p_grant_update_flag => p_grant_update_flag,
                         x_grant_select_flag => l_grant_select_flag,
                         x_grant_insert_flag => l_grant_insert_flag,
                         x_grant_delete_flag => l_grant_delete_flag,
                         x_grant_update_flag => l_grant_update_flag);

-- -----------------------------------------------------------------
-- Ensure that if there is a function ID provided that it is valid
-- -----------------------------------------------------------------
   IF (p_function_id IS NOT NULL) THEN
      l_function_id := Validate_Function_ID (p_function_id => p_function_id);
      IF (l_function_id <= 0) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_FUNC_FOR_GRNT');
         FND_MESSAGE.SET_TOKEN('GRANT_NAME', p_grant_name);
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

-- -----------------------------------------------------------------
-- Validate object group id provided
-- -----------------------------------------------------------------
   l_obj_group_id := Validate_Obj_Grp_ID (p_group_id => p_obj_group_id);

   IF (l_obj_group_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_GROUP');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Validate User Group ID provided.
-- -----------------------------------------------------------------
   l_user_group_id := Validate_User_Grp_ID (p_user_group_id => p_user_group_id);

   IF (l_user_group_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_USER_GROUP');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Insert the values requested into the Grants table.
-- -----------------------------------------------------------------
   INSERT
     INTO igs_sc_grants
          (grant_id,
           function_id,
           user_group_id,
           obj_group_id,
           grant_name,
           grant_text,
           grant_select_flag,
           grant_insert_flag,
           grant_update_flag,
           grant_delete_flag,
           locked_flag,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login
          )
   VALUES (NVL(p_grant_id,igs_sc_grants_s.nextval),
           l_function_id,
           l_user_group_id,
           l_obj_group_id,
           p_grant_name,
           p_grant_text,
           p_grant_select_flag,
           l_grant_insert_flag,
           l_grant_update_flag,
           l_grant_delete_flag,
           l_locked_flag,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1)
          )
          RETURNING grant_id INTO p_grant_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Grant_SP;
      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant.Ex_UN';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||','||' Grant Name: '||p_grant_name||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Grant_SP;
      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant.Ex_error';
         l_debug_str := 'Handled Exception: Grant ID: '||p_grant_id||','||' Grant Name: '||p_grant_name||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant.Ex_others';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||','||' Grant Name: '||p_grant_name||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Grant;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is for the
                        handling on inserting data into igs_sc_grant_conds
                        table.  There is validation on the grant_id,
                        obj_attrib_id, and user_attrib_id values received
                        to ensure that these records have been inserted
                        into the OSS security data model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Insert_Grant_Cond (p_api_version       IN NUMBER,
                             p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_grant_id          IN igs_sc_grant_conds.grant_id%TYPE,
                             p_obj_attrib_id     IN igs_sc_grant_conds.obj_attrib_id%TYPE,
                             p_user_attrib_id    IN igs_sc_grant_conds.user_attrib_id%TYPE,
                             p_condition         IN igs_sc_grant_conds.condition%TYPE,
                             p_text_value        IN igs_sc_grant_conds.text_value%TYPE,
                             p_grant_cond_num    IN igs_sc_grant_conds.grant_cond_num%TYPE,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_return_message    OUT NOCOPY VARCHAR2
                            )
IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_Grant_Cond';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_user_attr_id       igs_sc_usr_attribs.user_attrib_id%TYPE := p_user_attrib_id;
   l_obj_attr_id        igs_sc_obj_attribs.obj_attrib_id%TYPE := p_obj_attrib_id;
   l_grant_id           igs_sc_grants.grant_id%TYPE := p_grant_id;

BEGIN
   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant_Cond';
       l_debug_str := 'Grant ID: '||p_grant_id||','||' Object Attribute ID: '||p_obj_attrib_id||','||'User Attribute ID: '||p_user_attrib_id
			||','||'Condition: '||p_condition||','||' Text Value: '||p_text_value||','||'Grant Cond Number: '||p_grant_cond_num;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Insert_Grant_Cond_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Validate that the grant exists.
-- -----------------------------------------------------------------
   l_grant_id := Validate_Grant_ID (p_grant_id => p_grant_id);
   IF (l_grant_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_GRANT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Validate that the object attribute ID exists.
-- -----------------------------------------------------------------
   IF (p_obj_attrib_id IS NOT NULL) THEN
      l_obj_attr_id := Validate_Obj_Attr_ID (p_obj_attr_id => p_obj_attrib_id);
      IF (l_obj_attr_id <= 0) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_ATTR');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

-- -----------------------------------------------------------------
-- Validate that the user attribute ID exists.
-- -----------------------------------------------------------------
   IF (p_user_attrib_id IS NOT NULL) THEN
      l_user_attr_id := Validate_User_Attr_ID (p_user_attr_id => p_user_attrib_id);
      IF (l_user_attr_id <= 0) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_USR_ATTR');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

-- -----------------------------------------------------------------
-- Check to make sure that the Grant Condition Number given is legal
-- -----------------------------------------------------------------
   IF (p_grant_cond_num <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_COND_NUM');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Insert the values requested into the Grant Conditions table.
-- -----------------------------------------------------------------
   INSERT
     INTO igs_sc_grant_conds
          (grant_id,
           grant_cond_num,
           obj_attrib_id,
           user_attrib_id,
           condition,
           text_value,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login
          )
   VALUES (l_grant_id,
           p_grant_cond_num,
           l_obj_attr_id,
           l_user_attr_id,
           p_condition,
           p_text_value,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1)
          );

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant_Cond.Ex_error';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||','||' Condtion Number: '||p_grant_cond_num||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant_Cond.Ex_un';
         l_debug_str := 'Handled Exception: Grant ID: '||p_grant_id||','||' Condtion Number: '||p_grant_cond_num||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Grant_Cond.Ex_others';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||','||' Condtion Number: '||p_grant_cond_num||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Grant_Cond;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : This procedure is designed for the handling
                        of the data insertion into igs_sc_obj_groups
                        table.  There is validation to ensure that
                        the group_name is not null and that the value
                        for the default_policy_type is either 'G'- Global
                        or 'R' - Restricted.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Insert_Object_Group (p_api_version            IN NUMBER,
                               p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_commit                 IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_obj_group_id           IN OUT NOCOPY igs_sc_obj_groups.obj_group_id%TYPE,
                               p_obj_group_name         IN igs_sc_obj_groups.obj_group_name%TYPE ,
                               p_default_policy_type    IN igs_sc_obj_groups.default_policy_type%TYPE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_return_message         OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name                CONSTANT VARCHAR2(30) := 'Insert_Object_Group';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_return_message          VARCHAR2(2000);
   l_message_count           NUMBER(15);
   l_return_status           VARCHAR2(30);
   l_default_policy_type     igs_sc_obj_groups.default_policy_type%TYPE;

BEGIN

   SAVEPOINT Insert_Object_Group_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Ensure that the object group name is NOT NULL
-- -----------------------------------------------------------------
   IF (p_obj_group_name IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_NULL_OBJ_GRP_NAME');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Ensure that the default policy has correct value of Y or N
-- -----------------------------------------------------------------
   IF (p_default_policy_type IN ('G', 'R')) THEN
      l_default_policy_type := p_default_policy_type;
   ELSE
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_DEF_POLICY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEFAULT_POLICY', p_default_policy_type);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Insert the values requested into the Grants table.
-- -----------------------------------------------------------------
   INSERT
     INTO igs_sc_obj_groups
          (obj_group_id,
           obj_group_name,
           default_policy_type,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login
          )
   VALUES (NVL(p_obj_group_id,igs_sc_obj_groups_s.nextval),
           p_obj_group_name,
           l_default_policy_type,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1)
          )
          RETURNING obj_group_id INTO p_obj_group_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Group_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Group_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Group_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Object_Group;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is for the handling
                        on insertion of data into igs_sc_obj_attribs table.
                        There is validation performed on the obj_group_id
                        and obj_attrib_id provided to ensure that the
                        records are present in the OSS data structure.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Insert_Object_Attr (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_obj_attrib_id     IN OUT NOCOPY igs_sc_obj_attribs.obj_attrib_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_attribs.obj_group_id%TYPE,
                              p_obj_attrib_name   IN igs_sc_obj_attribs.obj_attrib_name%TYPE,
			      p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_Object_Attr';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_obj_group_id       igs_sc_obj_groups.obj_group_id%TYPE;

BEGIN

   SAVEPOINT Insert_Object_Attr_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Validate the object group ID is present.
-- -----------------------------------------------------------------
   l_obj_group_id := Validate_Obj_Grp_ID (p_group_id => p_obj_group_id);

   IF (l_obj_group_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_GROUP');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Ensure that the object attribute name is valid
-- -----------------------------------------------------------------
   IF (p_obj_attrib_name IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_ATTR_NAME');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Insert the values requested into the Grants table.
-- -----------------------------------------------------------------
   INSERT
     INTO igs_sc_obj_attribs
          (obj_group_id,
           obj_attrib_id,
           obj_attrib_name,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
	   active_flag
          )
   VALUES (l_obj_group_id,
           NVL(p_obj_attrib_id,igs_sc_obj_attribs_s.nextval),
           p_obj_attrib_name,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1),
	   p_active_flag
          )
          RETURNING obj_attrib_id INTO p_obj_attrib_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Attr_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Attr_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Attr_SP;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Object_Attr;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is for the handling
                        of data insertion into the igs_sc_obj_att_mths
                        table.  There is validation performed on the
                        object_id, obj_attrib_id, obj_attrib_type, and
                        static_type to ensure that the values given are
                        in the OSS data model or have valid values expected
                        for the types.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Insert_Object_Attr_Method (p_api_version       IN NUMBER,
                                     p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                     p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                     p_obj_attrib_type   IN igs_sc_obj_att_mths.obj_attrib_type%TYPE,
                                     p_static_type       IN igs_sc_obj_att_mths.static_type%TYPE,
                                     p_select_text       IN igs_sc_obj_att_mths.select_text%TYPE,
				     p_null_allow_flag	 IN VARCHAR2 DEFAULT 'N',
				     p_call_from_lct	 IN VARCHAR2 DEFAULT 'N',
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_Object_Attr_Method';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_object_id          igs_sc_obj_att_mths.object_id%TYPE;
   l_obj_attrib_id      igs_sc_obj_att_mths.obj_attrib_id%TYPE;
   l_obj_attrib_type    igs_sc_obj_att_mths.obj_attrib_type%TYPE;
   l_static_type        igs_sc_obj_att_mths.static_type%TYPE;
   l_object_name        fnd_objects.database_object_name%TYPE;

BEGIN

   SAVEPOINT Insert_Object_Attr_Method_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Validate the object ID is present.
-- -----------------------------------------------------------------
   l_object_id := Validate_Object_ID (p_object_id => p_object_id);

   IF (l_object_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJECT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Validate that the object attribute ID exists.
-- -----------------------------------------------------------------

   l_obj_attrib_id := Validate_Obj_Attr_ID (p_obj_attr_id => p_obj_attrib_id);

   IF (l_obj_attrib_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_ATTR');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Validate the information that is to be updated.
-- -----------------------------------------------------------------

   l_obj_attrib_type := Validate_Obj_Attr_type (p_obj_att_type => p_obj_attrib_type);

   IF (l_obj_attrib_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_ATTR_TYPE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_static_type := Validate_Static_Type (p_static_type => p_static_type);

   IF (l_static_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_STATIC_TYPE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF P_CALL_FROM_LCT <> 'Y' THEN
     OPEN c_table_name(p_object_id);
     FETCH c_table_name INTO l_object_name;
     CLOSE c_table_name;
     IF NOT check_attrib_text ( l_object_name, p_select_text,l_obj_attrib_type) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRNT_TXT_ERR');
          FND_MESSAGE.SET_TOKEN('OBJ_NAME',l_object_name);
          FND_MESSAGE.SET_TOKEN('GRNT_TEXT', p_select_text);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

     END IF;
   END IF;

-- -----------------------------------------------------------------
-- Insert the values requested into the Grants table.
-- -----------------------------------------------------------------
   INSERT
     INTO igs_sc_obj_att_mths
          (object_id,
           obj_attrib_id,
           obj_attrib_type,
           static_type,
           select_text,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
	   null_allow_flag
          )
   VALUES (l_object_id,
           l_obj_attrib_id,
           l_obj_attrib_type,
           l_static_type,
           p_select_text,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1),
	   p_null_allow_flag
          );
-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Attr_Method_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Attr_Method_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Attr_Method_SP;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Object_Attr_Method;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is for the
                        handling of the inserting of data into the
                        table igs_sc_obj_functns.  There is validation
                        performed on the obj_group_id to ensure that
                        the value given is present in the OSS data
                        model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Insert_Object_Func (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_function_id       IN OUT NOCOPY igs_sc_obj_functns.function_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_functns.obj_group_id%TYPE,
                              p_function_name     IN igs_sc_obj_functns.function_name%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_Object_Func';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_obj_group_id       igs_sc_obj_functns.obj_group_id%TYPE;

BEGIN

   SAVEPOINT Insert_Object_Func_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Validate object group id provided
-- -----------------------------------------------------------------
   l_obj_group_id := Validate_Obj_Grp_ID (p_group_id => p_obj_group_id);

   IF (l_obj_group_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_GROUP');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Ensure that the function name is not null.
-- -----------------------------------------------------------------
   IF (p_function_name IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_FUNC_NAME');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Insert the values requested into the Grants table.
-- -----------------------------------------------------------------
   INSERT
     INTO igs_sc_obj_functns
          (function_id,
           obj_group_id,
           function_name,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login
          )
   VALUES (NVL(igs_sc_obj_functns_s.nextval,p_function_id),
           l_obj_group_id,
           p_function_name,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1)
          )
          RETURNING function_id INTO p_function_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Func_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Func_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_Func_SP;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Object_Func;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to handle
                        the insertion of the data into igs_sc_objects
                        table.  This ensures a link between the object
                        groups and the fnd objects resident in the system.
                        There is validation to ensure that the object_id,
                        and the obj_group_id are valid and present in the
                        data model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Insert_Object (p_api_version       IN NUMBER,
                         p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_object_id         IN OUT NOCOPY igs_sc_objects.object_id%TYPE,
                         p_obj_group_id      IN igs_sc_objects.obj_group_id%TYPE,
                         p_obj_name          IN fnd_objects.obj_name%TYPE ,
                         p_database_object_name   IN fnd_objects.database_object_name%TYPE ,
                         p_pk1_column_name   IN fnd_objects.pk1_column_name%TYPE ,
                         p_pk2_column_name   IN fnd_objects.pk2_column_name%TYPE ,
                         p_pk3_column_name   IN fnd_objects.pk3_column_name%TYPE ,
                         p_pk4_column_name   IN fnd_objects.pk4_column_name%TYPE ,
                         p_pk5_column_name   IN fnd_objects.pk5_column_name%TYPE ,
                         p_pk1_column_type   IN fnd_objects.pk1_column_type%TYPE ,
                         p_pk2_column_type   IN fnd_objects.pk2_column_type%TYPE ,
                         p_pk3_column_type   IN fnd_objects.pk3_column_type%TYPE ,
                         p_pk4_column_type   IN fnd_objects.pk4_column_type%TYPE ,
                         p_pk5_column_type   IN fnd_objects.pk5_column_type%TYPE ,
			 p_select_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_insert_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_update_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_delete_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_enforce_par_sec_flag IN VARCHAR2 DEFAULT 'N',
			 p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_return_message    OUT NOCOPY VARCHAR2
                        )
 IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_Object';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_object_id          igs_sc_objects.object_id%TYPE;
   l_obj_group_id       igs_sc_objects.obj_group_id%TYPE;
   l_rowid              VARCHAR2(255);
   l_application_id	NUMBER;

   CURSOR c_obj IS
     SELECT object_id
       FROM fnd_objects
      WHERE obj_name = p_obj_name;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------

BEGIN

   SAVEPOINT Insert_Object_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Validate object group id provided
-- -----------------------------------------------------------------
   l_obj_group_id := Validate_Obj_Grp_ID (p_group_id => p_obj_group_id);

   IF (l_obj_group_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_GROUP');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Check if object exists
-- -----------------------------------------------------------------

  OPEN c_obj;
  FETCH c_obj INTO l_object_id;
  CLOSE c_obj;

  IF(SUBSTR(p_obj_name,1,3) = 'IGS') THEN
     l_application_id := 8405;
  ELSIF(SUBSTR(p_obj_name,1,3) = 'IGF') THEN
     l_application_id := 8406;
  END IF;

  IF l_object_id IS NULL THEN
    -- populate ID Insert table into FND

    IF p_object_id IS NULL THEN
      SELECT fnd_objects_s.nextval INTO l_object_id FROM DUAL;
    ELSE
      l_object_id := p_object_id;
    END IF;

      FND_OBJECTS_PKG.INSERT_ROW (
         x_rowid => l_rowid,
         x_object_id =>l_object_id,
         x_obj_name => p_obj_name,
         x_pk1_column_name => p_pk1_column_name,
         x_pk2_column_name => p_pk2_column_name,
         x_pk3_column_name => p_pk3_column_name,
         x_pk4_column_name => p_pk4_column_name,
         x_pk5_column_name => p_pk5_column_name,
         x_pk1_column_type => p_pk1_column_type,
         x_pk2_column_type => p_pk2_column_type,
         x_pk3_column_type => p_pk3_column_type,
         x_pk4_column_type => p_pk4_column_type,
         x_pk5_column_type => p_pk5_column_type,
         x_application_id  => l_application_id,
         x_database_object_name => p_database_object_name,
         x_display_name    => p_obj_name,
         x_description     => p_obj_name,
         x_creation_date   => SYSDATE,
         x_created_by      =>   NVL(fnd_global.user_id,-1),
         x_last_update_date => SYSDATE,
         x_last_updated_by  => NVL(fnd_global.user_id,-1),
         x_last_update_login => NVL(fnd_global.login_id, -1));

  END IF;

  p_object_id := l_object_id;

-- -----------------------------------------------------------------
-- Insert the values requested into the Grants table.
-- -----------------------------------------------------------------

   INSERT
     INTO igs_sc_objects
          (object_id,
           obj_group_id,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
	   select_flag,
	   insert_flag,
	   update_flag,
	   delete_flag,
	   enforce_par_sec_flag,
	   active_flag
          )
   VALUES (l_object_id,
           l_obj_group_id,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1),
	   p_select_flag,
	   p_insert_flag,
	   p_update_flag,
	   p_delete_flag,
	   p_enforce_par_sec_flag,
	   p_active_flag
          );

  -- Create database policy for table
    modify_policy(p_database_object_name ) ;

  -- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Object_SP;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Object;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to handle
                        the insertion of data into the table
                        igs_sc_usr_attribs.  There is validation
                        to ensure that the static_type and
                        user_attrib_type are valid values.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

*****************************************************************/
PROCEDURE Insert_User_Attr (p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_user_attrib_id    IN OUT NOCOPY igs_sc_usr_attribs.user_attrib_id%TYPE,
                            p_user_attrib_name  IN igs_sc_usr_attribs.user_attrib_name%TYPE,
                            p_user_attrib_type  IN igs_sc_usr_attribs.user_attrib_type%TYPE,
                            p_static_type       IN igs_sc_usr_attribs.static_type%TYPE,
                            p_select_text       IN igs_sc_usr_attribs.select_text%TYPE,
			    p_active_flag	IN VARCHAR2 DEFAULT 'Y',
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_User_Attr';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_user_attrib_type   igs_sc_usr_attribs.user_attrib_type%TYPE;
   l_static_type        igs_sc_usr_attribs.static_type%TYPE;

BEGIN

   SAVEPOINT Insert_User_Attr_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Validate that the attribute name is valid.
-- -----------------------------------------------------------------
   IF (p_user_attrib_name IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_USR_ATTR_NAME');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Ensure that there is SELECT text provided.
-- -----------------------------------------------------------------
   IF (p_select_text IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_SELECT_TEXT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Validate that the attribute type is valid.
-- -----------------------------------------------------------------
   l_user_attrib_type := Validate_User_Attr_Type (p_usr_att_type => p_user_attrib_type);

   IF (l_user_attrib_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_USR_ATT_TYPE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Validatate that the static type is valid.
-- -----------------------------------------------------------------
   l_static_type := Validate_Static_Type (p_static_type => p_static_type);

   IF (l_static_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_STATIC_TYPE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF NOT check_attrib_text ( 'DUAL', p_select_text,l_user_attrib_type) THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRNT_TXT_ERR');
          FND_MESSAGE.SET_TOKEN('OBJ_NAME','USER_ATTRIB');
          FND_MESSAGE.SET_TOKEN('GRNT_TEXT', p_select_text);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

   END IF;


-- -----------------------------------------------------------------
-- Insert the values requested into the Grants table.
-- -----------------------------------------------------------------
   INSERT
     INTO igs_sc_usr_attribs
          (user_attrib_id,
           user_attrib_name,
           user_attrib_type,
           static_type,
           select_text,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
	   active_flag
          )
   VALUES ( NVL(p_user_attrib_id,igs_sc_usr_attribs_s.nextval),
           p_user_attrib_name,
           l_user_attrib_type,
           l_static_type,
           p_select_text,
           SYSDATE,
           NVL(FND_GLOBAL.user_id,-1),
           NVL(FND_GLOBAL.user_id,-1),
           SYSDATE,
           NVL(FND_GLOBAL.login_id, -1),
	   p_active_flag
          )
          RETURNING user_attrib_id INTO p_user_attrib_id;

  -- Generate values

  IF l_static_type IN ('C','S') AND l_user_attrib_type <> 'U' THEN

    IGS_SC_GRANTS_PVT.POPULATE_USER_ATTRIB (
        P_API_VERSION      => 1.0,
        P_ATTRIB_ID        => p_user_attrib_id,
        P_USER_ID          => NULL,
        P_ALL_ATTRIBS      => 'Y',
        X_RETURN_STATUS    => l_return_status,
        X_MSG_COUNT        => l_message_count,
        X_MSG_DATA         => l_return_message
     );


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_User_Attr_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_User_Attr_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);

      ROLLBACK TO Insert_User_Attr_SP;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;


END Insert_User_Attr;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            :
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito        April 23, 2003  New Procedure Created.
   pkpatel             10-Mar-2006     Bug 5081932 (Used wf_local_synch instead of private API wf_directory)
******************************************************************/
PROCEDURE Insert_Local_Role (
                      p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_role_name               IN  VARCHAR2,
                      p_role_display_name       IN  VARCHAR2,
                      p_orig_system             IN  VARCHAR2,
                      p_orig_system_id          IN  NUMBER,
                      p_language                IN  VARCHAR2 DEFAULT NULL,
                      p_territory               IN  VARCHAR2 DEFAULT NULL,
                      p_role_description        IN  VARCHAR2 DEFAULT NULL,
                      p_notification_preference IN  VARCHAR2 DEFAULT 'MAILHTML',
                      p_email_address           IN  VARCHAR2 DEFAULT NULL,
                      p_fax                     IN  VARCHAR2 DEFAULT NULL,
                      p_status                  IN  VARCHAR2 DEFAULT 'ACTIVE',
                      p_expiration_date         IN  DATE DEFAULT NULL,
                      p_start_date              IN  DATE DEFAULT SYSDATE,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_Local_Role';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_parameters         wf_parameter_list_t;
-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------

BEGIN
   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_Role';
       l_debug_str := 'Role Name: '||p_role_name||','||' Role Display Name: '||p_role_display_name||','||'Role Orig System: '||p_orig_system
			||','||' Role Orig System ID: '||p_orig_system_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Insert_Local_Role_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

        wf_event.addparametertolist('USER_NAME',p_role_name,l_parameters);
        wf_event.addparametertolist('DISPLAYNAME',p_role_display_name,l_parameters);
        wf_event.addparametertolist('DESCRIPTION',p_role_description,l_parameters);
        wf_event.addparametertolist('PREFERREDLANGUAGE',p_language,l_parameters);
        wf_event.addparametertolist('ORCLNLSTERRITORY',p_territory,l_parameters);
        wf_event.addparametertolist('ORCLWORKFLOWNOTIFICATIONPREF',p_notification_preference,l_parameters);
        wf_event.addparametertolist('MAIL',p_email_address,l_parameters);
        wf_event.addparametertolist('FACSIMILETELEPHONENUMBER',p_fax,l_parameters);
        wf_event.addparametertolist('ORCLISENABLED',p_status,l_parameters);

        wf_local_synch.propagate_role(p_orig_system      => p_orig_system,
                                      p_orig_system_id   => p_orig_system_id,
                                      p_attributes       => l_parameters,
                                      p_start_date       => p_start_date,
                                      p_expiration_date  => p_expiration_date
                                      );


-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Local_Role_SP;
      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_Role.Ex_UN';
         l_debug_str := 'Unhandled Exception: Role Name: '||p_role_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Local_Role_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_Role.Ex_Error';
         l_debug_str := 'Handled Exception: Role Name: '||p_role_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Local_Role_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_Role.Ex_others';
         l_debug_str := 'Other Exception: Role Name: '||p_role_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;


END Insert_Local_Role;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            :
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.
   gmaheswa             Jul 28, 2005    Modified c_fnd_user_name cursor to validate user from fnd_user instead of wf_user.
   pkpatel              10-Mar-2006      Bug 5081932 (Used wf_local_synch instead of private API wf_directory)
******************************************************************/
PROCEDURE Insert_Local_User_Role (p_api_version         IN NUMBER,
                                  p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_commit              IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_user_name           IN wf_local_user_roles.user_name%TYPE,
                                  p_role_name           IN wf_local_user_roles.role_name%TYPE,
                                  p_user_orig_system    IN wf_local_user_roles.user_orig_system%TYPE,
                                  p_user_orig_system_id IN wf_local_user_roles.user_orig_system_id%TYPE,
                                  p_role_orig_system    IN wf_local_user_roles.role_orig_system%TYPE,
                                  p_role_orig_system_id IN wf_local_user_roles.role_orig_system_id%TYPE,
                                  p_start_date          IN wf_local_user_roles.start_date%TYPE,
                                  p_expiration_date     IN wf_local_user_roles.expiration_date%TYPE,
                                  p_security_group_id   IN wf_local_user_roles.security_group_id%TYPE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_message      OUT NOCOPY VARCHAR2
                                 )
 IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Insert_Local_User_Role';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_user_found		VARCHAR2(1);
-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
--  This cursor check what user_id and system are used in wf_users view

CURSOR c_fnd_user_name IS
     SELECT 'X'
     FROM fnd_user
     WHERE user_name = p_user_name
     AND user_id = p_user_orig_system_id;

BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_User_Role';
       l_debug_str := 'Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||'Role Orig System: '||p_role_orig_system
			||','||' Role Orig System ID: '||p_role_orig_system_id||'User Orig System: '||p_user_orig_system
			||','||' User Orig System ID: '||p_user_orig_system_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Insert_Local_User_Role_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check if fnd userid is used.

   OPEN c_fnd_user_name;
   FETCH c_fnd_user_name INTO l_user_found;

   IF  c_fnd_user_name%NOTFOUND  THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_USR_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   CLOSE c_fnd_user_name;

wf_local_synch.propagateUserRole(p_user_name => p_user_name,
                                 p_role_name => p_role_name,
                                 p_user_orig_system => p_user_orig_system,
                                 p_user_orig_system_id => p_user_orig_system_id,
                                 p_role_orig_system    => p_role_orig_system,
                                 p_role_orig_system_id => p_role_orig_system_id,
                                 p_start_date          => p_start_date,
                                 p_expiration_date     => p_expiration_date
			 	 );

    -- Populate the user attributes values
    IGS_SC_GRANTS_PVT.POPULATE_USER_ATTRIB (
        P_API_VERSION      => 1.0,
        P_ATTRIB_ID        => NULL,
        P_USER_ID          => p_user_orig_system_id,
        P_ALL_ATTRIBS      => 'Y',
        X_RETURN_STATUS    => l_return_status,
        X_MSG_COUNT        => l_message_count,
        X_MSG_DATA         => l_return_message
     );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Local_User_Role_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_User_Role.Ex_UN';
         l_debug_str := 'Other Exception: Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Local_User_Role_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_User_Role.Ex_error';
         l_debug_str := 'Other Exception: Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Insert_Local_User_Role_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Insert_Local_User_Role.Ex_others';
         l_debug_str := 'Other Exception: Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Insert_Local_User_Role;



/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to handle
                        the insertion of the data into igs_sc_objects
                        table.  This ensures a link between the object
                        groups and the fnd objects resident in the system.
                        There is validation to ensure that the object_id,
                        and the obj_group_id are valid and present in the
                        data model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Update_Object (p_api_version       IN NUMBER,
                         p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_object_id         IN igs_sc_objects.object_id%TYPE,
                         p_obj_group_id      IN igs_sc_objects.obj_group_id%TYPE,
                         p_obj_name          IN fnd_objects.obj_name%TYPE ,
                         p_database_object_name   IN fnd_objects.database_object_name%TYPE ,
                         p_pk1_column_name   IN fnd_objects.pk1_column_name%TYPE ,
                         p_pk2_column_name   IN fnd_objects.pk2_column_name%TYPE ,
                         p_pk3_column_name   IN fnd_objects.pk3_column_name%TYPE ,
                         p_pk4_column_name   IN fnd_objects.pk4_column_name%TYPE ,
                         p_pk5_column_name   IN fnd_objects.pk5_column_name%TYPE ,
                         p_pk1_column_type   IN fnd_objects.pk1_column_type%TYPE ,
                         p_pk2_column_type   IN fnd_objects.pk2_column_type%TYPE ,
                         p_pk3_column_type   IN fnd_objects.pk3_column_type%TYPE ,
                         p_pk4_column_type   IN fnd_objects.pk4_column_type%TYPE ,
                         p_pk5_column_type   IN fnd_objects.pk5_column_type%TYPE ,
			 p_select_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_insert_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_update_flag       IN VARCHAR2 DEFAULT 'Y',
			 p_delete_flag	     IN VARCHAR2 DEFAULT 'Y',
			 p_enforce_par_sec_flag IN VARCHAR2 DEFAULT 'N',
			 p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_return_message    OUT NOCOPY VARCHAR2
                        )
 IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Update_Object';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_object_id          igs_sc_objects.object_id%TYPE;
   l_obj_group_id       igs_sc_objects.obj_group_id%TYPE;
   l_rowid              VARCHAR2(255);
   l_object_name        fnd_objects.database_object_name%TYPE ;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------

BEGIN

   SAVEPOINT Update_Object_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Validate object group id provided
-- -----------------------------------------------------------------
   l_obj_group_id := Validate_Obj_Grp_ID (p_group_id => p_obj_group_id);

   IF (l_obj_group_id <= 0) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_GROUP');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Check if object exists
-- -----------------------------------------------------------------

  OPEN c_table_name(p_object_id);
  FETCH c_table_name INTO l_object_name;
  CLOSE c_table_name;

  IF l_object_name IS NULL THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJECT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   FND_OBJECTS_PKG.UPDATE_ROW (
         x_object_id =>p_object_id,
         x_obj_name => p_obj_name,
         x_pk1_column_name => p_pk1_column_name,
         x_pk2_column_name => p_pk2_column_name,
         x_pk3_column_name => p_pk3_column_name,
         x_pk4_column_name => p_pk4_column_name,
         x_pk5_column_name => p_pk5_column_name,
         x_pk1_column_type => p_pk1_column_type,
         x_pk2_column_type => p_pk2_column_type,
         x_pk3_column_type => p_pk3_column_type,
         x_pk4_column_type => p_pk4_column_type,
         x_pk5_column_type => p_pk5_column_type,
         x_application_id  => 8405,
         x_database_object_name => p_database_object_name,
         x_display_name      => p_obj_name,
         x_description       => p_obj_name,
         x_last_update_date  => sysdate,
         x_last_updated_by   => nvl(fnd_global.user_id,-1),
         x_last_update_login => nvl(fnd_global.login_id, -1));


   UPDATE IGS_SC_OBJECTS SET
      LAST_UPDATED_BY	=	NVL(FND_GLOBAL.user_id,-1),
      LAST_UPDATE_DATE	=	SYSDATE,
      LAST_UPDATE_LOGIN	=	NVL(FND_GLOBAL.login_id, -1),
      SELECT_FLAG	=	P_SELECT_FLAG,
      INSERT_FLAG	=	P_INSERT_FLAG,
      UPDATE_FLAG	=	P_UPDATE_FLAG,
      DELETE_FLAG	=	P_DELETE_FLAG,
      ENFORCE_PAR_SEC_FLAG =	P_ENFORCE_PAR_SEC_FLAG,
      ACTIVE_FLAG	=	P_ACTIVE_FLAG
   WHERE OBJECT_ID = P_OBJECT_ID
   AND OBJ_GROUP_ID = P_OBJ_GROUP_ID;


   modify_policy(p_database_object_name );


-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Object;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            :
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito        April 23, 2003  New Procedure Created.
   pkpatel             10-Mar-2006     Bug 5081932 (Used wf_local_synch instead of directly updating table wf_local_role)
******************************************************************/
PROCEDURE Update_Local_Role (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_role_name               IN  VARCHAR2,
                              p_role_display_name       IN  VARCHAR2,
                              p_orig_system             IN  VARCHAR2,
                              p_orig_system_id          IN  NUMBER,
                              p_language                IN  VARCHAR2 DEFAULT NULL,
                              p_territory               IN  VARCHAR2 DEFAULT NULL,
                              p_role_description        IN  VARCHAR2 DEFAULT NULL,
                              p_notification_preference IN  VARCHAR2 DEFAULT 'MAILHTML',
                              p_email_address           IN  VARCHAR2 DEFAULT NULL,
                              p_fax                     IN  VARCHAR2 DEFAULT NULL,
                              p_status                  IN  VARCHAR2 DEFAULT 'ACTIVE',
                              p_expiration_date         IN  DATE DEFAULT NULL,
                              p_start_date              IN  DATE DEFAULT SYSDATE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Update_Local_Role';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_parameters         wf_parameter_list_t;
-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------

BEGIN
   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_Role';
       l_debug_str := 'Role Name: '||p_role_name||','||' Role Display Name: '||p_role_display_name||','||'Role Orig System: '||p_orig_system
			||','||' Role Orig System ID: '||p_orig_system_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Update_Local_Roles_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

        wf_event.addparametertolist('USER_NAME',p_role_name,l_parameters);
        wf_event.addparametertolist('DISPLAYNAME',p_role_display_name,l_parameters);
        wf_event.addparametertolist('DESCRIPTION',p_role_description,l_parameters);
        wf_event.addparametertolist('PREFERREDLANGUAGE',p_language,l_parameters);
        wf_event.addparametertolist('ORCLNLSTERRITORY',p_territory,l_parameters);
        wf_event.addparametertolist('ORCLWORKFLOWNOTIFICATIONPREF',p_notification_preference,l_parameters);
        wf_event.addparametertolist('MAIL',p_email_address,l_parameters);
        wf_event.addparametertolist('FACSIMILETELEPHONENUMBER',p_fax,l_parameters);
        wf_event.addparametertolist('ORCLISENABLED',p_status,l_parameters);
        wf_event.addparametertolist('UPDATEONLY','TRUE',l_parameters);

        wf_local_synch.propagate_role(p_orig_system      => p_orig_system,
                                      p_orig_system_id   => p_orig_system_id,
                                      p_attributes       => l_parameters,
                                      p_start_date       => p_start_date,
                                      p_expiration_date  => p_expiration_date
                                      );

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Local_Roles_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_Role.Ex_error';
         l_debug_str := 'Unhandled Exception: Role Name: '||p_role_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Local_Roles_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_Role.Ex_un';
         l_debug_str := 'handled Exception: Role Name: '||p_role_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Local_Roles_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_Role.Ex_others';
         l_debug_str := 'Other Exception: Role Name: '||p_role_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Local_Role;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            :
   Remarks            :

   Change History
   Who                  When            What

------------------------------------------------------------------------
   Don Shellito        April 23, 2003  New Procedure Created.
   pkpatel             10-Mar-2006      Bug 5081932 (Used wf_local_synch instead of private API wf_directory)
******************************************************************/
PROCEDURE Update_Local_User_Role (p_api_version       IN NUMBER,
                                   p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                   p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                   p_user_name           IN wf_local_user_roles.user_name%TYPE,
                                   p_role_name           IN wf_local_user_roles.role_name%TYPE,
                                   p_user_orig_system    IN wf_local_user_roles.user_orig_system%TYPE,
                                   p_user_orig_system_id IN wf_local_user_roles.user_orig_system_id%TYPE,
                                   p_role_orig_system    IN wf_local_user_roles.role_orig_system%TYPE,
                                   p_role_orig_system_id IN wf_local_user_roles.role_orig_system_id%TYPE,
                                   p_start_date          IN wf_local_user_roles.start_date%TYPE,
                                   p_expiration_date     IN wf_local_user_roles.expiration_date%TYPE,
                                   p_security_group_id   IN wf_local_user_roles.security_group_id%TYPE,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Update_Local_User_Role';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------

BEGIN
   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_User_Role';
       l_debug_str := 'Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||'Role Orig System: '||p_role_orig_system
			||','||' Role Orig System ID: '||p_role_orig_system_id||'User Orig System: '||p_user_orig_system
			||','||' User Orig System ID: '||p_user_orig_system_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Update_Local_User_Roles_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

wf_local_synch.propagateUserRole(p_user_name => p_user_name,
                                 p_role_name => p_role_name,
                                 p_user_orig_system    => p_user_orig_system,
                                 p_user_orig_system_id => p_user_orig_system_id,
                                 p_role_orig_system    => p_role_orig_system,
                                 p_role_orig_system_id => p_role_orig_system_id,
                                 p_start_date          => p_start_date,
                                 p_expiration_date     => p_expiration_date
			 	 );

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Local_User_Roles_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_User_Role.Ex_un';
         l_debug_str := 'Unhandled Exception: Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Local_User_Roles_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_User_Role.Ex_error';
         l_debug_str := 'Handled Exception: Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Local_User_Roles_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Local_User_Role.Ex_others';
         l_debug_str := 'Other Exception: Role Name: '||p_role_name||','||' User Name: '||p_user_name||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Local_User_Role;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to handle the
                        updating of the grant information requested.  There
                        will be validations to ensure that the IDs provided
                        have already been defined in the OSS data model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Update_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                        p_function_id       IN igs_sc_grants.function_id%TYPE,
                        p_user_group_id     IN igs_sc_grants.user_group_id%TYPE,
                        p_grant_name        IN igs_sc_grants.grant_name%TYPE,
                        p_grant_text        IN igs_sc_grants.grant_text%TYPE,
                        p_grant_select_flag IN igs_sc_grants.grant_select_flag%TYPE DEFAULT 'N',
                        p_grant_insert_flag IN igs_sc_grants.grant_insert_flag%TYPE DEFAULT 'N',
                        p_grant_update_flag IN igs_sc_grants.grant_update_flag%TYPE DEFAULT 'N',
                        p_grant_delete_flag IN igs_sc_grants.grant_delete_flag%TYPE DEFAULT 'N',
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
 ) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Grant';
   l_update_oper             CONSTANT VARCHAR2(30) := 'UPDATE';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_return_message          VARCHAR2(2000);
   l_message_count           NUMBER(15);
   l_return_status           VARCHAR2(30);
   l_grant_name              igs_sc_grants.grant_name%TYPE;
   l_function_id             igs_sc_grants.function_id%TYPE;
   l_grant_text              igs_sc_grants.grant_text%TYPE;
   l_grant_select_flag       igs_sc_grants.grant_select_flag%TYPE;
   l_grant_delete_flag       igs_sc_grants.grant_delete_flag%TYPE;
   l_grant_update_flag       igs_sc_grants.grant_update_flag%TYPE;
   l_grant_insert_flag       igs_sc_grants.grant_insert_flag%TYPE;
   l_locked_flag             igs_sc_grants.locked_flag%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_grants_values IS
      SELECT grant_name,
             grant_text,
             function_id,
             grant_select_flag,
             grant_delete_flag,
             grant_update_flag,
             grant_insert_flag,
             locked_flag
        FROM igs_sc_grants
       WHERE grant_id = p_grant_id;

BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant';
       l_debug_str := 'Grant ID: '||p_grant_id||','||'Role ID: '||','||p_user_group_id
			||','||' Grant Name: '||p_grant_name||','||' Grant Text: '||p_grant_text||','||'Select Flag: '||p_grant_select_flag
			||','||' Insert Flag: '||p_grant_insert_flag||','||' Update Flag: '||p_grant_update_flag||','||' Delete Flag: '||p_grant_delete_flag;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Update_Grant_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Obtain the previous values of the grants record.
-- -----------------------------------------------------------------
   OPEN c_get_grants_values;
   FETCH c_get_grants_values
    INTO l_grant_name,
         l_grant_text,
         l_function_id,
         l_grant_select_flag,
         l_grant_delete_flag,
         l_grant_update_flag,
         l_grant_insert_flag,
         l_locked_flag;



   IF (c_get_grants_values%NOTFOUND) THEN
      CLOSE c_get_grants_values; --mmkumar
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

      IF (c_get_grants_values%ISOPEN) THEN
         CLOSE c_get_grants_values;
      END IF;

-- -----------------------------------------------------------------
-- Determine if the function ID provided is a valid function ID.
-- -----------------------------------------------------------------
   IF ((p_function_id IS NOT NULL) ) THEN
      l_function_id := Validate_Function_ID (p_function_id => p_function_id);
      IF (l_function_id <= 0) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_FUNC_FOR_GRNT');
         FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

-- -----------------------------------------------------------------
-- Ensure that the values provided are valid for the grants.
-- -----------------------------------------------------------------
   Get_Valid_Grant_Vals (p_grant_select_flag => p_grant_select_flag,
                         p_grant_insert_flag => p_grant_insert_flag,
                         p_grant_delete_flag => p_grant_delete_flag,
                         p_grant_update_flag => p_grant_update_flag,
                         x_grant_select_flag => l_grant_select_flag,
                         x_grant_insert_flag => l_grant_insert_flag,
                         x_grant_delete_flag => l_grant_delete_flag,
                         x_grant_update_flag => l_grant_update_flag
                        );

-- -----------------------------------------------------------------
-- Make sure that the locked flag has a correct value.
-- -----------------------------------------------------------------
   IF (l_locked_flag = 'Y') THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
      FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_update_oper);
      FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;



-- -----------------------------------------------------------------
-- Update the existing record
-- -----------------------------------------------------------------
   UPDATE igs_sc_grants   grts
      SET grts.grant_name             = p_grant_name,
          grts.grant_text             = p_grant_text,
          grts.function_id            = l_function_id,
          grts.user_group_id             = p_user_group_id,
          grts.grant_select_flag      = l_grant_select_flag,
          grts.grant_delete_flag      = l_grant_delete_flag,
          grts.grant_update_flag      = l_grant_update_flag,
          grts.grant_insert_flag      = l_grant_insert_flag,
          grts.last_updated_by        = NVL(FND_GLOBAL.user_id,-1),
          grts.last_update_date       = SYSDATE,
          grts.last_update_login      = NVL(FND_GLOBAL.login_id, -1)
    WHERE grts.grant_id = p_grant_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grants_values%ISOPEN) THEN
         CLOSE c_get_grants_values;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant.Ex_error';
         l_debug_str := 'Handled Exception: Grant ID: '||p_grant_id||','||' Grant Name: '||p_grant_name||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_grants_values%ISOPEN) THEN
         CLOSE c_get_grants_values;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant.Ex_un';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||','||' Grant Name: '||p_grant_name||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grants_values%ISOPEN) THEN
         CLOSE c_get_grants_values;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant.Ex_others';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||','||' Grant Name: '||p_grant_name||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Grant;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to handle
                        the updates on the igs_sc_grant_conds table.
                        There are validations to ensure that the IDs
                        provided are valid.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.
   mmkumar              Jun 28, 2005    Removed code for opening cursor c_get_grant_cond
   prbhardw		Jul 18, 2005    Modified code to update condition number
******************************************************************/
PROCEDURE Update_Grant_Cond (p_api_version         IN NUMBER,
                             p_init_msg_list       IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit              IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_grant_id            IN igs_sc_grant_conds.grant_id%TYPE,
                             p_obj_attrib_id       IN igs_sc_grant_conds.obj_attrib_id%TYPE,
                             p_user_attrib_id      IN igs_sc_grant_conds.user_attrib_id%TYPE,
                             p_condition           IN igs_sc_grant_conds.condition%TYPE,
                             p_text_value          IN igs_sc_grant_conds.text_value%TYPE,
                             p_grant_cond_num      IN igs_sc_grant_conds.grant_cond_num%TYPE,
			     p_old_grant_cond_num  IN igs_sc_grant_conds.grant_cond_num%TYPE DEFAULT 0,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_return_message      OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Update_Grant_Cond';
   l_update_oper        CONSTANT VARCHAR2(30) := 'UPDATE';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_obj_attrib_id      igs_sc_grant_conds.obj_attrib_id%TYPE;
   l_user_attrib_id     igs_sc_grant_conds.user_attrib_id%TYPE;
   l_grant_name         igs_sc_grants.grant_name%TYPE;
   l_old_grant_cond_num  NUMBER;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_grant_cond IS
      SELECT cnds.obj_attrib_id,
             cnds.user_attrib_id
        FROM igs_sc_grant_conds    cnds
       WHERE cnds.grant_id       = p_grant_id
         AND cnds.grant_cond_num = p_grant_cond_num;

   CURSOR c_get_grant_name IS
      SELECT grt.grant_name
        FROM igs_sc_grants    grt
       WHERE grt.grant_id = p_grant_id;

BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant_Cond';
       l_debug_str := 'Grant ID: '||p_grant_id||','||' Object Attribute ID: '||p_obj_attrib_id||','||'User Attribute ID: '||p_user_attrib_id
			||','||'Condition: '||p_condition||','||' Text Value: '||p_text_value||','||'Grant Cond Number: '||p_grant_cond_num;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Update_Grant_Cond_SP;
   IF p_old_grant_cond_num <> 0 THEN
     l_old_grant_cond_num := p_old_grant_cond_num;
   ELSE
     l_old_grant_cond_num := p_grant_cond_num;
   END IF;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check to determine if the grant is locked or not.  If not locked
-- then the update to the condition can happen.
-- -----------------------------------------------------------------
   IF (Is_Grant_Locked(p_grant_id) = 'Y') THEN
      OPEN c_get_grant_name;
      FETCH c_get_grant_name
       INTO l_grant_name;

      CLOSE c_get_grant_name; --mmkumar
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
      FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_update_oper);
      FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;




-- -----------------------------------------------------------------
-- Get the existing values for the record being updated.
-- -----------------------------------------------------------------
   -- mmkumar, removed code where we were opening cursors c_get_grant_cond Bug : 4431768

-- -----------------------------------------------------------------
-- Determine if the parameters given are valid to use for update.
-- -----------------------------------------------------------------
   IF ((p_obj_attrib_id IS NOT NULL)) THEN
      l_obj_attrib_id := Validate_Obj_Attr_ID (p_obj_attr_id => p_obj_attrib_id);
      IF (l_obj_attrib_id <= 0) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_ATTR');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF ((p_user_attrib_id IS NOT NULL) ) THEN
      l_user_attrib_id := Validate_User_Attr_ID (p_user_attr_id => p_user_attrib_id);
      IF (l_user_attrib_id <= 0) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_USR_ATTR');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


-- -----------------------------------------------------------------
-- Update the Grant Conditions record.
-- -----------------------------------------------------------------
   UPDATE igs_sc_grant_conds   cnds
      SET cnds.obj_attrib_id     = l_obj_attrib_id,
          cnds.user_attrib_id    = l_user_attrib_id,
          cnds.condition         = p_condition,
          cnds.text_value        = p_text_value,
          cnds.last_updated_by   = NVL(FND_GLOBAL.user_id,-1),
          cnds.last_update_date  = SYSDATE,
          cnds.last_update_login = NVL(FND_GLOBAL.login_id, -1),
	  cnds.grant_cond_num    = p_grant_cond_num
    WHERE cnds.grant_id       = p_grant_id
      AND cnds.grant_cond_num = l_old_grant_cond_num;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant_Cond.Ex_un';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||','||' Condtion Number: '||p_grant_cond_num||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant_Cond.Ex_error';
         l_debug_str := 'Handled Exception: Grant ID: '||p_grant_id||','||' Condtion Number: '||p_grant_cond_num||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Update_Grant_Cond.Ex_others';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||','||' Condtion Number: '||p_grant_cond_num||','||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Grant_Cond;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to handle
                        the updating of the igs_sc_obj_groups records.
                        There is validation on the IDs given and ensure
                        that the appropriate values are updated.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Update_Object_Group (p_api_version            IN NUMBER,
                               p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_commit                 IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_obj_group_id           IN igs_sc_obj_groups.obj_group_id%TYPE,
                               p_obj_group_name         IN igs_sc_obj_groups.obj_group_name%TYPE ,
                               p_default_policy_type    IN igs_sc_obj_groups.default_policy_type%TYPE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_return_message         OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Object_Group';
   l_update_oper             CONSTANT VARCHAR2(30) := 'UPDATE';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_return_message          VARCHAR2(2000);
   l_message_count           NUMBER(15);
   l_return_status           VARCHAR2(30);
   l_obj_group_name          igs_sc_obj_groups.obj_group_name%TYPE;
   l_default_policy_type     igs_sc_obj_groups.default_policy_type%TYPE;
   l_grant_name              igs_sc_grants.grant_name%TYPE;
   l_grant_id                igs_sc_grants.grant_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_obj_group IS
      SELECT grps.obj_group_name,
             grps.default_policy_type
        FROM igs_sc_obj_groups    grps
       WHERE grps.obj_group_id = p_obj_group_id;

   CURSOR c_get_grant_name IS
      SELECT grt.grant_name
        FROM igs_sc_grants    grt
       WHERE grt.grant_id = l_grant_id;

   CURSOR c_get_grants IS
      SELECT grt.grant_id,
             grt.grant_name
        FROM igs_sc_grants     grt
       WHERE grt.obj_group_id = p_obj_group_id;

BEGIN

   SAVEPOINT Update_Object_Group_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
-- -----------------------------------------------------------------
-- Obtain the latest values for the object group being updated.
-- -----------------------------------------------------------------
   OPEN c_get_obj_group;
   FETCH c_get_obj_group
    INTO l_obj_group_name,
         l_default_policy_type;

   IF (c_get_obj_group%NOTFOUND) THEN
      CLOSE c_get_obj_group; --mmkumar
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_OBJ_GRP_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Check values being updated.
-- -----------------------------------------------------------------
   IF ((p_default_policy_type IS NOT NULL) ) THEN
      l_default_policy_type := p_default_policy_type;
   END IF;

   IF ((p_obj_group_name IS NOT NULL)  ) THEN
      l_obj_group_name := p_obj_group_name;
   END IF;

   IF (c_get_obj_group%ISOPEN) THEN
         CLOSE c_get_obj_group;
   END IF;



-- -----------------------------------------------------------------
-- Ensure that the default policy value is valid.
-- -----------------------------------------------------------------
   IF (l_default_policy_type NOT IN ('G', 'R')) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_DEF_POLICY_TYPE');
      FND_MESSAGE.SET_TOKEN('DEFAULT_POLICY', l_default_policy_type);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- Update the object groups information for the group ID given.
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

   UPDATE igs_sc_obj_groups   objs
      SET objs.default_policy_type    = l_default_policy_type,
          objs.last_updated_by        = NVL(FND_GLOBAL.user_id,-1),
          objs.last_update_date       = SYSDATE,
          objs.last_update_login      = NVL(FND_GLOBAL.login_id, -1)
    WHERE objs.obj_group_id = p_obj_group_id;

  ELSE

   UPDATE igs_sc_obj_groups   objs
      SET objs.obj_group_name         = l_obj_group_name,
          objs.default_policy_type    = l_default_policy_type,
          objs.last_updated_by        = NVL(FND_GLOBAL.user_id,-1),
          objs.last_update_date       = SYSDATE,
          objs.last_update_login      = NVL(FND_GLOBAL.login_id, -1)
    WHERE objs.obj_group_id = p_obj_group_id;

  END IF;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_obj_group%ISOPEN) THEN
         CLOSE c_get_obj_group;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Group_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_obj_group%ISOPEN) THEN
         CLOSE c_get_obj_group;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Group_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_obj_group%ISOPEN) THEN
         CLOSE c_get_obj_group;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Group_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Object_Group;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to ensure that
                        the updates made to igs_sc_obj_att_mths is perform
                        with the proper validation.  The IDs are validated
                        to ensure they exist in the OSS data model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Update_Object_Attr_Method (p_api_version       IN NUMBER,
                                     p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                     p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                     p_obj_attrib_type   IN igs_sc_obj_att_mths.obj_attrib_type%TYPE,
                                     p_static_type       IN igs_sc_obj_att_mths.static_type%TYPE,
                                     p_select_text       IN igs_sc_obj_att_mths.select_text%TYPE,
				     p_null_allow_flag   IN VARCHAR2 DEFAULT 'N',
				     p_call_from_lct	 IN VARCHAR2 DEFAULT 'N',
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Update_Object_Attr_Method';
   l_update_oper        CONSTANT VARCHAR2(30) := 'UPDATE';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_obj_attrib_type    igs_sc_obj_att_mths.obj_attrib_type%TYPE;
   l_static_type        igs_sc_obj_att_mths.static_type%TYPE;
   l_select_text        igs_sc_obj_att_mths.select_text%TYPE;
   l_grant_id           igs_sc_grants.grant_id%TYPE;
   l_grant_name         igs_sc_grants.grant_name%TYPE;
   l_object_name        fnd_objects.database_object_name%TYPE;


-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_obj_mthd IS
      SELECT mthd.obj_attrib_type,
             mthd.static_type,
             mthd.select_text
        FROM igs_sc_obj_att_mths   mthd
       WHERE mthd.object_id     = p_object_id
         AND mthd.obj_attrib_id = p_obj_attrib_id;

   CURSOR c_get_grant_info IS
      SELECT cond.grant_id,
             grt.grant_name
        FROM igs_sc_grant_conds   cond,
             igs_sc_grants        grt
       WHERE cond.obj_attrib_id  = p_obj_attrib_id
         AND grt.grant_id        = cond.grant_id;

BEGIN

   SAVEPOINT Update_Object_Attr_Method_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;
-- -----------------------------------------------------------------
-- Determine if there is a grant associated to the user attribute so
-- that the check on lock can be performed.
-- -----------------------------------------------------------------
   OPEN c_get_grant_info;
   FETCH c_get_grant_info
    INTO l_grant_id,
         l_grant_name;

   WHILE (c_get_grant_info%FOUND) LOOP

-- -----------------------------------------------------------------
-- Check to determine if the grant is locked or not.  If not locked
-- then the update to the condition can happen.
-- -----------------------------------------------------------------
      IF (Is_Grant_Locked(l_grant_id) = 'Y') THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
         FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_update_oper);
         FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_grant_info
       INTO l_grant_id,
            l_grant_name;

   END LOOP;

   CLOSE c_get_grant_info;

-- -----------------------------------------------------------------
-- Obtain the previous values of the object method before update
-- -----------------------------------------------------------------
   OPEN c_get_obj_mthd;
   FETCH c_get_obj_mthd
    INTO l_obj_attrib_type,
         l_static_type,
         l_select_text;

   IF (c_get_obj_mthd%NOTFOUND) THEN

      -- Call Insert instead
       Insert_Object_Attr_Method (p_api_version  => p_api_version,
                                     p_init_msg_list  => p_init_msg_list,
                                     p_commit         => p_commit,
                                     p_object_id      => p_object_id,
                                     p_obj_attrib_id  => p_obj_attrib_id,
                                     p_obj_attrib_type => p_obj_attrib_type,
                                     p_static_type    => p_static_type,
                                     p_select_text    => p_select_text,
				     p_null_allow_flag=> p_null_allow_flag,
                                     x_return_status  => x_return_status,
                                     x_return_message => x_return_message );
      return;


/*    FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_OBJ_MTHD_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
*/
   END IF;

-- -----------------------------------------------------------------
-- Validate the information that is to be updated.
-- -----------------------------------------------------------------
   IF ((p_obj_attrib_type IS NOT NULL)  ) THEN
      l_obj_attrib_type := Validate_Obj_Attr_type (p_obj_att_type => p_obj_attrib_type);
      IF (l_obj_attrib_type IS NULL) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_OBJ_ATTR_TYPE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF ((p_static_type IS NOT NULL)  ) THEN
      l_static_type := Validate_Static_Type (p_static_type => p_static_type);
      IF (l_static_type IS NULL) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_STATIC_TYPE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF ((p_select_text is NOT NULL)  ) THEN
      l_select_text := p_select_text;
   END IF;

   CLOSE c_get_obj_mthd;

-- -----------------------------------------------------------------
-- Update the Object Attribute Methods.
-- -----------------------------------------------------------------
   IF P_CALL_FROM_LCT <> 'Y' THEN
      OPEN c_table_name(p_object_id);
      FETCH c_table_name INTO l_object_name;
      CLOSE c_table_name;
      IF NOT check_attrib_text ( l_object_name, l_select_text,l_obj_attrib_type) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRNT_TXT_ERR');
          FND_MESSAGE.SET_TOKEN('OBJ_NAME',l_object_name);
          FND_MESSAGE.SET_TOKEN('GRNT_TEXT', p_select_text);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


   UPDATE igs_sc_obj_att_mths   mthd
      SET mthd.obj_attrib_type   = l_obj_attrib_type,
          mthd.static_type       = l_static_type,
          mthd.select_text       = l_select_text,
          mthd.last_updated_by   = NVL(FND_GLOBAL.user_id,-1),
          mthd.last_update_date  = SYSDATE,
          mthd.last_update_login = NVL(FND_GLOBAL.login_id, -1),
	  mthd.null_allow_flag   = p_null_allow_flag
    WHERE mthd.object_id     = p_object_id
      AND mthd.obj_attrib_id = p_obj_attrib_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_obj_mthd%ISOPEN) THEN
         CLOSE c_get_obj_mthd;
      END IF;
      IF (c_get_grant_info%ISOPEN) THEN
         CLOSE c_get_grant_info;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Attr_Method_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_obj_mthd%ISOPEN) THEN
         CLOSE c_get_obj_mthd;
      END IF;
      IF (c_get_grant_info%ISOPEN) THEN
         CLOSE c_get_grant_info;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Attr_Method_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_obj_mthd%ISOPEN) THEN
         CLOSE c_get_obj_mthd;
      END IF;
      IF (c_get_grant_info%ISOPEN) THEN
         CLOSE c_get_grant_info;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Attr_Method_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Object_Attr_Method;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : This procedure is designed for the updates
                        to be made to the table igs_sc_obj_functns.
                        There are validations performed on the IDs that
                        are provided to ensure they exist in the OSS
                        data model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Update_Object_Func (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_function_id       IN igs_sc_obj_functns.function_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_functns.obj_group_id%TYPE,
                              p_function_name     IN igs_sc_obj_functns.function_name%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
 ) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Object_Func';
   l_api_version        CONSTANT NUMBER        := 1.0;
   l_update_oper        CONSTANT VARCHAR2(30)  := 'UPDATE';
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_obj_group_id       igs_sc_obj_functns.obj_group_id%TYPE;
   l_function_name      igs_sc_obj_functns.function_name%TYPE;
   l_grant_id           igs_sc_grants.grant_id%TYPE;
   l_grant_name         igs_sc_grants.grant_name%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_func_values IS
      SELECT fnc.obj_group_id,
             fnc.function_name
        FROM igs_sc_obj_functns     fnc
       WHERE fnc.function_id = p_function_id;

   CURSOR c_get_grants IS
      SELECT grt.grant_id,
             grt.grant_name
        FROM igs_sc_grants     grt
       WHERE grt.function_id = p_function_id;

BEGIN

   SAVEPOINT Update_Object_Func_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;
-- -----------------------------------------------------------------
-- Ensure that there are no locked grants against the function that
-- is being updated.
-- -----------------------------------------------------------------
   OPEN c_get_grants;
   FETCH c_get_grants
    INTO l_grant_id,
         l_grant_name;

   WHILE (c_get_grants%FOUND) LOOP

      IF (Is_Grant_Locked(l_grant_id) = 'Y') THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
         FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_update_oper);
         FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_grants
       INTO l_grant_id,
            l_grant_name;

   END LOOP;

-- -----------------------------------------------------------------
-- Obtain the previous function ID values.
-- -----------------------------------------------------------------
   OPEN c_get_func_values;
   FETCH c_get_func_values
    INTO l_obj_group_id,
         l_function_name;

   IF (c_get_func_values%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_OBJ_FUNC_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_get_func_values;

-- -----------------------------------------------------------------
-- Update the object function values received.
-- -----------------------------------------------------------------
   UPDATE igs_sc_obj_functns   fnct
      SET fnct.function_name     = p_function_name,
          fnct.last_updated_by   = NVL(FND_GLOBAL.user_id,-1),
          fnct.last_update_date  = SYSDATE,
          fnct.last_update_login = NVL(FND_GLOBAL.login_id, -1)
    WHERE fnct.function_id = p_function_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_func_values%ISOPEN) THEN
         CLOSE c_get_func_values;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Func_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_func_values%ISOPEN) THEN
         CLOSE c_get_func_values;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Func_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_func_values%ISOPEN) THEN
         CLOSE c_get_func_values;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Func_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Object_Func;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is for the updates
                        to be made to data present in igs_sc_obj_attribs.
                        The IDs that are provided are validated to ensure
                        data present in the OSS data model.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Update_Object_Attr (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_obj_attrib_id     IN igs_sc_obj_attribs.obj_attrib_id%TYPE,
                              p_obj_group_id      IN igs_sc_obj_attribs.obj_group_id%TYPE,
                              p_obj_attrib_name   IN igs_sc_obj_attribs.obj_attrib_name%TYPE,
			      p_active_flag       IN VARCHAR2 DEFAULT 'Y',
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Object_Attr';
   l_update_oper        CONSTANT VARCHAR2(30)  := 'UPDATE';
   l_api_version        CONSTANT NUMBER        := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_obj_group_id       igs_sc_obj_attribs.obj_group_id%TYPE;
   l_obj_attrib_name    igs_sc_obj_attribs.obj_attrib_name%TYPE;
   l_grant_id           igs_sc_grant_conds.grant_id%TYPE;
   l_grant_name         igs_sc_grants.grant_name%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_obj_attrib IS
      SELECT attr.obj_group_id,
             attr.obj_attrib_name
        FROM igs_sc_obj_attribs     attr
       WHERE attr.obj_attrib_id = p_obj_attrib_id;

   CURSOR c_get_grant_info IS
      SELECT cond.grant_id,
             grt.grant_name
        FROM igs_sc_grant_conds   cond,
             igs_sc_grants        grt
       WHERE cond.obj_attrib_id  = p_obj_attrib_id
         AND grt.grant_id        = cond.grant_id;

BEGIN

   SAVEPOINT Update_Object_Attr_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Determine if there is a grant associated to the user attribute so
-- that the check on lock can be performed.
-- -----------------------------------------------------------------
   OPEN c_get_grant_info;
   FETCH c_get_grant_info
    INTO l_grant_id,
         l_grant_name;

   WHILE (c_get_grant_info%FOUND) LOOP

-- -----------------------------------------------------------------
-- Check to determine if the grant is locked or not.  If not locked
-- then the update to the condition can happen.
-- -----------------------------------------------------------------
      IF (Is_Grant_Locked(l_grant_id) = 'Y') THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
         FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_update_oper);
         FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_grant_info
       INTO l_grant_id,
            l_grant_name;

   END LOOP;

   CLOSE c_get_grant_info;

-- -----------------------------------------------------------------
-- Obtain the previous function ID values.
-- -----------------------------------------------------------------
   OPEN c_get_obj_attrib;
   FETCH c_get_obj_attrib
    INTO l_obj_group_id,
         l_obj_attrib_name;

   IF (c_get_obj_attrib%NOTFOUND) THEN
      CLOSE c_get_obj_attrib; --mmkumar
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_OBJ_ATTR_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

    IF (c_get_obj_attrib%ISOPEN) THEN
         CLOSE c_get_obj_attrib;
    END IF;



-- ----------------------------------------------------------------
-- Update the object attributes with the values received.
-- ----------------------------------------------------------------
   UPDATE igs_sc_obj_attribs   attr
      SET attr.obj_attrib_name   = p_obj_attrib_name,
          attr.last_updated_by   = NVL(FND_GLOBAL.user_id,-1),
          attr.last_update_date  = SYSDATE,
          attr.last_update_login = NVL(FND_GLOBAL.login_id, -1),
	  attr.active_flag	 = p_active_flag
    WHERE attr.obj_attrib_id = p_obj_attrib_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_obj_attrib%ISOPEN) THEN
         CLOSE c_get_obj_attrib;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Attr_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_obj_attrib%ISOPEN) THEN
         CLOSE c_get_obj_attrib;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Attr_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_obj_attrib%ISOPEN) THEN
         CLOSE c_get_obj_attrib;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_Object_Attr_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_Object_Attr;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is for the updates
                        that are required to the table igs_sc_usr_attribs.
                        There is validation on the types and the IDs to
                        ensure data is in OSS data model and for integrity.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Update_User_Attr (p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_user_attrib_id    IN igs_sc_usr_attribs.user_attrib_id%TYPE,
                            p_user_attrib_name  IN igs_sc_usr_attribs.user_attrib_name%TYPE,
                            p_user_attrib_type  IN igs_sc_usr_attribs.user_attrib_type%TYPE,
                            p_static_type       IN igs_sc_usr_attribs.static_type%TYPE,
                            p_select_text       IN igs_sc_usr_attribs.select_text%TYPE,
			    p_active_flag       IN igs_sc_usr_attribs.active_flag%TYPE,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30)  := 'Update_User_Attr';
   l_update_oper        CONSTANT VARCHAR2(30)  := 'UPDATE';
   l_api_version        CONSTANT NUMBER        := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_user_attrib_name   igs_sc_usr_attribs.user_attrib_name%TYPE;
   l_user_attrib_type   igs_sc_usr_attribs.user_attrib_type%TYPE;
   l_static_type        igs_sc_usr_attribs.static_type%TYPE;
   l_select_text        igs_sc_usr_attribs.select_text%TYPE;
   l_grant_name         igs_sc_grants.grant_name%TYPE;
   l_grant_id           igs_sc_grants.grant_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_usr_attrib IS
      SELECT attr.user_attrib_name,
             attr.user_attrib_type,
             attr.static_type,
             attr.select_text
        FROM igs_sc_usr_attribs    attr
       WHERE attr.user_attrib_id = p_user_attrib_id;

   CURSOR c_get_grant_info IS
      SELECT cond.grant_id,
             grt.grant_name
        FROM igs_sc_grant_conds   cond,
             igs_sc_grants        grt
       WHERE cond.user_attrib_id = p_user_attrib_id
         AND grt.grant_id        = cond.grant_id;

BEGIN

   SAVEPOINT Update_User_Attr_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;



-- -----------------------------------------------------------------
-- Determine if there is a grant associated to the user attribute so
-- that the check on lock can be performed.
-- -----------------------------------------------------------------
   OPEN c_get_grant_info;
   FETCH c_get_grant_info
    INTO l_grant_id,
         l_grant_name;

   WHILE (c_get_grant_info%FOUND) LOOP

-- -----------------------------------------------------------------
-- Check to determine if the grant is locked or not.  If not locked
-- then the update to the condition can happen.
-- -----------------------------------------------------------------
      IF (Is_Grant_Locked(l_grant_id) = 'Y') THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
         FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_update_oper);
         FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_grant_info
       INTO l_grant_id,
            l_grant_name;

   END LOOP;

   CLOSE c_get_grant_info;

-- -----------------------------------------------------------------
-- Obtain the previous User Attribute values.
-- -----------------------------------------------------------------
   OPEN c_get_usr_attrib;
   FETCH c_get_usr_attrib
    INTO l_user_attrib_name,
         l_user_attrib_type,
         l_static_type,
         l_select_text;

   IF (c_get_usr_attrib%NOTFOUND) THEN
      CLOSE c_get_usr_attrib; --mmkumar
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_USR_ATTR_NOT_FOUND');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

      IF (c_get_usr_attrib%ISOPEN) THEN
         CLOSE c_get_usr_attrib;
      END IF;


-- -----------------------------------------------------------------
-- Validate the values to be updated.
-- -----------------------------------------------------------------
   IF ((p_user_attrib_type IS NOT NULL)  ) THEN
      l_user_attrib_type := Validate_User_Attr_Type (p_usr_att_type => p_user_attrib_type);
      IF (l_user_attrib_type IS NULL) THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_USR_ATT_TYPE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   l_static_type := Validate_Static_Type (p_static_type => p_static_type);
   IF (l_static_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_INV_STATIC_TYPE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ((p_select_text IS NOT NULL)  ) THEN
      l_select_text := p_select_text;
   END IF;

   IF ((p_user_attrib_name IS NOT NULL) ) THEN
      l_user_attrib_name := p_user_attrib_name;
   END IF;



   IF NOT check_attrib_text ( 'DUAL', l_select_text,l_user_attrib_type) THEN

          FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRNT_TXT_ERR');
          FND_MESSAGE.SET_TOKEN('OBJ_NAME','USER_ATTRIB');
          FND_MESSAGE.SET_TOKEN('GRNT_TEXT', l_select_text);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Update the user attribute values.
-- -----------------------------------------------------------------
   UPDATE igs_sc_usr_attribs   attr
      SET attr.user_attrib_name  = l_user_attrib_name,
          attr.user_attrib_type  = l_user_attrib_type,
          attr.static_type       = l_static_type,
          attr.select_text       = l_select_text,
          attr.last_updated_by   = NVL(FND_GLOBAL.user_id,-1),
          attr.last_update_date  = SYSDATE,
          attr.last_update_login = NVL(FND_GLOBAL.login_id, -1),
	  attr.active_flag       = p_active_flag
    WHERE attr.user_attrib_id = p_user_attrib_id;

   IF l_static_type IN ('C','S') AND (p_active_flag = 'Y') THEN

    IGS_SC_GRANTS_PVT.POPULATE_USER_ATTRIB (
        P_API_VERSION      => 1.0,
        P_ATTRIB_ID        => p_user_attrib_id,
        P_USER_ID          => NULL,
        P_ALL_ATTRIBS      => 'Y',
        X_RETURN_STATUS    => l_return_status,
        X_MSG_COUNT        => l_message_count,
        X_MSG_DATA         => l_return_message
     );


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
  ELSE
   -- delete all curent values
   Delete_User_Attr_Val (p_api_version       => l_api_version,
                         p_user_attrib_id    => p_user_attrib_id,
                         p_user_id           => NULL,
                         x_return_status     => l_return_status,
                         x_return_message    => l_return_message
                       );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;


-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (c_get_grant_info%ISOPEN) THEN
         CLOSE c_get_grant_info;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_User_Attr_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_usr_attrib%ISOPEN) THEN
         CLOSE c_get_usr_attrib;
      END IF;
      IF (c_get_grant_info%ISOPEN) THEN
         CLOSE c_get_grant_info;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_User_Attr_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_usr_attrib%ISOPEN) THEN
         CLOSE c_get_usr_attrib;
      END IF;
      IF (c_get_grant_info%ISOPEN) THEN
         CLOSE c_get_grant_info;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Update_User_Attr_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Update_User_Attr;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove
                        the object group from the OSS data model.  The
                        Child tables that reference the object group ID
                        will also be removed.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Object_Group (p_api_version       IN NUMBER,
                               p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_obj_group_id      IN igs_sc_obj_groups.obj_group_id%TYPE,
                               x_return_status     OUT NOCOPY VARCHAR2,
                               x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Object_Group';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_object_id          igs_sc_objects.object_id%TYPE;
   l_function_id        igs_sc_obj_functns.function_id%TYPE;
   l_grant_id           igs_sc_grants.grant_id%TYPE;
   l_obj_attrib_id      igs_sc_obj_attribs.obj_attrib_id%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_object_id IS
      SELECT objs.object_id
        FROM igs_sc_objects    objs
       WHERE objs.obj_group_id = p_obj_group_id;

   CURSOR c_get_function_id IS
      SELECT funcs.function_id
        FROM igs_sc_obj_functns    funcs
       WHERE funcs.obj_group_id = p_obj_group_id;

   CURSOR c_get_grant_id IS
      SELECT grts.grant_id
        FROM igs_sc_grants     grts
       WHERE grts.obj_group_id = p_obj_group_id;

   CURSOR c_get_obj_attr_id IS
      SELECT attrs.obj_attrib_id
        FROM igs_sc_obj_attribs      attrs
       WHERE attrs.obj_group_id = p_obj_group_id;

BEGIN

   SAVEPOINT Delete_Object_Group_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;
-- -----------------------------------------------------------------
-- Delete all the grants associated to the group provided
-- -----------------------------------------------------------------
   OPEN c_get_grant_id;
   FETCH c_get_grant_id
    INTO l_grant_id;

   WHILE (c_get_grant_id%FOUND) LOOP

      Delete_Grant (p_api_version       => l_api_version,
                    p_grant_id          => l_grant_id,
                    x_return_status     => l_return_status,
                    x_return_message    => l_return_message
                   );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_grant_id
       INTO l_grant_id;

   END LOOP;

   IF (c_get_grant_id%ISOPEN) THEN
      CLOSE c_get_grant_id;
   END IF;

-- -----------------------------------------------------------------
-- Delete all the object attributes associated to the group provided
-- -----------------------------------------------------------------
   OPEN c_get_obj_attr_id;
   FETCH c_get_obj_attr_id
    INTO l_obj_attrib_id;

   WHILE (c_get_obj_attr_id%FOUND) LOOP

      Delete_Object_Attr (p_api_version       => l_api_version,
                          p_obj_attrib_id     => l_obj_attrib_id,
                          x_return_status     => l_return_status,
                          x_return_message    => l_return_message
                         );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_obj_attr_id
       INTO l_obj_attrib_id;

   END LOOP;

   IF (c_get_obj_attr_id%ISOPEN) THEN
      CLOSE c_get_obj_attr_id;
   END IF;

-- -----------------------------------------------------------------
-- Delete all the object functions associated to the group provided
-- -----------------------------------------------------------------
   OPEN c_get_function_id;
   FETCH c_get_function_id
    INTO l_function_id;

   WHILE (c_get_function_id%FOUND) LOOP

      Delete_Object_Func (p_api_version       => l_api_version,
                          p_function_id       => l_function_id,
                          x_return_status     => l_return_status,
                          x_return_message    => l_return_message
                          );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_function_id
       INTO l_function_id;

   END LOOP;

   IF (c_get_function_id%ISOPEN) THEN
      CLOSE c_get_function_id;
   END IF;

-- -----------------------------------------------------------------
-- Delete all the objects associated to the group provided
-- -----------------------------------------------------------------
   OPEN c_get_object_id;
   FETCH c_get_object_id
    INTO l_object_id;

   WHILE (c_get_object_id%FOUND) LOOP

      Delete_Object (p_api_version       => l_api_version,
                     p_obj_group_id      => p_obj_group_id,
                     p_object_id         => l_object_id,
                     x_return_status     => l_return_status,
                     x_return_message    => l_return_message
                    );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_object_id
       INTO l_object_id;

   END LOOP;

   IF (c_get_object_id%ISOPEN) THEN
      CLOSE c_get_object_id;
   END IF;

-- -----------------------------------------------------------------
-- Delete the object group group that has been requested for delete.
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_obj_groups    grps
    WHERE grps.obj_group_id = p_obj_group_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_id%ISOPEN) THEN
         CLOSE c_get_grant_id;
      END IF;
      IF (c_get_object_id%ISOPEN) THEN
         CLOSE c_get_object_id;
      END IF;
      IF (c_get_obj_attr_id%ISOPEN) THEN
         CLOSE c_get_obj_attr_id;
      END IF;
      IF (c_get_function_id%ISOPEN) THEN
         CLOSE c_get_function_id;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Group_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_grant_id%ISOPEN) THEN
         CLOSE c_get_grant_id;
      END IF;
      IF (c_get_object_id%ISOPEN) THEN
         CLOSE c_get_object_id;
      END IF;
      IF (c_get_obj_attr_id%ISOPEN) THEN
         CLOSE c_get_obj_attr_id;
      END IF;
      IF (c_get_function_id%ISOPEN) THEN
         CLOSE c_get_function_id;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Group_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_id%ISOPEN) THEN
         CLOSE c_get_grant_id;
      END IF;
      IF (c_get_object_id%ISOPEN) THEN
         CLOSE c_get_object_id;
      END IF;
      IF (c_get_obj_attr_id%ISOPEN) THEN
         CLOSE c_get_obj_attr_id;
      END IF;
      IF (c_get_function_id%ISOPEN) THEN
         CLOSE c_get_function_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Group_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Object_Group;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove the
                        object attribute requested from the OSS data model.
                        This will ensure that all child tables that have
                        reference to the object attribute are also removed.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Object_Attr (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_obj_attrib_id     IN igs_sc_obj_attribs.obj_attrib_id%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Object_Attr';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_grant_id           igs_sc_grant_conds.grant_id%TYPE;
   l_grant_cond_num     igs_sc_grant_conds.grant_cond_num%TYPE;
   l_object_id_mthd     igs_sc_obj_att_mths.object_id%TYPE;
   l_object_id_val      igs_sc_obj_att_vals.object_id%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_object_id_mthd IS
      SELECT objs.object_id
        FROM igs_sc_obj_att_mths     objs
       WHERE objs.obj_attrib_id = p_obj_attrib_id;

   CURSOR c_get_object_id_val IS
      SELECT attrs.object_id
        FROM igs_sc_obj_att_vals     attrs
       WHERE attrs.obj_attrib_id = p_obj_attrib_id;

BEGIN

   SAVEPOINT Delete_Object_Attr_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF (NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

   OPEN c_get_object_id_val;
   FETCH c_get_object_id_val
    INTO l_object_id_val;

   WHILE (c_get_object_id_val%FOUND)  LOOP

-- -----------------------------------------------------------------
-- Delete all the object attribute values that are associated to the
-- object attribute that is being requested for deletion.
-- -----------------------------------------------------------------
      Delete_Object_Attr_Val (p_api_version       => l_api_version,
                              p_obj_attrib_id     => p_obj_attrib_id,
                              p_object_id         => l_object_id_val,
                              x_return_status     => l_return_status,
                              x_return_message    => l_return_message
                             );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_object_id_val
       INTO l_object_id_val;

   END LOOP;

   IF (c_get_object_id_val%ISOPEN) THEN
      CLOSE c_get_object_id_val;
   END IF;

-- -----------------------------------------------------------------
-- Delete the object attribute methods that are associated to
-- the attribute being deleted.
-- -----------------------------------------------------------------
   OPEN c_get_object_id_mthd;
   FETCH c_get_object_id_mthd
    INTO l_object_id_mthd;

   WHILE (c_get_object_id_mthd%FOUND)  LOOP

      Delete_Object_Attr_Method (p_api_version       => l_api_version,
                                 p_object_id         => l_object_id_mthd,
                                 p_obj_attrib_id     => p_obj_attrib_id,
                                 x_return_status     => l_return_status,
                                 x_return_message    => l_return_message
                                );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_object_id_mthd
       INTO l_object_id_mthd;

   END LOOP;

   IF (c_get_object_id_mthd%ISOPEN) THEN
      CLOSE c_get_object_id_mthd;
   END IF;

-- -----------------------------------------------------------------
-- Delete the attribute that has been requested for deletion.
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_obj_attribs     attrs
    WHERE attrs.obj_attrib_id = p_obj_attrib_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_object_id_mthd%ISOPEN) THEN
         CLOSE c_get_object_id_mthd;
      END IF;
      IF (c_get_object_id_val%ISOPEN) THEN
         CLOSE c_get_object_id_val;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_object_id_mthd%ISOPEN) THEN
         CLOSE c_get_object_id_mthd;
      END IF;
      IF (c_get_object_id_val%ISOPEN) THEN
         CLOSE c_get_object_id_val;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_object_id_mthd%ISOPEN) THEN
         CLOSE c_get_object_id_mthd;
      END IF;
      IF (c_get_object_id_val%ISOPEN) THEN
         CLOSE c_get_object_id_val;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Object_Attr;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove the
                        object attribute method from the OSS data model.
                        There are no child tables that have reference to
                        the methods so there is no need to remove any
                        references.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Object_Attr_Method (p_api_version       IN NUMBER,
                                     p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                     p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                     p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Object_Attr_Method';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_message_count      NUMBER(15);

BEGIN

   SAVEPOINT Delete_Object_Attr_Method_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;


-- -----------------------------------------------------------------
-- Delete all the methods associated to the object_id and the
-- obj_attrib_id provided.
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_obj_att_mths     mtds
    WHERE mtds.object_id     = p_object_id
      AND mtds.obj_attrib_id = p_obj_attrib_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_Method_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_Method_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_Method_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Object_Attr_Method;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove the
                        object function from the OSS data model.  The
                        child table on grants that have any reference to
                        this function being removed shall also be removed.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Object_Func (p_api_version       IN NUMBER,
                              p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_function_id       IN  igs_sc_obj_functns.function_id%TYPE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Object_Func';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_grant_id           igs_sc_grants.grant_id%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_grant_id IS
      SELECT grt.grant_id
        FROM igs_sc_grants          grt,
             igs_sc_obj_functns     fnc
       WHERE fnc.function_id  = p_function_id
         AND grt.function_id  = fnc.function_id
         AND grt.obj_group_id = fnc.obj_group_id;

BEGIN

   SAVEPOINT Delete_Object_Func_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
     FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Delete all the grants that are associated to the function_id
-- provided.
-- -----------------------------------------------------------------
   OPEN c_get_grant_id;
   FETCH c_get_grant_id
    INTO l_grant_id;

   WHILE (c_get_grant_id%FOUND)  LOOP

      Delete_Grant (p_api_version       => l_api_version,
                    p_grant_id          => l_grant_id,
                    x_return_status     => l_return_status,
                    x_return_message    => l_return_message
                   );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      FETCH c_get_grant_id
       INTO l_grant_id;

   END LOOP;

   IF (c_get_grant_id%ISOPEN) THEN
      CLOSE c_get_grant_id;
   END IF;

-- -----------------------------------------------------------------
-- Delete the function that is provided.
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_obj_functns     fctn
    WHERE fctn.function_id = p_function_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_id%ISOPEN) THEN
         CLOSE c_get_grant_id;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Func_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_grant_id%ISOPEN) THEN
         CLOSE c_get_grant_id;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Func_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_id%ISOPEN) THEN
         CLOSE c_get_grant_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Func_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Object_Func;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove the
                        object attribute value from the OSS data model.
                        There are no child tables that need to be cleaned
                        of the object attribute value.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Object_Attr_Val (p_api_version       IN NUMBER,
                                  p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_object_id         IN igs_sc_obj_att_mths.object_id%TYPE,
                                  p_obj_attrib_id     IN igs_sc_obj_att_mths.obj_attrib_id%TYPE,
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Object_Attr_Val';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_message_count      NUMBER(15);

BEGIN

   SAVEPOINT Delete_Object_Attr_Val_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Delete the attribute values that are associated to the attribute
-- id and object id provided.
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_obj_att_vals     oval
    WHERE oval.obj_attrib_id = p_obj_attrib_id
      AND oval.object_id     = p_object_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_Val_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_Val_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_Attr_Val_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Object_Attr_Val;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove
                        the object from the OSS data model.  There are
                        no child tables that are to be cleaned of the
                        object being removed.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Object (p_api_version       IN NUMBER,
                         p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_obj_group_id      IN igs_sc_objects.obj_group_id%TYPE,
                         p_object_id         IN igs_sc_objects.object_id%TYPE,
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Object';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_message_count      NUMBER(15);
   l_database_object_name VARCHAR2(255);

   CURSOR c_obj IS
     SELECT database_object_name
       FROM fnd_objects
      WHERE object_id = p_object_id;
BEGIN

   SAVEPOINT Delete_Object_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;
-- -----------------------------------------------------------------
-- Delete the objects that are associated to the object group id and
-- the object id provided.
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_objects     objs
    WHERE objs.obj_group_id = p_obj_group_id
      AND objs.object_id    = p_object_id;

  OPEN c_obj;
  FETCH c_obj INTO l_database_object_name;
  CLOSE c_obj;


--  FND_OBJECTS_PKG.DELETE_ROW (x_object_id =>p_object_id);


  modify_policy(l_database_object_name,'DROP');

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Object_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Object;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove the
                        user attribute from the OSS data model.  The child
                        tables that have reference to the user attribute
                        being removed will also be removed.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_User_Attr (p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                            p_user_attrib_id    IN igs_sc_usr_attribs.user_attrib_id%TYPE,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_User_Attr';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_grant_id           igs_sc_grant_conds.grant_id%TYPE;
   l_grant_cond_num     igs_sc_grant_conds.grant_cond_num%TYPE;
   l_user_id            igs_sc_usr_att_vals.user_id%TYPE;
   l_grant_name         igs_sc_grants.grant_name%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_grant_conds IS
      SELECT grts.grant_id,
             grts.grant_cond_num,
             gnt.grant_name
        FROM igs_sc_grant_conds    grts,
             igs_sc_grants         gnt
       WHERE grts.user_attrib_id = p_user_attrib_id
         AND gnt.grant_id        = grts.grant_id;

   CURSOR c_get_user_id IS
      SELECT uval.user_id
        FROM igs_sc_usr_att_vals     uval
       WHERE uval.user_attrib_id = p_user_attrib_id;

BEGIN

   SAVEPOINT Delete_User_Attr_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Delete all the grant conditions that may have the object
-- attribute associated to it.
-- -----------------------------------------------------------------
   OPEN c_get_grant_conds;
   FETCH c_get_grant_conds
    INTO l_grant_id,
         l_grant_cond_num,
         l_grant_name;

   IF (c_get_grant_conds%FOUND) THEN
      CLOSE c_get_grant_conds; --mmkumar
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_PRSNT');
      FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (c_get_grant_conds%ISOPEN) THEN
      CLOSE c_get_grant_conds;
   END IF;

-- -----------------------------------------------------------------
-- Delete all the grant conditions that may have the user
-- attribute associated to it.
-- -----------------------------------------------------------------
   Delete_User_Attr_Val (p_api_version       => l_api_version,
                         p_user_attrib_id    => p_user_attrib_id,
                         p_user_id           => NULL,
                         x_return_status     => l_return_status,
                         x_return_message    => l_return_message
                        );

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (c_get_user_id%ISOPEN) THEN
      CLOSE c_get_user_id;
   END IF;

-- -----------------------------------------------------------------
-- Delete the user attributes associated to the attribute id given
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_usr_attribs     attr
    WHERE attr.user_attrib_id = p_user_attrib_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_conds%ISOPEN) THEN
         CLOSE c_get_grant_conds;
      END IF;
      IF (c_get_user_id%ISOPEN) THEN
         CLOSE c_get_user_id;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_User_Attr_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_grant_conds%ISOPEN) THEN
         CLOSE c_get_grant_conds;
      END IF;
      IF (c_get_user_id%ISOPEN) THEN
         CLOSE c_get_user_id;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_User_Attr_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_conds%ISOPEN) THEN
         CLOSE c_get_grant_conds;
      END IF;
      IF (c_get_user_id%ISOPEN) THEN
         CLOSE c_get_user_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_User_Attr_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_User_Attr;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove
                        the user attribute values from the OSS data
                        model.  There are no child tables to be updated
                        due to the removal of the value.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_User_Attr_Val (p_api_version       IN NUMBER,
                                p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                p_user_attrib_id    IN  igs_sc_usr_attribs.user_attrib_id%TYPE,
                                p_user_id           IN NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_User_Attr_Val';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

BEGIN

   SAVEPOINT Delete_User_Attr_Val_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Delete the user attribute values based on the attribute ID and
-- User ID provided.
-- -----------------------------------------------------------------
   DELETE
     FROM igs_sc_usr_att_vals    atvl
    WHERE ( atvl.user_id        = p_user_id OR p_user_id IS NULL )
      AND atvl.user_attrib_id = p_user_attrib_id;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_User_Attr_Val_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_User_Attr_Val_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_User_Attr_Val_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_User_Attr_Val;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove the
                        grant from the OSS data model.  All child tables
                        that have reference to the grant being removed
                        will also be removed.  It must be noted that the
                        only way to remove a grant is to unlock it first.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Grant';
   l_delete_oper        CONSTANT VARCHAR2(30) := 'DELETE';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_grant_cond_num     igs_sc_grant_conds.grant_cond_num%TYPE;
   l_grant_name         igs_sc_grants.grant_name%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_grant_cond IS
      SELECT grts.grant_cond_num
        FROM igs_sc_grant_conds    grts
       WHERE grts.grant_id = p_grant_id;

   CURSOR c_get_grant_name IS
      SELECT grts.grant_name
        FROM igs_sc_grants         grts
       WHERE grts.grant_id = p_grant_id;

BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant';
       l_debug_str := 'Grant ID: '||p_grant_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Delete_Grant_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Determine if the grant is locked or not.
-- -----------------------------------------------------------------
   IF (Is_Grant_Locked(p_grant_id) = 'N') THEN

-- -----------------------------------------------------------------
-- Delete all the grant conditions for the Grant.
-- -----------------------------------------------------------------
      OPEN c_get_grant_cond;
      FETCH c_get_grant_cond
       INTO l_grant_cond_num;

      WHILE (c_get_grant_cond%FOUND) LOOP

         Delete_Grant_Cond (p_api_version       => l_api_version,
                            p_grant_id          => p_grant_id,
                            p_grant_cond_num    => l_grant_cond_num,
                            x_return_status     => l_return_status,
                            x_return_message    => l_return_message
                           );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         FETCH c_get_grant_cond
          INTO l_grant_cond_num;

      END LOOP;

      IF (c_get_grant_cond%ISOPEN) THEN
         CLOSE c_get_grant_cond;
      END IF;

-- -----------------------------------------------------------------
-- Delete the grant that has been requested for deletion.
-- -----------------------------------------------------------------
      DELETE
        FROM igs_sc_grants   grts
       WHERE grts.grant_id  = p_grant_id;

   ELSE

      OPEN c_get_grant_name;
      FETCH c_get_grant_name
       INTO l_grant_name;

      CLOSE c_get_grant_name; --mmkumar

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
      FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_delete_oper);
      FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      IF (c_get_grant_cond%ISOPEN) THEN
         CLOSE c_get_grant_cond;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant.Ex_error';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      IF (c_get_grant_cond%ISOPEN) THEN
         CLOSE c_get_grant_cond;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant.Ex_un';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      IF (c_get_grant_cond%ISOPEN) THEN
         CLOSE c_get_grant_cond;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant.Ex_others';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||','||' Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Grant;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to remove the
                        grant condition from the OSS data model.  There
                        are no child tables that need to be cleaned up
                        on this removal.  It must be noted that the only
                        way to remove the grant condition is if the grant
                        is unlocked.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Grant_Cond (p_api_version       IN NUMBER,
                             p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_grant_id          IN igs_sc_grant_conds.grant_id%TYPE,
                             p_grant_cond_num    IN igs_sc_grant_conds.grant_cond_num%TYPE,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Grant_Cond';
   l_delete_oper        CONSTANT VARCHAR2(30) := 'DELETE';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_grant_name         igs_sc_grants.grant_name%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_grant_name IS
      SELECT grts.grant_name
        FROM igs_sc_grants         grts
       WHERE grts.grant_id = p_grant_id;

BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant_Cond';
       l_debug_str := 'Grant ID: '||p_grant_id||','||'Grant Cond Number: '||p_grant_cond_num;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Delete_Grant_Cond_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check to make sure that the grant is unlocked.
-- -----------------------------------------------------------------
   IF (Is_Grant_Locked(p_grant_id) = 'N') THEN

-- -----------------------------------------------------------------
-- Delete the grant condition that is being requested.
-- -----------------------------------------------------------------
      DELETE
        FROM igs_sc_grant_conds     conds
       WHERE conds.grant_id         = p_grant_id
         AND conds.grant_cond_num   = p_grant_cond_num;

   ELSE

      OPEN c_get_grant_name;
      FETCH c_get_grant_name
       INTO l_grant_name;

      CLOSE c_get_grant_name; --mmkumar

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_GRANT_LOCKED_NO_OPS');
      FND_MESSAGE.SET_TOKEN('OPS_TYPE', l_delete_oper);
      FND_MESSAGE.SET_TOKEN('GRANT_NAME', l_grant_name);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant_Cond.Ex_un';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||','||'Grant Cond Number: '||p_grant_cond_num||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;


   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant_Cond.Ex_error';
         l_debug_str := 'Handled Exception: Grant ID: '||p_grant_id||','||'Grant Cond Number: '||p_grant_cond_num||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_get_grant_name%ISOPEN) THEN
         CLOSE c_get_grant_name;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Grant_Cond_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Delete_Grant_Cond.Ex_others';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||','||'Grant Cond Number: '||p_grant_cond_num||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Grant_Cond;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Local_Role (p_api_version       IN NUMBER,
                             p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Local_Role';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

BEGIN

   SAVEPOINT Delete_Local_Role_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Local_Role_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Local_Role_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Local_Role_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Local_Role;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            :
   remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Delete_Local_User_Role (p_api_version       IN NUMBER,
                                  p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                                  x_return_status     OUT NOCOPY VARCHAR2,
                                  x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Local_User_Role';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

BEGIN

   SAVEPOINT Delete_Local_User_Role_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Local_User_Role_SP;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Local_User_Role_SP;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Delete_Local_User_Role_SP;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Delete_Local_User_Role;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to determine
                        if the grant is locked or not.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Is_Grant_Locked (
   p_grant_id IN igs_sc_grants.grant_id%TYPE
) RETURN VARCHAR2 AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Is_Grant_Locked';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_lock_flag          igs_sc_grants.locked_flag%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_get_lock_flag IS
      SELECT grnt.locked_flag
        FROM igs_sc_grants    grnt
       WHERE grnt.grant_id  = p_grant_id;

BEGIN

-- -----------------------------------------------------------------
-- Check to determine if the grant is locked or not.
-- -----------------------------------------------------------------
   OPEN c_get_lock_flag;
   FETCH c_get_lock_flag
    INTO l_lock_flag;

   IF (l_lock_flag = 'Y') THEN
      CLOSE c_get_lock_flag;
      RETURN ('Y');
   ELSE
      CLOSE c_get_lock_flag;
      RETURN ('N');
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION

   WHEN OTHERS THEN
      IF (c_get_lock_flag%ISOPEN) THEN
         CLOSE c_get_lock_flag;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
      IF g_upgrade_mode = 'Y' THEN
        RAISE;
      END IF;

END Is_Grant_Locked;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to lock the
                        grant so that it can not be deleted and start
                        the use of the grant into the system.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Lock_Grant (p_api_version       IN NUMBER,
                      p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Lock_Grant';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_grant_id           igs_sc_grants.grant_id%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_grant IS
      SELECT grts.grant_id
        FROM igs_sc_grants    grts
       WHERE grts.grant_id = p_grant_id;

BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Lock_Grant';
       l_debug_str := 'Grant ID: '||p_grant_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Lock_Grant_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check to ensure that the grant is in existence.
-- -----------------------------------------------------------------
   OPEN c_check_grant;
   FETCH c_check_grant
    INTO l_grant_id;

   IF (c_check_grant%NOTFOUND) THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_NO_GRANT_AVAIL');
      FND_MESSAGE.SET_TOKEN('GRANT_NAME', p_grant_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   ELSE

      -- Generate grant for objects
      IGS_SC_GRANTS_PVT.construct_grant(
         p_api_version  => 1.0,
         p_init_msg_list     =>  FND_API.G_FALSE,
         p_commit            =>  FND_API.G_FALSE,
         p_validation_level  =>  FND_API.G_VALID_LEVEL_NONE,
         p_grant_id          => p_grant_id,
         x_return_status    => l_return_status ,
         x_msg_count        => l_message_count,
         x_msg_data         => l_return_message );

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
       END IF;

      UPDATE igs_sc_grants    grts
         SET grts.locked_flag = 'Y'
       WHERE grts.grant_id    = p_grant_id;

   END IF;

   IF (c_check_grant%ISOPEN) THEN
      CLOSE c_check_grant;
   END IF;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_check_grant%ISOPEN) THEN
         CLOSE c_check_grant;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Lock_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Lock_Grant';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_check_grant%ISOPEN) THEN
         CLOSE c_check_grant;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Lock_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Lock_Grant';
         l_debug_str := 'Handled Exception: Grant ID: '||p_grant_id||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_check_grant%ISOPEN) THEN
         CLOSE c_check_grant;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Lock_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Lock_Grant';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

END Lock_Grant;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to unlock the
                        grant so that it can be deleted.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Unlock_Grant (p_api_version       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_grant_id          IN igs_sc_grants.grant_id%TYPE,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_return_message    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Unlock_Grant';
   l_api_version        CONSTANT NUMBER       := 1.0;
   l_grant_id           igs_sc_grants.grant_id%TYPE;
   l_return_message     VARCHAR2(2000);
   l_message_count      NUMBER(15);
   l_return_status      VARCHAR2(30);
   l_locked_flag_value  VARCHAR2(1) := 'N';

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_grant IS
      SELECT grts.grant_id
        FROM igs_sc_grants    grts
       WHERE grts.grant_id = p_grant_id;

BEGIN

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Unlock_Grant';
       l_debug_str := 'Grant ID: '||p_grant_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;

   SAVEPOINT Unlock_Grant_SP;

-- -----------------------------------------------------------------
-- Check for the Compatible API call
-- -----------------------------------------------------------------
   IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- -----------------------------------------------------------------
-- If the calling program has passed the parameter for initializing
-- the message list
-- -----------------------------------------------------------------
   IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
   END IF;

-- -----------------------------------------------------------------
-- Set the return status to success
-- -----------------------------------------------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------
-- Check to ensure that the grant is in existence.
-- -----------------------------------------------------------------
   OPEN c_check_grant;
   FETCH c_check_grant
    INTO l_grant_id;

   IF (c_check_grant%NOTFOUND) THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_NO_GRANT_AVAIL');
      FND_MESSAGE.SET_TOKEN('GRANT_NAME', p_grant_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   ELSE

      DELETE
        FROM igs_sc_obj_grants    objs
       WHERE objs.grant_id = p_grant_id;

      UPDATE igs_sc_grants    grts
         SET grts.locked_flag = l_locked_flag_value
       WHERE grts.grant_id    = p_grant_id;

   END IF;

   IF (c_check_grant%ISOPEN) THEN
      CLOSE c_check_grant;
   END IF;

-- -----------------------------------------------------------------
-- Commit the transaction if requested to via parameter value.
-- -----------------------------------------------------------------
   IF (FND_API.to_Boolean(p_commit)) THEN
      COMMIT;
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (c_check_grant%ISOPEN) THEN
         CLOSE c_check_grant;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Unlock_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Unlock_Grant';
         l_debug_str := 'Unhandled Exception: Grant ID: '||p_grant_id||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (c_check_grant%ISOPEN) THEN
         CLOSE c_check_grant;
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Unlock_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Unlock_Grant';
         l_debug_str := 'Handled Exception: Grant ID: '||p_grant_id||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

   WHEN OTHERS THEN
      IF (c_check_grant%ISOPEN) THEN
         CLOSE c_check_grant;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                 p_count => l_message_count,
                                 p_data  => x_return_message);
      ROLLBACK TO Unlock_Grant_SP;

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
         l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Unlock_Grant';
         l_debug_str := 'Other Exception: Grant ID: '||p_grant_id||'Error Message: '||x_return_message;
         fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
      END IF;

END Unlock_Grant;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this procedure is to ensure that
                        the values that are being inserted or updated
                        are either Y or N.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
PROCEDURE Get_Valid_Grant_Vals (p_grant_select_flag    IN VARCHAR2,
                                p_grant_insert_flag    IN VARCHAR2,
                                p_grant_delete_flag    IN VARCHAR2,
                                p_grant_update_flag    IN VARCHAR2,
                                x_grant_select_flag    OUT NOCOPY VARCHAR2,
                                x_grant_insert_flag    OUT NOCOPY VARCHAR2,
                                x_grant_delete_flag    OUT NOCOPY VARCHAR2,
                                x_grant_update_flag    OUT NOCOPY VARCHAR2
) IS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Get_Valid_Grant_Vals';

BEGIN

-- -----------------------------------------------------------------
-- Ensure that the values provided are valid for the grants.
-- -----------------------------------------------------------------
   IF ((UPPER(p_grant_select_flag) = 'Y') OR (UPPER(p_grant_select_flag) = 'N')) THEN
      x_grant_select_flag := UPPER(p_grant_select_flag);
   ELSE
      x_grant_select_flag := 'N';
   END IF;
   IF ((UPPER(p_grant_update_flag) = 'Y') OR (UPPER(p_grant_select_flag) = 'N')) THEN
      x_grant_update_flag := UPPER(p_grant_update_flag);
   ELSE
      x_grant_update_flag := 'N';
   END IF;
   IF ((UPPER(p_grant_delete_flag) = 'Y') OR (UPPER(p_grant_delete_flag) = 'N')) THEN
      x_grant_delete_flag := UPPER(p_grant_delete_flag);
   ELSE
      x_grant_delete_flag := 'N';
   END IF;
   IF ((UPPER(p_grant_insert_flag) = 'Y') OR (UPPER(p_grant_insert_flag) = 'N')) THEN
      x_grant_insert_flag := UPPER(p_grant_insert_flag);
   ELSE
      x_grant_insert_flag := 'N';
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Get_Valid_Grant_Vals;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to check to
                        make sure that the function being requested
                        for insert or update is available in the system.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_Function_ID (
   p_function_id        IN NUMBER
) RETURN NUMBER AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Function_ID';
   l_function_id        igs_sc_obj_functns.function_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_func_id IS
      SELECT fnc.function_id
        FROM igs_sc_obj_functns   fnc
       WHERE fnc.function_id  = p_function_id;

BEGIN

-- -----------------------------------------------------------------
-- Open the cursor to determine if the ID is valid and found.
-- -----------------------------------------------------------------
   OPEN c_check_func_id;
   FETCH c_check_func_id
    INTO l_function_id;

   IF (c_check_func_id%FOUND) THEN
      CLOSE c_check_func_id;
      RETURN (l_function_id);
   ELSE
      CLOSE c_check_func_id;
      RETURN (0);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (c_check_func_id%ISOPEN) THEN
         CLOSE c_check_func_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_Function_ID;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the object group ID is present in the system
                        before insert or update of records.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_Obj_Grp_ID (
   p_group_id        IN NUMBER
) RETURN NUMBER AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Obj_Grp_ID';
   l_group_id           igs_sc_obj_groups.obj_group_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_obj_group IS
      SELECT grps.obj_group_id
        FROM igs_sc_obj_groups   grps
       WHERE grps.obj_group_id  = p_group_id;

BEGIN

-- -----------------------------------------------------------------
-- Open the cursor to determine if the ID is valid and found.
-- -----------------------------------------------------------------
   OPEN c_check_obj_group;
   FETCH c_check_obj_group
    INTO l_group_id;

   IF (c_check_obj_group%FOUND) THEN
      CLOSE c_check_obj_group;
      RETURN (l_group_id);
   ELSE
      CLOSE c_check_obj_group;
      RETURN (0);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (c_check_obj_group%ISOPEN) THEN
         CLOSE c_check_obj_group;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_Obj_Grp_ID;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the object attribute being inserted or updated
                        is already present in the system.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_Obj_Attr_ID (
   p_obj_attr_id             IN NUMBER
) RETURN NUMBER AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Obj_Attr_ID';
   l_obj_attr_id        igs_sc_obj_attribs.obj_attrib_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_obj_attrib IS
      SELECT attr.obj_attrib_id
        FROM igs_sc_obj_attribs   attr
       WHERE attr.obj_attrib_id  = p_obj_attr_id;

BEGIN

-- -----------------------------------------------------------------
-- Open the cursor to determine if the ID is valid and found.
-- -----------------------------------------------------------------
   OPEN c_check_obj_attrib;
   FETCH c_check_obj_attrib
    INTO l_obj_attr_id;

   IF (c_check_obj_attrib%FOUND) THEN
      CLOSE c_check_obj_attrib;
      RETURN (l_obj_attr_id);
   ELSE
      CLOSE c_check_obj_attrib;
      RETURN (0);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (c_check_obj_attrib%ISOPEN) THEN
         CLOSE c_check_obj_attrib;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_Obj_Attr_ID;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the user group ID is defined in the system prior
                        to insert or updated.  The user group ID is
                        associated to the wf_local_roles record being present.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_User_Grp_ID (
   p_user_group_id      IN NUMBER
) RETURN NUMBER AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_User_Grp_ID';
   l_user_group_id      wf_local_roles.orig_system_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_user_group_id IS
      SELECT wflr.orig_system_id
        FROM wf_local_roles    wflr
       WHERE wflr.ORIG_SYSTEM = 'IGS'
             AND wflr.orig_system_id  = p_user_group_id;

BEGIN

-- -----------------------------------------------------------------
-- Open the cursor to determine if the ID is valid and found.
-- -----------------------------------------------------------------
   OPEN c_check_user_group_id;
   FETCH c_check_user_group_id
    INTO l_user_group_id;

   IF (c_check_user_group_id%FOUND) THEN
      CLOSE c_check_user_group_id;
      RETURN (l_user_group_id);
   ELSE
      CLOSE c_check_user_group_id;
      RETURN (0);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (c_check_user_group_id%ISOPEN) THEN
         CLOSE c_check_user_group_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_User_Grp_ID;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the grant ID that is to be inserted or updated
                        is present in the system.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_Grant_ID (
   p_grant_id      IN NUMBER
) RETURN NUMBER AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Grant_ID';
   l_grant_id           igs_sc_grants.grant_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_grant_id IS
      SELECT grt.grant_id
        FROM igs_sc_grants     grt
       WHERE grt.grant_id  = p_grant_id;

BEGIN

-- -----------------------------------------------------------------
-- Open the cursor to determine if the ID is valid and found.
-- -----------------------------------------------------------------
   OPEN c_check_grant_id;
   FETCH c_check_grant_id
    INTO l_grant_id;

   IF (c_check_grant_id%FOUND) THEN
      CLOSE c_check_grant_id;
      RETURN (l_grant_id);
   ELSE
      CLOSE c_check_grant_id;
      RETURN (0);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (c_check_grant_id%ISOPEN) THEN
         CLOSE c_check_grant_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_Grant_ID;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the object that is being inserted or updated
                        is present in the system.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_Object_ID (
   p_object_id      IN NUMBER
) RETURN NUMBER AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Object_ID';
   l_object_id          fnd_objects.object_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_object_id IS
      SELECT objs.object_id
        FROM fnd_objects     objs
       WHERE objs.object_id  = p_object_id;

BEGIN

-- -----------------------------------------------------------------
-- Open the cursor to determine if the ID is valid and found.
-- -----------------------------------------------------------------
   OPEN c_check_object_id;
   FETCH c_check_object_id
    INTO l_object_id;

   IF (c_check_object_id%FOUND) THEN
      CLOSE c_check_object_id;
      RETURN (l_object_id);
   ELSE
      CLOSE c_check_object_id;
      RETURN (0);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (c_check_object_id%ISOPEN) THEN
         CLOSE c_check_object_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_Object_ID;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the user attribute being inserted or updated is
                        present in the system.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_User_Attr_ID (
   p_user_attr_id      IN NUMBER
) RETURN NUMBER AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_User_Attr_ID';
   l_user_attr_id       igs_sc_usr_attribs.user_attrib_id%TYPE;

-- -----------------------------------------------------------------
-- Define the cursors to be used in procedure.
-- -----------------------------------------------------------------
   CURSOR c_check_user_attr_id IS
      SELECT attr.user_attrib_id
        FROM igs_sc_usr_attribs    attr
       WHERE attr.user_attrib_id  = p_user_attr_id;

BEGIN

-- -----------------------------------------------------------------
-- Open the cursor to determine if the ID is valid and found.
-- -----------------------------------------------------------------
   OPEN c_check_user_attr_id;
   FETCH c_check_user_attr_id
    INTO l_user_attr_id;

   IF (c_check_user_attr_id%FOUND) THEN
      CLOSE c_check_user_attr_id;
      RETURN (l_user_attr_id);
   ELSE
      CLOSE c_check_user_attr_id;
      RETURN (0);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (c_check_user_attr_id%ISOPEN) THEN
         CLOSE c_check_user_attr_id;
      END IF;
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_User_Attr_ID;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the value being inserted or updated for the static
                        type falls into the values that are expected.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/


FUNCTION Validate_Static_Type (
   p_static_type      IN VARCHAR2
) RETURN VARCHAR2 AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Static_Type';

BEGIN

-- -----------------------------------------------------------------
-- Check for the valid values on the Static types.
-- -----------------------------------------------------------------
   IF (p_static_type IN ('C','S','D')) THEN
      RETURN (p_static_type);
   ELSE
      RETURN (NULL);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_Static_Type;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the object attribute type is valid for the value
                        expected to be there.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_Obj_Attr_Type (
   p_obj_att_type      IN VARCHAR2
) RETURN VARCHAR2 AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Obj_Attr_Type';

BEGIN

-- -----------------------------------------------------------------
-- Check for the valid values on the Object attribute types.
-- -----------------------------------------------------------------
   IF (p_obj_att_type IN ('S','T','F','M')) THEN
      RETURN (p_obj_att_type);
   ELSE
      RETURN (NULL);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_Obj_Attr_Type;


/******************************************************************
   Created By         : Don Shellito
   Date Created By    : April 23, 2003
   Purpose            : The purpose of this function is to ensure that
                        the value for the user attribute type is valid
                        and can be used in the system.
   Remarks            :

   Change History
   Who                  When            What
------------------------------------------------------------------------
   Don Shellito         April 23, 2003  New Procedure Created.

******************************************************************/
FUNCTION Validate_User_Attr_Type (
   p_usr_att_type      IN VARCHAR2
) RETURN VARCHAR2 AS

-- -----------------------------------------------------------------
-- Define local variables to be used.
-- -----------------------------------------------------------------
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_User_Attr_Type';

BEGIN

-- -----------------------------------------------------------------
-- Check for the valid values on the user attribute types.
-- -----------------------------------------------------------------
   IF (p_usr_att_type IN ('S', 'F', 'M','U')) THEN
      RETURN (p_usr_att_type);
   ELSE
      RETURN (NULL);
   END IF;

-- -----------------------------------------------------------------
-- Exception Block definition
-- -----------------------------------------------------------------
EXCEPTION
   WHEN OTHERS THEN
      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_pkg_name, l_api_name);
      END IF;
      RAISE FND_API.G_EXC_ERROR;

END Validate_User_Attr_Type;

PROCEDURE Generate_Message
IS

   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);

BEGIN

   FND_MSg_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN

      l_msg_data := '';

      FOR l_cur IN 1..l_msg_count LOOP

         l_msg_data := FND_MSg_PUB.GET(l_cur, FND_API.g_FALSE);
         fnd_file.put_line (FND_FILE.LOG,l_msg_data);
      END LOOP;

   ELSE

         l_msg_data  := 'Error Returned but Error stack has no data';
         fnd_file.put_line (FND_FILE.LOG,l_msg_data);

   END IF;

END Generate_Message;

/******************************************************************/
PROCEDURE Unlock_All_Grants(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_obj_group_id     IN  igs_sc_obj_groups.obj_group_id%TYPE
) IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Unlock_All_Grants';
   l_msg_data       VARCHAR2(2000);
   l_msg_count      NUMBER(15);
   l_return_status  VARCHAR2(30);

BEGIN
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Unlock_All_Grants';
       l_debug_str := 'Object Group ID: '||p_obj_group_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;
   -- Just call the procedure
   SAVEPOINT Unlock_All_Grants;

   IGS_SC_GRANTS_PVT.unlock_all_grants(
     p_api_version       => 1.0 ,
     x_return_status     => l_return_status,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data,
     p_obj_group_id      => p_obj_group_id
   );

   -- Checking the status

   IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
      --Successfull completion
      retcode := 0;
   ELSE
      -- Error: generating message and returning the error code
      Generate_Message;
      retcode := 2;
   END IF;



EXCEPTION

   WHEN OTHERS THEN

      ROLLBACK TO Unlock_All_Grants;

      retcode := 2;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END Unlock_All_Grants;

PROCEDURE Lock_All_Grants(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_obj_group_id     IN  igs_sc_obj_groups.obj_group_id%TYPE
) IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Lock_All_Grants';
   l_msg_data       VARCHAR2(2000);
   l_msg_count      NUMBER(15);
   l_return_status  VARCHAR2(30);

BEGIN

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       l_label := 'igs.plsql.igs_sc_data_sec_apis_pkg.Lock_All_Grants';
       l_debug_str := 'Object Group ID: '||p_obj_group_id;
       fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
    END IF;

   -- Just call the procedure
   SAVEPOINT Lock_All_Grants;

   IGS_SC_GRANTS_PVT.lock_all_grants(
     p_api_version       => 1.0 ,
     x_return_status     => l_return_status,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data,
     p_obj_group_id      => p_obj_group_id
   );

   -- Checking the status

   IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
      --Successfull completion
      retcode := 0;
   ELSE
      -- Error: generating message and returning the error code
      Generate_Message;
      retcode := 2;
   END IF;



EXCEPTION

   WHEN OTHERS THEN

      ROLLBACK TO Lock_All_Grants;

      retcode := 2;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END Lock_All_Grants;

PROCEDURE Populate_User_Attribs(
   errbuf             OUT NOCOPY VARCHAR2,  -- Request standard error string
   retcode            OUT NOCOPY NUMBER  ,  -- Request standard return status
   p_all_attribs      IN  VARCHAR2
) IS

   l_api_name    CONSTANT VARCHAR2(30)   := 'Lock_All_Grants';
   l_msg_data       VARCHAR2(2000);
   l_msg_count      NUMBER(15);
   l_return_status  VARCHAR2(30);

BEGIN

   -- Just call the procedure
   SAVEPOINT Unlock_All_Grants;

   IGS_SC_GRANTS_PVT.populate_user_attrib(
     p_api_version       => 1.0 ,
     x_return_status     => l_return_status,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data,
     p_all_attribs       => p_all_attribs

   );

   -- Checking the status

   IF (l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
      --Successfull completion
      retcode := 0;
   ELSE
      -- Error: generating message and returning the error code
      Generate_Message;
      retcode := 2;
   END IF;



EXCEPTION

   WHEN OTHERS THEN

      ROLLBACK TO Lock_All_Grants;

      retcode := 2;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, l_api_name);
      END IF;

      Generate_Message;

END Populate_User_Attribs;


PROCEDURE enable_policy (
  p_database_object_name IN VARCHAR2 )
IS
BEGIN
  modify_policy (p_database_object_name);
END enable_policy;


PROCEDURE modify_policy (
  p_database_object_name IN VARCHAR2,
  p_action VARCHAR2 DEFAULT 'CREATE')
IS

--PRAGMA AUTONOMOUS_TRANSACTION;

 p_var     VARCHAR2(32000);
 l_policy  NUMBER(1);
 l_status      VARCHAR2(255);
 l_industry      VARCHAR2(255);
 l_owner      VARCHAR2(255);
 l_aol_schema  VARCHAR2(255);
 l_apps_schema  VARCHAR2(255);
 l_apps_mls_schema VARCHAR2(255);
 L_SELECT_FLAG VARCHAR2(1) := NULL;
 L_UPDATE_FLAG VARCHAR2(1) := NULL;
 L_DELETE_FLAG VARCHAR2(1):= NULL;
 L_INSERT_FLAG VARCHAR2(1):= NULL;
 L_PAR_SECURITY VARCHAR2(1):= NULL;

 CURSOR c_policy IS
  SELECT POLICY_NAME,
         OBJECT_OWNER
    FROM DBA_POLICIES
   WHERE object_name = p_database_object_name
   AND object_owner = l_owner;

 CURSOR C_DEFAULT_SECURITY IS
 SELECT DECODE(SELECT_FLAG, 'Y','S',NULL) SELECT_FLAG,
	DECODE(UPDATE_FLAG, 'Y','U',NULL) UPDATE_FLAG,
	DECODE(DELETE_FLAG, 'Y','D',NULL) DELETE_FLAG,
	DECODE(INSERT_FLAG, 'Y','I',NULL) INSERT_FLAG,
	DECODE(ENFORCE_PAR_SEC_FLAG,'Y','Y',NULL) ENFORCE_PAR_SEC_FLAG
 FROM IGS_SC_OBJECTS SC,
      FND_OBJECTS FND
 WHERE FND.OBJ_NAME = p_database_object_name
 AND SC.OBJECT_ID = FND.OBJECT_ID
 AND SC.ACTIVE_FLAG = 'Y';


CURSOR get_db_version IS
SELECT SUBSTR(version,1,INSTR(version,'.')-1)
FROM v$instance;

l_stmt VARCHAR2(10000);
l_db_version NUMBER;
l_app_info boolean ;

BEGIN
/* ORA-28115 - policy with check option violation  */

  l_app_info := fnd_installation.get_app_info(
           'FND', l_status, l_industry, l_aol_schema);
  IF NOT l_app_info THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  system.ad_apps_private.get_apps_schema_name(
          1, l_aol_schema, l_apps_schema, l_apps_mls_schema);

  -- Get application
  IF  (SUBSTR(p_database_object_name,1,3) = 'IGS') THEN
      IF (SUBSTR(p_database_object_name,LENGTH(p_database_object_name)-2,3) IN ('_SV', '_V')) THEN
          l_owner := l_apps_schema;
      ELSE
          l_app_info := FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'IGS',
              status	=> l_status,
              industry => l_industry,
              oracle_schema	=>  l_owner);
      END IF;
  ELSIF (SUBSTR(p_database_object_name,1,3) = 'IGF') THEN
      l_app_info := FND_INSTALLATION.GET_APP_INFO(
              application_short_name => 'IGF',
              status	=> l_status,
              industry => l_industry,
              oracle_schema	=>  l_owner);
  END IF;



  FOR c_policy_rec IN c_policy LOOP
   -- Drop existing policies

     dbms_rls.drop_policy (object_schema   => c_policy_rec.object_owner,
                           object_name     => p_database_object_name,
                           policy_name     => c_policy_rec.policy_name );


  END LOOP;

  IF p_action = 'DROP'   THEN
    --Don't create new policies
    RETURN;
  END IF;

  OPEN C_DEFAULT_SECURITY;
  FETCH C_DEFAULT_SECURITY INTO L_SELECT_FLAG,L_UPDATE_FLAG,L_DELETE_FLAG,L_INSERT_FLAG,L_PAR_SECURITY;
  CLOSE C_DEFAULT_SECURITY;

  OPEN get_db_version;
  FETCH get_db_version INTO l_db_version;
  CLOSE get_db_version;

  IF L_INSERT_FLAG IS NOT NULL THEN

      IF  L_PAR_SECURITY IS NOT NULL THEN
          IF (l_db_version >= 10) THEN
		  l_stmt:= 'BEGIN dbms_rls.add_policy (
				object_schema   => :1,
				object_name     => :2,
				policy_name     => :3,
				function_schema => :4,
				policy_function => :5,
				statement_types => :6,
				update_check    => TRUE,
				long_predicate  => TRUE); END;';
		  EXECUTE IMMEDIATE(l_stmt) using l_owner, p_database_object_name, p_database_object_name||'_PI',
				l_apps_schema,'IGS_SC_GRANTS_TBL_PVT.UPDATE_ROW','insert';
	  ELSE
	          dbms_rls.add_policy (
			       object_schema   => l_owner,
			       object_name     => p_database_object_name,
			       policy_name     => p_database_object_name||'_PI',
			       function_schema => l_apps_schema,
			       policy_function => 'IGS_SC_GRANTS_TBL_PVT.UPDATE_ROW',
			       statement_types => 'insert',
			       update_check    => TRUE );
	  END IF;
      ELSE
          IF (l_db_version >= 10) THEN
		  l_stmt:= 'BEGIN dbms_rls.add_policy (
				object_schema   => :1,
				object_name     => :2,
				policy_name     => :3,
				function_schema => :4,
				policy_function => :5,
				statement_types => :6,
				update_check    => TRUE,
				long_predicate  => TRUE); END;';
		  EXECUTE IMMEDIATE(l_stmt) using l_owner, p_database_object_name, p_database_object_name||'_PI',
				l_apps_schema,'IGS_SC_GRANTS_TBL_PVT.INSERT_ROW','insert';
	  ELSE
		  dbms_rls.add_policy (object_schema   => l_owner,
			       object_name     => p_database_object_name,
			       policy_name     => p_database_object_name||'_PI',
			       function_schema => l_apps_schema,
			       policy_function => 'IGS_SC_GRANTS_TBL_PVT.INSERT_ROW',
			       statement_types => 'insert',
			       update_check    => TRUE );
	  END IF;
      END IF;
  END IF;
  IF L_UPDATE_FLAG IS NOT NULL THEN
           IF (l_db_version >= 10) THEN
		  l_stmt:= 'BEGIN dbms_rls.add_policy (
				object_schema   => :1,
				object_name     => :2,
				policy_name     => :3,
				function_schema => :4,
				policy_function => :5,
				statement_types => :6,
				update_check    => TRUE,
				long_predicate  => TRUE); END;';
		  EXECUTE IMMEDIATE(l_stmt) using l_owner, p_database_object_name, p_database_object_name||'_PU',
				l_apps_schema,'IGS_SC_GRANTS_TBL_PVT.UPDATE_ROW','update';
	   ELSE
		  dbms_rls.add_policy (object_schema   => l_owner,
			       object_name     => p_database_object_name,
			       policy_name     => p_database_object_name||'_PU',
			       function_schema => l_apps_schema,
			       policy_function => 'IGS_SC_GRANTS_TBL_PVT.UPDATE_ROW',
			       statement_types => 'update',
			       update_check    => TRUE );
	   END IF;
  END IF;
  IF L_SELECT_FLAG IS NOT NULL THEN
           IF (l_db_version >= 10) THEN
		  l_stmt:= 'BEGIN dbms_rls.add_policy (
				object_schema   => :1,
				object_name     => :2,
				policy_name     => :3,
				function_schema => :4,
				policy_function => :5,
				statement_types => :6,
				update_check    => TRUE,
				long_predicate  => TRUE); END;';
		  EXECUTE IMMEDIATE(l_stmt) using l_owner, p_database_object_name, p_database_object_name||'_PS',
				l_apps_schema,'IGS_SC_GRANTS_TBL_PVT.SELECT_ROW','select';
	   ELSE
		  dbms_rls.add_policy (object_schema   => l_owner,
			       object_name     => p_database_object_name,
			       policy_name     => p_database_object_name||'_PS',
			       function_schema => l_apps_schema,
			       policy_function => 'IGS_SC_GRANTS_TBL_PVT.SELECT_ROW',
			       statement_types => 'select',
			       update_check    => TRUE );
           END IF;
  END IF;
  IF L_DELETE_FLAG IS NOT NULL THEN
      IF  L_PAR_SECURITY IS NOT NULL THEN
           IF (l_db_version >= 10) THEN
		  l_stmt:= 'BEGIN dbms_rls.add_policy (
				object_schema   => :1,
				object_name     => :2,
				policy_name     => :3,
				function_schema => :4,
				policy_function => :5,
				statement_types => :6,
				update_check    => TRUE,
				long_predicate  => TRUE); END;';
		  EXECUTE IMMEDIATE(l_stmt) using l_owner, p_database_object_name, p_database_object_name||'_PD',
				l_apps_schema,'IGS_SC_GRANTS_TBL_PVT.UPDATE_ROW','delete';
	   ELSE
		  dbms_rls.add_policy (object_schema   => l_owner,
			       object_name     => p_database_object_name,
			       policy_name     => p_database_object_name||'_PD',
			       function_schema => l_apps_schema,
			       policy_function => 'IGS_SC_GRANTS_TBL_PVT.UPDATE_ROW',
			       statement_types => 'delete',
			       update_check    => TRUE );
	  END IF;
      ELSE
           IF (l_db_version >= 10) THEN
		  l_stmt:= 'BEGIN dbms_rls.add_policy (
				object_schema   => :1,
				object_name     => :2,
				policy_name     => :3,
				function_schema => :4,
				policy_function => :5,
				statement_types => :6,
				update_check    => TRUE,
				long_predicate  => TRUE); END;';
		  EXECUTE IMMEDIATE(l_stmt) using l_owner, p_database_object_name, p_database_object_name||'_PD',
				l_apps_schema,'IGS_SC_GRANTS_TBL_PVT.DELETE_ROW','delete';
	   ELSE
		  dbms_rls.add_policy (object_schema   => l_owner,
			       object_name     => p_database_object_name,
			       policy_name     => p_database_object_name||'_PD',
			       function_schema => l_apps_schema,
			       policy_function => 'IGS_SC_GRANTS_TBL_PVT.DELETE_ROW',
			       statement_types => 'delete',
			       update_check    => TRUE );
	   END IF;
      END IF;
  END IF;
 -- COMMIT WORK;
EXCEPTION
   WHEN OTHERS THEN
      IF C_DEFAULT_SECURITY%ISOPEN THEN
         CLOSE C_DEFAULT_SECURITY;
      END IF;
      ROLLBACK;

      IF (FND_MSg_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
         FND_MSg_PUB.Add_Exc_Msg (g_PKg_NAME, 'MODIFY_POLICY');
      END IF;
      RAISE;
--      RAISE FND_API.G_EXC_ERROR;

END modify_policy;

/* This procedure shifts sequences in all tables to remove empty spaces in numbering
    Table list :

IGS_SC_USR_ATTRIBS user_attrib_id

    IGS_SC_USR_ATT_VALS user_id ,user_attrib_id

IGS_SC_OBJ_GROUPS obj_group_id

  IGS_SC_OBJECTS object_id,obj_group_id

  IGS_SC_OBJ_FUNCTNS  function_id,obj_group_id

  IGS_SC_OBJ_ATT_MTHS  object_id,obj_attrib_id

  IGS_SC_OBJ_ATTRIBS obj_group_id ,obj_attrib_id

    IGS_SC_OBJ_ATT_VALS object_id,obj_attrib_id

IGS_SC_OBJ_GRANTS grant_id,object_id

  IGS_SC_GRANTS grant_id,user_group_id,obj_group_id ,function_id

  IGS_SC_GRANT_CONDS  grant_id,obj_attrib_id,user_attrib_id

*/
PROCEDURE change_seq IS

  CURSOR igs_sc_grants_c IS
         SELECT grant_id
           FROM igs_sc_grants
          ORDER BY grant_id
     FOR UPDATE OF grant_id;

  CURSOR igs_sc_usr_attribs_c IS
         SELECT user_attrib_id
           FROM igs_sc_usr_attribs
          ORDER BY user_attrib_id
           FOR UPDATE OF user_attrib_id;

  CURSOR igs_sc_obj_groups_c IS
         SELECT obj_group_id
           FROM igs_sc_obj_groups
          ORDER BY obj_group_id
           FOR UPDATE OF obj_group_id;

  CURSOR igs_sc_obj_functns_c IS
         SELECT function_id
           FROM igs_sc_obj_functns
          ORDER BY function_id
           FOR UPDATE OF function_id;

  CURSOR igs_sc_obj_attribs_c IS
         SELECT obj_attrib_id
           FROM igs_sc_obj_attribs
          ORDER BY obj_attrib_id
           FOR UPDATE OF obj_attrib_id;

 l_current_seq  NUMBER;

BEGIN

-- -----------------------------------------------------------------
-- Check if admin mode is enabled
-- -----------------------------------------------------------------
  IF IGS_SC_GRANTS_PVT.admin_mode <> 'Y' AND g_upgrade_mode <> 'Y' THEN

      FND_MESSAGE.SET_NAME('IGS', 'IGS_SC_ADMIN_MODE_OFF');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

-- UPDATE GRANTS

  l_current_seq := 1;

  FOR igs_sc_grants_rec IN igs_sc_grants_c LOOP

    IF igs_sc_grants_rec.grant_id <> l_current_seq THEN

      -- Update all tables
      UPDATE IGS_SC_OBJ_GRANTS  SET grant_id = l_current_seq WHERE grant_id = igs_sc_grants_rec.grant_id;

      UPDATE IGS_SC_GRANT_CONDS SET grant_id = l_current_seq WHERE grant_id = igs_sc_grants_rec.grant_id;

      -- Update table itself
      UPDATE igs_sc_grants SET grant_id = l_current_seq WHERE CURRENT OF igs_sc_grants_c;

    END IF;

    l_current_seq := l_current_seq +1;

  END LOOP;

-- UPDATE USER ATTRIBS

  l_current_seq := 1;

  FOR igs_sc_usr_attribs_rec IN igs_sc_usr_attribs_c LOOP

    IF igs_sc_usr_attribs_rec.user_attrib_id <> l_current_seq THEN

      -- Update all tables

      UPDATE IGS_SC_GRANT_CONDS SET user_attrib_id = l_current_seq WHERE user_attrib_id = igs_sc_usr_attribs_rec.user_attrib_id;
      UPDATE IGS_SC_USR_ATT_VALS SET user_attrib_id = l_current_seq WHERE user_attrib_id = igs_sc_usr_attribs_rec.user_attrib_id;

      -- Update table itself
      UPDATE igs_sc_usr_attribs SET user_attrib_id = l_current_seq WHERE CURRENT OF igs_sc_usr_attribs_c;

    END IF;

    l_current_seq := l_current_seq +1;

  END LOOP;



-- UPDATE GROUPS

  l_current_seq := 1;

  FOR igs_sc_obj_groups_rec IN igs_sc_obj_groups_c LOOP

    IF igs_sc_obj_groups_rec.obj_group_id <> l_current_seq THEN

      -- Update all tables

      UPDATE IGS_SC_OBJECTS SET obj_group_id = l_current_seq WHERE obj_group_id = igs_sc_obj_groups_rec.obj_group_id;

      UPDATE IGS_SC_OBJ_FUNCTNS SET obj_group_id = l_current_seq WHERE obj_group_id = igs_sc_obj_groups_rec.obj_group_id;

      UPDATE IGS_SC_OBJ_ATTRIBS SET obj_group_id = l_current_seq WHERE obj_group_id = igs_sc_obj_groups_rec.obj_group_id;

      UPDATE IGS_SC_GRANTS SET obj_group_id = l_current_seq WHERE obj_group_id = igs_sc_obj_groups_rec.obj_group_id;

      -- Update table itself
      UPDATE igs_sc_obj_groups SET obj_group_id = l_current_seq WHERE CURRENT OF igs_sc_obj_groups_c;

    END IF;

    l_current_seq := l_current_seq +1;

  END LOOP;

-- UPDATE FUNCTIONS

  l_current_seq := 1;

  FOR igs_sc_obj_functns_rec IN igs_sc_obj_functns_c LOOP

    IF igs_sc_obj_functns_rec.function_id <> l_current_seq THEN

      -- Update all tables

      UPDATE IGS_SC_GRANTS SET function_id = l_current_seq WHERE function_id = igs_sc_obj_functns_rec.function_id;

      -- Update table itself
      UPDATE igs_sc_obj_functns SET function_id = l_current_seq WHERE CURRENT OF igs_sc_obj_functns_c;

    END IF;

    l_current_seq := l_current_seq +1;

  END LOOP;


-- UPDATE OBJ ATTRIBS

  l_current_seq := 1;

  FOR igs_sc_obj_attribs_rec IN igs_sc_obj_attribs_c LOOP

    IF igs_sc_obj_attribs_rec.obj_attrib_id <> l_current_seq THEN

      -- Update all tables

      UPDATE IGS_SC_OBJ_ATT_MTHS SET obj_attrib_id = l_current_seq WHERE obj_attrib_id = igs_sc_obj_attribs_rec.obj_attrib_id;

      UPDATE IGS_SC_OBJ_ATT_VALS SET obj_attrib_id = l_current_seq WHERE obj_attrib_id = igs_sc_obj_attribs_rec.obj_attrib_id;

      UPDATE IGS_SC_GRANT_CONDS SET obj_attrib_id = l_current_seq WHERE obj_attrib_id = igs_sc_obj_attribs_rec.obj_attrib_id;

      -- Update table itself
      UPDATE igs_sc_obj_attribs SET obj_attrib_id = l_current_seq WHERE CURRENT OF igs_sc_obj_attribs_c;

    END IF;

    l_current_seq := l_current_seq +1;

  END LOOP;


END change_seq;


PROCEDURE enable_upgrade_mode (
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_obj_group_id      IN igs_sc_obj_groups.obj_group_id%TYPE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_data          OUT NOCOPY VARCHAR2
) IS

 l_api_name       CONSTANT VARCHAR2(30)   := 'ENABLE_UPGRADE_MODE';
 l_api_version    CONSTANT NUMBER         := 1.0;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     enable_upgrade_mode;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- API body
  -- Unlock all grants.
  IF p_obj_group_id <> -1 THEN
    -- Unlock Grants for the object group ID
    IGS_SC_GRANTS_PVT.unlock_all_grants(
      p_api_version       => 1.0 ,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_obj_group_id      => p_obj_group_id);


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;
  ELSE
    -- Unlock all grants i.e disable security
    IGS_SC_GRANTS_PVT.unlock_all_grants(
      p_api_version       => 1.0 ,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_obj_group_id      => null);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;




  -- Set internal variable for upgrade mode

  g_upgrade_mode := 'Y';


  -- End of API body.
  -- Standard check of p_commit.

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => l_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO enable_upgrade_mode;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO enable_upgrade_mode;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO enable_upgrade_mode;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                 p_data  => x_msg_data );

END enable_upgrade_mode;

FUNCTION replace_string(
  p_string       IN VARCHAR2,
  p_from_pattern IN VARCHAR2,
  p_to_pattern   IN VARCHAR2
) RETURN VARCHAR2
IS

 l_out_string   VARCHAR2(4000);
 l_upper_string VARCHAR2(4000);
 l_occurence    NUMBER(10) := 0;
 l_len          NUMBER(5);

BEGIN

  IF upper(p_from_pattern) = upper(p_to_pattern) THEN

    --check for being the same value, infinite loop
    RETURN p_string;

  END IF;

  -- delete all values for the current user

  l_out_string := p_string;
  l_upper_string := UPPER(l_out_string);

  l_len := length(p_from_pattern);

  l_occurence := INSTR(l_upper_string,p_from_pattern,1,1);

  LOOP

    IF l_occurence = 0 THEN
      -- no more found exit
      EXIT;

    END IF;

    l_out_string := SUBSTR(l_out_string,1,l_occurence-1)||p_to_pattern||SUBSTR(l_out_string,l_occurence+l_len,32000);

    l_upper_string := UPPER(l_out_string);

    -- find next
    l_occurence := INSTR(l_upper_string,p_from_pattern,1,1);

  END LOOP;

  RETURN l_out_string;

END replace_string;

FUNCTION get_obj_name (
  p_obj_id IN fnd_objects.object_id%TYPE )
RETURN VARCHAR2 IS

  l_obj_name  fnd_objects.database_object_name%TYPE ;

  CURSOR c_objects IS
    SELECT DATABASE_OBJECT_NAME
      FROM FND_OBJECTS
     WHERE OBJECT_ID = p_obj_id;
BEGIN

  OPEN c_objects;
  FETCH c_objects INTO l_obj_name;
  CLOSE c_objects;

  RETURN l_obj_name;


END get_obj_name;


PROCEDURE Cut_String (
  p_file_ptr   UTL_FILE.FILE_TYPE,
  p_string   IN VARCHAR2
) IS
 l_new_string    VARCHAR2(255);
 l_result_string VARCHAR2(4000);
 l_pos           NUMBER;
 l_total_len     NUMBER(3) := 250;
BEGIN

 l_result_string := p_string;

 LOOP

  IF length (l_result_string) <= l_total_len THEN
   EXIT;
  END IF;
   --Get a 255 charachter string
   l_new_string := substr(l_result_string,1,l_total_len);

   l_pos :=l_total_len;

   -- Find space starting from end
   WHILE ( (substr(l_new_string,l_pos,1) <>' ') AND  (substr(l_new_string,l_pos-1,l_pos) IS NOT NULL)) LOOP
     l_pos := l_pos -1;
   END LOOP;

   l_new_string := substr(l_new_string,1,l_pos);

   -- put to the file
   UTL_FILE.PUT_LINE ( p_file_ptr, l_new_string);

   -- modify string
   l_result_string := substr(l_result_string,length(l_new_string)+1,4000);

 END LOOP;

 UTL_FILE.PUT_LINE ( p_file_ptr, l_result_string);

END Cut_String;

PROCEDURE Generate_Table_SQL (
  p_table_name IN VARCHAR2,
  p_where_clause IN VARCHAR2,
  p_pk_value   IN VARCHAR2,
  p_file_ptr   UTL_FILE.FILE_TYPE
  )
IS
  l_query_str  VARCHAR2(32000);
  l_result     VARCHAR2(32000);
  l_col_list   VARCHAR2(32000);
  l_concat_col_list  VARCHAR2(32000);
  l_col_name   VARCHAR2(80);
  l_object_num  NUMBER(1):=0;
  TYPE cur_typ IS REF CURSOR;
  c_query       cur_typ;
  l_str        VARCHAR2(2000);
  l_status      VARCHAR2(255);
  l_industry      VARCHAR2(255);
  l_owner      VARCHAR2(255);

  CURSOR c_cols IS
    SELECT COLUMN_NAME
      FROM ALL_TAB_COLUMNS
     WHERE TABLE_NAME=p_table_name
           AND OWNER = l_owner
  ORDER BY COLUMN_NAME;

BEGIN
  -- Get application
  IF NOT FND_INSTALLATION.GET_APP_INFO (
              application_short_name => 'IGS',
              status	=> l_status,
              industry => l_industry,
              oracle_schema	=>  l_owner) THEN
    l_owner := 'IGS';
  END IF;

  FOR c_cols_rec IN c_cols LOOP

    IF  c_cols_rec.column_name =  'OBJECT_ID'  THEN
        l_col_name := 'IGS_SC_DATA_SEC_APIS_PKG.get_obj_name('||c_cols_rec.column_name||')';
        l_object_num :=1;
    ELSE
      l_col_name   := c_cols_rec.column_name;
    END IF;

    IF l_col_list IS NULL THEN
      l_col_list := c_cols_rec.column_name;


      l_concat_col_list := '''''''''||'||l_col_name||'||''''''';

    ELSE
      l_col_list := l_col_list||','||c_cols_rec.column_name;
      IF  c_cols_rec.column_name =  'OBJECT_ID' THEN
        -- do not append '' at the beggining

        l_concat_col_list := l_concat_col_list||',IGS_SC_DATA_SEED_PKG.get_obj_id(''''''||'||l_col_name||'||'''''')';

      ELSIF  c_cols_rec.column_name IN  ('CREATION_DATE','START_DATE','LAST_UPDATE_DATE') THEN

        l_concat_col_list := l_concat_col_list||',sysdate';

      ELSE

        l_concat_col_list := l_concat_col_list||',''''''||'||l_col_name||'||''''''';

      END IF;
    END IF;
  END LOOP;
--  l_concat_col_list := l_concat_col_list||'||''''''''';
  l_concat_col_list := l_concat_col_list||'''';

  l_query_str := 'SELECT '||l_concat_col_list||' FROM '||p_table_name||' WHERE '||p_where_clause;
--   UTL_FILE.PUT_LINE ( p_file_ptr, l_query_str);

  OPEN c_query FOR l_query_str USING p_pk_value;
  LOOP

   FETCH c_query INTO l_result;
   EXIT WHEN c_query%NOTFOUND;

   l_str := 'INSERT INTO '||p_table_name||' ('||l_col_list||') VALUES ( ';
   Cut_String ( p_file_ptr, l_str);

   l_str := l_result||');' ;
   Cut_String ( p_file_ptr, l_str);

   UTL_FILE.FFLUSH ( p_file_ptr );

  END LOOP;
  CLOSE c_query;


END Generate_Table_SQL;

PROCEDURE Generate_Objects_SQL (
  p_file_ptr   UTL_FILE.FILE_TYPE
  )
IS

  l_comm_string VARCHAR2(700) ;
  l_cur_object  NUMBER;

  CURSOR c_objects IS
    SELECT DATABASE_OBJECT_NAME,
           PK1_COLUMN_NAME   ,
           PK2_COLUMN_NAME   ,
           PK3_COLUMN_NAME   ,
           PK4_COLUMN_NAME   ,
           PK5_COLUMN_NAME   ,
           PK1_COLUMN_TYPE   ,
           PK2_COLUMN_TYPE   ,
           PK3_COLUMN_TYPE   ,
           PK4_COLUMN_TYPE   ,
           PK5_COLUMN_TYPE   ,
           APPLICATION_ID  ,
           OBJ_NAME
      FROM FND_OBJECTS
     WHERE OBJ_NAME LIKE 'IGS%'
  ORDER BY OBJ_NAME;

BEGIN

  -- Put script begginning part

  UTL_FILE.PUT_LINE ( p_file_ptr,'  DECLARE');

  UTL_FILE.PUT_LINE ( p_file_ptr,'   CURSOR c_obj (v_database_object_name VARCHAR2 ) IS');
  UTL_FILE.PUT_LINE ( p_file_ptr,'     SELECT object_id');
  UTL_FILE.PUT_LINE ( p_file_ptr,'       FROM fnd_objects ');
  UTL_FILE.PUT_LINE ( p_file_ptr,'      WHERE database_object_name = v_database_object_name;');

  UTL_FILE.PUT_LINE ( p_file_ptr,'  TYPE l_obj_rec_tbl IS TABLE OF fnd_objects%ROWTYPE  INDEX BY BINARY_INTEGER;');

  UTL_FILE.PUT_LINE ( p_file_ptr,'  l_obj_tbl l_obj_rec_tbl;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'  l_object_id  fnd_objects.object_id%TYPE;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'  l_record_num NUMBER(10);');
  UTL_FILE.PUT_LINE ( p_file_ptr,'  l_cur_num NUMBER(10) := 0;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'  l_total   NUMBER(9) :=0;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'  l_rowid VARCHAR2(255);');
  UTL_FILE.PUT_LINE ( p_file_ptr,' BEGIN');

  l_cur_object := 0;

  FOR c_objects_rec IN c_objects LOOP
     l_comm_string := '  l_obj_tbl('||l_cur_object||').DATABASE_OBJECT_NAME := '''||c_objects_rec.DATABASE_OBJECT_NAME||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK1_COLUMN_NAME := '''||c_objects_rec.PK1_COLUMN_NAME||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK1_COLUMN_TYPE := '''||c_objects_rec.PK1_COLUMN_TYPE||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK2_COLUMN_NAME := '''||c_objects_rec.PK2_COLUMN_NAME||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK2_COLUMN_TYPE := '''||c_objects_rec.PK2_COLUMN_TYPE||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );

     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK3_COLUMN_NAME := '''||c_objects_rec.PK3_COLUMN_NAME||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK3_COLUMN_TYPE := '''||c_objects_rec.PK3_COLUMN_TYPE||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );

     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK4_COLUMN_NAME := '''||c_objects_rec.PK4_COLUMN_NAME||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK4_COLUMN_TYPE := '''||c_objects_rec.PK4_COLUMN_TYPE||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );

     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK5_COLUMN_NAME := '''||c_objects_rec.PK5_COLUMN_NAME||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').PK5_COLUMN_TYPE := '''||c_objects_rec.PK5_COLUMN_TYPE||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').APPLICATION_ID := '''||c_objects_rec.APPLICATION_ID||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );
     l_comm_string := '  l_obj_tbl('||l_cur_object||').OBJ_NAME := '''||c_objects_rec.OBJ_NAME||''';';
     UTL_FILE.PUT_LINE ( p_file_ptr,l_comm_string );

    UTL_FILE.FFLUSH ( p_file_ptr );
    l_cur_object := l_cur_object+1;

  END LOOP;

  UTL_FILE.PUT_LINE ( p_file_ptr,'  l_total :='||(l_cur_object-1)||';' );
  UTL_FILE.FFLUSH ( p_file_ptr );

  --Add last part of the script
  UTL_FILE.PUT_LINE ( p_file_ptr,'   FOR l_cur_num IN 0..l_total LOOP      ');
  UTL_FILE.PUT_LINE ( p_file_ptr,'     l_object_id := null; ');

  UTL_FILE.PUT_LINE ( p_file_ptr,'     OPEN c_obj ( l_obj_tbl(l_cur_num).DATABASE_OBJECT_NAME);');
  UTL_FILE.PUT_LINE ( p_file_ptr,'     FETCH c_obj INTO l_object_id;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'     CLOSE c_obj;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'     IF l_object_id IS NULL THEN ');
  UTL_FILE.PUT_LINE ( p_file_ptr,'      SELECT fnd_objects_s.nextval INTO l_object_id FROM DUAL;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'      FND_OBJECTS_PKG.INSERT_ROW (');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_rowid => l_rowid,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_object_id =>l_object_id,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_obj_name => l_obj_tbl(l_cur_num).OBJ_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk1_column_name =>   l_obj_tbl(l_cur_num).PK1_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk2_column_name =>   l_obj_tbl(l_cur_num).PK2_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk3_column_name =>   l_obj_tbl(l_cur_num).PK3_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk4_column_name =>   l_obj_tbl(l_cur_num).PK4_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk5_column_name =>   l_obj_tbl(l_cur_num).PK5_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk1_column_type =>   l_obj_tbl(l_cur_num).PK1_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk2_column_type =>   l_obj_tbl(l_cur_num).PK2_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk3_column_type =>   l_obj_tbl(l_cur_num).PK3_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk4_column_type =>   l_obj_tbl(l_cur_num).PK4_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk5_column_type =>   l_obj_tbl(l_cur_num).PK5_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_application_id  =>   l_obj_tbl(l_cur_num).APPLICATION_ID  ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_database_object_name => l_obj_tbl(l_cur_num).DATABASE_OBJECT_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_display_name    => l_obj_tbl(l_cur_num).OBJ_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_description     => l_obj_tbl(l_cur_num).OBJ_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_creation_date   => sysdate,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_created_by      =>   nvl(fnd_global.user_id,-1),');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_last_update_date => sysdate,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_last_updated_by  => nvl(fnd_global.user_id,-1),');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_last_update_login => nvl(fnd_global.login_id, -1));');

  UTL_FILE.PUT_LINE ( p_file_ptr,'    ELSE');

  UTL_FILE.PUT_LINE ( p_file_ptr,'     FND_OBJECTS_PKG.UPDATE_ROW (');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_object_id =>l_object_id,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_obj_name => l_obj_tbl(l_cur_num).OBJ_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk1_column_name =>   l_obj_tbl(l_cur_num).PK1_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk2_column_name =>   l_obj_tbl(l_cur_num).PK2_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk3_column_name =>   l_obj_tbl(l_cur_num).PK3_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk4_column_name =>   l_obj_tbl(l_cur_num).PK4_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk5_column_name =>   l_obj_tbl(l_cur_num).PK5_COLUMN_NAME   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk1_column_type =>   l_obj_tbl(l_cur_num).PK1_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk2_column_type =>   l_obj_tbl(l_cur_num).PK2_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk3_column_type =>   l_obj_tbl(l_cur_num).PK3_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk4_column_type =>   l_obj_tbl(l_cur_num).PK4_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_pk5_column_type =>   l_obj_tbl(l_cur_num).PK5_COLUMN_TYPE   ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_application_id  =>   l_obj_tbl(l_cur_num).APPLICATION_ID  ,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_database_object_name => l_obj_tbl(l_cur_num).DATABASE_OBJECT_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_display_name    => l_obj_tbl(l_cur_num).OBJ_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_description     => l_obj_tbl(l_cur_num).OBJ_NAME,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_last_update_date  => sysdate,');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_last_updated_by   => nvl(fnd_global.user_id,-1),');
  UTL_FILE.PUT_LINE ( p_file_ptr,'         x_last_update_login => nvl(fnd_global.login_id, -1));');

  UTL_FILE.PUT_LINE ( p_file_ptr,'     END IF;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'   END LOOP;');

  UTL_FILE.PUT_LINE ( p_file_ptr,'END;');
  UTL_FILE.PUT_LINE ( p_file_ptr,'/');
  UTL_FILE.FFLUSH ( p_file_ptr );


END Generate_Objects_SQL;






PROCEDURE Generate_SQL_file(
  p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_NONE,
  x_return_status     OUT  NOCOPY VARCHAR2,
  x_msg_count         OUT  NOCOPY NUMBER,
  x_msg_data          OUT  NOCOPY VARCHAR2,
  p_dirpath           IN   VARCHAR2,
  p_in_file_name      IN   VARCHAR2,
  p_out_file_name      IN   VARCHAR2
)
IS


 l_api_name         CONSTANT VARCHAR2(30)   := 'Generate_SQL_file';
 l_api_version        CONSTANT NUMBER       := 1.0;
 l_in_file_ptr      UTL_FILE.FILE_TYPE;
 l_out_file_ptr      UTL_FILE.FILE_TYPE;
 l_line             VARCHAR2(2000);
 l_line2            VARCHAR2(2000);
 l_attr_val         VARCHAR2(255);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Generate_SQL_file;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_in_file_ptr  := UTL_FILE.FOPEN ( p_dirpath, p_in_file_name, 'r',2000 );
  l_out_file_ptr  := UTL_FILE.FOPEN ( p_dirpath, p_out_file_name, 'a',2000 );

 -- Put header infomation
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM +=======================================================================+' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM +=======================================================================+' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM | FILENAME                                                              |' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM |    IGSSC001.sql                                                       |' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM |                                                                       |' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM | DESCRIPTION                                                           |' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM |     this file si generated by IGS security package                    |' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM |     It contains seed data SQL for SEED115 ONLY                        | ' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM |     Never apply to any other environments                             |' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'REM +=======================================================================+' );

    UTL_FILE.PUT_LINE ( l_out_file_ptr,'SET VERIFY OFF;' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'WHENEVER OSERROR  EXIT FAILURE ROLLBACK;' );
    UTL_FILE.PUT_LINE ( l_out_file_ptr,'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;' );



--  UTL_FILE.PUT_LINE ( l_out_file_ptr, '# ' );
--  UTL_FILE.FFLUSH ( l_out_file_ptr );
    Generate_Objects_SQL (l_out_file_ptr);

  BEGIN
    LOOP
      UTL_FILE.GET_LINE ( l_in_file_ptr, l_line );
      UTL_FILE.GET_LINE ( l_in_file_ptr, l_line2 );

      UTL_FILE.PUT_LINE ( l_out_file_ptr, 'DELETE FROM '||ltrim(rtrim(l_line))||' WHERE '||replace_string(l_line2,':1','1')||';' );
      UTL_FILE.FFLUSH ( l_out_file_ptr );

      Generate_Table_SQL (ltrim(rtrim(l_line)),l_line2,'1', l_out_file_ptr);


    END LOOP;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
              RAISE;
  END;

  UTL_FILE.PUT_LINE ( l_out_file_ptr,'COMMIT;');
  UTL_FILE.PUT_LINE ( l_out_file_ptr,'EXIT;');
  UTL_FILE.FFLUSH ( l_out_file_ptr );

  IF (UTL_FILE.IS_OPEN ( l_out_file_ptr )) THEN
      UTL_FILE.FCLOSE ( l_out_file_ptr );
  END IF;

EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
        ROLLBACK TO Generate_SQL_file;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('IGS', 'IGS_DS_INVALID_PATH');
        FND_MSG_PUB.Add;

 WHEN UTL_FILE.WRITE_ERROR THEN
        ROLLBACK TO Generate_SQL_file;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('IGS', 'IGS_DS_WRITE_ERROR');
        FND_MSG_PUB.Add;

 WHEN UTL_FILE.INVALID_FILEHANDLE  THEN
        ROLLBACK TO Generate_SQL_file;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name('IGS', 'IGS_DS_INVALID_FILEHANDLE');
        FND_MSG_PUB.Add;

 WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO Generate_SQL_file;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF (UTL_FILE.IS_OPEN ( l_out_file_ptr )) THEN
        UTL_FILE.FCLOSE ( l_out_file_ptr );
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO Generate_SQL_file;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (UTL_FILE.IS_OPEN ( l_out_file_ptr )) THEN
        UTL_FILE.FCLOSE ( l_out_file_ptr );
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO Generate_SQL_file;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     END IF;

     IF (UTL_FILE.IS_OPEN ( l_out_file_ptr )) THEN
        UTL_FILE.FCLOSE ( l_out_file_ptr );
     END IF;

END Generate_SQL_file;

END IGS_SC_DATA_SEC_APIS_PKG;

/
