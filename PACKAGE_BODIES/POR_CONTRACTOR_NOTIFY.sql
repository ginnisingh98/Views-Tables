--------------------------------------------------------
--  DDL for Package Body POR_CONTRACTOR_NOTIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_CONTRACTOR_NOTIFY" AS
/* $Header: PORGCNTB.pls 120.0.12010000.2 2011/03/25 08:56:12 mmaramga ship $*/

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_pkg_name CONSTANT VARCHAR2(50) := 'POR_CONTRACTOR_NOTIFY';
g_module_prefix CONSTANT VARCHAR2(50) := 'por.plsql.' || g_pkg_name || '.';

/*===========================================================================
  PROCEDURE NAME: SUPPLIER_NEED_NOTIFY
  DESCRIPTION:    Checks if supplier for this requisition needs to be notified
===========================================================================*/

PROCEDURE SUPPLIER_NEED_NOTIFY (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 )
IS

  L_REQ_HEADER_ID Number;
  L_CONTR_ASSIGN_REQD VARCHAR2(1) := 'N';
  L_CONTRACTOR_STATUS   PO_REQUISITION_HEADERS_ALL.CONTRACTOR_STATUS%TYPE;
  L_SUPPLIER_NOTIFIED_FLAG  PO_REQUISITION_HEADERS_ALL.SUPPLIER_NOTIFIED_FLAG%TYPE;

BEGIN

  L_REQ_HEADER_ID := WF_ENGINE.GETITEMATTRNUMBER
                                          (ITEMTYPE   => ITEMTYPE,
                                           ITEMKEY    => ITEMKEY,
                                         ANAME      => 'DOCUMENT_ID');

  --Query the supplires which need to be notified for this requisition
  SELECT CONTRACTOR_STATUS, SUPPLIER_NOTIFIED_FLAG
    INTO L_CONTRACTOR_STATUS, L_SUPPLIER_NOTIFIED_FLAG
    FROM PO_REQUISITION_HEADERS_ALL
   WHERE REQUISITION_HEADER_ID = L_REQ_HEADER_ID;

  IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	  g_module_prefix || 'SUPPLIER_NEED_NOTIFY' ||
          'L_CONTRACTOR_STATUS, L_SUPPLIER_NOTIFIED_FLAG: ' ||
          L_CONTRACTOR_STATUS|| ',' ||  L_SUPPLIER_NOTIFIED_FLAG);
  end if;

  IF L_CONTRACTOR_STATUS = 'PENDING' AND  nvl(L_SUPPLIER_NOTIFIED_FLAG,'N') = 'N' THEN
	L_CONTR_ASSIGN_REQD := 'Y';
  ELSE
	L_CONTR_ASSIGN_REQD := 'N';
  END IF;

  RESULTOUT := WF_ENGINE.ENG_COMPLETED || ':' ||  L_CONTR_ASSIGN_REQD;

EXCEPTION
   WHEN OTHERS THEN
     IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, g_module_prefix || 'SUPPLIER_NEED_NOTIFY' || sqlerrm);
     END IF;

END SUPPLIER_NEED_NOTIFY;


PROCEDURE SELECT_SUPPLIER_NOTIFY (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 )
IS

  L_REQUISITION_SUPPLIER_ID   PO_REQUISITION_SUPPLIERS.REQUISITION_SUPPLIER_ID%TYPE;
  L_REQ_HEADER_ID             PO_REQUISITION_HEADERS_ALL.REQUISITION_HEADER_ID%TYPE;
  L_SUPPLIER_EXISTS           VARCHAR2(50);
  L_NOTIFIER                  WF_USER_ROLES.ROLE_NAME%TYPE;
  L_START_DATE                PO_REQUISITION_LINES_ALL.ASSIGNMENT_START_DATE%TYPE;
  L_JOB_DESCRIPTION           PO_REQUISITION_LINES_ALL.ITEM_DESCRIPTION%TYPE;
  L_COMPANY_NAME              varchar2(100);
  L_REQ_NUM_LINE_NUM          varchar2(100);
  L_STATUS                    varchar2(1);
  L_EXP_MSG                   varchar2(100);
  L_REQUISITION_LINE_ID       PO_REQUISITION_LINES_ALL.REQUISITION_LINE_ID%TYPE;
  L_LINE_NUM     PO_REQUISITION_LINES_ALL.LINE_NUM%TYPE;
  L_VENDOR_NAME	 PO_VENDORS.VENDOR_NAME%TYPE;

BEGIN

  L_REQ_HEADER_ID := WF_ENGINE.GETITEMATTRNUMBER
                                          (ITEMTYPE   => ITEMTYPE,
                                           ITEMKEY    => ITEMKEY,
                                         ANAME      => 'DOCUMENT_ID');
--To be removed
    if L_REQ_HEADER_ID is not null then
       UPDATE PO_REQUISITION_HEADERS_ALL
 	   SET SUPPLIER_NOTIFIED_FLAG = 'Y'
         WHERE REQUISITION_HEADER_ID = L_REQ_HEADER_ID;
    end if;

  --Query the suppliers which need to be notified for this requisition
      BEGIN

      SELECT MAX(PLS.REQUISITION_SUPPLIER_ID)
	INTO L_REQUISITION_SUPPLIER_ID
        FROM PO_REQUISITION_SUPPLIERS PLS,
             PO_REQUISITION_LINES_ALL PORL
       WHERE NVL(PLS.SUPPLIER_NOTIFIED_FLAG,'N') = 'N'
         AND PORL.REQUISITION_LINE_ID = PLS.REQUISITION_LINE_ID
         AND PORL.REQUISITION_HEADER_ID = L_REQ_HEADER_ID;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  L_REQUISITION_SUPPLIER_ID := NULL;
      END;

      IF L_REQUISITION_SUPPLIER_ID IS NULL THEN

	L_SUPPLIER_EXISTS := 'ALL_SUPPLIER_NOTIFIED';
        UPDATE PO_REQUISITION_HEADERS_ALL
 	   SET SUPPLIER_NOTIFIED_FLAG = 'Y'
         WHERE REQUISITION_HEADER_ID = L_REQ_HEADER_ID;

      ELSE

      SELECT PORL.ASSIGNMENT_START_DATE,
             PORL.ITEM_DESCRIPTION, PORH.SEGMENT1 || ' / ' ||  PORL.LINE_NUM, PORL.REQUISITION_LINE_ID
	INTO L_START_DATE, L_JOB_DESCRIPTION, L_REQ_NUM_LINE_NUM, L_REQUISITION_LINE_ID
        FROM PO_REQUISITION_SUPPLIERS PLS,
             PO_REQUISITION_LINES_ALL PORL,
             PO_REQUISITION_HEADERS_ALL PORH
       WHERE PORL.REQUISITION_LINE_ID = PLS.REQUISITION_LINE_ID
         AND PLS.REQUISITION_SUPPLIER_ID = L_REQUISITION_SUPPLIER_ID
         AND PORL.REQUISITION_HEADER_ID = PORH.REQUISITION_HEADER_ID;

      IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	  g_module_prefix || 'SELECT_SUPPLIER_NOTIFY' ||
          'L_START_DATE, L_JOB_DESCRIPTION, L_REQUISITION_SUPPLIER_ID: ' ||
          L_START_DATE || ',' ||  L_JOB_DESCRIPTION || ',' ||
	  L_REQUISITION_SUPPLIER_ID);
      end if;

        WF_ENGINE.SETITEMATTRNUMBER
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'REQUISITION_SUPPLIER_ID',
                         AVALUE     => L_REQUISITION_SUPPLIER_ID);

  	WF_ENGINE.SETITEMATTRTEXT
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'JOB_DESCRIPTION',
                         AVALUE     => L_JOB_DESCRIPTION);

	WF_ENGINE.SETITEMATTRDATE
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'START_DATE',
                         AVALUE     => L_START_DATE);

	POS_ENTERPRISE_UTIL_PKG.GET_ENTERPRISE_PARTY_NAME(L_COMPANY_NAME, L_EXP_MSG, L_STATUS);

	WF_ENGINE.SETITEMATTRTEXT
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'COMPANY_DISPLAY_NAME',
                         AVALUE     => L_COMPANY_NAME);

	WF_ENGINE.SETITEMATTRTEXT
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'REQ_NUM_LINE_NUM',
                         AVALUE     => L_REQ_NUM_LINE_NUM);

       WF_ENGINE.SetItemAttrDocument(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'LINE_ATTACHMENT',
                                      documentid   =>
           'FND:entity=REQ_LINES' || '&' || 'pk1name=REQUISITION_LINE_ID' ||
           '&' || 'pk1value='|| L_REQUISITION_LINE_ID ||
           '&' || 'categories=Vendor');

      PO_REQAPPROVAL_INIT1.LOCATE_NOTIFIER(L_REQUISITION_SUPPLIER_ID, 'RS', L_NOTIFIER);

      IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
        g_module_prefix || 'SELECT_SUPPLIER_NOTIFY' || 'L_NOTIFIER: ' || L_NOTIFIER || ' L_REQUISITION_SUPPLIER_ID :' || L_REQUISITION_SUPPLIER_ID);
      end if;

      IF (L_NOTIFIER IS NULL) THEN
        L_NOTIFIER := GET_ADHOC_EMAIL_ROLE(L_REQUISITION_SUPPLIER_ID, NULL, ITEMTYPE, ITEMKEY);
      END IF;

      IF (L_NOTIFIER IS NOT NULL) THEN

   	WF_ENGINE.SETITEMATTRTEXT (ITEMTYPE => ITEMTYPE,
                                        ITEMKEY  => ITEMKEY,
                                        ANAME    => 'STAFF_SUPPLIER_NAME',
   	   			        AVALUE   => L_NOTIFIER);

        L_SUPPLIER_EXISTS := 'SUPPLIER_EMAIL_EXISTS';

        IF g_po_wf_debug = 'Y' THEN
 	  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	    g_module_prefix || 'SELECT_SUPPLIER_NOTIFY' || 'L_SUPPLIER_EXISTS: ' ||  L_SUPPLIER_EXISTS);
	END IF;

      else

        L_SUPPLIER_EXISTS := 'SUPPLIER_EMAIL_NOT_AVAILABLE';

        IF g_po_wf_debug = 'Y' THEN
 	  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	    g_module_prefix || 'SELECT_SUPPLIER_NOTIFY' || 'L_SUPPLIER_EXISTS: ' ||  L_SUPPLIER_EXISTS);
	END IF;

        SELECT PORL.LINE_NUM, POV.VENDOR_NAME
	  INTO L_LINE_NUM, L_VENDOR_NAME
          FROM PO_REQUISITION_SUPPLIERS PLS,
               PO_REQUISITION_LINES_ALL PORL,
               PO_VENDORS POV
         WHERE PORL.REQUISITION_LINE_ID = PLS.REQUISITION_LINE_ID
           AND PLS.REQUISITION_SUPPLIER_ID = L_REQUISITION_SUPPLIER_ID
           AND PLS.VENDOR_ID = POV.VENDOR_ID;

	 IF g_po_wf_debug = 'Y' THEN
 	   PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	    g_module_prefix || 'SELECT_SUPPLIER_NOTIFY L_LINE_NUM:L_VENDOR_NAME'
	    || L_LINE_NUM || ':' ||  L_VENDOR_NAME);
	 END IF;

         WF_ENGINE.SETITEMATTRTEXT
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'VENDOR_DISPLAY_NAME',
                         AVALUE     => L_VENDOR_NAME);

  	 WF_ENGINE.SETITEMATTRNUMBER
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'REQUISITION_LINE_NUM',
                         AVALUE     => L_LINE_NUM);

  	 WF_ENGINE.SETITEMATTRTEXT
                        (ITEMTYPE   => ITEMTYPE,
                         ITEMKEY    => ITEMKEY,
                         ANAME      => 'IS_SUPPLIER_EMAIL_NOT_AVAIL',
                         AVALUE     => 'Y');
      END IF;

    END IF;

    RESULTOUT := WF_ENGINE.ENG_COMPLETED || ':' ||  L_SUPPLIER_EXISTS;

EXCEPTION
   WHEN OTHERS THEN
     IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, g_module_prefix || 'SELECT_SUPPLIER_NOTIFY' || sqlerrm);
     END IF;

END SELECT_SUPPLIER_NOTIFY;

PROCEDURE UPDATE_NOTIFY_SUPPLIER (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 )
IS

  L_REQUISITION_SUPPLIER_ID Number;

BEGIN

  L_REQUISITION_SUPPLIER_ID := WF_ENGINE.GETITEMATTRNUMBER
                                        (ITEMTYPE   => ITEMTYPE,
                                         ITEMKEY    => ITEMKEY,
                                         ANAME      => 'REQUISITION_SUPPLIER_ID');
  IF g_po_wf_debug = 'Y' THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
	g_module_prefix || 'UPDATE_NOTIFY_SUPPLIER' || 'L_REQUISITION_SUPPLIER_ID : ' || L_REQUISITION_SUPPLIER_ID);
  end if;

  UPDATE PO_REQUISITION_SUPPLIERS
     SET SUPPLIER_NOTIFIED_FLAG = 'Y', SUPPLIER_NOTIFIED_DATE = SYSDATE
   WHERE REQUISITION_SUPPLIER_ID = L_REQUISITION_SUPPLIER_ID;

  RETURN;

EXCEPTION
   WHEN OTHERS THEN
     IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, g_module_prefix || 'UPDATE_NOTIFY_SUPPLIER' || sqlerrm);
     END IF;

END UPDATE_NOTIFY_SUPPLIER;


FUNCTION GET_ADHOC_EMAIL_ROLE(L_REQ_SUPPLIER_ID NUMBER,
            L_REQ_LINE_ID NUMBER,
            ITEMTYPE VARCHAR2,
            ITEMKEY VARCHAR2)
RETURN varchar2
IS

  X_PROGRESS          VARCHAR2(300);
  L_DOC_STRING        VARCHAR2(200);
  L_VENDOR_SITE_CODE  PO_VENDOR_SITES.VENDOR_SITE_CODE%TYPE;
  L_VENDOR_SITE_ID    NUMBER;
  L_VENDOR_CONTACT_ID NUMBER;
  L_VENDOR_SITE_LANG  PO_VENDOR_SITES.LANGUAGE%TYPE;
  L_ADHOCUSER_LANG    WF_LANGUAGES.NLS_LANGUAGE%TYPE;
  L_ADHOCUSER_TERRITORY WF_LANGUAGES.NLS_TERRITORY%TYPE;
  L_EMAIL_PERFORMER     WF_USER_ROLES.ROLE_NAME%TYPE := NULL;
  L_EMAIL_ADDRESS        VARCHAR2(2000) := NULL;
  L_DISPLAY_NAME        VARCHAR2(80);
  L_PERFORMER_EXISTS    NUMBER;
  L_NOTIFICATION_PREFERENCE VARCHAR2(20) := 'MAILHTML';

BEGIN

  IF (G_PO_WF_DEBUG = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE,ITEMKEY,'POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE: L_REQ_SUPPLIER_ID:' || L_REQ_SUPPLIER_ID);
  END IF;

  BEGIN
    IF (L_REQ_SUPPLIER_ID IS NOT NULL) THEN

    SELECT PRS.VENDOR_SITE_ID, PRS.VENDOR_CONTACT_ID, PVS.VENDOR_SITE_CODE, PVS.LANGUAGE
      INTO L_VENDOR_SITE_ID, L_VENDOR_CONTACT_ID, L_VENDOR_SITE_CODE, L_VENDOR_SITE_LANG
      FROM PO_REQUISITION_SUPPLIERS PRS, PO_VENDOR_SITES_ALL PVS
     WHERE PRS.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
       AND PRS.REQUISITION_SUPPLIER_ID = L_REQ_SUPPLIER_ID;

  ELSIF (L_REQ_LINE_ID IS NOT NULL) THEN

    SELECT PRL.VENDOR_SITE_ID, PRL.VENDOR_CONTACT_ID, PVS.VENDOR_SITE_CODE, PVS.LANGUAGE
      INTO L_VENDOR_SITE_ID, L_VENDOR_CONTACT_ID, L_VENDOR_SITE_CODE, L_VENDOR_SITE_LANG
      FROM PO_REQUISITION_LINES PRL, PO_VENDOR_SITES_ALL PVS
     WHERE PRL.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
       AND PRL.REQUISITION_LINE_ID = L_REQ_LINE_ID;

  END IF;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     IF (G_PO_WF_DEBUG = 'Y') THEN
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE,ITEMKEY,'POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE: SUPPLIER SITE DOES NOT EXIST');
    END IF;
    RETURN NULL;
  END;

  IF (G_PO_WF_DEBUG = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE,ITEMKEY,' L_VENDOR_SITE_ID, L_VENDOR_CONTACT_ID, L_VENDOR_SITE_CODE, L_VENDOR_SITE_LANG:'
	|| L_VENDOR_SITE_ID || '*' || L_VENDOR_CONTACT_ID || '*' || L_VENDOR_SITE_CODE || '*' || L_VENDOR_SITE_LANG);
  END IF;

  --GET EMAIL ADDRESS FROM SUPPLIER SITE
  BEGIN
   SELECT EMAIL_ADDRESS
     INTO L_EMAIL_ADDRESS
     FROM PO_VENDOR_SITES_ALL
    WHERE VENDOR_SITE_ID = L_VENDOR_SITE_ID;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     L_EMAIL_ADDRESS := NULL;
  END;

  IF (G_PO_WF_DEBUG = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE,ITEMKEY,'POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE: L_EMAIL_ADDRESS FROM SUPPLIER SITE:' || L_EMAIL_ADDRESS || '*');
  END IF;

  --GET EMAIL ADDRESS FROM VENDOR CONTACTS
  IF L_EMAIL_ADDRESS IS NULL AND L_VENDOR_CONTACT_ID IS NOT NULL THEN
    BEGIN
     SELECT EMAIL_ADDRESS
       INTO L_EMAIL_ADDRESS
       FROM PO_VENDOR_CONTACTS
      WHERE VENDOR_CONTACT_ID = L_VENDOR_CONTACT_ID
        AND VENDOR_SITE_ID = L_VENDOR_SITE_ID;

     IF (G_PO_WF_DEBUG = 'Y') THEN
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE,ITEMKEY,'POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE: L_EMAIL_ADDRESS FROM VENDOR CONTACT:' || L_EMAIL_ADDRESS);
     END IF;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       L_EMAIL_ADDRESS := NULL;
    END;
  END IF;

  IF L_EMAIL_ADDRESS IS NULL THEN
    IF (G_PO_WF_DEBUG = 'Y') THEN
       PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE,ITEMKEY,'POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE: L_EMAIL_ADDRESS IS NULL');
    END IF;
    RETURN NULL;
  END IF;

  L_EMAIL_PERFORMER := L_VENDOR_SITE_CODE || SUBSTR(L_VENDOR_SITE_ID, 1, 15);
  L_DISPLAY_NAME := L_VENDOR_SITE_CODE || SUBSTR(L_VENDOR_SITE_ID, 1, 15);

  --ALSO RETRIEVE LANGUAGE TO SET THE ADHOCUSER LANGUAGE TO SUPPLIER SITE PREFERRED LANGUAGE

  IF L_VENDOR_SITE_LANG IS  NOT NULL THEN

    SELECT WFL.NLS_LANGUAGE, WFL.NLS_TERRITORY INTO L_ADHOCUSER_LANG, L_ADHOCUSER_TERRITORY
      FROM WF_LANGUAGES WFL, FND_LANGUAGES_VL FLV
     WHERE WFL.CODE = FLV.LANGUAGE_CODE
       AND FLV.NLS_LANGUAGE = L_VENDOR_SITE_LANG;

  ELSE

    SELECT WFL.NLS_LANGUAGE, WFL.NLS_TERRITORY INTO L_ADHOCUSER_LANG, L_ADHOCUSER_TERRITORY
      FROM WF_LANGUAGES WFL, FND_LANGUAGES_VL FLV
     WHERE WFL.CODE = FLV.LANGUAGE_CODE
       AND FLV.INSTALLED_FLAG = 'B';

  END IF;

  SELECT COUNT(*)
    INTO L_PERFORMER_EXISTS
    FROM WF_USERS
   WHERE NAME = L_EMAIL_PERFORMER;

  X_PROGRESS := '003';

  IF (L_PERFORMER_EXISTS = 0) THEN

    WF_DIRECTORY.CREATEADHOCUSER(L_EMAIL_PERFORMER, L_DISPLAY_NAME, L_ADHOCUSER_LANG,
      L_ADHOCUSER_TERRITORY, NULL, L_NOTIFICATION_PREFERENCE,   L_EMAIL_ADDRESS, NULL,
      'ACTIVE', NULL);

  ELSE

    WF_DIRECTORY.SETADHOCUSERATTR(L_EMAIL_PERFORMER, L_DISPLAY_NAME, L_NOTIFICATION_PREFERENCE,
      L_ADHOCUSER_LANG, L_ADHOCUSER_TERRITORY,  L_EMAIL_ADDRESS, NULL);

  END IF;

  X_PROGRESS := 'POR_CONTRACTOR_NOTIFY.GET_ADHOC_EMAIL_ROLE: 02';
  IF (G_PO_WF_DEBUG = 'Y') THEN
     PO_WF_DEBUG_PKG.INSERT_DEBUG(ITEMTYPE,ITEMKEY,X_PROGRESS);
  END IF;

  RETURN L_EMAIL_PERFORMER;

EXCEPTION
  WHEN OTHERS THEN
    IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, g_module_prefix || 'GET_ADHOC_EMAIL_ROLE' || sqlerrm);
     END IF;

END GET_ADHOC_EMAIL_ROLE;

/*===========================================================================
  PROCEDURE NAME: SET_REQSINPOOL_FLAG
  DESCRIPTION: Sets the REQS_IN_POOL flag in the po_requisition_lines_all table to 'Y'
===========================================================================*/

PROCEDURE SET_REQSINPOOL_FLAG (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 )
is
  L_REQ_HEADER_ID PO_REQUISITION_HEADERS_ALL.REQUISITION_HEADER_ID%TYPE;

BEGIN

    L_REQ_HEADER_ID := WF_ENGINE.GETITEMATTRNUMBER
                                          (ITEMTYPE   => ITEMTYPE,
                                           ITEMKEY    => ITEMKEY,
                                         ANAME      => 'DOCUMENT_ID');

    IF L_REQ_HEADER_ID is not null then
       UPDATE PO_REQUISITION_LINES_ALL
 	  SET REQS_IN_POOL_FLAG = 'Y'
        WHERE REQUISITION_HEADER_ID = L_REQ_HEADER_ID
          AND NVL(CONTRACTOR_REQUISITION_FLAG, 'N') = 'Y';
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_po_wf_debug = 'Y' THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, g_module_prefix || 'SET_REQSINPOOL_FLAG' || sqlerrm);
     END IF;

END SET_REQSINPOOL_FLAG;

END POR_CONTRACTOR_NOTIFY;

/
