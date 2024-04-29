--------------------------------------------------------
--  DDL for Package BEN_PLAN_IN_PROGRAM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_IN_PROGRAM_BK3" AUTHID CURRENT_USER as
/* $Header: becppapi.pkh 120.0 2005/05/28 01:16:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_in_Program_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_in_Program_b
  (
   p_plip_id                        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_in_Program_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_in_Program_a
  (
   p_plip_id                        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Plan_in_Program_bk3;

 

/
