--------------------------------------------------------
--  DDL for Package PA_INVOICE_TIEBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_TIEBACK" AUTHID CURRENT_USER as
/* $Header: PAXVINTS.pls 115.4 2002/11/23 12:26:34 prajaram ship $ */

  TYPE  num_arr is table of NUMBER index by BINARY_INTEGER;
  TYPE  var_arr_01 is table of VARCHAR2(1) index by BINARY_INTEGER;
  TYPE  var_arr_25 is table of VARCHAR2(25) index by BINARY_INTEGER;
--
-- This procedure will find if any conversion rate from project currency to
-- invoice currency changes or not. If changes, then insert invoice
-- distribution warnings .This function will be called from Invoice tieback
-- process from receivables.
--
-- Parameter  :
--	 P_Project_Id     - Project Id
--       P_Draft_Inv_Num  - Draft Invoice Number
--       P_project_num    - Project Number
--       P_cust_trx_id    - Customer Transaction Id
--       P_user_id        - User id
--       P_request_id     - Request Id
--       P_out_error      - Warning Code
--

PROCEDURE Validate_inv_acct_amt
                      ( P_project_id         IN   num_arr,
                        P_draft_inv_num      IN   num_arr,
                        P_project_num        IN   var_arr_25,
                        P_cust_trx_id        IN   num_arr,
                        P_user_id            IN   NUMBER,
                        P_request_id         IN   NUMBER,
                        P_num_of_rec         IN   NUMBER,
                        P_out_error         OUT  NOCOPY   var_arr_01 );


END PA_INVOICE_TIEBACK;

 

/
