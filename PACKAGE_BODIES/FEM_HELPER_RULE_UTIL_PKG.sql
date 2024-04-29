--------------------------------------------------------
--  DDL for Package Body FEM_HELPER_RULE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_HELPER_RULE_UTIL_PKG" AS
--$Header: fem_helper_rule_utl.plb 120.6 2008/02/20 06:58:04 jcliving noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_helper_rule_utl.plb
 |
 | NAME FEM_HELPER_RULE_UTIL_PKG
 |
 | DESCRIPTION
 |
 |   Package Body for the FEM Helper Rule Utility Package
 |
 | HISTORY
 |
 |    19-JAN-06  RFlippo  initial creation
 |    10-MAY-07  RFlippo  added p_commit logic
 |    22-MAY-07  RFlippo  get_helper needs to find helper for the Object_ID
 |                        and register it if it exists
 |    24-MAY-07  RFlippo  fixed issue where get_helper_rule not working
 |                        for cr_new_ver_from_defaults
 |    05-JUL-07  Rflippo  remove savepoint on get_helper_rule because
 |                        needs to be callable from functions (i.e.
 |                        get_rule_dirty_flag)
 +=========================================================================*/

-----------------------
-- Package Constants --
-----------------------
c_resp_app_id CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;

c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;
c_login_id    NUMBER := FND_GLOBAL.Login_Id;

c_module_pkg   CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_helper_rule_util_pkg';
G_PKG_NAME     CONSTANT  VARCHAR2(30) := 'FEM_HELPER_RULE_UTIL_PKG';

f_set_status  BOOLEAN;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

-----------------------
-- Package Variables --
-----------------------
v_module_log   VARCHAR2(255);


v_token_value  VARCHAR2(150);
v_token_trans  VARCHAR2(1);

v_msg_text     VARCHAR2(4000);

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);


-----------------------
-- Private Procedures --
-----------------------
PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);



/*************************************************************************

                       register_helper_rule

PURPOSE:  Registers the association between a true rule and a helper rule.

*************************************************************************/

PROCEDURE register_helper_rule (
   p_rule_obj_def_id IN NUMBER,
   p_helper_obj_def_id   IN NUMBER,
   p_helper_object_type_code IN VARCHAR2,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2)
 IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_helper_rule_util_pkg.register_helper_rule';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Register_helper_rule';

  v_rule_object_id   NUMBER;
  v_helper_object_id NUMBER;
  v_object_type_code VARCHAR2(30);

  e_unexp            EXCEPTION;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  register_helper_rule_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_unexp;
  END IF;


BEGIN

   SELECT object_id
   INTO v_rule_object_id
   FROM fem_object_definition_b
   WHERE object_definition_id = p_rule_obj_def_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'p_rule_obj_def_id does not exist');
    END IF;
    RAISE e_unexp;

END;

BEGIN

   SELECT object_id
   INTO v_helper_object_id
   FROM fem_object_definition_b
   WHERE object_definition_id = p_helper_obj_def_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'p_helper_obj_def_id does not exist');
    END IF;
    RAISE e_unexp;

END;

/*  Verify that the object_type_code is valid */
BEGIN

   SELECT object_type_code
   INTO v_object_type_code
   FROM fem_object_types_vl
   WHERE object_type_code = p_helper_object_type_code;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'p_object_type_code does not exist');
    END IF;
    RAISE e_unexp;


END;


insert into fem_objdef_helper_rules (OBJECT_DEFINITION_ID,
HELPER_OBJECT_TYPE_CODE,
OBJECT_ID,
HELPER_OBJ_DEF_ID,
HELPER_OBJECT_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN
)
values (p_rule_obj_def_id
,p_helper_object_type_code
,v_rule_object_id
,p_helper_obj_def_id
,v_helper_object_id
,sysdate
,c_user_id
,c_user_id
,sysdate
,c_login_id);


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;


IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION

 WHEN e_unexp THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO register_helper_rule_pub;
    x_return_status := c_unexp;


 WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => SQLERRM);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO register_helper_rule_pub;
    x_return_status := c_unexp;

END register_helper_rule;



/*************************************************************************

                       get_helper_rule

PURPOSE:  Identifies the helper rule of a specified helper object type
          for a given true rule.

*************************************************************************/

PROCEDURE get_helper_rule (
   p_rule_obj_def_id         IN NUMBER,
   p_helper_object_type_code IN VARCHAR2,
   p_api_version             IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list           IN VARCHAR2   DEFAULT c_false,
   p_commit                  IN VARCHAR2   DEFAULT c_false,
   p_encoded                 IN VARCHAR2   DEFAULT c_true,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_helper_obj_def_id       OUT NOCOPY NUMBER   )
 IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_helper_rule_util_pkg.get_helper_rule';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'get_helper_rule';

  v_rule_object_id   NUMBER;
  v_helper_object_id NUMBER;
  v_object_type_code VARCHAR2(30);
  v_msg_count        NUMBER;
  v_msg_data         VARCHAR2(4000);
  v_return_status    VARCHAR2(4000);

  e_unexp            EXCEPTION;

BEGIN

/*  comment out so can be called from function
  -- Standard Start of API savepoint
  SAVEPOINT  get_helper_rule_pub;  */


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_unexp;
  END IF;


/* Verify that the object def id exists*/
BEGIN

   SELECT object_id
   INTO v_rule_object_id
   FROM fem_object_definition_b
   WHERE object_definition_id = p_rule_obj_def_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'p_rule_obj_def_id ='||p_rule_obj_def_id||' does not exist');
    END IF;
    RAISE e_unexp;

END;


/*  Verify that the object_type_code is valid */
BEGIN

   SELECT object_type_code
   INTO v_object_type_code
   FROM fem_object_types_vl
   WHERE object_type_code = p_helper_object_type_code;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'p_object_type_code ='||p_helper_object_type_code||'does not exist');
    END IF;
    RAISE e_unexp;


END;


BEGIN

   SELECT helper_obj_def_id
   INTO x_helper_obj_def_id
   FROM fem_objdef_helper_rules
   WHERE object_definition_id = p_rule_obj_def_id
   AND helper_object_type_code = p_helper_object_type_code;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
 /*  Does helper exist for this Object ID */
   BEGIN
      SELECT min(helper_obj_def_id)
      INTO x_helper_obj_def_id
      FROM fem_objdef_helper_rules H, fem_object_definition_b D
      WHERE D.object_id = H.object_id
      AND D.object_definition_id = p_rule_obj_def_id
      AND helper_object_type_code = p_helper_object_type_code;

   IF x_helper_obj_def_id IS NULL THEN
          IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => FND_LOG.level_statement,
              p_module   => C_MODULE,
              p_msg_text => ' no helper rule for rule_obj_def_id ='||p_rule_obj_def_id||' and object_type_code = '||p_helper_object_type_code);
          END IF;
          RAISE e_unexp;

   END IF;

   /*  Register the helper for this mapping rule object def */
     register_helper_rule (
        p_rule_obj_def_id => p_rule_obj_def_id,
        p_helper_obj_def_id => x_helper_obj_def_id,
        p_helper_object_type_code => p_helper_object_type_code,
        x_return_status  => v_return_status,
        x_msg_count  => v_msg_count,
        x_msg_data => v_msg_data);


   END;

END;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;




EXCEPTION

 WHEN e_unexp THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    --ROLLBACK TO get_helper_rule_pub;
    x_return_status := c_unexp;
    x_helper_obj_def_id := -1;


 WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => SQLERRM);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    --ROLLBACK TO get_helper_rule_pub;
    x_return_status := c_unexp;
    x_helper_obj_def_id := -1;

END get_helper_rule;





/*************************************************************************

                         OA Exception Handler

*************************************************************************/

PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   e_bad_p_api_ver         EXCEPTION;
   e_bad_p_init_msg_list   EXCEPTION;
   e_bad_p_commit          EXCEPTION;
   e_bad_p_encoded         EXCEPTION;
BEGIN

x_return_status := c_success;

CASE p_api_version
   WHEN c_api_version THEN NULL;
   ELSE RAISE e_bad_p_api_ver;
END CASE;

CASE p_init_msg_list
   WHEN c_false THEN NULL;
   WHEN c_true THEN
      FND_MSG_PUB.Initialize;
   ELSE RAISE e_bad_p_init_msg_list;
END CASE;

CASE p_encoded
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_encoded;
END CASE;

CASE p_commit
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_commit;
END CASE;

EXCEPTION
   WHEN e_bad_p_api_ver THEN
     IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_api_version);
      END IF;
      x_return_status := c_error;


   WHEN e_bad_p_init_msg_list THEN
       IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_INIT_MSG_LIST_ERR');
      END IF;
      x_return_status := c_error;


   WHEN e_bad_p_encoded THEN
       IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_ENCODED_ERR');
      END IF;
      x_return_status := c_error;

   WHEN e_bad_p_commit THEN
       IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_COMMIT_ERR');
      END IF;
      x_return_status := c_error;

END Validate_OA_Params;


END FEM_helper_rule_util_Pkg;

/
