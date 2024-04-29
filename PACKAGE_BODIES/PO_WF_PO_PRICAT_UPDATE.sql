--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_PRICAT_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_PRICAT_UPDATE" AS
/* $Header: POXWPCTB.pls 115.4 2002/11/21 03:17:48 sbull ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWPCAB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_WF_PO_PRICAT_UPDATE
 |
 | NOTES
 | MODIFIED    IMRAN ALI (08/25/98) - Created
 *=====================================================================*/

--
-- Process_line_items
--

procedure process_line_items     ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_progress                varchar2(100);
	x_interface_header_id	  number;
	x_batch_id		  number;
   	x_buyer_id                NUMBER;
   	x_document_type           VARCHAR2(25);
   	x_document_subtype        VARCHAR2(25);
   	x_create_items            VARCHAR2(1) := 'N';
   	x_create_source_rule_flag VARCHAR2(1) := 'N';
   	x_approval_status         VARCHAR2(25);
   	x_rel_gen_method          VARCHAR2(25);
   	x_commit_interval         NUMBER := 1;
	X_process_code 		  varchar2(25) := 'NOTIFIED';
	x_current_line_accept_flag varchar2(1);
	c_price_chg_accept_flag	   varchar2(1);
	c_price_break_flag	   varchar2(1);
	c_interface_header_id	   number;
	c_interface_line_id	   number;

  	cursor C_temp_lines_interface IS
     		SELECT	interface_header_id, interface_line_id, price_chg_accept_flag, price_break_flag
       		FROM	po_lines_interface
      		WHERE	interface_header_id = X_interface_header_id
		AND	NVL(process_code, 'PENDING') = X_process_code
      		ORDER	By	interface_line_id, unit_price desc;

begin

  x_progress := 'PO_WF_PO_PRICAT_UPDATE.process_line_items: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode

  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_interface_header_id := wf_engine.GetItemAttrNumber  ( itemtype => itemtype,
                                   		          itemkey  => itemkey,
                            	 	                  aname    => 'INTERFACE_HEADER_ID');

  x_batch_id 		:= wf_engine.GetItemAttrNumber  ( itemtype => itemtype,
                                   		          itemkey  => itemkey,
                            	 	                  aname    => 'BATCH_ID');

  x_buyer_id 		:= wf_engine.GetItemAttrNumber  ( itemtype => itemtype,
                                   		       	  itemkey  => itemkey,
                            	 	               	  aname    => 'BUYER_ID');

  x_document_type 	:= wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'DOCUMENT_TYPE_CODE');

  x_document_subtype 	:= wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'DOCUMENT_SUBTYPE');

  x_rel_gen_method 	:= wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'RELEASE_GEN_METHOD');

  x_approval_status 	:= wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'APPROVAL_STATUS');


  IF (g_po_pdoi_write_to_file = 'Y') THEN
     po_debug.put_line ('Procedure PO_WF_PO_PRICAT_UPDATE.Process_line_items');
     po_debug.put_line ('INTERFACE_HEADER_ID: ' || to_char(x_interface_header_id));
     po_debug.put_line ('BATCH_ID: ' || to_char(x_batch_id));
  END IF;

  -- Call the Purchasing Open Interface to process the records. Use the Batch ID saved in
  -- the WF attributes when the WF was initiated and interface_header_id to call the POI so
  -- that only those rows are processed which have been pending for this document.

  --
  -- Update the price_chg_accept_flag for price breaks;
  --

  OPEN	C_temp_lines_interface;
  LOOP

    FETCH C_temp_lines_interface
    INTO  c_interface_header_id, c_interface_line_id, c_price_chg_accept_flag, c_price_break_flag;

    EXIT WHEN C_temp_lines_interface%NOTFOUND;

    if ( NVL(c_price_break_flag, 'N') = 'N' ) then

	-- process line and get the acceptance flag.

    	x_current_line_accept_flag := c_price_chg_accept_flag;
    else

	-- process price break - update acceptance flag.

	update po_lines_interface
	set price_chg_accept_flag = x_current_line_accept_flag
	where interface_header_id = c_interface_header_id
	and   interface_line_id   = c_interface_line_id;

    end if;

  END LOOP;

  CLOSE C_temp_lines_interface;

  --
  -- Call POI here
  --

  po_docs_interface_sv5.process_po_headers_interface(  	X_batch_id,
          						X_buyer_id,
          						X_document_type,
          						X_document_subtype,
          						X_create_items,
          						X_create_source_rule_flag,
          						X_rel_gen_method,
          						X_approval_status,
          						X_commit_interval,
							X_process_code  );

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('PO_WF_PO_PRICAT_UPDATE','process_line_items',x_progress);
    	raise;
end process_line_items;


-- ************************************************************************* --

procedure  were_all_items_processed     ( itemtype        in  varchar2,
                              	   	  itemkey         in  varchar2,
	                           	  actid           in number,
                                   	  funcmode        in  varchar2,
                                   	  result          out NOCOPY varchar2    )
is
	x_interface_header_id	number;
	x_progress              varchar2(100);
begin

  x_interface_header_id := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'INTERFACE_HEADER_ID');

  result := 'COMPLETE:Y';

  begin
  	select 'COMPLETE:N' into result from sys.dual
  	where exists ( select 'un_processed_items_exist'
		 from PO_LINES_INTERFACE
		 where interface_header_id = x_interface_header_id
		 and NVL(process_code, 'PENDING') = 'NOTIFIED'
		 and NVL(price_chg_accept_flag,'NULL') = 'NULL' );
  exception
	when no_data_found then
	result := 'COMPLETE:Y';
  end;

  return;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('PO_WF_PO_PRICAT_UPDATE','were_all_items_processed',x_progress);
    	raise;
end;

-- ************************************************************************* --

procedure  were_any_items_rejected      ( itemtype        in  varchar2,
                              	   	  itemkey         in  varchar2,
	                           	  actid           in number,
                                   	  funcmode        in  varchar2,
                                   	  result          out NOCOPY varchar2    )
is
	x_interface_header_id	number;
	x_progress              varchar2(100);
begin

  x_interface_header_id := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		       itemkey  => itemkey,
                            	 	               aname    => 'INTERFACE_HEADER_ID');

  result := 'COMPLETE:N';

  begin
  	select 'COMPLETE:Y' into result from sys.dual
  	where exists ( select 'items_were_rejected'
		 from PO_LINES_INTERFACE
		 where interface_header_id = x_interface_header_id
		 and NVL(process_code, 'PENDING') = 'NOTIFIED'
		 and NVL(price_chg_accept_flag,'NULL') = 'N');
  exception
	when no_data_found then
	result := 'COMPLETE:N';
  end;

  return;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('PO_WF_PO_PRICAT_UPDATE','were_any_items_rejected',x_progress);
    	raise;
end;

-- ************************************************************************* --

procedure  cancel_buyer_notif    ( itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
	                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
	x_progress              varchar2(10) := '001';
	x_nid			number := NULL;
begin

  -- Find all outstanding notifications to the buyer for this document and
  -- cancel them.

  -- As we loop back in the WF there can be only one outstanding notification.

  begin
  	select notification_id into x_nid
  	from wf_item_activity_statuses_v
  	where item_type = itemtype
  	AND item_key = itemkey
  	AND ACTIVITY_NAME = 'BUYER_NOTIFICATION';

  exception
	when others then
	null;
  end;

  x_progress := '002';

  if x_nid is not null then

	-- Need to trap the exception as the notification may not be open.
	begin
		wf_notification.cancel (x_nid, NULL);
	exception
		when others then
		null;
	end;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    	wf_core.context('PO_WF_PO_PRICAT_UPDATE','cancel_buyer_notif',x_progress);
    	raise;
end  cancel_buyer_notif;

END  PO_WF_PO_PRICAT_UPDATE;

/
