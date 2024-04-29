--------------------------------------------------------
--  DDL for Package Body POS_ISP_UPDMODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ISP_UPDMODIFIERS" AS
/* $Header: POSUMODB.pls 120.0 2005/06/01 16:47:48 appldev noship $ */

/*===========================================================================
  PROCEDURE NAME:	updmodifiers()
===========================================================================*/

PROCEDURE updmodifiers(
        p_asl_id                    IN   PO_ASL_ATTRIBUTES.ASL_ID%TYPE,
        p_proc_lead_time            IN   PO_ASL_ATTRIBUTES.PROCESSING_LEAD_TIME%TYPE,
        p_min_order_qty             IN   PO_ASL_ATTRIBUTES.MIN_ORDER_QTY%TYPE,
        p_fixed_lot_multiple        IN   PO_ASL_ATTRIBUTES.FIXED_LOT_MULTIPLE%TYPE,
        p_error_code                OUT  NOCOPY VARCHAR2,
        p_error_message             OUT  NOCOPY VARCHAR2) IS



BEGIN

    /* Update PO_ASL_ATTRIBUTES form ISP     */

    UPDATE PO_ASL_ATTRIBUTES
    SET PROCESSING_LEAD_TIME = p_proc_lead_time,
        MIN_ORDER_QTY        = p_min_order_qty,
        FIXED_LOT_MULTIPLE   = p_fixed_lot_multiple
    WHERE asl_id  = p_asl_id
      and using_organization_id = -1;



 EXCEPTION

  WHEN OTHERS THEN

    p_ERROR_CODE := 'Y';
    p_ERROR_MESSAGE := 'exception raised during Update';

END;


END POS_ISP_UPDMODIFIERS;


/
