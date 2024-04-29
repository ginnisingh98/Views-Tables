--------------------------------------------------------
--  DDL for Package Body CCT_ROUTE_RESULT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_ROUTE_RESULT_PUB" as
/* $Header: cctrresb.pls 115.4 2002/11/28 01:13:06 gvasvani noship $ */

FUNCTION	 AddAgentID(
     p_routeResult_varr  IN OUT NOCOPY cct_routeResult_varr
    ,p_agentID             IN VARCHAR2
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2 IS

   l_return_status varchar2(32) := G_FALSE;
   i BINARY_INTEGER;
 begin
    x_return_status := G_FALSE;
    If (p_agentID IS NULL) Then
        RAISE NULL_POINTER_EXCEPTION;
    End If ;

    l_return_status := SetResultType(p_routeResult_varr,G_AGENTIDS,l_return_status);

    p_routeResult_varr.EXTEND();
    i := p_routeResult_varr.LAST;
    p_routeResult_varr(i) := p_agentID;
    x_return_status := G_TRUE;
    return x_return_status;
    EXCEPTION
      WHEN NULL_POINTER_EXCEPTION THEN
        RAISE NULL_POINTER_EXCEPTION;
      WHEN OTHERS THEN
      return x_return_status;
-- end ;
END AddAgentID;

FUNCTION	 AddRoutePoint(
     p_routeResult_varr  IN OUT NOCOPY cct_routeResult_varr
    ,p_RoutePoint             IN VARCHAR2
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2 IS

   l_return_status varchar2(1) := G_FALSE;
   i BINARY_INTEGER;
 begin
    x_return_status := G_FALSE;
    If (p_RoutePoint IS NULL) Then
        RAISE NULL_POINTER_EXCEPTION;
    End If ;

    l_return_status :=SetResultType(p_routeResult_varr,G_ROUTEPOINT,l_return_status);
    p_routeResult_varr.EXTEND();
    i := p_routeResult_varr.LAST;
    p_routeResult_varr(i) := p_RoutePoint;
    x_return_status := G_TRUE;
    return x_return_status;
    EXCEPTION
      WHEN NULL_POINTER_EXCEPTION THEN
        RAISE NULL_POINTER_EXCEPTION;
      WHEN OTHERS THEN
      return x_return_status;
-- end ;
END AddRoutePoint;

FUNCTION	 GetResultType(
     p_routeResult_varr  IN cct_routeResult_varr
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2 IS

   l_routeResult varchar2(4000) :='';
   i BINARY_INTEGER;
 begin
    x_return_status := G_FALSE;
    i := p_routeResult_varr.FIRST;
    if (i <= p_routeResult_varr.LAST) then
	--dbms_output.put_line (' Value of routeResult is ' || p_routeResult_varr(i));
      l_routeResult := p_routeResult_varr(i);
      x_return_status := G_TRUE;
    End If ;
    return l_routeResult;
    EXCEPTION
      WHEN OTHERS THEN
      return l_routeResult;
END GetResultType;

FUNCTION	 SetResultType(
     p_routeResult_varr  IN OUT NOCOPY cct_routeResult_varr
    ,p_routeResult IN VARCHAR2
    ,x_return_status Out NOCOPY VARCHAR2
 ) return varchar2 IS

   l_routeResult varchar2(4000) :='';
   l_orig_result varchar2(4000) :='';
   i BINARY_INTEGER;
 begin
    x_return_status := G_FALSE;
    --For varrays, FIRST always returns 1 and LAST always equals COUNT
    i := p_routeResult_varr.COUNT();
    if (i=0) then
	 p_routeResult_varr.EXTEND();
    elsif (i>1) then
      i := p_routeResult_varr.FIRST;
	 if (p_routeResult_varr(i)<>p_routeResult) then
		 p_routeResult_varr.DELETE();
		 p_routeResult_varr.EXTEND();
      else
		x_return_status := G_TRUE;
		return p_routeResult;
	 end if ;
    end if;
    i := p_routeResult_varr.FIRST;
    if (i <= p_routeResult_varr.LAST) then
	--dbms_output.put_line (' Value of routeResult is ' || p_routeResult_varr(i));
      l_orig_result := p_routeResult_varr(i);
      p_routeResult_varr(i) := p_routeResult;
      x_return_status := G_TRUE;
    End If ;
    return l_orig_result;
    EXCEPTION
      WHEN NULL_POINTER_EXCEPTION THEN
        RAISE NULL_POINTER_EXCEPTION;
      WHEN OTHERS THEN
      return l_orig_result;
END SetResultType;

FUNCTION	 NumOfAgents(
     p_routeResult_varr  IN cct_routeResult_varr
 ) return NUMBER IS

   l_size NUMBER;
   i BINARY_INTEGER;
 begin
    i := p_routeResult_varr.COUNT();
    l_size := i-1;
    return l_size;
    EXCEPTION
      WHEN OTHERS THEN
      return l_size;
-- end ;
END NumOfAgents;


END CCT_Route_Result_Pub;


/
