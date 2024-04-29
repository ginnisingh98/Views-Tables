--------------------------------------------------------
--  DDL for Package Body PAY_UPGRADE_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_UPGRADE_DEFINITIONS_PKG" AS
/* $Header: pypud01t.pkb 120.1 2005/06/16 03:24 nmanchan noship $ */

g_package  varchar2(33) := '  pay_upgrade_definitions_pkg.';

PROCEDURE chk_short_name ( p_short_name in varchar2 ) is
--
cursor csr_unique_name is
	select null from pay_upgrade_definitions
		where upper(short_name) = upper(p_short_name);
--
l_proc   varchar2(72) := g_package||'chk_short_name';
l_exists varchar2(1);
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

	open csr_unique_name;
	fetch csr_unique_name into l_exists;

	if csr_unique_name%found then

		close csr_unique_name;
		fnd_message.set_name( 'PAY', 'PAY_33187_SHORT_NAME_EXISTS' );
	        fnd_message.raise_error;

	end if;
	close csr_unique_name;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END chk_short_name;


PROCEDURE chk_lookup( p_lookup_type in varchar2
	             ,p_lookup_code in varchar2
		     ,p_column      in varchar2
	            )
is
--
l_proc   varchar2(72) := g_package||'chk_lookup';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if hr_api.not_exists_in_hr_lookups
     (p_effective_date => trunc(sysdate)
     ,p_lookup_type    => p_lookup_type
     ,p_lookup_code    => p_lookup_code
     )
  then
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
    fnd_message.set_token('COLUMN', p_column);
    fnd_message.raise_error;
  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END chk_lookup;

PROCEDURE chk_mandatory_arg( p_argument in varchar2 , p_column in varchar2)
is
--
l_proc   varchar2(72) := g_package||'chk_mandatory_arg';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_argument is null then
	fnd_message.set_name( 'PAY', 'PAY_75178_NO_DATA' );
	fnd_message.set_token('VALUE1' , l_proc);
	fnd_message.set_token('VALUE2' , p_column) ;
        fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END chk_mandatory_arg;

PROCEDURE chk_legislation_code( p_legislation_code  in varchar2 )
is
--
cursor csr_legislation_code is
select null
from fnd_territories
where territory_code = p_legislation_code ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_legislation_code';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_legislation_code;
  fetch csr_legislation_code into l_exists ;

  if csr_legislation_code%notfound then
    close csr_legislation_code;
    fnd_message.set_name('PAY', 'PAY_33177_LEG_CODE_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_legislation_code;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END chk_legislation_code;

PROCEDURE chk_delete ( p_upgrade_definition_id in number )
is
--
cursor csr_delete is
	select null from pay_upgrade_status
	where
	upgrade_definition_id = p_upgrade_definition_id ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_delete';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_delete;
  fetch csr_delete into l_exists ;

  if csr_delete%found then
    close csr_delete;
    fnd_message.set_name('PAY', 'PAY_33188_DELETION_NOT_ALLOWED');
    fnd_message.raise_error;
  end if;
  close csr_delete;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END chk_delete;


PROCEDURE Insert_Row (
	 P_SHORT_NAME              in            VARCHAR2
        ,P_NAME			           in		     VARCHAR2
	,P_DESCRIPTION             in            VARCHAR2
	,P_LEGISLATION_CODE        in            VARCHAR2   default null
	,P_UPGRADE_LEVEL           in            VARCHAR2
	,P_CRITICALITY             in            VARCHAR2
	,P_FAILURE_POINT           in            VARCHAR2
	,P_LEGISLATIVELY_ENABLED   in            VARCHAR2
	,P_UPGRADE_PROCEDURE       in            VARCHAR2
	,P_THREADING_LEVEL         in            VARCHAR2
	,P_UPGRADE_METHOD          in            VARCHAR2
	,P_QUALIFYING_PROCEDURE    in            VARCHAR2   default null
	,P_OWNER_APPL_ID           in            NUMBER     default null
        ,P_FIRST_PATCHSET          in            VARCHAR2   default null
        ,P_VALIDATE_CODE           in            VARCHAR2   default null
        ,P_ADDITIONAL_INFO         in            VARCHAR2   default null
	,P_LAST_UPDATE_DATE	       in	         DATE
	,P_LAST_UPDATED_BY	       in	         NUMBER
	,P_LAST_UPDATE_LOGIN	   in	         NUMBER
	,P_CREATED_BY		       in	         NUMBER
	,P_CREATION_DATE	       in	         DATE
	,P_UPGRADE_DEFINITION_ID   out nocopy    NUMBER
) is
--
l_upgrade_definition_id PAY_UPGRADE_DEFINITIONS.UPGRADE_DEFINITION_ID%TYPE;
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'Insert_Row';

cursor csr_exists is
	select null from PAY_UPGRADE_DEFINITIONS
	    where upgrade_definition_id = l_upgrade_definition_id;

cursor csr_nextseq is
	select pay_upgrade_definitions_s.nextval from dual;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Check for mandatory arguments.

     chk_mandatory_arg( p_short_name ,'SHORT_NAME' );

     chk_mandatory_arg( p_name , 'NAME' );

     chk_mandatory_arg( p_description, 'DESCRIPTION' );

     chk_mandatory_arg( p_upgrade_level, 'UPGRADE_LEVEL' );

     chk_mandatory_arg( p_criticality, 'CRITICALITY' );

     chk_mandatory_arg( p_threading_level, 'THREADING_LEVEL' );

     chk_mandatory_arg( p_failure_point, 'FAILURE_POINT' );

     chk_mandatory_arg( p_legislatively_enabled, 'LEGISLATIVELY_ENABLED' );

     chk_mandatory_arg( p_upgrade_procedure, 'UPGRADE_PROCEDURE' );

     chk_mandatory_arg( p_upgrade_method, 'UPGRADE_METHOD');


  -- Check for Lookups

     chk_lookup( 'PAY_GEN_UPGRADE_LEVEL', p_upgrade_level ,'UPGRADE_LEVEL');

     chk_lookup( 'PAY_GEN_UPGRADE_CRITICALITY', p_criticality , 'CRITICALITY');

     chk_lookup( 'PAY_GEN_THREADING_LEVEL', p_threading_level, 'THREADING_LEVEL' );

     chk_lookup( 'PAY_GEN_FAILURE_POINT', p_failure_point, 'FAILURE_POINT' );

     chk_lookup( 'YES_NO', p_legislatively_enabled, 'LEGISLATIVELY_ENABLED' );

     chk_lookup( 'PAY_GEN_UPGRADE_METHOD', p_upgrade_method, 'UPGRADE_METHOD' );


  -- Check for Non Unique Short name.

     chk_short_name( p_short_name );


  -- Check for valid Legislation code.

     if p_legislation_code is not null then
	     chk_legislation_code( p_legislation_code );
     end if;


  -- Upgrade Level cannot be Global when legsislation code is not null.

     if p_legislation_code is not null and p_upgrade_level = 'G' then
	    fnd_message.set_name('PAY', 'PAY_33189_GLOBAL_LEG_UPGDEF');
	    fnd_message.raise_error;
     end if;

  -- Legislatively Enabled must be 'N' when legislation code is not null.

     if p_legislation_code is not null and p_legislatively_enabled <> 'N' then
	    fnd_message.set_name('PAY', 'PAY_33190_ENABLE_LEG_UPGDEF');
	    fnd_message.raise_error;
     end if;

     open csr_nextseq;
	    fetch csr_nextseq into l_upgrade_definition_id;
     close csr_nextseq;


    insert into PAY_UPGRADE_DEFINITIONS (
	UPGRADE_DEFINITION_ID,
	SHORT_NAME,
	NAME,
	DESCRIPTION,
	LEGISLATION_CODE,
	UPGRADE_LEVEL,
	CRITICALITY,
	FAILURE_POINT,
	LEGISLATIVELY_ENABLED,
	UPGRADE_PROCEDURE,
	THREADING_LEVEL,
	UPGRADE_METHOD,
	QUALIFYING_PROCEDURE,
	OWNER_APPLICATION_ID,
        FIRST_PATCHSET,
        VALIDATE_CODE,
        ADDITIONAL_INFO,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
	) values (
	l_upgrade_definition_id,
	p_short_name,
	p_name,
	p_description,
	p_legislation_code,
	p_upgrade_level,
	p_criticality,
	p_failure_point,
	p_legislatively_enabled,
	p_upgrade_procedure,
	p_threading_level,
	p_upgrade_method,
	p_qualifying_procedure,
	p_owner_appl_id,
        p_first_patchset,
        p_validate_code,
        p_additional_info,
	p_creation_date,
	p_created_by,
	p_last_update_date,
	p_last_updated_by,
	p_last_update_login   );

	insert into PAY_UPGRADE_DEFINITIONS_TL (
	    UPGRADE_DEFINITION_ID,
    	    LANGUAGE,
	    SOURCE_LANG,
	    NAME,
	    DESCRIPTION,
	    ADDITIONAL_INFO,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    CREATED_BY,
	    CREATION_DATE
	    ) select
	    l_upgrade_definition_id,
            l.language_code,
            userenv('lang'),
	    p_name,
    	    p_description,
    	    p_additional_info,
	    p_last_update_date,
	    p_last_updated_by,
	    p_last_update_login,
	    p_created_by,
	    p_creation_date
		    from FND_LANGUAGES L
		    where L.INSTALLED_FLAG in ('I', 'B')
		    and not exists
		    (select NULL
			    from PAY_UPGRADE_DEFINITIONS_TL T
			    where T.UPGRADE_DEFINITION_ID = l_UPGRADE_DEFINITION_ID
			    and T.LANGUAGE = L.LANGUAGE_CODE);


    open csr_exists;
    fetch csr_exists into l_exists;

    if csr_exists%notfound then
	close csr_exists;
	raise no_data_found;
    end if;

    p_upgrade_definition_id := l_upgrade_definition_id;

    close csr_exists;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END Insert_Row;

PROCEDURE Update_Row (
	  P_UPGRADE_DEFINITION_ID  in            NUMBER
        , P_CRITICALITY            in            VARCHAR2
	, P_FAILURE_POINT          in            VARCHAR2
        , P_UPGRADE_PROCEDURE      in            VARCHAR2
        , P_DESCRIPTION            in            VARCHAR2
	, P_QUALIFYING_PROCEDURE   in            VARCHAR2
	, P_OWNER_APPL_ID          in            NUMBER
        , P_FIRST_PATCHSET         in            VARCHAR2
        , P_VALIDATE_CODE          in            VARCHAR2
        , P_ADDITIONAL_INFO        in            VARCHAR2
        , P_LAST_UPDATE_DATE       in            DATE
	, P_LAST_UPDATED_BY        in            NUMBER
	, P_LAST_UPDATE_LOGIN      in            NUMBER
) is
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'Update_Row';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Check for mandatory arguments.

     chk_mandatory_arg( p_upgrade_definition_id, 'UPGRADE_DEFINITION_ID' );

     chk_mandatory_arg( p_description, 'DESCRIPTION' );

     chk_mandatory_arg( p_criticality, 'CRITICALITY' );

     chk_mandatory_arg( p_failure_point, 'FAILURE_POINT' );

     chk_mandatory_arg( p_upgrade_procedure, 'UPGRADE_PROCEDURE' );


  -- Check for Lookups

     chk_lookup( 'PAY_GEN_UPGRADE_CRITICALITY', p_criticality, 'CRITICALITY' );

     chk_lookup( 'PAY_GEN_FAILURE_POINT', p_failure_point, 'FAILURE_POINT' );


     update PAY_UPGRADE_DEFINITIONS set
            description = p_description,
	    criticality = p_criticality,
	    failure_point = p_failure_point,
	    upgrade_procedure = p_upgrade_procedure,
            qualifying_procedure = p_qualifying_procedure,
            owner_application_id = p_owner_appl_id,
            first_patchset = p_first_patchset,
            validate_code = p_validate_code,
            additional_info = p_additional_info,
	    last_update_date = p_last_update_date,
	    last_updated_by = p_last_updated_by,
	    last_update_login = p_last_update_login
	 where upgrade_definition_id = p_upgrade_definition_id;

     if (sql%notfound) then
         raise no_data_found;
     end if;

     update PAY_UPGRADE_DEFINITIONS_TL set
	    description = p_description,
	    additional_info = p_additional_info,
	    last_update_date = p_last_update_date,
	    last_updated_by = p_last_updated_by,
	    last_update_login = p_last_update_login,
	    source_lang = userenv('lang')
         where upgrade_definition_id = p_upgrade_definition_id
	   and userenv('lang') in (language, source_lang);

     if (sql%notfound) then
         raise no_data_found;
     end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END Update_Row;

PROCEDURE Lock_Row (
	  P_UPGRADE_DEFINITION_ID  in  NUMBER
	, P_SHORT_NAME             in  VARCHAR2
	, P_NAME		   in  VARCHAR2
	, P_LEGISLATION_CODE       in  VARCHAR2
	, P_UPGRADE_LEVEL          in  VARCHAR2
	, P_CRITICALITY            in  VARCHAR2
	, P_FAILURE_POINT          in  VARCHAR2
	, P_LEGISLATIVELY_ENABLED  in  VARCHAR2
	, P_UPGRADE_PROCEDURE      in  VARCHAR2
	, P_THREADING_LEVEL        in  VARCHAR2
	, P_DESCRIPTION            in  VARCHAR2
	, P_UPGRADE_METHOD         in  VARCHAR2
	, P_QUALIFYING_PROCEDURE   in  VARCHAR2
) is
--
cursor csr_lck is
   select
      SHORT_NAME,
      NAME,
      LEGISLATION_CODE,
      UPGRADE_LEVEL,
      CRITICALITY,
      FAILURE_POINT,
      LEGISLATIVELY_ENABLED,
      UPGRADE_PROCEDURE,
      THREADING_LEVEL,
      DESCRIPTION,
      UPGRADE_METHOD,
      QUALIFYING_PROCEDURE
      from PAY_UPGRADE_DEFINITIONS
	where UPGRADE_DEFINITION_ID = P_UPGRADE_DEFINITION_ID
	      for update of UPGRADE_DEFINITION_ID nowait;
--
cursor csr_lck_tl is
   select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
      from PAY_UPGRADE_DEFINITIONS_TL
	    where UPGRADE_DEFINITION_ID = P_UPGRADE_DEFINITION_ID
	      and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
		      for update of UPGRADE_DEFINITION_ID nowait;
--
recinfo csr_lck%rowtype;
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'Lock_Row';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Lock the Base table record.

     open csr_lck;
     fetch csr_lck into recinfo;
     if (csr_lck%notfound) then
	 close csr_lck;
	 fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
     end if;
     close csr_lck;

     if ( (recinfo.short_name = p_short_name)
      and ((recinfo.legislation_code = p_legislation_code)
           or ((recinfo.legislation_code is null) and (p_legislation_code is null)))
      and (recinfo.name = p_name)
      and (recinfo.description = p_description)
      and (recinfo.upgrade_level = p_upgrade_level)
      and (recinfo.criticality = p_criticality)
      and (recinfo.failure_point = p_failure_point)
      and (recinfo.legislatively_enabled = p_legislatively_enabled)
      and (recinfo.upgrade_procedure = p_upgrade_procedure)
      and (recinfo.threading_level = p_threading_level)
      and (recinfo.upgrade_method = p_upgrade_method )
      and ((recinfo.qualifying_procedure = p_qualifying_procedure)
           or ((recinfo.qualifying_procedure is null) and (p_qualifying_procedure is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in csr_lck_tl loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = p_DESCRIPTION)
         and (tlinfo.name = p_name)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  return;
  --
END Lock_Row;

PROCEDURE Delete_Row (
	P_UPGRADE_DEFINITION_ID in NUMBER
)is
--
l_proc   varchar2(100) := g_package || 'Delete_Row';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  chk_mandatory_arg( p_upgrade_definition_id, 'UPGRADE_DEFINITION_ID' );

  chk_delete ( p_upgrade_definition_id );

  delete from PAY_UPGRADE_LEGISLATIONS
  where UPGRADE_DEFINITION_ID = P_UPGRADE_DEFINITION_ID;

  delete from PAY_UPGRADE_DEFINITIONS_TL
  where UPGRADE_DEFINITION_ID = P_UPGRADE_DEFINITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PAY_UPGRADE_DEFINITIONS
  where UPGRADE_DEFINITION_ID = P_UPGRADE_DEFINITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END Delete_Row;

procedure ADD_LANGUAGE
is
BEGIN
  --
  delete from PAY_UPGRADE_DEFINITIONS_TL T
  where not exists
    (select NULL
    from PAY_UPGRADE_DEFINITIONS B
    where B.UPGRADE_DEFINITION_ID = T.UPGRADE_DEFINITION_ID
    );

  update PAY_UPGRADE_DEFINITIONS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PAY_UPGRADE_DEFINITIONS_TL B
    where B.UPGRADE_DEFINITION_ID = T.UPGRADE_DEFINITION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.UPGRADE_DEFINITION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.UPGRADE_DEFINITION_ID,
      SUBT.LANGUAGE
    from PAY_UPGRADE_DEFINITIONS_TL SUBB, PAY_UPGRADE_DEFINITIONS_TL SUBT
    where SUBB.UPGRADE_DEFINITION_ID = SUBT.UPGRADE_DEFINITION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into PAY_UPGRADE_DEFINITIONS_TL (
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    UPGRADE_DEFINITION_ID,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.UPGRADE_DEFINITION_ID,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_UPGRADE_DEFINITIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_UPGRADE_DEFINITIONS_TL T
    where T.UPGRADE_DEFINITION_ID = B.UPGRADE_DEFINITION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  --
END ADD_LANGUAGE;

PROCEDURE Load_Row (
          P_SHORT_NAME             in  VARCHAR2
	, P_NAME		           in  VARCHAR2
	, P_DESCRIPTION            in  VARCHAR2
	, P_LEGISLATION_CODE       in  VARCHAR2
	, P_UPGRADE_LEVEL          in  VARCHAR2
	, P_CRITICALITY            in  VARCHAR2
	, P_THREADING_LEVEL        in  VARCHAR2
	, P_FAILURE_POINT          in  VARCHAR2
	, P_LEGISLATIVELY_ENABLED  in  VARCHAR2
	, P_UPGRADE_PROCEDURE      in  VARCHAR2
	, P_UPGRADE_METHOD         in  VARCHAR2
	, P_QUALIFYING_PROCEDURE   in  VARCHAR2
	, P_OWNER_APPL_SHORT_NAME  in  VARCHAR2
	, P_FIRST_PATCHSET         in  VARCHAR2
	, P_VALIDATE_CODE          in  VARCHAR2
    , P_ADDITIONAL_INFO        in  VARCHAR2
    , P_OWNER		           in  VARCHAR2
) is
--
l_proc   varchar2(100) := g_package || 'Load_Row';
l_upgrade_definition_id PAY_UPGRADE_DEFINITIONS.UPGRADE_DEFINITION_ID%TYPE;

l_sysdate            date := sysdate;
l_created_by         PAY_UPGRADE_DEFINITIONS.CREATED_BY%TYPE;
l_creation_date      PAY_UPGRADE_DEFINITIONS.CREATION_DATE%TYPE;
l_last_updated_by    PAY_UPGRADE_DEFINITIONS.LAST_UPDATED_BY%TYPE;
l_last_update_login  PAY_UPGRADE_DEFINITIONS.LAST_UPDATE_LOGIN%TYPE;
l_last_update_date   PAY_UPGRADE_DEFINITIONS.LAST_UPDATE_DATE%TYPE;

cursor csr_existing is
   select  upgrade_definition_id
      from   pay_upgrade_definitions
	      where  upper(short_name) = upper(p_short_name) ;

CURSOR C_APPL IS
        select application_id
        from fnd_application
        where upper(application_short_name) = upper(P_OWNER_APPL_SHORT_NAME);

l_appl_id PAY_UPGRADE_DEFINITIONS.OWNER_APPLICATION_ID%type;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_owner = 'SEED' then
      hr_general2.init_fndload
	      (p_resp_appl_id => 801
	      ,p_user_id      => 1
	      );
  else
      hr_general2.init_fndload
	      (p_resp_appl_id => 801
	      ,p_user_id      => -1
	      );
  end if;

  -- Set the WHO Columns
  l_created_by        := fnd_global.user_id;
  l_creation_date     := l_sysdate;
  l_last_update_date  := l_sysdate;
  l_last_updated_by   := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;

 IF P_OWNER_APPL_SHORT_NAME IS NOT NULL THEN
    OPEN C_APPL;
    FETCH C_APPL INTO l_appl_id;

    IF C_APPL%NOTFOUND THEN
	CLOSE C_APPL;
	fnd_message.set_name('FND', 'AFDICT- ARG APPL');
	fnd_message.set_token('APPL', P_OWNER_APPL_SHORT_NAME);
        fnd_message.raise_error;
    END IF;
    CLOSE C_APPL;
  END IF;

  open csr_existing;
  fetch csr_existing into l_upgrade_definition_id;

  if csr_existing%FOUND then

     close csr_existing;
     Update_Row (
	  P_UPGRADE_DEFINITION_ID  =>  l_upgrade_definition_id
        , P_CRITICALITY            =>  p_criticality
        , P_FAILURE_POINT          =>  p_failure_point
        , P_UPGRADE_PROCEDURE      =>  p_upgrade_procedure
        , P_DESCRIPTION            =>  p_description
        , P_QUALIFYING_PROCEDURE   =>  p_qualifying_procedure
        , P_OWNER_APPL_ID          =>  l_appl_id
        , P_FIRST_PATCHSET         =>  p_first_patchset
        , P_VALIDATE_CODE          =>  p_validate_code
        , P_ADDITIONAL_INFO        =>  p_additional_info
        , P_LAST_UPDATE_DATE       =>  l_last_update_date
        , P_LAST_UPDATED_BY        =>  l_last_updated_by
        , P_LAST_UPDATE_LOGIN      =>  l_last_update_login
       );

  else

     close csr_existing;
     -- This is not an update . Call the insert_row procedure.
     --

     Insert_Row (
  	 P_SHORT_NAME              =>  p_short_name
        ,P_NAME			           =>  p_name
	,P_DESCRIPTION             =>  p_description
	,P_LEGISLATION_CODE        =>  p_legislation_code
	,P_UPGRADE_LEVEL           =>  p_upgrade_level
	,P_CRITICALITY             =>  p_criticality
	,P_FAILURE_POINT           =>  p_failure_point
	,P_LEGISLATIVELY_ENABLED   =>  p_legislatively_enabled
	,P_UPGRADE_PROCEDURE       =>  p_upgrade_procedure
	,P_THREADING_LEVEL         =>  p_threading_level
	,P_UPGRADE_METHOD          =>  p_upgrade_method
        ,P_QUALIFYING_PROCEDURE    =>  p_qualifying_procedure
        ,P_OWNER_APPL_ID          =>  l_appl_id
        ,P_FIRST_PATCHSET         =>  p_first_patchset
        ,P_VALIDATE_CODE          =>  p_validate_code
        ,P_ADDITIONAL_INFO        =>  p_additional_info
	,P_LAST_UPDATE_DATE	       =>  l_last_update_date
	,P_LAST_UPDATED_BY	       =>  l_last_updated_by
	,P_LAST_UPDATE_LOGIN	   =>  l_last_update_login
	,P_CREATED_BY		       =>  l_created_by
	,P_CREATION_DATE	       =>  l_creation_date
	,P_UPGRADE_DEFINITION_ID   =>  l_upgrade_definition_id
       );

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END Load_Row;

PROCEDURE Translate_Row (
       	  P_SHORT_NAME      in  VARCHAR2
	, P_NAME	    in  VARCHAR2
	, P_DESCRIPTION     in  VARCHAR2
	, P_ADDITIONAL_INFO  in varchar2
	, P_OWNER	    in  VARCHAR2
) is
--
l_proc   varchar2(100) := g_package || 'Translate_Row';
l_last_updated_by   number;
l_last_update_login number;
l_last_update_date  date;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if P_OWNER = 'SEED' then
      hr_general2.init_fndload
        (p_resp_appl_id => 801
        ,p_user_id      => 1
        );
  else
      hr_general2.init_fndload
        (p_resp_appl_id => 801
        ,p_user_id      => -1
        );
  end if;
  --
  l_last_updated_by   := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;
  l_last_update_date  := sysdate;
  --

  UPDATE pay_upgrade_definitions_tl
    SET name = nvl(p_name,name),
	description = nvl(p_description,description),
	additional_info = nvl(p_additional_info, additional_info),
        last_update_date  = l_last_update_date,
        last_updated_by   = l_last_updated_by,
        last_update_login = l_last_update_login,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND upgrade_definition_id in
        (SELECT pud.upgrade_definition_id
           FROM pay_upgrade_definitions pud
           WHERE upper(p_short_name) = upper(pud.short_name) );

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END Translate_Row;

END PAY_UPGRADE_DEFINITIONS_PKG;


/
