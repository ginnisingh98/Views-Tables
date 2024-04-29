--------------------------------------------------------
--  DDL for Package BEN_VALD_RLSHP_FOR_REIMB_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VALD_RLSHP_FOR_REIMB_BK3" AUTHID CURRENT_USER as
/* $Header: bevrpapi.pkh 120.0 2005/05/28 12:12:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Vald_Rlshp_For_Reimb_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Vald_Rlshp_For_Reimb_b
  (
   p_vald_rlshp_for_reimb_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Vald_Rlshp_For_Reimb_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Vald_Rlshp_For_Reimb_a
  (
   p_vald_rlshp_for_reimb_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Vald_Rlshp_For_Reimb_bk3;

 

/
