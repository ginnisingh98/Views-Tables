--------------------------------------------------------
--  DDL for Package WSH_DSNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DSNO" AUTHID CURRENT_USER as
/* $Header: WSHDSNOS.pls 120.0.12010000.1 2008/07/29 06:02:06 appldev ship $ */

  --
  -- PROCEDURE:         Submit
  -- Purpose:           Submit DSNO for a Trip Stop
  -- Arguments:         p_trip_stop_id - Trip Stop Identifier
  -- Description:       Submits DSNO for a trip stop
  --
--  Bug 2425936 : added a parameter p_trip_id included in
--                concurrent program for performance issue
PROCEDURE Submit (
	errbuf	        OUT NOCOPY      VARCHAR2,
	retcode 	OUT NOCOPY      VARCHAR2,
	p_trip_id	IN	NUMBER  DEFAULT NULL,
	p_trip_stop_id	IN	NUMBER);


-- start bug 1578251: new procedure submit_trip_stop with x_completion_status
  --
  -- PROCEDURE:         Submit_Trip_stop
  -- Purpose:           Submit DSNO for a Trip Stop
  -- Arguments:         p_trip_stop_id - Trip Stop Identifier
  --                    x_completion_status - result of this submission
  -- Description:       Submits DSNO for a trip stop
  --

PROCEDURE Submit_Trip_Stop (
	p_trip_stop_id      IN	NUMBER,
        x_completion_status OUT NOCOPY  VARCHAR2);
-- end bug 1578251: new procedure submit_trip_stop with x_completion_status


END WSH_DSNO;

/
