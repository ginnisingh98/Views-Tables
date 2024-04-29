--------------------------------------------------------
--  DDL for Package INV_LOT_SEL_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_SEL_ATTR" AUTHID CURRENT_USER AS
/* $Header: INVLSDFS.pls 120.1.12010000.3 2009/04/10 09:25:05 gjyoti ship $ */

-- Record Type for the lot number attributes columns
TYPE lot_sel_attributes_rec_type IS RECORD
(
	COLUMN_NAME	VARCHAR2(50)	:=NULL
,	COLUMN_TYPE	VARCHAR2(20)	:=NULL
,	COLUMN_VALUE	fnd_descr_flex_col_usage_vl.default_value%TYPE :=NULL
,	REQUIRED	VARCHAR2(10)	:='NULL'
,	PROMPT	        VARCHAR2(100)	:=NULL
,	COLUMN_LENGTH	NUMBER          :=NULL
);

-- Table type definition for an array of cb_chart_status_rec_type records.
TYPE lot_sel_attributes_tbl_type is TABLE OF lot_sel_attributes_rec_type
  INDEX BY BINARY_INTEGER;

TYPE n_attribute_table_type IS TABLE OF mtl_lot_numbers.n_attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE d_attribute_table_type IS TABLE OF mtl_lot_numbers.d_attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE c_attribute_table_type IS TABLE OF mtl_lot_numbers.c_attribute1%TYPE INDEX BY BINARY_INTEGER;

TYPE t_genref IS REF CURSOR;

/*  procedure definition to fetch the attribute category
 * for a given item and organization */
PROCEDURE get_context_code(
 	context_value 	OUT NOCOPY VARCHAR2
,	org_id		IN NUMBER
,	item_id 	IN NUMBER
, 	flex_name 	IN VARCHAR2
,  p_lot_serial_number IN VARCHAR2);

PROCEDURE get_context_code(
	context_value 	OUT NOCOPY VARCHAR2
	, org_id	IN  NUMBER
	, item_id	IN  NUMBER
	, flex_name	IN  VARCHAR2);

/*-------------------------------------------------
* Check whether a descriptive flexfield has enabled(required)
  segements. The return value can be:
  0 - no enabled segments
  1 - has enabled segments but are not required
  2 - had enabled and required segments
  -------------------------------------------------*/
FUNCTION is_enabled(p_flex_name IN VARCHAR2,
                    p_organization_id IN NUMBER,
                    p_inventory_item_id IN NUMBER) RETURN NUMBER ;


/*----------------------------------------------------
* Check Whether the DFF has any required Context or Global Segment
  1 - Has required Context or Global Data segment
  0 - Otherwise
  ----------------------------------------------------*/

FUNCTION is_dff_required(p_flex_name IN VARCHAR2,
                         p_application_short_name IN VARCHAR2,
                         p_organization_id IN NUMBER,
                         p_inventory_item_id IN NUMBER) RETURN NUMBER;


/*--------------------------------------------------------------
* Returns 1 if the context_override_flag is set, 0 otherwise
--------------------------------------------------------------*/

FUNCTION is_context_displayed(p_flex_name IN VARCHAR2,
                              p_application_short_name IN VARCHAR2) RETURN NUMBER;


/*-------------------------------------------------
* Returns the delimiter for the given flex field
  -------------------------------------------------*/

FUNCTION get_delimiter(p_flex_name IN VARCHAR2,
                       p_application_short_name IN VARCHAR2) RETURN VARCHAR2;


/*-------------------------------------------------
* Check whether a segment of a descriptive flexfield is enabled(required)
  The return value can be:
  0 - no enabled segment
  1 - enabled segment
  2 - enabled and required segment
  -------------------------------------------------*/
FUNCTION is_enabled_segment(p_flex_name IN VARCHAR2,
                            p_segment_name IN VARCHAR2,
                            p_organization_id IN NUMBER,
                            p_inventory_item_id IN NUMBER) RETURN NUMBER ;

-- procedure definition for get lot number attributes defaults
PROCEDURE get_default(
	x_attributes_default		OUT  NOCOPY lot_sel_attributes_tbl_type
,	x_attributes_default_count	OUT NOCOPY	NUMBER
,	x_return_status	        	OUT NOCOPY  VARCHAR2
, 	x_msg_count	       		OUT NOCOPY  NUMBER
, 	x_msg_data     	        	OUT  NOCOPY VARCHAR2
,	p_table_name			IN	VARCHAR2
,	p_attributes_name		IN	VARCHAR2
,	p_inventory_item_id		IN	NUMBER
,	p_organization_id		IN	NUMBER
,	p_lot_serial_number		IN	VARCHAR2
,	p_attributes			IN	lot_sel_attributes_tbl_type);

/*Bug 2756040: Added extra IN parameter p_issue_receipt at the end to determine
if the transaction is of type issue or receipt. This has a default value
of NULL */
/*Bug 4328865: Replaced the default value of IN parameter p_issue_receipt with '@@@' */
PROCEDURE get_attribute_values
(       x_lot_serial_attributes		 OUT NOCOPY lot_sel_attributes_tbl_type
, 	x_lot_serial_attributes_count	 OUT NOCOPY NUMBER
,	x_return_status			 OUT NOCOPY VARCHAR2
,	x_msg_count			 OUT NOCOPY NUMBER
,	x_msg_data			 OUT NOCOPY VARCHAR2
,	p_table_name			 IN  VARCHAR2
,	p_attributes_name		 IN  VARCHAR2
,	p_inventory_item_id		 IN  NUMBER
,	p_organization_id		 IN  NUMBER
,	p_lot_serial_number		 IN  VARCHAR2
,	p_issue_receipt			 IN  VARCHAR2 DEFAULT '@@@');


/* New Procedure to get the Inventory Attributes */

procedure get_inv_lot_attributes( x_return_status	 OUT NOCOPY VARCHAR2
				,x_msg_count		 OUT NOCOPY NUMBER
				,x_msg_data		 OUT NOCOPY VARCHAR2
				,x_inv_lot_attributes	 OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
				,P_inventory_item_id	 IN  NUMBER
				,P_LOT_NUMBER		 IN  VARCHAR2
				,p_organization_id	 IN  NUMBER
				,p_attribute_category	 IN VARCHAR2 );

/* ----------------------------------------------------------
 * Procedure to fetch descriptive flexfield context category
 * from MSN for a given item and organization.
 * Currently, made changes only for fetching from MSN.
 * Need to add code to fetch from MLN if the flex_name
 * is Lot Attributes --Added for 2756040
 *----------------------------------------------------------*/

PROCEDURE get_lot_serial_context(context_value 	OUT NOCOPY VARCHAR2,
		org_id		IN NUMBER,
		item_id     	IN NUMBER,
		p_lot_serial	IN VARCHAR2,
		flex_name 	IN VARCHAR2);

 PROCEDURE get_dflex_context(
	x_context 		OUT NOCOPY t_genref,
	p_application_id	IN NUMBER,
	p_flex_name		IN VARCHAR2);

 PROCEDURE get_dflex_segment(
	x_segment		OUT NOCOPY t_genref,
	p_application_id	IN NUMBER,
	p_flex_name		IN VARCHAR2,
	p_flex_context_code	IN VARCHAR2);


procedure get_inv_serial_attributes( x_return_status	 OUT NOCOPY VARCHAR2
				,x_msg_count		 OUT NOCOPY NUMBER
				,x_msg_data		 OUT NOCOPY VARCHAR2
				,x_inv_serial_attributes OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
				,x_concatenated_values	 OUT NOCOPY VARCHAR2
				,P_inventory_item_id	 IN  NUMBER
				,P_Serial_Number	 IN  VARCHAR2
				,p_attribute_category	 IN VARCHAR2
				,p_transaction_temp_id   IN  NUMBER DEFAULT NULL
				,p_transaction_source	 IN  VARCHAR2  DEFAULT NULL);

 --  Bug 7249316
 FUNCTION is_lot_attributes_required( p_flex_name IN VARCHAR2,
                                  p_organization_id IN NUMBER,
                                  p_inventory_item_id IN NUMBER,
                                  p_lot_number IN VARCHAR2)  RETURN BOOLEAN;

/* Added for bug 7632531 */

 FUNCTION lock_lot_records( p_org_id                IN  NUMBER
                            , p_inventory_item_id   IN  NUMBER
                            , p_lot_uniqueness      IN  NUMBER DEFAULT NULL
                            , p_lot_generation      IN  NUMBER DEFAULT NULL
                            , p_lot_prefix          IN  VARCHAR2
                            , x_return_status       OUT NOCOPY  VARCHAR2
                          ) RETURN BOOLEAN;

/* End of changes for bug 7632531 */

END INV_LOT_SEL_ATTR;

/
