--------------------------------------------------------
--  DDL for Package Body IBY_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_WORKFLOW_PVT" AS
/* $Header: ibywfutb.pls 120.2 2005/10/30 05:49:15 appldev noship $ */

PROCEDURE raise_biz_event
          (
          p_e_name         IN VARCHAR2,
          p_e_key          IN VARCHAR2,
          p_e_param_names  IN JTF_VARCHAR2_TABLE_300,
          p_e_param_vals   IN JTF_VARCHAR2_TABLE_300,
          p_e_data         IN CLOB DEFAULT NULL,
          p_commit         IN VARCHAR2 DEFAULT 'N'
          )
IS
  l_param_list wf_parameter_list_t;
BEGIN

  l_param_list := wf_parameter_list_t();

  IF ((NOT p_e_param_names IS NULL) AND (NOT p_e_param_vals IS NULL)) THEN
    FOR i IN p_e_param_names.FIRST..p_e_param_names.LAST LOOP
      wf_event.AddParameterToList(
          p_name => p_e_param_names(i),
          p_value => p_e_param_vals(i),
          p_parameterlist => l_param_list);
    END LOOP;
  END IF;

  wf_event.raise(
          p_event_name => p_e_name,
          p_event_key => p_e_key,
          p_event_data => p_e_data,
          p_parameters => l_param_list);

  l_param_list.delete;

  IF (UPPER(p_commit) = iby_utility_pvt.C_API_YES) THEN
      commit;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
      l_param_list.delete;
      raise_application_error(-20000, 'IBY_G_WORKFLOW_ERR#' ||
        'ITEM_TYPE=' || p_e_name || '#' ||
        'ITEM_KEY=' || p_e_key || '#' ||
        'WF_ERR_NAME=' || SQLCODE || '#' ||
        'WF_ERR_MSG=' || SQLERRM
        ,FALSE);

END raise_biz_event;


END IBY_WORKFLOW_PVT;

/
