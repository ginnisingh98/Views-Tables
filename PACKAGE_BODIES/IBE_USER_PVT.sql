--------------------------------------------------------
--  DDL for Package Body IBE_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_USER_PVT" AS
/* $Header: IBEVUSRB.pls 120.5.12010000.4 2018/12/12 08:35:58 pwu ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_USER_PVT';

 /*+====================================================================
 | PROCEDURE NAME
 |    Create_User
 |
 | DESCRIPTION
 |    This API is called in java layer by
 |    oracle.apps.ibe.um.UserManager.createUser
 |
 | USAGE
 |    -   Creates FND User
 |
 |  REFERENCED APIS
 |     This API calls the following APIs
 |    -    FND_USER_PKG.CreatePendingUser
 +======================================================================*/
 Procedure Create_User(
         p_user_name		IN	VARCHAR2,
         p_password		IN	VARCHAR2,
         p_start_date        	IN  DATE,
         p_end_date          	IN  DATE,
         p_password_date     	IN  DATE,
         p_email_address     	IN  VARCHAR2,
         p_customer_id       	IN  NUMBER,
         x_user_id           	OUT NOCOPY  NUMBER ) IS

    Cursor c_get_user_st_end_date(c_user_name VARCHAR2) IS
     select to_char(u.start_date,'yyyy-mm-dd'), to_char(u.end_date,'yyyy-mm-dd')
     from fnd_user u where user_name=upper(c_user_name);

    l_start_date  VARCHAR2(30);
    l_end_date  VARCHAR2(30);

 BEGIN
    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    	IBE_UTIL.debug('enter ibe_user_pvt.create_user');
    END IF;

     --Ceates an FND_USER and Link the fnd_user table
     --and hz_parties by setting the customer_id column in fnd_user table


	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('Call FND_USER_PKG.CreatePendingUser API to create a user');
	END IF;

 	IF p_password is not null THEN

		  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Before Call to FND_USER_PKG.CreatePendingUser API: p_password is not null');
		  END IF;

		  x_user_id := FND_USER_PKG.createPendingUser (
		    x_user_name                 =>p_user_name,
		    x_owner                     => 'CUST',
		    x_unencrypted_password      => p_password,
		    x_password_date             => p_password_date,
		    x_email_address             => p_email_address
		  );


 	ELSE
 		  -- OID record exists; create FND record and relink
 		  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Before Call to FND_USER_PKG.CreatePendingUser API: p_password is null');
		  END IF;

		  x_user_id := FND_USER_PKG.createPendingUser (
		    x_user_name                 =>p_user_name,
		    x_owner                     => 'CUST',
		    x_email_address             => p_email_address
		  );

 	END IF;

	open c_get_user_st_end_date(p_user_name);
	fetch c_get_user_st_end_date into l_start_date, l_end_date;
	close c_get_user_st_end_date;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('start_date = '||l_start_date||' : end_date = '||l_end_date);
	END IF;

     	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  		IBE_UTIL.debug('After Call to FND_USER_PKG.CreatePendingUser API userid :'||x_user_id);
  		IBE_UTIL.debug('Before Call to FND_USER_PKG.updateUser API for updating customer_id');
     	END IF;


	FND_USER_PKG.updateUser (
		x_user_name                => p_user_name,
		x_owner                    => 'CUST',
		x_customer_id              => p_customer_id
	);

	open c_get_user_st_end_date(p_user_name);
	fetch c_get_user_st_end_date into l_start_date, l_end_date;
	close c_get_user_st_end_date;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('start_date = '||l_start_date||' : end_date = '||l_end_date);
	END IF;

     	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  		IBE_UTIL.debug('After Call to FND_USER_PKG.updateUser API for updating customer_id');
     	END IF;


     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	IBE_UTIL.debug('exit ibe_user_pvt.create_user ');
     END IF;

 End create_user;


/*+====================================================================
| PROCEDURE NAME
|    Update_User
|
| DESCRIPTION
|    This API is called by User Management when Contact Detail is updated
|
| USAGE
|    -   Updates FND User
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -    FND_USER_PKG.UpdateUser
+======================================================================*/
Procedure Update_User(
        p_user_name			IN	VARCHAR2,
        p_password			IN	VARCHAR2,
        p_start_date    IN  DATE,
        p_end_date      IN  DATE,
        p_old_password  IN  VARCHAR2,
        p_party_id    	IN 	NUMBER) IS
l_end_date date;
BEGIN

IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   IBE_UTIL.debug('enter ibe_user_pvt.update_user');
END IF;

	--Ceates an FND_USER and Link the fnd_user table
  --and hz_parties by setting the customer_id column in fnd_user table
  if (p_end_date is null) then
         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     		IBE_UTIL.debug('p_end_date is null');
     	 END IF;
     l_end_date := null_date;
  else
     l_end_date := p_end_date;
  end if;

  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	IBE_UTIL.debug('Call FND_USER_PKG.UpdateUser API to updated a user');
  END IF;

  FND_USER_PKG.UpdateUser (
        x_user_name             => p_user_name,
        x_owner                 => 'CUST',
        x_unencrypted_password  => p_password,
        x_start_date            => p_start_date,
        x_end_date              => l_end_date,
        x_old_password          => p_old_password,
        x_customer_id           => p_party_id
  );

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('exit enter ibe_user_pvt.update_user ');
   END IF;

End update_user;

/*+====================================================================
| PROCEDURE NAME
|    Create_User
|
| DESCRIPTION
|    This API is called by while revoking sites from user in User Management
|
| USAGE
|    - This API calls FND_USER_RESP_GROUPS_API and end dates the responsibility
|
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -     FND_USER_RESP_GROUPS_API.update_assignmets
+======================================================================*/
Procedure Update_Assignment(
	   p_user_id               IN  NUMBER,
	   p_responsibility_id     IN  NUMBER,
	   p_resp_application_id   IN  NUMBER,
	   p_security_group_id     IN  NUMBER ,
	   p_start_date            IN  DATE,
	   p_end_date              IN  DATE,
	   p_description           IN  VARCHAR2) IS

         l_start_date Date;

BEGIN
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('enter ibe_user_pvt.Update_Assignment');
   END IF;

	--Ceates an FND_USER and Link the fnd_user table
    --and hz_parties by setting the customer_id column in fnd_user table

  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	IBE_UTIL.debug('Call FND_USER_RESP_API.Update_Assignment API to revoke responsibility');
  END IF;

  if (p_start_date is null) then
      l_start_date := sysdate;
  end if;

  FND_USER_RESP_GROUPS_API.Update_Assignment (
        user_id                         =>p_user_id,
        responsibility_id               => p_responsibility_id,
        responsibility_application_id   => p_resp_application_id,
        security_group_id               => p_security_group_id,
        start_date                      => l_start_date,
        end_date                        => p_end_date,
        description                     => p_description
    );


 IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
 	IBE_UTIL.debug('After FND_USER_RESP_API.Update_Assignment API to revoke responsibility');
 	IBE_UTIL.debug('exit enter ibe_user_pvt.Update_Assignment ');
 END IF;

 End Update_Assignment;

 /*+====================================================================
 | FUNCTION NAME
 |    TestUserName
 |
 | DESCRIPTION
 |    This api test whether a username exists in FND and/or in OID.
 |
 | USAGE
 |    - This API is called for validating the username ion Registration
 |
 |  REFERENCED APIS
 |     This API calls the following APIs
 |    -     FND_USER_PKG.TestUserName
 +======================================================================*/


 Function TestUserName(p_user_name in varchar2) return pls_integer
 is
   retval pls_integer:=0;
   -- cur BINARY_INTEGER := DBMS_SQL.OPEN_CURSOR;
   -- fdbk BINARY_INTEGER;
   l_block varchar2(2000);
 Begin

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('enter ibe_user_pvt.TestUserName API');
   	IBE_UTIL.debug('calling fnd_user_pkg.TestUserName API');
   END IF;


    begin
    l_block :=
    'begin :result := fnd_user_pkg.testUsername(:1); end;';
    execute immediate l_block using out retval, in p_user_name;
    exception
      when others then
      	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      		IBE_UTIL.debug('fnd_user_pkg.TestUserName API returns '|| retval);
      	END IF;
        raise;
    end;


    /*
	IBE_UTIL.debug('Parsing IBE_USER_PVT.testUsername ' );

	DBMS_SQL.PARSE (cur, 'DECLARE user_name_test_status INTEGER; ' ||
				' BEGIN ' ||
				'	user_name_test_status := fnd_user_pkg.testUsername(:username); ' ||
				'	:status := user_name_test_status; ' ||
				' END;', DBMS_SQL.NATIVE);


	IBE_UTIL.debug('Binding username ' );
	DBMS_SQL.BIND_VARIABLE (cur, 'username', p_user_name);

	IBE_UTIL.debug('Binding status ' );
	DBMS_SQL.BIND_VARIABLE (cur, 'status', retval);

	IBE_UTIL.debug('Executing ' );
	fdbk := DBMS_SQL.EXECUTE (cur);

	IBE_UTIL.debug('Retrieving status' );
	DBMS_SQL.VARIABLE_VALUE (cur, 'status', retval);

	DBMS_SQL.CLOSE_CURSOR (cur);

	IBE_UTIL.debug('After calling TestUserName : retval =' || retval);

   -- retval := FND_USER_PKG.TestUserName(p_user_name);
   */

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('fnd_user_pkg.TestUserName API returns '|| retval);
      	IBE_UTIL.debug('exit ibe_user_pvt.TestUserName API');
   END IF;


   return (retval);

 End TestUserName;

END IBE_USER_PVT;

/
