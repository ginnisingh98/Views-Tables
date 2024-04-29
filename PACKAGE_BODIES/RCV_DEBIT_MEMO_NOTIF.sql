--------------------------------------------------------
--  DDL for Package Body RCV_DEBIT_MEMO_NOTIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_DEBIT_MEMO_NOTIF" AS
/* $Header: RCVWFDMB.pls 120.1.12010000.6 2014/03/19 23:16:25 vthevark ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   RCVWPA1B.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package: RCV_DEBIT_MEMO_NOTIF
 |
 | NOTES        dreddy  Created 3/30/2000
 |
 *=======================================================================*/

--
-- get the receipt_info
-- call the workflow
--
PROCEDURE dm_workflow_call(x_transaction_id    number)is
l_seq           varchar2(80);
EmployeeId      number;
ReceiptNum      varchar2(20);
PONumber        po_headers_all.clm_document_number%type; -- Bug 9342280
x_ship_id       number;
x_po_header_id  number;
x_po_release_id number;  -- Bug 18419254
Quantity        number;
ItemKey         varchar2(80);
ItemType        varchar2(80);
WorkflowProcess varchar2(80);
x_progress      varchar2(30);

x_errormessage    varchar2(2000) := '';  -- Bug 16925688

BEGIN

/* 4698050 - debit memo failure notiifacations should goto buyer rather than to
   receiver. commenting the below selection of employee_id from rcv_transactions
   and getting the same from po_headers as below.
*/
        x_progress := '010';

         select shipment_header_id,
--                employee_id,   -- Bugfix #4698050
                quantity,
                po_header_id,
                po_release_id    -- Bug 18419254
         into   x_ship_id,
--                EmployeeId,    -- BUgFix 4698050
                Quantity,
                x_po_header_id,
                x_po_release_id  -- Bug 18419254
         from rcv_transactions
         where transaction_id = x_transaction_id ;

       x_progress := '020';

         select receipt_num
         into ReceiptNum
         from rcv_shipment_headers
         where shipment_header_id = x_ship_id;

         x_progress := '030';

         /* Bug 9342280 Modified the from clause below from po_headers to
            po_headers_trx_v to accomodate CLM PO Number changes */

         select segment1,agent_id  -- BugFix 4698050
         into PONumber,EmployeeId  -- BugFix 4698050
         from po_headers_trx_v
         where po_header_id = x_po_header_id;

         -- Bug 18419254 : Buyer on BPA and releases can be different. DM failure notification needs to go to buyer in the release.
         x_progress := '035';
         IF (x_po_release_id IS NOT NULL) THEN
          select agent_id
          into   EmployeeId
          from   po_releases
          where  po_release_id = x_po_release_id;
         END IF;

         x_progress := '040';

		  /* Bug 16925688 added error message */
         Begin
             select max(error_message)
                 into x_errormessage
             from po_interface_errors pie,
                  rcv_transactions rt
             where   rt.transaction_id = x_transaction_id
                 and pie.interface_line_id = rt.interface_transaction_id;
         EXCEPTION
             WHEN OTHERS THEN
                 null;
         End;
         /* Bug 16925688 end */

         select to_char(PO_WF_ITEMKEY_S.NEXTVAL) into l_seq from sys.dual;
         ItemKey := ReceiptNum || '-' || l_seq;
         ItemType := 'RCVDMEMO' ;
         WorkflowProcess := 'RCV_DEBIT_MEMO';

          -- call the WF

           Start_WF_Process ( ItemType => ItemType,
      	 		      ItemKey => ItemKey,
 			      WorkflowProcess => WorkflowProcess,
                              ReceiptNum => ReceiptNum,
                              EmployeeId => EmployeeId ,
                              Quantity => Quantity,
                              PONumber => PONumber,
                              ErrorMessage => x_errormessage);   -- Bug 16925688
 EXCEPTION
 WHEN OTHERS THEN

   x_progress := '050';

   po_message_s.sql_error('In Exception of dm_workflow_call()', x_progress, sqlcode);

   RAISE;

END dm_workflow_call;


--  Start_WF_Process
--  Generates the itemkey, sets up the Item Attributes,
--  then starts the workflow process.
--
PROCEDURE Start_WF_Process ( ItemType               VARCHAR2,
                             ItemKey                VARCHAR2,
                             WorkflowProcess        VARCHAR2,
                             ReceiptNum             VARCHAR2,
                             EmployeeId             NUMBER,
                             Quantity               NUMBER,
                             PONumber               VARCHAR2,
                              ErrorMessage           VARCHAR2 ) is  --bug 16925688 add

x_progress              varchar2(300);
x_wf_created		number;
p_orig_system           varchar2(20);
x_username              varchar2(100);
x_user_display_name     varchar2(240);
l_message1              varchar2(2000);
l_message2              varchar2(2000);
l_message3              varchar2(2000);
l_message4              varchar2(2000);
l_message               varchar2(2000);

BEGIN


 IF  ( ItemType is NOT NULL )   AND
      ( ItemKey is NOT NULL)     AND
      ( ReceiptNum is NOT NULL ) THEN

	-- check to see if process has already been created
	-- if it has, don't create process again.
	begin
	  select count(*)
	  into   x_wf_created
	  from   wf_items
	  where  item_type = ItemType
	  and  item_key  = ItemKey;

	end;

       commit;

       if x_wf_created = 0 then
        wf_engine.CreateProcess( ItemType => ItemType,
                                 ItemKey  => ItemKey,
                                 process  => WorkflowProcess );
       end if;

-- get the user id
        p_orig_system:= 'PER';
        WF_DIRECTORY.GetUserName(p_orig_system,
                                 EmployeeId,
                                 x_username,
                                 x_user_display_name);

-- get the message to be sent

        l_message  := fnd_message.get_string('PO', 'RCV_WF_NOTIF_DEBIT_MEMO');
        l_message1 := fnd_message.get_string('PO', 'RCV_WF_DM_MSG1');
        l_message2 := fnd_message.get_string('PO', 'RCV_WF_DM_MSG2');
        l_message3 := fnd_message.get_string('PO', 'RCV_WF_DM_MSG3');
        l_message4 := fnd_message.get_string('PO', 'RCV_WF_DM_MSG4');

		 if ErrorMessage is not null then
		  l_message3 :='"' || ErrorMessage || '"'||fnd_global.local_chr(10)||fnd_global.local_chr(10)||l_message3 ;   -- Bug 16925688 added
        end if;

-- Initialize workflow item attributes


        --
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'USER_NAME' ,
                              avalue     => x_username);

        --
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'USER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'RECEIPT_NUM',
                                        avalue          =>  ReceiptNum);

        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'QUANTITY',
                                        avalue          =>  Quantity);

        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'PO_NUMBER',
                                        avalue          =>  PONumber);
        --

        wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RCV_DM_NOTIF_MSG',
                            avalue   => l_message);

        --
        wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RCV_DM_MSG1',
                            avalue   => l_message1);
        --
        wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RCV_DM_MSG2',
                            avalue   => l_message2);

       --
        wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RCV_DM_MSG3',
                            avalue   => l_message3);

       --
        wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'RCV_DM_MSG4',
                            avalue   => l_message4);
       --

        wf_engine.StartProcess(itemtype        => itemtype,
                               itemkey         => itemkey );

   END IF;

EXCEPTION
 WHEN OTHERS THEN

   x_progress :=  'RCV_DEBIT_MEMO_NOTIF.Start_WF_Process: In Exception handler';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

   po_message_s.sql_error('In Exception of Start_WF_Process()', x_progress, sqlcode);

   RAISE;

END Start_WF_Process;

END RCV_DEBIT_MEMO_NOTIF;

/
