--------------------------------------------------------
--  DDL for Package POS_USER_ADMIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_USER_ADMIN_PKG" AUTHID CURRENT_USER as
/*$Header: POSADMS.pls 120.16.12010000.5 2014/07/24 09:22:46 ppotnuru ship $ */

procedure reset_password
  ( p_user_id           IN  NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

PROCEDURE set_user_inactive_date
  ( p_user_id            IN NUMBER
  , p_inactive_date      IN DATE
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

procedure grant_user_resp
  ( p_user_id           IN  NUMBER
  , p_resp_id           IN  NUMBER
  , p_resp_app_id       IN  NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

procedure grant_user_resps
  ( p_user_id           IN  NUMBER
  , p_resp_ids          IN  po_tbl_number
  , p_resp_app_ids      IN  po_tbl_number
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

procedure revoke_user_resp
  ( p_user_id           IN  NUMBER
  , p_resp_id           IN  NUMBER
  , p_resp_app_id       IN  NUMBER
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

procedure revoke_user_resps
  ( p_user_id           IN  NUMBER
  , p_resp_ids          IN  po_tbl_number
  , p_resp_app_ids      IN  po_tbl_number
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

procedure update_user_info
  ( p_party_id          IN  NUMBER
  , p_user_name_prefix  IN  VARCHAR2
  , p_user_name_f       IN  VARCHAR2
  , p_user_name_m       IN  VARCHAR2
  , p_user_name_l       IN  VARCHAR2
  , p_user_title        IN  VARCHAR2
  , p_user_email        IN  VARCHAR2
  , p_user_phone        IN  VARCHAR2
  , p_user_extension    IN  VARCHAR2
  , p_user_fax          IN  VARCHAR2
  , x_return_status     OUT NOCOPY VARCHAR2
  , x_msg_count         OUT NOCOPY NUMBER
  , x_msg_data          OUT NOCOPY VARCHAR2
  );

PROCEDURE createsecattr
  ( p_user_id        IN NUMBER
  , p_attribute_code IN VARCHAR2
  , p_app_id         IN NUMBER
  , p_varchar2_value IN VARCHAR2 DEFAULT NULL
  , p_date_value     IN DATE DEFAULT NULL
  , p_number_value   IN NUMBER DEFAULT NULL
  );

PROCEDURE deletesecattr
  ( p_user_id        IN NUMBER
  , p_attribute_code IN VARCHAR2
  , p_app_id         IN NUMBER
  , p_varchar2_value IN VARCHAR2 DEFAULT NULL
  , p_date_value     IN DATE DEFAULT NULL
  , p_number_value   IN NUMBER DEFAULT NULL
  );

PROCEDURE create_supplier_user_account
  (p_user_name        IN  VARCHAR2,
   p_user_email       IN  VARCHAR2,
   p_person_party_id  IN  NUMBER,
   p_resp_ids         IN  po_tbl_number,
   p_resp_app_ids     IN  po_tbl_number,
   p_sec_attr_codes   IN  po_tbl_varchar30,
   p_sec_attr_numbers IN  po_tbl_number,
   p_password         IN  VARCHAR2 DEFAULT NULL,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   x_user_id          OUT NOCOPY NUMBER,
   x_password         OUT NOCOPY VARCHAR2
   );

-- this version does not assign responsibility or securing attributes
PROCEDURE create_supplier_user_account
  (p_user_name       IN  VARCHAR2,
   p_user_email      IN  VARCHAR2,
   p_person_party_id IN  NUMBER,
   p_password        IN  VARCHAR2 DEFAULT NULL,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   x_user_id         OUT NOCOPY NUMBER,
   x_password        OUT NOCOPY VARCHAR2
   );

-- this version does not assign responsibility or securing attributes
-- It send out an email to the user with the username and password info.
PROCEDURE create_supplier_user_ntf
  (p_user_name       IN  VARCHAR2,
   p_user_email      IN  VARCHAR2,
   p_person_party_id IN  NUMBER,
   p_password        IN  VARCHAR2 DEFAULT NULL,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   x_user_id         OUT NOCOPY NUMBER,
   x_password        OUT NOCOPY VARCHAR2
   );

-- assign the user with default responsibilities
-- as required for the supplier registation approval logic
-- Note: pass Y to p_pon_def_also to assign default responsibility for
-- sourcing (bug 5415703)
PROCEDURE assign_vendor_reg_def_resp
  (p_user_id         IN  NUMBER,
   p_vendor_id       IN  NUMBER,
   p_pon_def_also    IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
   );

-- The following are backward compatible versions of some of the
-- procedures above. The difference between these and their
-- corresponding versions above is that the error messages
-- are combined into one in the output parameter.
--
-- For new code, please use the new versions above

procedure grant_user_resp
  ( p_user_id           IN  NUMBER
  , p_resp_id           IN  NUMBER
  , p_resp_app_id       IN  NUMBER
  , x_status            OUT NOCOPY VARCHAR2
  , x_exception_msg     OUT NOCOPY VARCHAR2
  );

procedure revoke_user_resp
  ( p_user_id           IN  NUMBER
  , p_resp_id           IN  NUMBER
  , p_resp_app_id       IN  NUMBER
  , x_status            OUT NOCOPY VARCHAR2
  , x_exception_msg     OUT NOCOPY VARCHAR2
  );

procedure update_user_info
  ( p_party_id          IN  NUMBER
  , p_user_name_prefix  IN  VARCHAR2
  , p_user_name_f       IN  VARCHAR2
  , p_user_name_m       IN  VARCHAR2
  , p_user_name_l       IN  VARCHAR2
  , p_user_title        IN  VARCHAR2
  , p_user_email        IN  VARCHAR2
  , p_user_phone        IN  VARCHAR2
  , p_user_extension    IN  VARCHAR2
  , p_user_fax          IN  VARCHAR2
  , x_status            OUT NOCOPY VARCHAR2
  , x_exception_msg     OUT NOCOPY VARCHAR2
  );

/* Added following procedure for Business Classification Recertification ER
7489217 */
procedure add_certntf_subscription
  ( p_user_id           IN  NUMBER
  , x_status            OUT NOCOPY VARCHAR2
  , x_exception_msg     OUT NOCOPY VARCHAR2
  );

procedure remove_certntf_subscription
  ( p_user_id           IN  NUMBER
  , x_status            OUT NOCOPY VARCHAR2
  , x_exception_msg     OUT NOCOPY VARCHAR2
  );

procedure get_certntf_subscription
  ( p_user_id           IN  NUMBER
  , x_subscr_exists     OUT NOCOPY VARCHAR2
  );

-- Bug 8325979 - Replacing the message subject and body with FND Message and its tokens

FUNCTION GET_SUPP_USER_ACCNT_SUBJECT(p_enterprise_name IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE GENERATE_SUPP_USER_ACCNT_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

procedure send_mail_contact
  ( p_user_id           IN  NUMBER
  , p_end_date          IN DATE
  , p_result    IN OUT NOCOPY VARCHAR2
  );


END POS_USER_ADMIN_PKG;

/
