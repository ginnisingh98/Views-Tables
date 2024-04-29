--------------------------------------------------------
--  DDL for Package AP_INTERFACE_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INTERFACE_WORKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: apiiwkfs.pls 120.4 2004/10/28 23:20:23 pjena noship $ */

  PROCEDURE Custom_Validate_Invoice(p_item_type		IN  VARCHAR2,
			     	    p_item_key		IN  VARCHAR2,
			     	    p_actid		IN  NUMBER,
			     	    p_funmode		IN  VARCHAR2,
			     	    p_result		OUT NOCOPY VARCHAR2);

  PROCEDURE Do_Custom_Validation(p_invoice_id		IN  NUMBER,
				 p_return_error_message OUT NOCOPY VARCHAR2);

  PROCEDURE Start_Invoice_Process(p_invoice_id		IN  NUMBER);

END AP_INTERFACE_WORKFLOW_PKG;

 

/
