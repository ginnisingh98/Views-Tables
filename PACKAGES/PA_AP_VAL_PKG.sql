--------------------------------------------------------
--  DDL for Package PA_AP_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AP_VAL_PKG" AUTHID CURRENT_USER AS
-- /* $Header: PAAPVALS.pls 120.0.12010000.2 2010/03/29 07:13:25 sesingh noship $ */

/*---------------------------------------------------------------------------------------------------------
    --  This procedure is to validate a retention invoice in payables. This is being called from Payables
    -- Input parameters
    --  Parameters                Type           Required  Description
    --  invoice_id              NUMBER            YES      invoice_id being validated
    -- cmt_exist_flag           VARCHAR                     returns whether unprocessed dedns exist
	----------------------------------------------------------------------------------------------------------*/
	Procedure validate_unprocessed_ded ( invoice_id IN ap_invoices_all.invoice_id%type,
				       	     cmt_exist_flag OUT NOCOPY VARCHAR2);
END PA_AP_VAL_PKG ;

/
