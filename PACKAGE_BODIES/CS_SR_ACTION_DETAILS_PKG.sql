--------------------------------------------------------
--  DDL for Package Body CS_SR_ACTION_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_ACTION_DETAILS_PKG" as
/* $Header: csxtnadb.pls 120.0 2005/08/12 15:28:48 aneemuch noship $ */

procedure INSERT_ROW (
  PX_EVENT_ACTION_DETAIL_ID in out NOCOPY NUMBER,
  P_EVENT_CONDITION_ID in NUMBER,
  P_RESOLUTION_CODE in VARCHAR2,
  P_INCIDENT_STATUS_ID in NUMBER,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_RELATIONSHIP_TYPE_ID in NUMBER,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_NOTIFICATION_TEMPLATE_ID in VARCHAR2,
  P_ACTION_CODE in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
  CURSOR C2 IS SELECT CS_SR_EVENT_ACTION_DETAILS_S.nextval FROM sys.dual;
  l_object_version_number number := 1;
begin
   If (px_EVENT_ACTION_DETAIL_ID IS NULL) OR (px_EVENT_ACTION_DETAIL_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_EVENT_ACTION_DETAIL_ID;
       CLOSE C2;
   End If;

  insert into CS_SR_ACTION_DETAILS (
    EVENT_ACTION_DETAIL_ID,
    EVENT_CONDITION_ID,
    RESOLUTION_CODE,
    INCIDENT_STATUS_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    RELATIONSHIP_TYPE_ID,
    SEEDED_FLAG,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ACTION_CODE,
    NOTIFICATION_TEMPLATE_ID,
    OBJECT_VERSION_NUMBER
  ) values
    (PX_EVENT_ACTION_DETAIL_ID,
    P_EVENT_CONDITION_ID,
    P_RESOLUTION_CODE,
    P_INCIDENT_STATUS_ID,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_RELATIONSHIP_TYPE_ID,
    P_SEEDED_FLAG,
    P_APPLICATION_ID,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    P_ACTION_CODE,
    P_NOTIFICATION_TEMPLATE_ID,
    L_OBJECT_VERSION_NUMBER
 );
    X_OBJECT_VERSION_NUMBER := l_object_Version_number;
end INSERT_ROW;

procedure LOCK_ROW (
  P_EVENT_ACTION_DETAIL_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
    OBJECT_VERSION_NUMBER
    from CS_SR_ACTION_DETAILS
    where EVENT_ACTION_DETAIL_ID = P_EVENT_ACTION_DETAIL_ID
    for update of EVENT_ACTION_DETAIL_ID nowait;

 l_object_version_number number := 0;
begin
  open c;
  fetch c into l_object_Version_number;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (l_object_version_number = P_OBJECT_VERSION_NUMBER) then
        null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_EVENT_ACTION_DETAIL_ID in NUMBER,
  P_EVENT_CONDITION_ID in NUMBER,
  P_RESOLUTION_CODE in VARCHAR2,
  P_INCIDENT_STATUS_ID in NUMBER,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_RELATIONSHIP_TYPE_ID in NUMBER,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_NOTIFICATION_TEMPLATE_ID in VARCHAR2,
  P_ACTION_CODE in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
  l_object_Version_number number;
begin
  update CS_SR_ACTION_DETAILS set
    RESOLUTION_CODE = P_RESOLUTION_CODE,
    INCIDENT_STATUS_ID = P_INCIDENT_STATUS_ID,
    START_DATE_ACTIVE = P_START_DATE_ACTIVE,
    END_DATE_ACTIVE = P_END_DATE_ACTIVE,
    RELATIONSHIP_TYPE_ID = P_RELATIONSHIP_TYPE_ID,
    SEEDED_FLAG = P_SEEDED_FLAG,
    APPLICATION_ID = P_APPLICATION_ID,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    NOTIFICATION_TEMPLATE_ID = P_NOTIFICATION_TEMPLATE_ID,
    ACTION_CODE = P_ACTION_CODE,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    EVENT_CONDITION_ID = P_EVENT_CONDITION_ID
  where EVENT_ACTION_DETAIL_ID = P_EVENT_ACTION_DETAIL_ID
--  and   ACTION_CODE        = P_ACTION_CODE
  RETURNING OBJECT_VERSION_NUMBER INTO L_OBJECT_VERSION_NUMBER;

  X_OBJECT_VERSION_NUMBER := l_object_version_number;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_EVENT_ACTION_DETAIL_ID in NUMBER
) is
begin
  delete from CS_SR_ACTION_DETAILS
  where EVENT_ACTION_DETAIL_ID = P_EVENT_ACTION_DETAIL_ID;


  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE LOAD_ROW (
  P_EVENT_CONDITION_ID       IN NUMBER,
  P_RESOLUTION_CODE          IN VARCHAR2,
  P_INCIDENT_STATUS_ID       IN NUMBER,
  P_START_DATE_ACTIVE        IN VARCHAR2,
  P_END_DATE_ACTIVE          IN VARCHAR2,
  P_RELATIONSHIP_TYPE_ID     IN NUMBER,
  P_SEEDED_FLAG              IN VARCHAR2,
  P_APPLICATION_ID           IN NUMBER,
  P_NOTIFICATION_TEMPLATE_ID IN VARCHAR2,
  P_ACTION_CODE              IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_CREATION_DATE            IN VARCHAR2,
  P_CREATED_BY               IN NUMBER,
  P_LAST_UPDATE_DATE         IN VARCHAR2,
  P_LAST_UPDATED_BY          IN NUMBER,
  P_LAST_UPDATE_LOGIN        IN NUMBER,
  P_OBJECT_VERSION_NUMBER    IN NUMBER,
  P_EVENT_ACTION_DETAIL_ID   IN NUMBER
)
IS

 -- Out local variables for the update / insert row procedures.
   lx_object_version_number  NUMBER := 0;
   l_user_id                 NUMBER := 0;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_EVENT_ACTION_DETAIL_ID      NUMBER;

BEGIN

   if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if;

   l_EVENT_ACTION_DETAIL_ID := p_EVENT_ACTION_DETAIL_ID;

   UPDATE_ROW (
   P_EVENT_ACTION_DETAIL_ID  =>l_event_action_detail_id,
   P_EVENT_CONDITION_ID      =>p_event_condition_id,
   P_RESOLUTION_CODE         =>p_resolution_code ,
   P_INCIDENT_STATUS_ID      =>p_incident_status_id,
   P_START_DATE_ACTIVE       =>to_date(p_start_date_active,'DD-MM-YYYY'),
   P_END_DATE_ACTIVE         =>to_date(p_end_date_active,'DD-MM-YYYY'),
   P_RELATIONSHIP_TYPE_ID    =>p_relationship_type_id,
   P_SEEDED_FLAG             =>p_seeded_flag,
   P_APPLICATION_ID          =>p_application_id,
   P_NOTIFICATION_TEMPLATE_ID=>p_notification_template_id,
   P_ACTION_CODE             =>p_action_code,
   P_LAST_UPDATE_DATE        =>nvl(to_date(p_last_update_date,'DD-MM-YYYY'),sysdate),
   P_LAST_UPDATED_BY         =>l_user_id,
   P_LAST_UPDATE_LOGIN       =>0,
   X_OBJECT_VERSION_NUMBER   =>lx_object_version_number
);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
      PX_EVENT_ACTION_DETAIL_ID =>l_event_action_detail_id,
      P_EVENT_CONDITION_ID      =>p_event_condition_id,
      P_RESOLUTION_CODE         =>p_resolution_code ,
      P_INCIDENT_STATUS_ID      =>p_incident_status_id,
      P_START_DATE_ACTIVE       =>to_date(p_start_date_active,'DD-MM-YYYY'),
      P_END_DATE_ACTIVE         =>to_date(p_end_date_active,'DD-MM-YYYY'),
      P_RELATIONSHIP_TYPE_ID    =>p_relationship_type_id,
      P_SEEDED_FLAG             =>p_seeded_flag,
      P_APPLICATION_ID          =>p_application_id,
      P_NOTIFICATION_TEMPLATE_ID=>p_notification_template_id,
      P_ACTION_CODE             =>p_action_code,
      P_CREATION_DATE           =>nvl(to_date( p_creation_date,
                                              'DD-MM-YYYY'),sysdate),
      P_CREATED_BY              =>l_user_id,

      P_LAST_UPDATE_DATE        =>nvl(to_date(p_last_update_date,
                                              'DD-MM-YYYY'),sysdate),
      P_LAST_UPDATED_BY         =>l_user_id,
      P_LAST_UPDATE_LOGIN       =>0,
      X_OBJECT_VERSION_NUMBER   =>lx_object_version_number
);

END LOAD_ROW;

end CS_SR_ACTION_DETAILS_PKG;

/
