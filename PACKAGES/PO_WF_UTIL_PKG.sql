--------------------------------------------------------
--  DDL for Package PO_WF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_WF_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: POXWUTLS.pls 120.2.12010000.2 2012/05/21 11:23:55 smvinod ship $ */
 /*=======================================================================+
 | FILENAME
 |  POXWUTLS.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_WF_UTIL_PKG
 |
 |   This package is a wrapper package to set and get workflow attributes
 |   with exception catched.
 |
 | NOTES
 | CREATE
 | MODIFIED
 *=====================================================================*/
-- PO AME Project
G_ITEM_TYPE wf_items.item_type%TYPE;
G_ITEM_KEY wf_items.item_key%TYPE;

procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2);

-- PO AME Project
procedure SetItemAttrText(aname in varchar2,
                          avalue in varchar2);

procedure SetItemAttrNumber(itemtype in varchar2,
                            itemkey in varchar2,
                            aname in varchar2,
                            avalue in number);

-- PO AME Project
procedure SetItemAttrNumber(aname in varchar2,
                            avalue in number);

procedure SetItemAttrDate(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in date);

procedure SetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              documentid in varchar2);


function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2)
return varchar2;

-- PO AME Project
function GetItemAttrText(aname in varchar2)
return varchar2;

function GetItemAttrNumber(itemtype in varchar2,
                           itemkey in varchar2,
                           aname in varchar2)
return number;

-- PO AME Project
function GetItemAttrNumber(aname in varchar2)
return number;

function GetItemAttrDate (itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2)
return date;

Function GetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2)
RETURN VARCHAR2;

function GetActivityAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2)
return varchar2;

function GetActivityAttrNumber(itemtype in varchar2,
                               itemkey in varchar2,
                               actid in number,
                               aname in varchar2)
return number;


function GetActivityAttrDate(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2)
return date;


-- bug5075361 START
PROCEDURE clear_wf_cache;
-- bug5075361 END

-- bug 4720152
function GetWorkflowErrorMessage
 return varchar2;
-- bug 4720152

end PO_WF_UTIL_PKG;

/
