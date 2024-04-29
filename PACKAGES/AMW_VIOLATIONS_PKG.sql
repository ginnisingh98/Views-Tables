--------------------------------------------------------
--  DDL for Package AMW_VIOLATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_VIOLATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtvlas.pls 120.1 2005/06/23 11:39:07 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_VIOLATIONS_PKG
-- Purpose
--
-- History
-- 		  	11/11/2003    tsho     Creates
--          05/20/2005    tsho     AMW.E add reval_request_id,reval_request_date, reval_requested_by_id
-- ===============================================================


-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new violation
-- History
--          05.20.2005 tsho: AMW.E add reval_request_id,reval_request_date, reval_requested_by_id
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_VIOLATION_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_REQUEST_DATE in DATE,
  X_REQUESTED_BY_ID in NUMBER,
  X_VIOLATOR_NUM in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2  := NULL,
  X_ATTRIBUTE1 in VARCHAR2          := NULL,
  X_ATTRIBUTE2 in VARCHAR2          := NULL,
  X_ATTRIBUTE3 in VARCHAR2          := NULL,
  X_ATTRIBUTE4 in VARCHAR2          := NULL,
  X_ATTRIBUTE5 in VARCHAR2          := NULL,
  X_ATTRIBUTE6 in VARCHAR2          := NULL,
  X_ATTRIBUTE7 in VARCHAR2          := NULL,
  X_ATTRIBUTE8 in VARCHAR2          := NULL,
  X_ATTRIBUTE9 in VARCHAR2          := NULL,
  X_ATTRIBUTE10 in VARCHAR2         := NULL,
  X_ATTRIBUTE11 in VARCHAR2         := NULL,
  X_ATTRIBUTE12 in VARCHAR2         := NULL,
  X_ATTRIBUTE13 in VARCHAR2         := NULL,
  X_ATTRIBUTE14 in VARCHAR2         := NULL,
  X_ATTRIBUTE15 in VARCHAR2         := NULL,
  X_REVAL_REQUEST_ID         in NUMBER  := NULL,
  X_REVAL_REQUEST_DATE       in DATE    := NULL,
  X_REVAL_REQUESTED_BY_ID    in NUMBER  := NULL
);



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- ===============================================================
procedure LOCK_ROW (
  X_VIOLATION_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_REQUEST_DATE in DATE,
  X_REQUESTED_BY_ID in NUMBER,
  X_VIOLATOR_NUM in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_REVAL_REQUEST_ID         in NUMBER  := NULL,
  X_REVAL_REQUEST_DATE       in DATE    := NULL,
  X_REVAL_REQUESTED_BY_ID    in NUMBER  := NULL
);



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
-- 		  	update AMW_VIOLATIONS
-- History
--          05.20.2005 tsho: AMW.E add reval_request_id,reval_request_date, reval_requested_by_id
-- ===============================================================
procedure UPDATE_ROW (
  X_VIOLATION_ID in NUMBER,
  X_CONSTRAINT_REV_ID in NUMBER,
  X_VIOLATOR_NUM in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2      := NULL,
  X_ATTRIBUTE1 in VARCHAR2              := NULL,
  X_ATTRIBUTE2 in VARCHAR2              := NULL,
  X_ATTRIBUTE3 in VARCHAR2              := NULL,
  X_ATTRIBUTE4 in VARCHAR2              := NULL,
  X_ATTRIBUTE5 in VARCHAR2              := NULL,
  X_ATTRIBUTE6 in VARCHAR2              := NULL,
  X_ATTRIBUTE7 in VARCHAR2              := NULL,
  X_ATTRIBUTE8 in VARCHAR2              := NULL,
  X_ATTRIBUTE9 in VARCHAR2              := NULL,
  X_ATTRIBUTE10 in VARCHAR2             := NULL,
  X_ATTRIBUTE11 in VARCHAR2             := NULL,
  X_ATTRIBUTE12 in VARCHAR2             := NULL,
  X_ATTRIBUTE13 in VARCHAR2             := NULL,
  X_ATTRIBUTE14 in VARCHAR2             := NULL,
  X_ATTRIBUTE15 in VARCHAR2             := NULL,
  X_REVAL_REQUEST_ID         in NUMBER  := NULL,
  X_REVAL_REQUEST_DATE       in DATE    := NULL,
  X_REVAL_REQUESTED_BY_ID    in NUMBER  := NULL
);


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_VIOLATION_ID in NUMBER
);




-- ----------------------------------------------------------------------
end AMW_VIOLATIONS_PKG;


 

/
