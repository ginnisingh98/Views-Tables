--------------------------------------------------------
--  DDL for Package BEN_CWB_STOCK_OPTN_DTLS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_STOCK_OPTN_DTLS_BK2" AUTHID CURRENT_USER as
/* $Header: becsoapi.pkh 120.4 2006/10/17 10:30:58 steotia noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cwb_stock_optn_dtls_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwb_stock_optn_dtls_b
  (p_effective_date                in     date
  ,p_grant_id                      in     number
  ,p_grant_number                  in     varchar2
  ,p_grant_name                    in     varchar2
  ,p_grant_type			   in     varchar2
  ,p_grant_date                    in     date
  ,p_grant_shares                  in     number
  ,p_grant_price                   in     number
  ,p_value_at_grant                in     number
  ,p_current_share_price	   in     number
  ,p_current_shares_outstanding    in     number
  ,p_vested_shares                 in     number
  ,p_unvested_shares		   in     number
  ,p_exercisable_shares            in     number
  ,p_exercised_shares              in     number
  ,p_cancelled_shares              in     number
  ,p_trading_symbol                in     varchar2
  ,p_expiration_date 		   in     date
  ,p_reason_code 		   in     varchar2
  ,p_class			   in     varchar2
  ,p_misc			   in     varchar2
  ,p_employee_number               in     varchar2
  ,p_person_id			   in     number
  ,p_business_group_id             in     number
  ,p_prtt_rt_val_id                in     number
  ,p_cso_attribute_category        in     varchar2
  ,p_cso_attribute1                in     varchar2
  ,p_cso_attribute2                in     varchar2
  ,p_cso_attribute3                in     varchar2
  ,p_cso_attribute4                in     varchar2
  ,p_cso_attribute5                in     varchar2
  ,p_cso_attribute6                in     varchar2
  ,p_cso_attribute7                in     varchar2
  ,p_cso_attribute8                in     varchar2
  ,p_cso_attribute9                in     varchar2
  ,p_cso_attribute10               in     varchar2
  ,p_cso_attribute11               in     varchar2
  ,p_cso_attribute12               in     varchar2
  ,p_cso_attribute13               in     varchar2
  ,p_cso_attribute14               in     varchar2
  ,p_cso_attribute15               in     varchar2
  ,p_cso_attribute16               in     varchar2
  ,p_cso_attribute17               in     varchar2
  ,p_cso_attribute18               in     varchar2
  ,p_cso_attribute19               in     varchar2
  ,p_cso_attribute20               in     varchar2
  ,p_cso_attribute21               in     varchar2
  ,p_cso_attribute22               in     varchar2
  ,p_cso_attribute23               in     varchar2
  ,p_cso_attribute24               in     varchar2
  ,p_cso_attribute25               in     varchar2
  ,p_cso_attribute26               in     varchar2
  ,p_cso_attribute27               in     varchar2
  ,p_cso_attribute28               in     varchar2
  ,p_cso_attribute29               in     varchar2
  ,p_cso_attribute30               in     varchar2
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cwb_stock_optn_dtls_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwb_stock_optn_dtls_a
  (p_effective_date                in     date
  ,p_grant_id                      in     number
  ,p_grant_number                  in     varchar2
  ,p_grant_name                    in     varchar2
  ,p_grant_type			   in     varchar2
  ,p_grant_date                    in     date
  ,p_grant_shares                  in     number
  ,p_grant_price                   in     number
  ,p_value_at_grant                in     number
  ,p_current_share_price	   in     number
  ,p_current_shares_outstanding    in     number
  ,p_vested_shares                 in     number
  ,p_unvested_shares		   in     number
  ,p_exercisable_shares            in     number
  ,p_exercised_shares              in     number
  ,p_cancelled_shares              in     number
  ,p_trading_symbol                in     varchar2
  ,p_expiration_date 		   in     date
  ,p_reason_code 		   in     varchar2
  ,p_class			   in     varchar2
  ,p_misc			   in     varchar2
  ,p_employee_number               in     varchar2
  ,p_person_id			   in     number
  ,p_business_group_id             in     number
  ,p_prtt_rt_val_id                in     number
  ,p_cso_attribute_category        in     varchar2
  ,p_cso_attribute1                in     varchar2
  ,p_cso_attribute2                in     varchar2
  ,p_cso_attribute3                in     varchar2
  ,p_cso_attribute4                in     varchar2
  ,p_cso_attribute5                in     varchar2
  ,p_cso_attribute6                in     varchar2
  ,p_cso_attribute7                in     varchar2
  ,p_cso_attribute8                in     varchar2
  ,p_cso_attribute9                in     varchar2
  ,p_cso_attribute10               in     varchar2
  ,p_cso_attribute11               in     varchar2
  ,p_cso_attribute12               in     varchar2
  ,p_cso_attribute13               in     varchar2
  ,p_cso_attribute14               in     varchar2
  ,p_cso_attribute15               in     varchar2
  ,p_cso_attribute16               in     varchar2
  ,p_cso_attribute17               in     varchar2
  ,p_cso_attribute18               in     varchar2
  ,p_cso_attribute19               in     varchar2
  ,p_cso_attribute20               in     varchar2
  ,p_cso_attribute21               in     varchar2
  ,p_cso_attribute22               in     varchar2
  ,p_cso_attribute23               in     varchar2
  ,p_cso_attribute24               in     varchar2
  ,p_cso_attribute25               in     varchar2
  ,p_cso_attribute26               in     varchar2
  ,p_cso_attribute27               in     varchar2
  ,p_cso_attribute28               in     varchar2
  ,p_cso_attribute29               in     varchar2
  ,p_cso_attribute30               in     varchar2
  ,p_cwb_stock_optn_dtls_id        in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_STOCK_OPTN_DTLS_BK2;

 

/
