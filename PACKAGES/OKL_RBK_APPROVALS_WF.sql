--------------------------------------------------------
--  DDL for Package OKL_RBK_APPROVALS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RBK_APPROVALS_WF" AUTHID CURRENT_USER AS
/* $Header: OKLREWFS.pls 115.1 2002/11/30 08:47:19 spillaip noship $ */

  PROCEDURE VALIDATE_APPROVAL_REQUEST (itemtype  IN VARCHAR2,
                                       itemkey   IN VARCHAR2,
                                       actid     IN NUMBER,
                                       funcmode  IN VARCHAR2,
                                       resultout OUT NOCOPY VARCHAR2);

  PROCEDURE GET_APPROVER (itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2);

END OKL_RBK_APPROVALS_WF;

 

/
