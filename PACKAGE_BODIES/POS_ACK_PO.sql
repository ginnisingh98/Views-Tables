--------------------------------------------------------
--  DDL for Package Body POS_ACK_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ACK_PO" AS
/* $Header: POSISPAB.pls 120.5.12010000.2 2008/08/02 14:55:34 sthoppan ship $ */

g_pkg_name CONSTANT VARCHAR2(50) := 'POS_ACK_PO';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/*	Bug No: 6670166
	Added g_default_promise_date global variable to get the POS_DEFAULT_PROMISE_DATE_ACK profile value. */

g_default_promise_date VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('POS_DEFAULT_PROMISE_DATE_ACK'),'N');
/*Bug 6772960
  Modified the signature which takes l_last_update_date as IN parameter
  and returns x_error as OUT parameter. l_last_update_date is used to
  check the concurrency i.e., to check whether multiple supplier users
  are acting on the same PO simutaneously. If the supplier try to modify
  the PO which has already been modified by other user x_error returns false.
*/
PROCEDURE ACKNOWLEDGE_PO (
   l_po_header_id     IN VARCHAR2,
   l_po_release_id    IN VARCHAR2 default null,
   l_po_buyer_id      IN VARCHAR2,
   l_po_accept_reject IN VARCHAR2,
   l_po_acc_type_code IN VARCHAR2,
   l_po_ack_comments  IN VARCHAR2 ,
   l_user_id          IN VARCHAR2,
   l_last_update_date IN DATE DEFAULT fnd_api.G_NULL_DATE,
   x_error            OUT  NOCOPY VARCHAR2)
IS
   l_acceptance_id     NUMBER;
   l_revision_num      NUMBER := 0;
   l_error	       VARCHAR2(240);
   l_item_type         VARCHAR2(20) := 'POSACKNT';
   l_seq_val           NUMBER;
   l_item_key          VARCHAR2(100);
   l_accp_type         VARCHAR2(240);
   l_accp_res          fnd_new_messages.message_text%type := null;
   l_doc               NUMBER;
   l_nid               NUMBER;
   l_doc_type          VARCHAR2(20);
   l_po_item_type      VARCHAR2(100);
   l_po_item_key       VARCHAR2(100);
   l_supp_username     VARCHAR2(100);
   l_supplier_displayname VARCHAR2(100);
   l_action 	       VARCHAR2(20);
   x_vendor	VARCHAR2(240);
   l_pending_signature_flag PO_HEADERS_ALL.pending_signature_flag%type;
   x_row_id             varchar2(30);
   x_Acceptance_id      number;
   x_Last_Update_Date   date ;
   x_Last_Updated_By    number;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   x_Creation_Date      date           	:=  TRUNC(SYSDATE);
   x_Created_By         number         	:=  fnd_global.user_id;
   x_Po_Header_Id       number;
   x_Po_Release_Id      number;
   x_Action             varchar2(240)	:= 'NEW';
   x_Action_Date        date    	:=  TRUNC(SYSDATE);
   x_Employee_Id        number;
   x_Revision_Num       number;
   x_Accepted_Flag      varchar2(1)	:= '';
   x_Acceptance_Lookup_Code varchar2(25);
   x_document_id	number;
   x_document_type_code varchar2(30);
   l_signature_flag     VARCHAR2(10);
   l_accepting_party    VARCHAR2(1);
   l_role               VARCHAR2(150);
   l_doc_subtype 	VARCHAR2(20);
   l_api_name           VARCHAR2(100) := 'ACKNOWLEDGE_PO';
   l_progress           VARCHAR2(100);
   l_message_name       varchar2(30);
   l_wf_user_id        number;
   l_wf_resp_id        number;
   l_wf_appl_id        number;
   l_wf_org_id         number;

   --Bug 6772960 - Start
   /*Added the l_last_upd_date variables to check the concurrency.
     Added the cursors to get the latest last_update_date which is there in the database.
   */
   l_last_upd_date        po_headers_all.last_update_date%type;

   CURSOR PO_CSR(p_po_header_id in number) IS
        SELECT last_update_date
        FROM   PO_HEADERS_ALL
        WHERE  PO_HEADER_ID = p_po_header_id
        FOR UPDATE of last_update_date NOWAIT;

   poRec PO_CSR%ROWTYPE;

   CURSOR REL_CSR(p_po_release_id in number) IS
        SELECT last_update_date
        FROM   PO_RELEASES_ALL
        WHERE  PO_RELEASE_ID = p_po_release_id
        FOR UPDATE of last_update_date NOWAIT;

   relRec REL_CSR%ROWTYPE;

   CURSOR NID_CSR(p_nid in number) IS
     select notification_id
     from   wf_notifications
     where  notification_id = p_nid
     FOR UPDATE of notification_id NOWAIT;

   nidRec NID_CSR%ROWTYPE;
   --Bug 6772960 - End

BEGIN

   --  Find if a notification has been sent thru core PO
   --  then complete the activity , if not then do the regular

   --dbms_output.put_line('Starting Offf');
   l_progress := '0';
  if l_po_release_id is null then

   --dbms_output.put_line('For Releases');
  begin
   select a.notification_id,poh.wf_item_type,poh.wf_item_key, a.message_name
   INTO   l_nid,l_po_item_type,l_po_item_key, l_message_name
   from   wf_notifications a,po_headers_all poh,
          wf_item_activity_statuses wa
   where  poh.po_header_id=l_po_header_id
   and    poh.wf_item_key=wa.item_key
   and    poh.wf_item_type=wa.item_type
   and    a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
   and    a.notification_id=wa.notification_id and a.status = 'OPEN'
   and    wa.activity_status = 'NOTIFIED';
  exception
   when no_data_found then l_nid := null;
  end;

  else
  begin
   --dbms_output.put_line('For Std PO');
   select a.notification_id,por.wf_item_type,por.wf_item_key
   INTO  l_nid,l_po_item_type,l_po_item_key
   from  wf_notifications a,po_releases_all por,
         wf_item_activity_statuses wa
   where por.po_release_id=l_po_release_id
   and   por.wf_item_key=wa.item_key
   and   por.wf_item_type=wa.item_type
   and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
   and   a.notification_id=wa.notification_id and a.status = 'OPEN'
   and   wa.activity_status = 'NOTIFIED';
  exception
   when no_data_found then l_nid := null;
  end;

  end if;
l_progress := '1';
   --Commented out since l_po_acc_type_code is passed in as null from FPI.
   /*
   select description into l_accp_type from POS_ACK_ACC_TYPE_LOV_V
   where LOOKUP_CODE =  l_po_acc_type_code; */

   -- Get the supplier user name
   WF_DIRECTORY.GetUserName(  'FND_USR',
                           l_user_id,
                           l_supp_username,
                           l_supplier_displayname);
  -- Get the Vendor Name
  if    l_po_release_id is null then
        select pov.vendor_name
        into x_vendor
        from po_vendors pov,po_headers_all poh
        where pov.vendor_id = poh.vendor_id
        and poh.po_header_id=l_po_header_id;
  else
        select pov.vendor_name
        into x_vendor
        from po_releases_all por,po_headers_all poh,po_vendors pov
        where por.po_release_id = l_po_release_id
        and por.po_header_id    = poh.po_header_id
        and poh.vendor_id       = pov.vendor_id;
  end if;
  l_progress := '2';
  if l_po_accept_reject = 'Y' then
     select fnd_message.get_string('POS','POS_PO_ACCEPTED')
     into l_accp_res from dual;
  else
    select fnd_message.get_string('POS','POS_PO_REJECTED')
    into l_accp_res from dual;
  end if;

  if l_nid is not null then
    l_progress := '3';

  /*Bug 6772960 - Start
  Locking the Notification id to allow only one user to update when more than
  one supplier user tries to acknowledge the PO.*/
  IF (l_last_update_date <> fnd_api.G_NULL_DATE) THEN
    BEGIN
     OPEN NID_CSR(l_nid);
     FETCH NID_CSR INTO nidRec;
     if (NID_CSR%NOTFOUND) then
	CLOSE NID_CSR;
     end if;
     CLOSE NID_CSR;
     EXCEPTION
      WHEN OTHERS THEN
        if (sqlcode = '-54') THEN
          x_error := 'true';
          return;
        end if;
     END;
  END IF;
  --Bug 6772960 - End

   --dbms_output.put_line('Notification found from core PO');
    if l_po_accept_reject = 'Y' then
       l_action := 'ACCEPT';
    else
       l_action := 'REJECT';

    end if;


    -- Set the attributes for the acceptance message to buyer
    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_po_item_type,
                            ItemKey     => l_po_item_key,
                            aname       => 'ACCEPTANCE_TYPE',
                            avalue      => l_accp_type
                            );

    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_po_item_type,
                            ItemKey     => l_po_item_key,
                            aname       => 'ACCEPTANCE_LOOKUP_CODE',
                            avalue      => l_po_acc_type_code
                            );

    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_po_item_type,
                            ItemKey     => l_po_item_key,
                            aname       => 'ACCEPTANCE_RESULT',
                            avalue      => l_accp_res
                            );


    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_po_item_type,
                            ItemKey     => l_po_item_key,
                            aname       => 'ACCEPTANCE_COMMENTS',
                            avalue      => l_po_ack_comments
                            );

    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_po_item_type,
                            ItemKey     => l_po_item_key,
                            aname       => 'SUPPLIER',
                            avalue      => x_vendor
                            );

    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_po_item_type,
                            ItemKey     => l_po_item_key,
                            aname       => 'SUPPLIER_USER_NAME',
                            avalue      => l_supp_username
                            );

     l_progress := '3-0';
     /*
        We will not reinitialize apps here.  This may make the next activity after the
        notification be deferred briefly.  But, this helps in keeping the responder name
        same as the l_supplier_name.  See bug 3900146 for details.

      */
     l_progress := '3-1';
        WF_NOTIFICATION.SetAttrText(nid =>l_nid ,
                          aname => 'RESULT',
                          avalue => l_action);

    l_progress := '3-2';
    WF_NOTIFICATION.Respond(nid =>l_nid ,
                respond_comment =>null,
                responder =>l_supp_username
                --action_source   in varchar2 default null
           );

  else

   --Bug 6772960 - Start
   /*
      l_last_update_date contains the last update date which is currently seen by supplier user.
      l_last_upd_date contains the last update date which is currently there is database.
      If there is any mismatch in the above dates that means the PO data whatever supplier user
      seeing currently is not the latest.
   */
   -- Lock the PO Header Row for update of Last Update Date
   IF (l_last_update_date <> fnd_api.G_NULL_DATE) THEN
     if (l_po_release_id is not null ) then
       BEGIN
        OPEN REL_CSR(l_po_release_id);
        FETCH REL_CSR INTO relRec;
        l_last_upd_date := relRec.last_update_date;
        if (REL_CSR%NOTFOUND) then
          CLOSE REL_CSR;
        end if;
        CLOSE REL_CSR;
       EXCEPTION
        WHEN OTHERS THEN
          if (sqlcode = '-54') THEN
            x_error := 'true';
            return;
          end if;
       END;
     else
      BEGIN
        OPEN PO_CSR(l_po_header_id);
        FETCH PO_CSR INTO poRec;
        l_last_upd_date := poRec.last_update_date;
        if (PO_CSR%NOTFOUND) then
         CLOSE PO_CSR;
        end if;
        CLOSE PO_CSR;
       EXCEPTION
         WHEN OTHERS THEN
         if (sqlcode = '-54') then
            x_error := 'true';
            return;
          end if;
       END;
     end if;

     -- Check if the same record is being update
     -- Check against last_updated_date to make sure that
     -- The record that was queried is being updated

     if (l_last_update_date <> l_last_upd_date) THEN
       x_error := 'true';
       return;
     end if;
   END IF;
   --Bug 6772960 - End

   --dbms_output.put_line('No Notification found ');
   l_progress := '4';
   select po_acceptances_s.nextval into l_acceptance_id from dual;

	if l_po_release_id is null then
           l_doc := l_po_header_id;
           x_po_header_id := l_po_header_id;

	   select revision_num ,nvl(pending_signature_flag,'N'),type_lookup_code
           into l_revision_num,l_pending_signature_flag,l_doc_subtype
	   from po_headers_all
	   where po_header_id = to_number(l_po_header_id);

           if (l_doc_subtype in ('STANDARD','PLANNED')) then
            l_doc_type    := 'PO';
           elsif (l_doc_subtype in ('BLANKET','CONTRACT')) then
            l_doc_type    := 'PA';
           end if;
	else
           l_doc := l_po_release_id;
           l_doc_type := 'RELEASE';
	   x_po_header_id := null;
	   l_doc_subtype := 'RELEASE';

	   select revision_num into l_revision_num
	   from po_releases_all
	   where po_release_id = to_number(l_po_release_id);
	end if;
         l_progress := '5';
         l_role := null;
         select pos_party_management_pkg.get_job_title_for_user( l_user_id)
         into l_role
         from dual;

         l_progress := '6';
   /*BINDING IMPACT */
    if (l_pending_signature_flag = 'Y') then
	l_signature_flag := 'Y';
        l_accepting_party := 'S' ;
    else
    -- For Regular Acceptances Signature_Flag = 'N' and Accepting_Party='S'
	l_signature_flag := 'N';
        l_accepting_party := 'S' ;
    end if;

    l_progress := '7';
  -- RDP

  /*	Bug No: 6670166
	Modified the if condition to replace the Promise Date with Need By Date only if POS_DEFAULT_PROMISE_DATE_ACK profile is set to 'Y'.
	Old behaviour used to replace the Promise Date with Need By Date irrespective of the POS_DEFAULT_PROMISE_DATE_ACK profile value. */

      IF(l_po_accept_reject = 'Y' AND g_default_promise_date = 'Y') THEN
	POS_ACK_PO.Acknowledge_promise_date (null,l_po_header_id,l_po_release_id,l_revision_num,l_user_id); -- RDP
      END IF;

    PO_ACCEPTANCES_INS_PVT.insert_row(
                        x_rowid                 =>  x_row_id,
			x_acceptance_id		=>  l_acceptance_id,
                        x_Last_Update_Date      =>  x_Last_Update_Date,
                        x_Last_Updated_By       =>  x_Last_Updated_By,
                        x_Last_Update_Login     =>  l_Last_Update_Login,
			p_creation_date		=>  x_Creation_Date,
			p_created_by		=>  x_Created_by,
			p_po_header_id		=>  x_po_header_id,
			p_po_release_id		=>  l_po_release_id,
			p_action		=>  fnd_message.get_string('ICX','ICX_POS_ACK_WEB'),
			p_action_date		=>  x_Action_Date,
			p_employee_id		=>  null,
			p_revision_num		=>  l_revision_num,
			p_accepted_flag		=>  l_po_accept_reject,
			p_acceptance_lookup_code=>  l_po_acc_type_code,
			p_note			=>  l_po_ack_comments,
                        p_accepting_party       =>  l_accepting_party,
                        p_signature_flag        =>  l_signature_flag,
                        p_role                  =>  l_role);

     l_progress := '8';
   /* Use PO API As Above */
   /* Bug 2807782, set employee_id to NULL. */
/*   insert into po_acceptances (
        acceptance_id,
        last_update_Date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        po_header_id,
        po_release_id,
        action,
        action_date,
        --employee_id,
        revision_num,
        accepted_flag,
        acceptance_lookup_code,
        note
   )
   values (
        l_acceptance_id,
        sysdate,
        l_user_id,
        l_user_id,
        sysdate,
        l_user_id,
        decode(l_po_release_id, null, l_po_header_id, null),
        l_po_release_id,
        fnd_message.get_string('ICX','ICX_POS_ACK_WEB'),
        sysdate,
        --l_po_buyer_id,
        l_revision_num,
        l_po_accept_reject,
        l_po_acc_type_code,
        l_po_ack_comments
   );
*/
      If (l_po_accept_reject = 'N' and l_pending_signature_flag = 'Y') then
         PO_SIGNATURE_PVT.Update_Po_Details(
                        p_po_header_id        => l_doc,
                        p_status              => 'REJECTED',
                        p_action_code         => 'SUPPLIER REJECTED',
                        p_object_type_code    => l_doc_type,
                        p_object_subtype_code => l_doc_subtype,
                        p_employee_id         => null,
                        p_revision_num        => l_revision_num);
     END IF;

     l_progress := '9';

   -- Reset the Acceptance required Flag
   --Bug 6772960 - Start
   -- Update the last update date when po_headers_all table is updated.

   if l_po_release_id is not null then
      update po_releases_all
      set acceptance_required_flag = 'N',
          LAST_UPDATE_DATE = SYSDATE,
          acceptance_due_date=''
      where po_release_id = l_po_release_id;
   else
     -- Do not reset the acceptance_required Flag for signatures
     if (l_pending_signature_flag = 'N') then
      update po_headers_all
      set acceptance_required_flag = 'N',
          LAST_UPDATE_DATE = SYSDATE,
          acceptance_due_date=''
      where po_header_id = l_po_header_id;
     end if;
   end if;
   --Bug 6772960 - End
   l_progress := '10';

   --dbms_output.put_line('Calling Workflow');
   -- call workflow to send the notification
   select po_wf_itemkey_s.nextval into l_seq_val from dual;

   l_item_key := 'POSACKNT_' || l_doc || '_' || to_char(l_seq_val);

   --dbms_output.put_line('Item Key is ' ||l_item_key);
   wf_engine.createProcess(ItemType    => l_item_type,
                           ItemKey     => l_item_key,
                           Process     => 'MAIN_PROCESS'
                           );

    PO_WF_UTIL_PKG.SetItemAttrNumber
                            (
                            ItemType    => l_item_type,
                            ItemKey     => l_item_key,
                            aname       => 'DOCUMENT_ID',
                            avalue      => l_doc
                            );
    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_item_type,
                            ItemKey     => l_item_key,
                            aname       => 'DOCUMENT_TYPE_CODE',
                            avalue      => l_doc_type
                            );

    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_item_type,
                            ItemKey     => l_item_key,
                            aname       => 'SUPPLIER_USER_NAME',
                            avalue      => l_supp_username
                            );

    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_item_type,
                            ItemKey     => l_item_key,
                            aname       => 'ACCEPTANCE_RESULT',
                            avalue      => l_accp_res
                            );

    PO_WF_UTIL_PKG.SetItemAttrText (
                             ItemType    => l_item_type,
                             ItemKey     => l_item_key,
                             aname       => 'ACCEPTANCE_TYPE',
                             avalue      => l_accp_type);

    PO_WF_UTIL_PKG.SetItemAttrText (
                             ItemType    => l_item_type,
                             ItemKey     => l_item_key,
                             aname       => 'ACCEPTANCE_COMMENTS',
                             avalue      =>  l_po_ack_comments);

    PO_WF_UTIL_PKG.SetItemAttrText
                            (
                            ItemType    => l_item_type,
                            ItemKey     => l_item_key,
                            aname       => 'SUPPLIER',
                            avalue      => x_vendor
                            );

  l_progress := '11';
  wf_engine.StartProcess( ItemType => l_item_type,
                           ItemKey  => l_item_key );
  l_progress := '12';
  end if;

EXCEPTION
   WHEN OTHERS THEN
       l_error := sqlerrm;
       IF g_fnd_debug = 'Y' THEN

       	  IF ( FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
       	    FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
       				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
       	  END IF;

       	END IF;

       raise;

END ACKNOWLEDGE_PO;

PROCEDURE CREATE_HEADER_PROCESS(
    pos_po_header_id        IN  VARCHAR2,
    pos_po_release_id       IN  VARCHAR2,
    pos_user_id             IN  NUMBER,
    pos_item_type           OUT NOCOPY VARCHAR2,
    pos_item_key            OUT NOCOPY VARCHAR2
    )
IS
   l_item_type        VARCHAR2(100)   := 'POSMPDPT';
   l_item_key         VARCHAR2(100);
   l_doc              VARCHAR2(240);
   l_user_id          NUMBER;
   l_seq_val          NUMBER;
   l_error            VARCHAR2(240);
BEGIN


   if pos_po_release_id is null then
      l_doc := pos_po_header_id;
   else
      l_doc := pos_po_release_id;
   end if;

   select po_wf_itemkey_s.nextval into l_seq_val
   from dual;

   l_item_key := 'POS_PODATE_CHG_' || l_doc || '_' || to_char(l_seq_val);
   pos_item_type := l_item_type;
   pos_item_key  := l_item_key;
   wf_engine.createProcess(ItemType    => l_item_type,
                           ItemKey     => l_item_key,
                           Process     => 'MAIN_PROCESS'
                           );
    PO_WF_UTIL_PKG.SetItemAttrNumber
                            (
                            ItemType    => l_item_type,
                            ItemKey     => l_item_key,
                            aname       => 'SUPPLIER_USER_ID',
                            avalue      => pos_user_id
                            );
    PO_WF_UTIL_PKG.SetItemAttrNumber
                            (
                            ItemType    => l_item_type,
                            ItemKey     => l_item_key,
                            aname       => 'DOCUMENT_ID',
                            avalue      => to_number(l_doc)
                            );

   if pos_po_release_id is null then
   	update po_headers_all
   	set authorization_status = 'IN PROCESS'
   	where po_header_id = to_number(pos_po_header_id);
   else
   	update po_releases_all
   	set authorization_status = 'IN PROCESS'
   	where po_release_id = to_number(pos_po_release_id);
   end if;



EXCEPTION
   WHEN OTHERS THEN
       l_error := sqlerrm;

END CREATE_HEADER_PROCESS;

PROCEDURE START_HEADER_PROCESS(
          l_item_type        IN  VARCHAR2,
          l_item_key         IN  VARCHAR2
	)
IS
   l_error    VARCHAR2(240);
BEGIN
   wf_engine.StartProcess( ItemType => l_item_type,
                           ItemKey  => l_item_key );
EXCEPTION
   WHEN OTHERS THEN
       l_error := sqlerrm;
END START_HEADER_PROCESS;


PROCEDURE ADD_SHIPMENT(
          l_item_type               IN  VARCHAR2,
          l_item_key                IN  VARCHAR2,
          l_line_location_id        IN  VARCHAR2,
          l_new_promise_date        IN  VARCHAR2,
          l_old_promise_date        IN  VARCHAR2,
          l_new_need_by_date        IN  VARCHAR2,
          l_old_need_by_date        IN  VARCHAR2,
          l_reason                  IN  VARCHAR2
	)
IS
--   l_error    VARCHAR2(240);
BEGIN

     --  Add Shipment Atrributes
    -- Commenting out the call as POS_CHANGE_PROM_DATES has been stubbed out

/*       POS_CHANGE_PROM_DATES.Add_Shipment_Attribute
           (
               l_item_type,
               l_item_key,
               l_line_location_id,
               to_date(l_old_promise_date,'YYYY-MM-DD'),
               to_date(l_new_promise_date,'YYYY-MM-DD'),
               to_date(l_old_need_by_date,'YYYY-MM-DD'),
               to_date(l_new_need_by_date,'YYYY-MM-DD'),
	       l_reason
           );  */

null;
EXCEPTION
   WHEN OTHERS THEN
   --  l_error := sqlerrm;
    null;
END ADD_SHIPMENT;

                                              --RDP new procedure defaults the promise_date with need_by_date while acknowledging
PROCEDURE Acknowledge_promise_date (
        p_line_location_id	IN	NUMBER,
  	p_po_header_id		IN	NUMBER,
  	p_po_release_id		IN	NUMBER,
  	p_revision_num		IN	NUMBER,
  	p_user_id		IN	NUMBER)

IS
BEGIN

--write_log('JUGGU',TO_CHAR(p_revision_num),'SU',sysdate);
IF p_po_release_id is null THEN

     IF p_line_location_id is not null THEN

         UPDATE PO_LINE_LOCATIONS_ALL PLL
         SET   pll.promised_date = pll.need_by_date,
               pll.last_update_date = sysdate,
               pll.last_updated_by = p_user_id
         WHERE pll.po_header_id= p_po_header_id
         AND   pll.po_release_id is null
         AND   pll.line_location_id= p_line_location_id
         AND   pll.promised_date is null;

         UPDATE PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA
         SET    plla.promised_date = plla.need_by_date,
                plla.last_update_date = sysdate,
                plla.last_updated_by = p_user_id
         WHERE  plla.po_header_id = p_po_header_id
         AND    plla.po_release_id is null
         AND    plla.line_location_id = p_line_location_id
         AND    plla.promised_date is null
         AND    plla.revision_num = (SELECT max(plla2.revision_num)
                                     FROM   po_line_locations_archive_all plla2
                                     WHERE  plla2.line_location_id = plla.line_location_id
                                     AND    plla.revision_num <= p_revision_num);
    ELSE

        UPDATE PO_LINE_LOCATIONS_ALL PLL
        SET    pll.promised_date = pll.need_by_date,
               pll.last_update_date = sysdate,
               pll.last_updated_by = p_user_id
        WHERE  pll.po_header_id = p_po_header_id
               AND pll.promised_date is null
           /*    AND  exists (
                                SELECT 1
      	      	                FROM   PO_ACCEPTANCES PA
             	                WHERE  pa.po_header_id = p_po_header_id
          	                       AND    pa.revision_num = p_revision_num
          	                       AND    pa.po_line_location_id = pll.line_location_id ) */
               AND    nvl(pll.cancel_flag, 'N') = 'N'
               AND    ((nvl(pll.closed_code, 'OPEN') = 'OPEN' and
                       nvl(pll.consigned_flag, 'N') = 'N')  OR
                       (pll.closed_code = 'CLOSED FOR INVOICE' and  pll.consigned_flag = 'Y'));

        UPDATE PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA
        SET    plla.promised_date = plla.need_by_date,
               plla.last_update_date = sysdate,
               plla.last_updated_by = p_user_id
        WHERE  plla.po_header_id = p_po_header_id
               AND plla.promised_date is null
               AND plla.revision_num = (SELECT max(plla2.revision_num)
                                        FROM   po_line_locations_archive_all plla2
                                        WHERE  plla2.line_location_id = plla.line_location_id
                                        AND    plla.revision_num <= p_revision_num)
              /* AND  exists (
                                SELECT 1
                                FROM   PO_ACCEPTANCES PA
                                WHERE  pa.po_header_id = p_po_header_id
                                       AND    pa.revision_num = p_revision_num
                                       AND    pa.po_line_location_id = plla.line_location_id ) */
               AND    nvl(plla.cancel_flag, 'N') = 'N'
               AND    ((nvl(plla.closed_code, 'OPEN') = 'OPEN' and
                      nvl(plla.consigned_flag, 'N') = 'N')  OR
                      (plla.closed_code = 'CLOSED FOR INVOICE' and  plla.consigned_flag = 'Y'));

     END IF;

 ELSE


    IF p_line_location_id is not null THEN

        UPDATE po_line_locations_all pll
        SET pll.promised_date =need_by_date,
            pll.last_update_date = sysdate,
            pll.last_updated_by = p_user_id
        WHERE pll.po_header_id= p_po_header_id
              AND pll.line_location_id= p_line_location_id
              AND pll.po_release_id = p_po_release_id
              AND pll. promised_date is null;

        UPDATE po_line_locations_archive_all plla
        SET plla.promised_date = plla.need_by_date,
            plla.last_update_date = sysdate,
            plla.last_updated_by = p_user_id
        WHERE plla.po_header_id= p_po_header_id
              AND plla.line_location_id= p_line_location_id
              AND plla.po_release_id = p_po_release_id
              AND plla. promised_date is null
              AND plla.revision_num = (SELECT max(plla2.revision_num)
                                       FROM   po_line_locations_archive_all plla2
                                       WHERE  plla2.line_location_id = plla.line_location_id
                                       AND    plla.revision_num <= p_revision_num);

    ELSE

        UPDATE PO_LINE_LOCATIONS_ALL PLL
        SET pll.promised_date =need_by_date,
            pll.last_update_date = sysdate,
            pll.last_updated_by = p_user_id
        WHERE  pll.po_header_id = p_po_header_id
               AND pll.po_release_id = p_po_release_id
               AND pll.promised_date is null
             /*  AND  exists (
                             SELECT 1
      	      	             FROM   PO_ACCEPTANCES PA
             	             WHERE  pa.po_release_id = p_po_release_id
                                    AND pa.po_header_id = p_po_header_id
          	                    AND pa.revision_num = p_revision_num
          	                    AND pa.po_line_location_id = PLL.line_location_id ) */
             AND nvl(pll.cancel_flag, 'N') = 'N'
             AND ((nvl(pll.closed_code, 'OPEN') = 'OPEN' AND (nvl(pll.consigned_flag, 'N') = 'N')) OR (pll.closed_code = 'CLOSED FOR INVOICE' AND pll.consigned_flag = 'Y'));

      UPDATE PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA
        SET plla.promised_date =need_by_date,
            plla.last_update_date = sysdate,
            plla.last_updated_by = p_user_id
        WHERE  plla.po_header_id = p_po_header_id
               AND plla.po_release_id = p_po_release_id
               AND plla.promised_date is null
               AND plla.revision_num = (SELECT max(plla2.revision_num)
                                       FROM   po_line_locations_archive_all plla2
                                       WHERE  plla2.line_location_id = plla.line_location_id
                                       AND    plla.revision_num <= p_revision_num)
             /*  AND  exists (
                            SELECT 1
                             FROM   PO_ACCEPTANCES PA
                             WHERE  pa.po_release_id = p_po_release_id
                                    AND pa.po_header_id = p_po_header_id
                                    AND pa.revision_num = p_revision_num
                                    AND pa.po_line_location_id = PLLA.line_location_id ) */
                                    AND nvl(plla.cancel_flag, 'N') = 'N'
                                    AND ((nvl(plla.closed_code, 'OPEN') = 'OPEN' AND (nvl(plla.consigned_flag, 'N') = 'N')) OR (plla.closed_code = 'CLOSED FOR INVOICE' AND plla.consigned_flag = 'Y'));

     END IF;



 END IF;


END Acknowledge_promise_date;


END POS_ACK_PO;

/
