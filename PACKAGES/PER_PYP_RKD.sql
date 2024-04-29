--------------------------------------------------------
--  DDL for Package PER_PYP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PYP_RKD" AUTHID CURRENT_USER as
/* $Header: pepyprhi.pkh 120.6.12010000.3 2009/06/10 12:58:47 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook.
--
Procedure after_delete
  (
   p_pay_proposal_id               in number,
   p_assignment_id_o               in number,
   p_business_group_id_o           in number,
   p_change_date_o                 in date,
   p_comments_o                    in varchar2,
   p_next_sal_review_date_o        in date,
   p_proposal_reason_o             in varchar2,
   p_proposed_salary_n_o           in number,
   p_forced_ranking_o              in number,
   p_date_to_o			   in date,
   p_performance_review_id_o       in number,
   p_attribute_category_o          in varchar2,
   p_attribute1_o                  in varchar2,
   p_attribute2_o                  in varchar2,
   p_attribute3_o                  in varchar2,
   p_attribute4_o                  in varchar2,
   p_attribute5_o                  in varchar2,
   p_attribute6_o                  in varchar2,
   p_attribute7_o                  in varchar2,
   p_attribute8_o                  in varchar2,
   p_attribute9_o                  in varchar2,
   p_attribute10_o                 in varchar2,
   p_attribute11_o                 in varchar2,
   p_attribute12_o                 in varchar2,
   p_attribute13_o                 in varchar2,
   p_attribute14_o                 in varchar2,
   p_attribute15_o                 in varchar2,
   p_attribute16_o                 in varchar2,
   p_attribute17_o                 in varchar2,
   p_attribute18_o                 in varchar2,
   p_attribute19_o                 in varchar2,
   p_attribute20_o                 in varchar2,
   p_object_version_number_o       in number,
   p_multiple_components_o         in varchar2,
   p_approved_o                    in varchar2
  );
end per_pyp_rkd;

/
