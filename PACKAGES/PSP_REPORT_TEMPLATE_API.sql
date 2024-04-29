--------------------------------------------------------
--  DDL for Package PSP_REPORT_TEMPLATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_REPORT_TEMPLATE_API" AUTHID CURRENT_USER as
/* $Header: PSPRTAIS.pls 120.1 2005/07/05 23:50:23 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------- Create_Report_Template --------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_Report_Template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Create_Report_Template
  (P_VALIDATE                      in     boolean  default false
   , P_TEMPLATE_ID                 in     NUMBER
   , P_TEMPLATE_NAME               in   VARCHAR2
   , P_BUSINESS_GROUP_ID           in   NUMBER
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
   , P_OBJECT_VERSION_NUMBER       out nocopy      NUMBER
   , P_WARNING                     out nocopy      boolean
   , P_RETURN_STATUS               out nocopy      boolean
   , P_CUSTOM_APPROVAL_CODE	     in		VARCHAR2
   , P_HUNDRED_PCENT_EFF_AT_PER_ASG  in		VARCHAR2
   , P_SELECTION_MATCH_LEVEL         in		VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Report_Template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Report_Template
  (P_VALIDATE                      in     boolean  default false
   , P_TEMPLATE_ID                   in	        NUMBER
   , P_TEMPLATE_NAME               in      VARCHAR2
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
   , P_OBJECT_VERSION_NUMBER       in out nocopy      NUMBER
   , P_WARNING                     out nocopy      boolean
   , P_RETURN_STATUS               out nocopy      boolean
   ,P_CUSTOM_APPROVAL_CODE	     in		VARCHAR2
   , P_HUNDRED_PCENT_EFF_AT_PER_ASG  in		VARCHAR2
   , P_SELECTION_MATCH_LEVEL         in		VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_Report_Template >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure Delete_Report_Template
  (P_VALIDATE                       in     BOOLEAN default false
  ,P_TEMPLATE_ID                      in     number
  ,P_OBJECT_VERSION_NUMBER          in out nocopy number
  ,P_WARNING                       out nocopy varchar2
  );
end PSP_Report_Template_API;

 

/
