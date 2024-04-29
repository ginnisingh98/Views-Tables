--------------------------------------------------------
--  DDL for Package FUN_GLINT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_GLINT_WF" AUTHID CURRENT_USER AS
/* $Header: FUN_GLINT_WF_S.pls 120.0 2003/05/27 21:59:45 bwong noship $ */

    -- Raised when the transfer results in unknown failure.
    gl_transfer_failure EXCEPTION;


/*-----------------------------------------------------
 * PROCEDURE get_attr_gl
 * ----------------------------------------------------
 * Get the attributes for the GL WF.
 * ---------------------------------------------------*/

PROCEDURE get_attr_gl (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE check_gl_setup
 * ----------------------------------------------------
 * Check whether there exists conversion between the
 * transaction currency and the GL currency.
 * Check whether the GL period is open.
 * ---------------------------------------------------*/

PROCEDURE check_gl_setup (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE transfer_to_gl
 * ----------------------------------------------------
 * Transfer to GL. Wrapper for
 * FUN_GL_TRANSFER.AUTONOMOUS_TRANSFER.
 *
 * If AUTONOMOUS_TRANSFER returns false, it means the
 * status is incorrect, i.e. the trx is already
 * transferred. So we abort our WF process.
 * ---------------------------------------------------*/

PROCEDURE transfer_to_gl (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE check_signal_initiator
 * ----------------------------------------------------
 * Check whether we raise an event to the initiator.
 * ---------------------------------------------------*/

PROCEDURE check_signal_initiator (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);



/*-----------------------------------------------------
 * PROCEDURE raise_gl_complete
 * ----------------------------------------------------
 * Raise the (initiator) GL complete event.
 * ---------------------------------------------------*/

PROCEDURE raise_gl_complete (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);



/*-----------------------------------------------------
 * PROCEDURE update_ini_complete
 * ----------------------------------------------------
 * Update the status to XFER_INI_GL.
 * ---------------------------------------------------*/

PROCEDURE update_ini_complete (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);




END; -- Package spec


 

/
