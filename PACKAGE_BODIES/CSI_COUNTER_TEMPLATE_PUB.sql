--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_TEMPLATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_TEMPLATE_PUB" AS
/* $Header: csipcttb.pls 120.16.12010000.2 2008/10/31 21:18:34 rsinn ship $ */
/*#
 * This is a public API for managing Counter Grouping and
 * Counter Template.
 * It contains routines to Create and Update Counter Grouping,
 * Counter Template, Item Associations, Derived Filters,
 * Counter Relationships
 * @rep:scope public
 * @rep:product CSI
 * @rep:displayname Manage Counter Template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CSI_COUNTER
*/
-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

-- G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_TEMPLATE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipcttb.pls';

--|---------------------------------------------------
--| procedure name: create_counter_group
--| description :   procedure used to
--|                 create counter group
--|---------------------------------------------------
/*#
 * This procedure is used to create counter group
 * In this process, it also creates counter item associations
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_groups_rec  Counter Group Record structure
 * @param p_ctr_item_associations_tbl Counter Item Associations Table structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Group
 */

PROCEDURE create_counter_group
 (p_api_version               IN     NUMBER
  ,p_commit                    IN     VARCHAR2
  ,p_init_msg_list             IN     VARCHAR2
  ,p_validation_level          IN     NUMBER
  ,p_counter_groups_rec        IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
  ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
  ,x_return_status                OUT    NOCOPY VARCHAR2
  ,x_msg_count                    OUT    NOCOPY NUMBER
  ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER_GROUP';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_counter_group;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter_group');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter_group'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_grp_rec(p_counter_groups_rec);
   END IF;

   -- Calling Customer Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  )  then
      CSI_COUNTER_TEMPLATE_CUHK.CREATE_COUNTER_GROUP_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_groups_rec   => p_counter_groups_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.CREATE_COUNTER_GROUP_PRE API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  )  then
      CSI_COUNTER_TEMPLATE_VUHK.CREATE_COUNTER_GROUP_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_groups_rec   => p_counter_groups_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.CREATE_COUNTER_GROUP_PRE API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.create_counter_group
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_counter_groups_rec => p_counter_groups_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_COUNTER_GROUP');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_CUHK.CREATE_COUNTER_GROUP_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.CREATE_COUNTER_GROUP_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_counter_groups_rec   => p_counter_groups_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.CREATE_COUNTER_GROUP_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.CREATE_COUNTER_GROUP_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_counter_groups_rec   => p_counter_groups_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.CREATE_COUNTER_GROUP_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

   -- Call the create_item_associations to create the item associations

   IF (p_ctr_item_associations_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_item_associations_tbl.FIRST .. p_ctr_item_associations_tbl.LAST
      LOOP
         IF p_ctr_item_associations_tbl.EXISTS(tab_row) THEN
            p_ctr_item_associations_tbl(tab_row).group_id := p_counter_groups_rec.counter_group_id;

            csi_ctr_gen_utility_pvt.put_line('inside item association..p_ctr_groups_rec = '||to_char(p_counter_groups_rec.counter_group_id));
            csi_ctr_gen_utility_pvt.put_line('item group id = '||to_char(p_ctr_item_associations_tbl(tab_row).group_id));

           create_item_association
             (
               p_api_version      => p_api_version
    	       ,p_commit           => fnd_api.g_false
               ,p_init_msg_list    => p_init_msg_list
               ,p_validation_level => p_validation_level
               ,p_ctr_item_associations_rec => p_ctr_item_associations_tbl(tab_row)
               ,x_return_status    => x_return_status
               ,x_msg_count        => x_msg_count
               ,x_msg_data         => x_msg_data
             );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                x_msg_data := FND_MSG_PUB.GET
                             (l_msg_index,
                              FND_API.G_FALSE);
                csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_ITEM_ASSOCIATIONS');
                csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                l_msg_index := l_msg_index + 1;
                l_msg_count := l_msg_count - 1;
              END LOOP;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
      END LOOP;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_counter_group;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_group;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_group;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_counter_group;


--|---------------------------------------------------
--| procedure name: create_item_association
--| description :   procedure used to
--|                 create item association to
--|                 counter group or counters
--|---------------------------------------------------
/*#
 * This procedure is used to create counter item associations
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_item_associations_rec Counter Item Associations Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Item Association
 */

PROCEDURE create_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_ITEM_ASSOCIATION';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_item_association;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_item_association');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line('create_item_association'     ||
                                        p_api_version         ||'-'||
                                        p_commit              ||'-'||
                                        p_init_msg_list       ||'-'||
                                        p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_item_assoc_rec(p_ctr_item_associations_rec);
   END IF;

   -- Calling Customer Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.CREATE_ITEM_ASSOCIATION_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_item_associations_rec   => p_ctr_item_associations_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.CREATE_ITEM_ASSOCIATION_PRE API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.CREATE_ITEM_ASSOCIATION_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_item_associations_rec  => p_ctr_item_associations_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.CREATE_ITEM_ASSOCIATION_PRE API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.create_item_association
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_item_associations_rec => p_ctr_item_associations_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line(' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_ITEM_ASSOCIATION');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_CUHK.CREATE_ITEM_ASSOCIATION_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.CREATE_ITEM_ASSOCIATION_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_item_associations_rec => p_ctr_item_associations_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.CREATE_ITEM_ASSOCIATION_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.CREATE_ITEM_ASSOCIATION_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.CREATE_ITEM_ASSOCIATION_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_item_associations_rec => p_ctr_item_associations_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.CREATE_ITEM_ASSOCIATION_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_item_association;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_item_association;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_item_association;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_item_association;

--|---------------------------------------------------
--| procedure name: create_counter_template
--| description :   procedure used to
--|                 create counter template
--|---------------------------------------------------
/*#
 * This procedure is used to create counter template.
 * This will also create Item Association, Properties
 * derived filters, relationships.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_template_rec Counter Template Record structure
 * @param p_ctr_item_associations_tbl Counter Item Associations Table structure
 * @param p_ctr_property_template_tbl Counter property template Table structure
 * @param p_counter_relationships_tbl Counter relationships Table structure
 * @param p_ctr_derived_filters_tbl Counter Derived Filters Table structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Template
 */

PROCEDURE create_counter_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER_TEMPLATE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_counter_template ;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter_template');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter_template'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_template_rec(p_counter_template_rec);
   END IF;

   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.create_counter_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_counter_template_rec      => p_counter_template_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
               ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
               ,p_counter_relationships_tbl => p_counter_relationships_tbl
               ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_counter_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.create_counter_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_counter_template_rec      => p_counter_template_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
               ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
               ,p_counter_relationships_tbl => p_counter_relationships_tbl
               ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_counter_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.create_counter_template
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_counter_template_rec => p_counter_template_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_COUNTER_TEMPLATE');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_VUHK.create_counter_template_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.create_counter_template_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
             ,p_counter_template_rec      => p_counter_template_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
             ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
             ,p_counter_relationships_tbl => p_counter_relationships_tbl
             ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_counter_template_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.create_counter_template_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.create_counter_template_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
             ,p_counter_template_rec      => p_counter_template_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
             ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
             ,p_counter_relationships_tbl => p_counter_relationships_tbl
             ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_counter_template_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks


   IF (p_ctr_item_associations_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_item_associations_tbl.FIRST .. p_ctr_item_associations_tbl.LAST
      LOOP
         IF p_ctr_item_associations_tbl.EXISTS(tab_row) THEN
            p_ctr_item_associations_tbl(tab_row).counter_id := p_counter_template_rec.counter_id;

            create_item_association
              (
                p_api_version      => p_api_version
               ,p_commit           => fnd_api.g_false
               ,p_init_msg_list    => p_init_msg_list
               ,p_validation_level => p_validation_level
               ,p_ctr_item_associations_rec => p_ctr_item_associations_tbl(tab_row)
               ,x_return_status    => x_return_status
               ,x_msg_count        => x_msg_count
               ,x_msg_data         => x_msg_data
              );

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET
                                 (l_msg_index,
                                  FND_API.G_FALSE);
                   csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_ITEM_ASSOCIATIONS');
                   csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                   l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
      END LOOP;
    END IF;

   IF (p_ctr_property_template_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_property_template_tbl.FIRST .. p_ctr_property_template_tbl.LAST
      LOOP
         IF p_ctr_property_template_tbl.EXISTS(tab_row) THEN
            p_ctr_property_template_tbl(tab_row).counter_id := p_counter_template_rec.counter_id;

	      create_ctr_property_template
	        (
	          p_api_version      => p_api_version
	         ,p_commit           => fnd_api.g_false
	         ,p_init_msg_list    => p_init_msg_list
	         ,p_validation_level => p_validation_level
	         ,p_ctr_property_template_rec => p_ctr_property_template_tbl(tab_row)
	         ,x_return_status    => x_return_status
	         ,x_msg_count        => x_msg_count
	         ,x_msg_data         => x_msg_data
	        );

	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	          l_msg_index := 1;
	          l_msg_count := x_msg_count;
	          WHILE l_msg_count > 0 LOOP
	             x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_CTR_PROPERTY_TEMPLATE');
	             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	             l_msg_index := l_msg_index + 1;
	             l_msg_count := l_msg_count - 1;
	          END LOOP;
	          RAISE FND_API.G_EXC_ERROR;
	       END IF;
         END IF;
      END LOOP;
    END IF;

   IF p_counter_template_rec.counter_type = 'FORMULA' AND
      p_counter_template_rec.derive_function IS NULL THEN

      csi_ctr_gen_utility_pvt.put_line(' Inside formula validation ');
      csi_ctr_gen_utility_pvt.put_line(' tbl count = '||to_char(p_counter_relationships_tbl.count));
      IF nvl(p_counter_relationships_tbl.count,0) = 0 THEN
        CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_FORMULA_REF');
      END IF;
   END IF;

   IF (p_counter_relationships_tbl.count > 0) THEN
      FOR tab_row IN p_counter_relationships_tbl.FIRST .. p_counter_relationships_tbl.LAST
      LOOP
         IF p_counter_relationships_tbl.EXISTS(tab_row) THEN
            p_counter_relationships_tbl(tab_row).object_counter_id := p_counter_template_rec.counter_id;

	      create_counter_relationship
	        (
	          p_api_version      => p_api_version
	         ,p_commit           => fnd_api.g_false
	         ,p_init_msg_list    => p_init_msg_list
	         ,p_validation_level => p_validation_level
	         ,p_counter_relationships_rec => p_counter_relationships_tbl(tab_row)
	         ,x_return_status    => x_return_status
	         ,x_msg_count        => x_msg_count
	         ,x_msg_data         => x_msg_data
	        );

	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	          l_msg_index := 1;
	          l_msg_count := x_msg_count;
	          WHILE l_msg_count > 0 LOOP
	             x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_COUNTER_RELATIONSHIP');
	             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	             l_msg_index := l_msg_index + 1;
	             l_msg_count := l_msg_count - 1;
	          END LOOP;
	          RAISE FND_API.G_EXC_ERROR;
	       END IF;
         END IF;
      END LOOP;
    END IF;

   IF (p_ctr_derived_filters_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_derived_filters_tbl.FIRST .. p_ctr_derived_filters_tbl.LAST
      LOOP
         IF p_ctr_derived_filters_tbl.EXISTS(tab_row) THEN
            p_ctr_derived_filters_tbl(tab_row).counter_id := p_counter_template_rec.counter_id;
         END IF;
     END LOOP;

	      create_derived_filters
	        (
	          p_api_version      => p_api_version
	         ,p_commit           => fnd_api.g_false
	         ,p_init_msg_list    => p_init_msg_list
	         ,p_validation_level => p_validation_level
                 ,p_ctr_derived_filters_tbl => p_ctr_derived_filters_tbl
	         ,x_return_status    => x_return_status
	         ,x_msg_count        => x_msg_count
	         ,x_msg_data         => x_msg_data
	        );

	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	          l_msg_index := 1;
	          l_msg_count := x_msg_count;
	          WHILE l_msg_count > 0 LOOP
	             x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_DERIVED_FILTERS');
	             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	             l_msg_index := l_msg_index + 1;
	             l_msg_count := l_msg_count - 1;
	          END LOOP;
	          RAISE FND_API.G_EXC_ERROR;
	       END IF;
         -- END IF;
      -- END LOOP;
    END IF;

    -- End of API body
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_counter_template;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_template;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_template;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_counter_template;


--|---------------------------------------------------
--| procedure name: create_ctr_property_template
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------
/*#
 * This procedure is used to create counter property template.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_property_template_rec Counter property template Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Property Template
 */

PROCEDURE create_ctr_property_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_CTR_PROPERTY_TEMPLATE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_ctr_property_template;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_property_template');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_property_template'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_property_template_rec(p_ctr_property_template_rec);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.create_ctr_prop_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_property_template_rec   => p_ctr_property_template_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_ctr_prop_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.create_ctr_prop_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_property_template_rec  => p_ctr_property_template_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_ctr_prop_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.create_ctr_property_template
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_property_template_rec => p_ctr_property_template_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_CTR_PROPERTY_TEMPLATE');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.create_ctr_prop_template_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.create_ctr_prop_template_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_property_template_rec => p_ctr_property_template_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_ctr_prop_template_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_VUHK.create_ctr_prop_template_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.create_ctr_prop_template_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_property_template_rec => p_ctr_property_template_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_ctr_prop_template_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_ctr_property_template;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_template;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_template;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_ctr_property_template;

--|---------------------------------------------------
--| procedure name: create_counter_relationship
--| description :   procedure used to
--|                 create counter relationship
--|---------------------------------------------------
/*#
 * This procedure is used to create counter relationships.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_relationships_rec Counter relationships Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Relationships
 */

PROCEDURE create_counter_relationship
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER_RELATIONSHIP';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_counter_relationship;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter_relationship');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter_relationship'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_relationship_rec(p_counter_relationships_rec);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.create_ctr_relationship_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_relationships_rec   => p_counter_relationships_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_ctr_relationship_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.create_ctr_relationship_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_relationships_rec  => p_counter_relationships_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_ctr_relationship_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.create_counter_relationship
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_counter_relationships_rec => p_counter_relationships_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_COUNTER_RELATIONSHIP');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.create_ctr_relationship_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.create_ctr_relationship_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_counter_relationships_rec  => p_counter_relationships_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_ctr_relationship_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_VUHK.create_ctr_relationship_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.create_ctr_relationship_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
             ,p_counter_relationships_rec  => p_counter_relationships_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_ctr_relationship_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_counter_relationship;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_relationship;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_relationship;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_counter_relationship;


/*#
 * This procedure is used to create derived filters.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_derived_filters_tbl Counter Derived Filters Table structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Derived Filters
 */
PROCEDURE create_derived_filters
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_DERIVED_FILTERS';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_derived_filters;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_derived_filters');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_derived_filters'   ||
					p_api_version         ||'-'||
					p_commit              ||'-'||
					p_init_msg_list       ||'-'||
					p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_derived_filters_tbl(p_ctr_derived_filters_tbl);
   END IF;

   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.create_derived_filters_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_derived_filters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.create_derived_filters_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_derived_filters_tbl  => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_derived_filters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.create_derived_filters
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_derived_filters_tbl => p_ctr_derived_filters_tbl
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_DERIVED_FILTERS');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.create_derived_filters_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.create_derived_filters_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_derived_filters_tbl  => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_derived_filters_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_VUHK.create_derived_filters_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.create_derived_filters_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_derived_filters_tbl  => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_derived_filters_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_derived_filters;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
				 p_data  => x_msg_data
				);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_derived_filters;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
				 p_data  => x_msg_data
				);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_derived_filters;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
		FND_MSG_PUB.Add_Exc_Msg
			(G_PKG_NAME,
             l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_derived_filters;


--|---------------------------------------------------
--| procedure name: update_counter_group
--| description :   procedure used to
--|                 update counter group
--|---------------------------------------------------
/*#
 * This procedure is used to update counter group
 * In this process, it also update/create counter item associations
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_groups_rec  Counter Group Record structure
 * @param p_ctr_item_associations_tbl Counter Item Associations Table structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter Group
 */


PROCEDURE update_counter_group
  (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_groups_rec        IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
    ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_GROUP';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    CURSOR c1(p_counter_group_id NUMBER, p_inventory_item_id NUMBER) IS
    SELECT counter_id
    FROM   csi_ctr_item_associations
    WHERE  nvl(associated_to_group,'N') = 'Y'
    AND    counter_id IS NOT NULL
    AND    group_id = p_counter_group_id
    AND    inventory_item_id = p_inventory_item_id; --Modified for 6112648
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_group;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_group');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_group'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_grp_rec(p_counter_groups_rec);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.update_counter_group_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_groups_rec   => p_counter_groups_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_counter_group_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.update_counter_group_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_groups_rec  => p_counter_groups_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_counter_group_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.update_counter_group
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_counter_groups_rec => p_counter_groups_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_COUNTER_GROUP');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.update_counter_group_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.update_counter_group_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_counter_groups_rec   => p_counter_groups_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_counter_group_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.update_counter_group_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.update_counter_group_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_counter_groups_rec   => p_counter_groups_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_counter_group_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

   -- Call the create_item_associations to create the item associations

   IF (p_ctr_item_associations_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_item_associations_tbl.FIRST .. p_ctr_item_associations_tbl.LAST
      LOOP
         IF p_ctr_item_associations_tbl.EXISTS(tab_row) THEN
            IF ((p_ctr_item_associations_tbl(tab_row).ctr_association_id IS NULL)
               OR
               (p_ctr_item_associations_tbl(tab_row).ctr_association_id = FND_API.G_MISS_NUM))
            THEN
               p_ctr_item_associations_tbl(tab_row).group_id := p_counter_groups_rec.counter_group_id;
               create_item_association
                  ( p_api_version      => p_api_version
                    ,p_commit           => fnd_api.g_false
                    ,p_init_msg_list    => p_init_msg_list
                    ,p_validation_level => p_validation_level
                    ,p_ctr_item_associations_rec => p_ctr_item_associations_tbl(tab_row)
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data
                  );

               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                             (l_msg_index,
                              FND_API.G_FALSE);
                    csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_ITEM_ASSOCIATIONS');
                    csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);                l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               /* Also create the item association for Counters currently
                  attach to the Counter Group */
                  ----Modified for 6112648
               FOR c1_rec in c1(p_counter_groups_rec.counter_group_id, p_ctr_item_associations_tbl(tab_row).inventory_item_id) LOOP
                  p_ctr_item_associations_tbl(tab_row).group_id := p_counter_groups_rec.counter_group_id;
                  p_ctr_item_associations_tbl(tab_row).counter_id := c1_rec.counter_id;
                  create_item_association
                     (p_api_version      => p_api_version
                      ,p_commit           => fnd_api.g_false
                      ,p_init_msg_list    => p_init_msg_list
                      ,p_validation_level => p_validation_level
                      ,p_ctr_item_associations_rec => p_ctr_item_associations_tbl(tab_row)
                      ,x_return_status    => x_return_status
                      ,x_msg_count        => x_msg_count
                      ,x_msg_data         => x_msg_data
                      );

                  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                     l_msg_index := 1;
                     l_msg_count := x_msg_count;
                     WHILE l_msg_count > 0 LOOP
                        x_msg_data := FND_MSG_PUB.GET
                             (l_msg_index,
                              FND_API.G_FALSE);
                        csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_ITEM_ASSOCIATIONS');
                        csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);                l_msg_index := l_msg_index + 1;
                        l_msg_count := l_msg_count - 1;
                     END LOOP;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;
               END LOOP;
               /* End of addition */
            ELSE
               p_ctr_item_associations_tbl(tab_row).group_id := p_counter_groups_rec.counter_group_id;
  	         update_item_association
	           (p_api_version      => p_api_version
 	            ,p_commit           => fnd_api.g_false
	            ,p_init_msg_list    => p_init_msg_list
	            ,p_validation_level => p_validation_level
	            ,p_ctr_item_associations_rec => p_ctr_item_associations_tbl(tab_row)
	            ,x_return_status    => x_return_status
	            ,x_msg_count        => x_msg_count
	            ,x_msg_data         => x_msg_data
	            );

	         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	            l_msg_index := 1;
	            l_msg_count := x_msg_count;
	            WHILE l_msg_count > 0 LOOP
	               x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	               csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.UPDATE_ITEM_ASSOCIATIONS');
	               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	               l_msg_index := l_msg_index + 1;
	               l_msg_count := l_msg_count - 1;
	            END LOOP;
	            RAISE FND_API.G_EXC_ERROR;
	         END IF;
            END IF;
         END IF;
      END LOOP;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_group;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_group;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_group;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_counter_group;


--|---------------------------------------------------
--| procedure name: update_item_association
--| description :   procedure used to
--|                 update item association to
--|                 counter group or counters
--|---------------------------------------------------
/*#
 * This procedure is used to update counter item associations
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_item_associations_rec Counter Item Associations Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Item Association
 */

PROCEDURE update_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_ITEM_ASSOCIATION';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_item_association;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_item_association');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_item_association'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_item_assoc_rec(p_ctr_item_associations_rec);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.update_item_association_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_item_associations_rec   => p_ctr_item_associations_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_item_association_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.update_item_association_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_item_associations_rec  => p_ctr_item_associations_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_item_association_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.update_item_association
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_item_associations_rec => p_ctr_item_associations_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_ITEM_ASSOCIATION');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.update_item_association_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.update_item_association_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_item_associations_rec => p_ctr_item_associations_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_item_association_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling         CSI_COUNTER_TEMPLATE_VUHK.update_item_association_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.update_item_association_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_item_associations_rec => p_ctr_item_associations_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM         CSI_COUNTER_TEMPLATE_VUHK.update_item_association_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_item_association;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_item_association;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_item_association;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_item_association;

--|---------------------------------------------------
--| procedure name: update_counter_template
--| description :   procedure used to
--|                 update counter template
--|---------------------------------------------------
/*#
 * This procedure is used to update counter template.
 * This will also create/update Item Association, Properties
 * derived filters, relationships.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_template_rec Counter Template Record structure
 * @param p_ctr_item_associations_tbl Counter Item Associations Table structure
 * @param p_ctr_property_template_tbl Counter property template Table structure
 * @param p_counter_relationships_tbl Counter relationships Table structure
 * @param p_ctr_derived_filters_tbl Counter Derived Filters Table structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter Template
 */

PROCEDURE update_counter_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_TEMPLATE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_template ;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_template');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_template'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_template_rec(p_counter_template_rec);
   END IF;

   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.update_counter_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_counter_template_rec => p_counter_template_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
               ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
               ,p_counter_relationships_tbl => p_counter_relationships_tbl
               ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_counter_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.update_counter_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
               ,p_counter_template_rec => p_counter_template_rec
               ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
               ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
               ,p_counter_relationships_tbl => p_counter_relationships_tbl
               ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_counter_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.update_counter_template
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_counter_template_rec => p_counter_template_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );



       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_COUNTER_TEMPLATE');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.update_counter_template_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.update_counter_template_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
             ,p_counter_template_rec => p_counter_template_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
             ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
             ,p_counter_relationships_tbl => p_counter_relationships_tbl
             ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_counter_template_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_VUHK.update_counter_template_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.update_counter_template_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
             ,p_counter_template_rec => p_counter_template_rec
             ,p_ctr_item_associations_tbl => p_ctr_item_associations_tbl
             ,p_ctr_property_template_tbl => p_ctr_property_template_tbl
             ,p_counter_relationships_tbl => p_counter_relationships_tbl
             ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_counter_template_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks


   IF (p_ctr_item_associations_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_item_associations_tbl.FIRST .. p_ctr_item_associations_tbl.LAST
      LOOP
         IF p_ctr_item_associations_tbl.EXISTS(tab_row) THEN
            IF ((p_ctr_item_associations_tbl(tab_row).ctr_association_id IS NULL)
               OR
               (p_ctr_item_associations_tbl(tab_row).ctr_association_id = FND_API.G_MISS_NUM))
            THEN
               p_ctr_item_associations_tbl(tab_row).counter_id := p_counter_template_rec.counter_id;
               create_item_association
                 (p_api_version      => p_api_version
                  ,p_commit           => fnd_api.g_false
                  ,p_init_msg_list    => p_init_msg_list
                  ,p_validation_level => p_validation_level
                  ,p_ctr_item_associations_rec => p_ctr_item_associations_tbl(tab_row)
                  ,x_return_status    => x_return_status
                  ,x_msg_count        => x_msg_count
                  ,x_msg_data         => x_msg_data
                  );

               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                               (l_msg_index,
                                FND_API.G_FALSE);
                    csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_ITEM_ASSOCIATIONS');
                    csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            ELSE
               update_item_association
                 (
                 p_api_version      => p_api_version
                 ,p_commit          => fnd_api.g_false
                 ,p_init_msg_list   => p_init_msg_list
                 ,p_validation_level => p_validation_level
                 ,p_ctr_item_associations_rec => p_ctr_item_associations_tbl(tab_row)
                 ,x_return_status    => x_return_status
                 ,x_msg_count        => x_msg_count
                 ,x_msg_data         => x_msg_data
                 );
               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                               (l_msg_index,
                                FND_API.G_FALSE);
                    csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.UPDATE_ITEM_ASSOCIATIONS');
                    csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
         END IF;
      END LOOP;
   END IF;

   IF (p_ctr_property_template_tbl.count > 0) THEN
      FOR tab_row IN p_ctr_property_template_tbl.FIRST .. p_ctr_property_template_tbl.LAST
      LOOP
         IF p_ctr_property_template_tbl.EXISTS(tab_row) THEN
            IF ((p_ctr_property_template_tbl(tab_row).counter_property_id IS NULL)
               OR
               (p_ctr_property_template_tbl(tab_row).counter_property_id = FND_API.G_MISS_NUM))
            THEN
               p_ctr_property_template_tbl(tab_row).counter_id := p_counter_template_rec.counter_id;
	         create_ctr_property_template
 	           (p_api_version      => p_api_version
	            ,p_commit           => fnd_api.g_false
	            ,p_init_msg_list    => p_init_msg_list
	            ,p_validation_level => p_validation_level
	            ,p_ctr_property_template_rec => p_ctr_property_template_tbl(tab_row)
	            ,x_return_status    => x_return_status
	            ,x_msg_count        => x_msg_count
	            ,x_msg_data         => x_msg_data
	           );

	         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	            l_msg_index := 1;
	            l_msg_count := x_msg_count;
	            WHILE l_msg_count > 0 LOOP
	               x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	               csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_CTR_PROPERTY_TEMPLATE');
	               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	               l_msg_index := l_msg_index + 1;
	               l_msg_count := l_msg_count - 1;
	            END LOOP;
	            RAISE FND_API.G_EXC_ERROR;
	         END IF;
            ELSE
	         update_ctr_property_template
 	           (p_api_version      => p_api_version
	            ,p_commit           => fnd_api.g_false
	            ,p_init_msg_list    => p_init_msg_list
	            ,p_validation_level => p_validation_level
	            ,p_ctr_property_template_rec => p_ctr_property_template_tbl(tab_row)
	            ,x_return_status    => x_return_status
	            ,x_msg_count        => x_msg_count
	            ,x_msg_data         => x_msg_data
	           );

	         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	            l_msg_index := 1;
	            l_msg_count := x_msg_count;
	            WHILE l_msg_count > 0 LOOP
	               x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	               csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.UPDATE_CTR_PROPERTY_TEMPLATE');
	               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	               l_msg_index := l_msg_index + 1;
	               l_msg_count := l_msg_count - 1;
	            END LOOP;
	            RAISE FND_API.G_EXC_ERROR;
	         END IF;
            END IF;
         END IF;
      END LOOP;
   END IF;

   IF p_counter_template_rec.counter_type = 'FORMULA' AND
      p_counter_template_rec.derive_function IS NULL THEN

      IF nvl(p_counter_relationships_tbl.count,0) = 0 THEN
        CSI_CTR_GEN_UTILITY_PVT.ExitWithErrMsg('CSI_API_CTR_REQ_FORMULA_REF');
      END IF;
   END IF;

   IF (p_counter_relationships_tbl.count > 0) THEN
      FOR tab_row IN p_counter_relationships_tbl.FIRST .. p_counter_relationships_tbl.LAST
      LOOP
         IF p_counter_relationships_tbl.EXISTS(tab_row) THEN
            IF ((p_counter_relationships_tbl(tab_row).relationship_id IS NULL)
               OR
               (p_counter_relationships_tbl(tab_row).relationship_id = FND_API.G_MISS_NUM))
            THEN
               p_counter_relationships_tbl(tab_row).object_counter_id := p_counter_template_rec.counter_id;
	       create_counter_relationship
	        (
	          p_api_version      => p_api_version
	         ,p_commit           => fnd_api.g_false
	         ,p_init_msg_list    => p_init_msg_list
	         ,p_validation_level => p_validation_level
	         ,p_counter_relationships_rec => p_counter_relationships_tbl(tab_row)
	         ,x_return_status    => x_return_status
	         ,x_msg_count        => x_msg_count
	         ,x_msg_data         => x_msg_data
	        );

	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	          l_msg_index := 1;
	          l_msg_count := x_msg_count;
	          WHILE l_msg_count > 0 LOOP
	             x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.CREATE_COUNTER_RELATIONSHIP');
	             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	             l_msg_index := l_msg_index + 1;
	             l_msg_count := l_msg_count - 1;
	          END LOOP;
        	  RAISE FND_API.G_EXC_ERROR;
	       END IF;

            ELSE
	      update_counter_relationship
	        (
	          p_api_version      => p_api_version
	         ,p_commit           => fnd_api.g_false
	         ,p_init_msg_list    => p_init_msg_list
	         ,p_validation_level => p_validation_level
	         ,p_counter_relationships_rec => p_counter_relationships_tbl(tab_row)
	         ,x_return_status    => x_return_status
	         ,x_msg_count        => x_msg_count
	         ,x_msg_data         => x_msg_data
	        );

	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	          l_msg_index := 1;
	          l_msg_count := x_msg_count;
	          WHILE l_msg_count > 0 LOOP
	             x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
	                              FND_API.G_FALSE);
	             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.UPDATE_COUNTER_RELATIONSHIP');
	             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	             l_msg_index := l_msg_index + 1;
	             l_msg_count := l_msg_count - 1;
	          END LOOP;
        	  RAISE FND_API.G_EXC_ERROR;
	       END IF;
            END IF;
         END IF;
      END LOOP;
    END IF;

   IF (p_ctr_derived_filters_tbl.count > 0) THEN
     FOR tab_row IN p_ctr_derived_filters_tbl.FIRST .. p_ctr_derived_filters_tbl.LAST
     LOOP
        IF p_ctr_derived_filters_tbl.EXISTS(tab_row) THEN
          p_ctr_derived_filters_tbl(tab_row).counter_id := p_counter_template_rec.counter_id;
        END IF;
     END LOOP;

	      update_derived_filters
	        (
	          p_api_version      => p_api_version
	         ,p_commit           => fnd_api.g_false
	         ,p_init_msg_list    => p_init_msg_list
	         ,p_validation_level => p_validation_level
                 ,p_ctr_derived_filters_tbl => p_ctr_derived_filters_tbl
	         ,x_return_status    => x_return_status
	         ,x_msg_count        => x_msg_count
	         ,x_msg_data         => x_msg_data
	        );

	       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	          l_msg_index := 1;
	          l_msg_count := x_msg_count;
	          WHILE l_msg_count > 0 LOOP
	             x_msg_data := FND_MSG_PUB.GET
	                             (l_msg_index,
        	                      FND_API.G_FALSE);
	             csi_ctr_gen_utility_pvt.put_line('Error from CSI_COUNTER_TEMPLATE_PUB.UPDATE_DERIVED_FILTERS');
	             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	             l_msg_index := l_msg_index + 1;
	             l_msg_count := l_msg_count - 1;
	          END LOOP;
	          RAISE FND_API.G_EXC_ERROR;
	       END IF;
       --  END IF;
      -- END LOOP;
    END IF;

    -- End of API body
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_template;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_template;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_template;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_counter_template;


--|---------------------------------------------------
--| procedure name: update_ctr_property_template
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------
/*#
 * This procedure is used to update counter property template.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_property_template_rec Counter property template record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter Property Template
 */

PROCEDURE update_ctr_property_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_CTR_PROPERTY_TEMPLATE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_ctr_property_template;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_property_template');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_property_template'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_property_template_rec(p_ctr_property_template_rec);
   END IF;

   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.update_ctr_prop_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_property_template_rec   => p_ctr_property_template_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_ctr_prop_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.update_ctr_prop_template_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_property_template_rec  => p_ctr_property_template_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_ctr_prop_template_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.update_ctr_property_template
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_property_template_rec => p_ctr_property_template_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_CTR_PROPERTY_TEMPLATE');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_CUHK.update_ctr_prop_template_post ..');
         CSI_COUNTER_TEMPLATE_CUHK.update_ctr_prop_template_post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_property_template_rec   => p_ctr_property_template_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_ctr_prop_template_post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.update_ctr_prop_template_post ..');
        CSI_COUNTER_TEMPLATE_VUHK.update_ctr_prop_template_post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_property_template_rec   => p_ctr_property_template_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_ctr_prop_template_post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_ctr_property_template;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_template;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_template;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_ctr_property_template;

--|---------------------------------------------------
--| procedure name: update_counter_relationship
--| description :   procedure used to
--|                 update counter relationship
--|---------------------------------------------------
/*#
 * This procedure is used to update counter relationship.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_relationships_rec Counter relationships Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter Relationship
 */

PROCEDURE update_counter_relationship
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER_RELATIONSHIP';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_relationship;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_relationship');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter_relationship'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_relationship_rec(p_counter_relationships_rec);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.update_ctr_relationship_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_relationships_rec   => p_counter_relationships_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_ctr_relationship_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.update_ctr_relationship_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_counter_relationships_rec  => p_counter_relationships_rec
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_ctr_relationship_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.update_counter_relationship
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_counter_relationships_rec => p_counter_relationships_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_COUNTER_RELATIONSHIP');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.update_ctr_relationship_post ..');
         CSI_COUNTER_TEMPLATE_CUHK.update_ctr_relationship_post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_counter_relationships_rec => p_counter_relationships_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_ctr_relationship_post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.update_ctr_relationship_post ..');
        CSI_COUNTER_TEMPLATE_VUHK.update_ctr_relationship_post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_counter_relationships_rec => p_counter_relationships_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_ctr_relationship_post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_relationship;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_relationship;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_relationship;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_counter_relationship;

--|---------------------------------------------------
--| procedure name: update_derived_filters
--| description :   procedure used to
--|                 update derived filters
--|---------------------------------------------------
/*#
 * This procedure is used to update derived filters
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_derived_filters_rec Counter Derived Filters Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Derived Filters
 */

PROCEDURE update_derived_filters
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_DERIVED_FILTERS';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_derived_filters;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_derived_filters');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_derived_filters'   ||
					p_api_version         ||'-'||
					p_commit              ||'-'||
					p_init_msg_list       ||'-'||
					p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_derived_filters_tbl(p_ctr_derived_filters_tbl);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.update_derived_filters_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_derived_filters_tbl    => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_derived_filters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.update_derived_filters_pre
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_derived_filters_tbl   => p_ctr_derived_filters_tbl
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_derived_filters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


   csi_counter_template_pvt.update_derived_filters
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_derived_filters_tbl => p_ctr_derived_filters_tbl
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_DERIVED_FILTERS');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_CUHK.update_derived_filters_post ..');
         CSI_COUNTER_TEMPLATE_CUHK.update_derived_filters_post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_derived_filters_tbl  => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_derived_filters_post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_VUHK.update_derived_filters_post ..');
        CSI_COUNTER_TEMPLATE_VUHK.update_derived_filters_post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_derived_filters_tbl  => p_ctr_derived_filters_tbl
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_derived_filters_post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_derived_filters;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_derived_filters;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_derived_filters;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
		FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_derived_filters;

/*#
 * This procedure is used to create estimation method
 * @param p_api_version Current API version
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @param p_ctr_estimation_rec Counter Estimation Record structure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Estimation Method
 */
PROCEDURE create_estimation_method
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      NUMBER
    ,x_return_status                 OUT NOCOPY     VARCHAR2
    ,x_msg_count                     OUT NOCOPY     NUMBER
    ,x_msg_data                      OUT NOCOPY     VARCHAR2
    ,p_ctr_estimation_rec        IN  OUT NOCOPY     CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
) IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_ESTIMATION_METHOD';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_estimation_method;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_derived_filters');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_estimation_method '   ||
					p_api_version         ||'-'||
					p_commit              ||'-'||
					p_init_msg_list       ||'-'||
					p_validation_level );
      csi_ctr_gen_utility_pvt.dm_ctr_estimation_methods_rec(p_ctr_estimation_rec);
   END IF;

   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.create_estimation_method_pre
             (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_estimation_method_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.create_estimation_method_pre
             (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_estimation_method_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.create_estimation_method
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_estimation_rec => p_ctr_estimation_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from csi_counter_template_pvt.create_estimation_method');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_CUHK.create_estimation_method_post ..');
         CSI_COUNTER_TEMPLATE_CUHK.create_estimation_method_post
           (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.create_estimation_method_post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.create_estimation_method_post ..');
        CSI_COUNTER_TEMPLATE_VUHK.create_estimation_method_post
	(	p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.create_estimation_method_post ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_estimation_method;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
				 p_data  => x_msg_data
				);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_estimation_method;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
				 p_data  => x_msg_data
				);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_estimation_method;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
		FND_MSG_PUB.Add_Exc_Msg
			(G_PKG_NAME,
             l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );
END create_estimation_method;

/*#
 * This procedure is used to update estimation method
 * @param p_api_version Current API version
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @param p_ctr_estimation_rec Counter Estimation Record structure
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Estimation Method
 */
PROCEDURE Update_Estimation_Method
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      NUMBER
    ,x_return_status                 OUT NOCOPY  VARCHAR2
    ,x_msg_count                     OUT NOCOPY  NUMBER
    ,x_msg_data                      OUT NOCOPY  VARCHAR2
    ,p_ctr_estimation_rec        IN  OUT NOCOPY  CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
) IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_ESTIMATION_METHOD';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_estimation_method;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_estimation_method');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_estimation_method '   ||
					p_api_version         ||'-'||
					p_commit              ||'-'||
					p_init_msg_list       ||'-'||
					p_validation_level );
      csi_ctr_gen_utility_pvt.dm_ctr_estimation_methods_rec(p_ctr_estimation_rec);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.update_estimation_method_pre
             (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_estimation_method_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.update_estimation_method_pre
             (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_estimation_method_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


   csi_counter_template_pvt.update_estimation_method
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_estimation_rec => p_ctr_estimation_rec
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_ESTIMATION_METHOD');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.update_estimation_method_post ..');
         CSI_COUNTER_TEMPLATE_CUHK.update_estimation_method_post
           (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.update_estimation_method_post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.update_estimation_method_post ..');
        CSI_COUNTER_TEMPLATE_VUHK.update_estimation_method_post
           (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,p_validation_level     => p_validation_level
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_ctr_estimation_rec   => p_ctr_estimation_rec
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.update_estimation_method_post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_estimation_method;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_estimation_method;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_estimation_method;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
		FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );
END update_estimation_method;

/*#
 * This procedure is used to prepare Counter template
 * data before instantiating them to become Counter
 * Instance.
 * @param p_api_version Current API version
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_commit API commits if set to fnd_api.g_true
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data  Message Data
 * @param p_source_object_id_template  The Inventory Item Id
 * @param p_source_object_id_instance  The counter Id
 * @param x_ctr_id_template The counter id
 * @param x_ctr_id_instance The new item instance id
 * @param p_organization_id The organization id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Autoinstantiate Counters
 */

PROCEDURE AutoInstantiate_Counters
(
   p_api_version		IN	NUMBER
   ,p_init_msg_list		IN	VARCHAR2
   ,p_commit			IN	VARCHAR2
   ,x_return_status	 	OUT NOCOPY	VARCHAR2
   ,x_msg_count		        OUT NOCOPY	NUMBER
   ,x_msg_data		        OUT NOCOPY	VARCHAR2
   ,p_source_object_id_template  IN	NUMBER
   ,p_source_object_id_instance  IN	NUMBER
   ,x_ctr_id_template	         IN OUT NOCOPY	ctr_template_autoinst_tbl
   ,x_ctr_id_instance	         IN OUT NOCOPY	counter_autoinstantiate_tbl
   ,x_ctr_grp_id_template 	 IN OUT NOCOPY	NUMBER
   ,x_ctr_grp_id_instance 	 IN OUT NOCOPY	NUMBER
   ,p_organization_id            IN      NUMBER
)  IS

   CURSOR ctr_item_assoc(p_source_object_id_template NUMBER) IS
   SELECT cia.counter_id, cia.group_id, cia.associated_to_group,
          ctr.counter_type, cia.primary_failure_flag
   FROM   csi_ctr_item_associations cia, csi_counter_template_b ctr
   WHERE  cia.counter_id = ctr.counter_id
   AND    inventory_item_id = p_source_object_id_template
   AND    nvl(cia.associated_to_group,'N') = 'N'
   AND    nvl (cia.end_date_active, sysdate+1) > sysdate
   ORDER BY counter_type DESC;

   CURSOR ctr_grp_assoc(p_source_object_id_template NUMBER) IS
   SELECT cia.counter_id, cia.group_id,
          cia.associated_to_group, cia.primary_failure_flag
   FROM   csi_ctr_item_associations cia, cs_csi_counter_groups cg
   WHERE  cia.group_id = cg.counter_group_id
   AND    cia.inventory_item_id = p_source_object_id_template
   AND    cia.counter_id IS NULL
   AND    nvl (cia.end_date_active, sysdate+1) > sysdate
   AND    nvl(cia.associated_to_group,'N') = 'Y';

   l_api_name                      CONSTANT VARCHAR2(30)   := 'AUTOINSTANTIATE_COUNTERS';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   -- l_debug_level                   NUMBER;
   l_flag                          VARCHAR2(1)             := 'N';
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;

   l_count                         NUMBER;
   l_return_message                VARCHAR2(100);

   l_COMMS_NL_TRACKABLE_FLAG       VARCHAR2(1);
   l_item			   VARCHAR2(40);
   l_counter_id		      	   NUMBER;
   l_validation_level	      	   NUMBER;
   l_source_object_cd		   VARCHAR2(30);

   l_group_id                      NUMBER;
   l_associated_to_group           NUMBER;
   l_ctr_id_template               NUMBER;
   l_ctr_id_instance               NUMBER;
   l_ctr_template_autoinst_tbl     ctr_template_autoinst_tbl;
   l_ctr_template_autoinst_count   NUMBER := 0;
   l_counter_autoinstantiate_tbl   counter_autoinstantiate_tbl;
   l_counter_autoinst_count NUMBER := 0;
   l_curr_maint_org_id      NUMBER;
   l_eam_item_type          NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  autoinstantiate_counters;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'autoinstantiate_counters');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'autoinstantiate_counters'   ||
					p_api_version         ||'-'||
					p_commit              ||'-'||
					p_init_msg_list       ||'-'||
					l_validation_level );
      -- csi_ctr_gen_utility_pvt.dump_instantiate_ctr_rec(p_);
   END IF;

   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.AutoInstantiate_Counters_pre
	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_source_object_id_template => p_source_object_id_template
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template	    => x_ctr_id_template
               ,x_ctr_id_instance	    => x_ctr_id_instance
               ,x_ctr_grp_id_template       => x_ctr_grp_id_template
               ,x_ctr_grp_id_instance       => x_ctr_grp_id_instance
               ,p_organization_id           => p_organization_id
            );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.AutoInstantiate_Counters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
       CSI_COUNTER_TEMPLATE_VUHK.AutoInstantiate_Counters_pre
   	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_source_object_id_template => p_source_object_id_template
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template	    => x_ctr_id_template
               ,x_ctr_id_instance	    => x_ctr_id_instance
               ,x_ctr_grp_id_template       => x_ctr_grp_id_template
               ,x_ctr_grp_id_instance       => x_ctr_grp_id_instance
               ,p_organization_id           => p_organization_id
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.AutoInstantiate_Counters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- Validate the source_object_id_template and source_object_id_instance.
   BEGIN
      SELECT COMMS_NL_TRACKABLE_FLAG,
	     concatenated_segments
      INTO   l_COMMS_NL_TRACKABLE_FLAG,
	     l_item
      FROM  mtl_system_items_kfv
      WHERE inventory_item_id = p_source_object_id_template
      AND   organization_id = p_organization_id     --cs_std.get_item_valdn_orgzn_id
      AND   (NVL(COMMS_NL_TRACKABLE_FLAG,'N') = 'Y' or NVL(service_item_flag,'N') = 'Y');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         csi_ctr_gen_utility_PVT.ExitWithErrMsg('CSI_API_CTR_INVALID_ITEM','ITEM',l_item);
   END;

   IF l_COMMS_NL_TRACKABLE_FLAG = 'Y' THEN
      l_source_object_cd := 'CP';
   ELSE
      l_source_object_cd := 'CONTRACT_LINE';
   END IF;

   /* Check if it is an EAM item to get the maint_organization_id */
   BEGIN
      SELECT eam_item_type
      INTO   l_eam_item_type
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = p_source_object_id_template
      AND    organization_id = p_organization_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_eam_item_type := 0;
      WHEN TOO_MANY_ROWS THEN
         l_eam_item_type := 1;
   END;

   IF l_eam_item_type = 1 or l_eam_item_type = 3 THEN
      BEGIN
         SELECT maint_organization_id
         INTO   l_curr_maint_org_id
         FROM   mtl_parameters
         WHERE  organization_id = p_organization_id;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   /* End of checking*/
   csi_ctr_gen_utility_pvt.put_line( ' EAM Item Type = '||to_char(l_eam_item_type));
   csi_ctr_gen_utility_pvt.put_line( ' Maint organization id = '||to_char(l_curr_maint_org_id));

   -- For each counter property, counter belonging to the counter group
   -- attched to the source_object_id_template, call Create_Ctr_Prop_Instance,
   -- Create_Counter_Instance and Create_Ctr_Grp_Instance.

   /*
   BEGIN
      SELECT counter_id
      INTO   l_counter_id
      FROM   csi_ctr_item_associations
      WHERE  inventory_item_id = p_source_object_id_template;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 -- This item does not have any counters. Raise a warning message that
	 -- no counters were instantiated but do not error out. Return control
	 -- to the caller.
	 csi_ctr_gen_utility_PVT.ExitWithErrMsg('CSI_API_CTR_ITEM_HAS_NO_CTRS','ITEM',l_item);
   END;
   */

   FOR item_rec in ctr_item_assoc(p_source_object_id_template)
   LOOP
      csi_counter_template_pvt.instantiate_counters
        (p_api_version         => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => fnd_api.g_false
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_counter_id_template  => item_rec.counter_id
         ,p_source_object_code_instance => l_source_object_cd
         ,p_source_object_id_instance   => p_source_object_id_instance
         ,x_ctr_id_template	    => l_ctr_id_template
         ,x_ctr_id_instance	    => l_ctr_id_instance
         ,p_maint_org_id            => l_curr_maint_org_id
         ,p_primary_failure_flag    => item_rec.primary_failure_flag
        );

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           l_msg_index := 1;
           l_msg_count := x_msg_count;

           WHILE l_msg_count > 0 LOOP
              x_msg_data := FND_MSG_PUB.GET
                        (l_msg_index,
                        FND_API.G_FALSE );
              csi_ctr_gen_utility_pvt.put_line( ' Error from Instantiate_Counters');
              csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
           END LOOP;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- if success then pass the counter id template, counter id instance to the table of records for out parameters
        l_ctr_template_autoinst_count := l_ctr_template_autoinst_count + 1;
        l_ctr_template_autoinst_tbl(l_ctr_template_autoinst_count).counter_id := l_ctr_id_template;

        l_counter_autoinst_count := l_counter_autoinst_count + 1;
        l_counter_autoinstantiate_tbl(l_counter_autoinst_count).counter_id := l_ctr_id_instance;

        --instance created successfully, pass the counter group id template and instance
        IF item_rec.associated_to_group = 'Y' then
          x_ctr_grp_id_template := item_rec.group_id;
          x_ctr_grp_id_instance := item_rec.group_id;
        END IF;
   END LOOP;

   FOR grp_rec in ctr_grp_assoc(p_source_object_id_template)
   LOOP
      csi_counter_template_pvt.instantiate_grp_counters
        (p_api_version         => p_api_version
         ,p_init_msg_list      => p_init_msg_list
         ,p_commit             => fnd_api.g_false
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,p_group_id_template  => grp_rec.group_id
         ,p_source_object_code_instance => l_source_object_cd
         ,p_source_object_id_instance   => p_source_object_id_instance
         ,x_ctr_grp_id_instance	    => x_ctr_grp_id_instance
         ,p_maint_org_id            => l_curr_maint_org_id
         ,p_primary_failure_flag    => grp_rec.primary_failure_flag
        );

        x_ctr_grp_id_template := grp_rec.group_id;

        csi_ctr_gen_utility_pvt.put_line('Old Group id template = '||to_char(x_ctr_grp_id_template));
        csi_ctr_gen_utility_pvt.put_line('New Group id template = '||to_char(x_ctr_grp_id_instance));

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           l_msg_index := 1;
           l_msg_count := x_msg_count;

           WHILE l_msg_count > 0 LOOP
              x_msg_data := FND_MSG_PUB.GET
                        (l_msg_index,
                        FND_API.G_FALSE );
              csi_ctr_gen_utility_pvt.put_line( ' Error from Instantiate Group Counters');
              csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
           END LOOP;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        --instance created successfully, pass the counter group id template and instance
   END LOOP;

   -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_CUHK.AutoInstantiate_Counters_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.AutoInstantiate_Counters_Post
   	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_source_object_id_template => p_source_object_id_template
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template	    => l_ctr_template_autoinst_tbl
               ,x_ctr_id_instance	    => l_counter_autoinstantiate_tbl
               ,x_ctr_grp_id_template       => x_ctr_grp_id_template
               ,x_ctr_grp_id_instance       => x_ctr_grp_id_instance
               ,p_organization_id           => p_organization_id
            );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.AutoInstantiate_Counters_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
        RAISE FND_API.G_EXC_ERROR;
   END;
     --
     -- Calling Post Vertical User Hook
   BEGIN

      IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling CSI_COUNTER_TEMPLATE_VUHK.AutoInstantiate_Counters_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.AutoInstantiate_Counters_Post
   	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_source_object_id_template => p_source_object_id_template
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template           => l_ctr_template_autoinst_tbl
               ,x_ctr_id_instance           => l_counter_autoinstantiate_tbl
               ,x_ctr_grp_id_template       => x_ctr_grp_id_template
               ,x_ctr_grp_id_instance       => x_ctr_grp_id_instance
               ,p_organization_id           => p_organization_id
            );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.AutoInstantiate_Counters_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO autoinstantiate_counters;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO autoinstantiate_counters;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO autoinstantiate_counters;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
		FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );
END AutoInstantiate_Counters;

/*#
 * This procedure is used to instantiate counter group and counters
 * @param p_api_version Current API Version
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_commit API commits if set to fnd_api.g_true
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data  Message Data
 * @param p_group_id_template   Group id which has to be attached
 * @param p_source_object_code_instance Source object code, 'CP' or 'CONTRACT_LINE'
 * @param p_source_object_id_instance   Source object id to be attached to the counter
 * @x_ctr_grp_id_instance      The counter group that was created
 * @p_maint_org_id             The maintaince organization id.
 * @p_primary_failure_flag     Primary Faliure Flag
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Instantiate Counter Group
 */

 PROCEDURE Instantiate_Grp_Counters
(
   p_api_version		IN	NUMBER
   ,p_init_msg_list		IN	VARCHAR2
   ,p_commit			IN	VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count		        OUT NOCOPY NUMBER
   ,x_msg_data		        OUT NOCOPY VARCHAR2
   ,p_group_id_template        	IN	NUMBER
   ,p_source_object_code_instance IN    VARCHAR2
   ,p_source_object_id_instance   IN	NUMBER
   ,x_ctr_grp_id_instance	  OUT NOCOPY	NUMBER
   ,p_maint_org_id                IN    NUMBER
   ,p_primary_failure_flag        IN    VARCHAR2
)IS

BEGIN
  --Call the Istantiate_Grp_Counters which takes care of creating and attaching groups.
   CSI_COUNTER_TEMPLATE_PVT.Instantiate_Grp_Counters
   (
   p_api_version   =>p_api_version,
   p_init_msg_list =>p_init_msg_list,
   p_commit        =>p_commit,
   x_return_status =>x_return_status,
   x_msg_count     =>x_msg_count,
   x_msg_data      =>x_msg_data,
   p_group_id_template =>p_group_id_template,
   p_source_object_code_instance => p_source_object_code_instance,
   p_source_object_id_instance => p_source_object_id_instance,
   x_ctr_grp_id_instance => x_ctr_grp_id_instance,
   p_maint_org_id=>p_maint_org_id,
   p_primary_failure_flag=>p_primary_failure_flag
   );


END Instantiate_Grp_Counters;

/*#
 * This procedure is used to Instantiate Counters
 * @param p_api_version Current API version
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_commit API commits if set to fnd_api.g_true
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data  Message Data
 * @param p_counter_id_template  Counter Id
 * @param p_source_object_code_instance A CP or a Service Item
 * @param p_source_object_id_instance An instance id or a service line
 * @param x_ctr_id_template The counter id
 * @param x_ctr_id_instance The new item instance id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Instantiate Counters
 */

PROCEDURE Instantiate_Counters
(
   p_api_version		IN	NUMBER
   ,p_init_msg_list		IN	VARCHAR2
   ,p_commit			IN	VARCHAR2
   ,x_return_status		    OUT NOCOPY	VARCHAR2
   ,x_msg_count		    OUT NOCOPY	NUMBER
   ,x_msg_data			    OUT NOCOPY	VARCHAR2
   ,p_counter_id_template         IN	NUMBER
   ,p_source_object_code_instance IN    VARCHAR2
   ,p_source_object_id_instance   IN	NUMBER
   ,x_ctr_id_template	    OUT NOCOPY	NUMBER
   ,x_ctr_id_instance	    OUT NOCOPY	NUMBER
) IS

   l_api_name                      CONSTANT VARCHAR2(30)   := 'INSTANTIATE_COUNTERS';
   l_api_version                   CONSTANT NUMBER         := 1.0;
   -- l_debug_level                   NUMBER;
   l_flag                          VARCHAR2(1)             := 'N';
   l_msg_data                      VARCHAR2(2000);
   l_msg_index                     NUMBER;
   l_msg_count                     NUMBER;

   l_count                         NUMBER;
   l_return_message                VARCHAR2(100);
   l_validation_level              NUMBER;
   l_item                          NUMBER;
   l_COMMS_NL_TRACKABLE_FLAG       VARCHAR2(1);
   l_ctr_grp_id                    NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  instantiate_counters;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   -- csi_ctr_gen_utility_pvt.check_ib_active;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'autoinstantiate_counters');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'instantiate_counters'   ||
					p_api_version         ||'-'||
					p_commit              ||'-'||
					p_init_msg_list       ||'-'||
					l_validation_level );
     --  csi_ctr_gen_utility_pvt.dump_instantiate_ctr_rec(p_);
   END IF;

  IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.instantiate_counters_pre
   	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_counter_id_template  => p_counter_id_template
               ,p_source_object_code_instance => p_source_object_code_instance
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template	    => x_ctr_id_template
               ,x_ctr_id_instance	    => x_ctr_id_instance
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.instantiate_counters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.instantiate_counters_pre
   	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_counter_id_template  => p_counter_id_template
               ,p_source_object_code_instance => p_source_object_code_instance
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template	    => x_ctr_id_template
               ,x_ctr_id_instance	    => x_ctr_id_instance
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.instantiate_counters_pre API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.instantiate_counters
      (
	p_api_version          => p_api_version
        ,p_init_msg_list        => p_init_msg_list
        ,p_commit               => p_commit
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
        ,p_counter_id_template  => p_counter_id_template
        ,p_source_object_code_instance => p_source_object_code_instance
        ,p_source_object_id_instance => p_source_object_id_instance
        ,x_ctr_id_template	    => x_ctr_id_template
        ,x_ctr_id_instance	    => x_ctr_id_instance
        ,p_maint_org_id          => NULL
        ,p_primary_failure_flag  => NULL
      );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.INSTANTIATE_COUNTERS');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

   -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_CUHK.instantiate_counters_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.instantiate_counters_Post
   	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_counter_id_template  => p_counter_id_template
               ,p_source_object_code_instance => p_source_object_code_instance
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template	    => x_ctr_id_template
               ,x_ctr_id_instance	    => x_ctr_id_instance
            );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.instantiate_counters_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
         RAISE FND_API.G_EXC_ERROR;
   END;

   --
   -- Calling Post Vertical User Hook
   BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.instantiate_counters_Post ..');
         CSI_COUNTER_TEMPLATE_VUHK.instantiate_counters_Post
    	    (
		p_api_version          => p_api_version
               ,p_init_msg_list        => p_init_msg_list
	       ,p_commit               => p_commit
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
               ,p_counter_id_template  => p_counter_id_template
               ,p_source_object_code_instance => p_source_object_code_instance
               ,p_source_object_id_instance => p_source_object_id_instance
               ,x_ctr_id_template	    => x_ctr_id_template
               ,x_ctr_id_instance	    => x_ctr_id_instance
            );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.instantiate_counters_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks
    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO instantiate_counters;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO instantiate_counters;
      FND_MSG_PUB.Count_And_Get
				(p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO instantiate_counters;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
		FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );
END Instantiate_Counters;

--|---------------------------------------------------
--| procedure name: delete_item_association
--| description :   procedure used to
--|                 delete item association to
--|                 counter group or counters
--|---------------------------------------------------
/*#
 * This procedure is used to delete item associations
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_association_id Item Associations Unique ID
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Item Association
 */

PROCEDURE delete_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_associations_id       IN     NUMBER
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'DELETE_ITEM_ASSOCIATION';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;

    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  delete_item_association;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'delete_item_association');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line('delete_item_association'     ||
                                        p_api_version         ||'-'||
                                        p_commit              ||'-'||
                                        p_init_msg_list       ||'-'||
                                        p_validation_level );
   END IF;

   -- Calling Customer Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' ))  then
      CSI_COUNTER_TEMPLATE_CUHK.DELETE_ITEM_ASSOCIATION_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_associations_id   => p_ctr_associations_id
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.DELETE_ITEM_ASSOCIATION_PRE API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Calling Vertical Pre-processing Hook
   IF ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' ))  then
      CSI_COUNTER_TEMPLATE_VUHK.DELETE_ITEM_ASSOCIATION_PRE
             (
		p_api_version          => p_api_version
	       ,p_commit               => p_commit
	       ,p_init_msg_list        => p_init_msg_list
	       ,p_validation_level     => p_validation_level
	       ,p_ctr_associations_id  => p_ctr_associations_id
	       ,x_return_status        => x_return_status
	       ,x_msg_count            => x_msg_count
	       ,x_msg_data             => x_msg_data
            );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
            x_msg_data := FND_MSG_PUB.GET
            (  l_msg_index,
               FND_API.G_FALSE
            );
            csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.DELETE_ITEM_ASSOCIATION_PRE API ');
            csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
            l_msg_index := l_msg_index + 1;
            l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   csi_counter_template_pvt.delete_item_association
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_ctr_associations_id => p_ctr_associations_id
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line(' Error from CSI_COUNTER_TEMPLATE_PVT.DELETE_ITEM_ASSOCIATION');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

  -- Calling Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
         csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_CUHK.DELETE_ITEM_ASSOCIATION_Post ..');
         CSI_COUNTER_TEMPLATE_CUHK.DELETE_ITEM_ASSOCIATION_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_associations_id      => p_ctr_associations_id
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
        --
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_CUHK.DELETE_ITEM_ASSOCIATION_Post API ');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
          END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
        --
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
     --
     -- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
        csi_ctr_gen_utility_pvt.put_line('Calling  CSI_COUNTER_TEMPLATE_VUHK.DELTE_ITEM_ASSOCIATION_Post ..');
        CSI_COUNTER_TEMPLATE_VUHK.DELETE_ITEM_ASSOCIATION_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_ctr_associations_id      => p_ctr_associations_id
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );
         --
         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_msg_index := 1;
            l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
               x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
               csi_ctr_gen_utility_pvt.put_line('ERROR FROM CSI_COUNTER_TEMPLATE_VUHK.DELETE_ITEM_ASSOCIATION_Post API ');
               csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
               l_msg_index := l_msg_index + 1;
               l_msg_count := l_msg_count - 1;
            END LOOP;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
         --
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_ctr_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO delete_item_association;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO delete_item_association;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO delete_item_association;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END delete_item_association;

END CSI_COUNTER_TEMPLATE_PUB;

/
