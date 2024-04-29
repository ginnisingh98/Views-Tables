--------------------------------------------------------
--  DDL for Package CS_KB_INTEG_CONSTANTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_INTEG_CONSTANTS_PKG" AUTHID CURRENT_USER AS
  /* $Header: cskbics.pls 115.2 2003/09/03 00:31:14 awwong noship $ */

  /* Integration constants for forms of other teams to use  */
  /*
  OBJECT_CODE     CONSTANT VARCHAR2(30) := 'cskCallingObjectCode';
  OBJECT_ID       CONSTANT VARCHAR2(30) := 'cskCallingObjectId';
  OBJECT_NAME     CONSTANT VARCHAR2(30) := 'cskCallingObjectName';
  OBJECT_NUM      CONSTANT VARCHAR2(30) := 'cskCallingObjectNum';
  SEARCH_TEXT     CONSTANT VARCHAR2(30) := 'cskSearchKeyword';
  SUMMARY_TEXT    CONSTANT VARCHAR2(30) := 'cskSummaryText';
  PRODUCT_IDS     CONSTANT VARCHAR2(30) := 'cskProductItemIds';
  PRODUCT_ORG_IDS  CONSTANT VARCHAR2(30) := 'cskProductOrgIds';
  PLATFORM_IDS     CONSTANT VARCHAR2(30) := 'cskPlatformItemIds';
  PLATFORM_ORG_IDS CONSTANT VARCHAR2(30) := 'cskPlatformOrgIds';
  RETURN_URL       CONSTANT VARCHAR2(30) := 'cskReturnUrl';
  RETURN_LABEL    CONSTANT VARCHAR2(30) := 'cskReturnLabel';
  CALLER_MESSAGE  CONSTANT VARCHAR2(30) := 'cskCallerMessage';
  SHOW_CREATE_SOL_BUTTON  CONSTANT VARCHAR2(30) := 'cskSrchBinShowCreateButton';
  SHOW_NOT_USEFUL_TYPE  CONSTANT VARCHAR2(30) := 'cskSrchBinShowNotUsefulType';
  TASK_PAGE_FUNC  CONSTANT VARCHAR2(30) := 'cskTaskTmplFunc';
  SOLUTION_NUM  CONSTANT VARCHAR2(30) := 'cskSolNum';
  INTEGRATION_EVENT  CONSTANT VARCHAR2(30) := 'cskIntegEvent';
  TASK_GROUP_ID  CONSTANT VARCHAR2(30) := 'cskTaskTemplateGroupId';
  TASK_RETURN_URL  CONSTANT VARCHAR2(30) := 'cskTaskReturnUrl';
  MSG_PARAM_NAME  CONSTANT VARCHAR2(30) := 'cskConfirmMsgParName';
  HIDE_BREAD_CRUMB  CONSTANT VARCHAR2(30) := 'cskHideBreadCrumb';
  RETAIN_AM  CONSTANT VARCHAR2(30) := 'cskRetainAM';
  */

  FUNCTION getParameterName(p_constant IN VARCHAR2)
   RETURN varchar2;

end CS_KB_INTEG_CONSTANTS_PKG;

 

/
