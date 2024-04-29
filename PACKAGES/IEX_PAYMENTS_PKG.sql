--------------------------------------------------------
--  DDL for Package IEX_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_PAYMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: iextpays.pls 120.0 2004/01/24 03:22:26 appldev noship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(x_rowid	IN OUT NOCOPY VARCHAR2
	,p_PAYMENT_ID		NUMBER
	,p_OBJECT_VERSION_NUMBER		NUMBER
	,p_PROGRAM_ID		NUMBER	DEFAULT NULL
	,p_LAST_UPDATE_DATE		DATE
	,p_LAST_UPDATED_BY		NUMBER
	,p_LAST_UPDATE_LOGIN		NUMBER	DEFAULT NULL
	,p_CREATION_DATE		DATE
	,p_CREATED_BY		NUMBER
	,p_PAYMENT_METHOD_ID		NUMBER	DEFAULT NULL
	,p_PAYMENT_METHOD		VARCHAR2
	,p_IPAYMENT_TRANS_ID		VARCHAR2	DEFAULT NULL
	,p_IPAYMENT_STATUS		NUMBER	DEFAULT NULL
	,p_PAY_SVR_CONFIRMATION		VARCHAR2	DEFAULT NULL
	,p_CAMPAIGN_SCHED_ID		NUMBER	DEFAULT NULL
	,p_ATTRIBUTE_CATEGORY		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE1		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE2		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE3		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE4		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE5		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE6		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE7		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE8		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE9		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE10		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE11		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE12		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE13		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE14		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE15		VARCHAR2	DEFAULT NULL
	,p_TANGIBLE_ID		VARCHAR2	DEFAULT NULL
	,p_PAYEE_ID		VARCHAR2	DEFAULT NULL
	,p_RESOURCE_ID		NUMBER	DEFAULT NULL
);

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid	VARCHAR2
	,p_PAYMENT_ID		NUMBER
	,p_OBJECT_VERSION_NUMBER		NUMBER
	,p_PROGRAM_ID		NUMBER	DEFAULT NULL
	,p_LAST_UPDATE_DATE		DATE
	,p_LAST_UPDATED_BY		NUMBER
	,p_LAST_UPDATE_LOGIN		NUMBER	DEFAULT NULL
	,p_CREATION_DATE		DATE
	,p_CREATED_BY		NUMBER
	,p_PAYMENT_METHOD_ID		NUMBER	DEFAULT NULL
	,p_PAYMENT_METHOD		VARCHAR2
	,p_IPAYMENT_TRANS_ID		VARCHAR2	DEFAULT NULL
	,p_IPAYMENT_STATUS		NUMBER	DEFAULT NULL
	,p_PAY_SVR_CONFIRMATION		VARCHAR2	DEFAULT NULL
	,p_CAMPAIGN_SCHED_ID		NUMBER	DEFAULT NULL
	,p_ATTRIBUTE_CATEGORY		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE1		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE2		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE3		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE4		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE5		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE6		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE7		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE8		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE9		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE10		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE11		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE12		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE13		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE14		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE15		VARCHAR2	DEFAULT NULL
	,p_TANGIBLE_ID		VARCHAR2	DEFAULT NULL
	,p_PAYEE_ID		VARCHAR2	DEFAULT NULL
	,p_RESOURCE_ID		NUMBER	DEFAULT NULL
);

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid	VARCHAR2);

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid	VARCHAR2
	,p_PAYMENT_ID		NUMBER
	,p_OBJECT_VERSION_NUMBER		NUMBER
	,p_PROGRAM_ID		NUMBER	DEFAULT NULL
	,p_LAST_UPDATE_DATE		DATE
	,p_LAST_UPDATED_BY		NUMBER
	,p_LAST_UPDATE_LOGIN		NUMBER	DEFAULT NULL
	,p_CREATION_DATE		DATE
	,p_CREATED_BY		NUMBER
	,p_PAYMENT_METHOD_ID		NUMBER	DEFAULT NULL
	,p_PAYMENT_METHOD		VARCHAR2
	,p_IPAYMENT_TRANS_ID		VARCHAR2	DEFAULT NULL
	,p_IPAYMENT_STATUS		NUMBER	DEFAULT NULL
	,p_PAY_SVR_CONFIRMATION		VARCHAR2	DEFAULT NULL
	,p_CAMPAIGN_SCHED_ID		NUMBER	DEFAULT NULL
	,p_ATTRIBUTE_CATEGORY		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE1		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE2		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE3		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE4		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE5		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE6		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE7		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE8		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE9		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE10		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE11		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE12		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE13		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE14		VARCHAR2	DEFAULT NULL
	,p_ATTRIBUTE15		VARCHAR2	DEFAULT NULL
	,p_TANGIBLE_ID		VARCHAR2	DEFAULT NULL
	,p_PAYEE_ID		VARCHAR2	DEFAULT NULL
	,p_RESOURCE_ID		NUMBER	DEFAULT NULL
);
END;


 

/
