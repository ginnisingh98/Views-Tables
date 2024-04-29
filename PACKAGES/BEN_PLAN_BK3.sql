--------------------------------------------------------
--  DDL for Package BEN_PLAN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_BK3" AUTHID CURRENT_USER as
/* $Header: beplnapi.pkh 120.0 2005/05/28 10:53:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_b
  (
   p_pl_id                          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_a
  (
   p_pl_id                          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Plan_bk3;

 

/
