--------------------------------------------------------
--  DDL for Package GMD_QC_STATUS_NEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_STATUS_NEXT_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVSTNS.pls 115.0 2002/09/12 15:31:01 sschinch noship $ */

/* Purpose: The package has code used in status management                 */
/*          The package will usually be called from the Change Status form */
/*                                                                         */
/*                                                                         */
/* Check_Dependent_Status  FUNCTION                                        */
/*                                                                         */


  FUNCTION GET_REWORK_STATUS(p_from_status VARCHAR2,
                             p_to_status VARCHAR2,
							 p_entity_type VARCHAR2)
                               RETURN VARCHAR2;


  FUNCTION GET_PENDING_STATUS(p_from_status VARCHAR2,
                              p_to_status VARCHAR2,
							  p_entity_type VARCHAR2)
                               RETURN VARCHAR2;

END GMD_QC_STATUS_NEXT_PVT;

 

/
