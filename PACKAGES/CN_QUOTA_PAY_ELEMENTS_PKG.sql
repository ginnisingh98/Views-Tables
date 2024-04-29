--------------------------------------------------------
--  DDL for Package CN_QUOTA_PAY_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_PAY_ELEMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntqpes.pls 115.2 2002/02/05 00:26:06 pkm ship      $ */
--
-- Package Name
-- CN_QUOTA_PAY_ELEMENTS_PKG
-- Purpose
--  Table Handler for CN_QUOTA_PAY_ELEMENTS
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
   (x_quota_pay_element_id  IN OUT NUMBER
    ,p_quota_id                 IN NUMBER
    ,p_pay_element_type_id      IN NUMBER
    ,p_status                   VARCHAR2  := NULL
    ,p_start_date	        DATE
    ,p_end_date	                DATE
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
   (p_quota_pay_element_id      IN  NUMBER
    ,p_quota_id                 IN NUMBER
    ,p_pay_element_type_id      IN NUMBER
    ,p_status                   VARCHAR2  := NULL
    ,p_start_date	        DATE
    ,p_end_date	                DATE
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
--   To Update the Quota Pay Element Map
--
-- *-------------------------------------------------------------------------*/
PROCEDURE update_row (
     p_quota_pay_element_id     NUMBER
    ,p_quota_id                 NUMBER   	:= fnd_api.g_miss_num
    ,p_pay_element_type_id      NUMBER   	:= fnd_api.g_miss_num
    ,p_status                   VARCHAR2   	:= fnd_api.g_miss_char
    ,p_start_date		DATE		:= fnd_api.g_miss_date
    ,p_end_date		        DATE		:= fnd_api.g_miss_date
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
--    Delete the  Quota Pay Element
--*-------------------------------------------------------------------------*/
PROCEDURE Delete_row( p_quota_pay_element_id     NUMBER );

END CN_QUOTA_PAY_ELEMENTS_PKG;

 

/
