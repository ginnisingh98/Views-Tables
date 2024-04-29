--------------------------------------------------------
--  DDL for Package CCT_PERFTEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_PERFTEST_PKG" AUTHID CURRENT_USER as
/* $Header: cctpfts.pls 120.0 2005/06/02 09:53:36 appldev noship $ */

Procedure DNIS_STATICGROUP_FILTER(
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy varchar2
  );

Function Get_SGAgents_for_DNIS(
    p_dnis IN VARCHAR2,
    x_agent_tbl IN OUT nocopy CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
)
RETURN NUMBER;
END CCT_PERFTEST_PKG;

 

/
