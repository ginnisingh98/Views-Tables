--------------------------------------------------------
--  DDL for Package Body EAM_MAINT_ATTRIBUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MAINT_ATTRIBUTES_PUB" AS
/* $Header: EAMPMATB.pls 120.4 2006/04/17 04:31:03 yjhabak noship $*/

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_maint_attributes_pub';


   -- Start of comments
   -- API name : eam_maint_attributes_pub
   -- Type     : Public.
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

   PROCEDURE create_maint_attributes
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id           IN  NUMBER
     ,p_owning_department_id  IN  NUMBER
     ,p_accounting_class_code IN  VARCHAR2
     ,p_area_id               IN  NUMBER
     ,p_parent_instance_id    IN NUMBER
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'create_maint_attributes';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

     l_org_id                  NUMBER;

     l_sn_1                    VARCHAR2(30);
     l_inv_id_1                NUMBER;
     l_org_id_1                NUMBER;
     l_sn_2                    VARCHAR2(30);
     l_inv_id_2                NUMBER;
     l_org_id_2                NUMBER;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_maint_attributes_pub;

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

     -- Call validate procedure for validating the maint attributes

     validate_maint_defaults
     (
       p_api_version           => 1.0
      ,p_instance_id           => p_instance_id
      ,p_owning_department_id  => p_owning_department_id
      ,p_accounting_class_code => p_accounting_class_code
      ,p_area_id               => p_area_id
      ,p_mode                  => 1
      ,x_org_id                => l_org_id
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
     );

     IF  x_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
     END IF;

     eam_org_maint_defaults_pvt.insert_row
     (
       p_api_version           => 1.0
      ,p_object_type           => 50
      ,p_object_id             => p_instance_id
      ,p_organization_id       => l_org_id
      ,p_owning_department_id  => p_owning_department_id
      ,p_accounting_class_code => p_accounting_class_code
      ,p_area_id               => p_area_id
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
     );

     IF  x_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
     END IF;

     -- Find serial number and inventory_item_id to be passed to the geneloagy API
     IF p_parent_instance_id IS NOT NULL THEN
        BEGIN
           SELECT cii.serial_number, cii.inventory_item_id, cii.last_vld_organization_id
             INTO l_sn_1, l_inv_id_1, l_org_id_1
             FROM csi_item_instances cii, mtl_system_items msi
            WHERE cii.instance_id = p_instance_id AND cii.inventory_item_id = msi.inventory_item_id
              AND cii.last_vld_organization_id = msi.organization_id AND msi.eam_item_type in (1,3)
              AND msi.serial_number_control_code <> 1;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('EAM', 'EAM_INVALID_INSTANCE_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END;
        BEGIN
           SELECT cii.serial_number, cii.inventory_item_id, cii.last_vld_organization_id
             INTO l_sn_2, l_inv_id_2, l_org_id_2
             FROM csi_item_instances cii, mtl_system_items msi, mtl_parameters mp
            WHERE cii.instance_id = p_parent_instance_id AND cii.inventory_item_id = msi.inventory_item_id
              AND cii.last_vld_organization_id = msi.organization_id AND msi.eam_item_type in (1,3)
              AND msi.serial_number_control_code <> 1 AND  msi.organization_id = mp.organization_id
              AND mp.maint_organization_id = l_org_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('EAM', 'EAM_INVLD_PARENT_INST_ID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
        END;

        wip_eam_genealogy_pvt.create_eam_genealogy
        (
           p_api_version               => 1.0,
           p_serial_number             => l_sn_1,
           p_organization_id           => l_org_id_1,
           p_inventory_item_id         => l_inv_id_1,
           p_parent_serial_number      => l_sn_2,
           p_parent_inventory_item_id  => l_inv_id_2,
           p_parent_organization_id    => l_org_id_2,
           p_from_eam                  => FND_API.G_TRUE,
           x_return_status             => x_return_status,
           x_msg_count                 => x_msg_count,
           x_msg_data                  => x_msg_data
        );

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
	   RAISE fnd_api.g_exc_error;
        END IF;

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
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END create_maint_attributes;


   PROCEDURE update_maint_attributes
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id           IN  NUMBER
     ,p_owning_department_id  IN  NUMBER
     ,p_accounting_class_code IN  VARCHAR2
     ,p_area_id               IN  NUMBER
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'update_maint_attributes';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

     l_org_id                  NUMBER;

     l_sn_1                    NUMBER;
     l_inv_id_1                NUMBER;
     l_org_id_1                NUMBER;
     l_sn_2                    NUMBER;
     l_inv_id_2                NUMBER;
     l_org_id_2                NUMBER;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_maint_attributes_pub;

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

     -- Call validate procedure for validating the maint attributes

     validate_maint_defaults
     (
       p_api_version           => 1.0
      ,p_instance_id           => p_instance_id
      ,p_owning_department_id  => p_owning_department_id
      ,p_accounting_class_code => p_accounting_class_code
      ,p_area_id               => p_area_id
      ,p_mode                  => 2
      ,x_org_id                => l_org_id
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
     );

     IF  x_return_status <> fnd_api.g_ret_sts_success THEN
	RAISE fnd_api.g_exc_error;
     END IF;

     eam_org_maint_defaults_pvt.update_insert_row
     (
       p_api_version           => 1.0
      ,p_object_type           => 50
      ,p_object_id             => p_instance_id
      ,p_organization_id       => l_org_id
      ,p_owning_department_id  => p_owning_department_id
      ,p_accounting_class_code => p_accounting_class_code
      ,p_area_id               => p_area_id
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
     );

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
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END update_maint_attributes;



   PROCEDURE validate_maint_defaults
   (
      p_api_version           IN  NUMBER
     ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
     ,p_commit                IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id           IN  NUMBER
     ,p_owning_department_id  IN  NUMBER   := NULL
     ,p_accounting_class_code IN  VARCHAR2 := NULL
     ,p_area_id               IN  NUMBER   := NULL
     ,p_mode                  IN  NUMBER
     ,x_org_id                OUT NOCOPY NUMBER
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

     l_api_name       CONSTANT VARCHAR2(30) := 'validate_maint_defaults';
     l_api_version    CONSTANT NUMBER       := 1.0;
     l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
     l_count                   NUMBER;

   BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT eam_maint_attributes_pub;

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

     -- Validate instance id
     SELECT count(instance_id) INTO l_count FROM csi_item_instances cii, mtl_system_items msi
      WHERE cii.instance_id = p_instance_id AND cii.inventory_item_id = msi.inventory_item_id
        AND cii.last_vld_organization_id = msi.organization_id AND msi.eam_item_type in (1,3)
	AND msi.serial_number_control_code <> 1;
     IF l_count = 0 THEN
        fnd_message.set_name('EAM', 'EAM_INVALID_INSTANCE_ID');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     -- Select the maintenance organization id
     SELECT mp.maint_organization_id INTO x_org_id FROM csi_item_instances cii, mtl_parameters mp
      WHERE cii.instance_id = p_instance_id AND cii.last_vld_organization_id = mp.organization_id;

     IF x_org_id is NULL THEN
        fnd_message.set_name('EAM', 'EAM_MAINT_ORG_MISSING');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
     END IF;

     -- Validate dept id
     IF p_owning_department_id IS NOT NULL THEN
        IF ( NOT(p_mode = 2 AND p_owning_department_id = fnd_api.g_miss_num)) THEN
           SELECT count(department_id) INTO l_count FROM bom_departments
            WHERE department_id = p_owning_department_id AND organization_id = x_org_id
              AND nvl(disable_date, sysdate+1) >= sysdate;

           IF l_count = 0 THEN
             fnd_message.set_name('EAM', 'EAM_ABO_INVALID_OWN_DEPT_ID');
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;
           END IF;
        END IF;
     END IF;

     -- Validate WIP Accounting class
     IF p_accounting_class_code IS NOT NULL THEN
        IF ( NOT(p_mode = 2 AND p_accounting_class_code = fnd_api.g_miss_char)) THEN
           SELECT count(*) INTO l_count FROM wip_accounting_classes
            WHERE class_code = p_accounting_class_code AND class_type = 6
              AND organization_id = x_org_id;

           IF l_count = 0 THEN
              fnd_message.set_name('EAM', 'EAM_ABO_INVALID_CLASS_CODE');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
        END IF;
     END IF;

     -- Validate Area
     IF p_area_id IS NOT NULL THEN
        IF ( NOT(p_mode = 2 AND p_area_id = fnd_api.g_miss_num)) THEN
           SELECT count(*) INTO l_count FROM mtl_eam_locations
            WHERE location_id = p_area_id AND organization_id = x_org_id
              AND sysdate BETWEEN nvl(start_date, sysdate-1) AND nvl(end_date, sysdate+1);

           IF l_count = 0 THEN
              fnd_message.set_name('EAM', 'EAM_LOCATION_ID_INVALID');
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
           END IF;
        END IF;
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
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO eam_maint_attributes_pub;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get(p_count => x_msg_count
                                  ,p_data => x_msg_data);
   END validate_maint_defaults;

END eam_maint_attributes_pub ;

/
