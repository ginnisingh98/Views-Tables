--------------------------------------------------------
--  DDL for Package Body FV_BUDGET_DISTRIBUTION_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BUDGET_DISTRIBUTION_HDR_PKG" as
/* $Header: FVBEHDRB.pls 120.4.12010000.2 2009/05/07 05:42:36 bnarang ship $ */
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_BUDGET_DISTRIBUTION_HDR_PKG.';

PROCEDURE Insert_Row(X_ROWID 	              IN OUT NOCOPY VARCHAR2,
		     X_DISTRIBUTION_ID        NUMBER,
                     X_FUND_VALUE             VARCHAR2,
		     X_SET_OF_BOOKS_ID        NUMBER,
		     X_LAST_UPDATE_DATE       DATE,
		     X_LAST_UPDATED_BY        NUMBER,
		     X_CREATION_DATE          DATE,
		     X_CREATED_BY             NUMBER,
		     X_LAST_UPDATE_LOGIN      NUMBER,
		     X_ATTRIBUTE1             VARCHAR2,
		     X_ATTRIBUTE2             VARCHAR2,
		     X_ATTRIBUTE3             VARCHAR2,
		     X_ATTRIBUTE4             VARCHAR2,
		     X_ATTRIBUTE5             VARCHAR2,
		     X_ATTRIBUTE6             VARCHAR2,
		     X_ATTRIBUTE7             VARCHAR2,
		     X_ATTRIBUTE8             VARCHAR2,
		     X_ATTRIBUTE9             VARCHAR2,
		     X_ATTRIBUTE10            VARCHAR2,
		     X_ATTRIBUTE11            VARCHAR2,
		     X_ATTRIBUTE12            VARCHAR2,
		     X_ATTRIBUTE13            VARCHAR2,
		     X_ATTRIBUTE14            VARCHAR2,
		     X_ATTRIBUTE15            VARCHAR2,
		     X_ATTRIBUTE_CATEGORY     VARCHAR2,
		     X_ORG_ID                 NUMBER,
		     X_FACTS_PRGM_SEGMENT     VARCHAR2,
		     X_TREASURY_SYMBOL_ID     NUMBER,
                     X_FREEZE_DEFINITION_FLAG VARCHAR2
		    ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Insert_Row';
  l_errbuf      VARCHAR2(1024);

	CURSOR C IS SELECT ROWID FROM FV_BUDGET_DISTRIBUTION_HDR
		    WHERE DISTRIBUTION_ID = X_DISTRIBUTION_ID;
  BEGIN
	INSERT INTO FV_BUDGET_DISTRIBUTION_HDR(
			DISTRIBUTION_ID,
			FUND_VALUE ,
			SET_OF_BOOKS_ID ,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY ,
			CREATION_DATE,
			CREATED_BY  ,
			LAST_UPDATE_LOGIN     ,
			ATTRIBUTE1   ,
			ATTRIBUTE2   ,
			ATTRIBUTE3   ,
			ATTRIBUTE4   ,
			ATTRIBUTE5   ,
			ATTRIBUTE6    ,
			ATTRIBUTE7   ,
			ATTRIBUTE8   ,
			ATTRIBUTE9   ,
			ATTRIBUTE10  ,
			ATTRIBUTE11   ,
			ATTRIBUTE12  ,
			ATTRIBUTE13  ,
			ATTRIBUTE14   ,
			ATTRIBUTE15   ,
			ATTRIBUTE_CATEGORY ,
			ORG_ID ,
			FACTS_PRGM_SEGMENT ,
			TREASURY_SYMBOL_ID,
                        FREEZE_DEFINITION_FLAG     )
	VALUES(
			X_DISTRIBUTION_ID ,
			X_FUND_VALUE ,
			X_SET_OF_BOOKS_ID ,
			X_LAST_UPDATE_DATE ,
			X_LAST_UPDATED_BY ,
			X_CREATION_DATE ,
			X_CREATED_BY   ,
			X_LAST_UPDATE_LOGIN  ,
			X_ATTRIBUTE1 ,
			X_ATTRIBUTE2 ,
			X_ATTRIBUTE3 ,
			X_ATTRIBUTE4 ,
			X_ATTRIBUTE5  ,
			X_ATTRIBUTE6  ,
			X_ATTRIBUTE7  ,
			X_ATTRIBUTE8  ,
			X_ATTRIBUTE9  ,
			X_ATTRIBUTE10 ,
			X_ATTRIBUTE11 ,
			X_ATTRIBUTE12 ,
			X_ATTRIBUTE13 ,
			X_ATTRIBUTE14  ,
			X_ATTRIBUTE15  ,
			X_ATTRIBUTE_CATEGORY ,
			X_ORG_ID  ,
			X_FACTS_PRGM_SEGMENT ,
			X_TREASURY_SYMBOL_ID,
          		X_FREEZE_DEFINITION_FLAG	);
	OPEN C;
	FETCH C INTO X_ROWID;
	IF (C%NOTFOUND) THEN
	  CLOSE C;
	  Raise NO_DATA_FOUND;
	END IF;
	CLOSE C;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
    RAISE;
END Insert_Row;

PROCEDURE Update_Row(X_ROWID 	              VARCHAR2,
		     X_DISTRIBUTION_ID        NUMBER,
                     X_FUND_VALUE             VARCHAR2,
		     X_SET_OF_BOOKS_ID        NUMBER,
		     X_LAST_UPDATE_DATE       DATE,
		     X_LAST_UPDATED_BY        NUMBER,
		     X_CREATION_DATE          DATE,
		     X_CREATED_BY             NUMBER,
		     X_LAST_UPDATE_LOGIN      NUMBER,
		     X_ATTRIBUTE1             VARCHAR2,
		     X_ATTRIBUTE2             VARCHAR2,
		     X_ATTRIBUTE3             VARCHAR2,
		     X_ATTRIBUTE4             VARCHAR2,
		     X_ATTRIBUTE5             VARCHAR2,
		     X_ATTRIBUTE6             VARCHAR2,
		     X_ATTRIBUTE7             VARCHAR2,
		     X_ATTRIBUTE8             VARCHAR2,
		     X_ATTRIBUTE9             VARCHAR2,
		     X_ATTRIBUTE10            VARCHAR2,
		     X_ATTRIBUTE11            VARCHAR2,
		     X_ATTRIBUTE12            VARCHAR2,
		     X_ATTRIBUTE13            VARCHAR2,
		     X_ATTRIBUTE14            VARCHAR2,
		     X_ATTRIBUTE15            VARCHAR2,
		     X_ATTRIBUTE_CATEGORY     VARCHAR2,
		     X_ORG_ID                 NUMBER,
		     X_FACTS_PRGM_SEGMENT     VARCHAR2,
		     X_TREASURY_SYMBOL_ID     NUMBER,
                     X_FREEZE_DEFINITION_FLAG VARCHAR2
		    ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Update_Row';
  l_errbuf      VARCHAR2(1024);
BEGIN
 UPDATE FV_BUDGET_DISTRIBUTION_HDR
 SET
	                DISTRIBUTION_ID    =    X_DISTRIBUTION_ID,
			FUND_VALUE         =    X_FUND_VALUE,
			SET_OF_BOOKS_ID    =    X_SET_OF_BOOKS_ID,
			LAST_UPDATE_DATE   =    X_LAST_UPDATE_DATE,
			LAST_UPDATED_BY    =    X_LAST_UPDATED_BY,
			CREATION_DATE      =    X_CREATION_DATE,
			CREATED_BY         =    X_CREATED_BY ,
			LAST_UPDATE_LOGIN  =    X_LAST_UPDATE_LOGIN ,
			ATTRIBUTE1         =    X_ATTRIBUTE1 ,
			ATTRIBUTE2         =    X_ATTRIBUTE2,
			ATTRIBUTE3         =    X_ATTRIBUTE3,
			ATTRIBUTE4         =    X_ATTRIBUTE4 ,
			ATTRIBUTE5         =    X_ATTRIBUTE5 ,
			ATTRIBUTE6         =    X_ATTRIBUTE6 ,
			ATTRIBUTE7         =    X_ATTRIBUTE7 ,
			ATTRIBUTE8         =    X_ATTRIBUTE8 ,
			ATTRIBUTE9         =    X_ATTRIBUTE9 ,
			ATTRIBUTE10        =    X_ATTRIBUTE10 ,
			ATTRIBUTE11        =    X_ATTRIBUTE11 ,
			ATTRIBUTE12        =    X_ATTRIBUTE12 ,
			ATTRIBUTE13        =    X_ATTRIBUTE13 ,
			ATTRIBUTE14        =    X_ATTRIBUTE14 ,
			ATTRIBUTE15        =    X_ATTRIBUTE15,
			ATTRIBUTE_CATEGORY =    X_ATTRIBUTE_CATEGORY,
			ORG_ID             =    X_ORG_ID ,
			FACTS_PRGM_SEGMENT =    X_FACTS_PRGM_SEGMENT ,
			TREASURY_SYMBOL_ID =    X_TREASURY_SYMBOL_ID,
                        FREEZE_DEFINITION_FLAG = X_FREEZE_DEFINITION_FLAG
 WHERE ROWID = X_ROWID;

 IF (SQL%NOTFOUND) THEN
	RAISE NO_DATA_FOUND;
	END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
    RAISE;
 END Update_Row;


PROCEDURE Lock_Row(  X_ROWID 	              VARCHAR2,
		     X_DISTRIBUTION_ID        NUMBER,
                     X_FUND_VALUE             VARCHAR2,
		     X_SET_OF_BOOKS_ID        NUMBER,
		     X_ATTRIBUTE_CATEGORY     VARCHAR2,
		     X_ORG_ID                 NUMBER,
		     X_FACTS_PRGM_SEGMENT     VARCHAR2,
		     X_TREASURY_SYMBOL_ID     NUMBER
		  ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Lock_Row';
  l_errbuf      VARCHAR2(1024);
	CURSOR C IS
		SELECT  distribution_id,
		        fund_value,
		        set_of_books_id,
		        attribute_category,
		        org_id,
		        facts_prgm_segment,
		        treasury_symbol_id
		FROM  FV_BUDGET_DISTRIBUTION_HDR
		WHERE ROWID = X_ROWID
		for UPDATE OF DISTRIBUTION_ID NOWAIT;
	Recinfo C%ROWTYPE;

 BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
   IF (C%NOTFOUND) THEN
   CLOSE C;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   APP_EXCEPTION.Raise_Exception;
   END IF;
  CLOSE C;
  IF ((recinfo.DISTRIBUTION_ID = X_DISTRIBUTION_ID)
	AND (recinfo.FUND_VALUE =  X_FUND_VALUE)
	AND (recinfo.SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID)
	AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
	     OR ((recinfo.ATTRIBUTE_CATEGORY IS NULL)
		AND (X_ATTRIBUTE_CATEGORY IS NULL)))
	AND ((recinfo.ORG_ID = X_ORG_ID)
	     OR ((recinfo.ORG_ID IS NULL)
		AND (X_ORG_ID IS NULL)))
	AND ((recinfo.FACTS_PRGM_SEGMENT = X_FACTS_PRGM_SEGMENT)
	     OR ((recinfo.FACTS_PRGM_SEGMENT IS NULL)
		AND (X_FACTS_PRGM_SEGMENT IS NULL)))
        AND (recinfo.TREASURY_SYMBOL_ID = X_TREASURY_SYMBOL_ID)
	) THEN
	RETURN;
   ELSE
	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
  IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name||'.message');
  END IF;
	APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
    RAISE;
 END Lock_Row;



PROCEDURE Delete_Row(X_ROWID VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Delete_Row';
  l_errbuf      VARCHAR2(1024);
 x_distribution_id NUMBER;
 x_fund_value      VARCHAR2(25);
BEGIN
  BEGIN
	SELECT distribution_id
	INTO   x_distribution_id
	FROM   FV_BUDGET_DISTRIBUTION_HDR
	WHERE  rowid = x_rowid;

	SELECT fund_value
	INTO   x_fund_value
	FROM   FV_BUDGET_DISTRIBUTION_HDR
	WHERE  rowid = x_rowid;

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE;
  END;


/* Delete FV_BUDGET_DISTRIBUTION_DTL - Master - Detail -  Detail Record */
  DELETE FROM FV_BUDGET_DISTRIBUTION_DTL
  WHERE fund_value IN
		(SELECT fund_value
		 FROM   FV_BUDGET_DISTRIBUTION_HDR
		 WHERE  fund_value = x_fund_value);

  IF (SQL%NOTFOUND) THEN
  NULL;
  END IF;

/* Delete FV_BUDGET_DISTRIBUTION_HDR - Master Record */
  DELETE FROM FV_BUDGET_DISTRIBUTION_HDR
  WHERE DISTRIBUTION_ID = X_DISTRIBUTION_ID ;

  IF (SQL%NOTFOUND) THEN
  RAISE NO_DATA_FOUND;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
    RAISE;
END DELETE_ROW;

END FV_BUDGET_DISTRIBUTION_HDR_PKG;

/
