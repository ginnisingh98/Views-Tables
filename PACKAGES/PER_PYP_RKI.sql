--------------------------------------------------------
--  DDL for Package PER_PYP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PYP_RKI" AUTHID CURRENT_USER as
/* $Header: pepyprhi.pkh 120.6.12010000.3 2009/06/10 12:58:47 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook.
--
Procedure after_insert
  (
   p_pay_proposal_id               in number,
   p_assignment_id                 in number,
   p_business_group_id             in number,
   p_change_date                   in date,
   p_comments                      in varchar2,
   p_next_sal_review_date          in date,
   p_proposal_reason               in varchar2,
   p_proposed_salary_n             in number,
   p_forced_ranking                in number,
   p_date_to			   in date,
   p_performance_review_id         in number,
   p_attribute_category            in varchar2,
   p_attribute1                    in varchar2,
   p_attribute2                    in varchar2,
   p_attribute3                    in varchar2,
   p_attribute4                    in varchar2,
   p_attribute5                    in varchar2,
   p_attribute6                    in varchar2,
   p_attribute7                    in varchar2,
   p_attribute8                    in varchar2,
   p_attribute9                    in varchar2,
   p_attribute10                   in varchar2,
   p_attribute11                   in varchar2,
   p_attribute12                   in varchar2,
   p_attribute13                   in varchar2,
   p_attribute14                   in varchar2,
   p_attribute15                   in varchar2,
   p_attribute16                   in varchar2,
   p_attribute17                   in varchar2,
   p_attribute18                   in varchar2,
   p_attribute19                   in varchar2,
   p_attribute20                   in varchar2,
   p_object_version_number         in number,
   p_multiple_components           in varchar2,
   p_approved                      in varchar2,
   p_inv_next_sal_date_warning     in boolean,
   p_proposed_salary_warning	   in boolean,
   p_approved_warning              in boolean,
   p_payroll_warning		   in boolean
  );
end per_pyp_rki;

/