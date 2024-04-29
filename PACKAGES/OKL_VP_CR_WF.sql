--------------------------------------------------------
--  DDL for Package OKL_VP_CR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_CR_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRCRWS.pls 120.0 2005/07/28 11:47:13 sjalasut noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME       CONSTANT VARCHAR2(200) := 'OKL_VP_CR_WF';
  G_APP_NAME       CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE       CONSTANT VARCHAR2(30)  := '_PVT';

  -------------------------------------------------------------------------------
  -- PROCEDURE raise_cr_event_approval
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : raise_cr_event_approval
  -- Description     : procedure raises business event for change request approval
  --                 : business event name oracle.apps.okl.la.vp.approve_change_request
  -- Parameters      : IN p_vp_crq_id change request agreement id
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE raise_cr_event_approval(p_api_version   IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_vp_crq_id     IN okl_vp_change_requests.id%TYPE
                                   );
  -------------------------------------------------------------------------------
  -- PROCEDURE check_approval_process
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_approval_process
  -- Description     : procedure checks the approval process configured in the
  --                   profile OKL: Change Request Approval Process
  -- Parameters      : NONE
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE check_approval_process(itemtype	  IN VARCHAR2
                                  ,itemkey   IN VARCHAR2
                                  ,actid		   IN NUMBER
                                  ,funcmode  IN VARCHAR2
                                  ,resultout OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE get_cr_approver
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : get_cr_approver
  -- Description     : procedure finds the approver to approve this change request
  --                   since this is a prototype, the requester is the approver
  -- Parameters      : NONE
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE get_cr_approver(itemtype  IN VARCHAR2
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
  --                   change requests
  -- Parameters      : NONE
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE get_msg_doc(document_id   IN VARCHAR2
                       ,display_type  IN VARCHAR2
                       ,document      IN OUT nocopy VARCHAR2
                       ,document_type IN OUT nocopy VARCHAR2
                        );

  -------------------------------------------------------------------------------
  -- PROCEDURE update_cr_status
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_cr_status
  -- Description     : updates change request status based on the approval outcome
  --                   via workflow or AME
  -- Parameters      : NONE
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE update_cr_status(itemtype	  IN VARCHAR2
                            ,itemkey   IN VARCHAR2
                            ,actid		   IN NUMBER
                            ,funcmode  IN VARCHAR2
                            ,resultout OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------------
  -- PROCEDURE process_cr_for_ame
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : process_cr_for_ame
  -- Description     : procedure that sets the message subjects, transaction context
  --                 : for Oracle Approvals Managment to handle the change request
  --                   approval process
  -- Parameters      : NONE
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE process_cr_for_ame(itemtype	  IN VARCHAR2
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
  -- Parameters      : IN p_vp_crq_id change request agreement id
  -- Version         : 1.0
  -- History         : May 18, 05 SJALASUT created
  -- End of comments
  PROCEDURE set_msg_attributes(itemtype  IN VARCHAR2
                              ,itemkey   IN VARCHAR2
                              ,actid     IN NUMBER
                              ,funcmode  IN VARCHAR2
                              ,resultout OUT NOCOPY VARCHAR2);

END okl_vp_cr_wf;

 

/
