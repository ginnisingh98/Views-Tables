--------------------------------------------------------
--  DDL for Package Body PAY_CUST_RESTRICTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CUST_RESTRICTIONS_PKG" as
/* $Header: pypcr01t.pkb 115.8 2003/07/02 05:56:37 tvankayl ship $ */
--
procedure unique_chk(x_form_name in VARCHAR2, x_name in VARCHAR2,X_LEGISLATION_CODE in VARCHAR2)
is
  result varchar2(255);
Begin
  SELECT count(*) INTO result
  FROM PAY_CUSTOMIZED_RESTRICTIONS
  WHERE UPPER(FORM_NAME) = UPPER(x_form_name)
  and   UPPER(NAME) = UPPER(x_name)
  and   BUSINESS_GROUP_ID is NULL
  and   nvl(LEGISLATION_CODE,'~null~') = nvl(X_LEGISLATION_CODE,'~null~');
  --
  IF (result>1) THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_CUST_RESTRICTIONS_PKG.UNIQUE_CHK');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  EXCEPTION
  when NO_DATA_FOUND then
    null;
end unique_chk;
--

PROCEDURE LOAD_ROW( X_APPLICATION_SHORT_NAME VARCHAR2,
		    X_LEGISLATION_CODE   VARCHAR2,
                    X_FORM_NAME          VARCHAR2,
                    X_NAME               VARCHAR2,
                    X_ENABLED_FLAG       VARCHAR2,
                    X_COMMENTS           VARCHAR2,
                    X_LEGISLATION_SUBGROUP VARCHAR2,
                    X_OWNER              VARCHAR2,
                    X_QUERY_FORM_TITLE   VARCHAR2,
                    X_STANDARD_FORM_TITLE  VARCHAR2
		    )
is
  l_proc                        VARCHAR2(61) := 'PAY_CUST_RESTRICTIONS_PKG.LOAD_ROW';
  l_rowid                       rowid;
  l_created_by                  PAY_CUSTOMIZED_RESTRICTIONS.created_by%TYPE             := 0;
  l_creation_date               PAY_CUSTOMIZED_RESTRICTIONS.creation_date%TYPE          := SYSDATE;
  l_last_update_date            PAY_CUSTOMIZED_RESTRICTIONS.last_update_date%TYPE       := SYSDATE;
  l_last_updated_by             PAY_CUSTOMIZED_RESTRICTIONS.last_updated_by%TYPE         := 0;
  l_last_update_login           PAY_CUSTOMIZED_RESTRICTIONS.last_update_login%TYPE      := 0;
  l_cust_rest_id                PAY_CUSTOMIZED_RESTRICTIONS.customized_restriction_id%TYPE ;
  l_appl_id                     PAY_CUSTOMIZED_RESTRICTIONS.application_id%TYPE;
  l_legislation_subgroup        PAY_CUSTOMIZED_RESTRICTIONS.legislation_subgroup%TYPE;



  CURSOR C_APPL IS
        select application_id
        from fnd_application
        where application_short_name = upper(X_APPLICATION_SHORT_NAME);

   CURSOR C1  IS
 	select customized_restriction_id,application_id,legislation_subgroup
	from    PAY_CUSTOMIZED_RESTRICTIONS pcr
        where   upper(pcr.form_name) = upper(X_FORM_NAME)
        and     upper(pcr.name) = upper(X_NAME)
	and     pcr.business_group_id is null
        and     nvl(pcr.legislation_code,'~null~') = nvl(X_LEGISLATION_CODE,'~null~');


begin

  -- Translate developer keys to internal parameters

  if X_OWNER = 'SEED' then
    l_created_by := 1;
    l_last_updated_by := 1;
  end if;

  -- Update or insert row as appropriate
  begin


  OPEN C1;
  FETCH C1 INTO l_cust_rest_id , l_appl_id, l_legislation_subgroup;
  IF C1%NOTFOUND THEN
	close C1;
	raise no_data_found;
  ELSE
         close C1;
  END IF;


    PER_CUSTOMIZED_RESTR_PKG.UPDATE_ROW
      (	X_CUSTOMIZED_RESTRICTION_ID => l_cust_rest_id
      ,X_APPLICATION_ID   => l_appl_id
      ,X_FORM_NAME                => X_FORM_NAME
      ,X_NAME                     => X_NAME
      ,X_BUSINESS_GROUP_ID        => null
      ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
      ,X_ENABLED_FLAG             => X_ENABLED_FLAG
      ,X_QUERY_FORM_TITLE         => X_QUERY_FORM_TITLE
      ,X_STANDARD_FORM_TITLE      => X_STANDARD_FORM_TITLE
      ,X_COMMENTS                 => X_COMMENTS
      ,X_LEGISLATION_SUBGROUP     => nvl(X_LEGISLATION_SUBGROUP,l_legislation_subgroup)
      ,X_LAST_UPDATE_DATE         => l_last_update_date
      ,X_LAST_UPDATED_BY          => l_last_updated_by
      ,X_LAST_UPDATE_LOGIN        => l_last_update_login
      );
  exception
    when no_data_found then

    OPEN C_APPL;
    FETCH C_APPL INTO l_appl_id;
    CLOSE C_APPL;


      PER_CUSTOMIZED_RESTR_PKG.INSERT_ROW
        (X_ROWID                    => l_rowid
	,X_CUSTOMIZED_RESTRICTION_ID => l_cust_rest_id
        ,X_APPLICATION_ID   => l_appl_id
        ,X_FORM_NAME                => X_FORM_NAME
        ,X_NAME                     => X_NAME
        ,X_BUSINESS_GROUP_ID        => null
        ,X_LEGISLATION_CODE         => X_LEGISLATION_CODE
        ,X_ENABLED_FLAG             => X_ENABLED_FLAG
        ,X_QUERY_FORM_TITLE         => X_QUERY_FORM_TITLE
        ,X_STANDARD_FORM_TITLE      => X_STANDARD_FORM_TITLE
	,X_COMMENTS                 => X_COMMENTS
        ,X_LEGISLATION_SUBGROUP     => X_LEGISLATION_SUBGROUP
        ,X_CREATED_BY               => l_created_by
        ,X_CREATION_DATE            => l_creation_date
        ,X_LAST_UPDATE_DATE         => l_last_update_date
        ,X_LAST_UPDATED_BY          => l_last_updated_by
        ,X_LAST_UPDATE_LOGIN        => l_last_update_login
        );
  end;
end LOAD_ROW;


PROCEDURE TRANSLATE_ROW( X_LEGISLATION_CODE   VARCHAR2,
                    X_FORM_NAME          VARCHAR2,
                    X_NAME               VARCHAR2,
                    X_OWNER              VARCHAR2,
                    X_QUERY_FORM_TITLE   VARCHAR2,
                    X_STANDARD_FORM_TITLE  VARCHAR2 )
is

	l_cust_rest_id       PAY_CUSTOMIZED_RESTRICTIONS.customized_restriction_id%TYPE ;

	CURSOR C1  IS
	 	select customized_restriction_id
 		from    PAY_CUSTOMIZED_RESTRICTIONS pcr
		where   upper(pcr.form_name) = upper(X_FORM_NAME)
	        and     upper(pcr.name) = upper(X_NAME)
		and     pcr.business_group_id is null
		and     nvl(pcr.legislation_code,'~null~') = nvl(X_LEGISLATION_CODE,'~null~') ;
begin
  -- unique_chk(X_FORM_NAME,X_NAME,X_LEGISLATION_CODE);
  --


OPEN C1;
  FETCH C1 INTO l_cust_rest_id ;
    if C1%FOUND then
    UPDATE PAY_CUSTOM_RESTRICTIONS_TL
	    SET QUERY_FORM_TITLE=nvl(X_QUERY_FORM_TITLE,QUERY_FORM_TITLE),
	        STANDARD_FORM_TITLE=nvl(X_STANDARD_FORM_TITLE,STANDARD_FORM_TITLE),
		last_update_date = SYSDATE,
	        last_updated_by = decode(x_owner,'SEED',1,0),
		last_update_login = 0,
		SOURCE_LANG = userenv('LANG')
	  WHERE customized_restriction_id = l_cust_rest_id
	    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    END IF;

CLOSE C1;

  --
  if (sql%notfound) then  -- trap system errors during update
  --    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  --    hr_utility.set_message_token ('PROCEDURE','PAY_CUST_RESTRICTIONS_PKG.TRANSLATE_ROW');
  --    hr_utility.set_message_token('STEP','1');
  --    hr_utility.raise_error;
  null;
  end if;
end TRANSLATE_ROW;

-----------------------------------------------------------------------------
END PAY_CUST_RESTRICTIONS_PKG;

/
