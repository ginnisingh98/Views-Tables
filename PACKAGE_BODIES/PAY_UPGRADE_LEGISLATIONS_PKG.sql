--------------------------------------------------------
--  DDL for Package Body PAY_UPGRADE_LEGISLATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_UPGRADE_LEGISLATIONS_PKG" AS
/* $Header: pypul01t.pkb 115.0 2003/11/21 03:07 tvankayl noship $ */

g_package  varchar2(33) := '  pay_upgrade_legislations_pkg.';

PROCEDURE chk_unique (  p_upgrade_definition_id in number
                      , p_legislation_code      in varchar2
) is
--
cursor csr_unique is
	select null from pay_upgrade_legislations
		where upgrade_definition_id = p_upgrade_definition_id
		and   legislation_code = p_legislation_code ;
--
l_proc   varchar2(72) := g_package||'chk_unique';
l_exists varchar2(1);
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

	open csr_unique;
	fetch csr_unique into l_exists;

	if csr_unique%found then

		close csr_unique;
		fnd_message.set_name( 'PAY', 'PAY_33191_UPG_LEG_EXISTS' );
	        fnd_message.raise_error;

	end if;
	close csr_unique;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END chk_unique;

PROCEDURE chk_mandatory_arg( p_argument in varchar2 , p_column in varchar2 )
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
	fnd_message.set_token('VALUE2' , p_column ) ;
        fnd_message.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END chk_mandatory_arg;

PROCEDURE chk_upgrade_definition_id( p_upgrade_definition_id in number )
is
--
l_legislatively_enabled PAY_UPGRADE_DEFINITIONS.LEGISLATIVELY_ENABLED%TYPE;
l_proc   varchar2(100) := g_package || 'chk_upgrade_definition_id';
--
cursor csr_upgrade_definition is
     select legislatively_enabled
	from pay_upgrade_definitions
	where upgrade_definition_id = p_upgrade_definition_id ;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_upgrade_definition ;
  fetch csr_upgrade_definition into l_legislatively_enabled;

  if csr_upgrade_definition%notfound then

	close csr_upgrade_definition;
	fnd_message.set_name('PAY', 'PAY_33192_INVALID_UPGDEF');
        fnd_message.raise_error;

  end if;
  close csr_upgrade_definition;

  if l_legislatively_enabled <> 'Y' then

	fnd_message.set_name('PAY', 'PAY_33193_UPG_CANNOT_ENABLE');
        fnd_message.raise_error;

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END chk_upgrade_definition_id;

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

PROCEDURE chk_delete ( p_upgrade_definition_id in number
                      ,p_legislation_code in varchar2 )
is
--
cursor csr_delete is
	select null from pay_upgrade_status
	where
	upgrade_definition_id = p_upgrade_definition_id
	and (
        ( legislation_code is not null and legislation_code = p_legislation_code )
	or ( business_group_id is not null and p_legislation_code = hr_api.return_legislation_code(business_group_id) ) );

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
	 P_UPGRADE_DEFINITION_ID   in            NUMBER
	,P_LEGISLATION_CODE        in            VARCHAR2
	,P_LAST_UPDATE_DATE	   in	         DATE
	,P_LAST_UPDATED_BY	   in	         NUMBER
	,P_LAST_UPDATE_LOGIN	   in	         NUMBER
	,P_CREATED_BY		   in	         NUMBER
	,P_CREATION_DATE	   in	         DATE
) is
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'Insert_Row';

cursor csr_exists is
	select null from PAY_UPGRADE_LEGISLATIONS
	    where upgrade_definition_id = p_upgrade_definition_id
	    and legislation_code = p_legislation_code;
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Check for mandatory arguments.

     chk_mandatory_arg( p_upgrade_definition_id , 'UPGRADE_DEFINITION_ID' );

     chk_mandatory_arg( p_legislation_code, 'LEGISLATION_CODE' );


  -- Check for valid Upgrade Definition.

     chk_upgrade_definition_id( p_upgrade_definition_id );


  -- Check for valid Legislation code.

     chk_legislation_code( p_legislation_code );


  -- Check for Uniqueness

     chk_unique( p_upgrade_definition_id, p_legislation_code );


    insert into PAY_UPGRADE_LEGISLATIONS (
	UPGRADE_DEFINITION_ID,
	LEGISLATION_CODE,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN
	) values (
	p_upgrade_definition_id,
	p_legislation_code,
	p_creation_date,
	p_created_by,
	p_last_update_date,
	p_last_updated_by,
	p_last_update_login   );

    open csr_exists;
    fetch csr_exists into l_exists;

    if csr_exists%notfound then
	close csr_exists;
	raise no_data_found;
    end if;

    close csr_exists;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END Insert_Row;

PROCEDURE Lock_Row (
	  P_UPGRADE_DEFINITION_ID  in  NUMBER
	, P_LEGISLATION_CODE       in  VARCHAR2
) is
--
cursor csr_lck is
   select null
      from PAY_UPGRADE_LEGISLATIONS
	where UPGRADE_DEFINITION_ID = P_UPGRADE_DEFINITION_ID
	  and LEGISLATION_CODE = P_LEGISLATION_CODE
	      for update of UPGRADE_DEFINITION_ID nowait;
--
recinfo csr_lck%rowtype;
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'Lock_Row';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Lock the table record.

     open csr_lck;
     fetch csr_lck into recinfo;
     if (csr_lck%notfound) then
	 close csr_lck;
	 fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
         app_exception.raise_exception;
     end if;
     close csr_lck;


  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  return;
  --
END Lock_Row;

PROCEDURE Delete_Row (
	P_UPGRADE_DEFINITION_ID in NUMBER
       ,P_LEGISLATION_CODE      in VARCHAR2
)is
--
l_proc   varchar2(100) := g_package || 'Delete_Row';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  chk_mandatory_arg( p_upgrade_definition_id , 'UPGRADE_DEFINITION_ID' );

  chk_mandatory_arg( p_legislation_code, 'LEGISLATION_CODE' );

  chk_delete ( p_upgrade_definition_id , p_legislation_code );

  delete from PAY_UPGRADE_LEGISLATIONS
  where UPGRADE_DEFINITION_ID = P_UPGRADE_DEFINITION_ID
    and LEGISLATION_CODE = P_LEGISLATION_CODE ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END Delete_Row;

PROCEDURE Load_Row (
       	  P_SHORT_NAME             in  VARCHAR2
	, P_LEGISLATION_CODE       in  VARCHAR2
	, P_OWNER		   in  VARCHAR2
) is
--
l_proc   varchar2(100) := g_package || 'Load_Row';
l_upgrade_definition_id PAY_UPGRADE_LEGISLATIONS.UPGRADE_DEFINITION_ID%TYPE;

l_sysdate            date := sysdate;
l_created_by         PAY_UPGRADE_LEGISLATIONS.CREATED_BY%TYPE;
l_creation_date      PAY_UPGRADE_LEGISLATIONS.CREATION_DATE%TYPE;
l_last_updated_by    PAY_UPGRADE_LEGISLATIONS.LAST_UPDATED_BY%TYPE;
l_last_update_login  PAY_UPGRADE_LEGISLATIONS.LAST_UPDATE_LOGIN%TYPE;
l_last_update_date   PAY_UPGRADE_LEGISLATIONS.LAST_UPDATE_DATE%TYPE;

cursor csr_existing is
   select  pul.upgrade_definition_id
      from   pay_upgrade_definitions pud, pay_upgrade_legislations pul
	     where  upper(pud.short_name) = upper(p_short_name)
	     and pud.upgrade_definition_id = pul.upgrade_definition_id
	     and pul.legislation_code = p_legislation_code;

cursor csr_upgrade_definition_id is
   select  pud.upgrade_definition_id
      from   pay_upgrade_definitions pud
	     where  upper(pud.short_name) = upper(p_short_name);

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


  open csr_existing;
  fetch csr_existing into l_upgrade_definition_id;

  if csr_existing%FOUND then

     close csr_existing;
     return;
  else

     close csr_existing;

     -- Get the parent upgrade definition id.

       open csr_upgrade_definition_id;
       fetch csr_upgrade_definition_id into l_upgrade_definition_id;

	  if csr_upgrade_definition_id%notfound then
     	     close csr_upgrade_definition_id;

	     fnd_message.set_name('PAY', 'PAY_33192_INVALID_UPGDEF');
	     fnd_message.raise_error;
	  end if;

     close csr_upgrade_definition_id;


     Insert_Row (
     	 P_UPGRADE_DEFINITION_ID   =>  l_upgrade_definition_id
	,P_LEGISLATION_CODE        =>  p_legislation_code
	,P_LAST_UPDATE_DATE	   =>  l_last_update_date
	,P_LAST_UPDATED_BY	   =>  l_last_updated_by
	,P_LAST_UPDATE_LOGIN	   =>  l_last_update_login
	,P_CREATED_BY		   =>  l_created_by
	,P_CREATION_DATE	   =>  l_creation_date
       );

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END Load_Row;

END PAY_UPGRADE_LEGISLATIONS_PKG;


/
