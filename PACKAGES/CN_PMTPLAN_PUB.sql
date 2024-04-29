--------------------------------------------------------
--  DDL for Package CN_PMTPLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PMTPLAN_PUB" AUTHID CURRENT_USER as
-- $Header: cnppplns.pls 120.4 2005/11/02 05:37:09 sjustina ship $

TYPE PmtPlan_rec_type IS RECORD
  (	 org_id             cn_pmt_plans.org_id%TYPE,
  	 name        	   cn_pmt_plans.name%TYPE,
     minimum_amount	   cn_pmt_plans.minimum_amount%TYPE,
     maximum_amount	   cn_pmt_plans.maximum_amount%TYPE,
     min_rec_flag	   cn_pmt_plans.min_rec_flag%TYPE,
     max_rec_flag          cn_pmt_plans.max_rec_flag%TYPE,
     max_recovery_amount   cn_pmt_plans.max_recovery_amount%TYPE,
     credit_type_name	   cn_credit_types.name%TYPE,
     pay_interval_type_name cn_interval_types.name%TYPE,
     start_date		   cn_pmt_plans.start_date%TYPE,
     end_date		   cn_pmt_plans.end_date%TYPE,
     object_version_number NUMBER := null,
     recoverable_interval_type  cn_interval_types_all_tl.name%TYPE,
     pay_against_commission  cn_pmt_plans.pay_against_commission%TYPE,
     attribute_category    cn_pmt_plans.attribute_category%TYPE := NULL,
     attribute1            cn_pmt_plans.attribute1%TYPE         := NULL,
     attribute2            cn_pmt_plans.attribute2%TYPE         := NULL,
     attribute3            cn_pmt_plans.attribute3%TYPE         := NULL,
     attribute4            cn_pmt_plans.attribute4%TYPE         := NULL,
     attribute5            cn_pmt_plans.attribute5%TYPE         := NULL,
     attribute6            cn_pmt_plans.attribute6%TYPE         := NULL,
     attribute7            cn_pmt_plans.attribute7%TYPE         := NULL,
     attribute8            cn_pmt_plans.attribute8%TYPE         := NULL,
     attribute9            cn_pmt_plans.attribute9%TYPE         := NULL,
     attribute10           cn_pmt_plans.attribute10%TYPE        := NULL,
     attribute11           cn_pmt_plans.attribute11%TYPE        := NULL,
     attribute12           cn_pmt_plans.attribute12%TYPE        := NULL,
     attribute13           cn_pmt_plans.attribute13%TYPE        := NULL,
     attribute14           cn_pmt_plans.attribute14%TYPE        := NULL,
     attribute15           cn_pmt_plans.attribute15%TYPE        := NULL,
     payment_group_code    cn_pmt_plans.payment_group_code%TYPE := NULL
  );


/*
TYPE PmtPlan_rec_type IS RECORD
  (  name        	   cn_pmt_plans.name%TYPE := fnd_api.g_miss_char,
     minimum_amount	   cn_pmt_plans.minimum_amount%TYPE := fnd_api.g_miss_num,
     maximum_amount	   cn_pmt_plans.maximum_amount%TYPE := fnd_api.g_miss_num,
     min_rec_flag	   cn_pmt_plans.min_rec_flag%TYPE := fnd_api.g_miss_char,
     max_rec_flag          cn_pmt_plans.max_rec_flag%TYPE := fnd_api.g_miss_char,
     max_recovery_amount   cn_pmt_plans.max_recovery_amount%TYPE := fnd_api.g_miss_num,
     credit_type_name	   cn_credit_types.name%TYPE := fnd_api.g_miss_num,
     pay_interval_type_name cn_interval_types.name%TYPE := fnd_api.g_miss_char,
     start_date		   cn_pmt_plans.start_date%TYPE := fnd_api.g_miss_date,
     end_date		   cn_pmt_plans.end_date%TYPE := fnd_api.g_miss_date,
     attribute_category    cn_pmt_plans.attribute_category%TYPE := NULL,
     attribute1            cn_pmt_plans.attribute1%TYPE         := NULL,
     attribute2            cn_pmt_plans.attribute2%TYPE         := NULL,
     attribute3            cn_pmt_plans.attribute3%TYPE         := NULL,
     attribute4            cn_pmt_plans.attribute4%TYPE         := NULL,
     attribute5            cn_pmt_plans.attribute5%TYPE         := NULL,
     attribute6            cn_pmt_plans.attribute6%TYPE         := NULL,
     attribute7            cn_pmt_plans.attribute7%TYPE         := NULL,
     attribute8            cn_pmt_plans.attribute8%TYPE         := NULL,
     attribute9            cn_pmt_plans.attribute9%TYPE         := NULL,
     attribute10           cn_pmt_plans.attribute10%TYPE        := NULL,
     attribute11           cn_pmt_plans.attribute11%TYPE        := NULL,
     attribute12           cn_pmt_plans.attribute12%TYPE        := NULL,
     attribute13           cn_pmt_plans.attribute13%TYPE        := NULL,
     attribute14           cn_pmt_plans.attribute14%TYPE        := NULL,
     attribute15           cn_pmt_plans.attribute15%TYPE        := NULL
  );
  */

  g_mode              VARCHAR2(30); --global to indicate if operation is insert/update

------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Create_PmtPlan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new payment plan
--
-- Desc 	: This procedure will validate the input for a payment plan
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
-- IN		:  p_pmt_plan_rec     IN	      PmtPlan_rec_type
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: Validations in the API are the following :
--                Start date less than end date
--                Name not missing or null
--                Credit type not missing or null
--                Start date not null
--                Min_rec_flag should be 'Y', 'N' or null
--                Max_rec_flag should be 'Y', 'N' or null
--                Payment plan should be unique
--                Credit Type should be valid
--                Pay intervval should be valid 'PERIOD', 'QUARTER', 'YEAR' or null
--
-- End of comments
--------------------------------------------------------------------------+
PROCEDURE Create_PmtPlan
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
	p_PmtPlan_rec       		IN  OUT NOCOPY    PmtPlan_rec_type,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);
/*
PROCEDURE Create_PmtPlan
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
	p_PmtPlan_rec       		IN      PmtPlan_rec_type,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);
*/
--------------------------------------------------------------------------------------+
--Start of comments
-- API name 	: Update_PmtPlan
-- Type		: Public.
-- Pre-reqs	: Payment plan must exist
-- Usage	: Used to update payment plans
-- Desc 	: Procedure to update payment plans
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
-- IN		:  p_old_pmt_plan_rec IN	      PmtPlan_rec_type
-- IN		:  p_pmt_plan_rec     IN	      PmtPlan_rec_type
--
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- OUT		:  x_status 	       OUT
--                   RETURN SQL Status
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        : Validations in the api are the following:
--                Start date cannot be updated to null
--                If end date is specified, it cannot be less than start date
--                The payment plan to be updated should already exist
--                If pmt plan has been assgnd, then recoverable flags can't be updated
--                Start and end dates can't be updated to affect existing assignemnets
--                Name and start date are mandatory parameters
--                If credit type is provided, it should be valid
--                If pay interval is provided, it should be valid
--
-- End of comments
---------------------------------------------------------------------------------------  +

   PROCEDURE  Update_PmtPlan
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_old_PmtPlan_rec               IN      PmtPlan_rec_type,
    	p_PmtPlan_rec                   IN  OUT NOCOPY    PmtPlan_rec_type,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    ) ;

/*
   PROCEDURE  Update_PmtPlan
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_old_PmtPlan_rec              IN      PmtPlan_rec_type,
    	p_PmtPlan_rec                  IN      PmtPlan_rec_type,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    ) ;
*/

---------------------------------------------------------------------------------------+
-- Start of Comments
--
-- API name 	: Delete_PmtPlan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Delete
-- Desc 	: Procedure to Delete Payment Plans
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
-- IN		:  x_PmtPlan_rec 	IN            PmtPlan_rec_type
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        : The following validations are performed by this API
--                Pmt plan should exist
--                Pmt plan cannot  be deleted if assigned to salesreps
--
-- End of comments
-------------------------------------------------------------------------------------    +
   PROCEDURE  Delete_PmtPlan
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_PmtPlan_rec                   IN      PmtPlan_rec_type ,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    ) ;
/*
   PROCEDURE  Delete_PmtPlan
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_pmt_plan_id                   IN      NUMBER,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    ) ;
*/


END CN_PmtPlan_PUB ;
 

/
