--------------------------------------------------------
--  DDL for Package Body PQH_PURGE_DELETE_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PURGE_DELETE_APIS" AS
/* $Header: pqpurdel.pkb 115.1 2002/03/22 05:43:20 pkm ship        $ */


--
PROCEDURE pqh_ptx_shadow_del(p_position_transaction_id IN NUMBER , p_object_version_number IN NUMBER) IS
BEGIN
delete from pqh_ptx_shadow where position_transaction_id = p_position_transaction_id;
END pqh_ptx_shadow_del;
--
PROCEDURE PQH_PTX_DPF_DF_DEL(p_ptx_deployment_factor_id IN NUMBER ,p_object_version_number IN NUMBER)IS
BEGIN
delete from pqh_ptx_dpf_df where ptx_deployment_factor_id = p_ptx_deployment_factor_id;
END PQH_PTX_DPF_DF_DEL;
--
PROCEDURE pqh_ptx_dpf_df_shadow_del(p_ptx_deployment_factor_id IN NUMBER ,p_object_version_number IN NUMBER) IS
BEGIN
delete from PQH_PTX_DPF_DF where ptx_deployment_factor_id = p_ptx_deployment_factor_id;
END  pqh_ptx_dpf_df_shadow_del;
--
PROCEDURE pqh_tjr_shadow_del(p_txn_job_requirement_id IN NUMBER,p_object_version_number IN NUMBER) IS
BEGIN
delete from pqh_tjr_shadow where txn_job_requirement_id = p_txn_job_requirement_id;
END pqh_tjr_shadow_del;
--
PROCEDURE pqh_pte_shadow_del (p_ptx_extra_info_id IN NUMBER,p_object_version_number IN NUMBER) IS
BEGIN
delete from pqh_pte_shadow where ptx_extra_info_id = p_ptx_extra_info_id;
END pqh_pte_shadow_del;

--
END PQH_PURGE_DELETE_APIS;

/
