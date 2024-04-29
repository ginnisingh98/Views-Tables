--------------------------------------------------------
--  DDL for Package POS_COMPARE_REVISIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_COMPARE_REVISIONS" AUTHID CURRENT_USER AS
/* $Header: POSPOCMS.pls 120.5 2006/05/10 15:04:18 abtrived noship $ */

PROCEDURE purge ( errbuf OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER,
	p_date IN DATE DEFAULT SYSDATE - 1/12 );

FUNCTION get_un_number ( p_un_number_id IN NUMBER )
	RETURN VARCHAR2;

FUNCTION get_item_number (p_item_id IN NUMBER)
	RETURN VARCHAR2;

FUNCTION get_hazard_class ( p_hazard_class_id IN NUMBER )
	RETURN VARCHAR2;

FUNCTION get_ap_terms ( p_term_id IN NUMBER )
	RETURN VARCHAR2;

FUNCTION get_buyer ( p_agent_id IN NUMBER )
	RETURN VARCHAR2;

FUNCTION get_vendor_contact ( p_vendor_contact_id IN NUMBER )
	RETURN VARCHAR2;

FUNCTION get_location ( p_location_id IN number )
	RETURN VARCHAR2;

FUNCTION get_source_quotation_header ( p_header_id IN NUMBER )
	RETURN VARCHAR2;

FUNCTION get_source_quotation_line ( p_line_id IN NUMBER )
	RETURN VARCHAR2;

FUNCTION get_po_lookup (
	p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2 )
	RETURN VARCHAR2;

PROCEDURE insert_changes (
	p_line_seq IN NUMBER,
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_line_id IN NUMBER,
	p_location_id IN NUMBER,
	p_distribution_id IN NUMBER,
	p_item_id IN NUMBER,
	p_po_num IN VARCHAR2,
	p_revision_num IN NUMBER,
	p_line_num IN NUMBER,
	p_location_num IN NUMBER,
	p_distribution_num IN NUMBER,
	p_level_altered IN VARCHAR2,
	p_field_altered IN VARCHAR2,
	p_changes_from IN VARCHAR2,
	p_changes_to IN VARCHAR2,
	p_enabled_org_name in VARCHAR2 default null,
	p_price_diff_num in NUMBER default null,
	p_change_from_date in DATE default null,
	p_change_to_date IN DATE DEFAULT NULL,
	p_item in varchar2 default null,
	p_job in varchar2 default null
	);


PROCEDURE verify_no_differences( p_line_seq IN NUMBER );

PROCEDURE compare_headers(
	p_po_from IN po_headers_archive_all%ROWTYPE,
	p_po_to IN po_headers_archive_all%ROWTYPE,
	p_sequence IN NUMBER,
        p_comparison_flag IN VARCHAR2
	);

PROCEDURE compare_releases(
	p_release_from IN po_releases_archive_all%ROWTYPE,
	p_release_to IN po_releases_archive_all%ROWTYPE,
	p_sequence IN NUMBER
	);
PROCEDURE compare_ga_assignments(
	p_ga_ass_from in po_ga_org_assignments_archive%ROWTYPE,
	p_ga_ass_to in po_ga_org_assignments_archive%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_price_diffs(
	p_pdiffs_from in po_price_differentials_archive%ROWTYPE,
	p_pdiffs_to in po_price_differentials_archive%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_lines(
	p_line_from IN po_lines_archive_all%ROWTYPE,
	p_line_to IN po_lines_archive_all%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_locations(
	p_loc_from IN po_line_locations_archive_all%ROWTYPE,
	p_loc_to IN po_line_locations_archive_all%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_distributions(
	p_dist_from IN po_distributions_archive_all%ROWTYPE,
	p_dist_to IN po_distributions_archive_all%ROWTYPE,
	p_sequence IN NUMBER
	);

/*Bug 1181007
  A new function added to fetch the charge account with the ccid from
  the table gl_code_combinations_kfv
*/
FUNCTION get_charge_account (p_code_combination_id IN NUMBER)
        RETURN VARCHAR2;

/* bug 4261155
   Adding a new function to get requestor name from per_people_f
*/
FUNCTION get_requestor ( p_agent_id IN NUMBER )
 	RETURN VARCHAR2;

/* bug 5215207
   Adding a new function to get owner for a work confirmation
*/
FUNCTION get_owner ( p_work_approver_id IN NUMBER )
 	RETURN VARCHAR2;

/*
bug 5106221
*/
FUNCTION get_shopping_category( p_category_id IN NUMBER )
	RETURN VARCHAR2;

/* Bug 4347578
*/
FUNCTION get_nextval
	RETURN NUMBER;

FUNCTION get_job ( p_job_id IN NUMBER )
 	RETURN VARCHAR2;

FUNCTION get_item ( p_item_id IN NUMBER, p_org_id IN NUMBER )
 	RETURN VARCHAR2;

FUNCTION Get_Line_adv_Amount_revision(
	p_po_line_id IN NUMBER, p_revision_num IN NUMBER)
	RETURN NUMBER;

FUNCTION Get_ship_val_percent_revision (
	p_po_line_location_id IN NUMBER, p_revision_num IN NUMBER)
	RETURN NUMBER;

END pos_compare_revisions;

 

/
