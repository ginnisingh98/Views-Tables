--------------------------------------------------------
--  DDL for Package BIS_DIMLEVEL_ERRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIMLEVEL_ERRS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVEDES.pls 115.4 2002/12/16 10:25:33 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVGDLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private Script for reporting inconsistencies in the dimension levels
REM |     of EDW like missing table for values, missing PK Key, start_Date  |
REM |     end_Date etc                                                      |
REM |     This package has limited error handling for file activities.      |
REM |                                                                       |
REM | HISTORY                                                               |
REM | December-2000 amkulkar Creation                                       |
REM +=======================================================================+
*/
--
-- CONSTANTS
   EDW_ERRORS             VARCHAR2(2000) := 'DIMLEVELERRORS.log';
PROCEDURE FILE_OPEN
(p_file_name              IN     VARCHAR2  DEFAULT EDW_ERRORS
,x_file_handle            OUT NOCOPY    UTL_FILE.FILE_TYPE
);
PROCEDURE WRITE_TO_FILE
(p_text           IN     VARCHAR2
,p_file_handle    IN     UTL_FILE.FILE_TYPE
);
PROCEDURE REPORT_ERRORS
(p_Dim_Level_Name         IN     VARCHAR2   DEFAULT NULL
,p_file_name              IN     VARCHAR2   DEFAULT NULL
);
END BIS_DIMLEVEL_ERRS_PVT;

 

/
