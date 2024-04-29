--------------------------------------------------------
--  DDL for Package BIS_PMF_MIGRATE_DIMENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_MIGRATE_DIMENSIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVMDLS.pls 115.6 2002/12/16 10:26:04 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVMDLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for getting Dimensions from EDW and populating the
REM |     corresponding BIS Tables  .
REM |                                                                       |
REM | HISTORY                                                               |
REM | August-2000 amkulkar Creation
REM +=======================================================================+
*/
--
G_EDW		VARCHAR2(80) := 'EDW';
G_LEVEL_EXCLUSION_STRING VARCHAR(32000) := '(''EDW_LOOKUP_M'')';
PROCEDURE MIGRATE_EDW_DIMENSIONS
(ERRBUF              OUT NOCOPY   VARCHAR2
,RETCODE             OUT NOCOPY   VARCHAR2
);
END BIS_PMF_MIGRATE_DIMENSIONS_PVT;

 

/
