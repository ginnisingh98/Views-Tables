--------------------------------------------------------
--  DDL for Package Body IEU_UWQM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQM_PUB" AS
/* $Header: IEUPUMTB.pls 115.17 2003/11/13 22:35:08 ckurian ship $ */

-- *******
--
-- Status_id : 0 - open , 1 - Locked, 2 - WIP , 3 - Closed, 4 - Delete
--
-- *******

PROCEDURE CREATE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_number          IN VARCHAR2,
  p_title		      IN VARCHAR2,
  p_party_id    	      IN NUMBER,
  p_priority_code             IN VARCHAR2,
  p_due_date		      IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_ieu_enum_type_uuid        IN VARCHAR2,
  p_work_status_flag          IN VARCHAR2,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_work_item_id	      OUT NOCOPY NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'CREATE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code  VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_source_object_type_code VARCHAR2(30);
  l_source_object_id   NUMBER;

  l_owner_id           NUMBER;
  l_assignee_id        NUMBER;
  l_owner_type         VARCHAR2(25);
  l_assignee_type      VARCHAR2(25);

  l_owner_type_actual  VARCHAR2(30);
  l_assignee_type_actual VARCHAR2(30);

  l_priority_id        NUMBER;
  l_priority_level     NUMBER;
  l_status_id          NUMBER := 0;
  l_title_len          NUMBER := 1990;

  l_status_update_user_id  NUMBER;

  l_msg_data          VARCHAR2(4000);

BEGIN

  null;

END CREATE_UWQM_ITEM;

PROCEDURE UPDATE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code 	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_title		              IN VARCHAR2,
  p_party_id    	          IN NUMBER,
  p_priority_code             IN VARCHAR2,
  p_due_date		          IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	          IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
--  p_ieu_enum_type_uuid        IN VARCHAR2 DEFAULT fnd_api.g_miss_char,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version  NUMBER        := 1.0;
  l_api_name     VARCHAR2(30)  := 'UPDATE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_owner_id           NUMBER;
  l_assignee_id        NUMBER;
  l_owner_type         VARCHAR2(25);
  l_assignee_type      VARCHAR2(25);
  l_priority_id        NUMBER;
  l_priority_level     NUMBER;
  l_status_id          NUMBER := 0;
  l_title_len          NUMBER := 1990;

  l_source_object_type_code VARCHAR2(30);
  l_source_object_id   NUMBER;

  l_owner_type_actual  VARCHAR2(30);
  l_assignee_type_actual VARCHAR2(30);

  l_msg_data           VARCHAR2(4000);


BEGIN

  null;

END UPDATE_UWQM_ITEM;


PROCEDURE OPEN_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'OPEN_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;

  l_status_update_user_id VARCHAR2(30);

BEGIN
  null;
END OPEN_UWQM_ITEM;


PROCEDURE USE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_work_item_id             OUT NOCOPY NUMBER,
  x_work_item_status         OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'USE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;

  l_resource_name      VARCHAR2(30);
  l_status_update_user_id     NUMBER;

BEGIN
  null;
END USE_UWQM_ITEM;

PROCEDURE RELEASE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code 	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'RELEASE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_work_item_id       NUMBER;
  l_workitem_obj_code  VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;

  l_old_status_update_user_id NUMBER;
  l_new_status_update_user_id NUMBER;

  l_miss_workitem_id_flag   NUMBER(1) := 0;
  l_miss_workitem_obj_code_flag NUMBER(1) := 0;

BEGIN

  null;
END RELEASE_UWQM_ITEM;

PROCEDURE CLOSE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'CLOSE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;
  l_status_update_user_id     NUMBER;

BEGIN

  null;

END CLOSE_UWQM_ITEM;

PROCEDURE DELETE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'DELETE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;
  l_status_update_user_id     NUMBER;

BEGIN
  null;
END DELETE_UWQM_ITEM;

PROCEDURE RESCHEDULE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code 	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER,
  p_reschedule_time           IN DATE,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'RESCHEDULE_UWQM_ITEM';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_work_item_id       NUMBER;
  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;

  l_old_status_update_user_id NUMBER;
  l_new_status_update_user_id NUMBER;

  l_miss_workitem_id_flag   NUMBER(1) := 0;
  l_miss_workitem_obj_code_flag NUMBER(1) := 0;

BEGIN
  null;
END RESCHEDULE_UWQM_ITEM;


PROCEDURE GET_UWQM_ITEM_WORK_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_work_item_status         OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) AS

  l_api_version  CONSTANT NUMBER        := 1.0;
  l_api_name     CONSTANT VARCHAR2(30)  := 'GET_UWQM_ITEM_WORK_STATUS';

  l_miss_param_flag    NUMBER(1) := 0;
  l_token_str          VARCHAR2(4000) := '';
  l_param_valid_flag   NUMBER(1) := 0;

  l_work_item_id       NUMBER;
  l_workitem_obj_code        VARCHAR2(30);
  l_object_function    VARCHAR2(30);
  l_status_id          NUMBER := 0;
  l_lookup_code        VARCHAR2(30);
  l_status             VARCHAR2(30);

  l_miss_workitem_id_flag   NUMBER(1) := 0;
  l_miss_workitem_obj_code_flag NUMBER(1) := 0;

BEGIN

  null;
END GET_UWQM_ITEM_WORK_STATUS;

END IEU_UWQM_PUB;

/
