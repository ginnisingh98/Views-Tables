--------------------------------------------------------
--  DDL for Package WFA_HTML_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WFA_HTML_JSP" AUTHID CURRENT_USER as
/* $Header: wfjsps.pls 120.6 2006/04/27 23:46:05 hgandiko noship $ */

/* get notification id given item type, item key, username.
 ** Created for integration with SSP Orders to Approve
 **/
function getSSPNid (
username IN VARCHAR2,
itemtype  IN VARCHAR2,
itemkey       IN VARCHAR2
)
return number;
pragma restrict_references(getSSPNid, WNDS, WNPS);

/* get notification id given item type, item key, username.
 ** Created for integration with SSP Orders to Approve
 ** returns open notifications only
 **/
function getSSPOpenNid (
username IN VARCHAR2,
itemtype  IN VARCHAR2,
itemkey       IN VARCHAR2
)
return number;
pragma restrict_references(getSSPOpenNid, WNDS, WNPS);

end WFA_HTML_JSP;
 

/
