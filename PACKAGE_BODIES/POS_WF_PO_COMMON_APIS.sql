--------------------------------------------------------
--  DDL for Package Body POS_WF_PO_COMMON_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_WF_PO_COMMON_APIS" AS
/* $Header: POSWFCMB.pls 115.2 2002/11/25 19:45:30 sbull noship $ */

/*

--
--
	This package contains the common API used by all the WEB Supplier
	Workflows.

	Be extremely careful when modifying anything here as it will
	most likey impact all the web supplier workflows.

--
--

*/


--

/*
	This activity assumes that you have the fol. attributes defined for the item:

	DOCUMENT_ID   -  ie. po_header_id
	DOCUMENT_NUM  -      segment1

	Only applicable from a SSP env (for web suppliers) - jumps into the ssp4 doc
	details flow.
*/


PROCEDURE  Get_PO_Details_URL(	 document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  p_rowid    VARCHAR2(2000);
  l_param    VARCHAR2(2000);
  Y          VARCHAR2(2000);
  x_progress    VARCHAR2(3) := '000';
  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;
  l_item_type        wf_items.item_type%TYPE;
  l_item_key         wf_items.item_key%TYPE;
  l_document_id      po_headers.po_header_id%TYPE;
  l_document_num     VARCHAR2(500);
  l_header_msg       VARCHAR2(500);
  l_document         VARCHAR2(32000) := '';
  NL                 VARCHAR2(1) := fnd_global.newline;

BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);

  x_progress := '001';

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  x_progress := '002';

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_document_num := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_NUM');

  fnd_client_info.set_org_context(to_char(l_org_id));

  x_progress := '003';

  select  rowidtochar(ROWID)
  into    p_rowid
  from    AK_FLOW_REGION_RELATIONS
  where   FROM_REGION_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_REGION_APPL_ID = 178
  and     FROM_PAGE_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_PAGE_APPL_ID = 178
  and     TO_PAGE_CODE = 'ICX_PO_HEADERS_DTL_D'
  and     TO_PAGE_APPL_ID = 178
  and     FLOW_CODE = 'ICX_INQUIRIES'
  and     FLOW_APPLICATION_ID = 178;

  x_progress := '004';

  l_param :=  icx_on_utilities.buildOracleONstring(p_rowid => p_rowid,
                                                   	 p_primary_key => 'ICX_PO_SUPPLIER_ORDERS_PK',
                                                   	 p1 => to_char(l_document_id));
  x_progress := '005';
  Y := icx_call.encrypt2(l_param,l_session_id);
  x_progress := '006';
  document := '<A HREF="OracleON.IC?Y=' || Y || '">' || l_document_num || '</A>';

  --dbms_output.put_line('After Get Po Details ' || document || document_type);

exception
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_ACKNOWLEDGE','Get_PO_Details_URL',x_progress);
    	raise;
end;

--

procedure  get_supplier_username   ( itemtype        in  varchar2,
                            	     itemkey         in  varchar2,
	                    	     actid           in number,
                            	     funcmode        in  varchar2,
                            	     result          out NOCOPY varchar2    )

is
	x_progress               varchar2(3) := '000';
	x_supplier_id		  number;
	x_supplier_username	 varchar2(100);
	x_supplier_display_name varchar2(240);
	x_orig_system		 varchar2(4);
begin

	--dbms_output.put_line (' In Get Supplier Username ');
	x_supplier_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'SUPPLIER_ID');

	--dbms_output.put_line (' Get Supplier Username ' || x_supplier_id);
	if x_supplier_id is not null then

		x_progress := '003';

		-- Get the supplier user name

	  	x_orig_system:= 'PER';

	  	WF_DIRECTORY.GetUserName(  x_orig_system,
	        	                   x_supplier_id,
       		         	           x_supplier_username,
                	        	   x_supplier_display_name);
		x_progress := '004';

		wf_engine.SetItemAttrText (   	itemtype => itemtype,
        			      		itemkey  => itemkey,
                		      		aname    => 'SUPPLIER_USER_NAME',
				      		avalue   => x_supplier_username);
	end if;
	--dbms_output.put_line (' result in  Get Supplier Username ' || x_supplier_username);

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_COMMON_APIS','Get_Supplier_username',x_progress);
    	raise;
end;

--

procedure  get_buyer_username   ( itemtype        in  varchar2,
                            	     itemkey         in  varchar2,
	                    	     actid           in number,
                            	     funcmode        in  varchar2,
                            	     result          out NOCOPY varchar2    )

is
	x_progress               varchar2(3) := '000';
	x_buyer_id		  number;
	x_buyer_username	 varchar2(100);
	x_buyer_display_name varchar2(240);
	x_orig_system		 varchar2(4);
begin

	x_buyer_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		    itemkey  => itemkey,
                            	 	            aname    => 'BUYER_USER_ID');

	if x_buyer_id is not null then

		x_progress := '003';

		-- Get the buyer user name

	  	x_orig_system:= 'PER';

	  	WF_DIRECTORY.GetUserName(  x_orig_system,
	        	                   x_buyer_id,
       		         	           x_buyer_username,
                	        	   x_buyer_display_name);
		x_progress := '004';

		wf_engine.SetItemAttrText (   	itemtype => itemtype,
        			      		itemkey  => itemkey,
                		      		aname    => 'BUYER_USER_NAME',
				      		avalue   => x_buyer_username);
	end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_COMMON_APIS','Get_Buyer_username',x_progress);
    	raise;
end;

--

procedure get_default_inventory_org ( 	itemtype        in  varchar2,
                            		itemkey         in  varchar2,
	                    		actid           in number,
                            		funcmode        in  varchar2,
                            		result          out NOCOPY varchar2    )
is
	x_def_inv_org 	number;
	x_progress    	varchar2(3) := '000';
begin

	select inventory_organization_id
	into x_def_inv_org
	from financials_system_parameters;

	wf_engine.SetItemAttrText (   	itemtype => itemtype,
        			      	itemkey  => itemkey,
                		      	aname    => 'SHIP_TO_ORGANIZATION_ID',
				      	avalue   => x_def_inv_org);

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_COMMON_APIS','get_default_inventory_org',x_progress);
    	raise;
end;

--

procedure set_attributes ( 	itemtype        in  varchar2,
                            	itemkey         in  varchar2,
	                    	actid           in number,
                            	funcmode        in  varchar2,
                            	result          out NOCOPY varchar2    )
is
	x_default_inv_org 	number;
	x_item_id	number;
	x_buyer_id	number;
	x_progress    	varchar2(3) := '000';
begin

	x_item_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   itemkey  => itemkey,
                            	 	           aname    => 'ITEM_ID');

	x_default_inv_org := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	   itemkey  => itemkey,
                            	 	           	   aname    => 'SHIP_TO_ORGANIZATION_ID');

	x_progress := '001';

	select buyer_id into x_buyer_id
	from mtl_system_items
	where inventory_item_id = x_item_id
	and   organization_id	= x_default_inv_org;

	wf_engine.SetItemAttrText (   	itemtype => itemtype,
        			      	itemkey  => itemkey,
                		      	aname    => 'BUYER_USER_ID',
				      	avalue   => x_buyer_id);

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_COMMON_APIS','set_attributes',x_progress);
    	raise;
end;


--

procedure get_supplier ( 	itemtype        in  varchar2,
                            	itemkey         in  varchar2,
	                    	actid           in number,
                            	funcmode        in  varchar2,
                            	result          out NOCOPY varchar2    )
is
	x_document_id number;
	x_vendor_id number;
	x_vendor    varchar2(80);
	x_progress    	varchar2(3)  := '000';
begin
--dbms_output.put_line (' In Get Supplier ');
	x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'DOCUMENT_ID');

	x_vendor_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'SUPPLIER_ID');

	--if x_document_id is not null and x_vendor_id is null then
	if x_document_id is not null then

		begin
			x_progress := '001';
			select vendor_id into x_vendor_id
			from po_headers_all
			where po_header_id = x_document_id;

			x_progress := '002';
		exception
			when others then
			null;
		end;

		if x_vendor_id is null then
			begin
				x_progress := '003';
				select vendor_id
				into x_vendor_id
				from po_headers_all
				where po_header_id = (select po_header_id from po_releases_all
							where po_release_id = x_document_id);

				x_progress := '004';
			exception
				when others then
				null;
			end ;
		end if;
	end if;
	x_progress := '005';

	if x_vendor_id is not null then
		begin
			select vendor_name into x_vendor
			from po_vendors
			where vendor_id = x_vendor_id;

			wf_engine.SetItemAttrNumber (   itemtype => itemtype,
        					   	itemkey  => itemkey,
                				   	aname    => 'SUPPLIER_ID',
				      			avalue   => x_vendor_id);

			wf_engine.SetItemAttrText (   	itemtype => itemtype,
        					      	itemkey  => itemkey,
                				      	aname    => 'SUPPLIER',
				      			avalue   => x_vendor);
		exception
			when others then
			null;
		end ;
	end if;
     -- call get supplier user name
	get_supplier_username   ( itemtype,itemkey, actid, funcmode , result );

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_COMMON_APIS','get_supplier',x_progress);
    	raise;
end;

--

procedure purge_workflow ( x_document_id in number )
is
	x_doc_revision	number;
	x_progress    	varchar2(3)  := '000';
	l_item_type	varchar2(10) := 'POSPOACK';
	l_item_key	varchar2(240);
begin

	-- abort any outstanding acceptance notifications for any previous revision of the document.

	select nvl(revision_num, 0)
	into x_doc_revision
	from po_headers
	where po_header_id = x_document_id;

	while x_doc_revision >= 0 loop

		l_item_key := 'POS_ACK_' || to_char (x_document_id) || '_' || to_char(x_doc_revision);

		begin
			-- Abort process if it exists
			wf_engine.abortprocess (l_item_type, l_item_key);
		exception
			when others then
			null;
		end;

		-- purge the workflow

		wf_purge.items (l_item_type, l_item_key);

		x_doc_revision := x_doc_revision - 1;

	end loop;

EXCEPTION
  WHEN OTHERS THEN
    	raise;
end;



END POS_WF_PO_COMMON_APIS;

/
