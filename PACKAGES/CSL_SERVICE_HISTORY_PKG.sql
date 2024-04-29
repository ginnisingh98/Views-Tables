--------------------------------------------------------
--  DDL for Package CSL_SERVICE_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_SERVICE_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: cslsrhis.pls 120.0 2005/05/25 11:01:30 appldev noship $ */

/*Function returns the history count allowed for a resource*/
FUNCTION GET_HISTORY_COUNT( p_resource_id IN NUMBER ) RETURN NUMBER;

/*Procedure calculates the x number of history service request for the given sr */
PROCEDURE CALCULATE_HISTORY( p_incident_id IN NUMBER
                           , p_resource_id IN NUMBER );

/*Procedure deletes all history records for a given service request*/
PROCEDURE DELETE_HISTORY( p_incident_id IN NUMBER
                        , p_resource_id IN NUMBER );

/*Procedure that loops over the acc table to gather incidents*/
PROCEDURE CONCURRENT_HISTORY;

END CSL_SERVICE_HISTORY_PKG;

 

/
