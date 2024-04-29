--------------------------------------------------------
--  DDL for Package Body IEU_WR_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WR_ITEMS_PKG" as
/* $Header: IEUVUWRB.pls 120.0 2005/06/02 15:42:25 appldev noship $ */

procedure INSERT_ROW
( p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_number          IN VARCHAR2,
  p_title		            IN VARCHAR2,
  p_party_id    	            IN NUMBER,
  p_priority_id        	      IN NUMBER,
  p_priority_level            IN NUMBER,
  p_due_date		      IN DATE,
  p_work_item_status_id       IN NUMBER,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_owner_type_actual         IN VARCHAR2,
  p_assignee_type_actual      IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_ieu_enum_type_uuid        IN VARCHAR2,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  p_work_source_id            IN NUMBER,
  p_distribution_status_id       IN NUMBER,
  x_work_item_id	            OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2
)  is

begin

   begin
       x_return_status := fnd_api.g_ret_sts_success;
       INSERT INTO IEU_UWQM_ITEMS
       ( WORK_ITEM_ID,
         OBJECT_VERSION_NUMBER,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         WORKITEM_OBJ_CODE,
         WORKITEM_PK_ID,
         WORK_ITEM_NUMBER,
         STATUS_ID,
         PRIORITY_ID,
         PRIORITY_LEVEL,
         DUE_DATE,
         TITLE,
         PARTY_ID,
         OWNER_ID,
         OWNER_TYPE,
         ASSIGNEE_ID,
         ASSIGNEE_TYPE,
         OWNER_TYPE_ACTUAL,
         ASSIGNEE_TYPE_ACTUAL,
         SOURCE_OBJECT_ID,
         SOURCE_OBJECT_TYPE_CODE,
         APPLICATION_ID,
         IEU_ENUM_TYPE_UUID,
         RESCHEDULE_TIME,
         STATUS_UPDATE_USER_ID,
         WS_ID,
         DISTRIBUTION_STATUS_ID
        )
       VALUES
       ( IEU_UWQM_ITEMS_S1.NEXTVAL,
         1,
         P_USER_ID,
         SYSDATE,
         P_USER_ID,
         SYSDATE,
         P_LOGIN_ID,
         p_WORKITEM_OBJ_CODE,
         p_workitem_pk_id,
         p_work_item_number,
         p_work_item_status_id,
         p_priority_id,
         p_priority_level,
         p_due_date,
         p_title,
         p_party_id,
         p_owner_id,
         p_owner_type,
         p_assignee_id,
         p_assignee_type,
         p_owner_type_actual,
         p_assignee_type_actual,
         p_source_object_id,
         p_source_object_type_code,
         p_application_id,
         p_ieu_enum_type_uuid,
         sysdate,
         p_user_id,
         p_work_source_id,
         p_distribution_status_id
        ) RETURNING WORK_ITEM_ID INTO X_WORK_ITEM_ID;

   exception
     when others then
      --dbms_output.put_line('err while inserting : '||sqlcode||' - '||sqlerrm);
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := sqlerrm;
   end;

end INSERT_ROW;

procedure UPDATE_ROW
( p_WORKITEM_OBJ_CODE  	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_title		            IN VARCHAR2,
  p_party_id    	            IN NUMBER,
  p_priority_id        	      IN NUMBER,
  p_priority_level            IN NUMBER,
  p_due_date		      IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_owner_type_actual         IN VARCHAR2,
  p_assignee_type_actual      IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_work_item_status_id       IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  p_work_source_id            IN NUMBER,
  p_distribution_status_id       IN NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2

) is

begin

     x_return_status := fnd_api.g_ret_sts_success;

     UPDATE IEU_UWQM_ITEMS
     SET
       CREATED_BY            =  P_USER_ID,
       CREATION_DATE         =  SYSDATE,
       LAST_UPDATED_BY       =  P_USER_ID,
       LAST_UPDATE_DATE      =  SYSDATE,
       LAST_UPDATE_LOGIN     =  P_LOGIN_ID,
       OBJECT_VERSION_NUMBER =  OBJECT_VERSION_NUMBER + 1,
       TITLE                 =  P_TITLE,
       PARTY_ID              =  P_PARTY_ID,
       PRIORITY_LEVEL        =  P_PRIORITY_LEVEL,
       PRIORITY_ID           =  P_PRIORITY_ID,
       DUE_DATE              =  P_DUE_DATE,
       OWNER_ID              =  P_OWNER_ID,
       OWNER_TYPE            =  P_OWNER_TYPE,
       ASSIGNEE_ID           =  P_ASSIGNEE_ID,
       ASSIGNEE_TYPE         =  P_ASSIGNEE_TYPE,
       OWNER_TYPE_ACTUAL     =  P_OWNER_TYPE_ACTUAL,
       ASSIGNEE_TYPE_ACTUAL  =  P_ASSIGNEE_TYPE_ACTUAL,
       SOURCE_OBJECT_ID      =  P_SOURCE_OBJECT_ID,
       SOURCE_OBJECT_TYPE_CODE = P_SOURCE_OBJECT_TYPE_CODE,
       APPLICATION_ID        =  P_APPLICATION_ID,
       STATUS_ID             =  P_WORK_ITEM_STATUS_ID,
       WS_ID                 =  P_WORK_SOURCE_ID,
       DISTRIBUTION_STATUS_ID =  P_DISTRIBUTION_STATUS_ID
     WHERE  WORKITEM_OBJ_CODE       =  P_WORKITEM_OBJ_CODE
     AND    WORKITEM_PK_ID          =  P_WORKITEM_PK_ID;

   if (sql%notfound) then
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'Work Item does not exist in UWQ Metaphor table';
   end if;

exception
  when others then
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := sqlerrm;

end UPDATE_ROW;

PROCEDURE LOAD_ROW
( p_workitem_obj_code  	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_number          IN VARCHAR2,
  p_title		      IN VARCHAR2,
  p_party_id    	      IN NUMBER,
  p_priority_id        	      IN NUMBER,
  p_priority_level            IN NUMBER,
  p_due_date		      IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_owner_type_actual         IN VARCHAR2,
  p_assignee_type_actual      IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_work_item_status_id       IN NUMBER,
  p_ieu_enum_type_uuid        IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  p_work_source_id            IN NUMBER,
  p_distribution_status_id       IN NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2

) is

x_work_item_id NUMBER;
l_status_id  NUMBER := 0;

 begin

  x_return_status := fnd_api.g_ret_sts_success;

  IEU_WR_ITEMS_PKG.UPDATE_ROW
       ( p_WORKITEM_OBJ_CODE,
         p_workitem_pk_id,
         p_title,
         p_party_id,
         p_priority_id,
         p_priority_level,
         p_due_date,
         p_owner_id,
         p_owner_type,
         p_assignee_id,
         p_assignee_type,
         p_owner_type_actual,
         p_assignee_type_actual,
         p_source_object_id,
         p_source_object_type_code,
         p_application_id,
         p_work_item_status_id,
         p_user_id,
         p_login_id,
         p_work_source_id,
         p_distribution_status_id,
  --       p_ieu_enum_type_uuid,
         x_msg_data,
         x_return_status
       );

     if (sql%notfound) then
        raise no_data_found;
     end if;
   Exception
     when no_data_found then
      IEU_WR_ITEMS_PKG.INSERT_ROW
       ( p_workitem_obj_code,
         p_workitem_pk_id,
         p_work_item_number,
         p_title,
         p_party_id,
         p_priority_id,
         p_priority_level,
         p_due_date,
         p_work_item_status_id,
         p_owner_id,
         p_owner_type,
         p_assignee_id,
         p_assignee_type,
         p_owner_type_actual,
         p_assignee_type_actual,
         p_source_object_id,
         p_source_object_type_code,
         p_application_id,
         p_ieu_enum_type_uuid,
         p_user_id,
         p_login_id,
         p_work_source_id,
         p_distribution_status_id,
         x_work_item_id,
         x_msg_data,
         x_return_status
       );
END LOAD_ROW;

procedure DELETE_ROW
( p_workitem_obj_code  	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2
) IS

l_message          VARCHAR2(4000);

begin
  l_message   := '';
  x_return_status := fnd_api.g_ret_sts_success;

  delete from IEU_UWQM_ITEMS
  where WORKITEM_OBJ_CODE = P_WORKITEM_OBJ_CODE
    and WORKITEM_PK_ID = P_WORKITEM_PK_ID;

   if (sql%notfound) then

       x_return_status := fnd_api.g_ret_sts_error;

       FND_MESSAGE.SET_NAME('IEU', 'IEU_WP_NO_FOUND');
       l_message := FND_MESSAGE.GET;

       RAISE fnd_api.g_exc_error;
   end if;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN

       x_return_status := fnd_api.g_ret_sts_error;
       x_msg_data := l_message;

end DELETE_ROW;

procedure UPDATE_STATUS_FLAG
( p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER default null,
  p_status_update_user_id     IN NUMBER,
  p_status_id                 IN NUMBER,
--  p_reschedule_time                IN DATE    DEFAULT NULL,
  x_return_status             OUT NOCOPY VARCHAR2
) IS

begin

  x_return_status := fnd_api.g_ret_sts_success;

  IF ( p_work_item_id is not null)
  THEN
     UPDATE IEU_UWQM_ITEMS
     SET    status_id = p_status_id,
            status_update_user_id = p_status_update_user_id
 --           reschedule_time = nvl(p_reschedule_time, sysdate)
     WHERE  WORK_ITEM_ID = P_WORK_ITEM_ID;
  ELSE
--IF ( ( p_workitem_obj_code is not null) and ( p_work_item_id is not null) )
     UPDATE IEU_UWQM_ITEMS
     SET    status_id = p_status_id,
            status_update_user_id = p_status_update_user_id
--            reschedule_time = nvl(p_reschedule_time, sysdate)
     WHERE  WORKITEM_OBJ_CODE = P_WORKITEM_OBJ_CODE
     AND    WORKITEM_PK_ID = P_WORKITEM_PK_ID;
   END IF;

   if (sql%notfound) then
      x_return_status := fnd_api.g_ret_sts_error;
   end if;

end UPDATE_STATUS_FLAG;
end IEU_WR_ITEMS_PKG;

/
