--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_SYSTEMS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_SYSTEMS_GRP" AS
/* $Header: csigtsyb.pls 115.7 2004/01/08 23:54:15 rmamidip ship $ */
-- Start of Comments
-- Package name     : csi_t_txn_systems_grp
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_T_TXN_SYSTEMS_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csigtsyb.pls';

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
l_api_version             CONSTANT NUMBER       := 1.0;
l_return_status_full               VARCHAR2(1);
l_access_flag                      VARCHAR2(1);
l_line_count                       NUMBER;
l_flag                             VARCHAR2(1)  :='N';
l_debug_level                      NUMBER;


 BEGIN
      -- standard start of api savepoint
      SAVEPOINT csi_t_txn_systems_grp;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;



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


    /**** Commented for Bug 3304439
    -- check for the profile option and enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- end enable trace
    ****/

    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    -- calling private package: create_system
    -- hint: primary key needs to be returned



      csi_t_txn_systems_pvt.create_txn_system(
        p_api_version                => p_api_version,
        p_commit                     => p_commit,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_txn_system_rec             => p_txn_system_rec,
        x_txn_system_id              => x_txn_system_id,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
     );



      -- check return status from the above procedure call
      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- END of api body.
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;

      -- standard call to get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO csi_t_txn_systems_grp;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO csi_t_txn_systems_grp;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                         );

          WHEN OTHERS THEN
                ROLLBACK TO csi_t_txn_systems_grp;
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
l_api_name                   CONSTANT VARCHAR2(30) := 'update_txn_system';
l_api_version                CONSTANT NUMBER       := 1.0;
-- local variables
l_rowid  rowid;
l_flag                                VARCHAR2(1)  :='N';
l_debug_level                         NUMBER;


BEGIN
      -- standard start of api savepoint
      SAVEPOINT update_txn_system_grp;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

       --debug messages
        csi_t_gen_utility_pvt.dump_api_info(
                                            p_pkg_name => g_pkg_name,
                                            p_api_name => l_api_name);

    IF csi_t_gen_utility_pvt.g_debug_level > 1 THEN

       csi_t_gen_utility_pvt.add(p_api_version          ||'-'||
                                 p_commit               ||'-'||
                                 p_init_msg_list        ||'-'||
                                 p_validation_level);

       csi_t_gen_utility_pvt.dump_txn_systems_rec(
        p_txn_systems_rec => p_txn_system_rec);

    END IF;

    /**** Commented for Bug 3304439
    -- check for the profile option and enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- end enable trace
    ****/

    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    -- calling private package: update_system
    csi_t_txn_systems_pvt.update_txn_system(
        p_api_version                => p_api_version,
        p_commit                     => p_commit,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_txn_system_rec             => p_txn_system_rec,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
        );




      -- check return status from the above procedure call
      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- end of api body
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
      END IF;

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO update_txn_system_grp;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO update_txn_system_grp;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO update_txn_system_grp;
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
 )
 IS
l_api_name                   CONSTANT VARCHAR2(30) := 'delete_txn_system';
l_api_version                CONSTANT NUMBER       := 1.0;
-- local variables
l_rowid  rowid;
l_flag                                VARCHAR2(1)  :='N';
l_debug_level                         NUMBER;


BEGIN
      -- standard start of api savepoint
      SAVEPOINT delete_txn_system_grp;

      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


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
                                 p_validation_level     ||'-'||
                                 p_txn_system_id );

    END IF;

    /**** Commented for Bug 3304439
    -- check for the profile option and enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- END enable trace
    ****/

    --
    -- This procedure check if the installed base is active, If not active
    -- populates the error message in the message queue and raises the
    -- fnd_api.g_exc_error exception
    --

    csi_utility_grp.check_ib_active;

    -- calling private package: delete_system
    csi_t_txn_systems_pvt.delete_txn_system(
        p_api_version                => p_api_version,
        p_commit                     => p_commit,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_txn_system_id              => p_txn_system_id,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
        );




      -- check return status from the above procedure call
      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- END of api body
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;

      -- standard call to get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO delete_txn_system_grp;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO delete_txn_system_grp;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO delete_txn_system_grp;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

 END delete_txn_system;




END csi_t_txn_systems_grp;

/
