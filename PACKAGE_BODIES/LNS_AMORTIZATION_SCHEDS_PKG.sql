--------------------------------------------------------
--  DDL for Package Body LNS_AMORTIZATION_SCHEDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_AMORTIZATION_SCHEDS_PKG" AS
/* $Header: LNS_AMSCH_TBLH_B.pls 120.1.12010000.2 2010/03/17 13:08:56 scherkas ship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(
	X_AMORTIZATION_SCHEDULE_ID		IN OUT NOCOPY NUMBER
	,P_LOAN_ID		IN NUMBER
	,P_PAYMENT_NUMBER		IN NUMBER
	,P_DUE_DATE		IN DATE
	,P_LATE_DATE		IN DATE
	,P_PRINCIPAL_AMOUNT		IN NUMBER
	,P_INTEREST_AMOUNT		IN NUMBER
	,P_OTHER_AMOUNT		IN NUMBER
	,P_REVERSED_FLAG		IN VARCHAR2
	,P_REVERSED_DATE		IN DATE
	,P_RATE_ID		IN NUMBER
	,P_CREATED_BY		IN NUMBER
	,P_CREATION_DATE		IN DATE
	,P_LAST_UPDATED_BY		IN NUMBER
	,P_LAST_UPDATE_DATE		IN DATE
	,P_LAST_UPDATE_LOGIN		IN NUMBER
	,P_ATTRIBUTE_CATEGORY		IN VARCHAR2
	,P_ATTRIBUTE1		IN VARCHAR2
	,P_ATTRIBUTE2		IN VARCHAR2
	,P_ATTRIBUTE3		IN VARCHAR2
	,P_ATTRIBUTE4		IN VARCHAR2
	,P_ATTRIBUTE5		IN VARCHAR2
	,P_ATTRIBUTE6		IN VARCHAR2
	,P_ATTRIBUTE7		IN VARCHAR2
	,P_ATTRIBUTE8		IN VARCHAR2
	,P_ATTRIBUTE9		IN VARCHAR2
	,P_ATTRIBUTE10		IN VARCHAR2
	,P_ATTRIBUTE11		IN VARCHAR2
	,P_ATTRIBUTE12		IN VARCHAR2
	,P_ATTRIBUTE13		IN VARCHAR2
	,P_ATTRIBUTE14		IN VARCHAR2
	,P_ATTRIBUTE15		IN VARCHAR2
	,P_ATTRIBUTE16		IN VARCHAR2
	,P_ATTRIBUTE17		IN VARCHAR2
	,P_ATTRIBUTE18		IN VARCHAR2
	,P_ATTRIBUTE19		IN VARCHAR2
	,P_ATTRIBUTE20		IN VARCHAR2
	,P_OBJECT_VERSION_NUMBER		IN NUMBER
	,P_PARENT_AMORTIZATION_ID		IN NUMBER
	,P_REAMORTIZATION_AMOUNT		IN NUMBER
	,P_REAMORTIZE_FROM_INSTALLMENT		IN NUMBER
	,P_REAMORTIZE_TO_INSTALLMENT		IN NUMBER
	,P_FEE_AMOUNT		IN NUMBER
	,P_PRINCIPAL_TRX_ID		IN NUMBER
	,P_INTEREST_TRX_ID		IN NUMBER
	,P_FEE_TRX_ID		IN NUMBER
	,P_STATEMENT_XML		IN CLOB
	,P_PRINCIPAL_BALANCE		IN NUMBER
	,P_PHASE		IN VARCHAR2
	,P_FUNDED_AMOUNT		IN NUMBER
) IS
BEGIN
	INSERT INTO LNS_AMORTIZATION_SCHEDS
	(
		AMORTIZATION_SCHEDULE_ID
		,LOAN_ID
		,PAYMENT_NUMBER
		,DUE_DATE
		,LATE_DATE
		,PRINCIPAL_AMOUNT
		,INTEREST_AMOUNT
		,OTHER_AMOUNT
		,REVERSED_FLAG
		,REVERSED_DATE
		,RATE_ID
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
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
		,OBJECT_VERSION_NUMBER
		,PARENT_AMORTIZATION_ID
		,REAMORTIZATION_AMOUNT
		,REAMORTIZE_FROM_INSTALLMENT
		,REAMORTIZE_TO_INSTALLMENT
		,FEE_AMOUNT
		,PRINCIPAL_TRX_ID
		,INTEREST_TRX_ID
		,FEE_TRX_ID
		,STATEMENT_XML
		,PRINCIPAL_BALANCE
		,PHASE
		,FUNDED_AMOUNT
	) VALUES (
		DECODE(X_AMORTIZATION_SCHEDULE_ID, FND_API.G_MISS_NUM, LNS_AMORTIZATION_SCHEDS_S.NEXTVAL, NULL, LNS_AMORTIZATION_SCHEDS_S.NEXTVAL, X_AMORTIZATION_SCHEDULE_ID)
		,DECODE(P_LOAN_ID, FND_API.G_MISS_NUM, NULL, P_LOAN_ID)
		,DECODE(P_PAYMENT_NUMBER, FND_API.G_MISS_NUM, NULL, P_PAYMENT_NUMBER)
		,DECODE(P_DUE_DATE, FND_API.G_MISS_DATE, NULL, P_DUE_DATE)
		,DECODE(P_LATE_DATE, FND_API.G_MISS_DATE, NULL, P_LATE_DATE)
		,DECODE(P_PRINCIPAL_AMOUNT, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_AMOUNT)
		,DECODE(P_INTEREST_AMOUNT, FND_API.G_MISS_NUM, NULL, P_INTEREST_AMOUNT)
		,DECODE(P_OTHER_AMOUNT, FND_API.G_MISS_NUM, NULL, P_OTHER_AMOUNT)
		,DECODE(P_REVERSED_FLAG, FND_API.G_MISS_CHAR, NULL, P_REVERSED_FLAG)
		,DECODE(P_REVERSED_DATE, FND_API.G_MISS_DATE, NULL, P_REVERSED_DATE)
		,DECODE(P_RATE_ID, FND_API.G_MISS_NUM, NULL, P_RATE_ID)
		,LNS_UTILITY_PUB.CREATED_BY
		,LNS_UTILITY_PUB.CREATION_DATE
		,LNS_UTILITY_PUB.LAST_UPDATED_BY
		,LNS_UTILITY_PUB.LAST_UPDATE_DATE
		,LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
		,DECODE(P_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE_CATEGORY)
		,DECODE(P_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE1)
		,DECODE(P_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE2)
		,DECODE(P_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE3)
		,DECODE(P_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE4)
		,DECODE(P_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE5)
		,DECODE(P_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE6)
		,DECODE(P_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE7)
		,DECODE(P_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE8)
		,DECODE(P_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE9)
		,DECODE(P_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE10)
		,DECODE(P_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE11)
		,DECODE(P_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE12)
		,DECODE(P_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE13)
		,DECODE(P_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE14)
		,DECODE(P_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE15)
		,DECODE(P_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE16)
		,DECODE(P_ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE17)
		,DECODE(P_ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE18)
		,DECODE(P_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE19)
		,DECODE(P_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE20)
		,DECODE(P_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, P_OBJECT_VERSION_NUMBER)
		,DECODE(P_PARENT_AMORTIZATION_ID, FND_API.G_MISS_NUM, NULL, P_PARENT_AMORTIZATION_ID)
		,DECODE(P_REAMORTIZATION_AMOUNT, FND_API.G_MISS_NUM, NULL, P_REAMORTIZATION_AMOUNT)
		,DECODE(P_REAMORTIZE_FROM_INSTALLMENT, FND_API.G_MISS_NUM, NULL, P_REAMORTIZE_FROM_INSTALLMENT)
		,DECODE(P_REAMORTIZE_TO_INSTALLMENT, FND_API.G_MISS_NUM, NULL, P_REAMORTIZE_TO_INSTALLMENT)
		,DECODE(P_FEE_AMOUNT, FND_API.G_MISS_NUM, NULL, P_FEE_AMOUNT)
		,DECODE(P_PRINCIPAL_TRX_ID, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_TRX_ID)
		,DECODE(P_INTEREST_TRX_ID, FND_API.G_MISS_NUM, NULL, P_INTEREST_TRX_ID)
		,DECODE(P_FEE_TRX_ID, FND_API.G_MISS_NUM, NULL, P_FEE_TRX_ID)
		,P_STATEMENT_XML
		,DECODE(P_PRINCIPAL_BALANCE, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_BALANCE)
		,DECODE(P_PHASE, FND_API.G_MISS_CHAR, NULL, P_PHASE)
		,DECODE(P_FUNDED_AMOUNT, FND_API.G_MISS_NUM, NULL, P_FUNDED_AMOUNT)
	) RETURNING
		 AMORTIZATION_SCHEDULE_ID
	 INTO
		 X_AMORTIZATION_SCHEDULE_ID;
END Insert_Row;

/* Update_Row procedure */
PROCEDURE Update_Row(
	P_AMORTIZATION_SCHEDULE_ID		IN NUMBER
	,P_LOAN_ID		IN NUMBER
	,P_PAYMENT_NUMBER		IN NUMBER
	,P_DUE_DATE		IN DATE
	,P_LATE_DATE		IN DATE
	,P_PRINCIPAL_AMOUNT		IN NUMBER
	,P_INTEREST_AMOUNT		IN NUMBER
	,P_OTHER_AMOUNT		IN NUMBER
	,P_REVERSED_FLAG		IN VARCHAR2
	,P_REVERSED_DATE		IN DATE
	,P_RATE_ID		IN NUMBER
	,P_LAST_UPDATED_BY		IN NUMBER
	,P_LAST_UPDATE_DATE		IN DATE
	,P_LAST_UPDATE_LOGIN		IN NUMBER
	,P_ATTRIBUTE_CATEGORY		IN VARCHAR2
	,P_ATTRIBUTE1		IN VARCHAR2
	,P_ATTRIBUTE2		IN VARCHAR2
	,P_ATTRIBUTE3		IN VARCHAR2
	,P_ATTRIBUTE4		IN VARCHAR2
	,P_ATTRIBUTE5		IN VARCHAR2
	,P_ATTRIBUTE6		IN VARCHAR2
	,P_ATTRIBUTE7		IN VARCHAR2
	,P_ATTRIBUTE8		IN VARCHAR2
	,P_ATTRIBUTE9		IN VARCHAR2
	,P_ATTRIBUTE10		IN VARCHAR2
	,P_ATTRIBUTE11		IN VARCHAR2
	,P_ATTRIBUTE12		IN VARCHAR2
	,P_ATTRIBUTE13		IN VARCHAR2
	,P_ATTRIBUTE14		IN VARCHAR2
	,P_ATTRIBUTE15		IN VARCHAR2
	,P_ATTRIBUTE16		IN VARCHAR2
	,P_ATTRIBUTE17		IN VARCHAR2
	,P_ATTRIBUTE18		IN VARCHAR2
	,P_ATTRIBUTE19		IN VARCHAR2
	,P_ATTRIBUTE20		IN VARCHAR2
	,P_OBJECT_VERSION_NUMBER		IN NUMBER
	,P_PARENT_AMORTIZATION_ID		IN NUMBER
	,P_REAMORTIZATION_AMOUNT		IN NUMBER
	,P_REAMORTIZE_FROM_INSTALLMENT		IN NUMBER
	,P_REAMORTIZE_TO_INSTALLMENT		IN NUMBER
	,P_FEE_AMOUNT		IN NUMBER
	,P_PRINCIPAL_TRX_ID		IN NUMBER
	,P_INTEREST_TRX_ID		IN NUMBER
	,P_FEE_TRX_ID		IN NUMBER
	,P_PRINCIPAL_BALANCE		IN NUMBER
	,P_PHASE		IN VARCHAR2
	,P_FUNDED_AMOUNT		IN NUMBER
) IS
BEGIN
	UPDATE LNS_AMORTIZATION_SCHEDS SET
		LOAN_ID = DECODE(P_LOAN_ID, NULL, LOAN_ID, FND_API.G_MISS_NUM, NULL, P_LOAN_ID)
		,PAYMENT_NUMBER = DECODE(P_PAYMENT_NUMBER, NULL, PAYMENT_NUMBER, FND_API.G_MISS_NUM, NULL, P_PAYMENT_NUMBER)
		,DUE_DATE = DECODE(P_DUE_DATE, NULL, DUE_DATE, FND_API.G_MISS_DATE, NULL, P_DUE_DATE)
		,LATE_DATE = DECODE(P_LATE_DATE, NULL, LATE_DATE, FND_API.G_MISS_DATE, NULL, P_LATE_DATE)
		,PRINCIPAL_AMOUNT = DECODE(P_PRINCIPAL_AMOUNT, NULL, PRINCIPAL_AMOUNT, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_AMOUNT)
		,INTEREST_AMOUNT = DECODE(P_INTEREST_AMOUNT, NULL, INTEREST_AMOUNT, FND_API.G_MISS_NUM, NULL, P_INTEREST_AMOUNT)
		,OTHER_AMOUNT = DECODE(P_OTHER_AMOUNT, NULL, OTHER_AMOUNT, FND_API.G_MISS_NUM, NULL, P_OTHER_AMOUNT)
		,REVERSED_FLAG = DECODE(P_REVERSED_FLAG, NULL, REVERSED_FLAG, FND_API.G_MISS_CHAR, NULL, P_REVERSED_FLAG)
		,REVERSED_DATE = DECODE(P_REVERSED_DATE, NULL, REVERSED_DATE, FND_API.G_MISS_DATE, NULL, P_REVERSED_DATE)
		,RATE_ID = DECODE(P_RATE_ID, NULL, RATE_ID, FND_API.G_MISS_NUM, NULL, P_RATE_ID)
		,LAST_UPDATED_BY = LNS_UTILITY_PUB.LAST_UPDATED_BY
		,LAST_UPDATE_DATE = LNS_UTILITY_PUB.LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN = LNS_UTILITY_PUB.LAST_UPDATE_LOGIN
		,ATTRIBUTE_CATEGORY = DECODE(P_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE_CATEGORY)
		,ATTRIBUTE1 = DECODE(P_ATTRIBUTE1, NULL, ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE1)
		,ATTRIBUTE2 = DECODE(P_ATTRIBUTE2, NULL, ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE2)
		,ATTRIBUTE3 = DECODE(P_ATTRIBUTE3, NULL, ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE3)
		,ATTRIBUTE4 = DECODE(P_ATTRIBUTE4, NULL, ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE4)
		,ATTRIBUTE5 = DECODE(P_ATTRIBUTE5, NULL, ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE5)
		,ATTRIBUTE6 = DECODE(P_ATTRIBUTE6, NULL, ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE6)
		,ATTRIBUTE7 = DECODE(P_ATTRIBUTE7, NULL, ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE7)
		,ATTRIBUTE8 = DECODE(P_ATTRIBUTE8, NULL, ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE8)
		,ATTRIBUTE9 = DECODE(P_ATTRIBUTE9, NULL, ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE9)
		,ATTRIBUTE10 = DECODE(P_ATTRIBUTE10, NULL, ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE10)
		,ATTRIBUTE11 = DECODE(P_ATTRIBUTE11, NULL, ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE11)
		,ATTRIBUTE12 = DECODE(P_ATTRIBUTE12, NULL, ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE12)
		,ATTRIBUTE13 = DECODE(P_ATTRIBUTE13, NULL, ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE13)
		,ATTRIBUTE14 = DECODE(P_ATTRIBUTE14, NULL, ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE14)
		,ATTRIBUTE15 = DECODE(P_ATTRIBUTE15, NULL, ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE15)
		,ATTRIBUTE16 = DECODE(P_ATTRIBUTE16, NULL, ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE16)
		,ATTRIBUTE17 = DECODE(P_ATTRIBUTE17, NULL, ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE17)
		,ATTRIBUTE18 = DECODE(P_ATTRIBUTE18, NULL, ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE18)
		,ATTRIBUTE19 = DECODE(P_ATTRIBUTE19, NULL, ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE19)
		,ATTRIBUTE20 = DECODE(P_ATTRIBUTE20, NULL, ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, P_ATTRIBUTE20)
		,OBJECT_VERSION_NUMBER = DECODE(P_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, P_OBJECT_VERSION_NUMBER)
		,PARENT_AMORTIZATION_ID = DECODE(P_PARENT_AMORTIZATION_ID, NULL, PARENT_AMORTIZATION_ID, FND_API.G_MISS_NUM, NULL, P_PARENT_AMORTIZATION_ID)
		,REAMORTIZATION_AMOUNT = DECODE(P_REAMORTIZATION_AMOUNT, NULL, REAMORTIZATION_AMOUNT, FND_API.G_MISS_NUM, NULL, P_REAMORTIZATION_AMOUNT)
		,REAMORTIZE_FROM_INSTALLMENT = DECODE(P_REAMORTIZE_FROM_INSTALLMENT, NULL, REAMORTIZE_FROM_INSTALLMENT, FND_API.G_MISS_NUM, NULL, P_REAMORTIZE_FROM_INSTALLMENT)
		,REAMORTIZE_TO_INSTALLMENT = DECODE(P_REAMORTIZE_TO_INSTALLMENT, NULL, REAMORTIZE_TO_INSTALLMENT, FND_API.G_MISS_NUM, NULL, P_REAMORTIZE_TO_INSTALLMENT)
		,FEE_AMOUNT = DECODE(P_FEE_AMOUNT, NULL, FEE_AMOUNT, FND_API.G_MISS_NUM, NULL, P_FEE_AMOUNT)
		,PRINCIPAL_TRX_ID = DECODE(P_PRINCIPAL_TRX_ID, NULL, PRINCIPAL_TRX_ID, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_TRX_ID)
		,INTEREST_TRX_ID = DECODE(P_INTEREST_TRX_ID, NULL, INTEREST_TRX_ID, FND_API.G_MISS_NUM, NULL, P_INTEREST_TRX_ID)
		,FEE_TRX_ID = DECODE(P_FEE_TRX_ID, NULL, FEE_TRX_ID, FND_API.G_MISS_NUM, NULL, P_FEE_TRX_ID)
		,PRINCIPAL_BALANCE = DECODE(P_PRINCIPAL_BALANCE, NULL, PRINCIPAL_BALANCE, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_BALANCE)
		,PHASE = DECODE(P_PHASE, NULL, PHASE, FND_API.G_MISS_CHAR, NULL, P_PHASE)
		,FUNDED_AMOUNT = DECODE(P_FUNDED_AMOUNT, NULL, FUNDED_AMOUNT, FND_API.G_MISS_NUM, NULL, P_FUNDED_AMOUNT)
	 WHERE AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_SCHEDULE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Update_Statement procedure */
PROCEDURE Update_Statement(
	P_AMORTIZATION_SCHEDULE_ID		IN NUMBER
	,P_STATEMENT_XML		IN CLOB
) IS
BEGIN
	UPDATE LNS_AMORTIZATION_SCHEDS SET
		STATEMENT_XML = P_STATEMENT_XML
	 WHERE AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_SCHEDULE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Statement;

/* Delete_Row procedure */
PROCEDURE Delete_Row(P_AMORTIZATION_SCHEDULE_ID IN NUMBER) IS
BEGIN
	DELETE FROM LNS_AMORTIZATION_SCHEDS
		WHERE AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_SCHEDULE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(
	P_AMORTIZATION_SCHEDULE_ID		IN NUMBER
	,P_LOAN_ID		IN NUMBER
	,P_PAYMENT_NUMBER		IN NUMBER
	,P_DUE_DATE		IN DATE
	,P_LATE_DATE		IN DATE
	,P_PRINCIPAL_AMOUNT		IN NUMBER
	,P_INTEREST_AMOUNT		IN NUMBER
	,P_OTHER_AMOUNT		IN NUMBER
	,P_REVERSED_FLAG		IN VARCHAR2
	,P_REVERSED_DATE		IN DATE
	,P_RATE_ID		IN NUMBER
	,P_CREATED_BY		IN NUMBER
	,P_CREATION_DATE		IN DATE
	,P_LAST_UPDATED_BY		IN NUMBER
	,P_LAST_UPDATE_DATE		IN DATE
	,P_LAST_UPDATE_LOGIN		IN NUMBER
	,P_ATTRIBUTE_CATEGORY		IN VARCHAR2
	,P_ATTRIBUTE1		IN VARCHAR2
	,P_ATTRIBUTE2		IN VARCHAR2
	,P_ATTRIBUTE3		IN VARCHAR2
	,P_ATTRIBUTE4		IN VARCHAR2
	,P_ATTRIBUTE5		IN VARCHAR2
	,P_ATTRIBUTE6		IN VARCHAR2
	,P_ATTRIBUTE7		IN VARCHAR2
	,P_ATTRIBUTE8		IN VARCHAR2
	,P_ATTRIBUTE9		IN VARCHAR2
	,P_ATTRIBUTE10		IN VARCHAR2
	,P_ATTRIBUTE11		IN VARCHAR2
	,P_ATTRIBUTE12		IN VARCHAR2
	,P_ATTRIBUTE13		IN VARCHAR2
	,P_ATTRIBUTE14		IN VARCHAR2
	,P_ATTRIBUTE15		IN VARCHAR2
	,P_ATTRIBUTE16		IN VARCHAR2
	,P_ATTRIBUTE17		IN VARCHAR2
	,P_ATTRIBUTE18		IN VARCHAR2
	,P_ATTRIBUTE19		IN VARCHAR2
	,P_ATTRIBUTE20		IN VARCHAR2
	,P_OBJECT_VERSION_NUMBER		IN NUMBER
	,P_PARENT_AMORTIZATION_ID		IN NUMBER
	,P_REAMORTIZATION_AMOUNT		IN NUMBER
	,P_REAMORTIZE_FROM_INSTALLMENT		IN NUMBER
	,P_REAMORTIZE_TO_INSTALLMENT		IN NUMBER
	,P_FEE_AMOUNT		IN NUMBER
	,P_PRINCIPAL_TRX_ID		IN NUMBER
	,P_INTEREST_TRX_ID		IN NUMBER
	,P_FEE_TRX_ID		IN NUMBER
	,P_STATEMENT_XML		IN CLOB
	,P_PRINCIPAL_BALANCE		IN NUMBER
	,P_PHASE		IN VARCHAR2
	,P_FUNDED_AMOUNT		IN NUMBER
) IS
	CURSOR C IS SELECT * FROM LNS_AMORTIZATION_SCHEDS
		WHERE AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_SCHEDULE_ID
		FOR UPDATE of AMORTIZATION_SCHEDULE_ID NOWAIT;
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
		(Recinfo.AMORTIZATION_SCHEDULE_ID = P_AMORTIZATION_SCHEDULE_ID)
		AND ( (Recinfo.LOAN_ID = P_LOAN_ID)
			OR ( (Recinfo.LOAN_ID IS NULL)
				AND (P_LOAN_ID IS NULL)))
		AND ( (Recinfo.PAYMENT_NUMBER = P_PAYMENT_NUMBER)
			OR ( (Recinfo.PAYMENT_NUMBER IS NULL)
				AND (P_PAYMENT_NUMBER IS NULL)))
		AND ( (Recinfo.DUE_DATE = P_DUE_DATE)
			OR ( (Recinfo.DUE_DATE IS NULL)
				AND (P_DUE_DATE IS NULL)))
		AND ( (Recinfo.LATE_DATE = P_LATE_DATE)
			OR ( (Recinfo.LATE_DATE IS NULL)
				AND (P_LATE_DATE IS NULL)))
		AND ( (Recinfo.PRINCIPAL_AMOUNT = P_PRINCIPAL_AMOUNT)
			OR ( (Recinfo.PRINCIPAL_AMOUNT IS NULL)
				AND (P_PRINCIPAL_AMOUNT IS NULL)))
		AND ( (Recinfo.INTEREST_AMOUNT = P_INTEREST_AMOUNT)
			OR ( (Recinfo.INTEREST_AMOUNT IS NULL)
				AND (P_INTEREST_AMOUNT IS NULL)))
		AND ( (Recinfo.OTHER_AMOUNT = P_OTHER_AMOUNT)
			OR ( (Recinfo.OTHER_AMOUNT IS NULL)
				AND (P_OTHER_AMOUNT IS NULL)))
		AND ( (Recinfo.REVERSED_FLAG = P_REVERSED_FLAG)
			OR ( (Recinfo.REVERSED_FLAG IS NULL)
				AND (P_REVERSED_FLAG IS NULL)))
		AND ( (Recinfo.REVERSED_DATE = P_REVERSED_DATE)
			OR ( (Recinfo.REVERSED_DATE IS NULL)
				AND (P_REVERSED_DATE IS NULL)))
		AND ( (Recinfo.RATE_ID = P_RATE_ID)
			OR ( (Recinfo.RATE_ID IS NULL)
				AND (P_RATE_ID IS NULL)))
		AND ( (Recinfo.CREATED_BY = P_CREATED_BY)
			OR ( (Recinfo.CREATED_BY IS NULL)
				AND (P_CREATED_BY IS NULL)))
		AND ( (Recinfo.CREATION_DATE = P_CREATION_DATE)
			OR ( (Recinfo.CREATION_DATE IS NULL)
				AND (P_CREATION_DATE IS NULL)))
		AND ( (Recinfo.LAST_UPDATED_BY = P_LAST_UPDATED_BY)
			OR ( (Recinfo.LAST_UPDATED_BY IS NULL)
				AND (P_LAST_UPDATED_BY IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_DATE = P_LAST_UPDATE_DATE)
			OR ( (Recinfo.LAST_UPDATE_DATE IS NULL)
				AND (P_LAST_UPDATE_DATE IS NULL)))
		AND ( (Recinfo.LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN)
			OR ( (Recinfo.LAST_UPDATE_LOGIN IS NULL)
				AND (P_LAST_UPDATE_LOGIN IS NULL)))
		AND ( (Recinfo.ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY)
			OR ( (Recinfo.ATTRIBUTE_CATEGORY IS NULL)
				AND (P_ATTRIBUTE_CATEGORY IS NULL)))
		AND ( (Recinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
			OR ( (Recinfo.ATTRIBUTE1 IS NULL)
				AND (P_ATTRIBUTE1 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
			OR ( (Recinfo.ATTRIBUTE2 IS NULL)
				AND (P_ATTRIBUTE2 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
			OR ( (Recinfo.ATTRIBUTE3 IS NULL)
				AND (P_ATTRIBUTE3 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
			OR ( (Recinfo.ATTRIBUTE4 IS NULL)
				AND (P_ATTRIBUTE4 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
			OR ( (Recinfo.ATTRIBUTE5 IS NULL)
				AND (P_ATTRIBUTE5 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
			OR ( (Recinfo.ATTRIBUTE6 IS NULL)
				AND (P_ATTRIBUTE6 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
			OR ( (Recinfo.ATTRIBUTE7 IS NULL)
				AND (P_ATTRIBUTE7 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
			OR ( (Recinfo.ATTRIBUTE8 IS NULL)
				AND (P_ATTRIBUTE8 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
			OR ( (Recinfo.ATTRIBUTE9 IS NULL)
				AND (P_ATTRIBUTE9 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
			OR ( (Recinfo.ATTRIBUTE10 IS NULL)
				AND (P_ATTRIBUTE10 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
			OR ( (Recinfo.ATTRIBUTE11 IS NULL)
				AND (P_ATTRIBUTE11 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
			OR ( (Recinfo.ATTRIBUTE12 IS NULL)
				AND (P_ATTRIBUTE12 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
			OR ( (Recinfo.ATTRIBUTE13 IS NULL)
				AND (P_ATTRIBUTE13 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
			OR ( (Recinfo.ATTRIBUTE14 IS NULL)
				AND (P_ATTRIBUTE14 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
			OR ( (Recinfo.ATTRIBUTE15 IS NULL)
				AND (P_ATTRIBUTE15 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE16 = P_ATTRIBUTE16)
			OR ( (Recinfo.ATTRIBUTE16 IS NULL)
				AND (P_ATTRIBUTE16 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE17 = P_ATTRIBUTE17)
			OR ( (Recinfo.ATTRIBUTE17 IS NULL)
				AND (P_ATTRIBUTE17 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE18 = P_ATTRIBUTE18)
			OR ( (Recinfo.ATTRIBUTE18 IS NULL)
				AND (P_ATTRIBUTE18 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE19 = P_ATTRIBUTE19)
			OR ( (Recinfo.ATTRIBUTE19 IS NULL)
				AND (P_ATTRIBUTE19 IS NULL)))
		AND ( (Recinfo.ATTRIBUTE20 = P_ATTRIBUTE20)
			OR ( (Recinfo.ATTRIBUTE20 IS NULL)
				AND (P_ATTRIBUTE20 IS NULL)))
		AND ( (Recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
			OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
				AND (P_OBJECT_VERSION_NUMBER IS NULL)))
		AND ( (Recinfo.PARENT_AMORTIZATION_ID = P_PARENT_AMORTIZATION_ID)
			OR ( (Recinfo.PARENT_AMORTIZATION_ID IS NULL)
				AND (P_PARENT_AMORTIZATION_ID IS NULL)))
		AND ( (Recinfo.REAMORTIZATION_AMOUNT = P_REAMORTIZATION_AMOUNT)
			OR ( (Recinfo.REAMORTIZATION_AMOUNT IS NULL)
				AND (P_REAMORTIZATION_AMOUNT IS NULL)))
		AND ( (Recinfo.REAMORTIZE_FROM_INSTALLMENT = P_REAMORTIZE_FROM_INSTALLMENT)
			OR ( (Recinfo.REAMORTIZE_FROM_INSTALLMENT IS NULL)
				AND (P_REAMORTIZE_FROM_INSTALLMENT IS NULL)))
		AND ( (Recinfo.REAMORTIZE_TO_INSTALLMENT = P_REAMORTIZE_TO_INSTALLMENT)
			OR ( (Recinfo.REAMORTIZE_TO_INSTALLMENT IS NULL)
				AND (P_REAMORTIZE_TO_INSTALLMENT IS NULL)))
		AND ( (Recinfo.FEE_AMOUNT = P_FEE_AMOUNT)
			OR ( (Recinfo.FEE_AMOUNT IS NULL)
				AND (P_FEE_AMOUNT IS NULL)))
		AND ( (Recinfo.PRINCIPAL_TRX_ID = P_PRINCIPAL_TRX_ID)
			OR ( (Recinfo.PRINCIPAL_TRX_ID IS NULL)
				AND (P_PRINCIPAL_TRX_ID IS NULL)))
		AND ( (Recinfo.INTEREST_TRX_ID = P_INTEREST_TRX_ID)
			OR ( (Recinfo.INTEREST_TRX_ID IS NULL)
				AND (P_INTEREST_TRX_ID IS NULL)))
		AND ( (Recinfo.FEE_TRX_ID = P_FEE_TRX_ID)
			OR ( (Recinfo.FEE_TRX_ID IS NULL)
				AND (P_FEE_TRX_ID IS NULL)))
		AND ( (Recinfo.STATEMENT_XML = P_STATEMENT_XML)
			OR ( (Recinfo.STATEMENT_XML IS NULL)
				AND (P_STATEMENT_XML IS NULL)))
		AND ( (Recinfo.PRINCIPAL_BALANCE = P_PRINCIPAL_BALANCE)
			OR ( (Recinfo.PRINCIPAL_BALANCE IS NULL)
				AND (P_PRINCIPAL_BALANCE IS NULL)))
		AND ( (Recinfo.PHASE = P_PHASE)
			OR ( (Recinfo.PHASE IS NULL)
				AND (P_PHASE IS NULL)))
		AND ( (Recinfo.FUNDED_AMOUNT = P_FUNDED_AMOUNT)
			OR ( (Recinfo.FUNDED_AMOUNT IS NULL)
				AND (P_FUNDED_AMOUNT IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/
