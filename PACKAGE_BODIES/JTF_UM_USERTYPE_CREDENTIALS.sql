--------------------------------------------------------
--  DDL for Package Body JTF_UM_USERTYPE_CREDENTIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_USERTYPE_CREDENTIALS" as
/* $Header: JTFUMUCB.pls 120.14.12010000.6 2010/12/22 07:41:38 anurtrip ship $ */

MODULE_NAME  CONSTANT VARCHAR2(50) := 'JTF.UM.PLSQL.JTF_UM_USERTYPE_CREDENTIALS';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME);



PROCEDURE CREATE_ACCOUNT
          (
	   P_PARTY_ID          NUMBER,
	   P_PARTY_TYPE      VARCHAR2,
           P_ORG_PARTY_ID   NUMBER:=FND_API.G_MISS_NUM
	  )
IS



l_party_type HZ_PARTIES.party_type%type;

p_approval_id NUMBER := -1;
p_account_number NUMBER;
x_return_status VARCHAR2(100);
x_msg_count NUMBER;
x_msg_data VARCHAR2(1000);
x_cust_account_id NUMBER;
x_cust_account_number VARCHAR2(30);
x_party_id NUMBER;
x_party_number VARCHAR2(30);
x_profile_id NUMBER;
x_cust_account_role_id NUMBER;
cust_acct_roles_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;
l_procedure_name varchar2(30) := 'CREATE_ACCOUNT';

l_gen_cust_no       VARCHAR2(1);
BEGIN
JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                   p_message   => l_procedure_name);




l_party_type := JTF_UM_UTIL_PVT.check_party_type(P_PARTY_ID);

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   =>'l_party_type:' || l_party_type
                              );
end if;


 begin
    /*  SELECT generate_customer_number INTO l_gen_cust_no
        FROM ar_system_parameters;*/
	l_gen_cust_no :=  HZ_MO_GLOBAL_CACHE.get_generate_customer_number();

    exception when no_data_found then
      l_gen_cust_no := 'Y';
    end;

    IF l_gen_cust_no <> 'Y' THEN
   SELECT hz_account_num_s.nextval into p_account_number FROM DUAL;
    END IF;

-- SELECT hz_account_num_s.nextval into p_account_number FROM DUAL;


   if l_party_type = 'PERSON' then

    -- create new account for Individual User

    jtf_customer_accounts_pvt.create_account(
    p_api_version         => 1,
    p_init_msg_list       => 'T',
    p_commit              => 'F',
    p_party_id            => P_PARTY_ID,
    p_account_number      => p_account_number,
    p_create_amt          => 'F',
    p_party_type          => 'P',
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    x_cust_account_id     => x_cust_account_id,
    x_cust_account_number => x_cust_account_number,
    x_party_id            => x_party_id,
    x_party_number        => x_party_number,
    x_profile_id          => x_profile_id
    );

   elsif l_party_type='PARTY_RELATIONSHIP'
   then

    -- create new account for Primary User or businessuser who was not assigned
    -- one when he was approved.

   jtf_customer_accounts_pvt.create_account(
    p_api_version         => 1,
    p_init_msg_list       => 'T',
    p_commit              => 'F',
    p_party_id            => P_ORG_PARTY_ID,
    p_account_number      => p_account_number,
    p_create_amt          => 'F',
    p_party_type          => 'O',
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    x_cust_account_id     => x_cust_account_id,
    x_cust_account_number => x_cust_account_number,
    x_party_id            => x_party_id,
    x_party_number        => x_party_number,
    x_profile_id          => x_profile_id
    );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                        p_message   =>'X_return_status@create_account:' ||x_return_status
                              );
end if;

  end if;
  if(x_return_status <> fnd_api.g_ret_sts_success)
  then
  jtf_debug_pub.log_exception(p_module => MODULE_NAME
  ,p_message => ' message stack in account creation:'||x_msg_data);
  raise_application_error(-20101,'Failed to create account:'||x_msg_data);

  end if;
  -- Creating record in hz_cust_account_roles
/*
	 -- added check for bug 4291085,4480150
	 -- create a acct role only for party relationship
*/


     if x_cust_account_id  is not null and l_party_type = 'PARTY_RELATIONSHIP' then


            cust_acct_roles_rec.cust_account_id := x_cust_account_id;
            cust_acct_roles_rec.party_id := P_PARTY_ID;
            cust_acct_roles_rec.role_type := 'CONTACT';
            cust_acct_roles_rec.status := 'A';
            cust_acct_roles_rec.created_by_module := 'JTA_USER_MANAGEMENT';
            hz_cust_account_role_v2pub.create_cust_account_role(
                     p_init_msg_list        =>'T',
                     p_cust_account_role_rec   => cust_acct_roles_rec,
                     x_cust_account_role_id    => x_cust_account_role_id,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data
                     );

            if(x_return_status <> fnd_api.g_ret_sts_success)
            then
        raise_application_error(-20101,'Failed to create cust account role:'||x_msg_data);
            end if;
      end if;

END CREATE_ACCOUNT;



PROCEDURE QUERY_ACCOUNT
           (
          X_USER_ID NUMBER
          )
IS
CURSOR CUSTOMER_ID
IS
SELECT CUSTOMER_ID
FROM FND_USER
WHERE USER_ID = X_USER_ID
AND (NVL(END_DATE,SYSDATE+1) > SYSDATE OR to_char(END_DATE) = to_char(FND_API.G_MISS_DATE)) ;

CURSOR ORG_PARTY_ID
IS
SELECT FU.CUSTOMER_ID,HZR.SUBJECT_ID,HZR.OBJECT_ID
FROM hz_relationships HZR,FND_USER FU
WHERE FU.USER_ID = X_USER_ID
AND FU.CUSTOMER_ID = HZR.PARTY_ID
AND HZR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
AND HZR.subject_type = 'PERSON'
AND HZR.relationship_code in ('EMPLOYEE_OF', 'CONTACT_OF')
AND HZR.object_table_name = 'HZ_PARTIES'
AND HZR.START_DATE <= SYSDATE
AND NVL(HZR.END_DATE, SYSDATE + 1) > SYSDATE
AND ( NVL(FU.end_date,SYSDATE+1) > SYSDATE OR to_char(FU.END_DATE) = to_char(FND_API.G_MISS_DATE));

l_procedure_name CONSTANT varchar2(30) := 'QUERY_ACCOUNT';
l_party_type HZ_PARTIES.party_type%type;
l_customer_id NUMBER;
P_USERTYPE_KEY VARCHAR2(80);
P_ACCOUNT_ROLE_ID NUMBER := -1;
P_PARTY_ID NUMBER;
P_SUBJECT_ID NUMBER;
P_OBJECT_ID NUMBER;
L_ACCT_CNT NUMBER :=-1;

/* This profile is now obsoleted - Bug 3493035
l_profile BOOLEAN := TRUE;
*/


BEGIN
JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                   p_message   => l_procedure_name);



if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   =>'X_USER_ID:' || X_USER_ID
                              );
end if;
OPEN CUSTOMER_ID;
FETCH CUSTOMER_ID INTO l_customer_id;
CLOSE CUSTOMER_ID;

l_party_type := JTF_UM_UTIL_PVT.check_party_type(l_customer_id);

    IF(l_party_type = 'PARTY_RELATIONSHIP')
    THEN

     OPEN ORG_PARTY_ID;
     FETCH ORG_PARTY_ID INTO P_PARTY_ID, P_SUBJECT_ID,P_OBJECT_ID;
     CLOSE ORG_PARTY_ID;

	 --check if any a/c has been created for the ORG and if that a/c is
	 -- associated with this user(B2B/B2C)

	 SELECT COUNT(*) into L_ACCT_CNT
	 FROM HZ_CUST_ACCOUNTS WHERE
	 CUST_ACCOUNT_ID IN( SELECT CUST_ACCOUNT_ID
	 FROM HZ_CUST_ACCOUNT_ROLES
	 WHERE PARTY_ID = p_party_id
	 AND STATUS = 'A') AND STATUS='A' ;



     IF l_is_debug_parameter_on THEN
     JTF_DEBUG_PUB.LOG_PARAMETERS
       (p_module    => MODULE_NAME,
        p_message   =>'P_PARTY_ID' ||P_PARTY_ID||'+ P_SUBJECT_ID'||P_SUBJECT_ID
        );
     END IF;



	 ELSIF(l_party_type = 'PERSON')
     THEN

	 P_PARTY_ID := l_customer_id;

/* Bug 3493035
       IF (nvl(FND_PROFILE.value('JTF_INDIVIDUALUSER_ACCOUNT'),'N') <> 'Y')
       THEN
       l_profile := FALSE;
       END IF;*/

	   --check if any a/c has been created for this user

		SELECT COUNT(*) into L_ACCT_CNT
		FROM HZ_CUST_ACCOUNTS
		WHERE PARTY_ID =p_party_id
		AND STATUS = 'A';


    END IF;


     if l_is_debug_parameter_on then
     JTF_DEBUG_PUB.LOG_PARAMETERS
       (p_module    => MODULE_NAME,
        p_message   =>'L_ACCT_CNT:'||L_ACCT_CNT
        );
       end if;

     IF ( L_ACCT_CNT = 0)  /* AND l_profile = TRUE Bug 3493035 */
      THEN


       CREATE_ACCOUNT (
           P_PARTY_ID    => P_PARTY_ID  ,
	   P_PARTY_TYPE  => l_party_type,
           P_ORG_PARTY_ID => P_OBJECT_ID
       );

     END IF;

END QUERY_ACCOUNT;
PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  )
IS
l_def_resp_id           NUMBER;
l_def_app_id            NUMBER;
l_def_resp_key          FND_RESPONSIBILITY_VL.RESPONSIBILITY_KEY%TYPE;
l_def_resp_name         FND_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE;

BEGIN
IF Fnd_User_Resp_Groups_Api.Assignment_Exists(
  user_id => X_USER_ID,
  responsibility_id => X_RESPONSIBILITY_ID,
  responsibility_application_id => X_APPLICATION_ID
  ) THEN

 /*
 Removed this direct update call as fnd_user_resp_groups is no
 longer a table. Converted this call to use an API instead.

UPDATE FND_USER_RESP_GROUPS SET END_DATE = SYSDATE
WHERE USER_ID = X_USER_ID
AND   RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
AND   RESPONSIBILITY_APPLICATION_ID = X_APPLICATION_ID;
  */
     Fnd_User_Resp_Groups_Api.UPLOAD_ASSIGNMENT(
                         user_id => X_USER_ID,
                         responsibility_id => X_RESPONSIBILITY_ID,
                         responsibility_application_id => X_APPLICATION_ID,
                         start_date => sysdate,
                         end_date => sysdate, -- Revoke the responsibility
                         description => null );


   -- We need to reset the profile option, if the revoked responsibility
   -- is the default login responsibility of a user

    get_default_login_resp(
                       p_user_id      => X_USER_ID,
                       x_resp_id      => l_def_resp_id,
                       x_app_id       => l_def_app_id,
                       x_resp_key     => l_def_resp_key,
                       x_resp_name    => l_def_resp_name
                                           );

 IF l_def_resp_id =  X_RESPONSIBILITY_ID AND l_def_app_id = X_APPLICATION_ID THEN

         set_default_login_resp(
                       p_user_id => X_USER_ID,
                       p_resp_id => null,
                       p_app_id  => null
                                 ) ;

 END IF;

END IF;

END REVOKE_RESPONSIBILITY;

PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  )
IS
BEGIN

Fnd_User_Resp_Groups_Api.UPLOAD_ASSIGNMENT(
  user_id => X_USER_ID,
  responsibility_id => X_RESPONSIBILITY_ID,
  responsibility_application_id => X_APPLICATION_ID,
  start_date => sysdate,
  end_date => null,
  description => null );

END ASSIGN_RESPONSIBILITY;


PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID    NUMBER
	  )
IS

p_responsibility_id NUMBER;
CURSOR RESP_KEY IS SELECT RESPONSIBILITY_ID
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY;
BEGIN

OPEN RESP_KEY;

FETCH RESP_KEY INTO p_responsibility_id;

CLOSE RESP_KEY;

IF NVL(p_responsibility_id,0) <> 0 THEN

          ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           => X_USER_ID,
	   X_RESPONSIBILITY_ID => p_responsibility_id,
	   X_APPLICATION_ID    => X_APPLICATION_ID  );
END IF;

END ASSIGN_RESPONSIBILITY;

PROCEDURE ASSIGN_DEFAULT_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID    NUMBER
	  )
IS
p_responsibility_id NUMBER;
p_assign_def_resp boolean;
CURSOR RESP_KEY IS SELECT RESPONSIBILITY_ID
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY;

BEGIN

OPEN RESP_KEY;

FETCH RESP_KEY INTO p_responsibility_id;

CLOSE RESP_KEY;

IF NVL(p_responsibility_id,0) <> 0 THEN

ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID            => X_USER_ID,
	   X_RESPONSIBILITY_ID  => p_responsibility_id,
	   X_APPLICATION_ID     => X_APPLICATION_ID
	  );

          -- Make assigned responsibility as default one

          set_default_login_resp(
                       p_user_id => X_USER_ID,
                       p_resp_id => p_responsibility_id,
                       p_app_id  => X_APPLICATION_ID
                                 ) ;
  /* This has been replaced by a method above
   p_assign_def_resp := fnd_profile.save
                       (X_NAME        => 'JTF_PROFILE_DEFAULT_RESPONSIBILITY',
		        X_VALUE       => p_responsibility_id,
		        X_LEVEL_NAME  => 'USER',
		        X_LEVEL_VALUE => X_USER_ID);
  */
END IF;

END ASSIGN_DEFAULT_RESPONSIBILITY;




PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID            NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID     NUMBER
	  )
IS

p_responsibility_id NUMBER;
CURSOR RESP_KEY_ID IS SELECT RESPONSIBILITY_ID
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY;
BEGIN

OPEN RESP_KEY_ID;

FETCH RESP_KEY_ID INTO p_responsibility_id;

CLOSE RESP_KEY_ID;

IF NVL(p_responsibility_id,0) <> 0 THEN

	  REVOKE_RESPONSIBILITY
          (
	   X_USER_ID           => X_USER_ID,
	   X_RESPONSIBILITY_ID => p_responsibility_id,
	   X_APPLICATION_ID    => X_APPLICATION_ID
	  );
END IF;

END REVOKE_RESPONSIBILITY;

--added for bug# 7661549
/****************************************************************
* Procedure Name :
*		   setApproverNotifPref
* Description :
*			This procedure is called after enabling the user in ASSIGN_USERTYPE_CREDENTIALS
*           This procedure sets the notification preference in the wf_local_roles for the given user to the value in the corresponding adHocRole.
* Parameters
*		  userName : The User Name
*		  userId : The User ID
*
************************************************************/
procedure setApproverNotifPref(userName varchar2, userId varchar2) is
    l_notif_pref wf_local_roles.NOTIFICATION_PREFERENCE%type;
    l_user_name wf_local_roles.name%type;
    l_user_display_name wf_local_roles.display_name%type;
    errCode varchar2(100);
    errMsg varchar2(200);
begin
    wf_directory.GetUserName(p_orig_system => 'FND_USR',
                p_orig_system_id => userId,
                p_name => l_user_name,
                p_display_name => l_user_display_name);
    if(l_user_name is not null) then
        select NOTIFICATION_PREFERENCE into l_notif_pref
        from jtf_um_usertype_reg ut,
                   wf_local_roles wlr
        where ut.status_code='PENDING'
              and '__JTA_UM'||USERTYPE_REG_ID = name
              and ut.user_id = userId;

        fnd_preference.put(p_user_name => userName, p_module_name => 'WF', p_pref_name => 'MAILTYPE', p_pref_value => l_notif_pref);
        wf_directory.SetUserAttr(user_name => userName,
                               orig_system => 'FND_USR',
                               orig_system_id => userId,
                               notification_preference => nvl(l_notif_pref,'QUERY'));
    end if;
exception
        when others then
        begin
            errCode := sqlcode;
            errMsg := sqlerrm;
            jtf_debug_pub.log_exception(p_module => MODULE_NAME,p_message => ' Error in setApproverNotifPref code:'||errCode||', msg: '||errMsg);
       exception
        when others then
            null;
       end;
end;

/****************************************************************
* Procedure Name :
*		   ASSIGN_USERTYPE_CREDENTIALS
* Description :
*			This procedure is called upon manual/auto approval of an User
* Parameters
*		  X_USER_NAME : The User Name
*		  X_USER_ID : The User ID
*		  X_USERTYPE_ID: The Usertype to which the User belongs
*
************************************************************/

PROCEDURE ASSIGN_USERTYPE_CREDENTIALS
          (
	   X_USER_NAME VARCHAR2,
	   X_USER_ID   NUMBER,
	   X_USERTYPE_ID NUMBER
	   )
IS

l_procedure_name CONSTANT varchar2(30) := 'ASSIGN_USERTYPE_CREDENTIALS';
p_usertype_resp_id  number;
p_usertype_app_id   NUMBER;
p_principal_name    VARCHAR2(255);
l_version           FND_RESPONSIBILITY_VL.VERSION%TYPE;
l_resp_id  number;
l_app_id   number;
l_resp_key  FND_RESPONSIBILITY_VL.RESPONSIBILITY_KEY%TYPE;
l_resp_name FND_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE;

userStartDate DATE;
userEndDate DATE;

-- added variables for 4276972
eventName constant varchar2(33):='oracle.apps.jtf.um.approveUTEvent';
l_usertype_reg_id number;
l_usertype_key varchar2(30);
l_parameter_list wf_parameter_list_t :=
wf_parameter_list_t();

--added variables for 4287135
isDefaultRespPresent boolean :=false;

CURSOR USERTYPE_RESP is select FR.RESPONSIBILITY_ID, UT.APPLICATION_ID, FR.VERSION
FROM JTF_UM_USERTYPE_RESP UT, FND_RESPONSIBILITY_VL FR
WHERE UT.USERTYPE_ID = X_USERTYPE_ID
AND   FR.APPLICATION_ID  = UT.APPLICATION_ID
AND   FR.RESPONSIBILITY_KEY = UT.RESPONSIBILITY_KEY
AND   (UT.EFFECTIVE_END_DATE IS NULL OR UT.EFFECTIVE_END_DATE > SYSDATE)
AND   UT.EFFECTIVE_START_DATE < SYSDATE;

CURSOR USERTYPE_ROLES IS SELECT PRINCIPAL_NAME
FROM JTF_UM_USERTYPE_ROLE
WHERE USERTYPE_ID = X_USERTYPE_ID
AND   (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE)
AND   EFFECTIVE_START_DATE < SYSDATE;


BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'X_USER_NAME:' || X_USER_NAME || '+' || 'X_USER_ID:' || X_USER_ID || '+' || 'X_USERTYPE_ID:' || X_USERTYPE_ID
                              );
end if;


    --changes for 3899304
	-- the user name which has been reserved has to be enabled.
	-- enable user only if the user is a pending user.

	select start_date,end_date into userStartDate,userEndDate from FND_USER
    where user_id = X_USER_ID;

	if  to_char(userStartDate) = to_char(FND_API.G_MISS_DATE) and to_char(userEndDate) = to_char(FND_API.G_MISS_DATE) then
	    fnd_user_pkg.EnableUser (
                                username   => X_USER_NAME,
                                start_date => sysdate,
                                end_date   => fnd_user_pkg.null_date);
        setApproverNotifPref(X_USER_NAME, X_USER_ID);   --added for bug# 7661549
        --Added for bug 7661549
        /*wf_directory.SetUserAttr(user_name => X_USER_NAME,
                                      orig_system => 'FND_USR',
                                      orig_system_id => X_USER_ID,
                                      notification_preference => nvl(fnd_profile.value_specific('JTA_UM_MAIL_PREFERENCE'),'QUERY'));*/

	end if;
	--end of changes for 3899304
   -- removing JTF_PENDING_REMOVAL resp assigned during registration process
   -- as we now have a check to assign default responsibility only if there
   -- are no previous default resp


    JTF_UM_USERTYPE_CREDENTIALS.REVOKE_RESPONSIBILITY
          ( X_USER_ID    => X_USER_ID,
            X_RESPONSIBILITY_KEY => 'JTF_PENDING_APPROVAL',
            X_APPLICATION_ID    => 690
          );
-- Assign Responsibilites based on user type

/*check if any default responsibility is already present.
  this check added for re-registration process of 4287135
  in which case the user already has a default responsibility
  and that should not change.*/


JTF_UM_USERTYPE_CREDENTIALS.get_default_login_resp(
                       p_user_id      => X_USER_ID,
                       x_resp_id      => l_resp_id,
                       x_app_id       => l_app_id,
                       x_resp_key     => l_resp_key,
                       x_resp_name    => l_resp_name
                                           );



        IF l_resp_id IS NOT NULL AND l_app_id IS NOT NULL THEN
		   			 isDefaultRespPresent:=true;
		END IF;


OPEN USERTYPE_RESP;
LOOP
FETCH USERTYPE_RESP INTO p_usertype_resp_id, p_usertype_app_id,l_version;
EXIT WHEN USERTYPE_RESP%NOTFOUND;

ASSIGN_RESPONSIBILITY
       (
        X_USER_ID => X_USER_ID,
	X_RESPONSIBILITY_ID => p_usertype_resp_id,
        X_APPLICATION_ID  => p_usertype_app_id
        );

     -- Make this responsibility a default one if it is web based
	 IF NOT isDefaultRespPresent THEN
     IF l_version = 'W' THEN

        set_default_login_resp(
                       p_user_id         => X_USER_ID,
                       p_resp_id         => p_usertype_resp_id,
                       p_app_id          => p_usertype_app_id
                                 );
		isDefaultRespPresent :=true;
     END IF;
	 END IF;

END LOOP;
CLOSE USERTYPE_RESP;

-- Assign Roles based on user type

OPEN USERTYPE_ROLES;

LOOP
FETCH USERTYPE_ROLES INTO p_principal_name;
EXIT WHEN USERTYPE_ROLES%NOTFOUND;


JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
             ( USER_NAME       => X_USER_NAME,
		       ROLE_NAME       => p_principal_name,
		       OWNERTABLE_NAME => 'JTF_UM_USERTYPES_B',
		       OWNERTABLE_KEY  => X_USERTYPE_ID
		     );


END LOOP;
CLOSE USERTYPE_ROLES;

-- Update the status

UPDATE JTF_UM_USERTYPE_REG SET STATUS_CODE='APPROVED'
WHERE USERTYPE_ID = X_USERTYPE_ID
AND USER_ID = X_USER_ID
and status_code='PENDING' and nvl(effective_end_date, SYSDATE + 1) > SYSDATE;

/* Bug fix: 3549056
Revoke Pending approval responsibility
No need to check whether usertype has responsibility associated to it or not



          get_usertype_resp(
                       p_usertype_id         => X_USERTYPE_ID,
                       p_resp_id             => l_resp_id,
                       p_app_id              => l_app_id
                            );

          IF l_resp_id IS NOT NULL AND l_app_id IS NOT NULL THEN
*/

        --  END IF; Bug fix: 3549056






      -- Bug Fix: 3493035
      IF (nvl(FND_PROFILE.value('JTA_UM_AUTO_ACCT_CREATION'),'Y') = 'Y') THEN

          QUERY_ACCOUNT (
                        X_USER_ID => X_USER_ID
                        );
      END IF;

	  -- raise event for Approval : 4276972
	  -- Get the values for creation of parameters for the event

		JTF_DEBUG_PUB.LOG_DEBUG (2, MODULE_NAME, 'Start Raising Event');

		Select ut.APPLICATION_ID,ut.USERTYPE_KEY,reg.USERTYPE_REG_ID
		Into l_app_id, l_usertype_key, l_usertype_reg_id
		From JTF_UM_USERTYPES_B ut ,  JTF_UM_USERTYPE_REG reg
		where  ut.USERTYPE_ID=reg.USERTYPE_ID and reg.USER_ID=X_USER_ID
		and reg.status_code='APPROVED' and
		nvl(reg.EFFECTIVE_END_DATE,sysdate+1) > sysdate;

		JTF_DEBUG_PUB.LOG_DEBUG (2, MODULE_NAME, 'Parameters '|| l_app_id ||' '||l_usertype_key|| ' '||l_usertype_reg_id   );

		-- create the parameter list
		       wf_event.AddParameterToList(
					p_name => 'USERTYPEREG_ID',
				      p_value=>to_char(l_usertype_reg_id),
				      p_parameterlist=>l_parameter_list
				      );
		       wf_event.AddParameterToList(
					p_name => 'APPID',
				      p_value=>to_char(l_app_id),
				      p_parameterlist=>l_parameter_list
				      );
		       wf_event.AddParameterToList(
					p_name => 'USER_TYPE_KEY',
				      p_value=>l_usertype_key,
				      p_parameterlist=>l_parameter_list
				      );

		   -- raise the event
		       wf_event.raise(
						       p_event_name =>eventName,
						     p_event_key =>X_USER_ID ,
						     p_parameters => l_parameter_list
						    );

			   --  delete parameter list as it is no longer required
		     		l_parameter_list.DELETE;

			-- end of event handling


JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


END ASSIGN_USERTYPE_CREDENTIALS;

PROCEDURE ASSIGN_ACCOUNT
          (
	   P_PARTY_ID          NUMBER,
	   P_USERTYPE_KEY      VARCHAR2,
	   P_ORG_PARTY_ID      NUMBER:=FND_API.G_MISS_NUM
	  )
IS

CURSOR FIND_APPROVAL IS SELECT APPROVAL_ID FROM JTF_UM_USERTYPES_B
WHERE USERTYPE_KEY = P_USERTYPE_KEY
AND   (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE);

l_party_type HZ_PARTIES.party_type%type;

p_approval_id NUMBER := -1;
p_account_number NUMBER;
x_return_status VARCHAR2(100);
x_msg_count NUMBER;
x_msg_data VARCHAR2(1000);
x_cust_account_id NUMBER;
x_cust_account_number VARCHAR2(30);
x_party_id NUMBER;
x_party_number VARCHAR2(30);
x_profile_id NUMBER;
x_cust_account_role_id NUMBER;
cust_acct_roles_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;

l_procedure_name varchar2(30) := 'ASSIGN_ACCOUNT';
BEGIN
JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                   p_message   => l_procedure_name);




OPEN FIND_APPROVAL;
FETCH FIND_APPROVAL INTO p_approval_id;
CLOSE FIND_APPROVAL;

l_party_type := JTF_UM_UTIL_PVT.check_party_type(P_PARTY_ID);

if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   =>'l_party_type:' || l_party_type
                              );
end if;

SELECT hz_account_num_s.nextval into p_account_number FROM DUAL;
if(p_approval_id is null or p_approval_id = -1 OR l_party_type='PARTY_RELATIONSHIP')
then

   --if P_USERTYPE_KEY = 'INDIVIDUALUSER' then
   if l_party_type = 'PERSON' then

    -- create new account for Individual User

    jtf_customer_accounts_pvt.create_account(
    p_api_version         => 1,
    p_init_msg_list       => 'T',
    p_commit              => 'F',
    p_party_id            => P_PARTY_ID,
    p_account_number      => p_account_number,
    p_create_amt          => 'F',
    p_party_type          => 'P',
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    x_cust_account_id     => x_cust_account_id,
    x_cust_account_number => x_cust_account_number,
    x_party_id            => x_party_id,
    x_party_number        => x_party_number,
    x_profile_id          => x_profile_id
    );

   else

    -- create new account for Primary User or businessuser who was not assigned
    -- one when he was approved.

   jtf_customer_accounts_pvt.create_account(
    p_api_version         => 1,
    p_init_msg_list       => 'T',
    p_commit              => 'F',
    p_party_id            => P_ORG_PARTY_ID,
    p_account_number      => p_account_number,
    p_create_amt          => 'F',
    p_party_type          => 'O',
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    x_cust_account_id     => x_cust_account_id,
    x_cust_account_number => x_cust_account_number,
    x_party_id            => x_party_id,
    x_party_number        => x_party_number,
    x_profile_id          => x_profile_id
    );
if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                        p_message   =>'X_return_status@create_account:' ||x_return_status
                              );
end if;

  end if;
  if(x_return_status <> fnd_api.g_ret_sts_success)
  then
  jtf_debug_pub.log_exception(p_module => MODULE_NAME
  ,p_message => ' message stack in account creation:'||x_msg_data);
  raise_application_error(-20101,'Failed to create account:'||x_msg_data);

  end if;
  -- Creating record in hz_cust_account_roles

     if x_cust_account_id is not null then

            cust_acct_roles_rec.cust_account_id := x_cust_account_id;
            cust_acct_roles_rec.party_id := P_PARTY_ID;
            cust_acct_roles_rec.role_type := 'CONTACT';
            cust_acct_roles_rec.status := 'A';
            cust_acct_roles_rec.created_by_module := 'JTA_USER_MANAGEMENT';
            hz_cust_account_role_v2pub.create_cust_account_role(
                     p_init_msg_list        =>'T',
                     p_cust_account_role_rec   => cust_acct_roles_rec,
                     x_cust_account_role_id    => x_cust_account_role_id,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data
                     );

            if(x_return_status <> fnd_api.g_ret_sts_success)
            then
        raise_application_error(-20101,'Failed to create cust account role:'||x_msg_data);
            end if;
      end if;

end if;
END ASSIGN_ACCOUNT;

PROCEDURE REJECT_DELETED_PEND_USER (P_USERNAME     in  VARCHAR2,
                                    X_PENDING_USER out NOCOPY VARCHAR2)

IS

CURSOR FIND_UT_APPWF_INFO IS
SELECT reg.WF_ITEM_TYPE, to_char (reg.USERTYPE_REG_ID)
FROM JTF_UM_USERTYPE_REG reg, FND_USER fu
WHERE fu.USER_NAME = P_USERNAME
AND   fu.USER_ID = reg.USER_ID
AND   STATUS_CODE = 'PENDING'
AND   (reg.EFFECTIVE_END_DATE is null
OR     reg.EFFECTIVE_END_DATE > sysdate);

itemtype varchar2 (8);
itemkey  varchar2 (240);

BEGIN

  OPEN FIND_UT_APPWF_INFO;
  FETCH FIND_UT_APPWF_INFO INTO itemtype, itemkey;
  IF (FIND_UT_APPWF_INFO%NOTFOUND) THEN
    X_PENDING_USER := 'N';
    CLOSE FIND_UT_APPWF_INFO;
    RETURN;
  END IF;
  CLOSE FIND_UT_APPWF_INFO;

  JTF_UM_WF_APPROVAL.COMPLETEAPPROVALACTIVITY (itemtype, itemkey, 'REJECTED', 'User deleted');

  -- Need to Cancel Notification
  JTF_UM_WF_APPROVAL.CANCEL_NOTIFICATION (itemtype, itemkey);
  X_PENDING_USER := 'Y';

END REJECT_DELETED_PEND_USER;

PROCEDURE ASSIGN_DEF_RESP(P_USERNAME     in  VARCHAR2,
	                  P_ACCOUNT_TYPE in VARCHAR2)
IS

l_usertype_id NUMBER;
l_usertype_key VARCHAR2(30);
l_responsibility_key VARCHAR2(30);
l_application_id NUMBER;
l_user_id        NUMBER;

cursor find_default_resp is select responsibility_key, application_id from
jtf_um_usertype_resp where usertype_id = l_usertype_id
and (effective_end_date is null or effective_end_date > sysdate) ;

cursor find_usertype is select usertype_id from jtf_um_usertypes_b
where usertype_key = l_usertype_key
and (effective_end_date is null or effective_end_date > sysdate) ;

cursor find_user_id is select user_id from fnd_user where user_name = P_USERNAME;

BEGIN

-- Map account type to user type

IF UPPER(P_ACCOUNT_TYPE) = 'BUSINESSUSER' THEN
l_usertype_key := 'BUSINESSUSER';

ELSE
l_usertype_key := 'INDIVIDUALUSER';

END IF;

-- Find out user type id

   open find_usertype;
   fetch find_usertype into l_usertype_id;
   close find_usertype;

-- Find out default responsibility

   open find_default_resp;
   fetch find_default_resp into l_responsibility_key, l_application_id;
   close find_default_resp;

-- Assign default responsibility
if l_responsibility_key is not null and l_application_id is not null then

   open find_user_id;
   fetch find_user_id into l_user_id;
   close find_user_id;

-- Make sure that user_id is not null
          if l_user_id is not null then
          ASSIGN_DEFAULT_RESPONSIBILITY
          (
	   X_USER_ID            => l_user_id,
	   X_RESPONSIBILITY_KEY => l_responsibility_key,
	   X_APPLICATION_ID     => l_application_id
	  );
          end if;
end if;

END ASSIGN_DEF_RESP;

PROCEDURE ASSIGN_DEF_ROLES(P_USERNAME     in  VARCHAR2,
	                   P_ACCOUNT_TYPE in VARCHAR2)
IS

l_usertype_id NUMBER;
l_usertype_key VARCHAR2(30);
l_principal_name VARCHAR2(255);

cursor find_default_role is select principal_name from
jtf_um_usertype_role where usertype_id = l_usertype_id
and (effective_end_date is null or effective_end_date > sysdate) ;

cursor find_usertype is select usertype_id from jtf_um_usertypes_b
where usertype_key = l_usertype_key
and (effective_end_date is null or effective_end_date > sysdate) ;

BEGIN

-- Map account type to user type

IF UPPER(P_ACCOUNT_TYPE) = 'BUSINESSUSER' THEN
l_usertype_key := 'BUSINESSUSER';

ELSE
l_usertype_key := 'INDIVIDUALUSER';

END IF;

   -- Find out user type id

   open find_usertype;
   fetch find_usertype into l_usertype_id;
   close find_usertype;

   -- Find out default roles

   open find_default_role;

  loop
   fetch  find_default_role into l_principal_name;
   exit when find_default_role%NOTFOUND;

   -- Assign default roles
   if l_principal_name is not null then

   -- Make sure that user name is not null
          if P_USERNAME is not null then
	  JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => P_USERNAME,
		       ROLE_NAME       => l_principal_name,
		       OWNERTABLE_NAME => 'JTF_UM_USERTYPES_B',
		       OWNERTABLE_KEY  => l_usertype_id
		     );
          end if;
    end if;
   end loop;
   close find_default_role;

END ASSIGN_DEF_ROLES;


/**
  * Procedure   :  get_usertype_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will determine the responsibility attached to the usertype
  * Parameters  :
  * input parameters
  * @param     p_usertype_id
  *     description:  The usertyp_id
  *     required   :  Y
  *     validation :  Must be a valid usertype_id
  *  output parameters
  *     x_resp_id
  *     description: The responsibility_id associated to the responsibility
  *                  associated to the usertype
  *     x_app_id
  *     description: The app_id associated to the responsibility
  *                  associated to the usertype
**/
procedure get_usertype_resp(
                       p_usertype_id         in number,
                       p_resp_id             out NOCOPY number,
                       p_app_id              out NOCOPY number
                            ) IS

l_procedure_name CONSTANT varchar2(30) := 'get_usertype_resp';
CURSOR FIND_UT_RESP IS SELECT UTRESP.APPLICATION_ID, FURESP.RESPONSIBILITY_ID
FROM   JTF_UM_USERTYPE_RESP UTRESP, FND_RESPONSIBILITY_VL FURESP
WHERE  UTRESP.USERTYPE_ID = p_usertype_id
AND    NVL(UTRESP.EFFECTIVE_END_DATE,SYSDATE+1) > SYSDATE
AND    UTRESP.EFFECTIVE_START_DATE < SYSDATE
AND    UTRESP.RESPONSIBILITY_KEY = FURESP.RESPONSIBILITY_KEY;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_usertype_id:' || p_usertype_id
                              );
end if;

 OPEN  FIND_UT_RESP;
 FETCH FIND_UT_RESP INTO p_app_id, p_resp_id;
 CLOSE FIND_UT_RESP;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END get_usertype_resp;


/**
 * Procedure   :  grant_roles
 * Type        :  Private
 * Pre_reqs    :  None
 * Description :  Will grant roles to users
 * Parameters  :
 * input parameters
 *   p_user_name:
 *     description:  The user_name of the user
 *     required   :  Y
 *     validation :  Must be a valid user_name
 *   p_role_id
 *     description: The value of the JTF_AUTH_PRINCIPAL_ID
 *     required   :  Y
 *     validation :  Must exist as a JTF_AUTH_PRONCIPAL_ID
 *                   in the table JTF_AUTH_PRINCIPALS_B
 *   p_source_name
 *     description: The value of the name of the source
 *     required   :  Y
 *     validation :  Must be "USERTYPE" or "ENROLLMENT"
 *   p_source_id
 *     description: The value of the id associated with the source
 *     required   :  Y
 *     validation :  Must be a usertype_id or a subscription_id
 * output parameters
 * None
 */
procedure grant_roles (
                       p_user_name          in varchar2,
                       p_role_id            in number,
                       p_source_name         in varchar2,
                       p_source_id         in varchar2
                     ) IS

CURSOR FIND_ROLE_NAME IS SELECT PRINCIPAL_NAME FROM JTF_AUTH_PRINCIPALS_B
WHERE JTF_AUTH_PRINCIPAL_ID = p_role_id AND IS_USER_FLAG = 0;

l_owner_table_name varchar2(50);
l_principal_name JTF_AUTH_PRINCIPALS_B.PRINCIPAL_NAME%TYPE;

BEGIN

  IF p_source_name <> 'USERTYPE' OR p_source_name <> 'ENROLLMENT' THEN
    RAISE_APPLICATION_ERROR(-20000,'The source name is incorrect');
  END IF;

  OPEN FIND_ROLE_NAME;
  FETCH FIND_ROLE_NAME INTO l_principal_name;

     IF FIND_ROLE_NAME%NOTFOUND THEN
      CLOSE FIND_ROLE_NAME;
      RAISE_APPLICATION_ERROR(-20000,'The role id is incorrect');
     END IF;

  CLOSE FIND_ROLE_NAME;

        IF p_source_name = 'USERTYPE' THEN

           l_owner_table_name := 'JTF_UM_USERTYPES_B';

        ELSIF p_source_name = 'ENROLLMENT' THEN

           l_owner_table_name := 'ENROLLMENT';

        END IF;


        JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => p_user_name,
		       ROLE_NAME       => l_principal_name,
		       OWNERTABLE_NAME => l_owner_table_name,
		       OWNERTABLE_KEY  => p_source_id
		     );

END grant_roles;

/**
  * Procedure   :  set_default_login_responsibility
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user_id of a user
  *     validation :  Must be a valid user_id
  * @param     p_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  *     required   :  Y
  *     validation :  Must be a valid responsibility_id
  * @param     p_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  *     required   : Y
  *     validation: Must be a valid application_id
  *  output parameters
  *  None
**/

procedure set_default_login_resp(
                       p_user_id             in number,
                       p_resp_id             in number,
                       p_app_id              in number
                                 ) IS
l_procedure_name CONSTANT varchar2(30) := 'set_default_login_resp';
p_assign_def_resp boolean;
p_assign_def_appl boolean;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_id:' || p_user_id || '+' || 'p_resp_id:' || p_resp_id || '+' || 'p_app_id:' || p_app_id
                              );
end if;

    p_assign_def_resp := fnd_profile.save
                       (X_NAME        => 'JTF_PROFILE_DEFAULT_RESPONSIBILITY',
		        X_VALUE       => p_resp_id,
		        X_LEVEL_NAME  => 'USER',
		        X_LEVEL_VALUE => p_user_id);

    p_assign_def_appl := fnd_profile.save
                       (X_NAME        => 'JTF_PROFILE_DEFAULT_APPLICATION',
		        X_VALUE       => p_app_id,
		        X_LEVEL_NAME  => 'USER',
		        X_LEVEL_VALUE => p_user_id);

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
END set_default_login_resp;

/**
  * Procedure   :  set_default_login_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_name
  *     description:  The user_name of a user
  *     validation :  Must be a valid user_name
  * @param     p_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  *     required   :  Y
  *     validation :  Must be a valid responsibility_id
  * @param     p_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  *     required   : Y

  *  output parameters
  *  None
**/

procedure set_default_login_resp(
                       p_user_name           in varchar2,
                       p_resp_id             in number,
                       p_app_id              in number
                                           ) IS

l_procedure_name CONSTANT varchar2(30) := 'set_default_login_resp';

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_name:' || p_user_name || '+' || 'p_resp_id:' || p_resp_id || '+' || 'p_app_id:' || p_app_id
                              );
end if;


          set_default_login_resp(
                       p_user_id         => JTF_UM_UTIL_PVT.get_user_id(p_user_name),
                       p_resp_id         => p_resp_id,
                       p_app_id          => p_app_id
                                 );


JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END set_default_login_resp;


/**
  * Procedure   :  get_default_login_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_name
  *     description:  The user_name of a user
  *     validation :  Must be a valid user_name
  * output parameters
  * @param     x_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  * @param     x_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  * @param x_resp_key
  *     description: The responsibility_key associated to the default logon
  *                  responsibility of a user
  * @param x_resp_name
  *     description: The responsibility_name associated to the default logon
  *                  responsibility of a user
  *
  *  None
**/

procedure get_default_login_resp(
                       p_user_name           in varchar2,
                       x_resp_id             out NOCOPY number,
                       x_app_id              out NOCOPY number,
                       x_resp_key            out NOCOPY varchar2,
                       x_resp_name           out NOCOPY varchar2
                                           ) IS

l_procedure_name CONSTANT varchar2(30) := 'get_default_login_resp';


BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_name:' || p_user_name
                              );
end if;


          get_default_login_resp(
                       p_user_id             => JTF_UM_UTIL_PVT.get_user_id(p_user_name),
                       x_resp_id             => x_resp_id,
                       x_app_id              => x_app_id ,
                       x_resp_key            => x_resp_key ,
                       x_resp_name           => x_resp_name
                                 );


JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

END get_default_login_resp;


/**
  * Procedure   :  get_default_login_resp
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Will set the default responsibility of a user
  * Parameters  :
  * input parameters
  * @param     p_user_id
  *     description:  The user_name of a user
  *     validation :  Must be a valid user_id
  * output parameters
  * @param     x_resp_id
  *     description: The responsibility_id associated to the default logon
  *                  responsibility of a  user
  * @param     x_app_id
  *     description: The app_id associated to the default logon
  *                  responsibility of a user
  * @param x_resp_key
  *     description: The responsibility_key associated to the default logon
  *                  responsibility of a user
  * @param x_resp_name
  *     description: The responsibility_name associated to the default logon
  *                  responsibility of a user
  *
  *  None
**/

procedure get_default_login_resp(
                       p_user_id             in number,
                       x_resp_id             out NOCOPY number,
                       x_app_id              out NOCOPY number,
                       x_resp_key            out NOCOPY varchar2,
                       x_resp_name           out NOCOPY varchar2
                                           ) IS

l_procedure_name CONSTANT varchar2(30) := 'get_default_login_resp';
l_app_id_defined boolean;
l_resp_id_defined boolean;
CURSOR FIND_RESP_INFO IS SELECT RESPONSIBILITY_KEY, RESPONSIBILITY_NAME
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_ID = x_resp_id
AND   APPLICATION_ID    = x_app_id;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );
if l_is_debug_parameter_on then
JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                              p_message   => 'p_user_id:' || p_user_id
                              );
end if;

       JTF_UM_UTIL_PVT.GET_SPECIFIC(
              name_z              => 'JTF_PROFILE_DEFAULT_APPLICATION',
              user_id_z           => p_user_id,
              val_z               => x_app_id,
              defined_z           => l_app_id_defined
                                   );

       JTF_UM_UTIL_PVT.GET_SPECIFIC(
              name_z              => 'JTF_PROFILE_DEFAULT_RESPONSIBILITY',
              user_id_z           => p_user_id,
              val_z               => x_resp_id,
              defined_z           => l_resp_id_defined
                                   );

    OPEN FIND_RESP_INFO;
    FETCH FIND_RESP_INFO INTO x_resp_key,x_resp_name;
    CLOSE FIND_RESP_INFO;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


END get_default_login_resp;

/**
  * Procedure   :  UPGRADE_PRIMARY_USER
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Concurrent program to upgrade primary users
  * Parameters  :
  * OUT parameters
  * As required by concurrent program standards
**/

PROCEDURE UPGRADE_PRIMARY_USER(ERRBUF  out NOCOPY VARCHAR2,
                               RETCODE out NOCOPY VARCHAR2
                               ) IS

  l_new_usertype_id NUMBER := 0;
  l_pending_users NUMBER   := 0;

  l_new_ut_key JTF_UM_USERTYPES_B.USERTYPE_KEY%TYPE := 'BUSINESSUSER';
  l_old_ut_key JTF_UM_USERTYPES_B.USERTYPE_KEY%TYPE := 'PRIMARYUSER';

  l_user_name varchar2(100);
  l_org_name varchar2(360);
  l_email varchar2(200);


  CURSOR FIND_BUS_UT_ID IS
  SELECT USERTYPE_ID
  FROM   JTF_UM_USERTYPES_B
  WHERE  USERTYPE_KEY = l_new_ut_key
  AND    NVL(EFFECTIVE_END_DATE, SYSDATE + 1) > SYSDATE;

  CURSOR PRIMARY_USERS IS SELECT USERTYPE_REG_ID, USER_ID
  FROM   JTF_UM_USERTYPE_REG UTREG
  WHERE  UTREG.USERTYPE_ID IN (SELECT USERTYPE_ID FROM JTF_UM_USERTYPES_B
                               WHERE USERTYPE_KEY = l_old_ut_key)
  AND    UTREG.STATUS_CODE = 'APPROVED'
  AND    NVL(UTREG.EFFECTIVE_END_DATE, SYSDATE + 1) > SYSDATE
  AND    NOT EXISTS
         (SELECT SUBSCRIPTION_REG_ID FROM JTF_UM_SUBSCRIPTION_REG SUBREG
          WHERE  SUBREG.USER_ID = UTREG.USER_ID
          AND    SUBREG.STATUS_CODE = 'PENDING'
          AND    NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE + 1) > SYSDATE
         );
/*
 CURSOR PENDING_USERS IS SELECT f.user_name, p.party_name, f.email_address
  FROM JTF_UM_USERTYPE_REG UTREG, JTF_UM_USERTYPES_B UT, hz_parties p, hz_relationships r, fnd_user f
  WHERE UT.USERTYPE_KEY = l_old_ut_key
  AND   UT.USERTYPE_ID = UTREG.USERTYPE_ID
  AND   UTREG.user_id = f.user_Id
  AND   UTREG.STATUS_CODE = 'PENDING'
  AND   p.party_id = r.object_id and r.party_id = f.customer_id
  AND   NVL(utreg.EFFECTIVE_END_DATE, SYSDATE + 1) > SYSDATE;
*/
 CURSOR PENDING_USERS IS
  SELECT f.user_name, p.party_name, f.email_address
  FROM JTF_UM_USERTYPE_REG UTREG, JTF_UM_USERTYPES_B UT, hz_parties p, hz_relationships r, fnd_user f
  WHERE UT.USERTYPE_KEY = 'PRIMARYUSER'
  AND   UT.USERTYPE_ID = UTREG.USERTYPE_ID
  AND   R.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
  AND   R.object_table_name = 'HZ_PARTIES'
  AND   R.START_DATE < SYSDATE
  AND   NVL(R.END_DATE, SYSDATE + 1) > SYSDATE
  AND   p.party_id = r.object_id and r.party_id = f.customer_id
  AND   NVL(utreg.EFFECTIVE_END_DATE, SYSDATE + 1) > SYSDATE
  AND   UTREG.user_id = f.user_Id
  AND   p.party_type = 'ORGANIZATION'
  AND
 (
 	UTREG.STATUS_CODE = 'PENDING'
	OR
	 ( UTREG.STATUS_CODE = 'APPROVED'
	    AND
	    EXISTS
	    (
		   SELECT SUBSCRIPTION_REG_ID
		    FROM JTF_UM_SUBSCRIPTION_REG SUBREG
		    WHERE  SUBREG.USER_ID = UTREG.USER_ID
		    AND
		    SUBREG.STATUS_CODE = 'PENDING'
		    AND
		    NVL(SUBREG.EFFECTIVE_END_DATE, SYSDATE + 1) > SYSDATE
	   )
	 )
 );


 BEGIN

  RETCODE := FND_API.G_RET_STS_SUCCESS;

  OPEN FIND_BUS_UT_ID;
  FETCH FIND_BUS_UT_ID INTO l_new_usertype_id;
    IF FIND_BUS_UT_ID%NOTFOUND THEN
       ERRBUF := ERRBUF || fnd_global.newline || 'Could not find valid Business User type';
       RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
  CLOSE FIND_BUS_UT_ID;


  fnd_message.set_name('JTF','JTA_UM_PRI_UP_USER_HEADER');
  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, fnd_message.get);

  IF RETCODE = FND_API.G_RET_STS_SUCCESS THEN

     FOR i IN PRIMARY_USERS LOOP
         fnd_message.set_name('JTF','JTA_UM_PRI_UP_USERS');
         UPDATE JTF_UM_USERTYPE_REG SET USERTYPE_ID = l_new_usertype_id
         WHERE  USERTYPE_REG_ID = i.USERTYPE_REG_ID;

         COMMIT;
	 -- this code can result in exceptions hence enclosing in a seperate block
	 -- as the following block is used for logging
	 BEGIN
         select f.user_name, p.party_name, f.email_address into l_user_name, l_org_name, l_email
         from hz_parties p, hz_relationships r, fnd_user f
         where
            p.party_id = r.object_id and r.party_id = f.customer_id
            AND R.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
            AND R.object_table_name = 'HZ_PARTIES'
            AND R.START_DATE < SYSDATE
            AND NVL(R.END_DATE, SYSDATE + 1) > SYSDATE
            and   f.user_id = i.user_id
	    and  r.relationship_code='EMPLOYEE_OF';

         fnd_message.set_token( 'USER_NAME', l_user_name );
         fnd_message.set_token( 'ORG_NAME', l_org_name );
         fnd_message.set_token( 'EMAIL', l_email );
         fnd_file.put_line(fnd_file.log, fnd_message.get);
	 EXCEPTION
		WHEN OTHERS THEN
			fnd_message.set_token( 'USER_NAME', i.user_id );
			fnd_message.set_token( 'ORG_NAME', 'Could not be retrived' );
			fnd_message.set_token( 'EMAIL', 'Could not be retrived' );
			fnd_file.put_line(fnd_file.log, fnd_message.get);
	 END;
     END LOOP;

  END IF;

  fnd_message.set_name('JTF','JTA_UM_PENDING_USER_HEADER');
  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, fnd_message.get);

  FOR i IN PENDING_USERS LOOP
         fnd_message.set_name('JTF','JTA_UM_PENDING_USERS');
         fnd_message.set_token( 'USER_NAME', i.user_name );
         fnd_message.set_token( 'ORG_NAME', i.party_name );
         fnd_message.set_token( 'EMAIL', i.email_address );
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         l_pending_users := l_pending_users + 1;
  END LOOP;

  fnd_file.new_line(fnd_file.log,1);
  /*
  SELECT COUNT(*) INTO l_pending_users
  FROM JTF_UM_USERTYPE_REG UTREG, JTF_UM_USERTYPES_B UT
  WHERE UT.USERTYPE_KEY = l_old_ut_key
  AND   UT.USERTYPE_ID = UTREG.USERTYPE_ID
  AND   UTREG.STATUS_CODE = 'PENDING';
  */
  IF l_pending_users = 0 THEN
      fnd_message.set_name('JTF','JTA_UM_PRI_UP_COMPLETE');
  ELSE
      fnd_message.set_name('JTF','JTA_UM_PRI_UP_INCOMPLETE');
      fnd_message.set_token('USERS',l_pending_users);
  END IF;

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, fnd_message.get);

END UPGRADE_PRIMARY_USER;
END JTF_UM_USERTYPE_CREDENTIALS;

/
