--------------------------------------------------------
--  DDL for Package Body CS_SR_EVENT_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_EVENT_CODES_PKG" as
/* $Header: csxtnevb.pls 115.2 2003/02/28 08:05:37 pkesani noship $ */
procedure INSERT_ROW (
  PX_EVENT_CODE in out NOCOPY VARCHAR2,
  P_RELATIONSHIP_TYPE in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_WF_BUSINESS_EVENT_ID in VARCHAR2,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_FROM_TO_STATUS in VARCHAR2,
  P_INCIDENT_STATUS in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
 l_object_version_number NUMBER := 1;
begin
  insert into CS_SR_EVENT_CODES_B (
    RELATIONSHIP_TYPE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    WF_BUSINESS_EVENT_ID,
    SEEDED_FLAG,
    APPLICATION_ID,
    OBJECT_VERSION_NUMBER,
    FROM_TO_STATUS,
    INCIDENT_STATUS,
    EVENT_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_RELATIONSHIP_TYPE,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_WF_BUSINESS_EVENT_ID,
    P_SEEDED_FLAG,
    P_APPLICATION_ID,
    l_object_version_number,
    P_FROM_TO_STATUS,
    P_INCIDENT_STATUS,
    Px_EVENT_CODE,
    Decode(P_CREATION_DATE,NULL,SYSDATE,P_CREATION_DATE),
    P_CREATED_BY,
    Decode(P_LAST_UPDATE_DATE,NULL,SYSDATE,P_LAST_UPDATE_DATE),
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  insert into CS_SR_EVENT_CODES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    EVENT_CODE,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    PX_EVENT_CODE,
    P_NAME,
    P_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_SR_EVENT_CODES_TL T
    where T.EVENT_CODE = PX_EVENT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

 x_object_version_number := l_object_version_number;
end INSERT_ROW;

procedure LOCK_ROW (
  P_EVENT_CODE in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from CS_SR_EVENT_CODES_VL
    where EVENT_CODE = P_EVENT_CODE
    for update of EVENT_CODE nowait;
  recinfo c%rowtype;

   l_object_Version_number number := 0;
begin
  open c;
  fetch c into l_object_version_number;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if  (l_OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  P_EVENT_CODE in VARCHAR2,
  P_RELATIONSHIP_TYPE in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_WF_BUSINESS_EVENT_ID in VARCHAR2,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_FROM_TO_STATUS in VARCHAR2,
  P_INCIDENT_STATUS in VARCHAR2,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER
) is
	l_object_Version_number number;
begin
  update CS_SR_EVENT_CODES_B set
    RELATIONSHIP_TYPE = P_RELATIONSHIP_TYPE,
    START_DATE_ACTIVE = P_START_DATE_ACTIVE,
    END_DATE_ACTIVE = P_END_DATE_ACTIVE,
    WF_BUSINESS_EVENT_ID = P_WF_BUSINESS_EVENT_ID,
    SEEDED_FLAG = P_SEEDED_FLAG,
    APPLICATION_ID = P_APPLICATION_ID,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    FROM_TO_STATUS = P_FROM_TO_STATUS,
    INCIDENT_STATUS = P_INCIDENT_STATUS,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where EVENT_CODE = P_EVENT_CODE
  RETURNING OBJECT_VERSION_NUMBER INTO L_OBJECT_VERSION_NUMBER;

  X_OBJECT_VERSION_NUMBER := l_object_version_number;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_SR_EVENT_CODES_TL set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where EVENT_CODE = P_EVENT_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_EVENT_CODE in VARCHAR2
) is
begin
  delete from CS_SR_EVENT_CODES_TL
  where EVENT_CODE = P_EVENT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_SR_EVENT_CODES_B
  where EVENT_CODE = P_EVENT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_SR_EVENT_CODES_TL T
  where not exists
    (select NULL
    from CS_SR_EVENT_CODES_B B
    where B.EVENT_CODE = T.EVENT_CODE
    );

  update CS_SR_EVENT_CODES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_SR_EVENT_CODES_TL B
    where B.EVENT_CODE = T.EVENT_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EVENT_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.EVENT_CODE,
      SUBT.LANGUAGE
    from CS_SR_EVENT_CODES_TL SUBB, CS_SR_EVENT_CODES_TL SUBT
    where SUBB.EVENT_CODE = SUBT.EVENT_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_SR_EVENT_CODES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    EVENT_CODE,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.EVENT_CODE,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_SR_EVENT_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_SR_EVENT_CODES_TL T
    where T.EVENT_CODE = B.EVENT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
  P_EVENT_CODE                 IN VARCHAR2,
  P_RELATIONSHIP_TYPE          IN VARCHAR2,
  P_START_DATE_ACTIVE          IN VARCHAR2,
  P_END_DATE_ACTIVE            IN VARCHAR2,
  P_WF_BUSINESS_EVENT_ID       IN VARCHAR2,
  P_SEEDED_FLAG                IN VARCHAR2,
  P_APPLICATION_ID             IN NUMBER,
  P_FROM_TO_STATUS             IN VARCHAR2,
  P_INCIDENT_STATUS            IN VARCHAR2,
  P_NAME                       IN VARCHAR2,
  P_DESCRIPTION                IN VARCHAR2,
  P_OWNER                      IN VARCHAR2,
  P_CREATION_DATE              IN VARCHAR2,
  P_CREATED_BY                 IN NUMBER,
  P_LAST_UPDATE_DATE           IN VARCHAR2,
  P_LAST_UPDATED_BY            IN NUMBER,
  P_LAST_UPDATE_LOGIN          IN NUMBER,
  P_OBJECT_VERSION_NUMBER      IN NUMBER )

IS

 -- Out local variables for the update / insert row procedures.
   lx_object_version_number  NUMBER := 0;
   l_user_id                 NUMBER := 0;

   -- needed to be passed as the parameter value for the insert's in/out
   -- parameter.
   l_event_code              VARCHAR2(30);

BEGIN

   if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if;

   l_event_code := p_event_code;

   UPDATE_ROW (
       P_EVENT_CODE                 =>l_event_code,
       P_RELATIONSHIP_TYPE          =>p_relationship_type,
       P_START_DATE_ACTIVE          =>to_date(p_start_date_active,'DD-MM-YYYY'),
       P_END_DATE_ACTIVE            =>to_date(p_end_date_active,'DD-MM-YYYY'),
       P_WF_BUSINESS_EVENT_ID       =>P_WF_BUSINESS_EVENT_ID,
       P_SEEDED_FLAG                =>p_seeded_flag,
       P_APPLICATION_ID             =>p_application_id,
       P_FROM_TO_STATUS             =>p_from_to_status,
       P_INCIDENT_STATUS            =>p_incident_status,
       P_NAME                       =>p_name,
       P_DESCRIPTION                =>p_description,
       P_LAST_UPDATE_DATE           =>nvl(to_date(p_last_update_date,
                                                 'DD-MM-YYYY'),sysdate),
       P_LAST_UPDATED_BY            =>l_user_id,
       P_LAST_UPDATE_LOGIN          =>0,
       X_OBJECT_VERSION_NUMBER      =>lx_object_version_number
   );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
        PX_EVENT_CODE               =>l_event_code,
        P_RELATIONSHIP_TYPE         =>p_relationship_type,
        P_START_DATE_ACTIVE         =>to_date(p_start_date_active,'DD-MM-YYYY'),
        P_END_DATE_ACTIVE           =>to_date(p_end_date_active,'DD-MM-YYYY'),
        P_WF_BUSINESS_EVENT_ID      =>P_WF_BUSINESS_EVENT_ID,
        P_SEEDED_FLAG               =>p_seeded_flag,
        P_APPLICATION_ID            =>p_application_id,
        P_FROM_TO_STATUS            =>p_from_to_status,
        P_INCIDENT_STATUS           =>p_incident_status,
        P_NAME                      =>p_name,
        P_DESCRIPTION               =>p_description,
        P_CREATION_DATE             =>nvl(to_date( p_creation_date,
                                                  'DD-MM-YYYY'),sysdate),
        P_CREATED_BY                =>l_user_id,
        P_LAST_UPDATE_DATE          =>nvl(to_date( p_last_update_date,
                                                  'DD-MM-YYYY'),sysdate),
        P_LAST_UPDATED_BY           =>l_user_id,
        P_LAST_UPDATE_LOGIN         =>0,
        X_OBJECT_VERSION_NUMBER     =>lx_object_version_number
       );

END LOAD_ROW;

procedure TRANSLATE_ROW ( X_EVENT_CODE  in  varchar2,
                          X_NAME in varchar2,
                          X_DESCRIPTION  in varchar2,
                          X_LAST_UPDATE_DATE in date,
                          X_LAST_UPDATE_LOGIN in number,
                          X_OWNER in varchar2)
is

l_user_id  number;

begin

if X_OWNER = 'SEED' then
  l_user_id := 1;
else
  l_user_id := 0;
end if;

update CS_SR_EVENT_CODES_TL set
 name = nvl(x_name,name),
 description = nvl(x_description,name),
 last_update_date = nvl(x_last_update_date,sysdate),
 last_updated_by = l_user_id,
 last_update_login = 0,
 source_lang = userenv('LANG')
 where event_code = x_event_code
 and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

end CS_SR_EVENT_CODES_PKG;

/
