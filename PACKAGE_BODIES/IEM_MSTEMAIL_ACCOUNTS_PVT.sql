--------------------------------------------------------
--  DDL for Package Body IEM_MSTEMAIL_ACCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MSTEMAIL_ACCOUNTS_PVT" as
/* $Header: iemvmacb.pls 120.2 2005/08/03 16:18:36 appldev noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_MSTEMAIL_ACCOUNTS_PVT ';

PROCEDURE encrypt_password(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2,
        P_Commit    			  IN VARCHAR2,
	p_email_account_id	              IN NUMBER,
        p_raw_data	              IN VARCHAR2,
        x_msg_count   		      OUT NOCOPY  NUMBER,
        x_return_status  		  OUT NOCOPY  VARCHAR2,
        x_msg_data   			  OUT NOCOPY  VARCHAR2)

IS
    l_api_name              VARCHAR2(255):='encrypt_password';
    l_api_version_number    NUMBER:=1.0;
    l_encrypted_data		VARCHAR2(4000);
    l_encrypted_key		VARCHAR2(4000);
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    PASSWORD_NOT_ENCRYPTED 	EXCEPTION;

   BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT IEM_EncryptPassword_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API begins
	/*iem_utils_pvt.IEM_EncryptPassword(p_api_version_number => 1.0,
					  p_init_msg_list => FND_API.G_FALSE,
             			 	  p_commit         => FND_API.G_FALSE,
                                      p_raw_data => p_raw_data,
                                      x_encrypted_data => l_encrypted_data,
                                      x_encrypted_key => l_encrypted_key,
                                      x_msg_count => l_msg_count,
				      x_return_status => l_return_status,
                                      x_msg_data => l_msg_data);

	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        	raise PASSWORD_NOT_ENCRYPTED;
 	end if;

	update iem_mstemail_accounts set user_password=l_encrypted_data, encrypt_key=l_encrypted_key where email_account_id=p_email_account_id;
*/
	fnd_vault.put('IEM', to_char(p_email_account_id), p_raw_data);

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
 /*   WHEN PASSWORD_NOT_ENCRYPTED THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_PASSWORD_NOT_ENCRYPTED');

        --FND_MESSAGE.ADD;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );
*/
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO IEM_EncryptPassword_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                p_data => x_msg_data
            );
END encrypt_password;




PROCEDURE decrypt_password(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2,
        P_Commit    			  IN VARCHAR2,
        p_email_account_id              IN NUMBER,
        x_decrypted_data  	      OUT NOCOPY  VARCHAR2,
        x_msg_count   		      OUT NOCOPY  NUMBER,
        x_return_status  		  OUT NOCOPY  VARCHAR2,
        x_msg_data   			  OUT NOCOPY  VARCHAR2)

IS
    l_api_name              VARCHAR2(255):='decrypt_password';
    l_api_version_number    NUMBER:=1.0;

    l_decrypted_data        VARCHAR2(200);

    l_msg_index_out	number;
  --  l_input_data	varchar2(2000);

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

   PASSWORD_NOT_DECRYPTED	EXCEPTION;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT IEM_DecryptPassword_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;


/*	select user_password, encrypt_key into l_user_password, l_encrypt_key from iem_mstemail_accounts where email_account_id=p_email_account_id;

	iem_utils_pvt.IEM_DecryptPassword(p_api_version_number => 1.0,
					  p_init_msg_list => FND_API.G_FALSE,
             			 	  p_commit         => FND_API.G_FALSE,
                                      p_input_data => l_user_password,
				      p_decrypted_key => l_encrypt_key,
                                      x_decrypted_data => x_decrypted_data,
                                      x_msg_count => l_msg_count,
				      x_return_status => l_return_status,
                                      x_msg_data => l_msg_data);

	if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        	raise PASSWORD_NOT_DECRYPTED;
 	end if;
*/
	x_decrypted_data := fnd_vault.get('IEM', to_char(p_email_account_id));

    -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 p_data  =>    x_msg_data
			);

    IF (x_msg_count >= 1) THEN
    	--Only one error
    	FND_MSG_PUB.Get(p_msg_index => FND_MSG_PUB.G_FIRST,
                    p_encoded=>'F',
                    p_data=>x_msg_data,
                   p_msg_index_out=>l_msg_index_out);

    END IF;

EXCEPTION
 /*   WHEN PASSWORD_NOT_DECRYPTED THEN
        ROLLBACK TO IEM_DecryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_PASSWORD_NOT_DECRYPTED');

        --FND_MESSAGE.ADD;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );
*/
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO IEM_DecryptPassword_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                                  p_data  =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IEM_DecryptPassword_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get( p_count =>      x_msg_count,
                               p_data  =>      x_msg_data );

    WHEN OTHERS THEN

        ROLLBACK TO IEM_DecryptPassword_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                p_data => x_msg_data
            );
    END decrypt_password;


END IEM_MSTEMAIL_ACCOUNTS_PVT;

/
