--------------------------------------------------------
--  DDL for Package PER_PPC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PPC_RKD" AUTHID CURRENT_USER as
/* $Header: peppcrhi.pkh 120.1 2006/03/14 18:16:34 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook.
--
Procedure after_delete
  (
  p_component_id                 in number,
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
end per_ppc_rkd;

 

/
