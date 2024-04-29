--------------------------------------------------------
--  DDL for Package PER_BF_PAYMENT_DETAILS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PAYMENT_DETAILS_BK2" AUTHID CURRENT_USER AS
/* $Header: pebpdapi.pkh 120.1 2005/10/02 02:12:21 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_payment_detail_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_payment_detail_b
  (p_effective_date               in   date
  ,p_check_number                 in   number
  ,p_payment_date                 in   date
  ,p_amount                       in   number
  ,p_check_type                   in   varchar2
  ,p_bpd_attribute_category       in   varchar2
  ,p_bpd_attribute1               in   varchar2
  ,p_bpd_attribute2               in   varchar2
  ,p_bpd_attribute3               in   varchar2
  ,p_bpd_attribute4               in   varchar2
  ,p_bpd_attribute5               in   varchar2
  ,p_bpd_attribute6               in   varchar2
  ,p_bpd_attribute7               in   varchar2
  ,p_bpd_attribute8               in   varchar2
  ,p_bpd_attribute9               in   varchar2
  ,p_bpd_attribute10              in   varchar2
  ,p_bpd_attribute11              in   varchar2
  ,p_bpd_attribute12              in   varchar2
  ,p_bpd_attribute13              in   varchar2
  ,p_bpd_attribute14              in   varchar2
  ,p_bpd_attribute15              in   varchar2
  ,p_bpd_attribute16              in   varchar2
  ,p_bpd_attribute17              in   varchar2
  ,p_bpd_attribute18              in   varchar2
  ,p_bpd_attribute19              in   varchar2
  ,p_bpd_attribute20              in   varchar2
  ,p_bpd_attribute21              in   varchar2
  ,p_bpd_attribute22              in   varchar2
  ,p_bpd_attribute23              in   varchar2
  ,p_bpd_attribute24              in   varchar2
  ,p_bpd_attribute25              in   varchar2
  ,p_bpd_attribute26              in   varchar2
  ,p_bpd_attribute27              in   varchar2
  ,p_bpd_attribute28              in   varchar2
  ,p_bpd_attribute29              in   varchar2
  ,p_bpd_attribute30              in   varchar2
  ,p_payment_detail_id            in   number
  ,p_payment_detail_ovn           in   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_payment_detail_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_payment_detail_a
  (p_effective_date               in     date
  ,p_check_number                 in     number
  ,p_payment_date                 in   date
  ,p_amount                       in     number
  ,p_check_type                   in     varchar2
  ,p_bpd_attribute_category       in     varchar2
  ,p_bpd_attribute1               in     varchar2
  ,p_bpd_attribute2               in     varchar2
  ,p_bpd_attribute3               in     varchar2
  ,p_bpd_attribute4               in     varchar2
  ,p_bpd_attribute5               in     varchar2
  ,p_bpd_attribute6               in     varchar2
  ,p_bpd_attribute7               in     varchar2
  ,p_bpd_attribute8               in     varchar2
  ,p_bpd_attribute9               in     varchar2
  ,p_bpd_attribute10              in     varchar2
  ,p_bpd_attribute11              in     varchar2
  ,p_bpd_attribute12              in     varchar2
  ,p_bpd_attribute13              in     varchar2
  ,p_bpd_attribute14              in     varchar2
  ,p_bpd_attribute15              in     varchar2
  ,p_bpd_attribute16              in     varchar2
  ,p_bpd_attribute17              in     varchar2
  ,p_bpd_attribute18              in     varchar2
  ,p_bpd_attribute19              in     varchar2
  ,p_bpd_attribute20              in     varchar2
  ,p_bpd_attribute21              in     varchar2
  ,p_bpd_attribute22              in     varchar2
  ,p_bpd_attribute23              in     varchar2
  ,p_bpd_attribute24              in     varchar2
  ,p_bpd_attribute25              in     varchar2
  ,p_bpd_attribute26              in     varchar2
  ,p_bpd_attribute27              in     varchar2
  ,p_bpd_attribute28              in     varchar2
  ,p_bpd_attribute29              in     varchar2
  ,p_bpd_attribute30              in     varchar2
  ,p_payment_detail_id            in     number
  ,p_payment_detail_ovn           in     number
  );
--
end per_bf_payment_details_bk2;

 

/
