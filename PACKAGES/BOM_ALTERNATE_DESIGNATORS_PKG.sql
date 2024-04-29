--------------------------------------------------------
--  DDL for Package BOM_ALTERNATE_DESIGNATORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_ALTERNATE_DESIGNATORS_PKG" AUTHID CURRENT_USER as
/* $Header: bompbads.pls 120.3 2007/02/27 10:44:09 vhymavat ship $ */

  PROCEDURE Check_Unique(X_Organization_Id NUMBER,
                         X_Alternate_Designator_Code VARCHAR2);


  PROCEDURE Check_References(X_Organization_Id NUMBER,
    			     X_Alternate_Designator_Code VARCHAR2);

  FUNCTION Check_References_wrapper(X_Organization_Id NUMBER,
    			     X_Alternate_Designator_Code VARCHAR2)
   RETURN VARCHAR2 ;

                       -------------------------------
                       -- Alternate Designator APIs --
                       -------------------------------

  PROCEDURE Insert_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code		IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code_old		IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_alt_desig_code_new		IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

  PROCEDURE Delete_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code		IN   VARCHAR2
       ,p_from_struct_alt_page          IN   VARCHAR2 DEFAULT 'N'
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

  PROCEDURE Delete_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code		IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

 PROCEDURE Create_Association(
        p_api_version                   IN NUMBER
--       ,p_organization_id               IN NUMBER
       ,p_alternate_designator_code     IN VARCHAR2
       ,p_structure_type_id             IN NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

  PROCEDURE Add_Language;

  PROCEDURE Insert_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code                IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_display_name                  IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,p_is_preferred			IN   VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Row (
        p_api_version                   IN   NUMBER
       ,p_alt_desig_code_old            IN   VARCHAR2
       ,p_organization_id               IN   NUMBER
       ,p_alt_desig_code_new            IN   VARCHAR2
       ,p_display_name_new              IN   VARCHAR2
       ,p_description                   IN   VARCHAR2
       ,p_disable_date                  IN   DATE
       ,p_structure_type_id             IN   NUMBER
       ,p_is_preferred 			IN  VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2);

---- For forms ----

procedure INSERT_ROW ( --- called by forms
  P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
  P_ORGANIZATION_ID in NUMBER,
  P_STRUCTURE_TYPE_ID in NUMBER,
  P_DISABLE_DATE in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_REQUEST_ID in NUMBER,
  P_DISPLAY_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
  P_ORGANIZATION_ID in NUMBER,
  P_STRUCTURE_TYPE_ID in NUMBER,
  P_DISABLE_DATE in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_REQUEST_ID in NUMBER,
--  P_DISPLAY_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2
);

procedure UPDATE_ROW ( --- called by forms
  P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
  P_ORGANIZATION_ID in NUMBER,
  P_STRUCTURE_TYPE_ID in NUMBER,
  P_DISABLE_DATE in DATE,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_REQUEST_ID in NUMBER,
  P_DISPLAY_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  P_ALTERNATE_DESIGNATOR_CODE in VARCHAR2,
  P_ORGANIZATION_ID in NUMBER
);

	-- Start of comments
	--	API name 	: copy_to_org
	--	Type		: private
	--	Pre-reqs	: Source organization structure name should exist.
	--	Function	: Copies structure name to the target organization from source organization
	--	Parameters	:
	--	IN		:	p_alt_desig_code IN VARCHAR2 Required
	--				    Alternate Designator Code of the structure name
	--              p_from_org_id    IN NUMBER Required
	--                  Organization from which the structure name should be copied
	--              p_to_org_id      IN NUMBER Required
	--                  Organization to which the structure name should be copied
	-- End of comments
PROCEDURE copy_to_org(
  p_alt_desig_code IN VARCHAR2,
  p_from_org_id IN NUMBER,
  p_to_org_id IN NUMBER
);

PROCEDURE LOAD_ROW ( --- called from bomalt.lct
  p_alternate_designator_code IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_description IN VARCHAR2,
  p_display_name IN VARCHAR2,
  p_disable_date IN DATE,
  p_structure_type_id IN NUMBER,
  p_attribute_category IN VARCHAR2,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2,
  p_attribute3 IN VARCHAR2,
  p_attribute4 IN VARCHAR2,
  p_attribute5 IN VARCHAR2,
  p_attribute6 IN VARCHAR2,
  p_attribute7 IN VARCHAR2,
  p_attribute8 IN VARCHAR2,
  p_attribute9 IN VARCHAR2,
  p_attribute10 IN VARCHAR2,
  p_attribute11 IN VARCHAR2,
  p_attribute12 IN VARCHAR2,
  p_attribute13 IN VARCHAR2,
  p_attribute14 IN VARCHAR2,
  p_attribute15 IN VARCHAR2,
  p_request_id IN NUMBER,
  p_program_application_id IN NUMBER,
  p_program_id IN NUMBER,
  p_program_update_date IN DATE,
  p_creation_date IN DATE,
  p_created_by IN NUMBER,
  p_last_update_date IN DATE,
  p_last_updated_by IN NUMBER,
  p_last_update_login IN NUMBER,
  p_custom_mode IN VARCHAR2,
  p_is_preferred IN VARCHAR2);

PROCEDURE LOAD_ALTERNATE_DESIGNATOR (
  p_alternate_designator_code IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_description IN VARCHAR2,
  p_display_name IN VARCHAR2,
  p_disable_date IN DATE,
  p_structure_type_id IN NUMBER,
  p_attribute_category IN VARCHAR2,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2,
  p_attribute3 IN VARCHAR2,
  p_attribute4 IN VARCHAR2,
  p_attribute5 IN VARCHAR2,
  p_attribute6 IN VARCHAR2,
  p_attribute7 IN VARCHAR2,
  p_attribute8 IN VARCHAR2,
  p_attribute9 IN VARCHAR2,
  p_attribute10 IN VARCHAR2,
  p_attribute11 IN VARCHAR2,
  p_attribute12 IN VARCHAR2,
  p_attribute13 IN VARCHAR2,
  p_attribute14 IN VARCHAR2,
  p_attribute15 IN VARCHAR2,
  p_request_id IN NUMBER,
  p_program_application_id IN NUMBER,
  p_program_id IN NUMBER,
  p_program_update_date IN DATE,
  p_creation_date IN DATE,
  p_created_by IN NUMBER,
  p_last_update_date IN DATE,
  p_last_updated_by IN NUMBER,
  p_last_update_login IN NUMBER,
  p_custom_mode IN VARCHAR2,
  p_is_preferred IN VARCHAR2);

PROCEDURE TRANSLATE_ROW ( --- called from bomalt.lct
  p_alternate_designator_code IN VARCHAR2,
  p_organization_id IN NUMBER,
  p_description IN VARCHAR2,
  p_display_name IN VARCHAR2,
  p_last_update_date IN DATE,
  p_last_updated_by IN NUMBER,
  p_last_update_login IN NUMBER,
  p_custom_mode IN VARCHAR2);

END BOM_ALTERNATE_DESIGNATORS_PKG;

/
