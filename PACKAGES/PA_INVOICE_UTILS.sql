--------------------------------------------------------
--  DDL for Package PA_INVOICE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_UTILS" AUTHID CURRENT_USER as
-- $Header: PAINUTLS.pls 115.0 99/08/05 13:00:08 porting ship  $
--
--  FUNCTION
--              Check_draft_invoice_exists
--
--
Function check_draft_invoice_exists (x_project_id     IN number,
                                     x_customer_id	IN number)
return number;
pragma RESTRICT_REFERENCES (check_draft_invoice_exists, WNDS, WNPS);

end PA_INVOICE_UTILS;

 

/
