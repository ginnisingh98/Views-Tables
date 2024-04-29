--------------------------------------------------------
--  DDL for Package BEN_OTP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OTP_RKU" AUTHID CURRENT_USER as
/* $Header: beotprhi.pkh 120.0 2005/05/28 09:58:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_optip_id                     in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_pgm_id                       in number
  ,p_ptip_id                      in number
  ,p_pl_typ_id                    in number
  ,p_opt_id                       in number
  ,p_cmbn_ptip_opt_id             in number
  ,p_legislation_code       in varchar2
  ,p_legislation_subgroup       in varchar2
  ,p_otp_attribute_category       in varchar2
  ,p_otp_attribute1               in varchar2
  ,p_otp_attribute2               in varchar2
  ,p_otp_attribute3               in varchar2
  ,p_otp_attribute4               in varchar2
  ,p_otp_attribute5               in varchar2
  ,p_otp_attribute6               in varchar2
  ,p_otp_attribute7               in varchar2
  ,p_otp_attribute8               in varchar2
  ,p_otp_attribute9               in varchar2
  ,p_otp_attribute10              in varchar2
  ,p_otp_attribute11              in varchar2
  ,p_otp_attribute12              in varchar2
  ,p_otp_attribute13              in varchar2
  ,p_otp_attribute14              in varchar2
  ,p_otp_attribute15              in varchar2
  ,p_otp_attribute16              in varchar2
  ,p_otp_attribute17              in varchar2
  ,p_otp_attribute18              in varchar2
  ,p_otp_attribute19              in varchar2
  ,p_otp_attribute20              in varchar2
  ,p_otp_attribute21              in varchar2
  ,p_otp_attribute22              in varchar2
  ,p_otp_attribute23              in varchar2
  ,p_otp_attribute24              in varchar2
  ,p_otp_attribute25              in varchar2
  ,p_otp_attribute26              in varchar2
  ,p_otp_attribute27              in varchar2
  ,p_otp_attribute28              in varchar2
  ,p_otp_attribute29              in varchar2
  ,p_otp_attribute30              in varchar2
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_pgm_id_o                     in number
  ,p_ptip_id_o                    in number
  ,p_pl_typ_id_o                  in number
  ,p_opt_id_o                     in number
  ,p_cmbn_ptip_opt_id_o           in number
  ,p_legislation_code_o     in varchar2
  ,p_legislation_subgroup_o     in varchar2
  ,p_otp_attribute_category_o     in varchar2
  ,p_otp_attribute1_o             in varchar2
  ,p_otp_attribute2_o             in varchar2
  ,p_otp_attribute3_o             in varchar2
  ,p_otp_attribute4_o             in varchar2
  ,p_otp_attribute5_o             in varchar2
  ,p_otp_attribute6_o             in varchar2
  ,p_otp_attribute7_o             in varchar2
  ,p_otp_attribute8_o             in varchar2
  ,p_otp_attribute9_o             in varchar2
  ,p_otp_attribute10_o            in varchar2
  ,p_otp_attribute11_o            in varchar2
  ,p_otp_attribute12_o            in varchar2
  ,p_otp_attribute13_o            in varchar2
  ,p_otp_attribute14_o            in varchar2
  ,p_otp_attribute15_o            in varchar2
  ,p_otp_attribute16_o            in varchar2
  ,p_otp_attribute17_o            in varchar2
  ,p_otp_attribute18_o            in varchar2
  ,p_otp_attribute19_o            in varchar2
  ,p_otp_attribute20_o            in varchar2
  ,p_otp_attribute21_o            in varchar2
  ,p_otp_attribute22_o            in varchar2
  ,p_otp_attribute23_o            in varchar2
  ,p_otp_attribute24_o            in varchar2
  ,p_otp_attribute25_o            in varchar2
  ,p_otp_attribute26_o            in varchar2
  ,p_otp_attribute27_o            in varchar2
  ,p_otp_attribute28_o            in varchar2
  ,p_otp_attribute29_o            in varchar2
  ,p_otp_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_otp_rku;

 

/
