--------------------------------------------------------
--  DDL for Package Body OKL_RBK_APPROVALS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RBK_APPROVALS_WF" AS
/* $Header: OKLREWFB.pls 115.1 2002/11/30 08:47:15 spillaip noship $ */

  PROCEDURE VALIDATE_APPROVAL_REQUEST (itemtype  IN VARCHAR2,
                                       itemkey   IN VARCHAR2,
                                       actid     IN NUMBER,
                                       funcmode  IN VARCHAR2,
                                       resultout OUT NOCOPY VARCHAR2) IS
  BEGIN
    null;
  END VALIDATE_APPROVAL_REQUEST;

  PROCEDURE GET_APPROVER (itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2) IS
  BEGIN
    null;
  END GET_APPROVER;

END OKL_RBK_APPROVALS_WF;

/
