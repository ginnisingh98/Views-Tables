--------------------------------------------------------
--  DDL for Package Body PO_ACKNOWLEDGE_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ACKNOWLEDGE_PO_PVT" AS
/* $Header: POXVACKB.pls 120.8 2006/09/12 12:25:55 jbalakri noship $ */

  g_pkg_name CONSTANT VARCHAR2(50) := 'PO_ACKNOWLEDGE_PO_PVT';
  g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

  -- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  -- Read the profile option that determines whether the promise date will be defaulted with need-by date or not
  g_default_promise_date VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('POS_DEFAULT_PROMISE_DATE_ACK'),'N');


/**
 * Private function: All_Shipments_Acknowledged
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM
 * Modifies:
 * Effects:  Returns if all the shipments have been acknowledged.
 */
FUNCTION All_Shipments_Acknowledged (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )
RETURN VARCHAR2 IS

  l_ship_not_acked_flag	VARCHAR2(1) := NULL;

  CURSOR l_rel_ship_not_acked_csr IS
      select 'Y'
      From   PO_LINE_LOCATIONS_ALL PLL
      Where  pll.po_release_id = p_po_release_id
      And    not exists (
		select 1
		From   PO_ACCEPTANCES PA
		Where  PA.po_release_id = p_po_release_id
		And    pa.revision_num = p_revision_num
		And    pa.po_line_location_id = PLL.line_location_id )
      And    nvl(pll.cancel_flag, 'N') = 'N'
      And    nvl(pll.payment_type,'NULL') not in ('ADVANCE','DELIVERY')
      And    ((nvl(pll.closed_code, 'OPEN') = 'OPEN' and
               nvl(pll.consigned_flag, 'N') = 'N')  OR
              (pll.closed_code = 'CLOSED FOR INVOICE' and
               pll.consigned_flag = 'Y'));

  CURSOR l_po_ship_not_acked_csr IS
      select 'Y'
      From   PO_LINE_LOCATIONS_ALL PLL
      Where  pll.po_header_id = p_po_header_id
      And    pll.po_release_id is null
      And    not exists (
		select 1
		From   PO_ACCEPTANCES PA
		Where  PA.po_header_id = p_po_header_id
		And    pa.revision_num = p_revision_num
		And    pa.po_line_location_id = PLL.line_location_id )
      And    nvl(pll.cancel_flag, 'N') = 'N'
      And    nvl(pll.payment_type,'NULL') not in ('ADVANCE','DELIVERY')
      And    ((nvl(pll.closed_code, 'OPEN') = 'OPEN' and
               nvl(pll.consigned_flag, 'N') = 'N')  OR
              (pll.closed_code = 'CLOSED FOR INVOICE' and
               pll.consigned_flag = 'Y'));

  l_api_name	CONSTANT VARCHAR2(30) := 'ALL_SHIPMENTS_ACKNOWLEDGED';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  If (p_po_release_id is not null) then
    OPEN l_rel_ship_not_acked_csr;
      LOOP
         FETCH l_rel_ship_not_acked_csr INTO L_ship_not_acked_flag;
         EXIT WHEN l_rel_ship_not_acked_csr%NOTFOUND;
         IF (L_ship_not_acked_flag = 'Y') THEN
            EXIT;
         END IF;
      END LOOP;
    CLOSE l_rel_ship_not_acked_csr;

  ELSIF (p_po_header_id is not null) then
    OPEN l_po_ship_not_acked_csr;
      LOOP
         FETCH l_po_ship_not_acked_csr INTO L_ship_not_acked_flag;
         EXIT WHEN l_po_ship_not_acked_csr%NOTFOUND;
         IF (L_ship_not_acked_flag = 'Y') THEN
            EXIT;
         END IF;
      END LOOP;
    CLOSE l_po_ship_not_acked_csr;

  END IF;

  If (L_ship_not_acked_flag = 'Y') THEN
    return FND_API.G_FALSE;
  ELSE
    return FND_API.G_TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', sqlcode);
      END IF;
    END IF;
    raise;
END All_Shipments_Acknowledged;




/**
 * Private function: Get_Header_Ack_Change_Status
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM
 * Modifies:
 * Effects: Return the acknowledgement status of the entire order,
 *          possible values are:
 *          1. ACK_REQUIRED
 *          2. SUPPLIER_CHANGE_PENDING
 *          3. PARTIALLY_ACKNOWLEDGED
 *          4. ACCEPTED
 *          5. REJECTED
 *          6. ACKNOWLEDGED
 *          7. ''
 *          8. SIG_REQUIRED
 *          9. PENDING_BUYERS_SIGNATURE
 */

FUNCTION Get_Header_Ack_Change_Status (
	p_po_header_id	IN 	NUMBER,
	p_po_release_id	IN	NUMBER,
	p_revision_num	IN	NUMBER )
RETURN VARCHAR2 IS

   l_accepted_flag		VARCHAR2(1) := null;
   l_ship_ack_exist_flag        VARCHAR2(1) := null;
   l_acceptance_required_flag	VARCHAR2(1) := null;
   l_shipment_exist_flag	VARCHAR2(1) := null;
   l_change_requested_by	PO_HEADERS_ALL.change_requested_by%TYPE := null;
   l_sign_flag              	PO_HEADERS_ALL.pending_signature_flag%TYPE := null;
   l_sup_sign_exist_flag    	VARCHAR2(1) := null;
   l_reject_sign_exist_flag 	VARCHAR2(1) := null;
   l_arch_revision_num		NUMBER := p_revision_num;

   CURSOR l_po_ship_ack_exists_csr IS
      select 'Y'
      from   PO_ACCEPTANCES
      where  po_header_id = p_po_header_id
      and    po_release_id is null
      and    revision_num = p_revision_num
      and    po_line_location_id is not null;

   CURSOR l_rel_ship_ack_exists_csr IS
      select 'Y'
      from   PO_ACCEPTANCES
      where  po_header_id is null
      and    po_release_id = p_po_release_id
      and    revision_num = p_revision_num
      and    po_line_location_id is not null;

   CURSOR l_sup_sign_exists_csr IS
      select 'Y'
      from   PO_ACCEPTANCES
      where  po_header_id     =  p_po_header_id
      and    revision_num     =  p_revision_num
      and    po_release_id       is null
      and    po_line_location_id is null
      and    accepting_party  = 'S'
      and    accepted_flag    = 'Y'
      and    signature_flag   = 'Y';

   CURSOR l_reject_sign_exists_csr IS
      select 'Y'
      from   PO_ACCEPTANCES
      where  po_header_id     =  p_po_header_id
      and    revision_num     =  p_revision_num
      and    po_release_id       is null
      and    po_line_location_id is null
      and    accepted_flag    = 'N'
      and    signature_flag   = 'Y';


BEGIN
   /* Release */
   IF (p_po_release_id is not null) THEN
      select nvl(acceptance_required_flag, 'N'),
             nvl(change_requested_by, ' ')
      into   l_acceptance_required_flag,
             l_change_requested_by
      from   PO_RELEASES_ALL
      where  po_release_id = p_po_release_id;

      /* Get if there is any shipment acknowledged. */
      OPEN l_rel_ship_ack_exists_csr;
      LOOP
        FETCH l_rel_ship_ack_exists_csr INTO l_ship_ack_exist_flag;
        EXIT WHEN l_rel_ship_ack_exists_csr%NOTFOUND;
        IF (l_ship_ack_exist_flag = 'Y') THEN
           EXIT;
        END IF;
      END LOOP;
      CLOSE l_rel_ship_ack_exists_csr;

      /* If PO is acceptance required. */
      IF (l_acceptance_required_flag = 'Y') THEN

         /* Bug 2731191, if all shipments have been changed or acked and the
            header acceptance_required_flag is 'Y', the status of PO should be
            SUPPLIER_CHANGE_PENDING, before we check ship_ack_exist_flag first
            so the status was mistakenly calculated as 'ACK_REQUIRED'. */

         BEGIN
           select revision_num
           into   l_arch_revision_num
           from   po_releases_archive_all
           where  po_release_id = p_po_release_id
           and    latest_external_flag = 'Y';

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_arch_revision_num := p_revision_num;
         END;


         /* If all shipments were either changed or acknowledged. */
         IF (PO_ACKNOWLEDGE_PO_PVT.All_Shipments_Responded (
		   1.0,
		   FND_API.G_FALSE,
		   null,
		   p_po_release_id,
		   l_arch_revision_num ) = FND_API.G_TRUE  AND
		l_change_requested_by = 'SUPPLIER' ) THEN
            return 'SUPPLIER_CHANGE_PENDING';

         /* return partially acknowledged when changes are made to shipments */
	 ELSIF (l_change_requested_by = 'SUPPLIER' or l_ship_ack_exist_flag is not null)   THEN
            return 'PARTIALLY_ACKNOWLEDGED';

         /* If none of the shipments was acknowledged, return ACK_REQUIRED. */
         ELSIF (l_ship_ack_exist_flag is NULL) THEN
            return 'ACK_REQUIRED';
         END IF;

      END IF;

   /* PO */
   ELSIF (p_po_header_id is not null) THEN
      select nvl(acceptance_required_flag, 'N'),
             nvl(change_requested_by, ' '),
             nvl(pending_signature_flag,'N')
      into   l_acceptance_required_flag,
             l_change_requested_by,
             l_sign_flag
      from   PO_HEADERS_ALL
      where  po_header_id = p_po_header_id;

/* Check for Signatures */

   IF (l_sign_flag = 'Y') THEN

      OPEN l_reject_sign_exists_csr;
      LOOP
        FETCH l_reject_sign_exists_csr INTO l_reject_sign_exist_flag;
        EXIT WHEN l_reject_sign_exists_csr%NOTFOUND;
        IF (l_sup_sign_exist_flag = 'Y') THEN
           EXIT;
        END IF;
      END LOOP;
      CLOSE l_reject_sign_exists_csr;

      IF (l_reject_sign_exist_flag = 'Y') THEN
          /* Now Check if the Signature was a reject by any party*/
            return 'REJECTED';
      ELSE

        OPEN l_sup_sign_exists_csr;
         LOOP
          FETCH l_sup_sign_exists_csr INTO l_sup_sign_exist_flag;
          EXIT WHEN l_sup_sign_exists_csr%NOTFOUND;
          IF (l_sup_sign_exist_flag = 'Y') THEN
            EXIT;
          END IF;
         END LOOP;
        CLOSE l_sup_sign_exists_csr;

          IF (l_sup_sign_exist_flag is NULL) THEN
            return 'SIG_REQUIRED';
          ELSIF (l_sup_sign_exist_flag = 'Y') then
           return 'PENDING_BUYER_SIGNATURE';
          END IF;
      END IF;
    END IF;

   IF (l_acceptance_required_flag = 'Y') OR
      (l_acceptance_required_flag = 'D') THEN
      OPEN l_po_ship_ack_exists_csr;
      LOOP
        FETCH l_po_ship_ack_exists_csr INTO l_ship_ack_exist_flag;
        EXIT WHEN l_po_ship_ack_exists_csr%NOTFOUND;
        IF (l_ship_ack_exist_flag = 'Y') THEN
           EXIT;
        END IF;
      END LOOP;
      CLOSE l_po_ship_ack_exists_csr;


         BEGIN
           select 'Y'
           into   l_shipment_exist_flag
           from   sys.dual
           where  exists (
              select 1
              from   PO_LINE_LOCATIONS_ALL
              where  po_header_id = p_po_header_id
              and    po_release_id is NULL );

         EXCEPTION
           WHEN OTHERS THEN
             l_shipment_exist_flag := 'N';
         END;


         BEGIN
           select revision_num
           into   l_arch_revision_num
           from   po_headers_archive_all
           where  po_header_id = p_po_header_id
           and    latest_external_flag = 'Y';

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_arch_revision_num := p_revision_num;
         END;


         /* Bug 2816175, if there is no shipment existing and PO was
            changed, we should show 'SUPPLIER_CHANGE_PENDING'. */
         IF (NVL(l_shipment_exist_flag, 'N') = 'N' AND
             l_change_requested_by = 'SUPPLIER' ) THEN
            return 'SUPPLIER_CHANGE_PENDING';

         ELSIF (NVL(l_shipment_exist_flag, 'N') = 'N') THEN
            return 'ACK_REQUIRED';

         /* If all shipments were either changed or acknowledged. */
         ELSIF (PO_ACKNOWLEDGE_PO_PVT.All_Shipments_Responded (
		   1.0,
		   FND_API.G_FALSE,
		   p_po_header_id,
		   null,
		   l_arch_revision_num) = FND_API.G_TRUE  AND
		l_change_requested_by = 'SUPPLIER' ) THEN
            return 'SUPPLIER_CHANGE_PENDING';

         /* return partially acknowledged when changes are made to shipments */
	 ELSIF (l_change_requested_by = 'SUPPLIER' or
                l_ship_ack_exist_flag is not null)   THEN
            return 'PARTIALLY_ACKNOWLEDGED';

         /* If none of the shipments was acknowledged, return ACK_REQUIRED. */
         ELSIF (l_ship_ack_exist_flag is NULL) THEN
            return 'ACK_REQUIRED';
         END IF;

      END IF;

   END IF;


   /*
    * If PO does not require acknowledgement, then PO is either
    * 1. Accepted; 2. Rejected; 3. Acknowledged; 4) Do not require ACK
    */
   IF (p_po_release_id is not null) THEN
      BEGIN
         /* Get header level accepted_flag. */
	 select accepted_flag
	 into   l_accepted_flag
         from   PO_ACCEPTANCES
         where  acceptance_id = (
                   select max(acceptance_id)
                   from   PO_ACCEPTANCES
                   where  po_release_id = p_po_release_id
                   and    revision_num = p_revision_num
                   and    po_line_location_id is null );

      EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      l_accepted_flag := null;
      END;

   ELSIF (p_po_header_id is not null) THEN
      BEGIN
	 select accepted_flag
         into   l_accepted_flag
         from   PO_ACCEPTANCES
         where  acceptance_id = (
                   select max(acceptance_id)
                   from   PO_ACCEPTANCES
                   where  po_header_id = p_po_header_id
                   and    po_release_id is null
                   and    revision_num = p_revision_num
                   and    po_line_location_id is null );

      EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      l_accepted_flag := null;
      END;

   END IF;

   IF (l_accepted_flag = 'Y') THEN
      return 'ACCEPTED';
   ELSIF (l_accepted_flag = 'N') THEN
      return 'REJECTED';
   ELSIF (l_accepted_flag = 'A') THEN
      return 'ACKNOWLEDGED';
   ELSE
      return '';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      raise;
END Get_Header_Ack_Change_Status;


/**
 * Private procedure: Acknowledge_Po
 * Requires: PO_HEADER_ID, PO_RELEASE_ID, REVISION_NUM, ACCEPTED_FLAG,
 *           COMMENT, BUYER_ID, USER_ID
 * Modifies: PO_ACCEPTANCES
 * Effects: Insert header level acknowledgement result into PO_ACCEPTANCES
 *          table, also update ACCEPTANCE_REQUIRED_FLAG at PO header level.
 */

PROCEDURE Acknowledge_Po (
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER,
	p_accepted_flag		IN	VARCHAR2,
	p_comment		IN 	VARCHAR2 default null,
	p_buyer_id		IN	NUMBER,
	p_user_id		IN	NUMBER )

IS

   --  Bug 2850566
   l_rowid              ROWID;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   l_Last_Update_Date   PO_ACCEPTANCES.last_update_date%TYPE;
   l_acc_po_header_id   PO_HEADERS_ALL.po_header_id%TYPE;
   l_acceptance_id      PO_ACCEPTANCES.acceptance_id%TYPE;
   l_user_id            PO_ACCEPTANCES.last_updated_by%TYPE;
   --  End of Bug 2850566

BEGIN

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   IF p_po_release_id IS NULL THEN
     l_acc_po_header_id := p_po_header_id;
   ELSE
     l_acc_po_header_id := NULL;
   END IF;

   l_user_id := p_user_id;

    PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid                  =>  l_rowid,
			x_acceptance_id			 =>  l_acceptance_id,
            x_Last_Update_Date       =>  l_Last_Update_Date,
            x_Last_Updated_By        =>  l_user_id,
            x_Last_Update_Login      =>  l_Last_Update_Login,
			p_creation_date			 =>  sysdate,
			p_created_by			 =>  p_user_id,
			p_po_header_id			 =>  l_acc_po_header_id,
			p_po_release_id			 =>  p_po_release_id,
			p_action			     =>  fnd_message.get_string('PO','PO_ACK_WEB'),
			p_action_date			 =>  sysdate,
			p_revision_num			 =>  p_revision_num,
			p_accepted_flag			 =>  p_accepted_flag,
			p_note                   =>  p_comment,
			p_accepting_party        =>  'S');

   --  End of Bug 2850566

   /* reset the header-level acceptance_required_flag. */
   IF (p_po_release_id is not null) THEN
      update PO_RELEASES_ALL
      set    acceptance_required_flag = 'N',
             acceptance_due_date = ''
      where  po_release_id = p_po_release_id;

   ELSIF (p_po_header_id is not null) THEN
      update PO_HEADERS_ALL
      set    acceptance_required_flag = 'N',
             acceptance_due_date = ''
      where  po_header_id = p_po_header_id;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      raise;
END Acknowledge_Po;


/**
 * Public function: Get_Po_Status_Code
 * Requires: PO_HEADER_ID,PO_RELEASE_ID
 * Modifies:
 * Effects: Return the overall status of the entire order.
 *          Possible values are:
 *          1. CANCELLED
 *          2. FROZEN
 *          3. ON HOLD
 *          4. INTERNAL CHANGE
 *          5. SUPPLIER_CHANGE_PENDING
 *          6. ACCEPTED
 *          7. REJECTED
 *          8. ACKNOWLEDGED
 *          9. PARTIALLY_ACKNOWLEDGED
 *         10. ACK_REQUIRED
 *         11. DRAFT
 *         12. PENDING_SUBMIT
 *         13. PENDING_SUPP_EDIT
 *         14. CAT_ADMIN_LOCK
 *         15. ''
 */

FUNCTION Get_Po_Status_Code (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER )
RETURN VARCHAR2 IS

  l_api_name	CONSTANT VARCHAR2(30) := 'GET_PO_STATUS_CODE';
  l_api_version	CONSTANT NUMBER := 1.0;

  l_cancel_flag		PO_HEADERS_ALL.cancel_flag%TYPE := null;
  l_frozen_flag		PO_HEADERS_ALL.frozen_flag%TYPE := null;
  l_on_hold_flag	PO_HEADERS_ALL.user_hold_flag%TYPE := null;
  l_accp_reqd_flag	PO_HEADERS_ALL.acceptance_required_flag%TYPE := null;
  l_closed_code		PO_HEADERS_ALL.closed_code%TYPE := null;
  l_auth_status		PO_HEADERS_ALL.authorization_status%TYPE := null;
  l_revision_num	PO_HEADERS_ALL.revision_num%TYPE;
  l_changed_by		PO_HEADERS_ALL.change_requested_by%TYPE := null;
  l_cancel_pending_flag	VARCHAR2(1) := 'N';

  l_ga_flag		PO_HEADERS_ALL.GLOBAL_AGREEMENT_flag%TYPE := null;
  l_authoring_flag	PO_HEADERS_ALL.SUPPLIER_AUTH_ENABLED_flag%TYPE := null;
  l_lock_owner_role	PO_HEADERS_ALL.LOCK_OWNER_ROLE%TYPE := null;
  l_catalog_status	VARCHAR2(100) := null;
  l_return_status	VARCHAR2(1) := null;

  CURSOR l_rel_supplier_cancel_csr IS
          select 'Y'
          from   PO_CHANGE_REQUESTS
          where  po_release_id = p_po_release_id
          and    request_status = 'PENDING'
          and    request_level  = 'HEADER'
          and    action_type    = 'CANCELLATION'
          and    initiator      = 'SUPPLIER';


  CURSOR l_po_supplier_cancel_csr IS
          select 'Y'
          from   PO_CHANGE_REQUESTS
          where  document_header_id = p_po_header_id
          and    request_status = 'PENDING'
          and    request_level  = 'HEADER'
          and    action_type    = 'CANCELLATION'
          and    initiator      = 'SUPPLIER';

BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.invoked', 'po_header_id: ' ||
        	NVL(TO_CHAR(p_po_header_id), ' ') || ' po_release_id: ' ||
        	NVL(TO_CHAR(p_po_release_id), ' ') );
  END IF;

  IF (p_po_release_id is not NULL) THEN
     select 	nvl(cancel_flag, 'N'),
		nvl(frozen_flag, 'N'),
		nvl(hold_flag, 'N'),
		nvl(closed_code, 'OPEN'),
		nvl(acceptance_required_flag, 'N'),
		nvl(authorization_status, 'INCOMPLETE'),
		revision_num,
		nvl(change_requested_by, ' ')
     into	l_cancel_flag,
  		l_frozen_flag,
  		l_on_hold_flag,
  		l_closed_code,
		l_accp_reqd_flag,
  		l_auth_status,
   		l_revision_num,
		l_changed_by
     from 	PO_RELEASES_all
     where	po_release_id = p_po_release_id;

  ELSE
     select 	nvl(cancel_flag, 'N'),
		nvl(frozen_flag, 'N'),
		nvl(user_hold_flag, 'N'),
		nvl(closed_code, 'OPEN'),
		nvl(acceptance_required_flag, 'N'),
		nvl(authorization_status, 'INCOMPLETE'),
		revision_num,
		nvl(change_requested_by, ' '),
		nvl(global_agreement_flag, 'N'),
		nvl(supplier_auth_enabled_flag, 'N'),
		nvl(lock_owner_role, ' ')
     into	l_cancel_flag,
  		l_frozen_flag,
  		l_on_hold_flag,
  		l_closed_code,
		l_accp_reqd_flag,
  		l_auth_status,
   		l_revision_num,
		l_changed_by,
		l_ga_flag,
		l_authoring_flag,
		l_lock_owner_role
     from 	PO_HEADERS_all
     where	po_header_id = p_po_header_id;

  END IF;

  IF (l_closed_code in ('CLOSED','FINALLY CLOSED') ) THEN
     return l_closed_code;
  ELSIF (l_frozen_flag = 'Y') THEN
     return 'FROZEN';
  ELSIF (l_on_hold_flag = 'Y') THEN
     return 'ON HOLD';
  ELSIF (l_cancel_flag = 'Y') THEN
     return 'CANCELLED';
  ELSIF (l_auth_status = 'REJECTED') THEN
     return 'REJECTED';
  ELSIF (l_closed_code <> 'OPEN' ) THEN
     return l_closed_code;
  ELSIF (l_ga_flag = 'Y' and l_lock_owner_role = 'CAT_ADMIN') THEN
     return 'CAT_ADMIN_LOCK';
  ELSIF (l_auth_status in ('IN PROCESS', 'REQUIRES REAPPROVAL')
	 AND l_changed_by <> 'SUPPLIER') THEN
     return 'INTERNAL CHANGE';
  END IF;

  IF (l_changed_by <> 'SUPPLIER' AND
      l_ga_flag = 'Y' and l_authoring_flag = 'Y') THEN

     PO_DRAFTS_GRP.GET_ONLINE_AUTH_STATUS_CODE (
 		P_API_VERSION		  => 1.0,
 		X_RETURN_STATUS		  => l_return_status,
 		P_PO_HEADER_ID 		  => p_po_header_id,
 		X_ONLINE_AUTH_STATUS_CODE => l_catalog_status );

     IF (l_catalog_status is not null AND l_catalog_status <> 'NO_DRAFT') THEN
       return l_catalog_status;
     END IF;

  END IF;


  IF (l_accp_reqd_flag='N' and l_changed_by='SUPPLIER') THEN

     If (p_po_release_id is not null) THEN
        begin
          OPEN l_rel_supplier_cancel_csr;
          FETCH l_rel_supplier_cancel_csr INTO l_cancel_pending_flag;
   	  CLOSE l_rel_supplier_cancel_csr;

        exception
          WHEN OTHERS then
            l_cancel_pending_flag := null;
        end;

          IF (l_cancel_pending_flag = 'Y') THEN
         	   return 'SUPPLIER_CANCEL_PENDING';
          ELSE
         	   return 'SUPPLIER_CHANGE_PENDING';
          END IF;

     ELSIF (p_po_header_id is not null) THEN
        begin
          OPEN l_po_supplier_cancel_csr;
          FETCH l_po_supplier_cancel_csr INTO l_cancel_pending_flag;
   	  CLOSE l_po_supplier_cancel_csr;

        exception
          WHEN OTHERS then
            l_cancel_pending_flag := null;
        end;

          IF (l_cancel_pending_flag = 'Y') THEN
            return 'SUPPLIER_CANCEL_PENDING';
          ELSE
            return 'SUPPLIER_CHANGE_PENDING';
          END IF;

     END IF;

  ELSE
     return PO_ACKNOWLEDGE_PO_PVT.Get_Header_Ack_Change_Status (
			p_po_header_id,
			p_po_release_id,
			l_revision_num );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
     FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.NO_DATA_FOUND Exception', sqlcode);
    END IF;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.others_exception', sqlcode);
      END IF;
    END IF;
    raise;

END Get_Po_Status_Code;



/**
 * Public function: Get_Shipment_Ack_Change_Status
 * Requires: PO_HEADER_ID,PO_RELEASE_ID
 * Modifies:
 * Effects: Return the acknowledgement status of individual shipment.
 *          Possible values are:
 *          1. ACK_REQUIRED
 *          2. PENDING_CHANGE
 *          3. PENDING_CANCEL
 *          4. ACCEPTED
 *          5. REJECTED
 *          6. ''
 */

FUNCTION Get_Shipment_Ack_Change_Status (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	P_line_location_id	IN	NUMBER,
	p_po_header_id		IN 	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )
RETURN VARCHAR2 IS

   l_ship_accepted_flag		VARCHAR2(1) := null;
   l_header_accepted_flag	VARCHAR2(1) := null;
   l_acceptance_required_flag 	VARCHAR2(1) := null;
   l_action_type		PO_CHANGE_REQUESTS.action_type%TYPE := null;

   l_revision_num		NUMBER := p_revision_num;
   l_authorization_status	PO_HEADERS_ALL.authorization_status%TYPE;

  l_api_name	CONSTANT VARCHAR2(30) := 'GET_PO_STATUS_CODE';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.invoked', 'line_location_id: ' ||
		NVL(TO_CHAR(P_line_location_id), ''));
  END IF;


  /* Bug 3715595 Use the latest revision_num to calculate the status
     if PO is rejected. */
  BEGIN

    IF (p_po_release_id is not null) THEN
      SELECT POR.revision_num, authorization_status
      INTO   l_revision_num, l_authorization_status
      FROM   PO_RELEASES_ALL POR
      WHERE  POR.po_release_id = p_po_release_id;

    ELSIF (p_po_header_id is not null) THEN
      SELECT POH.revision_num, authorization_status
      INTO   l_revision_num, l_authorization_status
      FROM   PO_HEADERS_ALL POH
      WHERE  POH.po_header_id = p_po_header_id;

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_revision_num := p_revision_num;
      l_authorization_status := '';
  END;

  IF (not l_authorization_status = 'REJECTED') THEN
    l_revision_num := p_revision_num;
  END IF;


  /* Shipment is pending change or cancel. */
  BEGIN

    IF (p_po_release_id is not null) THEN

    select PCR.action_type
    into   l_action_type
    from   PO_CHANGE_REQUESTS PCR,
           PO_RELEASES_ALL POR
    where  pcr.document_line_location_id = P_line_location_id
    and    pcr.po_release_id = p_po_release_id
    and    por.po_release_id = p_po_release_id
    and    por.change_requested_by = 'SUPPLIER'
    and    request_level = 'SHIPMENT'
    and    ((request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP','REQ_APP')) OR
            (request_status = 'REJECTED' and change_request_group_id = (
              	select MAX(change_request_group_id)
              	from   po_change_requests pcr2
                where  pcr2.po_release_id = p_po_release_id
                and    pcr2.request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP'))) )
    and    rownum = 1;

    ELSIF (p_po_header_id is not null) THEN

    select PCR.action_type
    into   l_action_type
    from   PO_CHANGE_REQUESTS PCR,
           PO_HEADERS_ALL POH
    where  pcr.document_line_location_id = P_line_location_id
    and    pcr.document_header_id = p_po_header_id
    and    poh.po_header_id = p_po_header_id
    and    poh.change_requested_by = 'SUPPLIER'
    and    request_level = 'SHIPMENT'
    and    ((request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP','REQ_APP')) OR
            (request_status = 'REJECTED' and change_request_group_id = (
              	select MAX(change_request_group_id)
              	from   po_change_requests pcr2
                where  pcr2.document_header_id = p_po_header_id
                and    pcr2.request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP'))) )
    and    rownum = 1;

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_action_type := null;
  END;

  if (l_action_type = 'CANCELLATION') then
    return 'PENDING_CANCEL';
  elsif (l_action_type = 'MODIFICATION') then
    return 'PENDING_CHANGE';
  end if;


  /* Check if shipment has been acknowledged. */
  BEGIN
    select accepted_flag
    into   l_ship_accepted_flag
    from   PO_ACCEPTANCES
    where  po_line_location_id = P_line_location_id
    and    revision_num = l_revision_num
    and    acceptance_id = (select MAX(acceptance_id)
                     from   PO_ACCEPTANCES PA2
                     where  PA2.po_line_location_id = P_line_location_id
                     and    PA2.revision_num = l_revision_num );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_ship_accepted_flag := null;
  END;

  IF (l_ship_accepted_flag = 'Y') THEN
    return 'ACCEPTED';
  ELSIF (l_ship_accepted_flag = 'N') THEN
    return 'REJECTED';
  END IF;


  IF (p_po_release_id is not null) THEN
    select nvl(acceptance_required_flag, 'N')
    into   l_acceptance_required_flag
    from   PO_RELEASES_ALL
    where  po_release_id = p_po_release_id
    and    revision_num = l_revision_num;

    IF (l_acceptance_required_flag in ('D','Y')) THEN
      return 'ACK_REQUIRED';

    ELSE
      BEGIN
        select accepted_flag
        into   l_header_accepted_flag
        from   PO_ACCEPTANCES
        where  acceptance_id = (
                   select max(acceptance_id)
                   from   PO_ACCEPTANCES
                   where  po_release_id = p_po_release_id
                   and    revision_num = l_revision_num
                   and    po_line_location_id is null );

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          l_header_accepted_flag := null;
      END;
    END IF;

  ELSIF (p_po_header_id is not null) THEN
    select nvl(acceptance_required_flag, 'N')
    into   l_acceptance_required_flag
    from   PO_HEADERS_ALL
    where  po_header_id = p_po_header_id;

    IF (l_acceptance_required_flag in('D', 'Y')) THEN
      return 'ACK_REQUIRED';

    ELSE
      BEGIN
        select accepted_flag
        into   l_header_accepted_flag
        from   PO_ACCEPTANCES
        where  acceptance_id = (
		select max(acceptance_id)
                from   PO_ACCEPTANCES
                where  po_header_id = p_po_header_id
                and    po_release_id is null
                and    revision_num = l_revision_num
                and    po_line_location_id is null );

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_header_accepted_flag := null;
      END;
    END IF;

  END IF;

  IF (l_header_accepted_flag = 'Y') THEN
    return 'ACCEPTED';
  ELSIF (l_header_accepted_flag = 'N') THEN
    return 'REJECTED';
  ELSE
    return '';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', sqlcode);
      END IF;
    END IF;
    raise;
END Get_Shipment_Ack_Change_Status;



/**
 * Public procedure: Acknowledge_Shipment
 * Requires: LINE_LOCATION_ID, PO_HEADER_ID, PO_RELEASE_ID, REVISION_NUM,
 *           ACCEPTED_FLAG, COMMENT, BUYER_ID, USER_ID
 * Modifies: PO_ACCEPTANCES
 * Effects: Insert shipment level acknowledgement result into PO_ACCEPTANCES
 *          table.  Also checks if all shipments have been acknowledged after
 *          insertion, if yes then post the header level acknowledge result.
 */

PROCEDURE Acknowledge_Shipment (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_line_location_id	IN	NUMBER,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER,
	p_accepted_flag		IN	VARCHAR2,
	p_comment		IN	VARCHAR2 default null,
	p_buyer_id		IN	NUMBER,
	p_user_id		IN	NUMBER )
IS

   --  Bug 2850566
   l_rowid              ROWID;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   l_Last_Update_Date   PO_ACCEPTANCES.last_update_date%TYPE;
   l_acc_po_header_id   PO_HEADERS_ALL.po_header_id%TYPE;
   l_acceptance_id      PO_ACCEPTANCES.acceptance_id%TYPE;
   l_user_id            PO_ACCEPTANCES.last_updated_by%TYPE;
   --  End of Bug 2850566


  l_api_name	CONSTANT VARCHAR2(30) := 'ACKNOWLEDGE_SHIPMENT';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
		l_api_name || '.invoked', 'Line_location_id: ' ||
		NVL(TO_CHAR(p_line_location_id),'null'));
  END IF;

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   IF(p_accepted_flag = 'Y' AND g_default_promise_date = 'Y') THEN
            -- RDP ( defaults the promise date with need by date)
   POS_ACK_PO.Acknowledge_promise_date (p_line_location_id,p_po_header_id,p_po_release_id,p_revision_num,p_user_id);
   END IF;


   IF p_po_release_id IS NULL THEN
     l_acc_po_header_id := p_po_header_id;
   ELSE
     l_acc_po_header_id := NULL;
   END IF;

   l_user_id := p_user_id;

    PO_ACCEPTANCES_INS_PVT.insert_row(
		x_rowid			=>  l_rowid,
		x_acceptance_id		=>  l_acceptance_id,
		x_Last_Update_Date	=>  l_Last_Update_Date,
		x_Last_Updated_By	=>  l_user_id,
		x_Last_Update_Login	=>  l_Last_Update_Login,
		p_creation_date		=>  sysdate,
		p_created_by		=>  p_user_id,
		p_po_header_id		=>  l_acc_po_header_id,
		p_po_release_id		=>  p_po_release_id,
		p_po_line_location_id	=>  p_line_location_id,
		p_action		=>  fnd_message.get_string('PO','PO_ACK_WEB'),
		p_action_date		=>  sysdate,
		p_employee_id		=>  to_number(null),
		p_revision_num		=>  p_revision_num,
		p_accepted_flag		=>  p_accepted_flag,
		p_note			=>  p_comment);

   --  End of Bug 2850566

  IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.after inserting shipment acknowledgement',
	'Line_location_id: '|| NVL(TO_CHAR(p_line_location_id),'null'));
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
      IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', sqlcode);
      END IF;
    END IF;
    raise;
END acknowledge_shipment;



/**
 * Public procedure: Carry_Over_Acknowledgement
 * Requires: PO_HEADER_ID, PO_RELEASE_ID, REVISION_NUM,
 * Modifies: PO_ACCEPTANCES
 * Effects:  Carry over the shipment_level acknowledgement results from the
 *           previous revision, it is called before launching PO approval
 *           workflow after supplier's change has been accepted by buyer.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE Carry_Over_Acknowledgement (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )    -- current revision_num
IS

  l_header_accepted_flag	VARCHAR2(1) := 'Y';
  l_buyer_id			NUMBER;

  l_api_name	CONSTANT VARCHAR2(30) := 'CARRY_OVER_ACKNOWLEDGEMENT';
  l_api_version	CONSTANT NUMBER := 1.0;

   --  Bug 2850566 RBAIRRAJ
   l_rowid              ROWID;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   l_Last_Update_Date   PO_ACCEPTANCES.last_update_date%TYPE;
   l_Last_Updated_By    PO_ACCEPTANCES.last_updated_by%TYPE;
   l_acceptance_id      PO_ACCEPTANCES.acceptance_id%TYPE;
   l_user_id            PO_ACCEPTANCES.last_updated_by%TYPE;

   CURSOR c1_csr IS
    Select
        PA.created_by,
    	PA.po_line_location_id,
        PA.action,
        PA.action_date,
        PA.accepted_flag,
        PA.Last_Updated_By
    from   PO_ACCEPTANCES PA
    Where  PA.po_release_id = p_po_release_id
    And    PA.revision_num = p_revision_num - 1
    And    PA.po_line_location_id is not null
    AND    NOT EXISTS ( select 1
		From   PO_ACCEPTANCES PA2
		Where  PA2.po_release_id = p_po_release_id
		And    PA2.revision_num = p_revision_num
		And    PA2.po_line_location_id = PA.po_line_location_id);


   CURSOR c2_csr IS
    Select
	  document_line_location_id
    from  PO_CHANGE_REQUESTS PCR
    Where PCR.po_release_id = p_po_release_id
    And   PCR.document_revision_num = p_revision_num - 1
    And   PCR.document_line_location_id is not null
    And   PCR.request_status = 'ACCEPTED'
    and   PCR.initiator = 'SUPPLIER'
    And   PCR.action_type = 'MODIFICATION'
    and   PCR.REQUEST_LEVEL = 'SHIPMENT'
    AND    NOT EXISTS ( select 1
		From   PO_ACCEPTANCES PA2
		Where  PA2.po_release_id = p_po_release_id
		And    PA2.revision_num = p_revision_num
		And    PA2.po_line_location_id = PCR.document_line_location_id);


   CURSOR c3_csr IS
    Select
        PA.created_by,
  	PA.po_line_location_id,
        PA.action,
        PA.action_date,
        PA.accepted_flag,
        PA.Last_Updated_By
    from  PO_ACCEPTANCES PA
    Where PA.po_header_id = p_po_header_id
    and   PA.po_release_id is null
    And   PA.revision_num = p_revision_num - 1
    And   PA.po_line_location_id is not null
    AND    NOT EXISTS ( select 1
		From   PO_ACCEPTANCES PA2
		Where  PA2.po_release_id = p_po_release_id
		And    PA2.revision_num = p_revision_num
		And    PA2.po_line_location_id = PA.po_line_location_id);


   CURSOR c4_csr IS
    Select
	   document_line_location_id
    from   PO_CHANGE_REQUESTS PCR
    Where  PCR.document_header_id = p_po_header_id
    And    PCR.po_release_id is null
    And    PCR.document_revision_num = p_revision_num - 1
    And    PCR.document_line_location_id is not null
    And    PCR.request_status = 'ACCEPTED'
    and    PCR.initiator = 'SUPPLIER'
    And    PCR.action_type = 'MODIFICATION'
    and    PCR.REQUEST_LEVEL = 'SHIPMENT'
    AND    NOT EXISTS ( select 1
		From   PO_ACCEPTANCES PA2
		Where  PA2.po_header_id = p_po_header_id
                And    PA2.po_release_id is null
		And    PA2.revision_num = p_revision_num
		And    PA2.po_line_location_id = PCR.document_line_location_id);


   --  End of Bug 2850566

BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;


  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.invoked', 'po_header_id: ' ||
	NVL(TO_CHAR(p_po_header_id),'null') || ' po_release_id: ' ||
	NVL(TO_CHAR(p_po_release_id),'null'));
  END IF;


  /* Copy the previous revision shipment-level acknowledgement. */
  If (p_po_release_id is not null) THEN
    select agent_id
    into   l_buyer_id
    from   po_releases_all
    where  po_release_id = p_po_release_id;


   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.
   for c1_rec in c1_csr
     loop

        l_user_id := c1_rec.Last_Updated_By;
        l_acceptance_id := NULL;

       PO_ACCEPTANCES_INS_PVT.insert_row(
		x_rowid			=>  l_rowid,
		x_acceptance_id		=>  l_acceptance_id,
		x_Last_Update_Date	=>  l_Last_Update_Date,
		x_Last_Updated_By	=>  l_user_id,
		x_Last_Update_Login	=>  l_Last_Update_Login,
		p_creation_date		=>  sysdate,
		p_created_by		=>  c1_rec.created_by,
		p_po_header_id		=>  NULL,
		p_po_release_id		=>  p_po_release_id,
		p_po_line_location_id	=>  c1_rec.po_line_location_id,
		p_action		=>  c1_rec.action,
		p_action_date		=>  c1_rec.action_date,
		p_revision_num		=>  p_revision_num,
		p_accepted_flag		=>  c1_rec.accepted_flag);
     end loop;
   --  End of Bug 2850566


    /* If a shipment-level change has been approved, we'll treat this
       shipment as being accepted by the supplier. */

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.
   for c2_rec in c2_csr
     loop
       l_acceptance_id := NULL;
       l_Last_Updated_By := NULL;

       PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid			=>  l_rowid,
            x_acceptance_id		=>  l_acceptance_id,
            x_Last_Update_Date		=>  l_Last_Update_Date,
            x_Last_Updated_By		=>  l_Last_Updated_By,
            x_Last_Update_Login		=>  l_Last_Update_Login,
            p_creation_date		=>  sysdate,
            p_created_by		=>  fnd_global.user_id,
            p_po_header_id		=>  NULL,
            p_po_release_id		=>  p_po_release_id,
            p_po_line_location_id	=>  c2_rec.document_line_location_id,
            p_action			=>  fnd_message.get_string('PO','PO_ACK_WEB'),
            p_action_date		=>  sysdate,
            p_revision_num		=>  p_revision_num,
            p_accepted_flag		=>  'Y');
    end loop;
   --  End of Bug 2850566


  ELSIf (p_po_header_id is not null) THEN
    select agent_id
    into   l_buyer_id
    from   po_headers_all
    where  po_header_id = p_po_header_id;


   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   for c3_rec in c3_csr
     loop
       l_user_id := c3_rec.Last_Updated_By;
       l_acceptance_id := NULL;

       PO_ACCEPTANCES_INS_PVT.insert_row(
		x_rowid			=>  l_rowid,
		x_acceptance_id		=>  l_acceptance_id,
		x_Last_Update_Date	=>  l_Last_Update_Date,
		x_Last_Updated_By	=>  l_user_id,
		x_Last_Update_Login	=>  l_Last_Update_Login,
		p_creation_date		=>  sysdate,
		p_created_by		=>  c3_rec.created_by,
		p_po_header_id		=>  p_po_header_id,
		p_po_release_id		=>  NULL,
		p_po_line_location_id	=>  c3_rec.po_line_location_id,
		p_action		=>  c3_rec.action,
		p_action_date		=>  c3_rec.action_date,
		p_revision_num		=>  p_revision_num,
		p_accepted_flag		=>  c3_rec.accepted_flag);
     end loop;
   --  End of Bug 2850566

    /* If a shipment-level change has been approved, we'll treat this
       shipment as being accepted by the supplier. */


   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   for c4_rec in c4_csr
     loop
       l_acceptance_id := NULL;
       l_Last_Updated_By := NULL;

       PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid			=>  l_rowid,
            x_acceptance_id		=>  l_acceptance_id,
            x_Last_Update_Date		=>  l_Last_Update_Date,
            x_Last_Updated_By		=>  l_Last_Updated_By,
            x_Last_Update_Login		=>  l_Last_Update_Login,
            p_creation_date		=>  sysdate,
            p_created_by		=>  fnd_global.user_id,
            p_po_header_id		=>  p_po_header_id,
            p_po_release_id		=>  NULL,
            p_po_line_location_id	=>  c4_rec.document_line_location_id,
            p_action			=>  fnd_message.get_string('PO','PO_ACK_WEB'),
            p_action_date		=>  sysdate,
            p_revision_num		=>  p_revision_num,
            p_accepted_flag		=>  'Y');
    end loop;
   --  End of Bug 2850566

  END IF;

  IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '. after carrying over shipment level ack. ', 'Log');
  END IF;

  /* If all shipments are acknowledged after carryover, post header-level
     acknowledgement. */
  IF (PO_ACKNOWLEDGE_PO_PVT.All_Shipments_Acknowledged(
   		1.0,
    		FND_API.G_FALSE,
		p_po_header_id,
		p_po_release_id,
		p_revision_num ) = FND_API.G_TRUE ) THEN

    IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.All_Shipments_Acknowledged. ', 'Log');
    END IF;

    BEGIN
      If (p_po_release_id is not null) THEN
        Select 'A'
	into   l_header_accepted_flag
	From   sys.dual
        Where  exists (
		select 1
		From   PO_ACCEPTANCES
		Where  po_release_id = p_po_release_id
      		and    revision_num = p_revision_num
		and    po_line_location_id is not null
		and    accepted_flag <> 'Y' );

      ELSIF (p_po_header_id is not null) THEN
        Select 'A'
	into   l_header_accepted_flag
	From   sys.dual
        Where  exists (
		select 'Y'
		From   PO_ACCEPTANCES
		Where  po_header_id = p_po_header_id
                and    po_release_id is null
      		and    revision_num = p_revision_num
		and    po_line_location_id is not null
		and    accepted_flag <> 'Y' );
      END IF;

    EXCEPTION
      When no_data_found then
        l_header_accepted_flag := 'Y';
    END;


    IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.call Acknowledge_po', ' header_id: ' ||
        NVL(TO_CHAR(p_po_header_id), ' ') || 'release_id: ' ||
        NVL(TO_CHAR(p_po_release_id), ' ') || 'accepted_flag: ' ||
        NVL(l_header_accepted_flag, ''));
    END IF;

    PO_ACKNOWLEDGE_PO_PVT.Acknowledge_po (
			p_po_header_id,
                        p_po_release_id,
                        p_revision_num,
                        l_header_accepted_flag,
                        null,
			l_buyer_id,
                        fnd_global.user_id );

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
      IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.others_exception', sqlcode);
      END IF;
    END IF;
    raise;

END Carry_Over_Acknowledgement;


/**
 * Public function: All_Shipments_Responded
 * Requires: PO_HEADER_ID,PO_RELEASE_ID,REVISION_NUM
 * Modifies:
 * Effects:  Returns if all the shipments have been either changed or
 *           acknowledged.
 */

FUNCTION All_Shipments_Responded (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER,
	p_revision_num		IN	NUMBER )
RETURN VARCHAR2 IS

   L_ship_not_responded_flag	VARCHAR2(1) := NULL;

   CURSOR l_rel_ship_not_responded_csr IS
      select 'Y'
      From   PO_LINE_LOCATIONS_ALL PLL
      Where  pll.po_release_id = p_po_release_id
      And    not exists (
		select 1
		From   PO_ACCEPTANCES PA
		Where  PA.po_release_id = p_po_release_id
		And    pa.revision_num = p_revision_num
		And    pa.po_line_location_id = PLL.line_location_id )
      And    not exists (
		select 1
		From   PO_CHANGE_REQUESTS pcr, po_releases_all por
		WHERE  por.po_release_id = p_po_release_id
                and    por.change_requested_by = 'SUPPLIER'
                and    pcr.po_release_id = p_po_release_id
		AND    PCR.document_revision_num = p_revision_num
                And    ((pcr.document_line_location_id = PLL.line_location_id) OR
                        (pcr.parent_line_location_id = PLL.line_location_id))
                and    pcr.initiator = 'SUPPLIER'
                And    ((pcr.request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP','REQ_APP')) OR
                        (pcr.request_status = 'REJECTED'
                and    pcr.CHANGE_REQUEST_GROUP_ID = (
                          select MAX(pcr2.CHANGE_REQUEST_GROUP_ID)
                          from   po_change_requests pcr2
                          where  pcr2.po_release_id = p_po_release_id
                          and    pcr2.document_revision_num = p_revision_num
                          and    pcr2.request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP')) ) ) )
      And    nvl(pll.cancel_flag, 'N') = 'N'
      And    nvl(pll.payment_type,'NULL') NOT IN ('ADVANCE','DELIVERY')
      And    nvl(pll.closed_code, 'OPEN') not in ('CLOSED', 'FINALLY CLOSED');


   CURSOR l_po_ship_not_responded_csr IS
      select 'Y'
      From   PO_LINE_LOCATIONS_ALL PLL
      Where  pll.po_header_id = p_po_header_id
      And    pll.po_release_id is null
      And    not exists (
		select 1
		From   PO_ACCEPTANCES PA
		Where  PA.po_header_id = p_po_header_id
		And    pa.revision_num = p_revision_num
		And    pa.po_line_location_id = PLL.line_location_id )
      And    not exists (
		select 1
		From   PO_CHANGE_REQUESTS pcr, po_headers_all poh
		WHERE  poh.po_header_id = p_po_header_id
                and    poh.change_requested_by = 'SUPPLIER'
                and    pcr.document_header_id = p_po_header_id
		AND    PCR.document_revision_num = p_revision_num
                And    ((pcr.document_line_location_id = PLL.line_location_id) OR
                        (pcr.parent_line_location_id = PLL.line_location_id))
                and    pcr.initiator = 'SUPPLIER'
	        And    ((pcr.request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP','REQ_APP')) OR
                        (pcr.request_status = 'REJECTED'
                and    pcr.CHANGE_REQUEST_GROUP_ID = (
                          select MAX(pcr2.CHANGE_REQUEST_GROUP_ID)
                          from   po_change_requests pcr2
                          where  pcr2.document_header_id = p_po_header_id
                          and    pcr2.document_revision_num = p_revision_num
                          and    pcr2.request_status in ('PENDING', 'BUYER_APP', 'WAIT_MGR_APP'))) ))
      And    nvl(pll.cancel_flag, 'N') = 'N'
      And    nvl(pll.payment_type,'NULL') NOT IN ('ADVANCE','DELIVERY')
      And    nvl(pll.closed_code, 'OPEN') not in ('CLOSED', 'FINALLY CLOSED');


  l_api_name	CONSTANT VARCHAR2(30) := 'ALL_SHIPMENTS_RESPONDED';
  l_api_version	CONSTANT NUMBER := 1.0;


BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   If (p_po_release_id is not null) then
      OPEN l_rel_ship_not_responded_csr;
      LOOP
         FETCH l_rel_ship_not_responded_csr INTO L_ship_not_responded_flag;
         EXIT WHEN l_rel_ship_not_responded_csr%NOTFOUND;
         IF (L_ship_not_responded_flag = 'Y') THEN
            EXIT;
         END IF;
      END LOOP;
      CLOSE l_rel_ship_not_responded_csr;

   ELSIF (p_po_header_id is not null) then
      OPEN l_po_ship_not_responded_csr;
      LOOP
         FETCH l_po_ship_not_responded_csr INTO L_ship_not_responded_flag;
         EXIT WHEN l_po_ship_not_responded_csr%NOTFOUND;
         IF (L_ship_not_responded_flag = 'Y') THEN
            EXIT;
         END IF;
      END LOOP;
      CLOSE l_po_ship_not_responded_csr;

   END IF;

   If (L_ship_not_responded_flag = 'Y') THEN
      return FND_API.G_FALSE;
   ELSE
      return FND_API.G_TRUE;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                       l_api_name || '.others_exception', sqlcode);
      END IF;
    END IF;
    raise;

END All_Shipments_Responded;


/**
 * Public procedure: Set_Header_Acknowledgement
 * Requires: PO_HEADER_ID, PO_RELEASE_ID
 * Modifies: PO_ACCEPTANCES
 * Effects:  For ack required PO, check if all shipments has been acknowledged
 *           and if there is no supplier change pending, if both conditions
 *           satisfied, post the header level acknowledgement record.
 * This API should be called after supplier submits the change requests and
 * after buyer responds to all supplier changes without revision increase.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE Set_Header_Acknowledgement (
    	p_api_version          	IN  	NUMBER,
    	p_Init_Msg_List		IN  	VARCHAR2,
    	x_return_status		OUT 	NOCOPY VARCHAR2,
	p_po_header_id		IN	NUMBER,
	p_po_release_id		IN	NUMBER )
IS

  l_api_name	CONSTANT VARCHAR2(30) := 'SET_HEADER_ACKNOWLEDGEMENT';
  l_api_version	CONSTANT NUMBER := 1.0;

  l_accp_required_flag		VARCHAR2(1) := null;
  l_ship_accepted_flag		VARCHAR2(1) := null;
  l_header_accepted_flag	VARCHAR2(1) := null;
  l_change_requested_by		PO_HEADERS_ALL.change_requested_by%TYPE := null;  l_revision_num		NUMBER;
  l_buyer_id			NUMBER;

  CURSOR l_rel_ship_accp_csr(rev_num NUMBER) IS
	SELECT accepted_flag
	FROM   po_acceptances
	WHERE  po_release_id = p_po_release_id
	AND    revision_num = rev_num
 	AND    po_line_location_id is not null;

  CURSOR l_po_ship_accp_csr(rev_num NUMBER) IS
	SELECT accepted_flag
	FROM   po_acceptances
	WHERE  po_header_id = p_po_header_id
	AND    revision_num = rev_num
 	AND    po_line_location_id is not null;

BEGIN

  IF fnd_api.to_boolean(P_Init_Msg_List) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
				     l_api_name, g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.invoked', 'po_header_id: ' ||
	NVL(TO_CHAR(p_po_header_id),'null') || ' po_release_id: ' ||
	NVL(TO_CHAR(p_po_release_id),'null'));
  END IF;


  IF (p_po_release_id is not null) THEN
    SELECT agent_id,
           revision_num,
           acceptance_required_flag,
           change_requested_by
    INTO   l_buyer_id,
           l_revision_num,
           l_accp_required_flag,
           l_change_requested_by
    FROM   PO_RELEASES_ALL
    WHERE  po_release_id = p_po_release_id;

  ELSIF (p_po_header_id is not null) THEN
    SELECT agent_id,
           revision_num,
           acceptance_required_flag,
           change_requested_by
    INTO   l_buyer_id,
           l_revision_num,
           l_accp_required_flag,
           l_change_requested_by
    FROM   PO_HEADERS_ALL
    WHERE  po_header_id = p_po_header_id;

  END IF;


  /* If PO does not require acknowledgement, no need to go further. */
  IF (l_accp_required_flag is null OR l_accp_required_flag = 'N') THEN
    RETURN;
  END IF;


  /* Check if there is no supplier change pending and all shipments have been
     acknowledged. */
  IF (NVL(l_change_requested_by, ' ') <> 'SUPPLIER' AND
      PO_ACKNOWLEDGE_PO_PVT.All_Shipments_Acknowledged (
    		1.0,
    		FND_API.G_FALSE,
		P_po_header_id,
		p_po_release_id,
		l_revision_num ) = FND_API.G_TRUE ) THEN

    IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix ||
	l_api_name || '.All_Shipments_Acknowledged', 'po_header_id: ' ||
	NVL(TO_CHAR(p_po_header_id),'null') || ' po_release_id: ' ||
	NVL(TO_CHAR(p_po_release_id),'null'));
    END IF;



    /* If there exist different type of shipment-level accepted_flag,
       header level accepted_flag will be saved as 'A'. */

    BEGIN
      IF (p_po_release_id is not null) THEN
        OPEN l_rel_ship_accp_csr(l_revision_num);
        FETCH l_rel_ship_accp_csr INTO l_ship_accepted_flag;
        CLOSE l_rel_ship_accp_csr;

      ELSIF (p_po_header_id is not null) THEN
        OPEN l_po_ship_accp_csr(l_revision_num);
        FETCH l_po_ship_accp_csr INTO l_ship_accepted_flag;
        CLOSE l_po_ship_accp_csr;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        l_ship_accepted_flag := NULL;
    END;

    /* If there is no ship ack records, no need to go further. */
    IF (l_ship_accepted_flag = null) THEN
      RETURN;
    END IF;

    l_header_accepted_flag := l_ship_accepted_flag;


    BEGIN
      IF (p_po_release_id is not null) THEN
	SELECT 'A'
	INTO   l_header_accepted_flag
	FROM   sys.dual
	WHERE  exists (
		SELECT 1
		FROM   PO_ACCEPTANCES
		WHERE  po_release_id = p_po_release_id
		AND    revision_num = l_revision_num
		AND    po_line_location_id is not null
		AND    accepted_flag <> l_ship_accepted_flag );

      ELSIF (p_po_header_id is not null) THEN
	SELECT 'A'
	INTO   l_header_accepted_flag
	FROM   sys.dual
	WHERE  exists (
		SELECT 'Y'
		FROM   PO_ACCEPTANCES
		WHERE  po_header_id = p_po_header_id
		AND    po_release_id is null
 		AND    revision_num = l_revision_num
		AND    po_line_location_id is not null
		AND    accepted_flag <> l_ship_accepted_flag );

      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_header_accepted_flag := l_ship_accepted_flag;
    END;

    IF (l_header_accepted_flag is not null) THEN
       PO_ACKNOWLEDGE_PO_PVT.Acknowledge_po (
		p_po_header_id,
                p_po_release_id,
                l_revision_num,
                l_header_accepted_flag,
                null,  -- note
		l_buyer_id,
                fnd_global.user_id );
    END IF;

  END IF; -- End if all_shipments_acknowledged

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      IF (g_fnd_debug = 'Y') AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                   l_api_name || '.others_exception', sqlcode);
      END IF;
    END IF;
    raise;

END Set_Header_Acknowledgement;



END PO_ACKNOWLEDGE_PO_PVT;

/
