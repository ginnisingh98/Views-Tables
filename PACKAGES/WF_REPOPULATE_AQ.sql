--------------------------------------------------------
--  DDL for Package WF_REPOPULATE_AQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_REPOPULATE_AQ" AUTHID CURRENT_USER AS
/* $Header: WFAQREPS.pls 120.1 2005/07/02 04:26:09 appldev ship $ */

--
-- Procedure
--   PopulateAQforItem
--
-- Purpose
--   Repopulates the smtp and/or deferred queue with actions related to a
-- 	particular item, item type, or all items.  Note: It does not clear
--      off existing actions already on the queues...instead we rely on the
--	runtime code to verify actions still need to be done.
--
-- Arguments:
--	ItemType 	-- set to null for all items.
--	ItemKey  	-- set to null for all items in type.
--	SMTPFlag 	-- Y/N: repopulate smtp aq?
--	DeferredFlag 	-- Y/N: repopulate deferred aq?
--
Procedure PopulateAQforItem(	ItemType in VARCHAR2,
				ItemKey in VARCHAR2,
				SMTPFlag in VARCHAR2 default 'Y',
				DeferredFlag in VARCHAR2 default 'Y');

END WF_Repopulate_AQ;

 

/
