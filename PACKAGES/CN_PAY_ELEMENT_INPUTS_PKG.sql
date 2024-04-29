--------------------------------------------------------
--  DDL for Package CN_PAY_ELEMENT_INPUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAY_ELEMENT_INPUTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cntpeis.pls 115.3 2002/02/05 00:26:03 pkm ship      $ */
--
-- Package Name
-- CN_PAY_ELEMENT_INPUTS_PKG
-- Purpose
--  Table Handler for CN_PAY_ELEMENT_INPUTS
--
-- History
-- 02-feb-01	Kumar Sivasankaran	Created
-- 23-Mar-01    Kumar Sivasankaran      Added couple of parameters
--
--==========================================================================
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
--==========================================================================

PROCEDURE insert_row
   (x_pay_element_input_id      IN OUT NUMBER
    ,p_quota_pay_element_id     IN NUMBER
    ,p_element_input_id         IN NUMBER
    ,p_element_type_id	        IN NUMBER
    ,p_tab_object_id            IN NUMBER
    ,p_col_object_id            IN NUMBER
    ,p_line_number		IN NUMBER
    ,p_start_date	        in DATE
    ,p_end_date			IN DATE
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

--==========================================================================

-- Procedure Name
--	Lock_row
-- Purpose
--    Lock db row after form record is changed
-- Notes
--==========================================================================

PROCEDURE lock_row
   (p_pay_element_input_id      IN  NUMBER
    ,p_quota_pay_element_id     IN NUMBER
    ,p_element_input_id         IN NUMBER
    ,p_element_type_id          IN NUMBER
    ,p_tab_object_id            IN NUMBER
    ,p_col_object_id            IN NUMBER
    ,p_line_number		IN NUMBER
    ,p_start_date		IN DATE
    ,p_end_date			IN DATE
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

--==========================================================================
-- Procedure Name
--   Update Record
-- Purpose
--   To Update the Quota Pay Element inputs
--
--==========================================================================
PROCEDURE update_row (
     p_pay_element_input_id     NUMBER
    ,p_quota_pay_element_id     NUMBER		:= fnd_api.g_miss_num
    ,p_element_input_id         NUMBER   	:= fnd_api.g_miss_num
    ,p_element_type_id          NUMBER   	:= fnd_api.g_miss_num
    ,p_tab_object_id            NUMBER   	:= fnd_api.g_miss_num
    ,p_col_object_id            NUMBER   	:= fnd_api.g_miss_num
    ,p_line_number		NUMBER		:= fnd_api.g_miss_num
    ,p_start_date		DATE		:= fnd_api.g_miss_date
    ,p_end_date			DATE 		:= fnd_api.g_miss_date
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

--==========================================================================
-- Procedure Name
--	Delete_row
-- Purpose
--    Delete the  Pay Element inputs
--==========================================================================
PROCEDURE Delete_row( p_pay_element_input_id     NUMBER );

END CN_PAY_ELEMENT_INPUTS_PKG;

 

/
