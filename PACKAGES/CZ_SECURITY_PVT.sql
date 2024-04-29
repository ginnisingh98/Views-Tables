--------------------------------------------------------
--  DDL for Package CZ_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_SECURITY_PVT" AUTHID CURRENT_USER AS
/*  $Header: czsecurs.pls 120.1 2008/02/18 15:02:34 ethomas ship $       */

--------------------------Pkg level constants------
----entity access user types
ENTITY_CREATOR      CONSTANT VARCHAR2(20) := 'CREATOR';
ENTITY_USER         CONSTANT VARCHAR2(20) := 'USER';

----user privilege constants
EDIT_ENTITY               CONSTANT VARCHAR2(100) := 'E';
MANAGE_ENTITY             CONSTANT VARCHAR2(100) := 'M';
MANAGE_AND_EDIT_ENTITY    CONSTANT VARCHAR2(100) := 'ME';
NO_MANAGE_AND_EDIT_ENTITY CONSTANT VARCHAR2(100) := 'N';

----entity type constants
MODEL         CONSTANT VARCHAR2(30) := 'MODEL';
UI            CONSTANT VARCHAR2(30) := 'UI';
RULEFOLDER    CONSTANT VARCHAR2(30) := 'RULEFOLDER';

----has privilege constants
HAS_PRIVILEGE      CONSTANT VARCHAR2(1)   := 'T';
HAS_NO_PRIVILEGE   CONSTANT VARCHAR2(1)   := 'F';
UNEXPECTED_ERROR   CONSTANT VARCHAR2(100) := 'U';

----default user access constants
DEFAULT_ENTITY_ACCESS     CONSTANT VARCHAR2(100) := 'CZ_DEFAULT_MODEL_ACCESS';
USE_ENTITY_ACCESS_CONTROL CONSTANT VARCHAR2(100) := 'CZ_USE_ENTITY_ACCESS_CONTROL';

-----model global operations constants
PUBLISH_MODEL_FUNCTION            CONSTANT    VARCHAR2(100) := 'CZDEVPUBLISHFUNC';
GENERATE_ACTIVE_MODEL_FUNCTION    CONSTANT    VARCHAR2(100) := 'CZDEVLOGICGENFUNC';
GENERATE_UI_FUNCTION              CONSTANT    VARCHAR2(100) := 'CZDEVUIGENFUNC';
IMPORT_MODEL_FUNCTION             CONSTANT    VARCHAR2(100) := 'CZDEVIMPORTMODELFUNC';
POPULATORS_FUNCTION               CONSTANT    VARCHAR2(100) := 'CZDEVPOPULATORSFUNC';
DEEP_MODEL_COPY_FUNC              CONSTANT    VARCHAR2(100) := 'CZDEVDEEPMODELCOPYFUNC';
UNLOCK_FUNCTION                   CONSTANT    VARCHAR2(100) := 'CZDEVFORCEUNLOCKFUNC';
UNLOCK_CHILD_MODELS               CONSTANT    VARCHAR2(1) := '1';
DO_NOT_UNLOCK_CHILD_MODELS        CONSTANT    VARCHAR2(1) := '0';
DO_COMMIT                         CONSTANT    VARCHAR2(1) := '1';
DO_NOT_COMMIT                     CONSTANT    VARCHAR2(1) := '0';
LOCK_CHILD_MODELS                 CONSTANT    VARCHAR2(1) := '1';
DO_NOT_LOCK_CHILD_MODELS          CONSTANT    VARCHAR2(1) := '0';
DO_INIT_MSG_LIST                  CONSTANT    VARCHAR2(1) := '1';

-----lock profiles
LOCK_MODELS_FOR_EDIT       CONSTANT VARCHAR2(100) := 'CZ_EDIT_MODELS_NO_LOCK';
LOCK_REQUIRE_LOCKING       CONSTANT VARCHAR2(100) := 'CZ_REQUIRE_LOCKING';
LOCK_MODELS_FOR_GLOPS      CONSTANT VARCHAR2(100) := 'CZ_ALLOW_GLOBAL_OPERATIONS_WITHOUT_LOCK';
LOCK_PUBLICATION_FOR_TEST  CONSTANT VARCHAR2(100) := 'CZ_ALLOW_PUBLISH_TO_TEST_WHEN_LOCKED';
LOCK_PUBLICATION_FOR_PROD  CONSTANT VARCHAR2(100) := 'CZ_ALLOW_PUBLISH_TO_PRODUCTION_WHEN_LOCKED';

------constants for lock
LOCK_REQUIRED                   CONSTANT VARCHAR2(1) := 'Y';
LOCK_NOT_REQUIRED               CONSTANT VARCHAR2(1) := 'N';

-----constants for deep and shallow lock
DEEP_LOCK    CONSTANT VARCHAR2(1)   := '1';
SHALLOW_LOCK CONSTANT VARCHAR2(1)   := '0';

----entity table names
DEVL_PROJECT_TABLE  CONSTANT VARCHAR2(100) := 'CZ_DEVL_PROJECTS';
UI_DEFS_TABLE       CONSTANT VARCHAR2(100) := 'CZ_UI_DEFS';
RULE_FOLDERS_TABLE  CONSTANT VARCHAR2(100) := 'CZ_RULE_FOLDERS';

INVALID_ENTITY_TYPE EXCEPTION;

----role type constants
MANAGE_MODEL_ROLE  CONSTANT VARCHAR2(100) := 'CZMANAGEMODELROLE';
EDIT_MODEL_ROLE    CONSTANT VARCHAR2(100) := 'CZEDITMODELROLE';
EDIT_RULE_ROLE     CONSTANT VARCHAR2(100) := 'CZEDITRULEROLE';
EDIT_UI_ROLE       CONSTANT VARCHAR2(100) := 'CZEDITUIROLE';
SECURITY_MENU      CONSTANT VARCHAR2(100) := 'SECURITY';
MANAGE_ACCESS_ROLE CONSTANT VARCHAR2(100) := 'CZMANAGEACCESSROLE';


-----lock functions
LOCK_MODEL_FUNC      CONSTANT VARCHAR2(100)    := 'CZDEVEDITMODELFUNC';
LOCK_UI_FUNC         CONSTANT VARCHAR2(100)    := 'CZDEVEDITUIFUNC';
LOCK_RULEFOLDER_FUNC CONSTANT VARCHAR2(100)    := 'CZDEVEDITRULEFUNC';

G_PKG_NAME                CONSTANT VARCHAR2(100) := 'cz_security_pvt';
G_INCOMPATIBLE_API   EXCEPTION;

TYPE number_type_tbl  IS TABLE OF NUMBER index by BINARY_INTEGER;
TYPE varchar_type_tbl IS TABLE OF VARCHAR2(100) index by BINARY_INTEGER;

TYPE model_name_tbl    IS TABLE OF VARCHAR2(255)  index by BINARY_INTEGER;
TYPE checkout_user_tbl IS TABLE OF VARCHAR2(100)  index by BINARY_INTEGER;

l_grant_entity_tbl  number_type_tbl;
l_grant_entity_type_tbl varchar_type_tbl;
g_models_locked       number_type_tbl;


g_entity_profile_value VARCHAR2(100) := NULL;
g_lock_profile_value   VARCHAR2(100) := NULL;
g_has_priv_status      VARCHAR2(1) := 'N';

------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---Start of comments
---API name                 : get_default_access_profile
---Type                      : Public
---Pre-reqs                 : None
---Function                 : Returns entity access profile
---Parameters               :
---IN                       :
---
---
---RETURN VALUE                : VARCHAR2
---
---
---Version: Current version :1.0

---End of comments

FUNCTION get_default_access_profile
RETURN VARCHAR2;

------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---Start of comments
---API name                 : grant_privilege
---Type                      : Public
---Pre-reqs                 : None
---Function                 : grant access to a user on an entity
---Parameters               :
---IN                       : p_api_version          IN  NUMBER       Required
---                              p_user_name            IN  VARCHAR2      Required
---                              p_privilege            IN  VARCHAR2      Required
---                              p_entity_type          IN  VARCHAR2      Required
---                              p_instance_pk1_value   IN  NUMBER      Required
---
---OUT                      :
---                              x_return_status OUT NOCOPY VARCHAR2
---                              x_msg_count     OUT NOCOPY NUMBER
---                              x_msg_data      OUT NOCOPY VARCHAR2
---
---
---Version: Current version :1.0
---End of comments

PROCEDURE grant_privilege(p_api_version        IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_entity_role        IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
---Start of comments
---API name                 : revoke_privilege
---Type                      : Public
---Pre-reqs                 : None
---Function                 : revoke access to a user on an entity
---Parameters               :
---IN                       : p_api_version          IN  NUMBER       Required
---                              p_user_name            IN  VARCHAR2      Required
---                              p_privilege            IN  VARCHAR2      Required
---                              p_entity_type          IN  VARCHAR2      Required
---                              p_instance_pk1_value   IN  NUMBER      Required
---
---OUT                      :
---                              x_return_status OUT NOCOPY VARCHAR2
---                              x_msg_count     OUT NOCOPY NUMBER
---                              x_msg_data      OUT NOCOPY VARCHAR2
---
---
---Version: Current version :1.0
---End of comments

PROCEDURE revoke_privilege(p_api_version       IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_entity_role        IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_msg_count         OUT NOCOPY NUMBER,
                          x_msg_data          OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------------
---Start of comments
---API name                 : has_privileges
---Type                      : Public
---Pre-reqs                 : None
---Function                 : check user privilege on an entity
---Parameters               :
---IN                       : p_api_version          IN  NUMBER       Required
---                              p_user_name            IN  VARCHAR2      Required
---                              p_function_name        IN  VARCHAR2      Required
---                              p_entity_type          IN  VARCHAR2      Required
---                              p_instance_pk1_value   IN  NUMBER      Required
---
---RETURN VALUE                :
---                              VARCHAR2 (allowable values are
---                                              CZ_SECURITY_PUB.HAS_PRIVILEGE
---                                          CZ_SECURITY_PUB.HAS_NO_PRIVILEGE)
---
---Version: Current version :1.0
---End of comments

FUNCTION has_privileges   (p_api_version       IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_function_name      IN VARCHAR2,
                          p_entity_type        IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER)
RETURN VARCHAR2;

--------------------------
----This API would return 'T' if the user has edit access on atleast one entity (MODEL,UI,RULEFOLDER),
-----otherwise it will return 'F'. This is used for the enable or disable the edit icon in the repository.
FUNCTION has_model_privileges(p_model_id IN NUMBER)
RETURN VARCHAR2;

-----------------------------------------------------------------------------------
---Start of comments
---API name                 : lock_entity
---Type                      : Public
---Pre-reqs                 : None
---Function                 : lock on an entity
---Parameters               :
---IN                       : p_api_version          IN  NUMBER       Required
---                              p_user_name            IN  VARCHAR2      Required
---                              p_entity_type          IN  VARCHAR2      Required
---                              p_instance_pk1_value   IN  NUMBER      Required
---                              p_lock_type                 IN  VARCHAR2 Required
---                                 allowed values cz_security_pvt.DEEP_LOCK
---                                                cz_security_pvt.SHALLOW_LOCK
---OUT                      :
---                              x_return_status OUT NOCOPY VARCHAR2
---                              x_msg_count     OUT NOCOPY NUMBER
---                              x_msg_data      OUT NOCOPY VARCHAR2
---
---Version: Current version :1.0
---End of comments

PROCEDURE lock_entity   (p_api_version            IN NUMBER,
                            p_user_name           IN VARCHAR2,
                            p_entity_type         IN VARCHAR2,
                            p_instance_pk1_value  IN NUMBER,
                            p_lock_type           IN VARCHAR2,
                            x_locked_entities     OUT NOCOPY number_type_tbl,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2);

----------------
PROCEDURE lock_entity (p_model_id IN NUMBER,
                          p_function_name IN VARCHAR2,
                          x_locked_entities  OUT NOCOPY number_type_tbl,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2);

----------------
PROCEDURE lock_entity   (p_api_version            IN NUMBER,
                            p_user_name           IN VARCHAR2,
                            p_entity_type         IN VARCHAR2,
                            p_instance_pk1_value  IN NUMBER,
                            p_lock_type           IN VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2);
-----------------
------------------------------------------------------------------------------------------
---Start of comments
---API name                 : unlock_entity
---Type                      : Public
---Pre-reqs                 : None
---Procedure                : unlock on an entity
---Parameters               :
---IN                       : p_api_version          IN  NUMBER       Required
---                              p_user_name            IN  VARCHAR2      Required
---                              p_entity_type          IN  VARCHAR2      Required
---                              p_instance_pk1_value   IN  NUMBER      Required
---
---OUT                      :
---                              x_return_status OUT NOCOPY VARCHAR2
---                              x_msg_count     OUT NOCOPY NUMBER
---                              x_msg_data      OUT NOCOPY VARCHAR2
---
---Version: Current version :1.0
---p_user_name              : FND_USERS.USER_NAME
---p_entity_type                : FND_OBJECTS.OBJ_NAME (ALlowable values are CZ_SECURITY_PUB.MODEL,
---                              CZ_SECURITY_PUB.UI, CZ_SECURITY_PUB.RULEFOLDER)
---p_instance_pk1_value     : Allowable values
---                              devl_project_id (if p_entity_type is CZ_SECURITY_PUB.MODEL or
---                              CZ_SECURITY_PUB.UI)
---                              rule_folder_id (if p_entity_type is CZ_SECURITY_PUB.RULEFOLDER)
---x_locked_entities         : entities locked by the API.  The calling application must keep a track of the
---                               entities locked, so that when unlock is done only on these entities.
---End of comments

PROCEDURE unlock_entity   (p_api_version       IN NUMBER,
                          p_user_name          IN VARCHAR2,
                          p_entity_type        IN VARCHAR2,
                          p_instance_pk1_value IN NUMBER,
                          p_locked_entities    IN OUT NOCOPY number_type_tbl,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2);

-------------------------
PROCEDURE unlock_entity  (p_model_id IN NUMBER,
                          p_function_name IN VARCHAR2,
                          p_locked_entities IN OUT NOCOPY number_type_tbl,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2);

-------------------------
PROCEDURE unlock_entity  (p_model_id      IN NUMBER,
                          p_function_name IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2);

-------------------------
PROCEDURE unlock_entity   (p_api_version          IN NUMBER,
                            p_user_name           IN VARCHAR2,
                            p_entity_type         IN VARCHAR2,
                            p_instance_pk1_value  IN NUMBER,
                            p_lock_type           IN VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2);

-------------------------
-----unlocks whole model
PROCEDURE unlock_model (p_model_id IN NUMBER,
                         x_return_status    OUT NOCOPY VARCHAR2,
                         x_msg_count        OUT NOCOPY NUMBER,
                         x_msg_data         OUT NOCOPY VARCHAR2);

---------------------------
FUNCTION get_profile_value(p_profile IN VARCHAR2)
RETURN VARCHAR2;

---------------------------------------------------------------------
PROCEDURE has_privileges(p_model_id        IN NUMBER,
                         p_function_name   IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER);

----------------------------------------------------------------------
PROCEDURE is_lock_required (p_lock_profile  IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER);

---------------------------------------------------------------------
PROCEDURE revoke_privilege(p_api_version         IN NUMBER,
                           p_instance_pk1_value  IN NUMBER,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_msg_count          OUT NOCOPY NUMBER,
                           x_msg_data           OUT NOCOPY VARCHAR2);

--------------------------------------
-----This API returns 'N' if the MODEL(and its references),
-----UI (and its children) and RULEFOLDER (and subfolders under it) are not locked,
-----Otherwise it returns 'Y'. This is used for the display of the Lock icon in the repository.
FUNCTION is_model_locked (p_model_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE is_model_locked (p_devl_project_id IN VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2);

-------------------------------------
--------Is_root_model_locked (p_model_id IN NUMBER) is used to check
--------lock on a single model. It would return 'N' if not locked otherwise it would return 'Y'.
FUNCTION is_model_structure_locked (p_model_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------
-----API that check if the root UI or any of ites children are locked.
-----It would return a status of 'N' if not locked else 'Y'
FUNCTION is_root_ui_locked (p_ui_def_id IN NUMBER)
RETURN VARCHAR2;

------------------------------------
-----API used to check lock on a single model
-----It would return a status of 'N' if not locked else 'Y'
FUNCTION is_ui_def_locked (p_ui_def_id IN NUMBER)
RETURN VARCHAR2;

------------------------------------
-----API used to check lock on a single model and its children
-----It would return a status of 'N' if not locked else 'Y'
FUNCTION are_models_locked (p_model_id IN NUMBER)
RETURN VARCHAR2;

------------------------------------
-----API used to check lock on a all rule folders of a given model (includes sub folders)
-----It would return a status of 'N' if not locked else 'Y'
FUNCTION is_root_rulefolder_locked (p_model_id IN NUMBER)
RETURN VARCHAR2;

---------------------------------
-----API used to check lock on a single rule folder
-----It would return a status of 'N' if not locked else 'Y'
FUNCTION is_rulefolder_locked (p_rule_folder_id IN NUMBER)
RETURN VARCHAR2;

------------------------------------
PROCEDURE lock_entity (p_model_id IN NUMBER,
                       p_function_name IN VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2);

FUNCTION unlock_model_structure (p_model_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION lock_model_structure (p_model_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION lock_ui_def (p_ui_def_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION unlock_ui_def (p_ui_def_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION lock_rulefolder(p_rule_folder_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION unlock_rulefolder(p_rule_folder_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_model_lockable (p_model_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_rulefolder_lockable (p_rule_folder_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_model_editable (p_model_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_ui_def_editable(p_ui_def_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_rulefolder_editable(p_rulefolder_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_structure_editable (p_model_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION has_model_privileges(p_model_id IN NUMBER, p_object_type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_rulefolder_locked(p_rule_folder_id IN NUMBER,p_object_type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_rulefolder_editable(p_rulefolder_id        IN NUMBER,
                                p_object_type          IN VARCHAR2,
                                p_parent_rulefolder_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_model_locked (p_model_id IN NUMBER,p_object_type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_model_locked (p_model_id      IN NUMBER,
                          p_object_type   IN VARCHAR2,
                          p_checkout_user IN VARCHAR2,
                          p_flag IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_model_editable (p_model_id IN NUMBER,p_object_type IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION is_model_editable (p_model_id IN NUMBER,
                            p_object_type IN VARCHAR2,
                            p_checkout_user IN VARCHAR2,
                            p_flag IN VARCHAR2 )
RETURN VARCHAR2;

----->>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION get_user_name(p_user_id IN NUMBER)
RETURN VARCHAR2 ;

FUNCTION get_resp_name (p_user_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE GET_CZ_GRANTS_VIEW;

PROCEDURE GET_CZ_GRANTS_UPDATE (p_entity_id   IN NUMBER,
                                p_entity_type IN VARCHAR2,
                                p_model_id    IN NUMBER,
                                p_priv        IN VARCHAR2,
                                p_user_name   in varchar2,
                                p_role        in varchar2);
FUNCTION get_grant_access(p_model_id IN NUMBER)
RETURN VARCHAR2;

------>>>>>>>>>>>>>>>>>>>>>>>>>>>>
/*
 * This is the public interface for force unlock operations on a model in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_model_id    number.  devl_project_id of the model from cz_devl_projects table
 * @param p_unlock_references   A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              force unlocked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be unlocked
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force unlock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE force_unlock_model (p_api_version        IN NUMBER,
                              p_model_id           IN NUMBER,
                              p_unlock_references  IN VARCHAR2,
                              p_init_msg_list      IN VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2);

/*
 * This is the public interface for lock operations on a model in Oracle Configurator
 * @param p_model_id    number.  devl_project_id of the model from cz_devl_projects table
 * @param p_lock_child_models   A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              locked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be locked
 * @param p_commit_flag A value of FND_API.G_TRUE indicates that the a commit be issued at the end of the
 *          the procedure. A value of FND_API.G_FALSE indicates that no COMMIT is done.
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_locked_entities Contains models locked by this procedure call.
 *         This when passed as an input parameter to unlock_model
 *         API would ensure that only those models that have been locked by the lock API are unlocked.  Models
 *         that were previously locked would not be unlocked (by the same user).  The retaining of the lock state
 *         is done only during implicit locks and not when an unlock is done from developer.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with lock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 *
 * Validations: The lock_model API validates the following:
 *              1. validate input parameters
 *              2. Check for the profile value 'CZ: Require Locking'. If 'Yes' then lock model
 *                 otherwise return a status of 'S'
 *              3. When doing a lock on the model and its children, if any of the model(s)
 *                 are locked by a different user (it is ok to be locked by the same user)
 *                 an exception is raised.
 *                 The error messages are written to the FND stack and there would be one message
 *                 for each model locked by a different user.
 *                 The message would contain the name of the model and the user who locked it.
 *
 * Error reporting: Messages are written to FND error stack.  The caller would have to get all the
 *                  messages from the stack.  No messages are logged to cz_db_logs.
 *
 * Usage
 * lock model and its children  :    cz_security_pvt.lock_model(
 *                             p_model_id => <devl_project_id of the model>,
 *                             p_lock_child_models =>  FND_API.G_TRUE,
 *                             p_commit_flag =>  FND_API.G_TRUE,
 *                             p_init_msg_list => FND_API.G_TRUE,
 *                             x_locked_entities =>  l_locked_entities,
 *                             x_return_status => x_return_status,
 *                             x_msg_count =>   x_msg_count,
 *                             x_msg_data =>   x_msg_data);
 *
 * lock root model only         :    cz_security_pvt.lock_model(
 *                             p_model_id => <devl_project_id of the model>,
 *                             p_lock_child_models =>  FND_API.G_FALSE,
 *                             p_commit_flag =>  FND_API.G_TRUE,
 *                             p_init_msg_list => FND_API.G_TRUE,
 *                             x_locked_entities =>  l_locked_entities,
 *                             x_return_status => x_return_status,
 *                             x_msg_count =>   x_msg_count,
 *                             x_msg_data =>   x_msg_data);
 */

PROCEDURE lock_model(p_api_version            IN NUMBER,
                     p_model_id               IN NUMBER,
                     p_lock_child_models      IN VARCHAR2,
                     p_commit_flag            IN VARCHAR2,
                     p_init_msg_list          IN VARCHAR2,
                     x_locked_entities  OUT NOCOPY number_type_tbl,
                     x_return_status         OUT NOCOPY VARCHAR2,
                     x_msg_count             OUT NOCOPY NUMBER,
                     x_msg_data              OUT NOCOPY VARCHAR2);

/*
 * This is the public interface for unlock operations on a model in Oracle Configurator
 * @param p_model_id    number. devl_project_id of the model from cz_devl_projects table
 * @param p_unlock_child_models A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              unlocked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be unlocked
 * @param p_models_to_unlock would contain an array of model id(s) that have been populated with
 * locked models during the execution of the lock model API.  The unlock_model API will unlock the models
 * in this array only.
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with unlock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 *
 * Usage
 * unlock model and its children  :    cz_security_pvt.unlock_model(
 *                             p_model_id => <devl_project_id of the model>,
 *                             p_unlock_child_models =>  FND_API.G_TRUE,
 *                             p_commit_flag =>  FND_API.G_TRUE,
 *                             p_models_to_unlock =>  l_locked_entities,
 *                             p_init_msg_list => FND_API.G_TRUE,
 *                             x_return_status => x_return_status,
 *                             x_msg_count =>   x_msg_count,
 *                             x_msg_data =>   x_msg_data);
 *
 * unlock root model only         :    cz_security_pvt.unlock_model(
 *                             p_model_id => <devl_project_id of the model>,
 *                             p_unlock_child_models =>  FND_API.G_FALSE,
 *                             p_commit_flag =>  FND_API.G_TRUE,
 *                             p_models_to_unlock =>  l_locked_entities,
 *                             p_init_msg_list => FND_API.G_TRUE,
 *                             x_return_status => x_return_status,
 *                             x_msg_count =>   x_msg_count,
 *                             x_msg_data =>   x_msg_data);
 *
 */

PROCEDURE unlock_model(p_api_version         IN NUMBER,
                       p_commit_flag         IN VARCHAR2,
                       p_models_to_unlock   IN number_type_tbl,
                       p_init_msg_list       IN VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2);

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----for developer
PROCEDURE lock_model(p_api_version       IN NUMBER,
                     p_model_id          IN NUMBER,
                     p_lock_child_models IN VARCHAR2,
                     p_commit_flag       IN VARCHAR2,
                     p_init_msg_list     IN VARCHAR2,
                     x_return_status    OUT NOCOPY VARCHAR2,
                     x_msg_count        OUT NOCOPY NUMBER,
                     x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE unlock_model(p_api_version         IN NUMBER,
                       p_model_id            IN NUMBER,
                       p_commit_flag         IN VARCHAR2,
                       p_init_msg_list       IN VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE lock_template(p_api_version       IN NUMBER,
                        p_template_id       IN NUMBER,
                        p_init_msg_list     IN VARCHAR2,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_count        OUT NOCOPY NUMBER,
                        x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE unlock_template(p_api_version       IN NUMBER,
                          p_template_id       IN NUMBER,
                          p_force_unlock      IN VARCHAR2,
                          p_init_msg_list     IN VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2);

------------->>>>>>>>>>>>>>>>>>>>>>>>>
----Wrappers to be used by Import, Publishing, Logic Gen and UI Gen. Hide the p_init_msg_list parameter.
----The message list is not initialized.

PROCEDURE lock_model(p_api_version            IN NUMBER,
                     p_model_id               IN NUMBER,
                     p_lock_child_models      IN VARCHAR2,
                     p_commit_flag            IN VARCHAR2,
                     x_locked_entities  OUT NOCOPY number_type_tbl,
                     x_return_status         OUT NOCOPY VARCHAR2,
                     x_msg_count             OUT NOCOPY NUMBER,
                     x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE unlock_model(p_api_version         IN NUMBER,
                       p_commit_flag         IN VARCHAR2,
                       p_models_to_unlock IN number_type_tbl,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2);

------------->>>>>>>>>>>>>>>>>>>>>>>>>
/*
 * This is the public interface for force unlock operations on a UI content template in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_template_id number.  Template_id of the template from cz_ui_templates table
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE force_unlock_template (p_api_version    IN NUMBER,
                                 p_template_id    IN NUMBER,
                                 p_init_msg_list  IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2);

/*
 * This is the public interface for lock operations on a UI content template in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_template_id number.  Template_id of the template from cz_ui_templates table
 * @param p_commit_flag A value of FND_API.G_TRUE indicates that the a commit be issued at the end of the
 *          the procedure. A value of FND_API.G_FALSE indicates that no COMMIT is done.
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force lock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE lock_template(p_api_version       IN NUMBER,
                        p_template_id       IN NUMBER,
                        p_commit_flag       IN VARCHAR2,
                        p_init_msg_list     IN VARCHAR2,
                        x_return_status    OUT NOCOPY VARCHAR2,
                        x_msg_count        OUT NOCOPY NUMBER,
                        x_msg_data         OUT NOCOPY VARCHAR2);

/*
 * This is the public interface for lock operations on a UI content template in Oracle Configurator
 * @param p_api_version number.  Current version of the API is 1.0
 * @param p_templates_to_lock array of templates to lock
 * @param p_commit_flag A value of FND_API.G_TRUE indicates that the a commit be issued at the end of the
 *          the procedure. A value of FND_API.G_FALSE indicates that no COMMIT is done.
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_locked_templates templates locked by this procedure
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force lock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */
PROCEDURE lock_template(p_api_version            IN  NUMBER,
                        p_templates_to_lock      IN  cz_security_pvt.number_type_tbl,
                        p_commit_flag            IN  VARCHAR2,
                        p_init_msg_list          IN  VARCHAR2,
                        x_locked_templates       OUT NOCOPY cz_security_pvt.number_type_tbl,
                        x_return_status          OUT NOCOPY VARCHAR2,
                        x_msg_count              OUT NOCOPY NUMBER,
                        x_msg_data               OUT NOCOPY VARCHAR2);


/*
 * This is the public interface for unlock operations on a UI content template in Oracle Configurator
 * @param p_template_id number.  Template_id of the template from cz_ui_templates table
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE unlock_template(p_api_version      IN NUMBER,
                          p_template_id      IN NUMBER,
                          p_init_msg_list    IN VARCHAR2,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2);

/*
 * This is the public interface for unlock operations on a UI content template in Oracle Configurator
 * @param p_templates_to_unlock     array of Template_ids from cz_ui_templates table to unlock
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_SECURITY
 */

PROCEDURE unlock_template(p_api_version IN  NUMBER,
                        p_templates_to_unlock    IN  cz_security_pvt.number_type_tbl,
                        p_commit_flag            IN  VARCHAR2,
                        p_init_msg_list          IN  VARCHAR2,
                        x_return_status          OUT NOCOPY VARCHAR2,
                        x_msg_count              OUT NOCOPY NUMBER,
                        x_msg_data               OUT NOCOPY VARCHAR2);




----------------------------
----procedures for rule import
PROCEDURE unlock_model(p_api_version         IN NUMBER,
                       p_models_to_unlock    IN SYSTEM.CZ_NUMBER_TBL_TYPE,
                       p_commit_flag         IN VARCHAR2,
                       p_init_msg_list       IN VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE unlock_model (p_api_version   IN NUMBER,
		    p_model_id              IN NUMBER,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2);

-------------------------------------------------
-----11.5.10 + Locking only
----
------------------------------------------------
FUNCTION get_locking_profile_value
RETURN VARCHAR2;
-----------------------------

END cz_security_pvt; /* end of package spec */

/
