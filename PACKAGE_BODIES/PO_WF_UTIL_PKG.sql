--------------------------------------------------------
--  DDL for Package Body PO_WF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_UTIL_PKG" AS
/* $Header: POXWUTLB.pls 120.2.12010000.2 2012/05/21 11:24:37 smvinod ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
 /*=======================================================================+
 | FILENAME
 |  POXWUTLB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package: PO_WF_UTIL_PKG
 |
 | NOTES
 | CREATE
 | MODIFIED
 *=====================================================================*/

procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2) is

BEGIN

      wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => aname,
                                 avalue   => avalue);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.SetItemAttrText: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;

END SetItemAttrText;

-- PO AME Project
procedure SetItemAttrText(aname in varchar2,
                          avalue in varchar2) is
BEGIN
      wf_engine.SetItemAttrText (itemtype => G_ITEM_TYPE,
                                 itemkey  => G_ITEM_KEY,
                                 aname    => aname,
                                 avalue   => avalue);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(G_ITEM_TYPE,
                                     G_ITEM_KEY,
                                     'PO_WF_UTIL_PKG.SetItemAttrText: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;

END SetItemAttrText;


procedure SetItemAttrNumber(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in number) is

BEGIN

      wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => aname,
                                   avalue   => avalue);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.SetItemAttrNumber: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;

END SetItemAttrNumber;

-- PO AME Project
procedure SetItemAttrNumber(aname in varchar2,
                          avalue in number) is

BEGIN

      wf_engine.SetItemAttrNumber (itemtype => G_ITEM_TYPE,
                                   itemkey  => G_ITEM_KEY,
                                   aname    => aname,
                                   avalue   => avalue);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(G_ITEM_TYPE,
                                     G_ITEM_KEY,
                                     'PO_WF_UTIL_PKG.SetItemAttrNumber: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;

END SetItemAttrNumber;
--

procedure SetItemAttrDate(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in date) is

BEGIN

      wf_engine.SetItemAttrDate (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => aname,
                                 avalue   => avalue);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.SetItemAttrDate: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;

END SetItemAttrDate;

--

procedure SetItemAttrDocument(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          documentid in varchar2) is

BEGIN

      wf_engine.SetItemAttrDocument (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => aname,
                                 documentid   => documentid);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.SetItemAttrDocument: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;

END SetItemAttrDocument;

--

function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2)
return varchar2 is

BEGIN

  return wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => aname,
                                   ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.GetItemAttrText: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetItemAttrText;

-- PO AME Project
function GetItemAttrText(aname in varchar2)
return varchar2 is

BEGIN

  return wf_engine.GetItemAttrText(itemtype => G_ITEM_TYPE,
                                   itemkey  => G_ITEM_KEY,
                                   aname    => aname,
                                   ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(G_ITEM_TYPE,
                                     G_ITEM_KEY,
                                     'PO_WF_UTIL_PKG.GetItemAttrText: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetItemAttrText;

function GetItemAttrNumber(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2)
return number is

BEGIN

  return wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => aname,
                                   ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.GetItemAttrNumber: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetItemAttrNumber;

-- PO AME Project

function GetItemAttrNumber(aname in varchar2)
return number is

BEGIN

  return wf_engine.GetItemAttrNumber(itemtype => G_ITEM_TYPE,
                                   itemkey  => G_ITEM_KEY,
                                   aname    => aname,
                                   ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(G_ITEM_TYPE,
                                     G_ITEM_KEY,
                                     'PO_WF_UTIL_PKG.GetItemAttrNumber: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetItemAttrNumber;

function GetItemAttrDate(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2)
return date is

BEGIN

  return wf_engine.GetItemAttrDate(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => aname,
                                   ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.GetItemAttrDate: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetItemAttrDate;

--

function GetItemAttrDocument(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2)
return VARCHAR2 is

BEGIN

  return wf_engine.GetItemAttrDocument(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => aname,
                                   ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.GetItemAttrDocument: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetItemAttrDocument;

--

function GetActivityAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2)
return varchar2 is

BEGIN

  return wf_engine.GetActivityAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       actid    => actid,
                                       aname    => aname,
                                       ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.GetActivityAttrText: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetActivityAttrText;

--

function GetActivityAttrNumber(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2)
return number is

BEGIN

  return wf_engine.GetActivityAttrNumber(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       actid    => actid,
                                       aname    => aname,
                                       ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.GetActivityAttrNumber: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetActivityAttrNumber;

--

function GetActivityAttrDate(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2)
return date is

BEGIN

  return wf_engine.GetActivityAttrDate(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       actid    => actid,
                                       aname    => aname,
                                       ignore_notfound => TRUE);

EXCEPTION
   WHEN OTHERS THEN
     IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                     itemkey,
                                     'PO_WF_UTIL_PKG.GetActivityAttrDate: ' || aname ||
                                     ' ' || sqlerrm);
     END IF;
     return NULL;

END GetActivityAttrDate;


-- bug5075361 START

-----------------------------------------------------------------------
--Start of Comments
--Name: clear_wf_cache
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Clear any cache that's maintained by WF. This is useful to clear
--  the cache for wf running in synchronize mode at the end so that
--  subsequent process will not be blocked in case this wf fails to
--  complete.
--Parameters:
--IN:
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE clear_wf_cache IS

l_progress VARCHAR2(10);

BEGIN

  l_progress := '000';
  WF_ENGINE_UTIL.clearcache;

  l_progress := '010';
  WF_ACTIVITY.clearcache;

  l_progress := '020';
  WF_ITEM_ACTIVITY_STATUS.clearcache;

  l_progress := '030';
  WF_ITEM.clearcache;

  l_progress := '040';
  WF_PROCESS_ACTIVITY.clearcache;

EXCEPTION
WHEN OTHERS THEN

  PO_MESSAGE_S.sql_error ('PO_WF_UTIL_PKG.clear_wf_cache', l_progress, sqlcode);
  RAISE;

END clear_wf_cache;

-- bug5075361 END

-- bug 4720152 Start
FUNCTION GetWorkflowErrorMessage
 	 RETURN VARCHAR2 IS
 	 BEGIN
 	   return wf_core.error_message;
END GetWorkflowErrorMessage;
-- bug 4720152 END
end PO_WF_UTIL_PKG;

/
