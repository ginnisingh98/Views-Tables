--------------------------------------------------------
--  DDL for Package CS_WF_ACTIVITIES_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WF_ACTIVITIES_CUST" AUTHID CURRENT_USER as
/* $Header: cswfcsts.pls 115.5 2002/11/25 19:39:18 rmanabat ship $ */

-- ***************************************************************************
-- *                                                                         *
-- *                         Service Request Item Type                       *
-- *                                                                         *
-- ***************************************************************************

--                   -----------------------------------------
--                   |             PUBLIC SECTION            |
--                   | Following procedures are customizable |
--                   -----------------------------------------

-- ---------------------------------------------------------------------------
-- Set_Response_Deadline
--   This procedure corresponds to the SET_RESPONSE_TIME function activity.
--   It sets the RESPONSE_TIME item attribute to the specified period of time
--   in units of DAYS.
--
--   Customization:  When customizing this procedure, you must set the
--                   RESPONSE_TIME item attribute to the response time period
--                   in units of DAYS.
-- ---------------------------------------------------------------------------

  PROCEDURE Set_Response_Deadline( itemtype      VARCHAR2,
                               	   itemkey       VARCHAR2,
                                   actid         NUMBER,
                                   funmode       VARCHAR2,
                                   result    OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- Initialize_Escalation_Hist
--   This procedure corresponds to the Initialize_Escalation_Hist function
--   activity.  It initializes the ESCALATION_HISTORY item attribute.
-- ---------------------------------------------------------------------------

  PROCEDURE Initialize_Escalation_Hist( itemtype       VARCHAR2,
                                        itemkey        VARCHAR2,
                                        actid          NUMBER,
                                        funmode        VARCHAR2,
                                        result     OUT NOCOPY VARCHAR2 );

-- ---------------------------------------------------------------------------
-- Update_Escalation_Hist
--   This procedure corresponds to the UPDATE_ESCALATION_HIST function
--   activity.  It updates the ESCALATION_HISTORY item attribute.
-- ---------------------------------------------------------------------------

  PROCEDURE Update_Escalation_Hist( itemtype       VARCHAR2,
                                    itemkey        VARCHAR2,
                                    actid          NUMBER,
                                    funmode        VARCHAR2,
                                    result     OUT NOCOPY VARCHAR2 );


END CS_WF_ACTIVITIES_CUST;

 

/
