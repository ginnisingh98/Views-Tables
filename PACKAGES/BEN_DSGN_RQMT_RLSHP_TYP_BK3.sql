--------------------------------------------------------
--  DDL for Package BEN_DSGN_RQMT_RLSHP_TYP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DSGN_RQMT_RLSHP_TYP_BK3" AUTHID CURRENT_USER as
/* $Header: bedrrapi.pkh 120.0 2005/05/28 01:40:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DSGN_RQMT_RLSHP_TYP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSGN_RQMT_RLSHP_TYP_b
  (
   p_dsgn_rqmt_rlshp_typ_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DSGN_RQMT_RLSHP_TYP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSGN_RQMT_RLSHP_TYP_a
  (
   p_dsgn_rqmt_rlshp_typ_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_DSGN_RQMT_RLSHP_TYP_bk3;

 

/
