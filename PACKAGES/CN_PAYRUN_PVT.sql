--------------------------------------------------------
--  DDL for Package CN_PAYRUN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAYRUN_PVT" AUTHID CURRENT_USER as
-- $Header: cnvpruns.pls 120.3 2005/09/29 19:04:27 rnagired ship $

TYPE Payrun_rec_type IS RECORD
  (  payrun_id             cn_payruns.payrun_id%TYPE,
     name        	   cn_payruns.name%TYPE,
     pay_date 	           cn_payruns.pay_date%TYPE,
     accounting_period_id  cn_payruns.accounting_period_id%TYPE,
     batch_id 	           cn_payruns.batch_id%TYPE,
     status                cn_payruns.status%TYPE,
     pay_period_id         cn_payruns.pay_period_id%TYPE,
     pay_period_start_date cn_period_statuses.start_date%TYPE,
     pay_period_end_date   cn_period_statuses.end_date%TYPE,
     incentive_type_code   cn_posting_details.incentive_type_code%TYPE,
     pay_group_id	   cn_payruns.pay_group_id%TYPE,
     --R12
     org_id          cn_payruns.org_id%TYPE,
     object_version_number cn_payruns.object_version_number%TYPE
  );
--============================================================================
-- Start of comments
-- API name 	: Create_Payrun
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to create a new payrun
--
-- Desc 	: This procedure will validate the input for a payrun
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
-- IN		:  p_payrun_rec        IN	      Required
-- 		   			   Default = G_MISS_PAYRUNS_REC
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: Note text
--
-- End of comments
--============================================================================

PROCEDURE Create_Payrun
( 	p_api_version      IN	NUMBER,
  	p_init_msg_list    IN	VARCHAR2 := cn_api.g_false,
	p_commit	    	 IN  	VARCHAR2 := cn_api.g_false,
	p_validation_level IN  	NUMBER := cn_api.g_valid_level_full,
	x_return_status    OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
	p_Payrun_rec       IN  OUT NOCOPY   Payrun_rec_type,
	x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status           OUT NOCOPY     VARCHAR2
);
--============================================================================
--Start of comments
-- API name 	: Update_Payrun
-- Type		: Public.
-- Usage	: Used to refresh/freeze/unfreeze a payrun
-- Desc 	: Procedure to update a payrun
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		   p_validation_level  IN NUMBER      Optional
-- OUT		:  x_return_status     OUT	      VARCHAR2
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2
-- IN		:  p_payrun_id         IN      	      cn_payruns.payrun_id%TYPE
--		   p_action            IN      	      VARCHAR2
-- OUT		:  x_status 	       OUT	      VARCHAR2
-- 		:  x_loading_status    OUT   	      VARCHAR2
-- End of comments
--============================================================================

   PROCEDURE  Update_Payrun
   (  p_api_version		 IN  NUMBER,
   	p_init_msg_list		 IN  VARCHAR2,
   	p_commit	    		 IN  VARCHAR2,
   	p_validation_level       IN  NUMBER,
   	x_return_status       	 OUT NOCOPY VARCHAR2,
   	x_msg_count	             OUT NOCOPY NUMBER,
   	x_msg_data		       OUT NOCOPY VARCHAR2,
   	p_payrun_id              IN  cn_payruns.payrun_id%TYPE,
      p_x_obj_ver_number       IN OUT NOCOPY cn_payruns.object_version_number%TYPE,
   	p_action                 IN  VARCHAR2,
   	x_status            	 OUT NOCOPY 	VARCHAR2,
	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    );
--============================================================================
-- Start of Comments
--
-- API name 	: Delete_Payrun
-- Type		: Private
-- Pre-reqs	: None.
-- Usage	: Delete
-- Desc 	: Procedure to Delete Payrun
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
-- IN		:  x_Payrun_rec 	IN            Payrun_rec_type
--
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments
--============================================================================
   PROCEDURE  Delete_Payrun
   (
      p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := cn_api.g_false,
	p_commit	    		IN  	VARCHAR2 := cn_api.g_false,
	p_validation_level		IN  	NUMBER := cn_api.g_valid_level_full,
      x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_payrun_id                     IN      cn_payruns.payrun_id%TYPE,
      p_validation_only          IN       VARCHAR2,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
	) ;

--============================================================================
-- Start of Comments
--
-- API name 	: Pay_Payrun
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: To Pay a payrun
-- Desc 	: Procedure to Pay Payrun
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
-- IN		:  p_Payrun_name 	IN            cn_payruns.name%TYPE
--
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments
--============================================================================
   PROCEDURE  Pay_Payrun
   (    p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := cn_api.g_false,
	p_commit	    		IN  	VARCHAR2 := cn_api.g_false,
	p_validation_level		IN  	NUMBER := cn_api.g_valid_level_full,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
    	p_payrun_id                     IN      cn_payruns.payrun_id%TYPE,
      p_x_obj_ver_number       IN OUT NOCOPY cn_payruns.object_version_number%TYPE,
    	x_status            	 OUT NOCOPY 	VARCHAR2,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2
    ) ;

--============================================================================
--Name :        delete_payrun_conc
--Description : Procedure which will be used as the executable for the
--            : concurrent program. delete payrun
--============================================================================
PROCEDURE delete_payrun_conc
     ( errbuf 	  OUT NOCOPY VARCHAR2,
      retcode	  OUT NOCOPY NUMBER ,
      p_name cn_payruns.name%TYPE,
   --R12
      p_org_name hr_operating_units.name%TYPE );
--============================================================================
--Name :        Build Bee API
--Description : Payroll Integration
--            : concurrent program. delete payrun
--============================================================================
PROCEDURE BUILD_BEE_API
  (x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_payrun_id          IN  NUMBER,
   p_loading_status     IN  VARCHAR2,
   x_loading_status     OUT NOCOPY VARCHAR2);
--============================================================================
--Name :        Populate CCIDS
--Description : Procedure  to Populate CCIDs
--============================================================================
FUNCTION populate_ccids
  (
   p_payrun_id            IN  cn_payruns.payrun_id%TYPE,
   p_salesrep_id          IN  cn_payment_worksheets.salesrep_id%TYPE,
   --p_start_date             IN  DATE,
   --p_end_date               IN  DATE,
   --  Bug 3866089 (the same as 11.5.8 bug 3841926, 11.5.10 3866116) by jjhuang on 11/1/04
   p_pmt_tran_id            IN cn_payment_transactions.payment_transaction_id%TYPE DEFAULT NULL,
   p_loading_status       OUT NOCOPY VARCHAR2,
   x_loading_status       OUT NOCOPY VARCHAR2
   ) RETURN VARCHAR2;
END CN_Payrun_PVT ;

 

/
