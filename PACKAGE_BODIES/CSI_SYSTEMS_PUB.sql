--------------------------------------------------------
--  DDL for Package Body CSI_SYSTEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_SYSTEMS_PUB" AS
/* $Header: csipsysb.pls 120.1.12010000.3 2010/01/22 07:43:48 dnema ship $ */
-- Start of Comments
-- Package name     : CSI_SYSTEMS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_SYSTEMS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipsysb.pls';



PROCEDURE get_systems
 (
     p_api_version               IN  NUMBER,
     p_commit                    IN  VARCHAR2,
     p_init_msg_list             IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     p_system_query_rec          IN  csi_datastructures_pub.system_query_rec,
     p_time_stamp                IN  DATE,
     p_active_systems_only       IN  VARCHAR2,
     x_systems_tbl               OUT NOCOPY csi_datastructures_pub.systems_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 )
  is
l_api_name                  CONSTANT VARCHAR2(30) := 'get_systems';
l_api_version               CONSTANT NUMBER       := 1.0;
l_return_status_full                 VARCHAR2(1);
l_access_flag                        VARCHAR2(1);
i                                    NUMBER       := 1;
l_flag                               VARCHAR2(1)  :='N';
l_debug_level                        NUMBER;

 BEGIN
      -- standard start of api savepoint
      --SAVEPOINT get_systems_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;



      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

     l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- if debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'get_systems');
    END IF;

    -- IF the debug level = 2 THEN dump all the parameters values.
    IF (l_debug_level > 1) THEN
             CSI_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_commit                  ||'-'||
                                p_init_msg_list           ||'-'||
                                p_validation_level        ||'-'||
                                p_time_stamp              );

         -- dump the system query records
         csi_gen_utility_pvt.dump_sys_query_rec(p_system_query_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- check for the profile option and enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- end enable trace
    ****/

      --
      -- api body
      --
      -- debug message

     csi_systems_pvt.get_systems(
        p_api_version                => p_api_version,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_system_query_rec           => p_system_query_rec,
        p_time_stamp                 => p_time_stamp,
        p_active_systems_only        => p_active_systems_only,
        x_systems_tbl                => x_systems_tbl,
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
      /***** srramakr commented for bug # 3304439
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
       ****/

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
               -- ROLLBACK TO get_systems_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
               -- ROLLBACK TO get_systems_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                         );

          WHEN OTHERS THEN
              --  ROLLBACK TO get_systems_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                   fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                         );
END get_systems;


PROCEDURE create_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2,
    p_init_msg_list              IN     VARCHAR2,
    p_validation_level           IN     NUMBER,
    p_system_rec                 IN     csi_datastructures_pub.system_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_system_id                  OUT NOCOPY    NUMBER,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    )

 is
l_api_name                CONSTANT VARCHAR2(30) := 'create_system';
l_api_version             CONSTANT NUMBER       := 1.0;
l_return_status_full               VARCHAR2(1);
l_access_flag                      VARCHAR2(1);
l_line_count                       NUMBER;
l_flag                             VARCHAR2(1)  :='N';
l_debug_level                      NUMBER;


 BEGIN
      -- standard start of api savepoint
      SAVEPOINT create_system_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;



      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

       l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- if debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'create_system');
    END IF;

    -- if the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_commit                  ||'-'||
                                p_init_msg_list           ||'-'||
                                p_validation_level        );

         -- dump the systems query records
         csi_gen_utility_pvt.dump_sys_rec(p_system_rec);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- check for the profile option and enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- END enable trace
    ****/

    -- calling private package: create_system
    -- hint: primary key needs to be returned


      csi_systems_pvt.create_system(
        p_api_version                =>p_api_version,
        p_commit                     =>fnd_api.g_false,
        p_init_msg_list              =>p_init_msg_list,
        p_validation_level           =>p_validation_level,
        p_system_rec                 =>p_system_rec,
        p_txn_rec                    =>p_txn_rec,
        x_system_id                  =>x_system_id,
        x_return_status              =>x_return_status,
        x_msg_count                  =>x_msg_count,
        x_msg_data                   =>x_msg_data
     );



      -- check return status from the above procedure call
      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- end of api body.
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      /***** srramakr commented for bug # 3304439
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
      ****/

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO create_system_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO create_system_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                         );

          WHEN OTHERS THEN
                ROLLBACK TO create_system_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END create_system;


PROCEDURE update_system(
    p_api_version                IN     NUMBER,
    p_commit                     IN     VARCHAR2,
    p_init_msg_list              IN     VARCHAR2,
    p_validation_level           IN     NUMBER,
    p_system_rec                 IN     csi_datastructures_pub.system_rec,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
    )
is
l_api_name                   CONSTANT VARCHAR2(30) := 'update_system';
l_api_version                CONSTANT NUMBER       := 1.0;
-- local variables
l_rowid  rowid;
l_flag                                VARCHAR2(1)  :='N';
l_debug_level                         NUMBER;

l_parent_system_id NUMBER;
l_child_system_rec csi_datastructures_pub.system_rec;

  -- Bug 	6675862
  CURSOR  CHILD_SYSTEM_CUR (parent_system_id NUMBER) IS
    SELECT SYSTEM_ID child_system_id
      FROM CSI_SYSTEMS_B
      WHERE PARENT_SYSTEM_ID = parent_system_id;

  -- Bug 	6675862
  CURSOR  CHILD_SYSTEMS_DETAILS_CUR (p_child_sys_id NUMBER) IS
     SELECT SYSTEM_ID,
            SYSTEM_TYPE_CODE,
            SYSTEM_NUMBER,
            PARENT_SYSTEM_ID,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            COTERMINATE_DAY_MONTH,
            AUTOCREATED_FROM_SYSTEM_ID,
            CONFIG_SYSTEM_TYPE,
            CONTEXT,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
		    OPERATING_UNIT_ID
     FROM   CSI_SYSTEMS_B
     WHERE  SYSTEM_ID = p_child_sys_id;

     -- Bug 	6675862
     CURSOR  SYS_TL_CSR (p_child_sys_id NUMBER) IS
      SELECT NAME,
           DESCRIPTION
        FROM   CSI_SYSTEMS_TL
        WHERE  SYSTEM_ID = p_child_sys_id;

     l_child_sys_details_rec CHILD_SYSTEMS_DETAILS_CUR%ROWTYPE;
     l_child_sys_tl_rec SYS_TL_CSR%ROWTYPE;

BEGIN
      -- standard start of api savepoint
      SAVEPOINT update_system_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

       l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- if debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'update_system');
    END IF;

    -- if the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                                p_api_version             ||'-'||
                                p_commit                  ||'-'||
                                p_init_msg_list           ||'-'||
                                p_validation_level        );

         -- dump the systems query records
         csi_gen_utility_pvt.dump_sys_rec(p_system_rec);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- check for the profile option and enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- END enable trace
    ****/

    csi_systems_pvt.update_system(
        p_api_version                => p_api_version,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_system_rec                 => p_system_rec,
        p_txn_rec                    => p_txn_rec,
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

      -- Bug 	6675862
      -- Updating Child systems if Cascasde ownership is selected

      -- condition updated for bug 8604665
      --IF NVL(p_system_rec.CASCADE_CUST_TO_INS_FLAG,'N') = 'Y' THEN
       IF NVL(p_system_rec.CASCADE_CUST_TO_INS_FLAG,'N') = 'Y'
        OR NVL(p_system_rec.install_to_site_change_flag,'N') = 'Y'
        OR NVL(p_system_rec.bill_to_site_change_flag,'N') = 'Y'
        OR NVL(p_system_rec.ship_to_site_change_flag,'N') = 'Y'
        OR NVL(p_system_rec.tech_cont_change_flag,'N') = 'Y'
        OR NVL(p_system_rec.bill_to_cont_change_flag,'N') = 'Y'
        OR NVL(p_system_rec.ship_to_cont_change_flag,'N') = 'Y'
        OR NVL(p_system_rec.serv_admin_cont_change_flag,'N') = 'Y'
       THEN

        -- Retrive list of all child systems for the updated system
        l_parent_system_id := p_system_rec.system_id;

         FOR child_system_rec in CHILD_SYSTEM_CUR(l_parent_system_id)
         LOOP
           BEGIN

            -- Call Update system private with child system id
            -- l_child_system_rec := p_system_rec;
            -- Construct the child system cursor
            OPEN CHILD_SYSTEMS_DETAILS_CUR (child_system_rec.child_system_id);
            FETCH CHILD_SYSTEMS_DETAILS_CUR  INTO l_child_sys_details_rec;
            CLOSE CHILD_SYSTEMS_DETAILS_CUR;

            OPEN SYS_TL_CSR (child_system_rec.child_system_id);
            FETCH SYS_TL_CSR  INTO l_child_sys_tl_rec;
            CLOSE SYS_TL_CSR;

            l_child_system_rec.SYSTEM_ID                       	:=	child_system_rec.child_system_id                 ;
	    --commented for bug 8604665
            --l_child_system_rec.CUSTOMER_ID                     	:=	p_system_rec.CUSTOMER_ID                ;
            l_child_system_rec.SYSTEM_TYPE_CODE                	:=	l_child_sys_details_rec.SYSTEM_TYPE_CODE           ;
            l_child_system_rec.SYSTEM_NUMBER                   	:=	l_child_sys_details_rec.SYSTEM_NUMBER              ;
            l_child_system_rec.PARENT_SYSTEM_ID                	:=	l_child_sys_details_rec.PARENT_SYSTEM_ID           ;
            l_child_system_rec.COTERMINATE_DAY_MONTH           	:=	l_child_sys_details_rec.COTERMINATE_DAY_MONTH      ;
            l_child_system_rec.AUTOCREATED_FROM_SYSTEM_ID      	:=	l_child_sys_details_rec.AUTOCREATED_FROM_SYSTEM_ID ;
            l_child_system_rec.CONFIG_SYSTEM_TYPE              	:=	l_child_sys_details_rec.CONFIG_SYSTEM_TYPE         ;
            l_child_system_rec.START_DATE_ACTIVE               	:=	l_child_sys_details_rec.START_DATE_ACTIVE          ;
            l_child_system_rec.END_DATE_ACTIVE                 	:=	l_child_sys_details_rec.END_DATE_ACTIVE            ;
            l_child_system_rec.CONTEXT                         	:=	l_child_sys_details_rec.CONTEXT                    ;
            l_child_system_rec.ATTRIBUTE1                      	:=	l_child_sys_details_rec.ATTRIBUTE1                 ;
            l_child_system_rec.ATTRIBUTE2                      	:=	l_child_sys_details_rec.ATTRIBUTE2                 ;
            l_child_system_rec.ATTRIBUTE3                      	:=	l_child_sys_details_rec.ATTRIBUTE3                 ;
            l_child_system_rec.ATTRIBUTE4                      	:=	l_child_sys_details_rec.ATTRIBUTE4                 ;
            l_child_system_rec.ATTRIBUTE5                      	:=	l_child_sys_details_rec.ATTRIBUTE5                 ;
            l_child_system_rec.ATTRIBUTE6                      	:=	l_child_sys_details_rec.ATTRIBUTE6                 ;
            l_child_system_rec.ATTRIBUTE7                      	:=	l_child_sys_details_rec.ATTRIBUTE7                 ;
            l_child_system_rec.ATTRIBUTE8                      	:=	l_child_sys_details_rec.ATTRIBUTE8                 ;
            l_child_system_rec.ATTRIBUTE9                      	:=	l_child_sys_details_rec.ATTRIBUTE9                 ;
            l_child_system_rec.ATTRIBUTE10                     	:=	l_child_sys_details_rec.ATTRIBUTE10                ;
            l_child_system_rec.ATTRIBUTE11                     	:=	l_child_sys_details_rec.ATTRIBUTE11                ;
            l_child_system_rec.ATTRIBUTE12                     	:=	l_child_sys_details_rec.ATTRIBUTE12                ;
            l_child_system_rec.ATTRIBUTE13                     	:=	l_child_sys_details_rec.ATTRIBUTE13                ;
            l_child_system_rec.ATTRIBUTE14                     	:=	l_child_sys_details_rec.ATTRIBUTE14                ;
            l_child_system_rec.ATTRIBUTE15                     	:=	l_child_sys_details_rec.ATTRIBUTE15                ;
            l_child_system_rec.OBJECT_VERSION_NUMBER           	:=	l_child_sys_details_rec.OBJECT_VERSION_NUMBER      ;
            l_child_system_rec.NAME                            	:=	l_child_sys_tl_rec.NAME                       ;
            l_child_system_rec.DESCRIPTION                     	:=	l_child_sys_tl_rec.DESCRIPTION                ;
            --
            l_child_system_rec.OPERATING_UNIT_ID               	:=	l_child_sys_details_rec.OPERATING_UNIT_ID          ;
            l_child_system_rec.REQUEST_ID                      	:=	p_system_rec.REQUEST_ID                 ;
            l_child_system_rec.PROGRAM_APPLICATION_ID          	:=	p_system_rec.PROGRAM_APPLICATION_ID     ;
            l_child_system_rec.PROGRAM_ID                      	:=	p_system_rec.PROGRAM_ID                 ;
            l_child_system_rec.PROGRAM_UPDATE_DATE        	    :=	p_system_rec.PROGRAM_UPDATE_DATE        ;
            --

	    --bug 8604665 start
	    -- Cascading changes to the child systems
	    IF NVL(p_system_rec.CASCADE_CUST_TO_INS_FLAG,'N') = 'Y' THEN
              l_child_system_rec.CUSTOMER_ID  := p_system_rec.CUSTOMER_ID;
            ELSE
               l_child_system_rec.CUSTOMER_ID  :=  FND_API.G_MISS_NUM;
            END IF;

            IF NVL(p_system_rec.ship_to_site_change_flag,'N') = 'Y' THEN
              l_child_system_rec.SHIP_TO_SITE_USE_ID :=	p_system_rec.SHIP_TO_SITE_USE_ID;
            else
              l_child_system_rec.SHIP_TO_SITE_USE_ID :=	FND_API.G_MISS_NUM;
            END IF;

            IF NVL(p_system_rec.bill_to_site_change_flag,'N') = 'Y' THEN
              l_child_system_rec.BILL_TO_SITE_USE_ID :=	p_system_rec.BILL_TO_SITE_USE_ID;
            else
              l_child_system_rec.BILL_TO_SITE_USE_ID :=	FND_API.G_MISS_NUM;
            END IF;

            IF NVL(p_system_rec.install_to_site_change_flag,'N') = 'Y' then
              l_child_system_rec.INSTALL_SITE_USE_ID :=  p_system_rec.INSTALL_SITE_USE_ID;
            else
              l_child_system_rec.INSTALL_SITE_USE_ID :=	FND_API.G_MISS_NUM;
            end if;

            IF NVL(p_system_rec.tech_cont_change_flag,'N') = 'Y' THEN
              l_child_system_rec.TECHNICAL_CONTACT_ID := p_system_rec.TECHNICAL_CONTACT_ID;

            ELSE
               l_child_system_rec.TECHNICAL_CONTACT_ID := FND_API.G_MISS_NUM;
            END IF;

            IF NVL(p_system_rec.bill_to_cont_change_flag,'N') = 'Y' THEN

             l_child_system_rec.BILL_TO_CONTACT_ID := p_system_rec.BILL_TO_CONTACT_ID;
            ELSE
              l_child_system_rec.BILL_TO_CONTACT_ID := FND_API.G_MISS_NUM;
            END IF;


            IF NVL(p_system_rec.ship_to_cont_change_flag,'N') = 'Y' THEN
              l_child_system_rec.SHIP_TO_CONTACT_ID := p_system_rec.SHIP_TO_CONTACT_ID;
            ELSE
              l_child_system_rec.SHIP_TO_CONTACT_ID := FND_API.G_MISS_NUM;
            END IF;


            IF NVL(p_system_rec.serv_admin_cont_change_flag,'N') = 'Y' THEN
             l_child_system_rec.SERVICE_ADMIN_CONTACT_ID := p_system_rec.SERVICE_ADMIN_CONTACT_ID;
            ELSE
              l_child_system_rec.SERVICE_ADMIN_CONTACT_ID := FND_API.G_MISS_NUM;
            END IF;

            --bug 8604665 end

            -- The Cascade Ownership flag is set so other location details from the
            -- parent system wont be cascaded

	    --commented for bug 8604665
            /*
	    l_child_system_rec.SHIP_TO_CONTACT_ID              	:=	FND_API.G_MISS_NUM;
            l_child_system_rec.BILL_TO_CONTACT_ID              	:=	FND_API.G_MISS_NUM;
            l_child_system_rec.TECHNICAL_CONTACT_ID            	:=	FND_API.G_MISS_NUM;
            l_child_system_rec.SERVICE_ADMIN_CONTACT_ID        	:=	FND_API.G_MISS_NUM;
            l_child_system_rec.SHIP_TO_SITE_USE_ID             	:=	FND_API.G_MISS_NUM;
            l_child_system_rec.BILL_TO_SITE_USE_ID             	:=	FND_API.G_MISS_NUM;
            l_child_system_rec.INSTALL_SITE_USE_ID             	:=	FND_API.G_MISS_NUM;
            */

            l_child_system_rec.TECH_CONT_CHANGE_FLAG           	:=	FND_API.G_MISS_CHAR;
            l_child_system_rec.BILL_TO_CONT_CHANGE_FLAG        	:=	FND_API.G_MISS_CHAR;
            l_child_system_rec.SHIP_TO_CONT_CHANGE_FLAG        	:=	FND_API.G_MISS_CHAR;
            l_child_system_rec.SERV_ADMIN_CONT_CHANGE_FLAG     	:=	FND_API.G_MISS_CHAR;
            l_child_system_rec.BILL_TO_SITE_CHANGE_FLAG        	:=	FND_API.G_MISS_CHAR;
            l_child_system_rec.SHIP_TO_SITE_CHANGE_FLAG        	:=	FND_API.G_MISS_CHAR;
            l_child_system_rec.INSTALL_TO_SITE_CHANGE_FLAG     	:=	FND_API.G_MISS_CHAR;
            l_child_system_rec.CASCADE_CUST_TO_INS_FLAG        	:=	FND_API.G_MISS_CHAR;

            csi_gen_utility_pvt.put_line('Updating Child System ID - ' || l_child_system_rec.system_id);
            csi_gen_utility_pvt.put_line('Corresponding Parent System ID - ' || l_child_system_rec.parent_system_id);

            csi_systems_pvt.update_system(
              p_api_version                => p_api_version,
              p_commit                     => fnd_api.g_false,
              p_init_msg_list              => p_init_msg_list,
              p_validation_level           => p_validation_level,
              p_system_rec                 => l_child_system_rec,
              p_txn_rec                    => p_txn_rec,
              x_return_status              => x_return_status,
              x_msg_count                  => x_msg_count,
              x_msg_data                   => x_msg_data
              );

           EXCEPTION
            WHEN OTHERS THEN
               csi_gen_utility_pvt.put_line( 'Into Others Exception in Cascade to Child Systems');
               csi_gen_utility_pvt.put_line( 'SQLCODE - ' || SQLCODE);
               csi_gen_utility_pvt.put_line( 'SQLERRM - ' || substr(SQLERRM, 1, 200));
           END;
         END LOOP; -- child_system_rec in CHILD_SYSTEM_CUR(p_system_rec.system_id)

      END IF; -- NVL(p_system_rec.CASCADE_CUST_TO_INS_FLAG,'N') = 'Y'
      -- End Bug 6675862

      --
      -- end of api body
      --

      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      /***** srramakr commented for bug # 3304439
      IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
      END IF;
      ****/

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO update_system_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO update_system_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO update_system_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
END update_system;

PROCEDURE expire_system
 (
     p_api_version                 IN     NUMBER,
     p_commit                      IN     VARCHAR2,
     p_init_msg_list               IN     VARCHAR2,
     p_validation_level            IN     NUMBER,
     p_system_rec                  IN     csi_datastructures_pub.system_rec,
     p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY    csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY    VARCHAR2,
     x_msg_count                   OUT NOCOPY    NUMBER,
     x_msg_data                    OUT NOCOPY    VARCHAR2
 )
 is
l_api_name                   CONSTANT VARCHAR2(30) := 'expire_system';
l_api_version                CONSTANT NUMBER       := 1.0;
-- local variables
l_rowid  rowid;
l_flag                                VARCHAR2(1)  :='N';
l_debug_level                         NUMBER;


BEGIN
      -- standard start of api savepoint
      SAVEPOINT expire_system_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


      -- standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list if p_init_msg_list is set to true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status to success
      x_return_status := fnd_api.g_ret_sts_success;

       l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- if debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'update_system');
    END IF;

    -- if the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level
                            );

         -- dump the systems query records
         csi_gen_utility_pvt.dump_sys_rec(p_system_rec);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);


    END IF;

    /***** srramakr commented for bug # 3304439
    -- check for the profile option and enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- end enable trace
    ****/

    csi_systems_pvt.expire_system(
        p_api_version                => p_api_version,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_system_rec                 => p_system_rec,
        p_txn_rec                    => p_txn_rec,
        x_instance_id_lst            => x_instance_id_lst,
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

      /***** srramakr commented for bug # 3304439
      IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
       ****/

      -- standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO expire_system_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO expire_system_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO expire_system_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

 END expire_system;




END csi_systems_pub;

/
