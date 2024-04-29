--------------------------------------------------------
--  DDL for Package PSA_MF_MISC_DIST_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MF_MISC_DIST_ALL_PKG" AUTHID CURRENT_USER as
 /* $Header: PSAMFMTS.pls 120.4 2006/09/13 13:14:22 agovil ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN NUMBER
  );
procedure UPDATE_ROW (
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MISC_MF_CASH_DIST_ID in NUMBER,
  X_MISC_CASH_DISTRIBUTION_ID in NUMBER,
  X_DISTRIBUTION_CCID in NUMBER,
  X_CASH_CCID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_POSTING_CONTROL_ID in NUMBER,
  X_GL_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REFERENCE1 in VARCHAR2,
  X_REFERENCE2 in DATE,
  X_REFERENCE3 in DATE,
  X_REFERENCE4 in VARCHAR2,
  X_REFERENCE5 in VARCHAR2,
  x_reversal_ccid IN NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
		      X_MISC_MF_CASH_DIST_ID in NUMBER,
		      x_reference1 IN varchar2
);
end PSA_MF_MISC_DIST_ALL_PKG;

 

/