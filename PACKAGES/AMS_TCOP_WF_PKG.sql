--------------------------------------------------------
--  DDL for Package AMS_TCOP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TCOP_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvtcws.pls 120.1 2005/11/17 04:16:30 mayjain noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_WF_PKG
-- Purpose
--
-- This package has all the methods required to integrate with
-- OMO Schedule Execution Workflow
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_TCOP_WF_PKG';

Procedure Is_Fatigue_Enabled (

          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out NOCOPY varchar2
);

Procedure Add_Request_To_Queue (
          itemtype in varchar2,
	  itemkey in varchar2,
	  actid in varchar2,
	  funcmode in varchar2,
	  result out NOCOPY varchar2
);

Procedure Is_This_Request_Scheduled (
          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out NOCOPY varchar2
);

Procedure Invoke_TCOP_Engine (
          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out NOCOPY varchar2
);

Procedure Run_FR_Conc_Request (
          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out NOCOPY varchar2
);

END AMS_TCOP_WF_PKG;

 

/
