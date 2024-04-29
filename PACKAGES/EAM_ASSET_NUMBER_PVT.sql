--------------------------------------------------------
--  DDL for Package EAM_ASSET_NUMBER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_NUMBER_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVASNS.pls 120.8.12010000.1 2008/07/24 11:49:38 appldev ship $ */
 -- Start of comments
 -- API name    : EAM_ASSET_NUMBER_PVT
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_API_VERSION                 IN NUMBER       REQUIRED
 --          P_INIT_MSG_LIST               IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_COMMIT                      IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_VALIDATION_LEVEL            IN NUMBER       OPTIONAL
 --             DEFAULT = FND_API.G_VALID_LEVEL_FULL
 --          P_INVENTORY_ITEM_ID           IN  NUMBER
 --          P_SERIAL_NUMBER               IN  VARCHAR2
 --	     P_INSTANCE_NUMBER		  VARCHAR2,
 --          P_START_DATE_ACTIVE           IN  DATE
 --          P_DESCRIPTIVE_TEXT            IN  VARCHAR2
 --          P_ORGANIZATION_ID             IN  NUMBER
 --          P_CATEGORY_ID                 IN  NUMBER
 --          P_PN_LOCATION_ID              IN  NUMBER
 --
 --          P_FA_ASSET_ID                 IN  NUMBER
 --          P_ASSET_CRITICALITY_CODE      IN  VARCHAR2
 --          P_MAINTAINABLE_FLAG           IN  VARCHAR2
 --          P_NETWORK_ASSET_FLAG          IN  VARCHAR2
 --          P_ATTRIBUTE_CATEGORY          IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE1                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE2                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE3                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE4                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE5                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE6                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE7                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE8                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE9                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE10                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE11                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE12                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE13                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE14                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE15                 IN  VARCHAR2    OPTIONAL
 --          P_LAST_UPDATE_DATE            IN  DATE        REQUIRED
 --          P_LAST_UPDATED_BY             IN  NUMBER      REQUIRED
 --          P_CREATION_DATE               IN  DATE        REQUIRED
 --          P_CREATED_BY                  IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_LOGIN           IN  NUMBER      REQUIRED
 --          P_REQUEST_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_APPLICATION_ID      IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_UPDATE_DATE         IN  DATE DEFAULT NULL
 -- OUT      X_OBJECT_ID                   OUT NUMBER
 --          X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 1.0
 --
 -- Notes    : Note text
 --
 -- End of comments


/*  Create a Row for an Asset Number in CSI_ITEM_INSTANCES */

PROCEDURE INSERT_ROW(
  P_API_VERSION                IN NUMBER,
  P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_SERIAL_NUMBER                 VARCHAR2,
  P_INSTANCE_NUMBER		  VARCHAR2,
  P_INSTANCE_DESCRIPTION          VARCHAR2,
  P_ORGANIZATION_ID               NUMBER,
  P_CATEGORY_ID                   NUMBER,
  P_PN_LOCATION_ID                NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_FA_SYNC_FLAG                  VARCHAR2,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_NETWORK_ASSET_FLAG            VARCHAR2,
  P_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
  P_REQUEST_ID                    NUMBER   DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER   DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER   DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE     DEFAULT NULL,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_CREATION_DATE                 DATE,
  P_CREATED_BY                    NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  p_active_start_date		  DATE DEFAULT NULL,
  p_active_end_date		  DATE DEFAULT NULL,
  p_location			  NUMBER DEFAULT NULL,
  p_linear_location_id	  	  NUMBER DEFAULT NULL,
  p_operational_log_flag	  VARCHAR2 DEFAULT NULL,
  p_checkin_status		  NUMBER DEFAULT NULL,
  p_supplier_warranty_exp_date        DATE DEFAULT NULL,
  p_equipment_gen_object_id   	  NUMBER DEFAULT NULL,
  p_mfg_serial_number_flag	  VARCHAR2 DEFAULT 'N',
  X_OBJECT_ID OUT NOCOPY NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  );


/* Update an Asset Row in CSI_ITEM_INSTANCES */
PROCEDURE UPDATE_ROW(
  P_API_VERSION                IN NUMBER,
  P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_instance_id     IN NUMBER,
  P_INSTANCE_DESCRIPTION              VARCHAR2,
  P_CATEGORY_ID                   NUMBER,
  P_PN_LOCATION_ID                NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_FA_SYNC_FLAG		  VARCHAR2 DEFAULT NULL,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_NETWORK_ASSET_FLAG            VARCHAR2,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
    P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_FROM_PUBLIC_API		  VARCHAR2 DEFAULT 'Y',
  P_INSTANCE_NUMBER		  VARCHAR2 DEFAULT NULL,
  P_LOCATION_TYPE_CODE		  VARCHAR2 DEFAULT NULL,
  P_LOCATION_ID			  NUMBER DEFAULT NULL,
  p_active_end_date		  DATE DEFAULT NULL,
  p_linear_location_id	  	  NUMBER DEFAULT NULL,
  p_operational_log_flag	  VARCHAR2 DEFAULT NULL,
  p_checkin_status		  NUMBER DEFAULT NULL,
  p_supplier_warranty_exp_date    DATE DEFAULT NULL,
  p_equipment_gen_object_id   	  NUMBER DEFAULT NULL
  ,p_reactivate_asset		VARCHAR2 DEFAULT 'N'
  ,p_disassociate_fa_flag	VARCHAR2 DEFAULT 'N',  --5474749
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2
  );


PROCEDURE LOCK_ROW(

          P_API_VERSION                IN NUMBER,
          P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
          P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
          P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          P_ROWID                         VARCHAR2,
          P_INSTANCE_ID		IN NUMBER,
          P_INSTANCE_NUMBER		    VARCHAR2 DEFAULT NULL,
          P_INSTANCE_DESCRIPTION         VARCHAR2,
          P_CATEGORY_ID                   NUMBER,
          P_PN_LOCATION_ID                NUMBER,
          P_FA_ASSET_ID                   NUMBER,
          P_ASSET_CRITICALITY_CODE        VARCHAR2,
          P_MAINTAINABLE_FLAG             VARCHAR2,
          P_NETWORK_ASSET_FLAG            VARCHAR2,
          P_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
          P_REQUEST_ID                    NUMBER   DEFAULT NULL,
          P_PROGRAM_APPLICATION_ID        NUMBER   DEFAULT NULL,
          P_PROGRAM_ID                    NUMBER   DEFAULT NULL,
          P_PROGRAM_UPDATE_DATE           DATE     DEFAULT NULL,
          P_LAST_UPDATE_DATE              DATE,
          P_LAST_UPDATED_BY               NUMBER,
          P_LAST_UPDATE_LOGIN             NUMBER,
          P_LOCATION_TYPE_CODE		  VARCHAR2 DEFAULT NULL,
    	  P_LOCATION_ID			  NUMBER DEFAULT NULL,
          p_linear_location_id	    	  NUMBER 	DEFAULT NULL,
          p_operational_log_flag	  VARCHAR2 	DEFAULT NULL,
          P_checkin_status	          NUMBER 	DEFAULT NULL,
          p_supplier_warranty_exp_date    DATE 	DEFAULT NULL,
          p_equipment_gen_object_id       NUMBER 	DEFAULT NULL,
          X_RETURN_STATUS                 OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                     OUT NOCOPY NUMBER,
          X_MSG_DATA                      OUT NOCOPY VARCHAR2
      );

/* Create an Asset Number along with its maintenance Attributes */
PROCEDURE CREATE_ASSET(
	 P_API_VERSION                IN NUMBER
	 ,P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE
	 ,P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE
         ,P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
         ,P_INVENTORY_ITEM_ID             NUMBER
	 ,P_SERIAL_NUMBER                 VARCHAR2
	 ,P_INSTANCE_NUMBER		  VARCHAR2
	 ,P_INSTANCE_DESCRIPTION          VARCHAR2
  	 ,P_ORGANIZATION_ID               NUMBER
  	 ,P_CATEGORY_ID                   NUMBER DEFAULT NULL
	 ,P_PN_LOCATION_ID              NUMBER DEFAULT NULL
	 ,P_FA_ASSET_ID                 NUMBER DEFAULT NULL
	 ,P_FA_SYNC_FLAG		VARCHAR2 DEFAULT NULL
	 ,P_ASSET_CRITICALITY_CODE      VARCHAR2 DEFAULT NULL
	 ,P_MAINTAINABLE_FLAG           VARCHAR2 DEFAULT NULL
	 ,P_NETWORK_ASSET_FLAG          VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL
	 ,P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL
	 ,P_REQUEST_ID                    NUMBER   DEFAULT NULL
	 ,P_PROGRAM_APPLICATION_ID        NUMBER   DEFAULT NULL
	 ,P_PROGRAM_ID                    NUMBER   DEFAULT NULL
	 ,P_PROGRAM_UPDATE_DATE           DATE     DEFAULT NULL
	 ,P_LAST_UPDATE_DATE              DATE
	 ,P_LAST_UPDATED_BY               NUMBER
	 ,P_CREATION_DATE                 DATE
	 ,P_CREATED_BY                    NUMBER
	 ,P_LAST_UPDATE_LOGIN             NUMBER
	 ,p_active_start_date		  DATE DEFAULT NULL
	 ,p_active_end_date		  DATE DEFAULT NULL
	 ,p_location			  NUMBER DEFAULT NULL
	 ,p_linear_location_id	  	  NUMBER DEFAULT NULL
	 ,p_operational_log_flag	  VARCHAR2 DEFAULT NULL
	 ,p_checkin_status		  NUMBER DEFAULT NULL
	 ,p_supplier_warranty_exp_date        DATE DEFAULT NULL
	 ,p_equipment_gen_object_id   	  NUMBER DEFAULT NULL
	 ,p_owning_department_id	  NUMBER DEFAULT NULL
	 ,p_accounting_class_code	  VARCHAR2 DEFAULT NULL
	 ,p_area_id			  NUMBER DEFAULT NULL
	 ,X_OBJECT_ID OUT NOCOPY NUMBER
	 ,X_RETURN_STATUS OUT NOCOPY VARCHAR2
	 ,X_MSG_COUNT OUT NOCOPY NUMBER
	 ,X_MSG_DATA OUT NOCOPY VARCHAR2

);

/* Update an Asset Number along with its maintenance Attributes */
procedure update_asset(
	  	P_API_VERSION                 IN NUMBER
	  	,P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE
	  	,P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE
	  	,P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
	  	,p_instance_id     	      IN NUMBER DEFAULT NULL
	  	,P_INSTANCE_DESCRIPTION          VARCHAR2 DEFAULT NULL
	  	,P_INVENTORY_ITEM_ID		 NUMBER
	  	,P_SERIAL_NUMBER		 VARCHAR2
	  	,P_ORGANIZATION_ID		 NUMBER
	  	,P_CATEGORY_ID                   NUMBER DEFAULT NULL
	  	,P_PN_LOCATION_ID                NUMBER DEFAULT NULL
	  	,P_FA_ASSET_ID                   NUMBER DEFAULT NULL
	  	,P_FA_SYNC_FLAG		  VARCHAR2 DEFAULT NULL
	  	,P_ASSET_CRITICALITY_CODE        VARCHAR2 DEFAULT NULL
	  	,P_MAINTAINABLE_FLAG             VARCHAR2 DEFAULT NULL
	  	,P_NETWORK_ASSET_FLAG            VARCHAR2 DEFAULT NULL
	  	,P_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL
	  	,P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL
	  	,P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL
	 	,P_REQUEST_ID                    NUMBER DEFAULT NULL
	  	,P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL
	  	,P_PROGRAM_ID                    NUMBER DEFAULT NULL
	  	,P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL
	  	,P_LAST_UPDATE_DATE              DATE DEFAULT NULL
	  	,P_LAST_UPDATED_BY               NUMBER DEFAULT NULL
	  	,P_LAST_UPDATE_LOGIN             NUMBER DEFAULT NULL
	  	,P_FROM_PUBLIC_API		  VARCHAR2 DEFAULT 'Y'
	  	,P_INSTANCE_NUMBER		  VARCHAR2 DEFAULT NULL
	        ,P_LOCATION_TYPE_CODE		  VARCHAR2 DEFAULT NULL
	        ,P_LOCATION_ID			  NUMBER DEFAULT NULL
	        ,p_active_end_date		  DATE DEFAULT NULL
	    	,p_linear_location_id	  	  NUMBER DEFAULT NULL
	    	,p_operational_log_flag	  VARCHAR2 DEFAULT NULL
	    	,p_checkin_status		  NUMBER DEFAULT NULL
	    	,p_supplier_warranty_exp_date        DATE DEFAULT NULL
	  	,p_equipment_gen_object_id   	  NUMBER DEFAULT NULL
	        ,p_owning_department_id	  NUMBER DEFAULT NULL
	        ,p_accounting_class_code	  VARCHAR2 DEFAULT NULL
	 	,p_area_id			  NUMBER DEFAULT NULL
	 	,p_reactivate_asset		VARCHAR2 DEFAULT 'N'
		,p_disassociate_fa_flag		VARCHAR2 DEFAULT 'N' --5474749
	  	,X_RETURN_STATUS             OUT NOCOPY VARCHAR2
	  	,X_MSG_COUNT                 OUT NOCOPY NUMBER
	  	,X_MSG_DATA                  OUT NOCOPY VARCHAR2
  	);

PROCEDURE SERIAL_CHECK(
  p_api_version                IN    NUMBER,
  p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit                     IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level           IN    NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY   VARCHAR2,
  x_msg_count                  OUT NOCOPY   NUMBER,
  x_msg_data                   OUT NOCOPY   VARCHAR2,
  x_errorcode                  OUT NOCOPY   NUMBER,
  x_ser_num_in_item_id		out NOCOPY boolean,
  p_INVENTORY_ITEM_ID		IN NUMBER,
  p_SERIAL_NUMBER              IN    VARCHAR2,
  p_ORGANIZATION_ID            IN    NUMBER);

  procedure find_assets(
  p_organization_id	number
  ,p_inventory_item_id number
  ,p_instance_id number
  ,p_category_id number
  ,P_PN_LOCATION_ID                NUMBER,
  P_EAM_LOCATION_ID               NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_WIP_ACCOUNTING_CLASS_CODE     VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_OWNING_DEPARTMENT_ID          NUMBER,
   P_PROD_ORGANIZATION_ID          NUMBER,
  P_EQUIPMENT_ITEM_ID             NUMBER,
  P_EQP_SERIAL_NUMBER             VARCHAR2
  ,p_eam_item_type                NUMBER
  ,p_asset_category_id            NUMBER
);

END EAM_ASSET_NUMBER_PVT;

/
