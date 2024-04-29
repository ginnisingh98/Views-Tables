--------------------------------------------------------
--  DDL for Package POS_VENDOR_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_VENDOR_REG_PKG" AUTHID CURRENT_USER AS
/* $Header: POSVREGS.pls 120.4.12010000.6 2014/04/07 10:26:47 spapana ship $ */

-- Following Action Codes are being used to store in POS_ACTION_HISTORY table

   ACTN_FYI               varchar2(30) := 'FYI';  /* FYI */
   ACTN_SAVE              varchar2(30) := 'DRAFT';  /* SAVE FOR LATER */
   ACTN_SUBMIT            varchar2(30) := 'SUBMIT';  /* SUBMIT */
   ACTN_PENDING           varchar2(30) := 'PENDING_APPROVAL';  /* PENDING_APPROVAL */
   ACTN_APPROVE           varchar2(30) := 'APPROVED';  /* APPROVE */
   ACTN_REJECT            varchar2(30) := 'REJECTED';  /* REJECT */
   ACTN_FORWARD           varchar2(30) := 'DELEGATE';  /* FORWARD */
   ACTN_APPR_FORWARD      varchar2(30) := 'APPROVE_FORWARD';  /* APPROVE_FORWARD */
   ACTN_NO_ACTION         varchar2(30) := 'NO_ACTION';  /* In case of Beat By first responder(approve) / rejected / return by any approver */
   ACTN_REQUEST_MORE_INFO varchar2(30) := 'QUESTION';  /* Requested for More information */
   ACTN_ANSWER            varchar2(30) := 'ANSWER';  /* Information Provided */
   ACTN_RETURN_TO_SUPP    varchar2(30) := 'RIF_SUPPLIER';  /* Return to Supplier */

-- Action Codes

PROCEDURE approve_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   );

PROCEDURE reject_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   );

PROCEDURE submit_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   );
PROCEDURE reopen_supplier_reg
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   );
PROCEDURE send_supplier_reg_link
  (p_supplier_reg_id IN  NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   );

PROCEDURE send_save_for_later_ntf
  (p_supplier_reg_id IN  NUMBER,
   p_email_address   IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   );

FUNCTION is_ou_id_valid
  (p_ou_id IN NUMBER
   ) RETURN VARCHAR2;

FUNCTION is_supplier_number_unique(
  p_supp_regid IN NUMBER,
  p_supp_number IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE is_taxpayer_id_unique(
  p_supp_regid IN NUMBER,
  p_taxpayer_id IN VARCHAR2,
  p_country IN VARCHAR2,
  x_is_unique OUT NOCOPY VARCHAR2,
  x_vendor_id OUT NOCOPY NUMBER
);

PROCEDURE is_duns_num_unique(
  p_supp_regid IN NUMBER,
  p_duns_num IN VARCHAR2,
  x_is_unique OUT NOCOPY VARCHAR2,
  x_vendor_id OUT NOCOPY NUMBER
);

PROCEDURE is_taxregnum_unique(
  p_supp_regid IN NUMBER
, p_taxreg_num IN VARCHAR2
, p_country IN VARCHAR2
, x_is_unique OUT NOCOPY VARCHAR2
, x_vendor_id OUT NOCOPY NUMBER
);

PROCEDURE notify_banking_approver
  (p_vendor_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2);

-- Begin Supplier Management: Bug 12849540
PROCEDURE validate_required_user_attrs
(   p_supp_reg_id   IN NUMBER,
    p_buyer_user    IN VARCHAR2,
    x_attr_req_tbl  OUT NOCOPY EGO_VARCHAR_TBL_TYPE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2

);

PROCEDURE insert_reg_action_hist
(   p_supp_reg_id     IN NUMBER,
    p_action          IN VARCHAR2,
    p_from_user_id     IN VARCHAR2,
    p_to_user_id     IN VARCHAR2,
    p_note            IN VARCHAR2,
    p_approval_group_id IN VARCHAR2
);

PROCEDURE update_reg_action_hist
(   p_supp_reg_id     IN NUMBER,
    p_action          IN VARCHAR2,
    p_note            IN VARCHAR2,
    p_from_user_id IN VARCHAR2,
    p_to_user_id IN VARCHAR2
);
PROCEDURE get_employeeId
(   p_userId IN NUMBER,
    p_employeeId IN OUT NOCOPY NUMBER
);

-- End Supplier Management: Bug 12849540

END POS_VENDOR_REG_PKG;

/
