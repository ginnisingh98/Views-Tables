--------------------------------------------------------
--  DDL for Package Body GL_WF_CUSTOMIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_WF_CUSTOMIZATION_PKG" AS
/*  $Header: glwfcusb.pls 120.2 2002/11/13 04:33:18 djogg ship $  */


--
-- *****************************************************************************
-- Procedure Is_JE_Valid
-- *****************************************************************************
--
PROCEDURE is_je_valid(itemtype	IN VARCHAR2,
		      itemkey  	IN VARCHAR2,
		      actid	IN NUMBER,
		      funcmode	IN VARCHAR2,
		      result	OUT NOCOPY VARCHAR2 ) IS
BEGIN
  IF ( funcmode = 'RUN'  ) THEN
    -- Additional code can be added here.
    -- COMPLETE:Y (Workflow transition branch "Yes") indicates that the journal
    --            batch is valid.
    -- COMPLETE:N (Workflow transition branch "No") indicates that the journal
    --            batch is not valid.
    result := 'COMPLETE:Y';
  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;
END is_je_valid;


--
-- *****************************************************************************
-- Procedure Does_JE_Need_Approval
-- *****************************************************************************
--
PROCEDURE does_je_need_approval( itemtype	IN VARCHAR2,
				  itemkey  	IN VARCHAR2,
				  actid	        IN NUMBER,
				  funcmode	IN VARCHAR2,
				  result	OUT NOCOPY VARCHAR2 ) IS
BEGIN
  IF ( funcmode = 'RUN'  ) THEN
    -- Additional code can be added here.
    -- COMPLETE:Y (Workflow transition branch "Yes") indicates that the journal
    --            batch needs approval.
    -- COMPLETE:N (Workflow transition branch "No") indicates that the journal
    --            batch does not need approval.
    result := 'COMPLETE:Y';
  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;
END does_je_need_approval;


--
-- *****************************************************************************
-- Procedure Can_Preparer_Approve
-- *****************************************************************************
--
PROCEDURE can_preparer_approve( itemtype	IN VARCHAR2,
				itemkey  	IN VARCHAR2,
				actid	        IN NUMBER,
				funcmode	IN VARCHAR2,
			        result	        OUT NOCOPY VARCHAR2 ) IS
BEGIN
  IF ( funcmode = 'RUN'  ) THEN
    -- Additional code can be added here.
    -- COMPLETE:Y (Workflow transition branch "Yes") indicates that the preparer
    --            can self-approve the journal batch.
    -- COMPLETE:N (Workflow transition branch "No") indicates that the preparer
    --            cannot self-approve the journal batch.
    result := 'COMPLETE:Y';
  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;
END can_preparer_approve;


--
-- *****************************************************************************
-- Procedure Verify_Authority
-- *****************************************************************************
--
PROCEDURE verify_authority( itemtype	IN VARCHAR2,
			    itemkey  	IN VARCHAR2,
		            actid	IN NUMBER,
			    funcmode	IN VARCHAR2,
			    result	OUT NOCOPY VARCHAR2 ) IS
BEGIN
  IF ( funcmode = 'RUN'  ) THEN
    -- Additional code can be added here.
    -- COMPLETE:PASS (Workflow transition branch "Pass") indicates that the
    --               approver passed the journal batch approval authorization
    --               check.
    -- COMPLETE:FAIL (Workflow transition branch "Fail") indicates that the
    --               approver failed the journal batch approval authorization
    --               check.
    result := 'COMPLETE:PASS';
  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;
END verify_authority;


END GL_WF_CUSTOMIZATION_PKG;

/
