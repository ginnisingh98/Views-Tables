--------------------------------------------------------
--  DDL for Package AP_QUICK_CREDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_QUICK_CREDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: apqkcres.pls 120.1 2003/12/22 19:38:53 syidner noship $ */

  FUNCTION Quick_Credit(
             P_Invoice_id              IN NUMBER,
             P_Vendor_Id_For_Invoice   IN NUMBER,
             P_Dm_Gl_Date              IN DATE,
             P_Dm_Org_Id               IN NUMBER,
             P_Credited_Invoice_Id     IN NUMBER,
             P_error_code              OUT NOCOPY VARCHAR2,
             P_calling_sequence        IN VARCHAR2) RETURN BOOLEAN;

END AP_QUICK_CREDIT_PKG;


 

/
