--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_009
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_009" AUTHID CURRENT_USER AS
/* $Header: IGSAD09S.pls 115.3 2002/02/12 16:21:10 pkm ship    $ */

Function Admp_Get_Sys_Acos(
  p_s_adm_cndtnl_offer_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Ads(
  p_s_adm_doc_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Aeqs(
  p_s_adm_entry_qual_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Afs(
  p_s_adm_fee_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Aods(
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Aors(
  p_s_adm_offer_resp_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Aos(
  p_s_adm_outcome_status IN VARCHAR2 )
RETURN VARCHAR2;

Function Admp_Get_Sys_Auos(
  p_s_adm_outcome_status IN VARCHAR2 )
RETURN VARCHAR2;

END IGS_AD_GEN_009;

 

/
