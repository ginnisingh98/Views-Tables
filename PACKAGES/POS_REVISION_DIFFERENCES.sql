--------------------------------------------------------
--  DDL for Package POS_REVISION_DIFFERENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_REVISION_DIFFERENCES" AUTHID CURRENT_USER AS
/* $Header: POSPORVS.pls 115.4 2003/12/10 06:18:33 ammitra ship $ */

/* Compare the entire PO */
PROCEDURE compare_po_to_all(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	);

PROCEDURE compare_po_to_original(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	);

PROCEDURE compare_po_to_previous(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	);

PROCEDURE compare_po(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num OUT NOCOPY NUMBER
	);

/* Compare PO header with a previous revision */
PROCEDURE compare_headers(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER ,
	p_comparison_flag_org IN VARCHAR2);

PROCEDURE compare_ga_assignments(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	);

PROCEDURE compare_pdiffs_line(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) ;

PROCEDURE compare_pdiffs_ship(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER
	) ;

/* Compare all lines for a PO */
PROCEDURE compare_lines(
	p_header_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER );

/* Compare all locations for a PO */
PROCEDURE compare_locations(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER );

/* Compare all distributions for a PO */
PROCEDURE compare_distributions(
	p_header_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER );

/* Compare one line in a PO and all its sub-components */
PROCEDURE compare_line_to_all(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	);

PROCEDURE compare_line_to_original(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	);

PROCEDURE compare_line_to_previous(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_dummy_in4 IN NUMBER DEFAULT NULL,
	p_dummy_in5 IN NUMBER DEFAULT NULL,
	p_dummy_in6 IN NUMBER DEFAULT NULL,
	p_dummy_in7 IN NUMBER DEFAULT NULL,
	p_dummy_in8 IN NUMBER DEFAULT NULL,
	p_dummy_in9 IN NUMBER DEFAULT NULL,
	p_dummy_in10 IN NUMBER DEFAULT NULL,
	p_sequence_num OUT NOCOPY NUMBER,
	p_dummy_out2 OUT NOCOPY NUMBER,
	p_dummy_out3 OUT NOCOPY NUMBER,
	p_dummy_out4 OUT NOCOPY NUMBER,
	p_dummy_out5 OUT NOCOPY NUMBER,
	p_dummy_out6 OUT NOCOPY NUMBER,
	p_dummy_out7 OUT NOCOPY NUMBER,
	p_dummy_out8 OUT NOCOPY NUMBER,
	p_dummy_out9 OUT NOCOPY NUMBER,
	p_dummy_out10 OUT NOCOPY NUMBER
	);

PROCEDURE compare_po_line(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num OUT NOCOPY NUMBER
	);



/* Compare a line in a PO with a previous revision */
PROCEDURE compare_line(
	p_line_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER );

/* Compare all locations for a PO line */
PROCEDURE compare_line_locs(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER );

/* Compare all distributions for a PO line */
PROCEDURE compare_line_dists(
	p_line_id IN NUMBER,
	p_release_id IN NUMBER,
	p_revision_num IN NUMBER,
	p_comparison_flag IN VARCHAR2,
	p_sequence_num IN NUMBER );

END pos_revision_differences;

 

/
