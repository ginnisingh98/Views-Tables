--------------------------------------------------------
--  DDL for Package DOM_COMMON_ATTACHMENT_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_COMMON_ATTACHMENT_SECURITY" AUTHID CURRENT_USER AS
/* $Header: DOMSECPS.pls 120.3.12010000.3 2009/04/09 10:14:02 chechand ship $ */
/*---------------------------------------------------------------------------+
 | This package contains APIs to reslove docuemnt security mappings          |
 | based on fnd data security                                                |
 +---------------------------------------------------------------------------*/

FUNCTION GET_DOC_ATTACHMENT_PRIVILEGES
(
p_entity_name IN VARCHAR2,
p_pk1_value IN VARCHAR2,
p_pk2_value IN VARCHAR2,
p_pk3_value IN VARCHAR2,
p_pk4_value IN VARCHAR2,
p_pk5_value IN VARCHAR2,
p_user_id IN VARCHAR2,
p_attachment_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2;

------------------------------------------------------------------

FUNCTION GET_ATTACHMENT_PRIVILAGES
(
p_entity_name IN VARCHAR2,
p_pk1_value IN VARCHAR2,
p_pk2_value IN VARCHAR2,
p_pk3_value IN VARCHAR2,
p_pk4_value IN VARCHAR2,
p_pk5_value IN VARCHAR2,
p_user_id IN VARCHAR2,
p_attachment_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2;
END DOM_COMMON_ATTACHMENT_SECURITY;

/
