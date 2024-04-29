--------------------------------------------------------
--  DDL for Package ARP_TAX_VIEW_TAXWARE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TAX_VIEW_TAXWARE" AUTHID CURRENT_USER as
/* $Header: zxtxvwas.pls 120.2 2006/10/06 11:41:38 vchallur ship $ */

USE_SHIP_TO CONSTANT VARCHAR2(10) := 'XXXXXXXXXX';
/* Bug 2158220 */
g_usenexpro   VARCHAR2(100);
g_sectaxs   NUMBER;
g_taxselparam   NUMBER;
g_taxtype   NUMBER;
g_serviceind   NUMBER;
g_orgid   NUMBER;



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
 |    company_code                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the company_code.                                              |
 |    Constant value of null.                                                |
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
 |    Constant value of 'D_CODE'.                                            |
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
 |    vendor_control_exemptions                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the Job No. ATTRIBUTE1 of ra_cust_trx_types                    |
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
	p_trx_type_id In Number)
return VARCHAR2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    use_nexpro                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the use nexpro flag.                                           |
 |    'Y' - use Nexpro                                                       |
 |    'N' - use Nexpro                                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function Use_Nexpro (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return VARCHAR2;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    use_secondary                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the use Secondary taxes flag                                   |
 |    1 = Use secondary taxes                                                |
 |    2 = Do not use secondary taxes                                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function Use_Secondary (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return NUMBER;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    Tax_Sel_Parm                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the Tax Selection parameter flag                               |
 |    2 = Use only ship-to address                                           |
 |    3 = Use only all jurisdications                                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function Tax_Sel_Parm (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return NUMBER;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    Tax_Type                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the tax type.                                                  |
 |    '1' = Sales Tax                                                        |
 |    '2' = Use Tax                                                          |
 |    '3' = Rental                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

/*As per Taxware recommendation, removing this function*/
/*function Tax_Type (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return NUMBER;*/


/*===========================================================================+
 | FUNCTION                                                                  |
 |    Service_Indicator                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the service indicator flag                                     |
 |    1 = Service                                                            |
 |    2 = Rental                                                             |
 |    3 = Non-Service                                                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

function Service_Indicator (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return NUMBER;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_exemptions                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the separated State/County/City/Sec Cnty/Sec City              |
 |    exemption levels.                                                      |
 |    Also returns the STEP90 flags - UseStep, StepProcFlag, CritFlag        |
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/

procedure GET_EXEMPTIONS(
	p_exemption_id In Number,
	p_State_Exempt_Percent Out NOCOPY Number,
	p_State_Exempt_Reason Out NOCOPY Varchar2,
	p_State_Cert_No Out NOCOPY Varchar2,
	p_County_Exempt_Percent Out NOCOPY Number,
	p_County_Exempt_Reason Out NOCOPY Varchar2,
	p_County_Cert_No Out NOCOPY Varchar2,
	p_City_Exempt_Percent Out NOCOPY Number,
	p_City_Exempt_Reason Out NOCOPY Varchar2,
	p_City_Cert_No Out NOCOPY Varchar2,
	p_Sec_County_Exempt_Percent Out NOCOPY Number,
	p_Sec_City_Exempt_Percent Out NOCOPY Number,
	p_Use_Step Out NOCOPY Varchar2,
	p_Step_Proc_Flag Out NOCOPY Varchar2,
	p_Crit_Flag Out NOCOPY Varchar2);




/*===========================================================================+
 | FUNCTION                                                                  |
 |    poa_address_code                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns POA Geocode                                                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/


function POA_ADDRESS_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)

return Varchar2;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    poo_address_code                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns POO Geocode                                                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/


function POO_ADDRESS_CODE(
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
 |    Returns Ship From Geocode                                              |
 |                                                                           |
 | SCOPE - Private                                                           |
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
 |    Returns Ship To Geocode                                                |
 |    Character 1 = In/Out City Limits                                       |
 |    Character 2-10 = Geocode                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
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
 |    Calculation_Flag                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the levels that tax should be calculated at                    |
 |    Character 1 = Calculate tax at State                                   |
 |    Character 2 = Calculate tax at County                                  |
 |    Character 3 = Calculate tax at City                                    |
 |    Character 4 = Calculate tax at Secondary County                        |
 |    Character 5 = Calculate tax at Secondary City                          |
 |    0 = Calculate tax                                                      |
 |    1 = Do not Calculate tax                                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     09-DEC-97    Kenichi Mizuta    Created                                |
 |                                                                           |
 +===========================================================================*/
function Calculation_Flag(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
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
 |    Returns the customer code to be passed to Taxware                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-SEP-03    Santosh Vaze      Created (Bug # 3139351)                |
 |     16-JUL-04    Debasis                         bug 3768303              |
 |                                                                           |
 +===========================================================================*/

function customer_code (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return varchar2;
--3768303 return number;


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
 | FUNCTION                                                                  |
 |    customer_name                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the customer name to be passed to Taxware                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-SEP-03    Santosh Vaze      Created (Bug # 3139351)                |
 |                                                                           |
 +===========================================================================*/

function customer_name (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return varchar2;


/*-----------------------------------------------------------+
       WRITES NO DATABASE STATE
       WRITES NO PROGRAM STATE              PRAGMAS
 +-----------------------------------------------------------*/

-- Needed to comment out the following pragma for 11.5 OE/OM changes
-- in the Package Body

end ARP_TAX_VIEW_TAXWARE;

 

/
