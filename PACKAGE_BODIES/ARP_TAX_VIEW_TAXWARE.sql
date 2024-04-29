--------------------------------------------------------
--  DDL for Package Body ARP_TAX_VIEW_TAXWARE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TAX_VIEW_TAXWARE" as
/* $Header: zxtxvwab.pls 120.8 2006/10/06 11:41:08 vchallur ship $ */

USE_SHIP_TO_GEO CONSTANT VARCHAR2(10) := 'XXXXXXXXX';

G_CURRENT_RUNTIME_LEVEL CONSTANT  NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
g_error_buffer                    VARCHAR2(100);

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
 |     12-AUG-99    Manoj Gudivaka    OE/OM change : replaced fnd_profile    |
 |                                    with oe_profile for profile            |
 |                                    SO_ORGANIZATION_ID                     |
 |                                                                           |
 +===========================================================================*/

function PRODUCT_CODE(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_item_id IN NUMBER,
	p_memo_line_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.PRODUCT_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.PRODUCT_CODE(+)');
  END IF;

  RETURN to_char(NULL);

  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.PRODUCT_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.PRODUCT_CODE(-)');
  END IF;

END PRODUCT_CODE;


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
return VARCHAR2 is
begin
  return null;
end company_code;

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
return VARCHAR2 is
begin
  return null;
end division_code;


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

function VENDOR_CONTROL_EXEMPTIONS(
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number,
	p_trx_type_id In Number)
return VARCHAR2 is
begin

  return null;
end vendor_control_exemptions;



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
return VARCHAR2
is
begin
 return null;
end Use_Nexpro;

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
return NUMBER
is
begin
return NULL;
/*This function is obsoleted*/
end Use_secondary;





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
return NUMBER
is
begin
   return null;
end tax_sel_parm;

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
return NUMBER
is
begin
     return null;
end tax_type;*/

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
return NUMBER
is
begin
   return null;
end SERVICE_INDICATOR;


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
	p_Crit_Flag Out NOCOPY Varchar2)
is
begin
  NULL;
end get_exemptions;





/*===========================================================================+
 | FUNCTION                                                                  |
 |    poa_address_code                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns POA Geocode                                                    |
 |    Character 1 = In/Out City Limits                                       |
 |    Character 2-10 = Geocode                                               |
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
return Varchar2 is
  begin
return NULL;
end poa_address_code;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    poo_address_code                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns POO Geocode                                                    |
 |    Character 1 = In/Out City Limits                                       |
 |    Character 2-10 = Geocode                                               |
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
return Varchar2 is

begin
return NULL;
end poo_address_code;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    ship_from_address_code                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns Ship From Geocode                                              |
 |    Character 1 = In/Out City Limits                                       |
 |    Character 2-10 = Geocode                                               |
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
return Varchar2 is
  l_geocode Varchar2(10);
begin
return NULL;
end ship_from_address_code;

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
return Varchar2 is
  l_geocode Varchar2(10);
begin
return NULL;
end ship_to_address_code;


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
function Calculation_Flag (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return Varchar2 is
 begin
 return NULL;
end Calculation_Flag;

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
return Varchar2 is
  l_audit_flag  Varchar2(10);
begin
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.AUDIT_FLAG',
                                        'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.AUDIT_FLAG(+)');
  END IF;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.AUDIT_FLAG',
                                        'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.AUDIT_FLAG(-)');
  END IF;
  return null;
exception
When others then
  g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
  IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_TAXWARE.AUDIT_FLAG EXCEPTION ERROR:',
       g_error_buffer);
  END IF;
end audit_flag;

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
        p_customer_trx_id IN Number
                   )
        return number is
        l_amount number;
begin
        return 0;
	/*This function obsoleted*/
end total_tax;



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
 |     16-JUL-04    Debasis Choudhuri        BUG 3768303                     |
 |                                                                           |
 +===========================================================================*/

function customer_code (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return VARCHAR2

is
begin
     return NULL;
end customer_code;

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
return  DATE
-- Bug 4175816 return DATE
is
begin
      return NULL;
end transaction_date;

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
return VARCHAR2
is
begin
    return NULL;
end customer_name;

end ARP_TAX_VIEW_TAXWARE;

/
