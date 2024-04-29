--------------------------------------------------------
--  DDL for Package IGW_PROP_USER_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_USER_ROLES_PVT" AUTHID CURRENT_USER as
 /* $Header: igwvpurs.pls 115.5 2002/11/15 00:47:03 ashkumar ship $*/
PROCEDURE create_prop_user_role (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         OUT NOCOPY  	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_user_id               	 IN 	NUMBER
 ,p_user_name			 IN	VARCHAR2
 ,p_role_id               	 IN 	NUMBER
 ,p_role_name			 IN	VARCHAR2
 ,p_logged_user_id		 IN     NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2);
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_user_role (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         IN 	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_user_id               	 IN 	NUMBER
 ,p_user_name			 IN	VARCHAR2
 ,p_role_id               	 IN 	NUMBER
 ,p_role_name 			 IN	VARCHAR2
 ,p_logged_user_id		 IN     NUMBER
 ,p_record_version_number        IN 	NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2);
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_user_role (
  p_init_msg_list                IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   		VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   		VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 		VARCHAR2
 ,p_logged_user_id	     	 IN		NUMBER
 ,p_record_version_number        IN   		NUMBER
 ,x_return_status                OUT NOCOPY  		VARCHAR2
 ,x_msg_count                    OUT NOCOPY  		NUMBER
 ,x_msg_data                     OUT NOCOPY  		VARCHAR2);
-----------------------------------------------------------------------------------

PROCEDURE VALIDATE_LOGGED_USER_RIGHTS
(p_proposal_id		  IN  NUMBER
,p_logged_user_id         IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------------------------

PROCEDURE CHECK_LOCK_GET_PK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
                ,x_proposal_id			OUT NOCOPY	NUMBER
		,x_user_id			OUT NOCOPY	NUMBER
		,x_role_id			OUT NOCOPY      NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2);

---------------------------------------------------------------------------------------------------------

PROCEDURE GET_ROLE_ID
(p_role_name		  IN  VARCHAR2
,x_role_id                OUT NOCOPY NUMBER
,x_return_status          OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------------------

PROCEDURE CHECK_IF_SEEDED_ROLE
(p_role_id	          IN  VARCHAR2
,x_return_status          OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS;

END IGW_PROP_USER_ROLES_PVT;

 

/
