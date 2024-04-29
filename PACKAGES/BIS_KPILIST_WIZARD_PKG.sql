--------------------------------------------------------
--  DDL for Package BIS_KPILIST_WIZARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_KPILIST_WIZARD_PKG" AUTHID CURRENT_USER AS
/* $Header: BISFKPIS.pls 120.0 2005/05/31 18:28:38 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISFKPIS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     API for KPI Wizards                                               |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 14-OCT-2003   akchan  Initial Creation                                |
REM | 11-FEB-2004   gbhaloti  Added API for deleting a function		    |
REM +=======================================================================+
*/
--
--
PROCEDURE CREATE_FUNCTION
( p_function_name IN  VARCHAR2
, p_document_name IN  VARCHAR2
, p_portlet_name  IN  VARCHAR2
, p_description   IN  VARCHAR2 := NULL
, x_function_id   OUT NOCOPY VARCHAR2
);

--
--
--

PROCEDURE UPDATE_FUNCTION
( p_function_id        IN VARCHAR2
, p_function_name      IN VARCHAR2
, p_parameters         IN VARCHAR2
, p_user_function_name IN VARCHAR2
, p_description        IN VARCHAR2 := NULL
);


PROCEDURE UPDATE_FUNCTION_PARAMETERS
( p_function_short_name   IN VARCHAR2
, p_parameters            IN VARCHAR2
, p_user_function_name    IN VARCHAR2
);


--procedure to delete a function entry
PROCEDURE DELETE_FUNCTION
( p_function_name       IN VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
);


END BIS_KPILIST_WIZARD_PKG;

 

/
