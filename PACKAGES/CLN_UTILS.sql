--------------------------------------------------------
--  DDL for Package CLN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_UTILS" AUTHID CURRENT_USER AS
/* $Header: CLNUTLS.pls 120.0 2005/05/24 16:20:35 appldev noship $ */
--  Package
--      CLN_UTILS
--
--  Purpose
--      Spec of package CLN_UTILS.
--
--
--  History
--      Mar-26-2002     Kodanda Ram         Created
--      Apr-02-2002     Rahul Krishan       Modified
--      Jun-07-2004     Sangeetha           Modified


  -- Name
  --   GET_TRADING_PARTNER
  -- Purpose
  --   This procedure is called just before calling create collaboration to get the
  --   actual trading partner id, from XMLG trading partner id and the returned
  --   value will be passed to create collaboration API.
  -- Arguments
  --
  -- Notes
  --   No specific notes.

  PROCEDURE GET_TRADING_PARTNER(
    p_ecx_tp_id             IN  NUMBER,
    x_return_id             OUT NOCOPY NUMBER );



  -- Name
  --     IsDeliveryRequired
  -- Purpose
  --   This procedure is called when resend button is clicked in the Collaboration HIstory
  --   Forms.The main purpose is to resend the document from XML gateway.  Its being refrenced from CLNGNOUT workflow
  -- Arguments
  --   The workflow process item name calling this API.
  --   The unique value passed as the event key to the workflow.
  --   The unique system generated activity ID, calling this API.
  --   The calling workflow assigns the value 'RUN'.
  --   The status of the API is passed out through this variable.
  --
  -- Notes
  --   No specific notes.


 PROCEDURE IsDeliveryRequired (p_itemtype        IN VARCHAR2,
                               p_itemkey         IN VARCHAR2,
                               p_actid           IN NUMBER,
                               p_funcmode        IN VARCHAR2,
                               x_resultout       IN OUT NOCOPY VARCHAR2);


END CLN_UTILS;

 

/
