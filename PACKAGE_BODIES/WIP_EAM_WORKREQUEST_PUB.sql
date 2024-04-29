--------------------------------------------------------
--  DDL for Package Body WIP_EAM_WORKREQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_WORKREQUEST_PUB" AS
/* $Header: WIPPWRPB.pls 120.1 2005/06/15 17:16:11 appldev  $ */
 -- Start of comments
 -- API name : WIP_EAM_WORKREQUEST_PUB
 -- Type     : Public
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- OUT      x_return_status   OUT   VARCHAR2(1)
 --          x_msg_count       OUT   NUMBER
 --          x_msg_data        OUT   VARCHAR2(2000)
 --
 -- Version  Current version 1.0  Himal Karmacharya
 --
 -- Notes    : Note text
 --
 -- End of comments


G_PKG_NAME CONSTANT VARCHAR2(30) :='WIP_EAM_WORKREQUEST_PUB';
procedure work_request_import
(
p_api_version in NUMBER := 1.0,
p_init_msg_list in VARCHAR2 := FND_API.G_FALSE,
p_commit in VARCHAR2 := FND_API.G_TRUE,
p_validation_level in NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_mode in VARCHAR2,
p_work_request_rec in WIP_EAM_WORK_REQUESTS%ROWTYPE,
p_request_log in VARCHAR2,
p_user_id in NUMBER,
x_work_request_id out NOCOPY NUMBER,
x_return_status out NOCOPY VARCHAR2,
x_msg_count out NOCOPY NUMBER,
x_msg_data out NOCOPY VARCHAR2
)
is

l_stmt_num NUMBER := 0;

l_return_flag BOOLEAN;
l_return_status VARCHAR2(50);
l_msg_count NUMBER;
l_msg_data VARCHAR2(50);
l_request_id NUMBER;
l_status_id NUMBER;

l_api_version constant number := 1.0;
l_api_name constant varchar2(30) := 'work_request_import';
l_calling_function varchar2(50);
l_error_message VARCHAR2(200);
l_resultout VARCHAR2(1);

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT work_request_import_pvt;

    l_stmt_num := 10;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_stmt_num := 20;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
    END IF;

    l_stmt_num := 30;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- call validate api
    WIP_EAM_WORKREQUEST_PVT.validate_work_request (
           p_api_version => p_api_version,
           p_init_msg_list => p_init_msg_list,
           p_mode => p_mode,
           p_org_id => p_work_request_rec.organization_id,
           p_request_id => p_work_request_rec.work_request_id,
           p_asset_group_id => p_work_request_rec.asset_group,
           p_asset_number => p_work_request_rec.asset_number,
           p_priority_id => p_work_request_rec.work_request_priority_id,
           p_status_id => p_work_request_rec.work_request_status_id,
           p_request_by_date => p_work_request_rec.expected_resolution_date,
           p_request_log => p_request_log,
           p_owning_dept_id => p_work_request_rec.work_request_owning_dept,
           p_work_request_type_id => p_work_request_rec.work_request_type_id,
           p_maintenance_object_type => p_work_request_rec.maintenance_object_type,
           p_maintenance_object_id => p_work_request_rec.maintenance_object_id,
	   p_eam_linear_id => p_work_request_rec.eam_linear_location_id,
           p_attribute_category => p_work_request_rec.attribute_category,
	   p_attribute1 => p_work_request_rec.attribute1,
	   p_attribute2 => p_work_request_rec.attribute2,
	   p_attribute3 => p_work_request_rec.attribute3,
	   p_attribute4 => p_work_request_rec.attribute4,
	   p_attribute5 => p_work_request_rec.attribute5,
	   p_attribute6 => p_work_request_rec.attribute6,
	   p_attribute7 => p_work_request_rec.attribute7,
	   p_attribute8 => p_work_request_rec.attribute8,
	   p_attribute9 => p_work_request_rec.attribute9,
	   p_attribute10 => p_work_request_rec.attribute10,
	   p_attribute11 => p_work_request_rec.attribute11,
	   p_attribute12 => p_work_request_rec.attribute12,
	   p_attribute13 => p_work_request_rec.attribute13,
	   p_attribute14 => p_work_request_rec.attribute14,
	   p_attribute15 => p_work_request_rec.attribute15,
	   p_created_for => p_work_request_rec.created_for,
	   p_phone_number => p_work_request_rec.phone_number,
	   p_email => p_work_request_rec.e_mail,
	   p_contact_preference => p_work_request_rec.contact_preference,
  	   p_notify_originator => p_work_request_rec.notify_originator,
           x_return_flag => l_return_flag,
           x_return_status => l_return_status,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data
    );


    l_stmt_num := 40;

    IF l_return_flag THEN

            IF p_mode = 'CREATE' THEN

                 WIP_EAM_WORKREQUEST_PVT.create_and_approve (
                      p_api_version => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      p_commit => p_commit,
                      p_validation_level => p_validation_level,
                      p_org_id => p_work_request_rec.organization_id,
                      p_asset_group_id => p_work_request_rec.asset_group,
                      p_asset_number => p_work_request_rec.asset_number,
                      p_priority_id => p_work_request_rec.work_request_priority_id,
                      p_request_by_date => p_work_request_rec.expected_resolution_date,
                      p_request_log => p_request_log,
                      p_owning_dept_id => p_work_request_rec.work_request_owning_dept,
                      p_user_id => p_user_id,
                      p_work_request_type_id => p_work_request_rec.work_request_type_id,
                      p_maintenance_object_type => p_work_request_rec.maintenance_object_type,
           		p_maintenance_object_id => p_work_request_rec.maintenance_object_id,
		      p_eam_linear_id => p_work_request_rec.eam_linear_location_id,
                      p_expected_resolution_date => p_work_request_rec.expected_resolution_date,
                      p_created_for => p_work_request_rec.created_for,
                      p_phone_number => p_work_request_rec.phone_number,
                      p_email         => p_work_request_rec.e_mail,
		      p_contact_preference => p_work_request_rec.contact_preference,
		      p_notify_originator => p_work_request_rec.notify_originator,
		      p_attribute_category => p_work_request_rec.attribute_category,
		      p_attribute1 => p_work_request_rec.attribute1,
		      p_attribute2  => p_work_request_rec.attribute2,
		      p_attribute3  => p_work_request_rec.attribute3,
		      p_attribute4  => p_work_request_rec.attribute4,
		      p_attribute5  => p_work_request_rec.attribute5,
		      p_attribute6  => p_work_request_rec.attribute6,
		      p_attribute7  => p_work_request_rec.attribute7,
		      p_attribute8   => p_work_request_rec.attribute8,
		      p_attribute9  => p_work_request_rec.attribute9,
		      p_attribute10  => p_work_request_rec.attribute10,
		      p_attribute11  => p_work_request_rec.attribute11,
		      p_attribute12  => p_work_request_rec.attribute12,
		      p_attribute13  => p_work_request_rec.attribute13,
		      p_attribute14  => p_work_request_rec.attribute14,
  		      p_attribute15 => p_work_request_rec.attribute15,
                      x_work_request_id => l_request_id,
                      x_resultout	=> l_resultout,
                      x_error_message	=> l_error_message,
                      x_return_status => l_return_status,
                      x_msg_count => l_msg_count,
                      x_msg_data => l_msg_data
                );
                 x_work_request_id := l_request_id;

            ELSIF p_mode = 'UPDATE' THEN

                  /*WIP_EAM_WORKREQUEST_PVT.update_work_request (
                      p_api_version => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      p_commit => p_commit,
                      p_validation_level => p_validation_level,
                      p_org_id => decode(p_work_request_rec.organization_id,null,organization_id,p_work_request_rec.organization_id),
                      p_asset_group_id => decode(p_work_request_rec.asset_group,null,asset_group,p_work_request_rec.asset_group),
                      p_asset_number => decode(p_work_request_rec.asset_number,asset_number,p_work_request_rec.asset_number),
                      p_request_id => p_work_request_rec.work_request_id,
                      p_status_id => decode(p_work_request_rec.work_request_status_id,null,work_request_status_id,p_work_request_rec.work_request_status_id),
                      p_priority_id => decode(p_work_request_rec.work_request_priority_id,null,work_request_priority_id,p_work_request_rec.priority_id),
                      p_request_by_date => decode(p_work_request_rec.expected_resolution_date,null,expected_resolution_date,p_work_request_rec.expected_resolution_date),
                      p_request_log => decode(p_request_log,null,description,p_request_log),
                      p_work_request_type_id => decode(p_work_request_rec.work_request_type_id,null,work_request_type_id,p_work_request_rec.work_request_type_id),
                      p_owning_dept_id => decode(p_work_request_rec.work_request_owning_dept,null,work_request_owning_dept,p_work_request_rec.work_request_owning_dept),
                      p_created_for => decode(p_work_request_rec.created_for,null,created_for,p_work_request_rec.created_for),
		      p_phone_number => decode(p_work_request_rec.phone_number,null,p_phone_number,p_work_request_rec.phone_number),
		      p_email => decode(p_work_request_rec.e_mail,null,e_mail,p_work_request_rec.e_mail),
		      p_contact_preference => decode(p_work_request_rec.contact_preference,null,contact_preference,p_work_request_rec.contact_preference),
		      p_notify_originator => decode(p_work_request_rec.notify_originator,null,notify_originator,p_work_request_rec.notify_originator),
		      p_attribute_category => decode(p_work_request_rec.attribute_category,null,attribute_category,p_work_request_rec.attribute_category),
		      p_attribute1 => decode(p_work_request_rec.attribute1, NULL, ATTRIBUTE1, p_work_request_rec.attribute1),
		      p_attribute2 => decode(p_work_request_rec.attribute2, NULL, ATTRIBUTE2, p_work_request_rec.attribute2),
		      p_attribute3 => decode(p_work_request_rec.attribute3, NULL, ATTRIBUTE3, p_work_request_rec.attribute3),
		      p_attribute4 => decode(p_work_request_rec.attribute4, NULL, ATTRIBUTE4, p_work_request_rec.attribute4),
		      p_attribute5 => decode(p_work_request_rec.attribute5, NULL, ATTRIBUTE5, p_work_request_rec.attribute5),
		      p_attribute6 => decode(p_work_request_rec.attribute6, NULL, ATTRIBUTE6, p_work_request_rec.attribute6),
		      p_attribute7 => decode(p_work_request_rec.attribute7, NULL, ATTRIBUTE7, p_work_request_rec.attribute7),
		      p_attribute8 => decode(p_work_request_rec.attribute8, NULL, ATTRIBUTE8, p_work_request_rec.attribute8),
		      p_attribute9 => decode(p_work_request_rec.attribute9, NULL, ATTRIBUTE9, p_work_request_rec.attribute9),
		      p_attribute10 => decode(p_work_request_rec.attribute10, NULL, ATTRIBUTE10, p_work_request_rec.attribute10),
		      p_attribute11 => decode(p_work_request_rec.attribute11, NULL, ATTRIBUTE11, p_work_request_rec.attribute11),
		      p_attribute12 => decode(p_work_request_rec.attribute12, NULL, ATTRIBUTE12, p_work_request_rec.attribute12),
		      p_attribute13 => decode(p_work_request_rec.attribute13, NULL, ATTRIBUTE13, p_work_request_rec.attribute13),
		      p_attribute14 => decode(p_work_request_rec.attribute14, NULL, ATTRIBUTE14, p_work_request_rec.attribute14),
  		      p_attribute15 => decode(p_work_request_rec.attribute15, NULL, ATTRIBUTE15, p_work_request_rec.attribute15),
                      x_return_status => l_return_status,
                      x_msg_count => l_msg_count,
                      x_msg_data => l_msg_data
                );*/
                WIP_EAM_WORKREQUEST_PVT.update_work_request (
		                      p_api_version => p_api_version,
		                      p_init_msg_list => p_init_msg_list,
		                      p_commit => p_commit,
		                      p_validation_level => p_validation_level,
		                      p_org_id => p_work_request_rec.organization_id,
		                      p_asset_group_id => p_work_request_rec.asset_group,
		                      p_asset_number => p_work_request_rec.asset_number,
		                      p_request_id => p_work_request_rec.work_request_id,
		                      p_status_id => p_work_request_rec.work_request_status_id,
		                      p_priority_id => p_work_request_rec.work_request_priority_id,
		                      p_request_by_date => p_work_request_rec.expected_resolution_date,
		                      p_request_log => p_request_log,
		                      p_work_request_type_id => p_work_request_rec.work_request_type_id,
				      p_eam_linear_id => p_work_request_rec.eam_linear_location_id,
		                      p_owning_dept_id => p_work_request_rec.work_request_owning_dept,
		                      p_created_for => p_work_request_rec.created_for,
				      p_phone_number => p_work_request_rec.phone_number,
				      p_email => p_work_request_rec.e_mail,
				      p_contact_preference => p_work_request_rec.contact_preference,
				      p_notify_originator => p_work_request_rec.notify_originator,
				      p_attribute_category => p_work_request_rec.attribute_category,
				      p_attribute1 => p_work_request_rec.attribute1,
				      p_attribute2 => p_work_request_rec.attribute2,
				      p_attribute3 => p_work_request_rec.attribute3,
				      p_attribute4 => p_work_request_rec.attribute4,
				      p_attribute5 => p_work_request_rec.attribute5,
				      p_attribute6 => p_work_request_rec.attribute6,
				      p_attribute7 => p_work_request_rec.attribute7,
				      p_attribute8 => p_work_request_rec.attribute8,
				      p_attribute9 => p_work_request_rec.attribute9,
				      p_attribute10 => p_work_request_rec.attribute10,
				      p_attribute11 => p_work_request_rec.attribute11,
				      p_attribute12 => p_work_request_rec.attribute12,
				      p_attribute13 => p_work_request_rec.attribute13,
				      p_attribute14 => p_work_request_rec.attribute14,
		  		      p_attribute15 => p_work_request_rec.attribute15,
		  		      p_from_public_api => 'Y',
		                      x_return_status => l_return_status,
		                      x_msg_count => l_msg_count,
		                      x_msg_data => l_msg_data
                );
                x_work_request_id := p_work_request_rec.work_request_id;

            END IF;

            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
          ELSE
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
          END IF;

          -- raise an error flag if any of the called procedures fails
          IF l_return_status = 'E' THEN
                RAISE FND_API.g_exc_error;
          ELSIF l_return_status = 'U' THEN
                RAISE FND_API.g_exc_unexpected_error;
          END IF;

          IF fnd_api.to_boolean(p_commit) THEN
                COMMIT WORK;
          END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO work_request_import_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO work_request_import_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
    WHEN OTHERS THEN
         ROLLBACK TO work_request_import_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

end work_request_import;

end;

/
