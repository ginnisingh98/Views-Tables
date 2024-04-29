--------------------------------------------------------
--  DDL for Package CN_SRP_PLAN_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PLAN_ASSIGNS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsrplas.pls 115.6 2002/11/21 21:08:13 hlchen ship $
--
-- Package Name
-- CN_SRP_PLAN_ASSIGNS_PKG
-- Purpose
--  Table Handler for CN_SRP_PLAN_ASSIGNS
--  FORM 	CNSRMT
--  BLOCK	SRP_PLAN_ASSIGNS
--
-- History
-- 06-Jun-99	Angela Chung	Created

-- -------------------------------------------------------------------------+
-- Procedure Name
--   INSERT_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE INSERT_ROW
  (X_SRP_PLAN_ASSIGN_ID IN OUT NOCOPY NUMBER,
   X_SRP_ROLE_ID IN NUMBER,
   X_ROLE_PLAN_ID IN NUMBER,
   X_SALESREP_ID IN NUMBER,
   X_ROLE_ID IN NUMBER,
   X_COMP_PLAN_ID IN NUMBER,
   X_START_DATE IN DATE,
   X_END_DATE IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2	:= NULL,
   X_ATTRIBUTE1 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE2 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE3 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE4 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE5 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE6 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE7 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE8 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE9 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE10 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE11 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE12 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE13 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE14 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE15 IN VARCHAR2	:= NULL,
   X_CREATED_BY IN NUMBER,
   X_CREATION_DATE IN DATE,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
   );

-- -------------------------------------------------------------------------+
-- Procedure Name
--   LOCK_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE LOCK_ROW
  (X_SRP_PLAN_ASSIGN_ID IN NUMBER,
   X_SRP_ROLE_ID IN NUMBER,
   X_ROLE_PLAN_ID IN NUMBER,
   X_SALESREP_ID IN NUMBER,
   X_ROLE_ID IN NUMBER,
   X_COMP_PLAN_ID IN NUMBER,
   X_START_DATE IN DATE,
   X_END_DATE IN DATE,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2	:= NULL,
   X_ATTRIBUTE1 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE2 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE3 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE4 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE5 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE6 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE7 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE8 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE9 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE10 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE11 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE12 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE13 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE14 IN VARCHAR2	:= NULL,
   X_ATTRIBUTE15 IN VARCHAR2	:= NULL
   );

-- -------------------------------------------------------------------------+
-- Procedure Name
--   UPDATE_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE UPDATE_ROW
  (X_SRP_PLAN_ASSIGN_ID IN NUMBER,
   X_SRP_ROLE_ID IN NUMBER   	:= fnd_api.g_miss_num,
   X_ROLE_PLAN_ID IN NUMBER   	:= fnd_api.g_miss_num,
   X_SALESREP_ID IN NUMBER   	:= fnd_api.g_miss_num,
   X_ROLE_ID IN NUMBER   	:= fnd_api.g_miss_num,
   X_COMP_PLAN_ID IN NUMBER   	:= fnd_api.g_miss_num,
   X_START_DATE IN DATE		:= fnd_api.g_miss_date,
   X_END_DATE IN DATE		:= fnd_api.g_miss_date,
   X_ATTRIBUTE_CATEGORY IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE1 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE2 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE3 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE4 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE5 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE6 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE7 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE8 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE9 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE10 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE11 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE12 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE13 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE14 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_ATTRIBUTE15 IN VARCHAR2	:= fnd_api.g_miss_char,
   X_LAST_UPDATE_DATE IN DATE,
   X_LAST_UPDATED_BY IN NUMBER,
   X_LAST_UPDATE_LOGIN IN NUMBER
   );

-- -------------------------------------------------------------------------+
-- Procedure Name
--   DELETE_ROW
-- Purpose
--
-- History
--
-- -------------------------------------------------------------------------+
PROCEDURE DELETE_ROW (X_SRP_PLAN_ASSIGN_ID IN NUMBER);

END CN_SRP_PLAN_ASSIGNS_PKG;

 

/
