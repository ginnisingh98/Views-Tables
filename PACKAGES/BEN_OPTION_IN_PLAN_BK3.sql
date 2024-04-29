--------------------------------------------------------
--  DDL for Package BEN_OPTION_IN_PLAN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTION_IN_PLAN_BK3" AUTHID CURRENT_USER as
/* $Header: becopapi.pkh 120.0 2005/05/28 01:09:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Option_in_Plan_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Option_in_Plan_b
  (p_oipl_id                     in number
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Option_in_Plan_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Option_in_Plan_a
  (p_oipl_id                     in number
  ,p_effective_start_date        in date
  ,p_effective_end_date          in date
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
end ben_Option_in_Plan_bk3;

 

/
