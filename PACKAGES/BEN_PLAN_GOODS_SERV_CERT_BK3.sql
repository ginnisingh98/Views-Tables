--------------------------------------------------------
--  DDL for Package BEN_PLAN_GOODS_SERV_CERT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_GOODS_SERV_CERT_BK3" AUTHID CURRENT_USER as
/* $Header: bepctapi.pkh 120.0 2005/05/28 10:17:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_plan_goods_serv_cert_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_goods_serv_cert_b
  (
   p_pl_gd_r_svc_ctfn_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_plan_goods_serv_cert_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_goods_serv_cert_a
  (
   p_pl_gd_r_svc_ctfn_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_plan_goods_serv_cert_bk3;

 

/
