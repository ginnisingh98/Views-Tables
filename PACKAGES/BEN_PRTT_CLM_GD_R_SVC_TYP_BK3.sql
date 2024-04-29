--------------------------------------------------------
--  DDL for Package BEN_PRTT_CLM_GD_R_SVC_TYP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_CLM_GD_R_SVC_TYP_BK3" AUTHID CURRENT_USER as
/* $Header: bepcgapi.pkh 120.0 2005/05/28 10:10:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_CLM_GD_R_SVC_TYP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_CLM_GD_R_SVC_TYP_b
  (
   p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTT_CLM_GD_R_SVC_TYP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_CLM_GD_R_SVC_TYP_a
  (
   p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_object_version_number          in  number
  );
--
end ben_PRTT_CLM_GD_R_SVC_TYP_bk3;

 

/
