--------------------------------------------------------
--  DDL for Package AP_GENERATE_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_GENERATE_DISTRIBUTIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: apaiduts.pls 120.4 2005/10/17 22:11:52 schitlap noship $ */
FUNCTION Generate_Dists_For_Invoice (
                        P_Invoice_Id    	IN  NUMBER,
			P_Batch_Id              IN  NUMBER,
                        P_Invoice_Date          IN  DATE,
                        P_Vendor_Id             IN  NUMBER,
                        P_Invoice_Currency_Code IN  VARCHAR2,
                        P_Exchange_Rate         IN  NUMBER,
                        P_Exchange_Rate_Type    IN  VARCHAR2,
                        P_Exchange_Date         IN  DATE,
			P_Calling_Mode		IN  VARCHAR2,
			P_Error_Code		OUT NOCOPY VARCHAR2,
			P_Token1		OUT NOCOPY VARCHAR2,
			P_Token2		OUT NOCOPY VARCHAR2,
                        P_Calling_Sequence 	IN  VARCHAR2) RETURN BOOLEAN;

FUNCTION Generate_Dists_For_Line (
                        P_Invoice_Id            IN  NUMBER,
			P_Invoice_Line_Number   IN  NUMBER,
			P_Batch_Id              IN  NUMBER,
                        P_Invoice_Date          IN  DATE,
                        P_Vendor_Id             IN  NUMBER,
                        P_Invoice_Currency_Code IN  VARCHAR2,
                        P_Exchange_Rate         IN  NUMBER,
                        P_Exchange_Rate_Type    IN  VARCHAR2,
                        P_Exchange_Date         IN  DATE,
                        P_Error_Code		OUT NOCOPY VARCHAR2,
                        P_Token1		OUT NOCOPY VARCHAR2,
			P_Token2		OUT NOCOPY VARCHAR2,
                        P_Calling_Sequence      IN  VARCHAR2) RETURN BOOLEAN;

FUNCTION generateDistsForInvoice (
                        P_Invoice_Id            IN  NUMBER,
                        P_Batch_Id              IN  NUMBER,
                        P_Invoice_Date          IN  DATE,
                        P_Vendor_Id             IN  NUMBER,
                        P_Invoice_Currency_Code IN  VARCHAR2,
                        P_Exchange_Rate         IN  NUMBER,
                        P_Exchange_Rate_Type    IN  VARCHAR2,
                        P_Exchange_Date         IN  DATE,
                        P_Calling_Mode          IN  VARCHAR2,
                        P_Error_Code            OUT NOCOPY VARCHAR2,
                        P_Token1                OUT NOCOPY VARCHAR2,
                        P_Token2                OUT NOCOPY VARCHAR2,
                        P_Calling_Sequence      IN  VARCHAR2) RETURN NUMBER;


END AP_GENERATE_DISTRIBUTIONS_PKG;

 

/
