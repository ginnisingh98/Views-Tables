--------------------------------------------------------
--  DDL for Package Body IEM_EMTA_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMTA_ACCT_PVT" AS
/* $Header: iemveacb.pls 120.3.12010000.2 2009/07/23 09:30:55 lkullamb ship $ */

--
--
-- Purpose: Mantain EMTA admin related issue.
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  12/19/2005   Created
--  Liang Xia  02/08/2005   Schema change for password in account table: fnd_val
--  lkullamb   07/23/2009  Added an out parameter to return whether an account is SSL enabled or not
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_EMTA_ACCT_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;


PROCEDURE LOAD_ACCOUNT_INFO(
 		  				  	 p_api_version_number  IN   NUMBER,
		  					 p_init_msg_list       IN   VARCHAR2 := null,
		  					 p_commit              IN   VARCHAR2 := null,
		  					 p_email_account_id 		IN number,
		  					 X_USER_NAME 				OUT NOCOPY varchar2,
		  					 X_USER_PASSWORD 			OUT NOCOPY varchar2,
						  	 X_IN_HOST 					OUT NOCOPY varchar2,
		  					 X_IN_PORT 					OUT NOCOPY varchar2,
							 X_SSL_CONNECTION_FLAG                          OUT NOCOPY varchar2,
		  					 x_return_status       OUT  NOCOPY VARCHAR2,
		  					 x_msg_count    		OUT  NOCOPY NUMBER,
		  					 x_msg_data            OUT  NOCOPY VARCHAR2 )
	 is
	l_api_name        		VARCHAR2(255):='LOAD_ACCOUNT_INFO';
	l_api_version_number 	NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

  l_user_name varchar2(100);
  l_user_pwd varchar2(100);
  l_encrypt_key varchar2(100);
  l_in_host varchar2(256);
  l_in_port varchar2(15);
  l_ssl_connection_flag varchar2(2);
  l_decrypted_pwd varchar2(256);

  l_is_acct_updated varchar2(1);
  IEM_FAILED_DECRYPT_ACCT_PWD EXCEPTION;
	l_count 					 NUMBER;
    errorMessage varchar2(2000);
    logMessage varchar2(2000);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		LOAD_ACCOUNT_INFO_PVT;

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
  				    p_api_version_number,
  				    l_api_name,
  				    G_PKG_NAME)
  THEN
  	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --begins here

	 --select user_name, user_password, encrypt_key, in_host, in_port
	 select user_name, in_host, in_port,ssl_connection_flag
	 into  l_user_name, l_in_host, l_in_port,l_ssl_connection_flag
	 from iem_mstemail_accounts where email_account_id = p_email_account_id ;

 	 l_decrypted_pwd := fnd_vault.get('IEM', p_email_account_id );
	 /*

	 IEM_UTILS_PVT.IEM_DecryptPassword(
							p_api_version_number =>1.0,
                     		p_init_msg_list => 'T',
                    		p_commit => p_commit,
        					p_input_data =>  l_user_pwd,
							p_decrypted_key => l_encrypt_key,
        					x_decrypted_data => l_decrypted_pwd ,
                            x_return_status =>l_return_status,
                            x_msg_count   => l_msg_count,
                            x_msg_data => l_msg_data);

	 	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
             raise IEM_FAILED_DECRYPT_ACCT_PWD;
     	end if;

	*/

	 X_USER_NAME := l_user_name;
	 X_USER_PASSWORD := l_decrypted_pwd;
	 X_IN_HOST := l_in_host;
	 X_IN_PORT := l_in_port;
	 X_SSL_CONNECTION_FLAG := l_ssl_connection_flag;

    -- Standard Check Of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;


    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN IEM_FAILED_DECRYPT_ACCT_PWD THEN
        ROLLBACK TO CHECK_IF_ACCOUNT_UPDATED_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('IEM', 'IEM_FAILED_DECRYPT_ACCT_PWD');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


	WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO LOAD_ACCOUNT_INFO_PVT;
       	 x_return_status := FND_API.G_RET_STS_ERROR ;
       	 FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO LOAD_ACCOUNT_INFO_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO LOAD_ACCOUNT_INFO_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END LOAD_ACCOUNT_INFO;

END;

/
