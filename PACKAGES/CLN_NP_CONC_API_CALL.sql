--------------------------------------------------------
--  DDL for Package CLN_NP_CONC_API_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_NP_CONC_API_CALL" AUTHID CURRENT_USER as
/* $Header: ECXNPCRS.pls 120.0 2005/08/25 04:47:19 nparihar noship $ */
--
-- Package: CLN_NP_CONC_API_CALL
--
-- Purpose: To run user defined PL/SQL function in concurrent mode. This process is called by the workflow which inturn is started by CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS
--
-- History
--    May-02-2002       Kodanda Ram         Created
--
--
-- Name
--    CALL_API
-- Purpose
--    This procedure submits a concurrent request for the user defined PL/SQL function
--
-- Arguments
--    P_ITEMTYPE   Item type
--    P_ITEMTYPE   Item Key
--    P_ACTID      Action ID
--    P_FUNCMODE   Function Mode
--    X_RESULTOUT  Result
--
-- Returns [ for functions ]
--
-- Notes
--    No specific notes



PROCEDURE CALL_API(
   p_itemtype        IN VARCHAR2,
   p_itemkey         IN VARCHAR2,
   p_actid           IN NUMBER,
   p_funcmode        IN VARCHAR2,
   x_resultout       IN OUT NOCOPY VARCHAR2);


END CLN_NP_CONC_API_CALL;

 

/
