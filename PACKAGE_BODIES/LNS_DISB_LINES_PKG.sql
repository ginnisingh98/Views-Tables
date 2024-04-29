--------------------------------------------------------
--  DDL for Package Body LNS_DISB_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_DISB_LINES_PKG" AS
/* $Header: LNS_DSBLN_TBLH_B.pls 120.2 2005/07/26 14:52:57 scherkas noship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(
	X_DISB_LINE_ID		IN OUT NOCOPY NUMBER
	,P_DISB_HEADER_ID		IN NUMBER
	,P_DISB_LINE_NUMBER		IN NUMBER
	,P_LINE_AMOUNT		IN NUMBER
	,P_LINE_PERCENT		IN NUMBER
	,P_PAYEE_PARTY_ID		IN NUMBER
	,P_BANK_ACCOUNT_ID		IN NUMBER
	,P_PAYMENT_METHOD_CODE		IN VARCHAR2
	,P_STATUS		IN VARCHAR2
	,P_REQUEST_DATE		IN DATE
	,P_DISBURSEMENT_DATE		IN DATE
	,P_OBJECT_VERSION_NUMBER		IN NUMBER
	,P_CREATION_DATE		IN DATE
	,P_CREATED_BY		IN NUMBER
	,P_LAST_UPDATE_DATE		IN DATE
	,P_LAST_UPDATED_BY		IN NUMBER
	,P_LAST_UPDATE_LOGIN		IN NUMBER
	,P_INVOICE_INTERFACE_ID		IN NUMBER
	,P_INVOICE_ID		IN NUMBER
) IS
BEGIN
	INSERT INTO LNS_DISB_LINES
	(
		DISB_LINE_ID
		,DISB_HEADER_ID
		,DISB_LINE_NUMBER
		,LINE_AMOUNT
		,LINE_PERCENT
		,PAYEE_PARTY_ID
		,BANK_ACCOUNT_ID
		,PAYMENT_METHOD_CODE
		,STATUS
		,REQUEST_DATE
		,DISBURSEMENT_DATE
		,OBJECT_VERSION_NUMBER
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,INVOICE_INTERFACE_ID
		,INVOICE_ID
	) VALUES (
		DECODE(X_DISB_LINE_ID, FND_API.G_MISS_NUM, LNS_DISB_LINES_S.NEXTVAL, NULL, LNS_DISB_LINES_S.NEXTVAL, X_DISB_LINE_ID)
		,DECODE(P_DISB_HEADER_ID, FND_API.G_MISS_NUM, NULL, P_DISB_HEADER_ID)
		,DECODE(P_DISB_LINE_NUMBER, FND_API.G_MISS_NUM, NULL, P_DISB_LINE_NUMBER)
		,DECODE(P_LINE_AMOUNT, FND_API.G_MISS_NUM, NULL, P_LINE_AMOUNT)
		,DECODE(P_LINE_PERCENT, FND_API.G_MISS_NUM, NULL, P_LINE_PERCENT)
		,DECODE(P_PAYEE_PARTY_ID, FND_API.G_MISS_NUM, NULL, P_PAYEE_PARTY_ID)
		,DECODE(P_BANK_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, P_BANK_ACCOUNT_ID)
		,DECODE(P_PAYMENT_METHOD_CODE, FND_API.G_MISS_CHAR, NULL, P_PAYMENT_METHOD_CODE)
		,DECODE(P_STATUS, FND_API.G_MISS_CHAR, NULL, P_STATUS)
		,DECODE(P_REQUEST_DATE, FND_API.G_MISS_DATE, NULL, P_REQUEST_DATE)
		,DECODE(P_DISBURSEMENT_DATE, FND_API.G_MISS_DATE, NULL, P_DISBURSEMENT_DATE)
		,DECODE(P_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, P_OBJECT_VERSION_NUMBER)
		,LNS_UTILITY_PUB.CREATION_DATE
		,LNS_UTILITY_PUB.CREATED_BY
		,LNS_UTILITY_PUB.LAST_UPDATE_DATE
		,LNS_UTILITY_PUB.LAST_UPDATED_BY
		,LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
		,DECODE(P_INVOICE_INTERFACE_ID, FND_API.G_MISS_NUM, NULL, P_INVOICE_INTERFACE_ID)
		,DECODE(P_INVOICE_ID, FND_API.G_MISS_NUM, NULL, P_INVOICE_ID)
	) RETURNING
		 DISB_LINE_ID
	 INTO
		 X_DISB_LINE_ID;
END Insert_Row;

/* Update_Row procedure */
PROCEDURE Update_Row(
	P_DISB_LINE_ID		IN NUMBER
	,P_DISB_HEADER_ID		IN NUMBER
	,P_DISB_LINE_NUMBER		IN NUMBER
	,P_LINE_AMOUNT		IN NUMBER
	,P_LINE_PERCENT		IN NUMBER
	,P_PAYEE_PARTY_ID		IN NUMBER
	,P_BANK_ACCOUNT_ID		IN NUMBER
	,P_PAYMENT_METHOD_CODE		IN VARCHAR2
	,P_STATUS		IN VARCHAR2
	,P_REQUEST_DATE		IN DATE
	,P_DISBURSEMENT_DATE		IN DATE
	,P_OBJECT_VERSION_NUMBER		IN NUMBER
	,P_LAST_UPDATE_DATE		IN DATE
	,P_LAST_UPDATED_BY		IN NUMBER
	,P_LAST_UPDATE_LOGIN		IN NUMBER
	,P_INVOICE_INTERFACE_ID		IN NUMBER
	,P_INVOICE_ID		IN NUMBER
) IS
BEGIN
	UPDATE LNS_DISB_LINES SET
		DISB_HEADER_ID = DECODE(P_DISB_HEADER_ID, NULL, DISB_HEADER_ID, FND_API.G_MISS_NUM, NULL, P_DISB_HEADER_ID)
		,DISB_LINE_NUMBER = DECODE(P_DISB_LINE_NUMBER, NULL, DISB_LINE_NUMBER, FND_API.G_MISS_NUM, NULL, P_DISB_LINE_NUMBER)
		,LINE_AMOUNT = DECODE(P_LINE_AMOUNT, NULL, LINE_AMOUNT, FND_API.G_MISS_NUM, NULL, P_LINE_AMOUNT)
		,LINE_PERCENT = DECODE(P_LINE_PERCENT, NULL, LINE_PERCENT, FND_API.G_MISS_NUM, NULL, P_LINE_PERCENT)
		,PAYEE_PARTY_ID = DECODE(P_PAYEE_PARTY_ID, NULL, PAYEE_PARTY_ID, FND_API.G_MISS_NUM, NULL, P_PAYEE_PARTY_ID)
		,BANK_ACCOUNT_ID = DECODE(P_BANK_ACCOUNT_ID, NULL, BANK_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, P_BANK_ACCOUNT_ID)
		,PAYMENT_METHOD_CODE = DECODE(P_PAYMENT_METHOD_CODE, NULL, PAYMENT_METHOD_CODE, FND_API.G_MISS_CHAR, NULL, P_PAYMENT_METHOD_CODE)
		,STATUS = DECODE(P_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, NULL, P_STATUS)
		,REQUEST_DATE = DECODE(P_REQUEST_DATE, NULL, REQUEST_DATE, FND_API.G_MISS_DATE, NULL, P_REQUEST_DATE)
		,DISBURSEMENT_DATE = DECODE(P_DISBURSEMENT_DATE, NULL, DISBURSEMENT_DATE, FND_API.G_MISS_DATE, NULL, P_DISBURSEMENT_DATE)
		,OBJECT_VERSION_NUMBER = DECODE(P_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, P_OBJECT_VERSION_NUMBER)
		,LAST_UPDATE_DATE = LNS_UTILITY_PUB.LAST_UPDATE_DATE
		,LAST_UPDATED_BY = LNS_UTILITY_PUB.LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN = LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
		,INVOICE_INTERFACE_ID = DECODE(P_INVOICE_INTERFACE_ID, NULL, INVOICE_INTERFACE_ID, FND_API.G_MISS_NUM, NULL, P_INVOICE_INTERFACE_ID)
		,INVOICE_ID = DECODE(P_INVOICE_ID, NULL, INVOICE_ID, FND_API.G_MISS_NUM, NULL, P_INVOICE_ID)
	 WHERE DISB_LINE_ID = P_DISB_LINE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(P_DISB_LINE_ID IN NUMBER) IS
BEGIN
	DELETE FROM LNS_DISB_LINES
		WHERE DISB_LINE_ID = P_DISB_LINE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(
	P_DISB_LINE_ID		IN NUMBER
	,P_DISB_HEADER_ID		IN NUMBER
	,P_DISB_LINE_NUMBER		IN NUMBER
	,P_LINE_AMOUNT		IN NUMBER
	,P_LINE_PERCENT		IN NUMBER
	,P_PAYEE_PARTY_ID		IN NUMBER
	,P_BANK_ACCOUNT_ID		IN NUMBER
	,P_PAYMENT_METHOD_CODE		IN VARCHAR2
	,P_STATUS		IN VARCHAR2
	,P_REQUEST_DATE		IN DATE
	,P_DISBURSEMENT_DATE		IN DATE
	,P_OBJECT_VERSION_NUMBER		IN NUMBER
	,P_CREATION_DATE		IN DATE
	,P_CREATED_BY		IN NUMBER
	,P_LAST_UPDATE_DATE		IN DATE
	,P_LAST_UPDATED_BY		IN NUMBER
	,P_LAST_UPDATE_LOGIN		IN NUMBER
	,P_INVOICE_INTERFACE_ID		IN NUMBER
	,P_INVOICE_ID		IN NUMBER
) IS
	CURSOR C IS SELECT * FROM LNS_DISB_LINES
		WHERE DISB_LINE_ID = P_DISB_LINE_ID
		FOR UPDATE of DISB_LINE_ID NOWAIT;
	Recinfo C%ROWTYPE;
BEGIN
	OPEN C;
	FETCH C INTO Recinfo;
	IF (C%NOTFOUND) THEN
		CLOSE C;
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE C;

	IF (
		(Recinfo.DISB_LINE_ID = P_DISB_LINE_ID)
		AND ( (Recinfo.DISB_HEADER_ID = P_DISB_HEADER_ID)
			OR ( (Recinfo.DISB_HEADER_ID IS NULL)
				AND (P_DISB_HEADER_ID IS NULL)))
		AND ( (Recinfo.DISB_LINE_NUMBER = P_DISB_LINE_NUMBER)
			OR ( (Recinfo.DISB_LINE_NUMBER IS NULL)
				AND (P_DISB_LINE_NUMBER IS NULL)))
		AND ( (Recinfo.LINE_AMOUNT = P_LINE_AMOUNT)
			OR ( (Recinfo.LINE_AMOUNT IS NULL)
				AND (P_LINE_AMOUNT IS NULL)))
		AND ( (Recinfo.LINE_PERCENT = P_LINE_PERCENT)
			OR ( (Recinfo.LINE_PERCENT IS NULL)
				AND (P_LINE_PERCENT IS NULL)))
		AND ( (Recinfo.PAYEE_PARTY_ID = P_PAYEE_PARTY_ID)
			OR ( (Recinfo.PAYEE_PARTY_ID IS NULL)
				AND (P_PAYEE_PARTY_ID IS NULL)))
		AND ( (Recinfo.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID)
			OR ( (Recinfo.BANK_ACCOUNT_ID IS NULL)
				AND (P_BANK_ACCOUNT_ID IS NULL)))
		AND ( (Recinfo.PAYMENT_METHOD_CODE = P_PAYMENT_METHOD_CODE)
			OR ( (Recinfo.PAYMENT_METHOD_CODE IS NULL)
				AND (P_PAYMENT_METHOD_CODE IS NULL)))
		AND ( (Recinfo.STATUS = P_STATUS)
			OR ( (Recinfo.STATUS IS NULL)
				AND (P_STATUS IS NULL)))
		AND ( (Recinfo.REQUEST_DATE = P_REQUEST_DATE)
			OR ( (Recinfo.REQUEST_DATE IS NULL)
				AND (P_REQUEST_DATE IS NULL)))
		AND ( (Recinfo.DISBURSEMENT_DATE = P_DISBURSEMENT_DATE)
			OR ( (Recinfo.DISBURSEMENT_DATE IS NULL)
				AND (P_DISBURSEMENT_DATE IS NULL)))
		AND ( (Recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
			OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
				AND (P_OBJECT_VERSION_NUMBER IS NULL)))
		AND ( (Recinfo.CREATION_DATE = P_CREATION_DATE)
			OR ( (Recinfo.CREATION_DATE IS NULL)
				AND (P_CREATION_DATE IS NULL)))
		AND ( (Recinfo.CREATED_BY = P_CREATED_BY)
			OR ( (Recinfo.CREATED_BY IS NULL)
				AND (P_CREATED_BY IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_DATE = P_LAST_UPDATE_DATE)
			OR ( (Recinfo.LAST_UPDATE_DATE IS NULL)
				AND (P_LAST_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.LAST_UPDATED_BY = P_LAST_UPDATED_BY)
			OR ( (Recinfo.LAST_UPDATED_BY IS NULL)
				AND (P_LAST_UPDATED_BY IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN)
			OR ( (Recinfo.LAST_UPDATE_LOGIN IS NULL)
				AND (P_LAST_UPDATE_LOGIN IS NULL)))
		AND ( (Recinfo.INVOICE_INTERFACE_ID = P_INVOICE_INTERFACE_ID)
			OR ( (Recinfo.INVOICE_INTERFACE_ID IS NULL)
				AND (P_INVOICE_INTERFACE_ID IS NULL)))
		AND ( (Recinfo.INVOICE_ID = P_INVOICE_ID)
			OR ( (Recinfo.INVOICE_ID IS NULL)
				AND (P_INVOICE_ID IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/