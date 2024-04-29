--------------------------------------------------------
--  DDL for Package IGW_PROP_NARRATIVES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_NARRATIVES_PVT" AUTHID CURRENT_USER as
 /* $Header: igwvprns.pls 115.4 2002/11/15 00:38:41 ashkumar ship $*/
PROCEDURE create_prop_narrative (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 X_ROWID 		          out NOCOPY 	        VARCHAR2,
 P_PROPOSAL_ID                    in	 	NUMBER,
 P_MODULE_TITLE                   in		VARCHAR2,
 P_MODULE_STATUS                  in		VARCHAR2,
 P_CONTACT_NAME                   in            VARCHAR2,
 P_PHONE_NUMBER                   in            VARCHAR2,
 P_EMAIL_ADDRESS                  in            VARCHAR2,
 P_COMMENTS                       in            VARCHAR2,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2);
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_narrative (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 x_rowid 		          IN 		VARCHAR2,
 P_PROPOSAL_ID                    in	 	NUMBER,
 P_MODULE_ID                      in		NUMBER,
 P_MODULE_TITLE                   in		VARCHAR2,
 P_MODULE_STATUS                  in		VARCHAR2,
 P_CONTACT_NAME                   in            VARCHAR2,
 P_PHONE_NUMBER                   in            VARCHAR2,
 P_EMAIL_ADDRESS                  in            VARCHAR2,
 P_COMMENTS                       in            VARCHAR2,
 p_record_version_number          IN 		NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2);
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_narrative (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_proposal_id    	         IN	        NUMBER
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2);

------------------------------------------------------------------------------------------
Procedure update_narrative_type_code (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 P_PROPOSAL_ID                    in	 	NUMBER,
 P_NARRATIVE_TYPE_CODE            in            VARCHAR2,
 P_NARRATIVE_SUBMISSION_CODE      in            VARCHAR2,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2);

-------------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2);


-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS;

------------------------------------------------------------------------------------------------------
PROCEDURE VALIDATE_LOGGED_USER_RIGHTS
(p_proposal_id		  IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2);

END IGW_PROP_NARRATIVES_PVT;

 

/
