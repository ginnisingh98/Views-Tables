--------------------------------------------------------
--  DDL for Package CN_SRP_PAYGROUP_PUB_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAYGROUP_PUB_CUHK" AUTHID CURRENT_USER as
-- $Header: cncspgps.pls 120.1 2005/10/12 13:50:42 mblum noship $ --+

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Assign_Salesreps_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before assigning salesperson to a paygroup
--
-- Desc 	:
--
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
-- IN		:  p_pay_group_name    IN             cn_pay_groups.name%TYPE
--                 p_pay_group_start_date IN          cn_pay_groups.start_date%TYPE
--                 p_pay_group_end_date   IN          cn_pay_groups.end_date%TYPE
--                 p_PayGroup_assign_rec  IN	      PayGroup_assign_rec%TYPE
--
-- OUT		:  x_loading_status    OUT NOCOPY            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT NOCOPY	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE Assign_salesreps_pre
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		        OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
        p_paygroup_assign_rec           IN OUT NOCOPY  cn_srp_paygroup_pub.PayGroup_assign_rec,
        x_loading_status		OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Assign_Salesreps_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization after assigning salesperson to a paygroup
--
-- Desc 	:
--
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
-- IN		:  p_pay_group_name    IN             cn_pay_groups.name%TYPE
--                 p_pay_group_start_date IN          cn_pay_groups.start_date%TYPE
--                 p_pay_group_end_date   IN          cn_pay_groups.end_date%TYPE
--                 p_PayGroup_assign_rec  IN	      PayGroup_assign_rec%TYPE
--
-- OUT		:  x_loading_status    OUT NOCOPY            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT NOCOPY	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE Assign_salesreps_post
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		        OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
        p_paygroup_assign_rec           IN      cn_srp_paygroup_pub.PayGroup_assign_rec,
        x_loading_status		OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);

--------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Update_srp_assignment_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before updating the salesrep assignment to paygroup
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
-- IN          :   p_old_pay_group_name         IN      cn_pay_groups.name%TYPE,
--	           p_old_pay_group_start_date	IN      cn_pay_groups.start_date%TYPE,
--                 p_old_pay_group_end_date	IN      cn_pay_groups.end_date%TYPE,
--                 p_pay_group_name		IN      cn_pay_groups.name%TYPE,
--                 p_pay_group_start_date	IN      cn_pay_groups.start_date%TYPE,
--                 p_pay_group_end_date	        IN      cn_pay_groups.end_date%TYPE,
--                 p_old_paygroup_assign_rec    IN      PayGroup_assign_rec,
--                 p_paygroup_assign_rec        IN      PayGroup_assign_rec,
--
-- OUT		:  x_loading_status    OUT NOCOPY            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT NOCOPY	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: The following are the validations performed by this API
--                - Checks if the old and the new pay group parameters are valid
--                - Checks if the assignement dates are valid.
--                - Checks that the assignment do not overlap.
--
-- End of comments
--------------------------------------------------------------------------------------+
  PROCEDURE Update_srp_assignment_pre
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status		        OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
        p_old_paygroup_assign_rec       IN OUT NOCOPY  cn_srp_paygroup_pub.PayGroup_assign_rec,
        p_paygroup_assign_rec           IN OUT NOCOPY  cn_srp_paygroup_pub.PayGroup_assign_rec,
        x_loading_status		OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);

--------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Update_srp_assignment_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization after updating the salesrep assignment to paygroup
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
-- IN          :   p_old_pay_group_name         IN      cn_pay_groups.name%TYPE,
--	           p_old_pay_group_start_date	IN      cn_pay_groups.start_date%TYPE,
--                 p_old_pay_group_end_date	IN      cn_pay_groups.end_date%TYPE,
--                 p_pay_group_name		IN      cn_pay_groups.name%TYPE,
--                 p_pay_group_start_date	IN      cn_pay_groups.start_date%TYPE,
--                 p_pay_group_end_date	        IN      cn_pay_groups.end_date%TYPE,
--                 p_old_paygroup_assign_rec    IN      PayGroup_assign_rec,
--                 p_paygroup_assign_rec        IN      PayGroup_assign_rec,
--
-- OUT		:  x_loading_status    OUT NOCOPY            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT NOCOPY	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: The following are the validations performed by this API
--                - Checks if the old and the new pay group parameters are valid
--                - Checks if the assignement dates are valid.
--                - Checks that the assignment do not overlap.
--
-- End of comments
--------------------------------------------------------------------------------------+
  PROCEDURE Update_srp_assignment_post
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status		        OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
        p_old_paygroup_assign_rec       IN      cn_srp_paygroup_pub.PayGroup_assign_rec,
        p_paygroup_assign_rec           IN      cn_srp_paygroup_pub.PayGroup_assign_rec,
        x_loading_status		OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);


--------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: ok_to_generate_msg
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Function to decide whether message needs to be generated
--
-- Desc 	:
--
-- Parameters	:
-- IN		:
-- OUT		:
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments
--------------------------------------------------------------------------------------+
  FUNCTION ok_to_generate_msg
    (p_paygroup_assign_rec           IN      cn_srp_paygroup_pub.paygroup_assign_rec)
RETURN BOOLEAN;


END CN_Srp_PayGroup_PUB_CUHK;
 

/
