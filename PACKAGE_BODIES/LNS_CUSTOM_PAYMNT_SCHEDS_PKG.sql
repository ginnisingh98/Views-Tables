--------------------------------------------------------
--  DDL for Package Body LNS_CUSTOM_PAYMNT_SCHEDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_CUSTOM_PAYMNT_SCHEDS_PKG" AS
/* $Header: LNS_CUST_TBLH_B.pls 120.0.12010000.2 2008/09/16 16:52:58 gparuchu ship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(
	X_CUSTOM_SCHEDULE_ID		IN OUT NOCOPY NUMBER
	,P_LOAN_ID		IN NUMBER
	,P_PAYMENT_NUMBER		IN NUMBER	DEFAULT NULL
	,P_DUE_DATE		IN DATE	DEFAULT NULL
	,P_PRINCIPAL_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_INTEREST_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_PRINCIPAL_PAID_TODATE		IN NUMBER	DEFAULT NULL
	,P_INTEREST_PAID_TODATE		IN NUMBER	DEFAULT NULL
	,P_OTHER_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_INSTALLMENT_BEGIN_BALANCE		IN NUMBER	DEFAULT NULL
	,P_INSTALLMENT_END_BALANCE		IN NUMBER	DEFAULT NULL
	,P_CURRENT_TERM_PAYMENT		IN NUMBER	DEFAULT NULL
	,P_CREATED_BY		IN NUMBER	DEFAULT NULL
	,P_CREATION_DATE		IN DATE	DEFAULT NULL
	,P_LAST_UPDATED_BY		IN NUMBER	DEFAULT NULL
	,P_LAST_UPDATE_DATE		IN DATE	DEFAULT NULL
	,P_LAST_UPDATE_LOGIN		IN NUMBER	DEFAULT NULL
	,P_ATTRIBUTE_CATEGORY		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE1		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE2		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE3		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE4		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE5		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE6		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE7		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE8		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE9		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE10		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE11		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE12		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE13		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE14		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE15		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE16		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE17		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE18		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE19		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE20		IN VARCHAR2	DEFAULT NULL
	,P_OBJECT_VERSION_NUMBER		IN NUMBER	DEFAULT NULL
	,P_FEE_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_LOCK_PRIN		IN VARCHAR2 DEFAULT NULL
	,P_LOCK_INT  		IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
	INSERT INTO LNS_CUSTOM_PAYMNT_SCHEDS
	(
		CUSTOM_SCHEDULE_ID
		,LOAN_ID
		,PAYMENT_NUMBER
		,DUE_DATE
		,PRINCIPAL_AMOUNT
		,INTEREST_AMOUNT
		,PRINCIPAL_PAID_TODATE
		,INTEREST_PAID_TODATE
		,OTHER_AMOUNT
		,INSTALLMENT_BEGIN_BALANCE
		,INSTALLMENT_END_BALANCE
		,CURRENT_TERM_PAYMENT
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
		,FEE_AMOUNT
		,LOCK_PRIN
		,LOCK_INT
	) VALUES (
		DECODE(X_CUSTOM_SCHEDULE_ID, FND_API.G_MISS_NUM, LNS_CUSTOM_PAYMNT_SCHEDS_S.NEXTVAL, NULL, LNS_CUSTOM_PAYMNT_SCHEDS_S.NEXTVAL, X_CUSTOM_SCHEDULE_ID)
		,DECODE(P_LOAN_ID, FND_API.G_MISS_NUM, NULL, P_LOAN_ID)
		,DECODE(P_PAYMENT_NUMBER, FND_API.G_MISS_NUM, NULL, P_PAYMENT_NUMBER)
		,DECODE(P_DUE_DATE, FND_API.G_MISS_DATE, NULL, P_DUE_DATE)
		,DECODE(P_PRINCIPAL_AMOUNT, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_AMOUNT)
		,DECODE(P_INTEREST_AMOUNT, FND_API.G_MISS_NUM, NULL, P_INTEREST_AMOUNT)
		,DECODE(P_PRINCIPAL_PAID_TODATE, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_PAID_TODATE)
		,DECODE(P_INTEREST_PAID_TODATE, FND_API.G_MISS_NUM, NULL, P_INTEREST_PAID_TODATE)
		,DECODE(P_OTHER_AMOUNT, FND_API.G_MISS_NUM, NULL, P_OTHER_AMOUNT)
		,DECODE(P_INSTALLMENT_BEGIN_BALANCE, FND_API.G_MISS_NUM, NULL, P_INSTALLMENT_BEGIN_BALANCE)
		,DECODE(P_INSTALLMENT_END_BALANCE, FND_API.G_MISS_NUM, NULL, P_INSTALLMENT_END_BALANCE)
		,DECODE(P_CURRENT_TERM_PAYMENT, FND_API.G_MISS_NUM, NULL, P_CURRENT_TERM_PAYMENT)
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
		,DECODE(P_FEE_AMOUNT, FND_API.G_MISS_NUM, NULL, P_FEE_AMOUNT)
		,DECODE(P_LOCK_PRIN, FND_API.G_MISS_CHAR, NULL, P_LOCK_PRIN)
		,DECODE(P_LOCK_INT, FND_API.G_MISS_CHAR, NULL, P_LOCK_INT)
	) RETURNING
		 CUSTOM_SCHEDULE_ID
	 INTO
		 X_CUSTOM_SCHEDULE_ID;
END Insert_Row;

/* Update_Row procedure */
PROCEDURE Update_Row(
	P_CUSTOM_SCHEDULE_ID		IN NUMBER
	,P_LOAN_ID		IN NUMBER	DEFAULT NULL
	,P_PAYMENT_NUMBER		IN NUMBER	DEFAULT NULL
	,P_DUE_DATE		IN DATE	DEFAULT NULL
	,P_PRINCIPAL_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_INTEREST_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_PRINCIPAL_PAID_TODATE		IN NUMBER	DEFAULT NULL
	,P_INTEREST_PAID_TODATE		IN NUMBER	DEFAULT NULL
	,P_OTHER_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_INSTALLMENT_BEGIN_BALANCE		IN NUMBER	DEFAULT NULL
	,P_INSTALLMENT_END_BALANCE		IN NUMBER	DEFAULT NULL
	,P_CURRENT_TERM_PAYMENT		IN NUMBER	DEFAULT NULL
	,P_LAST_UPDATED_BY		IN NUMBER	DEFAULT NULL
	,P_LAST_UPDATE_DATE		IN DATE	DEFAULT NULL
	,P_LAST_UPDATE_LOGIN		IN NUMBER	DEFAULT NULL
	,P_ATTRIBUTE_CATEGORY		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE1		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE2		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE3		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE4		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE5		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE6		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE7		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE8		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE9		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE10		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE11		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE12		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE13		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE14		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE15		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE16		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE17		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE18		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE19		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE20		IN VARCHAR2	DEFAULT NULL
	,P_OBJECT_VERSION_NUMBER		IN NUMBER	DEFAULT NULL
	,P_FEE_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_LOCK_PRIN		IN VARCHAR2 DEFAULT NULL
	,P_LOCK_INT  		IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
	UPDATE LNS_CUSTOM_PAYMNT_SCHEDS SET
		LOAN_ID = DECODE(P_LOAN_ID, NULL, LOAN_ID, FND_API.G_MISS_NUM, NULL, P_LOAN_ID)
		,PAYMENT_NUMBER = DECODE(P_PAYMENT_NUMBER, NULL, PAYMENT_NUMBER, FND_API.G_MISS_NUM, NULL, P_PAYMENT_NUMBER)
		,DUE_DATE = DECODE(P_DUE_DATE, NULL, DUE_DATE, FND_API.G_MISS_DATE, NULL, P_DUE_DATE)
		,PRINCIPAL_AMOUNT = DECODE(P_PRINCIPAL_AMOUNT, NULL, PRINCIPAL_AMOUNT, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_AMOUNT)
		,INTEREST_AMOUNT = DECODE(P_INTEREST_AMOUNT, NULL, INTEREST_AMOUNT, FND_API.G_MISS_NUM, NULL, P_INTEREST_AMOUNT)
		,PRINCIPAL_PAID_TODATE = DECODE(P_PRINCIPAL_PAID_TODATE, NULL, PRINCIPAL_PAID_TODATE, FND_API.G_MISS_NUM, NULL, P_PRINCIPAL_PAID_TODATE)
		,INTEREST_PAID_TODATE = DECODE(P_INTEREST_PAID_TODATE, NULL, INTEREST_PAID_TODATE, FND_API.G_MISS_NUM, NULL, P_INTEREST_PAID_TODATE)
		,OTHER_AMOUNT = DECODE(P_OTHER_AMOUNT, NULL, OTHER_AMOUNT, FND_API.G_MISS_NUM, NULL, P_OTHER_AMOUNT)
		,INSTALLMENT_BEGIN_BALANCE = DECODE(P_INSTALLMENT_BEGIN_BALANCE, NULL, INSTALLMENT_BEGIN_BALANCE, FND_API.G_MISS_NUM, NULL, P_INSTALLMENT_BEGIN_BALANCE)
		,INSTALLMENT_END_BALANCE = DECODE(P_INSTALLMENT_END_BALANCE, NULL, INSTALLMENT_END_BALANCE, FND_API.G_MISS_NUM, NULL, P_INSTALLMENT_END_BALANCE)
		,CURRENT_TERM_PAYMENT = DECODE(P_CURRENT_TERM_PAYMENT, NULL, CURRENT_TERM_PAYMENT, FND_API.G_MISS_NUM, NULL, P_CURRENT_TERM_PAYMENT)
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
		,FEE_AMOUNT = DECODE(P_FEE_AMOUNT, NULL, FEE_AMOUNT, FND_API.G_MISS_NUM, NULL, P_FEE_AMOUNT)
		,LOCK_PRIN = DECODE(P_LOCK_PRIN, NULL, LOCK_PRIN, FND_API.G_MISS_CHAR, NULL, P_LOCK_PRIN)
		,LOCK_INT = DECODE(P_LOCK_INT, NULL, LOCK_INT, FND_API.G_MISS_CHAR, NULL, P_LOCK_INT)
	 WHERE CUSTOM_SCHEDULE_ID = P_CUSTOM_SCHEDULE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Update_Row;

/* Delete_Row procedure */
PROCEDURE Delete_Row(P_CUSTOM_SCHEDULE_ID IN NUMBER) IS
BEGIN
	DELETE FROM LNS_CUSTOM_PAYMNT_SCHEDS
		WHERE CUSTOM_SCHEDULE_ID = P_CUSTOM_SCHEDULE_ID;

	if (sql%notfound) then
		raise no_data_found;
	end if;
END Delete_Row;

/* Lock_Row procedure */
PROCEDURE Lock_Row(
	P_CUSTOM_SCHEDULE_ID		IN NUMBER
	,P_LOAN_ID		IN NUMBER	DEFAULT NULL
	,P_PAYMENT_NUMBER		IN NUMBER	DEFAULT NULL
	,P_DUE_DATE		IN DATE	DEFAULT NULL
	,P_PRINCIPAL_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_INTEREST_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_PRINCIPAL_PAID_TODATE		IN NUMBER	DEFAULT NULL
	,P_INTEREST_PAID_TODATE		IN NUMBER	DEFAULT NULL
	,P_OTHER_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_INSTALLMENT_BEGIN_BALANCE		IN NUMBER	DEFAULT NULL
	,P_INSTALLMENT_END_BALANCE		IN NUMBER	DEFAULT NULL
	,P_CURRENT_TERM_PAYMENT		IN NUMBER	DEFAULT NULL
	,P_CREATED_BY		IN NUMBER	DEFAULT NULL
	,P_CREATION_DATE		IN DATE	DEFAULT NULL
	,P_LAST_UPDATED_BY		IN NUMBER	DEFAULT NULL
	,P_LAST_UPDATE_DATE		IN DATE	DEFAULT NULL
	,P_LAST_UPDATE_LOGIN		IN NUMBER	DEFAULT NULL
	,P_ATTRIBUTE_CATEGORY		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE1		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE2		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE3		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE4		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE5		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE6		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE7		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE8		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE9		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE10		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE11		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE12		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE13		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE14		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE15		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE16		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE17		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE18		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE19		IN VARCHAR2	DEFAULT NULL
	,P_ATTRIBUTE20		IN VARCHAR2	DEFAULT NULL
	,P_OBJECT_VERSION_NUMBER		IN NUMBER	DEFAULT NULL
	,P_FEE_AMOUNT		IN NUMBER	DEFAULT NULL
	,P_LOCK_PRIN		IN VARCHAR2 DEFAULT NULL
	,P_LOCK_INT  		IN VARCHAR2 DEFAULT NULL
) IS
	CURSOR C IS SELECT * FROM LNS_CUSTOM_PAYMNT_SCHEDS
		WHERE CUSTOM_SCHEDULE_ID = P_CUSTOM_SCHEDULE_ID
		FOR UPDATE of CUSTOM_SCHEDULE_ID NOWAIT;
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
		(Recinfo.CUSTOM_SCHEDULE_ID = P_CUSTOM_SCHEDULE_ID)
		AND ( (Recinfo.LOAN_ID = P_LOAN_ID)
			OR ( (Recinfo.LOAN_ID IS NULL)
				AND (P_LOAN_ID IS NULL)))
		AND ( (Recinfo.PAYMENT_NUMBER = P_PAYMENT_NUMBER)
			OR ( (Recinfo.PAYMENT_NUMBER IS NULL)
				AND (P_PAYMENT_NUMBER IS NULL)))
		AND ( (Recinfo.DUE_DATE = P_DUE_DATE)
			OR ( (Recinfo.DUE_DATE IS NULL)
				AND (P_DUE_DATE IS NULL)))
		AND ( (Recinfo.PRINCIPAL_AMOUNT = P_PRINCIPAL_AMOUNT)
			OR ( (Recinfo.PRINCIPAL_AMOUNT IS NULL)
				AND (P_PRINCIPAL_AMOUNT IS NULL)))
		AND ( (Recinfo.INTEREST_AMOUNT = P_INTEREST_AMOUNT)
			OR ( (Recinfo.INTEREST_AMOUNT IS NULL)
				AND (P_INTEREST_AMOUNT IS NULL)))
		AND ( (Recinfo.PRINCIPAL_PAID_TODATE = P_PRINCIPAL_PAID_TODATE)
			OR ( (Recinfo.PRINCIPAL_PAID_TODATE IS NULL)
				AND (P_PRINCIPAL_PAID_TODATE IS NULL)))
		AND ( (Recinfo.INTEREST_PAID_TODATE = P_INTEREST_PAID_TODATE)
			OR ( (Recinfo.INTEREST_PAID_TODATE IS NULL)
				AND (P_INTEREST_PAID_TODATE IS NULL)))
		AND ( (Recinfo.OTHER_AMOUNT = P_OTHER_AMOUNT)
			OR ( (Recinfo.OTHER_AMOUNT IS NULL)
				AND (P_OTHER_AMOUNT IS NULL)))
		AND ( (Recinfo.INSTALLMENT_BEGIN_BALANCE = P_INSTALLMENT_BEGIN_BALANCE)
			OR ( (Recinfo.INSTALLMENT_BEGIN_BALANCE IS NULL)
				AND (P_INSTALLMENT_BEGIN_BALANCE IS NULL)))
		AND ( (Recinfo.INSTALLMENT_END_BALANCE = P_INSTALLMENT_END_BALANCE)
			OR ( (Recinfo.INSTALLMENT_END_BALANCE IS NULL)
				AND (P_INSTALLMENT_END_BALANCE IS NULL)))
		AND ( (Recinfo.CURRENT_TERM_PAYMENT = P_CURRENT_TERM_PAYMENT)
			OR ( (Recinfo.CURRENT_TERM_PAYMENT IS NULL)
				AND (P_CURRENT_TERM_PAYMENT IS NULL)))
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
		AND ( (Recinfo.FEE_AMOUNT = P_FEE_AMOUNT)
			OR ( (Recinfo.FEE_AMOUNT IS NULL)
				AND (P_FEE_AMOUNT IS NULL)))
		AND ( (Recinfo.LOCK_PRIN = P_LOCK_PRIN)
			OR ( (Recinfo.LOCK_PRIN IS NULL)
				AND (P_LOCK_PRIN IS NULL)))
		AND ( (Recinfo.LOCK_INT = P_LOCK_INT)
			OR ( (Recinfo.LOCK_INT IS NULL)
				AND (P_LOCK_INT IS NULL)))
	   ) THEN
		return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;
END;


/