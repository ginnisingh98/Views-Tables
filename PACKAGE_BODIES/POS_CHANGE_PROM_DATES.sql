--------------------------------------------------------
--  DDL for Package Body POS_CHANGE_PROM_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_CHANGE_PROM_DATES" AS
/* $Header: POSCPDTB.pls 115.14 2002/12/20 03:21:49 mji ship $ */


PROCEDURE initialize(x_employee_id in NUMBER, x_org_id IN NUMBER);

--
--			PARENT WORKFLOW FUNCITONS
--

procedure  Add_Shipment_Attribute   ( itemtype            in  varchar2,
                                      itemkey             in  varchar2,
			              line_location_id    in  number,
				      orig_promised_date  in  date,
				      new_promised_date   in date,
				      orig_NeedBy_date    in  date,
				      new_NeedBy_date     in date,
				      new_reason          in varchar2 )
is
	x_progress    	varchar2(3) := '000';
	att_name	varchar2(60);
	shipment_count	number;
begin

	shipment_count := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'NUMBER_OF_SHIPMENTS');

	shipment_count := shipment_count + 1;

	-- Create line location id attribute.

	att_name := 'LINE_LOC_ID' || to_char(shipment_count);

	wf_engine.AddItemAttr ( ItemType  => ItemType,
                                ItemKey   => ItemKey,
				aname     => att_name);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => att_name,
				      avalue   => line_location_id);

       -- Create new reason attribute

        att_name := 'LINE_LOC_ID' || to_char(shipment_count);
        att_name := att_name || '_REASON';

        wf_engine.AddItemAttr ( ItemType  => ItemType,
                                ItemKey   => ItemKey,
                                aname     => att_name);

        wf_engine.SetItemAttrText (   itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => att_name,
                                      avalue   => new_reason);



	-- Create original promised date attribute.

	att_name := 'LINE_LOC_ID' || to_char(shipment_count);
	att_name := att_name || '_ORIG_PDATE';

	wf_engine.AddItemAttr ( ItemType  => ItemType,
                                ItemKey   => ItemKey,
				aname     => att_name);

	wf_engine.SetItemAttrDate (   itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => att_name,
				      avalue   => orig_promised_date);

	-- Create new promised date attribute.

	att_name := 'LINE_LOC_ID' || to_char(shipment_count);
	att_name := att_name || '_NEW_PDATE';

	wf_engine.AddItemAttr ( ItemType  => ItemType,
                                ItemKey   => ItemKey,
				aname     => att_name);

	wf_engine.SetItemAttrDate (   itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => att_name,
				      avalue   => new_promised_date);

	-- Create original promised date attribute.

	att_name := 'LINE_LOC_ID' || to_char(shipment_count);
	att_name := att_name || '_ORIG_NDATE';

	wf_engine.AddItemAttr ( ItemType  => ItemType,
                                ItemKey   => ItemKey,
				aname     => att_name);

	wf_engine.SetItemAttrDate (   itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => att_name,
				      avalue   => orig_needby_date);

	-- Create new promised date attribute.

	att_name := 'LINE_LOC_ID' || to_char(shipment_count);
	att_name := att_name || '_NEW_NDATE';

	wf_engine.AddItemAttr ( ItemType  => ItemType,
                                ItemKey   => ItemKey,
				aname     => att_name);

	wf_engine.SetItemAttrDate (   itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => att_name,
				      avalue   => new_needby_date);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'NUMBER_OF_SHIPMENTS',
				      avalue   => shipment_count);

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Add_Shipment_Attribute',x_progress);
    	raise;
end;

--

procedure  Set_Parent_Attributes   (   itemtype        in  varchar2,
                                itemkey         in  varchar2,
	                        actid           in  number,
                                funcmode        in  varchar2,
                                result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_document_id		number;
	x_agent_id		number;
	x_agent_username	varchar2(60);
	x_agent_display_name	varchar2(240);
	x_document_num		varchar2(60);
	x_document_type_code	varchar2(60);
	x_document_subtype	varchar2(60);
	x_document_type		varchar2(80);
	x_supplier_userid	number;
	x_supplier_username	varchar2(60);
	x_supplier_displayname  varchar2(240);
	x_line_loc_id1		number;
	x_po_release_id		number;
	x_org_id	 	number;

begin
	x_document_id := wf_engine.GetItemAttrNumber ( 	itemtype => itemtype,
                                   		   	itemkey  => itemkey,
                            	 	           	aname    => 'DOCUMENT_ID');

	x_line_loc_id1 := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	itemkey  => itemkey,
                            	 	           	aname    => 'LINE_LOC_ID1');

	select po_release_id into x_po_release_id
	from po_line_locations_all
	where line_location_id = X_line_loc_id1;

	if x_po_release_id is not null then
		-- shipment for a release

		select 	por.release_type,
			polc.displayed_field,
			por.org_id ,
			poh.segment1||'-'||to_char(por.release_num),
			por.agent_id
		into   	x_Document_SubType,
			x_document_type,
			x_org_id,
			x_document_num,
			x_agent_id
		from po_releases_all por,
		     po_lookup_codes polc,
                     po_headers_all  poh
		where po_release_id = x_po_release_id
                and  por.po_header_id=poh.po_header_id
		and  por.release_type = polc.lookup_code
		and  polc.lookup_type = 'DOCUMENT SUBTYPE';

		x_Document_Type_Code := 'RELEASE';

	else

		select poh.segment1, poh.agent_id, poh.type_lookup_code, polc.displayed_field, poh.org_id
		into x_document_num, x_agent_id, x_document_subtype, x_document_type, x_org_id
		from po_headers_all poh,
		     po_lookup_codes polc
		where
		     poh.po_header_id = x_document_id
		and  poh.type_lookup_code = polc.lookup_code
		and  polc.lookup_type = 'PO TYPE';

		if X_Document_SubType in ('BLANKET', 'CONTRACT') then
			x_Document_Type_Code := 'PA';
		else
			x_Document_Type_Code := 'PO';
		end if;
	end if;

	-- Set Item Attributes.

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'DOCUMENT_NUM',
				    avalue   => x_document_num);


	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'DOCUMENT_TYPE_CODE',
				    avalue   => x_document_type_code);

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'DOCUMENT_TYPE',
				    avalue   => x_document_type);

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'DOCUMENT_SUBTYPE',
				    avalue   => x_document_subtype);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'ORG_ID',
				      avalue   => x_org_id);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'BUYER_ID',
				      avalue   => x_agent_id);


EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Set_Parent_Attributes',x_progress);
    	raise;
end;

--

procedure  Start_WFs_For_Shipments  (   itemtype        in  varchar2,
                                    	itemkey         in  varchar2,
	                        	actid           in number,
                                	funcmode        in  varchar2,
                                	result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
        l_seq                   varchar2(10);
	x_ItemType	        varchar2(8);
	x_ItemKey	        varchar2(240);
	x_Process	        varchar2(80);
	WorkflowProcess	        varchar2(80);
	print_check	        varchar2(3);
	shipment_count	       	number;
	x_base_att_name		varchar2(60);
	x_att_name		varchar2(60);
	x_line_location_id	number;
	document_id		number;
	supplier_user_id	number;
	x_orig_promised_date    date;
	x_new_promised_date     date;
	x_orig_needby_date      date;
	x_new_needby_date       date;
	x_document_type_code	varchar2(60);
	x_document_subtype	varchar2(60);
	x_document_type		varchar2(80);
	x_document_id		number;
        x_document_num		varchar2(240);
	x_org_id		number;
	x_supplier_username	varchar2(60);
	x_new_reason            varchar2(2000);
	x_requester_id		number;
begin

	shipment_count := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'NUMBER_OF_SHIPMENTS');

	x_document_id  := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'DOCUMENT_ID');

	x_document_num := wf_engine.GetItemAttrText ( 	itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'DOCUMENT_NUM');

	supplier_user_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		 	  itemkey  => itemkey,
                            	 	         	  aname    => 'SUPPLIER_USER_ID');

	x_document_type_code := wf_engine.GetItemAttrText ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'DOCUMENT_TYPE_CODE');

	x_document_subtype := wf_engine.GetItemAttrText ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'DOCUMENT_SUBTYPE');

	x_document_type := wf_engine.GetItemAttrText 	( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'DOCUMENT_TYPE');

	x_org_id  := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   itemkey  => itemkey,
                            	 	           aname    => 'ORG_ID');

	--
	-- Start Individual Workflows for Each Shipment to Process the Date Change.
	--

	x_ItemType := 'POSMPDCH';
	x_Process  := 'MAIN_PROCESS';
	WHILE shipment_count > 0 LOOP

		x_base_att_name := 'LINE_LOC_ID' || to_char(shipment_count);
		x_att_name := x_base_att_name;

		x_line_location_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		 		    itemkey  => itemkey,
                            	 	         		    aname    => x_att_name);

                -- get the requestor id from requisition lines if this line was created from
		-- a requisition

		begin
			select to_person_id
			into   x_requester_id
			from   po_requisition_lines_all
			where  line_location_id = x_line_location_id;

		exception
			when no_data_found then
			null;

			when others then
			raise;
		end;

        	x_ItemKey  := itemkey || '-' || to_char(x_line_location_id);

        	wf_engine.createProcess     ( ItemType  => x_ItemType,
                	                      ItemKey   => x_ItemKey,
					      Process   => x_Process );

		-- Set Shipment Level Attributes.

		x_att_name := x_base_att_name || '_ORIG_PDATE';
		x_orig_promised_date := wf_engine.GetItemAttrDate (   itemtype => itemtype,
                                   		 		      itemkey  => itemkey,
                            	 	         		      aname    => x_att_name);
		x_att_name := x_base_att_name || '_NEW_PDATE';
		x_new_promised_date := wf_engine.GetItemAttrDate (    itemtype => itemtype,
                                   		 		      itemkey  => itemkey,
                            	 	         		      aname    => x_att_name);
		x_att_name := x_base_att_name || '_ORIG_NDATE';
		x_orig_needby_date := wf_engine.GetItemAttrDate (   itemtype => itemtype,
                                   		 		    itemkey  => itemkey,
                            	 	         		    aname    => x_att_name);
		x_att_name := x_base_att_name || '_NEW_NDATE';
		x_new_needby_date := wf_engine.GetItemAttrDate (   itemtype => itemtype,
                                   		 		   itemkey  => itemkey,
                            	 	         		   aname    => x_att_name);
                x_att_name := x_base_att_name || '_REASON';
                x_new_reason := wf_engine.GetItemAttrText (        itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => x_att_name);

		wf_engine.SetItemAttrNumber ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'LINE_LOCATION_ID',
					      avalue   => x_line_location_id);

		wf_engine.SetItemAttrNumber ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'DOCUMENT_ID',
					      avalue   => x_document_id);

		wf_engine.SetItemAttrDate   ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'ORIG_PROMISED_DATE',
					      avalue   => x_orig_promised_date);

		wf_engine.SetItemAttrDate   ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'NEW_PROMISED_DATE',
					      avalue   => x_new_promised_date);

		wf_engine.SetItemAttrDate   ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'ORIG_NEEDBY_DATE',
					      avalue   => x_orig_needby_date);

		wf_engine.SetItemAttrDate   ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'NEW_NEEDBY_DATE',
					      avalue   => x_new_needby_date);

                wf_engine.SetItemAttrText   ( itemtype => x_itemtype,
                                              itemkey  => x_itemkey,
                                              aname    => 'REASON',
                                              avalue   => x_new_reason);

		wf_engine.SetItemAttrText   ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'SUPPLIER_USER_ID',
					      avalue   => supplier_user_id);

		wf_engine.SetItemAttrText   ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'PARENT_WF_ITEMKEY',
					      avalue   => itemkey);

		wf_engine.SetItemAttrText   ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'DOCUMENT_NUM',
					      avalue   => x_document_num);

		wf_engine.SetItemAttrText ( itemtype => x_itemtype,
        				    itemkey  => x_itemkey,
        		        	    aname    => 'DOCUMENT_TYPE_CODE',
					    avalue   => x_document_type_code);

		wf_engine.SetItemAttrText ( itemtype => x_itemtype,
        				    itemkey  => x_itemkey,
        		        	    aname    => 'DOCUMENT_TYPE',
					    avalue   => x_document_type);

		wf_engine.SetItemAttrText ( itemtype => x_itemtype,
        				    itemkey  => x_itemkey,
        		        	    aname    => 'DOCUMENT_SUBTYPE',
					    avalue   => x_document_subtype);

		wf_engine.SetItemAttrNumber ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'ORG_ID',
					      avalue   => x_org_id);

		wf_engine.SetItemAttrNumber ( itemtype => x_itemtype,
        				      itemkey  => x_itemkey,
        		        	      aname    => 'REQUESTER_ID',
					      avalue   => x_requester_id);

        	wf_engine.StartProcess      ( ItemType  => x_ItemType,
                	                      ItemKey   => x_ItemKey );

		shipment_count := shipment_count - 1;

	END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Start_WFs_For_Shipments',x_progress);
    	raise;
end;

--

--

procedure reset_doc_status ( 	itemtype        in  varchar2,
                            	itemkey         in  varchar2,
	                    	actid           in number,
                            	funcmode        in  varchar2,
                            	result          out nocopy varchar2    )
is
	x_document_id		number;
	x_progress    		varchar2(3) := '000';
	x_document_type_code	varchar2(60);
	x_org_id		number;
begin

	-- set the org context

	x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		  itemkey  => itemkey,
                            	 	          aname    => 'ORG_ID');

	fnd_client_info.set_org_context(to_char(x_org_id));

	x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'DOCUMENT_ID');

	x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                   		       	      itemkey  => itemkey,
                            	 	               	      aname    => 'DOCUMENT_TYPE_CODE');
	if x_document_type_code <> 'RELEASE' then
		update po_headers_all
		set authorization_status = 'APPROVED'
		where po_header_id = x_document_id;
	else
		update po_releases_all
		set authorization_status = 'APPROVED'
		where po_release_id = x_document_id;
	end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','reset_doc_status',x_progress);
    	raise;
end;

--

procedure  Change_Order_Approval   ( itemtype        in  varchar2,
                           	     itemkey         in  varchar2,
	                   	     actid           in number,
                           	     funcmode        in  varchar2,
                           	     result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';

        l_seq                  varchar2(10);
	x_ItemType	       varchar2(8);
	x_ItemKey	       varchar2(240);
	WorkflowProcess	       varchar2(80);
	print_check	       varchar2(3);

	ActionOriginatedFrom   varchar2(30) := 'POS_DATE_CHG';
	Preparer_ID             Number;
	DocumentTypeCode       varchar2(30);
	DocumentSubtype        varchar2(60);
	DocumentStatus         varchar2(60);
	RequestorAction        varchar2(60) := 'APPROVE';
	forwardToID            number;
	forwardFromID          number;
	DefaultApprovalPathID  number;
	DocumentNote	       VARCHAR2(240) := '';
	X_system_message_level varchar2(4);
	x_po_auth_status       VARCHAR2(25) := '';
	x_po_header_id         NUMBER;
	x_req_status	       VARCHAR2(25) := '';
	x_req_status_dsp       VARCHAR2(25) := '';
	x_error_rc	       VARCHAR2(25) := '';
	x_doc_header_id	       number;
	l_approval_mode	       VARCHAR2(30);
	document_id 	       number;
	document_num	       varchar2(60);
	x_po_release_id	       number;
        x_employee_id		number;
	x_org_id	       number;
        l_responsibility_id    number;

begin

	-- set the org context
	x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		  itemkey  => itemkey,
                            	 	          aname    => 'ORG_ID');

	x_employee_id := wf_engine.GetItemAttrNumber ( 	itemtype => itemtype,
                                   		  	itemkey  => itemkey,
                            	 	          	aname    => 'BUYER_ID');


	fnd_client_info.set_org_context(to_char(x_org_id));

	document_id := wf_engine.GetItemAttrNumber ( 	itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'DOCUMENT_ID');

	Document_num := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'DOCUMENT_NUM');

	preparer_id := wf_engine.GetItemAttrNumber ( 	itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'BUYER_ID');

	DocumentTypeCode := wf_engine.GetItemAttrText    ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'DOCUMENT_TYPE_CODE');

	documentSubtype := wf_engine.GetItemAttrText	 ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'DOCUMENT_SUBTYPE');

        select to_char(PO_WF_ITEMKEY_S.NEXTVAL) into l_seq from sys.dual;

        x_ItemKey := to_char(Document_ID) || '-' || l_seq;

        initialize (x_employee_id, x_org_id);

	if NVL(DocumentTypeCode, 'PO') <> 'RELEASE' then

		update po_headers_all set
					authorization_status = 'IN PROCESS',
				      	revision_num = revision_num + 1,
            				revised_date = sysdate,
            				last_update_date = sysdate,
            				last_updated_by = fnd_global.user_id,
            				last_update_login = fnd_global.login_id,
            				request_id = fnd_global.conc_request_id,
            				program_application_id = fnd_global.prog_appl_id,
            				program_id = fnd_global.conc_program_id,
            				program_update_date = sysdate
		where po_header_id = document_id;
	else
		update po_releases_all set
					authorization_status = 'IN PROCESS',
				      	revision_num = revision_num + 1,
            				revised_date = sysdate,
            				last_update_date = sysdate,
            				last_updated_by = fnd_global.user_id,
            				last_update_login = fnd_global.login_id,
            				request_id = fnd_global.conc_request_id,
            				program_application_id = fnd_global.prog_appl_id,
            				program_id = fnd_global.conc_program_id,
            				program_update_date = sysdate
		where po_release_id = document_id;
	end if;

	select wf_approval_itemtype, wf_approval_process
	into x_ItemType, WorkflowProcess
	from PO_DOCUMENT_TYPES_V
	where DOCUMENT_TYPE_CODE = DocumentTypeCode
	and DOCUMENT_SUBTYPE =  DocumentSubtype;

	IF x_ItemType IS NULL THEN

		-- return failure;
		result := 'COMPLETE:FAILURE';
	ELSE

		print_check := 'N';


	        PO_REQAPPROVAL_INIT1.Start_WF_Process ( ItemType => x_ItemType,
      	 						ItemKey => x_ItemKey,
 							WorkflowProcess => WorkflowProcess,
			 				ActionOriginatedFrom => ActionOriginatedFrom,
			  				DocumentID => Document_ID,
			  				DocumentNumber => Document_Num,
			  				PreparerID => Preparer_ID,
			  				DocumentTypeCode => DocumentTypeCode,
			  				DocumentSubtype => DocumentSubtype,
			  				SubmitterAction => RequestorAction,
			  				forwardToID => forwardToID,
			  				forwardFromID => forwardFromID,
			  				DefaultApprovalPathID => DefaultApprovalPathID,
							Note => DocumentNote,
							printFlag => print_check );


		result := 'COMPLETE:SUCCESS';

	END IF;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATE','Change_Order_Approval',x_progress);
    	raise;
end;

--

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--
--			CHILD WORKFLOW FUNCITONS
--

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--

procedure  Set_Attributes   (   itemtype        in  varchar2,
                                itemkey         in  varchar2,
	                        actid           in  number,
                                funcmode        in  varchar2,
                                result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_item_id 		number;
	x_line_location_id	number;
	x_document_id		number;
	x_orig_system		varchar2(4);
	x_agent_id		number;
	x_agent_username	varchar2(60);
	x_agent_display_name	varchar2(240);
	x_document_num		varchar2(60);
	x_document_type_code	varchar2(60);
	x_document_type		varchar2(80);
	x_ship_to_organization_id number;
	x_supplier_userid	number;
	x_supplier_username	varchar2(60) ;
	x_supplier_displayname  varchar2(240);
	DocumentTypeCode        varchar2(30);
	x_org_id		number;
	x_acceptance_result	varchar2(30);
	x_line_num 		number;
	x_qty_ordered 		number;
	x_item_description	varchar2(240);
	x_uom			varchar2(25);
	x_vendor_name		varchar2(240);
begin
	-- set the org context
       --dbms_output.put_line('Inside Set Attributes');

	x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		  itemkey  => itemkey,
                            	 	          aname    => 'ORG_ID');

	fnd_client_info.set_org_context(to_char(x_org_id));

	x_line_location_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	    itemkey  => itemkey,
                            	 	           	    aname    => 'LINE_LOCATION_ID');

	x_document_id := wf_engine.GetItemAttrNumber ( 	itemtype => itemtype,
                                   		   	itemkey  => itemkey,
                            	 	           	aname    => 'DOCUMENT_ID');

	x_supplier_username := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                   		   	    itemkey  => itemkey,
                            	 	           	    aname    => 'SUPPLIER_USER_NAME');

	DocumentTypeCode := wf_engine.GetItemAttrText ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'DOCUMENT_TYPE_CODE');

	x_supplier_userid := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	   itemkey  => itemkey,
                            	 	           	   aname    => 'SUPPLIER_USER_ID');

  	fnd_message.set_name ('ICX','POS_PO_WF_REJECTED_VALUE');
  	x_acceptance_result := fnd_message.get;

  	wf_engine.SetItemAttrText ( itemtype => itemtype,
        	              	    itemkey  => itemkey,
                	      	    aname    => 'ACCEPTANCE_RESULT',
			      	    avalue   => nvl(x_acceptance_result, 'Rejected'));

	if DocumentTypeCode  <> 'RELEASE' then
		select poh.agent_id, pol.item_id, poll.ship_to_organization_id,pol.line_num,
		pol.UNIT_MEAS_LOOKUP_CODE, pol.ITEM_DESCRIPTION,
		DECODE(poll.SHIPMENT_TYPE, 'PRICE BREAK',  NULL,
		poll.QUANTITY - poll.QUANTITY_CANCELLED),pv.vendor_name
		into x_agent_id, x_item_id, x_ship_to_organization_id,x_line_num,
		     x_uom,x_item_description,x_qty_ordered,x_vendor_name
		from po_headers_all poh,
		     po_lines_all pol,
		     po_line_locations_all poll,
		     po_vendors pv
		where
		     poll.line_location_id = x_line_location_id
		and  pol.po_line_id = poll.po_line_id
		and  poll.po_header_id = poh.po_header_id
                and  poh.vendor_id=pv.vendor_id;
	else
		select por.agent_id, pol.item_id, poll.ship_to_organization_id,pol.line_num,
		pol.UNIT_MEAS_LOOKUP_CODE, POL.ITEM_DESCRIPTION,
		DECODE(poll.SHIPMENT_TYPE, 'PRICE BREAK',  NULL,
		poll.QUANTITY - poll.QUANTITY_CANCELLED),pv.vendor_name
		into x_agent_id, x_item_id, x_ship_to_organization_id,x_line_num,
		     x_uom,x_item_description,x_qty_ordered,x_vendor_name
		from po_releases_all por,
		     po_lines_all pol,
		     po_line_locations_all poll,
                     po_vendors pv,
                     po_headers_all poh
		where
		     poll.line_location_id = x_line_location_id
		and  pol.po_line_id = poll.po_line_id
		and  poll.po_release_id = por.po_release_id
                and  poh.po_header_id   = por.po_header_id
                and  poh.vendor_id      = pv.vendor_id;
	end if;

	-- Set Item Attributes.


	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'SHIP_TO_ORGANIZATION_ID',
				      avalue   => x_ship_to_organization_id);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'ITEM_ID',
				      avalue   => x_item_id);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'BUYER_USER_ID',
				      avalue   => x_agent_id);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'LINE_NUMBER',
				      avalue   => x_line_num);

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'UOM',
				      avalue   => x_uom);

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'ITEM_DESCRIPTION',
				      avalue   => x_item_description);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'QTY_ORDERED',
				      avalue   => x_qty_ordered);

	wf_engine.SetItemAttrText (   	itemtype => itemtype,
        				itemkey  => itemkey,
        	        		aname    => 'SUPPLIER',
					avalue   => x_vendor_name);

	select user_name
	into x_supplier_username
	from fnd_user where user_id = x_supplier_userid;

	if x_supplier_username is null then

		-- get suplier user id

		if x_supplier_userid is not null then

			x_progress := '003';

			-- Get the supplier user name

	  		x_orig_system := 'PER';

	  		WF_DIRECTORY.GetUserName(  x_orig_system,
	        		                   x_supplier_userid,
       		         		           x_supplier_username,
                	        		   x_supplier_displayname);

			x_progress := '004';
		end if;
	end if;

	wf_engine.SetItemAttrText (   	itemtype => itemtype,
        				itemkey  => itemkey,
        	        		aname    => 'SUPPLIER_USER_NAME',
					avalue   => x_supplier_username);

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Set_Attributes',x_progress);
    	raise;
end;

--

procedure  Find_Planner   ( itemtype        in  varchar2,
                            itemkey         in  varchar2,
	                    actid           in number,
                            funcmode        in  varchar2,
                            result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_planner_code		varchar2(10);
	x_planner_username	varchar2(100);
	x_planner_display_name	varchar2(240);
	x_employee_id		number := null;
	x_item_id		number;
	x_orig_system		varchar2(4);
	x_ship_to_org_id	number;
begin

	x_item_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   itemkey  => itemkey,
                            	 	           aname    => 'ITEM_ID');

	x_ship_to_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	  itemkey  => itemkey,
                            	 	           	  aname    => 'SHIP_TO_ORGANIZATION_ID');

	x_progress := '001';

	begin

		select distinct planner_code
		into x_planner_code
		from mtl_system_items
		where inventory_item_id = x_item_id
		and organization_id = x_ship_to_org_id;

		x_progress := '002';

		select distinct employee_id
		into x_employee_id
		from mtl_planners
		where planner_code = x_planner_code
		and organization_id = x_ship_to_org_id;

	exception
		when no_data_found then
			null;
		when others then
			raise;
	end;

	if x_employee_id is not null then

		x_progress := '003';

		-- Get the employee user name

	  	x_orig_system:= 'PER';

	  	WF_DIRECTORY.GetUserName(  x_orig_system,
	        	                   x_employee_id,
       		         	           x_planner_username,
                	        	   x_planner_display_name);

		x_progress := '004';

		if x_planner_username is null then

			-- May want to raise an exception as there is no role defined of the employee.
			result := 'COMPLETE:NOT_FOUND';
		else
			wf_engine.SetItemAttrText (   itemtype => itemtype,
        				      itemkey  => itemkey,
        	        		      aname    => 'PLANNER_USER_NAME',
					      avalue   => x_planner_username);

			result := 'COMPLETE:FOUND';
		end if;
	else
		result := 'COMPLETE:NOT_FOUND';
	end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Find_Planner',x_progress);
    	raise;
end;

--

procedure  Find_ShopFloor_Mgr   ( itemtype        in  varchar2,
                                  itemkey         in  varchar2,
	                    	  actid           in number,
                            	  funcmode        in  varchar2,
                             	  result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_Shopfloor_Mgr_username	varchar2(100) := null;
	x_Shopfloor_Mgr_display_name	varchar2(240);
	x_Shopfloor_Mgr_id		number := null;
	x_item_id		number;
	x_orig_system		varchar2(4);
	x_ship_to_org_id	number;
begin

	x_ship_to_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	  itemkey  => itemkey,
                            	 	           	  aname    => 'SHIP_TO_ORGANIZATION_ID');

	x_progress := '001';

	begin

    		x_Shopfloor_Mgr_username := wip_std_wf.GetProductionSchedLogin(x_ship_to_org_id);

	exception
		when no_data_found then
			null;
		when others then
			raise;
	end;

	if x_Shopfloor_Mgr_username is not null then

		wf_engine.SetItemAttrText (  itemtype => itemtype,
        			      	     itemkey  => itemkey,
        	       		      	     aname    => 'SHOPFLOORMGR_USER_NAME',
				      	     avalue   => x_Shopfloor_Mgr_username);

		result := 'COMPLETE:FOUND';
	else
		result := 'COMPLETE:NOT_FOUND';
	end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Find_ShopFloor_Mgr',x_progress);
    	raise;
end;

--

procedure  Find_Requester   ( itemtype        in  varchar2,
                              itemkey         in  varchar2,
	                      actid           in number,
                              funcmode        in  varchar2,
                              result          out nocopy varchar2    )
is
	x_progress               varchar2(3) := '000';
	x_requester_id		 number;
	x_requester_username	 varchar2(100);
	x_requester_display_name varchar2(240);
	x_orig_system		 varchar2(4);
	x_org_id		 number;
begin

	-- set the org context

	x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		  itemkey  => itemkey,
                            	 	          aname    => 'ORG_ID');

	fnd_client_info.set_org_context(to_char(x_org_id));

	x_requester_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'REQUESTER_ID');

	if x_requester_id is not null then

		x_progress := '003';

		-- Get the employee user name

	  	x_orig_system:= 'PER';

	  	WF_DIRECTORY.GetUserName(  x_orig_system,
	        	                   x_requester_id,
       		         	           x_requester_username,
                	        	   x_requester_display_name);

		x_progress := '004';

		if x_requester_username is null then

			-- May want to raise an exception as there is no role defined of the employee.
			result := 'COMPLETE:NOT_FOUND';
		else
			wf_engine.SetItemAttrText (   	itemtype => itemtype,
        				      		itemkey  => itemkey,
        	        		      		aname    => 'REQUESTER_USER_NAME',
					      		avalue   => x_requester_username);

			result := 'COMPLETE:FOUND';
		end if;
	else
		result := 'COMPLETE:NOT_FOUND';
	end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Find_Requester',x_progress);
    	raise;
end;

--

procedure  OSP_Item   ( itemtype        in  varchar2,
                        itemkey         in  varchar2,
	                actid           in number,
                        funcmode        in  varchar2,
                        result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_item_id		number;
	x_osp_item_flag		varchar2(1);
	x_ship_to_org_id	number;
begin

	x_item_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   itemkey  => itemkey,
                            	 	           aname    => 'ITEM_ID');

	x_ship_to_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	  itemkey  => itemkey,
                            	 	           	  aname    => 'SHIP_TO_ORGANIZATION_ID');

	x_progress := '001';

    /* bug 1342116 : if item id is null we should not check for osp flag*/
       IF x_item_id is null THEN
          result := 'COMPLETE:N';
       ELSE
	select distinct OUTSIDE_OPERATION_FLAG
	into x_osp_item_flag
	from mtl_system_items
	where inventory_item_id = x_item_id
	and organization_id = x_ship_to_org_id;

	if nvl(x_osp_item_flag, 'N') = 'Y' then
		result := 'COMPLETE:Y';
	else
		result := 'COMPLETE:N';
	end if;
       END IF;
EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','OSP_Item',x_progress);
    	raise;
end;

--

procedure  Planned_Item   ( itemtype        in  varchar2,
                            itemkey         in  varchar2,
	                    actid           in number,
                            funcmode        in  varchar2,
                            result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_item_id 		number;
	x_planning_item_flag	varchar2(1);
	x_ship_to_org_id	number;
begin

	x_item_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   itemkey  => itemkey,
                            	 	           aname    => 'ITEM_ID');

	x_ship_to_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	  itemkey  => itemkey,
                            	 	           	  aname    => 'SHIP_TO_ORGANIZATION_ID');

	x_progress := '001';

     /* bug 1342116 : if item id is null we should not check for planned item flag*/
      IF x_item_id is null THEN
         result := 'COMPLETE:N';
      ELSE
	select distinct REPETITIVE_PLANNING_FLAG
	into x_planning_item_flag
	from mtl_system_items
	where inventory_item_id = x_item_id
	and organization_id = x_ship_to_org_id;

	if nvl(x_planning_item_flag, 'N') = 'Y' then
		result := 'COMPLETE:Y';
	else
		result := 'COMPLETE:N';
	end if;
       END IF;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Planned_Item',x_progress);
    	raise;
end;

--

procedure  Update_Date   ( itemtype        in  varchar2,
                           itemkey         in  varchar2,
	                   actid           in number,
                           funcmode        in  varchar2,
                           result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_line_location_id	number;
	x_new_date		date;
	x_parent_WF_itemtype	varchar2(10) := 'POSMPDPT';
	x_parent_WF_itemkey	varchar2(240);
	x_org_id		number;
        x_employee_id		number;

begin

	-- set the org context

	x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		  itemkey  => itemkey,
                            	 	          aname    => 'ORG_ID');

        x_employee_id := wf_engine.GetItemAttrNumber (	itemtype => itemtype,
                                   		  	itemkey  => itemkey,
                            	 	          	aname    => 'BUYER_USER_ID');

--        fnd_client_info.set_org_context(to_char(x_org_id));

	x_line_location_id := wf_engine.GetItemAttrNumber ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'LINE_LOCATION_ID');

	x_new_date := wf_engine.GetItemAttrDate ( 	itemtype => itemtype,
                                   		 	itemkey  => itemkey,
                            	 	         	aname    => 'NEW_PROMISED_DATE');

        initialize(x_employee_id, x_org_id);

	UPDATE po_line_locations_all
	SET promised_date = x_new_date,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            request_id = fnd_global.conc_request_id,
            program_application_id = fnd_global.prog_appl_id,
            program_id = fnd_global.conc_program_id,
            program_update_date = sysdate
	WHERE line_location_id = x_line_location_id;

	-- dbms_output.put_line ('DONE updating date');

	--
	-- Update the parent WF to register the acceptance.
	-- The document would have to be routed for approval.
	--

	x_parent_WF_itemkey := wf_engine.GetItemAttrText ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'PARENT_WF_ITEMKEY');

	wf_engine.SetItemAttrText   ( itemtype => x_parent_WF_itemtype,
        			      itemkey  => x_parent_WF_itemkey,
        	        	      aname    => 'UPDATE_ACCEPTED_FLAG',
				      avalue   => 'Y');

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Update_Date',x_progress);
    	raise;
end;

--

procedure  Update_Prom_Needby_Date   ( 	itemtype        in  varchar2,
                           		itemkey         in  varchar2,
	                   		actid           in number,
                           		funcmode        in  varchar2,
                           		result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_line_location_id	number;
	x_new_promised_date	date;
	x_new_needby_date	date;
	x_parent_WF_itemtype	varchar2(10) := 'POSMPDPT';
	x_parent_WF_itemkey	varchar2(240);
	x_org_id		number;
begin

	-- set the org context

	x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		  itemkey  => itemkey,
                            	 	          aname    => 'ORG_ID');

	fnd_client_info.set_org_context(to_char(x_org_id));

	x_line_location_id := wf_engine.GetItemAttrNumber ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'LINE_LOCATION_ID');

	x_new_promised_date := wf_engine.GetItemAttrDate ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'NEW_PROMISED_DATE');

	x_new_needby_date := wf_engine.GetItemAttrDate ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'NEW_NEEDBY_DATE');

	UPDATE po_line_locations_all
	SET promised_date = x_new_promised_date,
	    need_by_date  = x_new_needby_date,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            request_id = fnd_global.conc_request_id,
            program_application_id = fnd_global.prog_appl_id,
            program_id = fnd_global.conc_program_id,
            program_update_date = sysdate
	WHERE line_location_id = x_line_location_id;

	--
	-- Update the parent WF to register the acceptance.
	-- The document would have to be routed for approval.
	--

	x_parent_WF_itemkey := wf_engine.GetItemAttrText ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'PARENT_WF_ITEMKEY');

	wf_engine.SetItemAttrText   ( itemtype => x_parent_WF_itemtype,
        			      itemkey  => x_parent_WF_itemkey,
        	        	      aname    => 'UPDATE_ACCEPTED_FLAG',
				      avalue   => 'Y');
EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Update_Prom_Needby_Date',x_progress);
    	raise;
end;

--

procedure  Update_Parent_WF   ( itemtype        in  varchar2,
                           	itemkey         in  varchar2,
	                   	actid           in number,
                           	funcmode        in  varchar2,
                           	result          out nocopy varchar2    )
is
	x_progress              varchar2(3)  := '000';
	x_parent_WF_itemtype	varchar2(10) := 'POSMPDPT';
	x_parent_WF_itemkey	varchar2(240);
	x_num_of_shipments	number;
	x_org_id	        number;
begin

	-- set the org context

	x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		  itemkey  => itemkey,
                            	 	          aname    => 'ORG_ID');

	fnd_client_info.set_org_context(to_char(x_org_id));

	x_parent_WF_itemkey := wf_engine.GetItemAttrText ( 	itemtype => itemtype,
                                   		 		itemkey  => itemkey,
                            	 	         		aname    => 'PARENT_WF_ITEMKEY');

	x_num_of_shipments := wf_engine.GetItemAttrNumber ( 	itemtype => x_parent_WF_itemtype,
                                   		 		itemkey  => x_parent_WF_itemkey,
                            	 	         		aname    => 'NUMBER_OF_SHIPMENTS');

	wf_engine.SetItemAttrNumber ( itemtype => x_parent_WF_itemtype,
        			      itemkey  => x_parent_WF_itemkey,
        	        	      aname    => 'NUMBER_OF_SHIPMENTS',
				      avalue   => x_num_of_shipments - 1);

	-- Complete Parent WF Process.

	begin

		wf_engine.CompleteActivity(x_parent_WF_itemtype, x_parent_WF_itemkey, 'BLOCK-1', '');
	exception
		when others then
		raise;
	end;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Update_Parent_WF',x_progress);
    	raise;
end;

--

procedure  All_Requesters_Notified  ( itemtype        in  varchar2,
                        itemkey         in  varchar2,
	                actid           in number,
                        funcmode        in  varchar2,
                        result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_item_id		number;
	x_distribution_id	number;
	x_line_location_id	number;
	x_dummy			varchar2(20) := 'No Dist';
	x_current_distribution_num number;
	x_deliver_to_person_id  number;
begin

	x_current_distribution_num := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   		    itemkey  => itemkey,
                            	 	           		    aname    => 'CURRENT_DISTRIBUTION');

	x_line_location_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		   	    itemkey  => itemkey,
                            	 	           	    aname    => 'LINE_LOCATION_ID');

	x_progress := '001';

	begin
		select 'Dist Exists', deliver_to_person_id
		into x_dummy, x_deliver_to_person_id
		from po_distributions_all
		where line_location_id = x_line_location_id
		and distribution_num = x_current_distribution_num;

		-- increment current distribution number
		x_current_distribution_num := x_current_distribution_num + 1;

	exception
		when no_data_found then
			null;
		when others then
			raise;
	end;

	if nvl(x_dummy, 'null') = 'Dist Exists' then

		-- update dist. num. item attribute

		wf_engine.SetItemAttrText ( itemtype => itemtype,
        				    itemkey  => itemkey,
        	        		    aname    => 'CURRENT_DISTRIBUTION',
					    avalue   => x_current_distribution_num);

		if x_deliver_to_person_id is not null  then

			-- set requester attribute

			wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        					    itemkey  => itemkey,
        	        			    aname    => 'REQUESTER_ID',
						    avalue   => x_deliver_to_person_id);

			result := 'COMPLETE:N';

		end if;
	else
		result := 'COMPLETE:Y';
	end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','All_Requesters_Notified',x_progress);
    	raise;
end;

--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out nocopy varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_acceptance_result	varchar2(30);
begin

  fnd_message.set_name ('ICX','POS_PO_WF_ACCEPTED_VALUE');
  x_acceptance_result := fnd_message.get;

  wf_engine.SetItemAttrText ( itemtype => itemtype,
        	              itemkey  => itemkey,
                	      aname    => 'ACCEPTANCE_RESULT',
			      avalue   => nvl(x_acceptance_result, 'Accepted'));
EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_CHANGE_PROM_DATES','Register_acceptance',x_progress);
    	raise;
end;


PROCEDURE initialize(x_employee_id in NUMBER,x_org_id IN NUMBER) IS

  x_resp_id NUMBER := -1;
  x_user_id NUMBER := -1;
  x_resp_appl_id NUMBER := 201;

BEGIN
   begin
	SELECT FND.user_id
	INTO   x_user_id
	FROM   FND_USER FND, HR_EMPLOYEES_CURRENT_V HR
        WHERE  HR.EMPLOYEE_ID = x_employee_id
        AND    FND.EMPLOYEE_ID = HR.EMPLOYEE_ID
        AND    ROWNUM = 1;

   EXCEPTION
      WHEN OTHERS THEN
	 x_user_id := -1;
   END;


   BEGIN

     FND_PROFILE.GET('RESP_ID', x_resp_id);

     if x_resp_id is NULL then

	select MIN(fr.responsibility_id)
	into x_resp_id
   	from fnd_user_resp_groups fur,
	     fnd_responsibility fr,
	     financials_system_params_all fsp
	  where fur.user_id = x_user_id
	    and fur.responsibility_application_id = x_resp_appl_id
	    and fur.responsibility_id = fr.responsibility_id
	    and fr.start_date < sysdate
	    and nvl(fr.end_date, sysdate +1) >= sysdate
	    and fur.start_date < sysdate
	    and nvl(fur.end_date, sysdate +1) >= Sysdate
	    AND nvl(fnd_profile.value_specific('ORG_ID', NULL, fr.responsibility_id, fur.responsibility_application_id),-1) = nvl(x_org_id,-1)
           and nvl(fsp.org_id,-1) = nvl(x_org_id,-1)
           and nvl(fsp.business_group_id,-1) = nvl(fnd_profile.value_specific('PER_BUSINESS_GROUP_ID', NULL, fr.responsibility_id, fur.responsibility_application_id),-1);

     end if;

   EXCEPTION
     when others then
	x_resp_id := -1;
   END;

    FND_GLOBAL.APPS_INITIALIZE(x_user_id,x_resp_id,x_resp_appl_id);

END initialize;



END POS_CHANGE_PROM_DATES;

/
