--------------------------------------------------------
--  DDL for Package PO_COMPARE_REVISIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COMPARE_REVISIONS" AUTHID CURRENT_USER AS
/* $Header: POXPOCMS.pls 115.4 2002/11/23 02:49:36 sbull ship $ */

PROCEDURE purge ( errbuf OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER,
	p_date IN VARCHAR2);

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
	p_changes_to IN VARCHAR2
	);

PROCEDURE verify_no_differences( p_line_seq IN NUMBER );

PROCEDURE compare_headers(
	p_po_from IN po_headers_archive%ROWTYPE,
	p_po_to IN po_headers_archive%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_releases(
	p_release_from IN po_releases_archive%ROWTYPE,
	p_release_to IN po_releases_archive%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_lines(
	p_line_from IN po_lines_archive%ROWTYPE,
	p_line_to IN po_lines_archive%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_locations(
	p_loc_from IN po_line_locations_archive%ROWTYPE,
	p_loc_to IN po_line_locations_archive%ROWTYPE,
	p_sequence IN NUMBER
	);

PROCEDURE compare_distributions(
	p_dist_from IN po_distributions_archive%ROWTYPE,
	p_dist_to IN po_distributions_archive%ROWTYPE,
	p_sequence IN NUMBER
	);

/*Bug 1181007
  A new function added to fetch the charge account with the ccid from
  the table gl_code_combinations_kfv
*/
FUNCTION get_charge_account (p_code_combination_id IN NUMBER)
        RETURN VARCHAR2;

END po_compare_revisions;

 

/
