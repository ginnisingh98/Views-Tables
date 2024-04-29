--------------------------------------------------------
--  DDL for Package OKL_LEASE_APP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_APP_WF" AUTHID CURRENT_USER AS
/* $Header: OKLLAWFS.pls 120.0 2005/11/23 11:30:45 viselvar noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
   G_APP_NAME				  CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_LEASE_APP_WF';

   G_STATUS_NEW             CONSTANT VARCHAR2(100) := 'NEW';
  ---------------------------------------------------------------------------
  SUBTYPE lavv_rec_type IS OKL_LAV_PVT.lavv_rec_type;

  -- Start of comments
  --
  -- Procedure Name  : check_approval_process
  -- Description     : Procedure to check if the Approval Process is Workflow driven
  --                   or through AME.
  -- Business Rules  : Checks the Frontend profile and directs the approval flow
  --                   accordingly
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_approval_process(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2, actid IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2);
  -- Start of comments
  --
  -- Procedure Name  : get_lat_ver_details
  -- Description     : Gets the details of the Lease Application Template version
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE get_lat_ver_details (itemtype IN VARCHAR2,
                                 itemkey IN VARCHAR2,
                                 actid IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2);

  -- Start of comments
  --
  -- Procedure Name  : get_lat_msg_doc
  -- Description     : Sets the message document for notification for Lease
  --                   Application template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE get_lat_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2);

  -- Start of comments
  --
  -- Procedure Name  : get_la_withdraw_msg_doc
  -- Description     : Sets the message document for notification for Lease
  --                   Application withdrawal
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE get_la_withdraw_msg_doc(document_id IN VARCHAR2,
                            display_type IN VARCHAR2,
                            document IN OUT NOCOPY VARCHAR2,
                            document_type IN OUT NOCOPY VARCHAR2);

  -- Start of comments
  --
  -- Procedure Name  : handle_lat_approval
  -- Description     : Handles the process after the process is approved or rejected
  -- Business Rules  : If Approved, call the API to activate the LAT
  --                   Else change the version status of LAT to NEW
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE handle_lat_approval (itemtype IN VARCHAR2,
                                 itemkey IN VARCHAR2,
                                 actid IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2) ;

  -- Start of comments
  --
  -- Procedure Name  : check_la_credit_status
  -- Description     : Procedure to check if credit processing has been done on the
  --                   Lease Application.
  -- Business Rules  : Checks if the Lease Application is in CR-APPROVED or CR-REJECTED
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE check_la_credit_status(itemtype IN VARCHAR2,
                                   itemkey IN VARCHAR2,
                                   actid IN NUMBER,
                                   funcmode IN VARCHAR2,
                                   resultout OUT NOCOPY VARCHAR2);
  -- Start of comments
  --
  -- Procedure Name  : get_la_withdraw_details
  -- Description     : Gets the details of the Lease Application details and
  --                   Sets the message for this operation
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE get_la_withdraw_details (itemtype IN VARCHAR2,
                                 itemkey IN VARCHAR2,
                                 actid IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2);

  -- Start of comments
  --
  -- Procedure Name  : handle_la_withdraw_approval
  -- Description     : Handles the process after the Lease Application withdrawal
  --                   is approved or rejected by Credit Analyst.
  -- Business Rules  : If Approved, call the API to withdraw the Lease Application
  --                   Else the Lease Application status is not changed.
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE handle_la_withdraw_approval (itemtype IN VARCHAR2,
                                           itemkey IN VARCHAR2,
                                           actid IN NUMBER,
                                           funcmode IN VARCHAR2,
                                           resultout OUT NOCOPY VARCHAR2);
END OKL_LEASE_APP_WF;

/
