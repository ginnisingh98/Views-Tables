--------------------------------------------------------
--  DDL for Package AP_WITHHOLDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WITHHOLDING_PKG" AUTHID CURRENT_USER as
/* $Header: apdoawts.pls 120.5.12010000.6 2009/11/16 08:11:15 imandal ship $ */

-- Public packaged variables:

l_create_dists     ap_system_parameters.create_awt_dists_type%TYPE;
l_create_invoices  ap_system_parameters.create_awt_invoices_type%TYPE;

PROCEDURE Ap_Do_Withholding(
          P_Invoice_Id             IN     NUMBER,
          P_Awt_Date               IN     DATE,
          P_Calling_Module         IN     VARCHAR2,
          P_Amount                 IN     NUMBER,
          P_Payment_Num            IN     NUMBER DEFAULT NULL,
          P_Checkrun_Name          IN     VARCHAR2 DEFAULT NULL,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER DEFAULT NULL,
          P_Program_Id             IN     NUMBER DEFAULT NULL,
          P_Request_Id             IN     NUMBER DEFAULT NULL,
          P_Awt_Success            OUT NOCOPY    VARCHAR2,
          P_Invoice_Payment_Id     IN     NUMBER DEFAULT NULL,
          P_Check_Id               IN     NUMBER DEFAULT NULL,
          p_checkrun_id            in     number default null);

PROCEDURE Ap_Withhold_AutoSelect(
          P_Checkrun_Name          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          p_checkrun_id            in     number);

PROCEDURE Ap_Withhold_Confirm(
          P_Checkrun_Name          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          p_checkrun_id            in     number,
          p_completed_pmts_group_id in    number,
          p_org_id                  in    number,
          p_check_date              in    date);

PROCEDURE Ap_Withhold_Cancel(
          P_Checkrun_Name          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          p_checkrun_id            in     number,
          p_completed_pmts_group_id in    number default null,
          p_org_id                  in    number default null);

PROCEDURE Ap_Undo_Temp_Withholding(
          P_Invoice_Id             IN     NUMBER,
          P_Vendor_Id              IN     NUMBER DEFAULT NULL,
          P_Payment_Num            IN     NUMBER,
          P_Checkrun_Name          IN     VARCHAR2,
          P_Undo_Awt_Date          IN     DATE,
          P_Calling_Module         IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER DEFAULT NULL,
          P_Program_Id             IN     NUMBER DEFAULT NULL,
          P_Request_Id             IN     NUMBER DEFAULT NULL,
          P_Awt_Success            OUT NOCOPY    VARCHAR2,
          P_checkrun_id            in     number default null);

PROCEDURE Ap_Undo_Withholding(
          P_Parent_Id              IN     NUMBER,
          P_Calling_Module         IN     VARCHAR2,
          P_Awt_Date               IN     DATE,
          P_New_Invoice_Payment_Id IN     NUMBER DEFAULT NULL,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER DEFAULT NULL,
          P_Program_Id             IN     NUMBER DEFAULT NULL,
          P_Request_Id             IN     NUMBER DEFAULT NULL,
          P_Awt_Success            OUT NOCOPY    VARCHAR2,
          P_Inv_Line_No            IN     NUMBER DEFAULT NULL,
          P_Dist_Line_No           IN     NUMBER DEFAULT NULL,
          P_New_Invoice_Id         IN     NUMBER DEFAULT NULL,
          P_New_Dist_Line_No       IN     NUMBER DEFAULT NULL);

PROCEDURE Create_AWT_Distributions(
          P_Invoice_Id             IN     NUMBER,
          P_Calling_Module         IN     VARCHAR2,
          P_Create_Dists           IN     VARCHAR2,
          P_Payment_Num            IN     NUMBER,
          P_Currency_Code          IN     VARCHAR2,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          P_Calling_Sequence       IN     VARCHAR2,
    	  P_Check_Id		   IN 	  NUMBER DEFAULT NULL);  --bug 8590059

PROCEDURE Create_AWT_Invoices(
          P_Invoice_Id             IN     NUMBER,
          P_Payment_Date           IN     DATE,
          P_Last_Updated_By        IN     NUMBER,
          P_Last_Update_Login      IN     NUMBER,
          P_Program_Application_Id IN     NUMBER,
          P_Program_Id             IN     NUMBER,
          P_Request_Id             IN     NUMBER,
          P_Calling_Sequence       IN     VARCHAR2,
          P_Calling_Module         IN     VARCHAR2 DEFAULT NULL, --Bug6660355 -- bug 8266021
          P_Inv_Line_No            IN     NUMBER DEFAULT NULL,
          P_Dist_Line_No           IN     NUMBER DEFAULT NULL,
          P_New_Invoice_Id         IN     NUMBER DEFAULT NULL,
          P_create_dists           IN     VARCHAR2 DEFAULT NULL); --Bug7685907 bug8207324 bug8236169
END AP_WITHHOLDING_PKG;

/
