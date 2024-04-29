--------------------------------------------------------
--  DDL for Package BIS_PMV_DRILL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_DRILL_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVDRIS.pls 120.1 2006/02/13 02:48:18 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.15=120.1):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PMV_DRILL_PVT                                       --
--                                                                        --
--  DESCRIPTION:  This package contains all the procedures used to        --
--                validate the Report Generator parameters.               --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  10/24/01   aleung     initial creation                                --
--  07-JUN-03 gsanap      Added p_NextExtraViewBy to drilldown bug 3007145--
----------------------------------------------------------------------------
  gvAll varchar2(3) := 'All';

  procedure copyParameters(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pPreFunctionName    in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pScheduleId         in varchar2 default null,
                        pPageId         in  varchar2 default null,
                        pRespId         in  varchar2 default null);

    -- DIMENSION VALUE EXTENSION - DRILL - Bug 3230530 / Bug 3004363
PROCEDURE copyGroupedParameters(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pPreFunctionName    in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pScheduleId         in varchar2 default null,
                          pPageId         in  varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type,
                          pTCTExists      in boolean default false,
                          pNestedRegionCode in varchar2 default null,
                          pAsofdateExists in boolean default false,
			  xTimeAttribute out NOCOPY varchar2

                        ) ;
END BIS_PMV_DRILL_PVT;

 

/
