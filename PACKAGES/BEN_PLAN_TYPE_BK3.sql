--------------------------------------------------------
--  DDL for Package BEN_PLAN_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_TYPE_BK3" AUTHID CURRENT_USER as
/* $Header: beptpapi.pkh 120.0 2005/05/28 11:22:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PLAN_TYPE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PLAN_TYPE_b
  (
   p_pl_typ_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PLAN_TYPE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PLAN_TYPE_a
  (
   p_pl_typ_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PLAN_TYPE_bk3;

 

/
