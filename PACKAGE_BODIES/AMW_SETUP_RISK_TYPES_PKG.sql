--------------------------------------------------------
--  DDL for Package Body AMW_SETUP_RISK_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_SETUP_RISK_TYPES_PKG" as
/* $Header: amwtrtpb.pls 120.3 2006/08/23 19:06:19 npanandi noship $ */


-- ===============================================================
-- Package name
--          AMW_SETUP_RISK_TYPES_PKG
-- Purpose
--
-- History
-- 		  	07/06/2004    tsho     Creates
-- ===============================================================


-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new compliance environment
--          in AMW_SETUP_RISK_TYPES_B and AMW_SETUP_RISK_TYPES_TL
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2
) is
  cursor C is select ROWID from AMW_SETUP_RISK_TYPES_B
    where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID;
begin
  insert into AMW_SETUP_RISK_TYPES_B (
  SETUP_RISK_TYPE_ID,
  RISK_TYPE_CODE,
  PARENT_SETUP_RISK_TYPE_ID,
  START_DATE,
  END_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  OBJECT_VERSION_NUMBER,
  TAG
  ) values (
  X_SETUP_RISK_TYPE_ID,
  X_RISK_TYPE_CODE,
  X_PARENT_SETUP_RISK_TYPE_ID,
  X_START_DATE,
  X_END_DATE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_DATE,
  X_CREATED_BY,
  X_CREATION_DATE,
  X_LAST_UPDATE_LOGIN,
  X_SECURITY_GROUP_ID,
  X_OBJECT_VERSION_NUMBER,
  X_TAG
  );

  insert into AMW_SETUP_RISK_TYPES_TL (
    LAST_UPDATE_LOGIN,
    SETUP_RISK_TYPE_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_SETUP_RISK_TYPE_ID,
    X_SETUP_RISK_TYPE_NAME,
    X_SETUP_RISK_TYPE_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMW_SETUP_RISK_TYPES_TL T
    where T.SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2
) is
  cursor c is select
    RISK_TYPE_CODE,
    START_DATE,
    END_DATE,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    TAG
    from AMW_SETUP_RISK_TYPES_B
    where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID
      and PARENT_SETUP_RISK_TYPE_ID = X_PARENT_SETUP_RISK_TYPE_ID
    for update of SETUP_RISK_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMW_SETUP_RISK_TYPES_TL
    where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SETUP_RISK_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
          ((recinfo.RISK_TYPE_CODE = X_RISK_TYPE_CODE)
           OR ((recinfo.RISK_TYPE_CODE is null) AND (X_RISK_TYPE_CODE is null)))
      AND ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.TAG = X_TAG)
           OR ((recinfo.TAG is null) AND (X_TAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_SETUP_RISK_TYPE_NAME)
          AND ((tlinfo.DESCRIPTION = X_SETUP_RISK_TYPE_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_SETUP_RISK_TYPE_DESCRIPTION is null)))
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



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
--          update AMW_SETUP_RISK_TYPES_B and AMW_SETUP_RISK_TYPES_TL
-- ===============================================================
procedure UPDATE_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2
) is
begin
  update AMW_SETUP_RISK_TYPES_B set
    RISK_TYPE_CODE = X_RISK_TYPE_CODE,
    PARENT_SETUP_RISK_TYPE_ID = X_PARENT_SETUP_RISK_TYPE_ID,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TAG = X_TAG
  where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMW_SETUP_RISK_TYPES_TL set
    NAME = X_SETUP_RISK_TYPE_NAME,
    DESCRIPTION = X_SETUP_RISK_TYPE_DESCRIPTION,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


-- ===============================================================
-- Procedure name
--          LOAD_ROW
-- Purpose
--          load AMW_SETUP_RISK_TYPE to AMW_SETUP_RISK_TYPES_B(_TL)
-- ===============================================================
procedure LOAD_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_RISK_TYPE_CODE in VARCHAR2,
  X_PARENT_SETUP_RISK_TYPE_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAG in VARCHAR2,
  X_SETUP_RISK_TYPE_NAME in VARCHAR2,
  X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  /** 08.23.2006 npanandi: bug 5486153 fix -- no need to pass
      X_PARENT_SETUP_RISK_TYPE_NAME, as it creates translation issues
  X_PARENT_SETUP_RISK_TYPE_NAME in VARCHAR2,
  **/
  X_COMPLIANCE_ENV_ID in NUMBER
) IS

  l_user_id number;
  l_setup_risk_type_id number;
  l_parent_setup_risk_type_id number;
  l_risk_type_code varchar2(30);
  l_existed_setup_risk_type_id number;
  l_existed_risk_type_code varchar2(30);
  l_row_id varchar2(32767);
  l_setup_risk_type_name varchar2(240);
  l_parent_setup_risk_type_name varchar2(240);
  l_compliance_env_id number;

  l_return_status			varchar2(1);
  l_msg_count			number;
  l_msg_data			varchar2(2000);

  cursor is_setup_risk_type_exist(l_setup_risk_type_name in varchar2) is
    select b.setup_risk_type_id
      from amw_setup_risk_types_b b
          ,amw_setup_risk_types_tl tl
     where b.setup_risk_type_id = tl.setup_risk_type_id
       and tl.LANGUAGE = USERENV('LANG')
       and tl.name = l_setup_risk_type_name;

  cursor is_risk_type_code_exist(l_risk_type_code in varchar2) is
    select b.risk_type_code
      from amw_setup_risk_types_b b
     where b.risk_type_code = l_risk_type_code;

  cursor get_new_setup_risk_type_id is
    select AMW_SETUP_RISK_TYPE_S.nextval
      from dual;

BEGIN
	-- Translate owner to file_last_updated_by
	l_user_id := fnd_load_util.owner_id(X_OWNER);

    l_setup_risk_type_name := X_SETUP_RISK_TYPE_NAME;
    /** 08.23.2006 npanandi: bug 5486153 fix --- X_PARENT_SETUP_RISK_TYPE_NAME
        is not being passed
    l_parent_setup_risk_type_name := X_PARENT_SETUP_RISK_TYPE_NAME;
    **/
    l_parent_setup_risk_type_id := X_PARENT_SETUP_RISK_TYPE_ID;
    l_risk_type_code := X_RISK_TYPE_CODE;
    l_existed_setup_risk_type_id := null;
    l_existed_risk_type_code := null;
    l_compliance_env_id := X_COMPLIANCE_ENV_ID;


    -- 10.26.2004 tsho: should handle loading Setup Risk Types other than Root
    IF (X_SETUP_RISK_TYPE_ID <> -1) THEN
      /*** 06.06.06 npanandi: commenting the below irrelevant portion because of
           AppsRe bug 5282548 consideration -- below DELETEs et.al. are causing
           major issues in an NLS environment, so the idea here is to adhere
           to the standard LDT load_row format (i.e. w/o- any DELETEs)
           to the extent possible
       ***/

      /***
      IF (l_setup_risk_type_name is not null) THEN
        OPEN is_setup_risk_type_exist (l_setup_risk_type_name);
        FETCH is_setup_risk_type_exist INTO l_existed_setup_risk_type_id;
        CLOSE is_setup_risk_type_exist;

        -- Delete specified existing risk type and its descendant.
        -- Delete associations records in AMW_COMPLIANCE_ENV_ASSOCS
        -- for the specified existing risk type and its descendant.
        IF(l_existed_setup_risk_type_id is not null) THEN
   	      AMW_SETUP_RISK_TYPES_PVT.Delete_Risk_Types(
    			p_setup_risk_type_id  => l_existed_setup_risk_type_id,
	    		x_return_status       => l_return_status,
    			x_msg_count           => l_msg_count,
    			x_msg_data            => l_msg_data);
        END IF;

        -- get the new setup_risk_type_id
        OPEN get_new_setup_risk_type_id;
        FETCH get_new_setup_risk_type_id INTO l_setup_risk_type_id;
        CLOSE get_new_setup_risk_type_id;
        ***/

        -- find out the parent_setup_risk_type_id if passed-in X_PARENT_SETUP_RISK_TYPE_NAME is not null
        -- otherwise, use passed-in X_PARENT_SETUP_RISK_TYPE_ID as l_parent_setup_risk_type_id
        /** 08.23.2006 npanandi: bug 5486153 fix --- logic around
             parentSetupriskTypeName is removed, due to translation issues
        IF (l_parent_setup_risk_type_name is not null) THEN
          OPEN is_setup_risk_type_exist (l_parent_setup_risk_type_name);
          FETCH is_setup_risk_type_exist INTO l_parent_setup_risk_type_id;
          CLOSE is_setup_risk_type_exist;
        END IF;
        **/

       /**** 06.06.06 npanandi: AppsRe bug 5282548 -- commenting below too
             for the reasons mentioned above
        ****/

        /**
        -- check if the specified risk_type_code is in used already
        IF (l_risk_type_code is not null) THEN
          OPEN is_risk_type_code_exist (l_risk_type_code);
          FETCH is_risk_type_code_exist INTO l_existed_risk_type_code;
          CLOSE is_risk_type_code_exist;

          IF (l_existed_risk_type_code is not null) THEN
            l_risk_type_code := l_setup_risk_type_id;
          END IF;
        END IF;
        **/

        /*** 06.06.06 npanandi: AppsRe bug 5282548 --- added begin clause
             to handle updates/inserts
         ***/
        begin
           AMW_SETUP_RISK_TYPES_PKG.UPDATE_ROW (
              X_SETUP_RISK_TYPE_ID          => X_SETUP_RISK_TYPE_ID,
              X_RISK_TYPE_CODE              => X_RISK_TYPE_CODE,
              /*** X_PARENT_SETUP_RISK_TYPE_ID   => X_PARENT_SETUP_RISK_TYPE_ID, ***/
              X_PARENT_SETUP_RISK_TYPE_ID   => l_parent_setup_risk_type_id,
              X_START_DATE                  => X_START_DATE,
              X_END_DATE                    => X_END_DATE,
              X_LAST_UPDATED_BY             => l_user_id,
              X_LAST_UPDATE_DATE            => sysdate,
              X_LAST_UPDATE_LOGIN           => 0,
              X_SECURITY_GROUP_ID           => X_SECURITY_GROUP_ID,
              X_OBJECT_VERSION_NUMBER       => X_OBJECT_VERSION_NUMBER,
              X_TAG                         => X_TAG,
              X_SETUP_RISK_TYPE_NAME        => X_SETUP_RISK_TYPE_NAME,
              X_SETUP_RISK_TYPE_DESCRIPTION => X_SETUP_RISK_TYPE_DESCRIPTION);
        exception
           when no_data_found then
              AMW_SETUP_RISK_TYPES_PKG.INSERT_ROW(
                 X_ROWID                       => l_row_id,
                 /*** 06.06.06 npanandi: the insert row here should take seeded
                      setupRiskTypeId, NOT any sequence generated one
                 X_SETUP_RISK_TYPE_ID          => l_setup_risk_type_id, **/
                 X_SETUP_RISK_TYPE_ID          => X_SETUP_RISK_TYPE_ID,
                 X_RISK_TYPE_CODE              => X_RISK_TYPE_CODE, /**l_risk_type_code,**/
                 X_PARENT_SETUP_RISK_TYPE_ID   => l_parent_setup_risk_type_id,
                 X_START_DATE                  => X_START_DATE,
                 X_END_DATE                    => X_END_DATE,
                 X_LAST_UPDATED_BY             => l_user_id,
                 X_LAST_UPDATE_DATE            => sysdate,
                 X_CREATED_BY                  => l_user_id,
                 X_CREATION_DATE               => sysdate,
                 X_LAST_UPDATE_LOGIN           => 0,
                 X_SECURITY_GROUP_ID           => X_SECURITY_GROUP_ID,
                 X_OBJECT_VERSION_NUMBER       => 1,
                 X_TAG                         => X_TAG,
                 X_SETUP_RISK_TYPE_NAME        => X_SETUP_RISK_TYPE_NAME,
                 X_SETUP_RISK_TYPE_DESCRIPTION => X_SETUP_RISK_TYPE_DESCRIPTION);

              -- check if default compliance env id is specified to associate with
              IF (l_compliance_env_id is not null) THEN
                 AMW_COMPLIANCE_ENV_ASSOCS_PVT.PROCESS_COMPLIANCE_ENV_ASSOCS (
                    p_select_flag         => 'Y',
                    p_compliance_env_id   => l_compliance_env_id,
                    p_object_type         => 'SETUP_RISK_TYPE',
                    p_pk1                 => X_SETUP_RISK_TYPE_ID, /**l_setup_risk_type_id,**/
   		            x_return_status       => l_return_status,
    		        x_msg_count           => l_msg_count,
    		        x_msg_data            => l_msg_data);
              END IF; -- end of if: l_compliance_env_id is not null
         /*** END IF; -- end of if: l_setup_risk_type_name is not null ***/
        end; /** end of begin,exception for handling updates/inserts **/
    ELSE
      -- handle Root Setup Risk Type (aka, X_SETUP_RISK_TYPE_ID = -1)
      BEGIN
    	select SETUP_RISK_TYPE_ID into l_setup_risk_type_id
  	      from AMW_SETUP_RISK_TYPES_B
    	 where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID;

        AMW_SETUP_RISK_TYPES_PKG.UPDATE_ROW (
              X_SETUP_RISK_TYPE_ID          => X_SETUP_RISK_TYPE_ID,
              X_RISK_TYPE_CODE              => X_RISK_TYPE_CODE,
              X_PARENT_SETUP_RISK_TYPE_ID   => X_PARENT_SETUP_RISK_TYPE_ID,
              X_START_DATE                  => X_START_DATE,
              X_END_DATE                    => X_END_DATE,
              X_LAST_UPDATED_BY             => l_user_id,
              X_LAST_UPDATE_DATE            => sysdate,
              X_LAST_UPDATE_LOGIN           => 0,
              X_SECURITY_GROUP_ID           => X_SECURITY_GROUP_ID,
              X_OBJECT_VERSION_NUMBER       => X_OBJECT_VERSION_NUMBER,
              X_TAG                         => X_TAG,
              X_SETUP_RISK_TYPE_NAME        => X_SETUP_RISK_TYPE_NAME,
              X_SETUP_RISK_TYPE_DESCRIPTION => X_SETUP_RISK_TYPE_DESCRIPTION);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    -- 07.29.2004 tsho: should use the passed-in x_setup_risk_type_id
 	    /*
         select AMW_SETUP_RISK_TYPE_S.nextval into l_setup_risk_type_id
           from dual;
	    */

        AMW_SETUP_RISK_TYPES_PKG.INSERT_ROW(
              X_ROWID                      => l_row_id,
              X_SETUP_RISK_TYPE_ID          => X_SETUP_RISK_TYPE_ID,
              X_RISK_TYPE_CODE              => X_RISK_TYPE_CODE,
              X_PARENT_SETUP_RISK_TYPE_ID   => X_PARENT_SETUP_RISK_TYPE_ID,
              X_START_DATE                  => X_START_DATE,
              X_END_DATE                    => X_END_DATE,
              X_LAST_UPDATED_BY             => l_user_id,
              X_LAST_UPDATE_DATE            => sysdate,
              X_CREATED_BY                  => l_user_id,
              X_CREATION_DATE               => sysdate,
              X_LAST_UPDATE_LOGIN           => 0,
              X_SECURITY_GROUP_ID           => X_SECURITY_GROUP_ID,
              X_OBJECT_VERSION_NUMBER       => 1,
              X_TAG                         => X_TAG,
              X_SETUP_RISK_TYPE_NAME        => X_SETUP_RISK_TYPE_NAME,
              X_SETUP_RISK_TYPE_DESCRIPTION => X_SETUP_RISK_TYPE_DESCRIPTION);
      END;

    END IF; -- end of if: X_SETUP_RISK_TYPE_ID <> -1


END LOAD_ROW;


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_SETUP_RISK_TYPE_ID in NUMBER,
  X_PARENT_SETUP_RISK_TYPE_ID  in NUMBER
) is
begin
  delete from AMW_SETUP_RISK_TYPES_B
  where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID
    and PARENT_SETUP_RISK_TYPE_ID = X_PARENT_SETUP_RISK_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_SETUP_RISK_TYPES_TL
  where SETUP_RISK_TYPE_ID = X_SETUP_RISK_TYPE_ID
    and SETUP_RISK_TYPE_ID not in (
        select SETUP_RISK_TYPE_ID from AMW_SETUP_RISK_TYPES_B
        )
    and SETUP_RISK_TYPE_ID not in (
        select PARENT_SETUP_RISK_TYPE_ID from AMW_SETUP_RISK_TYPES_B
        );

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;



-- ===============================================================
-- Procedure name
--          ADD_LANGUAGE
-- Purpose
--
-- ===============================================================
procedure ADD_LANGUAGE
is
begin
  delete from AMW_SETUP_RISK_TYPES_TL T
  where not exists
    (select NULL
    from AMW_SETUP_RISK_TYPES_B B
    where B.SETUP_RISK_TYPE_ID = T.SETUP_RISK_TYPE_ID
    );

  update AMW_SETUP_RISK_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMW_SETUP_RISK_TYPES_TL B
    where B.SETUP_RISK_TYPE_ID = T.SETUP_RISK_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SETUP_RISK_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SETUP_RISK_TYPE_ID,
      SUBT.LANGUAGE
    from AMW_SETUP_RISK_TYPES_TL SUBB, AMW_SETUP_RISK_TYPES_TL SUBT
    where SUBB.SETUP_RISK_TYPE_ID = SUBT.SETUP_RISK_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_SETUP_RISK_TYPES_TL (
    LAST_UPDATE_LOGIN,
    SETUP_RISK_TYPE_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.SETUP_RISK_TYPE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMW_SETUP_RISK_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_SETUP_RISK_TYPES_TL T
    where T.SETUP_RISK_TYPE_ID = B.SETUP_RISK_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/**05.31.2006 npanandi: bug 5259681 fix, added translate row***/
procedure TRANSLATE_ROW(
	X_SETUP_RISK_TYPE_ID		  in NUMBER,
	X_SETUP_RISK_TYPE_NAME        in VARCHAR2,
    X_SETUP_RISK_TYPE_DESCRIPTION in VARCHAR2,
	X_LAST_UPDATE_DATE    	      in VARCHAR2,
	X_OWNER			              in VARCHAR2,
	X_CUSTOM_MODE		          in VARCHAR2) is

   f_luby	 number;	-- entity owner in file
   f_ludate	 date;	    -- entity update date in file
   db_luby	 number;	-- entity owner in db
   db_ludate date;		-- entity update date in db
begin
   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.owner_id(X_OWNER);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

   select last_updated_by, last_update_date
     into db_luby, db_ludate
	 from AMW_SETUP_RISK_TYPES_TL
	where setup_risk_type_id = X_SETUP_RISK_TYPE_ID
	  and language = userenv('LANG');

   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, X_CUSTOM_MODE)) then
      update AMW_SETUP_RISK_TYPES_TL
	     set name	            = X_SETUP_RISK_TYPE_NAME,
		     description        = nvl(X_SETUP_RISK_TYPE_DESCRIPTION, description),
			 source_lang		= userenv('LANG'),
		     last_update_date	= f_ludate,
		     last_updated_by	= f_luby,
		     last_update_login	= 0
	   where setup_risk_type_id = X_SETUP_RISK_TYPE_ID
	     and userenv('LANG') in (language, source_lang);
   end if;

end TRANSLATE_ROW;
/**05.31.2006 npanandi: bug 5259681 fix ends***/


-- ----------------------------------------------------------------------
end AMW_SETUP_RISK_TYPES_PKG;

/
