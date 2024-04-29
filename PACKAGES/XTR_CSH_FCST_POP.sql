--------------------------------------------------------
--  DDL for Package XTR_CSH_FCST_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_CSH_FCST_POP" AUTHID CURRENT_USER AS
/* $Header: xtrfpcls.pls 115.3 2002/03/08 17:22:55 pkm ship      $ */

-- CONTEXT: CALL = XTR_CASH_FCST.Forecast
--   Global variables
--
source_view		VARCHAR2(160);
G_calendar_start	DATE;
G_calendar_end		DATE;

--
-- Global Procedures/Functions
--
PROCEDURE Populate_Aging_Buckets;

PROCEDURE Populate_Cells;

END XTR_CSH_FCST_POP;

 

/
