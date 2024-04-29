--------------------------------------------------------
--  DDL for Package IGW_PROP_USERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_USERS_PVT" AUTHID CURRENT_USER as
 /* $Header: igwvprus.pls 115.5 2002/11/15 00:46:26 ashkumar ship $*/
PROCEDURE create_prop_user (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         OUT NOCOPY  	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_user_id               	 IN 	NUMBER
 ,p_user_name			 IN	VARCHAR2
 ,p_full_name			 IN	VARCHAR2
 ,p_start_date_active     	 IN	DATE
 ,p_end_date_active       	 IN	DATE
 ,p_logged_user_id		 IN     NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2);
--------------------------------------------------------------------------------------------------------------

Procedure update_prop_user (
  p_init_msg_list                IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN 	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN 	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 		         IN 	VARCHAR2
 ,p_proposal_id			 IN 	NUMBER
 ,p_proposal_number		 IN	VARCHAR2
 ,p_user_id               	 IN 	NUMBER
 ,p_user_name			 IN	VARCHAR2
 ,p_full_name			 IN	VARCHAR2
 ,p_start_date_active     	 IN	DATE
 ,p_end_date_active       	 IN	DATE
 ,p_logged_user_id		 IN     NUMBER
 ,p_record_version_number        IN 	NUMBER
 ,x_return_status                OUT NOCOPY 	VARCHAR2
 ,x_msg_count                    OUT NOCOPY 	NUMBER
 ,x_msg_data                     OUT NOCOPY 	VARCHAR2);
--------------------------------------------------------------------------------------------------------

Procedure delete_prop_user (
  p_init_msg_list                IN   	VARCHAR2   := FND_API.G_FALSE
 ,p_commit                       IN   	VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                IN   	VARCHAR2   := FND_API.G_FALSE
 ,x_rowid 			 IN 	VARCHAR2
 ,p_logged_user_id	     	 IN	NUMBER
 ,p_record_version_number        IN   	NUMBER
 ,x_return_status                OUT NOCOPY  	VARCHAR2
 ,x_msg_count                    OUT NOCOPY  	NUMBER
 ,x_msg_data                     OUT NOCOPY  	VARCHAR2);
 ------------------------------------------------------------------------------------------------

PROCEDURE CHECK_IF_USER_HAS_SEEDED_ROLE
(p_proposal_id	          IN  NUMBER
,p_user_id		  IN  NUMBER
,x_return_status          OUT NOCOPY VARCHAR2);
---------------------------------------------------------------------------------------------

PROCEDURE CHECK_LOCK_GET_COLS
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
                ,x_proposal_id			OUT NOCOPY	NUMBER
		,x_user_id			OUT NOCOPY	NUMBER
		,x_start_date_active		OUT NOCOPY     DATE
		,x_end_date_active		OUT NOCOPY	DATE
		,x_return_status          	OUT NOCOPY 	VARCHAR2);
------------------------------------------------------------------------------------------------

PROCEDURE CHECK_ERRORS;

END IGW_PROP_USERS_PVT;

 

/
