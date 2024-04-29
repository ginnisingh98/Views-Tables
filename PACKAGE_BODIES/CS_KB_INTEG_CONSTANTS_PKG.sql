--------------------------------------------------------
--  DDL for Package Body CS_KB_INTEG_CONSTANTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_INTEG_CONSTANTS_PKG" AS
  /* $Header: cskbicb.pls 115.1 2003/12/02 23:08:11 awwong noship $ */

  FUNCTION getParameterName(p_constant IN VARCHAR2)
   RETURN varchar2
  IS
    l_name varchar2(100) := null;
  BEGIN
    if(p_constant = 'OBJECT_CODE') then
      l_name := 'cskCallingObjectCode';

    elsif (p_constant = 'OBJECT_ID') then
      l_name := 'cskCallingObjectId';

    elsif (p_constant = 'OBJECT_NAME') then
      l_name := 'cskCallingObjectName';

    elsif (p_constant = 'OBJECT_NUM') then
      l_name := 'cskCallingObjectNum';

    elsif (p_constant = 'SEARCH_TEXT') then
      l_name := 'cskSearchKeyword';

    elsif (p_constant = 'SUMMARY_TEXT') then
      l_name := 'cskSummaryText';

    elsif (p_constant = 'PRODUCT_IDS') then
      l_name := 'cskProductItemIds';

    elsif (p_constant = 'PRODUCT_ORG_IDS') then
      l_name := 'cskProductOrgIds';

    elsif (p_constant = 'PLATFORM_IDS') then
      l_name := 'cskPlatformItemIds';

    elsif (p_constant = 'PLATFORM_ORG_IDS') then
      l_name := 'cskPlatformOrgIds';

    elsif (p_constant = 'RETURN_URL') then
      l_name := 'cskReturnUrl';

    elsif (p_constant = 'RETURN_LABEL') then
      l_name := 'cskReturnLabel';

    elsif (p_constant = 'CALLER_MESSAGE') then
      l_name := 'cskCallerMessage';

    elsif (p_constant = 'SHOW_CREATE_SOL_BUTTON') then
      l_name := 'cskSrchBinShowCreateButton';

    elsif (p_constant = 'SHOW_NOT_USEFUL_TYPE') then
      l_name := 'cskSrchBinShowNotUsefulType';

    elsif (p_constant = 'TASK_PAGE_FUNC') then
      l_name := 'cskTaskTmplFunc';

    elsif (p_constant = 'SOLUTION_NUM') then
      l_name := 'cskSolNum';

    elsif (p_constant = 'INTEGRATION_EVENT') then
      l_name := 'cskIntegEvent';

    elsif (p_constant = 'TASK_GROUP_ID') then
      l_name := 'cskTaskTemplateGroupId';

    elsif (p_constant = 'TASK_RETURN_URL') then
      l_name := 'cskTaskReturnUrl';

    elsif (p_constant = 'HIDE_BREAD_CRUMB') then
      l_name := 'cskHideBreadCrumb';

    elsif (p_constant = 'RETAIN_AM') then
      l_name := 'cskRetainAM';

    elsif (p_constant = 'MSG_TYPE_NAME') then
      l_name := 'cskMsgType';
    elsif (p_constant = 'MSG_PARAM_NAME') then
      l_name := 'cskMsgText';
    elsif (p_constant = 'INFORMATION') then
      l_name := 'I';
    elsif (p_constant = 'CONFIRMATION') then
      l_name := 'C';
    elsif (p_constant = 'WARNING') then
      l_name := 'W';
    elsif (p_constant = 'ERROR') then
      l_name := 'E';
    elsif (p_constant = 'SEVERE') then
      l_name := 'S';

    end if;

    return l_name;

  END getParameterName;


end CS_KB_INTEG_CONSTANTS_PKG;

/
