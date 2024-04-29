--------------------------------------------------------
--  DDL for Package BEN_PLAN_TYPE_OPTION_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_TYPE_OPTION_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: beponapi.pkh 120.0 2005/05/28 10:56:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_plan_type_option_type_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_type_option_type_b
  (
   p_pl_typ_opt_typ_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_plan_type_option_type_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_type_option_type_a
  (
   p_pl_typ_opt_typ_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_plan_type_option_type_bk3;

 

/
