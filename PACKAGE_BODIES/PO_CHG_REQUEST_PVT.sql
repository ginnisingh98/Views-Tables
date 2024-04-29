--------------------------------------------------------
--  DDL for Package Body PO_CHG_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHG_REQUEST_PVT" AS
/* $Header: POXPCHGB.pls 120.28.12010000.18 2014/04/22 09:24:06 pneralla ship $ */

 g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- The module base for the subprogram.
D_ifLineChangable CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(g_module_prefix,'ifLineChangable');

/**
 * Private Function: getAckNotifId
 * Requires: PO_HEADER_ID , PO_RELEASE_ID
 * Modifies: None
 * Effects: Checks if there is an open Notification for Acknowledgement
 * from Core PO for the Supplier
 * Returns:
 *   Notification Id
 */

 function getAckNotifId (
 p_po_header_id  	in number,
 p_po_release_id 	in number,
 x_activity_name         out nocopy varchar2) RETURN NUMBER IS

 v_nid               NUMBER;
 l_po_item_type      PO_HEADERS_ALL.WF_ITEM_TYPE%TYPE;
 l_po_item_key       PO_HEADERS_ALL.WF_ITEM_KEY%TYPE;
 l_message_name      varchar2(100);


 BEGIN
   if p_po_release_id is null then
  	begin
   	select a.notification_id,poh.wf_item_type,poh.wf_item_key, a.message_name
   	INTO   v_nid,l_po_item_type,l_po_item_key, l_message_name
   	from   wf_notifications a, po_headers_all poh,
           wf_item_activity_statuses wa
   	where  poh.po_header_id  = p_po_header_id and
	       poh.wf_item_key   = wa.item_key and
   	       poh.wf_item_type  = wa.item_type
   	       and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
               and   a.status = 'OPEN'
               and   a.notification_id = wa.notification_id
               and  wa.activity_status = 'NOTIFIED';
  	exception
   		when no_data_found then v_nid := null;
  	end;
   else
  	begin
   	    select a.notification_id,por.wf_item_type,por.wf_item_key, a.message_name
   	    INTO  v_nid,l_po_item_type,l_po_item_key, l_message_name
   	    from  wf_notifications a, po_releases_all por,
                  wf_item_activity_statuses wa
   	    where por.po_release_id   = p_po_release_id and
   	          por.wf_item_key     = wa.item_key and
	          por.wf_item_type    = wa.item_type
   	          and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
                  and   a.status = 'OPEN'
		  and   a.notification_id = wa.notification_id
                  and  wa.activity_status = 'NOTIFIED';
  	exception
   		when no_data_found then v_nid := null;
   		x_activity_name := null;
  	end;
   end if;
  	if (l_message_name = 'PO_EMAIL_PO_WITH_RESPONSE') then
  	     x_activity_name := 'NOTIFY_WEB_SUPPLIER_RESP';
  	elsif (l_message_name = 'PO_EMAIL_PO_PDF_WITH_RESPONSE') then
  	    x_activity_name := 'NOTIFY_WEB_SUPP_PDF';
  	end if;

 return v_nid;
 END;

 /**
 * Private Function: getSigNotifId
 * Requires: P_ITEM_KEY
 * Modifies: None
 * Effects: Checks if there is an open Notification for Signature for
 * the Supplier
 * Returns:
 *   Notification Id
 */

 function getSigNotifId (
 p_item_type    in VARCHAR2,
 p_item_key  	in VARCHAR2
 ) RETURN NUMBER IS

 v_nid               NUMBER;

 BEGIN
  	begin
    	select a.notification_id
    	INTO   v_nid
    	from   wf_notifications a, wf_item_activity_statuses wa
   	    where  wa.item_key       =  p_item_key and
   	           wa.item_type      =  p_item_type  and
   	           a.message_name    = 'PO_SUPPLIER_SIGNATURE' and
               a.status		     = 'OPEN' and
   	           a.notification_id = wa.notification_id;

  	exception
   		when no_data_found then v_nid := null;
  	end;
  return v_nid;
 END;


/**
 * Private Function: getRequestGroupId
 * Requires: PO_HEADER_ID , PO_RELEASE_ID , Document_Type
 * Modifies: None
 * Effects: Gets the Request Group Id for Supplier Change Requests
 * Returns:
 *   RequestGroupId
 */

 function getRequestGroupId (
 p_po_header_id  	in number,
 p_po_release_id 	in number,
 p_document_type  	in varchar2) RETURN NUMBER IS

 v_req_grp_id number;

 cursor c1(p_po_header_id in number,p_document_type in varchar2) is
        select change_request_group_id
        from  po_change_requests
        where document_header_id = p_po_header_id and
              request_status     in ('NEW', 'PENDING') and
              request_level in ('HEADER', 'LINE', 'SHIPMENT') and
              document_type     = p_document_type;

 cursor c2(p_po_release_id in number, p_document_type in varchar2) is
        select change_request_group_id
        from  po_change_requests
        where po_release_id     = p_po_release_id and
              request_status     in ('NEW', 'PENDING') and
              request_level in ('HEADER', 'LINE', 'SHIPMENT') and
              document_type     = p_document_type;

 BEGIN

  if p_po_release_id is null then
    begin
        open c1(p_po_header_id,p_document_type);
        fetch c1 into  v_req_grp_id;
        close c1;
    exception
    	when others then
    	v_req_grp_id := null;
    end;
   else
    begin
        open c2(p_po_release_id,p_document_type);
        fetch c2 into  v_req_grp_id;
        close c2;
    exception
    	when others then
    	v_req_grp_id := null;
    end;
   end if;
  /*  if v_req_grp_id is null then
    	select po_chg_request_seq.nextval
    	into   v_req_grp_id
    	from dual;
    end if;  */
   return v_req_grp_id;
 END;

/**
 * Private Function: startSupplierWF
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM,CHANGE_REQUEST_GROUP_ID,
             ACCEPTANCE_REQUIRED_FLAG
 * Modifies:
 * Effects:  This procedure checks whether PO Requires Acceptance notifications
             are active and close those notifications with proper result. This
             procedure also initiates the PO Change Order workflow process to send
             the notification to the buyer about the supplier acknowledgement.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *
 */

 function startSupplierWF
 (p_po_header_id       IN  number,
  p_po_release_id      IN  number,
  p_revision_num       IN  number,
  p_chg_request_grp_id IN  number,
  p_ack_reqd	       IN  varchar2
  ) RETURN VARCHAR2 IS

   startWf             varchar2(10);
   ifAckReqd           PO_HEADERS_ALL.acceptance_required_flag%TYPE;
   l_nid               NUMBER;
   l_po_item_type      PO_HEADERS_ALL.WF_ITEM_TYPE%TYPE;
   l_po_item_key       PO_HEADERS_ALL.WF_ITEM_KEY%TYPE;
   l_api_name          CONSTANT VARCHAR2(30) := 'startSupplierWF';
   x_return_status     VARCHAR2(10);
   l_activity_name     VARCHAR2(100);
   l_document_type     varchar2(10);
   l_chg_request_grp_id  number;

   /* Start changes for 7172390 */
   -- Added l_accepted_flag variable to get the accepted flag of the document.
   -- Added Notif_Ack_Status variable to get the status of the document.
   l_accepted_flag    VARCHAR2(20);
   Notif_Ack_Status  VARCHAR2(100);
   /* End changes for 7172390 */

 BEGIN
    -- Assume worflow needs to be started for every change request
    startWf := FND_API.G_TRUE;
    -- initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Also update approved flag on the po_line_locations to restrict receiving
    -- call workflow if this is the final action

    if p_po_release_id is null then
      select wf_item_key,wf_item_type
      into   l_po_item_key,l_po_item_type
      from   po_headers_all
      where  po_header_id = p_po_header_id;
    else
      select wf_item_key,wf_item_type
      into   l_po_item_key,l_po_item_type
      from   po_releases_all
      where  po_release_id = p_po_release_id;
    end if;

    if(p_ack_reqd = 'Y') then
      --Retrieve the Acknowledgement Notification sent thru core po
      l_nid := getAckNotifId(p_po_header_id,p_po_release_id, l_activity_name);
      -- Close the notification sent thru core po
      startWf := po_acknowledge_po_grp.all_shipments_responded (
        1.0,FND_API.G_FALSE,p_po_header_id , p_po_release_id, p_revision_num );
      if l_nid is not null then
        begin
        /* Start changes for 7172390 */
        if(startWf = FND_API.G_TRUE) THEN
          BEGIN
            /* l_accepted_flag and Notif_Ack_Status will have the following values respectively.
               'Y' for Accepted staus.
               'N' for Rejected status.
               'A' for Acknowledged staus.
               None of the above then Supplier Change Pending status.
            */
            if p_po_release_id is null then
              SELECT ACCEPTED_FLAG
              INTO   l_accepted_flag
              FROM   po_acceptances
              WHERE  po_header_id = p_po_header_id
              AND    REVISION_NUM = p_revision_num
              AND    PO_LINE_LOCATION_ID IS NULL
              AND    ACCEPTING_PARTY='S';
            ELSE
              SELECT ACCEPTED_FLAG
              INTO   l_accepted_flag
              FROM   po_acceptances
              WHERE  po_release_id = p_po_release_id
              AND    REVISION_NUM = p_revision_num
              AND    PO_LINE_LOCATION_ID IS NULL
              AND    ACCEPTING_PARTY='S';
            END IF;
          EXCEPTION
            WHEN No_Data_Found THEN
              Notif_Ack_Status := FND_MESSAGE.GET_STRING('POS','POS_PO_SUP_CHANGE');
          END;
          IF l_accepted_flag = 'Y' THEN
            Notif_Ack_Status := FND_MESSAGE.GET_STRING('POS','POS_ACCEPTED');
          elsif l_accepted_flag = 'N' THEN
            Notif_Ack_Status := FND_MESSAGE.GET_STRING('POS','POS_REJECTED');
          elsif l_accepted_flag = 'A' THEN
            Notif_Ack_Status := FND_MESSAGE.GET_STRING('POS','POS_PO_ACKNOWLEDGED');
          ELSE
            Notif_Ack_Status := FND_MESSAGE.GET_STRING('POS','POS_PO_SUP_CHANGE');
          END IF;
        ELSE
          Notif_Ack_Status := FND_MESSAGE.GET_STRING('POS','POS_PO_PARTIALLY_ACKED');
        END IF;
        wf_engine.completeActivity(l_po_item_type,
                                   l_po_item_key,
                                   l_activity_name,
                                   --'NOTIFY_WEB_SUPPLIER_RESP',
                                   Notif_Ack_Status);
        /* End changes for 7172390 */
        exception
          when others then
            raise;
        end;
  	  end if;
    else
	    startWf := FND_API.G_TRUE;
    end if;

    -- Call workflow
	  if(startWf = FND_API.G_TRUE) then
      /* Handle the change request group id for cases when supplier completes the acknowledgement after
         asking for a change initially bug 4872348 */
      if(p_chg_request_grp_id is null) then
        if (p_po_release_id is not null) then
          l_document_type := 'RELEASE';
        else
          l_document_type := 'PO';
        end if;

        l_chg_request_grp_id  := getRequestGroupId (p_po_header_id => p_po_header_id,
                                 p_po_release_id => p_po_release_id,
                                 p_document_type  => l_document_type );
      else
        l_chg_request_grp_id  := p_chg_request_grp_id;
      end if;                                     -- end of fix

	    po_sup_chg_request_wf_grp.StartSupplierChangeWF(
	    1.0,x_return_status,p_po_header_id ,p_po_release_id,
      p_revision_num, l_chg_request_grp_id ,p_ack_reqd);
	  end if;

    return x_return_status;

  exception
     WHEN OTHERS THEN
         raise;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
             IF g_fnd_debug = 'Y' THEN
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
               FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                             l_api_name || '.others_exception', sqlcode);
             END IF;
             END IF;
         END IF;
         return x_return_status;
  end startSupplierWF;

  /**
 * Private Function: startSignatureWF
 * Requires: PO_HEADER_ID , PO_RELEASE_ID ,
 * Modifies: None
 * Effects: Initiates the supplier Signature workflow
 * Returns:
 *  x_return_status
 */

 function startSignatureWF (
         p_item_type              IN VARCHAR2,
         p_item_key               IN VARCHAR2,
  	 p_po_header_id  	  IN NUMBER,
  	 p_revision_num  	  IN NUMBER,
         p_document_type          IN VARCHAR2,
         p_document_subtype       IN VARCHAR2,
         p_document_number        IN VARCHAR2,
         p_org_id                 IN NUMBER,
         p_Agent_Id               IN NUMBER,
         p_supplier_user_id       IN NUMBER
  ) RETURN VARCHAR2 IS

   l_nid                  NUMBER;
   l_api_name             CONSTANT VARCHAR2(30) := 'startSignatureWF';
   x_return_status        VARCHAR2(10);
   l_supplier_username    fnd_user.user_name%type;
   n_varname              Wf_Engine.NameTabTyp;
   n_varval               Wf_Engine.NumTabTyp;
   t_varname              Wf_Engine.NameTabTyp;
   t_varval               Wf_Engine.TextTabTyp;
   l_supplier_displayname VARCHAR2(240);

 BEGIN
    -- initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   if (p_item_key is null ) then
       x_return_status := FND_API.g_ret_sts_unexp_error;
       return x_return_status;
   else

      wf_engine.createProcess (	ItemType => p_item_type,
				ItemKey =>  p_item_key,
				Process => 'DOCUMENT_SIGNATURE_PROCESS');

      -- Get Supplier User Name

       WF_DIRECTORY.GetUserName(  'FND_USR',
                                   p_supplier_user_id,
                                   l_supplier_username,
                                   l_supplier_displayname);

        -- Set Workflow Attributes
            n_varname(1) := 'DOCUMENT_ID';
	    n_varval(1)  := p_po_header_id;
	    n_varname(2) := 'SUPPLIER_USER_ID';
	    n_varval(2)  := p_supplier_user_id;
	    n_varname(3) := 'PO_REVISION_NUM';
	    n_varval(3)  := p_revision_num;
	    n_varname(4) := 'ORG_ID';
	    n_varval(4)  := p_org_id;
	    n_varname(5) := 'BUYER_EMPLOYEE_ID';
	    n_varval(5)  := p_agent_id;

	    t_varname(1) := 'DOCUMENT_TYPE';
	    t_varval(1)  := p_document_type;
	    t_varname(2) := 'DOCUMENT_SUBTYPE';
	    t_varval(2)  := p_document_subtype;
	    t_varname(3) := 'DOCUMENT_NUMBER';
	    t_varval(3)  := p_document_number;
	    t_varname(4) := 'SUPPLIER_USER_NAME';
	    t_varval(4)  := l_supplier_username;

	    Wf_Engine.SetItemAttrNumberArray(p_item_type, p_item_key,n_varname,n_varval);
	    Wf_Engine.SetItemAttrTextArray(p_item_type, p_item_key,t_varname,t_varval);

	    wf_engine.StartProcess(ItemType => p_item_type,
				   ItemKey => p_item_key);
        -- DO explicit commit
        commit;
   return x_return_status;
  end if;
exception
    WHEN OTHERS THEN
        raise;
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others_exception', sqlcode);
            END IF;
            END IF;
        END IF;
        return x_return_status;
 end startSignatureWF;
/**
 * Public Procedure: save_request
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: API message list
 * Effects:  Saves Data to the Change Request Table
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */

 procedure save_request(
    p_api_version            IN  NUMBER,
    p_Init_Msg_List          IN  VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    p_po_header_id  	     IN  NUMBER,
    p_po_release_id 	     IN  NUMBER,
    p_revision_num  	     IN  NUMBER,
    p_po_change_requests     IN  pos_chg_rec_tbl,
    x_request_group_id       OUT NOCOPY NUMBER,
    p_chn_int_cont_num       IN varchar2 default null,
    p_chn_source             IN varchar2 default null,
    p_chn_requestor_username in varchar2 default null,
    p_user_id                IN number default null,
    p_login_id               IN number default null) IS

    rec_cnt                 number;
    p_chg_request_grp_id    number;
    x_return_code           varchar2(40);
    v_request_group_id      number;
    accp_flag               char(1);
    v_buyer_id              number;
    v_document_type         po_change_requests.DOCUMENT_TYPE%TYPE;
    l_user_id               NUMBER :=  fnd_global.user_id;
    l_login_id              NUMBER :=  fnd_global.login_id;
    l_api_name              CONSTANT VARCHAR2(30) := 'save_request';
    l_api_version_number    CONSTANT NUMBER := 1.0;

 BEGIN
     IF fnd_api.to_boolean(P_Init_Msg_List) THEN
        -- initialize message list
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if (p_user_id is not null) then
          l_user_id := p_user_id;
          l_login_id := p_login_id;
    end if;

    rec_cnt    := p_po_change_requests.count();
    -- get the ChangerequestGroupID only when changes are requested
    IF( rec_cnt > 0) THEN
    -- Get the document type of the first record to get the unique request group id
    if (p_po_release_id is not null) then
       v_document_type := 'RELEASE';
    else
       v_document_type := 'PO';
    end if;

    v_request_group_id := getRequestGroupId(p_po_header_id,p_po_release_id,v_document_type);
    IF(v_request_group_id is null) THEN
    select po_chg_request_seq.nextval
    into   v_request_group_id
    from dual;
    END IF;
    x_request_group_id := v_request_group_id;
    END IF;

    FOR i in 1..rec_cnt LOOP
     if(p_po_change_requests(i).action_type not in ('ACCEPT','REJECT')) then

   	    insert into po_change_requests(
    	change_request_group_id, change_request_id,
    	initiator, action_type, request_reason,
        request_level, request_status, document_type,
        document_header_id, document_num,
    	document_revision_num, po_release_id,
        created_by, creation_date,last_updated_by,last_update_date,
        last_update_login,document_line_id, document_line_number,
        document_line_location_id, document_shipment_number,
        parent_line_location_id, document_distribution_id,
        document_distribution_number,
    	old_quantity, new_quantity,
        old_promised_date, new_promised_date,
    	old_supplier_part_number, new_supplier_part_number,
    	old_price, new_price, old_need_by_date, new_need_by_date,
    	old_supplier_reference_number, new_supplier_reference_number,
        Approval_Required_Flag,Parent_Change_request_Id,
        Requester_Id ,
        OLD_SUPPLIER_ORDER_NUMBER , NEW_SUPPLIER_ORDER_NUMBER,
        OLD_SUPPLIER_ORDER_LINE_NUMBER , NEW_SUPPLIER_ORDER_LINE_NUMBER,
        change_active_flag, MSG_CONT_NUM, REQUEST_ORIGIN,ADDITIONAL_CHANGES,
        OLD_START_DATE,NEW_START_DATE,OLD_EXPIRATION_DATE,NEW_EXPIRATION_DATE,
        OLD_AMOUNT,NEW_AMOUNT,
        SUPPLIER_DOC_REF, SUPPLIER_LINE_REF, SUPPLIER_SHIPMENT_REF, --added in FPJ for splits.
        NEW_PROGRESS_TYPE,NEW_PAY_DESCRIPTION  --<< Complex work changes for R12 >>

        )
    	values (x_request_group_id,po_chg_request_seq.nextval,
    	p_po_change_requests(i).initiator,
    	p_po_change_requests(i).action_type,
    	p_po_change_requests(i).request_reason,
    	p_po_change_requests(i).request_level,
    	p_po_change_requests(i).request_status,
    	p_po_change_requests(i).document_type,
    	p_po_change_requests(i).document_header_id,
    	p_po_change_requests(i).document_num,
	to_number(p_po_change_requests(i).document_revision_num),
    	p_po_change_requests(i).po_release_id,
    	l_user_id,sysdate,l_login_id,sysdate,l_login_id,
    	p_po_change_requests(i).document_line_id,
    	p_po_change_requests(i).document_line_number,
    	p_po_change_requests(i).document_line_location_id,
    	p_po_change_requests(i).document_shipment_number,
    	p_po_change_requests(i).parent_line_location_id,
    	p_po_change_requests(i).document_distribution_id,
    	p_po_change_requests(i).document_distribution_number,
    	p_po_change_requests(i).old_quantity,
    	p_po_change_requests(i).new_quantity,
    	p_po_change_requests(i).old_promised_date,
    	p_po_change_requests(i).new_promised_date,
    	p_po_change_requests(i).old_supplier_part_number,
    	p_po_change_requests(i).new_supplier_part_number,
    	p_po_change_requests(i).old_price,
    	p_po_change_requests(i).new_price,
    	p_po_change_requests(i).old_need_by_date,
    	p_po_change_requests(i).new_need_by_date,
    	p_po_change_requests(i).old_supplier_reference_number,
    	p_po_change_requests(i).new_supplier_reference_number,
        p_po_change_requests(i).Approval_Required_Flag,
        p_po_change_requests(i).Parent_Change_request_Id,
        p_po_change_requests(i).Requester_id,
        p_po_change_requests(i).Old_Supplier_Order_Number,
        p_po_change_requests(i).New_Supplier_Order_Number,
        p_po_change_requests(i).Old_Supplier_Order_Line_Number,
        p_po_change_requests(i).New_Supplier_Order_Line_Number,
        decode(p_po_change_requests(i).request_status,'ACCEPTED','N','Y'),
        p_chn_int_cont_num,
        p_chn_source,
        p_po_change_requests(i).Additional_changes,
        p_po_change_requests(i).old_start_date,
        p_po_change_requests(i).new_start_date,
        p_po_change_requests(i).old_expiration_date,
        p_po_change_requests(i).new_expiration_date,
        p_po_change_requests(i).old_amount,
        p_po_change_requests(i).new_amount,
        p_po_change_requests(i).SUPPLIER_DOC_REF,
        p_po_change_requests(i).SUPPLIER_LINE_REF,
        p_po_change_requests(i).SUPPLIER_SHIPMENT_REF,
        p_po_change_requests(i).NEW_PROGRESS_TYPE, --<< Complex work changes for R12 >>
    	p_po_change_requests(i).NEW_PAY_DESCRIPTION

        );
     end if;
    end loop;

 EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
               FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others exception' ,sqlcode);
             END IF;
	        END IF;
        END IF;

 END save_request;

/**
 * Public Procedure: process_supplier_request
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM,POS_CHG_REC_TBL
 * Modifies:
 * Effects:  Processes the change Request and calls PO Doc Submission Check
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *		       POS_ERR_TYPE
 */

 procedure process_supplier_request (
	     p_po_header_id           IN  number,
	     p_po_release_id          IN  number,
	     p_revision_num           IN  number,
	     p_po_change_requests     IN  pos_chg_rec_tbl,
	     x_online_report_id       OUT NOCOPY number,
	     x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
	     p_chn_int_cont_num       IN varchar2 default null,
             p_chn_source             IN varchar2 default null,
             p_chn_requestor_username in varchar2 default null,
             p_user_id                IN number default null,
             p_login_id               IN number default null,
             p_last_upd_date          IN date default null,
             p_mpoc                   IN varchar2 default FND_API.G_FALSE) IS

 x_error_code   	  varchar2(40);
 no_rec_found   	  exception;
 v_auth_status  	  PO_HEADERS_ALL.AUTHORIZATION_STATUS%TYPE;
 x_progress     	  varchar2(3) := '000';
 l_api_version_number     CONSTANT NUMBER := 1.0;
 l_api_name               CONSTANT VARCHAR2(30) := 'process_supplier_request';
 l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);
 l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
 l_user_id                NUMBER;
 l_login_id               NUMBER;
 l_request_group_id       NUMBER :=null;
 x_return_status          varchar2(20);
 updatePoAttr             boolean := false;
 saveRequest              boolean := false;
 callWf                   boolean := false;
 l_po_change_requests     pos_chg_rec_tbl := NULL;
 vAckTbl		  pos_ack_rec_tbl := pos_ack_rec_tbl();
 ack_cnt                  number :=0;
 callDocCheck             boolean :=false;
 accp_flag                char(1);
 v_buyer_id               number;
 x_accp_flag po_headers_all.acceptance_required_flag%type;
 l_err_msg_name_tbl     po_tbl_varchar30;
 l_err_msg_text_tbl     po_tbl_varchar2000;
 l_last_upd_date        po_headers_all.last_update_date%type;
 l_count_asn		NUMBER;
 l_ret_sts		varchar2(1);


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

 BEGIN
    -- initialize return status
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_progress := '001';


   -- Lock the PO Header Row for update of Last Update Date
   if (p_po_release_id is not null ) then
     BEGIN
           OPEN REL_CSR(p_po_release_id);
           FETCH REL_CSR INTO relRec;
           l_last_upd_date := relRec.last_update_date;
           if (REL_CSR%NOTFOUND) then
             CLOSE REL_CSR;
             IF (g_fnd_debug = 'Y') THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
                FND_LOG.string(FND_LOG.level_error, g_module_prefix || 'process_supplier_request ', ' Record dosent exist for po_release_id = ' || p_po_release_id);
              END IF;
             END IF;
           end if;
           CLOSE REL_CSR;
     EXCEPTION
      WHEN OTHERS THEN
        if (sqlcode = '-54') then
          l_err_msg_name_tbl := po_tbl_varchar30();
          l_err_msg_text_tbl := po_tbl_varchar2000();
          x_pos_errors  := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);
          x_pos_errors.message_name.extend;
          x_pos_errors.text_line.extend;
          x_pos_errors.message_name(1) := null;
          x_pos_errors.text_line(1) :=  fnd_message.get_string('POS', 'POS_LOCKED_PO_ROW');
          return;
        end if;
     END;
   else
    BEGIN
          OPEN PO_CSR(p_po_header_id);
          FETCH PO_CSR INTO poRec;
          l_last_upd_date := poRec.last_update_date;
          if (PO_CSR%NOTFOUND) then
           CLOSE PO_CSR;
           IF (g_fnd_debug = 'Y') THEN
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
               FND_LOG.string(FND_LOG.level_error, g_module_prefix || 'process_supplier_request', 'Record dosent exist for po_header_id = ' || p_po_header_id);
             END IF;
            END IF;
          end if;
          CLOSE PO_CSR;
         EXCEPTION
          WHEN OTHERS THEN
           if (sqlcode = '-54') then
             l_err_msg_name_tbl := po_tbl_varchar30();
             l_err_msg_text_tbl := po_tbl_varchar2000();
             x_pos_errors   := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);
             x_pos_errors.message_name.extend;
             x_pos_errors.text_line.extend;
             x_pos_errors.message_name(1) := null;
             x_pos_errors.text_line(1) :=  fnd_message.get_string('POS', 'POS_LOCKED_PO_ROW');

             return;
            end if;
         END;
   end if;

   -- Check if the same record is being update
   -- Check against last_updated_date to make sure that
   -- The record that was queried is being updated

   if (p_last_upd_date <> l_last_upd_date) then
         l_err_msg_name_tbl := po_tbl_varchar30();
         l_err_msg_text_tbl := po_tbl_varchar2000();
         x_pos_errors   := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);
         x_pos_errors.message_name.extend;
         x_pos_errors.text_line.extend;
         x_pos_errors.message_name(1) := null;
         x_pos_errors.text_line(1) :=  fnd_message.get_string('POS', 'POS_MODIFIED_PO_ROW');
       return;
   end if;
   -- Copy the request into a local var
   l_po_change_requests := p_po_change_requests;

  IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                     '.invoked', 'Type: ' ||
                     ', Header  ID: ' || NVL(TO_CHAR(p_po_header_id),'null') ||
                     ', Release ID: ' || NVL(TO_CHAR(p_po_release_id),'null'));
      END IF;
   END IF;


   validate_shipment_cancel (
        p_po_header_id,
		p_po_release_id,
        p_po_change_requests,
        x_pos_errors,
        l_ret_sts);
        if(l_ret_sts = 'Y') then
        return;
        end if;

    if ( l_po_change_requests(1).action_type in ('CANCELLATION') AND
              l_po_change_requests(1).request_level='HEADER' ) then
              if (l_po_change_requests.count > 1 ) then
                 x_return_status := FND_API.g_ret_sts_unexp_error;

                   FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		     IF g_fnd_debug = 'Y' THEN
		       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
		           FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
		           l_api_name || fnd_message.get_string('PO', 'POS_MULT_HDR_CANCEL_REQ'), sqlcode);
		       END IF;
		     END IF;



                   l_err_msg_name_tbl := po_tbl_varchar30();
                   l_err_msg_text_tbl := po_tbl_varchar2000();
                   x_pos_errors       := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);



                 x_pos_errors.message_name.extend;
                 x_pos_errors.text_line.extend;
                 x_pos_errors.message_name(1) := null;
                 /*
                   POS_MULT_HDR_CANCEL_REQ  = 'Multiple requests are made in context with Header level cancel.'
                 */

                 x_pos_errors.text_line(1) :=  fnd_message.get_string('PO', 'POS_MULT_HDR_CANCEL_REQ');

                 return;
              end if;
              save_cancel_request(
                  p_api_version  => 1.0    ,
                  p_Init_Msg_List => FND_API.G_FALSE,
                  x_return_status  => l_return_status,
 	              p_po_header_id   => p_po_header_id,
 	              p_po_release_id  => p_po_release_id,
 	              p_revision_num   => p_revision_num,
 	              p_po_change_requests  => l_po_change_requests,
                  x_request_group_id   => l_request_group_id
                  );
                  x_online_report_id := 0;
                  if (l_return_status <>  FND_API.g_ret_sts_success) then
                     l_err_msg_name_tbl := po_tbl_varchar30();
                   l_err_msg_text_tbl := po_tbl_varchar2000();
                   x_pos_errors       := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);


                   x_pos_errors.message_name.extend;
                   x_pos_errors.text_line.extend;
                   x_pos_errors.message_name(1) := null;
                 /*
                   POS_SAVE_CANCEL_REQ_ERR  = 'Error while saving the cancel request: '
                 */

                 x_pos_errors.text_line(1) :=
                     fnd_message.get_string('PO', 'POS_SAVE_CANCEL_REQ_ERR') ||
                     FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, p_encoded => 'F');


                  end if;

              return;

     end if;

    if p_po_release_id is null then
		select agent_id,nvl(acceptance_required_flag,'N')
		into v_buyer_id,x_accp_flag
		from po_headers_all
		where po_header_id = p_po_header_id;
    else
        	select agent_id,nvl(acceptance_required_flag,'N')
		into v_buyer_id,x_accp_flag
		from po_releases_all
		where po_release_id = p_po_release_id;
    end if;

    FOR i in 1..l_po_change_requests.count()
       LOOP
         if (l_po_change_requests(i).action_type in ('ACCEPT','REJECT') AND
           l_po_change_requests(i).request_level='SHIPMENT' ) then
            callWf := true;
          --updatePoAttr := false;
          --callDocCheck := false;

           if (l_po_change_requests(i).action_type = 'ACCEPT') then
		accp_flag := 'Y';
           else
        	accp_flag := 'N';
           end if;

           -- Process The Acknowledgements

    	   PO_ACKNOWLEDGE_PO_GRP.Acknowledge_shipment(
           1.0,FND_API.G_FALSE,x_return_status,
    	   l_po_change_requests(i).document_line_location_id,
    	   l_po_change_requests(i).document_header_id,
    	   l_po_change_requests(i).po_release_id,
    	   l_po_change_requests(i).document_revision_num,
     	   accp_flag,
    	   l_po_change_requests(i).request_reason,
	   v_buyer_id, fnd_global.user_id);

        elsif (l_po_change_requests(i).request_level='LINE' AND
               l_po_change_requests(i).action_type='MODIFICATION') then
              callWf := true;
              callDocCheck := true;
              updatePoAttr := true;
              saveRequest  := true;
        elsif (l_po_change_requests(i).request_level='SHIPMENT' AND
               l_po_change_requests(i).action_type='CANCELLATION') then
          -- Do not call doc sub check for shipment cancellation
              saveRequest  := true;
              callWf := true;
              --callDocCheck := false;
              updatePoAttr := true;

        elsif (l_po_change_requests(i).request_level='SHIPMENT' AND
               l_po_change_requests(i).action_type='MODIFICATION') then
            -- If quantity,promised_date,price,Amount have not changed in the shipment level do not update po
            /*Bug 7112734 - Start
            During PO change process if Supplier Order Line number alone is changed then it will
            be treated as acceptance of the PO.
            */
    	      if (l_po_change_requests(i).new_quantity is null AND
    	          l_po_change_requests(i).new_promised_date is null AND
                  l_po_change_requests(i).new_price is null AND
                  l_po_change_requests(i).new_amount is null) then      -- FPS Enhancement
                  --callDocCheck := false;
                  --updatePoAttr := false;
		              l_po_change_requests(i).request_status     := 'ACCEPTED';

                  -- If PO requires acknowledgement, post shipment-level acceptance.
                  IF (x_accp_flag = 'Y') THEN

                     callWf := true;
                     -- Process The Acknowledgements
    	               PO_ACKNOWLEDGE_PO_GRP.Acknowledge_shipment(
           		       1.0,FND_API.G_FALSE,x_return_status,
    	   		         l_po_change_requests(i).document_line_location_id,
    	   		         l_po_change_requests(i).document_header_id,
    	   		         l_po_change_requests(i).po_release_id,
    	   		         l_po_change_requests(i).document_revision_num,
     	   		         'Y',
    	   		         l_po_change_requests(i).request_reason,
	   		             v_buyer_id, fnd_global.user_id);

                  END IF;

              else
                 -- if othere parameters are updated with so then update po
                 callWf := true;
                 callDocCheck := true;
                 updatePoAttr := true;
                 saveRequest  := true;
                 -- Bug 7112734  - End
              end if; -- if only so has changed

	    if (l_po_change_requests(i).New_Supplier_Order_Line_Number is not null) then
                 begin
                  update po_line_locations_all
                  set supplier_order_line_number = l_po_change_requests(i).New_Supplier_Order_Line_Number
                  where line_location_id = l_po_change_requests(i).document_line_location_id;
                exception
                WHEN OTHERS THEN
                x_return_status := FND_API.g_ret_sts_unexp_error;
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
                    IF g_fnd_debug = 'Y' THEN
                     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                       FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others_exception', sqlcode);
                     END IF;
                    END IF;
                 END IF;
                end;          end if;
        elsif  (l_po_change_requests(i).request_level='HEADER'
              AND l_po_change_requests(i).action_type='MODIFICATION') then
                  saveRequest  := true;

	if (nvl(l_po_change_requests(i).New_Supplier_Order_Number,-1) <>  nvl(l_po_change_requests(i).Old_Supplier_Order_Number,-1)) then

 	        if (p_po_release_id is null ) then
              -- Update the vendor_order_num for PO Headers no need of approval.
                  update po_headers_all
                  set vendor_order_num = l_po_change_requests(i).New_Supplier_Order_Number
                  where po_header_id   = p_po_header_id;
            else
              -- Update the vendor_order_num for PO Releases no need of approval.
                  update po_releases_all
                  set vendor_order_num = l_po_change_requests(i).New_Supplier_Order_Number
                  where po_release_id   = p_po_release_id;
            end if;
	   end if;

              -- Set startWf to false
	    if (l_po_change_requests(i).Additional_changes is not null) then
              callWf       := true;
              updatePoAttr := true;
	    end if;
              --callDocCheck := false;

        end if; -- end if accept reject
      END LOOP;
   if ((callDocCheck) AND l_po_change_requests.count() > 0 ) then
    IF g_fnd_debug = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                   '.invoked', ' Change Count : ' || TO_CHAR(l_po_change_requests.count()));
        END IF;
     END IF;

    IS_ASN_EXIST(
        p_po_header_id,
		p_po_release_id,
		p_po_change_requests,
		x_pos_errors,
		l_ret_sts);
		IF( l_ret_sts = 'Y')
		THEN RETURN;
		END IF;


       validate_change_request (
       p_api_version           => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       x_return_status         => x_return_status,
       x_msg_data              => l_msg_data,
       p_po_header_id          => p_po_header_id,
       p_po_release_id         => p_po_release_id,
       p_revision_num          => p_revision_num,
       p_po_change_requests    => l_po_change_requests,
       x_online_report_id      => x_online_report_id,
       x_pos_errors            => x_pos_errors);

   end if;

   if (l_po_change_requests.count() > 0 AND x_return_status = FND_API.G_RET_STS_SUCCESS) then
      IF g_fnd_debug = 'Y' THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                   '.invoked', 'Type: ' ||
                   ', Save Count : ' || TO_CHAR(l_po_change_requests.count()));
          END IF;
       END IF;


     if(x_return_status = FND_API.G_RET_STS_SUCCESS) then

       if (saveRequest) then

       save_request(
       p_api_version            => 1.0,
       p_init_msg_list          => FND_API.G_FALSE,
       x_return_status          => x_return_status,
       p_po_header_id           => p_po_header_id,
       p_po_release_id          => p_po_release_id,
       p_revision_num           => p_revision_num,
       p_po_change_requests     => l_po_change_requests,
       x_request_group_id       => l_request_group_id,
       p_chn_int_cont_num       => p_chn_int_cont_num,
       p_chn_source             => p_chn_source,
       p_chn_requestor_username => p_chn_requestor_username,
       p_user_id                => p_user_id,
       p_login_id               => p_login_id);
     end if;

     if(updatePoAttr) then
        IF g_fnd_debug = 'Y' THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
               FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                        '.invoked', 'Update PO ' ||
                        ', Header  ID: ' || NVL(TO_CHAR(p_po_header_id),'null') ||
                        ', Release ID: ' || NVL(TO_CHAR(p_po_release_id),'null'));
           END IF;
       END IF;
        update_po_attributes(p_po_header_id,p_po_release_id,p_revision_num,
        	l_request_group_id, x_return_status, p_chn_requestor_username,
        	p_user_id,
        	p_login_id);
     end if;


        /* Bug 3534807, mji
           Check if all shipments has been acknowledged, if yes post header
           acknowledgement record.
        */
        PO_ACKNOWLEDGE_PO_GRP.Set_Header_Acknowledgement (
    		1.0,
    		FND_API.G_FALSE,
		x_return_status,
		p_po_header_id,
		p_po_release_id );


     if (callWf) then
       IF g_fnd_debug = 'Y' THEN
         IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                   '.invoked', 'Call Workflow ' || ', request group id ' || to_char(l_request_group_id));
         END IF;
       END IF;
--start multiple po change
       if (p_mpoc = FND_API.G_TRUE) then
	 if(x_accp_flag = 'Y') then
    	   x_return_status := po_acknowledge_po_grp.all_shipments_responded (
             1.0,FND_API.G_FALSE,p_po_header_id , p_po_release_id, p_revision_num );
	 else
	   x_return_status := FND_API.G_TRUE;
	 end if;

	 if(x_return_status = FND_API.G_TRUE) then
	     IF g_fnd_debug = 'Y' THEN
	        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
	            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
	                          '.invoked', ' All shipments acked/changed ' );
	        END IF;
	     END IF;
	 else
	     l_err_msg_name_tbl := po_tbl_varchar30();
	     l_err_msg_text_tbl := po_tbl_varchar2000();
	     x_pos_errors  := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);
	     x_pos_errors.message_name.extend;
	     x_pos_errors.text_line.extend;
	     x_pos_errors.message_name(1) := null;
	     x_pos_errors.text_line(1) :=  fnd_message.get_string('POS', 'POS_PO_ALL_NOT_RESPND');
	 end if;
       end if;
--end mupltiple po change change

         x_return_status := startSupplierWF( p_po_header_id,p_po_release_id,
                p_revision_num, l_request_group_id, x_accp_flag);
           IF g_fnd_debug = 'Y' THEN
	             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
	               FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
	                      '.invoked', 'Call Workflow ' || ', Return Status  ' || x_return_status);
	             END IF;
         END IF;
     end if;

    end if; --if docCheck returns FND_API.G_RET_STS_SUCCESS

    end if;
    -- Update the PO Headers/Releases even if the changes dosent require doc Check
    if (callDocCheck=false) then
       if (p_user_id is null or p_login_id is null) then
              l_user_id := fnd_global.user_id;
              l_login_id := fnd_global.login_id;
            else
              l_user_id := p_user_id;
              l_login_id := p_login_id;
       end if;
       -- Update the last update date if po dosent require to be updated
       if (p_po_release_id is not null) then
        update po_releases_all set
            		    last_update_date       = sysdate,
            		    last_updated_by        = l_user_id,
            		    last_update_login      = l_login_id,
            		    request_id             = fnd_global.conc_request_id,
            		    program_application_id = fnd_global.prog_appl_id,
            		    program_id             = fnd_global.conc_program_id,
            		    program_update_date    = sysdate
	where po_release_id = p_po_release_id;
       else
        update po_headers_all set
            		    last_update_date       = sysdate,
            		    last_updated_by        = l_user_id,
            		    last_update_login      = l_login_id,
            		    request_id             = fnd_global.conc_request_id,
            		    program_application_id = fnd_global.prog_appl_id,
            		    program_id             = fnd_global.conc_program_id,
            		    program_update_date    = sysdate
	where po_header_id = p_po_header_id;
       end if;
     end if; -- if call doc check is false
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others_exception', sqlcode);
            END IF;
	    END IF;
        END IF;
        l_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                        p_encoded => 'F');
 END process_supplier_request;
/**
 * Private Procedure: update_po_attributes
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM,REQUEST_GROUP_ID
 * Modifies:
 * Effects:  Updates The PO_HEADERS_ALL, PO_RELEASES_ALL
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */

 procedure update_po_attributes
          (p_po_header_id       IN  number,
           p_po_release_id      IN  number,
           p_revision_num       IN  number,
           p_chg_request_grp_id IN  number,
           x_return_status      OUT NOCOPY varchar2,
           p_chn_requestor_username in varchar2 default null,
           p_user_id            IN number default null,
           p_login_id           IN number default null) is

   l_api_name          CONSTANT VARCHAR2(30) := 'update_po_attributes';
   l_user_id      number;
   l_login_id     number;

BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      if (p_user_id is null or p_login_id is null) then
              l_user_id := fnd_global.user_id;
              l_login_id := fnd_global.login_id;
            else
              l_user_id := p_user_id;
              l_login_id := p_login_id;
      end if;

      if p_po_release_id is null then
        update po_headers_all set
                 	    authorization_status   = 'IN PROCESS',
   	                    CHANGE_REQUESTED_BY	   = 'SUPPLIER',
            		    last_update_date       = sysdate,
            		    last_updated_by        = l_user_id,
            		    last_update_login      = l_login_id,
            		    request_id             = fnd_global.conc_request_id,
            		    program_application_id = fnd_global.prog_appl_id,
            		    program_id             = fnd_global.conc_program_id,
            		    program_update_date    = sysdate
	where po_header_id = p_po_header_id;

       -- Update the approved_flag to R for all the shipments that has been changed
       -- do not update the flag for cancellation requests at shipments
       -- That was the earlier comment now we are going to chnage the
       -- Approved flag for cancellation records as asked by DBI team
       -- bug 4306375
       -- jai

       update po_line_locations_all
       set approved_flag = 'R'
       where  line_location_id in (select document_line_location_id
            			           from   po_change_requests
		                		   where  request_level = 'SHIPMENT' and
				                   document_header_id   = p_po_header_id and
     				               action_type          in ('MODIFICATION','CANCELLATION') and
				                   initiator            = 'SUPPLIER' and
		    		               request_status       ='PENDING') and
               approved_flag='Y';

       -- Update all the shipments for which line price has been changed to prevent receiving
       -- do not update the line locations for cancellation request
       -- That was the earlier comment now we are going to chnage the
       -- Approved flag for cancellation records as asked by DBI team
       -- bug 4306375
       -- jai

       update po_line_locations_all
       set approved_flag = 'R'
       where  po_header_id in (select document_header_id
                                   from   po_change_requests
                                   where  request_level = 'HEADER' and
                                   document_header_id   = p_po_header_id and
                                   action_type          ='CANCELLATION' and
                                   initiator            = 'SUPPLIER' and
                                   request_status       ='PENDING') and
       approved_flag='Y';

       update po_line_locations_all
       set    approved_flag = 'R'
       where  po_line_id in (select document_line_id
			     from   po_change_requests
			     where  request_level      = 'LINE' and
				    document_header_id = p_po_header_id and
				    request_status     = 'PENDING' and
				    initiator          = 'SUPPLIER' and
				    action_type        = 'MODIFICATION' and
				    new_price is not null) and
                    approved_flag='Y'
                    and po_release_id is null;   --This condition added for bug 8768745


              /* jai
              and
              line_location_id not in (select document_line_location_id
                                   from   po_change_requests
                                   where  request_level      = 'SHIPMENT' and
                                          document_header_id = p_po_header_id and
                                          action_type        = 'CANCELLATION' and
				          initiator          = 'SUPPLIER' and
                                            request_status     ='PENDING') ;
             */
      else
       -- For Releases
       update po_releases_all set
			    authorization_status   = 'IN PROCESS',
                            CHANGE_REQUESTED_BY	   = 'SUPPLIER',
            		    revised_date           = sysdate,
            		    last_update_date       = sysdate,
            		    last_updated_by        = l_user_id,
            		    last_update_login      = l_login_id,
            		    request_id             = fnd_global.conc_request_id,
            		    program_application_id = fnd_global.prog_appl_id,
            		    program_id             = fnd_global.conc_program_id,
            		    program_update_date    = sysdate
	where po_release_id = p_po_release_id;

      -- Now Update the approved_flag to R for all the shipments that has been
      -- changed to prevent receiving
       update po_line_locations_all
       set approved_flag = 'R'
       where  line_location_id in (select document_line_location_id
			                       from   po_change_requests
				                   where  request_level  = 'SHIPMENT' and
				                   po_release_id  = p_po_release_id and
					               action_type     in ('MODIFICATION','CANCELLATION') and
				                   initiator      = 'SUPPLIER' and
					               request_status = 'PENDING') and
        approved_flag='Y';

       --New DBI request
      update po_line_locations_all
       set approved_flag = 'R'
       where  po_release_id in (select po_release_id
                                   from   po_change_requests
                                   where  request_level = 'HEADER' and
                                   po_release_id   = p_po_release_id and
                                   action_type          ='CANCELLATION' and
                                   initiator            = 'SUPPLIER' and
                                   request_status       ='PENDING') and
     approved_flag='Y';
      end if;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others_exception', sqlcode);
            END IF;
            END IF;
        END IF;
END update_po_attributes;

/**
 * Public Procedure: validate_change_request
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM,POS_CHG_REC_TBL
 * Modifies:
 * Effects:  Converts the Supplier Change Request To PO Change Request
 *           Calls Doc Submission Check API
 *           Also calls process_acknowledgements API to post Acknowledgements
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */

procedure validate_change_request (
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_data            OUT NOCOPY VARCHAR2,
	    p_po_header_id        IN  number,
	    p_po_release_id       IN  number,
	    p_revision_num        IN  number,
	    p_po_change_requests  IN OUT NOCOPY pos_chg_rec_tbl,
	    x_online_report_id    OUT NOCOPY number,
 	    x_pos_errors          OUT NOCOPY pos_err_type,
 	    x_doc_check_error_msg OUT NOCOPY Doc_Check_Return_Type) is

 x_error_code           varchar2(40);
 rec_cnt                number :=0;
 line_cnt               number :=0;
 ship_cnt               number :=0;
 dist_cnt               number :=0;
 ack_cnt                number :=0;
 p_document_id          NUMBER;
 v_document_type        PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
 v_type_code            PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
 v_document_subtype     PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
 sub_check_failed       exception;

 poLineIdTbl  	        po_tbl_number    := po_tbl_number();
 unitPriceTbl 		po_tbl_number    := po_tbl_number();
 -- <PO_CHANGE_API FPJ> VENDOR_PRODUCT_NUM should use varchar30, not varchar40:
 supItemTbl		po_tbl_varchar30 := po_tbl_varchar30();
 startdateTbl           po_tbl_date      := po_tbl_date();
 expirationdateTbl      po_tbl_date      := po_tbl_date();
 amountTbl              po_tbl_number    := po_tbl_number();
 shipamountTbl          po_tbl_number    := po_tbl_number();
 poLineLocIdTbl  	po_tbl_number    := po_tbl_number();
 parentLineLocIdTbl     po_tbl_number    := po_tbl_number();
 quantityTbl  		po_tbl_number    := po_tbl_number();
 priceOverrideTbl  	po_tbl_number    := po_tbl_number();
 shipmentNumTbl  	po_tbl_number    := po_tbl_number();
 promisedDateTbl  	po_tbl_date      := po_tbl_date();

 distQtyTbl		po_tbl_number    := po_tbl_number();
 distIdTbl		po_tbl_number    := po_tbl_number();
 distAmtTbl             po_tbl_number    := po_tbl_number();    -- FPS

 l_return_status 	varchar2(10);
 l_sub_check_status 	varchar2(10);
 l_online_report_id 	number;
 l_msg_data             varchar2(2000);

 --l_doc_check_error_msg 	Doc_Check_Return_Type := NULL;

 -- <PO_CHANGE_API FPJ START>
 -- Added a PO_ prefix to the names of the change object types:
 vLineChanges		PO_LINES_REC_TYPE;
 vShipChanges		PO_SHIPMENTS_REC_TYPE;
 vDistChanges		PO_DISTRIBUTIONS_REC_TYPE;
 vRequestedChanges      PO_CHANGES_REC_TYPE;
 -- <PO_CHANGE_API FPJ END>

 vAckTbl		pos_ack_rec_tbl := pos_ack_rec_tbl();
 x_progress varchar2(3) := '000';
 l_api_name             CONSTANT VARCHAR2(30) := 'validate_change_request';
 l_api_version          CONSTANT NUMBER := 1.0;
 x_sub_errors           number;
 x_org_id               number;
 sub_error_flag         varchar2(1);
 x_cum_flag             boolean     := FALSE;
 x_price                number := NULL;
 l_error_index          number     := 0;
 l_err_msg_name_tbl     po_tbl_varchar30;
 l_err_msg_text_tbl     po_tbl_varchar2000;
 l_total_qty		number;
 l_ga_ship_qty          number;
 l_ga_lineLocId         number;
 l_ga_lineId            number;
 l_qty_orig		number;
 l_qty_split		number;
 l_shipToOrg		number;
 l_shipToLoc		number;
 l_needByDate		date;
 lLine			number;
 changeOrig		varchar2(1) := 'F';
 l_price_break_type     VARCHAR2(1) := NULL;
 l_cumulative_flag      BOOLEAN     := false;
 l_initiator            po_change_requests.initiator%type :='SUPPLIER';
 --<< Complex work changes for R12 >>
 progress_type_tbl     PO_TBL_VARCHAR30:= PO_TBL_VARCHAR30();
 pay_description_tbl   PO_TBL_VARCHAR240:= PO_TBL_VARCHAR240();

  /* 9867085 */
 skip_line number := 0;

 -- Bug 8818198. Modified cursor to pick lines, which are not cancelled.
 -- Bug 9060324. Modified cursor to pick only the open lines.
 cursor ga_line_csr(p_po_header_id in number) is
        select po_line_id
        from  po_lines_archive_all  pol
        where pol.po_header_id = p_po_header_id and
              pol.latest_external_flag='Y' and
	      nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED') and
	      nvl(pol.cancel_flag,'N') <> 'Y' and
	      nvl(pol.MANUAL_PRICE_CHANGE_FLAG,'N') <> 'Y' AND /* 9867085 */
              pol.from_header_id in (
				select po_header_id
				from po_headers_all poh
				where poh.global_agreement_flag='Y'
				and poh.po_header_id=pol.from_header_id)
				and exists(select poll.line_location_id
 	                      		   from po_line_locations_archive_all poll
	   	                           where  poll.po_line_id = pol.po_line_id and
 	                                          nvl(poll.closed_code,'OPEN') not in('FINALLY CLOSED') and
                     	                          nvl(poll.cancel_flag,'N') <> 'Y' and
              	                                  poll.latest_external_flag='Y') ;

 cursor ga_ship_csr(p_line_id in number) is
        select line_location_id,quantity
        from   po_line_locations_archive_all
        where  po_line_id = p_line_id and
	       nvl(closed_code,'OPEN') not in('FINALLY CLOSED') and
	       nvl(cancel_flag,'N') <> 'Y' and
               latest_external_flag='Y' ;

 BEGIN

    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
   IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Type: ' ||
                      ', Header  ID: ' || NVL(TO_CHAR(p_po_header_id),'null') ||
                      ', Release ID: ' || NVL(TO_CHAR(p_po_release_id),'null'));
       END IF;
    END IF;

    if (p_po_release_id is not null) then
        p_document_id      := p_po_release_id;
        v_document_type    := 'RELEASE';
        v_document_subtype := 'RELEASE';
        select org_id
        into x_org_id
        from po_releases_all
        where po_release_id= p_po_release_id;
     else
        p_document_id := p_po_header_id;
        select type_lookup_code , org_id
        into v_type_code , x_org_id
        from po_headers_all
        where po_header_id= p_po_header_id;
        if (v_type_code in ('STANDARD','PLANNED')) then
            v_document_type    := 'PO';
            v_document_subtype := v_type_code;
        elsif (v_type_code in ('BLANKET','CONTRACT')) then
            v_document_type    := 'PA';
            v_document_subtype := v_type_code;
        end if;
     end if;

    -- Set the org context before calling core po api's
    PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;         -- <R12 MOAC>

    rec_cnt := p_po_change_requests.count();
    -- Now check if the document references a global agreement
    -- or a blanket, then get the price accordingly
    if (rec_cnt > 0) then
     l_initiator:=p_po_change_requests(1).initiator;
    end if;
  if (rec_cnt > 0) then
   FOR i in 1..rec_cnt
   LOOP
      --Construct the table of line record
        if(p_po_change_requests(i).request_level = 'LINE') then
             poLineIdTbl.extend; unitPriceTbl.extend; supItemTbl.extend;
             startdateTbl.extend;expirationdateTbl.extend;amountTbl.extend;

             line_cnt := line_cnt + 1;
             poLineIdTbl(line_cnt)       := p_po_change_requests(i).document_line_id;
             unitPriceTbl(line_cnt)      := p_po_change_requests(i).new_price;
             supItemTbl(line_cnt)        := p_po_change_requests(i).new_supplier_part_number;
             startdateTbl(line_cnt)      := p_po_change_requests(i).new_start_date;
             expirationdateTbl(line_cnt) := p_po_change_requests(i).new_expiration_date;
             amountTbl(line_cnt)         := p_po_change_requests(i).new_amount;
        end if; -- end if line

      -- do not send cancellation request
    if(p_po_change_requests(i).request_level = 'SHIPMENT' AND
         (p_po_change_requests(i).action_type not in ('ACCEPT','REJECT','CANCEL'))) then
             ship_cnt := ship_cnt + 1;
             poLineLocIdTbl.extend; quantityTbl.extend;
	         promisedDateTbl.extend;priceOverrideTbl.extend;
	         parentLineLocIdTbl.extend;
             shipmentNumTbl.extend;
             shipamountTbl.extend;
             progress_type_tbl.extend;
             pay_description_tbl.extend;
	      -- if release / standard po referencing a GA/ Quotation
	      -- Call Get Price Break API.

	  --if ((p_po_change_requests(i).from_header_id is not null) or
          --   (p_po_change_requests(i).po_release_id is not null)) then
	  if  (p_po_change_requests(i).po_release_id is not null) then

               SELECT decode(price_break_lookup_code, 'CUMULATIVE', 'Y', 'N')
               INTO l_price_break_type
               FROM po_lines_all
               WHERE po_line_id = p_po_change_requests(i).document_line_id;

               IF (l_price_break_type = 'Y') THEN
                   l_cumulative_flag := TRUE;
               ELSE
                  l_cumulative_flag := FALSE;
               END IF;

if(p_po_change_requests(i).new_price is null) then
               x_price := po_sourcing2_sv.get_break_price(
               nvl(p_po_change_requests(i).new_quantity,p_po_change_requests(i).old_quantity),
               p_po_change_requests(i).ship_to_organization_id,
               p_po_change_requests(i).ship_to_location_id,
               p_po_change_requests(i).document_line_id,
	           l_cumulative_flag,
               nvl(p_po_change_requests(i).new_need_by_date,p_po_change_requests(i).old_need_by_date), -- need_by_date
               p_po_change_requests(i).document_line_location_id);
    	       p_po_change_requests(i).old_price := x_price;
end if;
	  end if; -- end if release

             poLineLocIdTbl(ship_cnt)     := p_po_change_requests(i).document_line_location_id;
	         parentLineLocIdTbl(ship_cnt) := p_po_change_requests(i).parent_line_location_id;
             quantityTbl(ship_cnt)        := p_po_change_requests(i).new_quantity;
             promisedDateTbl(ship_cnt)    := p_po_change_requests(i).new_promised_date;
	         priceOverrideTbl(ship_cnt)   := nvl(p_po_change_requests(i).new_price,x_price);
	         shipmentNumTbl(ship_cnt)     := p_po_change_requests(i).document_shipment_number;
             progress_type_tbl(ship_cnt)  := p_po_change_requests(i).new_progress_type;
             pay_description_tbl(ship_cnt):= p_po_change_requests(i).new_pay_description;
             shipamountTbl(ship_cnt):= p_po_change_requests(i).new_amount;
    end if; -- if shipment

    if   (p_po_change_requests(i).request_level = 'DISTRIBUTION') then
	         dist_cnt := dist_cnt + 1;
     	     distIdTbl.extend;  distQtyTbl.extend; distAmtTbl.extend;    -- FPS Changes
	         distIdTbl(dist_cnt)  := p_po_change_requests(i).document_distribution_id;
	         distQtyTbl(dist_cnt) := p_po_change_requests(i).new_quantity;
                 distAmtTbl(dist_cnt) := p_po_change_requests(i).new_amount;    -- FPS Changes

    end if; -- if dist

   --end if; -- end of rec count
  END LOOP;

    -- Now check if the change request consists of any shipments that refers to a GA
    -- in that case sum up the quatities and call price break api to get new line price
    -- and post a line level change to Doc Check API

 if (p_po_release_id is null ) then
   open ga_line_csr(p_po_header_id);
   loop

      l_qty_orig  := 0;
      l_qty_split := 0;
      l_total_qty := 0;
      x_price     := 0;

      fetch ga_line_csr into l_ga_lineId;
      exit when ga_line_csr%notfound;

      /* 9867085 */
      SKIP_LINE := 0;

      FOR I IN 1..REC_CNT LOOP

       IF ( P_PO_CHANGE_REQUESTS(I).REQUEST_LEVEL = 'LINE' AND
            P_PO_CHANGE_REQUESTS(I).DOCUMENT_LINE_ID = L_GA_LINEID AND
            NVL(P_PO_CHANGE_REQUESTS(I).NEW_PRICE,-1) <> NVL(P_PO_CHANGE_REQUESTS(I).OLD_PRICE,-1) )
       THEN
            SKIP_LINE := 1;

       END IF;
      end loop;

      IF SKIP_LINE = 1 THEN
         SKIP_LINE := 0;
         --CONTINUE; Bug#12883760 Key word not supported in 10g
      ELSE
      /* 9867085 */

      open ga_ship_csr(l_ga_lineId);

        loop

       	   fetch ga_ship_csr
       	   into l_ga_lineLocId,l_ga_ship_qty;
           exit when ga_ship_csr%notfound;
           changeOrig := 'F';
           FOR i in 1..rec_cnt LOOP

	      if (p_po_change_requests(i).request_level = 'SHIPMENT' and
	          p_po_change_requests(i).action_type = 'MODIFICATION' ) then

 	          if(p_po_change_requests(i).document_line_location_id = l_ga_lineLocId and
                 p_po_change_requests(i).new_quantity is not null and
 	             p_po_change_requests(i).parent_line_location_id is null ) then

                     l_qty_orig := l_qty_orig + p_po_change_requests(i).new_quantity;
		     changeOrig := 'T';
                  end if;
	         -- Sum up all the split quantities
 	          if (p_po_change_requests(i).parent_line_location_id is not null and
 	              p_po_change_requests(i).parent_line_location_id = l_ga_lineLocId and
                  p_po_change_requests(i).new_quantity is not null) then

                   l_qty_split  := l_qty_split + p_po_change_requests(i).new_quantity;

	          end if;
	      end if ; -- if shipment change
           END LOOP;

           if (changeOrig = 'F') then
	 -- if original shipment hasnt been changed
	   l_qty_orig := l_qty_orig + l_ga_ship_qty;
	   end if;
        end loop;
      close ga_ship_csr;

          l_total_qty := l_qty_orig + l_qty_split;

	   -- Get the price break for the total quantity for each line using the min shipment
           -- need by date and ship to org
          select ship_to_location_id, ship_to_organization_id,need_by_date
	      into   l_shipToLoc,l_shipToOrg,l_needBydate
          from   po_line_locations_archive_all
          where  shipment_num = (select min(shipment_num)
                       from   po_line_locations_archive_all
                       where  po_line_id = l_ga_lineId and
                              nvl(closed_code,'OPEN') not in('FINALLY CLOSED') and
                              nvl(cancel_flag,'N') <> 'Y' and
                              latest_external_flag='Y' ) and
                              latest_external_flag='Y' and
                              po_line_id = l_ga_lineId ;

          -- For Global Agreement refered Standard PO's x_cum_flag  is always FALSE
           x_price := po_sourcing2_sv.get_break_price(
           l_total_qty, l_shipToOrg, l_shipToLoc, l_ga_lineId, x_cum_flag, l_needBydate, null);

	  -- Post a line level change with the price returned from price break api

	     lLine := poLineIdTbl.count;
             poLineIdTbl.extend; unitPriceTbl.extend; supItemTbl.extend;
             startdateTbl.extend;expirationdateTbl.extend;amountTbl.extend;

             line_cnt := line_cnt + 1;
             poLineIdTbl(lLine+1)       := l_ga_lineId;
             unitPriceTbl(lLine+1)      := x_price;
             supItemTbl(lLine+1)        := null;
             startdateTbl(lLine+1)      := null;
             expirationdateTbl(lLine+1) := null;
             amountTbl(lLine+1)         := null;


             IF g_fnd_debug = 'Y' THEN
	                   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
	                     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name
	                        , 'Calculating Price break for STD PO from GA: ' ||
	                        ', PO Line Id : ' || NVL(TO_CHAR(l_ga_lineId),'null') ||
	                        ', Total Quantity  : ' || NVL(TO_CHAR(l_total_qty),'null') ||
	                        ', Price Break : ' || NVL(TO_CHAR(x_price),'null'));
	                   END IF;
	     END IF;
        END IF;--SKIP_LINE = 1
       end loop;
     close ga_line_csr;

    end if; -- if release id
 -- Construct Line Record Changes

     -- <PO_CHANGE_API FPJ START>
     -- Added a PO_ prefix to the names of the change object types and
     -- modified their constructors.
     vLineChanges	  := PO_LINES_REC_TYPE.create_object (
                               p_po_line_id         => poLineIdTbl,
                               p_unit_price         => unitPriceTbl,
                               p_vendor_product_num => supItemTbl,
                               p_start_date         => startdateTbl,
                               p_expiration_date    => expirationdateTbl,
                               p_amount             => amountTbl
                             );

     vShipChanges	  := PO_SHIPMENTS_REC_TYPE.create_object (
                               p_po_line_location_id     => poLineLocIdTbl,
                               p_quantity                => quantityTbl,
                               p_promised_date           => promisedDateTbl,
                               p_price_override          => priceOverrideTbl,
                               p_parent_line_location_id => parentLineLocIdTbl,
                               p_split_shipment_num      => shipmentNumTbl,
                               p_payment_type            => progress_type_tbl,
                               p_description             => pay_description_tbl,
                               p_amount                  => shipamountTbl
                             );

     vDistChanges      := PO_DISTRIBUTIONS_REC_TYPE.create_object (
                               p_po_distribution_id      => distIdTbl,
                               p_quantity_ordered        => distQtyTbl,
                               p_amount_ordered          => distAmtTbl        -- FPS
                             );

     vRequestedChanges  := PO_CHANGES_REC_TYPE.create_object (
                               p_po_header_id         => p_po_header_id,
                               p_po_release_id        => p_po_release_id,
                               p_line_changes         => vLineChanges,
                               p_shipment_changes     => vShipChanges,
                               p_distribution_changes => vDistChanges
                          );
     -- <PO_CHANGE_API FPJ END>



     PO_DOCUMENT_CHECKS_GRP.PO_SUBMISSION_CHECK(
     p_api_version  	       => 1.0,
     p_action_requested        => 'DOC_SUBMISSION_CHECK',
     p_document_type           => v_document_type,
     p_document_subtype        => v_document_subtype,
     p_document_id             => p_document_id,
     p_org_id                  => x_org_id,
     p_requested_changes       => vRequestedChanges,
     p_req_chg_initiator       => l_initiator,
     x_return_status	       => l_return_status,
     x_sub_check_status	       => l_sub_check_status,
     x_msg_data                => l_msg_data,
     x_online_report_id	       => x_online_report_id,
     x_doc_check_error_record  => x_doc_check_error_msg);




     l_err_msg_name_tbl := po_tbl_varchar30();
     l_err_msg_text_tbl := po_tbl_varchar2000();
     x_pos_errors       := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);

     if  (  l_return_status    = FND_API.G_RET_STS_SUCCESS AND
            l_sub_check_status = FND_API.G_RET_STS_ERROR) THEN

               x_sub_errors := x_doc_check_error_msg.online_report_id.count;
               sub_error_flag := 'N';
    	       FOR i in 1..x_sub_errors loop
                 if ((x_doc_check_error_msg.message_name(i) not in
                      ('PO_SUB_PO_LINE_NE_SHIP_AMT','PO_SUB_PO_LINE_NE_SHIP_QTY',
		           'PO_SUB_PO_SHIP_NE_DIST_AMT','PO_SUB_PO_SHIP_NE_DIST_QTY',
		           'PO_SUB_REQ_LINE_NE_DIST_AMT','PO_SUB_REQ_LINE_NE_DIST_QTY',
                       'PO_SUB_REL_SHIP_NE_DIST_AMT','PO_SUB_REL_SHIP_NE_DIST_QTY',
                       'PO_SUB_SHIP_NO_DIST','PO_SUB_REL_SHIP_NO_DIST',
		       'PO_SUB_PAY_ITEM_NE_LINE_AMT'))             --Bug 5547289
                     AND nvl(x_doc_check_error_msg.message_type(i), 'E') <> 'W') then
                  sub_error_flag := 'Y';
                  l_error_index := l_error_index + 1;
                  x_pos_errors.message_name.extend;
                  x_pos_errors.text_line.extend;
                  x_pos_errors.message_name(l_error_index) := x_doc_check_error_msg.message_name(i);
                  x_pos_errors.text_line(l_error_index)    := x_doc_check_error_msg.text_line(i);
                 end if;
               end loop;
            -- Some other errors were reported from submission check api
            if (sub_error_flag = 'Y') then
                raise sub_check_failed;
            else
		x_return_status := FND_API.G_RET_STS_SUCCESS;
            end if;
     elsif (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        --x_msg_data has stuff regarding doc sub check.
            l_error_index := l_error_index + 1;
            x_pos_errors.message_name.extend;
            x_pos_errors.text_line.extend;
            x_pos_errors.message_name(l_error_index) := null;
            x_pos_errors.text_line(l_error_index)    := l_msg_data;
            raise sub_check_failed;
     -- If l_return_status and l_sub_check_status = FND_API.G_RET_STS_SUCCESS
     -- Then Continue no errors in doc check
     end if;

     x_progress := '007';
  end if; --end rec cnt

 EXCEPTION
     WHEN FND_API.g_exc_error THEN
         x_return_status := FND_API.g_ret_sts_error;
     WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
     WHEN sub_check_failed THEN
         x_return_status := FND_API.g_ret_sts_error;
     WHEN OTHERS THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
             IF g_fnd_debug = 'Y' THEN
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
               FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                             l_api_name || '.others_exception', sqlcode);
             END IF;
 	    END IF;
         END IF;
         l_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                         p_encoded => 'F');
 END validate_change_request;

/* Overloaded Procedure to return only filtered Errors for supplier changes*/

procedure validate_change_request (
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_data            OUT NOCOPY VARCHAR2,
	        p_po_header_id        IN  number,
	        p_po_release_id       IN  number,
	        p_revision_num        IN  number,
	        p_po_change_requests  IN OUT NOCOPY pos_chg_rec_tbl,
	        x_online_report_id    OUT NOCOPY number,
 	        x_pos_errors          OUT NOCOPY pos_err_type) is

 l_doc_check_error_msg 	Doc_Check_Return_Type := NULL;
 l_msg_data             varchar2(2000) := NULL;

 BEGIN
       --l_po_change_requests := p_po_change_requests;

       validate_change_request (
       p_api_version           => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       x_return_status         => x_return_status,
       x_msg_data              => l_msg_data,
       p_po_header_id          => p_po_header_id,
       p_po_release_id         => p_po_release_id,
       p_revision_num          => p_revision_num,
       p_po_change_requests    => p_po_change_requests,
       x_online_report_id      => x_online_report_id,
       x_pos_errors            => x_pos_errors,
       x_doc_check_error_msg   => l_doc_check_error_msg);

 END validate_change_request;

/**
 * Private Function: ifLineChangable
 * Requires: PO_LINE_ID
 * Modifies: None
 * Effects:
 *           Determines id the Line Price can be changed
 * Returns:
 *   x_return_status -
 *   'Y' - price change is allowed.
 *    'N' - price change is not allowed.
 *  Modified the logic in the function for the bug 18360218(17382389)
 */

 function ifLineChangable( p_po_line_id IN  number)
	   return varchar2 is

    d_mod CONSTANT VARCHAR2(100) := D_ifLineChangable;
    d_position NUMBER := 0;

    l_line_id_tbl PO_TBL_NUMBER;
    l_result_set_id NUMBER;
    l_result_type VARCHAR2(30);
    l_results PO_VALIDATION_RESULTS_TYPE;
    l_allow_price_override varchar2(1);
    l_line_modifier_exist varchar2(1);
    l_po_header_id number;
    l_count number;
    l_doc_type                   varchar2(25);
    l_line_type varchar2(25);
    l_complex_fin_po varchar2(1) :='N';
    l_price_break_lookup_code_tbl  PO_TBL_VARCHAR30;
    l_amount_changed_flag_tbl   PO_TBL_VARCHAR1;
    l_result_type_rank_WARNING NUMBER :=PO_VALIDATIONS.result_type_rank(PO_VALIDATIONS.c_result_type_warning);

    x_price_update_allowed varchar2(1);

  BEGIN
    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod, 'p_po_line_id', p_po_line_id);
    END IF;

    d_position := 10;
    l_allow_price_override :='Y';

    d_position := 100;
    begin

      select nvl(ref_pol.allow_price_override_flag,'Y'),
             pol.po_header_id,
             poh.type_lookup_code,
             pol.ORDER_TYPE_LOOKUP_CODE
      into l_allow_price_override,
           l_po_header_id,
           l_doc_type,
           l_line_type
      from po_lines_all ref_pol,
           po_lines_all pol,
           po_headers_all poh
      where pol.po_line_id=p_po_line_id
            and pol.po_header_id=poh.po_header_id
            and pol.from_line_id=ref_pol.po_line_id;

    exception
     when no_data_found then
       l_allow_price_override:='Y';

     when others then
      Raise;
     end;

     IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_allow_price_override', l_allow_price_override);
      PO_LOG.stmt(d_mod, d_position, 'l_po_header_id', l_po_header_id);
      PO_LOG.stmt(d_mod, d_position, 'l_doc_type', l_doc_type);
      PO_LOG.stmt(d_mod, d_position, 'l_line_type', l_line_type);

    END IF;

     --See if the PO is of type BLANKET; if so, the price can be updatable at any time.
     if( l_doc_type = 'BLANKET') then
      return 'Y';
     end if;

     --For a PO line, if the allow Price Override checkbox is unchecked on src line,
     -- then Line price cannot be changed
    if(l_allow_price_override='N') then
      return 'N';
    end if;


    -- Do not allow Price Change for an Amount Based Line of a Complex PO(Actual)/ SPO
    if(l_line_type= 'AMOUNT') then

        if(PO_COMPLEX_WORK_PVT.is_complex_work_po(l_po_header_id)) then

          if(PO_COMPLEX_WORK_PVT.is_financing_po(l_po_header_id)) then
              l_complex_fin_po:='Y';
          end if;

      end if;

      if(l_complex_fin_po = 'N') then
        return 'N';
      end if;
    end if;


    -- Check for line modifier
    -- Find whether manual or overridden modifiers exist
    -- Price update is not allowed if manual or overridden modifier applied on the line.

    d_position := 200;
    PO_PRICE_ADJUSTMENTS_PKG.line_modifier_exist(
       p_po_header_id        => l_po_header_id
      ,p_po_line_id          => p_po_line_id
      ,x_line_modifier_exist => l_line_modifier_exist);


    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_line_modifier_exist', l_line_modifier_exist);
    END IF;

    if(nvl(l_line_modifier_exist,'N') ='Y') then
        return 'N';
    end if;


    d_position := 300;


    l_line_id_tbl := PO_TBL_NUMBER(p_po_line_id);
    l_amount_changed_flag_tbl := PO_TBL_VARCHAR1('N');
    l_price_break_lookup_code_tbl := PO_TBL_VARCHAR30(NULL);



    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_line_id_tbl(1) = ', l_line_id_tbl(1));
      PO_LOG.stmt(d_mod, d_position, 'l_amount_changed_flag_tbl(1) = ', l_amount_changed_flag_tbl(1));
      PO_LOG.stmt(d_mod, d_position, 'l_price_break_lookup_code_tbl(1) = ', l_price_break_lookup_code_tbl(1));
    END IF;

    d_position := 400;

    select count(1)
    into   l_count
    from po_distributions_all pod
    where po_line_id=p_po_line_id
          and nvl(pod.amount_changed_flag,'N')='N';

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_count', l_count);
    END IF;

    IF l_count = 0 then
      l_amount_changed_flag_tbl(1) := 'Y';
    end if ;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_line_id_tbl(1) = ', l_line_id_tbl(1));
      PO_LOG.stmt(d_mod, d_position, 'l_amount_changed_flag_tbl(1) = ', l_amount_changed_flag_tbl(1));
      PO_LOG.stmt(d_mod, d_position, 'l_price_break_lookup_code_tbl(1) = ', l_price_break_lookup_code_tbl(1));
    END IF;

    d_position := 500;

    PO_VALIDATIONS.validate_unit_price_change(
       p_line_id_tbl => l_line_id_tbl
     , p_price_break_lookup_code_tbl => l_price_break_lookup_code_tbl
     , p_amount_changed_flag_tbl => l_amount_changed_flag_tbl
     , p_stopping_result_type => PO_VALIDATIONS.c_result_type_FAILURE
     , x_result_type => l_result_type
     , x_result_set_id => l_result_set_id
     , x_results => l_results);


    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod, d_position, 'l_result_set_id', l_result_set_id);
      PO_LOG.stmt(d_mod, d_position, 'l_result_type', l_result_type);
    END IF;

    d_position := 600;

    IF (PO_VALIDATIONS.result_type_rank(l_result_type) >=
        l_result_type_rank_WARNING)
      THEN
      x_price_update_allowed := 'Y';
    ELSE
      x_price_update_allowed :='N';
    END IF;


    IF PO_LOG.d_proc THEN
      PO_LOG.proc_end(d_mod, 'x_price_update_allowed', x_price_update_allowed);
    END IF;

   return x_price_update_allowed;

    EXCEPTION
      WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN
          PO_LOG.exc(d_mod, d_position, NULL);
        END IF;
      Return '';

 END ifLineChangable;


procedure validateCancelRequest(
           p_api_version    IN     NUMBER,
           p_init_msg_list  IN     VARCHAR2 := FND_API.G_FALSE,
           x_return_status  OUT    NOCOPY VARCHAR2,
           p_po_header_id   IN     NUMBER,
           p_po_release_id  IN     NUMBER) IS

    p_document_id       NUMBER;
    v_document_type     PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    v_document_subtype  PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    v_type_code         PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    l_api_name          CONSTANT VARCHAR2(30) := 'validateCancelRequest';
    l_api_version       CONSTANT NUMBER := 1.0;
    x_org_id            number;
    x_ship_count NUMBER := 0;


  BEGIN
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;

    -- Call this when logging is enabled

   IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                      '.invoked', 'Type: ' ||
                      ', Header  ID: ' || NVL(TO_CHAR(p_po_header_id),'null') ||
                      ', Release ID: ' || NVL(TO_CHAR(p_po_release_id),'null'));
       END IF;
   END IF;
    if (p_po_release_id is not null) then

        p_document_id      := p_po_release_id;
        v_document_type    := 'RELEASE';
        v_document_subtype := 'RELEASE';


	select poh.type_lookup_code,por.org_id
	into	v_type_code,x_org_id
	from	po_headers_all poh,po_releases_all por
	where   por.po_header_id = poh.po_header_id and
		por.po_release_id = p_po_release_id;

	if (v_type_code = 'BLANKET') then
		v_document_type := 'RELEASE';
		v_document_subtype := 'BLANKET';
	elsif (v_type_code = 'PLANNED') then
		v_document_type := 'RELEASE';
		v_document_subtype := 'SCHEDULED';
	end if;
    else
        p_document_id := p_po_header_id;
        select type_lookup_code into v_type_code
        from po_headers_all
        where po_header_id= p_po_header_id;
        if (v_type_code in ('STANDARD','PLANNED')) then
            v_document_type    := 'PO';
            v_document_subtype := v_type_code;
        elsif (v_type_code in ('BLANKET','CONTRACT')) then
            v_document_type    := 'PA';
            v_document_subtype := v_type_code;
        end if;

        select org_id
        into x_org_id
        from po_headers_all
        where po_header_id= p_po_header_id;

    end if;
         -- Set the org context before calling the cancel api

         PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;    -- <R12 MOAC>

         PO_Document_Control_GRP.check_control_action(
         p_api_version      => 1.0,
         p_init_msg_list    => FND_API.G_TRUE,
         x_return_status    => x_return_status,
         p_doc_type         => v_document_type,
         p_doc_subtype      => v_document_subtype,
         p_doc_id           => p_po_header_id,
         p_doc_num          => null,
         p_release_id       => p_po_release_id,
         p_release_num      => null,
         p_doc_line_id      => null,
         p_doc_line_num     => null,
         p_doc_line_loc_id  => null,
         p_doc_shipment_num => null,
         p_action           => 'CANCEL');


      IF (x_return_status =  FND_API.G_RET_STS_SUCCESS) then

	BEGIN
	if (p_po_release_id is not null) then
		SELECT    count(*)
		INTO     x_ship_count
	        FROM PO_LINE_LOCATIONS_ALL POLL,PO_LINES_ALL POL
		WHERE 	   POLL.po_release_id = p_po_release_id
		     AND   POLL.po_line_id = POL.po_line_id
		     AND   nvl(POLL.cancel_flag, 'N') = 'N'
		     AND   nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
		     AND   POLL.shipment_type in ('SCHEDULED', 'BLANKET')
                     AND   (nvl(POLL.quantity_received,0) >= nvl(POLL.quantity,0)
                                OR nvl(POLL.quantity_billed,0) > nvl(POLL.quantity,0)
                                OR nvl(POLL.quantity_billed,0) > nvl(POLL.quantity_received,0))
		     AND   POL.order_type_lookup_code NOT IN ('RATE', 'FIXED PRICE');
	else
		SELECT    count(*)
		INTO     x_ship_count
	        FROM PO_LINE_LOCATIONS_ALL POLL,PO_LINES_ALL POL,PO_HEADERS_ALL POH
		WHERE
			   POH.PO_HEADER_ID = p_po_header_id
		     AND   POH.PO_HEADER_ID = POL.PO_HEADER_ID
		     AND   POH.TYPE_LOOKUP_CODE ='STANDARD'
		     AND   POLL.po_line_id = POL.po_line_id
		     AND   nvl(POLL.cancel_flag, 'N') = 'N'
		     AND   nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                     AND   (nvl(POLL.quantity_received,0) >= nvl(POLL.quantity,0)
                                OR nvl(POLL.quantity_billed,0) > nvl(POLL.quantity,0)
                                OR nvl(POLL.quantity_billed,0) > nvl(POLL.quantity_received,0))
		     AND   POL.order_type_lookup_code NOT IN ('RATE', 'FIXED PRICE')
                     AND   NVL(POLL.payment_type,' ') <> 'ADVANCE'; -- <Bug 5504546>

	end if;

	if (x_ship_count > 0) then
		x_return_status := FND_API.G_RET_STS_ERROR;
	else
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	end if;

	EXCEPTION
			WHEN FND_API.g_exc_error THEN
		        x_return_status := FND_API.g_ret_sts_error;
			WHEN FND_API.g_exc_unexpected_error THEN
			x_return_status := FND_API.g_ret_sts_unexp_error;
			WHEN OTHERS THEN
		        x_return_status := FND_API.g_ret_sts_unexp_error;
	        	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
		            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
		            IF g_fnd_debug = 'Y' THEN
		            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
		              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
		                            l_api_name || '.others_exception', sqlcode);
		             END IF;
		            END IF;
			END IF;

	END;
END IF;


EXCEPTION

    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others_exception', sqlcode);
            END IF;
            END IF;
        END IF;

END validateCancelRequest;

PROCEDURE  getShipmentStatus(
           p_line_location_id   IN     NUMBER,
           p_po_header_id       IN     NUMBER,
           p_po_release_id      IN     NUMBER,
           p_revision_num       IN     NUMBER,
           x_msg_code           OUT NOCOPY VARCHAR2,
           x_msg_display        OUT NOCOPY VARCHAR2,
           x_note               OUT NOCOPY LONG) IS

x_ack_stat varchar2(40);
x_accp_flag po_headers_all.acceptance_required_flag%type;
x_revision number;
x_cons_flag po_line_locations.consigned_flag%type;

BEGIN
if p_line_location_id is not null then
 if (p_po_release_id is null) then
select DECODE( nvl(pll.cancel_flag,'N'),
                'Y',fnd_message.get_string('POS','POS_PO_CANCELLED'),
                'N',DECODE(NVL(pll.CONSIGNED_FLAG,'N'),
                 'Y',DECODE(NVL(pll.CLOSED_CODE,'OPEN'),'CLOSED FOR INVOICE',
                    DECODE(
                    PO_ACKNOWLEDGE_PO_GRP.GET_SHIPMENT_ACK_CHANGE_STATUS
                    (1.0,FND_API.G_FALSE,pll.line_location_id,
                     pll.po_header_id, p_po_release_id,p_revision_num),
                    'PENDING_CHANGE',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CHANGE'),
                    'ACK_REQUIRED',FND_MESSAGE.GET_STRING('POS','POS_ACCP_REQUIRED'),
                    'PENDING_CANCEL',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CANCEL'),
                    'ACCEPTED',FND_MESSAGE.GET_STRING('POS','POS_PO_ACCEPTED'),
                    'REJECTED',FND_MESSAGE.GET_STRING('POS','POS_PO_REJECTED'),
                    '',polc.displayed_field),
                    polc.displayed_field
                  ),
                 'N',
                   CASE
                    when NVL(pll.CLOSED_CODE,'OPEN')='OPEN' OR NVL(pll.CLOSED_CODE,'OPEN')='CLOSED FOR RECEIVING'
                     OR NVL(pll.CLOSED_CODE,'OPEN') = 'CLOSED FOR INVOICE'
                     THEN
                  DECODE(
                    PO_ACKNOWLEDGE_PO_GRP.GET_SHIPMENT_ACK_CHANGE_STATUS
                    (1.0,FND_API.G_FALSE,pll.line_location_id,
                     pll.po_header_id, p_po_release_id,p_revision_num),
                    'PENDING_CHANGE',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CHANGE'),
                    'ACK_REQUIRED',FND_MESSAGE.GET_STRING('POS','POS_ACCP_REQUIRED'),
                    'PENDING_CANCEL',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CANCEL'),
                    'ACCEPTED',FND_MESSAGE.GET_STRING('POS','POS_PO_ACCEPTED'),
                    'REJECTED',FND_MESSAGE.GET_STRING('POS','POS_PO_REJECTED'),
                    '',polc.displayed_field)
                   ELSE polc.displayed_field
                  END
              )
            ) ,
	    nvl(pll.closed_code,'OPEN'),
            PO_ACKNOWLEDGE_PO_GRP.GET_SHIPMENT_ACK_CHANGE_STATUS
            (1.0,FND_API.G_FALSE,pll.line_location_id,
             pll.po_header_id, p_po_release_id,p_revision_num),nvl(poh.acceptance_required_flag,'N'),
            poh.revision_num,nvl(pll.consigned_flag,'N')
    into    x_msg_display,x_msg_code,x_ack_stat,x_accp_flag,x_revision,x_cons_flag
    from    po_line_locations_all pll,
	    po_headers_all poh,
            po_lookup_codes polc
    where
            polc.lookup_code     = NVL(pll.closed_code, 'OPEN') and
            polc.lookup_type     = 'DOCUMENT STATE' and
	    poh.po_header_id	 = pll.po_header_id and
            pll.line_location_id = p_line_location_id ;

    if ( x_ack_stat in ('REJECTED','ACCEPTED')) then
	begin
           select note into x_note
           from po_acceptances
           where po_line_location_id=p_line_location_id and
                 revision_num = x_revision;
        exception
	when others then
          x_note := null;
        end;
    end if;

 else
 select DECODE( nvl(pll.cancel_flag,'N'),
                'Y',fnd_message.get_string('POS','POS_PO_CANCELLED'),
                'N',DECODE(NVL(pll.CONSIGNED_FLAG,'N'),
                 'Y',DECODE(NVL(pll.CLOSED_CODE,'OPEN'),'CLOSED FOR INVOICE',
                    DECODE(
                    PO_ACKNOWLEDGE_PO_GRP.GET_SHIPMENT_ACK_CHANGE_STATUS
                    (1.0,FND_API.G_FALSE,pll.line_location_id,
                     pll.po_header_id, p_po_release_id,p_revision_num),
                    'PENDING_CHANGE',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CHANGE'),
                    'ACK_REQUIRED',FND_MESSAGE.GET_STRING('POS','POS_ACCP_REQUIRED'),
                    'PENDING_CANCEL',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CANCEL'),
                    'ACCEPTED',FND_MESSAGE.GET_STRING('POS','POS_PO_ACCEPTED'),
                    'REJECTED',FND_MESSAGE.GET_STRING('POS','POS_PO_REJECTED'),
                    '',polc.displayed_field),
                    polc.displayed_field
                  ),
                 'N',
                  CASE
                    when NVL(pll.CLOSED_CODE,'OPEN')='OPEN' OR NVL(pll.CLOSED_CODE,'OPEN')='CLOSED FOR RECEIVING'
                     OR NVL(pll.CLOSED_CODE,'OPEN') = 'CLOSED FOR INVOICE'
                     THEN
                  DECODE(
                    PO_ACKNOWLEDGE_PO_GRP.GET_SHIPMENT_ACK_CHANGE_STATUS
                    (1.0,FND_API.G_FALSE,pll.line_location_id,
                     pll.po_header_id, p_po_release_id,p_revision_num),
                    'PENDING_CHANGE',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CHANGE'),
                    'ACK_REQUIRED',FND_MESSAGE.GET_STRING('POS','POS_ACCP_REQUIRED'),
                    'PENDING_CANCEL',FND_MESSAGE.GET_STRING('POS','POS_PENDING_CANCEL'),
                    'ACCEPTED',FND_MESSAGE.GET_STRING('POS','POS_PO_ACCEPTED'),
                    'REJECTED',FND_MESSAGE.GET_STRING('POS','POS_PO_REJECTED'),
                    '',polc.displayed_field)
                   ELSE polc.displayed_field
                  END
              )
            ) ,
	    nvl(pll.closed_code,'OPEN'),
            PO_ACKNOWLEDGE_PO_GRP.GET_SHIPMENT_ACK_CHANGE_STATUS
            (1.0,FND_API.G_FALSE,pll.line_location_id,
             pll.po_header_id, p_po_release_id,p_revision_num),nvl(por.acceptance_required_flag,'N'),
	    por.revision_num,nvl(pll.consigned_flag,'N')
    into    x_msg_display,x_msg_code,x_ack_stat,x_accp_flag,x_revision,x_cons_flag
    from    po_line_locations_all pll,
	    po_releases_all por,
            po_lookup_codes polc
    where
            polc.lookup_code     = NVL(pll.closed_code, 'OPEN') and
            polc.lookup_type     = 'DOCUMENT STATE' and
	    por.po_header_id	 = pll.po_header_id and
            por.po_release_id    = p_po_release_id and
            pll.line_location_id = p_line_location_id ;

      if ( x_ack_stat = 'REJECTED') then
	begin
           select note into x_note
           from po_acceptances
           where po_line_location_id=p_line_location_id and
                 revision_num = x_revision;
        exception
	when others then
          x_note := null;
        end;
      end if;

  end if;

   --Bug 4107241: allow acknowledge any shipments not closed/finally closed.
   if (x_ack_stat = 'ACK_REQUIRED' and
      x_msg_code not in ('CLOSED', 'FINALLY CLOSED') ) then
           x_msg_code :='ACK REQUIRED';
           -- valid assumption for now, coz this values is reqd in UI
           -- to display ack actions in poplist , where only PO's with
           -- status OPEN ack is allowed
   elsif  x_ack_stat = 'REJECTED' then
          x_msg_code := 'REJECTED';
   elsif  (x_ack_stat = 'ACCEPTED' and x_accp_flag='Y') then
          x_msg_code := 'ACKSTAGE';
   elsif  x_ack_stat = 'PENDING_CANCEL' then
          x_msg_code := 'PENDING_CANCEL';

   end if;
 else
  -- This means a split shipment pass back PENDING
       select FND_MESSAGE.GET_STRING('POS','POS_PENDING_CHANGE')
       into x_msg_display
       from dual;

       x_msg_code :='PENDING_CHANGE';
end if;

END getShipmentStatus;

procedure save_cancel_request(
          p_api_version          IN NUMBER    ,
          p_Init_Msg_List        IN VARCHAR2  ,
          x_return_status        OUT NOCOPY VARCHAR2,
 	  p_po_header_id         IN  number,
 	  p_po_release_id        IN  number,
 	  p_revision_num         IN  number,
 	  p_po_change_requests   IN  pos_chg_rec_tbl,
          x_request_group_id     OUT NOCOPY NUMBER) is

    l_api_name              CONSTANT VARCHAR2(30) := 'save_cancel_request';
    l_api_version_number    CONSTANT NUMBER := 1.0;
    l_request_group_id      NUMBER;

 BEGIN
     IF fnd_api.to_boolean(P_Init_Msg_List) THEN
        -- initialize message list
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;
       save_request(
       p_api_version           => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       x_return_status         => x_return_status,
       p_po_header_id          => p_po_header_id,
       p_po_release_id         => p_po_release_id,
       p_revision_num          => p_revision_num,
       p_po_change_requests    => p_po_change_requests,
       x_request_group_id      => l_request_group_id);

     -- Call Update PO Procedure to set PO in IN PROCESS
       update_po_attributes(p_po_header_id,
			    p_po_release_id,
			    p_revision_num,
                            l_request_group_id,
                            x_return_status);

     -- Start the workflow for cancel request
      if (x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         x_return_status := startSupplierWF(
                p_po_header_id,p_po_release_id,p_revision_num,
        	l_request_group_id,'N');
      end if;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others exception' ,sqlcode);
            END IF;
            END IF;
        END IF;


END save_cancel_request;

/**
 * Private Function: getLineAttrs
 * Requires: PO_LINE_ID
 * Modifies: None
 * Effects:
 *           Determines if there is a Global Agreement,Un Number, Haz Class
 * Returns:
 *           x_ga_number, x_un_number, x_haz_class
 */
procedure getLineAttrs(
           p_from_header_id     IN  NUMBER,
           p_un_number_id       IN  NUMBER,
           p_haz_class_id       IN  NUMBER,
           x_ga_number          OUT NOCOPY VARCHAR2,
           x_un_number          OUT NOCOPY VARCHAR2,
           x_haz_class_desc     OUT NOCOPY VARCHAR2) is

BEGIN

 BEGIN
  SELECT segment1
  INTO   x_ga_number
  FROM   po_headers_all
  WHERE  po_header_id = p_from_header_id
  AND    global_agreement_flag='Y';
 EXCEPTION
  when no_data_found then
  x_ga_number := null;
 END;

 if p_un_number_id is not null then

  BEGIN
   SELECT UN_NUMBER
   INTO   x_un_number
   FROM  PO_UN_NUMBERS_TL
   WHERE UN_NUMBER_ID = p_un_number_id
   AND   LANGUAGE = USERENV('LANG');
   --AND   SOURCE_LANG = USERENV('LANG'); Bug 3637026
  EXCEPTION
    when no_data_found then
    x_un_number := null;
  END;
 end if;

 if p_haz_class_id is not null then

  BEGIN
   SELECT DESCRIPTION
   INTO  x_haz_class_desc
   FROM  PO_HAZARD_CLASSES_TL
   WHERE HAZARD_CLASS_ID = p_haz_class_id
   AND   LANGUAGE = USERENV('LANG');
   --AND   SOURCE_LANG = USERENV('LANG'); Bug 3637026
  EXCEPTION
    when no_data_found then
    x_haz_class_desc := null;
  END;
 end if;

END getLineAttrs;

/**
 * Procedure: cancel_change_request
 * Requires: PO_LINE_ID or po_line_location_id
 * Modifies: None
 * Effects:
 * Determines if there is any change request pending approval for the buyer
 * and cancels the request subsequently
 *
 */
PROCEDURE cancel_change_request
   (p_api_version         IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2,
    x_return_status       OUT  NOCOPY VARCHAR2,
    p_po_header_id        IN   NUMBER,
    p_po_release_id       IN   NUMBER,
    p_po_line_id          IN   NUMBER,
    p_po_line_location_id IN   NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'cancel_change_request';
l_api_version CONSTANT NUMBER := 1.0;
l_cancel_msg fnd_new_messages.message_text%type := fnd_message.get_string('POS','POS_AUTO_CANCEL_BY_BUYER');
xGrpId       number := 0;
xRevNum      number ;
lGrpId       number := 0;
lRevNum      number ;
l_return_status varchar2(1);
l_msg_out varchar2(2000);
l_revision_num number;

 cursor c1(p_po_header_id in number) is
        select change_request_group_id,DOCUMENT_REVISION_NUM
        from  po_change_requests
        where document_header_id = p_po_header_id and
	      document_type    = 'PO' and
	      change_active_flag= 'Y' and
	      initiator = 'SUPPLIER' and
              request_status  not in ('ACCEPTED', 'REJECTED');

 cursor c2(p_po_release_id in number) is
        select change_request_group_id,DOCUMENT_REVISION_NUM
        from  po_change_requests
        where po_release_id  = p_po_release_id and
	      document_type   = 'RELEASE' and
	      change_active_flag= 'Y' and
	      initiator = 'SUPPLIER' and
              request_status  not in ('ACCEPTED', 'REJECTED');

BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

   -- Get the change request group id for the change requests if any
   if (p_po_release_id is not null) then
	open c2(p_po_release_id);
	fetch c2 into xGrpId,xRevNum;
        close c2;
   else
	open c1(p_po_header_id);
	fetch c1 into xGrpId,xRevNum;
        close c1;
   end if;

 if (xGrpId > 0) then
   l_cancel_msg :=  fnd_message.get_string('POS','POS_AUTO_CANCEL_BY_BUYER') ;
   if (p_po_release_id is not null and p_po_line_id is null and p_po_line_location_id is null) then
      begin
        update po_change_requests
        set request_status  = 'REJECTED',change_active_flag = 'N',
             request_reason=l_cancel_msg
        where po_release_id = p_po_release_id and
	          initiator = 'SUPPLIER' and
              request_status  not in ('ACCEPTED','REJECTED') and
	          action_type='MODIFICATION';

        update po_change_requests
        set request_status  = 'ACCEPTED',
            change_active_flag = 'N'
      	where initiator = 'SUPPLIER' and
              request_status  not in ('ACCEPTED','REJECTED') and
              action_type='CANCELLATION' and
              po_release_id = p_po_release_id;
      exception
        when no_data_found then
             null;
      end;
   end if;

   if (p_po_header_id is not null and p_po_line_id is null and p_po_line_location_id is null) then
      begin
        update po_change_requests
        set request_status  = 'REJECTED',
            change_active_flag = 'N',
            request_reason=l_cancel_msg
        where document_header_id = p_po_header_id and
              request_status  not in ('ACCEPTED','REJECTED') and
	          initiator = 'SUPPLIER' and
	          action_type='MODIFICATION';

        update po_change_requests
        set    request_status  = 'ACCEPTED',
               change_active_flag = 'N'
        where  request_status  not in ('ACCEPTED','REJECTED') and
	       initiator = 'SUPPLIER' and
               action_type='CANCELLATION' and
               document_header_id = p_po_header_id ;
      exception
        when no_data_found then
             null;
      end;
   end if;

   if (p_po_line_location_id is not null ) then
      begin
        update po_change_requests
        set request_status  = 'REJECTED',change_active_flag = 'N',request_reason=l_cancel_msg
        where document_line_location_id = p_po_line_location_id and
              request_level = 'SHIPMENT' and
              request_status  not in ('ACCEPTED','REJECTED') and
	      initiator = 'SUPPLIER' and
              action_type='MODIFICATION';

        update po_change_requests
        set request_status  = 'ACCEPTED',change_active_flag = 'N'
        where document_line_location_id = p_po_line_location_id and
              request_level = 'SHIPMENT' and
              request_status  not in ('ACCEPTED','REJECTED') and
	      initiator = 'SUPPLIER' and
              action_type='CANCELLATION';

      exception
        when no_data_found then
             null;
      end;
   end if;

   if (p_po_line_id is not null and p_po_line_location_id is null ) then
      begin
        update po_change_requests
        set request_status='REJECTED',change_active_flag='N',request_reason=l_cancel_msg
        where document_line_id = p_po_line_id and
              request_status  not in ('ACCEPTED','REJECTED') and
	      initiator = 'SUPPLIER' and
              action_type='MODIFICATION';

        update po_change_requests
        set request_status='ACCEPTED',change_active_flag='N'
        where document_line_id = p_po_line_id and
              request_status  not in ('ACCEPTED','REJECTED') and
	      initiator = 'SUPPLIER' and
              action_type='CANCELLATION';

      exception
        when no_data_found then
             null;
      end;
   end if;

   -- reset document status to approved if there are no more changes pending by supplier

   if (p_po_release_id is not null) then
	open c2(p_po_release_id);
	fetch c2 into lGrpId,lRevNum;
        close c2;
	if (lGrpId is null) then

        update po_releases_all set
			            authorization_status   = 'APPROVED',
                        CHANGE_REQUESTED_BY	   = null,
            		    revised_date           = sysdate,
            		    last_update_date       = sysdate,
            		    last_updated_by        = fnd_global.user_id,
            		    last_update_login      = fnd_global.login_id,
            		    request_id             = fnd_global.conc_request_id,
            		    program_application_id = fnd_global.prog_appl_id,
            		    program_id             = fnd_global.conc_program_id,
            		    program_update_date    = sysdate
		where po_release_id = p_po_release_id;
        -- Update all the change requests with current revision number
	else
	      begin
                select revision_num
		into l_revision_num
		from po_releases_all
		where po_release_id = p_po_release_id;
	     exception
		when others then
		raise;
	     end;
        	update po_change_requests
                set document_revision_num = l_revision_num
                where po_release_id = p_po_release_id and
                      request_status  not in ('ACCEPTED','REJECTED') and
	              document_type   = 'RELEASE' and
	              change_active_flag= 'Y' and
	              initiator = 'SUPPLIER' ;
        end if;
   else
	open c1(p_po_header_id);
	fetch c1 into lGrpId,lRevNum;
        close c1;
	if (lGrpId is null) then

        update po_headers_all set
                 	    authorization_status   = 'APPROVED',
     	                    CHANGE_REQUESTED_BY	   = null,
            		    last_update_date       = sysdate,
            		    last_updated_by        = fnd_global.user_id,
            		    last_update_login      = fnd_global.login_id,
            		    request_id             = fnd_global.conc_request_id,
            		    program_application_id = fnd_global.prog_appl_id,
            		    program_id             = fnd_global.conc_program_id,
            		    program_update_date    = sysdate
		where po_header_id = p_po_header_id;
        -- Update all the change requests with current revision number
	else

	      begin
                select revision_num
		into l_revision_num
		from po_headers_all
		where po_header_id = p_po_header_id;
	     exception
		when others then
		raise;
	     end;
        	update po_change_requests
                set document_revision_num=l_revision_num
                where document_header_id = p_po_header_id and
                      request_status  not in ('ACCEPTED','REJECTED') and
	              document_type   = 'PO' and
	              change_active_flag= 'Y' and
	              initiator = 'SUPPLIER' ;
        end if;
   end if;
   -- Call process Response to send notification if there are no more changes
   -- in change request table

   if (lGrpId is null) then
        po_sup_chg_request_wf_grp.Buyer_CancelDocWithChn(
        1.0,l_return_status,p_po_header_id,p_po_release_id,xRevNum,xGrpId,l_msg_out);
       if (l_return_status <> 'S') then
         IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                           l_api_name || '.call buyer cancel workflow', l_msg_out);
            END IF;
         END IF;
      end if;
     end if; -- if lGrpId is null
   end if; -- if xGrpId > 0



EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF (g_fnd_debug = 'Y') THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                 FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                               l_api_name || '.others_exception', 'Exception');
               END IF;
            END IF;
        END IF;
 END cancel_change_request;

 procedure process_supplier_signature (
         p_api_version            IN  NUMBER,
         p_Init_Msg_List          IN  VARCHAR2,
         x_return_status          OUT NOCOPY VARCHAR2,
         x_notification_id        OUT NOCOPY NUMBER,
  	 p_po_header_id  	  IN  number,
  	 p_revision_num  	  IN  number,
         p_document_subtype       IN  VARCHAR2,
         p_document_number        IN  VARCHAR2,
         p_org_id                 IN  NUMBER,
         p_Agent_Id               IN  NUMBER,
         p_supplier_user_id       IN  number)
  IS

 l_api_version_number     CONSTANT NUMBER := 1.0;
 l_api_name               CONSTANT VARCHAR2(30) := 'process_supplier_signature';
 l_item_key               WF_ITEMS.item_key%TYPE := NULL;
 l_item_type              WF_ITEMS.item_type%TYPE;
 x_result                 VARCHAR2(20);
 x_sup_user_id            NUMBER;
 l_supplier_username      fnd_user.user_name%type;
 sig_notif_notfound       exception;
 l_document_type          VARCHAR2(20);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);
 l_ret_status             VARCHAR2(20);
 BEGIN

    IF fnd_api.to_boolean(P_Init_Msg_List) THEN
        -- initialize message list
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        if (p_document_subtype in ('STANDARD','PLANNED')) then
            l_document_type    := 'PO';

        elsif (p_document_subtype in ('BLANKET','CONTRACT')) then
            l_document_type    := 'PA';
        end if;

    select wf_item_type
      into l_item_type
      from po_headers_all
      WHERE po_header_id = p_po_header_id;


    -- First Find the Item Key for this Document if it were ever generated
    BEGIN
         PO_SIGNATURE_GRP.Find_Item_Key(
                          p_api_version   => 1.0,
			  p_init_msg_list => FND_API.G_FALSE,
                          p_po_header_id  => p_po_header_id,
                          p_revision_num  => p_revision_num ,
                          p_document_type => l_document_type ,
                          x_itemkey       => l_item_key,
			  x_result        => x_result,
			  x_return_status => l_ret_status,
			  x_msg_count     => l_msg_count,
			  x_msg_data      => l_msg_data );
    END;



    -- To create Item key for the Document Signature Process
    IF (l_item_key is null) then
      BEGIN

         PO_SIGNATURE_GRP.Get_Item_Key(
                          p_api_version   => 1.0,
			  p_init_msg_list => FND_API.G_FALSE,
                          p_po_header_id  => p_po_header_id,
                          p_revision_num  => p_revision_num ,
                          p_document_type => l_document_type ,
                          x_itemkey       => l_item_key,
			  x_result        => x_result,
			  x_return_status => l_ret_status,
			  x_msg_count     => l_msg_count,
			  x_msg_data      => l_msg_data );

       END;


      -- Start Signature Workflow and pass the Newly generated Item Key
      -- Create a Workflow Process

         x_return_status := startSignatureWF (
         l_item_type,
         l_item_key ,
  	 p_po_header_id ,
  	 p_revision_num ,
         l_document_type,
         p_document_subtype,
         p_document_number,
         p_org_id ,
         p_Agent_Id ,
         p_supplier_user_id ) ;

       if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
           x_notification_id := getSigNotifId(l_item_type, l_item_key);
           if x_notification_id is null then
             RAISE sig_notif_notfound;
           end if;
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
             FND_LOG.string(FND_LOG.level_unexpected, l_api_name ||
           l_item_key || '.Notification :' || to_char(x_notification_id) ,sqlcode);
           END IF;

           return;
       end if;


     ELSE

     -- Find the Notification generated for the given Item Key
     -- Compare the User Id with the Workflow Invoker's User Id
        x_sup_user_id := wf_engine.GetItemAttrNumber (itemtype => l_item_type,
                                                      itemkey  => l_item_key,
                                                      aname    => 'SUPPLIER_USER_ID');

     if (x_sup_user_id = p_supplier_user_id) then
      -- get the signature notification for the item key
      x_notification_id := getSigNotifId(l_item_type, l_item_key);
      if (x_notification_id is null) then
        RAISE sig_notif_notfound;
      end if;
      return;
     else
      -- If the Notification was not generated for the same user the
      -- Abort the previous process and start a new one
        BEGIN
         PO_SIGNATURE_GRP.Abort_Doc_Sign_Process(
                          p_api_version   => 1.0,
			  p_init_msg_list => FND_API.G_FALSE,
			  p_itemkey       => l_item_key,
			  x_result        => x_result,
			  x_return_status => l_ret_status,
			  x_msg_count     => l_msg_count,
			  x_msg_data      => l_msg_data );

        END;
        -- Generate new Item Key
        BEGIN

         PO_SIGNATURE_GRP.Get_Item_Key(
                          p_api_version => 1.0,
			  p_init_msg_list => FND_API.G_FALSE,
                          p_po_header_id  => p_po_header_id,
                          p_revision_num  => p_revision_num ,
                          p_document_type => l_document_type ,
                          x_itemkey       => l_item_key,
			  x_result        => x_result,
			  x_return_status => l_ret_status,
			  x_msg_count     => l_msg_count,
			  x_msg_data      => l_msg_data );
        END;

      -- Start Signature Workflow and pass the Newly generated Item Key
      -- Create a Workflow Process

         x_return_status := startSignatureWF (
         l_item_type,
         l_item_key ,
  	 p_po_header_id ,
  	 p_revision_num ,
         l_document_type,
         p_document_subtype,
         p_document_number,
         p_org_id ,
         p_Agent_Id ,
         p_supplier_user_id ) ;

         if (x_return_status = 'S') then
           x_notification_id := getSigNotifId(l_item_type, l_item_key);
          if (x_notification_id is null) then
            RAISE sig_notif_notfound;
          end if;

          return;
         end if;

     end if;
    END IF;

 EXCEPTION
    WHEN FND_API.g_exc_error THEN
         x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
         x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN sig_notif_notfound THEN
        IF g_fnd_debug = 'Y' THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
            FND_LOG.string(FND_LOG.level_unexpected, l_api_name ||
                       l_item_key || '.Notification not found exception' ,sqlcode);
          END IF;
        END IF;
         x_return_status := FND_API.g_ret_sts_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
               IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                 FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others exception' ,sqlcode);
               END IF;
	        END IF;
        END IF;
 END process_supplier_signature;

 function   create_pos_change_rec (
	p_Action_Type			    IN    VARCHAR2, --(30),
	p_Initiator			    IN    VARCHAR2, --(30),
	p_Document_Type			IN    VARCHAR2, --(30),
	p_Request_Level			IN    VARCHAR2, --(30),
	p_Request_Status			IN    VARCHAR2, --(30),
	p_Document_Header_Id		IN    NUMBER,
        p_Request_Reason          IN    VARCHAR2  default null, --(2000),
	p_PO_Release_Id			IN    NUMBER  default null,
	p_Document_Num			IN    VARCHAR2  default null, --(20),
	p_Document_Revision_Num	IN    NUMBER  default null,
	p_Document_Line_Id		IN    NUMBER  default null,
	p_Document_Line_Number	IN    NUMBER  default null,
	p_Document_Line_Location_Id  IN   NUMBER  default null,
	p_Document_Shipment_Number   IN   NUMBER  default null,
        p_Document_Distribution_id   IN   NUMBER  default null,
        p_Document_Distribution_Number IN NUMBER  default null,
	p_Parent_Line_Location_Id	  IN  NUMBER  default null,
	p_Old_Quantity            IN    NUMBER  default null,
	p_New_Quantity            IN    NUMBER  default null,
	p_Old_Promised_Date		IN    DATE  default null,
	p_New_Promised_Date		IN    DATE  default null,
	p_Old_Supplier_Part_Number IN   VARCHAR2  default null, --(25),
	p_New_Supplier_Part_Number IN   VARCHAR2  default null, --(25),
	p_Old_Price			    IN    NUMBER  default null,
	p_New_Price			    IN    NUMBER  default null,
	p_Old_Supplier_Reference_Num IN  VARCHAR2  default null, --(30),
	p_New_Supplier_Reference_Num IN  VARCHAR2  default null, --(30),
	p_From_Header_id			IN    NUMBER  default null,
	p_Recoverable_Tax			IN    NUMBER  default null,
	p_Non_recoverable_tax		IN    NUMBER  default null,
	p_Ship_To_Location_id		IN    NUMBER  default null,
	p_Ship_To_Organization_Id	IN    NUMBER  default null,
	p_Old_Need_By_Date		IN    DATE  default null,
	p_New_Need_By_Date		IN    DATE  default null,
	p_Approval_Required_Flag	IN    VARCHAR2  default null, --(1),
	p_Parent_Change_request_Id  IN  NUMBER  default null,
        p_Requester_id			IN    NUMBER  default null,
        p_Old_Supplier_Order_Number IN  VARCHAR2  default null, --(25),
        p_New_Supplier_Order_Number IN  VARCHAR2  default null, --(25),
        p_Old_Supplier_Order_Line_Num IN  VARCHAR2  default null, --(25),
        p_New_Supplier_Order_Line_Num IN  VARCHAR2  default null  , --(25),
        p_Additional_changes             IN  VARCHAR2  default null, --(2000),
        p_old_Start_date                 IN  DATE   default null,
        p_new_Start_date                 IN  DATE   default null,
        p_old_Expiration_date            IN  DATE   default null,
        p_new_Expiration_date            IN  DATE   default null,
        p_old_Amount                     IN  NUMBER  default null,
        p_new_Amount                     IN  NUMBER  default null,
        p_SUPPLIER_DOC_REF               IN  varchar2  default null, --(256),
	p_SUPPLIER_LINE_REF              IN  varchar2  default null, --(256),
        p_SUPPLIER_SHIPMENT_REF          IN  varchar2   default null, --(256)
         --<< Complex work changes for R12 >>
        p_NEW_PROGRESS_TYPE              IN  varchar2   default null,
        p_NEW_PAY_DESCRIPTION            IN  varchar2   default null

 ) return pos_chg_rec
 is

begin
  return pos_chg_rec(
            Action_Type => p_Action_Type,
            Initiator => p_Initiator,
            Request_Reason => p_Request_Reason,
            Document_Type => p_Document_Type,
            Request_Level => p_Request_Level,
            Request_Status => p_Request_Status,
            Document_Header_Id =>  p_Document_Header_Id,
            PO_Release_Id => p_PO_Release_Id,
            Document_Num => p_Document_Num,
            Document_Revision_Num => p_Document_Revision_Num,
            Document_Line_Id => p_Document_Line_Id,
            Document_Line_Number => p_Document_Line_Number,
            Document_Line_Location_Id => p_Document_Line_Location_Id,
            Document_Shipment_Number => p_Document_Shipment_Number,
            Document_Distribution_id => p_Document_Distribution_id,
            Document_Distribution_Number => p_Document_Distribution_Number,
            Parent_Line_Location_Id => p_Parent_Line_Location_Id,
            Old_Quantity => p_Old_Quantity,
            New_Quantity => p_New_Quantity,
            Old_Promised_Date => p_Old_Promised_Date,
            New_Promised_Date => p_New_Promised_Date,
            Old_Supplier_Part_Number => p_Old_Supplier_Part_Number,
            New_Supplier_Part_Number => p_New_Supplier_Part_Number,
            Old_Price => p_Old_Price,
            New_Price => p_New_Price,
            Old_Supplier_Reference_Number => p_Old_Supplier_Reference_Num,
            New_Supplier_Reference_Number => p_New_Supplier_Reference_Num,
            From_Header_id => p_From_Header_id,
            Recoverable_Tax => p_Recoverable_Tax,
            Non_recoverable_tax => p_Non_recoverable_tax,
            Ship_To_Location_id => p_Ship_To_Location_id,
            Ship_To_Organization_Id => p_Ship_To_Organization_Id,
            Old_Need_By_Date => p_Old_Need_By_Date,
            New_Need_By_Date => p_New_Need_By_Date,
            Approval_Required_Flag => p_Approval_Required_Flag,
            Parent_Change_request_Id => p_Parent_Change_request_Id,
            Requester_id => p_Requester_id,
            Old_Supplier_Order_Number => p_Old_Supplier_Order_Number,
            New_Supplier_Order_Number => p_New_Supplier_Order_Number,
            Old_Supplier_Order_Line_Number => p_Old_Supplier_Order_Line_Num,
            New_Supplier_Order_Line_Number => p_New_Supplier_Order_Line_Num,
            Additional_changes => p_Additional_changes,
            old_Start_date => p_old_Start_date,
            new_Start_date => p_new_Start_date,
            old_Expiration_date => p_old_Expiration_date,
            new_Expiration_date => p_new_Expiration_date,
            old_Amount => p_old_Amount,
            new_Amount => p_new_Amount,
            SUPPLIER_DOC_REF => p_SUPPLIER_DOC_REF,
     	    SUPPLIER_LINE_REF => p_SUPPLIER_LINE_REF,
            SUPPLIER_SHIPMENT_REF => p_SUPPLIER_SHIPMENT_REF ,
             --<< Complex work changes for R12 >>
            NEW_PROGRESS_TYPE    =>p_NEW_PROGRESS_TYPE,
            NEW_PAY_DESCRIPTION  =>p_NEW_PAY_DESCRIPTION


      );

 end;

 /*
 *  Function to get maximum shipment number for a given po_line_id
 */
 function getMaxShipmentNum (
	p_po_line_id IN NUMBER)
	return NUMBER IS

 v_ship_num NUMBER;
 v_progress	varchar2(3);

 BEGIN

 v_progress := '111';

 select max(shipment_num)
 into v_ship_num
 from po_line_locations_All
 where po_line_id = p_po_line_id
 group by po_line_id;

 RETURN v_ship_num;

 EXCEPTION
  WHEN others THEN
  PO_MESSAGE_S.SQL_ERROR(
    'PO_CHG_REQUEST_PVT.getMaxShipmentNum',
     v_progress,
     sqlcode );

 RETURN -1;

 END;

 function getLastUpdateDate (
 	p_header_id IN NUMBER,
 	p_release_id in NUMBER)
	return DATE IS

 p_last_update_date DATE;
 v_progress	varchar2(3);

 BEGIN

 v_progress := '113';

 if (p_header_id is null) then

 select last_update_Date
 into p_last_update_date
 from po_releases_All where
 po_release_id = p_release_id
 and rownum=1;

 else

 select last_update_Date
 into p_last_update_date
 from po_headers_All
 where po_header_id = p_header_id
 and rownum=1;

 end if;

 return p_last_update_Date;

 EXCEPTION
  WHEN others THEN
  PO_MESSAGE_S.SQL_ERROR(
    'PO_CHG_REQUEST_PVT.getLastUpdateDate',
     v_progress,
     sqlcode );

 return null;

 END;

 /*Added release_id as part of fix for bug 12903291 */
procedure validate_shipment_cancel (
             p_po_header_id           IN  number,
             p_po_release_id          IN  number,
             p_po_change_requests     IN  pos_chg_rec_tbl,
             x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
	     x_ret_sts		      OUT NOCOPY varchar2
             ) IS

l_po_change_requests    pos_chg_rec_tbl := NULL;
l_count_asn             NUMBER;
l_err_msg_name_tbl     po_tbl_varchar30;
l_err_msg_text_tbl     po_tbl_varchar2000;
l_err_count             NUMBER;

BEGIN
l_err_count := 0;
l_po_change_requests := p_po_change_requests ;
l_err_msg_name_tbl := po_tbl_varchar30();
l_err_msg_text_tbl := po_tbl_varchar2000();
x_pos_errors   := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);
x_ret_sts := 'N';
FOR j in 1..l_po_change_requests.count()
 LOOP
 if ( l_po_change_requests(j).action_type in ('CANCELLATION')) then --AND
 --       l_po_change_requests(j).request_level='SHIPMENT' ) then
  IF(p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL) THEN
    select count(*)
    into l_count_asn
    from RCV_TRANSACTIONS_INTERFACE rti
    where rti.TRANSACTION_TYPE = 'SHIP' and
          rti.PROCESSING_STATUS_CODE = 'PENDING' and
          rti.quantity > 0 and
          rti.PO_HEADER_ID = p_po_header_id and
          rti.po_release_id (+) = p_po_release_id and
          (rti.po_line_location_id = l_po_change_requests(j).document_line_location_id OR  l_po_change_requests(j).document_line_location_id is null);
  ELSE
    select count(*)
    into l_count_asn
    from RCV_TRANSACTIONS_INTERFACE rti
    where rti.TRANSACTION_TYPE = 'SHIP' and
          rti.PROCESSING_STATUS_CODE = 'PENDING' and
          rti.quantity > 0 and
          rti.PO_HEADER_ID = p_po_header_id AND
          (rti.po_line_location_id = l_po_change_requests(j).document_line_location_id OR  l_po_change_requests(j).document_line_location_id is null);
  END IF;

  IF(l_count_asn > 0) then
         l_err_count := l_err_count + 1;
         x_pos_errors.message_name.extend;
         x_pos_errors.text_line.extend;
         x_pos_errors.message_name(l_err_count) := null;
         if l_po_change_requests(j).document_line_location_id is not null then
           FND_MESSAGE.set_name('POS','POS_CAN_PO_LS_UNPRC_TX');
           fnd_message.set_token('LINE', l_po_change_requests(j).Document_Line_Number);
           fnd_message.set_token('SHIPMENT', l_po_change_requests(j).Document_Shipment_Number);
           x_pos_errors.text_line(l_err_count) := fnd_message.get;
         else
           x_pos_errors.text_line(l_err_count) := fnd_message.get_String('POS', 'POS_CAN_PO_UNPRC_TX');
          return;
         END IF;
  END IF;

  IF(p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL) THEN
	SELECT count(*)
    into l_count_asn
    FROM RCV_SHIPMENT_LINES RSL
    WHERE RSL.po_header_id = p_po_header_id
    AND RSL.po_release_id (+) = p_po_release_id
    AND (RSL.po_line_location_id = l_po_change_requests(j).document_line_location_id OR l_po_change_requests(j).document_line_location_id is null)
    AND NVL(RSL.quantity_shipped,0) > NVL(RSL.quantity_received,0)
    AND NVL(RSL.ASN_LINE_FLAG,'N') = 'Y'
    AND NVL(RSL.SHIPMENT_LINE_STATUS_CODE,'EXPECTED') <> 'CANCELLED';
  ELSE
    SELECT count(*)
    into l_count_asn
    FROM RCV_SHIPMENT_LINES RSL
    WHERE RSL.po_header_id = p_po_header_id
    AND (RSL.po_line_location_id = l_po_change_requests(j).document_line_location_id OR l_po_change_requests(j).document_line_location_id is null)
    AND NVL(RSL.quantity_shipped,0) > NVL(RSL.quantity_received,0)
    AND NVL(RSL.ASN_LINE_FLAG,'N') = 'Y'
    AND NVL(RSL.SHIPMENT_LINE_STATUS_CODE,'EXPECTED') <> 'CANCELLED';
  END IF;

  IF(l_count_asn > 0) then
         l_err_count := l_err_count + 1;
         x_pos_errors.message_name.extend;
         x_pos_errors.text_line.extend;
         x_pos_errors.message_name(l_err_count) := null;
         if l_po_change_requests(j).document_line_location_id is not null then
           FND_MESSAGE.set_name('POS','POS_CAN_PO_LS_OPEN_ASN');
           fnd_message.set_token('LINE', l_po_change_requests(j).Document_Line_Number);
           fnd_message.set_token('SHIPMENT', l_po_change_requests(j).Document_Shipment_Number);
           x_pos_errors.text_line(l_err_count) := fnd_message.get;
         else
           x_pos_errors.text_line(l_err_count) := fnd_message.get_String('POS', 'POS_CAN_PO_OPEN_ASN') ;
           return;
         END IF;
  END IF;
   END IF;
   END LOOP;
   if(l_err_count < 1) then
   validate_ship_inv_cancel (
       p_po_header_id,
       p_po_change_requests,
       x_pos_errors,
       x_ret_sts);
   else
       x_ret_sts := 'Y';
   end if;

END validate_shipment_cancel;

procedure validate_ship_inv_cancel (
              p_po_header_id           IN  number,
              p_po_change_requests     IN  pos_chg_rec_tbl,
              x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
              x_ret_sts		       OUT NOCOPY varchar2
              ) IS

 l_po_change_requests    pos_chg_rec_tbl := NULL;
 l_count_asn             NUMBER;
 l_err_msg_name_tbl     po_tbl_varchar30;
 l_err_msg_text_tbl     po_tbl_varchar2000;
 l_err_count             NUMBER;
 l_quan_ordered          NUMBER;
 l_quan_recd             NUMBER;
 l_quan_billed           NUMBER;
 BEGIN
 l_err_count := 0;
 l_po_change_requests := p_po_change_requests ;
 l_err_msg_name_tbl := po_tbl_varchar30();
 l_err_msg_text_tbl := po_tbl_varchar2000();
 x_pos_errors   := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);
 FOR j in 1..l_po_change_requests.count()
    LOOP
     if ( l_po_change_requests(j).action_type in ('CANCELLATION') AND
        l_po_change_requests(j).request_level='SHIPMENT' ) then
     l_quan_ordered := -1;
     l_quan_recd := -1;
     l_quan_billed := -1;
     begin
     SELECT nvl(POLL.quantity, 0), nvl(POLL.quantity_billed, 0), nvl(POLL.quantity_received, 0)
     into l_quan_ordered, l_quan_billed, l_quan_recd
     FROM PO_LINE_LOCATIONS_ALL POLL, PO_LINES_ALL POL
     WHERE POLL.line_location_id = l_po_change_requests(j).document_line_location_id
     AND   POLL.po_line_id = POL.po_line_id
     AND   nvl(POLL.cancel_flag, 'N') = 'N'
     AND   nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
     AND   nvl(POLL.receipt_required_flag, 'Y') <> 'N'
     AND   nvl(POLL.quantity_billed, 0) > nvl(POLL.quantity_received,0);
     EXCEPTION
      WHEN OTHERS THEN
      l_quan_ordered := -1;
     END;

 if (l_quan_ordered > -1 ) then
       l_err_count := l_err_count + 1;
       x_pos_errors.message_name.extend;
       x_pos_errors.text_line.extend;
       x_pos_errors.message_name(l_err_count) := null;
       FND_MESSAGE.set_name('POS','POS_CAN_PO_QTY_BILL_RCV');
       fnd_message.set_token('LINE', l_po_change_requests(j).Document_Line_Number);
       fnd_message.set_token('SHIPMENT', l_po_change_requests(j).Document_Shipment_Number);
       fnd_message.set_token('QTY_BILL', l_quan_billed) ;
       fnd_message.set_token('QTY_RCV', l_quan_recd) ;
       x_pos_errors.text_line(l_err_count) := fnd_message.get;
    end if;

   l_quan_ordered := -1;
   l_quan_recd := -1;
   l_quan_billed := -1;
   begin
   SELECT nvl(POLL.quantity, 0), nvl(POLL.quantity_billed, 0), nvl(POLL.quantity_received, 0)
   into l_quan_ordered, l_quan_billed, l_quan_recd
   FROM PO_LINE_LOCATIONS_ALL POLL, PO_LINES_ALL POL
   WHERE POLL.line_location_id =  l_po_change_requests(j).document_line_location_id
   AND   POLL.po_line_id = POL.po_line_id
   AND   nvl(POLL.cancel_flag, 'N') = 'N'
   AND   nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
   AND   nvl(POLL.receipt_required_flag, 'Y') <> 'N'
   AND   nvl(POLL.quantity_billed, 0) > nvl(POLL.quantity,0);
   EXCEPTION
     WHEN OTHERS THEN
      l_quan_ordered := -1;
   END;
    if (l_quan_ordered > -1 ) then
       l_err_count := l_err_count + 1;
       x_pos_errors.message_name.extend;
       x_pos_errors.text_line.extend;
       x_pos_errors.message_name(l_err_count) := null;
       FND_MESSAGE.set_name('POS','POS_CAN_PO_QTY_BILL_ORD');
       fnd_message.set_token('LINE', l_po_change_requests(j).Document_Line_Number);
       fnd_message.set_token('SHIPMENT', l_po_change_requests(j).Document_Shipment_Number);
       fnd_message.set_token('QTY_BILL', l_quan_billed) ;
       fnd_message.set_token('QTY_ORD', l_quan_ordered) ;
       x_pos_errors.text_line(l_err_count) := fnd_message.get;
    end if;
   END IF;
   END LOOP;
   if(l_err_count < 1) then
   x_ret_sts := 'N';
   else
   x_ret_sts := 'Y';
   end if ;

END validate_ship_inv_cancel;

procedure validate_shipment_split (
             p_po_header_id           IN  number,
             p_po_release_id          IN  number,
             p_po_line_location_id    IN  number,
             x_pos_errors             OUT NOCOPY POS_ERR_TYPE,
	     x_ret_sts		      OUT NOCOPY varchar2
             ) IS

l_count_asn             NUMBER;
l_qty_intf  NUMBER :=0;
l_qty_shipd NUMBER :=0;
l_qty_ordered NUMBER;
l_total_rcv NUMBER;
l_err_msg_name_tbl     po_tbl_varchar30;
l_err_msg_text_tbl     po_tbl_varchar2000;
l_err_count             NUMBER;
l_api_name              CONSTANT VARCHAR2(30) := 'validate_shipment_split';

CURSOR  intf_qty_rel_cur(po_header_id NUMBER, po_release_id NUMBER , line_loc_id NUMBER)
IS
 select rti.quantity
    from RCV_TRANSACTIONS_INTERFACE rti
    where rti.PROCESSING_STATUS_CODE = 'PENDING' and
          rti.quantity > 0 and
          rti.PO_HEADER_ID = po_header_id and
          rti.po_release_id (+) = po_release_id and
          rti.po_line_location_id = line_loc_id ;

CURSOR intf_qty_cur (po_header_id NUMBER , line_loc_id NUMBER) IS
SELECT rti.quantity
    from RCV_TRANSACTIONS_INTERFACE rti
    where rti.PROCESSING_STATUS_CODE = 'PENDING' and
          rti.quantity > 0 and
          rti.PO_HEADER_ID = po_header_id AND
          rti.po_line_location_id = line_loc_id;

CURSOR  shipd_qty_rel_cur(po_header_id NUMBER, po_release_id NUMBER, line_loc_id NUMBER) IS
	SELECT RSL.quantity_shipped
    FROM RCV_SHIPMENT_LINES RSL
    WHERE RSL.po_header_id = po_header_id
    AND RSL.po_release_id (+) = po_release_id
    AND RSL.po_line_location_id = line_loc_id
    AND NVL(RSL.quantity_shipped,0) > NVL(RSL.quantity_received,0)
    AND NVL(RSL.ASN_LINE_FLAG,'N') = 'Y'
    AND NVL(RSL.SHIPMENT_LINE_STATUS_CODE,'EXPECTED') <> 'CANCELLED';


CURSOR shipd_qty_cur(po_header_id NUMBER, line_loc_id NUMBER) IS
SELECT RSL.quantity_shipped
    FROM RCV_SHIPMENT_LINES RSL
    WHERE RSL.po_header_id = po_header_id
    AND RSL.po_line_location_id = line_loc_id
    AND NVL(RSL.quantity_shipped,0) > NVL(RSL.quantity_received,0)
    AND NVL(RSL.ASN_LINE_FLAG,'N') = 'Y'
    AND NVL(RSL.SHIPMENT_LINE_STATUS_CODE,'EXPECTED') <> 'CANCELLED';




BEGIN
l_err_count := 0;
l_err_msg_name_tbl := po_tbl_varchar30();
l_err_msg_text_tbl := po_tbl_varchar2000();
x_pos_errors   := POS_ERR_TYPE( l_err_msg_name_tbl,l_err_msg_text_tbl);
x_ret_sts := '';

  IF(p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL AND p_po_line_location_id IS NOT NULL ) THEN
   FOR intf_qty_rel_rec IN intf_qty_rel_cur( p_po_header_id,p_po_release_id,p_po_line_location_id) LOOP
      l_qty_intf := l_qty_intf + intf_qty_rel_rec.quantity;
      END LOOP;
  ELSE
   FOR intf_qty_rec IN intf_qty_cur( p_po_header_id,p_po_line_location_id) LOOP
      l_qty_intf := l_qty_intf + intf_qty_rec.quantity;
      END LOOP;

  END IF;


  IF( p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL ) THEN
   FOR shipd_qty_rel_rec IN shipd_qty_rel_cur(p_po_header_id,p_po_release_id,p_po_line_location_id) LOOP
    l_qty_shipd :=  l_qty_shipd + shipd_qty_rel_rec.quantity_shipped ;
   END LOOP;
  ELSE
   FOR shipd_qty_rec IN shipd_qty_cur(p_po_header_id,p_po_line_location_id) LOOP
    l_qty_shipd :=  l_qty_shipd + shipd_qty_rec.quantity_shipped ;
   END LOOP;
  END IF;

  IF(l_qty_intf > 0) OR (l_qty_shipd >0) THEN


     IF(p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL)  THEN

     BEGIN
     SELECT  QUANTITY,
     (NVL(QUANTITY_RECEIVED, 0)+NVL(QUANTITY_CANCELLED, 0))
     INTO l_qty_ordered,l_total_rcv
     FROM po_line_locations_all
     WHERE po_header_id=  p_po_header_id
     AND  PO_RELEASE_ID = p_po_release_id
     AND  line_location_id=p_po_line_location_id;
     EXCEPTION WHEN OTHERS
     THEN
      l_qty_ordered:=0;
      l_total_rcv:=0;
      END;

     ELSE
     BEGIN
      SELECT  QUANTITY,
     (NVL(QUANTITY_RECEIVED, 0)+NVL(QUANTITY_CANCELLED, 0))
     INTO l_qty_ordered,l_total_rcv
     FROM po_line_locations_all
     WHERE po_header_id=  p_po_header_id
     AND  line_location_id=p_po_line_location_id;
     EXCEPTION WHEN OTHERS THEN
      l_qty_ordered:=0;
      l_total_rcv:=0;
      END;

     END IF;


     IF(l_qty_ordered <= (l_total_rcv+Nvl(l_qty_intf,0)+Nvl(l_qty_shipd,0))) THEN
         l_err_count := l_err_count + 1;
         x_pos_errors.message_name.extend;
         x_pos_errors.text_line.extend;
         x_pos_errors.message_name(l_err_count) := null;
         FND_MESSAGE.set_name('POS','POS_SPLIT_ASN_FULLQTY');
         x_pos_errors.text_line(l_err_count) := fnd_message.get;
         return;
     END IF;

   END IF;

x_ret_sts :='S';

EXCEPTION
 WHEN OTHERS THEN
  x_ret_sts := FND_API.g_ret_sts_unexp_error;
    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
            FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
             l_api_name || '.others_exception', 'Exception');
        END IF;
    END IF;

end validate_shipment_split;



/*Added for bug#14155598*/
PROCEDURE IS_ASN_EXIST(p_po_header_id       IN NUMBER,
                       p_po_release_id      IN NUMBER,
                       p_po_change_requests IN POS_CHG_REC_TBL,
                       x_pos_errors         OUT nocopy POS_ERR_TYPE,
                       x_ret_sts            OUT nocopy VARCHAR2)
IS
  l_po_change_requests POS_CHG_REC_TBL := NULL;
  l_count_asn          NUMBER;
  l_Qty_Shpd NUMBER;
  l_qty_intf NUMBER;
  l_err_msg_name_tbl   PO_TBL_VARCHAR30;
  l_err_msg_text_tbl   PO_TBL_VARCHAR2000;
  l_err_count          NUMBER;
  l_api_name           VARCHAR2(100) := 'IS_ASN_EXIST';
  CURSOR ship_cur(
    p_po_line_id NUMBER) IS
    SELECT line_location_id,shipment_num
    FROM   po_line_locations_all
    WHERE  po_line_id = p_po_line_id;

  CURSOR intf_qty_rel_cur(po_header_id NUMBER,po_release_id NUMBER, line_loc_id NUMBER)  IS
  SELECT rti.quantity
            FROM   rcv_transactions_interface rti
            WHERE  rti.processing_status_code = 'PENDING'
                   AND rti.quantity > 0
                   AND rti.po_header_id = po_header_id
                   AND rti.po_release_id (+) = po_release_id
                   AND  rti.po_line_location_id =line_loc_id;


  CURSOR intf_qty_cur(po_header_id NUMBER, line_loc_id NUMBER ) IS
  SELECT rti.quantity
            FROM   rcv_transactions_interface rti
            WHERE  rti.processing_status_code = 'PENDING'
                   AND rti.quantity > 0
                   AND rti.po_header_id = po_header_id
                   AND rti.po_line_location_id = line_loc_id;
                   --l_po_change_requests(j).document_line_location_id;

  CURSOR shipd_qty_rel_cur(po_header_id NUMBER, po_release_id NUMBER, line_loc_id NUMBER) IS
  SELECT RSL.quantity_shipped
            INTO   l_Qty_Shpd
            FROM   rcv_shipment_lines RSL
            WHERE  RSL.po_header_id = po_header_id
                   AND RSL.po_release_id (+) = po_release_id
                   AND RSL.po_line_location_id = line_loc_id
                   --l_po_change_requests(j).document_line_location_id
                   AND Nvl(RSL.quantity_shipped, 0) > Nvl(RSL.quantity_received, 0)
                   AND Nvl(RSL.asn_line_flag, 'N') = 'Y'
                   AND Nvl(RSL.shipment_line_status_code, 'EXPECTED') <>'CANCELLED';

  CURSOR shipd_qty_cur( po_header_id NUMBER, line_loc_id NUMBER) IS
     SELECT RSL.quantity_shipped
            INTO   l_Qty_Shpd
            FROM   rcv_shipment_lines RSL
            WHERE  RSL.po_header_id = po_header_id
                   AND RSL.po_line_location_id =line_loc_id
                   AND Nvl(RSL.quantity_shipped, 0) > Nvl(RSL.quantity_received, 0)
                   AND Nvl(RSL.asn_line_flag, 'N') = 'Y'
                   AND Nvl(RSL.shipment_line_status_code, 'EXPECTED') <>'CANCELLED';






BEGIN
    l_err_count := 0;
    l_po_change_requests := p_po_change_requests;
    l_err_msg_name_tbl := Po_tbl_varchar30();
    l_err_msg_text_tbl := Po_tbl_varchar2000();
    x_pos_errors := Pos_err_type(l_err_msg_name_tbl, l_err_msg_text_tbl);
    x_ret_sts := 'N';

    IF g_fnd_debug = 'Y' THEN
      IF ( fnd_log.g_current_runtime_level <= fnd_log.level_procedure ) THEN
        fnd_log.String(fnd_log.level_procedure, g_module_prefix|| l_api_name|| '.invoked', 'Type: '
                                                               || 'entered procedure'
                                                               ||l_api_name
                                                               ||', Header  ID: '
                                                               ||Nvl(To_char(p_po_header_id), 'null')
                                                               ||', Release ID: '
                                                               ||Nvl(To_char(p_po_release_id), 'null'));
      END IF;
    END IF;

    FOR j IN 1..l_po_change_requests.Count() LOOP
        IF( l_po_change_requests(j).request_level = 'SHIPMENT' AND l_po_change_requests(j).action_type = 'MODIFICATION' ) THEN

            l_qty_intf:=0;
            IF( p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL ) THEN
             FOR intf_qty_rel_rec IN intf_qty_rel_cur(p_po_header_id,p_po_release_id,l_po_change_requests(j).document_line_location_id)  LOOP
               l_qty_intf :=  l_qty_intf + intf_qty_rel_rec.quantity ;
             END LOOP;

            ELSE
              FOR intf_qty_rec IN intf_qty_cur(p_po_header_id,l_po_change_requests(j).document_line_location_id) LOOP
               l_qty_intf :=  l_qty_intf + intf_qty_rec.quantity ;
              END LOOP;

            END IF;

             IF g_fnd_debug = 'Y' THEN
                IF ( fnd_log.g_current_runtime_level <= fnd_log.level_procedure ) THEN
                 fnd_log.String(fnd_log.level_procedure, g_module_prefix|| l_api_name|| '.invoked', 'Type: '
                                                            || 'entered procedure'
                                                            ||l_api_name
                                                            || 'po_line_loc_id:'
                                                            || Nvl(To_Char(l_po_change_requests(j).document_line_location_id),'null')
                                                            ||',l_qty_intf: '
                                                            ||Nvl(To_char(l_qty_intf), 'null')
                                                             );
                 END IF;
              END IF;

             l_Qty_Shpd:=0;
             IF( p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL ) THEN
               FOR shipd_qty_rel_rec IN shipd_qty_rel_cur(p_po_header_id,p_po_release_id,l_po_change_requests(j).document_line_location_id) LOOP
                 l_Qty_Shpd :=  l_Qty_Shpd + shipd_qty_rel_rec.quantity_shipped ;
               END LOOP;
             ELSE
               FOR shipd_qty_rec IN shipd_qty_cur(p_po_header_id,l_po_change_requests(j).document_line_location_id) LOOP
                l_Qty_Shpd :=  l_Qty_Shpd + shipd_qty_rec.quantity_shipped ;
               END LOOP;
             END IF;

            IF g_fnd_debug = 'Y' THEN
              IF ( fnd_log.g_current_runtime_level <= fnd_log.level_procedure ) THEN
                 fnd_log.String(fnd_log.level_procedure, g_module_prefix|| l_api_name|| '.invoked', 'Type: '
                                                               || 'entered procedure'
                                                               ||l_api_name
                                                               ||',l_Qty_Shpd: '
                                                               ||Nvl(To_char(l_Qty_Shpd), 'null')
                                                                    );
               END IF;
            END IF;

            IF g_fnd_debug = 'Y' THEN
               IF ( fnd_log.g_current_runtime_level <= fnd_log.level_procedure ) THEN
                  fnd_log.String(fnd_log.level_procedure, g_module_prefix|| l_api_name|| '.invoked', 'Type: '
                                                               || 'entered procedure'
                                                               ||l_api_name
                                                               ||',l_po_change_requests(j).new_quantity: '
                                                               ||Nvl(To_char(l_po_change_requests(j).new_quantity), 'null')
                                                               );
                END IF;
            END IF;

         IF( l_qty_intf > 0 ) OR (l_Qty_Shpd > 0) THEN

            IF(l_po_change_requests(j).new_quantity < (Nvl(l_qty_intf,0)+Nvl(l_Qty_Shpd,0) )) THEN
            l_err_count := l_err_count + 1;
            x_pos_errors.message_name.extend;
            x_pos_errors.text_line.extend;
            x_pos_errors.Message_name(l_err_count) := NULL;
            IF L_po_change_requests(j).document_line_location_id IS NOT NULL
            THEN
              fnd_message.Set_name('POS', 'POS_SPLIT_ASN_PENDING');
              fnd_message.Set_token('QTY',(Nvl(l_qty_intf,0)+Nvl(l_Qty_Shpd,0) ));
              fnd_message.Set_token('QTY',(Nvl(l_qty_intf,0)+Nvl(l_Qty_Shpd,0) ));
              fnd_message.Set_token('LINE',l_po_change_requests(j).document_line_number);
              fnd_message.Set_token('SHIPMENT',l_po_change_requests(j).document_shipment_number);
			        x_pos_errors.Text_line(l_err_count) := fnd_message.get;
            END IF;
          END IF;
         END IF;

        END IF;



        IF ( l_po_change_requests(j).request_level = 'LINE' AND l_po_change_requests(j).action_type = 'MODIFICATION' ) THEN
          FOR ship_rec IN ship_cur(l_po_change_requests(j).document_line_id)
          LOOP
              IF( p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL ) THEN
                SELECT Count(*)
                INTO   l_count_asn
                FROM   rcv_transactions_interface rti
                WHERE  rti.processing_status_code = 'PENDING'
                       AND rti.quantity > 0
                       AND rti.po_header_id = p_po_header_id
                       AND rti.po_release_id (+) = p_po_release_id
                       AND rti.po_line_location_id = ship_rec.line_location_id;
              ELSE
                SELECT Count(*)
                INTO   l_count_asn
                FROM   rcv_transactions_interface rti
                WHERE  rti.processing_status_code = 'PENDING'
                       AND rti.quantity > 0
                       AND rti.po_header_id = p_po_header_id
                       AND rti.po_line_location_id = ship_rec.line_location_id;
              END IF;

              IF( l_count_asn > 0 ) THEN
                l_err_count := l_err_count + 1;
                x_pos_errors.message_name.extend;
                x_pos_errors.text_line.extend;
                x_pos_errors.Message_name(l_err_count) := NULL;

                IF l_po_change_requests(j).document_line_id IS NOT NULL
                THEN
                  fnd_message.Set_name('POS', 'POS_CHG_LINE_UNPRC_TRX');
                  fnd_message.Set_token('LINE',l_po_change_requests(j).document_line_number);
                  fnd_message.Set_token('SHIPMENT',ship_rec.shipment_num);
                  x_pos_errors.Text_line(l_err_count) := fnd_message.get;
                END IF;
              END IF;

              IF( p_po_header_id IS NOT NULL AND p_po_release_id IS NOT NULL ) THEN
                SELECT Count(*)
                INTO   l_count_asn
                FROM   rcv_shipment_lines RSL
                WHERE  RSL.po_header_id = p_po_header_id
                       AND RSL.po_release_id (+) = p_po_release_id
                       AND RSL.po_line_location_id = ship_rec.line_location_id
                       AND Nvl(RSL.quantity_shipped, 0) > Nvl(RSL.quantity_received, 0)
                       AND Nvl(RSL.asn_line_flag, 'N') = 'Y'
                       AND Nvl(RSL.shipment_line_status_code, 'EXPECTED') <>'CANCELLED';
              ELSE
                SELECT Count(*)
                INTO   l_count_asn
                FROM   rcv_shipment_lines RSL
                WHERE  RSL.po_header_id = p_po_header_id
                       AND RSL.po_line_location_id = ship_rec.line_location_id
                       AND Nvl(RSL.quantity_shipped, 0) > Nvl(RSL.quantity_received, 0)
                       AND Nvl(RSL.asn_line_flag, 'N') = 'Y'
                       AND Nvl(RSL.shipment_line_status_code, 'EXPECTED') <>'CANCELLED' ;
              END IF;

              IF( l_count_asn > 0 ) THEN
                l_err_count := l_err_count + 1;
                x_pos_errors.message_name.extend;
                x_pos_errors.text_line.extend;
                x_pos_errors.Message_name(l_err_count) := NULL;
                IF l_po_change_requests(j).document_line_id IS NOT NULL
                THEN
                  fnd_message.Set_name('POS', 'POS_CHG_LINE_OPEN_ASN');
                  fnd_message.Set_token('LINE',l_po_change_requests(j).document_line_number);
                  fnd_message.Set_token('SHIPMENT',ship_rec.shipment_num);
                  x_pos_errors.Text_line(l_err_count) := fnd_message.get;
                END IF;
              END IF;
          END LOOP;
        END IF;
    END LOOP;

    IF( l_err_count < 1 ) THEN
      x_ret_sts := 'N';
    ELSE
      x_ret_sts := 'Y';
    END IF;
EXCEPTION
  WHEN OTHERS THEN  RAISE;
             x_ret_sts := 'Y';
             IF fnd_msg_pub.Check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
             THEN
               fnd_msg_pub.Add_exc_msg(g_pkg_name, l_api_name);
               IF g_fnd_debug = 'Y' THEN
                 IF ( fnd_log.g_current_runtime_level <=fnd_log.level_unexpected ) THEN
                   fnd_log.String(fnd_log.level_unexpected, g_module_prefix|| l_api_name||'.others_exception', SQLCODE);
                 END IF;
               END IF;
             END IF;
END IS_ASN_EXIST;



END PO_CHG_REQUEST_PVT;

/
