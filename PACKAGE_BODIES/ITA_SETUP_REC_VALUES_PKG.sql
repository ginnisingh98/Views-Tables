--------------------------------------------------------
--  DDL for Package Body ITA_SETUP_REC_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_SETUP_REC_VALUES_PKG" as
/* $Header: itatrevb.pls 120.12.12000000.2 2007/10/09 11:06:58 shelango ship $ */
--
-- ************************************************************************/
-- ** PROCEDURE - custom_debug    takes message as a parameter and the message can  */
-- **            be inserted into any custome table	              */
-- ************************************************************************/
--


procedure custom_debug(X_DEBUG_MSG in VARCHAR2) IS
L_DUMMY_VAR VARCHAR2(10);
begin

	L_DUMMY_VAR := null;


	-- insert into  sam_test
	-- (id,
	-- message,
	-- creation_date
	-- )
	-- values
	-- (
	-- sam_test_s1.nextval,
	-- X_DEBUG_MSG,
	-- sysdate
	-- );

	--commit;


end custom_debug;

--
-- ************************************************************************/
-- ** PROCEDURE - getContextInfo    It returns the context_id depending upon  */
-- **            the org context name				              */
-- ************************************************************************/
--

procedure getContextInfo(
			X_CONTEXT_ID OUT NOCOPY NUMBER,
			P_CONTEXT_NAME IN VARCHAR2,
			P_SETUP_GROUP_NAME IN VARCHAR2
)
IS
    l_setup_group_substr varchar2(10);
    ERR_MSG VARCHAR2(100);
    ERR_CDE NUMBER;

Begin

    IF P_CONTEXT_NAME  IS NOT NULL THEN
     BEGIN
	 l_setup_group_substr := SUBSTR(P_SETUP_GROUP_NAME, 1, 5);
	 custom_debug('SAM :: In side the getContextInfo ');
	 custom_debug('SAM :: l_setup_group_substr ' || l_setup_group_substr);

	  IF (l_setup_group_substr = 'SQLGL') THEN
	    begin
			custom_debug('SAM :: l_setup_group_substr SQLGL ');
			select distinct
			SET_OF_BOOKS_ID into X_CONTEXT_ID
			from GL_SETS_OF_BOOKS
			where NAME = nvl(P_CONTEXT_NAME,999);
			 EXCEPTION
			 WHEN NO_DATA_FOUND THEN
			    X_CONTEXT_ID := null;
	    end;
	  ELSE
	    begin
			custom_debug('SAM :: l_setup_group_substr NOT SQLGL ');
			select distinct
			org.ORGANIZATION_ID into X_CONTEXT_ID
			from
			HR_ALL_ORGANIZATION_UNITS org
			where
			org.NAME = nvl(P_CONTEXT_NAME,999);
			 EXCEPTION
			 WHEN NO_DATA_FOUND THEN
			    X_CONTEXT_ID := null;
	    end;
          END IF;
	 custom_debug('SAM :: X_CONTEXT_ID ' || X_CONTEXT_ID);

     END;
    END IF;

End getContextInfo;

--
-- ************************************************************************/
-- ** PROCEDURE - GetParameterCode    It returns the parametere code for the  */
-- **            parameter name depending on the parameter code              */
-- ************************************************************************/
--

  procedure GetParameterCode  (p_parameter_name    IN VARCHAR2,
			      p_setup_group_code IN VARCHAR2,
			      X_PARAMETER_CODE OUT NOCOPY VARCHAR2)
  IS
    g_parameter_code          VARCHAR2(111) := NULL;
    ERR_MSG VARCHAR2(100);
    ERR_CDE NUMBER;
  BEGIN

    IF p_parameter_name  IS NOT NULL THEN
      BEGIN
	  custom_debug('g_parameter_code p_parameter_name :: ' || p_parameter_name);

	SELECT parameter_code
          INTO X_PARAMETER_CODE
          FROM ita_setup_parameters_vl
          WHERE parameter_name = p_parameter_name and
	  setup_group_code = p_setup_group_code;
	EXCEPTION
          WHEN OTHERS THEN
  	    ERR_MSG := SUBSTR(SQLERRM,1,100);
	    ERR_CDE := SQLCODE;
	    custom_debug('In the exception ERR_MSG :: ' || ERR_MSG  || ' :: ERR_CDE :: ' ||  ERR_CDE);
            X_PARAMETER_CODE := NULL;
      END;
    END IF;
    custom_debug('X_PARAMETER_CODE  :: ' || X_PARAMETER_CODE);
  END GetParameterCode;


procedure INSERT_ROW (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID in NUMBER
)

is
begin

  custom_debug('In to the INSERT_ROW X_PARAMETER_CODE ' || X_PARAMETER_CODE);

  insert into ITA_SETUP_REC_VALUES_B (
    REC_VALUE_ID,
    PARAMETER_CODE,
    CONTEXT_ORG_ID,
    CONTEXT_ORG_NAME,
    DEFAULT_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    PK1_VALUE,
    PK2_VALUE,
    REC_INTERFACE_ID
  ) values (
    X_REC_VALUE_ID,
    X_PARAMETER_CODE,
    X_CONTEXT_ORG_ID,
    X_CONTEXT_ORG_NAME,
    X_DEFAULT_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_PK1_VALUE,
    X_PK2_VALUE,
    X_REC_INTERFACE_ID
  );

  custom_debug('In to the INSERT_ROW callin insert in TL X_REC_VALUE_ID :: ' || X_REC_VALUE_ID);

  insert into ITA_SETUP_REC_VALUES_TL (
    REC_VALUE_ID,
    PARAMETER_CODE,
    CONTEXT_ORG_NAME,
    RECOMMENDED_VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REC_VALUE_ID,
    X_PARAMETER_CODE,
    X_CONTEXT_ORG_NAME,
    X_RECOMMENDED_VALUE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists (
    select null
    from ITA_SETUP_REC_VALUES_TL tl
    where
      (tl.REC_VALUE_ID = X_REC_VALUE_ID or
	  (PARAMETER_CODE = X_PARAMETER_CODE and CONTEXT_ORG_NAME = X_CONTEXT_ORG_NAME)) and
      tl.LANGUAGE = L.LANGUAGE_CODE);


end INSERT_ROW;


procedure UPDATE_ROW (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID NUMBER
) is
begin
  update ITA_SETUP_REC_VALUES_B set
    REC_VALUE_ID = X_REC_VALUE_ID,
    PARAMETER_CODE = X_PARAMETER_CODE,
    CONTEXT_ORG_ID = X_CONTEXT_ORG_ID,
    CONTEXT_ORG_NAME = X_CONTEXT_ORG_NAME,
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    PK1_VALUE = X_PK1_VALUE,
    PK2_VALUE = X_PK2_VALUE,
    REC_INTERFACE_ID = X_REC_INTERFACE_ID
  where REC_VALUE_ID = X_REC_VALUE_ID or
    (PARAMETER_CODE = X_PARAMETER_CODE and CONTEXT_ORG_NAME = X_CONTEXT_ORG_NAME);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ITA_SETUP_REC_VALUES_TL set
    REC_VALUE_ID = X_REC_VALUE_ID,
    PARAMETER_CODE = X_PARAMETER_CODE,
    CONTEXT_ORG_NAME = X_CONTEXT_ORG_NAME,
    RECOMMENDED_VALUE = X_RECOMMENDED_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SOURCE_LANG = userenv('LANG')
  where
    (REC_VALUE_ID = X_REC_VALUE_ID or
      (PARAMETER_CODE = X_PARAMETER_CODE and CONTEXT_ORG_NAME = X_CONTEXT_ORG_NAME)) and
    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure LOAD_ROW (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID NUMBER,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is

f_luby	number;	-- entity owner in file
f_ludate	date;		-- entity update date in file
db_luby	number;	-- entity owner in db
db_ludate	date;		-- entity update date in db

begin
	-- Translate owner to file_last_updated_by
	f_luby := fnd_load_util.owner_id(X_OWNER);

	-- Translate char last_update_date to date
	f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	select LAST_UPDATED_BY, LAST_UPDATE_DATE into db_luby, db_ludate
	from ITA_SETUP_REC_VALUES_B
	where REC_VALUE_ID = X_REC_VALUE_ID or
        (PARAMETER_CODE = X_PARAMETER_CODE and CONTEXT_ORG_NAME = X_CONTEXT_ORG_NAME);

	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE))
	then ITA_SETUP_REC_VALUES_PKG.UPDATE_ROW (
		X_REC_VALUE_ID			=> X_REC_VALUE_ID,
		X_PARAMETER_CODE			=> X_PARAMETER_CODE,
		X_CONTEXT_ORG_ID			=> X_CONTEXT_ORG_ID,
		X_CONTEXT_ORG_NAME		=> X_CONTEXT_ORG_NAME,
		X_RECOMMENDED_VALUE		=> X_RECOMMENDED_VALUE,
		X_DEFAULT_FLAG			=> X_DEFAULT_FLAG,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_PK1_VALUE				=> X_PK1_VALUE,
		X_PK2_VALUE				=> X_PK2_VALUE,
		X_REC_INTERFACE_ID		=> X_REC_INTERFACE_ID);
	end if;
	exception when NO_DATA_FOUND
	then ITA_SETUP_REC_VALUES_PKG.INSERT_ROW (
		X_REC_VALUE_ID			=> X_REC_VALUE_ID,
		X_PARAMETER_CODE			=> X_PARAMETER_CODE,
		X_CONTEXT_ORG_ID			=> X_CONTEXT_ORG_ID,
		X_CONTEXT_ORG_NAME		=> X_CONTEXT_ORG_NAME,
		X_RECOMMENDED_VALUE		=> X_RECOMMENDED_VALUE,
		X_DEFAULT_FLAG			=> X_DEFAULT_FLAG,
		X_CREATION_DATE			=> f_ludate,
		X_CREATED_BY			=> f_luby,
		X_LAST_UPDATE_DATE		=> f_ludate,
		X_LAST_UPDATED_BY			=> f_luby,
		X_LAST_UPDATE_LOGIN		=> 0,
		X_SECURITY_GROUP_ID		=> null,
		X_OBJECT_VERSION_NUMBER		=> 1,
		X_PK1_VALUE				=> X_PK1_VALUE,
		X_PK2_VALUE				=> X_PK2_VALUE,
		X_REC_INTERFACE_ID		=> X_REC_INTERFACE_ID);
end LOAD_ROW;


procedure LOAD_ROW_FOR_IMPORT (
  X_REC_VALUE_ID in NUMBER,
  X_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_ORG_ID in NUMBER,
  X_CONTEXT_ORG_NAME in VARCHAR2,
  X_RECOMMENDED_VALUE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PK1_VALUE in VARCHAR2,
  X_PK2_VALUE in VARCHAR2,
  X_REC_INTERFACE_ID NUMBER
) is

db_rec_value_id	number;
db_luby		number;
db_ludate		date;

begin
	select REC_VALUE_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE into db_rec_value_id, db_luby, db_ludate
	from ITA_SETUP_REC_VALUES_B
	where REC_VALUE_ID = X_REC_VALUE_ID or
        (PARAMETER_CODE = X_PARAMETER_CODE and CONTEXT_ORG_NAME = X_CONTEXT_ORG_NAME);

	if (db_luby is not null and db_ludate is not null)
	then ITA_SETUP_REC_VALUES_PKG.UPDATE_ROW (
		X_REC_VALUE_ID			=> db_rec_value_id,
		X_PARAMETER_CODE			=> X_PARAMETER_CODE,
		X_CONTEXT_ORG_ID			=> X_CONTEXT_ORG_ID,
		X_CONTEXT_ORG_NAME		=> X_CONTEXT_ORG_NAME,
		X_RECOMMENDED_VALUE		=> X_RECOMMENDED_VALUE,
		X_DEFAULT_FLAG			=> X_DEFAULT_FLAG,
		X_LAST_UPDATE_DATE		=> X_LAST_UPDATE_DATE,
		X_LAST_UPDATED_BY			=> X_LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN		=> X_LAST_UPDATE_LOGIN,
		X_SECURITY_GROUP_ID		=> X_SECURITY_GROUP_ID,
		X_OBJECT_VERSION_NUMBER		=> X_OBJECT_VERSION_NUMBER,
		X_PK1_VALUE				=> X_PK1_VALUE,
		X_PK2_VALUE				=> X_PK2_VALUE,
		X_REC_INTERFACE_ID		=> X_REC_INTERFACE_ID);
	end if;
	exception when NO_DATA_FOUND
	then ITA_SETUP_REC_VALUES_PKG.INSERT_ROW (
		X_REC_VALUE_ID			=> X_REC_VALUE_ID,
		X_PARAMETER_CODE			=> X_PARAMETER_CODE,
		X_CONTEXT_ORG_ID			=> X_CONTEXT_ORG_ID,
		X_CONTEXT_ORG_NAME		=> X_CONTEXT_ORG_NAME,
		X_RECOMMENDED_VALUE		=> X_RECOMMENDED_VALUE,
		X_DEFAULT_FLAG			=> X_DEFAULT_FLAG,
		X_CREATION_DATE			=> X_CREATION_DATE,
		X_CREATED_BY			=> X_CREATED_BY,
		X_LAST_UPDATE_DATE		=> X_LAST_UPDATE_DATE,
		X_LAST_UPDATED_BY			=> X_LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN		=> X_LAST_UPDATE_LOGIN,
		X_SECURITY_GROUP_ID		=> X_SECURITY_GROUP_ID,
		X_OBJECT_VERSION_NUMBER		=> X_OBJECT_VERSION_NUMBER,
		X_PK1_VALUE				=> X_PK1_VALUE,
		X_PK2_VALUE				=> X_PK2_VALUE,
		X_REC_INTERFACE_ID		=> X_REC_INTERFACE_ID);
end LOAD_ROW_FOR_IMPORT;


procedure ADD_LANGUAGE
is
begin
  delete from ITA_SETUP_REC_VALUES_TL tl
  where not exists (
    select null
    from ITA_SETUP_REC_VALUES_B b
    where
	b.PARAMETER_CODE = tl.PARAMETER_CODE and
	b.CONTEXT_ORG_NAME = tl.CONTEXT_ORG_NAME
    );

  update ITA_SETUP_REC_VALUES_TL tl set (
      RECOMMENDED_VALUE
    ) = (select
      b.RECOMMENDED_VALUE
    from ITA_SETUP_REC_VALUES_TL b
    where
	b.PARAMETER_CODE = tl.PARAMETER_CODE and
	b.CONTEXT_ORG_NAME = tl.CONTEXT_ORG_NAME and
      b.LANGUAGE = tl.SOURCE_LANG)
  where (
      tl.PARAMETER_CODE,
	tl.CONTEXT_ORG_NAME,
      tl.LANGUAGE
  ) in (select
      subtl.PARAMETER_CODE,
	subtl.CONTEXT_ORG_NAME,
      subtl.LANGUAGE
    from ITA_SETUP_REC_VALUES_TL subb, ITA_SETUP_REC_VALUES_TL subtl
    where
      subb.PARAMETER_CODE = subtl.PARAMETER_CODE and
      subb.CONTEXT_ORG_NAME = subtl.CONTEXT_ORG_NAME and
      subb.LANGUAGE = subtl.SOURCE_LANG and
    	(subb.RECOMMENDED_VALUE <> subtl.RECOMMENDED_VALUE or
        (subb.RECOMMENDED_VALUE is null and subtl.RECOMMENDED_VALUE is not null) or
        (subb.RECOMMENDED_VALUE is not null and subtl.RECOMMENDED_VALUE is null)));

  insert into ITA_SETUP_REC_VALUES_TL (
    PARAMETER_CODE,
    CONTEXT_ORG_ID,
    CONTEXT_ORG_NAME,
    RECOMMENDED_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG,
    REC_VALUE_ID,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE
  ) select
    b.PARAMETER_CODE,
    b.CONTEXT_ORG_ID,
    b.CONTEXT_ORG_NAME,
    b.RECOMMENDED_VALUE,
    b.CREATED_BY,
    b.CREATION_DATE,
    b.LAST_UPDATED_BY,
    b.LAST_UPDATE_DATE,
    b.LAST_UPDATE_LOGIN,
    b.SECURITY_GROUP_ID,
    b.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    b.SOURCE_LANG,
    b.REC_VALUE_ID,
    b.REQUEST_ID,
    b.PROGRAM_APPLICATION_ID,
    b.PROGRAM_ID,
    b.PROGRAM_UPDATE_DATE
  from ITA_SETUP_REC_VALUES_TL b, FND_LANGUAGES L
  where
    L.INSTALLED_FLAG in ('I', 'B') and
    b.LANGUAGE = userenv('LANG') and
    not exists (
     select null
     from ITA_SETUP_REC_VALUES_TL tl
     where
       tl.PARAMETER_CODE = b.PARAMETER_CODE and
       tl.CONTEXT_ORG_NAME = b.CONTEXT_ORG_NAME and
       tl.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure IMPORT (
  BATCH_ID in NUMBER,
  CREATED_BY in NUMBER
) is

m_rec_value_id NUMBER;
m_current_date DATE;
m_org_name VARCHAR2(240);
m_org_id NUMBER;
m_parameter_code VARCHAR2(111);
m_setup_group_code VARCHAR2(81);
m_default_flag VARCHAR2(1);
m_rec_interface_id NUMBER;
--interface_row GET_INTERFACE_ROWS%ROWTYPE;
m_error_msg VARCHAR2(3000);

cursor GET_INTERFACE_ROWS (
  X_BATCH_ID in NUMBER,
  X_CREATED_BY in NUMBER
) is
SELECT
  distinct DEFAULT_FLAG,
  PARAMETER_CODE,
  SETUP_GROUP_CODE,
  PK1_VALUE,
  PK2_VALUE,
  REC_VALUE,
  CREATED_BY,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID  ,
  OBJECT_VERSION_NUMBER,
  REC_INTERFACE_ID
FROM
  ITA_SETUP_REC_INTF
WHERE
  BATCH_ID = X_BATCH_ID and
  CREATED_BY = X_CREATED_BY and
  IMPORTED_FLAG <> 'Y';
begin

for interface_row in GET_INTERFACE_ROWS(BATCH_ID, CREATED_BY) loop

m_rec_interface_id := interface_row.REC_INTERFACE_ID;
m_error_msg := null;

select ITA_SETUP_REC_VALUES_S1.nextval into m_rec_value_id from dual;
select sysdate into m_current_date from dual;



if (interface_row.PARAMETER_CODE IS NOT NULL) then
		GetParameterCode  (p_parameter_name => interface_row.PARAMETER_CODE,
				      p_setup_group_code => interface_row.SETUP_GROUP_CODE,
				      X_PARAMETER_CODE => m_parameter_code);

end if;

  custom_debug('In to the INSERT_ROW m_parameter_code ' || m_parameter_code);

if (m_parameter_code IS NOT NULL) then


	if (interface_row.SETUP_GROUP_CODE = 'FND.FND_PROFILE_OPTION_VALUES') then
	BEGIN

		LOAD_ROW_FOR_IMPORT (
		X_REC_VALUE_ID => m_rec_value_id,
		X_PARAMETER_CODE => m_parameter_code, --interface_row.PARAMETER_CODE,
		X_CONTEXT_ORG_ID => null,
		X_CONTEXT_ORG_NAME => null,
		X_RECOMMENDED_VALUE => interface_row.REC_VALUE,
		X_DEFAULT_FLAG => 'Y',
		X_CREATION_DATE => m_current_date,
		X_CREATED_BY => interface_row.CREATED_BY,
		X_LAST_UPDATE_DATE => m_current_date,
		X_LAST_UPDATED_BY => interface_row.LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN => interface_row.LAST_UPDATE_LOGIN,
		X_SECURITY_GROUP_ID => interface_row.SECURITY_GROUP_ID,
		X_OBJECT_VERSION_NUMBER => interface_row.OBJECT_VERSION_NUMBER,
		X_PK1_VALUE => interface_row.PK1_VALUE,
		X_PK2_VALUE => interface_row.PK2_VALUE,
		X_REC_INTERFACE_ID => interface_row.REC_INTERFACE_ID
		);


	END;
	elsif (interface_row.PK1_VALUE IS NOT NULL) then
	BEGIN
		getContextInfo(X_CONTEXT_ID => m_org_id,
			P_CONTEXT_NAME => interface_row.PK1_VALUE,
			P_SETUP_GROUP_NAME => interface_row.SETUP_GROUP_CODE);

		m_default_flag := interface_row.DEFAULT_FLAG;
		if (m_default_flag is null) then m_default_flag := 'N'; end if;

		LOAD_ROW_FOR_IMPORT (
		X_REC_VALUE_ID => m_rec_value_id,
		X_PARAMETER_CODE => m_parameter_code, --interface_row.PARAMETER_CODE,
		X_CONTEXT_ORG_ID => m_org_id, --interface_row.PK1_VALUE,
		X_CONTEXT_ORG_NAME => interface_row.PK1_VALUE,-- m_org_name,
		X_RECOMMENDED_VALUE => interface_row.REC_VALUE,
		X_DEFAULT_FLAG => m_default_flag,
		X_CREATION_DATE => m_current_date,
		X_CREATED_BY => interface_row.CREATED_BY,
		X_LAST_UPDATE_DATE => m_current_date,
		X_LAST_UPDATED_BY => interface_row.LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN => interface_row.LAST_UPDATE_LOGIN,
		X_SECURITY_GROUP_ID => interface_row.SECURITY_GROUP_ID,
		X_OBJECT_VERSION_NUMBER => interface_row.OBJECT_VERSION_NUMBER,
		X_PK1_VALUE => m_org_id,
		X_PK2_VALUE => interface_row.PK2_VALUE,
		X_REC_INTERFACE_ID => interface_row.REC_INTERFACE_ID
		);

		custom_debug('interface_row.PK1_VALUE IS NOT NULL');
	END;
	ELSE --ELSIF (interface_row.DEFAULT_FLAG ='Y') then
	BEGIN

		LOAD_ROW_FOR_IMPORT (
		X_REC_VALUE_ID => m_rec_value_id,
		X_PARAMETER_CODE => m_parameter_code, --interface_row.PARAMETER_CODE,
		X_CONTEXT_ORG_ID => -1,
		X_CONTEXT_ORG_NAME => '*',
		X_RECOMMENDED_VALUE => interface_row.REC_VALUE,
		X_DEFAULT_FLAG => 'Y',
		X_CREATION_DATE => m_current_date,
		X_CREATED_BY => interface_row.CREATED_BY,
		X_LAST_UPDATE_DATE => m_current_date,
		X_LAST_UPDATED_BY => interface_row.LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN => interface_row.LAST_UPDATE_LOGIN,
		X_SECURITY_GROUP_ID => interface_row.SECURITY_GROUP_ID,
		X_OBJECT_VERSION_NUMBER => interface_row.OBJECT_VERSION_NUMBER,
		X_PK1_VALUE => -1,
		X_PK2_VALUE => interface_row.PK2_VALUE,
		X_REC_INTERFACE_ID => interface_row.REC_INTERFACE_ID
		);

	END;
	end if;


	--update ITA_SETUP_REC_INTF
	--set IMPORTED_FLAG = 'Y'
	--where REC_INTERFACE_ID = interface_row.REC_INTERFACE_ID;

	if m_error_msg is null then
	delete from ITA_SETUP_REC_INTF
	where REC_INTERFACE_ID = interface_row.REC_INTERFACE_ID;
      end if;

end if;


end loop;


	 EXCEPTION
	 WHEN OTHERS THEN
         m_error_msg := substr(SQLERRM, 1, 3000);
	   update ITA_SETUP_REC_INTF
	   set STATUS_TXT = m_error_msg
	   where REC_INTERFACE_ID = m_rec_interface_id;


end IMPORT;


-- *****************************************
-- FUNCTION
--   getRecValueCode0
-- Input Parameters
--   context_org_id
--   parameter_code
-- Return Values
--   varchar2   recommended_value for
--              the org and parameter code
-- *****************************************
FUNCTION getRecValueCode0(
   p_context_org_id     IN   VARCHAR2,
   p_parameter_code     IN   VARCHAR2
)
return VARCHAR2 IS
  l_rec_value_code VARCHAR2(3000);
BEGIN
  l_rec_value_code := null;

  select recommended_value
  into l_rec_value_code
  from ita_setup_rec_values_vl
  where parameter_code = p_parameter_code
  and context_org_id = to_number(p_context_org_id);

  return l_rec_value_code;

EXCEPTION
  when no_data_found then
    select max(recommended_value)
    into l_rec_value_code
    from ita_setup_rec_values_vl
    where parameter_code = p_parameter_code
    and default_flag = 'Y';

    return l_rec_value_code;

  when others then
    return null;

END getRecValueCode0;

-- hyuen start bug 5395104
-- *****************************************
-- FUNCTION
--   getRecValueCodeFromOrg
-- Input Parameters
--   context_org_id
--   parameter_code
--   overrideLevel
-- Return Values
--   varchar2   recommended_value for
--              the org parameter code
-- *****************************************
FUNCTION getRecValueCodeFromOrg(p_context_org_id IN VARCHAR2,   p_parameter_code IN VARCHAR2,   p_overridelevel IN INT) RETURN VARCHAR2 IS l_rec_value_code VARCHAR2(3000);
    l_paramcodeorg VARCHAR2(3000);
    BEGIN
      l_rec_value_code := NULL;
      l_paramcodeorg := NULL;

      SELECT parameter_code
      INTO l_paramcodeorg
      FROM ita_parameter_hierarchy
      WHERE override_parameter_code = p_parameter_code
       AND override_level = p_overridelevel;

      l_rec_value_code := getrecvaluecode0(p_context_org_id,   l_paramcodeorg);

      RETURN l_rec_value_code;
    END getRecValueCodeFromOrg;

 -- *****************************************
 -- FUNCTION
 --   getRecValueCodeFromSuppliers
 -- Input Parameters
 --   context_org_id
 --   parameter_code
 -- Return Values
 --   varchar2   recommended_value for
 --              the Suppliers parameter code
 -- *****************************************
 FUNCTION getRecValueCodeFromSuppliers(p_context_org_id IN VARCHAR2,   p_parameter_code IN VARCHAR2) RETURN VARCHAR2 IS l_rec_value_code VARCHAR2(3000);
    l_paramcodesupps VARCHAR2(3000);
    BEGIN
      l_rec_value_code := NULL;
      l_paramcodesupps := NULL;

      SELECT override_parameter_code
      INTO l_paramcodesupps
      FROM ita_parameter_hierarchy
      WHERE parameter_code =
        (SELECT parameter_code
         FROM ita_parameter_hierarchy
         WHERE override_parameter_code = p_parameter_code
         AND override_level = 2)
      AND override_level = 1;

      l_rec_value_code := getrecvaluecode0(p_context_org_id,   l_paramcodesupps);

      RETURN l_rec_value_code;
    END getRecValueCodeFromSuppliers;
-- hyuen end bug 8395104

-- *****************************************
-- FUNCTION
--   getRecValueCode
-- Input Parameters
--   context_org_id
--   parameter_code
-- Return Values
--   varchar2   recommended_value for
--              the org and parameter code
-- *****************************************
FUNCTION getRecValueCode(
   p_context_org_id     IN   VARCHAR2,
   p_parameter_code     IN   VARCHAR2
)
return VARCHAR2 IS
  l_rec_value_code VARCHAR2(3000);
BEGIN
  l_rec_value_code := null;

  -- hyuen start bug 5395104
  l_rec_value_code := getRecValueCode0(p_context_org_id,p_parameter_code);

  IF(l_rec_value_code IS NULL) THEN
    BEGIN
      IF(SUBSTR(p_parameter_code,   1,   18) = 'SQLAP.AP_SUPPLIERS') THEN
        l_rec_value_code := getrecvaluecodefromorg(p_context_org_id,   p_parameter_code,   1);
      ELSIF SUBSTR(p_parameter_code,   1,   27) = 'SQLAP.AP_SUPPLIER_SITES_ALL' THEN
        BEGIN
          l_rec_value_code := getrecvaluecodefromsuppliers(p_context_org_id,   p_parameter_code);
          IF l_rec_value_code IS NULL THEN
            l_rec_value_code := getrecvaluecodefromorg(p_context_org_id,   p_parameter_code,   2);
           END IF;
        END;
      END IF;

    END;
  END IF;

  return l_rec_value_code;
  -- hyuen end bug 5395104
END getRecValueCode;

-- *****************************************
-- FUNCTION
--   getRecValueMeaning
-- Input Parameters
--   context_org_id
--   parameter_code
-- Return Values
--   varchar2   recommended_value meaning for
--              the org and parameter code
-- *****************************************
FUNCTION getRecValueMeaning(
   p_context_org_id     IN   VARCHAR2,
   p_parameter_code     IN   VARCHAR2
)
return VARCHAR2 IS
  l_select_clause         ITA_SETUP_PARAMETERS_B.SELECT_CLAUSE%TYPE;
  l_from_clause           ITA_SETUP_PARAMETERS_B.FROM_CLAUSE%TYPE;
  l_where_clause          ITA_SETUP_PARAMETERS_B.WHERE_CLAUSE%TYPE;
  l_rec_value_meaning VARCHAR2(3000);
  l_rec_value_code VARCHAR2(3000);
  l_curr_sql VARCHAR2(32767);
BEGIN
  l_rec_value_meaning := null;
  l_rec_value_code := null;

  l_rec_value_code := getRecValueCode(p_context_org_id,p_parameter_code);

  --DBMS_OUTPUT.PUT_LINE('recValueCode: ' || l_rec_value_code);

  if (l_rec_value_code is null) then
   return null;
  end if;

  SELECT select_clause, from_clause, where_clause
  INTO l_select_clause, l_from_clause, l_where_clause
  FROM ita_setup_parameters_b
  WHERE parameter_code = p_parameter_code;

  --DBMS_OUTPUT.PUT_LINE('select clause: ' || l_select_clause);
  --DBMS_OUTPUT.PUT_LINE('from clause: ' || l_from_clause);
  --DBMS_OUTPUT.PUT_LINE('where clause: ' || l_where_clause);

  IF l_select_clause IS NOT NULL THEN
       l_select_clause := RTRIM(l_select_clause);

       if l_select_clause is null then
         --DBMS_OUTPUT.PUT_LINE('select is null: ' || l_rec_value_code);
         return l_rec_value_code;
       end if;

       IF l_from_clause IS NOT NULL THEN
            l_from_clause := RTRIM(l_from_clause);
       END IF;

       IF l_where_clause IS NOT NULL THEN
            l_where_clause := RTRIM(l_where_clause);
       END IF;

       l_curr_sql := l_select_clause || ' ' || l_from_clause || ' ' || l_where_clause;

       --DBMS_OUTPUT.PUT_LINE('SQL: ' || l_curr_sql);

       -- hyuen start bug 5410296 handle Profile option
       --  l_curr_sql := REPLACE(l_curr_sql,':1',l_rec_value_code);

       --  EXECUTE IMMEDIATE l_curr_sql into l_rec_value_meaning;
       IF(SUBSTR(p_parameter_code,   1,   29) = 'FND.FND_PROFILE_OPTION_VALUES') then
         begin
           l_rec_value_meaning := ITA_RECORD_CURR_STATUS_PKG.GET_PROFILE_VALUE_MEANING (l_curr_sql, l_rec_value_code);
         end;
       else
         begin
           l_curr_sql := REPLACE(l_curr_sql,':1',l_rec_value_code);
           --DBMS_OUTPUT.PUT_LINE('Bind: ' || l_curr_sql);
           EXECUTE IMMEDIATE l_curr_sql into l_rec_value_meaning;
         end;
       end if;

       -- hyuen end bug 5410296 handle Profile option


  END IF;

  if (l_rec_value_meaning is null) then
   return l_rec_value_code;
  end if;

  return l_rec_value_meaning;

EXCEPTION
  when others then
   return null;
END getRecValueMeaning;


end ITA_SETUP_REC_VALUES_PKG;

/
