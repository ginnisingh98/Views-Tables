--------------------------------------------------------
--  DDL for Package POS_ISP_UPDMODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ISP_UPDMODIFIERS" AUTHID CURRENT_USER as
/* $Header: POSUMODS.pls 120.0 2005/06/02 15:12:54 appldev noship $  */

/*===========================================================================
  PACKAGE NAME:		pos_isp_updmodifiers


  DESCRIPTION:          Contains the server side APIs: high-level record types,
			cursors and record type variables.

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:               HKUMMATI

  PROCEDURES/FUNCTIONS:

============================================================================*/
/*===========================================================================
  PROCEDURE NAME:	updatemodifiers()


  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       HKUMMATI	09/21/2000   Created
===========================================================================*/

PROCEDURE updmodifiers(
        p_asl_id                    IN   PO_ASL_ATTRIBUTES.ASL_ID%TYPE,
        p_proc_lead_time            IN   PO_ASL_ATTRIBUTES.PROCESSING_LEAD_TIME%TYPE,
        p_min_order_qty             IN   PO_ASL_ATTRIBUTES.MIN_ORDER_QTY%TYPE,
        p_fixed_lot_multiple        IN   PO_ASL_ATTRIBUTES.FIXED_LOT_MULTIPLE%TYPE,
        p_error_code                OUT NOCOPY  VARCHAR2,
        p_error_message             OUT NOCOPY  VARCHAR2);


END POS_ISP_UPDMODIFIERS;


 

/
