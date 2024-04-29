--------------------------------------------------------
--  DDL for Package AP_XML_INVOICE_INBOUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_XML_INVOICE_INBOUND_PKG" AUTHID CURRENT_USER as
/* $Header: apxmlins.pls 120.1 2004/10/29 19:19:33 pjena noship $ */

function get_token_display_field(p_lookup_code in VARCHAR2) return VARCHAR2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    start_open_interface                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway's post process trigger. This starts open interface.|
 +===========================================================================*/
procedure start_open_interface;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    notify_supplier                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by Open interface to start Workflow notification.                |
 +===========================================================================*/

procedure send_email(p_mail_subject in VARCHAR2,
                     p_mail_content in VARCHAR2,
                     p_mail_address in VARCHAR2);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    send_email                                                             |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


procedure notify_supplier(p_request_id in NUMBER,
                          p_calling_sequence VARCHAR2);
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    notify_recipient                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by the request set                                               |
 +===========================================================================*/
procedure notify_recipient(p_errbuf out NOCOPY VARCHAR2, p_return_code out NOCOPY VARCHAR2);
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    change_case                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to change the case                                 |
 +===========================================================================*/
procedure change_case(p_in_string in  VARCHAR2,
                      p_out_string out NOCOPY VARCHAR2,
                      p_direction in VARCHAR2 default 'U');
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    derive_org_id                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to derive org_id                                   |
 +===========================================================================*/
procedure derive_org_id(p_po_number in VARCHAR2 default NULL,
                        p_org_id out NOCOPY NUMBER);
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    derive_vendor_id                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to derive vendor_id                                |
 +===========================================================================*/
procedure derive_vendor_id(p_vendor_site_id in NUMBER,
                           p_org_id in NUMBER,
                           p_vendor_id out NOCOPY NUMBER);
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    derive_email_address                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to derive email_address                            |
 +===========================================================================*/
procedure derive_email_address(p_vendor_site_id in NUMBER,
                               p_vendor_id in NUMBER,
                               p_email_address out NOCOPY VARCHAR2);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    after_map                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    Used at the end of map                                                 |
 +===========================================================================*/
procedure after_map(p_group_id in VARCHAR2);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_taxable_flag2                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    Used in the map.                                                       |
 |    Set taxable_flag='Y' for the given item line                           |
 +===========================================================================*/
procedure set_taxable_flag2(p_item_line_id in NUMBER);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    correct_charge_type                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    changes p_charge_type to either FREIGHT or MISCELLANEOUS               |
 +===========================================================================*/
procedure correct_charge_type(p_charge_type in out NOCOPY VARCHAR2);


END AP_XML_INVOICE_INBOUND_PKG ;

 

/
