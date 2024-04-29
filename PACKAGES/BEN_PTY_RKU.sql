--------------------------------------------------------
--  DDL for Package BEN_PTY_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTY_RKU" AUTHID CURRENT_USER as
/* $Header: beptyrhi.pkh 120.0 2005/05/28 11:25:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_pl_pcp_typ_id                in number
  ,p_pl_pcp_id                    in number
  ,p_business_group_id            in number
  ,p_pcp_typ_cd                   in varchar2
  ,p_min_age                      in number
  ,p_max_age                      in number
  ,p_gndr_alwd_cd                 in varchar2
  ,p_pty_attribute_category       in varchar2
  ,p_pty_attribute1               in varchar2
  ,p_pty_attribute2               in varchar2
  ,p_pty_attribute3               in varchar2
  ,p_pty_attribute4               in varchar2
  ,p_pty_attribute5               in varchar2
  ,p_pty_attribute6               in varchar2
  ,p_pty_attribute7               in varchar2
  ,p_pty_attribute8               in varchar2
  ,p_pty_attribute9               in varchar2
  ,p_pty_attribute10              in varchar2
  ,p_pty_attribute11              in varchar2
  ,p_pty_attribute12              in varchar2
  ,p_pty_attribute13              in varchar2
  ,p_pty_attribute14              in varchar2
  ,p_pty_attribute15              in varchar2
  ,p_pty_attribute16              in varchar2
  ,p_pty_attribute17              in varchar2
  ,p_pty_attribute18              in varchar2
  ,p_pty_attribute19              in varchar2
  ,p_pty_attribute20              in varchar2
  ,p_pty_attribute21              in varchar2
  ,p_pty_attribute22              in varchar2
  ,p_pty_attribute23              in varchar2
  ,p_pty_attribute24              in varchar2
  ,p_pty_attribute25              in varchar2
  ,p_pty_attribute26              in varchar2
  ,p_pty_attribute27              in varchar2
  ,p_pty_attribute28              in varchar2
  ,p_pty_attribute29              in varchar2
  ,p_pty_attribute30              in varchar2
  ,p_object_version_number        in number
  ,p_pl_pcp_id_o                  in number
  ,p_business_group_id_o          in number
  ,p_pcp_typ_cd_o                 in varchar2
  ,p_min_age_o                    in number
  ,p_max_age_o                    in number
  ,p_gndr_alwd_cd_o               in varchar2
  ,p_pty_attribute_category_o     in varchar2
  ,p_pty_attribute1_o             in varchar2
  ,p_pty_attribute2_o             in varchar2
  ,p_pty_attribute3_o             in varchar2
  ,p_pty_attribute4_o             in varchar2
  ,p_pty_attribute5_o             in varchar2
  ,p_pty_attribute6_o             in varchar2
  ,p_pty_attribute7_o             in varchar2
  ,p_pty_attribute8_o             in varchar2
  ,p_pty_attribute9_o             in varchar2
  ,p_pty_attribute10_o            in varchar2
  ,p_pty_attribute11_o            in varchar2
  ,p_pty_attribute12_o            in varchar2
  ,p_pty_attribute13_o            in varchar2
  ,p_pty_attribute14_o            in varchar2
  ,p_pty_attribute15_o            in varchar2
  ,p_pty_attribute16_o            in varchar2
  ,p_pty_attribute17_o            in varchar2
  ,p_pty_attribute18_o            in varchar2
  ,p_pty_attribute19_o            in varchar2
  ,p_pty_attribute20_o            in varchar2
  ,p_pty_attribute21_o            in varchar2
  ,p_pty_attribute22_o            in varchar2
  ,p_pty_attribute23_o            in varchar2
  ,p_pty_attribute24_o            in varchar2
  ,p_pty_attribute25_o            in varchar2
  ,p_pty_attribute26_o            in varchar2
  ,p_pty_attribute27_o            in varchar2
  ,p_pty_attribute28_o            in varchar2
  ,p_pty_attribute29_o            in varchar2
  ,p_pty_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_pty_rku;

 

/
