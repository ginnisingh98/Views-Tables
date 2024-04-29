--------------------------------------------------------
--  DDL for Package Body CN_INTEL_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_INTEL_CALC_PKG" AS
/* $Header: cntcalcb.pls 120.1 2005/07/20 10:45:54 mblum noship $ */
--
-- Package Name
--   CN_INTEL_CALC_PKG
-- Purpose
--   Table handler for CN_SRP_INTEL_PERIODS
-- Form
--   N/A
-- Block
--   N/A
--
-- History
--   16-SEP-99  Yonghong Mao  Created

procedure insert_row (
		      x_srp_intel_period_id                IN NUMBER,
		      x_salesrep_id                        IN NUMBER,
		      x_org_id                             IN NUMBER,
		      x_period_id                          IN NUMBER,
		      x_processing_status_code             IN VARCHAR2,
		      x_process_all_flag                   IN VARCHAR2,
		      x_attribute_category                 IN VARCHAR2 := null,
		      x_attribute1                         IN VARCHAR2 := null,
		      x_attribute2                         IN VARCHAR2 := null,
		      x_attribute3                         IN VARCHAR2 := null,
		      x_attribute4                         IN VARCHAR2 := null,
		      x_attribute5                         IN VARCHAR2 := null,
		      x_attribute6                         IN VARCHAR2 := null,
		      x_attribute7                         IN VARCHAR2 := null,
		      x_attribute8                         IN VARCHAR2 := null,
		      x_attribute9                         IN VARCHAR2 := null,
		      x_attribute10                        IN VARCHAR2 := null,
		      x_attribute11                        IN VARCHAR2 := null,
		      x_attribute12                        IN VARCHAR2 := null,
		      x_attribute13                        IN VARCHAR2 := null,
		      x_attribute14                        IN VARCHAR2 := null,
                      x_attribute15                        IN VARCHAR2 := null,
                      x_creation_date                      IN DATE := sysdate,
                      x_created_by                         IN NUMBER := fnd_global.user_id,
                      x_last_update_date                   IN DATE := sysdate,
                      x_last_updated_by                    IN NUMBER := fnd_global.user_id,
                      x_last_update_login                  IN NUMBER := fnd_global.login_id,
                      x_start_date                         IN DATE := null,
                      x_end_date                           IN DATE := null
  ) IS
     l_srp_intel_period_id NUMBER(15);
     l_rowid ROWID;
     CURSOR u_id IS
	SELECT cn_srp_intel_periods_s.NEXTVAL
	FROM dual;
     CURSOR c IS SELECT ROWID FROM cn_srp_intel_periods
       WHERE srp_intel_period_id = l_srp_intel_period_id;
     CURSOR rec IS
	SELECT srp_intel_period_id
	  FROM cn_srp_intel_periods
	  WHERE period_id = x_period_id
	  AND salesrep_id = x_salesrep_id
	  AND org_id      = x_org_id;
BEGIN
   OPEN rec;
   FETCH rec INTO l_srp_intel_period_id;
   IF (rec%found) THEN
      CLOSE rec;
      RETURN;
   END IF;
   CLOSE rec;

   IF (x_srp_intel_period_id IS NULL) THEN
      OPEN u_id;
      FETCH u_id INTO l_srp_intel_period_id;
      CLOSE u_id;
    ELSE
      l_srp_intel_period_id := x_srp_intel_period_id;
   END IF;

   INSERT INTO cn_srp_intel_periods (
      srp_intel_period_id,
      salesrep_id,
      org_id,
      period_id,
      processing_status_code,
      process_all_flag,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      start_date,
      end_date
      ) VALUES (
      l_srp_intel_period_id,
      x_salesrep_id,
      x_org_id,
      x_period_id,
      x_processing_status_code,
      x_process_all_flag,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_start_date,
      x_end_date
     );

   OPEN c;
   FETCH c INTO l_rowid;
   IF (c%notfound) THEN
      CLOSE c;
      RAISE no_data_found;
   END IF;
   CLOSE c;

END insert_row;


PROCEDURE lock_row (
		    x_srp_intel_period_id             IN NUMBER,
		    x_salesrep_id                     IN NUMBER,
		    x_period_id                       IN NUMBER,
		    x_processing_status_code          IN VARCHAR2,
		    x_process_all_flag                IN VARCHAR2,
                    x_start_date                      IN DATE,
                    x_end_date                        IN DATE,
		    x_attribute_category              IN VARCHAR2,
		    x_attribute1                      IN VARCHAR2,
		    x_attribute2                      IN VARCHAR2,
		    x_attribute3                      IN VARCHAR2,
		    x_attribute4                      IN VARCHAR2,
		    x_attribute5                      IN VARCHAR2,
		    x_attribute6                      IN VARCHAR2,
		    x_attribute7                      IN VARCHAR2,
		    x_attribute8                      IN VARCHAR2,
		    x_attribute9                      IN VARCHAR2,
		    x_attribute10                     IN VARCHAR2,
		    x_attribute11                     IN VARCHAR2,
		    x_attribute12                     IN VARCHAR2,
		    x_attribute13                     IN VARCHAR2,
                    x_attribute14                     IN VARCHAR2,
                    x_attribute15                     IN VARCHAR2)
  IS
     CURSOR c IS SELECT
       salesrep_id,
       period_id,
       processing_status_code,
       process_all_flag,
       start_date,
       end_date,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
       FROM cn_srp_intel_periods
       WHERE srp_intel_period_id = x_srp_intel_period_id
       FOR UPDATE OF srp_intel_period_id nowait;
     recinfo c%ROWTYPE;
BEGIN
   OPEN c;
   FETCH c INTO recinfo;
   IF (c%notfound) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE c;

   IF ( recinfo.salesrep_id = x_salesrep_id AND
	recinfo.period_id = x_period_id AND
	recinfo.processing_status_code = x_processing_status_code AND
	recinfo.process_all_flag = x_process_all_flag AND
	( (recinfo.start_date = x_start_date)
	  OR ((recinfo.start_date IS NULL) AND (x_start_date IS NULL))
	)
	AND
	( (recinfo.end_date = x_end_date)
	  OR ((recinfo.end_date IS NULL) AND (x_end_date IS NULL))
	)
	AND
	( (recinfo.attribute_category = x_attribute_category)
	  OR ((recinfo.attribute_category IS NULL) AND (x_attribute_category IS NULL))
	)
	AND
	( (recinfo.attribute1 = x_attribute1)
	  OR ((recinfo.attribute1 IS NULL) AND (x_attribute1 IS NULL))
	)
	AND
	(  (recinfo.attribute2 = x_attribute2)
	  OR ((recinfo.attribute2 IS NULL) AND (x_attribute2 IS NULL))
	)
	AND
	(  recinfo.attribute3 = x_attribute3
	  OR (recinfo.attribute3 IS NULL AND x_attribute3 IS NULL)
	)
	AND
	(  recinfo.attribute4 = x_attribute4
	  OR (recinfo.attribute4 IS NULL AND x_attribute4 IS NULL)
	)
	AND
	(  recinfo.attribute5 = x_attribute5
	  OR (recinfo.attribute5 IS NULL AND x_attribute5 IS NULL)
	)
	AND
	(  recinfo.attribute6 = x_attribute6
	  OR (recinfo.attribute6 IS NULL AND x_attribute6 IS NULL)
	)
	AND
	(  recinfo.attribute7 = x_attribute7
	  OR (recinfo.attribute7 IS NULL AND x_attribute7 IS NULL)
	)
	AND
	(  recinfo.attribute8 = x_attribute8
	  OR (recinfo.attribute8 IS NULL AND x_attribute8 IS NULL)
	)
	AND
	(  recinfo.attribute9 = x_attribute9
	  OR (recinfo.attribute9 IS NULL AND x_attribute9 IS NULL)
	)
        AND
	(  recinfo.attribute10 = x_attribute10
	  OR (recinfo.attribute10 IS NULL AND x_attribute10 IS NULL)
	)
	AND
	(  recinfo.attribute11 = x_attribute11
	  OR (recinfo.attribute11 IS NULL AND x_attribute11 IS NULL)
	)
        AND
	(  recinfo.attribute12 = x_attribute12
	  OR (recinfo.attribute12 IS NULL AND x_attribute12 IS NULL)
	)
	AND
	(  recinfo.attribute13 = x_attribute13
	  OR (recinfo.attribute13 IS NULL AND x_attribute13 IS NULL)
	)
	AND
	(  recinfo.attribute14 = x_attribute14
	  OR (recinfo.attribute14 IS NULL AND x_attribute14 IS NULL)
	)
        AND
	(  recinfo.attribute15 = x_attribute15
	  OR (recinfo.attribute15 IS NULL AND x_attribute15 IS NULL)
	)
      ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
   END IF;

   RETURN;
END lock_row;

PROCEDURE update_row (
		    x_srp_intel_period_id             IN NUMBER,
		    x_salesrep_id                     IN NUMBER,
		    x_period_id                       IN NUMBER,
		    x_start_date                      IN DATE,
		    x_end_date                        IN DATE,
		    x_processing_status_code          IN VARCHAR2,
		    x_process_all_flag                IN VARCHAR2,
		    x_attribute_category              IN VARCHAR2,
		    x_attribute1                      IN VARCHAR2,
		    x_attribute2                      IN VARCHAR2,
		    x_attribute3                      IN VARCHAR2,
		    x_attribute4                      IN VARCHAR2,
		    x_attribute5                      IN VARCHAR2,
		    x_attribute6                      IN VARCHAR2,
		    x_attribute7                      IN VARCHAR2,
		    x_attribute8                      IN VARCHAR2,
		    x_attribute9                      IN VARCHAR2,
		    x_attribute10                     IN VARCHAR2,
		    x_attribute11                     IN VARCHAR2,
		    x_attribute12                     IN VARCHAR2,
		    x_attribute13                     IN VARCHAR2,
                    x_attribute14                     IN VARCHAR2,
                    x_attribute15                     IN VARCHAR2,
                    x_last_update_date                IN DATE,
                    x_last_updated_by                 IN NUMBER,
                    x_last_update_login               IN NUMBER) IS
BEGIN
   UPDATE cn_srp_intel_periods SET
     salesrep_id = x_salesrep_id,
     period_id = x_period_id,
     start_date = x_start_date,
     end_date = x_end_date,
     processing_status_code = x_processing_status_code,
     process_all_flag = x_process_all_flag,
     attribute_category = x_attribute_category,
     attribute1 = x_attribute1,
     attribute2 = x_attribute2,
     attribute3 = x_attribute3,
     attribute4 = x_attribute4,
     attribute5 = x_attribute5,
     attribute6 = x_attribute6,
     attribute7 = x_attribute7,
     attribute8 = x_attribute8,
     attribute9 = x_attribute9,
     attribute10 = x_attribute10,
     attribute11 = x_attribute11,
     attribute12 = x_attribute12,
     attribute13 = x_attribute13,
     attribute14 = x_attribute14,
     attribute15 = x_attribute15,
     last_update_date = x_last_update_date,
     last_updated_by = x_last_updated_by,
     last_update_login = x_last_update_login
     WHERE srp_intel_period_id = x_srp_intel_period_id;

   IF (SQL%notfound) THEN
      RAISE no_data_found;
   END IF;

END update_row;

PROCEDURE delete_row (
		      x_srp_intel_period_id           IN NUMBER
		      ) IS
BEGIN
   DELETE FROM cn_srp_intel_periods
     WHERE srp_intel_period_id = x_srp_intel_period_id;

   IF (SQL%notfound) THEN
      RAISE no_data_found;
   END IF;

END delete_row;

end CN_INTEL_CALC_PKG;

/
