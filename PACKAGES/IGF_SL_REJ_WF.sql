--------------------------------------------------------
--  DDL for Package IGF_SL_REJ_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_REJ_WF" AUTHID CURRENT_USER AS
/* $Header: IGFSL18S.pls 120.0 2005/06/01 13:04:22 appldev noship $ */

  /*************************************************************
  Created By : viramali
  Date Created On : 2001/05/15
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE send_notif(
                      itemtype  IN VARCHAR2,
                      itemkey   IN VARCHAR2,
                      actid     IN NUMBER,
                      funcmode  IN VARCHAR2,
                      resultout OUT NOCOPY VARCHAR2 );
PROCEDURE manif_loan(
                      itemtype  IN VARCHAR2,
                      itemkey   IN VARCHAR2,
                      actid     IN NUMBER,
                      funcmode  IN VARCHAR2,
                      resultout OUT NOCOPY VARCHAR2 );
PROCEDURE reprint_loan(
                      itemtype  IN VARCHAR2,
                      itemkey   IN VARCHAR2,
                      actid     IN NUMBER,
                      funcmode  IN VARCHAR2,
                      resultout OUT NOCOPY VARCHAR2 );

END igf_sl_rej_wf;

 

/
