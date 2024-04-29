--------------------------------------------------------
--  DDL for Package Body JTS_FLOW_STEPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_FLOW_STEPS_PKG" as
/* $Header: jtstcfsb.pls 115.1 2002/06/07 11:53:13 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_FLOW_STEPS_PKG
-- Purpose          : details of each flow step
-- History          : 18-Apr-02  Shirley Zou  Created.
-- NOTE             :
-- --------------------------------------------------------------------


FUNCTION GET_NEXT_STEP_ID RETURN NUMBER IS
   l_step_id 	JTS_FLOW_STEPS_B.step_id%TYPE;
BEGIN
   SELECT jts.jts_flow_steps_b_s.nextval
   INTO   l_step_id
   FROM   sys.dual;

   return (l_step_id);
EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END GET_NEXT_STEP_ID;

-------------------------------------------------
-- This is for seeding the Flow Step Details.
-- Inserts a step.
-------------------------------------------------
PROCEDURE INSERT_ROW(
  p_setup_page		IN VARCHAR2,
  p_flow_id		IN NUMBER,
  p_mandatory_flag 	IN VARCHAR2,
  p_concurrent_flag	IN VARCHAR2,
  p_step_sequence	IN NUMBER,
  p_step_name 	 	IN VARCHAR2,
  p_description 	IN VARCHAR2,
  p_impact 		IN VARCHAR2,
  p_created_by		IN NUMBER,
  p_last_updated_by	IN NUMBER,
  p_last_update_login 	IN NUMBER,
  x_step_id		OUT NUMBER
) IS
BEGIN

  x_step_id := get_next_step_id;

  insert into JTS_FLOW_STEPS_B (
    SETUP_PAGE,
    STEP_ID,
    FLOW_ID,
    MANDATORY_FLAG,
    CONCURRENT_FLAG,
    STEP_SEQUENCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    p_setup_page,
    X_STEP_ID,
    p_flow_id,
    p_mandatory_flag,
    p_concurrent_flag,
    p_step_sequence,
    sysdate,
    p_created_by,
    sysdate,
    p_last_updated_by,
    p_last_update_login
  );

  insert into JTS_FLOW_STEPS_TL (
    STEP_ID,
    STEP_NAME,
    DESCRIPTION,
    IMPACT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_STEP_ID,
    p_step_name,
    P_description,
    p_impact,
    sysdate,
    p_created_by,
    sysdate,
    p_last_updated_by,
    p_last_update_login,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTS_FLOW_STEPS_TL T
    where T.STEP_ID = X_STEP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;

END INSERT_ROW;

-------------------------------------------------
-- This is for seeding the Flow Step Details
-- Deletes a step based on step_id
-------------------------------------------------
PROCEDURE DELETE_ROW(p_step_id IN NUMBER) IS
BEGIN
  DELETE FROM jts_flow_steps_b
  WHERE  step_id = p_step_id;

  DELETE FROM jts_flow_steps_tl
  WHERE  step_id = p_step_id;

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;

END DELETE_ROW;

-------------------------------------------------
-- This is for seeding the Flow Step Details
-- Warning: Should be only used in exceptional cases
--  	    where updating is absolutely necessary
--	    because of a setup error.
--  	    Users cannot call this procedure
-- Updates a step
-------------------------------------------------
procedure UPDATE_ROW (
  p_setup_page		IN VARCHAR2,
  p_step_id 		IN NUMBER,
  p_flow_id		IN NUMBER,
  p_mandatory_flag 	IN VARCHAR2,
  p_concurrent_flag	IN VARCHAR2,
  p_step_sequence	IN NUMBER,
  p_step_name 	 	IN VARCHAR2,
  p_description 	IN VARCHAR2,
  p_impact 		IN VARCHAR2,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) is
begin

  update JTS_FLOW_STEPS_B set
    SETUP_PAGE = P_SETUP_PAGE,
    FLOW_ID = P_FLOW_ID,
    MANDATORY_FLAG = P_MANDATORY_FLAG,
    CONCURRENT_FLAG = P_CONCURRENT_FLAG,
    STEP_SEQUENCE = P_STEP_SEQUENCE,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where STEP_ID = P_STEP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTS_FLOW_STEPS_TL set
    STEP_NAME = P_STEP_NAME,
    DESCRIPTION = P_DESCRIPTION,
    IMPACT = P_IMPACT,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STEP_ID = P_STEP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
end UPDATE_ROW;

-------------------------------------------------
-- This is for seeding the Flow Step Details.
--
-- Translates the flow name
-------------------------------------------------
PROCEDURE TRANSLATE_ROW (
         p_step_id  		IN NUMBER,
         p_owner    		IN VARCHAR2,
         p_step_name  		IN VARCHAR2,
         p_description		IN VARCHAR2,
         p_impact		IN VARCHAR2
        )
IS
BEGIN
    update jts_flow_steps_tl set
       step_name = nvl(p_step_name, step_name),
       description = nvl(p_description, description),
       impact = nvl(p_impact, impact),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(p_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  step_id = p_step_id
    and    userenv('LANG') in (language, source_lang);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END TRANSLATE_ROW;

-------------------------------------------------
-- This is for seeding the Flow Step Details.
--
-- Uploads a step
-- If p_step_id is not NULL and there is no step with
-- such step_id in the database, then a new step_id will be used
-------------------------------------------------
PROCEDURE LOAD_ROW (
          p_setup_page 		IN VARCHAR2,
          p_step_id      	IN NUMBER,
          p_flow_id		IN NUMBER,
          P_OWNER              	IN VARCHAR2,
          p_mandatory_flag   	IN VARCHAR2,
          p_concurrent_flag    	IN VARCHAR2,
          p_step_sequence       IN NUMBER,
          p_step_name      	IN VARCHAR2,
          p_description    	IN VARCHAR2,
  	  P_impact	 	in VARCHAR2
         )
IS
   l_user_id      	JTS_FLOW_STEPS_B.created_by%TYPE := 0;
   l_count	  	number := 0;
   l_step_id     	JTS_FLOW_STEPS_B.step_id%TYPE;

BEGIN
   if P_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   select count(*)
   into	  l_count
   from   jts_flow_steps_b
   where  step_id = p_step_id;


   IF (l_count = 0) THEN --no step with step_id exists.  Use p_step_id to insert a new row
      IF p_step_id IS NOT NULL THEN --use a new step_id
      	INSERT_ROW (
      	    p_setup_page		=>  p_setup_page,
      	    p_flow_id			=>  p_flow_id,
  	    p_mandatory_flag 		=>  p_mandatory_flag,
  	    p_concurrent_flag		=>  p_concurrent_flag,
  	    p_step_sequence		=>  p_step_sequence,
  	    p_step_name 	 	=>  p_step_name,
  	    p_description 		=>  p_description,
  	    p_impact 			=>  p_impact,
  	    p_created_by		=>  l_user_id,
  	    p_last_updated_by		=>  l_user_id,
  	    p_last_update_login 	=>  1,
  	    x_step_id			=>  l_step_id
      	);
      END IF;
   ELSE --step with p_step_id exists, update

      UPDATE_ROW (
          p_setup_page			=>  p_setup_page,
          p_step_id			=>  p_step_id,
	  p_flow_id			=>  p_flow_id,
	  p_mandatory_flag 		=>  p_mandatory_flag,
	  p_concurrent_flag		=>  p_concurrent_flag,
	  p_step_sequence		=>  p_step_sequence,
	  p_step_name 	 		=>  p_step_name,
	  p_description 		=>  p_description,
	  p_impact 			=>  p_impact,
	  P_LAST_UPDATE_DATE 		=>  sysdate,
	  P_LAST_UPDATED_BY 	 	=>  l_user_id,
	  P_LAST_UPDATE_LOGIN 		=>  1
      );
   end if;
EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END LOAD_ROW;


-------------------------------------------------
-- Lock Row
-------------------------------------------------
procedure LOCK_ROW (
  X_STEP_ID in NUMBER,
  X_FLOW_ID in NUMBER,
  X_MANDATORY_FLAG in VARCHAR2,
  X_CONCURRENT_FLAG in VARCHAR2,
  X_STEP_SEQUENCE in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_SETUP_PAGE in VARCHAR2,
  X_STEP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_IMPACT in VARCHAR2
) is
  cursor c is select
      FLOW_ID,
      MANDATORY_FLAG,
      CONCURRENT_FLAG,
      STEP_SEQUENCE,
      SECURITY_GROUP_ID,
      SETUP_PAGE
    from JTS_FLOW_STEPS_B
    where STEP_ID = X_STEP_ID
    for update of STEP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      STEP_NAME,
      DESCRIPTION,
      IMPACT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTS_FLOW_STEPS_TL
    where STEP_ID = X_STEP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STEP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.FLOW_ID = X_FLOW_ID)
      AND (recinfo.MANDATORY_FLAG = X_MANDATORY_FLAG)
      AND (recinfo.CONCURRENT_FLAG = X_CONCURRENT_FLAG)
      AND (recinfo.STEP_SEQUENCE = X_STEP_SEQUENCE)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.SETUP_PAGE = X_SETUP_PAGE)
           OR ((recinfo.SETUP_PAGE is null) AND (X_SETUP_PAGE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.STEP_NAME = X_STEP_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
          AND (tlinfo.IMPACT = X_IMPACT)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

-------------------------------------------------
-- Add Language
------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from JTS_FLOW_STEPS_TL T
  where not exists
    (select NULL
    from JTS_FLOW_STEPS_B B
    where B.STEP_ID = T.STEP_ID
    );

  update JTS_FLOW_STEPS_TL T set (
      STEP_NAME,
      DESCRIPTION,
      IMPACT
    ) = (select
      B.STEP_NAME,
      B.DESCRIPTION,
      B.IMPACT
    from JTS_FLOW_STEPS_TL B
    where B.STEP_ID = T.STEP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STEP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STEP_ID,
      SUBT.LANGUAGE
    from JTS_FLOW_STEPS_TL SUBB, JTS_FLOW_STEPS_TL SUBT
    where SUBB.STEP_ID = SUBT.STEP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STEP_NAME <> SUBT.STEP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or SUBB.IMPACT <> SUBT.IMPACT
  ));

  insert into JTS_FLOW_STEPS_TL (
    STEP_ID,
    STEP_NAME,
    DESCRIPTION,
    IMPACT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STEP_ID,
    B.STEP_NAME,
    B.DESCRIPTION,
    B.IMPACT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTS_FLOW_STEPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTS_FLOW_STEPS_TL T
    where T.STEP_ID = B.STEP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END JTS_FLOW_STEPS_PKG;

/
