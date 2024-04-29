--------------------------------------------------------
--  DDL for Package BIS_AUTOINC_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_AUTOINC_SCHEDULE" AUTHID CURRENT_USER as
/* $Header: BISVAISS.pls 115.3 2002/08/16 01:32:55 gsanap noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      bis_autoinc_schedule                                    --
--                                                                        --
--  DESCRIPTION:  Auto increment dates for PM Viewer scheduled reports.   --                            --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  XX-XXX-XX  XXXXXXXX   xxxxxxxxxxxxxxxxxxxxx                           --
--  07/17/2001 dmarkman   Initial creation                                --
--                                                                        --
----------------------------------------------------------------------------

procedure autoIncrementDates(pRegionCode       in varchar2,
                             pFunctionName     in varchar2,
                             pSessionId        in varchar2,
                             pUserId           in varchar2,
                             pResponsibilityId in varchar2,
                             pScheduleId       in varchar2);


end bis_autoinc_schedule;


 

/
