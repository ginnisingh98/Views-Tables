--------------------------------------------------------
--  DDL for Package Body POS_WF_PO_ACKNOWLEDGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_WF_PO_ACKNOWLEDGE" AS
/* $Header: POSWPOAB.pls 115.4 2003/07/24 02:41:52 rbairraj noship $ */


--

/*
	Private Procedure
*/

Procedure Insert_Acc_Rejection_Row(itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in  number,
				   flag		   in  varchar2);


--
--
--

procedure  acceptance_required   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_doc_header_id		number;
	x_acceptance_flag	varchar2(1) := null;
	x_acceptance_due_date	date;
	x_progress              varchar2(3) := '000';
begin
	x_progress := '001';

  	x_acceptance_due_date := wf_engine.GetItemAttrDate ( itemtype => itemtype,
        		         			     itemkey  => itemkey,
                		 			     aname    => 'ACCEPTANCE_DUE_DATE');

  	x_acceptance_flag := wf_engine.GetItemAttrText ( itemtype => itemtype,
        		         			 itemkey  => itemkey,
                		 			 aname    => 'ACCEPTANCE_REQUIRED');

	if (x_acceptance_due_date is NULL or nvl(x_acceptance_flag, 'N') <> 'Y') then

  		wf_engine.SetItemAttrText (   itemtype => itemtype,
        			              itemkey  => itemkey,
                			      aname    => 'BY',
					      avalue   => '');
	end if;

	result := 'COMPLETE:' || nvl(x_acceptance_flag, 'N');

exception
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_ACKNOWLEDGE','acceptance_required',x_progress);
    	raise;
end;

--

procedure  Register_acceptance   ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_acceptance_result	varchar2(30);
	x_org_id		number;
begin

  -- set the org context
  x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	    itemkey  => itemkey,
                            	 	    aname    => 'ORG_ID');

  fnd_client_info.set_org_context(to_char(x_org_id));

  fnd_message.set_name ('ICX','POS_PO_WF_ACCEPTED_VALUE');
  x_acceptance_result := fnd_message.get;

  wf_engine.SetItemAttrText ( itemtype => itemtype,
        	              itemkey  => itemkey,
                	      aname    => 'ACCEPTANCE_RESULT',
			      avalue   => nvl(x_acceptance_result, 'Accepted'));

  -- insert acceptance record.

  Insert_Acc_Rejection_Row(itemtype, itemkey, actid, 'Y');

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_ACKNOWLEDGE','Register_acceptance',x_progress);
    	raise;
end;

--

procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_progress              varchar2(3) := '000';
	x_acceptance_result	varchar2(30);
	x_org_id		number;
begin

  -- set the org context
  x_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	    itemkey  => itemkey,
                            	 	    aname    => 'ORG_ID');

  fnd_client_info.set_org_context(to_char(x_org_id));

  fnd_message.set_name ('ICX','POS_PO_WF_REJECTED_VALUE');
  x_acceptance_result := fnd_message.get;

  wf_engine.SetItemAttrText ( itemtype => itemtype,
        	              itemkey  => itemkey,
                	      aname    => 'ACCEPTANCE_RESULT',
			      avalue   => nvl(x_acceptance_result, 'Rejected'));

  -- insert rejection record.

  Insert_Acc_Rejection_Row(itemtype, itemkey, actid, 'N');

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_ACKNOWLEDGE','Register_rejection',x_progress);
    	raise;
end;

--

procedure  Initialize_Attributes(  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_document_id number;
	x_document_type_code varchar2(60);
	x_document_num	varchar2(60);
	x_document_type	varchar2(80);
	x_release_num	number := null;
	x_agent_id	number;
	x_acceptance_required_flag varchar2(1);
	x_acceptance_due_date date := null;
	x_progress      varchar2(3) := '000';
	x_org_id	number;
  	p_rowid    VARCHAR2(2000);
  	l_param    VARCHAR2(2000);
begin
	x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'DOCUMENT_ID');

	x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                   		       	      itemkey  => itemkey,
                            	 	               	      aname    => 'DOCUMENT_TYPE_CODE');
	--dbms_output.put_line('Document Code is ' || x_document_type_code );
	if x_document_type_code <> 'RELEASE' then

		select poh.segment1 || '-' || poh.revision_num, polc.displayed_field, poh.agent_id,
		       poh.acceptance_required_flag, poh.acceptance_due_date, poh.org_id
		into x_document_num, x_document_type, x_agent_id, x_acceptance_required_flag,
			x_acceptance_due_date, x_org_id
		from po_headers_all poh,
		     po_lookup_codes polc
		where poh.po_header_id = x_document_id
		and   poh.type_lookup_code = polc.lookup_code
		and   polc.lookup_type = 'PO TYPE';

		wf_engine.SetItemAttrText ( itemtype => itemtype,
        				    itemkey  => itemkey,
        		        	    aname    => 'FOR',
					    avalue   => '');

	else
		select por.release_num, por.agent_id, poh.segment1 || '-' || poh.revision_num, polc.displayed_field,
			 por.acceptance_required_flag, por.acceptance_due_date, por.agent_id
		into x_release_num, x_agent_id, x_document_num, x_document_type, x_acceptance_required_flag,
			x_acceptance_due_date, x_agent_id
		from po_releases_all por,
		     po_headers_all poh,
		     po_lookup_codes polc
		where por.po_release_id = x_document_id
		and   por.po_header_id = poh.po_header_id
		and   polc.lookup_type = 'DOCUMENT TYPE'
		and   polc.lookup_code = 'RELEASE';
	end if;

	-- Set Item Attributes.

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'DOCUMENT_NUM',
				    avalue   => x_document_num);

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'DOCUMENT_TYPE',
				    avalue   => x_document_type);

	wf_engine.SetItemAttrText ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'ACCEPTANCE_REQUIRED',
				    avalue   => x_acceptance_required_flag);

	wf_engine.SetItemAttrDate ( itemtype => itemtype,
        			    itemkey  => itemkey,
        	        	    aname    => 'ACCEPTANCE_DUE_DATE',
				    avalue   => x_acceptance_due_date);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'RELEASE_NUM',
				      avalue   => x_release_num);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'BUYER_USER_ID',
				      avalue   => x_agent_id);

	wf_engine.SetItemAttrNumber ( itemtype => itemtype,
        			      itemkey  => itemkey,
        	        	      aname    => 'ORG_ID',
				      avalue   => x_org_id);

    	wf_engine.SetItemAttrText( itemtype => itemtype,
                              	   itemkey  => itemkey,
                              	   aname    => 'PO_DETAILS_URL',
                              	   avalue   => 'PLSQL:POS_WF_PO_COMMON_APIS.GET_PO_DETAILS_URL/' ||
                         			itemtype || ':' || itemkey);
EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_ACKNOWLEDGE','Initialize_Attributes',x_progress);
    	raise;
end;


--


Procedure Insert_Acc_Rejection_Row(itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in  number,
				   flag		   in  varchar2)
is

   x_row_id             varchar2(30);
   x_Acceptance_id      number;
   -- Bug 2850566
   x_Last_Update_Date   date ;
   x_Last_Updated_By    number;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   -- End of Bug 2850566
   x_Creation_Date      date           	:=  TRUNC(SYSDATE);
   x_Created_By         number         	:=  fnd_global.user_id;
   x_Po_Header_Id       number;
   x_Po_Release_Id      number;
   x_Action             varchar2(240)	:= 'NEW';
   x_Action_Date        date    	:=  TRUNC(SYSDATE);
   x_Employee_Id        number;
   x_Revision_Num       number;
   x_Accepted_Flag      varchar2(1)	:= flag;
   x_Acceptance_Lookup_Code varchar2(25);
   x_Attribute_Category varchar2(30);
   x_Attribute1         varchar2(150);
   x_Attribute2         varchar2(150);
   x_Attribute3         varchar2(150);
   x_Attribute4         varchar2(150);
   x_Attribute5         varchar2(150);
   x_Attribute6         varchar2(150);
   x_Attribute7         varchar2(150);
   x_Attribute8         varchar2(150);
   x_Attribute9         varchar2(150);
   x_Attribute10        varchar2(150);
   x_Attribute11        varchar2(150);
   x_Attribute12        varchar2(150);
   x_Attribute13        varchar2(150);
   x_Attribute14        varchar2(150);
   x_Attribute15        varchar2(150);
   x_document_id	number;
   x_document_type_code varchar2(30);
begin

    --  Bug 2850566 RBAIRRAJ
    --  Commenting out the code for selecting the Acceptance Id as it is
    --  handled in the PO_ACCEPTANCE row handler

	--  SELECT po_acceptances_s.nextval into x_Acceptance_id FROM sys.dual;

	if flag = 'Y' then
		x_Acceptance_Lookup_Code := 'Accepted Terms';
	else
		x_Acceptance_Lookup_Code := 'REJECTED';
	end if;

	x_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'DOCUMENT_ID');

	x_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                   		       	      itemkey  => itemkey,
                            	 	               	      aname    => 'DOCUMENT_TYPE_CODE');

	-- abort any outstanding acceptance notifications for any previous revision of the document.

	if x_document_type_code <> 'RELEASE' then
		x_Po_Header_Id := x_document_id;

		select revision_num
		into x_revision_num
		from po_headers
		where po_header_id = x_document_id;
	else
		x_Po_Release_Id := x_document_id;

		select po_header_id, revision_num
		into x_Po_Header_Id, x_revision_num
		from po_releases
		where po_release_id = x_document_id;
	end if;

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.
    PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid                 =>  x_row_id,
			x_acceptance_id			=>  x_Acceptance_id,
            x_Last_Update_Date      =>  x_Last_Update_Date,
            x_Last_Updated_By       =>  x_Last_Updated_By,
            x_Last_Update_Login     =>  l_Last_Update_Login,
			p_creation_date			=>  x_Creation_Date,
			p_created_by			=>  x_Created_by,
			p_po_header_id			=>  x_Po_Header_Id,
			p_po_release_id			=>  x_Po_Release_Id,
			p_action			    =>  x_Action,
			p_action_date			=>  x_Action_Date,
			p_employee_id			=>  x_Employee_Id,
			p_revision_num			=>  x_Revision_Num,
			p_accepted_flag			=>  x_Accepted_Flag,
			p_acceptance_lookup_code=>  x_Acceptance_Lookup_Code,
			p_attribute_category	=>  x_Attribute_Category,
			p_attribute1			=>  x_Attribute1,
			p_attribute2			=>  x_Attribute2,
			p_attribute3			=>  x_Attribute3,
			p_attribute4			=>  x_Attribute4,
			p_attribute5			=>  x_Attribute5,
			p_attribute6			=>  x_Attribute6,
			p_attribute7			=>  x_Attribute7,
			p_attribute8			=>  x_Attribute8,
			p_attribute9			=>  x_Attribute9,
			p_attribute10			=>  x_Attribute10,
			p_attribute11			=>  x_Attribute11,
			p_attribute12			=>  x_Attribute12,
			p_attribute13			=>  x_Attribute13,
			p_attribute14			=>  x_Attribute14,
			p_attribute15			=>  x_Attribute15);

exception
	when others then
	raise;
end;

--

procedure abort_notification ( document_id	in number, document_rev	in number, document_type varchar2)
is
	x_progress    	varchar2(3)  := '000';
	l_item_type	varchar2(10) := 'POSPOACK';
	l_item_key	varchar2(240);
	x_document_type_code	varchar2(60);
	x_acceptance_required 	varchar2(1) := 'N';
	x_org_id		number;
begin

	l_item_key := 'POS_ACK_' || to_char (document_id) || '_' || to_char(nvl(document_rev, 0));

  	-- set the org context
	begin
  		x_org_id := wf_engine.GetItemAttrNumber ( itemtype => l_item_type,
                                   	    	  	  itemkey  => l_item_key,
                            	 	    	  	  aname    => 'ORG_ID');

  		fnd_client_info.set_org_context(to_char(x_org_id));

		if document_type = 'RELEASE' then
			select nvl(acceptance_required_flag, 'N')
			into x_acceptance_required
			from po_releases
			where po_release_id = document_id;
		else
			select nvl(acceptance_required_flag, 'N')
			into x_acceptance_required
			from po_headers
			where po_header_id = document_id;
		end if;
	exception
		when others then
		null;
	end;

	if x_acceptance_required = 'Y' then
	   begin
		-- Abort the notification - workflow will take the default transition.

		wf_engine.completeActivity ( l_item_type, l_item_key, 'NOTIFY_SUPPLIER', 'Abort' );

	   exception
		when others then
		null;
	   end;
	end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('POS_WF_PO_ACKNOWLEDGE','abort_notifications',x_progress);
    	raise;
end;

--

END POS_WF_PO_ACKNOWLEDGE;

/
