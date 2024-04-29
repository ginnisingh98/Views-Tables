--------------------------------------------------------
--  DDL for Package CN_WKSHT_GET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_WKSHT_GET_PUB" AUTHID CURRENT_USER as
-- $Header: cnpwkgts.pls 115.20 2003/07/24 02:54:17 achung ship $

TYPE Wksht_rec IS RECORD
  (  payment_worksheet_id cn_payment_worksheets.payment_worksheet_id%TYPE,
     salesrep_id          cn_salesreps.salesrep_id%TYPE,
     salesrep_name        cn_salesreps.name%TYPE,
     resource_id          cn_salesreps.resource_id%TYPE,
     employee_number      cn_salesreps.employee_number%TYPE,
     current_earnings	  NUMBER,
     pmt_amount_earnings  NUMBER,
     pmt_amount_diff      NUMBER,
     pmt_amount_adj       NUMBER,
     pmt_amount_adj_rec   NUMBER,
     Pmt_amount_total	  NUMBER,
     held_amount          NUMBER,
     worksheet_status     cn_lookups.meaning%TYPE,
     worksheet_status_code cn_lookups.lookup_code%TYPE,
     Analyst_name	   cn_salesreps.assigned_to_user_name%TYPE,
     object_version_number NUMBER,
     view_notes   	  VARCHAR2(1),
     view_ced             VARCHAR2(1),
     status_by		  fnd_user.user_name%TYPE,
     cost_center          cn_salesreps.cost_center%TYPE,
     charge_to_cost_center cn_salesreps.charge_to_cost_center%TYPE,
     notes                cn_lookups.meaning%TYPE
     );

TYPE wksht_tbl IS TABLE OF wksht_rec INDEX BY BINARY_INTEGER;

--============================================================================
-- Start of Comments
--
-- API name 	: Get_srp_wksht
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: To get a salesreps's trx for a given payrun
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
-- IN		:  p_Payrun_id   	IN            cn_payruns.id%TYPE
--
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments
--============================================================================

PROCEDURE  get_srp_wksht
  (
   p_api_version			IN 	NUMBER,
   p_init_msg_list		        IN	VARCHAR2,
   p_commit	    		IN  	VARCHAR2,
   p_validation_level		IN  	NUMBER,
   x_return_status       	 OUT NOCOPY 	VARCHAR2,
   x_msg_count	           OUT NOCOPY 	NUMBER,
   x_msg_data		   OUT NOCOPY 	VARCHAR2,
   p_start_record                  IN      NUMBER,
   p_increment_count               IN      NUMBER,
   p_payrun_id                     IN      NUMBER,
   p_salesrep_name			IN      VARCHAR2,
   p_employee_number		IN 	VARCHAR2,
   p_analyst_name	                IN      VARCHAR2,
   p_my_analyst			IN      VARCHAR2,
   p_unassigned			IN 	VARCHAR2,
   p_worksheet_status		IN 	VARCHAR2,
   p_currency_code			IN 	VARCHAR2,
   p_order_by			IN 	VARCHAR2,
   x_wksht_tbl                     OUT NOCOPY     wksht_tbl,
   x_tot_amount_earnings  	 OUT NOCOPY 	NUMBER,
   x_tot_amount_adj       	 OUT NOCOPY 	NUMBER,
   x_tot_amount_adj_rec   	 OUT NOCOPY 	NUMBER,
   x_tot_amount_total	   OUT NOCOPY 	NUMBER,
   x_tot_held_amount                OUT NOCOPY     NUMBER,
  x_tot_ced                OUT NOCOPY     NUMBER,
  x_tot_earn_diff                OUT NOCOPY     NUMBER,
  x_total_records                 OUT NOCOPY     NUMBER
  );
END CN_wksht_get_pub;

 

/
