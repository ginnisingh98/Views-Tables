--------------------------------------------------------
--  DDL for Package Body CSI_GENERIC_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_GENERIC_GRP" AS
/* $Header: csiggenb.pls 120.1 2006/06/06 23:29:09 sguthiva noship $ */

    FUNCTION CONFIG_ROOT_NODE (p_instance_id             IN  NUMBER ,
                               p_relationship_type_code  IN  VARCHAR2
                              )
    RETURN NUMBER IS
    l_object_id    NUMBER:= -1;
    BEGIN
        SELECT object_id
        INTO   l_object_id
        FROM   csi_ii_relationships
        WHERE LEVEL = ( SELECT MAX(LEVEL)
                        FROM   csi_ii_relationships
                        START WITH subject_id = p_instance_id
                        CONNECT BY subject_id = PRIOR object_id
                      )
        AND    relationship_type_code = p_relationship_type_code
        START WITH subject_id = p_instance_id
        CONNECT BY subject_id = PRIOR object_id;
        RETURN l_object_id;
    EXCEPTION
      WHEN OTHERS THEN
           RETURN l_object_id;
    END CONFIG_ROOT_NODE;

    -- This function is used only by the form CSIMEDIT.fmb

    FUNCTION R_COUNT  ( L_SELECT IN VARCHAR2)
        RETURN  Number IS
        l_count Number := 0;
    BEGIN
        EXECUTE IMMEDIATE l_select
        Into    l_count;
        RETURN l_count ;
    Exception
      When Others then
          l_count := 0;
          RETURN l_count ;
    END R_COUNT;


PROCEDURE validate_ext_attribs(
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2  ,
    p_ext_attrib_rec             IN   csi_datastructures_pub.ext_attrib_rec,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE validate_attribute_level (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_ext_attrib_rec             IN   csi_datastructures_pub.ext_attrib_rec,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_attribute_code (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_attribute_code             IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_attribute_category (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_attribute_category         IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE validate_attribute_name (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_attribute_name             IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );


PROCEDURE Create_extended_attrib(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN     VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN     NUMBER       := fnd_api.g_valid_level_full,
    p_ext_attrib_rec             IN     csi_datastructures_pub.ext_attrib_rec,
    x_attribute_id               OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2)
 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_extended_attrib';
l_api_version               CONSTANT NUMBER       := 1.0;
l_debug_level                        VARCHAR2(1);
l_master_org_id                      NUMBER;
l_inv_item_id                        NUMBER;
l_item_category_id                   NUMBER;
l_instance_id                        NUMBER;
l_validation_flag                    VARCHAR2(1);

 BEGIN
 SAVEPOINT Create_extended_attrib_grp;

      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        IF (l_debug_level > 0) THEN
          csi_gen_utility_pvt.put_line( 'Create_extended_attrib');
        END IF;

        IF (l_debug_level > 1) THEN
             csi_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_Commit                  ||'-'||
                                p_Init_Msg_list           ||'-'||
                                p_Validation_level
                                );
            --csi_gen_utility_pvt.dump_ext_attrib_rec(p_ext_attrib_rec);
        END IF;
        IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF ( (p_ext_attrib_rec.attribute_level IS NULL
           OR p_ext_attrib_rec.attribute_level = fnd_api.g_miss_char )
          OR (p_ext_attrib_rec.attribute_code IS NULL
           OR p_ext_attrib_rec.attribute_code = fnd_api.g_miss_char) )
        THEN
           l_validation_flag:='Y';
        ELSE
           IF (p_ext_attrib_rec.master_organization_id IS NULL
            OR p_ext_attrib_rec.master_organization_id = fnd_api.g_miss_num)
           THEN
               l_master_org_id := NULL;
           ELSE
               l_master_org_id := p_ext_attrib_rec.master_organization_id;
           END IF;

           IF (p_ext_attrib_rec.inventory_item_id IS NULL
            OR p_ext_attrib_rec.inventory_item_id = fnd_api.g_miss_num)
           THEN
               l_inv_item_id := NULL;
           ELSE
               l_inv_item_id := p_ext_attrib_rec.inventory_item_id;
           END IF;

           IF (p_ext_attrib_rec.item_category_id IS NULL
            OR p_ext_attrib_rec.item_category_id = fnd_api.g_miss_num)
           THEN
               l_item_category_id := NULL;
           ELSE
               l_item_category_id := p_ext_attrib_rec.item_category_id;
           END IF;

           IF (p_ext_attrib_rec.instance_id IS NULL
            OR p_ext_attrib_rec.instance_id=fnd_api.g_miss_num)
           THEN
               l_instance_id := NULL;
           ELSE
               l_instance_id := p_ext_attrib_rec.instance_id;
           END IF;

           BEGIN
              SELECT attribute_id
              INTO   x_attribute_id
              FROM   csi_i_extended_attribs
              WHERE  attribute_level=p_ext_attrib_rec.attribute_level
              AND    (l_master_org_id IS NULL
                     OR
                      (   l_master_org_id IS NOT NULL
                      AND master_organization_id =l_master_org_id) )
              AND    (l_inv_item_id IS NULL
                     OR
                      (   l_inv_item_id IS NOT NULL
                      AND inventory_item_id =l_inv_item_id) )
              AND    (l_item_category_id IS NULL
                     OR
                      (   l_item_category_id IS NOT NULL
                      AND item_category_id =l_item_category_id) )
              AND    (l_instance_id IS NULL
                     OR
                     (    l_instance_id IS NOT NULL
                     AND  instance_id =l_instance_id) )
              AND   attribute_code =p_ext_attrib_rec.attribute_code;

              l_validation_flag:='N';
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
              l_validation_flag:='Y';
           END;

        END IF;

      IF l_validation_flag = 'Y' THEN
        validate_ext_attribs(
            p_init_msg_list    => fnd_api.g_false,
            p_validation_level => p_validation_level,
            p_validation_mode  => 'CREATE',
            p_ext_attrib_rec   => p_ext_attrib_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

        IF x_return_status<>fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;


        IF x_return_status = fnd_api.g_ret_sts_success THEN
      -- invoke table handler(csi_systems_b_pkg.insert_row)

          csi_i_ext_attrib_pkg.insert_row(
            px_attribute_id               =>  x_attribute_id ,
            p_attribute_level             =>  p_ext_attrib_rec.attribute_level,
            p_master_organization_id      =>  p_ext_attrib_rec.master_organization_id,
            p_inventory_item_id           =>  p_ext_attrib_rec.inventory_item_id,
            p_item_category_id            =>  p_ext_attrib_rec.item_category_id,
            p_instance_id                 =>  p_ext_attrib_rec.instance_id,
            p_attribute_code              =>  p_ext_attrib_rec.attribute_code,
            p_attribute_name              =>  p_ext_attrib_rec.attribute_name,
            p_attribute_category          =>  p_ext_attrib_rec.attribute_category,
            p_description                 =>  p_ext_attrib_rec.description,
            p_active_start_date           =>  p_ext_attrib_rec.active_start_date,
            p_active_end_date             =>  p_ext_attrib_rec.active_end_date,
            p_context                     =>  p_ext_attrib_rec.context,
            p_attribute1                  =>  p_ext_attrib_rec.attribute1,
            p_attribute2                  =>  p_ext_attrib_rec.attribute2,
            p_attribute3                  =>  p_ext_attrib_rec.attribute3,
            p_attribute4                  =>  p_ext_attrib_rec.attribute4,
            p_attribute5                  =>  p_ext_attrib_rec.attribute5,
            p_attribute6                  =>  p_ext_attrib_rec.attribute6,
            p_attribute7                  =>  p_ext_attrib_rec.attribute7,
            p_attribute8                  =>  p_ext_attrib_rec.attribute8,
            p_attribute9                  =>  p_ext_attrib_rec.attribute9,
            p_attribute10                 =>  p_ext_attrib_rec.attribute10,
            p_attribute11                 =>  p_ext_attrib_rec.attribute11,
            p_attribute12                 =>  p_ext_attrib_rec.attribute12,
            p_attribute13                 =>  p_ext_attrib_rec.attribute13,
            p_attribute14                 =>  p_ext_attrib_rec.attribute14,
            p_attribute15                 =>  p_ext_attrib_rec.attribute15,
            p_created_by                  =>  fnd_global.user_id,
            p_creation_date               =>  SYSDATE,
            p_last_updated_by             =>  fnd_global.user_id,
            p_last_update_date            =>  SYSDATE,
            p_last_update_login           =>  fnd_global.conc_login_id,
            p_object_version_number       =>  1
            );


        END IF;

          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;
      END IF; --End of End If for l_validation_flag = 'Y'
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO Create_extended_attrib_grp;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO Create_extended_attrib_grp;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO Create_extended_attrib_grp;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

 END Create_extended_attrib;

-- This function is used by systems form UI.

FUNCTION ui_system_rec RETURN csi_datastructures_pub.system_rec
  IS
    l_system_rec csi_datastructures_pub.system_rec;
  BEGIN
    RETURN l_system_rec;
  END ui_system_rec;

-- This function is used by form UI.

FUNCTION ui_transaction_rec RETURN csi_datastructures_pub.transaction_rec
  IS
    l_transaction_rec csi_datastructures_pub.transaction_rec;
  BEGIN
    RETURN l_transaction_rec;
  END ui_transaction_rec;

  -- This function is used by form UI.

FUNCTION ui_ext_attrib_query_rec RETURN csi_datastructures_pub.extend_attrib_query_rec
  IS
    l_extend_attrib_query_rec csi_datastructures_pub.extend_attrib_query_rec;
  BEGIN
    RETURN l_extend_attrib_query_rec;
  END ui_ext_attrib_query_rec;

FUNCTION ui_relationship_query_rec RETURN csi_datastructures_pub.relationship_query_rec
  IS
    l_relationship_query_rec csi_datastructures_pub.relationship_query_rec;
  BEGIN
    RETURN l_relationship_query_rec;
  END ui_relationship_query_rec;

-- ---------------------------------------------------------------------------------------------------
-- Validate attribute_level:
-- If 'GLOBAL' is passed then values for master_organization_id, inventory_item_id,
-- item_category_id and instance_id should be passed as null else raise an error
-- If 'CATEGORY' is passed then values for master_organization_id, inventory_item_id
-- and instance_id should be passed as null else raise an error.
-- If 'ITEM" is passed then values for item_category_id and instance_id
-- should be passed as null else raise an error
-- If 'INSTANCE' is passed then values for master_organization_id ,inventory_item_id
-- and item_category_id should be passed as null else raise an error.
-- --------------------------------------------------------------------------------------------------

PROCEDURE validate_attribute_level (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_ext_attrib_rec             IN   csi_datastructures_pub.ext_attrib_rec,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
l_lookup_code       VARCHAR2(30):=NULL;
l_ext_lookup_type   VARCHAR2(30):= 'CSI_IEA_LEVEL_CODE';
BEGIN
        IF fnd_api.to_boolean( p_init_msg_list )
        THEN
          fnd_msg_pub.initialize;
        END IF;
        x_return_status := fnd_api.g_ret_sts_success;

        IF p_validation_mode='CREATE' THEN
         IF ( (p_ext_attrib_rec.attribute_level IS NOT NULL) AND (p_ext_attrib_rec.attribute_level<>fnd_api.g_miss_char) )
         THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_lookups
                WHERE   lookup_type = l_ext_lookup_type
                AND     lookup_code = p_ext_attrib_rec.attribute_level;
                IF p_ext_attrib_rec.attribute_level = 'GLOBAL'
                THEN
                    IF (  (p_ext_attrib_rec.master_organization_id IS NOT NULL
                       AND p_ext_attrib_rec.master_organization_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.inventory_item_id IS NOT NULL
                       AND p_ext_attrib_rec.inventory_item_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.item_category_id IS NOT NULL
                       AND p_ext_attrib_rec.item_category_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.instance_id IS NOT NULL
                       AND p_ext_attrib_rec.instance_id <> fnd_api.g_miss_num)
                       )
                    THEN
                       fnd_message.set_name('CSI', 'CSI_PASS_NULL_PARAMS');
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                    END IF;
                 END IF; --End if Global

                 IF p_ext_attrib_rec.attribute_level = 'CATEGORY'
                 THEN
                    IF (  (p_ext_attrib_rec.master_organization_id IS NOT NULL
                       AND p_ext_attrib_rec.master_organization_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.inventory_item_id IS NOT NULL
                       AND p_ext_attrib_rec.inventory_item_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.instance_id IS NOT NULL
                       AND p_ext_attrib_rec.instance_id <> fnd_api.g_miss_num)
                       )
                    THEN
                       fnd_message.set_name('CSI', 'CSI_PASS_CAT_PARAMS');
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                    ELSIF  ( (p_ext_attrib_rec.item_category_id IS NULL)
                         OR  (p_ext_attrib_rec.item_category_id = fnd_api.g_miss_num) )
                    THEN
                       fnd_message.set_name('CSI', 'CSI_MISSING_CAT_PARAMETER');
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                    ELSE
                         l_dummy := NULL;
                         BEGIN
                             SELECT 'x'
                             INTO   l_dummy
                             FROM   mtl_category_set_valid_cats
                             WHERE  category_id = p_ext_attrib_rec.item_category_id
                             AND    category_set_id = ( SELECT category_set_id
                                                        FROM   csi_install_parameters );
                         EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                             fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETER');
                             fnd_message.set_token('PARAMETER',p_ext_attrib_rec.item_category_id);
                             fnd_msg_pub.add;
                             x_return_status := fnd_api.g_ret_sts_error;
                         END;
                    END IF;
                 END IF; --End If Category

                 IF p_ext_attrib_rec.attribute_level = 'ITEM'
                 THEN
                    IF (  (p_ext_attrib_rec.item_category_id IS NOT NULL
                       AND p_ext_attrib_rec.item_category_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.instance_id IS NOT NULL
                       AND p_ext_attrib_rec.instance_id <> fnd_api.g_miss_num)
                       )
                    THEN
                       fnd_message.set_name('CSI', 'CSI_PASS_ITEM_PARAMS');
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                    ELSIF  ( (p_ext_attrib_rec.inventory_item_id IS NULL
                           OR p_ext_attrib_rec.inventory_item_id = fnd_api.g_miss_num)
                        OR   (p_ext_attrib_rec.master_organization_id IS NULL
                           OR p_ext_attrib_rec.master_organization_id = fnd_api.g_miss_num) )
                    THEN
                       fnd_message.set_name('CSI', 'CSI_MISSING_ITEM_PARAMETER');
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                    ELSE
                         l_dummy := NULL;
                         BEGIN
                             SELECT 'x'
                             INTO   l_dummy
                             FROM   mtl_system_items
                             WHERE  organization_id = p_ext_attrib_rec.master_organization_id
                             AND    inventory_item_id = p_ext_attrib_rec.inventory_item_id;
                         EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                             fnd_message.set_name('CSI', 'CSI_INVALID_ITEM_PARAMETER');
                             fnd_msg_pub.add;
                             x_return_status := fnd_api.g_ret_sts_error;
                         END;
                    END IF;
                 END IF; --End If Item

                 IF p_ext_attrib_rec.attribute_level = 'INSTANCE'
                 THEN
                    IF (  (p_ext_attrib_rec.master_organization_id IS NOT NULL
                       AND p_ext_attrib_rec.master_organization_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.inventory_item_id IS NOT NULL
                       AND p_ext_attrib_rec.inventory_item_id <> fnd_api.g_miss_num)
                     OR   (p_ext_attrib_rec.item_category_id IS NOT NULL
                       AND p_ext_attrib_rec.item_category_id <> fnd_api.g_miss_num)
                       )
                    THEN
                       fnd_message.set_name('CSI', 'CSI_PASS_INS_PARAMS');
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                    ELSIF  ( (p_ext_attrib_rec.instance_id IS NULL
                           OR p_ext_attrib_rec.instance_id = fnd_api.g_miss_num) )
                    THEN
                       fnd_message.set_name('CSI', 'CSI_MISSING_INS_PARAMETER');
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                    ELSE
                         l_dummy := NULL;
                         BEGIN
                             SELECT 'x'
                             INTO   l_dummy
                             FROM   csi_item_instances
                             WHERE  instance_id = p_ext_attrib_rec.instance_id;
                         EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                             fnd_message.set_name('CSI', 'CSI_INVALID_INS_PARAMETER');
                             fnd_message.set_token('PARAMETER',p_ext_attrib_rec.instance_id);
                             fnd_msg_pub.add;
                             x_return_status := fnd_api.g_ret_sts_error;
                         END;
                    END IF;
                 END IF; -- end if instance
                EXCEPTION
                WHEN no_data_found THEN
                       fnd_message.set_name('CSI', 'CSI_INVALID_AL_PARAMETER');
                       fnd_message.set_token('PARAMETER',p_ext_attrib_rec.attribute_level);
                       fnd_msg_pub.add;
                       x_return_status := fnd_api.g_ret_sts_error;
                END;--End for csi_lookups
         ELSE -- Else if p_ext_attrib_rec.attribute_level IS NULL
             fnd_message.set_name('CSI', 'CSI_MISSING_PARAMETER');
             fnd_message.set_token('PARAMETER','ATTRIBUTE_LEVEL');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
         END IF;--End if p_ext_attrib_rec.attribute_level IS NOT NULL
        END IF; --End if p_validation_mode='CREATE'

        fnd_msg_pub.count_and_get
         (  p_count          =>   x_msg_count,
            p_data           =>   x_msg_data
          );
END;

PROCEDURE validate_attribute_code (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_attribute_code             IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
l_attrib_lookup_type VARCHAR2(30):= 'CSI_EXTEND_ATTRIB_POOL';
BEGIN
        IF fnd_api.to_boolean( p_init_msg_list )
        THEN
          fnd_msg_pub.initialize;
        END IF;
        x_return_status := fnd_api.g_ret_sts_success;

        IF p_validation_mode='CREATE' THEN
          IF ( (p_attribute_code IS NOT NULL) AND (p_attribute_code<>fnd_api.g_miss_char) ) THEN
            BEGIN
            SELECT 'x'
            INTO   l_dummy
            FROM   csi_lookups
            WHERE  lookup_type=l_attrib_lookup_type
            AND    lookup_code=p_attribute_code;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETER');
             fnd_message.set_token('PARAMETER',p_attribute_code);
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
            END;
          ELSE
             fnd_message.set_name('CSI', 'CSI_MISSING_PARAMETER');
             fnd_message.set_token('PARAMETER','ATTRIBUTE_CODE');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          END IF;
        END IF;
END;

PROCEDURE validate_attribute_category (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_attribute_category         IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
l_cat_lookup_type   VARCHAR2(30) := 'CSI_IEA_CATEGORY';
BEGIN
        IF fnd_api.to_boolean( p_init_msg_list )
        THEN
          fnd_msg_pub.initialize;
        END IF;
        x_return_status := fnd_api.g_ret_sts_success;

        IF p_validation_mode='CREATE' THEN
          IF ( (p_attribute_category IS NOT NULL) AND (p_attribute_category<>fnd_api.g_miss_char) ) THEN
            BEGIN
            SELECT 'x'
            INTO   l_dummy
            FROM   csi_lookups
            WHERE  lookup_type= l_cat_lookup_type
            AND    lookup_code=p_attribute_category;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('CSI', 'CSI_INVALID_PARAMETER');
             fnd_message.set_token('PARAMETER',p_attribute_category);
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
            END;
          END IF;
        END IF;
END;

PROCEDURE validate_attribute_name (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2  ,
    p_attribute_name             IN   VARCHAR2  ,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy             VARCHAR2(1);
BEGIN
        IF fnd_api.to_boolean( p_init_msg_list )
        THEN
          fnd_msg_pub.initialize;
        END IF;
        x_return_status := fnd_api.g_ret_sts_success;

        IF p_validation_mode='CREATE' THEN
          IF ( (p_attribute_name IS NULL) OR (p_attribute_name = fnd_api.g_miss_char) ) THEN
             fnd_message.set_name('CSI', 'CSI_MISSING_PARAMETER');
             fnd_message.set_token('PARAMETER','ATTRIBUTE_NAME');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          END IF;
        END IF;
END;


PROCEDURE validate_ext_attribs(
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2  ,
    p_ext_attrib_rec             IN   csi_datastructures_pub.ext_attrib_rec,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'validate_ext_attribs';
 BEGIN

--dmsg('inside validate_systems');

      -- initialize api RETURN status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN

          validate_attribute_level(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_ext_attrib_rec         => p_ext_attrib_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_attribute_code(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_attribute_code         => p_ext_attrib_rec.attribute_code,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_attribute_category(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_attribute_category     => p_ext_attrib_rec.attribute_category,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

          validate_attribute_name(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_attribute_name         => p_ext_attrib_rec.attribute_name,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;
       END IF;

  END validate_ext_attribs;

  PROCEDURE terminate_instances(
    errbuf      OUT NOCOPY VARCHAR2,
    retcode     OUT NOCOPY NUMBER,
    p_status_id IN  NUMBER)
  IS

    CURSOR exp_inst_cur(p_expired_status_id IN NUMBER) IS
      SELECT cii.instance_id,
             cii.instance_number,
             cii.active_end_date,
             cii.object_version_number
      FROM   csi_item_instances cii
      WHERE  nvl(cii.active_end_date , sysdate)  < sysdate
      AND    cii.instance_status_id <> p_expired_status_id
      AND    not exists ( SELECT 'X' from csi_instance_statuses cis
                          WHERE  cis.instance_status_id = cii.instance_status_id
                          AND    cis.terminated_flag = 'Y');

     l_exp_instance_rec    csi_datastructures_pub.instance_rec;
     l_exp_inst_ids_list   csi_datastructures_pub.id_tbl;
     l_exp_txn_rec         csi_datastructures_pub.transaction_rec;
     l_expired_status_id   NUMBER;
     l_exp_instances_count NUMBER;
     l_parent_found        CHAR := 'N';

     l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(2000);

     l_error_flag          char := 'N';
     l_error_message       varchar2(2000);
     v_commit_counter      number := 0;

  BEGIN

    SAVEPOINT terminate_instances;

    fnd_file.put_line(fnd_file.log, 'Begining of Terminate Expired Instances.');

    --l_expired_status_id := fnd_profile.value('CSI_INST_EXPIRED_STATUS');

    IF p_status_id is NOT NULL Then
       l_expired_status_id := p_status_id;
    ELSE
       l_expired_status_id := fnd_profile.value('CSI_SYS_TERM_INST_STATUS_ID');
    END iF;

    IF l_expired_status_id is NOT NULL THEN

      FOR exp_inst_rec in exp_inst_cur(l_expired_status_id)
      LOOP

        fnd_file.put_line(fnd_file.log,'Processing instance '||exp_inst_rec.instance_number); --to_char(exp_inst_rec.instance_id));

        BEGIN

          /* check if this instance is a child of some instance , if yes do not terminate it*/

          BEGIN

            SELECT 'Y'
            INTO   l_parent_found
            FROM   csi_ii_relationships
            WHERE  subject_id             = exp_inst_rec.instance_id
            AND    relationship_type_code = 'COMPONENT_OF'
            AND    sysdate between nvl(active_start_date, sysdate -1)
                           and     nvl(active_end_date, sysdate + 1);

          EXCEPTION
            WHEN no_data_found THEN
              l_parent_found := 'N';
            WHEN too_many_rows THEN
              l_parent_found := 'Y';
          END;

          IF l_parent_found <> 'Y' THEN

            l_exp_txn_rec.transaction_id             := fnd_api.g_miss_num;
            l_exp_txn_rec.transaction_type_id        := 5;
            l_exp_txn_rec.transaction_date           := sysdate;
            l_exp_txn_rec.source_transaction_date    := sysdate;
            l_exp_txn_rec.source_header_ref_id       := fnd_api.g_miss_num;
            l_exp_txn_rec.source_header_ref          := fnd_global.conc_request_id; --'TERMINATE_INSTANCES';
            l_exp_txn_rec.source_line_ref_id         := fnd_api.g_miss_num;
            l_exp_txn_rec.source_line_ref            := fnd_api.g_miss_char;

            l_exp_instance_rec.instance_id           := exp_inst_rec.instance_id;
            l_exp_instance_rec.active_end_date       := exp_inst_rec.active_end_date;
            l_exp_instance_rec.object_version_number := exp_inst_rec.object_version_number;
            l_exp_instance_rec.instance_status_id    := l_expired_status_id;

            fnd_file.put_line(fnd_file.log,'Calling csi_item_instance_pub.expire item instance.');

            csi_item_instance_pub.expire_item_instance(
              p_api_version      => 1.0,
              p_commit           => fnd_api.g_false,
              p_init_msg_list    => fnd_api.g_true,
              p_validation_level => fnd_api.g_valid_level_full,
              p_instance_rec     => l_exp_instance_rec,
              p_expire_children  => fnd_api.g_true,
              p_txn_rec          => l_exp_txn_rec,
              x_instance_id_lst  => l_exp_inst_ids_list,
              x_return_status    => l_return_status,
              x_msg_count        => l_msg_count,
              x_msg_data         => l_msg_data);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              l_error_flag := 'Y';
              l_error_message := csi_t_gen_utility_pvt.dump_error_stack;
              raise fnd_api.g_exc_error;
            END IF;

            fnd_file.put_line(fnd_file.log,'Processed successfully.');

          ELSE
            fnd_file.put_line(fnd_file.log,'Parent found, so did not qualify.');
          END IF;

        EXCEPTION
          WHEN fnd_api.g_exc_error THEN
            fnd_file.put_line(fnd_file.log, l_error_message);
        END;

        v_commit_counter := v_commit_counter + 1;
          IF v_commit_counter = 100 THEN
             v_commit_counter := 0;
             commit;
          END IF;

      END LOOP;
      commit;

    ELSE
      fnd_file.put_line(fnd_file.log,'Profile CSI_SYS_TERM_INST_STATUS_ID is not set.');
      l_error_flag := 'Y';
    END IF;

    IF l_error_flag = 'Y' THEN
      retcode := 1;
    ELSE
      retcode := 0;
      errbuf  := 'Instances Terminated Successfully.';
    END IF;

    fnd_file.put_line(fnd_file.log,'End of Terminate Expired Instances.');

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO terminate_instances;
      retcode := 1;
      errbuf  := csi_t_gen_utility_pvt.dump_error_stack;
    WHEN others THEN
      ROLLBACK TO terminate_instances;
      retcode := -1;
      errbuf  := substr(sqlerrm, 1, 300);
  END terminate_instances;

END CSI_GENERIC_GRP;

/
