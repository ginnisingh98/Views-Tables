--------------------------------------------------------
--  DDL for Package AP_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: appurges.pls 120.0 2005/07/07 21:42:28 bghose noship $ */

FUNCTION Set_Purge_Status
         (P_Status           IN  VARCHAR2,
          P_Purge_Name       IN  VARCHAR2,
          P_Debug_Switch     IN  VARCHAR2,
          P_Calling_Sequence IN VARCHAR2)
RETURN BOOLEAN;


FUNCTION Check_no_purge_in_process
         (P_Purge_Name          IN  VARCHAR2,
          P_Debug_Switch        IN  VARCHAR2,
          P_Calling_Sequence    IN  VARCHAR2)
RETURN  BOOLEAN;


FUNCTION Seed_purge_tables
         (P_Category          IN  VARCHAR2,
          P_Purge_Name        IN  VARCHAR2,
          P_Activity_Date     IN  DATE,
          P_Organization_ID   IN  NUMBER,
          P_PA_Status         IN  VARCHAR2,
          P_Purchasing_Status IN  VARCHAR2,
          P_Payables_Status   IN  VARCHAR2,
          P_Assets_Status     IN  VARCHAR2,
          P_Chv_Status           IN  VARCHAR2,
          P_EDI_Status           IN  VARCHAR2,
          P_MRP_Status           IN  VARCHAR2,
          P_Debug_Switch      IN  VARCHAR2,
          P_calling_sequence  IN  VARCHAR2)
RETURN BOOLEAN;


FUNCTION Create_Summary_Records(p_purge_name       IN VARCHAR2,
                                p_category         IN VARCHAR2,
                                p_range_size       IN NUMBER,
                                p_debug_switch     IN VARCHAR2,
                                p_calling_sequence IN VARCHAR2)
RETURN BOOLEAN;


FUNCTION Confirm_Seeded_Data(P_Status            IN  VARCHAR2,
                             P_Category          IN  VARCHAR2,
                             P_Purge_Name        IN  VARCHAR2,
                             P_Activity_Date     IN  DATE,
                             P_Organization_ID   IN  NUMBER,
                             P_PA_Status         IN  VARCHAR2,
                             P_Purchasing_Status IN  VARCHAR2,
                             P_Payables_Status   IN  VARCHAR2,
                             P_Assets_Status     IN  VARCHAR2,
                             P_Chv_Status        IN  VARCHAR2,
                             P_EDI_Status        IN  VARCHAR2,
                             P_MRP_Status        IN  VARCHAR2,
                             P_Debug_Switch      IN  VARCHAR2,
                             p_calling_sequence  IN  VARCHAR2)
RETURN BOOLEAN;


FUNCTION Delete_Seeded_Data
         (P_Purge_Name          IN  VARCHAR2,
          P_Category            IN  VARCHAR2,
          P_activity_Date       IN  DATE,
          P_Range_Size          IN  NUMBER,
          P_Purchasing_Status   IN  VARCHAR2,
          P_MRP_Status          IN  VARCHAR2,
          P_Debug_Switch        IN  VARCHAR2,
          P_Calling_Sequence    IN  VARCHAR2)
RETURN BOOLEAN;


FUNCTION Abort_Purge
         (P_Purge_Name          IN  VARCHAR2,
          P_Original_Status     IN  VARCHAR2,
          P_Debug_Switch        IN  VARCHAR2,
          P_Calling_Sequence    IN  VARCHAR2)
RETURN BOOLEAN;

END AP_PURGE_PKG;

 

/
