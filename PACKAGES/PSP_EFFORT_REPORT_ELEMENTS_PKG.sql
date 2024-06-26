--------------------------------------------------------
--  DDL for Package PSP_EFFORT_REPORT_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFFORT_REPORT_ELEMENTS_PKG" AUTHID CURRENT_USER as
 /* $Header: PSPSUEFS.pls 115.11 2003/09/08 16:11:02 spchakra ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_USE_IN_EFFORT_REPORT in VARCHAR2,
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
  X_BASE_NON_BASE_COMP_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_BUSINESS_GROUP_ID IN NUMBER,	-- Introduced for bug fix 3098050
  X_SET_OF_BOOKS_ID IN NUMBER		-- Introduced for bug fix 3098050
  );
procedure LOCK_ROW (
  X_ELEMENT_TYPE_ID in NUMBER,
  X_USE_IN_EFFORT_REPORT in VARCHAR2,
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
  X_BASE_NON_BASE_COMP_FLAG in VARCHAR2,
  X_BUSINESS_GROUP_ID IN NUMBER,	-- Introduced for bug fix 3098050
  X_SET_OF_BOOKS_ID IN NUMBEr		-- Introduced for bug fix 3098050
);
procedure UPDATE_ROW (
  X_ELEMENT_TYPE_ID in NUMBER,
  X_USE_IN_EFFORT_REPORT in VARCHAR2,
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
  X_BASE_NON_BASE_COMP_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_BUSINESS_GROUP_ID IN NUMBER,	-- Introduced for bug fix 3098050
  X_SET_OF_BOOKS_ID IN NUMBER		-- Introduced for bug fix 3098050
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ELEMENT_TYPE_ID in NUMBER,
  X_USE_IN_EFFORT_REPORT in VARCHAR2,
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
  X_BASE_NON_BASE_COMP_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_BUSINESS_GROUP_ID IN NUMBER,	-- Introduced for bug fix 3098050
  X_SET_OF_BOOKS_ID IN NUMBER		-- Introduced for bug fix 3098050
  );
procedure DELETE_ROW (
  X_ELEMENT_TYPE_ID in NUMBER
);
end PSP_EFFORT_REPORT_ELEMENTS_PKG;

 

/
