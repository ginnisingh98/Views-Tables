--------------------------------------------------------
--  DDL for Package IGS_PR_PROG_OUT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_PROG_OUT_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPR36S.pls 115.1 2002/11/29 02:52:43 nsidana noship $ */

  /*************************************************************
  Created By :Deepankar Dey
  Date Created on : 30-Sept-2002
  Purpose :  This procedure checks the Business Events Name and route the Workflow control to particular
             Notification Activity and pass corresponding parameters to the Message Body of that Notification .
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  PROCEDURE find_prog_out_notification(
                         itemtype    IN VARCHAR2,
                         itemkey     IN VARCHAR2,
                         actid	    IN NUMBER,
                         funcmode    IN VARCHAR2,
                         resultout   IN OUT NOCOPY VARCHAR2
			 );


END igs_pr_prog_out_wf_pkg;

 

/
