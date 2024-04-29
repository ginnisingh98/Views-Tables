--------------------------------------------------------
--  DDL for Package Body ARP_TAX_VIEW_VERTEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TAX_VIEW_VERTEX" as
/* $Header: zxtxvwvb.pls 120.8.12010000.2 2008/11/12 12:52:23 spasala ship $ */

USE_SHIP_TO_GEO CONSTANT VARCHAR2(10) := 'XXXXXXXXX';
USE_SHIP_TO_INOUT CONSTANT VARCHAR2(10) := 'X';

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
 |     16-AUG-99    Manoj Gudivaka    11i OE/OM changes:replaced fnd_profile |
 |                                    with oe_profile                        |
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
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.PRODUCT_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.PRODUCT_CODE(+)');
  END IF;

  RETURN NULL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.PRODUCT_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.PRODUCT_CODE(-)');
  END IF;

END PRODUCT_CODE;

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
return VARCHAR2 is
begin
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.VENDOR_CONTROL_EXEMPTIONS',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.VENDOR_CONTROL_EXEMPTIONS(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.VENDOR_CONTROL_EXEMPTIONS',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.VENDOR_CONTROL_EXEMPTIONS',
                      'p_trx_type_id = '||to_char(p_trx_type_id));
  END IF;
  return null;
exception
 when others then
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
	 FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.VENDOR_CONTROL_EXEMPTIONS EXCEPTION ERROR:',
		       g_error_buffer);
    END IF;
end vendor_control_exemptions;


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
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.COMPANY_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.COMPANY_CODE(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.COMPANY_CODE',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
  END IF;
  return NULL;
exception
 when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.COMPANY_CODE EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;
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
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.DIVISION_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.DIVISION_CODE(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.DIVISION_CODE',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
  END IF;
  return '01';
exception
 when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.DIVISION_CODE EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;
end division_code;


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
return VARCHAR2 is
begin
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRX_LINE_TYPE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRX_LINE_TYPE(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRX_LINE_TYPE',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
  END IF;
  return NULL;
exception
 when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRX_LINE_TYPE EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;
end trx_line_type;

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
return VARCHAR2 is
begin
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CLASS',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CLASS(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CLASS',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CLASS',
                      'p_customer_id = '||to_char(p_customer_id));
  END IF;
  return null;
exception
 when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CLASS EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;
end customer_class;


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

PROCEDURE GET_EXEMPTIONS(
        p_exemption_id             In Number,
        p_cert_no                  Out NOCOPY Varchar2,
        p_State_Exempt_Percent     Out NOCOPY Number,
        p_State_Exempt_Reason      Out NOCOPY Varchar2,
        p_County_Exempt_Percent    Out NOCOPY Number,
        p_County_Exempt_Reason     Out NOCOPY Varchar2,
        p_City_Exempt_Percent      Out NOCOPY Number,
        p_City_Exempt_Reason       Out NOCOPY Varchar2,
        p_District_Exempt_Percent  Out NOCOPY Number,
        p_District_Exempt_Reason   Out NOCOPY Varchar2)
IS
BEGIN
   IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.GET_EXEMPTIONS',
             'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.GET_EXEMPTIONS(+)');
   END IF;

   p_cert_no := null;

   p_State_Exempt_Percent    := null;
   p_County_Exempt_percent   := null;
   p_City_Exempt_percent     := null;
   p_District_Exempt_percent := null;

   p_State_Exempt_Reason     := null;
   p_County_Exempt_Reason    := null;
   p_City_Exempt_Reason      := null;
   p_District_Exempt_Reason  := null;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.GET_EXEMPTIONS',
             'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.GET_EXEMPTIONS(-)');
   END IF;

END GET_EXEMPTIONS;


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
return Varchar2 is
begin
IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POO_ADDRESS_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POO_ADDRESS_CODE(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POO_ADDRESS_CODE',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
  END IF;
  return null;
exception
  when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POO_ADDRESS_CODE EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;

end POO_ADDRESS_CODE;



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
return Varchar2 is
 begin
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POA_GEOCODE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POA_GEOCODE(+)');
   END IF;
   IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POA_GEOCODE',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POO_GEOCODE',
                      'p_salesrep_id = '||to_char(p_salesrep_id));
   END IF;
  return NULL;
exception
  when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.POA_GEOCODE EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;
end;

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
return Varchar2 is
begin
   IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_FROM_ADDRESS_CODE',
					'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_FROM_ADDRESS_CODE(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_FROM_ADDRESS_CODE',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_FROM_ADDRESS_CODE',
                     'p_warehouse_id = '||to_char(p_warehouse_id));
  END IF;
  return NULL;
exception
  when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_FROM_ADDRESS_CODE EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;
end;

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
return Varchar2 is
  l_inout Boolean;
  l_geocode Varchar2(30);
begin
 /* if arp_process_tax.vendor_installed_flag = 'N' then
	return NULL;
  end if;*/
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_TO_ADDRESS_CODE',
                                        'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_TO_ADDRESS_CODE(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_TO_ADDRESS_CODE',
                      'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_TO_ADDRESS_CODE',
                      'p_ship_to_address_id = '||to_char(p_ship_to_address_id)||'p_ship_to_location_id = '||to_char(p_ship_to_location_id));
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_TO_ADDRESS_CODE',
                      'p_trx_date = '||p_trx_date||' p_ship_to_state = '||p_ship_to_state||'p_postal_code = '||p_postal_code);
  END IF;

  return NULL;
exception
  when others then
   g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.SHIP_TO_ADDRESS_CODE EXCEPTION ERROR:',
		       g_error_buffer);
   END IF;
end;

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
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.AUDIT_FLAG',
                                        'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.AUDIT_FLAG(+)');
  END IF;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.AUDIT_FLAG',
                                        'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.AUDIT_FLAG(-)');
  END IF;
  return null;
exception
When others then
  g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
  IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.AUDIT_FLAG EXCEPTION ERROR:',
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
begin
   IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TOTAL_TAX',
                                        'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TOTAL_TAX(+)');
   END IF;
   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TOTAL_TAX',
                      ' p_customer_trx_id = '||to_char(p_customer_trx_id));
   END IF;

   return null;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TOTAL_TAX',
                                        'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TOTAL_TAX(-)');
   END IF;
   exception
        when others then
        return 0;
end total_tax;

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
 |                                                                           |
 +===========================================================================*/

function customer_code (
	p_view_name IN VARCHAR2,
	p_header_id IN Number,
	p_line_id IN Number)
return  VARCHAR2
-- Bug3486347return NUMBER
is
begin
/* Santosh */
   IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CODE',
                                        'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CODE(+)');
    END IF;
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CODE',
                     'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
    END IF;
    return null;
exception
 when others then
  g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
  IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.CUSTOMER_CODE EXCEPTION ERROR:',
		       g_error_buffer);
  END IF;
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
  IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRANSACTION_DATE',
                                        'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRANSACTION_DATE(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_statement, 'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRANSACTION_DATE',
                     'p_view_name = '||p_view_name||' p_header_id = '||to_char(p_header_id)||' p_line_id = '||to_char(p_line_id));
  END IF;
  return null;
exception
 when others then
  g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
  IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,'ZX.PARTNER.ARP_TAX_VIEW_VERTEX.TRANSACTION_DATE EXCEPTION ERROR:',
		       g_error_buffer);
  END IF;
end transaction_date;

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

PROCEDURE override_parameters is
Begin
NULL;
End override_parameters;
--2662879

END ARP_TAX_VIEW_VERTEX;

/
