--------------------------------------------------------
--  DDL for Package BEN_ELTBL_CHC_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELTBL_CHC_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: beeccapi.pkh 120.0 2005/05/28 01:48:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELTBL_CHC_CTFN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELTBL_CHC_CTFN_b
  (
   p_elctbl_chc_ctfn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELTBL_CHC_CTFN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELTBL_CHC_CTFN_a
  (
   p_elctbl_chc_ctfn_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELTBL_CHC_CTFN_bk3;

 

/
