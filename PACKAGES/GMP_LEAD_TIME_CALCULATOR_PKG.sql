--------------------------------------------------------
--  DDL for Package GMP_LEAD_TIME_CALCULATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_LEAD_TIME_CALCULATOR_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPLTCPS.pls 120.1.12010000.1 2008/07/30 06:15:43 appldev ship $ */

PROCEDURE calculate_lead_times(
        errbuf		OUT  NOCOPY VARCHAR2,
        retcode         OUT  NOCOPY VARCHAR2,
        /*Sowmya - Inventory convergence - begin*/
        /*
        p_from_orgn_code VARCHAR2 ,
        p_to_orgn_code    VARCHAR2,
        p_from_item_no  VARCHAR2,
        p_to_item_no    VARCHAR2) ;
        */
        /*Sowmya - Inventory convergence - End*/
        p_from_orgn             NUMBER,
	p_to_orgn               NUMBER,
        p_from_item_id          NUMBER,
        p_to_item_id            NUMBER) ;

PROCEDURE calc_lead_time(p_routing_id  NUMBER);

PROCEDURE log_message( pbuff  IN VARCHAR2);

PROCEDURE time_stamp ;

/*Sowmya - Included a new function to get the average work hours*/
FUNCTION get_avg_working_hours (p_calendar_code IN VARCHAR2) RETURN NUMBER;

END gmp_lead_time_calculator_pkg ;

/
