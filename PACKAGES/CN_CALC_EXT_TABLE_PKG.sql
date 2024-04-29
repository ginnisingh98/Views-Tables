--------------------------------------------------------
--  DDL for Package CN_CALC_EXT_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_EXT_TABLE_PKG" AUTHID CURRENT_USER AS
/* $Header: cntextts.pls 115.5 2002/11/21 21:09:26 hlchen ship $ */
--
-- Package Name
-- CN_CALC_EXT_TABLE_PKG
-- Purpose
--  Table Handler for CN_CALC_EXT_TABLE
--
-- History
-- 02-feb-01	Kumar Sivasankaran	Created

--==========================================================================
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
--==========================================================================

PROCEDURE insert_row
   (x_calc_ext_table_id  IN OUT NOCOPY NUMBER
    ,p_name                 VARCHAR2 := NULL
    ,p_description          VARCHAR2 := NULL
    ,p_internal_table_id    NUMBER := NULL
    ,p_external_table_id        NUMBER := NULL
    ,P_USED_FLAG	        VARCHAR2   := NULL
    ,P_SCHEMA 		        VARCHAR2   := NULL
    ,P_EXTERNAL_TABLE_NAME      VARCHAR2   := NULL
    ,P_ALIAS		        VARCHAR2   := NULL
    ,p_attribute_category       VARCHAR2	:= NULL
    ,p_attribute1               VARCHAR2	:= NULL
    ,p_attribute2               VARCHAR2	:= NULL
    ,p_attribute3               VARCHAR2	:= NULL
    ,p_attribute4               VARCHAR2	:= NULL
    ,p_attribute5               VARCHAR2	:= NULL
    ,p_attribute6               VARCHAR2	:= NULL
    ,p_attribute7               VARCHAR2	:= NULL
    ,p_attribute8               VARCHAR2        := NULL
    ,p_attribute9               VARCHAR2	:= NULL
    ,p_attribute10              VARCHAR2	:= NULL
    ,p_attribute11              VARCHAR2	:= NULL
    ,p_attribute12              VARCHAR2	:= NULL
    ,p_attribute13              VARCHAR2	:= NULL
    ,p_attribute14              VARCHAR2	:= NULL
    ,p_attribute15              VARCHAR2	:= NULL
    ,p_Created_By               NUMBER
    ,p_Creation_Date            DATE
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--	Lock_row
-- Purpose
--    Lock db row after form record is changed
-- Notes
-- *-------------------------------------------------------------------------*/

PROCEDURE lock_row
   (p_calc_ext_table_id     NUMBER
    ,p_name                 VARCHAR2 := NULL
    ,P_DESCRIPTION          VARCHAR2 := NULL
    ,P_INTERNAL_TABLE_ID    NUMBER := NULL
    ,P_EXTERNAL_TABLE_ID    NUMBER := NULL
    ,P_USED_FLAG	    VARCHAR2   := NULL
    ,P_SCHEMA 		    VARCHAR2   := NULL
    ,P_EXTERNAL_TABLE_NAME  VARCHAR2   := NULL
    ,P_ALIAS		    VARCHAR2   := NULL
    ,p_attribute_category       VARCHAR2	:= NULL
    ,p_attribute1               VARCHAR2	:= NULL
    ,p_attribute2               VARCHAR2	:= NULL
    ,p_attribute3               VARCHAR2	:= NULL
    ,p_attribute4               VARCHAR2	:= NULL
    ,p_attribute5               VARCHAR2	:= NULL
    ,p_attribute6               VARCHAR2	:= NULL
    ,p_attribute7               VARCHAR2	:= NULL
    ,p_attribute8               VARCHAR2        := NULL
    ,p_attribute9               VARCHAR2	:= NULL
    ,p_attribute10              VARCHAR2	:= NULL
    ,p_attribute11              VARCHAR2	:= NULL
    ,p_attribute12              VARCHAR2	:= NULL
    ,p_attribute13              VARCHAR2	:= NULL
    ,p_attribute14              VARCHAR2	:= NULL
    ,p_attribute15              VARCHAR2	:= NULL
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--   Update Record
-- Purpose
--
-- *-------------------------------------------------------------------------*/
PROCEDURE update_row (
    p_calc_ext_table_id        NUMBER	:= fnd_api.g_miss_num
    ,p_name                     VARCHAR2    := fnd_api.g_miss_char
    ,P_DESCRIPTION              VARCHAR2    := fnd_api.g_miss_char
    ,P_INTERNAL_TABLE_ID        NUMBER := fnd_api.g_miss_num
    ,P_EXTERNAL_TABLE_ID        NUMBER := fnd_api.g_miss_num
    ,P_USED_FLAG	        VARCHAR2   := fnd_api.g_miss_char
    ,P_SCHEMA 		        VARCHAR2   := fnd_api.g_miss_char
    ,P_EXTERNAL_TABLE_NAME      VARCHAR2   := fnd_api.g_miss_char
    ,P_ALIAS		        VARCHAR2   := fnd_api.g_miss_char
    ,p_attribute_category       VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute1               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute2               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute3               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute4               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute5               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute6               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute7               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute8               VARCHAR2       	:= fnd_api.g_miss_char
    ,p_attribute9               VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute10              VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute11              VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute12              VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute13              VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute14              VARCHAR2	:= fnd_api.g_miss_char
    ,p_attribute15              VARCHAR2	:= fnd_api.g_miss_char
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER );

--/*-------------------------------------------------------------------------*
-- Procedure Name
--	Delete_row
-- Purpose
--*-------------------------------------------------------------------------*/
PROCEDURE Delete_row( p_calc_ext_table_id     NUMBER );

END CN_CALC_EXT_TABLE_PKG;

 

/
