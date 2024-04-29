--------------------------------------------------------
--  DDL for Package MST_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_RELEASE" AUTHID CURRENT_USER AS
/*$Header: MSTRELPS.pls 115.3 2003/10/15 17:23:32 atsrivas noship $ */

  type number_tab_type is table of number index by binary_integer;

  -- this procedure is called from ui to insert trip data into mst_release_temp for release
  -- for loads given in p_load_tab. if p_load_type = 'CM' then this list contains CMs otherwise trips

  procedure insert_trips (p_plan_id            IN NUMBER
                        , p_release_id         IN NUMBER
                        , p_load_tab           IN NUMBER_TAB_TYPE
                        , p_load_type          IN VARCHAR2);--'CM' or 'TRIP'

  -- this procedure is used to release the loads for release_id = p_release_id in mst_release_trips
  -- it is called from ui after inserting trip data into mst_release_temp using procedure 'insert_trips'
  -- also it is called from procedure 'release_plan' after inserting plan's trip data into mst_release_temp

  procedure release_load (p_err_code           OUT NOCOPY VARCHAR2
                        , p_err_buff           OUT NOCOPY VARCHAR2
                        , p_plan_id            IN         NUMBER
                        , p_release_id         IN         NUMBER
                        , p_release_mode       IN         NUMBER DEFAULT NULL);

  -- this procedure is called form ui as well as engine to release entire plan

  procedure release_plan (p_err_code           OUT NOCOPY VARCHAR2
                        , p_err_buff           OUT NOCOPY VARCHAR2
                        , p_plan_id            IN         NUMBER
                        , p_release_id         IN         NUMBER
                        , p_release_mode       IN         NUMBER DEFAULT NULL);


-- p_release_mode = 1    => auto release
--                = null => manual release


  procedure submit_release_request ( p_request_id         OUT NOCOPY NUMBER
                                   , p_release_type       IN VARCHAR2  -- 'LOAD' or 'PLAN
                                   , p_plan_id            IN NUMBER
                                   , p_release_id         IN NUMBER
                                   , p_release_mode       IN NUMBER DEFAULT NULL);

------ following functions are being used in MSTEXCEP.pld -------------------------------------------
  --  p_release_type = 1  => auto released, 2 => released, 3 => flagged for release, 4 => unreleased
  procedure set_release_type (p_release_type IN NUMBER);

  -- used in views of all tls, all ltls, all parcels, all continuous moves
  function get_release_type RETURN NUMBER;
-----------------------------------------------------------------------------------------------------

END MST_RELEASE;

 

/
