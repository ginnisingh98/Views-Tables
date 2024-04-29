--------------------------------------------------------
--  DDL for Package BEN_PIL_ELCTBL_CHC_POPL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ELCTBL_CHC_POPL_BK3" AUTHID CURRENT_USER as
/* $Header: bepelapi.pkh 120.1 2007/05/13 23:05:21 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Pil_Elctbl_chc_Popl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Pil_Elctbl_chc_Popl_b
  (
   p_pil_elctbl_chc_popl_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Pil_Elctbl_chc_Popl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Pil_Elctbl_chc_Popl_a
  (
   p_pil_elctbl_chc_popl_id         in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Pil_Elctbl_chc_Popl_bk3;

/
