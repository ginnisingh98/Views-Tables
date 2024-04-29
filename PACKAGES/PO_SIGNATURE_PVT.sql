--------------------------------------------------------
--  DDL for Package PO_SIGNATURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SIGNATURE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVSIGS.pls 120.2 2006/05/15 18:26:12 tpoon noship $ */

  --  Sets the attributes required for the Process
  PROCEDURE Set_Startup_Values (itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2);


  --  Sets the Notification Message body of the Signature Notifications for Supplier/Buyer
  PROCEDURE get_signature_notfn_body (document_id    IN VARCHAR2,
                                      display_type   IN VARCHAR2,
                                      document       IN OUT NOCOPY CLOB,
                                      document_type  IN OUT NOCOPY VARCHAR2);

  --  Calls the eRecord APIs to store the eRecord
  PROCEDURE create_erecord (itemtype        IN VARCHAR2,
                            itemkey         IN VARCHAR2,
                            actid           IN NUMBER,
                            funcmode        IN VARCHAR2,
                            resultout       OUT NOCOPY VARCHAR2);

 --  Updates relevant PO tables based on the Supplier and Buyers signature response
  PROCEDURE post_signature(itemtype	    IN  VARCHAR2,
                           itemkey  	IN  VARCHAR2,
                           actid	    IN  NUMBER,
                           funcmode	    IN  VARCHAR2,
                           resultout    OUT NOCOPY VARCHAR2);

  --  Sets the supplier response attribute to ACCEPTED
  PROCEDURE set_accepted_supplier_response(itemtype	  IN  VARCHAR2,
                                           itemkey    IN  VARCHAR2,
                                           actid	  IN  NUMBER,
                                           funcmode	  IN  VARCHAR2,
                                           resultout  OUT NOCOPY VARCHAR2);


  --  Sets the supplier response attribute to REJECTED
  PROCEDURE set_rejected_supplier_response(itemtype	 IN  VARCHAR2,
                                           itemkey   IN  VARCHAR2,
                                           actid	 IN  NUMBER,
                                           funcmode	 IN  VARCHAR2,
                                           resultout OUT NOCOPY VARCHAR2);

  --  Sets the buyer notification body when supplier rejected the document
  PROCEDURE get_buyer_info_notfn_body (document_id      IN VARCHAR2,
                                       display_type     IN VARCHAR2,
                                       document         IN OUT NOCOPY CLOB,
                                       document_type    IN OUT NOCOPY VARCHAR2);

  --  Sets the buyer response attribute to ACCEPTED
  PROCEDURE set_accepted_buyer_response(itemtype	IN  VARCHAR2,
                                        itemkey  	IN  VARCHAR2,
                                        actid	    IN  NUMBER,
                                        funcmode	IN  VARCHAR2,
                                        resultout   OUT NOCOPY VARCHAR2);

  --  Sets the supplier notification body when buyer accepted/rejected the document
  PROCEDURE get_supplier_info_notfn_body (document_id    IN VARCHAR2,
                                          display_type   IN VARCHAR2,
                                          document       IN OUT NOCOPY CLOB,
                                          document_type  IN OUT NOCOPY VARCHAR2);

  --  Sets the buyer response attribute to REJECTED
  PROCEDURE set_rejected_buyer_response(itemtype	IN  VARCHAR2,
                                        itemkey  	IN  VARCHAR2,
                                        actid	    IN  NUMBER,
                                        funcmode	IN  VARCHAR2,
                                        resultout   OUT NOCOPY VARCHAR2);

  --  Checks if the document requires Signature
  PROCEDURE Is_Signature_Required(itemtype        IN VARCHAR2,
                                  itemkey         IN VARCHAR2,
                                  actid           IN NUMBER,
                                  funcmode        IN VARCHAR2,
                                  resultout       OUT NOCOPY VARCHAR2);

  -- <BUG 3607009 START>
  --  Checks if the document requires Signature
  FUNCTION is_signature_required ( p_itemtype      IN   VARCHAR2
                                 , p_itemkey       IN   VARCHAR2
                                 ) RETURN BOOLEAN;
  -- <BUG 3607009 END>

  -- Checks if the document was ever Signed
  FUNCTION Was_Signature_Required(p_document_id IN NUMBER) return BOOLEAN;

  --  Sets the Supplier Notification Id attribute of the Signature Notification
  PROCEDURE Set_Supplier_Notification_Id(itemtype        IN VARCHAR2,
                                         itemkey         IN VARCHAR2,
                                         actid           IN NUMBER,
                                         funcmode        IN VARCHAR2,
                                         resultout       OUT NOCOPY VARCHAR2);

  --  Sets the Buyer Notification Id attribute of the Signature Notification
  PROCEDURE Set_Buyer_Notification_Id(itemtype        IN VARCHAR2,
                                      itemkey         IN VARCHAR2,
                                      actid           IN NUMBER,
                                      funcmode        IN VARCHAR2,
                                      resultout       OUT NOCOPY VARCHAR2);

  --  Updates the PO tables
  PROCEDURE Update_Po_Details(p_po_header_id        IN NUMBER,
                              p_status              IN VARCHAR2,
                              p_action_code         IN VARCHAR2,
                              p_object_type_code    IN VARCHAR2,
                              p_object_subtype_code IN VARCHAR2,
                              p_employee_id         IN NUMBER,
                              p_revision_num        IN NUMBER);

  -- To create Item key for the Document Signature Process
  PROCEDURE Get_Item_Key(p_po_header_id  IN  NUMBER,
                         p_revision_num  IN  NUMBER,
                         p_document_type IN  VARCHAR2,
                         x_itemkey       OUT NOCOPY VARCHAR2,
                         x_result        OUT NOCOPY VARCHAR2);

  -- Returns item key of the active Document Signature Process
  PROCEDURE Find_Item_Key(p_po_header_id  IN  NUMBER,
                          p_revision_num  IN  NUMBER,
                          p_document_type IN  VARCHAR2,
                          x_itemkey       OUT NOCOPY VARCHAR2,
                          x_result        OUT NOCOPY VARCHAR2);

  -- To Abort Document Signature Process after Signatures are completed
  PROCEDURE Abort_Doc_Sign_Process(p_itemkey IN  VARCHAR2,
                                   x_result  OUT NOCOPY VARCHAR2);

  -- To complete the blocked activities in PO Approval workflow
  PROCEDURE Complete_Block_Activities(p_itemkey IN  VARCHAR2,
                                      p_status  IN  VARCHAR2,
                                      x_result  OUT NOCOPY VARCHAR2);

  -- To get the last signed document revision number
  PROCEDURE Get_Last_Signed_Revision(p_po_header_id        IN NUMBER,
                                     p_revision_num        IN NUMBER,
                                     x_signed_revision_num OUT NOCOPY NUMBER,
                                     x_signed_records      OUT NOCOPY VARCHAR2,
                                     x_return_status       OUT NOCOPY VARCHAR2);

  -- To find out if the eRecord exists for the document revision
  PROCEDURE Does_Erecord_Exist(p_po_header_id      IN  NUMBER,
                               p_revision_num      IN  NUMBER,
                               x_erecord_exist     OUT NOCOPY VARCHAR2,
                               x_pending_signature OUT NOCOPY VARCHAR2);

  -- When signatures are complete updates the relevant tables
  PROCEDURE Post_Forms_Commit( p_po_header_id           IN  NUMBER,
                               p_revision_num           IN  NUMBER,
                               x_result                 OUT NOCOPY VARCHAR2,
                               x_error_msg              OUT NOCOPY VARCHAR2,
                               x_msg_data               OUT NOCOPY VARCHAR2);

--  Checks if there are more than one signature records exist in the
--  PO_ACCEPTANCES table
  PROCEDURE Check_For_Multiple_Entries( p_po_header_id           IN  NUMBER,
                                        p_revision_num           IN  NUMBER,
                                        x_result                 OUT NOCOPY VARCHAR2,
                                        x_error_msg              OUT NOCOPY VARCHAR2);


  -- <BUG 3751927 START>
  --  Gets rejection type of a document version from action history
  --  and acceptences.  See package body for more info.
PROCEDURE get_rejection_type (  p_po_header_id      IN   NUMBER
                              , p_revision_num      IN   NUMBER
                              , x_buyer_rejected    OUT NOCOPY VARCHAR2
                              , x_supplier_rejected OUT NOCOPY VARCHAR2
                            );
  -- <BUG 3751927 END>
--<Bug#5013783 Start>
PROCEDURE if_was_sign_reqd_set_acc_flag(p_document_id         IN NUMBER,
                                        x_if_acc_flag_updated OUT NOCOPY VARCHAR2);
--<Bug#5013783 End>

-- Bug 5216351
PROCEDURE if_rev_and_signed_set_acc_flag (
            p_document_id         IN NUMBER,
            p_old_revision_num    IN NUMBER,
            x_if_acc_flag_updated OUT NOCOPY VARCHAR2);

END PO_SIGNATURE_PVT;


 

/
