--------------------------------------------------------
--  DDL for Package PER_ESA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ESA_RKD" AUTHID CURRENT_USER as
/* $Header: peesarhi.pkh 120.0.12010000.1 2008/07/28 04:37:47 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
  (p_attendance_id                in number
  ,p_person_id_o                  in number
  ,p_establishment_id_o           in number
  ,p_establishment_o              in varchar2
  ,p_attended_start_date_o        in date
  ,p_attended_end_date_o          in date
  ,p_full_time_o                  in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_object_version_number_o      in number
  ,p_business_group_id_o          in number
  ,p_party_id_o                   in number   -- HR/TCA merge
  ,p_address_o			  in varchar2
   );
end per_esa_rkd;

/
