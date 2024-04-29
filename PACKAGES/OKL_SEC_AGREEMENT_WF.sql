--------------------------------------------------------
--  DDL for Package OKL_SEC_AGREEMENT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEC_AGREEMENT_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRZWFS.pls 120.0 2007/12/24 10:42:04 ankushar noship $ */

  G_APP_NAME    CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'okl_sec_agreement_wf';
  G_LEVEL       CONSTANT VARCHAR2(4)   := '_PVT';
  l_api_version CONSTANT NUMBER        := 1;
  G_FND_APP     CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;

   SUBTYPE poxv_rec_type IS OKL_POX_PVT.poxv_rec_type;

  --------------------------------------------------------------------------------------------------
  ----------------------------------Raising Business Event ------------------------------------------
  --------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE raise_add_khr_approval_event
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_add_khr_approval_event
  -- Description     :
  -- Business Rules  : Raises the credit line approval event
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_agreement_id, p_pool_id.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE raise_add_khr_approval_event (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  p_agreement_id   IN  OKC_K_HEADERS_B.ID%TYPE,
                                  p_pool_id        IN  OKL_POOLS_ALL.ID%TYPE,
                                  p_pool_trans_id  IN  OKL_POOL_TRANSACTIONS.ID%TYPE);

 ---------------------------------------------------------------------------
 -- PROCEDURE Set_Add_Khr_Attributes
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Set_Add_Khr_Attributes
  -- Description     :
  -- Business Rules  : sets the parent attributes.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Set_Add_Khr_Attributes(itemtype  IN  VARCHAR2,
                                  itemkey   IN  VARCHAR2,
                                  actid     IN  NUMBER,
                                  funcmode  IN  VARCHAR2,
                                  resultout OUT NOCOPY VARCHAR2);

 --------------------------------------------------------------------------------------------------
----------------------------------Main Approval Process ------------------------------------------
--------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE update_add_khr_apprv_sts
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_add_khr_apprv_sts
  -- Description     :
  -- Business Rules  : Updates the Add Contracts Request status from pending approval
  --                   to approved or approval rejected.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_add_khr_apprv_sts(itemtype  IN  VARCHAR2,
                                   itemkey   IN  VARCHAR2,
                                   actid     IN  NUMBER,
                                   funcmode  IN  VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2);

  /*
  -- This API is for IA Add Contracts Request Approval via WF
  */
 ---------------------------------------------------------------------------
 -- PROCEDURE get_add_khr_approver
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_add_khr_approver
  -- Description     :
  -- Business Rules  : returns whether the approver is found or not.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE get_add_khr_approver(itemtype   IN VARCHAR2,
                                     itemkey    IN VARCHAR2,
                                     actid      IN NUMBER,
                                     funcmode   IN VARCHAR2,
           		                        resultout  OUT  NOCOPY VARCHAR2);

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
 -- PROCEDURE check_add_khr_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_add_khr_approval_process
  -- Description     :
  -- Business Rules  : Checks whether the profile option is set to WF or AME
  --                   and sets the parameter accordingly.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE check_add_apprv_process( itemtype	 IN  VARCHAR2,
            				                    itemkey  	IN  VARCHAR2,
			                            	    actid		   IN  NUMBER,
			                                 funcmode	 IN  VARCHAR2,
            				                    resultout OUT NOCOPY VARCHAR2 );

 ---------------------------------------------------------------------------
 -- PROCEDURE wf_add_khr_approval_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : wf_add_khr_approval_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is WF.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE wf_add_khr_apprv_process( itemtype	 IN  VARCHAR2,
	         			                    itemkey  	IN  VARCHAR2,
			                         	    actid		   IN  NUMBER,
			                              funcmode	 IN  VARCHAR2,
				                             resultout OUT NOCOPY VARCHAR2 );

 ---------------------------------------------------------------------------
 -- PROCEDURE ame_add_khr_apprv_process
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : ame_add_khr_apprv_process
  -- Description     :
  -- Business Rules  : This is raised when the profile option is AME.
  -- Parameters      : itemtype, itemkey, actid, funcmode,resultout.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE ame_add_khr_apprv_process( itemtype	 IN  VARCHAR2,
          				                    itemkey  	IN  VARCHAR2,
			                          	    actid		   IN  NUMBER,
			                               funcmode	 IN  VARCHAR2,
				                              resultout OUT NOCOPY VARCHAR2 );

END okl_sec_agreement_wf;


/
