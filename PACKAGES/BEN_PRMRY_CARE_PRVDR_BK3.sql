--------------------------------------------------------
--  DDL for Package BEN_PRMRY_CARE_PRVDR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRMRY_CARE_PRVDR_BK3" AUTHID CURRENT_USER as
/* $Header: bepprapi.pkh 120.1.12000000.1 2007/01/19 21:49:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRMRY_CARE_PRVDR_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRMRY_CARE_PRVDR_b
  (
   p_prmry_care_prvdr_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRMRY_CARE_PRVDR_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRMRY_CARE_PRVDR_a
  (
   p_prmry_care_prvdr_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PRMRY_CARE_PRVDR_bk3;

 

/
