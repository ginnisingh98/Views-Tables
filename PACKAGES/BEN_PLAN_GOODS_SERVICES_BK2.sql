--------------------------------------------------------
--  DDL for Package BEN_PLAN_GOODS_SERVICES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_GOODS_SERVICES_BK2" AUTHID CURRENT_USER as
/* $Header: bevgsapi.pkh 120.0 2005/05/28 12:04:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_goods_services_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_goods_services_b
  (
   p_pl_gd_or_svc_id                in  number
  ,p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_gd_or_svc_typ_id               in  number
  ,p_alw_rcrrg_clms_flag            in  varchar2
  ,p_gd_or_svc_usg_cd               in  varchar2
  ,p_vgs_attribute_category         in  varchar2
  ,p_vgs_attribute1                 in  varchar2
  ,p_vgs_attribute2                 in  varchar2
  ,p_vgs_attribute3                 in  varchar2
  ,p_vgs_attribute4                 in  varchar2
  ,p_vgs_attribute5                 in  varchar2
  ,p_vgs_attribute6                 in  varchar2
  ,p_vgs_attribute7                 in  varchar2
  ,p_vgs_attribute8                 in  varchar2
  ,p_vgs_attribute9                 in  varchar2
  ,p_vgs_attribute10                in  varchar2
  ,p_vgs_attribute11                in  varchar2
  ,p_vgs_attribute12                in  varchar2
  ,p_vgs_attribute13                in  varchar2
  ,p_vgs_attribute14                in  varchar2
  ,p_vgs_attribute15                in  varchar2
  ,p_vgs_attribute16                in  varchar2
  ,p_vgs_attribute17                in  varchar2
  ,p_vgs_attribute18                in  varchar2
  ,p_vgs_attribute19                in  varchar2
  ,p_vgs_attribute20                in  varchar2
  ,p_vgs_attribute21                in  varchar2
  ,p_vgs_attribute22                in  varchar2
  ,p_vgs_attribute23                in  varchar2
  ,p_vgs_attribute24                in  varchar2
  ,p_vgs_attribute25                in  varchar2
  ,p_vgs_attribute26                in  varchar2
  ,p_vgs_attribute27                in  varchar2
  ,p_vgs_attribute28                in  varchar2
  ,p_vgs_attribute29                in  varchar2
  ,p_vgs_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_gd_svc_recd_basis_cd           in varchar2
  ,p_gd_svc_recd_basis_dt           in date
  ,p_gd_svc_recd_basis_mo           in number

  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_goods_services_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_goods_services_a
  (
   p_pl_gd_or_svc_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_gd_or_svc_typ_id               in  number
  ,p_alw_rcrrg_clms_flag            in  varchar2
  ,p_gd_or_svc_usg_cd               in  varchar2
  ,p_vgs_attribute_category         in  varchar2
  ,p_vgs_attribute1                 in  varchar2
  ,p_vgs_attribute2                 in  varchar2
  ,p_vgs_attribute3                 in  varchar2
  ,p_vgs_attribute4                 in  varchar2
  ,p_vgs_attribute5                 in  varchar2
  ,p_vgs_attribute6                 in  varchar2
  ,p_vgs_attribute7                 in  varchar2
  ,p_vgs_attribute8                 in  varchar2
  ,p_vgs_attribute9                 in  varchar2
  ,p_vgs_attribute10                in  varchar2
  ,p_vgs_attribute11                in  varchar2
  ,p_vgs_attribute12                in  varchar2
  ,p_vgs_attribute13                in  varchar2
  ,p_vgs_attribute14                in  varchar2
  ,p_vgs_attribute15                in  varchar2
  ,p_vgs_attribute16                in  varchar2
  ,p_vgs_attribute17                in  varchar2
  ,p_vgs_attribute18                in  varchar2
  ,p_vgs_attribute19                in  varchar2
  ,p_vgs_attribute20                in  varchar2
  ,p_vgs_attribute21                in  varchar2
  ,p_vgs_attribute22                in  varchar2
  ,p_vgs_attribute23                in  varchar2
  ,p_vgs_attribute24                in  varchar2
  ,p_vgs_attribute25                in  varchar2
  ,p_vgs_attribute26                in  varchar2
  ,p_vgs_attribute27                in  varchar2
  ,p_vgs_attribute28                in  varchar2
  ,p_vgs_attribute29                in  varchar2
  ,p_vgs_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_gd_svc_recd_basis_cd           in varchar2
  ,p_gd_svc_recd_basis_dt           in date
  ,p_gd_svc_recd_basis_mo           in number
  );
--
end ben_Plan_goods_services_bk2;

 

/
