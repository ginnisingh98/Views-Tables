--------------------------------------------------------
--  DDL for Package LNS_BUS_EVENT_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_BUS_EVENT_SUB_PVT" AUTHID CURRENT_USER AS
/* $Header: LNS_BUS_EVENT_S.pls 120.0 2005/05/31 18:22:42 appldev noship $ */

FUNCTION Delinquency_Create(p_subscription_guid In RAW, p_event IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2;

END LNS_BUS_EVENT_SUB_PVT; -- Package spec

 

/
