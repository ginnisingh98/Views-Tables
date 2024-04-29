--------------------------------------------------------
--  DDL for Package BIS_PMV_DRILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_DRILL_PUB" AUTHID CURRENT_USER as
/* $Header: BISPDRIS.pls 115.3 2002/08/16 01:28:14 gsanap noship $ */

PROCEDURE DRILLACROSS
(pURL		IN	VARCHAR2
,pSessionId	IN	VARCHAR2	DEFAULT NULL
,pUserId	IN	VARCHAR2	DEFAULT NULL
,pResponsibilityId IN 	VARCHAR2	DEFAULT NULL
,pFunctionName	IN	VARCHAR2	DEFAULT NULL
)
;
end BIS_PMV_DRILL_PUB;

 

/
