--------------------------------------------------------
--  DDL for Package CCT_ROUTE_RESULT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_ROUTE_RESULT_PUB" AUTHID CURRENT_USER as
/* $Header: cctrress.pls 115.4 2002/11/28 01:10:58 gvasvani noship $ */
NULL_POINTER_EXCEPTION EXCEPTION;
G_TRUE Varchar2(1) := 'Y';
G_FALSE Varchar2(1) := 'N';
G_AGENTIDS Varchar2(32) := 'AGENTIDS';
G_ROUTEPOINT Varchar2(32) := 'ROUTEPOINT';

FUNCTION   AddAgentID(
     p_routeResult_varr  IN OUT NOCOPY cct_routeResult_varr
    ,p_agentID             IN VARCHAR2
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2;

FUNCTION   AddRoutePoint(
     p_routeResult_varr  IN OUT NOCOPY cct_routeResult_varr
    ,p_RoutePoint             IN VARCHAR2
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2;

FUNCTION	 GetResultType(
     p_routeResult_varr  IN cct_routeResult_varr
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2;

FUNCTION   SetResultType(
     p_routeResult_varr  IN OUT NOCOPY cct_routeResult_varr
    ,p_routeResult IN VARCHAR2
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2;

FUNCTION   NumOfAgents(
     p_routeResult_varr  IN cct_routeResult_varr
 ) return NUMBER;

END CCT_Route_Result_Pub;


 

/
