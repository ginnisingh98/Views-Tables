--------------------------------------------------------
--  DDL for Package PSP_REPORT_TEMPLATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_REPORT_TEMPLATE_BK2" AUTHID CURRENT_USER as
/* $Header: PSPRTAIS.pls 120.1 2005/07/05 23:50:23 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------- Update_Report_Template_b -------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Report_Template_b
    (P_TEMPLATE_ID                 in     NUMBER
   , P_TEMPLATE_NAME               in    VARCHAR2
   , P_BUSINESS_GROUP_ID           in    NUMBER
   , P_SET_OF_BOOKS_ID             in    NUMBER
   , P_REPORT_TYPE                 in    VARCHAR2
   , P_PERIOD_FREQUENCY_ID         in    NUMBER
   , P_REPORT_TEMPLATE_CODE        in    VARCHAR2
   , P_DISPLAY_ALL_EMP_DISTRIB_FLAG in              VARCHAR2
   , P_MANUAL_ENTRY_OVERRIDE_FLAG  in              VARCHAR2
   , P_APPROVAL_TYPE               in              VARCHAR2
   , P_SUP_LEVELS                  in              NUMBER
   , P_PREVIEW_EFFORT_REPORT_FLAG  in    VARCHAR2
   , P_NOTIFICATION_REMINDER in             NUMBER
   , P_SPRCD_TOLERANCE_AMT           in            NUMBER
   , P_SPRCD_TOLERANCE_PERCENT       in            NUMBER
   , P_DESCRIPTION                   in            VARCHAR2
   , P_EGISLATION_CODE               in           VARCHAR2
   ,P_CUSTOM_APPROVAL_CODE	     in		VARCHAR2
   , P_HUNDRED_PCENT_EFF_AT_PER_ASG  in		VARCHAR2
   , P_SELECTION_MATCH_LEVEL         in		VARCHAR2
   );
--
-- ----------------------------------------------------------------------------
-- |------------------------- Update_Report_Template_a -------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Report_Template_a
  ( P_TEMPLATE_ID                 in     NUMBER
   , P_TEMPLATE_NAME               in    VARCHAR2
   , P_BUSINESS_GROUP_ID           in    NUMBER
   , P_SET_OF_BOOKS_ID             in    NUMBER
   , P_REPORT_TYPE                 in    VARCHAR2
   , P_PERIOD_FREQUENCY_ID         in    NUMBER
   , P_REPORT_TEMPLATE_CODE        in    VARCHAR2
   , P_DISPLAY_ALL_EMP_DISTRIB_FLAG in              VARCHAR2
   , P_MANUAL_ENTRY_OVERRIDE_FLAG  in              VARCHAR2
   , P_APPROVAL_TYPE               in              VARCHAR2
   , P_SUP_LEVELS                  in              NUMBER
   , P_PREVIEW_EFFORT_REPORT_FLAG  in    VARCHAR2
   , P_NOTIFICATION_REMINDER in             NUMBER
   , P_SPRCD_TOLERANCE_AMT           in            NUMBER
   , P_SPRCD_TOLERANCE_PERCENT       in            NUMBER
   , P_DESCRIPTION                   in            VARCHAR2
   , P_EGISLATION_CODE               in           VARCHAR2
   , P_OBJECT_VERSION_NUMBER         in           number
   , P_WARNING                       in           boolean
   , P_RETURN_STATUS                 in           boolean
   ,P_CUSTOM_APPROVAL_CODE	     in		VARCHAR2
   , P_HUNDRED_PCENT_EFF_AT_PER_ASG  in		VARCHAR2
   , P_SELECTION_MATCH_LEVEL         in		VARCHAR2
  );
end PSP_Report_Template_BK2;

 

/
