--------------------------------------------------------
--  DDL for Package AK_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CUSTOM_PUB" AUTHID CURRENT_USER as
/* $Header: akdpcres.pls 115.6 2002/09/27 17:55:43 tshort noship $ */

-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.

G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_CUSTOM_PUB';

-- Type definitions

-- Region primary key record

TYPE Custom_PK_Rec_Type IS RECORD (
custom_appl_id	   NUMBER		     := FND_API.G_MISS_NUM,
custom_code		   VARCHAR2(30)		     := FND_API.G_MISS_CHAR,
region_appl_id           NUMBER                    := FND_API.G_MISS_NUM,
region_code              VARCHAR2(30)              := FND_API.G_MISS_CHAR
);

-- Customization Record

TYPE Custom_Rec_Type IS RECORD (
customization_appl_id	NUMBER				:= NULL,
customization_code		VARCHAR2(30)			:= NULL,
region_appl_id    NUMBER                    := NULL,
region_code              VARCHAR2(30)              := NULL,
verticalization_id		VARCHAR2(150)			:=NULL,
localization_code		VARCHAR2(150)			:= NULL,
org_id			NUMBER				:= NULL,
site_id			NUMBER				:= NULL,
responsibility_id		NUMBER				:= NULL,
web_user_id			NUMBER				:= NULL,
default_customization_flag	VARCHAR2(1)			:= NULL,
customization_level_id	NUMBER				:= NULL,
developer_mode		VARCHAR2(1)			:= NULL,
reference_path		VARCHAR2(100)			:= NULL,
function_name			VARCHAR2(30)			:= NULL,
start_date_active		DATE				:= NULL,
end_date_active		DATE				:= NULL,
name				VARCHAR2(80)			:= NULL,
description			VARCHAR2(2000)			:= NULL,
created_by			NUMBER				:= NULL,
creation_date			DATE				:= NULL,
last_updated_by		NUMBER				:= NULL,
last_update_date		DATE				:= NULL,
last_update_login		NUMBER				:= NULL);

-- Custom Region Record

TYPE Cust_Region_Rec_Type IS RECORD (
customization_appl_id NUMBER                          := NULL,
customization_code            VARCHAR2(30)                    := NULL,
region_appl_id    NUMBER                    := NULL,
region_code              VARCHAR2(30)              := NULL,
property_name			VARCHAR2(30)			:= NULL,
property_varchar2_value	VARCHAR2(2000)			:= NULL,
property_number_value		NUMBER				:= NULL,
criteria_join_condition	VARCHAR2(3)			:= NULL,
property_varchar2_value_tl	VARCHAR2(2000)			:= NULL,
created_by                    NUMBER                          := NULL,
creation_date                 DATE                            := NULL,
last_updated_by               NUMBER                          := NULL,
last_update_date              DATE                            := NULL,
last_update_login             NUMBER                          := NULL);

-- Custom Region Item Record

TYPE Cust_Reg_Item_Rec_Type IS RECORD (
customization_appl_id NUMBER                          := NULL,
customization_code            VARCHAR2(30)                    := NULL,
region_appl_id    NUMBER                    := NULL,
region_code              VARCHAR2(30)              := NULL,
attr_appl_id			NUMBER				:= NULL,
attr_code			VARCHAR2(30)			:= NULL,
property_name 		VARCHAR2(30)			:= NULL,
property_varchar2_value	VARCHAR2(4000)			:= NULL,
property_number_value		NUMBER				:= NULL,
property_date_value		DATE				:= NULL,
property_varchar2_value_tl	VARCHAR2(4000)			:= NULL,
created_by                    NUMBER                          := NULL,
creation_date                 DATE                            := NULL,
last_updated_by               NUMBER                          := NULL,
last_update_date              DATE                            := NULL,
last_update_login             NUMBER                          := NULL);

-- Customization primary key table

TYPE Criteria_Tbl_Type IS TABLE OF AK_CRITERIA%ROWTYPE
INDEX BY BINARY_INTEGER;

TYPE Cust_Reg_Item_Tbl_Type IS TABLE OF Cust_Reg_Item_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Cust_Region_Tbl_Type IS TABLE OF Cust_Region_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Custom_PK_Tbl_Type IS TABLE OF Custom_PK_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Custom_Tbl_Type IS TABLE OF Custom_Rec_Type
INDEX BY BINARY_INTEGER;

/*Constants for missing data types */
G_MISS_CUST_REG_ITEM_REC	Cust_Reg_Item_Rec_Type;
G_MISS_CUST_REG_ITEM_TBL	Cust_Reg_Item_Tbl_Type;
G_MISS_CUST_REGION_REC		Cust_Region_Rec_Type;
G_MISS_CUST_REGION_TBL		Cust_Region_Tbl_Type;
G_MISS_CUSTOM_PK_REC		Custom_PK_Rec_Type;
G_MISS_CUSTOM_PK_TBL		Custom_PK_Tbl_Type;
G_MISS_CUSTOM_REC	        Custom_Rec_Type;
G_MISS_CUSTOM_TBL	        Custom_Tbl_Type;
G_MISS_CRITERIA_REC		Criteria_Tbl_Type;

end AK_CUSTOM_PUB;

 

/
