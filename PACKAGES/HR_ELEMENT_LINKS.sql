--------------------------------------------------------
--  DDL for Package HR_ELEMENT_LINKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ELEMENT_LINKS" AUTHID CURRENT_USER as
/* $Header: pyelelnk.pkh 115.0 99/07/17 05:58:58 porting ship $ */
--

 /*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************
--
    Name        : hr_element_links
--
    Description : This package holds procedures and functions related to the
                  following tables :
			PAY_ELEMENT_LINKS_F
--
    $Author: appldev $
    $Date: 99/07/17 05:58:58 $
    $Revision: 115.0 $

    Uses        : hr_element_links
    Used By     : n/a
--
    Test List
    ---------
    Procedure                     Name       Date        Test Id Status
    +----------------------------+----------+-----------+-------+--------------+
    chk_mutual_exclusivity        M Dyer     19-Jan-1993   1     Complete
--
    Change List
    -----------
    Date         Name          Vers    Bug No     Description
    +-----------+-------------+-------+----------+-----------------------------+    17-Feb-93    J.S.Hobbs     30.6               Altered insert_alu and
						  create_standard_entries_el.
    03-Mar-1993  J.S.Hobbs     30.9               Removed get_termination_date,
						  get_entry_start_date_qc and
						  create_rec_element_entry.
						  They are in hrentmnt.
    21-Apr-1993  M Dyer
    05-Oct-1993  M Kaddir      40.2     X21       Changed chk_element_link
                                                  and chk_mutual_exclusivity
                                                  to include two new link
                                                  criteria:
                                                  -  Employment Category and
                                                  -  Pay Basis
    22-Oct-1993  J.S.Hobbs     40.2              -Changed ins_3p_element_link
						  to cope with two new
						  criteria ie. PAY_BASIS_ID and
						  EMPLOYMENT_CATEGORY.
                                                 -Removed
						  create_standard_entries_el
						  and recoded in hrentmnt with
						  a new prcoedure called
						  maintain_entries_el.
	24-Jan-94 N Simpson			- Removed CHK_MUTUAL_EXCLUSIVITY
						  which was not accessed by
						  other packages.G525

    ###########################################################################

    04-Mar-1994  C.Swan                           Moved from 10.0 as a result
                                                  of the 10->10G merge.
    07-Mar-1994  C.Swan                           Removed leading "####" from
                                                  above line, due to
                                                  Autoinstall objecting.
    28-MAR-94   R.Neale       40.6                Added header info
    30-MAR-94   A.McGhee      40.7                Moved header line to the
						  comment section.

                                                                              */
--
 /*
 NAME
       get_greatest_end_date
 DESCRIPTION
        This function returns the greatest end date that the element link can
        continue until. This is the least of the element_type end date and
        the last end date of any payrolls it may be linked to
*/
--
FUNCTION        get_greatest_end_date(p_element_type_id  in number,
                                      p_business_group_id in number,
                                      p_link_to_all_payrolls_flag in varchar2,
                                      p_payroll_id	in number,
                                      p_greatest_link_date in date)
							 return date;
--
 /*
 NAME
        chk_element_links
 DESCRIPTION
        This procedure checks to see if any distributed links are themselves in        distribution sets
 */
--
--
PROCEDURE       chk_element_links(p_element_type_id     in number,
                                  p_element_link_id     in number,
                                  p_val_start_date      in date,
                                  p_val_end_date        in out date,
                                  p_business_group_id   in number,
                                  p_legislation_code    in varchar2,
                                  p_costable_type       in varchar2,
                                  p_organization_id     in number,
                                  p_people_group_id     in number,
                                  p_job_id              in number,
                                  p_position_id         in number,
                                  p_grade_id            in number,
                                  p_location_id         in number,
                                  p_payroll_id          in number,
                                  p_link_to_all_payrolls_flag in varchar2,
                                  p_element_set_id      in number,
				  p_balancing_keyflex_id in number,
				  p_classification_id	in number,
                                  p_employment_category in varchar2,
                                  p_pay_basis_id        in number);
--
 /*
 NAME
        chk_upd_element_links
 DESCRIPTION
        The costable type of a link can only be updated over all time if there
        are no entries in existence for this link.
 */
--
PROCEDURE       chk_upd_element_links(p_element_link_id	in number,
				      p_update_mode  	in varchar2,
                                      p_val_start_date	in date,
                                      p_val_end_date	in date,
                                      p_old_costable_type in varchar2,
                                      p_costable_type	in varchar2);
--
 /*
 NAME
        chk_del_element_links
 DESCRIPTION
        This procedure checks to see whether element links can be deleted.
        They cannot be deleted if there are any non recurring entries in the
        but this will result in these entries being lost forever and a warning
        message will be given to this effect.
 */
--
--
PROCEDURE       chk_del_element_link(p_element_link_id  in varchar2,
                                     p_val_start_date   in date,
                                     p_val_end_date     in date,
                                     p_warning_message  in out varchar2);
--
 PROCEDURE insert_alu(p_mode                  varchar2,
                      p_id_flex_num           number,
                      p_business_group_id     number,
                      p_people_group_id       number,
                      p_element_link_id       number,
                      p_assignment_id         number,
                      p_effective_start_date  date,
                      p_effective_end_date    date);
--
 /*
 NAME
        ins_costing_segments
 DESCRIPTION
        This procedure will update the pay_cost_allocation_keyflex table with
        the concatenated costing keyflexes. It should always be called when
        a new costed, fixed or distributed element link is created and also
        when one of these fields has been updated.
        */
PROCEDURE       ins_costing_segments(
                                     p_cost_allocation_keyflex_id varchar2,
                                     p_displayed_cost_keyflex varchar2,
                                     p_balancing_keyflex_id varchar2,
                                     p_displayed_balancing_keyflex varchar2);
--
--
 /*
 NAME
        ins_3p_element_link
 DESCRIPTION
        This procedure inserts link input values when an element link is
        created. It will also insert Assignment link usages and Standard
        recurring entries.
 */
--
procedure ins_3p_element_link
(
 p_element_link_id	     in number,
 p_element_type_id	     in number,
 p_val_start_date	     in date,
 p_val_end_date		     in date,
 p_standard_link_flag	     in varchar2,
 p_payroll_id		     in number,
 p_link_to_all_payrolls_flag in varchar2,
 p_job_id		     in number,
 p_grade_id		     in number,
 p_position_id		     in number,
 p_organization_id	     in number,
 p_people_group_id	     in number,
 p_location_id		     in number,
 p_pay_basis_id              in number,
 p_employment_category       in varchar2,
 p_qual_age		     in number,
 p_qual_length_of_service    in number,
 p_qual_units		     in varchar2,
 p_costable_type	     in varchar2,
 p_pay_value_name	     in varchar2,
 p_id_flex_num		     in number,
 p_business_group_id	     in number,
 p_legislation_code	     in varchar2
);
--
 /*
 NAME
        upd_3p_element_link
 DESCRIPTION
        This procedure updates the costing flag on the link input values
        according to the costable type on the element link.
 */
--
PROCEDURE	upd_3p_element_links(p_element_link_id	in number,
				     p_val_start_date	in date,
				     p_val_end_date	in date,
				     p_pay_value_name 	in varchar2,
				     p_old_costable_type  in varchar2,
				     p_costable_type	in varchar2,
					p_payroll_id		number,
					p_business_group_id	number,
					p_location_id		number,
					p_grade_id		number,
					p_link_to_all_payrolls_flag	varchar2,
					p_organization_id	number,
					p_position_id		number,
					p_job_id		number,
					p_element_type_id	number,
					p_pay_basis_id		number,
					p_employment_category	number,
					p_people_group_id	number,
					p_old_link_flag	in varchar2,
					p_link_flag	in varchar2);
--
PROCEDURE       delete_entry_values(
                                p_element_entry_id       in number,
                                p_delete_mode           in varchar2,
				p_val_session_date	in date,
                                p_val_start_date        in date,
                                p_val_end_date          in date);
--
--
 /*
 NAME
        del_3p_element_link
 DESCRIPTION
        This procedure deletes link input values in line with the deletion on
        element link. It will also delete Assignment link usages and recurring
        entries.
 */
--
PROCEDURE       del_3p_element_links(
                                p_element_link_id       in number,
                                p_delete_mode           in varchar2,
                                p_val_session_date      in date,
                                p_val_start_date        in date,
                                p_val_end_date          in date,
                                p_id_flex_num           in number,
                                p_business_group_id     in number,
                                p_people_group_id       in number);
--
--
/*	TITLE
	chk_link_input_values
	DESCRIPTION
	This procedure checks against the corresponding input value to ensure
	that the validation is correct for the link input value. This includes
	hot defaulted values.
*/
--
PROCEDURE	chk_link_input_values(
			p_input_value_id in numbeR,
                        p_legislation_code in varchar2,
                        p_costable_type in varchar2,
                        p_costed_flag   in varchar2,
			p_validation_start_date in datE,
			P_Validation_end_date in datE,
			p_min_value in varchar2,
			p_max_value in varchar2,
			p_default_value in varchar2,
			p_warning_or_error in varchar2);
--
-- This procedure checks that the link flag may be updated to Y by checking
-- for the existence of entries for the link.
--
procedure LINK_FLAG_UPDATED (p_link_id	number);
--
end hr_element_links;

 

/
