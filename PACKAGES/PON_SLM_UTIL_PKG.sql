--------------------------------------------------------
--  DDL for Package PON_SLM_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_SLM_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: PONSLMUTLS.pls 120.0.12010000.3 2014/10/21 06:52:06 spapana noship $ */

--SLM UI Enhancement
SLM_MESSAGE_SUFFIX CONSTANT VARCHAR2(1) := 'Z';
SLM_MESSAGE_SUFFIX_UNDERSCORE CONSTANT VARCHAR2(2) := '_Z';
SLM_WF_ATTR CONSTANT VARCHAR2(12) := 'SLM_DOC_TYPE';
g_is_slm_doc varchar2(1) := 'N';

/* SLM UI Enhancement : This api checks if document is assessment.
 * If assessment, return _Z
 * Else call above api.
*/
FUNCTION GET_AUCTION_MESSAGE_SUFFIX (p_auction_header_id IN NUMBER,
                                     p_doctype_group_name IN VARCHAR2) RETURN VARCHAR2;

/* SLM UI Enhancement : This api returns _Z for SLM
 * and doctype suffix for non-SLM
*/
FUNCTION GET_SLM_NEG_MESSAGE_SUFFIX(is_slm_doc IN VARCHAR2,
                                    p_doctype_group_name IN VARCHAR2) RETURN VARCHAR2;

/* SLM UI Enhancement : This api checks if this is a SLM Document or not
 * See if we need to check profile value also?
*/
FUNCTION IS_SLM_DOCUMENT(p_auction_header_id IN NUMBER) RETURN VARCHAR2;

/* SLM UI Enhancement : This api returns Assessment for SLM
 * and Negotiaiton for non-SLM
*/
FUNCTION GET_SLM_NEG_MESSAGE(is_slm_doc IN VARCHAR2) RETURN VARCHAR2;

/* SLM UI Enhancement : This api sets SLM_DOC_TYPE attribute of the workflow
 * Every workflow should use same internal name for the attribute.
*/
PROCEDURE SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype IN VARCHAR2,
                                     p_itemkey  IN VARCHAR2,
                                     p_auction_header_id IN NUMBER);

--SLM UI Enhancement
PROCEDURE SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype IN VARCHAR2,
                                     p_itemkey  IN VARCHAR2,
                                     p_value    IN VARCHAR2);

FUNCTION GET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype in varchar2,
                                    p_itemkey in varchar2) return varchar2;


PROCEDURE SET_SLM_DOC_TYPE_NOTIF_ATTR(p_nid  IN  NUMBER,
                                      p_value  IN  VARCHAR2);

END PON_SLM_UTIL_PKG;

/
