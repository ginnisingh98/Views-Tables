--------------------------------------------------------
--  DDL for Package Body JTS_SETUP_FLOW_HIEARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_SETUP_FLOW_HIEARCHY_PKG" as
/* $Header: jtstcsfb.pls 115.3 2002/06/07 11:53:18 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_SETUP_FLOW_HIEARCHY_PKG
-- Purpose          : Setup Summary Hiearchy.
-- History          : 27-Feb-02  Sung Ha Huh  Created.
-- NOTE             :
-- --------------------------------------------------------------------


FUNCTION GET_NEXT_FLOW_ID RETURN NUMBER IS
   l_flow_id 	JTS_SETUP_FLOWS_B.flow_id%TYPE;
BEGIN
   SELECT jts_setup_flows_b_s.nextval
   INTO   l_flow_id
   FROM   sys.dual;

   return (l_flow_id);
EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END GET_NEXT_FLOW_ID;

FUNCTION GET_FLOW_ID(p_code IN VARCHAR2) RETURN NUMBER IS
   l_flow_id 	JTS_SETUP_FLOWS_B.flow_id%TYPE := NULL;
BEGIN
  SELECT flow_id
  INTO   l_flow_id
  FROM   JTS_SETUP_FLOWS_B
  WHERE  flow_code = p_code;
  return (l_flow_id);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return NULL;
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END GET_FLOW_ID;

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
-- Inserts a flow.  Parent_id is found by
-- the flow_code of the parent.
-- Precondition: Parents need to be inserted first
-- in to the tables.
-------------------------------------------------
PROCEDURE INSERT_ROW(
  p_flow_code		IN VARCHAR2,
  p_flow_type 		IN VARCHAR2,
  p_parent_code		IN VARCHAR2,
  p_has_child_flag 	IN VARCHAR2,
  p_flow_sequence	IN NUMBER,
  p_overview_url 	IN VARCHAR2,
  p_diagnostics_url 	IN VARCHAR2,
  p_dpf_code 		IN VARCHAR2,
  p_dpf_asn 		IN VARCHAR2,
  p_num_steps 		IN NUMBER,
  p_flow_name 		IN VARCHAR2,
  p_created_by		IN NUMBER,
  p_last_updated_by	IN NUMBER,
  p_last_update_login 	IN NUMBER,
  x_flow_id		OUT NUMBER
) IS
  l_parent_id	JTS_SETUP_FLOWS_B.parent_id%TYPE;
BEGIN

  x_flow_id := get_next_flow_id;

  l_parent_id := get_flow_id(p_parent_code);

  insert into JTS_SETUP_FLOWS_B (
    FLOW_ID,
    FLOW_CODE,
    FLOW_TYPE,
    PARENT_ID,
    HAS_CHILD_FLAG,
    FLOW_SEQUENCE,
    OVERVIEW_URL,
    DIAGNOSTICS_URL,
    DPF_CODE,
    DPF_ASN,
    NUM_STEPS,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FLOW_ID,
    p_flow_code,
    P_FLOW_TYPE,
    l_parent_id,
    P_HAS_CHILD_FLAG,
    P_FLOW_SEQUENCE,
    P_OVERVIEW_URL,
    P_DIAGNOSTICS_URL,
    P_DPF_CODE,
    P_DPF_ASN,
    P_NUM_STEPS,
    1,
    sysdate,
    p_created_by,
    sysdate,
    p_last_updated_by,
    p_last_update_login
  );

  insert into JTS_SETUP_FLOWS_TL (
    FLOW_ID,
    FLOW_CODE,
    FLOW_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FLOW_ID,
    p_flow_code,
    P_FLOW_NAME,
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
    from JTS_SETUP_FLOWS_TL T
    where T.FLOW_ID = X_FLOW_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;

END INSERT_ROW;

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
-- Deletes a flow based on flow_code
-------------------------------------------------
PROCEDURE DELETE_ROW(p_flow_code IN VARCHAR2) IS
BEGIN
  DELETE FROM jts_setup_flows_b
  WHERE  flow_code = p_flow_code;

  DELETE FROM jts_setup_flows_tl
  WHERE  flow_code = p_flow_code;

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;

END DELETE_ROW;

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
-- Deletes a flow based on flow_id
-------------------------------------------------
PROCEDURE DELETE_ROW(p_flow_id	IN NUMBER) IS
BEGIN
  DELETE FROM jts_setup_flows_b
  WHERE  flow_id = p_flow_id;

  DELETE FROM jts_setup_flows_tl
  WHERE  flow_id = p_flow_id;

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;

END DELETE_ROW;

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
-- Warning: Should be only used in exceptional cases
--  	    where updating is absolutely necessary
--	    because of a setup error.
--  	    Users cannot call this procedure
-- Updates a flow
-------------------------------------------------
procedure UPDATE_ROW (
  P_FLOW_CODE 		in VARCHAR2,
  P_FLOW_TYPE 		in VARCHAR2,
  P_PARENT_CODE		in VARCHAR2,
  P_HAS_CHILD_FLAG 	in VARCHAR2,
  P_FLOW_SEQUENCE 	in NUMBER,
  P_OVERVIEW_URL 	in VARCHAR2,
  P_DIAGNOSTICS_URL 	in VARCHAR2,
  P_DPF_CODE 		in VARCHAR2,
  P_DPF_ASN 		in VARCHAR2,
  P_NUM_STEPS 		in NUMBER,
  P_FLOW_NAME 		in VARCHAR2,
  P_LAST_UPDATE_DATE 	in DATE,
  P_LAST_UPDATED_BY 	in NUMBER,
  P_LAST_UPDATE_LOGIN 	in NUMBER
) is
  l_parent_id 	JTS_SETUP_FLOWS_B.parent_id%TYPE;
begin
  l_parent_id := get_flow_id(p_parent_code);

  update JTS_SETUP_FLOWS_B set
    FLOW_TYPE = P_FLOW_TYPE,
    PARENT_ID = L_PARENT_ID,
    HAS_CHILD_FLAG = P_HAS_CHILD_FLAG,
    FLOW_SEQUENCE = P_FLOW_SEQUENCE,
    OVERVIEW_URL = P_OVERVIEW_URL,
    DIAGNOSTICS_URL = P_DIAGNOSTICS_URL,
    DPF_CODE = P_DPF_CODE,
    DPF_ASN = P_DPF_ASN,
    NUM_STEPS = P_NUM_STEPS,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where FLOW_CODE = P_FLOW_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTS_SETUP_FLOWS_TL set
    FLOW_NAME = P_FLOW_NAME,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FLOW_CODE = P_FLOW_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
end UPDATE_ROW;

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
--
-- Translates the flow name
-------------------------------------------------
PROCEDURE TRANSLATE_ROW (
         p_flow_code  		IN VARCHAR2,
         p_owner    		IN VARCHAR2,
         p_flow_name  		IN VARCHAR2
        )
IS
BEGIN
    update jts_setup_flows_tl set
       flow_name = nvl(p_flow_name, flow_name),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(p_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  flow_code = p_flow_code
    and    userenv('LANG') in (language, source_lang);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END TRANSLATE_ROW;

-------------------------------------------------
-- This is for seeding the Flow hiearchy.
--
-- Uploads a flow
-- If p_flow_id is not NULL and there is no flow with
-- such flow_id in the database, then a new flow_id will be used
-------------------------------------------------
PROCEDURE LOAD_ROW (
          P_FLOW_CODE      	IN VARCHAR2,
          P_OWNER              	IN VARCHAR2,
          p_flow_type   	IN VARCHAR2,
          p_parent_code        	IN VARCHAR2,
          p_has_child_flag      IN VARCHAR2,
          p_flow_sequence      	IN NUMBER,
          p_num_steps    	IN NUMBER,
  	  P_OVERVIEW_URL 	in VARCHAR2,
  	  P_DIAGNOSTICS_URL 	in VARCHAR2,
  	  P_DPF_CODE 		in VARCHAR2,
  	  P_DPF_ASN 		in VARCHAR2,
          P_FLOW_NAME         	IN VARCHAR2
         )
IS
   l_user_id      	JTS_SETUP_FLOWS_B.created_by%TYPE := 0;
   l_count	  	number := 0;
   l_flow_id     	JTS_SETUP_FLOWS_B.flow_id%TYPE;

BEGIN
   if P_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   select count(*)
   into	  l_count
   from   jts_setup_flows_b
   where  flow_code = p_flow_code;


   IF (l_count = 0) THEN --no flow with p_flow_code exists.  Use p_flow_code to insert a new row
      IF p_flow_code IS NOT NULL THEN --use a new flow_id
      	INSERT_ROW (
	    p_flow_code			=>  p_flow_code,
  	    p_flow_type 		=>  p_flow_type,
  	    p_parent_code 		=>  p_parent_code,
  	    p_has_child_flag 		=>  p_has_child_flag,
  	    p_flow_sequence 		=>  p_flow_sequence,
  	    p_overview_url 		=>  p_overview_url,
  	    p_diagnostics_url 		=>  p_diagnostics_url,
  	    p_dpf_code 			=>  p_dpf_code,
  	    p_dpf_asn 			=>  p_dpf_asn,
  	    p_num_steps 		=>  p_num_steps,
  	    p_flow_name 		=>  p_flow_name,
      	    p_created_by    		=>  l_user_id,
      	    p_last_updated_by  		=>  l_user_id,
      	    p_last_update_login  	=>  1,
      	    x_flow_id   		=>  l_flow_id
      	);
      END IF;
   ELSE --flow with p_flow_code exists, update

      UPDATE_ROW (
  	  P_FLOW_CODE 			=>  p_flow_code,
  	  P_FLOW_TYPE 			=>  p_flow_type,
  	  P_PARENT_CODE			=>  p_parent_code,
  	  P_HAS_CHILD_FLAG 		=>  p_has_child_flag,
  	  P_FLOW_SEQUENCE 		=>  p_flow_sequence,
  	  P_OVERVIEW_URL 		=>  p_overview_url,
  	  P_DIAGNOSTICS_URL 		=>  p_diagnostics_url,
  	  P_DPF_CODE 			=>  p_dpf_code,
  	  P_DPF_ASN 			=>  p_dpf_asn,
  	  P_NUM_STEPS 			=>  p_num_steps,
  	  P_FLOW_NAME 			=>  p_flow_name,
  	  P_LAST_UPDATE_DATE 		=>  sysdate,
  	  P_LAST_UPDATED_BY 		=>  l_user_id,
  	  P_LAST_UPDATE_LOGIN 		=>  1
      );
   end if;
EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END LOAD_ROW;


procedure LOCK_ROW (
  X_FLOW_ID in NUMBER,
  X_FLOW_CODE in VARCHAR2,
  X_FLOW_TYPE in VARCHAR2,
  X_PARENT_ID in NUMBER,
  X_HAS_CHILD_FLAG in VARCHAR2,
  X_FLOW_SEQUENCE in NUMBER,
  X_OVERVIEW_URL in VARCHAR2,
  X_DIAGNOSTICS_URL in VARCHAR2,
  X_DPF_CODE in VARCHAR2,
  X_DPF_ASN in VARCHAR2,
  X_NUM_STEPS in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FLOW_NAME in VARCHAR2
) is
  cursor c is select
      FLOW_TYPE,
      PARENT_ID,
      HAS_CHILD_FLAG,
      FLOW_SEQUENCE,
      OVERVIEW_URL,
      DIAGNOSTICS_URL,
      DPF_CODE,
      DPF_ASN,
      NUM_STEPS,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER
    from JTS_SETUP_FLOWS_B
    where FLOW_ID = X_FLOW_ID
    and FLOW_CODE = X_FLOW_CODE
    for update of FLOW_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FLOW_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTS_SETUP_FLOWS_TL
    where FLOW_ID = X_FLOW_ID
    and FLOW_CODE = X_FLOW_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FLOW_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.FLOW_TYPE = X_FLOW_TYPE)
           OR ((recinfo.FLOW_TYPE is null) AND (X_FLOW_TYPE is null)))
      AND ((recinfo.PARENT_ID = X_PARENT_ID)
           OR ((recinfo.PARENT_ID is null) AND (X_PARENT_ID is null)))
      AND ((recinfo.HAS_CHILD_FLAG = X_HAS_CHILD_FLAG)
           OR ((recinfo.HAS_CHILD_FLAG is null) AND (X_HAS_CHILD_FLAG is null)))
      AND (recinfo.FLOW_SEQUENCE = X_FLOW_SEQUENCE)
      AND ((recinfo.OVERVIEW_URL = X_OVERVIEW_URL)
           OR ((recinfo.OVERVIEW_URL is null) AND (X_OVERVIEW_URL is null)))
      AND ((recinfo.DIAGNOSTICS_URL = X_DIAGNOSTICS_URL)
           OR ((recinfo.DIAGNOSTICS_URL is null) AND (X_DIAGNOSTICS_URL is null)))
      AND ((recinfo.DPF_CODE = X_DPF_CODE)
           OR ((recinfo.DPF_CODE is null) AND (X_DPF_CODE is null)))
      AND ((recinfo.DPF_ASN = X_DPF_ASN)
           OR ((recinfo.DPF_ASN is null) AND (X_DPF_ASN is null)))
      AND ((recinfo.NUM_STEPS = X_NUM_STEPS)
           OR ((recinfo.NUM_STEPS is null) AND (X_NUM_STEPS is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FLOW_NAME = X_FLOW_NAME)
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


procedure ADD_LANGUAGE
is
begin
  delete from JTS_SETUP_FLOWS_TL T
  where not exists
    (select NULL
    from JTS_SETUP_FLOWS_B B
    where B.FLOW_ID = T.FLOW_ID
    and B.FLOW_CODE = T.FLOW_CODE
    );

  update JTS_SETUP_FLOWS_TL T set (
      FLOW_NAME
    ) = (select
      B.FLOW_NAME
    from JTS_SETUP_FLOWS_TL B
    where B.FLOW_ID = T.FLOW_ID
    and B.FLOW_CODE = T.FLOW_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FLOW_ID,
      T.FLOW_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.FLOW_ID,
      SUBT.FLOW_CODE,
      SUBT.LANGUAGE
    from JTS_SETUP_FLOWS_TL SUBB, JTS_SETUP_FLOWS_TL SUBT
    where SUBB.FLOW_ID = SUBT.FLOW_ID
    and SUBB.FLOW_CODE = SUBT.FLOW_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FLOW_NAME <> SUBT.FLOW_NAME
  ));

  insert into JTS_SETUP_FLOWS_TL (
    FLOW_ID,
    FLOW_CODE,
    FLOW_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FLOW_ID,
    B.FLOW_CODE,
    B.FLOW_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTS_SETUP_FLOWS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTS_SETUP_FLOWS_TL T
    where T.FLOW_ID = B.FLOW_ID
    and T.FLOW_CODE = B.FLOW_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END JTS_SETUP_FLOW_HIEARCHY_PKG;

/
