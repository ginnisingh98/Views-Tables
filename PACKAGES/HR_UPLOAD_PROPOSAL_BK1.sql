--------------------------------------------------------
--  DDL for Package HR_UPLOAD_PROPOSAL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UPLOAD_PROPOSAL_BK1" AUTHID CURRENT_USER as
/* $Header: hrpypapi.pkh 120.11.12010000.3 2008/12/05 14:33:06 vkodedal ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< upload_salary_proposal_b  >--------------------|
-- ----------------------------------------------------------------------------

procedure upload_salary_proposal_b
  (p_change_date                   in     date
  ,p_business_group_id             in     number
  ,p_assignment_id		   in     number
  ,p_proposed_salary               in     number
  ,p_proposal_reason		   in     varchar2
  ,p_next_sal_review_date          in     date  -- Bug 1620922
  ,p_forced_ranking                in     number
  ,p_date_to			   in     date
  ,p_pay_proposal_id               in     number
  ,p_object_version_number         in     number
  --
  ,p_component_reason_1		   in     varchar2
  ,p_change_amount_1		   in     number
  ,p_change_percentage_1	   in     number
  ,p_approved_1			   in 	  varchar2
  ,p_component_id_1		   in     number
  ,p_ppc_object_version_number_1   in     number
  --
  ,p_component_reason_2		   in     varchar2
  ,p_change_amount_2		   in     number
  ,p_change_percentage_2	   in     number
  ,p_approved_2			   in 	  varchar2
  ,p_component_id_2		   in     number
  ,p_ppc_object_version_number_2   in     number
  --
  ,p_component_reason_3		   in     varchar2
  ,p_change_amount_3		   in     number
  ,p_change_percentage_3	   in     number
  ,p_approved_3			   in 	  varchar2
  ,p_component_id_3		   in     number
  ,p_ppc_object_version_number_3   in     number
  --
  ,p_component_reason_4		   in     varchar2
  ,p_change_amount_4		   in     number
  ,p_change_percentage_4	   in     number
  ,p_approved_4			   in 	  varchar2
  ,p_component_id_4		   in     number
  ,p_ppc_object_version_number_4   in     number
  --
  ,p_component_reason_5		   in     varchar2
  ,p_change_amount_5		   in     number
  ,p_change_percentage_5	   in     number
  ,p_approved_5			   in 	  varchar2
  ,p_component_id_5		   in     number
  ,p_ppc_object_version_number_5   in     number
  --
  ,p_component_reason_6		   in     varchar2
  ,p_change_amount_6		   in     number
  ,p_change_percentage_6	   in     number
  ,p_approved_6			   in 	  varchar2
  ,p_component_id_6		   in     number
  ,p_ppc_object_version_number_6   in     number
  --
  ,p_component_reason_7		   in     varchar2
  ,p_change_amount_7		   in     number
  ,p_change_percentage_7	   in     number
  ,p_approved_7			   in 	  varchar2
  ,p_component_id_7		   in     number
  ,p_ppc_object_version_number_7   in     number
  --
  ,p_component_reason_8		   in     varchar2
  ,p_change_amount_8		   in     number
  ,p_change_percentage_8	   in     number
  ,p_approved_8			   in 	  varchar2
  ,p_component_id_8		   in     number
  ,p_ppc_object_version_number_8   in     number
  --
  ,p_component_reason_9		   in     varchar2
  ,p_change_amount_9		   in     number
  ,p_change_percentage_9	   in     number
  ,p_approved_9			   in 	  varchar2
  ,p_component_id_9		   in     number
  ,p_ppc_object_version_number_9   in     number
  --
  ,p_component_reason_10	   in     varchar2
  ,p_change_amount_10		   in     number
  ,p_change_percentage_10	   in     number
  ,p_approved_10		   in 	  varchar2
  ,p_component_id_10		   in     number
  ,p_ppc_object_version_number_10  in     number
   );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< upload_salary_proposal_a  >--------------------|
-- ----------------------------------------------------------------------------
procedure  upload_salary_proposal_a
  (p_change_date                   in     date
  ,p_business_group_id             in     number
  ,p_assignment_id		   in     number
  ,p_proposed_salary               in     number
  ,p_proposal_reason		   in     varchar2
  ,p_next_sal_review_date          in     date
  ,p_forced_ranking                in     number
  ,p_date_to			   in     date
  ,p_pay_proposal_id               in     number
  ,p_object_version_number         in     number
  --
  ,p_component_reason_1		   in     varchar2
  ,p_change_amount_1		   in     number
  ,p_change_percentage_1	   in     number
  ,p_approved_1			   in 	  varchar2
  ,p_component_id_1		   in     number
  ,p_ppc_object_version_number_1   in     number
  --
  ,p_component_reason_2		   in     varchar2
  ,p_change_amount_2		   in     number
  ,p_change_percentage_2	   in     number
  ,p_approved_2			   in 	  varchar2
  ,p_component_id_2		   in     number
  ,p_ppc_object_version_number_2   in     number
  --
  ,p_component_reason_3		   in     varchar2
  ,p_change_amount_3		   in     number
  ,p_change_percentage_3	   in     number
  ,p_approved_3			   in 	  varchar2
  ,p_component_id_3		   in     number
  ,p_ppc_object_version_number_3   in     number
  --
  ,p_component_reason_4		   in     varchar2
  ,p_change_amount_4		   in     number
  ,p_change_percentage_4	   in     number
  ,p_approved_4			   in 	  varchar2
  ,p_component_id_4		   in     number
  ,p_ppc_object_version_number_4   in     number
  --
  ,p_component_reason_5		   in     varchar2
  ,p_change_amount_5		   in     number
  ,p_change_percentage_5	   in     number
  ,p_approved_5			   in 	  varchar2
  ,p_component_id_5		   in     number
  ,p_ppc_object_version_number_5   in     number
  --
  ,p_component_reason_6		   in     varchar2
  ,p_change_amount_6		   in     number
  ,p_change_percentage_6	   in     number
  ,p_approved_6			   in 	  varchar2
  ,p_component_id_6		   in     number
  ,p_ppc_object_version_number_6   in     number
  --
  ,p_component_reason_7		   in     varchar2
  ,p_change_amount_7		   in     number
  ,p_change_percentage_7	   in     number
  ,p_approved_7			   in 	  varchar2
  ,p_component_id_7		   in     number
  ,p_ppc_object_version_number_7   in     number
  --
  ,p_component_reason_8		   in     varchar2
  ,p_change_amount_8		   in     number
  ,p_change_percentage_8	   in     number
  ,p_approved_8			   in 	  varchar2
  ,p_component_id_8		   in     number
  ,p_ppc_object_version_number_8   in     number
  --
  ,p_component_reason_9		   in     varchar2
  ,p_change_amount_9		   in     number
  ,p_change_percentage_9	   in     number
  ,p_approved_9			   in 	  varchar2
  ,p_component_id_9		   in     number
  ,p_ppc_object_version_number_9   in     number
  --
  ,p_component_reason_10	   in     varchar2
  ,p_change_amount_10		   in     number
  ,p_change_percentage_10	   in     number
  ,p_approved_10		   in 	  varchar2
  ,p_component_id_10		   in     number
  ,p_ppc_object_version_number_10  in     number
  --
  ,p_pyp_proposed_sal_warning      in     boolean
  ,p_additional_comp_warning	   in     boolean
  );
end hr_upload_proposal_bk1;

/
