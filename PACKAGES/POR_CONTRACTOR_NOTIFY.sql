--------------------------------------------------------
--  DDL for Package POR_CONTRACTOR_NOTIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_CONTRACTOR_NOTIFY" AUTHID CURRENT_USER AS
/* $Header: PORGCNTS.pls 115.2 2004/06/17 18:30:23 mahmad noship $*/

/*===========================================================================
  PROCEDURE NAME:  SUPPLIER_NEED_NOTIFY
  DESCRIPTION:    Checks if supplier for this requisition needs to be notified
===========================================================================*/

PROCEDURE SUPPLIER_NEED_NOTIFY (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 );

/*===========================================================================
  PROCEDURE NAME: SELECT_SUPPLIER_NOTIFY
  DESCRIPTION:
===========================================================================*/

PROCEDURE SELECT_SUPPLIER_NOTIFY (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 );

/*===========================================================================
  PROCEDURE NAME: UPDATE_NOTIFY_SUPPLIER
  DESCRIPTION:
===========================================================================*/

PROCEDURE UPDATE_NOTIFY_SUPPLIER (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 );

/*===========================================================================
  FUNCTION NAME: GET_ADHOC_EMAIL_ROLE
  DESCRIPTION: RETURNS ADHOC ROLE BASED ON THE EMAIL ADDRESS IN VENDOR SITE AND VENDOR CONTACT
===========================================================================*/

FUNCTION GET_ADHOC_EMAIL_ROLE(L_REQ_SUPPLIER_ID NUMBER,
                              L_REQ_LINE_ID NUMBER,
			      ITEMTYPE VARCHAR2,
			      ITEMKEY VARCHAR2)
RETURN varchar2;

/*===========================================================================
  PROCEDURE NAME: SET_REQSINPOOL_FLAG
  DESCRIPTION: Sets the REQS_IN_POOL flag in the po_requisition_lines_all table to 'Y'
===========================================================================*/

PROCEDURE SET_REQSINPOOL_FLAG (ITEMTYPE   IN   VARCHAR2,
          ITEMKEY    IN   VARCHAR2,
          ACTID      IN   NUMBER,
          FUNCMODE   IN   VARCHAR2,
          RESULTOUT  OUT NOCOPY  VARCHAR2 );

END POR_CONTRACTOR_NOTIFY;


 

/
