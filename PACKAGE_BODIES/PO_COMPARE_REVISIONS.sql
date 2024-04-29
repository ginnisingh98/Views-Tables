--------------------------------------------------------
--  DDL for Package Body PO_COMPARE_REVISIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COMPARE_REVISIONS" AS
/* $Header: POXPOCMB.pls 120.0.12010000.3 2010/11/29 06:17:22 lswamina ship $ */

/*********************************************************************
 * NAME
 * purge
 *
 * PURPOSE
 * Delete records from the temp table, ICX_PO_REVISIONS_TEMP, where
 * all the records for differences are stored.
 *
 * ARGUMENTS
 * p_date	Purges all records that are older than this date.  The
 *		date defaults to two hours back from the current date.
 *
 * NOTES
 * You need to set-up a concurrent program in Oracle Applications to
 * call this program in a specific frequency.
 *
 * HISTORY
 * 10-SEP-97	Rami Haddad	Created
 * 20-OCT-97	Winston Lang	Added errbuf and retcode parameters.
 ********************************************************************/
PROCEDURE purge(
	errbuf OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER,
	p_date IN VARCHAR2
	) AS
v_progress	VARCHAR2(3);

BEGIN

retcode := 0;
errbuf := '';

v_progress := '010';

DELETE	icx_po_revisions_temp
WHERE creation_date < NVL( to_date(p_date, 'YYYY/MM/DD HH24:MI:SS'),SYSDATE - 1/12 );

COMMIT;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.PURGE',
		v_progress,
		sqlcode );
	RAISE;

END purge;



/*********************************************************************
 * NAME
 * get_un_number
 *
 * PURPOSE
 * Resolves the UN number.
 *
 * ARGUMENTS
 * p_un_number_id	Unique identifier for UN number in
 *			PO_UN_NUMBERS table.
 *
 * NOTES
 * Return NULL if an error occurs.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Return NULL if no values found.
 ********************************************************************/
FUNCTION get_un_number( p_un_number_id IN NUMBER )
	RETURN VARCHAR2 AS

v_un_number	po_un_numbers.un_number%TYPE;
v_progress	VARCHAR2(3);

BEGIN

v_progress := '020';

SELECT	un_number
INTO	v_un_number
FROM	po_un_numbers
WHERE	un_number_id = p_un_number_id;

RETURN v_un_number;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_UN_NUMBER',
		v_progress,
		sqlcode );
	RAISE;

END get_un_number;



/*********************************************************************
 * NAME
 * get_item_number
 *
 * PURPOSE
 * Resolves the item number.
 *
 * ARGUMENTS
 * p_item_id	Unique identifier for item number in
 *		MTL_SYSTEM_ITEMS_KFV view.
 *
 * NOTES
 * Return NULL if an error occurs.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Return NULL if no values found.
 *				Obtain item number by calling
 *				ICX_UTIL.ITEM_FLEX_SEG function.
 ********************************************************************/
FUNCTION get_item_number(p_item_id IN NUMBER)
	RETURN VARCHAR2 AS

v_item_num	varchar2( 4000 );
v_progress	varchar2(3);

BEGIN

v_progress := '030';

SELECT	icx_util.item_flex_seg( msi.rowid )
INTO	v_item_num
FROM
	mtl_system_items msi,
	financials_system_parameters fsp
WHERE
	p_item_id = msi.inventory_item_id (+)
AND	fsp.inventory_organization_id = NVL(
		msi.organization_id,
		fsp.inventory_organization_id );

RETURN v_item_num;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_ITEM_NUMBER',
		v_progress,
		sqlcode );
	RAISE;

END get_item_number;



/*********************************************************************
 * NAME
 * get_hazard_class
 *
 * PURPOSE
 * Resolves the hazard class.
 *
 * ARGUMENTS
 * p_hazard_class_id	Unique identifier for hazard class in
 *			PO_HAZARD_CLASSES table.
 *
 * NOTES
 * Return NULL if an error occurs.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Return NULL if no values found.
 ********************************************************************/
FUNCTION get_hazard_class( p_hazard_class_id IN NUMBER )
	RETURN VARCHAR2 AS

v_hazard_class	po_hazard_classes.hazard_class%TYPE;
v_progress	varchar2(3);

BEGIN

v_progress := '040';

SELECT	hazard_class
INTO	v_hazard_class
FROM	po_hazard_classes
WHERE	hazard_class_id = p_hazard_class_id;

RETURN v_hazard_class;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_HAZARD_CLASS',
		v_progress,
		sqlcode );
	RAISE;

END get_hazard_class;



/*********************************************************************
 * NAME
 * get_ap_terms
 *
 * PURPOSE
 * Resolves the payment terms.
 *
 * ARGUMENTS
 * p_term_id	Unique identifier for hazard class in
 *		PO_HAZARD_CLASSES table.
 *
 * NOTES
 * Return NULL if no matching records were found.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Return NULL if no values found.
 ********************************************************************/
FUNCTION get_ap_terms( p_term_id IN NUMBER )
	RETURN VARCHAR2 AS

v_ap_terms	ap_terms.description%TYPE;
v_progress	varchar2(3);

BEGIN

v_progress := '060';

SELECT	description
INTO	v_ap_terms
FROM	ap_terms
WHERE	term_id = p_term_id;

RETURN v_ap_terms;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_AP_TERMS',
		v_progress,
		sqlcode );
	RAISE;

END get_ap_terms;



/*********************************************************************
 * NAME
 * get_buyer
 *
 * PURPOSE
 * Resolves the buyer name.
 *
 * ARGUMENTS
 * p_agent_id	Unique identifier for buyer in PER_PEOPLE_F table.
 *
 * NOTES
 * Return NULL if no matching records were found.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Return NULL if no values found.
 ********************************************************************/
FUNCTION get_buyer( p_agent_id IN NUMBER )
	RETURN VARCHAR2 AS

v_full_name	per_people_f.full_name%TYPE;
v_progress	varchar2(3);

BEGIN

v_progress := '070';

--Bug 1915684  Added distinct to retrieve name of buyer
--             to avoid multiple rows
-- Bug 2111528 Added condition to get buyers with current effective
-- date
SELECT	distinct full_name
INTO	v_full_name
FROM	per_people_f
WHERE	person_id = p_agent_id
and  TRUNC(SYSDATE) BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE ;

RETURN v_full_name;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_BUYER',
		v_progress,
		sqlcode );
	RAISE;

END get_buyer;



/*********************************************************************
 * NAME
 * get_vendor_contact
 *
 * PURPOSE
 * Resolves the supplier contact.
 *
 * ARGUMENTS
 * p_vendor_contact_id	Unique identifier for vendor in
 *			PO_VENDOR_CONTACTS table.
 *
 * NOTES
 * Return NULL if no matching records were found.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Return NULL if no values found.
 *				Obtain name from PO_VENDOR_CONTACTS
 *				table.
 ********************************************************************/
FUNCTION get_vendor_contact( p_vendor_contact_id IN NUMBER )
	RETURN VARCHAR2 AS

v_full_name	varchar2( 40 );
v_progress	varchar2(3);

BEGIN

v_progress := '080';

--bug10314122 More than one row ll be returned by this query if vendor site condition is not used.
--We need not join with vendor_site_id because first_name and last_name are the same for one contact id.

SELECT	DECODE(last_name, NULL, NULL, last_name || ',' || first_name)
INTO	v_full_name
FROM	po_vendor_contacts
WHERE	vendor_contact_id = p_vendor_contact_id
  AND   ROWNUM = 1;

RETURN v_full_name;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_VENDOR_CONTACT',
		v_progress,
		sqlcode );
	RAISE;

END get_vendor_contact;



/*********************************************************************
 * NAME
 * get_location
 *
 * PURPOSE
 * Resolves the location code
 *
 * ARGUMENTS
 * p_location_id	Unique identifier for the location in
 *			HR_LOCATIONS table.
 *
 * NOTES
 * Return NULL if no matching records were found.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Return NULL if no values found.
 ********************************************************************/
FUNCTION get_location( p_location_id IN NUMBER )
	RETURN VARCHAR2 AS

v_location_code	hr_locations.location_code%TYPE;
v_progress	varchar2(3);

BEGIN

v_progress := '090';

SELECT	location_code
INTO	v_location_code
FROM	hr_locations
WHERE	location_id = p_location_id;

RETURN v_location_code;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;

WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_LOCATION',
		v_progress,
		sqlcode );
	RAISE;

END get_location;



/*********************************************************************
 * NAME
 * get_source_quotation_header
 *
 * PURPOSE
 * Resolves the source quotation PO number.
 *
 * ARGUMENTS
 * p_header_id	Unique identifier for PO in PO_HEADERS table.
 *
 * NOTES
 * Return NULL if no matching records were found.
 *
 * HISTORY
 * 23-SEP-97	Rami Haddad	Created
 ********************************************************************/
FUNCTION get_source_quotation_header( p_header_id in number )
	RETURN VARCHAR2 AS

v_po_num	po_headers.segment1%TYPE;
v_progress	varchar2(3);

BEGIN

v_progress := '100';

SELECT	segment1
INTO	v_po_num
FROM	po_headers
WHERE	po_header_id = p_header_id;

RETURN	v_po_num;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_SOURCE_QUOTATION_HEADER',
		v_progress,
		sqlcode );
	RAISE;

END get_source_quotation_header;



/*********************************************************************
 * NAME
 * get_source_quotation_line
 *
 * PURPOSE
 * Resolves the source quotation PO line number.
 *
 * ARGUMENTS
 * p_line_id	Unique identifier for PO line in PO_LINES table.
 *
 * NOTES
 * Return NULL if no matching records were found.
 *
 * HISTORY
 * 23-SEP-97	Rami Haddad	Created
 ********************************************************************/
FUNCTION get_source_quotation_line( p_line_id in number )
	RETURN VARCHAR2 AS

v_line_num	po_lines.line_num%TYPE;
v_progress	varchar2(3);

BEGIN

v_progress := '110';

SELECT	line_num
INTO	v_line_num
FROM	po_lines
WHERE	po_line_id = p_line_id;

RETURN	v_line_num;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_SOURCE_QUOTATION_LINE',
		v_progress,
	 	sqlcode );
	RAISE;

END get_source_quotation_line;



/*********************************************************************
 * NAME
 * get_po_lookup
 *
 * PURPOSE
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 *
 * HISTORY
 * 31-OCT-97	Rami Haddad	Created
 ********************************************************************/
FUNCTION get_po_lookup(
	p_lookup_type IN VARCHAR2,
	p_lookup_code IN VARCHAR2
	) RETURN VARCHAR2 AS

v_description	po_lookup_codes.description%TYPE;
v_progress	varchar2(3);

BEGIN

v_progress := '120';

SELECT	description
INTO	v_description
FROM	po_lookup_codes
WHERE
	lookup_type = p_lookup_type
AND	lookup_code = p_lookup_code;

RETURN	v_description;

EXCEPTION
WHEN no_data_found THEN
	RETURN NULL;
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.GET_PO_LOOKUP',
		v_progress,
		sqlcode );
	RAISE;

END get_po_lookup;

/*********************************************************************
 * NAME
 * get_vendor_site
 *
 * PURPOSE
 * Resolves the vendor site
 *
 * ARGUMENTS
 * p_vendor_site_id     Unique identifier for the location in
 *                      PO_VENDOR_SITES table.
 *
 * NOTES
 * Return NULL if no matching records were found.
 *
 * HISTORY
 * 09-AUG-01    Amitabh Mitra created
 ********************************************************************/
FUNCTION get_vendor_site( p_vendor_site_id IN NUMBER )
        RETURN VARCHAR2 AS

v_site_code     varchar2(20);
v_progress      varchar2(3);

BEGIN

v_progress := '140';

SELECT  vendor_site_code
INTO    v_site_code
FROM    po_vendor_sites_all
WHERE   vendor_site_id = p_vendor_site_id;

RETURN v_site_code;

EXCEPTION
WHEN no_data_found THEN
        RETURN NULL;

WHEN others THEN
        PO_MESSAGE_S.SQL_ERROR(
                'PO_COMPARE_REVISIONS.GET_VENDOR_SITE',
                v_progress,
                sqlcode );
        RAISE;

END get_vendor_site;


/*********************************************************************
 * NAME
 * insert_changes
 *
 * PURPOSE
 * Insert the comparison result into the temp table.
 *
 * ARGUMENTS
 * p_line_seq		Sequence number to identify the comparison
 *			results for a specific record.
 * p_header_id		Unique identifier for PO.
 * p_release_id		Unique identifier for PO release.
 * p_line_id		Unique identifier for PO line.
 * p_location_id	Unique identifier for PO line location.
 * p_distribution_id	Unique identifier for PO distribution.
 * p_item_id		Unique identified for line item.
 * p_po_num		PO number.
 * p_line_num		PO line number.
 * p_location_num	PO line location number.
 * p_distribution_num	PO distribution number.
 * p_level_altered	Level altered.  Possible values are:
 *
 *	Code			User-friendly name
 *	----			------------------
 *	ICX_DISTRIBUTION	Distribution
 *	ICX_HEADER		Header
 *	ICX_LINE		Line
 *	ICX_SHIPMENT		Shipment
 *
 * p_field_altered	Field altered.  Possible values are:
 *
 *	Code			User-friendly name
 *	----			------------------
 *	ICX_ACCEPTANCE_DUE_DATE	Acceptance Due Date
 *	ICX_ACCEPTANCE_REQUIRED	Acceptance Required
 *	ICX_AMOUNT		Amount
 *	ICX_AMOUNT_AGREED	Amount Agreed
 *	ICX_AMOUNT_DUE_DATE	Amount Due Date
 *	ICX_AMOUNT_LIMIT	Amount Limit
 *	ICX_BILL_TO		Bill To
 *	ICX_BUYER		Buyer
 *	ICX_CANCELLED		Cancelled
 *	ICX_CHARGE_ACCT		Charge Account
 *	ICX_CLOSED_CODE		Closed
 *	ICX_CONFIRMED		Confirm
 *	ICX_CONTRACT_NUMBER	Contract Number
 *	ICX_EFFECTIVE_DATE	Effective Date
 *	ICX_ERROR		Error
 *	ICX_EXPIRATION_DATE	Expiration Date
 *	ICX_FOB			FOB
 *	ICX_FREIGHT_TERMS	Freight Terms
 *	ICX_HAZARD_CLASS	Hazard Class
 *	ICX_ITEM		Item
 *	ICX_ITEM_DESCRIPTION	Item Description
 *	ICX_ITEM_REVISION	Item Revision
 *	ICX_LAST_ACCEPT_DATE	Last Acceptance Date
 *	ICX_LINE_NUMBER		Line Number
 *	ICX_NEED_BY_DATE	Need By Date
 *	ICX_NEW			New
 *	ICX_NOTE_TO_VENDOR	Note To Vendor
 *	ICX_PAYMENT_TERMS	Payment Terms
 *	ICX_PRICE_BREAK		Price Break
 *	ICX_PRICE_TYPE		Price Type
 *	ICX_PROMISED_DATE	Promised Date
 *	ICX_QUANTITY		Quantity
 *	ICX_QUANTITY_AGREED	Quantity Agreed
 *	ICX_RELEASE_DATE	Released Date
 *	ICX_RELEASE_NUMBER	Release Number
 *	ICX_REQUESTOR		Requestor
 *	ICX_SHIP_NUM		Shipment Number
 *	ICX_SHIP_TO		Ship To
 *	ICX_SHIP_VIA		Ship Via
 *	ICX_SOURCE_QT_HEADER	Source Quotation Header
 *	ICX_SOURCE_QT_LINE	Source Quotation Line
 *	ICX_SUPPLIER_CONTACT	Supplier Contact
 *	ICX_SUPPLIER_ITEM_NUM	Supplier Item Number
 *	ICX_TAXABLE_FLAG	Taxable
 *	ICX_UNIT_PRICE		Unit Price
 *	ICX_UN_NUMBER		UN Number
 *	ICX_UOM			UOM
 *
 * p_changes_from	Previous value of field altered.
 * p_changes_to		New value of field altered.
 *
 * NOTES
 * Stamps every line with the current system date.  Use that value
 * when purging the table, to remove 2-hours old records for example.
 *
 * Replace IDs that are NULL with -99, to do the sorting correctly.
 * When sorting in an ascending order, NULL values are at the last,
 * while, to sort these records correctly, they should be the first.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created
 * 22-SEP-97	Rami Haddad	Removed prompts look-up in AK.
 *				Replace NULL with -99 for sorting.
 ********************************************************************/
PROCEDURE insert_changes(
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
	) AS

v_progress	VARCHAR2(3);

BEGIN

v_progress := '900';

INSERT INTO
	icx_po_revisions_temp(
	line_seq,
	creation_date,
	header_id,
	release_id,
	line_id,
	location_id,
	distribution_id,
	item_id,
	po_num,
	revision_num,
	line_num,
	location_num,
	distribution_num,
	level_altered,
	field_altered,
	changes_from,
	changes_to
	)
VALUES
	(
	p_line_seq,
	SYSDATE,
	p_header_id,
	p_release_id,
	p_line_id,
	p_location_id,
	p_distribution_id,
	p_item_id,
	p_po_num,
	p_revision_num,
	p_line_num,
	p_location_num,
	p_distribution_num,
	p_level_altered,
	p_field_altered,
	p_changes_from,
	p_changes_to
	);

COMMIT;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.INSERT_CHANGES',
		v_progress,
		sqlcode );
	RAISE;

END insert_changes;



/*********************************************************************
 * NAME
 * verify_no_differences
 *
 * PURPOSE
 * Insert a line in the ICX_PO_REVISIONS_TEMP table indicating that
 * there are no differences between the compared records.
 *
 * ARGUMENTS
 * p_line_seq		Sequence number to identify the comparison
 *			results for a specific record.
 *
 * NOTES
 * Refer to bug#549414 for more details.
 *
 * This is used specifically to handle AK functionality.  AK is
 * expecting a row in table with the PK.  The initial table in this
 * case is actually a procedure, so AK fails.  The procedure checks.
 * If there are no differences, insert a dummy row in the table that
 * say something like 'No differences.'
 *
 * HISTORY
 * 31-OCT-97	Rami Haddad	Created
 ********************************************************************/
PROCEDURE verify_no_differences( p_line_seq IN NUMBER ) AS

records_exist	number;
v_progress	varchar2(3);

BEGIN

v_progress := '130';

SELECT	COUNT(*)
INTO	records_exist
FROM	icx_po_revisions_temp
WHERE	line_seq = p_line_seq;

IF records_exist = 0 THEN
	insert_changes(
		p_line_seq,
		-99,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		0,	-- -99
		NULL,
		NULL,
		NULL,
		'ICX_HEADER',
		--fnd_message.get_String('PO', 'POS_NO_DIFFERENCE'),
                'ICX_NO_DIFFERENCE',
		NULL,
		NULL
		);
END IF;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.VERIFY_NO_DIFFERENCES',
		v_progress,
		sqlcode );
	RAISE;

END verify_no_differences;



/*********************************************************************
 * NAME
 * compare_headers
 *
 * PURPOSE
 * Accepts two records of the same PO with different revisions,
 * compare the data in both POs, and stores the differences in a
 * temporary table.
 *
 * ARGUMENTS
 * p_po_from	Old version of the PO.
 * p_po_to	New version of the PO.
 * p_sequence	Sequence number to use in the temp table to identify
 *		the records for delta.
 *
 * NOTES
 * The comparison is not done on all fields, but only the ones than
 * cause a revision change, according to Oracle Purchasing Reference
 * Manual.
 *
 * The fields that can be changed on PO header, and cause a revision
 * number increase are:
 *
 *	Cancel Flag
 *	Buyer
 *	Vendor contact
 *	Confirming flag
 *	Ship-to location
 *	Bill-to location
 *	Payment terms
 *	Amount
 *	Ship via
 *	FOB
 *	Freignt terms
 *	Note to vendor
 *	Acceptance required
 *	Acceptance due date
 *	Amount Limit
 *	Start Date
 *	End Date
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created.
 * 22-SEP-97	Rami Haddad	Added buyer comparison.
 ********************************************************************/
PROCEDURE compare_headers(
	p_po_from in po_headers_archive%ROWTYPE,
	p_po_to in po_headers_archive%ROWTYPE,
	p_sequence in number
	) AS

/*
 * Constant variables to pass for insert_changes
 */
c_level_altered		icx_po_revisions_temp.level_altered%TYPE
			:= 'ICX_HEADER';
c_po_header_id		NUMBER;
c_po_num		po_headers_archive.segment1%TYPE;
c_revision_num		NUMBER;
c_release_id		NUMBER := NULL;
c_line_id		NUMBER := NULL;
c_line_num		NUMBER := NULL;
c_location_id		NUMBER := NULL;
c_location_num		NUMBER := NULL;
c_distribution_id	NUMBER := NULL;
c_distribution_num	NUMBER := NULL;
c_item_id		NUMBER := NULL;

v_amount_from		NUMBER;
v_amount_to		NUMBER;
v_progress		VARCHAR2(3);

BEGIN

/*
 * At least the latest revision should exist.
 */
IF p_po_to.po_header_id IS NULL THEN
	RETURN;
END IF;

/*
 * Set values for all constants
 */
c_po_header_id		:= p_po_to.po_header_id;
c_po_num		:= p_po_to.segment1;
c_revision_num		:= p_po_to.revision_num;

/*
 * If the old record does not exist, then this is an error.
 */
v_progress := '910';

IF p_po_from.po_header_id IS NULL THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ERROR'),
                'ICX_ERROR',
		NULL,
		NULL
		);
	RETURN;
END IF;

/* Are the POs the same? */
IF p_po_from.po_header_id <> p_po_to.po_header_id THEN
	RETURN;
END IF;

/* Do not compare POs of the same revision number. */
IF NVL( p_po_from.revision_num, -99 ) =
	NVL( p_po_to.revision_num, -99 ) THEN
	RETURN;
END IF;

v_progress := '140';

/* Check for cancelled PO. */
IF p_po_to.cancel_flag = 'Y' THEN
	IF p_po_from.cancel_flag = 'Y'
	THEN
		RETURN;
	ELSE
		insert_changes(
			p_sequence,
			c_po_header_id,
			c_release_id,
			c_line_id,
			c_location_id,
			c_distribution_id,
			c_item_id,
			c_po_num,
			c_revision_num,
			c_line_num,
			c_location_num,
			c_distribution_num,
			c_level_altered,
			--fnd_message.get_string('PO', 'POS_CANCELLED'),
                        'ICX_CANCELLED',
			NULL,
			NULL
			);
		RETURN;
	END IF;
END IF;
/*
 * Check for the differences
 */

v_progress := '150';

/* Buyer */
IF p_po_from.agent_id <> p_po_to.agent_id THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_BUYER'),
                'ICX_BUYER',
		get_buyer( p_po_from.agent_id ),
		get_buyer( p_po_to.agent_id )
		);
END IF;

v_progress := '160';

/* Vendor contact */
IF NVL( p_po_from.vendor_contact_id, -99 ) <>
	NVL( p_po_to.vendor_contact_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SUPPLIER_CONTACT'),
                'ICX_SUPPLIER_CONTACT',
		get_vendor_contact( p_po_from.vendor_contact_id ),
		get_vendor_contact( p_po_to.vendor_contact_id )
		);
END IF;

v_progress := '170';

/* Confirming flag */
IF NVL( p_po_from.confirming_order_flag, ' ' ) <>
	NVL( p_po_to.confirming_order_flag, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_CONFIRMED'),
                'ICX_CONFIRMED',
		p_po_from.confirming_order_flag,
		p_po_to.confirming_order_flag
		);
END IF;

v_progress := '180';

/* Ship-to location */
IF NVL( p_po_from.ship_to_location_id, -99 ) <>
	NVL( p_po_to.ship_to_location_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SHIP_TO'),
                'ICX_SHIP_TO',
		get_location( p_po_from.ship_to_location_id ),
		get_location( p_po_to.ship_to_location_id )
		);
END IF;

v_progress := '190';

/* Bill-to location */
IF NVL( p_po_from.bill_to_location_id, -99 ) <>
	NVL( p_po_to.bill_to_location_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_BILL_TO'),
                'ICX_BILL_TO',
		get_location( p_po_from.bill_to_location_id ),
		get_location( p_po_to.bill_to_location_id )
		);
END IF;

v_progress := '200';

/* Payment terms */
IF NVL( p_po_from.terms_id, -99 ) <> NVL( p_po_to.terms_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_PAYMENT_TERMS'),
                'ICX_PAYMENT_TERMS',
		get_ap_terms( p_po_from.terms_id ),
		get_ap_terms( p_po_to.terms_id )
		);
END IF;

/* Amount */
v_amount_from := po_totals_po_sv.get_po_archive_total(
			c_po_header_id,
			p_po_from.revision_num );
v_amount_to := po_totals_po_sv.get_po_archive_total(
			c_po_header_id,
			p_po_to.revision_num );

v_progress := '210';

IF v_amount_from <> v_amount_to THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_AMOUNT'),
                'ICX_AMOUNT',
		v_amount_from,
		v_amount_to
		);
END IF;

v_progress := '220';

/* Ship via */
IF NVL( p_po_from.ship_via_lookup_code, ' ' ) <>
	NVL( p_po_to.ship_via_lookup_code, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SHIP_VIA'),
                'ICX_SHIP_VIA',
		p_po_from.ship_via_lookup_code,
		p_po_to.ship_via_lookup_code
		);
END IF;

v_progress := '230';

/* FOB */
IF NVL( p_po_from.fob_lookup_code, ' ' ) <>
	NVL( p_po_to.fob_lookup_code, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_FOB'),
                'ICX_FOB',
		get_po_lookup( 'FOB', p_po_from.fob_lookup_code ),
		get_po_lookup( 'FOB', p_po_to.fob_lookup_code )
		);
END IF;

v_progress := '240';

/* Freignt terms */
IF NVL( p_po_from.freight_terms_lookup_code, ' ' ) <>
	NVL( p_po_to.freight_terms_lookup_code, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_FREIGHT_TERMS'),
                'ICX_FREIGHT_TERMS',
		get_po_lookup(
			'FREIGHT TERMS',
			p_po_from.freight_terms_lookup_code ),
		get_po_lookup(
			'FREIGHT TERMS',
			p_po_to.freight_terms_lookup_code )
		);
END IF;

v_progress := '250';

/* Note to vendor */
IF NVL( p_po_from.note_to_vendor, ' ' ) <>
	NVL( p_po_to.note_to_vendor, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_NOTE_TO_VENDOR'),
                'ICX_NOTE_TO_VENDOR',
		p_po_from.note_to_vendor,
		p_po_to.note_to_vendor
		);
END IF;

v_progress := '260';

/* Acceptance required */
IF NVL( p_po_from.acceptance_required_flag, ' ' ) <>
	NVL( p_po_to.acceptance_required_flag, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ACCEPTANCE_REQUIRED'),
                'ICX_ACCEPTANCE_REQUIRED',
		p_po_from.acceptance_required_flag,
		p_po_to.acceptance_required_flag
		);
END IF;

v_progress := '270';

/* Acceptance due date */
IF NVL( p_po_from.acceptance_due_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_po_to.acceptance_due_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ACCEPTANCE_DUE_DATE'),
                'ICX_ACCEPTANCE_DUE_DATE',
		       to_char(p_po_from.acceptance_due_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
		       to_char(p_po_to.acceptance_due_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
		       );
END IF;

v_progress := '280';

/* Amount limit */
IF NVL( p_po_from.amount_limit, -99 ) <>
	NVL( p_po_to.amount_limit, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_AMOUNT_LIMIT'),
                'ICX_AMOUNT_LIMIT',
		p_po_from.amount_limit,
		p_po_to.amount_limit
		);
END IF;

v_progress := '290';

/* Effective date */
IF NVL( p_po_from.start_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_po_to.start_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_EFFECTIVE_DATE'),
                'ICX_EFFECTIVE_DATE',
          to_char(p_po_from.start_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
           to_char(p_po_to.start_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
		);
END IF;

v_progress := '300';

/* Expiration date */
IF NVL( p_po_from.end_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_po_to.end_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_EXPIRATION_DATE'),
 		 'ICX_EXPIRATION_DATE',
		 to_char(p_po_from.end_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
           to_char(p_po_to.end_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
		);
END IF;

v_progress := '310';

/* Amount agreed */
IF NVL( p_po_from.blanket_total_amount, -99 ) <>
	NVL( p_po_to.blanket_total_amount, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_AMOUNT_AGREED'),
		 'ICX_AMOUNT_AGREED',
		p_po_from.blanket_total_amount,
		p_po_to.blanket_total_amount
		);
END IF;
v_progress := '320';

/* Supplier Site */
IF NVL( p_po_from.vendor_site_id, -99 ) <>
        NVL( p_po_to.vendor_site_id, -99 ) THEN
        insert_changes(
                p_sequence,
                c_po_header_id,
                c_release_id,
                c_line_id,
                c_location_id,
                c_distribution_id,
                c_item_id,
                c_po_num,
                c_revision_num,
                c_line_num,
                c_location_num,
                c_distribution_num,
                c_level_altered,
                'ICX_VENDOR_SITE',
                get_vendor_site(p_po_from.vendor_site_id),
                get_vendor_site(p_po_to.vendor_site_id)
                );
END IF;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.COMPARE_HEADERS',
		v_progress,
		 sqlcode );
	RAISE;

END compare_headers;



/*********************************************************************
 * NAME
 * compare_releases
 *
 * PURPOSE
 * Accepts two records of the same release with different revisions,
 * compare the data in both releases, and stores the differences in a
 * temporary table.
 *
 * ARGUMENTS
 * p_release_from	Old version of the PO.
 * p_release_to		New version of the PO.
 * p_sequence		Sequence number to use in the temp table to
 *			identify the records for delta.
 *
 * NOTES
 * The comparison is not done on all fields, but only the ones than
 * cause a revision change, according to Oracle Purchasing Reference
 * Manual.
 *
 * The fields that can be changed on PO header, and cause a revision
 * number increase are:
 *
 *	Cancel Flag
 *	Buyer
 *	Acceptance required
 *	Acceptance due date
 *	Release number
 *	Release date
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created.
 * 22-SEP-97	Rami Haddad	Added buyer comparison.
 ********************************************************************/
PROCEDURE compare_releases(
	p_release_from in po_releases_archive%ROWTYPE,
	p_release_to in po_releases_archive%ROWTYPE,
	p_sequence IN NUMBER
	) AS

/*
 * Constant variables to pass for insert_changes
 */
c_level_altered		icx_po_revisions_temp.level_altered%TYPE
			:= 'ICX_HEADER';
c_po_header_id		NUMBER;
c_po_num		po_headers_archive.segment1%TYPE;
c_release_id		NUMBER;
c_revision_num		NUMBER;
c_line_id		NUMBER := NULL;
c_line_num		NUMBER := NULL;
c_location_id		NUMBER := NULL;
c_location_num		NUMBER := NULL;
c_distribution_id	NUMBER := NULL;
c_distribution_num	NUMBER := NULL;
c_item_id		NUMBER := NULL;
v_progress		VARCHAR2(3);

v_po_num		po_headers_archive.segment1%TYPE;

BEGIN

/*
 * At least the latest revision should exist.
 */
IF p_release_to.po_header_id IS NULL THEN
	RETURN;
END IF;

/*
 * Set values for all constants
 */
c_po_header_id		:= p_release_to.po_header_id;

v_progress := '320';

SELECT	segment1
INTO	v_po_num
FROM	po_headers_archive
WHERE
	po_header_id = p_release_to.po_header_id
AND	latest_external_flag = 'Y';

c_po_num		:= v_po_num || '-' ||
			p_release_to.release_num;
c_revision_num		:= p_release_to.revision_num;
c_release_id		:= p_release_to.po_release_id;

/*
 * If the old record does not exist, then this is a new one.
 */

v_progress := '330';

IF p_release_from.po_header_id IS NULL THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_NEW'),
		 'ICX_NEW',
		NULL,
		NULL
		);
	RETURN;
END IF;

/*
 * Are the releases the same?
 */
IF NVL( p_release_from.po_release_id, -99 ) <>
	NVL( p_release_to.po_release_id, -99 ) THEN
	RETURN;
END IF;

/*
 * Do not compare releases of the same revision number.
 */

IF NVL( p_release_from.revision_num, -99 ) =
	NVL( p_release_to.revision_num, -99 ) THEN
	RETURN;
END IF;

v_progress := '340';

/*
 * Check for cancelled release.
 */
IF p_release_to.cancel_flag = 'Y' THEN
	IF p_release_from.cancel_flag = 'Y'
	THEN
		RETURN;
	ELSE
		insert_changes(
			p_sequence,
			c_po_header_id,
			c_release_id,
			c_line_id,
			c_location_id,
			c_distribution_id,
			c_item_id,
			c_po_num,
			c_revision_num,
			c_line_num,
			c_location_num,
			c_distribution_num,
			c_level_altered,
			--fnd_message.get_string('PO', 'POS_CANCELLED'),
			'ICX_CANCELLED',
			NULL,
			NULL
			);
		RETURN;
	END IF;
END IF;

v_progress := '350';

/* Buyer */
IF p_release_from.agent_id <>  p_release_to.agent_id THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_BUYER'),
		 'ICX_BUYER',
		get_buyer( p_release_from.agent_id ),
		get_buyer( p_release_to.agent_id )
		);
END IF;

v_progress := '360';

/* Acceptance due date */
IF NVL( p_release_from.acceptance_due_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_release_to.acceptance_due_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ACCEPTANCE_DUE_DATE'),
		'ICX_ACCEPTANCE_DUE_DATE',
		 to_char(p_release_from.acceptance_due_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
           to_char(p_release_to.acceptance_due_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
		);
END IF;

v_progress := '380';

/* Acceptance required */
IF NVL( p_release_from.acceptance_required_flag, ' ' ) <>
	NVL( p_release_to.acceptance_required_flag, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ACCEPTANCE_REQUIRED'),
		 'ICX_ACCEPTANCE_REQUIRED',
		p_release_from.acceptance_required_flag,
		p_release_to.acceptance_required_flag
		);
END IF;

v_progress := '390';

/* Release number */
IF NVL( p_release_from.release_num, -99 ) <>
	NVL( p_release_to.release_num, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_revision_num,
		c_po_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_RELEASE_NUMBER'),
		 'ICX_RELEASE_NUMBER',
		p_release_from.release_num,
		p_release_to.release_num
		);
END IF;

v_progress := '400';

/* Release date */
IF NVL( p_release_from.release_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_release_to.release_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_RELEASE_DATE'),
		 'ICX_RELEASE_DATE',
		to_char(p_release_from.release_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
           to_char(p_release_to.release_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
		);
END IF;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.COMPARE_RELEASES',
		v_progress,
		sqlcode );
	RAISE;

END compare_releases;



/*********************************************************************
 * NAME
 * compare_lines
 *
 * PURPOSE
 * Accepts two records of the same lines with different revisions,
 * compare the data in both lines, and stores the differences in a
 * temporary table.
 *
 * ARGUMENTS
 * p_line_from	Old version of the PO.
 * p_line_to	New version of the PO.
 * p_sequence	Sequence number to use in the temp table to identify
 *		the records for delta.
 *
 * NOTES
 * The comparison is not done on all fields, but only the ones than
 * cause a revision change, according to Oracle Purchasing Reference
 * Manual.
 *
 * The fields that can be changed on PO header, and cause a revision
 * number increase are:
 *
 *	Cancel Flag
 *	Unit price
 *	Line number
 *	Item
 *	Item revision
 *	Item description
 *	Quantity
 *	UOM
 *	Source quotation header
 *	Source quotation line
 *	Hazard class
 *	Contract number
 *	Supplier item number
 *	Note to vendor
 *	UN number
 *	Price type
 *	Quantity Agreed
 *	Amount Agreed
 *	Closed Code
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created.
 * 22-SEP-97	Rami Haddad	Added comparison for buyer, source
 *				quotation header, source quotation
 *				line, supplier item number, quantity
 *				agreed, and amount agreed.
 * 08-SEP-97	Rami Haddad	Compare closed code
 ********************************************************************/
PROCEDURE compare_lines(
	p_line_from in po_lines_archive%ROWTYPE,
	p_line_to in po_lines_archive%ROWTYPE,
	p_sequence IN NUMBER
	) AS

/*
 * Constant variables to pass for insert_changes
 */
c_level_altered		icx_po_revisions_temp.level_altered%TYPE
			:= 'ICX_LINE';
c_po_header_id		NUMBER;
c_release_id		NUMBER := NULL;
c_po_num		po_headers_archive.segment1%TYPE;
c_line_id		NUMBER;
c_line_num		NUMBER;
c_revision_num		NUMBER;
c_location_id		NUMBER := NULL;
c_location_num		NUMBER := NULL;
c_distribution_id	NUMBER := NULL;
c_distribution_num	NUMBER := NULL;
c_item_id		NUMBER := NULL;

v_progress		VARCHAR2(3);

BEGIN

/*
 * At least the latest revision should exist.
 */
IF p_line_to.po_header_id IS NULL THEN
	RETURN;
END IF;

/*
 * Set values for all constants
 */
c_po_header_id		:= p_line_to.po_header_id;
c_line_id		:= p_line_to.po_line_id;
c_revision_num		:= p_line_to.revision_num;
c_line_num		:= p_line_to.line_num;
c_item_id		:= p_line_to.item_id;

v_progress := '410';

/*
 * If the old record does not exist, then this is a new one.
 */
IF p_line_from.po_header_id IS NULL THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_NEW'),
		'ICX_NEW',
		NULL,
		NULL
		);
	RETURN;
END IF;

/*
 * Are the lines the same?
 */
IF NVL( p_line_from.po_line_id, -99 ) <>
	NVL( p_line_to.po_line_id, -99 ) THEN
	RETURN;
END IF;

/*
 * Do not compare lines of the same revision number.
 */

IF NVL( p_line_from.revision_num, -99 ) =
	NVL( p_line_to.revision_num, -99 ) THEN
	RETURN;
END IF;

v_progress := '420';

/*
 * If current line is cancelled, then check if the prior one
 * is cancelled as well. If it is, then there is no
 * change. Otherwise, the line is cancelled for the current
 * revision.
 */
IF p_line_to.cancel_flag = 'Y' THEN
	IF p_line_from.cancel_flag ='Y'
	THEN
		RETURN;
	ELSE
		insert_changes(
			p_sequence,
			c_po_header_id,
			c_release_id,
			c_line_id,
			c_location_id,
			c_distribution_id,
			c_item_id,
			c_po_num,
			c_revision_num,
			c_line_num,
			c_location_num,
			c_distribution_num,
			c_level_altered,
			--fnd_message.get_string('PO', 'POS_CANCELLED'),
			 'ICX_CANCELLED',
			NULL,
			NULL
			);
		RETURN;
	END IF;
END IF;

/*
 * Line not cancelled in current PO. Compare all fields with
 * line in prior revision.
 */

v_progress := '430';

/* Unit price */
IF NVL( p_line_from.unit_price, -99 ) <>
	NVL( p_line_to.unit_price, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_UNIT_PRICE'),
		 'ICX_UNIT_PRICE',
		p_line_from.unit_price,
		p_line_to.unit_price
		);
END IF;

v_progress := '440';

/* Line number */
IF NVL( p_line_from.line_num, -99 ) <>
	NVL( p_line_to.line_num, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_LINE_NUMBER'),
		 'ICX_LINE_NUMBER',
		p_line_from.line_num,
		p_line_to.line_num
		);
END IF;

v_progress := '450';

/* Item */
IF NVL( p_line_from.item_id, -99 )  <> NVL( p_line_to.item_id, -99 )
THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ITEM'),
		 'ICX_ITEM',
		get_item_number( p_line_from.item_id ),
		get_item_number( p_line_to.item_id )
		);
END IF;

v_progress := '460';

/* Item revision */
IF NVL( p_line_from.item_revision, ' ' ) <>
	NVL( p_line_to.item_revision, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ITEM_REVISION'),
		 'ICX_ITEM_REVISION',
		p_line_from.item_revision,
		p_line_to.item_revision
		);
END IF;

v_progress := '470';

/* Item description */
IF NVL( p_line_from.item_description, ' ' ) <>
	NVL( p_line_to.item_description, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_ITEM_DESCRIPTION'),
		 'ICX_ITEM_DESCRIPTION',
		p_line_from.item_description,
		p_line_to.item_description
		);
END IF;

v_progress := '480';

/* Quantity */
IF NVL( p_line_from.quantity, -99 ) <>
	NVL( p_line_to.quantity, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_QUANTITY'),
		 'ICX_QUANTITY',
		p_line_from.quantity,
		p_line_to.quantity
		);
END IF;

v_progress := '490';

/* UOM */
IF NVL( p_line_from.unit_meas_lookup_code, ' ' ) <>
	NVL( p_line_to.unit_meas_lookup_code, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_UOM'),
		 'ICX_UOM',
		p_line_from.unit_meas_lookup_code,
		p_line_to.unit_meas_lookup_code
		);
END IF;

v_progress := '500';

/* Source quotation header */
IF NVL( p_line_from.from_header_id, -99 ) <>
	NVL( p_line_to.from_header_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SOURCE_QT_HEADER'),
		 'ICX_SOURCE_QT_HEADER',
		get_source_quotation_header(
			p_line_from.from_header_id ),
		get_source_quotation_header(
			p_line_to.from_header_id )

		);
END IF;

v_progress := '510';

/* Source quotation line */
IF NVL( p_line_from.from_line_id, -99 ) <>
	NVL( p_line_to.from_line_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SOURCE_QT_LINE'),
		 'ICX_SOURCE_QT_LINE',
		get_source_quotation_line(
			p_line_from.from_line_id ),
		get_source_quotation_line(
			p_line_to.from_line_id )

		);
END IF;

v_progress := '520';

/* Hazard class */
IF NVL( p_line_from.hazard_class_id, -99 ) <>
	NVL( p_line_to.hazard_class_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_HAZARD_CLASS'),
		 'ICX_HAZARD_CLASS',
		get_hazard_class( p_line_from.hazard_class_id ),
		get_hazard_class( p_line_to.hazard_class_id )
		);
END IF;

v_progress := '530';

/* Contract number */
IF NVL( p_line_from.contract_num, ' ' ) <>
	NVL( p_line_to.contract_num, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_CONTRACT_NUMBER'),
		 'ICX_CONTRACT_NUMBER',
		p_line_from.contract_num,
		p_line_to.contract_num
		);
END IF;

v_progress := '540';

/* Supplie item number */
IF NVL( p_line_from.vendor_product_num, ' ' ) <>
	NVL( p_line_to.vendor_product_num, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SUPPLIER_ITEM_NUM'),
		 'ICX_SUPPLIER_ITEM_NUM',
		p_line_from.vendor_product_num,
		p_line_to.vendor_product_num
		);
END IF;

v_progress := '550';

/* Note to vendor */
IF NVL( p_line_from.note_to_vendor, ' ' ) <>
	NVL( p_line_to.note_to_vendor, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_NOTE_TO_VENDOR'),
		 'ICX_NOTE_TO_VENDOR',
		p_line_from.note_to_vendor,
		p_line_to.note_to_vendor
		);
END IF;

v_progress := '560';

/* UN number */
IF NVL( p_line_from.un_number_id, -99 ) <>
	NVL( p_line_to.un_number_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_UN_NUMBER'),
		 'ICX_UN_NUMBER',
		get_un_number( p_line_from.un_number_id ),
		get_un_number( p_line_to.un_number_id )
		);
END IF;

v_progress := '570';

/* Price type */
IF NVL( p_line_from.price_type_lookup_code, ' ' ) <>
	NVL( p_line_to.price_type_lookup_code, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_PRICE_TYPE'),
		 'ICX_PRICE_TYPE',
		get_po_lookup(
			'PRICE TYPE',
			p_line_from.price_type_lookup_code ),
		get_po_lookup(
			'PRICE TYPE',
			 p_line_to.price_type_lookup_code )
		);
END IF;

v_progress := '580';

/* Quantity agreed */
/*Bug 1461326
  Quantity_commited is a number field and to handle nulls we
  were incorrectly using the following
   NVL( p_line_from.quantity_committed, ' ' )
   NVL( p_line_to.quantity_committed, ' ' )
  Code replaced to the following and resolved the issue
   NVL( p_line_from.quantity_committed,-99)
   NVL( p_line_to.quantity_committed,-99)
*/

IF NVL( p_line_from.quantity_committed, -99 ) <>
	NVL( p_line_to.quantity_committed,-99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_QUANTITY_AGREED'),
		 'ICX_QUANTITY_AGREED',
		p_line_from.quantity_committed,
		p_line_to.quantity_committed
		);
END IF;

v_progress := '590';

/* Amount agreed */
/*Bug 1461326
  Comitted_amount is a number field and to handle nulls we
  were incorrectly using the following
   NVL( p_line_from.committed_amount, ' ' )
   NVL( p_line_to.committed_amount, ' ' )
  Code replaced to the following and resolved the issue
   NVL( p_line_from.committed_amount,-99)
   NVL( p_line_to.committed_amount,-99)
*/
IF NVL( p_line_from.committed_amount, -99 ) <>
	NVL( p_line_to.committed_amount, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_AMOUNT_AGREED'),
		 'ICX_AMOUNT_AGREED',
		p_line_from.committed_amount,
		p_line_to.committed_amount
		);
END IF;

/* Closed code */
IF NVL( p_line_from.closed_code, ' ' ) <>
	NVL( p_line_to.closed_code , ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_CLOSED_CODE'),
		 'ICX_CLOSED_CODE',
		get_po_lookup( 'DOCUMENT STATE',
			p_line_from.committed_amount ),
		get_po_lookup( 'DOCUMENT STATE',
			p_line_to.committed_amount )
		);
END IF;

/* Bug - 1260356 - Need to show archived changes for Line Level Expiration date */
IF NVL( p_line_from.expiration_date,
                TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
        NVL( p_line_to.expiration_date,
                TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
        insert_changes(
                p_sequence,
                c_po_header_id,
                c_release_id,
                c_line_id,
                c_location_id,
                c_distribution_id,
                c_item_id,
                c_po_num,
                c_revision_num,
                c_line_num,
                c_location_num,
                c_distribution_num,
                c_level_altered,
                --fnd_message.get_String('PO', 'POS_EXPIRATION_DATE'),
                'ICX_EXPIRATION_DATE',
                 to_char(p_line_from.expiration_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
           to_char(p_line_to.expiration_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
                );
END IF;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.COMPARE_LINES',
		v_progress,
		sqlcode );
	RAISE;

END compare_lines;



/*********************************************************************
 * NAME
 * compare_locations
 *
 * PURPOSE
 * Accepts two records of the same locations with different revisions,
 * compare the data in both locations, and stores the differences in a
 * temporary table.
 *
 * ARGUMENTS
 * p_loc_from	Old version of the line location.
 * p_loc_to	New version of the line location.
 * p_sequence	Sequence number to use in the temp table to identify
 *		the records for delta.
 *
 * NOTES
 * The comparison is not done on all fields, but only the ones than
 * cause a revision change, according to Oracle Purchasing Reference
 * Manual.
 *
 * The fields that can be changed on PO header, and cause a revision
 * number increase are:
 *
 *	Cancel Flag
 *	Shipment number
 *	Ship-to location
 *	Quantity
 *	Promised date
 *	Need-by date
 *	Last accept date
 *	Taxable flag
 *	Shipment price
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created.
 * 23-SEP-97	Rami Haddad	Added comparison for shipment number
 *				and shipment price.
 ********************************************************************/
PROCEDURE compare_locations(
	p_loc_from in po_line_locations_archive%ROWTYPE,
	p_loc_to in po_line_locations_archive%ROWTYPE,
	p_sequence IN NUMBER
	) AS

/* Constant variables to pass for insert_changes */
c_level_altered		icx_po_revisions_temp.level_altered%TYPE
			:= 'ICX_SHIPMENT';
c_po_header_id		NUMBER;
c_release_id		NUMBER;
c_po_num		po_headers_archive.segment1%TYPE := NULL;
c_line_id		NUMBER;
c_line_num		NUMBER := NULL;
c_location_id		NUMBER;
c_location_num		NUMBER;
c_revision_num		NUMBER;
c_distribution_id	NUMBER := NULL;
c_distribution_num	NUMBER := NULL;
c_item_id		NUMBER := NULL;

v_progress		VARCHAR2(3);

BEGIN

/*
 * At least the latest revision should exist.
 */
IF p_loc_to.po_header_id IS NULL THEN
	RETURN;
END IF;

/* Set values for all constants */
c_po_header_id		:= p_loc_to.po_header_id;
c_release_id		:= p_loc_to.po_release_id;
c_line_id		:= p_loc_to.po_line_id;
c_location_id		:= p_loc_to.line_location_id;
c_location_num		:= p_loc_to.shipment_num;
c_revision_num		:= p_loc_to.revision_num;


--get the line number using line id
/* Bug 2201739, we should fetch item_id from line level */

select line_num, item_id
into c_line_num, c_item_id
from po_lines_all
where po_line_id =  p_loc_to.po_line_id;

v_progress := '600';

/* If the previous record does not exist, then this is a new one. */
IF p_loc_from.po_header_id IS NULL THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_NEW'),
		 'ICX_NEW',
		NULL,
		NULL
		);
	RETURN;
END IF;

/* Are the lines the same? */
IF p_loc_from.line_location_id  <> p_loc_to.line_location_id THEN
	RETURN;
END IF;

/* Do not compare lines of the same revision number. */
IF NVL( p_loc_from.revision_num, -99 ) =
	NVL( p_loc_to.revision_num, -99 ) THEN
	RETURN;
END IF;

/*
 * If current line location is cancelled, then check if the priior one
 * is cancelled as well.  If it is, then there is no change. Otherwise
 * the line is cancelled for the current revision.
 */

v_progress := '610';

IF p_loc_to.cancel_flag = 'Y' THEN
	IF p_loc_from.cancel_flag = 'Y'
	THEN
		RETURN;
	ELSE
		insert_changes(
			p_sequence,
			c_po_header_id,
			c_release_id,
			c_line_id,
			c_location_id,
			c_distribution_id,
			c_item_id,
			c_po_num,
			c_revision_num,
			c_line_num,
			c_location_num,
			c_distribution_num,
			c_level_altered,
			--fnd_message.get_string('PO', 'POS_CANCELLED'),
			 'ICX_CANCELLED',
			NULL,
			NULL
			);
		RETURN;
	END IF;
END IF;

/*
 * Line location not cancelled in current PO. Compare all field with
 * line in prior revision.
 */

v_progress := '620';

/* Shipment number */
IF NVL( p_loc_from.shipment_num, -99 ) <>
	NVL( p_loc_to.shipment_num, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SHIP_NUM'),
		 'ICX_SHIP_NUM',
		p_loc_from.shipment_num,
		p_loc_to.shipment_num
		);
END IF;

v_progress := '630';

/* Ship-to location */
IF NVL( p_loc_from.ship_to_location_id, -99 ) <>
	NVL( p_loc_to.ship_to_location_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_SHIP_TO'),
		 'ICX_SHIP_TO',
		get_location( p_loc_from.ship_to_location_id ),
		get_location( p_loc_to.ship_to_location_id )
		);
END IF;

v_progress := '640';

/* Quantity */
IF NVL( p_loc_from.quantity, -99 ) <>  NVL( p_loc_to.quantity, -99 )
THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_QUANTITY'),
		 'ICX_QUANTITY',
		p_loc_from.quantity,
		p_loc_to.quantity
		);
END IF;

v_progress := '650';

/* promised date */
IF NVL( p_loc_from.promised_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_loc_to.promised_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_PROMISED_DATE'),
		 'ICX_PROMISED_DATE',
		       to_char(p_loc_from.promised_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
		       to_char(p_loc_to.promised_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))

		);
END IF;

v_progress := '660';

/* Need-by date */
IF NVL( p_loc_from.need_by_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_loc_to.need_by_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_NEED_BY_DATE'),
		 'ICX_NEED_BY_DATE',
      to_char(p_loc_from.need_by_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
		to_char(p_loc_to.need_by_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
		);
END IF;

v_progress := '670';

/* Last accept date */
IF NVL( p_loc_from.last_accept_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <>
	NVL( p_loc_to.last_accept_date,
		TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		p_loc_from.revision_num || '-' || p_loc_to.revision_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_LAST_ACCEPT_DATE'),
		 'ICX_LAST_ACCEPT_DATE',
		       to_char(p_loc_from.last_accept_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')),
		       to_char(p_loc_to.last_accept_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'))
		);
END IF;

v_progress := '680';

/* Taxable flag */
IF NVL( p_loc_from.taxable_flag, ' ' ) <>
	NVL( p_loc_to.taxable_flag, ' ' ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_TAXABLE_FLAG'),
		 'ICX_TAXABLE_FLAG',
		get_po_lookup(
			'YES/NO',
			p_loc_from.taxable_flag ),
		get_po_lookup(
			'YES/NO',
			p_loc_to.taxable_flag )
		);
END IF;


v_progress := '690';

/* Price break */
IF NVL( p_loc_from.price_override, -99 ) <>
	NVL( p_loc_to.price_override, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_PRICE_BREAK'),
		 'ICX_PRICE_BREAK',
		p_loc_from.price_override,
		p_loc_to.price_override
		);
END IF;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.COMPARE_LOCATIONS',
		v_progress,
		sqlcode );
	RAISE;

END compare_locations;



/*********************************************************************
 * NAME
 * compare_distributions
 *
 * PURPOSE
 * Accepts two records of the same distribution with different
 * revisions, compare the data in both distributions, and stores the
 * differences in a temporary table.
 *
 * ARGUMENTS
 * p_dist_from	Old version of the distribution.
 * p_dist_to	New version of the distribution.
 * p_sequence	Sequence number to use in the temp table to identify
 *		the records for delta.
 *
 * NOTES
 * The comparison is not done on all fields, but only the ones than
 * cause a revision change, according to Oracle Purchasing Reference
 * Manual.
 *
 * The fields that can be changed on PO header, and cause a revision
 * number increase are:
 *
 *	Cancel Flag
 *	Quantity ordered
 *	Requestor
 *	Charge account
 *
 * Distributions cannot be cancelled, so there is no need to check for
 * cancelled distribution lines.
 *
 * HISTORY
 * 08-AUG-97	Nilo Paredes	Created.
 ********************************************************************/
PROCEDURE compare_distributions(
	p_dist_from in po_distributions_archive%ROWTYPE,
	p_dist_to in po_distributions_archive%ROWTYPE,
	p_sequence IN NUMBER
	) AS

/*
 * Constant variables to pass for insert_changes
 */
c_level_altered		icx_po_revisions_temp.level_altered%TYPE
			:= 'ICX_DISTRIBUTION';
c_po_header_id		NUMBER;
c_release_id		NUMBER;
c_po_num		po_headers_archive.segment1%TYPE := NULL;
c_line_id		NUMBER;
c_line_num		NUMBER := NULL;
c_location_id		NUMBER;
c_location_num		NUMBER := NULL;
c_distribution_id	NUMBER;
c_distribution_num	NUMBER;
c_revision_num		NUMBER;
c_item_id		NUMBER := NULL;

v_progress		VARCHAR2(3);

BEGIN

/*
 * At least the latest revision should exist.
 */
IF p_dist_to.po_header_id IS NULL THEN
	RETURN;
END IF;

/*
 * Set values for all constants
 */
c_po_header_id		:= p_dist_to.po_header_id;
c_release_id		:= p_dist_to.po_release_id;
c_line_id		:= p_dist_to.po_line_id;
c_location_id		:= p_dist_to.line_location_id;
c_distribution_id	:= p_dist_to.po_distribution_id;
c_distribution_num	:= p_dist_to.distribution_num;
c_revision_num		:= p_dist_to.revision_num;

v_progress := '700';

/* Bug# 1893770 */
--get the line number using line id

select line_num
into c_line_num
from po_lines_all
where po_line_id =  p_dist_to.po_line_id;

--get the shipment number using line location id

select shipment_num
into c_location_num
from po_line_locations_all
where line_location_id =  p_dist_to.line_location_id;

/*
 * If the old record does not exist, then this is a new one.
 */

IF p_dist_from.po_header_id IS NULL THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_NEW'),
		 'ICX_NEW',
		NULL,
		NULL
		);
	RETURN;
END IF;

/*
 * Are the lines the same?
 */
IF NVL( p_dist_from.line_location_id, -99 ) <>
	NVL( p_dist_to.line_location_id, -99 ) THEN
	RETURN;
END IF;

/*
 * Do not compare lines of the same revision number.
 */

IF NVL( p_dist_from.revision_num, -99 ) =
	NVL( p_dist_to.revision_num, -99 ) THEN
	RETURN;
END IF;

v_progress := '710';

/* Quantity ordered */
IF NVL( p_dist_from.quantity_ordered, -99 ) <>
	NVL( p_dist_to.quantity_ordered, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_QUANTITY'),
		 'ICX_QUANTITY',
		p_dist_from.quantity_ordered,
		p_dist_to.quantity_ordered
		);
END IF;

v_progress := '720';

/* Requestor */
IF NVL( p_dist_from.deliver_to_person_id, -99 ) <>
	NVL( p_dist_to.deliver_to_person_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_REQUESTOR'),
		 'ICX_REQUESTOR',
		p_dist_from.deliver_to_person_id,
		p_dist_to.deliver_to_person_id
		);
END IF;

v_progress := '730';

/* Charge account */

/* Bug 1181007
   inserting the associated charge account instead of the
   ccid by using the function get_charge_account.
*/

IF NVL( p_dist_from.code_combination_id, -99 ) <>
	NVL( p_dist_to.code_combination_id, -99 ) THEN
	insert_changes(
		p_sequence,
		c_po_header_id,
		c_release_id,
		c_line_id,
		c_location_id,
		c_distribution_id,
		c_item_id,
		c_po_num,
		c_revision_num,
		c_line_num,
		c_location_num,
		c_distribution_num,
		c_level_altered,
		--fnd_message.get_String('PO', 'POS_CHARGE_ACCT'),
		 'ICX_CHARGE_ACCT',
		get_charge_account(p_dist_from.code_combination_id),
		get_charge_account(p_dist_to.code_combination_id)
		);
END IF;

EXCEPTION
WHEN others THEN
	PO_MESSAGE_S.SQL_ERROR(
		'PO_COMPARE_REVISIONS.PO_COMPARE_DISTRIBUTIONS',
		v_progress,
		sqlcode );
	RAISE;

END compare_distributions;

/*Bug 1181007
  The following function get_charge_account is added to fetch
  the charge account when the ccid is given
*/

/*********************************************************************
 * NAME
 * get_charge_account
 *
 * PURPOSE
 * To fetch the charge account based on the ccid from the
 * gl_code_combinations_kfv.
 *
 * ARGUMENTS
 * p_code_combiation_id Unique identifier for charge account in
 *                      GL_CODE_COMBINATIONS_KFV view.
 *
 * NOTES
 * Return NULL if an error occurs.
 *
 * HISTORY
 * 01-FEB-2000  Suresh Arunachalam      Created
 ********************************************************************/

FUNCTION get_charge_account(p_code_combination_id IN NUMBER)
        RETURN VARCHAR2 AS
v_charge_account        varchar2( 4000 );
v_progress              varchar2(3);

BEGIN

v_progress := '830';

SELECT  concatenated_segments
INTO    v_charge_account
FROM    gl_code_combinations_kfv
WHERE   code_combination_id = p_code_combination_id;

RETURN v_charge_account;

EXCEPTION
WHEN no_data_found THEN
        RETURN NULL;
WHEN others THEN
        PO_MESSAGE_S.SQL_ERROR(
                'PO_COMPARE_REVISIONS.GET_CHARGE_ACCOUNT',
                v_progress,
                sqlcode );
        RAISE;

END get_charge_account;

END po_compare_revisions;

/
