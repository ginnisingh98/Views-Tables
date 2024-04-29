--------------------------------------------------------
--  DDL for Package WSMPINVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPINVL" AUTHID CURRENT_USER AS
/* $Header: WSMINVLS.pls 120.4 2006/03/28 03:50:09 sisankar noship $ */

USER NUMBER;
LOGIN NUMBER;
WSMISSUE NUMBER;
WSMRECEIPT NUMBER;
REQUEST NUMBER;
PROGRAM NUMBER;
PROGAPPL NUMBER;

/*BA#IIIP*/

/* Message type for errors in WSM_INTERFACE_ERRORS table
** Message_type lookup in MFG_LOOKUPS.WIP_ML_ERROR_TYPE.
** 1 - Error, 2 - Warning.
*/
	Message_Type_Error Number := 1;
	Message_Type_Warning Number := 2;
/* Global Debug parameter and is set by MRP_DEBUG profile value */

	G_DEBUG varchar2(1) := 'N';

/*EA#IIIP*/

/* Transaction Types */
SPLIT NUMBER := 1;
MERGE NUMBER := 2;
TRANSLATE NUMBER := 3;
TRANSFER NUMBER := 4;

/* Modes to call program */
ONLINE NUMBER := 1;
CONCURRENT NUMBER := 2;

/* Values for process status */
PENDING NUMBER := 1; -- changed from 2 to 1 by Bala Balakumar, Jul22,2000.
ERROR NUMBER := 3;
COMPLETE NUMBER := 4;

/* Added for bug fix 4958157 */
l_miss_char  CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
l_miss_date  CONSTANT DATE        := FND_API.G_MISS_DATE;
l_miss_num   CONSTANT NUMBER      := FND_API.G_MISS_NUM;

/* This record type is added for maintaining lot attributes in Inv lot transactions */
/*
Type lot_attributes_rec_type is RECORD
(
 l_mtli_txn_id   		NUMBER,
 l_description                  VARCHAR2(256),
 l_grade_code			VARCHAR2(150),
 l_origination_date		DATE,
 l_date_code			VARCHAR2(150),
 l_change_date			DATE,
 l_age				NUMBER,
 l_retest_date			DATE,
 l_maturity_date		DATE,
 l_item_size			NUMBER,
 l_color			VARCHAR2(150),
 l_volume			NUMBER,
 l_volume_uom			VARCHAR2(3),
 l_place_of_origin		VARCHAR2(150),
 l_best_by_date			DATE,
 l_length			NUMBER,
 l_length_uom			VARCHAR2(3),
 l_recycled_content		NUMBER,
 l_thickness			NUMBER,
 l_thickness_uom		VARCHAR2(3),
 l_width			NUMBER,
 l_width_uom			VARCHAR2(3),
 l_vendor_id			NUMBER,
 l_vendor_name				VARCHAR2(240),
 l_territory_code			VARCHAR2(30),
 l_supplier_lot_number		VARCHAR2(150),
 l_curl_wrinkle_fold		VARCHAR2(150),
 l_lot_attribute_category	VARCHAR2(30),
 l_attribute_category		VARCHAR2(30)
); */ -- commented out to change this based on MTL_LOT_NUMBERS table

Type lot_attributes_rec_type is RECORD
(
 l_mtli_txn_id   			NUMBER,
 l_description				MTL_LOT_NUMBERS.DESCRIPTION%TYPE,
 l_grade_code				MTL_LOT_NUMBERS.GRADE_CODE%TYPE,
 l_origination_date			MTL_LOT_NUMBERS.ORIGINATION_DATE%TYPE,
 l_date_code				MTL_LOT_NUMBERS.DATE_CODE%TYPE,
 l_change_date				MTL_LOT_NUMBERS.CHANGE_DATE%TYPE,
 l_age						MTL_LOT_NUMBERS.AGE%TYPE,
 l_retest_date				MTL_LOT_NUMBERS.RETEST_DATE%TYPE,
 l_maturity_date			MTL_LOT_NUMBERS.MATURITY_DATE%TYPE,
 l_item_size				MTL_LOT_NUMBERS.ITEM_SIZE%TYPE,
 l_color					MTL_LOT_NUMBERS.COLOR%TYPE,
 l_volume					MTL_LOT_NUMBERS.VOLUME%TYPE,
 l_volume_uom				MTL_LOT_NUMBERS.VOLUME_UOM%TYPE,
 l_place_of_origin			MTL_LOT_NUMBERS.PLACE_OF_ORIGIN%TYPE,
 l_best_by_date				MTL_LOT_NUMBERS.BEST_BY_DATE%TYPE,
 l_length					MTL_LOT_NUMBERS.LENGTH%TYPE,
 l_length_uom				MTL_LOT_NUMBERS.LENGTH_UOM%TYPE,
 l_recycled_content			MTL_LOT_NUMBERS.RECYCLED_CONTENT%TYPE,
 l_thickness				MTL_LOT_NUMBERS.THICKNESS%TYPE,
 l_thickness_uom			MTL_LOT_NUMBERS.THICKNESS_UOM%TYPE,
 l_width					MTL_LOT_NUMBERS.WIDTH%TYPE,
 l_width_uom				MTL_LOT_NUMBERS.WIDTH_UOM%TYPE,
 l_vendor_id				MTL_LOT_NUMBERS.VENDOR_ID%TYPE,
 l_vendor_name				MTL_LOT_NUMBERS.VENDOR_NAME%TYPE,
 l_territory_code			MTL_LOT_NUMBERS.TERRITORY_CODE%TYPE,
 l_supplier_lot_number		MTL_LOT_NUMBERS.SUPPLIER_LOT_NUMBER%TYPE,
 l_curl_wrinkle_fold		MTL_LOT_NUMBERS.CURL_WRINKLE_FOLD%TYPE,
 l_lot_attribute_category	MTL_LOT_NUMBERS.LOT_ATTRIBUTE_CATEGORY%TYPE,
 l_attribute_category		MTL_LOT_NUMBERS.ATTRIBUTE_CATEGORY%TYPE
);

/* This is the main routing for processing inventory lot transactions
   You can call the routine to process a group of rows by passing a group
   id or just one row by passing a transaction id */

PROCEDURE Process_Interface_rows(
	errbuf    out NOCOPY varchar2,
	retcode   out NOCOPY number,
	P_Group_Id IN NUMBER,
	P_header_Id IN NUMBER,
	P_Mode IN NUMBER);

PROCEDURE Transact(
	P_Group_Id IN NUMBER,
	P_header_Id IN NUMBER,
	P_Mode IN NUMBER,
	x_header_id out NOCOPY number,
	o_err_code out NOCOPY number,
	o_err_message out NOCOPY varchar2,
	x_err_cnt out NOCOPY number);

/* Validates data in tables.  Only needs to be called for records that
  did not come in through the form */
--FUNCTION Validate(
--P_Transaction_Id IN NUMBER) return BOOLEAN;

PROCEDURE Validate_Merge(
	P_header_Id IN NUMBER
	,err_status OUT NOCOPY NUMBER
	,o_err_message OUT NOCOPY VARCHAR);

PROCEDURE Validate_HEADER(
	P_header_Id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR);

PROCEDURE Validate_parent(
	P_header_Id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR);

PROCEDURE Validate_Starting(
	P_header_Id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR);

PROCEDURE Validate_resulting(
	P_header_Id IN NUMBER,
	err_status OUT NOCOPY NUMBER ,
	o_err_message OUT NOCOPY VARCHAR);
/*
FUNCTION Validate_Header(
	P_Transaction_Id IN NUMBER) return BOOLEAN;

FUNCTION Validate_Starting(
	P_Transaction_Id IN NUMBER) return BOOLEAN;

FUNCTION Validate_Resulting(
	P_Transaction_Id IN NUMBER) return BOOLEAN;
*/

/* Gets a transaction header id from a sequence */
FUNCTION Get_Header_Id RETURN NUMBER;

/* Set packaged variables */
PROCEDURE Set_Vars;

/* Users might do a split in which the resulting quantities add up to
   less than the starting quantities.  In this case, we need an extra
   resulting record */
PROCEDURE Create_Extra_Record(
	P_header_Id IN NUMBER,
	x_err_code       OUT NOCOPY NUMBER,
 	x_err_msg       OUT NOCOPY VARCHAR2   );

/* This procedure will populate MTL_MATERIAL_TRANSACTIONS_TEMP
   and LOTS_TEMP */
PROCEDURE Create_Mtl_Records(
	P_Header_id IN NUMBER, -- added by bala.
	P_Header_Id1 IN NUMBER,
	P_Transaction_Id IN NUMBER,
	P_Transaction_Type IN NUMBER,
	x_err_code       OUT NOCOPY NUMBER,
	x_err_msg       OUT NOCOPY VARCHAR2
	);

PROCEDURE Misc_Issue
(
	X_Header_Id1 IN NUMBER,
	X_Inventory_Item_Id IN NUMBER,
	X_Organization_id IN NUMBER,
	X_Quantity IN NUMBER,
	X_Acct_Period_Id IN NUMBER,
	X_Lot_Number IN VARCHAR2,
	X_Subinventory IN VARCHAR2,
	X_Locator_Id IN NUMBER,
	X_Revision IN VARCHAR2,
	X_Reason_Id IN NUMBER,
	X_Reference IN VARCHAR2,
	X_Transaction_Date IN DATE,
	X_Source_Line_Id IN NUMBER,
	X_Header_Id 	IN NUMBER, -- added by Bala
	x_err_code       OUT NOCOPY NUMBER,
	x_err_msg       OUT NOCOPY VARCHAR2
);

PROCEDURE Misc_Receipt
(
	X_Header_Id1 IN NUMBER,
	X_Inventory_Item_Id IN NUMBER,
	X_Organization_id IN NUMBER,
	X_Quantity IN NUMBER,
	X_Acct_Period_Id IN NUMBER,
	X_Lot_Number IN VARCHAR2,
	X_Subinventory IN VARCHAR2,
	X_Locator_Id IN NUMBER,
	X_Revision IN VARCHAR2,
	X_Reason_Id IN NUMBER,
	X_Reference IN VARCHAR2,
	X_Transaction_Date IN DATE,
	X_Source_Line_Id IN NUMBER,
	X_Header_Id 	IN NUMBER, -- added by Bala
	x_lot_attributes_rec IN lot_attributes_rec_type,   -- added by sisankar for  bug 4920235
	x_invattr_tbl  IN inv_lot_api_pub.char_tbl,
	x_Cattr_tbl  IN inv_lot_api_pub.char_tbl,
	x_Dattr_tbl  IN inv_lot_api_pub.date_tbl,
	x_Nattr_tbl  IN inv_lot_api_pub.number_tbl,
	x_err_code       OUT NOCOPY NUMBER,
	x_err_msg       OUT NOCOPY VARCHAR2
);

/* Launches the inventory transaction worker to process transactions */
FUNCTION Launch_Worker (
	X_Header_Id1 IN NUMBER,
	X_Message OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

/* Sets records to PROCESS_STATUS = COMPLETE */
PROCEDURE Success_All(
	p_header_id NUMBER,
	p_group_id NUMBER,
	x_err_code OUT NOCOPY NUMBER,
 	x_err_msg  OUT NOCOPY VARCHAR2,
 	p_mode NUMBER); /*Bug 4779518 fix*/

/* Sets records to PROCESS_STATUS = ERROR */
PROCEDURE Error_All(
		p_header_id NUMBER,
		p_group_id NUMBER,
                p_message VARCHAR2);


/*BA#IIIP*/
/* Show progress in the logfile if Debug is ON */
PROCEDURE showProgress(
	processingMode IN NUMBER,
	headerId NUMBER,
	procName IN VARCHAR2, -- Bug#1844972
	procLocation IN NUMBER, -- Bug#1844972
        showMessage VARCHAR2);

/* Create a Log for the user from wsm_interface_errors */
PROCEDURE writeToLog(
	requestId NUMBER
        , programId NUMBER
        , programApplnId NUMBER
                    );
/*EA#IIIP*/

/*AM Genealogy Integration */

	PROCEDURE enter_genealogy_records       (	p_transaction_id NUMBER ,
						p_transaction_type_id NUMBER,
						p_header_id NUMBER,
						p_process_status NUMBER ,
						err_status OUT NOCOPY NUMBER ,
						o_err_message OUT NOCOPY VARCHAR );

/*AM End Genealogy Integration */


END WSMPINVL;

 

/
