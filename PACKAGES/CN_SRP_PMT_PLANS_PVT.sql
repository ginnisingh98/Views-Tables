--------------------------------------------------------
--  DDL for Package CN_SRP_PMT_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PMT_PLANS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvsppas.pls 120.4 2005/07/25 04:32:29 raramasa noship $ */

TYPE pmt_plan_assign_rec IS RECORD
  (srp_pmt_plan_id            cn_srp_pmt_plans.srp_pmt_plan_id%TYPE,
   salesrep_id                cn_srp_pmt_plans.salesrep_id%TYPE,
   org_id                     cn_srp_pmt_plans.org_id%TYPE,
   pmt_plan_id                cn_srp_pmt_plans.pmt_plan_id%TYPE,
   start_date                 cn_srp_pmt_plans.start_date%TYPE,
   end_date                   cn_srp_pmt_plans.end_date%TYPE,
   minimum_amount             cn_srp_pmt_plans.minimum_amount%TYPE,
   maximum_amount             cn_srp_pmt_plans.maximum_amount%TYPE,
   srp_role_id                cn_srp_pmt_plans.srp_role_id%TYPE,
   role_pmt_plan_id           cn_srp_pmt_plans.role_pmt_plan_id%TYPE,
   lock_flag                  cn_srp_pmt_plans.lock_flag%TYPE,
   object_version_number      cn_srp_pmt_plans.object_version_number%TYPE);

TYPE payrun_tbl IS TABLE OF cn_payruns.name%TYPE;

-- --------------------------------------------------------------------------*
-- Procedure: Create_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Create_Srp_Pmt_Plan
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY	VARCHAR2		      ,
	x_loading_status           OUT NOCOPY  VARCHAR2 	              ,
	x_msg_count		   OUT NOCOPY	NUMBER			      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
        p_pmt_plan_assign_rec      IN OUT NOCOPY pmt_plan_assign_rec);

-- --------------------------------------------------------------------------*
-- Procedure: Update_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Update_Srp_Pmt_Plan
  (  	p_api_version              IN	NUMBER				      ,
     	p_init_msg_list		   IN	VARCHAR2,
  	p_commit	    	   IN  	VARCHAR2,
  	p_validation_level	   IN  	NUMBER,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_loading_status           OUT NOCOPY  VARCHAR2                       ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2                      ,
	p_pmt_plan_assign_rec      IN OUT NOCOPY  pmt_plan_assign_rec	);

-- --------------------------------------------------------------------------*
-- Procedure: Valid_Delete_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE valid_delete_srp_pmt_plan
  (  	p_srp_pmt_plan_id          IN   NUMBER,
     	p_init_msg_list		   IN	VARCHAR2,
  	x_loading_status	   OUT NOCOPY	VARCHAR2	     	      ,
  	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
  	x_msg_count		   OUT NOCOPY	NUMBER			      ,
  	x_msg_data		   OUT NOCOPY	VARCHAR2);

-- --------------------------------------------------------------------------*
-- Procedure: Delete_Srp_Pmt_Plan
-- --------------------------------------------------------------------------*
PROCEDURE Delete_Srp_Pmt_Plan
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2,
	p_commit	    	   IN  	VARCHAR2,
	p_validation_level	   IN  	NUMBER,
	x_return_status		   OUT NOCOPY	VARCHAR2	     	      ,
	x_loading_status           OUT NOCOPY  VARCHAR2 	              ,
	x_msg_count		   OUT NOCOPY	NUMBER		    	      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2               	      ,
        p_srp_pmt_plan_id          IN   NUMBER);

-- --------------------------------------------------------------------------*
-- Procedure: check_payruns
-- --------------------------------------------------------------------------*
PROCEDURE check_payruns
  (p_operation              IN VARCHAR2,
   p_srp_pmt_plan_id        IN NUMBER,
   p_salesrep_id            IN  NUMBER,
   p_start_date		    IN  DATE,
   p_end_date		    IN  DATE,
   x_payrun_tbl             OUT NOCOPY payrun_tbl
   );

-- Start of comments
-- API name 	: Create_Mass_Asgn_Srp_Pmt_Plan
-- Type		: Private
-- Pre-reqs	: None.
-- Usage	: Used to create a new mass payment plan assignment to an salesrep
-- Desc 	: Procedure to create a new mass payment plan assignment to salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 		   p_role_pmt_plan_id  IN             NUMBER
--                 p_srp_role_id       IN             NUMBER
--
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
PROCEDURE Create_Mass_Asgn_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_srp_pmt_plan_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );


-- Start of comments
-- API name 	: Update_Mass_Asgn_Srp_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to update mass pmt plan assignment of an salesrep
-- Desc 	: Procedure to update mass pmt plan assignment of an salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 	           p_srp_role_id       IN NUMBER
--                 p_role_pmt_plan_id  IN NUMBER
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
PROCEDURE Update_Mass_Asgn_Srp_Pmt_plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );

-- Start of comments
-- API name 	: Delete_Mass_Asgn_Srp_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to delete a payment plan assignment to an salesrep
-- Desc 	: Procedure to delete a payment plan assignment to salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
--  	           p_srp_role_id       IN NUMBER
--                 p_role_pmt_plan_id  IN NUMBER
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
PROCEDURE Delete_Mass_Asgn_Srp_Pmt_Plan
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );

END cn_srp_pmt_plans_pvt;

 

/
