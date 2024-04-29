--------------------------------------------------------
--  DDL for Package Body CS_SR_EVENT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_EVENT_ACTIONS_PKG" as
/* $Header: csxtneab.pls 120.0 2005/08/12 15:29:53 aneemuch noship $ */
procedure INSERT_ROW (
  PX_EVENT_CODE in out NOCOPY VARCHAR2,
  PX_ACTION_CODE in out NOCOPY VARCHAR2,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
  l_object_Version_number number := 1;
begin
  insert into CS_SR_EVENT_ACTIONS (
    EVENT_CODE,
    ACTION_CODE,
    SEEDED_FLAG,
    APPLICATION_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    PX_EVENT_CODE,
    PX_ACTION_CODE,
    P_SEEDED_FLAG,
    P_APPLICATION_ID,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    L_OBJECT_VERSION_NUMBER);

  x_object_version_number := l_object_version_number;

end INSERT_ROW;

procedure LOCK_ROW (
  P_EVENT_CODE in VARCHAR2,
  P_ACTION_CODE in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from CS_SR_EVENT_ACTIONS
    where EVENT_CODE = P_EVENT_CODE
    and ACTION_CODE = P_ACTION_CODE
    for update of EVENT_CODE nowait;

   l_object_Version_number number := 0;

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
  P_EVENT_CODE in VARCHAR2,
  P_ACTION_CODE in VARCHAR2,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
begin
  update CS_SR_EVENT_ACTIONS set
    SEEDED_FLAG = P_SEEDED_FLAG,
    APPLICATION_ID = P_APPLICATION_ID,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    START_DATE_ACTIVE = P_START_DATE_ACTIVE,
    END_DATE_ACTIVE = P_END_DATE_ACTIVE,
    EVENT_CODE = P_EVENT_CODE,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where EVENT_CODE = P_EVENT_CODE
  and ACTION_CODE = P_ACTION_CODE
  RETURNING OBJECT_VERSION_NUMBER INTO X_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_EVENT_CODE in VARCHAR2,
  P_ACTION_CODE in VARCHAR2
) is
begin
  delete from CS_SR_EVENT_ACTIONS
  where EVENT_CODE = P_EVENT_CODE
  and ACTION_CODE = P_ACTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE LOAD_ROW (
  P_EVENT_CODE                 IN VARCHAR2,
  P_ACTION_CODE                IN VARCHAR2,
  P_SEEDED_FLAG                IN VARCHAR2,
  P_APPLICATION_ID             IN NUMBER,
  P_START_DATE_ACTIVE          IN VARCHAR2,
  P_END_DATE_ACTIVE            IN VARCHAR2,
  P_OWNER                      IN VARCHAR2,
  P_CREATION_DATE              IN VARCHAR2,
  P_CREATED_BY                 IN NUMBER,
  P_LAST_UPDATE_DATE           IN VARCHAR2,
  P_LAST_UPDATED_BY            IN NUMBER,
  P_LAST_UPDATE_LOGIN          IN NUMBER,
  P_OBJECT_VERSION_NUMBER      IN NUMBER
)

IS
 -- Out local variables for the update / insert row procedures.
   lx_object_version_number  NUMBER := 0;
   l_user_id                 NUMBER := 0;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_action_code             VARCHAR2(30);
   l_event_code              VARCHAR2(30);

BEGIN

   if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if;

   l_action_code        := p_action_code;
   l_event_code         := p_event_code;

   UPDATE_ROW (
     P_EVENT_CODE                 =>l_event_code,
     P_ACTION_CODE                =>l_action_code,
     P_SEEDED_FLAG                =>p_seeded_flag,
     P_APPLICATION_ID             =>p_application_id,
     P_START_DATE_ACTIVE          =>to_date(p_start_date_active,'DD-MM-YYYY'),
     P_END_DATE_ACTIVE            =>to_date(p_end_date_active,'DD-MM-YYYY'),
     P_LAST_UPDATE_DATE           =>nvl(to_date(p_last_update_date,
                                                'DD-MM-YYYY'),sysdate),
     P_LAST_UPDATED_BY            =>l_user_id,
     P_LAST_UPDATE_LOGIN          =>0,
     X_OBJECT_VERSION_NUMBER      =>lx_object_version_number
     );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
         PX_EVENT_CODE            =>l_event_code,
         PX_ACTION_CODE           =>l_action_code,
         P_SEEDED_FLAG            =>p_seeded_flag,
         P_APPLICATION_ID         =>p_application_id,
         P_START_DATE_ACTIVE      =>to_date(p_start_date_active,'DD-MM-YYYY'),
         P_END_DATE_ACTIVE        =>to_date(p_end_date_active,'DD-MM-YYYY'),
         P_CREATION_DATE          =>nvl(to_date( p_creation_date,
                                                'DD-MM-YYYY'),sysdate),
         P_CREATED_BY             =>l_user_id,
         P_LAST_UPDATE_DATE       =>nvl(to_date( p_last_update_date,
                                                'DD-MM-YYYY'),sysdate),
         P_LAST_UPDATED_BY        =>l_user_id,
         P_LAST_UPDATE_LOGIN      =>0,
         X_OBJECT_VERSION_NUMBER  =>lx_object_version_number
         );

END LOAD_ROW;

end CS_SR_EVENT_ACTIONS_PKG;

/
