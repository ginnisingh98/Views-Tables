--------------------------------------------------------
--  DDL for Package BEN_CWB_WKSHT_GRP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_WKSHT_GRP_BK1" AUTHID CURRENT_USER as
/* $Header: becwgapi.pkh 120.0 2005/05/28 01:29:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cwb_wksht_grp_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_wksht_grp_b
  (
   p_cwb_wksht_grp_id                in number
  ,p_business_group_id               in number
  ,p_pl_id                           in number
  ,p_ordr_num                        in number
  ,p_wksht_grp_cd                    in varchar2
  ,p_label                           in varchar2
  ,p_cwg_attribute_category         in varchar2
  ,p_cwg_attribute1                 in varchar2
  ,p_cwg_attribute2                 in varchar2
  ,p_cwg_attribute3                 in varchar2
  ,p_cwg_attribute4                 in varchar2
  ,p_cwg_attribute5                 in varchar2
  ,p_cwg_attribute6                 in varchar2
  ,p_cwg_attribute7                 in varchar2
  ,p_cwg_attribute8                 in varchar2
  ,p_cwg_attribute9                 in varchar2
  ,p_cwg_attribute10                in varchar2
  ,p_cwg_attribute11                in varchar2
  ,p_cwg_attribute12                in varchar2
  ,p_cwg_attribute13                in varchar2
  ,p_cwg_attribute14                in varchar2
  ,p_cwg_attribute15                in varchar2
  ,p_cwg_attribute16                in varchar2
  ,p_cwg_attribute17                in varchar2
  ,p_cwg_attribute18                in varchar2
  ,p_cwg_attribute19                in varchar2
  ,p_cwg_attribute20                in varchar2
  ,p_cwg_attribute21                in varchar2
  ,p_cwg_attribute22                in varchar2
  ,p_cwg_attribute23                in varchar2
  ,p_cwg_attribute24                in varchar2
  ,p_cwg_attribute25                in varchar2
  ,p_cwg_attribute26                in varchar2
  ,p_cwg_attribute27                in varchar2
  ,p_cwg_attribute28                in varchar2
  ,p_cwg_attribute29                in varchar2
  ,p_cwg_attribute30                in varchar2
  ,p_status_cd                      in varchar2
  ,p_hidden_cd                     in varchar2
  ,p_object_version_number           in number
  ,p_effective_date                  in date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cwb_wksht_grp_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_wksht_grp_a
  (
   p_cwb_wksht_grp_id                in number
  ,p_business_group_id               in number
  ,p_pl_id                           in number
  ,p_ordr_num                        in number
  ,p_wksht_grp_cd                    in varchar2
  ,p_label                           in varchar2
  ,p_cwg_attribute_category         in varchar2
  ,p_cwg_attribute1                 in varchar2
  ,p_cwg_attribute2                 in varchar2
  ,p_cwg_attribute3                 in varchar2
  ,p_cwg_attribute4                 in varchar2
  ,p_cwg_attribute5                 in varchar2
  ,p_cwg_attribute6                 in varchar2
  ,p_cwg_attribute7                 in varchar2
  ,p_cwg_attribute8                 in varchar2
  ,p_cwg_attribute9                 in varchar2
  ,p_cwg_attribute10                in varchar2
  ,p_cwg_attribute11                in varchar2
  ,p_cwg_attribute12                in varchar2
  ,p_cwg_attribute13                in varchar2
  ,p_cwg_attribute14                in varchar2
  ,p_cwg_attribute15                in varchar2
  ,p_cwg_attribute16                in varchar2
  ,p_cwg_attribute17                in varchar2
  ,p_cwg_attribute18                in varchar2
  ,p_cwg_attribute19                in varchar2
  ,p_cwg_attribute20                in varchar2
  ,p_cwg_attribute21                in varchar2
  ,p_cwg_attribute22                in varchar2
  ,p_cwg_attribute23                in varchar2
  ,p_cwg_attribute24                in varchar2
  ,p_cwg_attribute25                in varchar2
  ,p_cwg_attribute26                in varchar2
  ,p_cwg_attribute27                in varchar2
  ,p_cwg_attribute28                in varchar2
  ,p_cwg_attribute29                in varchar2
  ,p_cwg_attribute30                in varchar2
  ,p_status_cd                      in varchar2
  ,p_hidden_cd                     in varchar2
  ,p_object_version_number           in number
  ,p_effective_date                  in date
  );
--
end ben_cwb_wksht_grp_bk1;

 

/
