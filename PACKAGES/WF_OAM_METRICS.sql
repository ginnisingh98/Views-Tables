--------------------------------------------------------
--  DDL for Package WF_OAM_METRICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_OAM_METRICS" AUTHID CURRENT_USER as
/* $Header: WFOAMMTS.pls 120.0.12010000.2 2014/05/13 07:44:19 skandepu ship $ */

--workItemsStatConcurrent
--	This procedure is invoked by the concurrent program FNDWFWITSTATCC
--	to populate the metrics data corresponding to Work Items.
procedure workItemsStatConcurrent(errorBuf OUT NOCOPY VARCHAR2,
                                  errorCode  OUT NOCOPY VARCHAR2);

procedure populateWorkItemsGraphData;

procedure populateActiveWorkItemsData;

procedure populateErroredWorkItemsData;

procedure populateDeferredWorkItemsData;

procedure populateSuspendedWorkItemsData;

procedure populateCompletedWorkItemsData;


--agentActivityStatConcurrent
--      This procedure is invoked by the concurrent program FNDWFAASTATCC
--      to populate the metrics data corresponding to Agent Activity.
procedure agentActivityStatConcurrent(errorBuf OUT NOCOPY VARCHAR2,
                                      errorCode  OUT NOCOPY VARCHAR2);

procedure populateAgentActivityGraphData;

procedure populateAgentActivityData;

function extractAgentName(pName varchar2) return varchar2;


--ntfMailerStatConcurrent
--      This procedure is invoked by the concurrent program FNDWFMLRSTATCC
--      to populate the Notification Mailer throughput data.
procedure ntfMailerStatConcurrent(errorBuf OUT NOCOPY VARCHAR2,
                               errorCode  OUT NOCOPY VARCHAR2);

procedure populateNtfMailerGraphData;

END WF_OAM_METRICS;

/
