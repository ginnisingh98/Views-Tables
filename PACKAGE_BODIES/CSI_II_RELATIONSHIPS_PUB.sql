--------------------------------------------------------
--  DDL for Package Body CSI_II_RELATIONSHIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_II_RELATIONSHIPS_PUB" AS
/* $Header: csipiirb.pls 120.2.12010000.2 2009/01/22 00:51:50 fli ship $ */
-- start of comments
-- package name     : csi_ii_relationships_pub
-- purpose          :
-- history          :
-- note             :
-- END of comments


g_pkg_name CONSTANT VARCHAR2(30)  := 'csi_ii_relationships_pub';
g_file_name CONSTANT VARCHAR2(12) := 'csipiirb.pls';


PROCEDURE get_relationships
 (
     p_api_version               IN  NUMBER,
     p_commit                    IN  VARCHAR2,
     p_init_msg_list             IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     p_relationship_query_rec    IN  csi_datastructures_pub.relationship_query_rec,
     p_depth                     IN  NUMBER,
     p_time_stamp                IN  DATE,
     p_active_relationship_only  IN  VARCHAR2,
     x_relationship_tbl          OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
     x_return_status             OUT NOCOPY VARCHAR2,
     x_msg_count                 OUT NOCOPY NUMBER,
     x_msg_data                  OUT NOCOPY VARCHAR2
 )
 is
l_api_name                  CONSTANT VARCHAR2(30) := 'get_relationships';
l_api_version               CONSTANT NUMBER       := 1.0;
l_return_status_full                 VARCHAR2(1);
l_access_flag                        VARCHAR2(1);
i                                    NUMBER       := 1;
l_flag                               VARCHAR2(1)  :='N';
l_debug_level                        NUMBER;

 BEGIN
      -- standard start of api SAVEPOINT
      --SAVEPOINT get_relationships_pub;

      -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

      -- standard call TO check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list is set TO true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;



      -- initialize api return status TO success
      x_return_status := fnd_api.g_ret_sts_success;

     l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- IF debug_level = 1 THEN dump the PROCEDURE name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'get_relationships');
    END IF;

    -- IF the debug level = 2 THEN dump all the parameters values.
    IF (l_debug_level > 1) THEN
             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level        ||'-'||
                            p_depth                   ||'_'||
                            p_time_stamp              );

         -- dump the relationship query records
         csi_gen_utility_pvt.dump_rel_query_rec(p_relationship_query_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- check for the profile option AND enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- END enable trace
    ****/

      --
      -- api body
      --
      -- debug message

     csi_ii_relationships_pvt.get_relationships(
        p_api_version                => p_api_version,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_relationship_query_rec     => p_relationship_query_rec,
        p_depth                      => p_depth,
        p_time_stamp                 => p_time_stamp,
        p_active_relationship_only   => p_active_relationship_only,
        x_relationship_tbl           => x_relationship_tbl,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
        );




      -- check return status FROM the above PROCEDURE call
      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- END of api body
      --
      /***** srramakr commented for bug # 3304439
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(FALSE);
        END IF;
      ****/

      -- standard call TO get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
               -- ROLLBACK TO get_relationships_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
              --  ROLLBACK TO get_relationships_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                         );

          WHEN others THEN
            --    ROLLBACK TO get_relationships_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                   fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                         );
END get_relationships;

PROCEDURE create_relationship(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_relationship_tbl           IN OUT NOCOPY csi_datastructures_pub.ii_relationship_tbl,
    p_txn_rec                    IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 is
l_api_name                CONSTANT VARCHAR2(30) := 'create_relationship';
l_api_version             CONSTANT NUMBER       := 1.0;
l_return_status_full               VARCHAR2(1);
l_access_flag                      VARCHAR2(1);
l_ii_relationship_rec              csi_datastructures_pub.ii_relationship_rec;
l_line_count                       NUMBER;
l_relationship_id                  NUMBER;
l_object_version_number            NUMBER;
l_transaction_rec                  csi_datastructures_pub.transaction_rec :=p_txn_rec;
l_flag                             VARCHAR2(1)  :='N';
l_debug_level                      NUMBER;
l_relationship_tbl                 csi_datastructures_pub.ii_relationship_tbl;
l_dummy_tbl                        csi_datastructures_pub.ii_relationship_tbl;
l_msg_count                        NUMBER;
l_msg_data                         VARCHAR2(2000);
l_msg_index                        NUMBER;
-- Begin Add Code for Siebel Genesis Project
l_owner_party_id                   NUMBER;
l_internal_party_id                NUMBER;
l_raise_bes_event                  VARCHAR2(1) := nvl(fnd_profile.value('CSI_RAISE_BES_CUST_OWNED_INSTANCES'),'N');
l_relationship_exists              VARCHAR2(1);
l_root_asset_id                    NUMBER;
-- End Add Code for Siebel Genesis Project
 BEGIN
      -- standard start of api savepoint
      SAVEPOINT create_relationship_pub;

      -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

      -- standard call TO check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list is set TO true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;



      -- initialize api return status TO success
      x_return_status := fnd_api.g_ret_sts_success;

       l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- IF debug_level = 1 THEN dump the PROCEDURE name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'create_relationship');
    END IF;

    -- IF the debug level = 2 THEN dump all the parameters values.
    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level        );

         -- dump the relationship query records
         csi_gen_utility_pvt.dump_rel_tbl(p_relationship_tbl);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- check for the profile option AND enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- END enable trace
    ****/


    -- calling private package: create_relationships
    -- hint: primary key needs TO be returned
    l_line_count := p_relationship_tbl.count;

     FOR l_count IN 1..l_line_count LOOP

        BEGIN
           SELECT relationship_id,
                  object_version_number
           INTO   l_relationship_id,
                  l_object_version_number
           FROM   csi_ii_relationships
           where relationship_id = (select max(relationship_id)
                                    from CSI_II_RELATIONSHIPS
                                    WHERE  object_id=p_relationship_tbl(l_count).object_id
                                    AND    subject_id=p_relationship_tbl(l_count).subject_id -- sguthiva added for bug 2370120
                                    AND    nvl(position_reference,fnd_api.g_miss_char) =
                                                     nvl(p_relationship_tbl(l_count).position_reference,fnd_api.g_miss_char)
                                    AND    relationship_type_code=p_relationship_tbl(l_count).relationship_type_code
                                    AND    active_end_date IS NOT NULL);
           --
           l_relationship_tbl(1):=p_relationship_tbl(l_count);
           l_relationship_tbl(1).relationship_id:=l_relationship_id;
           l_relationship_tbl(1).object_version_number:=l_object_version_number;
           l_relationship_tbl(1).subject_id:=p_relationship_tbl(l_count).subject_id;

           IF p_relationship_tbl(l_count).active_end_date IS NULL OR
              p_relationship_tbl(l_count).active_end_date = fnd_api.g_miss_date
           THEN
              l_relationship_tbl(1).active_end_date:=NULL;
           END IF;

            csi_ii_relationships_pvt.update_relationship(
            p_api_version                => p_api_version,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => p_init_msg_list,
            p_validation_level           => p_validation_level,
            p_relationship_tbl           => l_relationship_tbl,
            p_txn_rec                    => p_txn_rec,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data
            );

	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		       l_msg_index := 1;
		       l_msg_count := x_msg_count;
	      WHILE l_msg_count > 0 LOOP
		       x_msg_data := FND_MSG_PUB.GET
			       (  l_msg_index,
					      FND_API.G_FALSE        );
	       csi_gen_utility_pvt.put_line( ' Error from Update_relationship PVT..');
	       csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		   l_msg_index := l_msg_index + 1;
		   l_msg_count := l_msg_count - 1;
		  END LOOP;
	      RAISE FND_API.G_EXC_ERROR;
	    END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
         --   l_relationship_tbl:=l_dummy_tbl;
            l_relationship_tbl(1):=p_relationship_tbl(l_count);
            csi_ii_relationships_pvt.create_relationship(
            p_api_version                => p_api_version,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => p_init_msg_list,
            p_validation_level           => p_validation_level,
            p_relationship_tbl           => l_relationship_tbl,
            p_txn_rec                    => p_txn_rec,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data
            );

	    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		       l_msg_index := 1;
		       l_msg_count := x_msg_count;
	      WHILE l_msg_count > 0 LOOP
		       x_msg_data := FND_MSG_PUB.GET
			       (  l_msg_index,
					      FND_API.G_FALSE        );
	       csi_gen_utility_pvt.put_line( ' Error from Create_relationship PVT..');
	       csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		   l_msg_index := l_msg_index + 1;
		   l_msg_count := l_msg_count - 1;
		  END LOOP;
	      RAISE FND_API.G_EXC_ERROR;
	    END IF;

         END;
         p_relationship_tbl(l_count).relationship_id:=l_relationship_tbl(1).relationship_id;

         -- Begin Add Code for Siebel Genesis Project
         IF l_raise_bes_event = 'Y' THEN
            BEGIN
               SELECT owner_party_id
               INTO   l_owner_party_id
               FROM   csi_item_instances
               WHERE  instance_id = p_relationship_tbl(l_count).object_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_owner_party_id := null;
            END;

            BEGIN
               SELECT internal_party_id
               INTO   l_internal_party_id
               FROM   csi_install_parameters;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  l_internal_party_id := null;
            END;

            IF l_internal_party_id <> l_owner_party_id THEN
               csi_gen_utility_pvt.put_line(' Calling CSI_BUSINESS_EVENT_PVT.UPDATE_INSTANCE_EVENT');
	         -- Check if relationships is already been built then allow update
                BEGIN
                   SELECT 'Y'
                   INTO   l_relationship_exists
                   FROM   csi_ii_relationships
                   WHERE  relationship_type_code = 'COMPONENT-OF'
                   AND    nvl(active_end_date, sysdate + 1) >= sysdate
                   AND    (object_id =  p_relationship_tbl(l_count).object_id OR
                          subject_id =  p_relationship_tbl(l_count).object_id);
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      l_relationship_exists := 'N';
                   WHEN TOO_MANY_ROWS THEN
                      l_relationship_exists := 'Y';
                END;

	       IF l_relationship_exists = 'Y' THEN
                 csi_gen_utility_pvt.put_line('In relationships, therefore raise the update instance event');
                 csi_gen_utility_pvt.put_line('The Subject Id '||p_relationship_tbl(l_count).subject_id);
                 csi_gen_utility_pvt.put_line('The Object Id '||p_relationship_tbl(l_count).object_id);
                 csi_gen_utility_pvt.put_line('The relationship_type_code '||p_relationship_tbl(l_count).relationship_type_code);

	         l_root_asset_id :=csi_ii_relationships_pvt.Get_Root_Parent(p_relationship_tbl(l_count).subject_id,
                                                        p_relationship_tbl(l_count).relationship_type_code,
                                                        p_relationship_tbl(l_count).object_id);
               END IF;
               --Bug 6990065, base bug 6916919, by requirement, update event should be raised instead of create event when relationship is created
               CSI_BUSINESS_EVENT_PVT.UPDATE_INSTANCE_EVENT
                 (p_api_version          => p_api_version
                  ,p_commit              => fnd_api.g_false
                  ,p_init_msg_list       => p_init_msg_list
                  ,p_validation_level    => p_validation_level
                  ,p_instance_id         => p_relationship_tbl(l_count).subject_id
                  ,p_subject_instance_id => nvl(l_root_asset_id, p_relationship_tbl(l_count).object_id)
                  ,x_return_status       => x_return_status
                  ,x_msg_count           => x_msg_count
                  ,x_msg_data            => x_msg_data
                 );

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;

                   WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                      csi_gen_utility_pvt.put_line('Error from CSI_BUSINESS_EVENT.UPDATE_INSTANCE_EVENT');
                      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                      l_msg_index := l_msg_index + 1;
                      l_msg_count := l_msg_count - 1;
                   END LOOP;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
             END IF;
          END IF;
          -- End Add Code for Siebel Genesis Project
       END LOOP;

   -- Here we call update_version_time to update date_time_stamp of
   -- version labels created with this transaction_id to sysdate.
         csi_item_instance_pvt.update_version_time
         ( p_api_version           => p_api_version
          ,p_commit                => fnd_api.g_false
          ,p_init_msg_list         => p_init_msg_list
          ,p_validation_level      => p_validation_level
          ,p_txn_rec               => p_txn_rec
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data);

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
          csi_gen_utility_pvt.put_line( ' Error from UPDATE_VERSION_TIME..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;


      -- check return status FROM the above PROCEDURE call
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

      /***** srramakr commented for bug # 3304439
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(FALSE);
        END IF;
      ****/
      -- standard call TO get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO create_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO create_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                         );

          WHEN OTHERS THEN
                ROLLBACK TO create_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

END create_relationship;


PROCEDURE update_relationship
 (
     p_api_version                IN  NUMBER,
     p_commit                     IN  VARCHAR2,
     p_init_msg_list              IN  VARCHAR2,
     p_validation_level           IN  NUMBER,
     p_relationship_tbl           IN      csi_datastructures_pub.ii_relationship_tbl,
     p_txn_rec                    IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_return_status              OUT NOCOPY VARCHAR2,
     x_msg_count                  OUT NOCOPY NUMBER,
     x_msg_data                   OUT NOCOPY VARCHAR2
 )
  is
l_api_name                   CONSTANT VARCHAR2(30) := 'update_ii_relationships';
l_api_version                CONSTANT NUMBER       := 1.0;
-- local variables
l_rowid  rowid;
l_flag                                VARCHAR2(1)  :='N';
l_debug_level                         NUMBER;
l_msg_count                           NUMBER;
l_msg_data                            VARCHAR2(2000);
l_msg_index                           NUMBER;
l_line_count                          NUMBER; -- Added for replacement bug.
l_relationship_tbl                    csi_datastructures_pub.ii_relationship_tbl:=p_relationship_tbl;
l_rel_tbl                             csi_datastructures_pub.ii_relationship_tbl:=p_relationship_tbl;
l_replace_flag                        VARCHAR2(1);
BEGIN
      -- standard start of api savepoint
      SAVEPOINT update_relationship_pub;

      -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

      -- standard call TO check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list is set TO true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


      -- initialize api return status TO success
      x_return_status := fnd_api.g_ret_sts_success;

       l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- IF debug_level = 1 THEN dump the PROCEDURE name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'update_relationship');
    END IF;

    -- IF the debug level = 2 THEN dump all the parameters values.
    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level        );

         -- dump the relationship query records
         csi_gen_utility_pvt.dump_rel_tbl(p_relationship_tbl);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- check for the profile option AND enable trace
    l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
    -- END enable trace
    ****/

    -- Added for replacement bug
     l_line_count := l_relationship_tbl.count;

     FOR l_count IN 1..l_line_count
     LOOP
     l_replace_flag:=fnd_api.g_false;
        IF l_relationship_tbl(l_count).relationship_id IS NOT NULL AND
           l_relationship_tbl(l_count).relationship_id <> fnd_api.g_miss_num AND
           l_relationship_tbl(l_count).active_end_date IS NOT NULL AND
           l_relationship_tbl(l_count).active_end_date <> fnd_api.g_miss_date
   -- Here I got a record which has an end date.
        THEN
          FOR l_search IN 1..l_line_count
          LOOP
            IF l_relationship_tbl(l_search).subject_id = l_relationship_tbl(l_count).subject_id AND
               l_relationship_tbl(l_search).object_id <> l_relationship_tbl(l_count).object_id AND
              (l_relationship_tbl(l_search).active_end_date IS NULL OR
               l_relationship_tbl(l_search).active_end_date = fnd_api.g_miss_date OR
               l_relationship_tbl(l_search).active_end_date > SYSDATE)
            THEN
    -- Here I found a record with the same subject, meaning parent swap.
               l_replace_flag:=fnd_api.g_true;
               EXIT;
            END IF;
          END LOOP;

        END IF;

       IF ((l_relationship_tbl(l_count).relationship_id IS NOT NULL AND
            l_relationship_tbl(l_count).relationship_id <> fnd_api.g_miss_num)) AND
            x_return_status = FND_API.G_RET_STS_SUCCESS
       THEN

       l_rel_tbl.delete;
       l_rel_tbl(1):=l_relationship_tbl(l_count);
       csi_gen_utility_pvt.put_line('Value of relationship_id is : '||l_rel_tbl(1).relationship_id);
       csi_gen_utility_pvt.put_line('Value of replace_flag is :'||l_replace_flag);
       csi_ii_relationships_pvt.update_relationship(
           p_api_version                => p_api_version,
           p_commit                     => fnd_api.g_false,
           p_init_msg_list              => p_init_msg_list,
           p_validation_level           => p_validation_level,
           p_relationship_tbl           => l_rel_tbl,
           p_replace_flag               => l_replace_flag,
           p_txn_rec                    => p_txn_rec,
           x_return_status              => x_return_status,
           x_msg_count                  => x_msg_count,
           x_msg_data                   => x_msg_data
           );
       END IF;

     END LOOP;
    -- End addition for replacement

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
          csi_gen_utility_pvt.put_line( ' Error from csi_ii_relationships_pvt.update_relationship..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

    -- Added for replacement

     FOR l_count IN 1..l_line_count
     LOOP
       IF ((l_relationship_tbl(l_count).relationship_id IS NULL OR
            l_relationship_tbl(l_count).relationship_id = fnd_api.g_miss_num)) AND
            x_return_status = FND_API.G_RET_STS_SUCCESS
       THEN
       l_rel_tbl.delete;
       l_rel_tbl(1):=l_relationship_tbl(l_count);
        csi_ii_relationships_pvt.create_relationship(
            p_api_version                => p_api_version,
            p_commit                     => fnd_api.g_false,
            p_init_msg_list              => p_init_msg_list,
            p_validation_level           => p_validation_level,
            p_relationship_tbl           => l_rel_tbl,
            p_txn_rec                    => p_txn_rec,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data
            );
       END IF;
     END LOOP;

     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0
         LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
          csi_gen_utility_pvt.put_line( ' Error from csi_ii_relationships_pvt.create_relationship..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
         END LOOP;
           RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- End addition for replacement


      -- check return status FROM the above PROCEDURE call
      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --
      -- END of api body
      --

   -- Here we call update_version_time to update date_time_stamp of
   -- version labels created with this transaction_id to sysdate.
         csi_item_instance_pvt.update_version_time
         ( p_api_version           => p_api_version
          ,p_commit                => fnd_api.g_false
          ,p_init_msg_list         => p_init_msg_list
          ,p_validation_level      => p_validation_level
          ,p_txn_rec               => p_txn_rec
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data);

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
          csi_gen_utility_pvt.put_line( ' Error from UPDATE_VERSION_TIME..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      /***** srramakr commented for bug # 3304439
      IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(FALSE);
        END IF;
      ****/
      -- standard call TO get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO update_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO update_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO update_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
END update_relationship;


-- hint: add corresponding delete detail table PROCEDUREs IF it's master-detail relationship.
--       the master delete PROCEDURE may NOT be needed depends on different business requirements.
PROCEDURE expire_relationship
 (
     p_api_version                 IN  NUMBER,
     p_commit                      IN  VARCHAR2,
     p_init_msg_list               IN  VARCHAR2,
     p_validation_level            IN  NUMBER,
     p_relationship_rec            IN  csi_datastructures_pub.ii_relationship_rec,
     p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec,
     x_instance_id_lst             OUT NOCOPY csi_datastructures_pub.id_tbl,
     x_return_status               OUT NOCOPY VARCHAR2,
     x_msg_count                   OUT NOCOPY NUMBER,
     x_msg_data                    OUT NOCOPY VARCHAR2
 )
 IS
l_api_name                    CONSTANT VARCHAR2(30) := 'delete_ii_relationships';
l_api_version                 CONSTANT NUMBER       := 1.0;
l_flag                                 VARCHAR2(1)  :='N';
l_debug_level                          NUMBER;


 BEGIN
      -- standard start of api savepoint
      SAVEPOINT expire_relationship_pub;

      -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

      -- standard call TO check for call compatibility.
      IF NOT fnd_api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- initialize message list IF p_init_msg_list is set TO true.
      IF fnd_api.to_boolean( p_init_msg_list )
      THEN
          fnd_msg_pub.initialize;
      END IF;


            -- initialize api return status TO success
      x_return_status := fnd_api.g_ret_sts_success;

      l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');
        -- IF debug_level = 1 THEN dump the PROCEDURE name
    IF (l_debug_level > 0) THEN
          CSI_gen_utility_pvt.put_line( 'expire_relationship');
    END IF;

    -- IF the debug level = 2 THEN dump all the parameters values.
    IF (l_debug_level > 1) THEN


             CSI_gen_utility_pvt.put_line(
                            p_api_version             ||'-'||
                            p_commit                  ||'-'||
                            p_init_msg_list           ||'-'||
                            p_validation_level
                           );

         -- dump the relationship query records
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
         csi_gen_utility_pvt.dump_rel_rec(p_relationship_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
       -- check for the profile option AND enable trace
      l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
       -- END enable trace
     *****/

    csi_ii_relationships_pvt.expire_relationship(
        p_api_version                => p_api_version,
        p_commit                     => fnd_api.g_false,
        p_init_msg_list              => p_init_msg_list,
        p_validation_level           => p_validation_level,
        p_relationship_rec           => p_relationship_rec,
        p_txn_rec                    => p_txn_rec,
        x_instance_id_lst            => x_instance_id_lst,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
        );





      -- check return status FROM the above PROCEDURE call
      IF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;



      -- standard check for p_commit
      IF fnd_api.to_boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      /***** srramakr commented for bug # 3304439
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(FALSE);
        END IF;
       *****/
      -- standard call TO get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN fnd_api.g_exc_error THEN
                ROLLBACK TO expire_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK TO expire_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );

          WHEN OTHERS THEN
                ROLLBACK TO expire_relationship_pub;
                x_return_status := fnd_api.g_ret_sts_unexp_error ;
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                         fnd_msg_pub.add_exc_msg(g_pkg_name ,l_api_name);
                  END IF;
                fnd_msg_pub.count_and_get
                        (p_count => x_msg_count ,
                         p_data => x_msg_data
                        );
END expire_relationship;



END csi_ii_relationships_pub;

/
