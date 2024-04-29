--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_LINKS_PKG" AUTHID CURRENT_USER as
/* $Header: pyeli.pkh 120.1.12010000.1 2008/07/27 22:31:16 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Element Links Table Handler
Purpose
	To act as an interface between forms and the Element Links entity
History
	16-MAR-1994	N Simpson	Created
	29-MAR-1994	N Simpson	Amended check_distribution_set to
					restrict cursor by business group/
					legislation code
	22-JUN-1994	N Simpson	Fixes to G908 bugs
	25-Oct-1994	N Simpson	Fixed G1355 by adding check to
					check_deletion_allowed to prevent
					deletion if balance adjustment entries
					exist outside the life of the link
    20-MAY-2005 SuSivasu    Fixed dbdrv, NOCOPY and GSCC issues.
    14-NOV-2006 thabara     Added function pay_basis_exists.
									*/
--------------------------------------------------------------------------------
function LINK_END_DATE (p_link_id number) return date;
--------------------------------------------------------------------------------
procedure insert_row(p_rowid                        in out nocopy varchar2,
                     p_element_link_id              in out nocopy number,
                     p_effective_start_date                date,
                     p_effective_end_date           in out nocopy date,
                     p_payroll_id                          number,
                     p_job_id                              number,
                     p_position_id                         number,
                     p_people_group_id                     number,
                     p_cost_allocation_keyflex_id          number,
                     p_organization_id                     number,
                     p_element_type_id                     number,
                     p_location_id                         number,
                     p_grade_id                            number,
                     p_balancing_keyflex_id                number,
                     p_business_group_id                   number,
		     p_legislation_code			   varchar2,
                     p_element_set_id                      number,
                     p_pay_basis_id                        number,
                     p_costable_type                       varchar2,
                     p_link_to_all_payrolls_flag           varchar2,
                     p_multiply_value_flag                 varchar2,
                     p_standard_link_flag                  varchar2,
                     p_transfer_to_gl_flag                 varchar2,
                     p_comment_id                          number,
                     p_employment_category                 varchar2,
                     p_qualifying_age                      number,
                     p_qualifying_length_of_service        number,
                     p_qualifying_units                    varchar2,
                     p_attribute_category                  varchar2,
                     p_attribute1                          varchar2,
                     p_attribute2                          varchar2,
                     p_attribute3                          varchar2,
                     p_attribute4                          varchar2,
                     p_attribute5                          varchar2,
                     p_attribute6                          varchar2,
                     p_attribute7                          varchar2,
                     p_attribute8                          varchar2,
                     p_attribute9                          varchar2,
                     p_attribute10                         varchar2,
                     p_attribute11                         varchar2,
                     p_attribute12                         varchar2,
                     p_attribute13                         varchar2,
                     p_attribute14                         varchar2,
                     p_attribute15                         varchar2,
                     p_attribute16                         varchar2,
                     p_attribute17                         varchar2,
                     p_attribute18                         varchar2,
                     p_attribute19                         varchar2,
                     p_attribute20                         varchar2);
-------------------------------------------------------------------------------
procedure lock_row(p_rowid                                 varchar2,
                   p_element_link_id                       number,
                   p_effective_start_date                  date,
                   p_effective_end_date                    date,
                   p_payroll_id                            number,
                   p_job_id                                number,
                   p_position_id                           number,
                   p_people_group_id                       number,
                   p_cost_allocation_keyflex_id            number,
                   p_organization_id                       number,
                   p_element_type_id                       number,
                   p_location_id                           number,
                   p_grade_id                              number,
                   p_balancing_keyflex_id                  number,
                   p_business_group_id                     number,
                   p_element_set_id                        number,
                   p_pay_basis_id                          number,
                   p_costable_type                         varchar2,
                   p_link_to_all_payrolls_flag             varchar2,
                   p_multiply_value_flag                   varchar2,
                   p_standard_link_flag                    varchar2,
                   p_transfer_to_gl_flag                   varchar2,
                   p_comment_id                            number,
                   p_employment_category                   varchar2,
                   p_qualifying_age                        number,
                   p_qualifying_length_of_service          number,
                   p_qualifying_units                      varchar2,
                   p_attribute_category                    varchar2,
                   p_attribute1                            varchar2,
                   p_attribute2                            varchar2,
                   p_attribute3                            varchar2,
                   p_attribute4                            varchar2,
                   p_attribute5                            varchar2,
                   p_attribute6                            varchar2,
                   p_attribute7                            varchar2,
                   p_attribute8                            varchar2,
                   p_attribute9                            varchar2,
                   p_attribute10                           varchar2,
                   p_attribute11                           varchar2,
                   p_attribute12                           varchar2,
                   p_attribute13                           varchar2,
                   p_attribute14                           varchar2,
                   p_attribute15                           varchar2,
                   p_attribute16                           varchar2,
                   p_attribute17                           varchar2,
                   p_attribute18                           varchar2,
                   p_attribute19                           varchar2,
                   p_attribute20                           varchar2) ;
--------------------------------------------------------------------------------
procedure update_row(p_rowid                               varchar2,
                     p_element_link_id                     number,
                     p_effective_start_date                date,
                     p_effective_end_date           in out nocopy date,
                     p_payroll_id                          number,
                     p_job_id                              number,
                     p_position_id                         number,
                     p_people_group_id                     number,
                     p_cost_allocation_keyflex_id          number,
                     p_organization_id                     number,
                     p_element_type_id                     number,
                     p_location_id                         number,
                     p_grade_id                            number,
                     p_balancing_keyflex_id                number,
                     p_business_group_id                   number,
		     p_legislation_code			   varchar2,
                     p_element_set_id                      number,
                     p_pay_basis_id                        number,
                     p_costable_type                       varchar2,
                     p_link_to_all_payrolls_flag           varchar2,
                     p_multiply_value_flag                 varchar2,
                     p_standard_link_flag                  varchar2,
                     p_transfer_to_gl_flag                 varchar2,
                     p_comment_id                          number,
                     p_employment_category                 varchar2,
                     p_qualifying_age                      number,
                     p_qualifying_length_of_service        number,
                     p_qualifying_units                    varchar2,
                     p_attribute_category                  varchar2,
                     p_attribute1                          varchar2,
                     p_attribute2                          varchar2,
                     p_attribute3                          varchar2,
                     p_attribute4                          varchar2,
                     p_attribute5                          varchar2,
                     p_attribute6                          varchar2,
                     p_attribute7                          varchar2,
                     p_attribute8                          varchar2,
                     p_attribute9                          varchar2,
                     p_attribute10                         varchar2,
                     p_attribute11                         varchar2,
                     p_attribute12                         varchar2,
                     p_attribute13                         varchar2,
                     p_attribute14                         varchar2,
                     p_attribute15                         varchar2,
                     p_attribute16                         varchar2,
                     p_attribute17                         varchar2,
                     p_attribute18                         varchar2,
                     p_attribute19                         varchar2,
                     p_attribute20                         varchar2);
--------------------------------------------------------------------------------
procedure delete_row(
--
	p_rowid 		varchar2,
	p_element_link_id 	number,
	p_delete_mode		varchar2,
	p_session_date		date,
	p_validation_start_date	date,
	p_validation_end_date	date,
	p_effective_start_date	date,
	p_business_group_id	number,
	p_people_group_id	number);
--------------------------------------------------------------------------------
function MAX_END_DATE(
--
--******************************************************************************
--* Returns the latest allowable date for the effective end date of a link.    *
--* This is the latest of:						       *
--*	1.	The element type's last effective end date.		       *
--*	2.	The latest end date for a payroll associated with the link.    *
--*	3.	The day before the start date of another link which would      *
--*		have matching criteria for the same element.
--******************************************************************************
--
-- Parameters are:
--
	p_element_type_id 		number,
	p_element_link_id		number,
	p_validation_start_date 	date,
	p_validation_end_date		date,
	p_organization_id		number,
	p_people_group_id		number,
	p_job_id			number,
	p_position_id			number,
	p_grade_id			number,
	p_location_id 			number,
	p_link_to_all_payrolls_flag	varchar2,
	p_payroll_id			number,
        p_employment_category           varchar2,
        p_pay_basis_id                  number,
	p_business_group_id		number) return date;
--------------------------------------------------------------------------------
function ELEMENT_IN_DISTRIBUTION_SET (
--******************************************************************************
--* Returns TRUE if the element is in a distribution set
--******************************************************************************

	p_element_type_id		number,
	p_business_group_id		number,
	p_legislation_code		varchar2) return boolean;
--------------------------------------------------------------------------------
function ELEMENT_ENTRIES_EXIST (
--
--******************************************************************************
--* Returns TRUE if element entries already exist for this link		       *
--******************************************************************************
--
-- Parameters are:
--
	p_element_link_id	number,
	p_error_if_true		boolean	:= FALSE) return boolean ;
--------------------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (
--
--******************************************************************************
--* Returns TRUE if there exists more than one row with the same link ID       *
--******************************************************************************
--
-- Parameters are:
--
	p_element_link_id	number,
	p_rowid			varchar2) return boolean;
--------------------------------------------------------------------------------
procedure CHECK_DELETION_ALLOWED (
--
--******************************************************************************
--* Checks to see if link may be deleted.				       *
--******************************************************************************
--
-- Parameters:
--
	p_element_link_id	number,
	p_delete_mode		varchar2,
	p_validation_start_date	date	);
--------------------------------------------------------------------------------
procedure CHECK_RELATIONSHIPS (
--
--******************************************************************************
--* Returns values used by forms to set item properties. The calls within this *
--* procedure could be used separately, but bundling them here reduces network *
--* traffic.								       *
--******************************************************************************
--
-- Parameters are:
--
	p_element_link_id			number,
	p_rowid					varchar2,
	p_date_effectively_updated	out	nocopy boolean,
	p_element_entries_exist		out	nocopy boolean	) ;
--------------------------------------------------------------------------------
function PAY_BASIS_EXISTS (
--
--******************************************************************************
--* Returns TRUE if a pay basis exists for the element type.                   *
--******************************************************************************
--
-- Parameters are:
--
        p_element_type_id       number
       ,p_business_group_id     number) return boolean;
--------------------------------------------------------------------------------
end PAY_ELEMENT_LINKS_PKG;

/
