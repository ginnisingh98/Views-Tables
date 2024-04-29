--------------------------------------------------------
--  DDL for Package BEN_PLAN_TYPE_IN_PROGRAM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_TYPE_IN_PROGRAM_BK3" AUTHID CURRENT_USER as
/* $Header: bectpapi.pkh 120.0 2005/05/28 01:25:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_Type_In_Program_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Type_In_Program_b
  (
   p_ptip_id                        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_Type_In_Program_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Type_In_Program_a
  (
   p_ptip_id                        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Plan_Type_In_Program_bk3;

 

/
