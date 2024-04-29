--------------------------------------------------------
--  DDL for Package Body GMD_SAMPLING_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SAMPLING_EVENTS_PVT" AS
/* $Header: GMDVSEVB.pls 120.3.12010000.2 2009/03/18 15:55:08 rnalla ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVSEVB.pls                                        |
--| Package Name       : GMD_SAMPLING_EVENTS_PVT                             |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Sampling Events          |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     06-Aug-2002     Created.                             |
--|    S. Feinstein     18-OCT-2005     Added material detail id to samples  |
--|    RAGSRIVA         23-Jun-2006     set migrated_ind to 0 in insert_row  |
--|    RLNAGARA  LPN ME 7027149 09-May-2008 Added LPN_ID to the INSERT statement|
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_sampling_events IN  GMD_SAMPLING_EVENTS%ROWTYPE
, x_sampling_events OUT NOCOPY GMD_SAMPLING_EVENTS%ROWTYPE) RETURN BOOLEAN IS
BEGIN

  x_sampling_events := p_sampling_events;

  INSERT INTO GMD_SAMPLING_EVENTS
   (
    SAMPLING_EVENT_ID
   ,ORIGINAL_SPEC_VR_ID
   ,ORGANIZATION_ID
   ,DISPOSITION
   ,SAMPLE_REQ_CNT
   ,SAMPLE_TAKEN_CNT
   ,ARCHIVED_TAKEN
   ,RESERVED_TAKEN
   ,SAMPLING_PLAN_ID
   ,EVENT_TYPE_CODE
   ,EVENT_ID
   ,SAMPLE_TYPE
   ,SOURCE
   ,INVENTORY_ITEM_ID
   ,REVISION
   ,PARENT_LOT_NUMBER
   ,LOT_NUMBER
   ,SUBINVENTORY
   ,LOCATOR_ID
   ,BATCH_ID
   ,RECIPE_ID
   ,FORMULA_ID
   ,FORMULALINE_ID
   ,MATERIAL_DETAIL_ID
   ,ROUTING_ID
   ,STEP_ID
   ,STEP_NO
   ,OPRN_ID
   ,CHARGE
   ,CUST_ID
   ,ORDER_ID
   ,ORDER_LINE_ID
   ,SHIP_TO_SITE_ID
   ,ORG_ID
   ,SUPPLIER_ID
   ,SUPPLIER_SITE_ID
   ,PO_LINE_ID
   ,RECEIPT_LINE_ID
   ,SUPPLIER_LOT_NO
   ,RESOURCES
   ,INSTANCE_ID
   ,VARIANT_ID
   ,TIME_POINT_ID
   ,COMPLETE_IND
   ,SAMPLE_ID_TO_EVALUATE
   ,COMPOSITE_ID_TO_EVALUATE
   ,TEXT_CODE
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN
   ,PO_HEADER_ID
   ,RECEIPT_ID
   ,LOT_RETEST_IND
   ,SAMPLE_ACTIVE_CNT
   ,MIGRATED_IND
   ,LPN_ID
   )
   VALUES
   (
    gmd_qc_sampling_event_id_s.NEXTVAL
   ,x_sampling_events.ORIGINAL_SPEC_VR_ID
   ,x_sampling_events.ORGANIZATION_ID
   ,x_sampling_events.DISPOSITION
   ,x_sampling_events.SAMPLE_REQ_CNT
   ,x_sampling_events.SAMPLE_TAKEN_CNT
   ,x_sampling_events.ARCHIVED_TAKEN
   ,x_sampling_events.RESERVED_TAKEN
   ,x_sampling_events.SAMPLING_PLAN_ID
   ,x_sampling_events.EVENT_TYPE_CODE
   ,x_sampling_events.EVENT_ID
   ,x_sampling_events.SAMPLE_TYPE
   ,x_sampling_events.SOURCE
   ,x_sampling_events.INVENTORY_ITEM_ID
   ,x_sampling_events.REVISION
   ,x_sampling_events.PARENT_LOT_NUMBER
   ,x_sampling_events.LOT_NUMBER
   ,x_sampling_events.SUBINVENTORY
   ,x_sampling_events.LOCATOR_ID
   ,x_sampling_events.BATCH_ID
   ,x_sampling_events.RECIPE_ID
   ,x_sampling_events.FORMULA_ID
   ,x_sampling_events.FORMULALINE_ID
   ,x_sampling_events.MATERIAL_DETAIL_ID
   ,x_sampling_events.ROUTING_ID
   ,x_sampling_events.STEP_ID
   ,x_sampling_events.STEP_NO
   ,x_sampling_events.OPRN_ID
   ,x_sampling_events.CHARGE
   ,x_sampling_events.CUST_ID
   ,x_sampling_events.ORDER_ID
   ,x_sampling_events.ORDER_LINE_ID
   ,x_sampling_events.SHIP_TO_SITE_ID
   ,x_sampling_events.ORG_ID
   ,x_sampling_events.SUPPLIER_ID
   ,x_sampling_events.SUPPLIER_SITE_ID
   ,x_sampling_events.PO_LINE_ID
   ,x_sampling_events.RECEIPT_LINE_ID
   ,x_sampling_events.SUPPLIER_LOT_NO
   ,x_sampling_events.RESOURCES
   ,x_sampling_events.INSTANCE_ID
   ,x_sampling_events.VARIANT_ID
   ,x_sampling_events.TIME_POINT_ID
   ,x_sampling_events.COMPLETE_IND
   ,x_sampling_events.SAMPLE_ID_TO_EVALUATE
   ,x_sampling_events.COMPOSITE_ID_TO_EVALUATE
   ,x_sampling_events.TEXT_CODE
   ,x_sampling_events.CREATION_DATE
   ,x_sampling_events.CREATED_BY
   ,x_sampling_events.LAST_UPDATED_BY
   ,x_sampling_events.LAST_UPDATE_DATE
   ,x_sampling_events.LAST_UPDATE_LOGIN
   ,x_sampling_events.PO_HEADER_ID
   ,x_sampling_events.RECEIPT_ID
   ,x_sampling_events.LOT_RETEST_IND
   ,x_sampling_events.SAMPLE_ACTIVE_CNT
   ,0
   ,x_sampling_events.LPN_ID
   )
      RETURNING sampling_event_id INTO x_sampling_events.sampling_event_id
   ;

  IF SQL%FOUND THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg ('GMD_SAMPLING_EVENTS_PVT', 'INSERT_ROW');
    RETURN FALSE;
END insert_row;





FUNCTION delete_row (p_sampling_event_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_sampling_event_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_sampling_events
    WHERE  sampling_event_id = p_sampling_event_id
    FOR UPDATE NOWAIT;

    DELETE gmd_sampling_events
    WHERE  sampling_event_id = p_sampling_event_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLING_EVENTS');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SAMPLING_EVENTS');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SAMPLING_EVENTS',
                            'RECORD','Sampling Event',
                            'KEY', p_sampling_event_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLING_EVENTS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;




FUNCTION lock_row (p_sampling_event_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_sampling_event_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_sampling_events
    WHERE  sampling_event_id = p_sampling_event_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLING_EVENTS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SAMPLING_EVENTS',
                            'RECORD','Sampling Event',
                            'KEY', p_sampling_event_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLING_EVENTS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_sampling_events IN  gmd_sampling_events%ROWTYPE
, x_sampling_events OUT NOCOPY gmd_sampling_events%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_sampling_events.sampling_event_id IS NOT NULL) THEN
    SELECT *
    INTO   x_sampling_events
    FROM   gmd_sampling_events
    WHERE  sampling_event_id = p_sampling_events.sampling_event_id
    ;
    RETURN TRUE;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLING_EVENTS');
    RETURN FALSE;
  END IF;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SAMPLING_EVENTS');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLING_EVENTS_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_SAMPLING_EVENTS_PVT;


/
