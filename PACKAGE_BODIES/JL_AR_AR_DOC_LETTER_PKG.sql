--------------------------------------------------------
--  DDL for Package Body JL_AR_AR_DOC_LETTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_AR_DOC_LETTER_PKG" as
/* $Header: jlarrdob.pls 120.3 2003/07/11 18:52:23 appradha ship $ */

  PROCEDURE Insert_Row(X_rowid                   IN OUT NOCOPY VARCHAR2,
                       X_tax_category_id                 NUMBER,
                       X_org_tax_attribute_name          VARCHAR2,
                       X_org_tax_attribute_value         VARCHAR2,
                       X_con_tax_attribute_name          VARCHAR2,
                       X_con_tax_attribute_value         VARCHAR2,
                       X_document_letter                 VARCHAR2,
                       X_start_date_active               DATE,
                       X_end_date_active                 DATE,
                       X_LAST_UPDATE_DATE                DATE,
                       X_LAST_UPDATED_BY                 NUMBER,
                       X_CREATION_DATE                   DATE,
                       X_CREATED_BY                      NUMBER,
                       X_LAST_UPDATE_LOGIN               NUMBER,
                       X_ORG_ID                          NUMBER,
                       X_ATTRIBUTE_CATEGORY              VARCHAR2,
                       X_ATTRIBUTE1                      VARCHAR2,
                       X_ATTRIBUTE2                      VARCHAR2,
                       X_ATTRIBUTE3                      VARCHAR2,
                       X_ATTRIBUTE4                      VARCHAR2,
                       X_ATTRIBUTE5                      VARCHAR2,
                       X_ATTRIBUTE6                      VARCHAR2,
                       X_ATTRIBUTE7                      VARCHAR2,
                       X_ATTRIBUTE8                      VARCHAR2,
                       X_ATTRIBUTE9                      VARCHAR2,
                       X_ATTRIBUTE10                     VARCHAR2,
                       X_ATTRIBUTE11                     VARCHAR2,
                       X_ATTRIBUTE12                     VARCHAR2,
                       X_ATTRIBUTE13                     VARCHAR2,
                       X_ATTRIBUTE14                     VARCHAR2,
                       X_ATTRIBUTE15                     VARCHAR2,
                       X_calling_sequence        IN  VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid
                FROM   jl_ar_ar_doc_letter
                WHERE  tax_category_id = X_tax_category_id
                AND    org_tax_attribute_name = X_org_tax_attribute_name
                AND    org_tax_attribute_value = X_org_tax_attribute_value
                AND    con_tax_attribute_name = X_con_tax_attribute_name
                AND    con_tax_attribute_value = X_con_tax_attribute_value;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

    BEGIN
--     Update the calling sequence
--
      current_calling_sequence := 'JL_AR_AR_DOC_LETTER_PKG.INSERT_ROW<-' ||
                                   X_calling_sequence;
--
      debug_info := 'Insert into JL_AR_AR_DOC_LETTER';
      insert into jl_ar_ar_doc_letter(
                                       tax_category_id,
                                       org_tax_attribute_name,
                                       org_tax_attribute_value,
                                       con_tax_attribute_name,
                                       con_tax_attribute_value,
                                       document_letter,
                                       start_date_active,
                                       end_date_active,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATED_BY,
                                       CREATION_DATE,
                                       CREATED_BY,
                                       LAST_UPDATE_LOGIN,
                                       ORG_ID,
                                       ATTRIBUTE_CATEGORY,
                                       ATTRIBUTE1,
                                       ATTRIBUTE2,
                                       ATTRIBUTE3,
                                       ATTRIBUTE4,
                                       ATTRIBUTE5,
                                       ATTRIBUTE6,
                                       ATTRIBUTE7,
                                       ATTRIBUTE8,
                                       ATTRIBUTE9,
                                       ATTRIBUTE10,
                                       ATTRIBUTE11,
                                       ATTRIBUTE12,
                                       ATTRIBUTE13,
                                       ATTRIBUTE14,
                                       ATTRIBUTE15)
       VALUES        (
                                       X_tax_category_id,
                                       X_org_tax_attribute_name,
                                       X_org_tax_attribute_value,
                                       X_con_tax_attribute_name,
                                       X_con_tax_attribute_value,
                                       X_document_letter,
                                       X_start_date_active,
                                       X_end_date_active,
                                       X_LAST_UPDATE_DATE,
                                       X_LAST_UPDATED_BY,
                                       X_CREATION_DATE,
                                       X_CREATED_BY,
                                       X_LAST_UPDATE_LOGIN,
                                       X_ORG_ID,
                                       X_ATTRIBUTE_CATEGORY,
                                       X_ATTRIBUTE1,
                                       X_ATTRIBUTE2,
                                       X_ATTRIBUTE3,
                                       X_ATTRIBUTE4,
                                       X_ATTRIBUTE5,
                                       X_ATTRIBUTE6,
                                       X_ATTRIBUTE7,
                                       X_ATTRIBUTE8,
                                       X_ATTRIBUTE9,
                                       X_ATTRIBUTE10,
                                       X_ATTRIBUTE11,
                                       X_ATTRIBUTE12,
                                       X_ATTRIBUTE13,
                                       X_ATTRIBUTE14,
                                       X_ATTRIBUTE15);

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
           FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
           FND_MESSAGE.SET_TOKEN('PARAMETERS',
                                'tax_category_id = ' || X_tax_category_id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row(  X_rowid                   VARCHAR2,
                       X_tax_category_id                 NUMBER,
                       X_org_tax_attribute_name          VARCHAR2,
                       X_org_tax_attribute_value         VARCHAR2,
                       X_con_tax_attribute_name          VARCHAR2,
                       X_con_tax_attribute_value         VARCHAR2,
                       X_document_letter                 VARCHAR2,
                       X_start_date_active               DATE,
                       X_end_date_active                 DATE,
                       X_LAST_UPDATE_DATE                DATE,
                       X_LAST_UPDATED_BY                 NUMBER,
                       X_CREATION_DATE                   DATE,
                       X_CREATED_BY                      NUMBER,
                       X_LAST_UPDATE_LOGIN               NUMBER,
                       X_ATTRIBUTE_CATEGORY              VARCHAR2,
                       X_ATTRIBUTE1                      VARCHAR2,
                       X_ATTRIBUTE2                      VARCHAR2,
                       X_ATTRIBUTE3                      VARCHAR2,
                       X_ATTRIBUTE4                      VARCHAR2,
                       X_ATTRIBUTE5                      VARCHAR2,
                       X_ATTRIBUTE6                      VARCHAR2,
                       X_ATTRIBUTE7                      VARCHAR2,
                       X_ATTRIBUTE8                      VARCHAR2,
                       X_ATTRIBUTE9                      VARCHAR2,
                       X_ATTRIBUTE10                     VARCHAR2,
                       X_ATTRIBUTE11                     VARCHAR2,
                       X_ATTRIBUTE12                     VARCHAR2,
                       X_ATTRIBUTE13                     VARCHAR2,
                       X_ATTRIBUTE14                     VARCHAR2,
                       X_ATTRIBUTE15                     VARCHAR2,
                       X_calling_sequence        IN    VARCHAR2
  ) IS
    CURSOR C IS SELECT *
                FROM   jl_ar_ar_doc_letter
                WHERE  tax_category_id = X_tax_category_id
                AND    org_tax_attribute_name = X_org_tax_attribute_name
                AND    org_tax_attribute_value = X_org_tax_attribute_value
                AND    con_tax_attribute_name = X_con_tax_attribute_name
                AND    con_tax_attribute_value = X_con_tax_attribute_value
                AND    end_date_active = X_end_date_active
                FOR UPDATE of tax_category_id, org_tax_attribute_name,
                              org_tax_attribute_value, con_tax_attribute_name,
                              con_tax_attribute_value, end_date_active
                NOWAIT;

    Recinfo C%ROWTYPE;

    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_AR_AR_DOC_LETTER_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND)
    THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    debug_info := 'Close cursor C';
    CLOSE C;
    IF (Recinfo.tax_category_id = X_tax_category_id       AND
        Recinfo.org_tax_attribute_name = X_org_tax_attribute_name AND
	Recinfo.org_tax_attribute_value = X_org_tax_attribute_value AND
        Recinfo.con_tax_attribute_name = X_con_tax_attribute_name   AND
        Recinfo.con_tax_attribute_value = X_con_tax_attribute_value AND
        Recinfo.document_letter = X_document_letter AND
        Recinfo.start_date_active = X_start_date_active AND
        Recinfo.end_date_active = X_end_date_active AND
	Recinfo.last_updated_by = X_last_updated_by AND
	Recinfo.last_update_date = X_last_update_date AND
	Recinfo.creation_date = X_creation_date AND
	Recinfo.created_by = X_created_by AND
	(Recinfo.last_update_login = X_last_update_login OR
           X_last_update_login IS NULL) AND
	(Recinfo.attribute1 = X_attribute1 OR
	   X_attribute1 IS NULL) AND
	(Recinfo.attribute2 = X_attribute2 OR
	   X_attribute2 IS NULL) AND
	(Recinfo.attribute3 = X_attribute3 OR
	   X_attribute3 IS NULL) AND
	(Recinfo.attribute4 = X_attribute4 OR
	   X_attribute4 IS NULL) AND
	(Recinfo.attribute5 = X_attribute5 OR
	   X_attribute5 IS NULL) AND
	(Recinfo.attribute6 = X_attribute6 OR
	   X_attribute6 IS NULL) AND
	(Recinfo.attribute7 = X_attribute7 OR
	   X_attribute7 IS NULL) AND
	(Recinfo.attribute8 = X_attribute8 OR
	   X_attribute8 IS NULL) AND
	(Recinfo.attribute9 = X_attribute9 OR
	   X_attribute9 IS NULL) AND
	(Recinfo.attribute10 = X_attribute10 OR
	   X_attribute10 IS NULL) AND
	(Recinfo.attribute11 = X_attribute11 OR
	   X_attribute11 IS NULL) AND
	(Recinfo.attribute12 = X_attribute12 OR
	   X_attribute12 IS NULL) AND
	(Recinfo.attribute13 = X_attribute13 OR
	   X_attribute13 IS NULL) AND
	(Recinfo.attribute14 = X_attribute14 OR
	   X_attribute14 IS NULL) AND
	(Recinfo.attribute15 = X_attribute15 OR
	   X_attribute15 IS NULL)
        )
    THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        IF (SQLCODE = -54) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
        ELSE
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                        'tax_category_id = ' || X_tax_category_id);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Lock_Row;

  PROCEDURE Update_Row(X_rowid                   VARCHAR2,

                       X_tax_category_id                 NUMBER,
                       X_org_tax_attribute_name          VARCHAR2,
                       X_org_tax_attribute_value         VARCHAR2,
                       X_con_tax_attribute_name          VARCHAR2,
                       X_con_tax_attribute_value         VARCHAR2,
                       X_document_letter                 VARCHAR2,
                       X_start_date_active               DATE,
                       X_end_date_active                 DATE,
                       X_LAST_UPDATE_DATE                DATE,
                       X_LAST_UPDATED_BY                 NUMBER,
                       X_CREATION_DATE                   DATE,
                       X_CREATED_BY                      NUMBER,
                       X_LAST_UPDATE_LOGIN               NUMBER,
                       X_ATTRIBUTE_CATEGORY              VARCHAR2,
                       X_ATTRIBUTE1                      VARCHAR2,
                       X_ATTRIBUTE2                      VARCHAR2,
                       X_ATTRIBUTE3                      VARCHAR2,
                       X_ATTRIBUTE4                      VARCHAR2,
                       X_ATTRIBUTE5                      VARCHAR2,
                       X_ATTRIBUTE6                      VARCHAR2,
                       X_ATTRIBUTE7                      VARCHAR2,
                       X_ATTRIBUTE8                      VARCHAR2,
                       X_ATTRIBUTE9                      VARCHAR2,
                       X_ATTRIBUTE10                     VARCHAR2,
                       X_ATTRIBUTE11                     VARCHAR2,
                       X_ATTRIBUTE12                     VARCHAR2,
                       X_ATTRIBUTE13                     VARCHAR2,
                       X_ATTRIBUTE14                     VARCHAR2,
                       X_ATTRIBUTE15                     VARCHAR2,

                       X_calling_sequence        IN    VARCHAR2
  ) IS

  BEGIN
    UPDATE jl_ar_ar_doc_letter
    SET tax_category_id = X_tax_category_id,
        org_tax_attribute_name     = X_org_tax_attribute_name,
        org_tax_attribute_value = X_org_tax_attribute_value,
        con_tax_attribute_name   = X_con_tax_attribute_name,
        con_tax_attribute_value = X_con_tax_attribute_value,
        document_letter = X_document_letter,
        start_date_active = X_start_date_active,
        end_date_active = X_end_date_active,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY  = X_LAST_UPDATED_BY,
        CREATION_DATE    = X_CREATION_DATE,
        CREATED_BY       = X_CREATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
        ATTRIBUTE1  = X_ATTRIBUTE1,
        ATTRIBUTE2  = X_ATTRIBUTE2,
        ATTRIBUTE3  = X_ATTRIBUTE3,
        ATTRIBUTE4  = X_ATTRIBUTE4,
        ATTRIBUTE5  = X_ATTRIBUTE5,
        ATTRIBUTE6  = X_ATTRIBUTE6,
        ATTRIBUTE7  = X_ATTRIBUTE7,
        ATTRIBUTE8  = X_ATTRIBUTE8,
        ATTRIBUTE9  = X_ATTRIBUTE9,
        ATTRIBUTE10 = X_ATTRIBUTE10,
        ATTRIBUTE11 = X_ATTRIBUTE11,
        ATTRIBUTE12 = X_ATTRIBUTE12,
        ATTRIBUTE13 = X_ATTRIBUTE13,
        ATTRIBUTE14 = X_ATTRIBUTE14,
        ATTRIBUTE15 = X_ATTRIBUTE15
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND)
    THEN
      raise NO_DATA_FOUND;
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row(  X_rowid                   VARCHAR2
  ) IS
  BEGIN
    DELETE
    FROM   jl_ar_ar_doc_letter
    WHERE  rowid = X_rowid;

    IF (SQL%NOTFOUND)
    THEN
      raise NO_DATA_FOUND;
    END IF;
  END Delete_Row;

  PROCEDURE Check_Unique(
			  X_rowid                   VARCHAR2,
		          X_org_tax_attribute_name  VARCHAR2,
		          X_org_tax_attribute_value VARCHAR2,
                          X_con_tax_attribute_name  VARCHAR2,
		          X_con_tax_attribute_value VARCHAR2,
		          X_end_date_active         DATE,
                          X_calling_sequence        IN    VARCHAR2
  ) IS
	l_dummy NUMBER;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_AR_AR_TX_DOC_LETTER_PKG.CHECK_UNIQUE<-' ||
                                 X_calling_sequence;
	SELECT COUNT(1)
	INTO   l_dummy
	FROM   jl_ar_ar_doc_letter
	WHERE  org_tax_attribute_name = X_org_tax_attribute_name
        AND    org_tax_attribute_value = X_org_tax_attribute_value
        AND    con_tax_attribute_name = X_con_tax_attribute_name
        AND    con_tax_attribute_value = X_con_tax_attribute_value
        AND    end_date_active = X_end_date_active
        AND    ((X_rowid IS NULL) OR (rowid <> X_rowid));
	IF (l_dummy >=1)
	THEN
	  FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	  FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
	  FND_MESSAGE.SET_TOKEN('PARAMETERS',
			' org_tax_attribute_name = ' || X_org_tax_attribute_name ||
			' org_tax_attribute_value = ' || X_org_tax_attribute_value ||
                        ' con_tax_attribute_name = '||X_con_tax_attribute_name||
			' con_tax_attribute_value = ' || X_con_tax_attribute_value ||
			' end_date_active = ' || X_end_date_active );
	  FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
  END Check_Unique;

  PROCEDURE Check_Overlapped_Dates(
			  X_rowid                   VARCHAR2,
		          X_org_tax_attribute_name          VARCHAR2,
		          X_org_tax_attribute_value      VARCHAR2,
                          X_con_tax_attribute_name VARCHAR2,
		          X_con_tax_attribute_value         VARCHAR2,
		          X_end_date_active         DATE,
		          X_start_date_active       DATE,
                          X_calling_sequence        IN    VARCHAR2
  ) IS
	l_dummy NUMBER;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence :=
                           'JL_AR_AR_DOC_LETTER_PKG.<-CHECK_OVERLAPPED_DATES' ||
                                 X_calling_sequence;
	SELECT COUNT(1)
	INTO   l_dummy
	FROM   jl_ar_ar_doc_letter a
	WHERE  a.org_tax_attribute_name = X_org_tax_attribute_name
        AND    a.org_tax_attribute_value = X_org_tax_attribute_value
        AND    a.con_tax_attribute_name = X_con_tax_attribute_name
        AND    a.con_tax_attribute_value = X_con_tax_attribute_value
        AND    ((a.end_date_active <= X_end_date_active AND
	       a.end_date_active >= X_start_date_active)
		OR
		(a.start_date_active <= X_end_date_active AND
                 a.start_date_active >= X_start_date_active)
		OR
		(a.start_date_active <= X_start_date_active AND
	         a.end_date_active >= X_end_date_active))
       AND     ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

	IF (l_dummy >=1)
	THEN
	  FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	  FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	  FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
	  FND_MESSAGE.SET_TOKEN('PARAMETERS',
			' org_tax_attribute_name = ' || X_org_tax_attribute_name ||
			' org_tax_attribute_value = ' || X_org_tax_attribute_value ||
                        ' con_tax_attribute_name ='||X_con_tax_attribute_name||
			' con_tax_attribute_value = ' || X_con_tax_attribute_value ||
			' end_date_active = ' || X_end_date_active );
	  FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END Check_Overlapped_Dates;

  PROCEDURE Check_Gaps(
              X_rowid                   VARCHAR2,
	      X_org_tax_attribute_name  VARCHAR2,
	      X_org_tax_attribute_value VARCHAR2,
              X_con_tax_attribute_name  VARCHAR2,
	      X_con_tax_attribute_value VARCHAR2,
	      X_end_date_active         DATE,
	      X_start_date_active       DATE,
              X_calling_sequence        IN    VARCHAR2
  ) IS
    l_dummy NUMBER;
    l_dummy1 NUMBER;
    l_dummy2 NUMBER;
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(100);
  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'JL_AR_AR_DOC_LETTER_PKG.CHECK_GAPS<-' ||
                                 X_calling_sequence;
--
--  Check if there is one row with it's end date exactly one day
--  less than the current row's start date
--
    SELECT COUNT(1)
    INTO   l_dummy
    FROM   jl_ar_ar_doc_letter a
    WHERE  a.org_tax_attribute_name = X_org_tax_attribute_name
    AND    a.org_tax_attribute_value = X_org_tax_attribute_value
    AND    a.con_tax_attribute_name = X_con_tax_attribute_name
    AND    a.con_tax_attribute_value = X_con_tax_attribute_value
    AND    trunc(a.end_date_active) = (trunc(X_start_date_active) -1)
    AND    ((X_rowid IS NULL) OR (a.rowid <> X_rowid));

    IF (l_dummy = 0)
    THEN
    BEGIN
--
--    Check if there is one row with the start date one day more than the
--    the current row's end-date
--
      SELECT COUNT(1)
      INTO   l_dummy1
      FROM   jl_ar_ar_doc_letter a
      WHERE  a.org_tax_attribute_name = X_org_tax_attribute_name
      AND    a.org_tax_attribute_value = X_org_tax_attribute_value
      AND    a.con_tax_attribute_name = X_con_tax_attribute_name
      AND    a.con_tax_attribute_value = X_con_tax_attribute_value
      AND   (trunc(a.start_date_active) = (trunc(X_end_date_active) + 1))
      AND   ((X_rowid IS NULL) OR (a.rowid <> X_rowid));
--
-- Check if there are no (other) rows at all for the primary key.
-- If there are no rows, then it is not an error.  Otherwise, it is.
--
      IF (l_dummy1 = 0)
      THEN
      BEGIN
        SELECT COUNT(1)
        INTO   l_dummy2
        FROM   jl_ar_ar_doc_letter a
        WHERE  a.org_tax_attribute_name = X_org_tax_attribute_name
        AND    a.org_tax_attribute_value = X_org_tax_attribute_value
        AND    a.con_tax_attribute_name = X_con_tax_attribute_name
        AND    a.con_tax_attribute_value = X_con_tax_attribute_value
        AND    ((X_rowid IS NULL) OR (a.rowid <> X_rowid));
        IF (l_dummy2 <> 0)
        THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
          FND_MESSAGE.SET_TOKEN(
                        'PARAMETERS',
				' org_tax_attribute_name = ' || X_org_tax_attribute_name ||
				' org_tax_attribute_value = ' || X_org_tax_attribute_value ||
                                ' con_tax_attribute_name = '||X_con_tax_attribute_name ||
				' con_tax_attribute_value = ' || X_con_tax_attribute_value ||
				' end_date_active = ' || X_end_date_active );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      END;
      END IF;
    END;
    END IF;
  END Check_Gaps;

END JL_AR_AR_DOC_LETTER_PKG;

/
