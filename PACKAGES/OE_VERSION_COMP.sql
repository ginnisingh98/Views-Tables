--------------------------------------------------------
--  DDL for Package OE_VERSION_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_VERSION_COMP" AUTHID CURRENT_USER AS
/* $Header: OEXSCOMS.pls 120.4.12010000.1 2008/07/25 07:54:15 appldev ship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_VERSION_COMP';

TYPE header_results_rec_type IS RECORD
(
header_id            NUMBER,
attribute_name  VARCHAR2(2000),
attribute_value VARCHAR2(2000),
current_id      VARCHAR2(2000),
current_value   VARCHAR2(2000),
prior_id        VARCHAR2(2000),
prior_value     VARCHAR2(2000),
next_id         VARCHAR2(2000),
next_value      VARCHAR2(2000)
);

TYPE line_results_rec_type IS RECORD
(
header_id          NUMBER,
line_id            NUMBER,
line_number        VARCHAR2(30),
attribute_value    VARCHAR2(2000),
attribute_name     VARCHAR2(2000),
current_id         VARCHAR2(2000),
current_value      VARCHAR2(2000),
prior_id           VARCHAR2(2000),
prior_value        VARCHAR2(2000),
next_id            VARCHAR2(2000),
next_value         VARCHAR2(2000)
);


TYPE header_tbl_type IS TABLE OF header_results_rec_type
INDEX BY BINARY_INTEGER;

TYPE header_sc_tbl_type IS TABLE OF header_results_rec_type
INDEX BY BINARY_INTEGER;

TYPE line_tbl_type IS TABLE OF line_results_rec_type
INDEX BY BINARY_INTEGER;

TYPE line_sc_tbl_type IS TABLE OF line_results_rec_type
INDEX BY BINARY_INTEGER;

PROCEDURE QUERY_HEADER_ROW
(p_header_id		NUMBER,
p_version		NUMBER,
p_phase_change_flag	VARCHAR2,
x_header_rec            IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type);

PROCEDURE QUERY_HEADER_TRANS_ROW
(p_header_id		NUMBER,
p_version		NUMBER,
x_header_rec            IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type);

PROCEDURE QUERY_HEADER_SC_ROW
(p_header_id		NUMBER,
p_sales_credit_id	NUMBER,
p_version		NUMBER,
p_phase_change_flag     VARCHAR2,
x_header_scredit_rec    IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type);

PROCEDURE QUERY_HEADER_SC_TRANS_ROW
(p_header_id		NUMBER,
p_sales_credit_id	NUMBER,
p_version		NUMBER,
x_header_scredit_rec    IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type);

PROCEDURE QUERY_LINE_ROW
(p_header_id		NUMBER,
p_line_id		NUMBER,
p_version		NUMBER,
p_phase_change_flag	VARCHAR2,
x_line_rec	        IN OUT NOCOPY OE_Order_Pub.line_rec_type);

PROCEDURE QUERY_LINE_TRANS_ROW
(p_header_id		NUMBER,
p_line_id		NUMBER,
p_version		NUMBER,
x_line_rec	        IN OUT NOCOPY OE_Order_Pub.line_rec_type);

PROCEDURE QUERY_LINE_SC_ROW
(p_header_id		NUMBER,
p_sales_credit_id	NUMBER,
p_version		NUMBER,
p_phase_change_flag	VARCHAR2,
x_line_scredit_rec      IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type);

PROCEDURE QUERY_LINE_SC_TRANS_ROW
(p_header_id		NUMBER,
p_sales_credit_id	NUMBER,
p_version		NUMBER,
x_line_scredit_rec      IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type);

PROCEDURE COMPARE_HEADER_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_header_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_COMP.header_tbl_type);

PROCEDURE COMPARE_HEADER_SC_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_header_sc_changed_attr_tbl     IN OUT NOCOPY OE_VERSION_COMP.header_sc_tbl_type);

PROCEDURE COMPARE_HEADER_SC_ATTRIBUTES
(p_header_id                      NUMBER,
 p_sales_credit_id                NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_header_sc_changed_attr_tbl     IN OUT NOCOPY OE_VERSION_COMP.header_sc_tbl_type,
 p_total_lines                    NUMBER);

PROCEDURE COMPARE_LINE_VERSIONS
(p_header_id	                  NUMBER,
 p_line_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_changed_attr_tbl          IN OUT NOCOPY OE_VERSION_COMP.line_tbl_type);

PROCEDURE COMPARE_LINE_ATTRIBUTES
(p_header_id                      NUMBER,
 p_line_id                        NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_changed_attr_tbl          IN OUT NOCOPY OE_VERSION_COMP.line_tbl_type,
 p_total_lines                    NUMBER,
 x_line_number                    VARCHAR2);

PROCEDURE COMPARE_LINE_SC_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_sc_changed_attr_tbl       IN OUT NOCOPY OE_VERSION_COMP.line_sc_tbl_type);

PROCEDURE COMPARE_LINE_SC_ATTRIBUTES
(p_header_id                      NUMBER,
 p_sales_credit_id                NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_sc_changed_attr_tbl       IN OUT NOCOPY OE_VERSION_COMP.line_sc_tbl_type,
 p_total_lines                    NUMBER,
 x_line_number                    VARCHAR2);

FUNCTION line_status
(   p_line_status_code            IN  VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Card_Equal
( p_instrument_id1    	IN NUMBER
, p_instrument_id2	IN NUMBER
, p_attribute_name      IN VARCHAR2
, p_is_card_history1	IN VARCHAR2
, p_is_card_history2	IN VARCHAR2
, x_is_equal		OUT NOCOPY VARCHAR2
, x_value1		OUT NOCOPY VARCHAR2
, x_value2		OUT NOCOPY VARCHAR2
);

--{added for bug 4302049
FUNCTION get_dff_seg_prompt(p_application_id               IN NUMBER,
		     p_descriptive_flexfield_name	IN VARCHAR2,
		     p_descriptive_flex_context_cod	IN VARCHAR2,
		     p_desc_flex_context_cod_prior	IN VARCHAR2,
		     p_desc_flex_context_cod_next	IN VARCHAR2,
		     p_application_column_name		IN VARCHAR2)
   RETURN VARCHAR2;
 --bug 4302049}

END OE_VERSION_COMP;

/
