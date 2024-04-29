--------------------------------------------------------
--  DDL for Package XNP_WF_TIMERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_WF_TIMERS" AUTHID CURRENT_USER AS
/* $Header: XNPWFTMS.pls 120.1 2005/06/24 04:51:11 appldev ship $ */

--
--
-- API Name   : Fire
-- Type       : Public
-- Purpose    : Invokes the 'Fire' procedure in the timer package
--
PROCEDURE FIRE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );

--
--
-- API Name   : Start Related Timers
-- Type       : Public
-- Purpose    : Starts timers related to the messag
--
PROCEDURE START_RELATED_TIMERS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );
--
--
-- API Name   : Get Timer Status
-- Type       : Public
-- Purpose    : Retrieves the status of the time
--
PROCEDURE GET_TIMER_STATUS
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );
--
--
-- API Name   : Restart All
-- Type       : Public
-- Purpose    : Restart all timers
--
PROCEDURE RESTART_ALL
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );
--
--
-- API Name   : Recalculate All
-- Type       : Public
-- Purpose    : Recalculate all timers
--
PROCEDURE RECALCULATE_ALL
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );
--
--
-- API Name   : Remove
-- Type       : Public
-- Purpose    : Remove the timer
--
PROCEDURE REMOVE
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );
--
--
-- API Name   : DeRegister
-- Type       : Public
-- Purpose    : Removes all timers related to an order
--
PROCEDURE DEREGISTER
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );
--
--
-- API Name   : Get Jeopardy Flag
-- Type       : Public
-- Purpose    : Retrieves the jeopardy flag for the given order ID
--
PROCEDURE GET_JEOPARDY_FLAG
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 );

END XNP_WF_TIMERS;

 

/
