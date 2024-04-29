--------------------------------------------------------
--  DDL for Package POS_SPM_WF_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SPM_WF_PKG1" AUTHID CURRENT_USER AS
/* $Header: POSSPM1S.pls 120.10.12010000.12 2014/03/12 12:32:46 spapana ship $ */

-- notify buyer admins that an address is created
-- in the supplier's address book
PROCEDURE notify_addr_created
  (p_vendor_id          IN  NUMBER,
   p_address_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   );

-- notify buyer admins that an address is removed
-- in the supplier's address book
PROCEDURE notify_addr_removed
  (p_vendor_id          IN  NUMBER,
   p_address_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   );

-- notify buyer admins that an address is updated in
-- the supplier's address book
PROCEDURE notify_addr_updated
  (p_vendor_id          IN  NUMBER,
   p_address_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   );

-- notify buyer admins that a business classification is created in
-- the supplier's list
PROCEDURE notify_bus_class_created
  (p_vendor_id            IN  NUMBER,
   p_bus_class_request_id IN  NUMBER,
   x_itemtype       	  OUT nocopy VARCHAR2,
   x_itemkey        	  OUT nocopy VARCHAR2,
   x_receiver       	  OUT nocopy VARCHAR2
   );

-- notify buyer admins that a business classification is removed from
-- the supplier's list
PROCEDURE notify_bus_class_removed
  (p_vendor_id              IN  NUMBER,
   p_bus_class_request_id   IN  NUMBER,
   x_itemtype       	    OUT nocopy VARCHAR2,
   x_itemkey        	    OUT nocopy VARCHAR2,
   x_receiver       	    OUT nocopy VARCHAR2
  );

-- notify buyer admins that a business classification is updated in
-- the supplier's list
PROCEDURE notify_bus_class_updated
  (p_vendor_id            IN  NUMBER,
   p_bus_class_request_id IN  NUMBER,
   x_itemtype       	  OUT nocopy VARCHAR2,
   x_itemkey        	  OUT nocopy VARCHAR2,
   x_receiver       	  OUT nocopy VARCHAR2
   );

-- notify buyer admins that a contact is created
-- in the supplier's contact directory
PROCEDURE notify_contact_created
  (p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   );

-- notify buyer admins that an contact is removed
-- in the supplier's contact directory
PROCEDURE notify_contact_removed
  (p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   );

-- notify buyer admins that an contact is updated in
-- the supplier's contact directory
PROCEDURE notify_contact_updated
  (p_vendor_id          IN  NUMBER,
   p_contact_request_id IN  NUMBER,
   x_itemtype           OUT nocopy VARCHAR2,
   x_itemkey            OUT nocopy VARCHAR2,
   x_receiver           OUT nocopy VARCHAR2
   );

/* not needed for r12. to remove later
PROCEDURE notify_contact_link_created
  (p_vendor_id            IN  NUMBER,
   p_cont_addr_request_id IN  NUMBER,
   x_itemtype             OUT nocopy VARCHAR2,
   x_itemkey              OUT nocopy VARCHAR2,
   x_receiver             OUT nocopy VARCHAR2
   );

PROCEDURE notify_contact_link_removed
  (p_vendor_id            IN  NUMBER,
   p_cont_addr_request_id IN  NUMBER,
   x_itemtype             OUT nocopy VARCHAR2,
   x_itemkey              OUT nocopy VARCHAR2,
   x_receiver             OUT nocopy VARCHAR2
   );
  */

-- notify buyer admins that a product and service is added to the
-- supplier's list
PROCEDURE notify_product_created
  (p_vendor_id      IN  NUMBER,
   x_itemtype       OUT nocopy VARCHAR2,
   x_itemkey        OUT nocopy VARCHAR2,
   x_receiver       OUT nocopy VARCHAR2
   );

-- notify buyer admins that a product and service is removed from the
-- supplier's list
PROCEDURE notify_product_removed
  (p_vendor_id      IN  NUMBER,
   x_itemtype       OUT nocopy VARCHAR2,
   x_itemkey        OUT nocopy VARCHAR2,
   x_receiver       OUT nocopy VARCHAR2
   );

-- notify a supplier that someone is trying to register
-- a supplier with same details as his/her company.
--
-- Note: This procedure uses PRAGMA AUTONOMOUS_TRANSACTION
--       so the notification will be created and sent in
--       a separate transaction!
--
-- p_vendor_id is the id of the vendor that is already in
-- the vendor master. A default contact of this vendor
-- should get the email
PROCEDURE notify_dup_supplier_reg
   (p_vendor_id     IN  NUMBER,
    p_first_name    IN  VARCHAR2,
    p_last_name     IN  VARCHAR2,
    p_sup_reg_email IN  VARCHAR2,
    x_itemtype      OUT nocopy VARCHAR2,
    x_itemkey       OUT nocopy VARCHAR2,
    x_receiver      OUT nocopy VARCHAR2
    );

-- notify buyer admins that a supplier has registered
PROCEDURE notify_supplier_registered
  (p_supplier_reg_id IN  NUMBER,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2,
   x_receiver        OUT nocopy VARCHAR2
   );

-- notify the supplier that his/her supplier registration is
-- approved
PROCEDURE notify_supplier_approved
  (p_supplier_reg_id IN  NUMBER,
   p_username        IN  VARCHAR2,
   p_password        IN  VARCHAR2,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2
   );

-- notify the supplier that his/her supplier registration is
-- rejected
PROCEDURE notify_supplier_rejected
  (p_supplier_reg_id IN  NUMBER,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2,
   x_receiver        OUT nocopy VARCHAR2
   );

-- This procedure is used by workflow to generate the buyer note with proper heading
-- in the notification to supplier when the supplier registration is approved or rejected.
-- It should not be used for other purpose.
--
-- Logic of the procedure: if notes_to_supplier is not null, returns a fnd message
-- POS_SUPPREG_BUYER_NOTE_HEADING for heading and the note; otherwise, null.
-- (bug 2725468).
--
PROCEDURE buyer_note
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2);

-- This procedure is used by workflow to generate the buyer note with
-- proper heading
-- in the notification to supplier when the buyer approves a bank account
-- It should not be used for other purpose.
--
PROCEDURE bank_acct_buyer_note
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2);

PROCEDURE notify_account_create
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2);

PROCEDURE notify_buyer_create_account
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   x_itemtype            OUT nocopy VARCHAR2,
   x_itemkey             OUT nocopy VARCHAR2);

PROCEDURE notify_account_update
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2);

PROCEDURE notify_buyer_update_account
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   x_itemtype            OUT nocopy VARCHAR2,
   x_itemkey             OUT nocopy VARCHAR2);

-- wf function activity to setup buyer receiver for account creation
PROCEDURE setup_acct_crt_buyer_rcvr
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2);

-- wf function activity to setup buyer receivers for supplier account update
PROCEDURE setup_acct_upd_buyer_rcvr
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2);

-- wf function activity to setup supplier receivers for buyer account update
PROCEDURE setup_acct_upd_supp_rcvr
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2);

-- wf function activity to setup receiver for account actions
PROCEDURE setup_acct_action_receiver
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2);

PROCEDURE notify_sup_on_acct_action
  (p_bank_account_number IN VARCHAR2,
   p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_request_status      IN VARCHAR2,
   p_note                IN VARCHAR2,
   x_itemtype            OUT nocopy VARCHAR2,
   x_itemkey             OUT nocopy VARCHAR2
   );

-- wf function activity to setup receiver for account address change or remove
PROCEDURE setup_acct_addr_receiver
  (itemtype  IN VARCHAR2,
   itemkey   IN VARCHAR2,
   actid     IN NUMBER,
   funcmode  IN VARCHAR2,
   resultout OUT nocopy VARCHAR2);

PROCEDURE notify_acct_addr_created
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   p_party_site_name     IN VARCHAR2,
   x_itemtype            OUT nocopy VARCHAR2,
   x_itemkey             OUT nocopy VARCHAR2);

PROCEDURE notify_acct_addr_changed
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   p_party_site_name  	 IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2);

PROCEDURE notify_acct_addr_removed
  (p_vendor_id           IN NUMBER,
   p_bank_name           IN VARCHAR2,
   p_bank_account_number IN VARCHAR2,
   p_currency_code       IN VARCHAR2,
   p_bank_account_name   IN VARCHAR2,
   p_party_site_name  	 IN VARCHAR2,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2);

-- Notify supplie user of login info.
-- The supplier user here is not the primary contact who submitted the
-- registration. The notification for the primary contact should be
-- sent using notify_supplier_approved method above.
PROCEDURE notify_supplier_user_approved
  (p_supplier_reg_id IN  NUMBER,
   p_username        IN  VARCHAR2,
   p_password        IN  VARCHAR2,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2
   );

-- send email to invite supplier to register
PROCEDURE send_supplier_invite_reg_ntf
  (p_supplier_reg_id IN NUMBER
   );

-- Send Notification to Supplier contact on clicking the Notify button
PROCEDURE PROS_SUPP_NOTIFICATION
  (p_supplier_reg_id IN varchar2,
   p_msg_subject in varchar2,
   p_msg_body in varchar2
   );

-- send email when supplier request is reopened/reconsidered
PROCEDURE send_supplier_reg_reopen_ntf
  (p_supplier_reg_id IN NUMBER
   );
-- send email when supplier registration request link is requested
PROCEDURE send_supplier_reg_link_ntf
  (p_supplier_reg_id IN NUMBER
   );
-- send email when supplier save request for later
PROCEDURE send_supplier_reg_saved_ntf
  (p_supplier_reg_id IN NUMBER
   );

-- send email when supplier submit request
PROCEDURE send_supplier_reg_submit_ntf
  (p_supplier_reg_id IN NUMBER
   );

-- send email to banking approvers once the supplier has been registered.
PROCEDURE notify_bank_aprv_supp_aprv
  (p_vendor_id           IN  NUMBER,
   x_itemtype      	 OUT nocopy VARCHAR2,
   x_itemkey       	 OUT nocopy VARCHAR2,
   x_receiver      	 OUT nocopy VARCHAR2
   );

-- notify the supplier that his/her supplier registration is approved
-- when the user (primary contact) already exists in OID and auto-link of username is enabled
PROCEDURE notify_supplier_apprv_ssosync
  (p_supplier_reg_id IN  NUMBER,
   p_username        IN  VARCHAR2,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2
   );

-- send email to non-primary contact of user registration
-- when the user already exists in OID and auto-link of username is enabled
PROCEDURE notify_user_approved_sso_sync
  (p_supplier_reg_id IN  NUMBER,
   p_username        IN  VARCHAR2,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2
   );

-- CODE ADDED FOR BUSINESS CLASSIFICATION RE-CERTIFICATION ER

-- workflow notification to supplier users for re-certification of Business Classifications

PROCEDURE bc_recert_workflow
(  ERRBUF      OUT nocopy VARCHAR2,
   RETCODE     OUT nocopy VARCHAR2
   );

-- END OF CODE ADDED FOR BUSINESS CLASSIFICATION RE-CERTIFICATION ER

-- Bug 8325979 - Replacing the message subject and body with FND Message and its tokens

FUNCTION GET_APPRV_SUPPLIER_SUBJECT(p_enterprise_name IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE GET_APPRV_SUPPLIER_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);
-- Bug 8325979 END

FUNCTION GET_SUPP_REOPEN_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2;
PROCEDURE GET_SUPP_REOPEN_NOTIF_BODY
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );
FUNCTION GET_SUPP_LINK_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2;
PROCEDURE GET_SUPP_LINK_NOTIF_BODY
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );

FUNCTION GET_SUPP_SAVE_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_SUPP_SAVE_NOTIF_BODY
  (
    document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );

FUNCTION GET_SUPP_SUBMIT_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_SUPP_SUBMIT_NOTIF_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );

FUNCTION GET_SUPP_REJECT_NOTIF_SUBJECT(p_enterprise_name IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_SUPP_REJECT_NOTIF_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );

FUNCTION GET_SUPP_RETURN_NOTIF_SUBJECT
RETURN VARCHAR2;

PROCEDURE GET_SUPP_RETURN_NOTIF_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );

FUNCTION GET_SUPP_REOPEN_MSG
(
  display_type IN VARCHAR2
)
RETURN VARCHAR2;

--
-- Begin Supplier Hub: OSN Integration
--
-- In this project, we have added a new token OSN_MESSAGE to the
-- FND message text.  This needs to be substituted with a message
-- that invites the supplier to sign up at Oracle Supplier Network.
-- Look into profile POS_SM_OSN_REG_MESSAGE to find a FND message name.
-- Then get the message text and put it into the OSN_MESSAGE token.
-- This utility function returns the OSN message or '' if
-- not found.  This is a generic function that can be used by
-- the General Notification flow, hence defining it in Spec.
-- Tue Sep  1 20:45:01 PDT 2009 bso R12.1.2
--

    FUNCTION get_osn_message RETURN VARCHAR2;

--
-- End Supplier Hub: OSN Integration
--

PROCEDURE notify_supp_appr_no_user_acc
  (p_supplier_reg_id IN  NUMBER,
   x_itemtype        OUT nocopy VARCHAR2,
   x_itemkey         OUT nocopy VARCHAR2,
   x_receiver        OUT nocopy VARCHAR2
   );


FUNCTION get_supplier_reg_url
(
  p_reg_key       IN VARCHAR2
)
RETURN VARCHAR2;

END pos_spm_wf_pkg1;

/
