--------------------------------------------------------
--  DDL for Package OE_OEOL_GSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OEOL_GSA" AUTHID CURRENT_USER as
/* $Header: OEXWGSAS.pls 120.0 2005/06/01 02:28:35 appldev noship $ */

-- PROCEDURE OE_GSA_CHECK
--
-- Line level workflow activity that does the GSA Violation check.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
procedure oe_gsa_check(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);


procedure oe_gsa_hold(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

procedure oe_gsa_release_hold(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

end oe_oeol_gsa;

 

/
