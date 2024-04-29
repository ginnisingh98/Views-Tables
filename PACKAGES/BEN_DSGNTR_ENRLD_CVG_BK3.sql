--------------------------------------------------------
--  DDL for Package BEN_DSGNTR_ENRLD_CVG_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DSGNTR_ENRLD_CVG_BK3" AUTHID CURRENT_USER as
/* $Header: bedecapi.pkh 120.0 2005/05/28 01:36:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DSGNTR_ENRLD_CVG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSGNTR_ENRLD_CVG_b
  (
   p_dsgntr_enrld_cvg_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_DSGNTR_ENRLD_CVG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSGNTR_ENRLD_CVG_a
  (
   p_dsgntr_enrld_cvg_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_DSGNTR_ENRLD_CVG_bk3;

 

/
