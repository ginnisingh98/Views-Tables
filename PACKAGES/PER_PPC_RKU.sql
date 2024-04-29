--------------------------------------------------------
--  DDL for Package PER_PPC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PPC_RKU" AUTHID CURRENT_USER as
/* $Header: peppcrhi.pkh 120.1 2006/03/14 18:16:34 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_update >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook.
--
Procedure after_update
  (
  p_component_id                 in number,
  p_approved                     in varchar2,
  p_component_reason             in varchar2,
  p_change_amount_n              in number,
  p_change_percentage            in number,
  p_comments                     in varchar2,
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
  p_validation_strength          in varchar2,
  p_pay_proposal_id_o            in number,
  p_business_group_id_o          in number,
  p_approved_o                   in varchar2,
  p_component_reason_o           in varchar2,
  p_change_amount_n_o            in number,
  p_change_percentage_o          in number,
  p_comments_o                   in varchar2,
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
  p_object_version_number_o      in number
  );
--
end per_ppc_rku;

 

/