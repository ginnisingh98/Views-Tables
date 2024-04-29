--------------------------------------------------------
--  DDL for Package WIP_EAM_WORKREQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_WORKREQUEST_PVT" AUTHID CURRENT_USER as
/* $Header: WIPVWRPS.pls 120.1 2005/06/15 17:14:29 appldev  $ */
/* Modified by yjhabak for Work Request Enhancement Project BUG No : 2997297 */
 -- Start of comments
 -- API name : WIP_EAM_WORKREQUEST_PVT
 -- Type     : Public
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       p_api_version IN NUMBER   Required
 --          p_init_msg_list IN VARCHAR2    Optional
 --             Default = FND_API.G_FALSE
 --          p_commit IN VARCHAR2 Optional
 --             Default = FND_API.G_FALSE
 --          p_validation_level IN NUMBER   Optional
 --             Default = FND_API.G_VALID_LEVEL_FULL
 --          p_CLASSID in out NUMBER
 --          p_CLASS_CODE in VARCHAR2
 --          p_CLASS_NAME in VARCHAR2
 --          p_CLASS_DESCRIPTION in VARCHAR2
 --          p_START_DATE_ACTIVE in DATE
 --          p_END_DATE_ACTIVE in DATE
 --          p_CREATION_DATE in DATE
 --          p_CREATED_BY in NUMBER
 --          p_LAST_UPDATE_DATE in DATE
 --          p_LAST_UPDATED_BY in NUMBER
 --          p_LAST_UPDATE_LOGIN in NUMBER
 -- OUT      x_return_status   OUT   VARCHAR2(1)
 --          x_msg_count       OUT   NUMBER
 --          x_msg_data        OUT   VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : create and update work request
 --
 -- End of comments

PROCEDURE create_work_request (
  p_api_version             IN NUMBER,
  p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_org_id                  IN NUMBER,
  p_asset_group_id          IN NUMBER,
  p_asset_number            IN VARCHAR2,
  p_priority_id             IN NUMBER,
  p_request_by_date         IN DATE,
  p_request_log             IN VARCHAR2,
  p_owning_dept_id          IN NUMBER,
  p_user_id                 IN NUMBER,
  p_work_request_type_id    IN NUMBER,
  p_maintenance_object_type IN NUMBER DEFAULT 3,
  p_maintenance_object_id   IN NUMBER DEFAULT NULL,
  p_eam_linear_id 	    IN NUMBER DEFAULT NULL,
  p_work_request_created_by IN NUMBER DEFAULT 1,
  p_created_for             IN NUMBER DEFAULT NULL,
  p_phone_number            IN VARCHAR2 DEFAULT NULL,
  p_email                   IN VARCHAR2 DEFAULT NULL,
  p_contact_preference      IN NUMBER DEFAULT NULL,
  p_notify_originator       IN NUMBER DEFAULT NULL,
  p_attribute_category      IN VARCHAR2 DEFAULT NULL,
  p_attribute1              IN VARCHAR2 DEFAULT NULL,
  p_attribute2              IN VARCHAR2 DEFAULT NULL,
  p_attribute3              IN VARCHAR2 DEFAULT NULL,
  p_attribute4              IN VARCHAR2 DEFAULT NULL,
  p_attribute5              IN VARCHAR2 DEFAULT NULL,
  p_attribute6              IN VARCHAR2 DEFAULT NULL,
  p_attribute7              IN VARCHAR2 DEFAULT NULL,
  p_attribute8              IN VARCHAR2 DEFAULT NULL,
  p_attribute9              IN VARCHAR2 DEFAULT NULL,
  p_attribute10             IN VARCHAR2 DEFAULT NULL,
  p_attribute11             IN VARCHAR2 DEFAULT NULL,
  p_attribute12             IN VARCHAR2 DEFAULT NULL,
  p_attribute13             IN VARCHAR2 DEFAULT NULL,
  p_attribute14             IN VARCHAR2 DEFAULT NULL,
  p_attribute15             IN VARCHAR2 DEFAULT NULL,
  x_request_id              OUT NOCOPY NUMBER,
  x_status_id               OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2
);

FUNCTION isdifferent(a VARCHAR2, b VARCHAR2) RETURN NUMBER;

FUNCTION isdifferent_number(a NUMBER, b NUMBER) RETURN NUMBER;

FUNCTION dff_prompt_name (
    appl_short_name  IN fnd_application.application_short_name%TYPE,
    flexfield_name   IN  fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
    attribute_name IN fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE ,
    attribute_category IN fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE := 'Global Data Elements')
RETURN fnd_descr_flex_col_usage_vl.form_above_prompt%TYPE;

PROCEDURE update_work_request (
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_org_id               IN NUMBER,
  p_asset_group_id       IN NUMBER,
  p_asset_number         IN VARCHAR2,
  p_request_id           IN NUMBER,
  p_status_id            IN NUMBER,
  p_priority_id          IN NUMBER,
  p_request_by_date      IN DATE,
  p_request_log          IN VARCHAR2,
  p_work_request_type_id IN NUMBER,
  p_eam_linear_id	 IN NUMBER DEFAULT NULL,
  p_owning_dept_id       IN NUMBER,
  p_created_for          IN NUMBER,
  p_phone_number         IN VARCHAR2,
  p_email                IN VARCHAR2,
  p_contact_preference   IN NUMBER,
  p_notify_originator    IN NUMBER,
  p_attribute_category   IN VARCHAR2,
  p_attribute1           IN VARCHAR2,
  p_attribute2           IN VARCHAR2,
  p_attribute3           IN VARCHAR2,
  p_attribute4           IN VARCHAR2,
  p_attribute5           IN VARCHAR2,
  p_attribute6           IN VARCHAR2,
  p_attribute7           IN VARCHAR2,
  p_attribute8           IN VARCHAR2,
  p_attribute9           IN VARCHAR2,
  p_attribute10          IN VARCHAR2,
  p_attribute11          IN VARCHAR2,
  p_attribute12          IN VARCHAR2,
  p_attribute13          IN VARCHAR2,
  p_attribute14          IN VARCHAR2,
  p_attribute15          IN VARCHAR2,
  p_from_public_api 	 IN VARCHAR2 DEFAULT 'N',
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
);

PROCEDURE return_dept_id (
    p_org_id IN NUMBER,
    p_dept_name IN VARCHAR2,
    x_dept_id OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2
);

PROCEDURE validate_work_request (
  p_api_version in NUMBER,
  p_init_msg_list in VARCHAR2:= FND_API.G_FALSE,
  p_mode in VARCHAR2,
  p_org_id in NUMBER,
  p_request_id in NUMBER,
  p_asset_group_id in NUMBER,
  p_asset_number in VARCHAR2,
  p_priority_id in NUMBER,
  p_status_id in NUMBER,
  p_request_by_date in DATE,
  p_request_log in VARCHAR2,
  p_owning_dept_id in NUMBER,
  p_work_request_type_id in NUMBER,
  p_maintenance_object_type	IN NUMBER DEFAULT 3,
  p_maintenance_object_id	IN NUMBER DEFAULT NULL,
  p_eam_linear_id in NUMBER default null,
  p_attribute_category in VARCHAR2 default null,
  p_attribute1 IN VARCHAR2 default null,
  p_attribute2 IN VARCHAR2 default null,
  p_attribute3 IN VARCHAR2 default null,
  p_attribute4 IN VARCHAR2 default null,
  p_attribute5 IN VARCHAR2 default null,
  p_attribute6 IN VARCHAR2 default null,
  p_attribute7 IN VARCHAR2 default null,
  p_attribute8 IN VARCHAR2 default null,
  p_attribute9 IN VARCHAR2 default null,
  p_attribute10 IN VARCHAR2 default null,
  p_attribute11 IN VARCHAR2 default null,
  p_attribute12 IN VARCHAR2 default null,
  p_attribute13 IN VARCHAR2 default null,
  p_attribute14 IN VARCHAR2 default null,
  p_attribute15 IN VARCHAR2 default null,
  p_created_for IN NUMBER default null,
  p_phone_number IN VARCHAR2 default null,
  p_email IN VARCHAR2 default null,
  p_contact_preference IN NUMBER default null,
  p_notify_originator IN NUMBER default null,
  x_return_flag OUT NOCOPY BOOLEAN,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);


PROCEDURE auto_approve_check (
  p_api_version in NUMBER,
  p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
  p_commit in VARCHAR2 := FND_API.G_FALSE,
  p_validation_level in NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_org_id in NUMBER,
  x_return_check OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
);

PROCEDURE create_and_approve(
	p_api_version              IN NUMBER,
  	p_init_msg_list            IN VARCHAR2 := FND_API.G_FALSE,
  	p_commit                   IN VARCHAR2 := FND_API.G_FALSE,
  	p_validation_level         IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  	p_org_id                   IN NUMBER,
  	p_asset_group_id           IN NUMBER,
  	p_asset_number             IN VARCHAR2,
  	p_priority_id              IN NUMBER,
  	p_request_by_date          IN DATE,
  	p_request_log              IN VARCHAR2,
  	p_owning_dept_id           IN NUMBER,
  	p_user_id                  IN NUMBER,
  	p_work_request_type_id     IN NUMBER,
  	p_maintenance_object_type  IN NUMBER DEFAULT 3,
  	p_maintenance_object_id	   IN NUMBER DEFAULT NULL,
	p_eam_linear_id 	   IN NUMBER DEFAULT NULL,
  	p_asset_location     	   IN NUMBER DEFAULT NULL,
        p_expected_resolution_date IN DATE DEFAULT NULL,
        p_work_request_created_by  IN NUMBER DEFAULT 1,
    	p_created_for              IN NUMBER DEFAULT NULL,
        p_phone_number             IN VARCHAR2 DEFAULT NULL,
        p_email                    IN VARCHAR2 DEFAULT NULL,
        p_contact_preference       IN NUMBER DEFAULT NULL,
        p_notify_originator        IN NUMBER DEFAULT NULL,
        p_attribute_category       IN VARCHAR2 DEFAULT NULL,
        p_attribute1               IN VARCHAR2 DEFAULT NULL,
        p_attribute2               IN VARCHAR2 DEFAULT NULL,
        p_attribute3               IN VARCHAR2 DEFAULT NULL,
        p_attribute4               IN VARCHAR2 DEFAULT NULL,
        p_attribute5               IN VARCHAR2 DEFAULT NULL,
        p_attribute6               IN VARCHAR2 DEFAULT NULL,
        p_attribute7               IN VARCHAR2 DEFAULT NULL,
        p_attribute8               IN VARCHAR2 DEFAULT NULL,
        p_attribute9               IN VARCHAR2 DEFAULT NULL,
        p_attribute10              IN VARCHAR2 DEFAULT NULL,
        p_attribute11              IN VARCHAR2 DEFAULT NULL,
        p_attribute12              IN VARCHAR2 DEFAULT NULL,
        p_attribute13              IN VARCHAR2 DEFAULT NULL,
        p_attribute14              IN VARCHAR2 DEFAULT NULL,
        p_attribute15              IN VARCHAR2 DEFAULT NULL,
        x_work_request_id          OUT NOCOPY NUMBER,
  	x_resultout                OUT NOCOPY VARCHAR2,
        x_error_message            OUT NOCOPY VARCHAR2,
        x_return_status            OUT NOCOPY VARCHAR2,
  	x_msg_count                OUT NOCOPY NUMBER,
  	x_msg_data                 OUT NOCOPY VARCHAR2
) ;


PROCEDURE check_product_install(
	p_api_version       IN NUMBER,
  	p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
  	p_commit            IN VARCHAR2 := FND_API.G_FALSE,
  	p_validation_level  IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
        p_appl_id           IN NUMBER,
        p_dep_appl_id       IN Number,
        x_installed         OUT NOCOPY NUMBER,
	x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
);

function validate_desc_flex_field
        (
        p_app_short_name        IN                      VARCHAR:='EAM',
        p_desc_flex_name        IN                      VARCHAR,
        p_ATTRIBUTE_CATEGORY    IN                      VARCHAR2 default null,
        p_ATTRIBUTE1            IN                        VARCHAR2 default null,
        p_ATTRIBUTE2            IN                        VARCHAR2 default null,
        p_ATTRIBUTE3            IN                        VARCHAR2 default null,
        p_ATTRIBUTE4            IN                        VARCHAR2 default null,
        p_ATTRIBUTE5            IN                        VARCHAR2 default null,
        p_ATTRIBUTE6            IN                        VARCHAR2 default null,
        p_ATTRIBUTE7            IN                        VARCHAR2 default null,
        p_ATTRIBUTE8            IN                        VARCHAR2 default null,
        p_ATTRIBUTE9            IN                        VARCHAR2 default null,
        p_ATTRIBUTE10           IN                       VARCHAR2 default null,
        p_ATTRIBUTE11           IN                       VARCHAR2 default null,
        p_ATTRIBUTE12           IN                       VARCHAR2 default null,
        p_ATTRIBUTE13           IN                       VARCHAR2 default null,
        p_ATTRIBUTE14           IN                       VARCHAR2 default null,
        p_ATTRIBUTE15           IN                       VARCHAR2 default null,
        x_error_segments        OUT NOCOPY               NUMBER,
        x_error_message         OUT NOCOPY               VARCHAR2
)
return boolean;



end WIP_EAM_WORKREQUEST_PVT;

 

/
