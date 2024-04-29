--------------------------------------------------------
--  DDL for Package CN_PAYGROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYGROUP_PUB" AUTHID CURRENT_USER as
-- $Header: cnppgrps.pls 120.8 2005/11/02 22:50:00 sjustina ship $ --+
/*#
 * The procedures in this package can be used to get pay group information, validate the input, create pay groups, update pay groups, and delete pay groups.
 * They are also used to create entry into cn_pay_groups and to update salesrep pay group assignment.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Pay Group
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

 /**Start of MOAC Org Validation change */
l_org_id NUMBER;
l_status VARCHAR2(1);
 /**End of MOAC Org Validation change */

TYPE PayGroup_rec_type IS RECORD
  (  pay_group_id          cn_pay_groups.pay_group_id%TYPE := CN_API.G_MISS_ID,
     name        	       cn_pay_groups.name%TYPE,
     period_set_name	   cn_pay_groups.period_set_name%TYPE,
     period_type	       cn_pay_groups.period_type%TYPE,
     start_date		       cn_pay_groups.start_date%TYPE,
     end_date		       cn_pay_groups.end_date%TYPE,
     pay_group_description cn_pay_groups.pay_group_description%TYPE := NULL,
     attribute_category    cn_pay_groups.attribute_category%TYPE := NULL,
     attribute1            cn_pay_groups.attribute1%TYPE         := NULL,
     attribute2            cn_pay_groups.attribute2%TYPE         := NULL,
     attribute3            cn_pay_groups.attribute3%TYPE         := NULL,
     attribute4            cn_pay_groups.attribute4%TYPE         := NULL,
     attribute5            cn_pay_groups.attribute5%TYPE         := NULL,
     attribute6            cn_pay_groups.attribute6%TYPE         := NULL,
     attribute7            cn_pay_groups.attribute7%TYPE         := NULL,
     attribute8            cn_pay_groups.attribute8%TYPE         := NULL,
     attribute9            cn_pay_groups.attribute9%TYPE         := NULL,
     attribute10           cn_pay_groups.attribute10%TYPE        := NULL,
     attribute11           cn_pay_groups.attribute11%TYPE        := NULL,
     attribute12           cn_pay_groups.attribute12%TYPE        := NULL,
     attribute13           cn_pay_groups.attribute13%TYPE        := NULL,
     attribute14           cn_pay_groups.attribute14%TYPE        := NULL,
     attribute15           cn_pay_groups.attribute15%TYPE        := NULL,
     object_version_number cn_pay_groups.object_version_number%TYPE := NULL,
     org_id                cn_pay_groups.org_id%TYPE := NULL
  );


TYPE PayGroup_tbl_type IS
   TABLE OF PayGroup_rec_type INDEX BY BINARY_INTEGER ;


G_MISS_PAYGROUP_REC  PayGroup_rec_type;

G_MISS_PAYGROUP_REC_TB  PayGroup_tbl_type;

/*#
 * This procedure gets the pay group information.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after create
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param p_start_record return search results starting from this row
 * @param p_fetch_size number or rows fetched
 * @param p_search_name pay group name to be searched with
 * @param p_search_start_date start date to be searched with
 * @param p_search_end_date end date to be searched with
 * @param p_search_period_set_name Period set name to be searched with
 * @param x_pay_group Record of type PayGroup_tbl_type that contains matched pay group information from the search criteria
 * @param x_total_record total number of rows returned from the search criteria
 * @param p_org_id  Org Identitifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get pay groups
 */
PROCEDURE Get_Pay_Group_Sum
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_search_name                 IN      VARCHAR2 := '%',
   p_search_start_date           IN      DATE := FND_API.G_MISS_DATE,
   p_search_end_date             IN      DATE := FND_API.G_MISS_DATE,
   p_search_period_set_name      IN      VARCHAR2 := '%',
   x_pay_group                   OUT NOCOPY     PayGroup_tbl_type,
   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2,
   p_org_id                      IN NUMBER := NULL
 );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Create_PayGroup
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create pay groups

-- Desc 	: This procedure will validate the input for a pay group
--		  and create one if all validations are passed.

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
-- IN		:  p_PayGroup_rec      IN	      PayGroup_rec

-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.

-- OUT		:  x_status           OUT	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)

-- Version	: Current version	1.0
--		  Initial version 	1.0

-- Notes	: The following validations are performed by this API
--                Name should not be null
--                Period set name should not be null
--                Period Type should not be null
--                Start date should not be null
--                End date should not be null
--                Start date should be less than end date
--                Name, start date and end date should be unique
--                Period set should be valid
--                Period type should be valid

-- End of comments
-------------------------------------------------------------------------------------+
/*#
 * This procedure validates the input for a pay group and creates one if all validations are passed.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after create
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_status Status
 * @param x_loading_status Status
 * @param p_PayGroup_rec Record of type PayGroup_rec_type that stores the data associated with pay group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create pay group
 */
PROCEDURE Create_PayGroup
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
	p_PayGroup_rec   IN OUT NOCOPY    PayGroup_rec_type,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);
------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Update_PayGroup
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to update pay groups
-- Desc 	: Procedure to update pay groups
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_old_PayGroup_rec   IN            PayGroup_rec
-- IN		:  p_PayGroup_rec       IN	      PayGroup_rec

-- OUT		:  x_loading_status    OUT
--                Detailed Error Message
-- OUT		:  x_status 	       OUT
--                   RETURN SQL Status
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        : The following are the validations performed by this api
--                Start date cannot be updated to null
--                End date cannot be updated to null
--                Start date should be less than end date
--                The pay group to be updated should exist
--                Pay group effectivity cannot be shrunk to be less than assignments
--                Pay group name, st date and end date cannot be null
--                If period_set is specified, then it should not be null
--                If period type is specified, then it should not be null
-- End of comments
-------------------------------------------------------------------------------------+
/*#
 * This API is used to update pay groups.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_status Status
 * @param x_loading_status Status
 * @param p_old_Paygroup_rec Record of type PayGroup_rec_type that stores the old data associated with pay group
 * @param p_PayGroup_rec Record of type PayGroup_rec_type that stores the updated data associated with pay group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update pay group
 */
   PROCEDURE  Update_PayGroup
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
        p_old_Paygroup_rec     IN  PayGroup_rec_type,
	p_PayGroup_rec         IN OUT NOCOPY     PayGroup_rec_type,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    ) ;

--------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Delete_PayGroup
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Delete
-- Desc 	: Procedure to Delete Pay Groups
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_PayGroup_rec 	IN            PayGroup_rec_type
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        : The following validations are done by this API
--                Pay group to be deleted must exist
-- End of comments
--------------------------------------------------------------------------------------+
/*#
 * This API is used to delete pay groups.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after delete
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the delete operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_status Status
 * @param x_loading_status Status
 * @param p_PayGroup_rec Record of type PayGroup_rec_type that stores the data associated with pay group
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete pay group
 */
 PROCEDURE  Delete_PayGroup
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_PayGroup_rec                  IN OUT NOCOPY     PayGroup_rec_type ,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    ) ;


TYPE PayGroup_assign_rec IS RECORD
  (  employee_type	   cn_salesreps.type%TYPE,
     employee_number       cn_salesreps.employee_number%TYPE,
     assignment_start_date cn_srp_pay_groups.start_date%TYPE,
     assignment_end_date   cn_srp_pay_groups.end_date%TYPE,
     attribute_category    cn_srp_pay_groups.attribute_category%TYPE := NULL,
     attribute1            cn_srp_pay_groups.attribute1%TYPE         := NULL,
     attribute2            cn_srp_pay_groups.attribute2%TYPE         := NULL,
     attribute3            cn_srp_pay_groups.attribute3%TYPE         := NULL,
     attribute4            cn_srp_pay_groups.attribute4%TYPE         := NULL,
     attribute5            cn_srp_pay_groups.attribute5%TYPE         := NULL,
     attribute6            cn_srp_pay_groups.attribute6%TYPE         := NULL,
     attribute7            cn_srp_pay_groups.attribute7%TYPE         := NULL,
     attribute8            cn_srp_pay_groups.attribute8%TYPE         := NULL,
     attribute9            cn_srp_pay_groups.attribute9%TYPE         := NULL,
     attribute10           cn_srp_pay_groups.attribute10%TYPE        := NULL,
     attribute11           cn_srp_pay_groups.attribute11%TYPE        := NULL,
     attribute12           cn_srp_pay_groups.attribute12%TYPE        := NULL,
     attribute13           cn_srp_pay_groups.attribute13%TYPE        := NULL,
     attribute14           cn_srp_pay_groups.attribute14%TYPE        := NULL,
     attribute15           cn_srp_pay_groups.attribute15%TYPE        := NULL );

END CN_PAYGROUP_PUB ;

 

/
