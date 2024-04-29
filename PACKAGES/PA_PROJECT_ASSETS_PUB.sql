--------------------------------------------------------
--  DDL for Package PA_PROJECT_ASSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_ASSETS_PUB" AUTHID CURRENT_USER as
/*$Header: PAPMPAPS.pls 120.5 2006/07/29 11:39:40 skannoji noship $*/
/*#
 * This package contains the public APIs that provide an open interface for external systems to insert, update, assign, and delete assets.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Asset APIs
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

--Package constant used for package version validation

G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;


--Locking exception
ROW_ALREADY_LOCKED	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);


--JPULTORAK Project Asset Creation

TYPE asset_in_rec_type IS RECORD
(pm_asset_reference		     VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
pa_project_asset_id		     NUMBER	       	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
asset_number				 VARCHAR2(15)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
pa_asset_name			     VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
asset_description			 VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
project_asset_type			 VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
location_id				     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
assigned_to_person_id		 NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
date_placed_in_service		 DATE			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
asset_category_id			 NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
book_type_code			     VARCHAR2(15)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
asset_units				     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
estimated_asset_units		 NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
estimated_cost			     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
depreciate_flag			     VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
depreciation_expense_ccid	 NUMBER		    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
amortize_flag				 VARCHAR2(1) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
estimated_in_service_date	 DATE			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
asset_key_ccid			     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
attribute_category			 VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute1				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute2				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute3				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute4				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute5				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute6				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute7				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute8				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute9				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute10				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute11				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute12				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute13				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute14				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute15				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
parent_asset_id			     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
manufacturer_name		     VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
model_number			     VARCHAR2(40)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
serial_number				 VARCHAR2(35)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
tag_number				     VARCHAR2(15)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
ret_target_asset_id			 NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
);

TYPE asset_in_tbl_type IS TABLE OF asset_in_rec_type
	INDEX BY BINARY_INTEGER;


TYPE asset_out_rec_type IS RECORD
(pm_asset_reference		     VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
pa_project_asset_id		     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
return_status				 VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

TYPE asset_out_tbl_type IS TABLE OF asset_out_rec_type
	INDEX BY BINARY_INTEGER;


TYPE asset_assignment_in_rec_type IS RECORD
(pa_task_id				     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
pm_task_reference		     VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
pa_project_asset_id		     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
pm_asset_reference		     VARCHAR2(240)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute_category			 VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute1				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute2				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute3				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute4				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute5				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute6				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute7				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute8				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute9				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute10				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute11				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute12				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute13				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute14				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute15				     VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

TYPE asset_assignment_in_tbl_type IS TABLE OF asset_assignment_in_rec_type
	INDEX BY BINARY_INTEGER;


TYPE asset_assignment_out_rec_type IS RECORD
(pa_task_id				     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
pa_task_number			     VARCHAR2(25)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
pm_task_reference		     VARCHAR2(25)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
pa_project_asset_id		     NUMBER			:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
pa_asset_name			     VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
pm_asset_reference		     VARCHAR2(240)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
return_status				 VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR);

TYPE asset_assignment_out_tbl_type IS TABLE OF asset_assignment_out_rec_type
	INDEX BY BINARY_INTEGER;



--Globals to be used by the LOAD/EXECUTE/FETCH process

--IN Types
G_assets_in_tbl			        asset_in_tbl_type;
G_asset_assignments_in_tbl      asset_assignment_in_tbl_type;

--Counters
G_assets_tbl_count		        NUMBER:=0;
G_asset_assignments_tbl_count	NUMBER:=0;

--OUT Types
G_assets_out_tbl		        asset_out_tbl_type;
G_asset_assignments_out_tbl     asset_assignment_out_tbl_type;

--JPULTORAK Project Asset Creation





--JPULTORAK Project Asset Creation

/*#
 * This API adds a project asset to the specified project. If the validations complete successfully, a new row
 * is created in the table PA_PROJECT_ASSETS_ALL.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if transaction will be commited
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 240} {@rep:required}
 * @param p_pa_asset_name The name that uniquely defines the asset in Oracle Projects
 * @rep:paraminfo {@rep:precision 240} {@rep:required}
 * @param p_asset_number Unique asset number
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_asset_description Asset description
 * @rep:paraminfo {@rep:precision 80} {@rep:required}
 * @param p_project_asset_type Asset type
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_location_id The identifier of the location to which the asset is assigned
 * @param p_assigned_to_person_id The identifier of the person to whom the asset is assigned
 * @param p_date_placed_in_service Date placed in service of the asset
 * @param p_asset_category_id The identifier of the asset category to which the asset is assigned
 * @param p_book_type_code The corporate book to which the asset is assigned
 * @rep:paraminfo {@rep:precision 15}
 * @param p_asset_units The number of asset units
 * @param p_estimated_asset_units The estimated number of asset units
 * @param p_estimated_cost The estimated cost
 * @param p_depreciate_flag Indicator whether the asset should be depreciated in Oracle Assets
 * @rep:paraminfo {@rep:precision 1}
 * @param p_depreciation_expense_ccid The depreciation expense account for the asset
 * @param p_amortize_flag Indicator whether cost adjustments should be ammortised in Oracle Assets
 * @rep:paraminfo {@rep:precision 1}
 * @param p_estimated_in_service_date The estimated date placed in service for the asset
 * @param p_asset_key_ccid Key flexfield code combination identifier for asset key flexfield
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:precision 30}
 * @param p_attribute1 through p_attribute15 Descriptive flexfield attribute
 * @rep:paraminfo {@rep:precision 150}
 * @param p_parent_asset_id The identifier of the parent asset
 * @param p_manufacturer_name The name of the manufacturer of the asset
 * @rep:paraminfo {@rep:precision 30}
 * @param p_model_number The model number of the asset
 * @rep:paraminfo {@rep:precision 40}
 * @param p_serial_number The serial number of the asset
 * @rep:paraminfo {@rep:precision 35}
 * @param p_tag_number The tag number of the asset
 * @rep:paraminfo {@rep:precision 15}
 * @param p_ret_target_asset_id The identifier of the target asset
 * @param p_pa_project_id_out API standard
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pa_project_number_out API standard
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_asset_id_out The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_asset_reference_out The reference code that uniquely dentifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Asset
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE add_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT	 NOCOPY VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_asset_name			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_number			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_description		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_asset_type		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_location_id				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_assigned_to_person_id	IN 	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_date_placed_in_service	IN 	DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_category_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_book_type_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_units				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_asset_units	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_cost			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_depreciate_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_depreciation_expense_ccid IN	NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_amortize_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_estimated_in_service_date IN	DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_key_ccid			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_parent_asset_id		    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_manufacturer_name		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_model_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_serial_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_tag_number				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_ret_target_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_project_id_out		OUT NOCOPY	NUMBER
 ,p_pa_project_number_out	OUT NOCOPY	VARCHAR2
 ,p_pa_project_asset_id_out	OUT NOCOPY	NUMBER
 ,p_pm_asset_reference_out  OUT NOCOPY VARCHAR2);



/*#
 * This procedure adds an asset assignment to the specified project.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if transaction will be commited
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_task_reference The reference code that identifies a project's task in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25}
 * @param p_pa_project_asset_id The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:precision 30}
 * @param p_attribute1 through p_attribute15 Descriptive flexfield attribute
 * @rep:paraminfo {@rep:precision 150}
 * @param p_pa_task_id_out The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pa_project_asset_id_out The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Asset Assignment
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE add_asset_assignment
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT NOCOPY	VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference	    IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id			    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id_out		    OUT NOCOPY	NUMBER
 ,p_pa_project_asset_id_out	OUT NOCOPY	NUMBER );



/*#
 * This procedure updates a project asset on the specified project.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if transaction will be commited
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_asset_id  The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pa_asset_name The name that uniquely defines the asset in Oracle Projects
 * @rep:paraminfo {@rep:precision 240} {@rep:required}
 * @param p_asset_number Unique asset number
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_asset_description Asset description
 * @rep:paraminfo {@rep:precision 80} {@rep:required}
 * @param p_project_asset_type Asset type
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_location_id The identifier of the location to which the asset is assigned
 * @param p_assigned_to_person_id The identifier of the person to whom the asset is assigned
 * @param p_date_placed_in_service Date placed in service of the asset
 * @param p_asset_category_id The identifier of the asset category to which the asset is assigned
 * @param p_book_type_code The corporate book to which the asset is assigned
 * @rep:paraminfo {@rep:precision 15}
 * @param p_asset_units The number of asset units
 * @param p_estimated_asset_units The estimated number of asset units
 * @param p_estimated_cost The estimated cost
 * @param p_depreciate_flag Indicator whether the asset should be depreciated in Oracle Assets
 * @rep:paraminfo {@rep:precision 1}
 * @param p_depreciation_expense_ccid The depreciation expense account for the asset
 * @param p_amortize_flag Indicator whether cost adjustments should be ammortised in Oracle Assets
 * @rep:paraminfo {@rep:precision 1}
 * @param p_estimated_in_service_date The estimated date placed in service for the asset
 * @param p_asset_key_ccid Key flexfield code combination identifier for asset key flexfield
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:precision 30}
 * @param p_attribute1 through p_attribute15 Descriptive flexfield attribute
 * @rep:paraminfo {@rep:precision 150}
 * @param p_parent_asset_id The identifier of the parent asset
 * @param p_manufacturer_name The name of the manufacturer of the asset
 * @rep:paraminfo {@rep:precision 30}
 * @param p_model_number The model number of the asset
 * @rep:paraminfo {@rep:precision 40}
 * @param p_serial_number The serial number of the asset
 * @rep:paraminfo {@rep:precision 35}
 * @param p_tag_number The tag number of the asset
 * @rep:paraminfo {@rep:precision 15}
 * @param p_ret_target_asset_id The identifier of the target asset
 * @param p_pa_project_id_out API standard
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pa_project_number_out API standard
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_asset_id_out The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_asset_reference_out The reference code that uniquely dentifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Project Asset
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE update_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT NOCOPY	VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id	    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_asset_name			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_number			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_description		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_asset_type		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_location_id				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_assigned_to_person_id	IN 	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_date_placed_in_service	IN 	DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_category_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_book_type_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_asset_units				IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_asset_units	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_estimated_cost			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_depreciate_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_depreciation_expense_ccid IN	NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_amortize_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_estimated_in_service_date IN	DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_asset_key_ccid			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_parent_asset_id		    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_manufacturer_name		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_model_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_serial_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_tag_number				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_ret_target_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_project_id_out		OUT NOCOPY	NUMBER
 ,p_pa_project_number_out	OUT NOCOPY	VARCHAR2
 ,p_pa_project_asset_id_out	OUT NOCOPY	NUMBER
 ,p_pm_asset_reference_out  OUT NOCOPY VARCHAR2 );



/*#
 * This procedure converts an incoming asset reference to a project asset ID.
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pa_project_asset_id  The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_out_project_asset_id The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Convert Asset Reference to Asset ID
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
--Put this in PA_PROJECT_PVT if desired
PROCEDURE convert_pm_assetref_to_id
 ( p_pa_project_id          IN NUMBER
  ,p_pa_project_asset_id    IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_pm_asset_reference     IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_out_project_asset_id   OUT NOCOPY NUMBER
  ,p_return_status          OUT NOCOPY VARCHAR2 );


/*#
 * This function returns the PROJECT_ASSET_ID based on the ASSET_REFERENCE and PROJECT_ID.
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Project Asset Id
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
--Put this in PA_PROJECT_PVT if desired
FUNCTION fetch_project_asset_id
 ( p_pa_project_id        IN NUMBER
  ,p_pm_asset_reference   IN VARCHAR2 ) RETURN NUMBER;


/*#
 * This procedure adds a project asset row to the global PL/SQL table G_ASSETS_IN_TBL.
 * @param p_api_version_number API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 240} {@rep:required}
 * @param p_pa_asset_name The name that uniquely defines the asset in Oracle Projects
 * @rep:paraminfo {@rep:precision 240} {@rep:required}
 * @param p_asset_number Unique asset number
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_asset_description Asset description
 * @rep:paraminfo {@rep:precision 80} {@rep:required}
 * @param p_project_asset_type Asset type
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_location_id The identifier of the location to which the asset is assigned
 * @param p_assigned_to_person_id The identifier of the person to whom the asset is assigned
 * @param p_date_placed_in_service Date placed in service of the asset
 * @param p_asset_category_id The identifier of the asset category to which the asset is assigned
 * @param p_book_type_code The corporate book to which the asset is assigned
 * @rep:paraminfo {@rep:precision 15}
 * @param p_asset_units The number of asset units
 * @param p_estimated_asset_units The estimated number of asset units
 * @param p_estimated_cost The estimated cost
 * @param p_depreciate_flag Indicator whether the asset should be depreciated in Oracle Assets
 * @rep:paraminfo {@rep:precision 1}
 * @param p_depreciation_expense_ccid The depreciation expense account for the asset
 * @param p_amortize_flag Indicator whether cost adjustments should be ammortised in Oracle Assets
 * @rep:paraminfo {@rep:precision 1}
 * @param p_estimated_in_service_date The estimated date placed in service for the asset
 * @param p_asset_key_ccid Key flexfield code combination identifier for asset key flexfield
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:precision 30}
 * @param p_attribute1 through p_attribute15 Descriptive flexfield attribute
 * @rep:paraminfo {@rep:precision 150}
 * @param p_parent_asset_id The identifier of the parent asset
 * @param p_manufacturer_name The name of the manufacturer of the asset
 * @rep:paraminfo {@rep:precision 30}
 * @param p_model_number The model number of the asset
 * @rep:paraminfo {@rep:precision 40}
 * @param p_serial_number The serial number of the asset
 * @rep:paraminfo {@rep:precision 35}
 * @param p_tag_number The tag number of the asset
 * @rep:paraminfo {@rep:precision 15}
 * @param p_ret_target_asset_id The identifier of the target asset
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Load Project Asset
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/

PROCEDURE load_project_asset
 ( p_api_version_number	    IN	NUMBER
  ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
  ,p_return_status		    OUT NOCOPY	VARCHAR2
  ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_asset_name			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_asset_number			IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_asset_description		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_project_asset_type		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_location_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_assigned_to_person_id	IN 	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_date_placed_in_service	IN 	DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_asset_category_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_book_type_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_asset_units			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_estimated_asset_units	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_estimated_cost			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_depreciate_flag		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_depreciation_expense_ccid IN	NUMBER  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_amortize_flag			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_estimated_in_service_date IN	DATE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  ,p_asset_key_ccid			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_parent_asset_id	    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_manufacturer_name		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_model_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_serial_number			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_tag_number				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_ret_target_asset_id	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  );



/*#
 * This procedure adds an asset assignment row to the global PL/SQL table G_ASSET_ASSIGNMENTS_IN_TBL.
 * @param p_api_version_number API standard: version number
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_task_reference The reference code that identifies a project's task in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_asset_id The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:precision 30}
 * @param p_attribute1 through p_attribute15 Descriptive flexfield attribute
 * @rep:paraminfo {@rep:precision 150}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Asset Assignmentss: Load Asset Assignment
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE load_asset_assignment
 ( p_api_version_number		IN	NUMBER
  ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
  ,p_return_status		    OUT NOCOPY	VARCHAR2
  ,p_pm_task_reference	    IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_task_id			    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_pa_project_asset_id	IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  ,p_attribute_category		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute1				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute2				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute3				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute4				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute5				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute6				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute7				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute8				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute9				IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute10			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute11			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute12			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute13			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute14			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ,p_attribute15			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR);


/*#
 * This procedure, which is called from the CREATE_PROJECT procedure, processes project assets and project asset assignments sent to
 * the procedure in PL/SQL table input parameters.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if transaction will be commited
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_assets_in The PL/SQL datatype
 * @rep:paraminfo {@rep:required}
 * @param p_assets_out The PL/SQL datatype
 * @rep:paraminfo {@rep:required}
 * @param p_asset_assignments_in The PL/SQL datatype of asset assignment
 * @param p_asset_assignments_out The PL/SQL datatype of asset assignment
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Projects: Execute Create Project Asset
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE execute_add_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit				    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list			IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status			OUT NOCOPY	VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_assets_in               IN  asset_in_tbl_type
 ,p_assets_out              OUT NOCOPY asset_out_tbl_type
 ,p_asset_assignments_in    IN  asset_assignment_in_tbl_type
 ,p_asset_assignments_out   OUT NOCOPY asset_assignment_out_tbl_type );


/*#
 * This procedure deletes a project asset and any associated asset assignments from a project.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if transaction will be commited
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_asset_id  The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project Asset
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/
PROCEDURE delete_project_asset
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT NOCOPY	VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM );


/*#
 * This procedure deletes an asset assignment from a project.
 * @param p_api_version_number API standard: version number
 * @param p_commit API standard (default = F): indicates if transaction will be commited
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code The identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:precision 30} {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @param p_pm_task_reference The reference code that identifies a project's task in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15}
 * @param p_pm_asset_reference The reference code that uniquely identifies the asset in the external system
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pa_project_asset_id  The reference code that uniquely identifies the asset within a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 15} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Asset Assignment
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:compatibility S
*/

PROCEDURE delete_asset_assignment
( p_api_version_number		IN	NUMBER
 ,p_commit					IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_init_msg_list		    IN	VARCHAR2	:= FND_API.G_FALSE
 ,p_msg_count				OUT NOCOPY	NUMBER
 ,p_msg_data				OUT NOCOPY	VARCHAR2
 ,p_return_status		    OUT NOCOPY	VARCHAR2
 ,p_pm_product_code			IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference	IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id			IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference	    IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id			    IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_asset_reference		IN	VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_asset_id		IN	NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM );


--JPULTORAK Project Asset Creation

END PA_PROJECT_ASSETS_PUB;

 

/
