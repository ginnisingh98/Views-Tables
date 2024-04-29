--------------------------------------------------------
--  DDL for Package Body GMD_SAMPLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SAMPLES_PVT" AS
/* $Header: GMDVSMPB.pls 120.2.12010000.2 2009/03/18 15:59:12 rnalla ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVSMPB.pls                                        |
--| Package Name       : GMD_SAMPLES_PVT                                     |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Samples                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     07-Aug-2002     Created.                             |
--|    magupta          06-Jan-2003     2733495: Added source_wshe and locat-|
--|                                              ion for insert_row.         |
--|    B. Stone         19-May-2003     2967055: Added sample instance       |
--|                                                                          |
--|    S. Feinstein     30-Jan-2004     3401377: added instance_id, resources|
--|                                              retrieval_date,date_received|
--|                                              date_required.              |
--|                                              changed source_comment to   |
--|                                              comment.                    |
--|                                                                          |
--|    S. Feinstein     12-FEB-2004     3401377: added remaining_qty, retain_as|
--|                                                                          |
--|    Sai Kiran        10-May-2004     3576573: added PO_HEADER_ID,         |
--|                                              PO_LINE_ID,RECEIPT_ID       |
--|                                           RECEIPT_LINE_ID,SUPPLIER_LOT_NO|
--|                                           to the 'insert_row' procedure  |
--|    S. Feinstein     11-MAR-2005     4165704: Inventory Convergence fields entered
--|    S. Feinstein     18-OCT-2005     4640143: added material detail id to samples
--|                                                                          |
--|    P Lowe           14-JUN-2006     5283854: added storage_organization_id
--|                     to samples                                           |
--|    PLOWE            19-May-2008     7027149 added support for LPN        |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_samples IN  GMD_SAMPLES%ROWTYPE
, x_samples OUT NOCOPY GMD_SAMPLES%ROWTYPE) RETURN BOOLEAN IS
BEGIN

    x_samples := p_samples;

    INSERT INTO GMD_SAMPLES
     (
      SAMPLE_ID
     ,SAMPLE_NO
     ,SAMPLE_DESC
     ,LAB_ORGANIZATION_ID
     ,SAMPLE_DISPOSITION
     ,RETAIN_AS
     ,INVENTORY_ITEM_ID
     ,ORGANIZATION_ID
     ,SUBINVENTORY
     ,LOCATOR_ID
     ,EXPIRATION_DATE
     ,PARENT_LOT_NUMBER
     ,LOT_NUMBER
     ,REVISION
     ,BATCH_ID
     ,RECIPE_ID
     ,FORMULA_ID
     ,FORMULALINE_ID
     ,MATERIAL_DETAIL_ID
     ,ROUTING_ID
     ,OPRN_ID
     ,CHARGE
     ,CUST_ID
     ,ORDER_ID
     ,ORDER_LINE_ID
     ,SHIP_TO_SITE_ID
     ,ORG_ID
     ,SUPPLIER_ID
     ,SUPPLIER_SITE_ID
     ,SAMPLE_QTY
     ,SAMPLE_QTY_UOM
     ,REMAINING_QTY
     ,SOURCE
     ,SAMPLE_INSTANCE
     ,SAMPLER_ID
     ,DATE_DRAWN
     ,SOURCE_COMMENT
     ,STORAGE_SUBINVENTORY
     ,STORAGE_LOCATOR_ID
     ,STORAGE_ORGANIZATION_ID -- 5283854
     ,EXTERNAL_ID
     ,SAMPLE_APPROVER_ID
     ,INV_APPROVER_ID
     ,PRIORITY
     ,SAMPLE_INV_TRANS_IND
     ,DELETE_MARK
     ,TEXT_CODE
     ,ATTRIBUTE_CATEGORY
     ,ATTRIBUTE1
     ,ATTRIBUTE2
     ,ATTRIBUTE3
     ,ATTRIBUTE4
     ,ATTRIBUTE5
     ,ATTRIBUTE6
     ,ATTRIBUTE7
     ,ATTRIBUTE8
     ,ATTRIBUTE9
     ,ATTRIBUTE10
     ,ATTRIBUTE11
     ,ATTRIBUTE12
     ,ATTRIBUTE13
     ,ATTRIBUTE14
     ,ATTRIBUTE15
     ,ATTRIBUTE16
     ,ATTRIBUTE17
     ,ATTRIBUTE18
     ,ATTRIBUTE19
     ,ATTRIBUTE20
     ,ATTRIBUTE21
     ,ATTRIBUTE22
     ,ATTRIBUTE23
     ,ATTRIBUTE24
     ,ATTRIBUTE25
     ,ATTRIBUTE26
     ,ATTRIBUTE27
     ,ATTRIBUTE28
     ,ATTRIBUTE29
     ,ATTRIBUTE30
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN
     ,STEP_ID
     ,STEP_NO
     ,SAMPLING_EVENT_ID
     ,LOT_RETEST_IND
     ,SOURCE_SUBINVENTORY
     ,SOURCE_LOCATOR_ID
     ,SAMPLE_TYPE
     ,VARIANT_ID
     ,TIME_POINT_ID
     ,INSTANCE_ID
     ,RESOURCES
     ,RETRIEVAL_DATE
     ,DATE_RECEIVED
     ,DATE_REQUIRED
     ,PO_HEADER_ID
     ,PO_LINE_ID
     ,RECEIPT_ID
     ,RECEIPT_LINE_ID
     ,SUPPLIER_LOT_NO
     ,LPN_ID -- 7027149
     )
     VALUES
     (
      gmd_qc_sample_id_s.NEXTVAL
     ,x_samples.SAMPLE_NO
     ,x_samples.SAMPLE_DESC
     ,x_samples.LAB_ORGANIZATION_ID
     ,x_samples.SAMPLE_DISPOSITION
     ,x_samples.RETAIN_AS
     ,x_samples.INVENTORY_ITEM_ID
     ,x_samples.ORGANIZATION_ID
     ,x_samples.SUBINVENTORY
     ,x_samples.LOCATOR_ID
     ,x_samples.EXPIRATION_DATE
     ,x_samples.PARENT_LOT_NUMBER
     ,x_samples.LOT_NUMBER
     ,x_samples.REVISION
     ,x_samples.BATCH_ID
     ,x_samples.RECIPE_ID
     ,x_samples.FORMULA_ID
     ,x_samples.FORMULALINE_ID
     ,x_samples.MATERIAL_DETAIL_ID
     ,x_samples.ROUTING_ID
     ,x_samples.OPRN_ID
     ,x_samples.CHARGE
     ,x_samples.CUST_ID
     ,x_samples.ORDER_ID
     ,x_samples.ORDER_LINE_ID
     ,x_samples.SHIP_TO_SITE_ID
     ,x_samples.ORG_ID
     ,x_samples.SUPPLIER_ID
     ,x_samples.SUPPLIER_SITE_ID
     ,x_samples.SAMPLE_QTY
     ,x_samples.SAMPLE_QTY_UOM
     ,x_samples.REMAINING_QTY
     ,x_samples.SOURCE
     ,x_samples.SAMPLE_INSTANCE
     ,x_samples.SAMPLER_ID
     ,x_samples.DATE_DRAWN
     ,x_samples.SOURCE_COMMENT
     ,x_samples.STORAGE_SUBINVENTORY
     ,x_samples.STORAGE_LOCATOR_ID
     ,x_samples.STORAGE_ORGANIZATION_ID -- 5283854
     ,x_samples.EXTERNAL_ID
     ,x_samples.SAMPLE_APPROVER_ID
     ,x_samples.INV_APPROVER_ID
     ,x_samples.PRIORITY
     ,x_samples.SAMPLE_INV_TRANS_IND
     ,x_samples.DELETE_MARK
     ,x_samples.TEXT_CODE
     ,x_samples.ATTRIBUTE_CATEGORY
     ,x_samples.ATTRIBUTE1
     ,x_samples.ATTRIBUTE2
     ,x_samples.ATTRIBUTE3
     ,x_samples.ATTRIBUTE4
     ,x_samples.ATTRIBUTE5
     ,x_samples.ATTRIBUTE6
     ,x_samples.ATTRIBUTE7
     ,x_samples.ATTRIBUTE8
     ,x_samples.ATTRIBUTE9
     ,x_samples.ATTRIBUTE10
     ,x_samples.ATTRIBUTE11
     ,x_samples.ATTRIBUTE12
     ,x_samples.ATTRIBUTE13
     ,x_samples.ATTRIBUTE14
     ,x_samples.ATTRIBUTE15
     ,x_samples.ATTRIBUTE16
     ,x_samples.ATTRIBUTE17
     ,x_samples.ATTRIBUTE18
     ,x_samples.ATTRIBUTE19
     ,x_samples.ATTRIBUTE20
     ,x_samples.ATTRIBUTE21
     ,x_samples.ATTRIBUTE22
     ,x_samples.ATTRIBUTE23
     ,x_samples.ATTRIBUTE24
     ,x_samples.ATTRIBUTE25
     ,x_samples.ATTRIBUTE26
     ,x_samples.ATTRIBUTE27
     ,x_samples.ATTRIBUTE28
     ,x_samples.ATTRIBUTE29
     ,x_samples.ATTRIBUTE30
     ,x_samples.CREATION_DATE
     ,x_samples.CREATED_BY
     ,x_samples.LAST_UPDATED_BY
     ,x_samples.LAST_UPDATE_DATE
     ,x_samples.LAST_UPDATE_LOGIN
     ,x_samples.STEP_ID
     ,x_samples.STEP_NO
     ,x_samples.SAMPLING_EVENT_ID
     ,x_samples.LOT_RETEST_IND
     ,x_samples.SOURCE_SUBINVENTORY
     ,x_samples.SOURCE_LOCATOR_ID
     ,x_samples.SAMPLE_TYPE
     ,x_samples.VARIANT_ID
     ,x_samples.TIME_POINT_ID
     ,x_samples.INSTANCE_ID
     ,x_samples.RESOURCES
     ,x_samples.RETRIEVAL_DATE
     ,x_samples.DATE_RECEIVED
     ,x_samples.DATE_REQUIRED
     ,x_samples.PO_HEADER_ID
     ,x_samples.PO_LINE_ID
     ,x_samples.RECEIPT_ID
     ,x_samples.RECEIPT_LINE_ID
     ,x_samples.SUPPLIER_LOT_NO
     ,x_samples.LPN_ID -- 7027149
     )
        RETURNING sample_id INTO x_samples.sample_id
     ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SAMPLES_PVT', 'INSERT_ROW');
      RETURN FALSE;

 END insert_row;





FUNCTION delete_row (
  p_sample_id IN NUMBER
, p_organization_id IN VARCHAR2
, p_sample_no IN VARCHAR2
) RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN

  IF p_sample_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_samples
    WHERE  sample_id = p_sample_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_samples
    SET    delete_mark = 1,
	   last_updated_by = fnd_global.user_id,
	   last_update_date = SYSDATE
    WHERE  sample_id = p_sample_id
    ;
  ELSIF p_organization_id IS NOT NULL AND
	p_sample_no IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_samples
    WHERE  organization_id = p_organization_id
    AND    sample_no = p_sample_no
    FOR UPDATE NOWAIT;

    UPDATE gmd_samples
    SET    delete_mark = 1,
	   last_updated_by = fnd_global.user_id,
	   last_update_date = SYSDATE
    WHERE  organization_id = p_organization_id
    AND    sample_no = p_sample_no
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLES');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SAMPLES');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SAMPLES',
                            'RECORD','Sample',
                            'KEY', p_organization_id || p_sample_no);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLES_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;




FUNCTION lock_row (
  p_sample_id IN NUMBER
, p_organization_id IN VARCHAR2
, p_sample_no IN VARCHAR2 )
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_sample_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_samples
    WHERE  sample_id = p_sample_id
    FOR UPDATE NOWAIT;
  ELSIF p_organization_id IS NOT NULL AND
	p_sample_no IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_samples
    WHERE  organization_id = p_organization_id
    AND    sample_no = p_sample_no
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLES');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SAMPLES',
                            'RECORD','Sampling Event',
                            'KEY', p_organization_id || p_sample_no);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLES_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_samples IN  gmd_samples%ROWTYPE
, x_samples OUT NOCOPY gmd_samples%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_samples.sample_id IS NOT NULL) THEN
    SELECT *
    INTO   x_samples
    FROM   gmd_samples
    WHERE  sample_id = p_samples.sample_id
    ;
    RETURN TRUE;

  ELSIF (p_samples.organization_id IS NOT NULL AND
	 p_samples.sample_no IS NOT NULL) THEN
    SELECT *
    INTO   x_samples
    FROM   gmd_samples
    WHERE  organization_id = p_samples.organization_id
    AND    sample_no = p_samples.sample_no
    ;
    RETURN TRUE;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLES');
    RETURN FALSE;
  END IF;

  RETURN FALSE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SAMPLES');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLES_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_SAMPLES_PVT;

/
