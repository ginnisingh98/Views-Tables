--------------------------------------------------------
--  DDL for Package Body AP_XML_TAX_DERIVATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_XML_TAX_DERIVATION_PKG" as
/* $Header: aptxderb.pls 120.2 2004/10/29 19:06:14 pjena noship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Name : CORRECT_TAX                                                     |
 |    Called by AP_XML_INVOICE_INBOUND_PKG                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This package gets the tax code for the Receiving country and State and |
 |    AP_INVOICE_LINES_INTERFACE is updated with this tax code.              |
 |    Note : If Tax Code is Null, we use  <State>-Taxable  as the tax code   |           |                                                                           |
 +===========================================================================*/
PROCEDURE correct_tax(p_invoice_id in NUMBER, p_vendor_id in NUMBER) as

  cursor num_of_tax_lines is
    select count(*) from ap_invoice_lines_interface
    where invoice_id = p_invoice_id and
          line_type_lookup_code = 'TAX';

  cursor org_id is
    select org_id from ap_invoices_interface
    where invoice_id = p_invoice_id;

  cursor ship_to(p_po_number in VARCHAR2, p_org_id in NUMBER) is
    select hl.country, hl.region_2
    from po_line_locations_all poll,
         po_lines_all pol,
         po_headers_all poh,
         hr_locations_all hl
    where
         poh.org_id = p_org_id and
         poh.segment1= p_po_number and
         pol.po_header_id =poh.po_header_id and
         poll.po_line_id=pol.po_line_id and
         poll.ship_to_location_id = hl.location_id
    order by pol.line_num;

  cursor tax_code(p_country in VARCHAR2,
                  p_state in VARCHAR2,
                  p_vendor_id in NUMBER) is
    select tax_code
    from ap_tax_derivations
    where receiving_country = p_country
    and receiving_state = p_state
    and vendor_id = p_vendor_id;

  cursor po_number is
    select distinct po_number
    from ap_invoice_lines_interface
    where invoice_id = p_invoice_id and
          po_number is not null;

  type char_table_type is table of varchar2(256) index by binary_integer;
  l_countries char_table_type;
  l_states char_table_type;
  l_num_of_tax_lines NUMBER;
  l_invoice_line_id NUMBER;
  l_org_id NUMBER;
  l_tax_code VARCHAR2(30);
  l_po_numbers char_table_type;

begin
  arp_util_tax.debug('AP_XML_TAX_DERIVATION_PKG.correct_tax(+)');
  arp_util_tax.debug('p_invoice_id:'||to_char(p_invoice_id));
  arp_util_tax.debug('p_vendor_id:'||to_char(p_vendor_id));
  --
  open num_of_tax_lines;
  fetch num_of_tax_lines into l_num_of_tax_lines;
  close num_of_tax_lines;
  --
  open po_number;
  fetch po_number bulk collect into l_po_numbers;
  close po_number;
  --
  open org_id;
  fetch org_id into l_org_id;
  close org_id;

  arp_util_tax.debug('num_of_tax_lines:'||to_char(l_num_of_tax_lines));

  if l_num_of_tax_lines = 0 and nvl(l_po_numbers.last, 0) = 1 then
    select ap_invoice_lines_interface_s.nextval
    into l_invoice_line_id
    from dual ;

    INSERT INTO AP_INVOICE_LINES_INTERFACE
      (ORG_ID, INVOICE_ID, INVOICE_LINE_ID, AMOUNT,
       LINE_NUMBER, LINE_TYPE_LOOKUP_CODE)
    VALUES
      (l_org_id, p_invoice_id, l_invoice_line_id, 0, NULL, 'TAX');
    commit;
    l_num_of_tax_lines := 1;
  end if;

  if l_num_of_tax_lines = 1 and
     nvl(l_po_numbers.last, 0) = 1 then

    arp_util_tax.debug('po_number:'||l_po_numbers(1));
    arp_util_tax.debug('org_id:'||to_char(l_org_id));

    open ship_to(l_po_numbers(1), l_org_id);
    fetch ship_to bulk collect into l_countries, l_states;
    close ship_to;

    if nvl(l_countries.last, 0) <> 0 then
      arp_util_tax.debug('country:'||l_countries(1));
      arp_util_tax.debug('state:'||l_states(1));

      open tax_code(l_countries(1), l_states(1), p_vendor_id);
      fetch tax_code into l_tax_code;
      close tax_code;


      if l_tax_code is null then
        l_tax_code := l_states(1)||'-Taxable';
      end if;

      arp_util_tax.debug('tax_code:'||l_tax_code);

      UPDATE AP_INVOICE_LINES_INTERFACE
      SET TAX_CODE = l_tax_code
      WHERE INVOICE_ID = p_invoice_id and
            TAX_CODE is NULL;
    end if;
  end if;
  --
  arp_util_tax.debug('AP_XML_TAX_DERIVATION_PKG.correct_tax(-)');
end;

END AP_XML_TAX_DERIVATION_PKG;

/
