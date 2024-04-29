--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_USER_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_USER_REG_PKG" AUTHID CURRENT_USER AS
/* $Header: POSUREGS.pls 120.2.12010000.2 2009/04/04 09:21:18 sthoppan ship $ */

PROCEDURE approve
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   );

PROCEDURE reject
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   );

PROCEDURE invite
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   );

PROCEDURE respond
  (p_registration_id IN  NUMBER,
   x_return_status   OUT nocopy VARCHAR2,
   x_msg_count       OUT nocopy NUMBER,
   x_msg_data        OUT nocopy VARCHAR2
   );

-- The following methods are exposed in spec to allow debugging.
-- There are not meant to be used by other packages
FUNCTION is_invited (p_registration_id IN NUMBER) RETURN VARCHAR2;

FUNCTION set_initial_password(l_reg_id NUMBER)  RETURN varchar2;

PROCEDURE set_profile_opt_ext_user
(p_userid in number);

-- Bug 8325979 - Replacing the message subject and body with FND Message and its tokens

FUNCTION GET_APPRV_REG_USR_SUBJECT(p_enterprise_name IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE GENERATE_APPRV_REG_USR_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);


END pos_supplier_user_reg_pkg;

/
