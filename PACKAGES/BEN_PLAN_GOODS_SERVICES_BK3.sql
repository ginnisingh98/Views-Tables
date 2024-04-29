--------------------------------------------------------
--  DDL for Package BEN_PLAN_GOODS_SERVICES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_GOODS_SERVICES_BK3" AUTHID CURRENT_USER as
/* $Header: bevgsapi.pkh 120.0 2005/05/28 12:04:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_goods_services_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_goods_services_b
  (
   p_pl_gd_or_svc_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Plan_goods_services_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_goods_services_a
  (
   p_pl_gd_or_svc_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Plan_goods_services_bk3;

 

/
