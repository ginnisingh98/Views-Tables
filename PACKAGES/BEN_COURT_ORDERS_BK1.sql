--------------------------------------------------------
--  DDL for Package BEN_COURT_ORDERS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COURT_ORDERS_BK1" AUTHID CURRENT_USER as
/* $Header: becrtapi.pkh 120.0 2005/05/28 01:22:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_court_orders_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_court_orders_b
  (
   p_crt_ordr_typ_cd                in  varchar2
  ,p_apls_perd_endg_dt              in  date
  ,p_apls_perd_strtg_dt             in  date
  ,p_crt_ident                      in  varchar2
  ,p_description                    in  varchar2
  ,p_detd_qlfd_ordr_dt              in  date
  ,p_issue_dt                       in  date
  ,p_qdro_amt                       in  number
  ,p_qdro_dstr_mthd_cd              in  varchar2
  ,p_qdro_pct                       in  number
  ,p_rcvd_dt                        in  date
  ,p_uom                            in  varchar2
  ,p_crt_issng                      in  varchar2
  ,p_pl_id                          in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_crt_attribute_category         in  varchar2
  ,p_crt_attribute1                 in  varchar2
  ,p_crt_attribute2                 in  varchar2
  ,p_crt_attribute3                 in  varchar2
  ,p_crt_attribute4                 in  varchar2
  ,p_crt_attribute5                 in  varchar2
  ,p_crt_attribute6                 in  varchar2
  ,p_crt_attribute7                 in  varchar2
  ,p_crt_attribute8                 in  varchar2
  ,p_crt_attribute9                 in  varchar2
  ,p_crt_attribute10                in  varchar2
  ,p_crt_attribute11                in  varchar2
  ,p_crt_attribute12                in  varchar2
  ,p_crt_attribute13                in  varchar2
  ,p_crt_attribute14                in  varchar2
  ,p_crt_attribute15                in  varchar2
  ,p_crt_attribute16                in  varchar2
  ,p_crt_attribute17                in  varchar2
  ,p_crt_attribute18                in  varchar2
  ,p_crt_attribute19                in  varchar2
  ,p_crt_attribute20                in  varchar2
  ,p_crt_attribute21                in  varchar2
  ,p_crt_attribute22                in  varchar2
  ,p_crt_attribute23                in  varchar2
  ,p_crt_attribute24                in  varchar2
  ,p_crt_attribute25                in  varchar2
  ,p_crt_attribute26                in  varchar2
  ,p_crt_attribute27                in  varchar2
  ,p_crt_attribute28                in  varchar2
  ,p_crt_attribute29                in  varchar2
  ,p_crt_attribute30                in  varchar2
  ,p_qdro_num_pymt_val              in  number
  ,p_qdro_per_perd_cd               in  varchar2
  ,p_pl_typ_id                      in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_court_orders_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_court_orders_a
  (
   p_crt_ordr_id                    in  number
  ,p_crt_ordr_typ_cd                in  varchar2
  ,p_apls_perd_endg_dt              in  date
  ,p_apls_perd_strtg_dt             in  date
  ,p_crt_ident                      in  varchar2
  ,p_description                    in  varchar2
  ,p_detd_qlfd_ordr_dt              in  date
  ,p_issue_dt                       in  date
  ,p_qdro_amt                       in  number
  ,p_qdro_dstr_mthd_cd              in  varchar2
  ,p_qdro_pct                       in  number
  ,p_rcvd_dt                        in  date
  ,p_uom                            in  varchar2
  ,p_crt_issng                      in  varchar2
  ,p_pl_id                          in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_crt_attribute_category         in  varchar2
  ,p_crt_attribute1                 in  varchar2
  ,p_crt_attribute2                 in  varchar2
  ,p_crt_attribute3                 in  varchar2
  ,p_crt_attribute4                 in  varchar2
  ,p_crt_attribute5                 in  varchar2
  ,p_crt_attribute6                 in  varchar2
  ,p_crt_attribute7                 in  varchar2
  ,p_crt_attribute8                 in  varchar2
  ,p_crt_attribute9                 in  varchar2
  ,p_crt_attribute10                in  varchar2
  ,p_crt_attribute11                in  varchar2
  ,p_crt_attribute12                in  varchar2
  ,p_crt_attribute13                in  varchar2
  ,p_crt_attribute14                in  varchar2
  ,p_crt_attribute15                in  varchar2
  ,p_crt_attribute16                in  varchar2
  ,p_crt_attribute17                in  varchar2
  ,p_crt_attribute18                in  varchar2
  ,p_crt_attribute19                in  varchar2
  ,p_crt_attribute20                in  varchar2
  ,p_crt_attribute21                in  varchar2
  ,p_crt_attribute22                in  varchar2
  ,p_crt_attribute23                in  varchar2
  ,p_crt_attribute24                in  varchar2
  ,p_crt_attribute25                in  varchar2
  ,p_crt_attribute26                in  varchar2
  ,p_crt_attribute27                in  varchar2
  ,p_crt_attribute28                in  varchar2
  ,p_crt_attribute29                in  varchar2
  ,p_crt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_qdro_num_pymt_val              in  number
  ,p_qdro_per_perd_cd               in  varchar2
  ,p_pl_typ_id                      in  number
  ,p_effective_date                 in  date
  );
--
end ben_court_orders_bk1;

 

/
