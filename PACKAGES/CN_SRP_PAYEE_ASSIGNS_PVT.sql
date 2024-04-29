--------------------------------------------------------
--  DDL for Package CN_SRP_PAYEE_ASSIGNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAYEE_ASSIGNS_PVT" AUTHID CURRENT_USER as
/* $Header: cnvpspas.pls 120.0 2005/06/16 15:19:43 mblum noship $ */

-- Start of Comments
-- API name 	: Create_Srp_Payee_Assigns
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Procedure to CREATE SRP PAYEE ASSIGNS
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		   p_init_msg_list          IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	            IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level       IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_srp_quota_assign_id, p_payee_id,
--                 p_start_date, p_end_date
-- OUT		:  x_return_status          OUT	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT	           NUMBER
-- 		:  x_msg_data	            OUT	           VARCHAR2(2000)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: Srp_payee_assigns
-- Description  :
-- Create_srp_payee_assigns is a PRIVATE API used to assign a payee to a
-- specific sales rep for a given comp plan, role, quota.
-- End of comments
--
PROCEDURE Create_Srp_Payee_Assigns
  (  	p_api_version              IN	NUMBER,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		   OUT NOCOPY NUMBER,
	x_msg_data		   OUT NOCOPY VARCHAR2,
	p_srp_quota_assign_id      IN   NUMBER,
	p_payee_id                 IN   NUMBER,
	p_start_date               IN   DATE,
	p_end_date                 IN   DATE,
	x_srp_payee_assign_id      OUT NOCOPY  NUMBER,
	x_object_version_number    OUT NOCOPY  NUMBER,
	x_loading_status           OUT NOCOPY  VARCHAR2
	);

-- Start of Comments
-- API name 	: UPDATE_SRP_PAYEE_ASSIGNS
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Procedure to UPDATE SRP PAYEE ASSIGNS
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		   p_init_msg_list          IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	            IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level       IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
--                                          IN SRP_PAYEE_ASGNS_REC_TBL_TYPE
-- OUT		:  x_return_status          OUT	          VARCHAR2(1)
-- 		:  x_msg_count	            OUT	          NUMBER
-- 		:  x_msg_data	            OUT	          VARCHAR2(2000)
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: UPDATE_SRP_PAYEE_ASSIGNS
-- Description  :
-- Update_srp_payee_assigns is a PRIVATE API used to update an existing
-- record.
-- End of comments
--
PROCEDURE Update_Srp_Payee_Assigns
  (  	p_api_version              IN	NUMBER,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		   OUT NOCOPY NUMBER,
	x_msg_data		   OUT NOCOPY VARCHAR2,
	p_srp_payee_assign_id      IN   NUMBER,
	p_payee_id                 IN   NUMBER,
	p_start_date               IN   DATE,
	p_end_date                 IN   DATE,
	p_object_version_number    IN  OUT NOCOPY NUMBER,
	x_loading_status           OUT NOCOPY  VARCHAR2
	);

-- Start of Comments
-- API name 	: Valid_Delete_Srp_Payee_asgns
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to validate a Delete a Srp Payee Assigns
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		   p_init_msg_list          IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	            IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level       IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_srp_payee_assign_id
-- OUT		:  x_return_status          OUT    VARCHAR2(1)
-- 		:  x_msg_count	            OUT    NUMBER
-- 		:  x_msg_data	            OUT    VARCHAR2(2000)
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: This procedure should be called before DELETE_SRP_PAYEE_ASSIGNS.
-- End of comments
--
PROCEDURE Valid_Delete_Srp_Payee_Assigns
  (   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		   OUT NOCOPY NUMBER,
	x_msg_data		   OUT NOCOPY VARCHAR2,
	p_srp_payee_assign_id      IN   NUMBER,
	x_loading_status           OUT NOCOPY  VARCHAR2
	);

-- Start of Comments
-- API name 	: Delete_Srp_Payee_asgns
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to Delete a Srp Payee Assigns
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		   p_init_msg_list          IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	            IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level       IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_srp_payee_assign_id
-- OUT		:  x_return_status          OUT    VARCHAR2(1)
-- 		:  x_msg_count	            OUT    NUMBER
-- 		:  x_msg_data	            OUT    VARCHAR2(2000)
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: This Package procedure is Use to DELETE_SRP_PAYEE_ASSIGNS.
-- End of comments
--
PROCEDURE Delete_Srp_Payee_Assigns
  (  	p_api_version              IN	NUMBER,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	   IN  	NUMBER
					   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY VARCHAR2,
	x_msg_count		   OUT NOCOPY NUMBER,
	x_msg_data		   OUT NOCOPY VARCHAR2,
	p_srp_payee_assign_id      IN   NUMBER,
	x_loading_status           OUT NOCOPY  VARCHAR2
	);

END CN_SRP_PAYEE_ASSIGNS_PVT ;

 

/
