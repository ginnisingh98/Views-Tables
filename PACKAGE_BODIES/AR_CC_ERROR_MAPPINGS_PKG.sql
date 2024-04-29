--------------------------------------------------------
--  DDL for Package Body AR_CC_ERROR_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CC_ERROR_MAPPINGS_PKG" AS
/* $Header: ARCCMAPB.pls 120.0 2005/03/22 22:36:19 jypandey noship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');
PROCEDURE Check_Unique(p_rowid IN ROWID,p_cc_error_code IN VARCHAR2,p_cc_trx_category IN VARCHAR2,p_receipt_method_id IN NUMBER) IS
dummy NUMBER;
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug('AR_CC_ERROR_MAPPINGS_PKG.Check_Unique(+)');
 END IF;
 IF (p_cc_error_code IS NOT NULL) THEN
  SELECT 1
  INTO dummy
  FROM dual D
  WHERE NOT EXISTS ( SELECT 1
                     FROM ar_cc_error_mappings E
                     WHERE E.cc_error_code = p_cc_error_code
		     AND   E.cc_trx_category = p_cc_trx_category
                     AND   E.receipt_method_id = p_receipt_method_id
		     AND ( E.rowid <> p_rowid OR p_rowid IS NULL ));
 END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_standard.debug('AR_CC_ERROR_MAPPINGS_PKG.Check_Unique(-)');
 END IF;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  FND_MESSAGE.SET_NAME('AR', 'AR_CC_ERROR_CODE_UNIQUE');
  APP_EXCEPTION.RAISE_EXCEPTION;
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Check_Unique');
   END IF;
   raise;
END Check_Unique;

PROCEDURE Insert_Row(x_rowid OUT NOCOPY ROWID,
                     p_cc_error_code IN VARCHAR2,
                     p_cc_error_text IN VARCHAR2,
                     p_receipt_method_id IN NUMBER,
		     p_cc_trx_category IN VARCHAR2,
                     p_cc_action_code IN VARCHAR2,
                     p_no_days IN NUMBER,
                     p_subsequent_action_code IN VARCHAR2,
                     p_error_notes IN VARCHAR2,
                     p_last_update_date IN DATE,
                     p_last_updated_by IN NUMBER,
                     p_last_update_login IN NUMBER,
                     p_creation_date IN DATE,
                     p_created_by IN NUMBER,
                     x_object_version_number OUT NOCOPY NUMBER) IS
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug( 'AR_CC_ERROR_MAPPINGS_PKG.Insert_Row()+' );
 END IF;
 x_object_version_number := 1;
 INSERT INTO ar_cc_error_mappings(
  CC_ERROR_CODE,
  CC_ERROR_TEXT,
  RECEIPT_METHOD_ID,
  CC_TRX_CATEGORY,
  CC_ACTION_CODE,
  NO_DAYS,
  SUBSEQUENT_ACTION_CODE,
  ERROR_NOTES,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  CREATION_DATE,
  CREATED_BY,
  OBJECT_VERSION_NUMBER)
 VALUES(
  p_cc_error_code,
  p_cc_error_text,
  p_receipt_method_id,
  p_cc_trx_category,
  p_cc_action_code,
  p_no_days,
  p_subsequent_action_code,
  p_error_notes,
  p_last_update_date,
  p_last_updated_by,
  p_last_update_login,
  p_creation_date,
  p_created_by,
  x_object_version_number) RETURNING ROWID INTO x_rowid;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug( 'AR_CC_ERROR_MAPPINGS_PKG.Insert_Row()-' );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug( 'EXCEPTION AR_CC_ERROR_MAPPINGS_PKG.Insert_Row()' );
  END IF;
  raise;
END Insert_Row;

PROCEDURE Update_Row(p_rowid IN ROWID,
                     p_cc_error_code IN VARCHAR2,
                     p_cc_error_text IN VARCHAR2,
                     p_receipt_method_id IN NUMBER,
		     p_cc_trx_category IN VARCHAR2,
                     p_cc_action_code IN VARCHAR2,
                     p_no_days IN NUMBER,
                     p_subsequent_action_code IN VARCHAR2,
                     p_error_notes IN VARCHAR2,
                     p_last_update_date IN DATE,
                     p_last_updated_by IN NUMBER,
                     p_last_update_login IN NUMBER,
		     x_object_version_number OUT NOCOPY NUMBER) IS
BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug( 'AR_CC_ERROR_MAPPINGS_PKG.Update_Row()+' );
 END IF;
 UPDATE ar_cc_error_mappings
 SET cc_error_code = p_cc_error_code,
     cc_error_text=p_cc_error_text,
     receipt_method_id=p_receipt_method_id,
     cc_trx_category=p_cc_trx_category,
     cc_action_code=p_cc_action_code,
     no_days=p_no_days,
     subsequent_action_code=p_subsequent_action_code,
     error_notes=p_error_notes,
     last_update_date=p_last_update_date,
     last_updated_by=p_last_updated_by,
     last_update_login=p_last_update_login,
     object_version_number=object_version_number+1
 WHERE rowid = p_rowid
 RETURNING object_version_number INTO x_object_version_number;
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug( 'AR_CC_ERROR_MAPPINGS_PKG.Update_Row()-' );
 END IF;
EXCEPTION
 WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug( 'EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Update_Row()' );
 END IF;
 raise;
END Update_Row;

PROCEDURE Delete_Row(p_rowid IN ROWID) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug( 'EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Delete_Row()+' );
   END IF;
  Delete ar_cc_error_mappings
  WHERE rowid = p_rowid;
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug( 'EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Delete_Row()-' );
   END IF;
EXCEPTION
  WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug( 'EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Delete_Row()' );
   END IF;
   raise;
END Delete_row;

PROCEDURE Lock_Row(p_rowid IN ROWID,
                   p_object_version_number IN NUMBER) IS
 l_object_version_number ar_cc_error_mappings.object_version_number%TYPE;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug( 'EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Lock_Row()+' );
   END IF;
   SELECT object_version_number
   INTO l_object_version_number
   FROM ar_cc_error_mappings
   WHERE rowid = p_rowid
   AND object_version_number = p_object_version_number
   FOR UPDATE OF object_version_number NOWAIT;
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug( 'EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Lock_Row()-' );
   END IF;
EXCEPTION
  WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug( 'EXCEPTION: AR_CC_ERROR_MAPPINGS_PKG.Lock_Row()' );
   END IF;
   raise;
END Lock_Row;

END AR_CC_ERROR_MAPPINGS_PKG;

/
