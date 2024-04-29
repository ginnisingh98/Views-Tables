--------------------------------------------------------
--  DDL for Package INV_CR_ASN_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CR_ASN_DETAILS" AUTHID CURRENT_USER AS
/* $Header: INVCRDIS.pls 120.3 2005/10/10 12:56:04 methomas noship $*/

/*******************************************************
*  Name: create_asn_details
*
*  Description:
*
*
*  Parameters:
*
*
*******************************************************/

TYPE asn_details_rec_tp IS RECORD
(
GROUP_ID                      number,
SHIPMENT_NUM                  varchar2(30),
ORGANIZATION_ID               number,
DISCREPANCY_REPORTING_CONTEXT varchar2(25),
ITEM_ID                       number,
QUANTITY_EXPECTED             number,
QUANTITY_ACTUAL               number,
UNIT_OF_MEASURE_EXPECTED      varchar2(25),
UNIT_OF_MEASURE_ACTUAL        varchar2(25),
LPN_EXPECTED                  varchar2(30),
LPN_ACTUAL                    varchar2(30),
ITEM_REVISION_EXPECTED        varchar2(3),
ITEM_REVISION_ACTUAL          varchar2(3),
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
LOT_NUMBER_EXPECTED           varchar2(80),
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
LOT_NUMBER_ACTUAL             varchar2(80),
SERIAL_NUMBER_EXPECTED        varchar2(30),
SERIAL_NUMBER_ACTUAL          varchar2(30),
VENDOR_ID                     number,
VENDOR_SITE_ID                number,
TRANSACTION_DATE              date
);

TYPE rcv_intf_rec_tp IS RECORD
(
	 group_id                 number ,
	 to_organization_id       number,
	 item_id                  number,
	 item_revision            varchar2(3),
	 shipment_header_id       number,
	 po_line_id               number,
	 quantity                 number,
	 unit_of_measure          varchar2(25),
	 uom_code                 varchar2(3),
	 header_interface_id      number
);



PROCEDURE create_asn_details_from_intf(
    p_interface_transaction_rec IN OUT nocopy rcv_intf_rec_tp ,
    x_status                  OUT nocopy VARCHAR2,
    x_message                 OUT nocopy VARCHAR2
			    );

PROCEDURE create_asn_details(
    p_organization_id      IN     NUMBER,
    p_group_id             IN     NUMBER,
    p_rcv_rcpt_rec         IN OUT nocopy  inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp,
    p_rcv_transaction_rec  IN OUT nocopy  inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp,
    p_rcpt_lot_qty_rec_tb  IN OUT nocopy  inv_rcv_std_rcpt_apis.rcpt_lot_qty_rec_tb_tp,
    p_interface_transaction_id IN number,
    x_status                  OUT nocopy VARCHAR2,
    x_message                 OUT nocopy VARCHAR2
			    );

/* Bug 4551595-Added the procedure to update wms_asn_details
               for item to be called from INV_RCV_STD_RCPT_APIS
	       at the header level for all the records of rti
	       for a group id */

PROCEDURE update_asn_item_details
(p_group_id IN NUMBER);

/* End of fix for Bug 4551595 */

END inv_cr_asn_details;

 

/
