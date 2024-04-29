--------------------------------------------------------
--  DDL for Package Body BIS_PMV_DRILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_DRILL_PUB" as
/* $Header: BISPDRIB.pls 115.3 2002/08/16 01:28:07 gsanap noship $ */

PROCEDURE DRILLACROSS
(pURL		IN	VARCHAR2
,pSessionId	IN	VARCHAR2	DEFAULT NULL
,pUserId	IN	VARCHAR2	DEFAULT NULL
,pResponsibilityId IN 	VARCHAR2	DEFAULT NULL
,pFunctionName	IN	VARCHAR2	DEFAULT NULL
)
IS
BEGIN
	BIS_PARAMETER_VALIDATION.DRILLACROSS
	(pUrlString => pUrl
	,pSessionId => pSessionId
	,pUserId    => pUserId
	,pFunctionName => pFunctionName
	,pRespId => pResponsibilityId
	);
EXCEPTION
WHEN OTHERS THEN
	NULL;
END DRILLACROSS;

end BIS_PMV_DRILL_PUB;

/
