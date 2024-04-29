--------------------------------------------------------
--  DDL for Package POR_ITEM_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_ITEM_ATTRIBUTES_PKG" AUTHID CURRENT_USER AS
/* $Header: PORATTRS.pls 115.2 2003/11/14 02:44:57 kaholee ship $ */


procedure Create_Attach_Item_Attr(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

/******************************************************************
 * Gets Requisition Lines that have associated adhoc data         *
 ******************************************************************/
PROCEDURE add_attribute_attachment(p_req_header_id IN NUMBER,
                                   p_item_type IN VARCHAR2,
                                   p_category_id IN NUMBER DEFAULT 33,
                                   p_wf_item_type IN VARCHAR2,
                                   p_wf_item_key IN VARCHAR2);

/******************************************************************
 * Concatenate all attribute codes and values into a text value   *
 * for an associated Requisition Line.                            *
 ******************************************************************/
PROCEDURE get_attach_text(p_requisition_line_id   IN NUMBER,
                          p_requisition_header_id IN NUMBER,
                          p_item_type             IN VARCHAR2,
                          p_text 		  OUT NOCOPY LONG);

/* 2977976
   Appends the parameter m_a1 to m_a15 to the existing text
   if  the value of the parameters m_a1 to m_a15 is not null
*/
function append_if_not_null(existing_text IN long,
                            m_a1 IN varchar2,
                            m_a2 IN varchar2,
                            m_a3 IN varchar2,
                            m_a4 IN varchar2,
                            m_a5 IN varchar2,
                            m_a6 IN varchar2,
                            m_a7 IN varchar2,
                            m_a8 IN varchar2,
                            m_a9 IN varchar2,
                            m_a10 IN varchar2,
                            m_a11 IN varchar2,
                            m_a12 IN varchar2,
                            m_a13 IN varchar2,
                            m_a14 IN varchar2,
                            m_a15 IN varchar2)
return long;

END POR_ITEM_ATTRIBUTES_PKG;

 

/
