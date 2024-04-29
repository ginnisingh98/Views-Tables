--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_WORKFLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRQUWS.pls 120.1 2005/11/23 10:41:46 viselvar noship $ */

  --------------------
  -- PACKAGE CONSTANTS
  --------------------
  G_PKG_NAME             CONSTANT VARCHAR2(30)  := 'OKL_LEASE_QUOTE_WORKFLOW_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(30)  := OKL_API.G_APP_NAME;
  G_API_VERSION          CONSTANT NUMBER        := 1;
  G_USER_ID              CONSTANT NUMBER        := FND_GLOBAL.USER_ID;
  G_LOGIN_ID             CONSTANT NUMBER        := FND_GLOBAL.LOGIN_ID;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(25)  := 'OKL_QUOTE_UNEXP_ERROR';
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';
  G_PKG_NAME_TOKEN       CONSTANT VARCHAR2(30)  := 'PKG_NAME';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(30)  := 'SQLERRM';

  ----------------
  -- PROGRAM UNITS
  ----------------

  PROCEDURE raise_quote_accept_event (p_quote_id      IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE populate_accept_attribs(itemtype   IN  VARCHAR2,
                                	itemkey    IN  VARCHAR2,
                                    actid      IN  NUMBER,
                                    funcmode   IN  VARCHAR2,
                                    resultout  OUT NOCOPY VARCHAR2);

  PROCEDURE raise_quote_submit_event (p_quote_id      IN  NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE populate_submit_attribs(itemtype  IN VARCHAR2,
                                	itemkey   IN VARCHAR2,
                                    actid     IN NUMBER,
                                    funcmode  IN VARCHAR2,
                                    resultout OUT NOCOPY VARCHAR2);
  -- procedure to check the approval process
  PROCEDURE check_approval_process(itemtype	IN VARCHAR2
                                    ,itemkey  	IN VARCHAR2
	                            ,actid      IN NUMBER
	                            ,funcmode	IN VARCHAR2
	                            ,resultout OUT NOCOPY VARCHAR2);

  -- Get the message body for Lease Quotes
  PROCEDURE get_quote_msg_doc(document_id   IN VARCHAR2,
                          display_type  IN VARCHAR2,
                          document      IN OUT nocopy VARCHAR2,
                          document_type IN OUT nocopy VARCHAR2);

  -- populate the quote attributes
  PROCEDURE populate_quote_attr(itemtype IN VARCHAR2,
                                itemkey IN VARCHAR2,
                                actid IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

  -- handle the quote approval process
  PROCEDURE handle_approval(itemtype   IN  VARCHAR2,
                            itemkey    IN  VARCHAR2,
                            actid      IN  NUMBER,
                            funcmode   IN  VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2);
END OKL_LEASE_QUOTE_WORKFLOW_PVT;

 

/
