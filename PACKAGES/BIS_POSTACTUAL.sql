--------------------------------------------------------
--  DDL for Package BIS_POSTACTUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_POSTACTUAL" AUTHID CURRENT_USER as
/* $Header: BISPACTS.pls 120.1 2005/10/06 06:58:30 ankgoel noship $ */

TYPE t_orgTable is TABLE of VARCHAR2(30)
	INDEX BY BINARY_INTEGER;

--
-- Inserts 1 row into bis_actual_values
--
PROCEDURE Post_Actual
( x_target_lvl_short_name  IN VARCHAR2
, x_organization_id        IN NUMBER
, x_actual_value           IN NUMBER
, x_timestamp              IN DATE DEFAULT NULL
, x_DIMENSION1_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION2_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION3_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION4_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION5_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
);

--
-- Gets the orgs that users have chosen to view KPIs for on the Configurable
-- Homepage.  the index of x_orgtable is the org_id, and the value is the
-- most recent start_date||'+'||end_date for that target level and that org.
--
/*PROCEDURE get_trgt_level_orgs
( p_target_lvl_short_name IN VARCHAR2
, x_orgtable              OUT NOCOPY t_orgTable
);*/

--
-- Gets the most recent start_end date for for p_period_type as defined
-- in p_calendar if the calendar or the period is invalid,
-- to_char(sysdate)||'+'||to_char(sysdate) is returned. if no data found,
-- an empty string is passed back.
--
FUNCTION Get_Start_End_Date
( p_calendar    IN VARCHAR2
, p_period_type IN VARCHAR2
)
RETURN VARCHAR2;

--
-- Gets the set of books id for p_organization_id
--
/*PROCEDURE Get_SOB
( p_organization_id IN NUMBER
, x_sob             OUT NOCOPY NUMBER
, x_msg             OUT NOCOPY VARCHAR2
) ;*/

--
-- Gets the calendar used by p_organization_id at p_target_level_name.
-- if the organization does not have a valid sob, the default calendar
-- 'Accounting' is returned.
--
/*PROCEDURE Get_Indicator_Calendar
( p_target_lvl_short_name IN VARCHAR2
, p_organization_id       IN NUMBER
, x_calendar              OUT NOCOPY VARCHAR2
, x_msg                   OUT NOCOPY VARCHAR2
) ;*/

end BIS_PostActual;

 

/
