--------------------------------------------------------
--  DDL for Package Body GMP_DP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_DP_UTILS" as
/* $Header: GMPDPUTB.pls 120.1 2005/09/08 06:57:22 rpatangy noship $ */

--+==========================================================================+
--| PROCEDURE NAME
--|    opm_forecast_interface
--|
--| DESCRIPTION
--|        Just a wrapper function
--| Input Parameters
--|   pforecast       VARCHAR2
--|   p_org_id        NUMBER
--|   p_user_id       NUMBER
--|
--|  Pseudo Code
--|  Check if a forecast designator has been provided,
--|  If     Not Get all process org designators
--|         And do the processing for each of the designator
--|  Else
--|         Do the processing for the designator passsed in
--|  End If
--|
--|  Please note that the user is NOT allowed to specify only the warehouse
--|  (and not the designator)
--|  But the user is allowed to specify the warehosue along with adesignator
--|
--| Pseudo logic for processing of a designator
--|  Check if forecast code already exist in OPM
--|  Yes : Delete rows or the one or allwarehouses
--|  No  : Create  header
--|
--|  Get the rows from mrp_forecast interace for one or
--|  multiple organizations-ids
--|
--|  Insert into the  fc_fcst_dtl table
--|
--|  Keep a count and commit after every 500 ??
--|
--|  Update the mrp_forecast_interface table
--|
--+==========================================================================+

PROCEDURE opm_forecast_interface (
    errbuf       OUT NOCOPY varchar2,
    retcode      OUT NOCOPY varchar2,
    pforecast    IN VARCHAR2,
    porg_id      IN number ,
    p_user_id    IN number )
IS

BEGIN

    errbuf := 'This functionality is obsolete in R12.0';
    retcode := 0;
END opm_forecast_interface ;

--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    truncate_forecast_names                                               |
--|                                                                          |
--| TYPE                                                                     |
--|    public                                                                |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--|   This function is used to truncate all of the forcast names to 10       |
--|   characters long and make them unique for the demand planner interface  |
--|                                                                          |
--| Input Parameters                                                         |
--|   None                                                                   |
--|                                                                          |
--| Output Parameters                                                        |
--|                                                                          |
--| AUTHOR                                                                   |
--|   Matthew Craig 5-Oct-2000                                               |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

PROCEDURE truncate_forecast_names(
  errbuf              OUT NOCOPY VARCHAR2,
  retcode             OUT NOCOPY VARCHAR2,
  p_user_id           IN NUMBER)
IS

BEGIN

    errbuf := 'This functionality is obsolete in R12.0';
    retcode := 0;

END truncate_forecast_names;

END gmp_dp_utils;

/
