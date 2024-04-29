--------------------------------------------------------
--  DDL for Package PER_US_EXTRA_ASSIGNMENT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_EXTRA_ASSIGNMENT_RULES" AUTHID CURRENT_USER AS
/* $Header: peasghcc.pkh 120.0 2005/05/31 05:41:45 appldev noship $ */
--
-- Global variable to store the location_id of the assignment record
-- before the update_emp_asg_criteria procedure makes a change to the
-- assignment.  THIS VARIABLE SHOULD ONLY BE REFRENCED IN THE
-- GET_CURR_ASS_LOCATION_ID procedure and in the PAY_US_TAX_INTERNAL
-- package.

   g_old_assgt_location       number   default  hr_api.g_number;


procedure insert_tax_record
  (p_effective_date    in date
  ,p_assignment_id     in number
  );
--
procedure update_tax_record
  (p_effective_date         in date
  ,p_datetrack_update_mode  in varchar2
  ,p_assignment_id          in number
  ,p_location_id            in number
  );
--
procedure get_curr_ass_location_id
  (p_effective_date         in date
  ,p_datetrack_update_mode  in varchar2
  ,p_assignment_id          in number
  );
--
procedure delete_tax_record
  (p_final_process_date  in date
  ,p_assignment_id       in number
  );
procedure pay_us_asg_reporting
  (p_assignment_id       in number
  );
--
END per_us_extra_assignment_rules;

 

/
