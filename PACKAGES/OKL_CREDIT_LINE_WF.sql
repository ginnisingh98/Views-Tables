--------------------------------------------------------
--  DDL for Package OKL_CREDIT_LINE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_LINE_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRDWFS.pls 120.0 2005/11/30 17:17:46 stmathew noship $ */

  G_APP_NAME    CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'okl_credit_line_wf';
  G_LEVEL       CONSTANT VARCHAR2(4)   := '_PVT';
  l_api_version CONSTANT NUMBER        := 1;
  G_FND_APP     CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;

 ---------------------------------------------------------------------------
 -- PROCEDURE raise_approval_event
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_approval_event
  -- Description     :
  -- Business Rules  : Raises the credit line approval event
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_contract_id.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE raise_approval_event (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  p_contract_id    IN  OKC_K_HEADERS_B.ID%TYPE);

 ---------------------------------------------------------------------------
 -- PROCEDURE Set_Parent_Attributes
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Set_Parent_Attributes
  -- Description     :
  -- Business Rules  : sets the parent attributes.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Set_Parent_Attributes(itemtype  IN  VARCHAR2,
                                  itemkey   IN  VARCHAR2,
                                  actid     IN  NUMBER,
                                  funcmode  IN  VARCHAR2,
                                  resultout OUT NOCOPY VARCHAR2);

 ---------------------------------------------------------------------------
 -- PROCEDURE update_approval_status
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_approval_status
  -- Description     :
  -- Business Rules  : Updates the credit line status from pending approval
  --                   to approved or declined.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_approval_status(itemtype  IN  VARCHAR2,
                                   itemkey   IN  VARCHAR2,
                                   actid     IN  NUMBER,
                                   funcmode  IN  VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2);

 ---------------------------------------------------------------------------
 -- PROCEDURE get_credit_line_approver
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_credit_line_approver
  -- Description     :
  -- Business Rules  : returns whether the approver is found or not.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE get_credit_line_approver (itemtype  IN  VARCHAR2,
                                      itemkey   IN  VARCHAR2,
                                      actid     IN  NUMBER,
                                      funcmode  IN  VARCHAR2,
                                      resultout OUT NOCOPY VARCHAR2);

 ---------------------------------------------------------------------------
 -- PROCEDURE pop_approval_doc
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : pop_approval_doc
  -- Description     :
  -- Business Rules  : This procedure is invoked dynamically by Workflow API's
  --                   in order to populate the message body item attribute
  --                   during notification submission.
  -- Parameters      : document_id, display_type, document, document_type.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE pop_approval_doc (document_id   IN VARCHAR2,
                              display_type  IN VARCHAR2,
                              document      IN OUT NOCOPY VARCHAR2,
                              document_type IN OUT NOCOPY VARCHAR2);

 ---------------------------------------------------------------------------
 -- PROCEDURE check_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_approval_process
  -- Description     :
  -- Business Rules  : Checks whether the profile option is set to WF or AME
  --                   and sets the parameter accordingly.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE check_approval_process( itemtype	 IN  VARCHAR2,
            				                    itemkey  	IN  VARCHAR2,
			                            	    actid		   IN  NUMBER,
			                                 funcmode	 IN  VARCHAR2,
            				                    resultout OUT NOCOPY VARCHAR2 );

 ---------------------------------------------------------------------------
 -- PROCEDURE wf_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : wf_approval_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is WF.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE wf_approval_process( itemtype	 IN  VARCHAR2,
             			                 itemkey  	IN  VARCHAR2,
			                         	    actid		   IN  NUMBER,
         			                     funcmode	 IN  VARCHAR2,
				                             resultout OUT NOCOPY VARCHAR2 );

 ---------------------------------------------------------------------------
 -- PROCEDURE ame_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : ame_approval_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is AME.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE ame_approval_process( itemtype	 IN  VARCHAR2,
          				                    itemkey  	IN  VARCHAR2,
			                          	    actid		   IN  NUMBER,
			                               funcmode	 IN  VARCHAR2,
				                              resultout OUT NOCOPY VARCHAR2 );

END okl_credit_line_wf;

 

/
