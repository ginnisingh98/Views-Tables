--------------------------------------------------------
--  DDL for Package OKL_VP_PA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_PA_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRPAWS.pls 120.0 2005/07/28 11:44:42 sjalasut noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_VP_PA_WF';
  G_APP_NAME       CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';

  -------------------------------------------------------------------------------
  -- PROCEDURE raise_pa_event_approval
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_pa_event_approval
  -- Description     : procedure raises business event for program agreement approval
  --                 : business event name oracle.apps.okl.la.vp.approve_program_agreement
  -- Parameters      : IN p_chr_id agreement id
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE raise_pa_event_approval(p_api_version   IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                   );
  -------------------------------------------------------------------------------
  -- PROCEDURE check_approval_process
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_approval_process
  -- Description     : procedure that checks the approval configured in the profile
  --                 : OKL: Program Agreement Approval Process
  -- Parameters      : default wf parameters
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE check_approval_process(itemtype	  IN VARCHAR2
				                               ,itemkey   IN VARCHAR2
			                                ,actid		   IN NUMBER
			                                ,funcmode  IN VARCHAR2
				                               ,resultout OUT NOCOPY VARCHAR2);
  -------------------------------------------------------------------------------
  -- PROCEDURE get_agrmnt_approver
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_agrmnt_approver
  -- Description     : procedure that gets the approver for workflow based approval
  --                 : the logic first finds if requester has a role to send,
  --                   if not found, the requisition goes to sysadmin
  -- Parameters      : default wf parameters
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE get_agrmnt_approver(itemtype  IN VARCHAR2
                               ,itemkey   IN VARCHAR2
                               ,actid     IN NUMBER
                               ,funcmode  IN VARCHAR2
                               ,resultout OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE get_msg_doc
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_msg_doc
  -- Description     : get_msg_doc constructs a sample summary of information that is
  --                 : displayed in the notification for approval, rejection and approved
  --                   operating agreements
  -- Parameters      : default wf parameters
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE get_msg_doc(document_id   IN VARCHAR2
                       ,display_type  IN VARCHAR2
                       ,document      IN OUT nocopy VARCHAR2
                       ,document_type IN OUT nocopy VARCHAR2
                        );

  -------------------------------------------------------------------------------
  -- PROCEDURE update_agrmnt_status
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_agrmnt_status
  -- Description     : updates agreement status based on the approval outcome
  --                   via workflow or AME
  -- Parameters      : default wf parameters
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE update_agrmnt_status(itemtype	  IN VARCHAR2
                                ,itemkey   IN VARCHAR2
                                ,actid		   IN NUMBER
                                ,funcmode  IN VARCHAR2
                                ,resultout OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE process_pa_for_ame
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : process_pa_for_ame
  -- Description     : procedure that sets the message subjects, transaction context
  --                 : for Oracle Approvals Managment to handle the program agreement
  --                   approval process
  -- Parameters      : default wf parameters
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments

  PROCEDURE process_pa_for_ame(itemtype	  IN VARCHAR2
                              ,itemkey   IN VARCHAR2
                              ,actid		   IN NUMBER
                              ,funcmode  IN VARCHAR2
                              ,resultout OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE set_msg_attributes
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_msg_attributes
  -- Description     : set_msg_attributes sets the notification contents based on the
  --                 : outcome of the approval process via workflow
  -- Parameters      : default wf parameters
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE set_msg_attributes(itemtype  IN VARCHAR2
                              ,itemkey   IN VARCHAR2
                              ,actid     IN NUMBER
                              ,funcmode  IN VARCHAR2
                              ,resultout OUT NOCOPY VARCHAR2);

END okl_vp_pa_wf;

 

/
