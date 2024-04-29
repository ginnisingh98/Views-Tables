--------------------------------------------------------
--  DDL for Package ARP_TAX_VIEW_VERTEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TAX_VIEW_VERTEX" AUTHID CURRENT_USER as
/* $Header: zxtxvwvs.pls 120.2 2006/10/06 11:45:14 vchallur ship $ */


USE_SHIP_TO CONSTANT VARCHAR2(10) := 'XXXXXXXXXX';

/*===========================================================================+
 | FUNCTION                                                                  |
 |    product_code                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the product_code                                               |
 |    Returns segment1 from MTL_SYSTEM_ITEMS.                                |
 |    Users may have a different segment for the product code.               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function PRODUCT_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_item_id IN NUMBER,
	p_memo_line_id IN NUMBER)
return VARCHAR2;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    vendor_control_exemptions                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    NOT USED BY VERTEX                                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function VENDOR_CONTROL_EXEMPTIONS (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_trx_type_id IN Number)
return VARCHAR2;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    company_code                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the company_code.                                              |
 |    Constant value of '01'.                                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function COMPANY_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return VARCHAR2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    division_code                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the division_code                                              |
 |    Constant value of '01'.                                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function DIVISION_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return VARCHAR2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    trx_line_type                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the Trx Line type. Constant value of 'SALE'                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function TRX_LINE_TYPE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return VARCHAR2;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    customer_class                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the customer class code of the customer                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function customer_class (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_customer_id IN Number)
return VARCHAR2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_exemptions                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the separated State/County/District/City exemption levels.     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

procedure GET_EXEMPTIONS(
	p_exemption_id             In Number,
	p_cert_no                  Out NOCOPY Varchar2,
	p_State_Exempt_Percent     Out NOCOPY Number,
	p_State_Exempt_Reason      Out NOCOPY Varchar2,
	p_County_Exempt_Percent    Out NOCOPY Number,
	p_County_Exempt_Reason     Out NOCOPY Varchar2,
	p_City_Exempt_Percent      Out NOCOPY Number,
	p_City_Exempt_Reason       Out NOCOPY Varchar2,
	p_District_Exempt_Percent  Out NOCOPY Number,
	p_District_Exempt_Reason   Out NOCOPY Varchar2);



/*===========================================================================+
 | FUNCTION                                                                  |
 |    poo_address_code                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    NOT USED BY VERTEX                                                     |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/


function POO_ADDRESS_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return Varchar2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    poa_address_code                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Concatenates the In/Out City Limits and the Geocode                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/


function POA_ADDRESS_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_salesrep_id IN Number)
return Varchar2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    ship_from_address_code                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Concatenates the In/Out City Limits and the Geocode                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/


function SHIP_FROM_ADDRESS_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_warehouse_id IN Number)
return Varchar2;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    ship_to_address_code                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Concatenates the In/Out City Limits and the Geocode                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function SHIP_TO_ADDRESS_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_ship_to_address_id In Number,
	p_ship_to_location_id In Number,
	p_trx_date In Date,
	p_ship_to_state In Varchar2,
	p_postal_code In Varchar2)
return Varchar2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    audit_flag                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Return appropriate audit_flag                                          |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     20-MAY-99    Toru Kawamura    Created                                 |
 |                                                                           |
 +===========================================================================*/

function AUDIT_FLAG(
        p_view_name IN VARCHAR2,
        p_header_id IN Number,
        p_line_id IN Number)
return Varchar2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    total_tax                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Return total tax amount for an invoice                                 |
 |    This function is used in view TAX_ADJUSTMENTS_V_A and                  |
 |    TAX_ADJUSTMENTS_V_V                                                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-JUN-99    Nilesh Patel     Created                                 |
 |                                                                           |
 +===========================================================================*/

function total_tax(
        p_customer_trx_id IN Number )
        return number;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    customer_code                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the customer code to be passed to Vertex                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-SEP-03    Santosh Vaze      Created                                |
 |     18-MAr-04    Debasis           Bug3486347                             |
 +===========================================================================*/

function customer_code (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return varchar2;
--Bug 3486347 return number;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    transaction_date                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the transaction date to be passed to Vertex                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-Jun-2005 Sanjeev Ahuja      Created                                |
 |                                                                           |
 +===========================================================================*/
function transaction_date (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return DATE;
--Bug 4175816 return date;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    override_parameters                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure will be executed between RESET_PARAMETERS and           |
 |    SET_PARAMETERS in ARP_TAX_VERTEX.calculate and will enable the         |
 |    user to override the parameters set therein                            |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-JUN-99    Nilesh Patel     Created                                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE override_parameters;


/*-----------------------------------------------------------+
       WRITES NO DATABASE STATE
       WRITES NO PROGRAM STATE              PRAGMAS
 +-----------------------------------------------------------*/


end ARP_TAX_VIEW_VERTEX;

 

/
