--------------------------------------------------------
--  DDL for Package Body EAM_ORG_MAINT_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ORG_MAINT_DEFAULTS_PVT" AS
/* $Header: EAMVOMDB.pls 120.1 2006/01/24 10:16:20 yjhabak noship $*/
   -- Start of comments
   -- API name : eam_org_maint_defaults_pvt
   -- Type     : Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN    p_api_version      IN NUMBER    Required
   --       p_init_msg_list    IN VARCHAR2  Optional  Default = FND_API.G_FALSE
   --       p_commit           IN VARCHAR2  Optional  Default = FND_API.G_FALSE
   --       p_validation_level IN NUMBER    Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --       parameter1
   --       parameter2
   --       .
   --       .
   -- OUT   x_return_status   OUT   VARCHAR2(1)
   --       x_msg_count       OUT   NUMBER
   --       x_msg_data        OUT   VARCHAR2(2000)
   --       parameter1
   --       parameter2
   --       .
   --       .
   -- Version  Current version x.x
   --          Changed....
   --          previous version   y.y
   --          Changed....
   --         .
   --         .
   --          previous version   2.0
   --          Changed....
   --          Initial version    1.0
   --
   -- Notes    : Note text
   --
   -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_org_maint_defaults_pvt';


   FUNCTION from_fnd_std_num(p_value NUMBER)
   RETURN NUMBER IS
   BEGIN
     IF (p_value = fnd_api.g_miss_num) THEN
       RETURN null;
     ELSE
       RETURN p_value;
     END IF;
   END from_fnd_std_num;


   FUNCTION from_fnd_std_char(p_value VARCHAR2)
   RETURN VARCHAR2 IS
   BEGIN
     IF (p_value = fnd_api.g_miss_char) THEN
       RETURN null;
     ELSE
       RETURN p_value;
     END IF;
   END from_fnd_std_char;


   PROCEDURE insert_row
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_object_type           IN  NUMBER
     ,p_object_id             IN  NUMBER
     ,p_organization_id       IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_activity_cause_code   IN  VARCHAR2 := NULL
     ,p_activity_type_code    IN  VARCHAR2 := NULL
     ,p_activity_source_code  IN  VARCHAR2 := NULL
     ,p_shutdown_type_code    IN  VARCHAR2 := NULL
     ,p_tagging_required_flag IN  VARCHAR2 := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_org_maint_defaults_pvt;

     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     -- API body

     -- All validation will done by the calling API

     BEGIN

        -- Insert row into EOMD
        INSERT INTO eam_org_maint_defaults
        (
           object_type
          ,object_id
          ,organization_id
          ,owning_department_id
          ,accounting_class_code
          ,area_id
          ,activity_cause_code
          ,activity_type_code
          ,activity_source_code
          ,shutdown_type_code
          ,tagging_required_flag
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
        )
        VALUES
        (
           p_object_type
          ,p_object_id
          ,p_organization_id
          ,p_owning_department_id
          ,p_accounting_class_code
          ,p_area_id
          ,p_activity_cause_code
          ,p_activity_type_code
          ,p_activity_source_code
          ,p_shutdown_type_code
          ,p_tagging_required_flag
          ,fnd_global.user_id
          ,sysdate
          ,fnd_global.user_id
          ,sysdate
          ,fnd_global.login_id
        );

     EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN
        fnd_message.set_name('EAM', 'EAM_EOMD_RECORD_EXISTS');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END;

     -- End of API body.

     -- Standard check of p_commit.
     IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END insert_row;


   PROCEDURE update_row
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_object_type           IN  NUMBER
     ,p_object_id             IN  NUMBER
     ,p_organization_id       IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_activity_cause_code   IN  VARCHAR2 := NULL
     ,p_activity_type_code    IN  VARCHAR2 := NULL
     ,p_activity_source_code  IN  VARCHAR2 := NULL
     ,p_shutdown_type_code    IN  VARCHAR2 := NULL
     ,p_tagging_required_flag IN  VARCHAR2 := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'update_row';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_org_maint_defaults_pvt;

     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     -- API body

     -- All validation will done by the calling API

     BEGIN

        -- Insert row into EOMD
        UPDATE eam_org_maint_defaults SET
           owning_department_id   =   decode(p_owning_department_id, fnd_api.g_miss_num, null, null, owning_department_id, p_owning_department_id)
          ,accounting_class_code  =   decode(p_accounting_class_code, fnd_api.g_miss_char, null, null, accounting_class_code, p_accounting_class_code)
          ,area_id                =   decode(p_area_id, fnd_api.g_miss_num, null, null, area_id, p_area_id)
          ,activity_cause_code    =   decode(p_activity_cause_code, fnd_api.g_miss_char, null, null, activity_cause_code, p_activity_cause_code)
          ,activity_type_code     =   decode(p_activity_type_code, fnd_api.g_miss_char, null, null, activity_type_code, p_activity_type_code)
          ,activity_source_code   =   decode(p_activity_source_code, fnd_api.g_miss_char, null, null, activity_source_code, p_activity_source_code)
          ,shutdown_type_code     =   decode(p_shutdown_type_code, fnd_api.g_miss_char, null, null, shutdown_type_code, p_shutdown_type_code)
          ,tagging_required_flag  =   decode(p_tagging_required_flag, fnd_api.g_miss_char, null, null, tagging_required_flag, p_tagging_required_flag)
          ,created_by             =   fnd_global.user_id
          ,creation_date          =   sysdate
          ,last_updated_by        =   fnd_global.user_id
          ,last_update_date       =   sysdate
          ,last_update_login      =   fnd_global.login_id
        WHERE object_type = p_object_type AND object_id = p_object_id
          AND organization_id = p_organization_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('EAM', 'EAM_EOMD_RECORD_NOT_FOUND');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END;

     -- End of API body.

     -- Standard check of p_commit.
     IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END update_row;


   -- Update if row exists else insert a new row
   PROCEDURE update_insert_row
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_object_type           IN  NUMBER
     ,p_object_id             IN  NUMBER
     ,p_organization_id       IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_activity_cause_code   IN  VARCHAR2 := NULL
     ,p_activity_type_code    IN  VARCHAR2 := NULL
     ,p_activity_source_code  IN  VARCHAR2 := NULL
     ,p_shutdown_type_code    IN  VARCHAR2 := NULL
     ,p_tagging_required_flag IN  VARCHAR2 := NULL
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'update_insert_row';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
     l_count                   NUMBER;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_org_maint_defaults_pvt;

     -- Standard call to check for call compatibility.
     IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := fnd_api.g_ret_sts_success;

     -- API body

     -- All validation will done by the calling API

     SELECT count(*) INTO l_count
       FROM eam_org_maint_defaults
      WHERE object_type = p_object_type AND object_id = p_object_id
        AND organization_id = p_organization_id;

     IF l_count = 0 THEN
        insert_row
        (
	  p_api_version           => 1.0
	 ,p_object_type           => p_object_type
	 ,p_object_id             => p_object_id
	 ,p_organization_id       => p_organization_id
	 ,p_owning_department_id  => from_fnd_std_num(p_owning_department_id)
	 ,p_accounting_class_code => from_fnd_std_char(p_accounting_class_code)
	 ,p_area_id               => from_fnd_std_num(p_area_id)
	 ,p_activity_cause_code   => from_fnd_std_char(p_activity_cause_code)
	 ,p_activity_type_code    => from_fnd_std_char(p_activity_type_code)
	 ,p_activity_source_code  => from_fnd_std_char(p_activity_source_code)
	 ,p_shutdown_type_code    => from_fnd_std_char(p_shutdown_type_code)
	 ,p_tagging_required_flag => from_fnd_std_char(p_tagging_required_flag)
	 ,x_return_status         => x_return_status
	 ,x_msg_count             => x_msg_count
	 ,x_msg_data              => x_msg_data
        );
      ELSE
        update_row
        (
	  p_api_version           => 1.0
	 ,p_object_type           => p_object_type
	 ,p_object_id             => p_object_id
	 ,p_organization_id       => p_organization_id
	 ,p_owning_department_id  => p_owning_department_id
	 ,p_accounting_class_code => p_accounting_class_code
	 ,p_area_id               => p_area_id
	 ,p_activity_cause_code   => p_activity_cause_code
	 ,p_activity_type_code    => p_activity_type_code
	 ,p_activity_source_code  => p_activity_source_code
	 ,p_shutdown_type_code    => p_shutdown_type_code
	 ,p_tagging_required_flag => p_tagging_required_flag
	 ,x_return_status         => x_return_status
	 ,x_msg_count             => x_msg_count
	 ,x_msg_data              => x_msg_data
        );
      END IF;

      IF  x_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
      END IF;

     -- End of API body.

     -- Standard check of p_commit.
     IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_count => x_msg_count
                              ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_org_maint_defaults_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END update_insert_row;


END eam_org_maint_defaults_pvt;


/
