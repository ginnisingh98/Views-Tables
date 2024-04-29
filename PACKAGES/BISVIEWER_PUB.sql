--------------------------------------------------------
--  DDL for Package BISVIEWER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISVIEWER_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPUBPS.pls 115.4 2002/08/16 01:30:52 gsanap noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls 
-- dbdrv: checkfile:~PROD:~PATH:~FILE
/*===========================================================================+
 |  Copyright (c) 1995 Oracle Corporation Belmont, California, USA           |
 |                       All rights reserved                                 |
 +===========================================================================+
 |                                                                           |
 | FILENAME                                                                  |
 |      BISPUBS.pls                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |
 |                                                                           |
 | PUBLIC PROCEDURES                                                         |
 |      showReport	                                                      |
 |                                                                           |
 | PUBLIC FUNCTIONS                                                          |
 |      <None>                                                               |
 |                                                                           |
 | PRIVATE PROCEDURES                                                        |
 |      <None>                                                               |
 |                                                                           |
 | PRIVATE FUNCTIONS                                                         |
 |      <None>                                                               |
 |                                                                           |
 | HISTORY   	04-AUG-2001     STSAY     CREATION			     |
 +===========================================================================*/

procedure showReport(pUrlString        in   varchar2,
                        pUserId           in   varchar2    default null,
                        pRespId           in   varchar2    default null ,
                        pSessionId        in   varchar2    default null,
                        pFunctionName     in   varchar2    default null,
                        --jprabhud added pPageId for enhancement #2442162
                        pPageId           in   varchar2    default null

                       );


END BISVIEWER_PUB;

 

/
