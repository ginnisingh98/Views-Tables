--------------------------------------------------------
--  DDL for Package BOM_CALENDAR_API_BK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CALENDAR_API_BK" AUTHID CURRENT_USER AS
-- $Header: BOMCALAS.pls 120.1 2005/06/21 05:29:08 appldev ship $
-- =========================================================================+
--  Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
--                         All rights reserved.                             |
-- =========================================================================+
--                                                                          |
-- File Name    : BOMCALAS.pls                                              |
-- Description  : This API will validate the input date against input       |
--                calendar as a valid working day.   		            |
-- Parameters: 	 x_calendar_code the calendar user wants to use	            |
--		 x_date 	 input date user wants to verify            |
--		 x_working_day   show is this date a working date	    |
--		 err_code	 error code, if any error happens	    |
--		 err_meg	 error message, if any error happens        |
-- Revision                                                                 |
--               Jen-Ya Ku    	 Creation                                   |
-- =========================================================================
PROCEDURE CHECK_WORKING_DAY (
	x_calendar_code  IN VARCHAR2,
	x_date	       IN DATE,
	x_working_day  IN OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
        err_code       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	err_meg	       IN OUT NOCOPY /* file.sql.39 change */ VARCHAR);

FUNCTION CHECK_WORKING_SHIFT (
	x_calendar_code IN VARCHAR2,
	x_date		IN DATE,
	err_code       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
	err_meg	       IN OUT NOCOPY /* file.sql.39 change */ VARCHAR)
return BOOLEAN;
END BOM_CALENDAR_API_BK;

 

/
