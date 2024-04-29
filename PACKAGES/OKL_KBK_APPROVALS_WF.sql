--------------------------------------------------------
--  DDL for Package OKL_KBK_APPROVALS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_KBK_APPROVALS_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRBWFS.pls 115.3 2003/11/19 23:35:11 mvasudev noship $ */

  G_APP_NAME    CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_KBK_APPROVALS_WF';
  G_LEVEL       CONSTANT VARCHAR2(4)   := '_PVT';
  l_api_version CONSTANT NUMBER        := 1;
  G_FND_APP     CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;

  PROCEDURE raise_approval_event (p_api_version    IN  NUMBER,
                                           p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                           x_return_status  OUT NOCOPY VARCHAR2,
                                           x_msg_count      OUT NOCOPY NUMBER,
                                           x_msg_data       OUT NOCOPY VARCHAR2,
                                           p_contract_id IN OKC_K_HEADERS_B.ID%TYPE);

  PROCEDURE Set_Parent_Attributes(itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

  PROCEDURE update_approval_status(itemtype  IN VARCHAR2,
                              itemkey   IN VARCHAR2,
                              actid     IN NUMBER,
                              funcmode  IN VARCHAR2,
                              resultout OUT NOCOPY VARCHAR2);

  PROCEDURE get_lease_contract_approver (itemtype  IN VARCHAR2,
                          itemkey   IN VARCHAR2,
                          actid     IN NUMBER,
                          funcmode  IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2);

  PROCEDURE pop_approval_doc (document_id   IN VARCHAR2,
                              display_type  IN VARCHAR2,
                              document      IN OUT NOCOPY VARCHAR2,
                              document_type IN OUT NOCOPY VARCHAR2);

  PROCEDURE check_approval_process( itemtype	IN VARCHAR2,
				                    itemkey  	IN VARCHAR2,
			                 	    actid		IN NUMBER,
			                        funcmode	IN VARCHAR2,
				                    resultout OUT NOCOPY VARCHAR2 );

  PROCEDURE wf_approval_process( itemtype	IN VARCHAR2,
				                 itemkey  	IN VARCHAR2,
			              	    actid		IN NUMBER,
			                     funcmode	IN VARCHAR2,
				                 resultout OUT NOCOPY VARCHAR2 );

END Okl_Kbk_Approvals_Wf;

 

/
