--------------------------------------------------------
--  DDL for Package XXAH_VPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_VPD_PKG" AS
--#########################################################################
--#
--#                 Copyright (c) 2010 Oracle Corporation
--#                        All rights reserved
--#
--#########################################################################
--#
--# Application   : Ahold Customizations
--# Module        :
--# File          : $RCSfile: xxahvpd.pls $
--# Version       : $Revision: 1.0 $
--# Description   : Package containing functions and procedures related to
--#                 the implementation of a VPD security
--#
--#
--# Date        Authors           Change reference/Description
--# ----------- ----------------- ----------------------------------
--# 01-DEC-2010 Johan Peeters     Initial version
--#
--#
--##########################################################################
--
-- package variables

g_key_number_attribute_id     NUMBER;

-- procedure and function definitions
FUNCTION parent_child_org(p_organization_id NUMBER
                         ,p_direction       VARCHAR2
                         ) RETURN VARCHAR2;
--
FUNCTION get_hash_key(p_salesrep_id NUMBER
                     ,p_buyer_id      NUMBER
                     ,p_user_id     NUMBER
                     ,p_level       VARCHAR2
                     ,p_creation_date DATE DEFAULT SYSDATE
                     ) RETURN VARCHAR2;
--
FUNCTION is_approver(p_user_id        NUMBER
                    ,p_application_id NUMBER
                    ,p_trx_id         NUMBER
                    ) RETURN VARCHAR2;
--
FUNCTION xxbi_access_allowed(p_hash_key      VARCHAR2
                            ,p_user_id       NUMBER
                            ) RETURN VARCHAR2;
--
FUNCTION access_allowed(p_entity        VARCHAR2
                       ,p_reference_id  NUMBER
                       ,p_user_id     NUMBER
                       ,p_header_id   NUMBER
                       ,p_creation_date DATE DEFAULT SYSDATE
                       ,p_doc_type      VARCHAR2
                       ) RETURN VARCHAR2;
--
FUNCTION policy_oe_blanket_headers(obj_schema VARCHAR2
				                              ,obj_name VARCHAR2) RETURN VARCHAR2;
--
FUNCTION policy_po_headers (obj_schema IN VARCHAR2
                           ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2;
--
FUNCTION policy_okc_rep_contracts (obj_schema IN VARCHAR2
                                  ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2;
--
FUNCTION policy_pon_auction_headers (obj_schema IN VARCHAR2
                                    ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2;
--
FUNCTION policy_xxbi_va_bh_bl_oh_ol (obj_schema IN VARCHAR2
                                    ,obj_name   IN VARCHAR2  ) RETURN VARCHAR2;
--
END  xxah_Vpd_Pkg;
 

/

  GRANT EXECUTE ON "APPS"."XXAH_VPD_PKG" TO "EBSBI";
