--------------------------------------------------------
--  DDL for Package OE_INVOICE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INVOICE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUINVS.pls 120.0 2005/05/31 23:44:04 appldev noship $ */

--  Start of Comments
--  API name    OE_Invoice_Util
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
-- Order line Workflow AutoInvoice Interface function
PROCEDURE Update_Interco_Invoiced_Flag
(   p_price_adjustment_id  IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2

);


END OE_Invoice_Util;

 

/
