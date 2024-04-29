--------------------------------------------------------
--  DDL for Package AMW_VIOLATION_USERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_VIOLATION_USERS_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtvlus.pls 120.1.12000000.1 2007/01/16 20:43:32 appldev ship $ */

-- ===============================================================
-- Package name
--          AMW_VIOLATION_USERS_PKG
-- Purpose
--
-- History
-- 		  	11/11/2003    tsho     Creates
--          01/06/2005    tsho     for new column WAIVED_FLAG
--          05/23/2005    tsho     AMW.E add corrected_flag
-- ===============================================================


-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new violation
-- History
--          05/23/2005    tsho     AMW.E add corrected_flag
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_USER_VIOLATION_ID in NUMBER,
  X_VIOLATION_ID in NUMBER,
  X_VIOLATED_BY_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_WAIVED_FLAG in VARCHAR2 := NULL,
  X_CORRECTED_FLAG in VARCHAR2 := NULL
);



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- History
--          05/23/2005    tsho     AMW.E add corrected_flag
-- ===============================================================
procedure LOCK_ROW (
  X_USER_VIOLATION_ID in NUMBER,
  X_VIOLATION_ID in NUMBER,
  X_VIOLATED_BY_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_WAIVED_FLAG in VARCHAR2 := NULL,
  X_CORRECTED_FLAG in VARCHAR2 := NULL
);



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
-- 		  	update AMW_VIOLATION_USERS
-- History
--          05/23/2005    tsho     AMW.E add corrected_flag
-- ===============================================================
procedure UPDATE_ROW (
  X_USER_VIOLATION_ID in NUMBER,
  X_VIOLATION_ID in NUMBER,
  X_VIOLATED_BY_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_WAIVED_FLAG in VARCHAR2 := NULL,
  X_CORRECTED_FLAG in VARCHAR2 := NULL
);


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_USER_VIOLATION_ID in NUMBER
);




-- ----------------------------------------------------------------------
end AMW_VIOLATION_USERS_PKG;

 

/
