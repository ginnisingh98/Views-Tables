--------------------------------------------------------
--  DDL for Package CN_SRP_PAYGROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PAYGROUP_PUB" AUTHID CURRENT_USER as
-- $Header: cnpspgps.pls 120.2 2005/10/27 16:02:55 mblum noship $
/*#
 * The procedures in this package can be used to assign salesreps to a pay group and to update that assignment. They can also be used for mass assignment and mass update of pay groups to salesreps.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Assign Pay Groups
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */
TYPE PayGroup_assign_rec IS RECORD
  (  pay_group_name        cn_pay_groups.name%TYPE                 := cn_api.g_miss_char,
     employee_type	   VARCHAR2(30)                            := cn_api.g_miss_char,
     employee_number       cn_salesreps.employee_number%TYPE       := cn_api.g_miss_char,
     source_id		   cn_salesreps.source_id%TYPE		   := null,
     assignment_start_date cn_srp_pay_groups.start_date%TYPE       := cn_api.g_miss_date,
     assignment_end_date   cn_srp_pay_groups.end_date%TYPE         := cn_api.g_miss_date,
     lock_flag             cn_srp_pay_groups.lock_flag%TYPE        := cn_api.g_miss_char,
     role_pay_group_id     cn_srp_pay_groups.role_pay_group_id%TYPE  := cn_api.g_miss_id,
     org_id                cn_srp_pay_groups.org_id%TYPE             := NULL,
     attribute_category    cn_srp_pay_groups.attribute_category%TYPE
                             := cn_api.g_miss_char,
     attribute1            cn_srp_pay_groups.attribute1%TYPE
                             := cn_api.g_miss_char,
     attribute2            cn_srp_pay_groups.attribute2%TYPE
                             := cn_api.g_miss_char,
     attribute3            cn_srp_pay_groups.attribute3%TYPE
                             := cn_api.g_miss_char,
     attribute4            cn_srp_pay_groups.attribute4%TYPE
                             := cn_api.g_miss_char,
     attribute5            cn_srp_pay_groups.attribute5%TYPE
                             := cn_api.g_miss_char,
     attribute6            cn_srp_pay_groups.attribute6%TYPE
                             := cn_api.g_miss_char,
     attribute7            cn_srp_pay_groups.attribute7%TYPE
                             := cn_api.g_miss_char,
     attribute8            cn_srp_pay_groups.attribute8%TYPE
                             := cn_api.g_miss_char,
     attribute9            cn_srp_pay_groups.attribute9%TYPE
                             := cn_api.g_miss_char,
     attribute10           cn_srp_pay_groups.attribute10%TYPE
                             := cn_api.g_miss_char,
     attribute11           cn_srp_pay_groups.attribute11%TYPE
                             := cn_api.g_miss_char,
     attribute12           cn_srp_pay_groups.attribute12%TYPE
                             := cn_api.g_miss_char,
     attribute13           cn_srp_pay_groups.attribute13%TYPE
                             := cn_api.g_miss_char,
     attribute14           cn_srp_pay_groups.attribute14%TYPE
                             := cn_api.g_miss_char,
     attribute15           cn_srp_pay_groups.attribute15%TYPE
                             := cn_api.g_miss_char);
-- Start of comments
-- API name 	: Assign_Salesreps
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create entry into cn_pay_groups
--
-- Desc 	: This procedure will validate the input for a pay group
--		  and create one if all validations are passed.
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_PayGroup_assign_rec  IN	      PayGroup_assign_rec%TYPE
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes	: The following validations are performed by this API
--                 - Checks if the paygroup exist
--                 - Checks if the salesrep exists
--                 - Checks that the assignments do not overlap
--
-- End of comments
/*#
 * This procedure is used to create entry into cn_srp_pay_groups. The procedure validates the input for a pay group and creates one if all validations are passed.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after assignment created
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_status Status
 * @param x_loading_status Status
 * @param p_paygroup_assign_rec Record of type PayGroup_assign_rec that stores the data associated with pay group assignments
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign pay group to salesperson
 */
 PROCEDURE Assign_salesreps
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := cn_api.g_false,
	p_commit	    		IN  	VARCHAR2 := cn_api.g_false,
	p_validation_level		IN  	NUMBER   := cn_api.g_valid_level_full,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        p_paygroup_assign_rec           IN      PayGroup_assign_rec,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);


-- Start of comments
-- API name 	: Create_Mass_Asgn_Srp_Pay_Group
-- Type		: Public.
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
-- 		   p_role_pay_pgroup_id  IN             NUMBER
--                 p_srp_role_id       IN             NUMBER
--
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0

/*#
 * This procedure is used to create a new mass pay group assignment to salesreps.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after create
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_srp_pay_group_id Return the unique identifier of this assignment
 * @param x_loading_status Status
 * @param p_srp_role_id Unique identifier of role assigned to a given salesperson
 * @param p_role_pay_group_id Unique identifier of role assigned to a given pay group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create pay group mass assignments
 */
 PROCEDURE Create_Mass_Asgn_Srp_Pay
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pay_group_id   IN    NUMBER,
   x_srp_pay_group_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );




-- Start of comments
-- API name 	: Update_salesrep_assignment
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create entry into cn_pay_groups
--
-- Desc 	: This procedure will validate the input for a pay group
--		  and create one if all validations are passed.
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN          :   p_old_paygroup_assign_rec    IN      PayGroup_assign_rec,
--                 p_paygroup_assign_rec        IN      PayGroup_assign_rec,
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT	      VARCHAR2(50)
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
/*#
 * This procedure is used to update the pay group assignment of a salesrep.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_loading_status Status
 * @param x_status Status
 * @param p_old_paygroup_assign_rec Record of type PayGroup_assign_rec that stores the old data associated with pay group assignments
 * @param p_paygroup_assign_rec Record of type PayGroup_assign_rec that stores the data associated with pay group assignments
 * @param p_ovn Object version number of the pay group assignments
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update pay group assignments
 */
  PROCEDURE Update_srp_assignment
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := cn_api.g_false,
	p_commit	    		IN  	VARCHAR2 := cn_api.g_false,
	p_validation_level		IN  	NUMBER   := cn_api.g_valid_level_full,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        p_old_paygroup_assign_rec       IN      PayGroup_assign_rec,
        p_paygroup_assign_rec           IN      PayGroup_assign_rec,
        p_ovn                           IN      NUMBER,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);
/*#
 * This procedure is used to update mass pay group assignment of salesreps.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_loading_status Status
 * @param p_srp_role_id Unique identifier of role assigned to a given salesperson
 * @param p_role_pay_group_id Unique identifier of role assigned to a given pay group
 * @param x_srp_pay_group_id Return the unique identifier of this assignment
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update pay group mass assignments
 */

PROCEDURE Update_Mass_Asgn_Srp_Pay
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pay_group_id   IN    NUMBER,
   x_srp_pay_group_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );

END CN_Srp_PayGroup_PUB ;

 

/
