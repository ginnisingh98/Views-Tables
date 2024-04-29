--------------------------------------------------------
--  DDL for Package Body PON_SLM_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_SLM_UTIL_PKG" as
/* $Header: PONSLMUTLB.pls 120.0.12010000.3 2014/10/21 06:51:12 spapana noship $ */

/* SLM UI Enhancement : This api checks if this is a SLM Document or not
 * See if we need to check profile value also?
*/
FUNCTION IS_SLM_DOCUMENT(p_auction_header_id IN NUMBER) RETURN VARCHAR2 IS

l_is_slm_doc VARCHAR2(1);
BEGIN
     l_is_slm_doc := 'N';
     SELECT Decode(Nvl(SUPP_REG_QUAL_FLAG, 'N'), 'Y', 'Y',
                  'N', Nvl(SUPP_EVAL_FLAG, 'N'), 'Y', 'Y','N')
     INTO l_is_slm_doc
     FROM pon_auction_headers_all
     WHERE auction_header_id = p_auction_header_id;

     g_is_slm_doc := l_is_slm_doc;

     RETURN l_is_slm_doc;

END IS_SLM_DOCUMENT;

/* SLM UI Enhancement : This api returns Assessment for SLM
 * and Negotiaiton for non-SLM
*/
FUNCTION GET_SLM_NEG_MESSAGE(is_slm_doc IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN
     IF is_slm_doc = 'Y' THEN

        RETURN fnd_message.get_string('PON', 'PON_AUC_NEG_Z');

     ELSE

        RETURN fnd_message.get_string('PON', 'PON_AUC_NEG');

     END IF;

END GET_SLM_NEG_MESSAGE;

/* SLM UI Enhancement : This api returns _Z for SLM
 * and doctype suffix for non-SLM
*/
FUNCTION GET_SLM_NEG_MESSAGE_SUFFIX(is_slm_doc IN VARCHAR2,
                                    p_doctype_group_name IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN
     IF is_slm_doc = 'Y' THEN

        RETURN SLM_MESSAGE_SUFFIX_UNDERSCORE;

     ELSE

        RETURN PON_AUCTION_PKG.GET_MESSAGE_SUFFIX(p_doctype_group_name);

     END IF;

END GET_SLM_NEG_MESSAGE_SUFFIX;

PROCEDURE SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype IN VARCHAR2,
                                     p_itemkey  IN VARCHAR2,
                                     p_value    IN VARCHAR2)
IS

BEGIN

PON_WF_UTL_PKG.SetItemAttrText(itemtype =>  p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => SLM_WF_ATTR,
                                avalue   => p_value);

END SET_SLM_DOC_TYPE_ATTRIBUTE;

FUNCTION GET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype in varchar2,
                                    p_itemkey in varchar2)
RETURN VARCHAR2 IS

BEGIN
  RETURN PON_WF_UTL_PKG.GetItemAttrText(itemtype =>  p_itemtype,
                                         itemkey  => p_itemkey,
                                         aname    => SLM_WF_ATTR);


END GET_SLM_DOC_TYPE_ATTRIBUTE;


/* SLM UI Enhancement : This api sets SLM_DOC_TYPE attribute of the workflow
 * Every workflow should use same internal name for the attribute.
*/
PROCEDURE SET_SLM_DOC_TYPE_ATTRIBUTE(p_itemtype IN VARCHAR2,
                                     p_itemkey  IN VARCHAR2,
                                     p_auction_header_id IN NUMBER)
IS

l_neg_assess_doctype VARCHAR2(15);
l_is_slm_doc  VARCHAR2(1);
BEGIN

     l_is_slm_doc := IS_SLM_DOCUMENT(p_auction_header_id);
     l_neg_assess_doctype := GET_SLM_NEG_MESSAGE(l_is_slm_doc);
     SET_SLM_DOC_TYPE_ATTRIBUTE  (p_itemtype   => p_itemType,
                                  p_itemkey    => p_itemKey,
                                  p_value      => l_neg_assess_doctype);

END SET_SLM_DOC_TYPE_ATTRIBUTE;

/* SLM UI Enhancement : This api checks if document is assessment.
 * If assessment, return _Z
 * Else call above api.
*/
FUNCTION GET_AUCTION_MESSAGE_SUFFIX (p_auction_header_id IN NUMBER,
                                     p_doctype_group_name IN VARCHAR2) RETURN VARCHAR2

IS
l_is_slm_doc VARCHAR2(1);

BEGIN

    l_is_slm_doc := IS_SLM_DOCUMENT(p_auction_header_id);

    RETURN GET_SLM_NEG_MESSAGE_SUFFIX(l_is_slm_doc, p_doctype_group_name);

END GET_AUCTION_MESSAGE_SUFFIX;

PROCEDURE SET_SLM_DOC_TYPE_NOTIF_ATTR(p_nid  IN  NUMBER,
                                      p_value  IN  VARCHAR2)

IS

BEGIN

PON_WF_UTL_PKG.SetNotifAttrText(nid => p_nid,
                                aname => SLM_WF_ATTR,
                                avalue => p_value);

END SET_SLM_DOC_TYPE_NOTIF_ATTR;


END PON_SLM_UTIL_PKG;

/
