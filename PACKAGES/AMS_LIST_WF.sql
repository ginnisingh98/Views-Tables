--------------------------------------------------------
--  DDL for Package AMS_LIST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_WF" AUTHID CURRENT_USER AS
/* $Header: amsvwlis.pls 120.1 2005/06/27 05:42:09 appldev ship $*/

--  Start of Comments
--
-- NAME
--   AMS_LIST_WF
--
-- PURPOSE
--   This package performs contains the workflow procedures for
--   List generation in OMO
--
-- HISTORY
--   03/08/2001        gjoby@us        CREATED

/***************************  PRIVATE ROUTINES  *******************************/
-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- End of Comments

PROCEDURE StartProcess
                   ( p_list_header_id        IN      NUMBER
                     ,workflowprocess        IN      VARCHAR2 DEFAULT NULL) ;

-- Start of Comments
--
-- NAME
--   Generate List
--
-- PURPOSE
--   This Procedure will call the generation of list
--
-- NOTES
--
--
-- HISTORY
-- End of Comments

PROCEDURE Generate_list(itemtype  IN	  VARCHAR2,
                        itemkey   IN	  VARCHAR2,
                        actid	    IN	  NUMBER,
                        funcmode  IN	  VARCHAR2,
                        result    OUT NOCOPY   VARCHAR2) ;

PROCEDURE Check_SCH(itemtype  IN       VARCHAR2,
                        itemkey   IN       VARCHAR2,
                        actid         IN       NUMBER,
                        funcmode  IN       VARCHAR2,
                        result    OUT NOCOPY   VARCHAR2) ;



PROCEDURE GEN_TARGET(itemtype  IN       VARCHAR2,
                    itemkey   IN       VARCHAR2,
                    actid         IN       NUMBER,
                    funcmode  IN       VARCHAR2,
                    result    OUT NOCOPY   VARCHAR2) ;
PROCEDURE Check_TAR(itemtype  IN       VARCHAR2,
                    itemkey   IN       VARCHAR2,
                    actid         IN       NUMBER,
                    funcmode  IN       VARCHAR2,
                    result    OUT NOCOPY   VARCHAR2) ;

PROCEDURE StartListBizEventProcess
                   ( p_list_header_id        IN      NUMBER);

PROCEDURE Wf_Init_var(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) ;

PROCEDURE Wf_abort_process
                   ( p_list_header_id        IN      NUMBER);

PROCEDURE Check_Item_Key        (itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2) ;
END;

 

/
