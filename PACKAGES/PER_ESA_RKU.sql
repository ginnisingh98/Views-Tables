--------------------------------------------------------
--  DDL for Package PER_ESA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ESA_RKU" AUTHID CURRENT_USER as
/* $Header: peesarhi.pkh 120.0.12010000.1 2008/07/28 04:37:47 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< after_update >----------------------------------|
-- ----------------------------------------------------------------------------
--
--{Start Of Comments}
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_update
   (p_attendance_id                in number,
    p_person_id                    in number,
    p_establishment_id             in number,
    p_establishment                in varchar2,
    p_attended_start_date          in date,
    p_attended_end_date            in date,
    p_full_time                    in varchar2,
    p_attribute_category           in varchar2,
    p_attribute1                   in varchar2,
    p_attribute2                   in varchar2,
    p_attribute3                   in varchar2,
    p_attribute4                   in varchar2,
    p_attribute5                   in varchar2,
    p_attribute6                   in varchar2,
    p_attribute7                   in varchar2,
    p_attribute8                   in varchar2,
    p_attribute9                   in varchar2,
    p_attribute10                  in varchar2,
    p_attribute11                  in varchar2,
    p_attribute12                  in varchar2,
    p_attribute13                  in varchar2,
    p_attribute14                  in varchar2,
    p_attribute15                  in varchar2,
    p_attribute16                  in varchar2,
    p_attribute17                  in varchar2,
    p_attribute18                  in varchar2,
    p_attribute19                  in varchar2,
    p_attribute20                  in varchar2,
    p_object_version_number        in number,
    p_business_group_id            in number,
    p_effective_date               in date,
    p_party_id                     in number,
    p_address			   in varchar2,
    p_person_id_o                  in number,
    p_establishment_id_o           in number,
    p_establishment_o              in varchar2,
    p_attended_start_date_o        in date,
    p_attended_end_date_o          in date,
    p_full_time_o                  in varchar2,
    p_attribute_category_o         in varchar2,
    p_attribute1_o                 in varchar2,
    p_attribute2_o                 in varchar2,
    p_attribute3_o                 in varchar2,
    p_attribute4_o                 in varchar2,
    p_attribute5_o                 in varchar2,
    p_attribute6_o                 in varchar2,
    p_attribute7_o                 in varchar2,
    p_attribute8_o                 in varchar2,
    p_attribute9_o                 in varchar2,
    p_attribute10_o                in varchar2,
    p_attribute11_o                in varchar2,
    p_attribute12_o                in varchar2,
    p_attribute13_o                in varchar2,
    p_attribute14_o                in varchar2,
    p_attribute15_o                in varchar2,
    p_attribute16_o                in varchar2,
    p_attribute17_o                in varchar2,
    p_attribute18_o                in varchar2,
    p_attribute19_o                in varchar2,
    p_attribute20_o                in varchar2,
    p_object_version_number_o      in number,
    p_business_group_id_o          in number,
    p_party_id_o                   in number,  -- HR/TCA merge
    p_address_o			   in varchar2
    );
end per_esa_rku;

/
