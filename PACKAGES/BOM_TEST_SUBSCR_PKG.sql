--------------------------------------------------------
--  DDL for Package BOM_TEST_SUBSCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_TEST_SUBSCR_PKG" AUTHID CURRENT_USER as
/* $Header: BOMTSUBS.pls 120.6 2008/05/29 20:30:22 atjen ship $ */
/**
  * This package provides function for testing BOM business events.
  */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMTSUBS.pls
--
--  DESCRIPTION
--
--      This package is used to test the BOM business events.
--
--  NOTES
--
--  HISTORY
--
-- 24-Oct-2005   Selva Radhakrishnan   Initial Creation
***************************************************************************/

  /**
    * This function is used to test the business events raised
    * in BOM APIs and BOs.
    */

FUNCTION bom_test_subscription (p_subscription_guid IN RAW,
                                 p_event IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2;

  /**
    * This function is used to test the business events raised
    * in BOM APIs and BOs.
    */

PROCEDURE SET_BOM_EVENT_INFO
(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2
);


END Bom_Test_Subscr_PKG;

/
