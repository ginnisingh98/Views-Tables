--------------------------------------------------------
--  DDL for Package GMD_STATUS_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_STATUS_CODE" AUTHID CURRENT_USER AS
/* $Header: GMDSTATS.pls 115.4 2002/08/23 20:27:33 txdaniel noship $ */

/* Purpose: The package has code used in status management                 */
/*          The package will usually be called from the Change Status form */
/*                                                                         */
/*                                                                         */
/* Check_Dependent_Status                                                  */
/*                                                                         */
/* MODIFICATION HISTORY                                                    */
/* Person      Date      Comments                                          */
/* ---------   ------    ------------------------------------------        */
/* L.Jackson   15Mar2001  Start
/* Sukarna Reddy 05/03/01 Added Check parent Status routine */

/* Constants                                                                                        */
/* =========                                                                                        */
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'GMD_STATUS_CODE';

  FUNCTION CHECK_DEPENDENT_STATUS
     ( P_Entity_Type    NUMBER,
       P_Entity_id      NUMBER,
       P_Current_Status VARCHAR2,
       P_To_Status      VARCHAR2)
   	RETURN BOOLEAN;

  FUNCTION CHECK_PARENT_STATUS(pentity_name VARCHAR2,
                               pentity_id   NUMBER)
                               RETURN BOOLEAN;


  FUNCTION GET_REWORK_STATUS(p_from_status VARCHAR2,
                             p_to_status VARCHAR2)
                               RETURN VARCHAR2;

  FUNCTION GET_PENDING_STATUS(p_from_status VARCHAR2,
                              p_to_status VARCHAR2)
                               RETURN VARCHAR2;

END; -- Package Specification GMD_STATUS_CODE

 

/
