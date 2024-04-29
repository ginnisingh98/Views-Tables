--------------------------------------------------------
--  DDL for Package BEN_CSO_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CSO_RKU" AUTHID CURRENT_USER as
/* $Header: becsorhi.pkh 120.0.12010000.1 2008/07/29 11:15:47 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_cwb_stock_optn_dtls_id       in number
  ,p_grant_id                     in number
  ,p_grant_number                 in varchar2
  ,p_grant_name                   in varchar2
  ,p_grant_type                   in varchar2
  ,p_grant_date                   in date
  ,p_grant_shares                 in number
  ,p_grant_price                  in number
  ,p_value_at_grant               in number
  ,p_current_share_price          in number
  ,p_current_shares_outstanding   in number
  ,p_vested_shares                in number
  ,p_unvested_shares              in number
  ,p_exercisable_shares           in number
  ,p_exercised_shares             in number
  ,p_cancelled_shares             in number
  ,p_trading_symbol               in varchar2
  ,p_expiration_date              in date
  ,p_reason_code                  in varchar2
  ,p_class                        in varchar2
  ,p_misc                         in varchar2
  ,p_employee_number              in varchar2
  ,p_person_id                    in number
  ,p_business_group_id            in number
  ,p_prtt_rt_val_id               in number
  ,p_object_version_number        in number
  ,p_cso_attribute_category       in varchar2
  ,p_cso_attribute1               in varchar2
  ,p_cso_attribute2               in varchar2
  ,p_cso_attribute3               in varchar2
  ,p_cso_attribute4               in varchar2
  ,p_cso_attribute5               in varchar2
  ,p_cso_attribute6               in varchar2
  ,p_cso_attribute7               in varchar2
  ,p_cso_attribute8               in varchar2
  ,p_cso_attribute9               in varchar2
  ,p_cso_attribute10              in varchar2
  ,p_cso_attribute11              in varchar2
  ,p_cso_attribute12              in varchar2
  ,p_cso_attribute13              in varchar2
  ,p_cso_attribute14              in varchar2
  ,p_cso_attribute15              in varchar2
  ,p_cso_attribute16              in varchar2
  ,p_cso_attribute17              in varchar2
  ,p_cso_attribute18              in varchar2
  ,p_cso_attribute19              in varchar2
  ,p_cso_attribute20              in varchar2
  ,p_cso_attribute21              in varchar2
  ,p_cso_attribute22              in varchar2
  ,p_cso_attribute23              in varchar2
  ,p_cso_attribute24              in varchar2
  ,p_cso_attribute25              in varchar2
  ,p_cso_attribute26              in varchar2
  ,p_cso_attribute27              in varchar2
  ,p_cso_attribute28              in varchar2
  ,p_cso_attribute29              in varchar2
  ,p_cso_attribute30              in varchar2
  ,p_grant_id_o                   in number
  ,p_grant_number_o               in varchar2
  ,p_grant_name_o                 in varchar2
  ,p_grant_type_o                 in varchar2
  ,p_grant_date_o                 in date
  ,p_grant_shares_o               in number
  ,p_grant_price_o                in number
  ,p_value_at_grant_o             in number
  ,p_current_share_price_o        in number
  ,p_current_shares_outstanding_o in number
  ,p_vested_shares_o              in number
  ,p_unvested_shares_o            in number
  ,p_exercisable_shares_o         in number
  ,p_exercised_shares_o           in number
  ,p_cancelled_shares_o           in number
  ,p_trading_symbol_o             in varchar2
  ,p_expiration_date_o            in date
  ,p_reason_code_o                in varchar2
  ,p_class_o                      in varchar2
  ,p_misc_o                       in varchar2
  ,p_employee_number_o            in varchar2
  ,p_person_id_o                  in number
  ,p_business_group_id_o          in number
  ,p_prtt_rt_val_id_o             in number
  ,p_object_version_number_o      in number
  ,p_cso_attribute_category_o     in varchar2
  ,p_cso_attribute1_o             in varchar2
  ,p_cso_attribute2_o             in varchar2
  ,p_cso_attribute3_o             in varchar2
  ,p_cso_attribute4_o             in varchar2
  ,p_cso_attribute5_o             in varchar2
  ,p_cso_attribute6_o             in varchar2
  ,p_cso_attribute7_o             in varchar2
  ,p_cso_attribute8_o             in varchar2
  ,p_cso_attribute9_o             in varchar2
  ,p_cso_attribute10_o            in varchar2
  ,p_cso_attribute11_o            in varchar2
  ,p_cso_attribute12_o            in varchar2
  ,p_cso_attribute13_o            in varchar2
  ,p_cso_attribute14_o            in varchar2
  ,p_cso_attribute15_o            in varchar2
  ,p_cso_attribute16_o            in varchar2
  ,p_cso_attribute17_o            in varchar2
  ,p_cso_attribute18_o            in varchar2
  ,p_cso_attribute19_o            in varchar2
  ,p_cso_attribute20_o            in varchar2
  ,p_cso_attribute21_o            in varchar2
  ,p_cso_attribute22_o            in varchar2
  ,p_cso_attribute23_o            in varchar2
  ,p_cso_attribute24_o            in varchar2
  ,p_cso_attribute25_o            in varchar2
  ,p_cso_attribute26_o            in varchar2
  ,p_cso_attribute27_o            in varchar2
  ,p_cso_attribute28_o            in varchar2
  ,p_cso_attribute29_o            in varchar2
  ,p_cso_attribute30_o            in varchar2
  );
--
end ben_cso_rku;

/
