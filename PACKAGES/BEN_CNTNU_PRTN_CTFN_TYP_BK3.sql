--------------------------------------------------------
--  DDL for Package BEN_CNTNU_PRTN_CTFN_TYP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CNTNU_PRTN_CTFN_TYP_BK3" AUTHID CURRENT_USER as
/* $Header: becpcapi.pkh 120.0 2005/05/28 01:10:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CNTNU_PRTN_CTFN_TYP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CNTNU_PRTN_CTFN_TYP_b
  (
   p_cntnu_prtn_ctfn_typ_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CNTNU_PRTN_CTFN_TYP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CNTNU_PRTN_CTFN_TYP_a
  (
   p_cntnu_prtn_ctfn_typ_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_CNTNU_PRTN_CTFN_TYP_bk3;

 

/
