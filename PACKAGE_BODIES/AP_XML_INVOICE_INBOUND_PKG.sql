--------------------------------------------------------
--  DDL for Package Body AP_XML_INVOICE_INBOUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_XML_INVOICE_INBOUND_PKG" as
/* $Header: apxmlinb.pls 120.2.12010000.2 2009/10/13 22:23:14 gagrawal ship $ */

function get_token_display_field(p_lookup_code in VARCHAR2) return VARCHAR2 as

  l_displayed_field VARCHAR2(80);
  cursor l_token_csr(c_lookup_code in VARCHAR2) is
	select 	displayed_field
	from 	ap_lookup_codes
	where 	lookup_type = 'XML TOKEN NAME'
          and 	lookup_code = p_lookup_code;

begin
  open l_token_csr(p_lookup_code);
  fetch l_token_csr into l_displayed_field;
  close l_token_csr;
  return l_displayed_field;
end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    correct_freight_line                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 +===========================================================================*/
procedure correct_freight_line(p_invoice_id in NUMBER) as

begin
  ap_debug_pkg.print('Y',
                     'AP_XML_INVOICE_INBOUND_PKG.correct_freight_line(+)');

  update ap_invoice_lines_interface
  set DIST_CODE_COMBINATION_ID =
    (select FREIGHT_CODE_COMBINATION_ID
     from ap_system_parameters_all sys,ap_invoices_interface h
     where sys.org_id = h.org_id and h.invoice_id = p_invoice_id)
  where line_type_lookup_code = 'FREIGHT' and
        invoice_id = p_invoice_id;

  ap_debug_pkg.print('Y',
                     'AP_XML_INVOICE_INBOUND_PKG.correct_freight)lihe(-)');
end;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    correct_line_type                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 +===========================================================================*/
procedure correct_line_type(p_invoice_id in number) as
begin
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND.correct_line_type(+)');
  --
  UPDATE AP_INVOICE_LINES_INTERFACE
  SET LINE_TYPE_LOOKUP_CODE = 'MISCELLANEOUS'
  WHERE LINE_TYPE_LOOKUP_CODE NOT IN ('ITEM', 'TAX', 'FREIGHT') and
        INVOICE_ID = p_invoice_id;
  --
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND.correct_line_type(-)');
end;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    change_case                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to change the case                                 |
 +===========================================================================*/

procedure change_case(p_in_string in VARCHAR2,
                      p_out_string out NOCOPY VARCHAR2,
                      p_direction in VARCHAR2 default 'U') as

begin
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.change_case(+)');

  if p_direction = 'U' then
    p_out_string := upper(p_in_string);
  elsif p_direction = 'L' then
    p_out_string := lower(p_in_string);
  else
    null;
  end if;

  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.change_case(-)');
end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    derive_org_id                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to derive org_id                                   |
 +===========================================================================*/
procedure derive_org_id(p_po_number in VARCHAR2 default NULL,
                        p_org_id out NOCOPY NUMBER) as
  l_org_id NUMBER;
begin
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.derive_org_id(+)');
  begin
    select distinct org_id into l_org_id
    from po_headers_all
    where segment1 = p_po_number;
  exception
    when others then
      ap_debug_pkg.print('Y',
                       'AP_XML_INVOICE_INBOUND_PKG.derive_org_id(EXCEPTION)');
     l_org_id := NULL;
  end;
  p_org_id := l_org_id;
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.derive_org_id(-)');
end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    derive_vendor_id                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to derive vendor_id                                |
 +===========================================================================*/
procedure derive_vendor_id(p_vendor_site_id in NUMBER,
                           p_org_id in NUMBER,
                           p_vendor_id out NOCOPY NUMBER) as
begin
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.derive_vendor_id(+)');
  select vendor_id into p_vendor_id
  from po_vendor_sites_all
  where org_id = p_org_id and vendor_site_id = p_vendor_site_id;
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.derive_vendor_id(-)');
exception
  when others then
    ap_debug_pkg.print('Y',
                    'AP_XML_INVOICE_INBOUND_PKG.derive_vendor_id(EXCEPTION)');
    p_vendor_id := NULL;
end;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    derive_email_address                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway to derive email_address                            |
 +===========================================================================*/
procedure derive_email_address(p_vendor_site_id in NUMBER,
                               p_vendor_id in NUMBER,
                               p_email_address out NOCOPY VARCHAR2) as
-- Bug 2079388
l_statement VARCHAR2(2000) ;
l_party_type varchar2(1) := 'S';


begin
    ap_debug_pkg.print('Y',
                       'AP_XML_INVOICE_INBOUND_PKG.derive_email_address(+)');

/* Bug 2079388
   Replace the sql below with dynamic sql to prevent dependency on XML
   datamodel in some cases. Details mentioned in the bug

    select company_admin_email
    into p_email_address
    from ecx_tp_headers
    where party_type = 'S' and
          party_site_id = p_vendor_site_id and
          party_id = p_vendor_id;
    ap_debug_pkg.print('Y',
                       'AP_XML_INVOICE_INBOUND_PKG.derive_email_address(-)');

*/
    l_statement :=
'SELECT  company_admin_email INTO :tab FROM ecx_tp_headers
    where party_site_id = ' || p_vendor_site_id ||
          ' and party_id = ' || p_vendor_id ||
          ' and party_type = '|| ''''|| l_party_type || '''';

    l_statement := 'BEGIN ' || l_statement;
    l_statement := l_statement || '; END;';

    EXECUTE IMMEDIATE l_statement USING OUT p_email_address ;


exception
  when others then
    ap_debug_pkg.print('Y',
                'AP_XML_INVOICE_INBOUND_PKG.derive_email_address(EXCEPTION)');
    p_email_address := NULL;
end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    start_open_interface                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by XMLGateway's post process trigger. This starts open interface.|
 +===========================================================================*/
procedure start_open_interface as

  l_request_id number;
  type num_table_type is table of number index by binary_integer;
  l_inv_ids num_table_type;
  l_vendor_ids num_table_type;
  l_tax_code varchar2(30);

  cursor inv_csr is
    select h.invoice_id, h.vendor_id
    from   ap_invoices_interface h
    where  h.source like 'XML GATEWAY' and
           h.status is NULL and
           h.vendor_name is NOT NULL;

begin
  ap_debug_pkg.print('Y',
                     'AP_XML_INVOICE_INBOUND_PKG.start_open_interface(+)');

    open inv_csr;
    fetch inv_csr bulk collect into l_inv_ids, l_vendor_ids;
    close inv_csr;

    forall i in nvl(l_inv_ids.first,1)..nvl(l_inv_ids.last,0)
        update ap_invoices_interface
        set vendor_name = null
        where invoice_id = l_inv_ids(i);
     --
     -- populate tax_code for line_type tax
     -- fix line type lookup code
     --
    for i in nvl(l_inv_ids.first,1)..nvl(l_inv_ids.last,0) loop
      --
      correct_line_type(l_inv_ids(i));
      --
-- Bug 2186813, part of obsoleting tax defaulting based on the p2p tax
-- setup form
     --   AP_XML_TAX_DERIVATION_PKG.correct_tax(l_inv_ids(i), l_vendor_ids(i));
      --
      correct_freight_line(l_inv_ids(i));


    end loop;
  commit;

  --
  -- Request is scheduled as a request set.
  --
  /*
  l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                    application=>'SQLAP',
                    program=> 'APXIIMPT',
                    sub_request=>FALSE,
                    argument1=>'XML GATEWAY');
  arp_util_tax.debug('Request_id:'||l_request_id);
  */
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.start_open_interface(-)');
end;


procedure send_email(p_mail_subject in VARCHAR2,
                     p_mail_content in VARCHAR2,
                     p_mail_address in VARCHAR2) as

  l_role                        VARCHAR2(100);
  l_display_role_name           VARCHAR2(100);
  l_item_key                    VARCHAR2(100);

begin
    ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.send_email(+)');
    arp_util_tax.debug('Creating adhoc role(+)');
    l_role := null;
    l_display_role_name := null;
    WF_DIRECTORY.createAdhocRole(role_name => l_role,
                                 role_display_name => l_display_role_name,
                                 email_address => p_mail_address,
                                 notification_preference => 'MAILTEXT');
    ap_debug_pkg.print('Y','Creating adhoc role(-)');
    --
    -- Creating a workflow process
    --
    select ap_p2p_inbound_notification_s.nextval into l_item_key from dual;
    ap_debug_pkg.print('Y','Creating a workflow process(+)');
    WF_ENGINE.createProcess('P2P',l_item_key, 'PROCESS_FOR_NOTIFICATION');

    ap_debug_pkg.print('Y','Creating a workflow process(-)');
    --
    -- Initializing attributes
    --
    ap_debug_pkg.print('Y','Initializing Mail Subject (+)');
    ap_debug_pkg.print('Y','subject:'||p_mail_subject);

    WF_ENGINE.setItemAttrText('P2P',l_item_key, 'MAIL_SUBJECT',p_mail_subject);
    ap_debug_pkg.print('Y','Initializing Mail Subject (-)');

    ap_debug_pkg.print('Y','Initializing Mail Header (+)');
    WF_ENGINE.setItemAttrText('P2P',l_item_key, 'MAIL_HEADER',NULL);
    ap_debug_pkg.print('Y','Initializing Mail Header (-)');

    ap_debug_pkg.print('Y','Initializing Mail Content (+)');
    WF_ENGINE.setItemAttrText('P2P',
                             l_item_key,'MAIL_CONTENT1', p_mail_content);

    ap_debug_pkg.print('Y','Initializing Mail Content (-)');

    ap_debug_pkg.print('Y','Initializing Adhoc Role(+)');
    WF_ENGINE.setItemAttrText('P2P',l_item_key,'ADHOC_ROLE',l_role);
    ap_debug_pkg.print('Y','Initializing Adhoc Role(-)');

    --
    -- Starting the process
    --
    ap_debug_pkg.print('Y','Starting the process(+)');
    WF_ENGINE.startProcess('P2P', l_item_key);
    ap_debug_pkg.print('Y','Starting the process(-)');
    ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.send_email(-)');

   commit;
end;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    notify_supplier                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by Open interface to start Workflow notification.                |
 +===========================================================================*/
procedure notify_supplier(p_request_id in NUMBER,
                          p_calling_sequence VARCHAR2) as

  cursor l_invoice_line_number_csr is
    select 	fnd_global.tab||displayed_field||': '
    from  	ap_lookup_codes
    where 	lookup_type = 'XML TOKEN NAME' and
                lookup_code = 'INVOICE LINE NUMBER';

  cursor l_invoice_number_csr is
    select 	displayed_field||': '
    from  	ap_lookup_codes
    where 	lookup_type = 'XML TOKEN NAME' and
                lookup_code = 'INVOICE NUMBER';

  cursor l_email_csr(c_request_id in NUMBER) is
    select 	distinct vendor_email_address
    from 	ap_invoices_interface
    where 	request_id = c_request_id
    and         vendor_email_address is not null; --bug4065112

  cursor l_message_csr(c_request_id in NUMBER,
                       c_vendor_email_address in VARCHAR2) is
    select 	h.invoice_id, to_number(null),h.invoice_num, to_number(null),
		fnd_global.tab||fnd_global.tab||lc.description||
		decode(r.token_name1,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name1)
                          ||': '||r.token_value1) ||
		decode(r.token_name2,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name2)
                          ||': '||r.token_value2) ||
		decode(r.token_name3,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name3)
                          ||': '||r.token_value3) ||
		decode(r.token_name4,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name4)
                          ||': '||r.token_value4) ||
		decode(r.token_name5,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name5)
                          ||': '||r.token_value5) ||
		decode(r.token_name6,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name6)
                          ||': '||r.token_value6) ||
		decode(r.token_name7,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name7)
                          ||': '||r.token_value7) ||
		decode(r.token_name8,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name8)
                          ||': '||r.token_value8) ||
		decode(r.token_name9,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name9)
                          ||': '||r.token_value9) ||
		decode(r.token_name10, null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name10)
                          ||': '||r.token_value10)||
                fnd_global.newline
     -- Bug  4065112 starts
               ,group_id, external_doc_ref
     -- Bug  4065112 ends

    from	ap_invoices_interface h,
		ap_interface_rejections r,
		ap_lookup_codes lc
    where	h.request_id = c_request_id
    and         nvl(r.notify_vendor_flag, 'N') = 'Y'
    and 	h.invoice_id = r.parent_id
    and         r.parent_table = 'AP_INVOICES_INTERFACE'
    and 	h.vendor_email_address = c_vendor_email_address
    and		lc.lookup_code = r.reject_lookup_code
    and		lc.lookup_type = 'REJECT CODE'
    union all
    select 	h.invoice_id, l.invoice_line_id,h.invoice_num, l.line_number,
		fnd_global.tab||fnd_global.tab||lc.description||
		decode(r.token_name1,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name1)
                          ||': '||r.token_value1) ||
		decode(r.token_name2,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name2)
                          ||': '||r.token_value2) ||
		decode(r.token_name3,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name3)
                          ||': '||r.token_value3) ||
		decode(r.token_name4,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name4)
                          ||': '||r.token_value4) ||
		decode(r.token_name5,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name5)
                          ||': '||r.token_value5) ||
		decode(r.token_name6,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name6)
                          ||': '||r.token_value6) ||
		decode(r.token_name7,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name7)
                          ||': '||r.token_value7) ||
		decode(r.token_name8,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name8)
                          ||': '||r.token_value8) ||
		decode(r.token_name9,  null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name9)
                          ||': '||r.token_value9) ||
		decode(r.token_name10, null, null,
                       fnd_global.newline||fnd_global.tab||fnd_global.tab||
                       get_token_display_field(r.token_name10)
                          ||': '||r.token_value10)||
                fnd_global.newline
     -- Bug 4065112 starts
     ,group_id, external_doc_ref
     -- Bug 4065112  ends
    from	ap_invoices_interface h,
                ap_invoice_lines_interface l,
		ap_interface_rejections r,
		ap_lookup_codes lc
    where	h.request_id = c_request_id
    and         h.invoice_id = l.invoice_id
    and         nvl(r.notify_vendor_flag, 'N') = 'Y'
    and 	l.invoice_line_id = r.parent_id
    and         r.parent_table = 'AP_INVOICE_LINES_INTERFACE'
    and 	h.vendor_email_address = c_vendor_email_address
    and		lc.lookup_code = r.reject_lookup_code
    and		lc.lookup_type = 'REJECT CODE'
    order by 1, 2;

  l_vendor_email_address 	VARCHAR2(2000);
  l_message_line  		VARCHAR2(2000);

  type email_and_message_rec is RECORD(
    vendor_email_address	VARCHAR2(2000),
    message			VARCHAR2(32000)
  );

  type email_and_message_table_type
      is table of email_and_message_rec index by binary_integer;
  l_email_and_message_table	email_and_message_table_type;

  type message_table_type is table of VARCHAR2(4000) index by binary_integer;
  l_message_table message_table_type;

  l_invoice_id_table ap_utilities_pkg.number_table_type;
  l_invoice_line_id_table ap_utilities_pkg.number_table_type;

  l_message			VARCHAR2(32000);
  l_index 			NUMBER := 0;
  l_item_key			VARCHAR2(100);
  l_role			VARCHAR2(100);
  l_display_role_name		VARCHAR2(100);
  l_temp_string			VARCHAR2(1000);
  l_invoice_id			NUMBER;
  l_invoice_line_id		NUMBER;
  l_invoice_index		NUMBER := 0;
  l_invoice_line_index		NUMBER := 0;
  l_prev_invoice_id		NUMBER;
  l_prev_invoice_line_id	NUMBER;
  l_result			boolean;
  l_invoice_number		VARCHAR2(30);
  l_invoice_number_tmp		VARCHAR2(50);
  l_org_id			NUMBER;
  l_invoice_line_number		VARCHAR2(30);
  l_invoice_line_number_tmp	NUMBER;
  -- Bug 4065112  starts
  l_group_id            ap_invoices_interface.group_id%TYPE;
  l_external_doc_ref    ap_invoices_interface.external_doc_ref%TYPE;
  l_call_3c4_invoice_id ap_invoices_interface.invoice_id%TYPE;
  -- Bug 4065112 ends

begin
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.notify_supplier(+)');
  ap_debug_pkg.print('Y','request_id: '||to_char(p_request_id));
  --
  open l_invoice_number_csr;
  fetch l_invoice_number_csr into l_invoice_number;
  close l_invoice_number_csr;
  --
  open l_invoice_line_number_csr;
  fetch l_invoice_line_number_csr into l_invoice_line_number;
  close l_invoice_line_number_csr;
  --
  -- Create table of email address and message.
  --
  open l_email_csr(p_request_id);
  loop
    fetch l_email_csr into l_vendor_email_address;
    exit when l_email_csr%notfound;
    ap_debug_pkg.print('Y','distinct email:'||l_vendor_email_address);
    --
    open l_message_csr(p_request_id, l_vendor_email_address);
    loop
      fetch l_message_csr into l_invoice_id, l_invoice_line_id,
            l_invoice_number_tmp, l_invoice_line_number_tmp, l_message_line,
                                --Bug 4065112 starts
                                 l_group_id, l_external_doc_ref;
                                 --Bug 4065112 ends

      exit when l_message_csr%notfound;
      --
      ap_debug_pkg.print('Y','invoice_num:'||l_invoice_number_tmp);
      --
      -- SQL is ordered by invoice_id and invoice_line_id
      --
      if (l_invoice_line_id is null and
          l_invoice_id <> nvl(l_prev_invoice_id,0)) then
        l_invoice_index := l_invoice_index + 1;
        l_prev_invoice_id := l_invoice_id;
        l_prev_invoice_line_id := NULL;
        l_invoice_id_table(l_invoice_index) := l_invoice_id;
        --
        ap_debug_pkg.print('Y','New Invoice');
          -- Bug 4065112: add the check condition for '3C4'
          if ( l_vendor_email_address <> '3C4' ) then
            l_message_line := fnd_global.newline||
                          l_invoice_number ||l_invoice_number_tmp||
                          fnd_global.newline||l_message_line;
          end if;
      end if;
      --
      if (l_invoice_line_id is not null and
          l_invoice_line_id <> nvl(l_prev_invoice_line_id,0)) then
        l_invoice_line_index := l_invoice_line_index + 1;
        l_prev_invoice_line_id := l_invoice_line_id;
        l_invoice_line_id_table(l_invoice_line_index) := l_invoice_line_id;
        --
        ap_debug_pkg.print('Y','New Invoice Line');
	  -- Bug 4065112: add the check condition for '3C4'
          if ( l_vendor_email_address <> '3C4' ) then
            l_message_line := fnd_global.newline||
                              l_invoice_number || l_invoice_number_tmp||
			                  fnd_global.newline||
			                  l_invoice_line_number ||
                                          l_invoice_line_number_tmp||
			                  fnd_global.newline||
                              l_message_line;
          end if;

      end if;
      --
      --
      ap_debug_pkg.print('Y','invoice_id:'||to_char(l_invoice_id));
      ap_debug_pkg.print('Y','invoice_line_id:'||to_char(l_invoice_line_id));
        -- Bug 4065112: add the check condition for '3C4'
        if ( l_vendor_email_address <> '3C4' ) then
         ap_debug_pkg.print('Y','Email prepared for sending main notification');


         if ( lengthb(l_message||l_message_line) > 32000) then
          l_index := l_index + 1;
          l_email_and_message_table(l_index).vendor_email_address
                           := l_vendor_email_address;
          l_email_and_message_table(l_index).message := l_message;
          l_message := NULL;
         else
          l_message := l_message||l_message_line;
         end if;
       else
          -- Bug 4065112 starts
          if ( nvl(l_call_3c4_invoice_id, 0 ) <> nvl( l_invoice_id, 0)) then
           ap_debug_pkg.print('Y','Calling API to generate reject xml message for 3C4');
            CLN_3C3_AP_TRIGGER_PKG.TRIGGER_REJECTION(l_invoice_id,
                                        l_group_id,
                                        p_request_id,
                                        l_external_doc_ref);
            l_call_3c4_invoice_id := l_invoice_id;
          end if;
          -- Bug 4065112 ends
        end if;

      --
      --
    end loop;
    close l_message_csr;
    --
    --
    if (l_message is not null) then
      l_index := l_index + 1;
      l_email_and_message_table(l_index).vendor_email_address
                    := l_vendor_email_address;
      l_email_and_message_table(l_index).message := l_message;
    end if;
    --
    --
    l_message := NULL;
    --
  end loop;
  close l_email_csr;
  --
  --
  -- Table l_email_address_table are populated as follows:
  -- ++++++++++++++++++++++++++++++++++++++
  -- vendor_email_address	message
  -- ++++++++++++++++++++++++++++++++++++++
  -- 1 tanji.koshio@oracle.com	'hello'
  -- 2 tanjikoshio@hotmail.com	'good morning'
  -- ...
  ---
  -- Now start Workflow process for each element of the table
  --
  for i in 1..nvl(l_email_and_message_table.last, 0) loop
    ap_debug_pkg.print('Y','index:'||to_char(i));
    ap_debug_pkg.print('Y',
           'size of message:'||lengthb(l_email_and_message_table(i).message));
    ap_debug_pkg.print('Y',
           'email:'||l_email_and_message_table(i).vendor_email_address);
    ap_debug_pkg.print('Y',
           l_email_and_message_table(i).message);
    --
    l_message_table(1) := substrb(l_email_and_message_table(i).message,
                                  1,     4000);
    l_message_table(2) := substrb(l_email_and_message_table(i).message,
                                  4001,  4000);
    l_message_table(3) := substrb(l_email_and_message_table(i).message,
                                  8001,  4000);
    l_message_table(4) := substrb(l_email_and_message_table(i).message,
                                  12001, 4000);
    l_message_table(5) := substrb(l_email_and_message_table(i).message,
                                  16001, 4000);
    l_message_table(6) := substrb(l_email_and_message_table(i).message,
                                  20001, 4000);
    l_message_table(7) := substrb(l_email_and_message_table(i).message,
                                  24001, 4000);
    l_message_table(8) := substrb(l_email_and_message_table(i).message,
                                  28001, 4000);
    --
    -- Create an Adhoc role
    --
    ap_debug_pkg.print('Y','Creating adhoc role(+)');
    l_role := null;
    l_display_role_name := null;
    WF_DIRECTORY.createAdhocRole(role_name => l_role,
                            role_display_name => l_display_role_name,
                            email_address =>
                            l_email_and_message_table(i).vendor_email_address,
                            notification_preference => 'MAILTEXT');
    ap_debug_pkg.print('Y','Creating adhoc role(-)');
    --
    -- Creating a workflow process
    --
    select ap_p2p_inbound_notification_s.nextval into l_item_key from dual;
    ap_debug_pkg.print('Y','Creating a workflow process(+)');
    WF_ENGINE.createProcess('P2P',l_item_key,
                            'PROCESS_FOR_NOTIFICATION');

    ap_debug_pkg.print('Y','Creating a workflow process(-)');
    --
    -- Initializing attributes
    --
    ap_debug_pkg.print('Y','Initializing Mail Subject (+)');
    FND_MESSAGE.SET_NAME('SQLAP', 'AP_XML_WF_SUPPLIER_EMAIL_SUBJ');
    l_temp_string := FND_MESSAGE.GET;


    -- Commented below code for 9007991
    -- select NVL(TO_NUMBER(DECODE(SUBSTRB( USERENV('CLIENT_INFO'),1,1),' ',
    --        NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    -- into   l_org_id
    -- from   dual;

    -- if (l_org_id is not null) then
    --   l_temp_string := l_temp_string ||
    --                  '('||mo_utils.get_ledger_name(l_org_id) ||')';
    -- end if;

    ap_debug_pkg.print('Y','subject:'||l_temp_string);
    WF_ENGINE.setItemAttrText('P2P',l_item_key, 'MAIL_SUBJECT',l_temp_string);
    ap_debug_pkg.print('Y','Initializing Mail Subject (-)');

    ap_debug_pkg.print('Y','Initializing Mail Header (+)');
    FND_MESSAGE.SET_NAME('SQLAP', 'AP_XML_WF_SUPPLIER_EMAIL_CONT');
    l_temp_string := FND_MESSAGE.GET;
    ap_debug_pkg.print('Y','mail header:'||l_temp_string);
    WF_ENGINE.setItemAttrText('P2P',l_item_key, 'MAIL_HEADER',l_temp_string);
    ap_debug_pkg.print('Y','Initializing Mail Header (-)');

    for j in 1..8 loop
      ap_debug_pkg.print('Y','Initializing Mail Content (+)');
      WF_ENGINE.setItemAttrText('P2P',l_item_key,'MAIL_CONTENT'||
                                 to_char(j),l_message_table(j));
      ap_debug_pkg.print('Y','Initializing Mail Content (-)');
    end loop;

    ap_debug_pkg.print('Y','Initializing Adhoc Role(+)');
    WF_ENGINE.setItemAttrText('P2P',l_item_key,'ADHOC_ROLE',l_role);
    ap_debug_pkg.print('Y','Initializing Adhoc Role(-)');

    --
    -- Starting the process
    --
    ap_debug_pkg.print('Y','Starting the process(+)');
    WF_ENGINE.startProcess('P2P', l_item_key);
    ap_debug_pkg.print('Y','Starting the process(-)');
  end loop;
  --
  --
  ap_debug_pkg.print('Y','Deleting from the interfaces(+)');
  ap_debug_pkg.print('Y','# of element in l_invoice_id_table:'||
                         to_char(nvl(l_invoice_id_table.last,0)));
  ap_debug_pkg.print('Y','# of element in l_invoice_line_id_table:'||
                         to_char(nvl(l_invoice_line_id_table.last,0)));
  l_result := ap_utilities_pkg.delete_invoice_from_interface(
                  l_invoice_id_table,
                  l_invoice_line_id_table,
                  'AP_XML_INVOICE_INBOUND_PKG.notify_supplier');
  ap_debug_pkg.print('Y','Deleting from the interfaces(-)');
  --
  --
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.notify_supplier(-)');
end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    notify_recipient                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Called by the request set                                               |
 +===========================================================================*/
procedure notify_recipient(p_errbuf out NOCOPY VARCHAR2, p_return_code out NOCOPY VARCHAR2)
is

  cursor parent_req is
    select PRIORITY_REQUEST_ID
    from   fnd_concurrent_requests
    where  request_id = FND_GLOBAL.CONC_REQUEST_ID;

  l_priority_request_id number;

  cursor req_set is
    select fnd_global.tab||PROGRAM ||' with Request ID: '||
           to_char(request_id)||fnd_global.newline
    from   fnd_conc_req_summary_v
    where  priority_request_id = l_priority_request_id
    order by request_id;

  l_request varchar2(1000);
  l_requests varchar2(3000);
  l_email_address varchar2(200);

begin
  ap_debug_pkg.print('Y','AP_XML_INVOICE_INBOUND_PKG.notify_recipient(+)');
  fnd_profile.get('AP_NOTIFICATION_EMAIL', l_email_address);
  ap_debug_pkg.print('Y','email address: '||l_email_address);

  open parent_req;
  fetch parent_req into l_priority_request_id;
  close parent_req;

  open req_set;
  loop
    fetch req_set into l_request;
    exit when req_set%notfound;
    if l_request is not null then
      l_requests := l_requests || l_request;
    end if;
  end loop;
  close req_set;

  if l_requests is not null then
    l_requests := 'The following requests are submitted:'||
                  fnd_global.newline||fnd_global.newline||
                  l_requests||fnd_global.newline||
                  'Please check the result for each request.';

    ap_debug_pkg.print('Y','l_requests:'||l_requests);
    ap_debug_pkg.print('Y','sending email +');
    send_email('P2P Inbound Process Request Set has been submitted',
                         l_requests,
                         l_email_address);
    ap_debug_pkg.print('Y','sending email -');
  end if;

  p_return_code := '0';
  ap_debug_pkg.print('Y','ap_xml_invoice_inbound_pkg.notify_recipient(-)');
exception
  when others then
    ap_debug_pkg.print('Y',
                 'ap_xml_invoice_inbound_pkg.notify_recipient EXCEPTION(-)');
    p_return_code := '2';

end notify_recipient;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_taxable_flag                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    For all invoices in this group,                                        |
 |      If common tax line (with no line_group_number) exists,               |
 |        set taxable_flag='Y' on all item lines                             |
 +===========================================================================*/
procedure set_taxable_flag(p_group_id in VARCHAR2) as
begin

  -- if any tax line is not affiliated with a particular item line
  -- affiliate  it with all item lines
  UPDATE  ap_invoice_lines_interface
  SET     taxable_flag =  'Y'
  WHERE   line_type_lookup_code = 'ITEM'
  AND     invoice_id IN
            (SELECT   h.invoice_id
             FROM     ap_invoices_interface h, ap_invoice_lines_interface l
             WHERE    h.invoice_id = l.invoice_id
             AND      h.source = 'XML GATEWAY'
             AND      h.group_id = p_group_id
             AND      l.line_type_lookup_code = 'TAX'
             AND      l.line_group_number is null
             GROUP BY h.invoice_id);

end set_taxable_flag;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_taxable_flag2                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    Used in the map.                                                       |
 |    Set taxable_flag='Y' for the given item line                           |
 +===========================================================================*/
procedure set_taxable_flag2(p_item_line_id in number) as
begin

  UPDATE  ap_invoice_lines_interface
  SET     taxable_flag =  'Y'
  WHERE   invoice_line_id = p_item_line_id;

end set_taxable_flag2;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    correct_charge_type                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    changes p_charge_type to either FREIGHT or MISCELLANEOUS               |
 +===========================================================================*/
procedure correct_charge_type(p_charge_type in out NOCOPY VARCHAR2) as
begin

  IF ( upper( trim(' ' from nvl(p_charge_type,'DUMMY') ) ) = 'FREIGHT' ) THEN
    p_charge_type := 'FREIGHT';
  ELSE
    p_charge_type := 'MISCELLANEOUS';
  END IF;

end correct_charge_type;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    correct_charge_ccid                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    Do charge account derivation                                           |
 +===========================================================================*/
procedure correct_charge_ccid(p_group_id in VARCHAR2) as

  l_org_id           number;
  l_freight_ccid     number;
  l_misc_ccid        number;

  cursor org_csr is
    SELECT  distinct ORG_ID
    FROM    AP_INVOICES_INTERFACE
    WHERE   GROUP_ID = p_group_id
    AND     SOURCE = 'XML GATEWAY';

begin
  ap_debug_pkg.print('Y',
                     'AP_XML_INVOICE_INBOUND_PKG.correct_charge_ccid(+)');

  open org_csr;
  loop
    fetch org_csr into l_org_id;
    exit when org_csr%notfound or org_csr%notfound is null;

    -- reset loop variables
    l_freight_ccid := NULL;
    l_misc_ccid    := NULL;

    -- fetch setup info
    SELECT FREIGHT_CODE_COMBINATION_ID
    INTO   l_freight_ccid
    FROM   AP_SYSTEM_PARAMETERS_ALL
    WHERE  NVL(ORG_ID,TO_NUMBER(NVL(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
             ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99'))) =
           NVL(l_org_id,TO_NUMBER(NVL(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
             ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99')));

    SELECT MISC_CHARGE_CCID
    INTO   l_misc_ccid
    FROM   FINANCIALS_SYSTEM_PARAMS_ALL
    WHERE  NVL(ORG_ID,TO_NUMBER(NVL(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
             ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99'))) =
           NVL(l_org_id,TO_NUMBER(NVL(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
             ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99')));

    -- update freight and misc lines
    UPDATE AP_INVOICE_LINES_INTERFACE
    SET    DIST_CODE_COMBINATION_ID =
             decode(LINE_TYPE_LOOKUP_CODE,'FREIGHT',l_freight_ccid,
                                          'MISCELLANEOUS',l_misc_ccid),
           PRORATE_ACROSS_FLAG =
             decode(LINE_TYPE_LOOKUP_CODE,'FREIGHT',decode(l_freight_ccid,'','Y','N'),
                                          'MISCELLANEOUS',decode(l_misc_ccid,'','Y','N'))
    WHERE  INVOICE_ID in
           (SELECT INVOICE_ID
            FROM   AP_INVOICES_INTERFACE
            WHERE  GROUP_ID = p_group_id
            AND    NVL(ORG_ID,TO_NUMBER(NVL(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
                     ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99'))) =
                   NVL(l_org_id,TO_NUMBER(NVL(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
                     ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10)), '-99')))
            AND    SOURCE = 'XML GATEWAY')
    AND    LINE_TYPE_LOOKUP_CODE in ('FREIGHT','MISCELLANEOUS');

  end loop; -- finish looping through org_id
  close org_csr;

  ap_debug_pkg.print('Y',
                     'AP_XML_INVOICE_INBOUND_PKG.correct_charge_ccid(-)');
end correct_charge_ccid;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    after_map                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    bug 2524551                                                            |
 |    Used at the end of map                                                 |
 +===========================================================================*/
procedure after_map(p_group_id in VARCHAR2) as
begin
  correct_charge_ccid(p_group_id);
  set_taxable_flag(p_group_id);
end after_map;


END AP_XML_INVOICE_INBOUND_PKG;

/
