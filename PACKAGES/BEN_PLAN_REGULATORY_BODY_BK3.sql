--------------------------------------------------------
--  DDL for Package BEN_PLAN_REGULATORY_BODY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_REGULATORY_BODY_BK3" AUTHID CURRENT_USER as
/* $Header: beprbapi.pkh 120.0 2005/05/28 11:03:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_Regulatory_body_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Regulatory_body_b
  (
   p_pl_regy_bod_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_Regulatory_body_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_Regulatory_body_a
  (
   p_pl_regy_bod_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Plan_Regulatory_body_bk3;

 

/
