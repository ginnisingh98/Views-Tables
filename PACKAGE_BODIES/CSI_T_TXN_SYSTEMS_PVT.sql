--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_SYSTEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_SYSTEMS_PVT" AS
/* $Header: csivtsyb.pls 120.1 2006/02/09 14:54:24 shegde noship $ */
-- start of comments
-- package name     : csi_t_txn_systems_pvt
-- purpose          :
-- history          :
-- note             :
-- END of comments


g_pkg_name  CONSTANT VARCHAR2(30) := 'csi_t_txn_systems_pvt';
g_file_name CONSTANT VARCHAR2(12) := 'csivtsyb.pls';

PROCEDURE dmsg (
    p_msg                       IN VARCHAR2
                );
PROCEDURE validate_txn_systems(
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2  ,
    p_txn_system_rec             IN   csi_t_datastructures_grp.txn_system_rec,
    x_return_status              OUT NOCOPY  VARCHAR2  ,
    x_msg_count                  OUT NOCOPY  NUMBER    ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

/* ----------------------------------------------------------------------------------------------- */
/* This Procedure(during creation/updation)is used to check for Unique system_name for a Customer  */
/*  and System_Number.IF found then raise an error else success                                    */
/* ----------------------------------------------------------------------------------------------- */
PROCEDURE Check_Unique(  p_txn_system_id     IN     NUMBER  ,
                         p_system_name       IN     VARCHAR2,
                         p_Customer_ID       IN     NUMBER  ,
                         p_System_number     IN     VARCHAR2,
                         p_txn_line_id       IN     NUMBER  ,
                         p_validation_level  IN     NUMBER  ,
                         x_return_status     OUT NOCOPY    VARCHAR2,
                         x_msg_count         OUT NOCOPY    NUMBER  ,
                         x_msg_data          OUT NOCOPY    VARCHAR2) IS
/* split out and commented the 2 cursors for perf Bug 4907908
    CURSOR dup_cur IS
      SELECT 'x'
      FROM   csi_t_txn_systems txn, csi_systems_vl sys
      WHERE  txn.system_name = p_system_name
      AND    txn.customer_id = p_Customer_ID
      AND   (txn.system_number IS NULL OR
             txn.system_number = p_System_number)
      OR     sys.name = p_system_name
      AND    sys.customer_id = p_Customer_ID
      AND   (sys.system_number IS NULL OR
             sys.system_number = p_System_number);

     CURSOR dup_cur1 IS
      SELECT 'x'
      FROM   csi_t_txn_systems txn, csi_systems_vl sys
      WHERE  txn.system_name = p_system_name
      AND    txn.customer_id = p_Customer_ID
      AND   (txn.system_number IS NULL OR
             txn.system_number = p_System_number)
      AND    txn.transaction_line_id =p_txn_line_id
      OR     sys.name = p_system_name
      AND    sys.customer_id = p_Customer_ID
      AND   (sys.system_number IS NULL OR
             sys.system_number = p_System_number);
*/
    l_dummy VARCHAR2(1);
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     Begin
      SELECT 'Y'
      INTO l_dummy
      FROM   csi_systems_vl sys
      WHERE  sys.name = p_system_name
      AND    sys.customer_id = p_Customer_ID
      AND   (sys.system_number IS NULL OR
             sys.system_number = p_System_number);
     Exception
        when no_data_found then
             null; -- valid system
        when others then
             FND_MESSAGE.SET_NAME('CSI', 'CSI_TXN_SYSTEM_DUP_NAME');
             FND_MSG_PUB.add;
             x_return_status := fnd_api.g_ret_sts_error;
     End;

/* commented for perf Bug 4907908
    l_dummy:=NULL;
    OPEN dup_cur;
    FETCH dup_cur INTO l_dummy;
    IF (dup_cur%FOUND) THEN
      FND_MESSAGE.SET_NAME('CSI', 'CSI_TXN_SYSTEM_DUP_NAME');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    CLOSE dup_cur;
   ELSE
    l_dummy:=NULL;
    OPEN dup_cur1;
    FETCH dup_cur1 INTO l_dummy;
    IF (dup_cur1%FOUND) THEN
      FND_MESSAGE.SET_NAME('CSI', 'CSI_TXN_SYSTEM_DUP_NAME');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    CLOSE dup_cur1;
*/
   Begin
    IF p_validation_level = fnd_api.g_valid_level_full THEN
       SELECT 'Y'
       INTO l_dummy
       FROM   csi_t_txn_systems txn
       WHERE  txn.system_name = p_system_name
       AND    txn.customer_id = p_Customer_ID
       AND   (txn.system_number IS NULL OR
              txn.system_number = p_System_number);
    ELSE -- validation level <> full
       SELECT 'Y'
       INTO l_dummy
       FROM   csi_t_txn_systems txn
       WHERE  txn.system_name = p_system_name
       AND    txn.customer_id = p_Customer_ID
       AND    txn.transaction_line_id =p_txn_line_id
       AND   (txn.system_number IS NULL OR
              txn.system_number = p_System_number);
    END IF;

   Exception
      when no_data_found then
           null; -- valid system
      when others then
           FND_MESSAGE.SET_NAME('CSI', 'CSI_TXN_SYSTEM_DUP_NAME');
           FND_MSG_PUB.add;
           x_return_status := fnd_api.g_ret_sts_error;
   End;

  EXCEPTION
      WHEN OTHERS THEN
         NULL;
  END Check_Unique;

-- hint: primary key needs to be returned.
PROCEDURE create_txn_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN     VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN     NUMBER       := fnd_api.g_valid_level_full,
    p_txn_system_rec             IN     csi_t_datastructures_grp.txn_system_rec,
    x_txn_system_id              OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'create_txn_system';
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_txn_system_id                    NUMBER;
l_system_history_id                NUMBER       :=fnd_api.g_miss_num;
l_debug_level                      NUMBER;
l_system_rec                       csi_datastructures_pub.system_rec;
l_start_date                       DATE;
 BEGIN
      -- standard start of api savepoint
      SAVEPOINT create_txn_system_pvt;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list IS set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- debug message


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      --debug messages
        csi_t_gen_utility_pvt.dump_api_info(
                                            p_pkg_name => g_pkg_name,
                                            p_api_name => l_api_name);

    IF csi_t_gen_utility_pvt.g_debug_level > 1 then


       csi_t_gen_utility_pvt.add(p_api_version          ||'-'||
                                 p_commit               ||'-'||
                                 p_init_msg_list        ||'-'||
                                 p_validation_level);

       csi_t_gen_utility_pvt.dump_txn_systems_rec(
        p_txn_systems_rec => p_txn_system_rec);

    END IF;

        validate_txn_systems( p_init_msg_list     => p_init_msg_list
                             ,p_validation_level  => p_validation_level
                             ,p_validation_mode   => 'CREATE'
                             ,p_txn_system_rec    => p_txn_system_rec
                             ,x_return_status     => x_return_status
                             ,x_msg_count         => x_msg_count
                             ,x_msg_data          => x_msg_data
                             );

      -- invoke validation procedures
      l_system_rec.customer_id              :=  p_txn_system_rec.customer_id;
      l_system_rec.system_type_code         :=  p_txn_system_rec.system_type_code;
      l_system_rec.ship_to_contact_id       :=  p_txn_system_rec.ship_to_contact_id;
      l_system_rec.bill_to_contact_id       :=  p_txn_system_rec.bill_to_contact_id;
      l_system_rec.technical_contact_id     :=  p_txn_system_rec.technical_contact_id;
      l_system_rec.service_admin_contact_id :=  p_txn_system_rec.service_admin_contact_id;
      l_system_rec.ship_to_site_use_id      :=  p_txn_system_rec.ship_to_site_use_id;
      l_system_rec.bill_to_site_use_id      :=  p_txn_system_rec.bill_to_site_use_id;
      l_system_rec.install_site_use_id      :=  p_txn_system_rec.install_site_use_id;
      l_system_rec.name                     :=  p_txn_system_rec.system_name;

      csi_systems_pvt.validate_systems(
          p_init_msg_list    => p_init_msg_list,
          p_validation_level => p_validation_level,
          p_validation_mode  => 'CREATE',
          p_system_rec       => l_system_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);


      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;

       IF (x_return_status = fnd_api.g_ret_sts_success) THEN


        -- check for unique system name
            Check_Unique(
                         p_txn_system_id     =>     NULL
                        ,p_system_name       =>     p_txn_system_rec.system_name
                        ,p_Customer_ID       =>     p_txn_system_rec.customer_id
                        ,p_System_number     =>     p_txn_system_rec.system_number
                        ,p_txn_line_id       =>     p_txn_system_rec.transaction_line_id
                        ,p_validation_level  =>     p_validation_level
                        ,x_return_status     =>     x_return_status
                        ,x_msg_count         =>     x_msg_count
                        ,x_msg_data          =>     x_msg_data);

          --dbms_output.put_line('Value of x_return_status='||x_return_status);
        END IF;

        IF ( (p_txn_system_rec.start_date_active = fnd_api.g_miss_date)
          OR (p_txn_system_rec.start_date_active IS NULL) )
        THEN
              l_start_date := SYSDATE;
        ELSE  l_start_date := p_txn_system_rec.start_date_active;
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_success THEN

              csi_t_txn_systems_pkg.insert_row(
            px_transaction_system_id      =>  x_txn_system_id,
            p_transaction_line_id         =>  p_txn_system_rec.transaction_line_id,
            p_system_name                 =>  p_txn_system_rec.system_name,
            p_description                 =>  p_txn_system_rec.description,
            p_system_type_code            =>  p_txn_system_rec.system_type_code,
            p_system_number               =>  p_txn_system_rec.system_number,
            p_customer_id                 =>  p_txn_system_rec.customer_id,
            p_bill_to_contact_id          =>  p_txn_system_rec.bill_to_contact_id,
            p_ship_to_contact_id          =>  p_txn_system_rec.ship_to_contact_id,
            p_technical_contact_id        =>  p_txn_system_rec.technical_contact_id,
            p_service_admin_contact_id    =>  p_txn_system_rec.service_admin_contact_id,
            p_ship_to_site_use_id         =>  p_txn_system_rec.ship_to_site_use_id,
            p_bill_to_site_use_id         =>  p_txn_system_rec.bill_to_site_use_id,
            p_install_site_use_id         =>  p_txn_system_rec.install_site_use_id,
            p_coterminate_day_month       =>  p_txn_system_rec.coterminate_day_month,
            p_config_system_type          =>  p_txn_system_rec.config_system_type,
            p_start_date_active           =>  l_start_date,
            p_end_date_active             =>  p_txn_system_rec.end_date_active,
            p_context                     =>  p_txn_system_rec.context,
            p_attribute1                  =>  p_txn_system_rec.attribute1,
            p_attribute2                  =>  p_txn_system_rec.attribute2,
            p_attribute3                  =>  p_txn_system_rec.attribute3,
            p_attribute4                  =>  p_txn_system_rec.attribute4,
            p_attribute5                  =>  p_txn_system_rec.attribute5,
            p_attribute6                  =>  p_txn_system_rec.attribute6,
            p_attribute7                  =>  p_txn_system_rec.attribute7,
            p_attribute8                  =>  p_txn_system_rec.attribute8,
            p_attribute9                  =>  p_txn_system_rec.attribute9,
            p_attribute10                 =>  p_txn_system_rec.attribute10,
            p_attribute11                 =>  p_txn_system_rec.attribute11,
            p_attribute12                 =>  p_txn_system_rec.attribute12,
            p_attribute13                 =>  p_txn_system_rec.attribute13,
            p_attribute14                 =>  p_txn_system_rec.attribute14,
            p_attribute15                 =>  p_txn_system_rec.attribute15,
            p_created_by                  =>  fnd_global.user_id,
            p_creation_date               =>  SYSDATE,
            p_last_updated_by             =>  fnd_global.user_id,
            p_last_update_date            =>  SYSDATE,
            p_last_update_login           =>  fnd_global.conc_login_id,
            p_object_version_number       =>  1
            );
            l_txn_system_id := x_txn_system_id;


        END IF;

       IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
       END IF;

      --
      -- END of api body
      --

      -- standard check FOR p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- standard call to get message count AND IF count IS 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO create_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO create_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO create_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END create_txn_system;



PROCEDURE update_txn_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2     := fnd_api.g_false,
    p_init_msg_list              IN     VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN     NUMBER       := fnd_api.g_valid_level_full,
    p_txn_system_rec             IN     csi_t_datastructures_grp.txn_system_rec,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    )
 IS
CURSOR  txn_sys_csr (sys_id NUMBER) IS
     SELECT customer_id
           ,object_version_number
           ,start_date_active
           ,end_date_active
     FROM   csi_t_txn_systems
     WHERE  transaction_system_id=sys_id
     FOR UPDATE NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'update_txn_system';
l_sys_csr                          txn_sys_csr%ROWTYPE;
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_rowid                            rowid;
l_object_version_number            NUMBER;
l_count                            NUMBER;
l_full_dump                        NUMBER;
l_debug_level                      NUMBER;
l_customer_id                      NUMBER;
l_system_rec                       csi_datastructures_pub.system_rec;


 BEGIN
      SAVEPOINT update_txn_system_pvt;

      IF NOT fnd_api.compatible_api_call ( l_api_version_number,
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

      --debug messages
        csi_t_gen_utility_pvt.dump_api_info(
                                            p_pkg_name => g_pkg_name,
                                            p_api_name => l_api_name);

    IF csi_t_gen_utility_pvt.g_debug_level > 1 then

       csi_t_gen_utility_pvt.add(p_api_version          ||'-'||
                                 p_commit               ||'-'||
                                 p_init_msg_list        ||'-'||
                                 p_validation_level);

       csi_t_gen_utility_pvt.dump_txn_systems_rec(
        p_txn_systems_rec => p_txn_system_rec);

    END IF;



      OPEN txn_sys_csr (p_txn_system_rec.transaction_system_id);
      FETCH txn_sys_csr INTO l_sys_csr;
       IF ( (l_sys_csr.object_version_number<>p_txn_system_rec.object_version_number)
         AND (p_txn_system_rec.object_version_number <> fnd_api.g_miss_num) ) THEN
                fnd_message.set_name('CSI', 'CSI_RECORD_CHANGED');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_error;
       END IF;
      CLOSE txn_sys_csr;

      -- validation for Active Start Date
        IF p_txn_system_rec.start_date_active <> fnd_api.g_miss_date THEN
            IF p_txn_system_rec.start_date_active <> l_sys_csr.start_date_active THEN
               fnd_message.set_name('CSI', 'CSI_UPD_NOT_ALLOWED');
               fnd_message.set_token('start_date_active',p_txn_system_rec.start_date_active);
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
            END IF;
        END IF;

-- validating the effective active end date
        IF l_sys_csr.end_date_active <= SYSDATE THEN
            IF (p_txn_system_rec.end_date_active = fnd_api.g_miss_date) OR
               (p_txn_system_rec.end_date_active <= SYSDATE) THEN
               fnd_message.set_name('CSI', 'CSI_CANT_UPDATE_EXPIRED_SYS');
               fnd_message.set_token('start_date_active',p_txn_system_rec.end_date_active);
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
            END IF;
        END IF;




      validate_txn_systems(  p_init_msg_list     => p_init_msg_list
                            ,p_validation_level  => p_validation_level
                            ,p_validation_mode   => 'UPDATE'
                            ,p_txn_system_rec    => p_txn_system_rec
                            ,x_return_status     => x_return_status
                            ,x_msg_count         => x_msg_count
                            ,x_msg_data          => x_msg_data
                             );

      l_system_rec.customer_id              :=  p_txn_system_rec.customer_id;
      l_system_rec.system_type_code         :=  p_txn_system_rec.system_type_code;
      l_system_rec.ship_to_contact_id       :=  p_txn_system_rec.ship_to_contact_id;
      l_system_rec.bill_to_contact_id       :=  p_txn_system_rec.bill_to_contact_id;
      l_system_rec.technical_contact_id     :=  p_txn_system_rec.technical_contact_id;
      l_system_rec.service_admin_contact_id :=  p_txn_system_rec.service_admin_contact_id;
      l_system_rec.ship_to_site_use_id      :=  p_txn_system_rec.ship_to_site_use_id;
      l_system_rec.bill_to_site_use_id      :=  p_txn_system_rec.bill_to_site_use_id;
      l_system_rec.install_site_use_id      :=  p_txn_system_rec.install_site_use_id;
      l_system_rec.name                     :=  p_txn_system_rec.system_name;

      csi_systems_pvt.validate_systems(
          p_init_msg_list    => p_init_msg_list,
          p_validation_level => p_validation_level,
          p_validation_mode  => 'UPDATE',
          p_system_rec       => l_system_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
      END IF;

      IF ( (p_txn_system_rec.customer_id IS NOT NULL) AND (p_txn_system_rec.customer_id<>fnd_api.g_miss_num) ) THEN
         l_customer_id:=p_txn_system_rec.customer_id;
      ELSE
         l_customer_id:=l_sys_csr.customer_id;
      END IF;


      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
        -- check for unique system name
          Check_Unique(
                         p_txn_system_id     =>     p_txn_system_rec.transaction_system_id
                        ,p_system_name       =>     p_txn_system_rec.system_name
                        ,p_Customer_ID       =>     l_customer_id
                        ,p_System_number     =>     p_txn_system_rec.system_number
                        ,p_txn_line_id       =>     p_txn_system_rec.transaction_line_id
                        ,p_validation_level  =>     p_validation_level
                        ,x_return_status     =>     x_return_status
                        ,x_msg_count         =>     x_msg_count
                        ,x_msg_data          =>     x_msg_data);

             --dbms_output.put_line('Value of x_return_status='||x_return_status);
       END IF;

   IF x_return_status = fnd_api.g_ret_sts_success THEN


       csi_t_txn_systems_pkg.update_row(
            p_transaction_system_id       =>  p_txn_system_rec.transaction_system_id,
            p_transaction_line_id         =>  p_txn_system_rec.transaction_line_id,
            p_system_name                 =>  p_txn_system_rec.system_name,
            p_description                 =>  p_txn_system_rec.description,
            p_system_type_code            =>  p_txn_system_rec.system_type_code,
            p_system_number               =>  p_txn_system_rec.system_number,
            p_customer_id                 =>  p_txn_system_rec.customer_id,
            p_bill_to_contact_id          =>  p_txn_system_rec.bill_to_contact_id,
            p_ship_to_contact_id          =>  p_txn_system_rec.ship_to_contact_id,
            p_technical_contact_id        =>  p_txn_system_rec.technical_contact_id,
            p_service_admin_contact_id    =>  p_txn_system_rec.service_admin_contact_id,
            p_ship_to_site_use_id         =>  p_txn_system_rec.ship_to_site_use_id,
            p_bill_to_site_use_id         =>  p_txn_system_rec.bill_to_site_use_id,
            p_install_site_use_id         =>  p_txn_system_rec.install_site_use_id,
            p_coterminate_day_month       =>  p_txn_system_rec.coterminate_day_month,
            p_config_system_type          =>  p_txn_system_rec.config_system_type,
            p_start_date_active           =>  p_txn_system_rec.start_date_active,
            p_end_date_active             =>  p_txn_system_rec.end_date_active,
            p_context                     =>  p_txn_system_rec.context,
            p_attribute1                  =>  p_txn_system_rec.attribute1,
            p_attribute2                  =>  p_txn_system_rec.attribute2,
            p_attribute3                  =>  p_txn_system_rec.attribute3,
            p_attribute4                  =>  p_txn_system_rec.attribute4,
            p_attribute5                  =>  p_txn_system_rec.attribute5,
            p_attribute6                  =>  p_txn_system_rec.attribute6,
            p_attribute7                  =>  p_txn_system_rec.attribute7,
            p_attribute8                  =>  p_txn_system_rec.attribute8,
            p_attribute9                  =>  p_txn_system_rec.attribute9,
            p_attribute10                 =>  p_txn_system_rec.attribute10,
            p_attribute11                 =>  p_txn_system_rec.attribute11,
            p_attribute12                 =>  p_txn_system_rec.attribute12,
            p_attribute13                 =>  p_txn_system_rec.attribute13,
            p_attribute14                 =>  p_txn_system_rec.attribute14,
            p_attribute15                 =>  p_txn_system_rec.attribute15,
            p_created_by                  =>  fnd_global.user_id,
            p_creation_date               =>  SYSDATE,
            p_last_updated_by             =>  fnd_global.user_id,
            p_last_update_date            =>  SYSDATE,
            p_last_update_login           =>  fnd_global.conc_login_id,
            p_object_version_number       =>  p_txn_system_rec.object_version_number
            );


   END IF;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;
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
                ROLLBACK TO update_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO update_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO update_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END update_txn_system;

PROCEDURE delete_txn_system
 (
     p_api_version                 IN     NUMBER,
     p_commit                      IN     VARCHAR2   := fnd_api.g_false,
     p_init_msg_list               IN     VARCHAR2   := fnd_api.g_false,
     p_validation_level            IN     NUMBER     := fnd_api.g_valid_level_full,
     p_txn_system_id               IN     NUMBER,
     x_return_status               OUT NOCOPY    VARCHAR2,
     x_msg_count                   OUT NOCOPY    NUMBER,
     x_msg_data                    OUT NOCOPY    VARCHAR2
 ) IS
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_api_name                CONSTANT VARCHAR2(30) := 'delete_txn_system';
l_debug_level                      NUMBER;
l_dummy                            VARCHAR2(1);
l_txn_system_rec                   csi_t_datastructures_grp.txn_system_rec;

 BEGIN

      SAVEPOINT delete_txn_system_pvt;

      IF NOT fnd_api.compatible_api_call ( l_api_version_number,
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

       --debug messages
        csi_t_gen_utility_pvt.dump_api_info(
                                            p_pkg_name => g_pkg_name,
                                            p_api_name => l_api_name);

    IF csi_t_gen_utility_pvt.g_debug_level > 1 then


       csi_t_gen_utility_pvt.add(p_api_version          ||'-'||
                                 p_commit               ||'-'||
                                 p_init_msg_list        ||'-'||
                                 p_validation_level     ||'-'||
                                 p_txn_system_id);

    END IF;
        l_txn_system_rec.transaction_system_id:=p_txn_system_id;
        validate_txn_systems(  p_init_msg_list     => p_init_msg_list
                              ,p_validation_level  => p_validation_level
                              ,p_validation_mode   => 'DELETE'
                              ,p_txn_system_rec    => l_txn_system_rec
                              ,x_return_status     => x_return_status
                              ,x_msg_count         => x_msg_count
                              ,x_msg_data          => x_msg_data
                             );


        IF x_return_status<>fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;


                        csi_t_txn_systems_pkg.Delete_Row(p_txn_system_id );


        IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
        END IF;
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
                ROLLBACK TO delete_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO delete_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                       (p_count => x_msg_count ,
                        p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO delete_txn_system_pvt;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
 END delete_txn_system;


PROCEDURE validate_txn_system_id (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_txn_system_id              IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
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
        IF ( (p_txn_system_id IS NOT NULL) AND (p_txn_system_id<>fnd_api.g_miss_num) ) THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_t_txn_systems
                WHERE   transaction_system_id=p_txn_system_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_TXN_SYSTEM_ID');
                     fnd_message.set_token('transaction_system_id',p_txn_system_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
        END IF;

       ELSIF p_validation_mode='UPDATE' OR  p_validation_mode='DELETE' THEN
         IF ( (p_txn_system_id IS NOT NULL) AND (p_txn_system_id<>fnd_api.g_miss_num) ) THEN
                BEGIN
                SELECT  'x'
                INTO    l_dummy
                FROM    csi_t_txn_systems
                WHERE   transaction_system_id=p_txn_system_id;
                EXCEPTION
                WHEN no_data_found THEN
                     fnd_message.set_name('CSI', 'CSI_INVALID_TXN_SYSTEM_ID');
                     fnd_message.set_token('transaction_system_id',p_txn_system_id);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                END;
          ELSE
                     fnd_message.set_name('CSI', 'CSI_NO_TXN_SYSTEM_ID');
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
          END IF;

       END IF;

      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_txn_system_id;

PROCEDURE validate_object_version_num (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_object_version_number      IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
BEGIN
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;

       IF(p_validation_mode = 'UPDATE') THEN
          IF ( (p_object_version_number IS NULL) OR (p_object_version_number = fnd_api.g_miss_num) ) THEN
             fnd_message.set_name('CSI', 'CSI_MISSING_OBJ_VER_NUM');
             fnd_msg_pub.add;
             x_return_status := fnd_api.g_ret_sts_error;
          END IF;
       END IF;

      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_object_version_num;

PROCEDURE validate_start_date (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_start_date                 IN   DATE    ,
    p_end_date                   IN   DATE    ,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER  ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
l_start_date    DATE;
l_end_date      DATE;
BEGIN
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      IF p_validation_mode='CREATE' THEN
          IF ((p_start_date = FND_API.G_MISS_DATE) OR (p_start_date IS NULL)) THEN
                    l_start_date := SYSDATE;
          ELSE      l_start_date := p_start_date;
          END IF;

          IF (p_end_date = FND_API.G_MISS_DATE) THEN
                 l_end_date := NULL;
          ELSE   l_end_date := p_end_date;
          END IF;

          IF (l_end_date IS NOT NULL) THEN
            IF (l_start_date > l_end_date)  THEN
     	       fnd_message.set_name('CSI','CSI_API_INVALID_START_DATE');
	           fnd_message.set_token('START_DATE_ACTIVE',l_start_date);
	           fnd_msg_pub.Add;
               x_return_status := fnd_api.g_ret_sts_error;
            END IF;
          END IF;
      END IF;
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_start_date;

PROCEDURE validate_end_date (
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_mode            IN   VARCHAR2,
    p_start_date                 IN   DATE    ,
    p_end_date                   IN   DATE    ,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER  ,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_dummy         VARCHAR2(1);
l_start_date    DATE;
l_end_date      DATE;
BEGIN
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      IF ( (p_validation_mode='CREATE') OR (p_validation_mode='UPDATE') ) THEN
          IF (p_end_date = FND_API.G_MISS_DATE) THEN
                 l_end_date := NULL;
          ELSE   l_end_date := p_end_date;
          END IF;

          IF (l_end_date IS NOT NULL) THEN
            IF  l_end_date < SYSDATE THEN
     	        fnd_message.set_name('CSI','CSI_API_INVALID_END_DATE');
	            fnd_message.set_token('END_DATE_ACTIVE',l_end_date);
	            fnd_msg_pub.Add;
                x_return_status := fnd_api.g_ret_sts_error;
            END IF;
          END IF;
      END IF;
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END validate_end_date;




PROCEDURE dmsg (
    p_msg                       IN VARCHAR2
                ) IS
BEGIN
    --dbms_output.put_line( p_msg );
    null;
END;




PROCEDURE validate_txn_systems(
    p_init_msg_list              IN   VARCHAR2     := fnd_api.g_false,
    p_validation_level           IN   NUMBER       := fnd_api.g_valid_level_full,
    p_validation_mode            IN   VARCHAR2,
    p_txn_system_rec             IN   csi_t_datastructures_grp.txn_system_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'validate_txn_systems';
 BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN
          validate_txn_system_id(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_txn_system_id          => p_txn_system_rec.transaction_system_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      END IF;

      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN
          validate_object_version_num(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_object_version_number  => p_txn_system_rec.object_version_number,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      END IF;

      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN
          validate_start_date(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_start_date             => p_txn_system_rec.start_date_active,
              p_end_date               => p_txn_system_rec.end_date_active,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      END IF;

      IF (p_validation_level >= fnd_api.g_valid_level_full) THEN
          validate_end_date(
              p_init_msg_list          => fnd_api.g_false,
              p_validation_mode        => p_validation_mode,
              p_start_date             => p_txn_system_rec.start_date_active,
              p_end_date               => p_txn_system_rec.end_date_active,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
              RAISE fnd_api.g_exc_error;
          END IF;

      END IF;
END validate_txn_systems;

END csi_t_txn_systems_pvt;

/
