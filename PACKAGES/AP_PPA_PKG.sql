--------------------------------------------------------
--  DDL for Package AP_PPA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PPA_PKG" AUTHID CURRENT_USER AS
/* $Header: aprddtss.pls 120.2 2003/06/17 18:37:20 isartawi noship $ */

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Public Procedure Specification
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE Due_Date_Sweeper(p_invoice_id		IN NUMBER,
			   p_matched		IN BOOLEAN,
			   p_system_user	IN NUMBER,
			   p_receipt_acc_days   IN NUMBER,
			   p_calling_sequence	IN VARCHAR2);
END AP_PPA_PKG;

 

/
