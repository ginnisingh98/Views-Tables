--------------------------------------------------------
--  DDL for Package Body CS_SR_ACTION_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_ACTION_CODES_PKG" as
/* $Header: csxtnacb.pls 115.3 2003/02/28 07:55:42 pkesani noship $ */

procedure INSERT_ROW (
  PX_ACTION_CODE 	  	 	   in out NOCOPY VARCHAR2,
  P_NOTIFICATION_TEMPLATE_NAME in VARCHAR2,
  P_NEW_STATUS 				   in VARCHAR2,
  P_SEEDED_FLAG 			   in VARCHAR2,
  P_RELATIONSHIP_TYPE 		   in VARCHAR2,
  P_NEW_RESOLUTION_CODE 	   in VARCHAR2,
  P_START_DATE_ACTIVE 		   in DATE,
  P_END_DATE_ACTIVE 		   in DATE,
  P_APPLICATION_ID 			   in NUMBER,
  P_NAME 					   in VARCHAR2,
  P_DESCRIPTION 			   in VARCHAR2,
  P_CREATION_DATE 			   in DATE,
  P_CREATED_BY 				   in NUMBER,
  P_LAST_UPDATE_DATE 		   in DATE,
  P_LAST_UPDATED_BY 		   in NUMBER,
  P_LAST_UPDATE_LOGIN 		   in NUMBER,
  X_OBJECT_VERSION_NUMBER Out NOCOPY NUMBER
) is
 l_object_version_number NUMBER := 1;
begin
  insert into CS_SR_ACTION_CODES_B (
    ACTION_CODE,
    NOTIFICATION_TEMPLATE_NAME,
    NEW_STATUS,
    SEEDED_FLAG,
    RELATIONSHIP_TYPE,
    NEW_RESOLUTION_CODE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    APPLICATION_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    PX_ACTION_CODE,
    P_NOTIFICATION_TEMPLATE_NAME,
    P_NEW_STATUS,
    P_SEEDED_FLAG,
    P_RELATIONSHIP_TYPE,
    P_NEW_RESOLUTION_CODE,
    P_START_DATE_ACTIVE,
    P_END_DATE_ACTIVE,
    P_APPLICATION_ID,
    l_OBJECT_VERSION_NUMBER,
    decode(P_CREATION_DATE,NULL,SYSDATE,P_CREATION_DATE),
    P_CREATED_BY,
    decode(P_LAST_UPDATE_DATE,NULL,SYSDATE,P_LAST_UPDATE_DATE),
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
   ) ;

  insert into CS_SR_ACTION_CODES_TL (
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ACTION_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_NAME,
    P_DESCRIPTION,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    PX_ACTION_CODE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CS_SR_ACTION_CODES_TL T
    where T.ACTION_CODE = PX_ACTION_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

     X_OBJECT_VERSION_NUMBER := l_object_Version_number;
end INSERT_ROW;

procedure LOCK_ROW (
  P_ACTION_CODE 	  in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from CS_SR_ACTION_CODES_VL
    where ACTION_CODE 		= P_ACTION_CODE
    for update of ACTION_CODE nowait;

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
  P_ACTION_CODE 	  			  in VARCHAR2,
  P_NOTIFICATION_TEMPLATE_NAME 	  in VARCHAR2,
  P_NEW_STATUS 					  in VARCHAR2,
  P_SEEDED_FLAG					  in VARCHAR2,
  P_RELATIONSHIP_TYPE 			  in VARCHAR2,
  P_NEW_RESOLUTION_CODE 		  in VARCHAR2,
  P_START_DATE_ACTIVE 			  in DATE,
  P_END_DATE_ACTIVE 			  in DATE,
  P_APPLICATION_ID 				  in NUMBER,
  P_NAME 						  in VARCHAR2,
  P_DESCRIPTION 				  in VARCHAR2,
  P_LAST_UPDATE_DATE 			  in DATE,
  P_LAST_UPDATED_BY 			  in NUMBER,
  P_LAST_UPDATE_LOGIN 			  in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
) is
l_object_Version_number number;
begin
  update CS_SR_ACTION_CODES_B set
    NOTIFICATION_TEMPLATE_NAME  = P_NOTIFICATION_TEMPLATE_NAME,
    NEW_STATUS 					= P_NEW_STATUS,
    SEEDED_FLAG 	        = P_SEEDED_FLAG,
    RELATIONSHIP_TYPE 		= P_RELATIONSHIP_TYPE,
    NEW_RESOLUTION_CODE 	= P_NEW_RESOLUTION_CODE,
    START_DATE_ACTIVE 		= P_START_DATE_ACTIVE,
    END_DATE_ACTIVE 		= P_END_DATE_ACTIVE,
    APPLICATION_ID 			= P_APPLICATION_ID,
    OBJECT_VERSION_NUMBER 	= OBJECT_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE 		= P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 		= P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 		= P_LAST_UPDATE_LOGIN
  where ACTION_CODE 		= P_ACTION_CODE
  RETURNING OBJECT_VERSION_NUMBER INTO L_OBJECT_VERSION_NUMBER;

  X_OBJECT_VERSION_NUMBER := l_object_version_number;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CS_SR_ACTION_CODES_TL set
    NAME 		= P_NAME,
    DESCRIPTION 	= P_DESCRIPTION,
    LAST_UPDATE_DATE 	= P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY 	= P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN 	= P_LAST_UPDATE_LOGIN,
    SOURCE_LANG 	= userenv('LANG')
  where ACTION_CODE 	= P_ACTION_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_ACTION_CODE in VARCHAR2
) is
begin
  delete from CS_SR_ACTION_CODES_TL
  where ACTION_CODE = P_ACTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CS_SR_ACTION_CODES_B
  where ACTION_CODE = P_ACTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CS_SR_ACTION_CODES_TL T
  where not exists
    (select NULL
    from CS_SR_ACTION_CODES_B B
    where B.ACTION_CODE = T.ACTION_CODE
    );

  update CS_SR_ACTION_CODES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from CS_SR_ACTION_CODES_TL B
    where B.ACTION_CODE = T.ACTION_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTION_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.ACTION_CODE,
      SUBT.LANGUAGE
    from CS_SR_ACTION_CODES_TL SUBB, CS_SR_ACTION_CODES_TL SUBT
    where SUBB.ACTION_CODE = SUBT.ACTION_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CS_SR_ACTION_CODES_TL (
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ACTION_CODE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.ACTION_CODE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CS_SR_ACTION_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CS_SR_ACTION_CODES_TL T
    where T.ACTION_CODE = B.ACTION_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
  P_ACTION_CODE                IN VARCHAR2,
  P_NOTIFICATION_TEMPLATE_NAME IN VARCHAR2,
  P_NEW_STATUS                 IN VARCHAR2,
  P_SEEDED_FLAG                IN VARCHAR2,
  P_RELATIONSHIP_TYPE          IN VARCHAR2,
  P_NEW_RESOLUTION_CODE        IN VARCHAR2,
  P_START_DATE_ACTIVE          IN VARCHAR2,
  P_END_DATE_ACTIVE            IN VARCHAR2,
  P_APPLICATION_ID             IN NUMBER,
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
   l_action_code             VARCHAR2(30);

BEGIN

   if ( p_owner = 'SEED' ) then
         l_user_id := 1;
   end if;

   l_action_code := p_action_code;

   UPDATE_ROW (
   P_ACTION_CODE 	        	 =>l_action_code,
   P_NOTIFICATION_TEMPLATE_NAME  =>p_notification_template_name,
   P_NEW_STATUS 				 =>p_new_status,
   P_SEEDED_FLAG				 =>p_seeded_flag,
   P_RELATIONSHIP_TYPE 	        =>p_relationship_type,
   P_NEW_RESOLUTION_CODE        =>p_new_resolution_code,
   P_START_DATE_ACTIVE          =>to_date(p_start_date_active,'DD-MM-YYYY'),
   P_END_DATE_ACTIVE            =>to_date(p_end_date_active,'DD-MM-YYYY'),
   P_APPLICATION_ID 	        =>p_application_id,
   P_NAME 	        			=>p_name,
   P_DESCRIPTION        		=>p_description,
   P_LAST_UPDATE_DATE      		=>nvl(to_date(p_last_update_date,
                                              'DD-MM-YYYY'),sysdate),
   P_LAST_UPDATED_BY 	        =>l_user_id,
   P_LAST_UPDATE_LOGIN 	        =>0,
   X_OBJECT_VERSION_NUMBER      =>lx_object_version_number
   );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
       PX_ACTION_CODE               =>l_action_code,
       P_NOTIFICATION_TEMPLATE_NAME =>p_notification_template_name,
       P_NEW_STATUS                 =>p_new_status,
       P_SEEDED_FLAG                =>p_seeded_flag,
       P_RELATIONSHIP_TYPE          =>p_relationship_type,
       P_NEW_RESOLUTION_CODE        =>p_new_resolution_code,
       P_START_DATE_ACTIVE          =>to_date(p_start_date_active,'DD-MM-YYYY'),
       P_END_DATE_ACTIVE            =>to_date(p_end_date_active,'DD-MM-YYYY'),
       P_APPLICATION_ID             =>p_application_id,
       P_NAME                       =>p_name,
       P_DESCRIPTION                =>p_description,
       P_CREATION_DATE 	            =>nvl(to_date( p_creation_date,
                                                  'DD-MM-YYYY'),sysdate),
       P_CREATED_BY 		    	=>l_user_id,
       P_LAST_UPDATE_DATE           =>nvl(to_date( p_last_update_date,
                                                  'DD-MM-YYYY'),sysdate),
       P_LAST_UPDATED_BY            =>l_user_id,
       P_LAST_UPDATE_LOGIN          =>0,
       X_OBJECT_VERSION_NUMBER      =>lx_object_version_number
       );

END LOAD_ROW;

procedure TRANSLATE_ROW ( X_ACTION_CODE  in  varchar2,
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

update CS_SR_ACTION_CODES_TL set
 name = nvl(x_name,name),
 description = nvl(x_description,name),
 last_update_date = nvl(x_last_update_date,sysdate),
 last_updated_by = l_user_id,
 last_update_login = 0,
 source_lang = userenv('LANG')
 where action_code = x_action_code
 and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

end CS_SR_ACTION_CODES_PKG;

/
