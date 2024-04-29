--------------------------------------------------------
--  DDL for Package Body GMD_QC_STATUS_NEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_STATUS_NEXT_PVT" AS
/* $Header: GMDVSTNB.pls 115.0 2002/09/12 15:31:40 sschinch noship $ */

/* Purpose: The package has code used in status management                 */
/*          The package will usually be called from the Change Status form */
/*                                                                         */
/*                                                                         */
/* Check_Dependent_Status  FUNCTION                                        */
/*                                                                         */


  FUNCTION GET_REWORK_STATUS(p_from_status VARCHAR2,
                             p_to_status VARCHAR2,
							 p_entity_type VARCHAR2)
                               RETURN VARCHAR2
  IS
    CURSOR Cur_get_rework IS
      SELECT rework_status
      FROM GMD_QC_STATUS_NEXT
      WHERE current_status = p_from_status
      AND target_status  = p_to_status
	  AND entity_type  = p_entity_type
	  AND pending_status IS NOT NULL;

    l_rework_status  VARCHAR2(30);
  BEGIN
    OPEN Cur_get_rework;
    FETCH Cur_get_rework INTO l_rework_status;
    CLOSE Cur_get_rework;
    RETURN (l_rework_status);

  END get_rework_status;


  FUNCTION GET_PENDING_STATUS(p_from_status VARCHAR2,
                              p_to_status VARCHAR2,
 			  p_entity_type VARCHAR2)
                               RETURN VARCHAR2
  IS
    CURSOR Cur_get_pending IS
      SELECT pending_status
      FROM GMD_QC_STATUS_NEXT
      WHERE current_status = p_from_status
      AND target_status  = p_to_status
	  AND  entity_type = p_entity_type;

    l_pending_status  VARCHAR2(30);
  BEGIN
    OPEN Cur_get_pending;
    FETCH Cur_get_pending INTO l_pending_status;
    CLOSE Cur_get_pending;
    RETURN (l_pending_status);

  END get_pending_status;

END GMD_QC_STATUS_NEXT_PVT;

/
