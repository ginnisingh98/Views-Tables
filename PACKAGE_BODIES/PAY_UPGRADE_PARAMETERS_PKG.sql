--------------------------------------------------------
--  DDL for Package Body PAY_UPGRADE_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_UPGRADE_PARAMETERS_PKG" AS
/* $Header: pypup01t.pkb 120.1 2005/07/07 03:58 rajeesha noship $ */

g_package  varchar2(33) := '  pay_upgrade_parameters_pkg.';


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


PROCEDURE Insert_Row (
	 P_UPG_DEF_SHORT_NAME      in            VARCHAR2
	,P_PARAMETER_NAME	   in		 VARCHAR2
	,P_PARAMETER_VALUE         in            VARCHAR2
	,P_last_update_date        in            DATE
	,P_LAST_UPDATED_BY         in            NUMBER
	,P_LAST_UPDATE_LOGIN       in            NUMBER
	,P_CREATED_BY              in            NUMBER
	,P_CREATION_DATE           in            DATE

) is
--
l_upgrade_definition_id PAY_UPGRADE_DEFINITIONS.UPGRADE_DEFINITION_ID%TYPE;
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'Insert_Row';

cursor csr_exists is
	select  upgrade_definition_id
      from   pay_upgrade_definitions
	      where  upper(short_name) = upper(p_upg_def_short_name);
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Check for mandatory arguments.

  chk_mandatory_arg( p_upg_def_short_name, 'SHORT_NAME' );

  chk_mandatory_arg( p_parameter_name, 'PARAMETER_NAME' );

  --

  open csr_exists;
  fetch csr_exists into l_upgrade_definition_id;

  IF csr_exists%NOTFOUND THEN
	CLOSE csr_exists;
	fnd_message.set_name('PAY', 'PAY_34863_SHORT_NAME_NOT_EXIST');
        fnd_message.raise_error;
  END IF;
  CLOSE csr_exists;

  insert into PAY_UPGRADE_PARAMETERS (
	UPGRADE_DEFINITION_ID,
	PARAMETER_NAME,
	PARAMETER_VALUE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE
	) values (
	l_upgrade_definition_id,
	p_parameter_name,
	p_parameter_value,
	p_last_update_date,
	p_last_updated_by,
	p_last_update_login,
	p_created_by,
	p_creation_date);

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END Insert_Row;

PROCEDURE Update_Row (
	  P_UPGRADE_DEFINITION_ID  in            NUMBER
        , P_PARAMETER_NAME         in            VARCHAR2
	, P_PARAMETER_VALUE        in            VARCHAR2
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

     chk_mandatory_arg( p_parameter_name, 'PARAMETER_NAME' );


     update PAY_UPGRADE_PARAMETERS set
            parameter_value = p_parameter_value,
	    last_update_date= p_last_update_date,
	    last_updated_by = p_last_updated_by,
	    last_update_login = p_last_update_login
	 where upgrade_definition_id = p_upgrade_definition_id
	 and parameter_name = p_parameter_name;

     if (sql%notfound) then
         raise no_data_found;
     end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END Update_Row;

PROCEDURE Load_Row (
          P_SHORT_NAME             in            VARCHAR2
        , P_PARAMETER_NAME	   in		 VARCHAR2
	, P_PARAMETER_VALUE        in            VARCHAR2
        , P_OWNER		   in            VARCHAR2
) is
--
l_proc   varchar2(100) := g_package || 'Load_Row';
l_upgrade_def_id PAY_UPGRADE_DEFINITIONS.UPGRADE_DEFINITION_ID%TYPE;

l_sysdate            date := sysdate;
l_created_by         PAY_UPGRADE_PARAMETERS.CREATED_BY%TYPE;
l_creation_date      PAY_UPGRADE_PARAMETERS.CREATION_DATE%TYPE;
l_last_updated_by    PAY_UPGRADE_PARAMETERS.LAST_UPDATED_BY%TYPE;
l_last_update_login  PAY_UPGRADE_PARAMETERS.LAST_UPDATE_LOGIN%TYPE;
l_last_update_date   PAY_UPGRADE_PARAMETERS.LAST_UPDATE_DATE%TYPE;


cursor csr_existing_upd_def is
   select  upgrade_definition_id
      from   pay_upgrade_definitions
	      where  upper(short_name) = upper(p_short_name) ;

cursor csr_existing_upd_param(p_def_id in varchar2) is
   select  null
	from   pay_upgrade_parameters
	      where  UPGRADE_DEFINITION_ID = p_def_id
	      and PARAMETER_NAME = P_PARAMETER_NAME;

l_exists varchar2(1);

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


  open csr_existing_upd_def;
  fetch csr_existing_upd_def into l_upgrade_def_id;

  IF csr_existing_upd_def%NOTFOUND THEN
	CLOSE csr_existing_upd_def;
	fnd_message.set_name('PAY', 'PAY_34863_SHORT_NAME_NOT_EXIST');
        fnd_message.raise_error;
  END IF;
  CLOSE csr_existing_upd_def;

  open csr_existing_upd_param(l_upgrade_def_id);
  fetch csr_existing_upd_param into l_exists;

  if csr_existing_upd_param%FOUND then

     close csr_existing_upd_param;
     Update_Row (
	  P_UPGRADE_DEFINITION_ID  =>  l_upgrade_def_id
         ,P_PARAMETER_NAME         =>  p_parameter_name
         ,P_PARAMETER_VALUE        =>  p_parameter_value
	 ,P_LAST_UPDATE_DATE       =>  l_last_update_date
	 ,P_LAST_UPDATED_BY        =>  l_last_updated_by
	 ,P_LAST_UPDATE_LOGIN      =>  l_last_update_login
       );

  else

     close csr_existing_upd_param;
     -- This is not an update . Call the insert_row procedure.
     --
     Insert_Row (
         P_UPG_DEF_SHORT_NAME      =>  p_short_name
       , P_PARAMETER_NAME	   =>  p_parameter_name
       , P_PARAMETER_VALUE         =>  p_parameter_value
       , P_LAST_UPDATE_DATE        =>  l_last_update_date
       , P_LAST_UPDATED_BY         =>  l_last_updated_by
       , P_LAST_UPDATE_LOGIN       =>  l_last_update_login
       , P_CREATED_BY              =>  l_created_by
       , P_CREATION_DATE           =>  l_creation_date
       );

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
END Load_Row;

END PAY_UPGRADE_PARAMETERS_PKG;


/
