--------------------------------------------------------
--  DDL for Package IEM_MSTEMAIL_ACCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MSTEMAIL_ACCOUNTS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvmacs.pls 120.0 2005/06/02 14:22:43 appldev noship $*/


-- Start of Comments
--  API name 	: IEM_EncryptPassword
--  Type	    : Private
--  Function	: This procedure is used to encrypt password.
--                Note, encrypted data is rounded to muliples of 8 bytes.
--  Pre-reqs	: None.
--  Parameters	:
--	IN
--  p_api_version_number    	   IN NUMBER	Required
--  p_init_msg_list	               IN VARCHAR2
--  p_commit	                   IN VARCHAR2
--  p_raw_data                     IN VARCHAR2  Required
--
--	OUT
--  x_encrypted_data               OUT  VARCHAR2  Encrypted data
-- x_encrypted_key		      OUT VARCHAR2  Encrypted key
--  x_return_status	               OUT	VARCHAR2
--	x_msg_count	                   OUT	NUMBER
--	x_msg_data	                   OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE encrypt_password(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2,
        P_Commit    			  IN VARCHAR2,
	p_email_account_id	              IN NUMBER,
        p_raw_data	              IN VARCHAR2,
        x_msg_count   		      OUT NOCOPY  NUMBER,
        x_return_status  		  OUT NOCOPY  VARCHAR2,
        x_msg_data   			  OUT NOCOPY  VARCHAR2);

-- Start of Comments
--  API name 	: IEM_DecryptPassword
--  Type	    : Private
--  Function	: This procedure is used to decrypt password.
--  Pre-reqs	: None.
--  Parameters	:
--	IN
--  p_api_version_number    	   IN NUMBER	Required
--  p_init_msg_list	               IN VARCHAR2
--  p_commit	                   IN VARCHAR2
--  p_input_data                   IN VARCHAR2  Required
-- p_decrypted_key              IN VARCHAR2,
--
--	OUT
--  x_decrypted_data               OUT  VARCHAR2
--  x_return_status	               OUT	VARCHAR2
--	x_msg_count	                   OUT	NUMBER
--	x_msg_data	                   OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE decrypt_password(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2,
        P_Commit    			  IN VARCHAR2,
        p_email_account_id              IN NUMBER,
        x_decrypted_data  	      OUT NOCOPY  VARCHAR2,
        x_msg_count   		      OUT NOCOPY  NUMBER,
        x_return_status  		  OUT NOCOPY  VARCHAR2,
        x_msg_data   			  OUT NOCOPY  VARCHAR2);


END IEM_MSTEMAIL_ACCOUNTS_PVT;

 

/
