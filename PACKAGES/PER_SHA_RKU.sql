--------------------------------------------------------
--  DDL for Package PER_SHA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SHA_RKU" AUTHID CURRENT_USER as
/* $Header: pesharhi.pkh 120.0 2005/05/31 21:03:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_update >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
    (p_std_holiday_absences_id    in  number
    ,p_date_not_taken             in  date
    ,p_person_id                  in  number
    ,p_standard_holiday_id        in  number
    ,p_actual_date_taken          in  date
    ,p_reason                     in  varchar2
    ,p_expired                    in  varchar2
    ,p_attribute_category         in  varchar2
    ,p_attribute1                 in  varchar2
    ,p_attribute2                 in  varchar2
    ,p_attribute3                 in  varchar2
    ,p_attribute4                 in  varchar2
    ,p_attribute5                 in  varchar2
    ,p_attribute6                 in  varchar2
    ,p_attribute7                 in  varchar2
    ,p_attribute8                 in  varchar2
    ,p_attribute9                 in  varchar2
    ,p_attribute10                in  varchar2
    ,p_attribute11                in  varchar2
    ,p_attribute12                in  varchar2
    ,p_attribute13                in  varchar2
    ,p_attribute14                in  varchar2
    ,p_attribute15                in  varchar2
    ,p_attribute16                in  varchar2
    ,p_attribute17                in  varchar2
    ,p_attribute18                in  varchar2
    ,p_attribute19                in  varchar2
    ,p_attribute20                in  varchar2
    ,p_object_version_number      in  number
    ,p_date_not_taken_o           in  date
    ,p_person_id_o                in  number
    ,p_standard_holiday_id_o      in  number
    ,p_actual_date_taken_o        in  date
    ,p_reason_o                   in  varchar2
    ,p_expired_o                  in  varchar2
    ,p_attribute_category_o       in  varchar2
    ,p_attribute1_o               in  varchar2
    ,p_attribute2_o               in  varchar2
    ,p_attribute3_o               in  varchar2
    ,p_attribute4_o               in  varchar2
    ,p_attribute5_o               in  varchar2
    ,p_attribute6_o               in  varchar2
    ,p_attribute7_o               in  varchar2
    ,p_attribute8_o               in  varchar2
    ,p_attribute9_o               in  varchar2
    ,p_attribute10_o              in  varchar2
    ,p_attribute11_o              in  varchar2
    ,p_attribute12_o              in  varchar2
    ,p_attribute13_o              in  varchar2
    ,p_attribute14_o              in  varchar2
    ,p_attribute15_o              in  varchar2
    ,p_attribute16_o              in  varchar2
    ,p_attribute17_o              in  varchar2
    ,p_attribute18_o              in  varchar2
    ,p_attribute19_o              in  varchar2
    ,p_attribute20_o              in  varchar2
    ,p_object_version_number_o    in  number
    );
  --
end per_sha_rku;

 

/
