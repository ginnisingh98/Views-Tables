--------------------------------------------------------
--  DDL for Package IBY_UPGRADE_PARAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_UPGRADE_PARAM_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyupgps.pls 120.0 2005/05/03 22:42:09 jleybovi noship $ */


--
-- Name: update_account
-- Args:
--       p_bep_account_id => the BEP account ID (type)
--       p_bepid_ => The bep ID
--       p_merchant_account_names => names of merchant account optionss
--       p_merchant_account_values => values of merchant account options
--       p_online_param_names    => names of online transmission parameters
--       p_online_param_values  => values of online transmission parameters
--       p_online_param_types   => types of online transmission parameters
--       p_settle_param_names    => names of settle transmission parameters
--       p_settle_param_values  => values of settle transmission parameters
--       p_settle_param_types   => types of settle transmission parameters
--       p_query_param_names    => names of query transmission parameters
--       p_query_param_values  => values of query transmission parameters
--       p_query_param_types   => types of online transmission parameters
--       p_commit => flag to indicate whether to commit
--
PROCEDURE update_account
          (
          p_bep_account_id          IN NUMBER,
	  p_bepid                   IN NUMBER,
          p_merchant_account_names  IN JTF_VARCHAR2_TABLE_100,
          p_merchant_account_values IN JTF_VARCHAR2_TABLE_100,
          p_online_param_names      IN JTF_VARCHAR2_TABLE_100,
          p_online_param_values     IN JTF_VARCHAR2_TABLE_100,
          p_online_param_types      IN JTF_VARCHAR2_TABLE_100,
          p_settle_param_names      IN JTF_VARCHAR2_TABLE_100,
          p_settle_param_values     IN JTF_VARCHAR2_TABLE_100,
          p_settle_param_types      IN JTF_VARCHAR2_TABLE_100,
          p_query_param_names       IN JTF_VARCHAR2_TABLE_100,
          p_query_param_values      IN JTF_VARCHAR2_TABLE_100,
          p_query_param_types       IN JTF_VARCHAR2_TABLE_100,
          p_commit                  IN VARCHAR2 DEFAULT 'N'
          );

END IBY_UPGRADE_PARAM_PVT;

 

/
