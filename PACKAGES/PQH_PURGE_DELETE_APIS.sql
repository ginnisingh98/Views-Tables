--------------------------------------------------------
--  DDL for Package PQH_PURGE_DELETE_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PURGE_DELETE_APIS" AUTHID CURRENT_USER AS
/* $Header: pqpurdel.pkh 115.1 2002/03/22 05:43:21 pkm ship        $ */


PROCEDURE pqh_ptx_shadow_del(p_position_transaction_id IN NUMBER,p_object_version_number IN NUMBER);
PROCEDURE pqh_ptx_dpf_df_del(p_ptx_deployment_factor_id IN NUMBER,p_object_version_number IN NUMBER);
PROCEDURE pqh_ptx_dpf_df_shadow_del(p_ptx_deployment_factor_id IN NUMBER,p_object_version_number IN NUMBER);
PROCEDURE pqh_tjr_shadow_del(p_txn_job_requirement_id IN NUMBER,p_object_version_number IN NUMBER);
PROCEDURE pqh_pte_shadow_del (p_ptx_extra_info_id IN NUMBER,p_object_version_number IN NUMBER);
END;

 

/
