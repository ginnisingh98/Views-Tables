--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_DETAILS_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_DETAILS_MAPPING" AUTHID CURRENT_USER AS
/* $Header: pqpvhdmp.pkh 115.1 2001/04/04 11:10:27 pkm ship       $ */
/*
   The functions declared in this header are designed to be used by the Data
   Pump engine to resolve id values that have to be passed to the API modules.
   However, most of these functions could also be used by any program that
   might want to do something similar.

   The exceptions to this are likely to be the functions where a user
   key value is one of the parameters.
*/
------------------------- get_vehicle_details_id --------------------------
/* NAME
    get_vehicle_details_id
  DESCRIPTION
    Returns Vehicle details Id.
  NOTES
    This function returns a tax_unit_id.  */

FUNCTION get_vehicle_details_id
( p_vehicle_details_user_key   IN VARCHAR2
 ) RETURN NUMBER;
pragma restrict_references (get_vehicle_details_id,WNDS);

-------------------------- get_vehicle_details_ovn -------------------------
/* NAME
    get_vehicle_details_ovn
  DESCRIPTION
    Returns vehicle details Object Version Number.
  NOTES
    This function returns the OVN .  */

FUNCTION get_vehicle_details_ovn
(
    p_vehicle_details_user_key IN VARCHAR2
)
   RETURN NUMBER;
pragma restrict_references (get_vehicle_details_ovn,WNDS);

END pqp_vehicle_details_mapping;

 

/
