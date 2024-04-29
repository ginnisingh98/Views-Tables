--------------------------------------------------------
--  DDL for Package IBY_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_WORKFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: ibywfuts.pls 120.2 2005/10/30 05:49:16 appldev noship $ */


--
-- Name: raise_biz_event
-- Args:
--       p_e_name => the event name (type)
--       p_e_key => key to the event
--       p_e_param_names => names of event parameters
--       p_e_param_vals => values of event parameters
--       p_e_data => data to the event (optional)
--       p_commit => flag to indicate whether to commit
--
PROCEDURE raise_biz_event
          (
          p_e_name         IN VARCHAR2,
          p_e_key          IN VARCHAR2,
          p_e_param_names  IN JTF_VARCHAR2_TABLE_300,
          p_e_param_vals   IN JTF_VARCHAR2_TABLE_300,
          p_e_data         IN CLOB DEFAULT NULL,
          p_commit         IN VARCHAR2 DEFAULT 'N'
          );

END IBY_WORKFLOW_PVT;

/
