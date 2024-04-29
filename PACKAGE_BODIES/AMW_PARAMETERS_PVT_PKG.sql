--------------------------------------------------------
--  DDL for Package Body AMW_PARAMETERS_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PARAMETERS_PVT_PKG" AS
/* $Header: amwparpb.pls 120.1 2005/10/25 23:25:14 appldev noship $ */
-- HISTORY
-- 11/19/2004    kosriniv     Creates
---------------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_PARAMETERS_PVT_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwparpb.pls';
G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE insert_parameter(
      p_parameter_name IN VARCHAR2,
      p_parameter_value IN VARCHAR2,
      p_pk1 IN VARCHAR2,
      p_pk2 IN VARCHAR2,
      p_pk3 IN VARCHAR2,
      p_pk4 IN VARCHAR2,
      p_pk5 IN VARCHAR2)
is
l_dummy number;
begin

	select 1 into l_dummy
	from amw_parameters
	where parameter_name = p_parameter_name
	and pk1 = p_pk1
	and NVL(pk2,-99) = NVL(p_pk2,-99)
	and NVL(pk3,-99) = NVL(p_pk3,-99)
	and NVL(pk4,-99) = NVL(p_pk4,-99)
	and NVL(pk5,-99) = NVL(p_pk5,-99) ;

EXCEPTION
	when no_data_found then
    	INSERT INTO
		AMW_PARAMETERS(
		  OBJECT_VERSION_NUMBER,
		  PARAMETER_NAME,
		  PARAMETER_VALUE,
		  PK1,PK2,PK3,PK4,PK5,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
VALUES(1,p_parameter_name, p_parameter_value,p_pk1,p_pk2,p_pk3,p_pk4,p_pk5,G_USER_ID, SYSDATE, G_USER_ID,SYSDATE,G_LOGIN_ID);

end insert_parameter;

PROCEDURE update_parameter(
p_parameter_name in varchar2,
p_parameter_value in varchar2,
p_pk1 in varchar2,
p_pk2 in varchar2,
p_pk3 in varchar2,
p_pk4 in varchar2,
p_pk5 in varchar2)
is

l_param_value varchar2(80);
l_object_version_number number;

begin

-- Retrieve the parameter..row...

	select parameter_value
	into l_param_value
	from amw_parameters
	where parameter_name = p_parameter_name
	and pk1 = p_pk1
	and NVL(pk2,-99) = NVL(p_pk2,-99)
	and NVL(pk3,-99) = NVL(p_pk3,-99)
	and NVL(pk4,-99) = NVL(p_pk4,-99)
	and NVL(pk5,-99) = NVL(p_pk5,-99) ;
-- Make sure that the parameter value changed..
	IF l_param_value <> p_parameter_value THEN
		update amw_parameters
		set parameter_value = p_parameter_value,
		last_updated_by = g_user_id,
		last_update_date = sysdate,
		last_update_login = G_LOGIN_ID,
		object_version_number = object_version_number+1
		where
		parameter_name = p_parameter_name
		and pk1 = p_pk1
		and NVL(pk2,-99) = NVL(p_pk2,-99)
                and NVL(pk3,-99) = NVL(p_pk3,-99)
                and NVL(pk4,-99) = NVL(p_pk4,-99)
                and NVL(pk5,-99) = NVL(p_pk5,-99) ;
	END IF;
END update_parameter;

PROCEDURE initialize_org_parameters(
p_process_approval_option IN VARCHAR2,
p_process_auto_approve IN VARCHAR2,
p_pk1 IN VARCHAR2,
p_pk2 IN VARCHAR2 := NULL,
p_pk3 IN VARCHAR2 := NULL,
p_pk4 IN VARCHAR2 := NULL,
p_pk5 IN VARCHAR2 := NULL,
p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		   OUT NOCOPY VARCHAR2,
x_msg_count                  OUT NOCOPY VARCHAR2,
x_msg_data		    OUT NOCOPY VARCHAR2
 ) IS
L_API_NAME CONSTANT VARCHAR2(30) := 'initialize_org_parameters';
BEGIN

-- Standard Initialization..
 G_USER_ID  := FND_GLOBAL.USER_ID;
  G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
--standard message list initialization code..
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- INSERT PROCESS_APPROVAL_OPTION..

    insert_parameter(
        p_parameter_name => 'PROCESS_APPROVAL_OPTION',
        p_parameter_value => p_process_approval_option,
        p_pk1 => p_pk1,
        p_pk2 => p_pk2,
        p_pk3 => p_pk3,
        p_pk4 => p_pk4,
        p_pk5 => p_pk5);

-- INSERT PROCESS_AUTO_APPROVE ..

    insert_parameter(
        p_parameter_name => 'PROCESS_AUTO_APPROVE',
        p_parameter_value => p_process_auto_approve,
        p_pk1 => p_pk1,
        p_pk2 => p_pk2,
        p_pk3 => p_pk3,
        p_pk4 => p_pk4,
        p_pk5 => p_pk5);


-- INSERT A NEW ROW IN TO THE AMW_PROCESS_ORGANIZATION..
    INSERT INTO AMW_PROCESS_ORGANIZATION(
                                                    PROCESS_ORGANIZATION_ID,
                                                    PROCESS_ID,
                                                    STANDARD_PROCESS_FLAG,
                                                    APPROVAL_STATUS,
                                                    ORGANIZATION_ID,
                                                    OBJECT_VERSION_NUMBER,
                                                    PROCESS_CODE,
                                                    REVISION_NUMBER,
                                                    PROCESS_ORG_REV_ID,
                                                    START_DATE,
                                                    APPROVAL_DATE,
                                                    RL_PROCESS_REV_ID,
                                                    RISK_CATEGORY,
                                                    CREATED_BY,
                                                    CREATION_DATE,
                                                    LAST_UPDATED_BY,
                                                    LAST_UPDATE_DATE,
                                                    LAST_UPDATE_LOGIN)
                                      values(  AMW_PROCESS_ORGANIZATION_S.nextval,
                                                    -2,
                                                    'Y',
                                                    'A',
                                                    p_pk1,
                                                    1,
                                                    '-2',
                                                    1,
                                                    AMW_PROCESS_ORG_REV_S.nextval,
                                                    sysdate,
                                                    sysdate,
                                                    -2,
                                                    'R',
                                                    g_user_id,
                                                    sysdate,
                                                    g_user_id,
                                                    sysdate,
                                                    G_LOGIN_ID
                                                    );

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END initialize_org_parameters;

PROCEDURE update_org_parameters(
p_process_approval_option IN VARCHAR2,
p_process_auto_approve IN VARCHAR2,
p_pk1 IN VARCHAR2,
p_pk2 IN VARCHAR2 := NULL,
p_pk3 IN VARCHAR2 := NULL,
p_pk4 IN VARCHAR2 := NULL,
p_pk5 IN VARCHAR2 := NULL,
p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		   OUT NOCOPY VARCHAR2,
x_msg_count                  OUT NOCOPY VARCHAR2,
x_msg_data		    OUT NOCOPY VARCHAR2
 ) IS

L_API_NAME CONSTANT VARCHAR2(30) := 'update_org_parameters';
BEGIN
-- Standard Initialization..
 G_USER_ID  := FND_GLOBAL.USER_ID;
  G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;
--standard message list initialization code..
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- UPDATE PROCESS_APPROVAL_OPTION..

    update_parameter(
        p_parameter_name => 'PROCESS_APPROVAL_OPTION',
        p_parameter_value => p_process_approval_option,
        p_pk1 => p_pk1,
        p_pk2 => p_pk2,
        p_pk3 => p_pk3,
        p_pk4 => p_pk4,
        p_pk5 => p_pk5);

-- UPDATE PROCESS_AUTO_APPROVE ..

    update_parameter(
        p_parameter_name => 'PROCESS_AUTO_APPROVE',
        p_parameter_value => p_process_auto_approve,
        p_pk1 => p_pk1,
        p_pk2 => p_pk2,
        p_pk3 => p_pk3,
        p_pk4 => p_pk4,
        p_pk5 => p_pk5);
exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);

end update_org_parameters;


-- abedajna added this for seed data entry.

procedure load_initial_seed_data (p_PARAMETER_NAME in varchar2,
				  p_parameter_value in varchar2,
				  p_pk1 in varchar2,
				  p_pk2 in varchar2,
				  p_pk3 in varchar2,
				  p_pk4 in varchar2,
				  p_pk5 in varchar2,
				  x_owner in varchar2,
				  x_last_update_date in varchar2) is
l_OWNER number;
l_last_update_date date;
l_dummy number;
begin
select 1 into l_dummy from amw_parameters where PARAMETER_NAME = p_PARAMETER_NAME and PK1 = p_PK1;
exception
	when no_data_found then
		l_OWNER := fnd_load_util.owner_id(X_OWNER);
		l_last_update_date := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
		insert into amw_parameters(OBJECT_VERSION_NUMBER,
					   PARAMETER_NAME,
					   PARAMETER_VALUE,
					   PK1,
					   pk2,
					   pk3,
					   pk4,
					   pk5,
					   CREATED_BY,
					   CREATION_DATE,
					   LAST_UPDATED_BY,
					   LAST_UPDATE_DATE,
					   LAST_UPDATE_LOGIN)
					   VALUES (
					   1,
					   p_PARAMETER_NAME,
					   p_parameter_value,
					   decode (p_pk1, '*NULL*', null, p_pk1),
					   decode (p_pk2, '*NULL*', null, p_pk2),
					   decode (p_pk3, '*NULL*', null, p_pk3),
					   decode (p_pk4, '*NULL*', null, p_pk4),
					   decode (p_pk5, '*NULL*', null, p_pk5),
					   l_OWNER,
					   l_last_update_date,
					   l_OWNER,
					   l_last_update_date,
					   0);


end load_initial_seed_data;

--kosriniv..for bug fix..4336520
PROCEDURE default_org_parameters(
p_org IN VARCHAR2,
p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		   OUT NOCOPY VARCHAR2,
x_msg_count                  OUT NOCOPY VARCHAR2,
x_msg_data		    OUT NOCOPY VARCHAR2
 ) IS
L_API_NAME CONSTANT VARCHAR2(30) := 'default_org_parameters';
l_proc_approval_option AMW_PARAMETERS.PARAMETER_VALUE%TYPE;
l_proc_auto_approve AMW_PARAMETERS.PARAMETER_VALUE%TYPE;
BEGIN


-- Standard Initialization..
 G_USER_ID  := FND_GLOBAL.USER_ID;
  G_LOGIN_ID  := FND_GLOBAL.CONC_LOGIN_ID;

--standard message list initialization code..
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF FND_API.to_Boolean( p_init_msg_list )  THEN
     FND_MSG_PUB.initialize;
  END IF;
  IF FND_GLOBAL.User_Id IS NULL THEN
    AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Select the Values from Risk Library...

	select parameter_value
	into l_proc_approval_option
	from amw_parameters
	where parameter_name = 'PROCESS_APPROVAL_OPTION'
	and pk1 = -1;

	select parameter_value
	into l_proc_auto_approve
	from amw_parameters
	where parameter_name = 'PROCESS_AUTO_APPROVE'
	and pk1 = -1;

  -- Initialize the Parameters...

	initialize_org_parameters(
	p_process_approval_option  => l_proc_approval_option,
	p_process_auto_approve     => l_proc_auto_approve,
	p_pk1                      => p_org,
	x_return_status	           => x_return_status,
	x_msg_count                => x_msg_count,
	x_msg_data		           => x_msg_data);

exception
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data => x_msg_data);

  WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,p_count => x_msg_count,p_data  => x_msg_data);
END default_org_parameters;

-- kosriniv ..update orgs concurrent programs
PROCEDURE update_all_org_params_cp(
errbuf     out nocopy  varchar2,
retcode    out nocopy  varchar2,
p_proc_approval_option in varchar2, -- A,B,C..
p_approval_required in varchar2, -- Y/N ..Y means auto_approve is No and N means auto_approve is Yes.
p_all_orgs in varchar2  -- NOCONF means only orgs that have not been configured..ALL means set/update all the orgs..
) is

L_API_NAME CONSTANT VARCHAR2(30) := 'update_all_org_params_cp';
l_proc_approval_option AMW_PARAMETERS.PARAMETER_VALUE%TYPE;
l_proc_auto_approve AMW_PARAMETERS.PARAMETER_VALUE%TYPE;
conc_status 		boolean;

cursor orgs_to_configure is
 select organization_id
 from amw_audit_units_v
 where organization_id not in (select organization_id
                               from amw_process_organization
                               where process_id = -2 );

-- when updating you need to skip those orgs in which processes are in pending approval.
cursor orgs_to_update is
 select organization_id
 from amw_process_organization
 where process_id = -2
   and organization_id not in (select distinct organization_id
                                from amw_process_locks);

begin


	retcode :=0;
	errbuf :='';

      -- first check whether the options available or not.
      if p_proc_approval_option is null then
      fnd_file.put_line (fnd_file.LOG, 'No Process Approval Option provided. Defaulting from Risk Library');
         -- Select the Values from Risk Library...
         select parameter_value
         into l_proc_approval_option
         from amw_parameters
         where parameter_name = 'PROCESS_APPROVAL_OPTION'
         and pk1 = -1;
      else
          l_proc_approval_option := p_proc_approval_option;
      end if;

      if p_approval_required is null then
      fnd_file.put_line (fnd_file.LOG, 'No Process Approval Required Parameter provided. Defaulting from Risk Library');
     	   select parameter_value
         into l_proc_auto_approve
         from amw_parameters
         where parameter_name = 'PROCESS_AUTO_APPROVE'
         and pk1 = -1;
      else
           if p_approval_required = 'N' then
              l_proc_auto_approve := 'Y';
           else l_proc_auto_approve := 'N';
           end if;
      end if;
      if 'ALL' = p_all_orgs OR 'NOCONF' = p_all_orgs then
      -- Now check p_all_orgs
       if 'ALL' = p_all_orgs then
       fnd_file.put_line (fnd_file.LOG, 'Updating Existing Org Parameters. Skipping Organizations where Process are in pending approval.');
      -- now update those that are configured..
        for org in orgs_to_update loop
          exit when orgs_to_update%notfound;

          -- UPDATE PROCESS_APPROVAL_OPTION..
          update_parameter(
            p_parameter_name => 'PROCESS_APPROVAL_OPTION',
            p_parameter_value => l_proc_approval_option,
            p_pk1 => org.organization_id,
            p_pk2 => null,
            p_pk3 => null,
            p_pk4 => null,
            p_pk5 => null);
          -- UPDATE PROCESS_AUTO_APPROVE ..
          update_parameter(
            p_parameter_name => 'PROCESS_AUTO_APPROVE',
            p_parameter_value => l_proc_auto_approve,
            p_pk1 => org.organization_id,
            p_pk2 => null,
            p_pk3 => null,
            p_pk4 => null,
            p_pk5 => null);
        end loop;
       end if;
      -- by default only set those that are not configured...
       for org in orgs_to_configure loop
          exit when orgs_to_configure%notfound;
         -- INSERT PROCESS_APPROVAL_OPTION..
          insert_parameter(
            p_parameter_name => 'PROCESS_APPROVAL_OPTION',
            p_parameter_value => l_proc_approval_option,
            p_pk1 => org.organization_id,
            p_pk2 => null,
            p_pk3 => null,
            p_pk4 => null,
            p_pk5 => null);
            -- INSERT PROCESS_AUTO_APPROVE ..
          insert_parameter(
            p_parameter_name => 'PROCESS_AUTO_APPROVE',
            p_parameter_value => l_proc_auto_approve,
            p_pk1 => org.organization_id,
            p_pk2 => null,
            p_pk3 => null,
            p_pk4 => null,
            p_pk5 => null);
-- INSERT A NEW ROW IN TO THE AMW_PROCESS_ORGANIZATION..
          INSERT INTO AMW_PROCESS_ORGANIZATION(
            PROCESS_ORGANIZATION_ID,
            PROCESS_ID,
            STANDARD_PROCESS_FLAG,
            APPROVAL_STATUS,
            ORGANIZATION_ID,
            OBJECT_VERSION_NUMBER,
            PROCESS_CODE,
            REVISION_NUMBER,
            PROCESS_ORG_REV_ID,
            START_DATE,
            APPROVAL_DATE,
            RL_PROCESS_REV_ID,
            RISK_CATEGORY,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN)
          values(
            AMW_PROCESS_ORGANIZATION_S.nextval,
            -2,
            'Y',
            'A',
            org.organization_id,
            1,
            '-2',
            1,
            AMW_PROCESS_ORG_REV_S.nextval,
            sysdate,
            sysdate,
            -2,
            'R',
            g_user_id,
            sysdate,
            g_user_id,
            sysdate,
            G_LOGIN_ID
            );
       end loop;
     end if;
     commit;
exception
	when others then
		rollback;
		retcode :=2;
		errbuf :=SUBSTR(SQLERRM,1,1000);
		conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','Error: '|| SQLERRM);
end update_all_org_params_cp;

END AMW_PARAMETERS_PVT_PKG;

/
