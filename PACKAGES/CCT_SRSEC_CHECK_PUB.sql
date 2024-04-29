--------------------------------------------------------
--  DDL for Package CCT_SRSEC_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_SRSEC_CHECK_PUB" AUTHID CURRENT_USER as
/* $Header: cctsrses.pls 115.1 2003/09/29 15:55:04 gvasvani noship $ */

--procedure TestSRSecurityT(p_table IN OUT NOCOPY System.CCT_AGENT_RESP_APP_ID_NST );
G_SR_FUNC_VER_1          VARCHAR2(64)   :='sr_uwq_integ';

procedure authenticate_agents(p_srnum IN Varchar2, p_agentIDs IN OUT NOCOPY Varchar2, p_isServerGroupID IN Varchar2, x_return_status OUT NOCOPY Varchar2);
procedure CallSRSecurityCheck(p_srnum IN Varchar2,p_table in out NOCOPY system.CCT_AGENT_RESP_APP_ID_NST, x_return_status out NOCOPY varchar2);

END CCT_SRSEC_CHECK_PUB;

 

/
