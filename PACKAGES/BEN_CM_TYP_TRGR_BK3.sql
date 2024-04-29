--------------------------------------------------------
--  DDL for Package BEN_CM_TYP_TRGR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CM_TYP_TRGR_BK3" AUTHID CURRENT_USER as
/* $Header: becttapi.pkh 120.0 2005/05/28 01:27:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cm_typ_trgr_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cm_typ_trgr_b
  (p_cm_typ_trgr_id              in number
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cm_typ_trgr_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cm_typ_trgr_a
  (p_cm_typ_trgr_id              in number
  ,p_effective_start_date        in date
  ,p_effective_end_date          in date
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
end ben_cm_typ_trgr_bk3;

 

/
