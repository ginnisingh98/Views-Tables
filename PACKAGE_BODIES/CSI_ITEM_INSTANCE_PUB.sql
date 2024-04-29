--------------------------------------------------------
--  DDL for Package Body CSI_ITEM_INSTANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ITEM_INSTANCE_PUB" AS
/* $Header: csipiib.pls 120.18.12010000.8 2009/12/08 02:22:08 hyonlee ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_ITEM_INSTANCE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipiib.pls';

/*----------------------------------------------------*/
/* procedure name: create_item_instance               */
/* description :   procedure used to                  */
/*                 create item instances              */
/*----------------------------------------------------*/

PROCEDURE create_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_rec          IN OUT NOCOPY csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_ITEM_INSTANCE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_transaction_type              VARCHAR2(10);
    l_old_oks_cp_rec                oks_ibint_pub.cp_rec_type;
    l_new_oks_cp_rec                oks_ibint_pub.cp_rec_type;
    l_contracts_status              VARCHAR2(3);
    l_account_id                    NUMBER;
    l_internal_party_id             NUMBER;
    l_party_id                      NUMBER;
    l_version_label                 VARCHAR2(30);
    l_version_label_rec             csi_datastructures_pub.version_label_rec;
    l_item_attribute_tbl            csi_item_instance_pvt.item_attribute_tbl;
    l_location_tbl                  csi_item_instance_pvt.location_tbl;
    l_generic_id_tbl                csi_item_instance_pvt.generic_id_tbl;
    l_lookup_tbl                    csi_item_instance_pvt.lookup_tbl;
    l_ins_count_rec                 csi_item_instance_pvt.ins_count_rec;
    l_asset_lookup_tbl              csi_asset_pvt.lookup_tbl;
    l_asset_count_rec               csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl                  csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl                 csi_asset_pvt.asset_loc_tbl;
    l_party                         NUMBER;
    l_contact                       NUMBER;
    l_account                       NUMBER;
    l_party_tbl                     csi_datastructures_pub.party_tbl;
    lc_party_tbl                    csi_datastructures_pub.party_tbl;
    l_temp_party_tbl                csi_datastructures_pub.party_tbl;
    l_account_tbl                   csi_datastructures_pub.party_account_tbl;
    l_temp_account_tbl              csi_datastructures_pub.party_account_tbl;
    l_count                         NUMBER;
    l_t_party_tbl                   csi_datastructures_pub.party_tbl;
    -- following were added for att enhancements.
    l_component_ins_type            VARCHAR2(1):=NULL ;
    l_config_hdr_id                 NUMBER;
    l_config_rev_nbr                NUMBER;
    l_config_key                    csi_utility_grp.config_instance_key;
    l_config_valid_status           VARCHAR2(10);
    l_return_message                VARCHAR2(100);
    -- Begin Add Code for Siebel Genesis Project
    l_raise_bes_event               VARCHAR2(1) := nvl(fnd_profile.value('CSI_RAISE_BES_CUST_OWNED_INSTANCES'),'N');
    l_link_to_line_id               NUMBER;
    l_item_type_code                VARCHAR2(30);
	l_create_event_called           VARCHAR2(1) := 'N'; --Added for bug 7156553, base bug 6996605
    -- End Add Code for Siebel Genesis Project
    -- end addition
    CURSOR instance_csr (p_ins_id IN NUMBER) IS
      SELECT  *
      FROM    csi_item_instances
      WHERE   instance_id = p_ins_id;
    l_instance_csr                  instance_csr%ROWTYPE;


    CURSOR config_ins_key (p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) is
      SELECT instance_hdr_id
            ,config_item_id
            ,has_failures
      FROM   cz_config_details_v d
            ,cz_config_hdrs_v h
      WHERE d.instance_hdr_id = h.config_hdr_id
      AND   d.instance_rev_nbr = h.config_rev_nbr
      AND   d.component_instance_type = 'I'
      AND   d.config_hdr_id = p_config_hdr_id
      AND   d.config_rev_nbr = p_config_rev_nbr;

    CURSOR instance_key (p_config_inst_hdr_id NUMBER, p_config_inst_item_id NUMBER)is
      SELECT instance_id
            ,object_version_number
            ,config_valid_status
      FROM   csi_item_instances
      WHERE  config_inst_hdr_id=p_config_inst_hdr_id
      AND    config_inst_item_id=p_config_inst_item_id;

    CURSOR new_config_ins_key (p_config_ins_hdr_id NUMBER, p_config_ins_rev_nbr NUMBER) is
      SELECT has_failures
            ,config_status
      FROM   cz_config_details_v d
            ,cz_config_hdrs h
      WHERE d.instance_hdr_id = p_config_ins_hdr_id
      AND   d.instance_rev_nbr = p_config_ins_rev_nbr
     -- AND   d.component_instance_type = 'I'
      AND   d.config_hdr_id = h.config_hdr_id
      AND   d.config_rev_nbr = h.config_rev_nbr;

    CURSOR new_instance_key (p_config_inst_hdr_id NUMBER, p_config_inst_item_id NUMBER)is
      SELECT instance_id
            ,object_version_number
            ,config_valid_status
      FROM   csi_item_instances
      WHERE  config_inst_hdr_id=p_config_inst_hdr_id
      AND    config_inst_item_id=p_config_inst_item_id;

      l_config_instance_rec           csi_datastructures_pub.instance_rec ;
      l_config_temp_rec               csi_datastructures_pub.instance_rec ;
      l_batch_hdr_id                  NUMBER;
      l_batch_rev_nbr                 NUMBER;
      l_instance_id_lst               csi_datastructures_pub.id_tbl;
      l_config_ins_rec                csi_datastructures_pub.instance_rec;
      l_config_tmp_rec                csi_datastructures_pub.instance_rec;
      --
      px_oks_txn_inst_tbl             OKS_IBINT_PUB.TXN_INSTANCE_TBL;
      px_child_inst_tbl               csi_item_instance_grp.child_inst_tbl;
      l_batch_id                      NUMBER;
      l_batch_type                    VARCHAR2(50);
BEGIN

     -- Standard Start of API savepoint
     SAVEPOINT  create_item_instance;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;

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
     l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

     -- If debug_level = 1 then dump the procedure name
     IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'create_item_instance');
     END IF;

     -- If the debug level = 2 then dump all the parameters values.
     IF (l_debug_level > 1) THEN

            csi_gen_utility_pvt.put_line( 'create_item_instance'     ||
                                          p_api_version         ||'-'||
                                          p_commit              ||'-'||
                                          p_init_msg_list       ||'-'||
                                          p_validation_level );
               csi_gen_utility_pvt.dump_instance_rec(p_instance_rec);
               csi_gen_utility_pvt.dump_party_tbl(p_party_tbl);
               csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
               csi_gen_utility_pvt.dump_organization_unit_tbl(p_org_assignments_tbl);
               csi_gen_utility_pvt.dump_pricing_attribs_tbl(p_pricing_attrib_tbl);
               csi_gen_utility_pvt.dump_party_account_tbl(p_account_tbl);
               csi_gen_utility_pvt.dump_ext_attrib_values_tbl(p_ext_attrib_values_tbl);
     END IF;
   /***** srramakr commented for bug # 3304439
     -- Check for the profile option and enable trace
             l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
     -- End enable trace
   ****/
    -- Start API body
    --
    -- Calling Pre Customer User Hook
  BEGIN

    IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C' ) THEN
       csi_gen_utility_pvt.put_line('Calling CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Pre ..');
	  CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Pre
		(
		p_api_version              => 1.0
	    ,p_commit                   => fnd_api.g_false
	    ,p_init_msg_list            => fnd_api.g_false
	    ,p_validation_level         => fnd_api.g_valid_level_full
	    ,p_instance_rec             => p_instance_rec
	    ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
	    ,p_party_tbl                => p_party_tbl
	    ,p_account_tbl              => p_account_tbl
	    ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
	    ,p_org_assignments_tbl      => p_org_assignments_tbl
	    ,p_asset_assignment_tbl     => p_asset_assignment_tbl
	    ,p_txn_rec                  => p_txn_rec
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
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Pre API ');
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
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Pre Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
    --
    -- Calling Pre Vertical User Hook
  BEGIN

    IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'B', 'V' )  THEN
       csi_gen_utility_pvt.put_line('Calling CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Pre ..');
	  CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Pre
		(
		p_api_version              => 1.0
	    ,p_commit                   => fnd_api.g_false
	    ,p_init_msg_list            => fnd_api.g_false
	    ,p_validation_level         => fnd_api.g_valid_level_full
	    ,p_instance_rec             => p_instance_rec
	    ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
	    ,p_party_tbl                => p_party_tbl
	    ,p_account_tbl              => p_account_tbl
	    ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
	    ,p_org_assignments_tbl      => p_org_assignments_tbl
	    ,p_asset_assignment_tbl     => p_asset_assignment_tbl
	    ,p_txn_rec                  => p_txn_rec
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
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Pre API ');
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
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Pre Vertical');
       RAISE FND_API.G_EXC_ERROR;
  END;

    -- End of PRE User Hooks
    --
    -- Create an item instance after validating all the instance attributes.
    -- API also validates that exactly one owner is being created for the
    -- item instance
    -- The following code has been added to assign call_contracts
    -- false so that contracts call can be made only once.
    IF (p_account_tbl.count > 0) THEN
      FOR tab_row IN p_account_tbl.FIRST .. p_account_tbl.LAST
         LOOP
            IF p_account_tbl.EXISTS(tab_row) THEN
               p_account_tbl(tab_row).call_contracts := fnd_api.g_false;
               p_account_tbl(tab_row).vld_organization_id := p_instance_rec.vld_organization_id;
            END IF;
         END LOOP;
    END IF;


     csi_item_instance_pvt.create_item_instance
       (
        p_api_version        => p_api_version
       ,p_commit             => fnd_api.g_false
       ,p_init_msg_list      => p_init_msg_list
       ,p_validation_level   => p_validation_level
       ,p_instance_rec       => p_instance_rec
       ,p_txn_rec            => p_txn_rec
       ,p_party_tbl          => p_party_tbl
       ,p_asset_tbl          => p_asset_assignment_tbl
       ,x_return_status      => x_return_status
       ,x_msg_count          => x_msg_count
       ,x_msg_data           => x_msg_data
       ,p_item_attribute_tbl => l_item_attribute_tbl
       ,p_location_tbl       => l_location_tbl
       ,p_generic_id_tbl     => l_generic_id_tbl
       ,p_lookup_tbl         => l_lookup_tbl
       ,p_ins_count_rec      => l_ins_count_rec
       );
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from CSI_ITEM_INSTANCE_PVT.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     --
     -- Calling Post Customer User Hook
   BEGIN

     IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
       csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post ..');
        CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_instance_rec             => p_instance_rec
	     ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
	     ,p_party_tbl                => p_party_tbl
	     ,p_account_tbl              => p_account_tbl
	     ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
	     ,p_org_assignments_tbl      => p_org_assignments_tbl
	     ,p_asset_assignment_tbl     => p_asset_assignment_tbl
	     ,p_txn_rec                  => p_txn_rec
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
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;


-- Call the create_party_relationship API to create instance-to-party
-- relationships.

  IF (p_party_tbl.count > 0) THEN
      FOR tab_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
         LOOP
            IF p_party_tbl.EXISTS(tab_row) THEN
               p_party_tbl(tab_row).instance_id := p_instance_rec.instance_id;
               IF ((p_party_tbl(tab_row).active_start_date IS NULL) OR
                   (p_party_tbl(tab_row).active_start_date = FND_API.G_MISS_DATE)) THEN
                    p_party_tbl(tab_row).active_start_date := p_instance_rec.active_start_date;
               END IF;
            END IF;
         END LOOP;
         -- Added by sguthiva for att enhancements
         -- The following code has been written to allow the flexibility
         -- to pass a party and its contacts.
         l_party:=1;
         l_contact:=1;
         l_account:=1;
         -- The following code is written for parties
        FOR tab_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
        LOOP
           IF nvl(p_party_tbl(tab_row).contact_flag,'N') <> 'Y'
           THEN
              l_party_tbl(l_party):=p_party_tbl(tab_row);
              IF p_account_tbl.count > 0
              THEN
                 FOR acct_row IN p_account_tbl.FIRST..p_account_tbl.last
                 LOOP
                    IF p_account_tbl(acct_row).parent_tbl_index =tab_row
                    THEN
                       l_account_tbl(l_account):=p_account_tbl(acct_row);
                       l_account_tbl(l_account).parent_tbl_index:=l_party;
                       l_account:=l_account+1;
                    END IF;
                 END LOOP;
              END IF;

              l_t_party_tbl(l_party).parent_tbl_index:=tab_row;
              l_t_party_tbl(l_party).contact_parent_tbl_index:=l_party;
              l_party:=l_party+1;
           END IF;
        END LOOP;
        -- The following code is written for contacts
        FOR cont_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
        LOOP
           IF p_party_tbl(cont_row).contact_flag='Y'
           AND (p_party_tbl(cont_row).contact_ip_id IS NULL
           OR   p_party_tbl(cont_row).contact_ip_id=fnd_api.g_miss_num
               )
           AND (p_party_tbl(cont_row).contact_parent_tbl_index IS NOT NULL
           AND  p_party_tbl(cont_row).contact_parent_tbl_index <> fnd_api.g_miss_num
               )
           THEN
              lc_party_tbl(l_contact):=p_party_tbl(cont_row);
              FOR k in l_t_party_tbl.first..l_t_party_tbl.last
              LOOP
                 IF l_t_party_tbl(k).parent_tbl_index=lc_party_tbl(l_contact).contact_parent_tbl_index
                 THEN
                    lc_party_tbl(l_contact).contact_parent_tbl_index:=l_t_party_tbl(k).contact_parent_tbl_index;
                 END IF;
              END LOOP;
              l_contact:=l_contact+1;
           END IF;
        END LOOP;

        p_account_tbl:=l_temp_account_tbl;
        p_account_tbl:=l_account_tbl;
        l_count:=l_party_tbl.count;
        p_party_tbl:=l_temp_party_tbl;
        p_party_tbl:=l_party_tbl;

        IF lc_party_tbl.COUNT > 0
        THEN
           FOR cont_row IN lc_party_tbl.FIRST..lc_party_tbl.LAST
           LOOP
              l_count:=l_count+1;
              p_party_tbl(l_count):=lc_party_tbl(cont_row);
           END LOOP;
        END IF;

        csi_party_relationships_pub.create_inst_party_relationship
        (
          p_api_version         => p_api_version
         ,p_commit              => fnd_api.g_false
         ,p_init_msg_list       => p_init_msg_list
         ,p_validation_level    => p_validation_level
         ,p_party_tbl           => p_party_tbl
         ,p_party_account_tbl   => p_account_tbl
         ,p_txn_rec             => p_txn_rec
	 ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
         ,x_return_status       => x_return_status
         ,x_msg_count           => x_msg_count
         ,x_msg_data            => x_msg_data
        );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from CSI_PARTY_RELATIONSHIPS_PUB.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
  END IF;

  -- Call create_organization_unit API to create instance-
  -- to-organization units associations

  IF (p_org_assignments_tbl.count > 0) THEN
      FOR tab_row IN p_org_assignments_tbl.FIRST .. p_org_assignments_tbl.LAST
         LOOP
             IF p_org_assignments_tbl.EXISTS(tab_row) THEN
                p_org_assignments_tbl(tab_row).instance_id := p_instance_rec.instance_id;
             END IF;
          END LOOP;

        csi_organization_unit_pub.create_organization_unit
        (
          p_api_version      => p_api_version
         ,p_commit           => fnd_api.g_false
         ,p_init_msg_list    => p_init_msg_list
         ,p_validation_level => p_validation_level
         ,p_org_unit_tbl     => p_org_assignments_tbl
         ,p_txn_rec          => p_txn_rec
         ,x_return_status    => x_return_status
         ,x_msg_count        => x_msg_count
         ,x_msg_data         => x_msg_data
        );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
          csi_gen_utility_pvt.put_line( ' Error from CSI_ORGANIZATION_UNIT_PUB..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

  END IF;

-- Call create_pricing_attribs to associate any pricing attributes
-- to the item instance

  IF (p_pricing_attrib_tbl.count > 0) THEN
      FOR tab_row IN p_pricing_attrib_tbl.FIRST .. p_pricing_attrib_tbl.LAST
         LOOP
             IF p_pricing_attrib_tbl.EXISTS(tab_row) THEN
                p_pricing_attrib_tbl(tab_row).instance_id := p_instance_rec.instance_id;
             END IF;
         END LOOP;

        csi_pricing_attribs_pub.create_pricing_attribs
        (
          p_api_version         => p_api_version
         ,p_commit              => fnd_api.g_false
         ,p_init_msg_list       => p_init_msg_list
         ,p_validation_level    => p_validation_level
         ,p_pricing_attribs_tbl => p_pricing_attrib_tbl
         ,p_txn_rec             => p_txn_rec
         ,x_return_status       => x_return_status
         ,x_msg_count           => x_msg_count
         ,x_msg_data            => x_msg_data
        );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );

          csi_gen_utility_pvt.put_line( ' Error from CSI_PRICING_ATTRIBS_PUB..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
  END IF;

-- Call create_extended_attribs to associate any extended attributes
-- to the item instance

  IF (p_ext_attrib_values_tbl.count > 0) THEN
      FOR tab_row IN p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST
         LOOP
            IF p_ext_attrib_values_tbl.EXISTS(tab_row) THEN
               p_ext_attrib_values_tbl(tab_row).instance_id := p_instance_rec.instance_id;
            END IF;
         END LOOP;

       create_extended_attrib_values
        (
          p_api_version         => p_api_version
         ,p_commit              => fnd_api.g_false
         ,p_init_msg_list       => p_init_msg_list
         ,p_validation_level    => p_validation_level
         ,p_ext_attrib_tbl      => p_ext_attrib_values_tbl
         ,p_txn_rec             => p_txn_rec
         ,x_return_status       => x_return_status
         ,x_msg_count           => x_msg_count
         ,x_msg_data            => x_msg_data
        );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );

          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
  END IF;

-- Call create_asset_assignments to associate any assets associated
-- to the item instance

  IF (p_asset_assignment_tbl.count > 0) THEN
     FOR tab_row IN p_asset_assignment_tbl.FIRST .. p_asset_assignment_tbl.LAST
     LOOP
       IF p_asset_assignment_tbl.EXISTS(tab_row) THEN
          p_asset_assignment_tbl(tab_row).instance_id := p_instance_rec.instance_id;
         csi_asset_pvt.create_instance_asset
         (
           p_api_version         => p_api_version
          ,p_commit              => fnd_api.g_false
          ,p_init_msg_list       => p_init_msg_list
          ,p_instance_asset_rec  => p_asset_assignment_tbl(tab_row)
          ,p_txn_rec             => p_txn_rec
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          ,p_lookup_tbl          => l_asset_lookup_tbl
          ,p_asset_count_rec     => l_asset_count_rec
          ,p_asset_id_tbl        => l_asset_id_tbl
          ,p_asset_loc_tbl       => l_asset_loc_tbl
          );

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
            WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
                  csi_gen_utility_pvt.put_line( ' Error from CSI_ASSET_PVT..');
                  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;
   END LOOP;
  END IF;

-- Added by rtalluri for Bug 2256588 on 03/26/02

-- If version label is null, then we need read the the default value from the profile option

   IF ((p_instance_rec.version_label IS NULL) OR
       (p_instance_rec.version_label = FND_API.G_MISS_CHAR)) THEN
        l_version_label := FND_PROFILE.VALUE('CSI_DEFAULT_VERSION_LABEL');
           IF  l_version_label IS NULL THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_VERSION_LABEL');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
           ELSE
               p_instance_rec.version_label := l_version_label;
           END IF;
   END IF;

--Calling the Create Version Label API to associate a version label for an instance created

        l_version_label_rec.instance_id           := p_instance_rec.instance_id;
        l_version_label_rec.version_label         := p_instance_rec.version_label;
        l_version_label_rec.date_time_stamp       := SYSDATE;
        l_version_label_rec.active_start_date     := p_instance_rec.active_start_date;


        csi_item_instance_pvt.create_version_label
          (
           p_api_version         => p_api_version
          ,p_commit              => fnd_api.g_false
          ,p_init_msg_list       => p_init_msg_list
          ,p_validation_level    => p_validation_level
          ,p_version_label_rec   => l_version_label_rec
          ,p_txn_rec             => p_txn_rec
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
           );

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              csi_gen_utility_pvt.put_line( ' Error from CSI_ITEM_INSTANCE_PVT.CREATE_VERSION_LABEL..');
              csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              FND_MESSAGE.SET_NAME('CSI','CSI_FAILED_TO_CREATE_VERSION');
              FND_MESSAGE.SET_TOKEN('API_ERROR', 'CREATE_VERSION_LABEL');
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

   -- End of addition by rtalluri for Bug 2256588 on 03/26/02

   -- Here we call update_version_time to update date_time_stamp of
   -- version labels created with this transaction_id to sysdate.
   -- Commented the following code, which is causing the prformance
   -- issue. -- bug 3558082 (reported in 11.5.8)
   -- Calling Contracts
   -- Added on 02-OCT-01
   -- Added by sk for fixing bug 2245976
   IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
      csi_gen_utility_pvt.populate_install_param_rec;
   END IF;
   --
   l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
   --
   BEGIN
      SELECT cip.party_id
      INTO   l_party_id
      FROM   csi_i_parties cip
      WHERE  cip.instance_id = p_instance_rec.instance_id
      AND    cip.relationship_type_code = 'OWNER';
   EXCEPTION
     WHEN OTHERS THEN
      l_party_id := NULL;
   END;

   IF l_party_id IS NOT NULL AND
      l_internal_party_id IS NOT NULL AND
      l_party_id <> l_internal_party_id
   THEN
   -- End addition by sk for fixing bug 2245976
      l_transaction_type:= 'NEW';

      -- Added for DEBUG purposes for bug 9028424
      IF p_instance_rec.call_contracts = fnd_api.g_false THEN
        csi_gen_utility_pvt.put_line('call_contracts(1): '||p_instance_rec.call_contracts);
      ELSIF p_instance_rec.call_contracts = 'N' THEN
        csi_gen_utility_pvt.put_line('call_contracts(2): '||p_instance_rec.call_contracts);
      ELSE
        csi_gen_utility_pvt.put_line('call_contracts(3): '||p_instance_rec.call_contracts);
      END IF;
      -- End DEBUG section

      IF (p_instance_rec.call_contracts <> fnd_api.g_false AND p_instance_rec.call_contracts <> 'N') --added by radha on 04/04/02 --added by HYONLEE on 10/30/09
      THEN
                   csi_item_instance_pvt.Call_to_Contracts(
                              p_transaction_type   =>   l_transaction_type
                             ,p_instance_id        =>   p_instance_rec.instance_id
                             ,p_new_instance_id    =>   NULL
                             ,p_vld_org_id         =>   p_instance_rec.vld_organization_id
                             ,p_quantity           =>   NULL
                             ,p_party_account_id1  =>   NULL
                             ,p_party_account_id2  =>   NULL
                             ,p_transaction_date   =>   p_txn_rec.transaction_date -- Refer 3483763
                             ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- Added jpwilson
                             ,p_oks_txn_inst_tbl   =>   px_oks_txn_inst_tbl
                             ,x_return_status      =>   x_return_status
                             ,x_msg_count          =>   x_msg_count
                             ,x_msg_data           =>   x_msg_data
                              );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
           THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE
                               );
                csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
              END LOOP;
                RAISE FND_API.G_EXC_ERROR;
           END IF;
      END IF;
   END IF;

-- Start att enhancements
  IF p_instance_rec.call_batch_validation<>fnd_api.g_false
  THEN
    IF   (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_rev_num IS NOT NULL AND p_instance_rec.config_inst_rev_num <> fnd_api.g_miss_num)
    THEN

          IF NOT csi_item_instance_vld_pvt.is_unique_config_key ( p_config_inst_hdr_id  => p_instance_rec.config_inst_hdr_id
                                                                 ,p_config_inst_item_id => p_instance_rec.config_inst_item_id
                                                                 ,p_instance_id         => p_instance_rec.instance_id
                                                                 ,p_validation_mode     => 'CREATE'
                                                                 )
          THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_KEY_EXISTS');
           FND_MSG_PUB.Add;
           RAISE fnd_api.g_exc_error;
          END IF;

          BEGIN
              SELECT component_instance_type
                    ,config_hdr_id
                    ,config_rev_nbr
              INTO   l_component_ins_type
                    ,l_config_hdr_id
                    ,l_config_rev_nbr
              FROM   cz_config_items_v
              WHERE  instance_hdr_id = p_instance_rec.config_inst_hdr_id
              AND    instance_rev_nbr = p_instance_rec.config_inst_rev_num
              AND    config_item_id = p_instance_rec.config_inst_item_id;
          EXCEPTION
              WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_NOT_IN_CZ');
               FND_MESSAGE.SET_TOKEN('INSTANCE_HDR_ID',p_instance_rec.config_inst_hdr_id);
               FND_MESSAGE.SET_TOKEN('INSTANCE_REV_NBR',p_instance_rec.config_inst_rev_num);
               FND_MESSAGE.SET_TOKEN('CONFIG_ITEM_ID',p_instance_rec.config_inst_item_id);
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
          END;

          IF l_component_ins_type='I'
          THEN
            Csi_item_instance_vld_pvt.Call_batch_validate
              ( p_instance_rec    => p_instance_rec
               ,p_config_hdr_id   => l_config_hdr_id
               ,p_config_rev_nbr  => l_config_rev_nbr
               ,x_config_hdr_id   => l_batch_hdr_id
               ,x_config_rev_nbr  => l_batch_rev_nbr
               ,x_return_status   => x_return_status);

            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_ERROR');
               FND_MSG_PUB.Add;
               csi_gen_utility_pvt.put_line('Call to batch validation has errored ');
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
     ELSIF (  (p_instance_rec.config_inst_hdr_id IS NULL OR p_instance_rec.config_inst_hdr_id = fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num))
          OR (  (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NULL OR p_instance_rec.config_inst_item_id = fnd_api.g_miss_num))
          OR (  (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_rev_num IS NULL OR p_instance_rec.config_inst_rev_num = fnd_api.g_miss_num))
    THEN
		       FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_CONFIG_COMB');
		       FND_MSG_PUB.Add;
		       RAISE fnd_api.g_exc_error;
    END IF;
  END IF;
  -- End att enhancements
  -- Adding new changes for bug 3799694
    IF   (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_rev_num IS NOT NULL AND p_instance_rec.config_inst_rev_num <> fnd_api.g_miss_num)
    THEN
             FOR l_config_ins_key IN new_config_ins_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_rev_num)
              LOOP

                IF l_config_ins_key.has_failures ='1'
                 OR nvl(l_config_ins_key.config_status,'0') <> '2'
                THEN
                   FOR l_instance_key IN new_instance_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_item_id)
                   LOOP

                         l_config_instance_rec:=l_config_temp_rec;
                      IF (l_instance_key.instance_id IS NOT NULL AND
                          l_instance_key.instance_id <> fnd_api.g_miss_num) AND
                         ( l_instance_key.config_valid_status IS NULL OR
                          (l_instance_key.config_valid_status IS NOT NULL AND
                           l_instance_key.config_valid_status <> '1'))
                      THEN
                         l_config_instance_rec.instance_id:=l_instance_key.instance_id;
                         l_config_instance_rec.object_version_number:=l_instance_key.object_version_number;
                         l_config_instance_rec.config_valid_status:='1'; --INVALID
                         csi_item_instance_pvt.update_item_instance
                          (
                            p_api_version        => p_api_version
                           ,p_commit             => fnd_api.g_false
                           ,p_init_msg_list      => p_init_msg_list
                           ,p_validation_level   => p_validation_level
                           ,p_instance_rec       => l_config_instance_rec
                           ,p_txn_rec            => p_txn_rec
                           ,x_instance_id_lst    => l_instance_id_lst
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                           ,p_item_attribute_tbl => l_item_attribute_tbl
                           ,p_location_tbl       => l_location_tbl
                           ,p_generic_id_tbl     => l_generic_id_tbl
                           ,p_lookup_tbl         => l_lookup_tbl
                           ,p_ins_count_rec      => l_ins_count_rec
                           ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
                           ,p_child_inst_tbl     => px_child_inst_tbl
                         );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                        WHILE l_msg_count > 0 LOOP
                             x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                             csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
                             csi_gen_utility_pvt.put_line( 'while updating config status');
                             csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                              l_msg_index := l_msg_index + 1;
                              l_msg_count := l_msg_count - 1;
                        END LOOP;
                           RAISE FND_API.G_EXC_ERROR;
                      END IF;
                      END IF;
                   END LOOP;
                ELSE
                   FOR l_instance_key IN new_instance_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_item_id)
                   LOOP

                         l_config_instance_rec:=l_config_temp_rec;
                      IF (l_instance_key.instance_id IS NOT NULL AND
                          l_instance_key.instance_id <> fnd_api.g_miss_num) AND
                         ( l_instance_key.config_valid_status IS NULL OR
                          (l_instance_key.config_valid_status IS NOT NULL AND
                           l_instance_key.config_valid_status <> '0'))
                      THEN
                         l_config_instance_rec.instance_id:=l_instance_key.instance_id;
                         l_config_instance_rec.object_version_number:=l_instance_key.object_version_number;
                         l_config_instance_rec.config_valid_status:='0'; --VALID
                         csi_item_instance_pvt.update_item_instance
                          (
                            p_api_version        => p_api_version
                           ,p_commit             => fnd_api.g_false
                           ,p_init_msg_list      => p_init_msg_list
                           ,p_validation_level   => p_validation_level
                           ,p_instance_rec       => l_config_instance_rec
                           ,p_txn_rec            => p_txn_rec
                           ,x_instance_id_lst    => l_instance_id_lst
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                           ,p_item_attribute_tbl => l_item_attribute_tbl
                           ,p_location_tbl       => l_location_tbl
                           ,p_generic_id_tbl     => l_generic_id_tbl
                           ,p_lookup_tbl         => l_lookup_tbl
                           ,p_ins_count_rec      => l_ins_count_rec
                           ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
                           ,p_child_inst_tbl     => px_child_inst_tbl
                         );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                         l_msg_index := 1;
                         l_msg_count := x_msg_count;
                         WHILE l_msg_count > 0 LOOP
                            x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                            csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
                            csi_gen_utility_pvt.put_line( 'while updating config status');
                            csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                            l_msg_index := l_msg_index + 1;
                            l_msg_count := l_msg_count - 1;
                         END LOOP;
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;
                   END IF;
                END LOOP;
             END IF;
          END LOOP;
    END IF;
    --
    IF px_oks_txn_inst_tbl.count > 0 THEN
       csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
       csi_gen_utility_pvt.put_line('Calling OKS Core API...');
       --
       IF p_txn_rec.transaction_type_id = 3 THEN
          l_batch_id := p_txn_rec.source_header_ref_id;
          l_batch_type := p_txn_rec.source_group_ref;
       ELSE
          l_batch_id := NULL;
          l_batch_type := NULL;
       END IF;
       --
       UPDATE CSI_TRANSACTIONS
       set contracts_invoked = 'Y'
       where transaction_id = p_txn_rec.transaction_id;
       --
       OKS_IBINT_PUB.IB_interface
          (
            P_Api_Version           =>  1.0,
            P_init_msg_list         =>  p_init_msg_list,
            P_single_txn_date_flag  =>  'Y',
            P_Batch_type            =>  l_batch_type,
            P_Batch_ID              =>  l_batch_id,
            P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
            x_return_status         =>  x_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data
         );
       --
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	  l_msg_index := 1;
	  l_msg_count := x_msg_count;
	  WHILE l_msg_count > 0 LOOP
	     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE        );
	     csi_gen_utility_pvt.put_line( 'Error from OKS_IBINT_PUB.IB_interface..');
	     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	     l_msg_index := l_msg_index + 1;
	     l_msg_count := l_msg_count - 1;
	  END LOOP;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

-- End addition of changes for bug 3799694
        -- End of API body

    -- Begin Add Code for Siebel Genesis Project - Call the Business Event
    IF l_raise_bes_event = 'Y' THEN
       csi_gen_utility_pvt.put_line('l_internal_party_Id = '||to_char(l_internal_party_id));
       csi_gen_utility_pvt.put_line('l_party_Id = '||to_char(l_party_id));
       csi_gen_utility_pvt.put_line('fnd_api.g_miss_num = '||to_char(fnd_api.g_miss_num));
       IF l_internal_party_id <> l_party_id THEN
          --Added for bug 7156553, base bug 6996605, when completing a sales order for a serial controlled item instance
          --which has been previously shipped out through a sales order then returned through a RMA,
          --the event to raise should be the update event, since a create event has already been raised
          --for the same instance_id
          BEGIN
            SELECT 'Y'
            INTO l_create_event_called
            FROM csi_item_instances_h
            WHERE instance_id = p_instance_rec.instance_id
            AND new_accounting_class_code = 'CUST_PROD'
            AND transaction_id <> p_txn_rec.transaction_id
            AND ROWNUM = 1;
          EXCEPTION
            WHEN OTHERS THEN
             l_create_event_called := 'N';
          END;
          IF (l_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line('l_create_event_called  : '||l_create_event_called);
          END IF;
          IF l_create_event_called = 'N' THEN
             csi_gen_utility_pvt.put_line('Firing the Create Instance Evnet');
             CSI_BUSINESS_EVENT_PVT.CREATE_INSTANCE_EVENT
                (p_api_version          => p_api_version
                 ,p_commit              => fnd_api.g_false
                 ,p_init_msg_list       => p_init_msg_list
                 ,p_validation_level    => p_validation_level
                 ,p_instance_id         => p_instance_rec.instance_id
                 ,p_subject_instance_id => null
                 ,x_return_status       => x_return_status
                 ,x_msg_count           => x_msg_count
                 ,x_msg_data            => x_msg_data
                );

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
                   csi_gen_utility_pvt.put_line('Error from CSI_BUSINESS_EVENT.CREATE_INSTANCE_EVENT');
                   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                   l_msg_index := l_msg_index + 1;
                   l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          ELSE
           csi_gen_utility_pvt.put_line('Firing the Update Instance Event');
           CSI_BUSINESS_EVENT_PVT.UPDATE_INSTANCE_EVENT
              ( p_api_version         => p_api_version
               ,p_commit              => fnd_api.g_false
               ,p_init_msg_list       => p_init_msg_list
               ,p_validation_level    => p_validation_level
               ,p_instance_id         => p_instance_rec.instance_id
               ,p_subject_instance_id => null
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
              );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;

              WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
                 csi_gen_utility_pvt.put_line(' Error from CSI_BUSINESS_EVENT.UPDATE_INSTANCE_EVENT');
                 csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
              END LOOP;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
       END IF;
    END IF;
    -- End Add Code for Siebel Genesis Project - Call the Business Event

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;
   /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_flag = 'Y') THEN
         dbms_session.set_sql_trace(FALSE);
    END IF;
    ****/
        -- End disable trace

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
               (p_encoded => FND_API.G_FALSE,   --Added for bug 7657438
                p_count => x_msg_count ,
                p_data  => x_msg_data
                );


-- Calling Post Vertical User Hook
  BEGIN

     IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'A', 'V' )  THEN
       csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Post ..');
        CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Post
           (
	      p_api_version              => 1.0
	     ,p_commit                   => fnd_api.g_false
	     ,p_init_msg_list            => fnd_api.g_false
	     ,p_validation_level         => fnd_api.g_valid_level_full
	     ,p_instance_rec             => p_instance_rec
	     ,p_ext_attrib_values_tbl    => p_ext_attrib_values_tbl
	     ,p_party_tbl                => p_party_tbl
	     ,p_account_tbl              => p_account_tbl
	     ,p_pricing_attrib_tbl       => p_pricing_attrib_tbl
	     ,p_org_assignments_tbl      => p_org_assignments_tbl
	     ,p_asset_assignment_tbl     => p_asset_assignment_tbl
	     ,p_txn_rec                  => p_txn_rec
	     ,x_return_status            => x_return_status
	     ,x_msg_count                => x_msg_count
	     ,x_msg_data                 => x_msg_data
	  );

	  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
              csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Create_Item_Instance_Post API ');
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
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Create Post Vertical');
       RAISE FND_API.G_EXC_ERROR;
  END;
     -- End of POST User Hooks



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                ROLLBACK TO create_item_instance;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,   --Added for bug 7657438
                        p_count   => x_msg_count,
                        p_data    => x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                ROLLBACK TO create_item_instance;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count => x_msg_count,
                        p_data  => x_msg_data
                );

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                ROLLBACK TO create_item_instance;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME,
             l_api_name
                );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

END create_item_instance;

/*----------------------------------------------------*/
/* Procedure name: update_item_instance               */
/* Description :   procedure used to update an Item   */
/*                 Instance                           */
/*----------------------------------------------------*/

PROCEDURE update_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN OUT NOCOPY csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_instance_id_lst       OUT    NOCOPY csi_datastructures_pub.id_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )

IS
    l_api_name               CONSTANT VARCHAR2(30)     := 'UPDATE_ITEM_INSTANCE';
    l_api_version            CONSTANT NUMBER           := 1.0;
    l_debug_level            NUMBER;
    l_instance_rec           csi_datastructures_pub.instance_rec;
    l_temp_instance_rec      csi_datastructures_pub.instance_rec;
    l_new_instance_rec       csi_datastructures_pub.instance_rec := p_instance_rec;
    l_config_instance_rec    csi_datastructures_pub.instance_rec ;
    l_config_temp_rec        csi_datastructures_pub.instance_rec ;
    l_party_tbl              csi_datastructures_pub.party_tbl;
    l_account_tbl            csi_datastructures_pub.party_account_tbl;
    l_party_row              NUMBER := 1;
    l_acct_row               NUMBER := 1;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_msg_index              NUMBER;
    l_line_count             NUMBER;
    l_flag                   VARCHAR2(1):='N';
    l_transaction_type       VARCHAR2(10) := NULL;
    l_old_oks_cp_rec         oks_ibint_pub.cp_rec_type;
    l_new_oks_cp_rec         oks_ibint_pub.cp_rec_type;
    l_contracts_status       VARCHAR2(3);
    l_account_id             NUMBER;
    l_owner_party_id         NUMBER;
    l_transaction_date       DATE ;
    l_internal_party_id      NUMBER;
    l_party_id               NUMBER;
    l_active_end_date        DATE;
    l_dummy                  VARCHAR2(1);
    l_version_label_rec      csi_datastructures_pub.version_label_rec;
    l_item_attribute_tbl     csi_item_instance_pvt.item_attribute_tbl;
    l_location_tbl           csi_item_instance_pvt.location_tbl;
    l_generic_id_tbl         csi_item_instance_pvt.generic_id_tbl;
    l_lookup_tbl             csi_item_instance_pvt.lookup_tbl;
    l_ins_count_rec          csi_item_instance_pvt.ins_count_rec;
    l_ou_lookup_tbl          csi_organization_unit_pvt.lookup_tbl;
    l_ou_count_rec           csi_organization_unit_pvt.ou_count_rec;
    l_ou_id_tbl              csi_organization_unit_pvt.ou_id_tbl;
    l_ext_id_tbl             csi_item_instance_pvt.ext_id_tbl;
    l_ext_count_rec          csi_item_instance_pvt.ext_count_rec;
    l_ext_attr_tbl           csi_item_instance_pvt.ext_attr_tbl;
    l_ext_cat_tbl            csi_item_instance_pvt.ext_cat_tbl;
    l_asset_lookup_tbl       csi_asset_pvt.lookup_tbl;
    l_asset_count_rec        csi_asset_pvt.asset_count_rec;
    l_asset_id_tbl           csi_asset_pvt.asset_id_tbl;
    l_asset_loc_tbl          csi_asset_pvt.asset_loc_tbl;
    l_updated                BOOLEAN := FALSE;
    l_date                   BOOLEAN := FALSE;
    l_curr_party_id          NUMBER;                           -- Added for 2972082
    l_cascade_party_tbl      csi_datastructures_pub.party_tbl; -- Added for 2972082
    l_cascade_account_tbl    csi_datastructures_pub.party_account_tbl; -- Added for 2972082
    l_found                  BOOLEAN := FALSE;                 -- Added for 2972082
    -- The following were added for att
    l_component_ins_type     VARCHAR2(1):=NULL;
    l_config_hdr_id          NUMBER;
    l_config_rev_nbr         NUMBER;
    l_config_key             csi_utility_grp.config_instance_key;
    l_config_valid_status    VARCHAR2(10);
    l_no_config_keys         BOOLEAN := FALSE;
    l_return_message         VARCHAR2(100);
    l_order_line_id          NUMBER;
    l_party_slot             NUMBER;
    l_tmp_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_bump_date              DATE;
    -- Begin Add Code for Siebel Genesis Project
    l_source_code            VARCHAR2(30);
    l_raise_bes_event        VARCHAR2(1) := nvl(fnd_profile.value('CSI_RAISE_BES_CUST_OWNED_INSTANCES'),'N');
    l_link_to_line_Id        NUMBER;
    l_item_type_code         VARCHAR2(30);
    l_root_asset_id          NUMBER;
    l_subject_id             NUMBER;
    l_object_id              NUMBER;
    l_relationship_type_code VARCHAR2(30);
    l_relationship_exists    VARCHAR2(1);
    l_instance_id	     NUMBER; -- Bug #5912182
	l_create_event_called    VARCHAR2(1) := 'N'; --Added for bug 7156553, base bug 6990065
    -- End Add Code for Siebel Genesis Project
    -- end addition
    CURSOR instance_csr (p_ins_id IN NUMBER) IS
      SELECT  *
      FROM    csi_item_instances
      WHERE   instance_id = p_ins_id;
    l_instance_csr           instance_csr%ROWTYPE;

    CURSOR old_ins_csr (p_ins_id IN NUMBER) IS
      SELECT *
      FROM   csi_item_instances
      WHERE  instance_id=p_ins_id;

    l_old_ins_csr            old_ins_csr%ROWTYPE;
--  Start of defining variables for bug 2172968

    l_create                 NUMBER;
    l_update                 NUMBER;
    l_p_id                   NUMBER;
    l_t_party_tbl            csi_datastructures_pub.party_tbl;
    l_t_account_tbl          csi_datastructures_pub.party_account_tbl;
    l_new_party_tbl          csi_datastructures_pub.party_tbl;
    l_new_account_tbl        csi_datastructures_pub.party_account_tbl;
    lb_party_tbl             csi_datastructures_pub.party_tbl;
    lc_party_tbl             csi_datastructures_pub.party_tbl;
    l_temp_party_tbl         csi_datastructures_pub.party_tbl;
    la_account_tbl           csi_datastructures_pub.party_account_tbl;
    l_temp_acct_tbl          csi_datastructures_pub.party_account_tbl;

--  End of defining variables for bug 2172968

    CURSOR config_ins_key (p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) is
      SELECT instance_hdr_id
            ,config_item_id
            ,has_failures
      FROM   cz_config_details_v d
            ,cz_config_hdrs_v h
      WHERE d.instance_hdr_id = h.config_hdr_id
      AND   d.instance_rev_nbr = h.config_rev_nbr
      AND   d.component_instance_type = 'I'
      AND   d.config_hdr_id = p_config_hdr_id
      AND   d.config_rev_nbr = p_config_rev_nbr;

    CURSOR instance_key (p_config_inst_hdr_id NUMBER, p_config_inst_item_id NUMBER)is
      SELECT instance_id
            ,object_version_number
            ,config_valid_status
      FROM   csi_item_instances
      WHERE  config_inst_hdr_id=p_config_inst_hdr_id
      AND    config_inst_item_id=p_config_inst_item_id;

    CURSOR new_config_ins_key (p_config_ins_hdr_id NUMBER, p_config_ins_rev_nbr NUMBER) is
      SELECT has_failures
            ,config_status
      FROM   cz_config_details_v d
            ,cz_config_hdrs h
      WHERE d.instance_hdr_id = p_config_ins_hdr_id
      AND   d.instance_rev_nbr = p_config_ins_rev_nbr
     -- AND   d.component_instance_type = 'I'
      AND   d.config_hdr_id = h.config_hdr_id
      AND   d.config_rev_nbr = h.config_rev_nbr;

    CURSOR new_instance_key (p_config_inst_hdr_id NUMBER, p_config_inst_item_id NUMBER)is
      SELECT instance_id
            ,object_version_number
            ,config_valid_status
      FROM   csi_item_instances
      WHERE  config_inst_hdr_id=p_config_inst_hdr_id
      AND    config_inst_item_id=p_config_inst_item_id;
      ------------------------------------------added-----------
    CURSOR non_owner_csr (p_ins_pty_id NUMBER) IS
      SELECT ip_account_id
            ,active_end_date
            ,object_version_number
      from   csi_ip_accounts
      where  instance_party_id=p_ins_pty_id
      and    relationship_type_code<>'OWNER';
      l_tem_acct_tbl         csi_datastructures_pub.party_account_tbl;
      l_tem_party_id         NUMBER:=NULL;
      l_temp_var             NUMBER:=1;
      l_bacct_row            NUMBER;
	   l_src_change_owner    VARCHAR2(1);
      ------------------------------------------end addition ---
      l_batch_hdr_id         NUMBER;
      l_batch_rev_nbr        NUMBER;
      l_instance_id_lst      csi_datastructures_pub.id_tbl;
      l_config_ins_rec       csi_datastructures_pub.instance_rec;
      l_config_tmp_rec       csi_datastructures_pub.instance_rec;
      l_lock_status          NUMBER;
      --
      px_oks_txn_inst_tbl             OKS_IBINT_PUB.TXN_INSTANCE_TBL;
      px_child_inst_tbl               csi_item_instance_grp.child_inst_tbl;
      l_batch_type                    VARCHAR2(50);
      l_batch_id                      NUMBER;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       update_item_instance;

        -- srramakr fix for Bug # 2909878
        -- Bug 3804960 commented the following as we are not going to use l_date.
        -- We need to honor the end_date passed to instance_rec
/****        IF p_ext_attrib_values_tbl.count > 0 OR
           p_party_tbl.count > 0 OR
           p_account_tbl.count > 0 OR
           p_pricing_attrib_tbl.count > 0 OR
           p_org_assignments_tbl.count > 0 OR
           p_asset_assignment_tbl.count > 0 THEN
           IF p_instance_rec.active_end_date <= sysdate -- srramakr changed to <=
           THEN
             l_date:=TRUE;
           END IF;
        END IF; ***/
        --
        IF p_instance_rec.active_end_date IS NOT NULL AND
           p_instance_rec.active_end_date <> FND_API.G_MISS_DATE THEN
           p_txn_rec.src_txn_creation_date := p_instance_rec.active_end_date;
        END IF;
        --
        -- End of 3804960
        -- Check for freeze_flag in csi_install_parameters is set to 'Y'
        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                p_api_version,
                                                l_api_name       ,
                                                G_PKG_NAME       )
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
        l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If debug_level = 1 then dump the procedure name
        IF (l_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'update_item_instance');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_debug_level > 1) THEN
                   csi_gen_utility_pvt.put_line( 'update_item_instance'     ||
                                                 p_api_version         ||'-'||
                                                 p_commit              ||'-'||
                                                 p_init_msg_list       ||'-'||
                                                 p_validation_level );
               csi_gen_utility_pvt.dump_instance_rec(p_instance_rec);
               csi_gen_utility_pvt.dump_party_tbl(p_party_tbl);
               csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
               csi_gen_utility_pvt.dump_organization_unit_tbl(p_org_assignments_tbl);
               csi_gen_utility_pvt.dump_pricing_attribs_tbl(p_pricing_attrib_tbl);
               csi_gen_utility_pvt.dump_party_account_tbl(p_account_tbl);
               csi_gen_utility_pvt.dump_ext_attrib_values_tbl(p_ext_attrib_values_tbl);
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
             l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/
        -- Start API body
        IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
           csi_gen_utility_pvt.populate_install_param_rec;
        END IF;
        --
        l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
        --
        IF l_internal_party_id IS NULL THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

   -- Begin Add Code for Siebel Genesis Project
   csi_gen_utility_pvt.put_line('Inside CSI_ITEM_INSTANCE_PUB.Update_Item_Instance');
   csi_gen_utility_pvt.put_line('p_instance_rec = '||to_char(p_instance_rec.instance_id));
   -- End Add Code for Siebel Genesis Project

   --Added for bug 7156553, base bug 6990065, when creating a new customer instance, sometime the procedure
   --create_instance is called to create the instance in inventory first, then
   --an update_instance is called to set the instance as a customer product. This causes only
   --update event to be raised for the instance. The code added is to ensure the create event
   --will get invoked for the instance.
   BEGIN
    SELECT 'Y'
    INTO l_create_event_called
    FROM csi_item_instances_h
    WHERE instance_id = p_instance_rec.instance_id
    AND new_accounting_class_code = 'CUST_PROD'
    AND ROWNUM = 1;
   EXCEPTION
    WHEN OTHERS THEN
      l_create_event_called := 'N';
   END;
   IF (l_debug_level > 1) THEN
    csi_gen_utility_pvt.put_line('l_create_event_called  : '||l_create_event_called);
   END IF;

    --Added for MACD lock functionality
   IF NOT (csi_Item_Instance_Pvt.Anything_To_Update(p_instance_rec   =>  p_instance_rec ))
   THEN
   -- If Anything is getting updated then lock check will be made in pvt.
    IF p_instance_rec.instance_id IS NOT NULL AND
       p_instance_rec.instance_id <> fnd_api.g_miss_num
    THEN
      csi_item_instance_pvt.get_instance_lock_status
      ( p_instance_id  => p_instance_rec.instance_id ,
        p_lock_status  => l_lock_status
      );
       IF (p_txn_rec.transaction_type_id = 401 AND
           l_lock_status = 1) OR
          (l_lock_status = 0)
       THEN
          NULL;
       ELSE
        FND_MESSAGE.SET_NAME('CSI','CSI_INSTANCE_LOCKED');
        FND_MESSAGE.SET_TOKEN('INSTANCE_ID',p_instance_rec.instance_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
   END IF;
    -- End addition for MACD lock functionality
        -- Call Pre Customer User Hook
   BEGIN
        IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C' ) THEN
           csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_CUHK.Update_Item_Instance_Pre ..');
           CSI_ITEM_INSTANCE_CUHK.Update_Item_Instance_Pre
            (
	        p_api_version           =>  1.0
	       ,p_commit                =>  fnd_api.g_false
	       ,p_init_msg_list         =>  fnd_api.g_false
	       ,p_validation_level      =>  fnd_api.g_valid_level_full
	       ,p_instance_rec          =>  p_instance_rec
	       ,p_ext_attrib_values_tbl =>  p_ext_attrib_values_tbl
	       ,p_party_tbl             =>  p_party_tbl
	       ,p_account_tbl           =>  p_account_tbl
	       ,p_pricing_attrib_tbl    =>  p_pricing_attrib_tbl
	       ,p_org_assignments_tbl   =>  p_org_assignments_tbl
	       ,p_asset_assignment_tbl  =>  p_asset_assignment_tbl
	       ,p_txn_rec               =>  p_txn_rec
	       ,x_instance_id_lst       =>  x_instance_id_lst
	       ,x_return_status         =>  x_return_status
	       ,x_msg_count             =>  x_msg_count
	       ,x_msg_data              =>  x_msg_data
            );
           --
           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               l_msg_index := 1;
               l_msg_count := x_msg_count;
               WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
                    csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Update_Item_Instance_Pre API ');
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
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Update Pre Customer');
       RAISE FND_API.G_EXC_ERROR;
   END;
        --
        -- Call Pre Vertical user Hook
   BEGIN
        IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V' ) THEN
           csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_VUHK.Update_Item_Instance_Pre ..');
           CSI_ITEM_INSTANCE_VUHK.Update_Item_Instance_Pre
            (
		   p_api_version           =>  1.0
	       ,p_commit                =>  fnd_api.g_false
	       ,p_init_msg_list         =>  fnd_api.g_false
	       ,p_validation_level      =>  fnd_api.g_valid_level_full
	       ,p_instance_rec          =>  p_instance_rec
	       ,p_ext_attrib_values_tbl =>  p_ext_attrib_values_tbl
	       ,p_party_tbl             =>  p_party_tbl
	       ,p_account_tbl           =>  p_account_tbl
	       ,p_pricing_attrib_tbl    =>  p_pricing_attrib_tbl
	       ,p_org_assignments_tbl   =>  p_org_assignments_tbl
	       ,p_asset_assignment_tbl  =>  p_asset_assignment_tbl
	       ,p_txn_rec               =>  p_txn_rec
	       ,x_instance_id_lst       =>  x_instance_id_lst
	       ,x_return_status         =>  x_return_status
	       ,x_msg_count             =>  x_msg_count
	       ,x_msg_data              =>  x_msg_data
            );
           --
           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               l_msg_index := 1;
               l_msg_count := x_msg_count;
               WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
                    csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Update_Item_Instance_Pre API ');
                    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
               END LOOP;
             RAISE FND_API.G_EXC_ERROR;
	       END IF;
        END IF;
  EXCEPTION
    WHEN OTHERS THEN
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Update Pre Vertical');
       RAISE FND_API.G_EXC_ERROR;
  END;
        -- End of PRE User Hooks
	--
        -- This will fetch old instance data for the purpose of contracts
       BEGIN
        OPEN   old_ins_csr (p_instance_rec.instance_id);
        FETCH  old_ins_csr INTO l_old_ins_csr;
        CLOSE  old_ins_csr;
       EXCEPTION
         WHEN OTHERS THEN
         NULL;
       END;

       BEGIN
          SELECT cip.party_id
          INTO   l_owner_party_id
          FROM   csi_i_parties cip
          WHERE  cip.instance_id = p_instance_rec.instance_id
          AND    cip.relationship_type_code = 'OWNER';
       EXCEPTION
          WHEN OTHERS THEN
          NULL;
       END;

	    BEGIN
 	        SELECT src_change_owner
 	        INTO l_src_change_owner
 	        FROM csi_txn_sub_types
 	        WHERE  sub_type_id = P_txn_rec.txn_sub_type_id
 	        AND    transaction_type_id = P_txn_rec.transaction_type_id;
 	    EXCEPTION
 	        WHEN OTHERS THEN
 	        NULL;
 	    END;

-- Following are the cascade ownership changes for
-- bug 2972082
      IF p_instance_rec.cascade_ownership_flag IS NOT NULL AND
         p_instance_rec.cascade_ownership_flag='Y'
      THEN
      csi_gen_utility_pvt.put_line('Cascade_ownership_flag      :'||p_instance_rec.cascade_ownership_flag);
       IF p_party_tbl.count > 0
       THEN
         FOR l_party_rec IN p_party_tbl.FIRST .. p_party_tbl.LAST
         LOOP
           IF p_party_tbl.EXISTS(l_party_rec)
           THEN
              IF p_party_tbl(l_party_rec).instance_id = p_instance_rec.instance_id AND
                 p_party_tbl(l_party_rec).relationship_type_code = 'OWNER'
              THEN
              -- Assigning cascade_ownership_flag with a value true
                 p_party_tbl(l_party_rec).cascade_ownership_flag:='Y';

                 IF p_party_tbl(l_party_rec).party_id<>l_internal_party_id
                 THEN
                    IF p_account_tbl.count>0
                    THEN
                       FOR l_acct_rec IN p_account_tbl.FIRST .. p_account_tbl.LAST
                       LOOP
                         IF p_account_tbl.EXISTS(l_acct_rec)
                         THEN
                           IF p_account_tbl(l_acct_rec).instance_party_id=
                              p_party_tbl(l_party_rec).instance_party_id AND
                              p_account_tbl(l_acct_rec).relationship_type_code='OWNER'
                           THEN
                              l_found:=TRUE;
                           END IF;
                         END IF;
                       END LOOP;
                    END IF;
                 ELSE
                  l_found:= TRUE;
                 END IF;
              END IF;
           END IF;
         END LOOP;
         IF NOT(l_found)
         THEN
		     IF l_src_change_owner = 'N' THEN
 	            NULL;
 	         ELSE
			    csi_gen_utility_pvt.put_line('Owner party or account information is not passed for the instance');
                csi_gen_utility_pvt.put_line(',which you are trying to cascade the ownership.');
                RAISE FND_API.G_EXC_ERROR;
             END IF;
	     END IF;
       ELSE
         -- Since party information is not passed so I need to build the party and account
         -- information.
         -- In the party record assign cascade_ownership_flag with a value fnd_api.g_true.
         BEGIN
           SELECT instance_party_id,
                  instance_id,
                  party_source_table,
                  party_id,
                  relationship_type_code,
                  contact_flag,
                  object_version_number,
                  'Y'
           INTO   l_cascade_party_tbl(1).instance_party_id,
                  l_cascade_party_tbl(1).instance_id,
                  l_cascade_party_tbl(1).party_source_table,
                  l_cascade_party_tbl(1).party_id,
                  l_cascade_party_tbl(1).relationship_type_code,
                  l_cascade_party_tbl(1).contact_flag,
                  l_cascade_party_tbl(1).object_version_number,
                  l_cascade_party_tbl(1).cascade_ownership_flag
           FROM   csi_i_parties
           WHERE  instance_id=p_instance_rec.instance_id
           AND    relationship_type_code='OWNER'
           AND   (active_end_date IS NULL OR active_end_date>sysdate);

           p_party_tbl:=l_cascade_party_tbl;

         EXCEPTION
           WHEN OTHERS
           THEN
             csi_gen_utility_pvt.put_line('Owner party information not found for the instance');
             csi_gen_utility_pvt.put_line(',which you are trying to cascade the ownership.');
             RAISE FND_API.G_EXC_ERROR;
         END;


         IF l_cascade_party_tbl(1).party_id <> l_internal_party_id
         THEN
         -- Here I need to build account record
          BEGIN
           SELECT ip_account_id,
                  instance_party_id,
                  party_account_id,
                  relationship_type_code,
                  1,
                  object_version_number
           INTO   l_cascade_account_tbl(1).ip_account_id,
                  l_cascade_account_tbl(1).instance_party_id,
                  l_cascade_account_tbl(1).party_account_id,
                  l_cascade_account_tbl(1).relationship_type_code,
                  l_cascade_account_tbl(1).parent_tbl_index,
                  l_cascade_account_tbl(1).object_version_number
           FROM   csi_ip_accounts
           WHERE  instance_party_id=l_cascade_party_tbl(1).instance_party_id
           AND    relationship_type_code='OWNER'
           AND   (active_end_date IS NULL OR active_end_date>sysdate);
               IF p_account_tbl.count>0
               THEN
                p_account_tbl(p_account_tbl.count+1):=l_cascade_account_tbl(1);
               ELSE
                p_account_tbl:=l_cascade_account_tbl;
               END IF;
          EXCEPTION
            WHEN OTHERS THEN
             csi_gen_utility_pvt.put_line('Owner account information not found for the instance');
             csi_gen_utility_pvt.put_line(',which you are trying to cascade the ownership');
             RAISE FND_API.G_EXC_ERROR;
          END;
         END IF; -- End of building account record.
       END IF;   -- End of party building party record.
      END IF;    -- End of cascade ownership check.

-- End of cascade ownership changes for
-- bug 2972082

       --
       --
       -- The following code has been added to assign call_contracts
       -- false so that contracts call can be made only once.
/*     -- Commented by sguthiva for bug 2307804
       IF (p_account_tbl.count > 0) THEN
            FOR tab_row IN p_account_tbl.FIRST .. p_account_tbl.LAST
            LOOP
               IF p_account_tbl.EXISTS(tab_row)
               THEN
                   IF   p_account_tbl(tab_row).instance_party_id = l_owner_party_id
                    AND p_account_tbl(tab_row).instance_party_id IS NOT NULL
                    AND p_account_tbl(tab_row).instance_party_id <> fnd_api.g_miss_num
                    AND l_owner_party_id IS NOT NULL
                   THEN
                       p_account_tbl(tab_row).call_contracts := fnd_api.g_false;
                       p_account_tbl(tab_row).vld_organization_id := p_instance_rec.vld_organization_id;
                   END IF;
               END IF;
            END LOOP;
       END IF;
        -- End fetching old instance data for the purpose of contracts
*/      -- End commentation by sguthiva for bug 2307804
-- IF any of the instance columns are changing then call the update_item_instance private api
   IF (csi_Item_Instance_Pvt.Anything_To_Update(p_instance_rec   =>  p_instance_rec ))
       THEN

       l_new_instance_rec := p_instance_rec;

       IF (p_party_tbl.count > 0) THEN
           FOR tab_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
             LOOP
                IF p_party_tbl.EXISTS(tab_row) THEN
                   IF ((p_party_tbl(tab_row).instance_party_id IS NOT NULL) AND
                       (p_party_tbl(tab_row).instance_party_id <> FND_API.G_MISS_NUM))THEN
                         l_new_instance_rec.accounting_class_code := NULL;
                   END IF;
                END IF;
             END LOOP;
       END IF;

       -- If Ownership is changing from Internal to External then OKS call should be made only at Account update level.
       -- The call should be suppressed at instance level. This is true for child instances also.
       -- Hence instance_rec.call_contracts is set to FLASE which eventually gets passed to child instances where the
       -- check is made.
       --
       l_party_slot := NULL;
       IF l_owner_party_id = l_internal_party_id THEN
	  IF p_party_tbl.count > 0 THEN
	     FOR party_rec in p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
		IF p_party_tbl.EXISTS(party_rec) THEN
		   IF p_party_tbl(party_rec).instance_id = p_instance_rec.instance_id AND
		      p_party_tbl(party_rec).relationship_type_code = 'OWNER' AND
		      p_party_tbl(party_rec).party_id IS NOT NULL AND
		      p_party_tbl(party_rec).party_id <> FND_API.G_MISS_NUM AND
		      p_party_tbl(party_rec).party_id <> l_internal_party_id THEN
		      l_party_slot := party_rec;
              -- Added
              l_new_instance_rec.owner_party_id:=p_party_tbl(party_rec).party_id;
		      exit;
		   END IF;
		END IF;
	     END LOOP;
	     IF l_party_slot IS NOT NULL AND
		p_account_tbl.count > 0 THEN
		FOR acct_rec in p_account_tbl.FIRST .. p_account_tbl.LAST LOOP
		   IF p_account_tbl.EXISTS(acct_rec) THEN
		      IF p_account_tbl(acct_rec).parent_tbl_index = l_party_slot AND
			 p_account_tbl(acct_rec).relationship_type_code = 'OWNER' THEN
			 l_new_instance_rec.call_contracts := FND_API.G_FALSE; -- since p_instance_rec is IN parameter
			 csi_gen_utility_pvt.put_line('Instance Rec Call contracts set to FALSE');
			 exit;
		      END IF;
		   END IF;
		END LOOP;
	     END IF;
	  END IF;
       END IF;
       --
       -- Similarly if the ownership is transferred from external to internal then
       -- make the call to contracts during party update and supress it at instance level.
       -- If this instance has a configuration then for the child instance, contracts call will be supressed
       -- for TRM txn type in Update_Child_Instance_Location by looking at the instance_rec.call_contracts.
       IF l_owner_party_id <> l_internal_party_id AND
          p_party_tbl.count > 0 THEN
          FOR party_rec in p_party_tbl.FIRST .. p_party_tbl.LAST LOOP
             IF p_party_tbl.EXISTS(party_rec) THEN
                IF p_party_tbl(party_rec).instance_id = p_instance_rec.instance_id AND
                   p_party_tbl(party_rec).relationship_type_code = 'OWNER' AND
                   p_party_tbl(party_rec).party_id = l_internal_party_id THEN
                   l_new_instance_rec.call_contracts := FND_API.G_FALSE; -- since p_instance_rec is IN parameter
              -- Added
                   l_new_instance_rec.owner_party_id:=p_party_tbl(party_rec).party_id;
                   csi_gen_utility_pvt.put_line('Instance Rec Call contracts set to FALSE');
                   exit;
                END IF;
             END IF;
          END LOOP;
       END IF;
       --
       IF (p_asset_assignment_tbl.count > 0) THEN
           l_new_instance_rec.accounting_class_code := NULL;
       END IF;
       --
       --
    -- srramakr fix for Bug # 2909878
    IF p_ext_attrib_values_tbl.count > 0 OR
       p_party_tbl.count > 0 OR
       p_account_tbl.count > 0 OR
       p_pricing_attrib_tbl.count > 0 OR
       p_org_assignments_tbl.count > 0 OR
       p_asset_assignment_tbl.count > 0 OR
       -- Added the following code for bug 4350017
       ((p_instance_rec.config_inst_hdr_id IS NOT NULL AND
         p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num) AND
        (p_instance_rec.config_inst_item_id IS NOT NULL AND
         p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num) AND
        (p_instance_rec.config_inst_rev_num IS NOT NULL AND
         p_instance_rec.config_inst_rev_num <> fnd_api.g_miss_num)
       )
       -- End code addition for bug 4350017
    THEN
       IF    l_new_instance_rec.active_end_date IS NOT NULL
        AND  l_new_instance_rec.active_end_date <> fnd_api.g_miss_date
        AND  l_new_instance_rec.active_end_date <= SYSDATE
       THEN
          l_new_instance_rec.active_end_date:=fnd_api.g_miss_date;
          l_new_instance_rec.instance_status_id:=fnd_api.g_miss_num; -- srramakr Fix for Bug # 2766216
          l_updated:=TRUE;
       END IF;
    END IF;
    -- Call the update_item_instance private API to update the instances
    csi_item_instance_pvt.update_item_instance
       (
         p_api_version      => p_api_version
        ,p_commit           => fnd_api.g_false
        ,p_init_msg_list    => p_init_msg_list
        ,p_validation_level => p_validation_level
        ,p_instance_rec     => l_new_instance_rec
        ,p_txn_rec          => p_txn_rec
        ,x_instance_id_lst  => x_instance_id_lst
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
        ,p_item_attribute_tbl => l_item_attribute_tbl
        ,p_location_tbl     => l_location_tbl
        ,p_generic_id_tbl     => l_generic_id_tbl
        ,p_lookup_tbl         => l_lookup_tbl
        ,p_ins_count_rec      => l_ins_count_rec
        ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
        ,p_child_inst_tbl     => px_child_inst_tbl
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
          csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Calling Contracts for Quantity Change
       IF p_instance_rec.quantity IS NOT NULL AND
          p_instance_rec.quantity <> FND_API.G_MISS_NUM AND
          p_instance_rec.quantity <> 0 AND -- Supress 'UPD' call if Qty drops to 0
          l_old_ins_csr.quantity <> p_instance_rec.quantity THEN
	  IF l_owner_party_id IS NOT NULL AND
	     l_owner_party_id <> l_internal_party_id THEN
            IF p_txn_rec.transaction_type_id <> 7   -- Added for bug 3973706
            THEN
	     CSI_Item_Instance_Pvt.Call_to_Contracts
		   ( p_transaction_type    => 'UPD'
		    ,p_instance_id         => p_instance_rec.instance_id
		    ,p_new_instance_id     => NULL
		    ,p_vld_org_id          => p_instance_rec.vld_organization_id
		    ,p_quantity            => l_old_ins_csr.quantity -- Passing the Old qty
		    ,p_party_account_id1   => NULL
		    ,p_party_account_id2   => NULL
                    ,p_transaction_date    => p_txn_rec.transaction_date -- Refer 3483763
                    ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- Added jpwilson
		    ,p_txn_type_id         => p_txn_rec.transaction_type_id
                    ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
		    ,x_return_status       => x_return_status
		    ,x_msg_count           => x_msg_count
		    ,x_msg_data            => x_msg_data
		  );
	       --
	      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			l_msg_index := 1;
			l_msg_count := x_msg_count;
		    WHILE l_msg_count > 0 LOOP
		      x_msg_data := FND_MSG_PUB.GET
				    (  l_msg_index,
				       FND_API.G_FALSE
				     );
		      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			  l_msg_index := l_msg_index + 1;
			  l_msg_count := l_msg_count - 1;
		    END LOOP;
		      RAISE FND_API.G_EXC_ERROR;
	      END IF;
            END IF;  -- Added for bug 3973706

	  END IF;
       END IF;
       --
       -- Caliing Contracts for Install Date Change
       IF ( (p_instance_rec.install_date IS NULL AND
             l_old_ins_csr.install_date IS NOT NULL) OR
            (p_instance_rec.install_date IS NOT NULL AND
             p_instance_rec.install_date <> FND_API.G_MISS_DATE AND
             nvl(l_old_ins_csr.install_date,FND_API.G_MISS_DATE) <> p_instance_rec.install_date) ) THEN
	  IF l_owner_party_id IS NOT NULL AND
	     l_owner_party_id <> l_internal_party_id THEN
	     CSI_Item_Instance_Pvt.Call_to_Contracts
	        ( p_transaction_type    => 'IDC'
	         ,p_instance_id         => p_instance_rec.instance_id
		 ,p_new_instance_id     => NULL
		 ,p_vld_org_id          => p_instance_rec.vld_organization_id
		 ,p_quantity            => p_instance_rec.quantity
		 ,p_party_account_id1   => NULL
		 ,p_party_account_id2   => NULL
                 ,p_transaction_date    => p_txn_rec.transaction_date -- Refer 3483763
                 ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- Added jpwilson
                 ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
		 ,x_return_status       => x_return_status
		 ,x_msg_count           => x_msg_count
		 ,x_msg_data            => x_msg_data
		 );
	      --
              IF x_return_status = 'W' THEN -- Warning from OKS
                 l_tmp_return_status := 'W';
		 l_msg_index := 1;
		 l_msg_count := x_msg_count;
	         WHILE l_msg_count > 0 LOOP
	            x_msg_data := FND_MSG_PUB.GET
			     (  l_msg_index,
				FND_API.G_FALSE
			      );
	            csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		    l_msg_index := l_msg_index + 1;
		    l_msg_count := l_msg_count - 1;
	         END LOOP;
                 FND_MSG_PUB.Count_And_Get
                 ( p_encoded => FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
                   p_data                  =>      x_msg_data
                 );
	      ELSIF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			l_msg_index := 1;
			l_msg_count := x_msg_count;
		    WHILE l_msg_count > 0 LOOP
		      x_msg_data := FND_MSG_PUB.GET
				    (  l_msg_index,
				       FND_API.G_FALSE
				     );
		      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
			  l_msg_index := l_msg_index + 1;
			  l_msg_count := l_msg_count - 1;
		    END LOOP;
	         RAISE FND_API.G_EXC_ERROR;
	      END IF;
          END IF;
       END IF;
   END IF;
   --
   x_return_status := l_tmp_return_status;
   -- Call Post Customer User Hook
  BEGIN

       IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
          csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_CUHK.Update_Item_Instance_Post ..');
          CSI_ITEM_INSTANCE_CUHK.Update_Item_Instance_Post
          (
           p_api_version           =>  1.0
          ,p_commit                =>  fnd_api.g_false
	      ,p_init_msg_list         =>  fnd_api.g_false
	      ,p_validation_level      =>  fnd_api.g_valid_level_full
	      ,p_instance_rec          =>  p_instance_rec
	      ,p_ext_attrib_values_tbl =>  p_ext_attrib_values_tbl
	      ,p_party_tbl             =>  p_party_tbl
	      ,p_account_tbl           =>  p_account_tbl
	      ,p_pricing_attrib_tbl    =>  p_pricing_attrib_tbl
	      ,p_org_assignments_tbl   =>  p_org_assignments_tbl
	      ,p_asset_assignment_tbl  =>  p_asset_assignment_tbl
	      ,p_txn_rec               =>  p_txn_rec
	      ,x_instance_id_lst       =>  x_instance_id_lst
	      ,x_return_status         =>  x_return_status
	      ,x_msg_count             =>  x_msg_count
	      ,x_msg_data              =>  x_msg_data
	      );
      --
           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               l_msg_index := 1;
               l_msg_count := x_msg_count;
               WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
                    csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Update_Item_Instance_Post API ');
                    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
               END LOOP;
              RAISE FND_API.G_EXC_ERROR;
	   END IF;
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Update Post Customer');
       RAISE FND_API.G_EXC_ERROR;
  END;
   --
   x_return_status := l_tmp_return_status;

  -- Call the update_party_relationship API to update instance-to-party
  -- relationships.
  -- START MODIFICATION BY SK for bug 2172968
   l_t_party_tbl := p_party_tbl;
   l_t_account_tbl := p_account_tbl;

   -- p_party_tbl has been replaced by l_t_party_tbl
   -- p_account_tbl has been replaced by l_t_account_tbl
   -- l_party_tbl has been replaced by l_new_party_tbl
   -- l_account_tbl has been replaced by l_new_account_tbl
   -- Above changes were made so as not to break the existing code.
   l_party_row := 1;
   l_acct_row  := 1;
   l_bacct_row  := 1;
   l_create:=1;
   l_update:=1;
   IF (l_t_party_tbl.count > 0) THEN
      FOR party_row IN l_t_party_tbl.FIRST .. l_t_party_tbl.LAST
      LOOP
         IF l_t_party_tbl.EXISTS(party_row) THEN
             IF ((l_t_party_tbl(party_row).instance_party_id IS NULL)
               OR
                (l_t_party_tbl(party_row).instance_party_id = FND_API.G_MISS_NUM))
             THEN
             -- The following code has been written to take of creating the contacts
             -- no matter the order which they are passed. So I'm grabbing the contacts
             -- into another temp table lb_party_tbl which I will make use in the seperate
             -- call during create_inst_party_relationship.
               IF l_t_party_tbl(party_row).contact_ip_id IS NOT NULL AND
                  l_t_party_tbl(party_row).contact_ip_id <> FND_API.G_MISS_NUM
               THEN
                  lb_party_tbl(l_create):= l_t_party_tbl(party_row);
                  l_t_party_tbl.DELETE(party_row);
                  l_create:=l_create+1;
               ELSE
                  l_new_party_tbl(l_party_row) := l_t_party_tbl(party_row);
                  l_t_party_tbl.DELETE(party_row);
               END IF;
              -- Grab all its accounts in a temprorary account table
              -- The following code has been written to take care the accounts for
              -- other than OWNER party.

                 IF l_t_account_tbl.COUNT > 0 THEN
                   FOR acct_row IN l_t_account_tbl.FIRST .. l_t_account_tbl.LAST
                   LOOP
                     IF l_t_account_tbl.EXISTS(acct_row) THEN
                       IF (l_t_account_tbl(acct_row).parent_tbl_index = l_party_row ) THEN --changed
                           la_account_tbl(l_bacct_row) := l_t_account_tbl(acct_row);
                           la_account_tbl(l_bacct_row).parent_tbl_index := l_party_row;
                           l_t_account_tbl.DELETE(acct_row);
                           l_bacct_row := l_bacct_row + 1;
                       END IF;
                     END IF;
                   END LOOP;
                 END IF;

             ELSE
              -- The following code has been written to take care the accounts for the
              -- OWNER party.
                  lc_party_tbl(l_update) := l_t_party_tbl(party_row);
                  l_t_party_tbl.DELETE(party_row);

                 IF l_t_account_tbl.COUNT > 0 THEN
                   FOR acct_row IN l_t_account_tbl.FIRST .. l_t_account_tbl.LAST
                   LOOP
                     IF l_t_account_tbl.EXISTS(acct_row) THEN
                       IF (l_t_account_tbl(acct_row).parent_tbl_index = l_party_row ) THEN --change
                           l_new_account_tbl(l_acct_row) := l_t_account_tbl(acct_row);
                           l_new_account_tbl(l_acct_row).parent_tbl_index := l_update;
                           l_t_account_tbl.DELETE(acct_row);
                           l_acct_row := l_acct_row + 1;
                       END IF;
                     END IF;
                   END LOOP;
                 END IF;
                 l_update:=l_update+1;
             END IF;
             l_party_row := l_party_row + 1;
         END IF;
      END LOOP;
   END IF;

   -- Update the parties,contacts and its accounts
  IF (lc_party_tbl.count > 0) THEN

  -- The following changes were made to make sure to associate
  -- accounts belonging to owner party to a newly created
  -- non owner parties.
     IF lc_party_tbl.COUNT > 0
     THEN
         FOR i IN 1..lc_party_tbl.COUNT
         LOOP
          IF lc_party_tbl.EXISTS(i)
          THEN
             BEGIN
               l_tem_party_id:=NULL;
               SELECT party_id
               INTO   l_tem_party_id
               FROM   csi_i_parties
               WHERE  instance_party_id=lc_party_tbl(i).instance_party_id
               AND    relationship_type_code='OWNER';
             EXCEPTION
               WHEN OTHERS THEN
                 l_tem_party_id:=NULL;
             END;
             IF  l_tem_party_id IS NOT NULL AND
                 lc_party_tbl(i).party_id <> l_tem_party_id AND
                 lc_party_tbl(i).relationship_type_code='OWNER'
             THEN
                 FOR j IN non_owner_csr(lc_party_tbl(i).instance_party_id)
                 LOOP
                   l_tem_acct_tbl(l_temp_var).ip_account_id:=j.ip_account_id;
                   l_tem_acct_tbl(l_temp_var).object_version_number:=j.object_version_number;
                   l_tem_acct_tbl(l_temp_var).active_end_date:=j.active_end_date;
                   l_temp_var:=l_temp_var+1;
                 END LOOP;

                 -- This loop has been written to take care of contacts issue.
                 -- When ever there is a transfer ownership then all the contacts
                 -- will get expired.
                 -- Contact object_version_numbers need to be bumped up
                 -- bug 2933430

                 FOR k IN i..lc_party_tbl.COUNT
                 LOOP
                   IF   lc_party_tbl(k).contact_ip_id=lc_party_tbl(i).instance_party_id
                    AND lc_party_tbl(k).contact_flag='Y'
                   THEN
                       -- Commented for bug 3376233
                       -- lc_party_tbl(k).object_version_number:=lc_party_tbl(k).object_version_number+1;
                       l_bump_date:=null;
                       -- IF lc_party_tbl(k).active_end_date = fnd_api.g_miss_date
                       -- THEN
                          BEGIN
                           SELECT active_end_date
                           INTO   l_bump_date --lc_party_tbl(k).active_end_date
                           FROM   csi_i_parties
                           WHERE  instance_party_id=lc_party_tbl(k).instance_party_id;

                       -- Added the following if condition for bug 3376233.
                           IF l_bump_date IS NULL OR
                              l_bump_date > SYSDATE
                           THEN
                           -- We need to bump up this record as it is active and will
                           -- get expired during transfer of ownership.
                           -- For those records which were already expired, there is no
                           -- need to bump up the version number.
                             IF lc_party_tbl(k).active_end_date = fnd_api.g_miss_date
                             THEN
                              lc_party_tbl(k).active_end_date:=l_bump_date;
                             END IF;
                             lc_party_tbl(k).object_version_number:=lc_party_tbl(k).object_version_number+1;
                           END IF;



                          EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                             NULL;
                          END;
                       -- END IF;
                   END IF;
                 END LOOP;

                 -- End addition for contacts bug 2933430

             END IF;
          END IF;
         END LOOP;
     END IF;
     --
     csi_party_relationships_pub.update_inst_party_relationship
	 (p_api_version      => p_api_version
	 ,p_commit           => fnd_api.g_false
	 ,p_init_msg_list    => p_init_msg_list
	 ,p_validation_level => p_validation_level
	 ,p_party_tbl        => lc_party_tbl
	 ,p_party_account_tbl=> l_new_account_tbl
	 ,p_txn_rec          => p_txn_rec
	 ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
	 ,x_return_status    => x_return_status
	 ,x_msg_count        => x_msg_count
	 ,x_msg_data         => x_msg_data
	   );

      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	WHILE l_msg_count > 0
	   LOOP
		      x_msg_data := FND_MSG_PUB.GET
			     (  l_msg_index,
				FND_API.G_FALSE       );
		  csi_gen_utility_pvt.put_line('Error from CSI_PARTY_RELATIONSHIPS_PUB.. ');
		  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   x_return_status := l_tmp_return_status;
   -- Create the parties and its accounts
   IF l_new_party_tbl.COUNT > 0 THEN
      -- The following changes were made to make sure to associate
      -- accounts belonging to owner party to a newly created
      -- non owner parties.
      IF la_account_tbl.COUNT > 0
      THEN
         FOR i IN 1..la_account_tbl.COUNT
         LOOP
          IF la_account_tbl.EXISTS(i)
          THEN
             IF l_tem_acct_tbl.COUNT>0
             THEN
               FOR j IN 1..l_tem_acct_tbl.COUNT
               LOOP
                IF la_account_tbl.EXISTS(i) AND
                   la_account_tbl(i).ip_account_id=l_tem_acct_tbl(j).ip_account_id
                THEN
                /*
                   la_account_tbl(i).object_version_number:=l_tem_acct_tbl(j).object_version_number+1;
                   IF la_account_tbl(i).active_end_date=fnd_api.g_miss_date
                   THEN
                     la_account_tbl(i).active_end_date:=l_tem_acct_tbl(j).active_end_date;
                   END IF;
                */
                 -- The following code is added for bug 3594408 (Rel 11.5.9)
                 BEGIN
                   SELECT object_version_number
                   INTO   la_account_tbl(i).object_version_number
                   FROM   csi_ip_accounts
                   WHERE  ip_account_id=la_account_tbl(i).ip_account_id;
                 EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                   NULL;
                 END;
                 -- End addition for bug 3594408 (Rel 11.5.9)
                END IF;
               END LOOP;
             END IF;
          END IF;
         END LOOP;
      END IF;
      csi_party_relationships_pub.create_inst_party_relationship
       ( p_api_version         => p_api_version
	,p_commit              => fnd_api.g_false
	,p_init_msg_list       => p_init_msg_list
	,p_validation_level    => p_validation_level
	,p_party_tbl           => l_new_party_tbl
	,p_party_account_tbl   => la_account_tbl
	,p_txn_rec             => p_txn_rec
	,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
	,x_return_status       => x_return_status
	,x_msg_count           => x_msg_count
	,x_msg_data            => x_msg_data
       );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
		      x_msg_data := FND_MSG_PUB.GET
			     (  l_msg_index,
				FND_API.G_FALSE       );
	      csi_gen_utility_pvt.put_line('Error from CSI_PARTY_RELATIONSHIPS_PUB.. ');
	      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	 END LOOP;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   x_return_status := l_tmp_return_status;

   -- Create the contacts for oooo.

   IF lb_party_tbl.COUNT > 0 THEN
      csi_party_relationships_pub.create_inst_party_relationship
       ( p_api_version         => p_api_version
	,p_commit              => fnd_api.g_false
	,p_init_msg_list       => p_init_msg_list
	,p_validation_level    => p_validation_level
	,p_party_tbl           => lb_party_tbl
	,p_party_account_tbl   => l_temp_acct_tbl
	,p_txn_rec             => p_txn_rec
	,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
	,x_return_status       => x_return_status
	,x_msg_count           => x_msg_count
	,x_msg_data            => x_msg_data
       );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
		      x_msg_data := FND_MSG_PUB.GET
			     (  l_msg_index,
				FND_API.G_FALSE       );
	      csi_gen_utility_pvt.put_line('Error from CSI_PARTY_RELATIONSHIPS_PUB.. ');
	      csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	 END LOOP;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   x_return_status := l_tmp_return_status;

   -- END MODIFICATION BY SK for bug 2172968


   -- Since some rows were deleted in accounts we need to add them up
   IF ((p_account_tbl.count > 0)
      OR (l_account_tbl.count > 0)) THEN

        IF p_party_tbl.count = 0 THEN
          l_acct_row := l_account_tbl.LAST + 1;
        ELSE

          l_acct_row := p_account_tbl.LAST + 1;
          IF l_acct_row IS NULL THEN
            l_acct_row := 1;
          END IF;
        END IF;

        IF l_account_tbl.count > 0 THEN
          FOR acct_row IN l_account_tbl.FIRST .. l_account_tbl.LAST
          LOOP
            IF l_account_tbl.EXISTS(acct_row) THEN
              p_account_tbl(l_acct_row) := l_account_tbl(acct_row);
              l_acct_row := l_acct_row + 1;
            END IF;
          END LOOP;
        END IF;
   END IF;


-- Call update_organization_unit to associate any org. assignments
-- to the item instance
 IF (p_org_assignments_tbl.count > 0) THEN
    FOR tab_row IN p_org_assignments_tbl.FIRST .. p_org_assignments_tbl.LAST
    LOOP
      IF p_org_assignments_tbl.EXISTS(tab_row) THEN
        IF ((p_org_assignments_tbl(tab_row).instance_ou_id IS NULL)
           OR
           (p_org_assignments_tbl(tab_row).instance_ou_id = FND_API.G_MISS_NUM))
        THEN
            csi_organization_unit_pvt.create_organization_unit
             (p_api_version       => p_api_version
             ,p_commit            => fnd_api.g_false
             ,p_init_msg_list     => p_init_msg_list
             ,p_validation_level  => p_validation_level
             ,p_org_unit_rec      => p_org_assignments_tbl(tab_row)
             ,p_txn_rec           => p_txn_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,p_lookup_tbl        => l_ou_lookup_tbl
             ,p_ou_count_rec      => l_ou_count_rec
             ,p_ou_id_tbl         => l_ou_id_tbl
            );
         ELSE
            csi_organization_unit_pvt.update_organization_unit
             (p_api_version       => p_api_version
             ,p_commit            => fnd_api.g_false
             ,p_init_msg_list     => p_init_msg_list
             ,p_validation_level  => p_validation_level
             ,p_org_unit_rec      => p_org_assignments_tbl(tab_row)
             ,p_txn_rec           => p_txn_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,p_lookup_tbl        => l_ou_lookup_tbl
             ,p_ou_count_rec      => l_ou_count_rec
             ,p_ou_id_tbl         => l_ou_id_tbl
            );
       END IF;
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                             FND_API.G_FALSE    );
          csi_gen_utility_pvt.put_line( ' Error from CSI_ORGANIZATION_UNIT_PUB..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;
   x_return_status := l_tmp_return_status;

-- Call update_pricing_attribs to associate any pricing attributes
-- to the item instance
  IF (p_pricing_attrib_tbl.count > 0) THEN
    FOR tab_row IN p_pricing_attrib_tbl.FIRST .. p_pricing_attrib_tbl.LAST
    LOOP
      IF p_pricing_attrib_tbl.EXISTS(tab_row) THEN
        IF ((p_pricing_attrib_tbl(tab_row).pricing_attribute_id IS NULL)
          OR
           (p_pricing_attrib_tbl(tab_row).pricing_attribute_id = FND_API.G_MISS_NUM))
        THEN
               csi_pricing_attribs_pvt.create_pricing_attribs
                ( p_api_version         => p_api_version
                 ,p_commit              => p_commit
                 ,p_init_msg_list       => p_init_msg_list
                 ,p_validation_level    => p_validation_level
                 ,p_pricing_attribs_rec => p_pricing_attrib_tbl(tab_row)
                 ,p_txn_rec             => p_txn_rec
                 ,x_return_status       => x_return_status
                 ,x_msg_count           => x_msg_count
                 ,x_msg_data            => x_msg_data
                 );
         ELSE
              csi_pricing_attribs_pvt.update_pricing_attribs
               ( p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_pricing_attribs_rec  => p_pricing_attrib_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
               );
         END IF;

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
           l_msg_index := 1;
           l_msg_count := x_msg_count;
           WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                     FND_API.G_FALSE    );
                 csi_gen_utility_pvt.put_line( ' Error from CSI_PRICING_ATTRIBS_PUB..');
                 csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                     l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
               END LOOP;
                 RAISE FND_API.G_EXC_ERROR;
         END IF;
     END IF;
   END LOOP;
 END IF;
   x_return_status := l_tmp_return_status;

-- Call create_extended_attribs to associate any extended attributes
-- to the item instance
 IF (p_ext_attrib_values_tbl.count > 0) THEN
    FOR tab_row IN p_ext_attrib_values_tbl.FIRST .. p_ext_attrib_values_tbl.LAST
    LOOP
      IF p_ext_attrib_values_tbl.EXISTS (tab_row) THEN
        IF ((p_ext_attrib_values_tbl(tab_row).attribute_value_id IS NULL)
          OR
           (p_ext_attrib_values_tbl(tab_row).attribute_value_id = FND_API.G_MISS_NUM))
        THEN
            csi_item_instance_pvt.create_extended_attrib_values
                ( p_api_version         => p_api_version
                 ,p_commit              => fnd_api.g_false
                 ,p_init_msg_list       => p_init_msg_list
                 ,p_validation_level    => p_validation_level
                 ,p_ext_attrib_rec      => p_ext_attrib_values_tbl(tab_row)
                 ,p_txn_rec             => p_txn_rec
                 ,x_return_status       => x_return_status
                 ,x_msg_count           => x_msg_count
                 ,x_msg_data            => x_msg_data
                 ,p_ext_id_tbl          => l_ext_id_tbl
                 ,p_ext_count_rec       => l_ext_count_rec
                 ,p_ext_attr_tbl        => l_ext_attr_tbl
                 ,p_ext_cat_tbl         => l_ext_cat_tbl
                );
        ELSE
-- call the update extended attributes api
            csi_item_instance_pvt.update_extended_attrib_values
               ( p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_ext_attrib_rec       => p_ext_attrib_values_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
--                ,p_ext_id_tbl           => l_ext_id_tbl
--                ,p_ext_count_rec        => l_ext_count_rec
--                ,p_ext_attr_tbl         => l_ext_attr_tbl
--                ,p_ext_cat_tbl          => l_ext_cat_tbl
               );
        END IF;
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                             FND_API.G_FALSE    );
                csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
              END LOOP;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF; -- exist if
   END LOOP; -- for loop
 END IF;
   x_return_status := l_tmp_return_status;

-- Call create_asset_assignments to associate any assets associated
-- to the item instance
  IF (p_asset_assignment_tbl.count > 0) THEN
    FOR tab_row IN p_asset_assignment_tbl.FIRST .. p_asset_assignment_tbl.LAST
    LOOP
      IF p_asset_assignment_tbl.EXISTS(tab_row) THEN
        IF ((p_asset_assignment_tbl(tab_row).instance_asset_id IS NULL)
          OR
           (p_asset_assignment_tbl(tab_row).instance_asset_id = FND_API.G_MISS_NUM)) THEN
               csi_asset_pvt.create_instance_asset
                (p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_instance_asset_rec   => p_asset_assignment_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                ,p_lookup_tbl           => l_asset_lookup_tbl
                ,p_asset_count_rec      => l_asset_count_rec
                ,p_asset_id_tbl         => l_asset_id_tbl
                ,p_asset_loc_tbl        => l_asset_loc_tbl
                );
        ELSE
--call the update assets api
               csi_asset_pvt.update_instance_asset
                (p_api_version          => p_api_version
                ,p_commit               => fnd_api.g_false
                ,p_init_msg_list        => p_init_msg_list
                ,p_validation_level     => p_validation_level
                ,p_instance_asset_rec   => p_asset_assignment_tbl(tab_row)
                ,p_txn_rec              => p_txn_rec
                ,x_return_status        => x_return_status
                ,x_msg_count            => x_msg_count
                ,x_msg_data             => x_msg_data
                ,p_lookup_tbl           => l_asset_lookup_tbl
                ,p_asset_count_rec      => l_asset_count_rec
                ,p_asset_id_tbl         => l_asset_id_tbl
                ,p_asset_loc_tbl        => l_asset_loc_tbl
                );
        END IF;
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
          WHILE l_msg_count > 0 LOOP
                x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                         FND_API.G_FALSE  );
                csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
              END LOOP;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;
  END IF;
   x_return_status := l_tmp_return_status;

-- Start att enhancements
  IF p_instance_rec.call_batch_validation<>fnd_api.g_false
  THEN
    IF p_instance_rec.instance_id IS NOT NULL AND
       p_instance_rec.instance_id <> fnd_api.g_miss_num
    THEN
       IF  (   l_old_ins_csr.config_inst_hdr_id IS NOT NULL
          AND (p_instance_rec.config_inst_hdr_id IS NULL OR p_instance_rec.config_inst_hdr_id = fnd_api.g_miss_num) )
         OR(   l_old_ins_csr.config_inst_hdr_id IS NULL
          AND (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num) )
         OR(   l_old_ins_csr.config_inst_hdr_id IS NOT NULL
          AND (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
          AND (l_old_ins_csr.config_inst_hdr_id <> p_instance_rec.config_inst_hdr_id) )
         OR(   l_old_ins_csr.config_inst_item_id IS NOT NULL
          AND (p_instance_rec.config_inst_item_id IS NULL OR p_instance_rec.config_inst_item_id = fnd_api.g_miss_num) )
         OR(   l_old_ins_csr.config_inst_item_id IS NULL
          AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num) )
         OR(   l_old_ins_csr.config_inst_item_id IS NOT NULL
          AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
          AND (l_old_ins_csr.config_inst_item_id <> p_instance_rec.config_inst_item_id) )
       THEN
               l_no_config_keys:=TRUE;
		       csi_gen_utility_pvt.put_line( 'Config keys were not provided. So no batch validation will be performed');
       END IF;

      IF NOT l_no_config_keys
      THEN
       IF   (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_rev_num IS NOT NULL AND p_instance_rec.config_inst_rev_num <> fnd_api.g_miss_num)
       THEN

          IF NOT csi_item_instance_vld_pvt.is_unique_config_key ( p_config_inst_hdr_id  => p_instance_rec.config_inst_hdr_id
                                                                 ,p_config_inst_item_id => p_instance_rec.config_inst_item_id
                                                                 ,p_instance_id         => p_instance_rec.instance_id
                                                                 ,p_validation_mode     => 'UPDATE'
                                                                 )
          THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_KEY_EXISTS');
           FND_MSG_PUB.Add;
           RAISE fnd_api.g_exc_error;
          END IF;

          BEGIN
              SELECT component_instance_type
                    ,config_hdr_id
                    ,config_rev_nbr
              INTO   l_component_ins_type
                    ,l_config_hdr_id
                    ,l_config_rev_nbr
              FROM   cz_config_items_v
              WHERE  instance_hdr_id = p_instance_rec.config_inst_hdr_id
              AND    instance_rev_nbr = p_instance_rec.config_inst_rev_num
              AND    config_item_id = p_instance_rec.config_inst_item_id;
          EXCEPTION
              WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_NOT_IN_CZ');
               FND_MESSAGE.SET_TOKEN('INSTANCE_HDR_ID',p_instance_rec.config_inst_hdr_id);
               FND_MESSAGE.SET_TOKEN('INSTANCE_REV_NBR',p_instance_rec.config_inst_rev_num);
               FND_MESSAGE.SET_TOKEN('CONFIG_ITEM_ID',p_instance_rec.config_inst_item_id);

               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
          END;

          IF l_component_ins_type='I'
          THEN

            Csi_item_instance_vld_pvt.Call_batch_validate
              ( p_instance_rec    => p_instance_rec
               ,p_config_hdr_id   => l_config_hdr_id
               ,p_config_rev_nbr  => l_config_rev_nbr
               ,x_config_hdr_id   => l_batch_hdr_id
               ,x_config_rev_nbr  => l_batch_rev_nbr
               ,x_return_status   => x_return_status);

            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_ERROR');
               FND_MSG_PUB.Add;
               csi_gen_utility_pvt.put_line('Call to batch validation has errored ');
               RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;

       ELSIF (  (p_instance_rec.config_inst_hdr_id IS NULL OR p_instance_rec.config_inst_hdr_id = fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num))
          OR (  (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NULL OR p_instance_rec.config_inst_item_id = fnd_api.g_miss_num))
          OR (  (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_rev_num IS NULL OR p_instance_rec.config_inst_rev_num = fnd_api.g_miss_num))
       THEN
		       FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_CONFIG_COMB');
		       FND_MSG_PUB.Add;
		       RAISE fnd_api.g_exc_error;
       END IF;
      END IF;
    END IF;
  END IF;
   -- Adding new changes for bug 3799694
    IF   (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_rev_num IS NOT NULL AND p_instance_rec.config_inst_rev_num <> fnd_api.g_miss_num)
    THEN
             FOR l_config_ins_key IN new_config_ins_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_rev_num)
              LOOP
                IF l_config_ins_key.has_failures ='1'
                 OR nvl(l_config_ins_key.config_status,'0') <> '2'
                THEN
                   FOR l_instance_key IN new_instance_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_item_id)
                   LOOP

                         l_config_instance_rec:=l_config_temp_rec;
                      IF (l_instance_key.instance_id IS NOT NULL AND
                          l_instance_key.instance_id <> fnd_api.g_miss_num) AND
                         ( l_instance_key.config_valid_status IS NULL OR
                          (l_instance_key.config_valid_status IS NOT NULL AND
                           l_instance_key.config_valid_status <> '1'))
                      THEN
                         l_config_instance_rec.instance_id:=l_instance_key.instance_id;
                         l_config_instance_rec.object_version_number:=l_instance_key.object_version_number;
                         l_config_instance_rec.config_valid_status:='1'; --INVALID

                         csi_item_instance_pvt.update_item_instance
                          (
                            p_api_version        => p_api_version
                           ,p_commit             => fnd_api.g_false
                           ,p_init_msg_list      => p_init_msg_list
                           ,p_validation_level   => p_validation_level
                           ,p_instance_rec       => l_config_instance_rec
                           ,p_txn_rec            => p_txn_rec
                           ,x_instance_id_lst    => l_instance_id_lst
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                           ,p_item_attribute_tbl => l_item_attribute_tbl
                           ,p_location_tbl       => l_location_tbl
                           ,p_generic_id_tbl     => l_generic_id_tbl
                           ,p_lookup_tbl         => l_lookup_tbl
                           ,p_ins_count_rec      => l_ins_count_rec
	                   ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
                           ,p_child_inst_tbl     => px_child_inst_tbl
                         );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                        WHILE l_msg_count > 0 LOOP
                             x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                             csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
                             csi_gen_utility_pvt.put_line( 'while updating config status');
                             csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                              l_msg_index := l_msg_index + 1;
                              l_msg_count := l_msg_count - 1;
                        END LOOP;
                           RAISE FND_API.G_EXC_ERROR;
                      END IF;
                      END IF;
                   END LOOP;
                ELSE
                   FOR l_instance_key IN new_instance_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_item_id)
                   LOOP
                         l_config_instance_rec:=l_config_temp_rec;
                      IF (l_instance_key.instance_id IS NOT NULL AND
                          l_instance_key.instance_id <> fnd_api.g_miss_num) AND
                         ( l_instance_key.config_valid_status IS NULL OR
                          (l_instance_key.config_valid_status IS NOT NULL AND
                           l_instance_key.config_valid_status <> '0'))
                      THEN
                         l_config_instance_rec.instance_id:=l_instance_key.instance_id;
                         l_config_instance_rec.object_version_number:=l_instance_key.object_version_number;
                         l_config_instance_rec.config_valid_status:='0'; --VALID
                         csi_item_instance_pvt.update_item_instance
                          (
                            p_api_version        => p_api_version
                           ,p_commit             => fnd_api.g_false
                           ,p_init_msg_list      => p_init_msg_list
                           ,p_validation_level   => p_validation_level
                           ,p_instance_rec       => l_config_instance_rec
                           ,p_txn_rec            => p_txn_rec
                           ,x_instance_id_lst    => l_instance_id_lst
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                           ,p_item_attribute_tbl => l_item_attribute_tbl
                           ,p_location_tbl       => l_location_tbl
                           ,p_generic_id_tbl     => l_generic_id_tbl
                           ,p_lookup_tbl         => l_lookup_tbl
                           ,p_ins_count_rec      => l_ins_count_rec
	                   ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
                           ,p_child_inst_tbl     => px_child_inst_tbl
                         );

                      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                        WHILE l_msg_count > 0 LOOP
                             x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                             csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
                             csi_gen_utility_pvt.put_line( 'while updating config status');
                             csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                              l_msg_index := l_msg_index + 1;
                              l_msg_count := l_msg_count - 1;
                        END LOOP;
                           RAISE FND_API.G_EXC_ERROR;
                      END IF;
                      END IF;
                   END LOOP;
                END IF;
             END LOOP;

    END IF;


-- End addition of changes for bug 3799694
  x_return_status := l_tmp_return_status;
-- End att enhancements

    -- sguthiva Added the following for bug 2632869
    IF l_updated
    THEN
    l_instance_rec:=l_temp_instance_rec;
    l_instance_rec:=p_instance_rec;
    -- Bug 3804960 We need to honor the end_date passed to instance_rec
   /***  IF l_date
     THEN
       l_instance_rec.active_end_date:=SYSDATE;
     END IF; ***/
     -- End of 3804960
     l_instance_rec.call_contracts := l_new_instance_rec.call_contracts; -- added for avoiding multiple OKS calls
     BEGIN
       SELECT object_version_number
       INTO   l_instance_rec.object_version_number
       FROM   csi_item_instances
       WHERE  instance_id=p_instance_rec.instance_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        NULL;
     END;
-- Call the update_item_instance private API to update the instances
       csi_item_instance_pvt.update_item_instance
       (
         p_api_version      => p_api_version
        ,p_commit           => fnd_api.g_false
        ,p_init_msg_list    => p_init_msg_list
        ,p_validation_level => p_validation_level
        ,p_instance_rec     => l_instance_rec
        ,p_txn_rec          => p_txn_rec
        ,x_instance_id_lst  => x_instance_id_lst
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
        ,p_item_attribute_tbl => l_item_attribute_tbl
        ,p_location_tbl     => l_location_tbl
        ,p_generic_id_tbl     => l_generic_id_tbl
        ,p_lookup_tbl         => l_lookup_tbl
        ,p_ins_count_rec      => l_ins_count_rec
	,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
        ,p_child_inst_tbl     => px_child_inst_tbl
       );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
          l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                                         FND_API.G_FALSE        );
          csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
   x_return_status := l_tmp_return_status;
    -- End addition for bug 2632869

-- Added by rtalluri for Bug 2256588 on 03/26/02
-- Call the Version label API to associate a version label for the updated record

   IF p_instance_rec.active_end_date = FND_API.G_MISS_DATE
   THEN
     BEGIN
       SELECT active_end_date
       INTO   l_active_end_date
       FROM   csi_item_instances
       WHERE  instance_id = p_instance_rec.instance_id;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
     END;
   ELSE
       l_active_end_date := p_instance_rec.active_end_date;
   END IF;

      IF  ((l_active_end_date > SYSDATE) OR
           (l_active_end_date IS NULL))
      THEN
          IF    ((p_instance_rec.version_label IS NOT NULL) AND
                 (p_instance_rec.version_label <> FND_API.G_MISS_CHAR))
          THEN
 -- Check if version label already exists in csi_i_version_labels
 -- If exists then raise an error message
                 BEGIN

                   SELECT 'x'
                   INTO   l_dummy
                   FROM   csi_i_version_labels
                   WHERE  instance_id = p_instance_rec.instance_id
                   AND    version_label = p_instance_rec.version_label
                   AND    ROWNUM=1;

                   fnd_message.set_name('CSI','CSI_VERSION_LABEL_EXIST');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_error;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      NULL;
                    WHEN OTHERS THEN
                      RAISE fnd_api.g_exc_error;
                 END;

                  l_version_label_rec.instance_id           := p_instance_rec.instance_id;
                  l_version_label_rec.version_label         := p_instance_rec.version_label;
                  l_version_label_rec.description           := p_instance_rec.version_label_description;
                  l_version_label_rec.date_time_stamp       := SYSDATE;
               -- calling create version label api
                  csi_item_instance_pvt.create_version_label
                  ( p_api_version         => p_api_version
                   ,p_commit              => p_commit
                   ,p_init_msg_list       => p_init_msg_list
                   ,p_validation_level    => p_validation_level
                   ,p_version_label_rec   => l_version_label_rec
                   ,p_txn_rec             => p_txn_rec
                   ,x_return_status       => x_return_status
                   ,x_msg_count           => x_msg_count
                   ,x_msg_data            => x_msg_data         );

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   FND_MESSAGE.SET_NAME('CSI','CSI_FAILED_TO_CREATE_VERSION');
                   FND_MESSAGE.SET_TOKEN('API_ERROR', 'CREATE_VERSION_LABEL');
                   FND_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
          END IF;
      END IF;
   x_return_status := l_tmp_return_status;

   -- End of addition by rtalluri for Bug 2256588 on 03/26/02

   -- Here we call update_version_time to update date_time_stamp of
   -- version labels created with this transaction_id to sysdate.
   -- Commented the following code, which is causing the prformance
   -- issue. -- bug 3558082 (reported in 11.5.8)
   --
   x_return_status := l_tmp_return_status;

   -- Calling Contracts
   -- Added on 02-OCT-01
   OPEN  instance_csr (p_instance_rec.instance_id);
   FETCH instance_csr INTO l_instance_csr;
   CLOSE instance_csr;
   --
   BEGIN
      SELECT cip.party_id
      INTO   l_party_id
      FROM   csi_i_parties cip
      WHERE  cip.instance_id = p_instance_rec.instance_id
      AND    cip.relationship_type_code = 'OWNER';
   EXCEPTION
      WHEN OTHERS THEN
	 l_party_id := NULL;
   END;
   --
   -- srramakr. If the current party is Internal, then no need to call OKS
   -- with TRM or RET. The call would have been made when the ownership got changed.
   IF l_party_id IS NOT NULL AND
      l_party_id <> l_internal_party_id THEN
      IF l_old_ins_csr.instance_status_id <> l_instance_csr.instance_status_id THEN
	 IF csi_item_instance_vld_pvt.termination_status
	   ( p_instance_status_id => l_instance_csr.instance_status_id )
	 THEN
	    IF p_txn_rec.transaction_type_id in (53,54) THEN -- RMA
	       l_transaction_type := 'RET';
	    ELSE
	       l_transaction_type := 'TRM';
	    END IF;
	     l_transaction_date := l_instance_csr.active_end_date;
	 END IF;
      END IF;
   END IF;
   --
   IF l_transaction_type IS NULL
   THEN
      IF l_old_ins_csr.active_end_date <= SYSDATE
	 AND (l_instance_csr.active_end_date IS NULL
	    OR l_instance_csr.active_end_date > SYSDATE )
      THEN
	 -- Added by sk for fixing bug 2245976
	 -- OWNER Party_id and Internal_party_id selection moved up.
	 IF l_party_id IS NOT NULL AND
	    l_internal_party_id IS NOT NULL AND
	    l_party_id <> l_internal_party_id
	 THEN
	 -- End addition by sk for fixing bug 2245976
	    l_transaction_type := 'NEW';
	    l_transaction_date := l_instance_csr.active_end_date;
	    -- 11.5.10 ER. While un-expiring the instance, order Line ID will passed only if it is changing
	    IF l_instance_csr.location_type_code = 'IN_TRANSIT' THEN
	       IF nvl(l_old_ins_csr.in_transit_order_line_id,-99999) <>
				  nvl(l_instance_csr.in_transit_order_line_id,-99999) THEN
		  l_order_line_id := l_instance_csr.in_transit_order_line_id;
	       ELSE
		  l_order_line_id := NULL;
	       END IF;
	    ELSE
	       IF nvl(l_old_ins_csr.last_oe_order_line_id,-99999) <>
				nvl(l_instance_csr.last_oe_order_line_id,-99999) THEN
		  l_order_line_id := l_instance_csr.last_oe_order_line_id;
	       ELSE
		  l_order_line_id := NULL;
	       END IF;
	    END IF;
	 ELSE
	    l_transaction_type := NULL;
	 END IF;
      END IF;
   END IF;
   --
   IF l_transaction_type IS NOT NULL THEN

      -- Added for DEBUG purposes for bug 9028424
      IF l_new_instance_rec.call_contracts = fnd_api.g_false THEN
        csi_gen_utility_pvt.put_line('call_contracts(1): '||l_new_instance_rec.call_contracts);
      ELSIF l_new_instance_rec.call_contracts = 'N' THEN
        csi_gen_utility_pvt.put_line('call_contracts(2): '||l_new_instance_rec.call_contracts);
      ELSE
        csi_gen_utility_pvt.put_line('call_contracts(3): '||l_new_instance_rec.call_contracts);
      END IF;
      -- End DEBUG section

      -- srramakr changed from p_instance_rec to l_new_instance_rec
      IF (l_new_instance_rec.call_contracts <> fnd_api.g_false AND l_new_instance_rec.call_contracts <> 'N') --added by radha on 04/04/02
      THEN
         IF p_txn_rec.transaction_type_id <> 7   -- Added for bug 3973706
         THEN
	     csi_item_instance_pvt.Call_to_Contracts
	       ( p_transaction_type   =>   l_transaction_type
		,p_instance_id        =>   p_instance_rec.instance_id
		,p_new_instance_id    =>   NULL
		,p_vld_org_id         =>   p_instance_rec.vld_organization_id
		,p_quantity           =>   NULL
		,p_party_account_id1  =>   NULL
		,p_party_account_id2  =>   NULL
		,p_transaction_date   =>   p_txn_rec.transaction_date -- l_transaction_date
                ,p_source_transaction_date   =>   p_txn_rec.source_transaction_date -- Added jpwilson
		,p_txn_type_id        => p_txn_rec.transaction_type_id  --added for BUG# 5752271
		,p_order_line_id      =>   l_order_line_id -- will have a value only when there is a change in order line_id
		,p_oks_txn_inst_tbl   =>   px_oks_txn_inst_tbl
		,x_return_status      =>   x_return_status
		,x_msg_count          =>   x_msg_count
		,x_msg_data           =>   x_msg_data
	       );
             --
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                   x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE
                               );
                   csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
         END IF; -- Added for bug 3973706
      END IF;
   END IF;
   --
   x_return_status := l_tmp_return_status;
   --
   IF px_oks_txn_inst_tbl.count > 0 THEN
      csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
      csi_gen_utility_pvt.put_line('Calling OKS Core API...');
      --
      IF p_txn_rec.transaction_type_id = 3 THEN
	 l_batch_id := p_txn_rec.source_header_ref_id;
	 l_batch_type := p_txn_rec.source_group_ref;
      ELSE
	 l_batch_id := NULL;
	 l_batch_type := NULL;
      END IF;
      --
      UPDATE CSI_TRANSACTIONS
      set contracts_invoked = 'Y'
      where transaction_id = p_txn_rec.transaction_id;
      --
      OKS_IBINT_PUB.IB_interface
	 (
	   P_Api_Version           =>  1.0,
	   P_init_msg_list         =>  p_init_msg_list,
	   P_single_txn_date_flag  =>  'Y',
	   P_Batch_type            =>  l_batch_type,
	   P_Batch_ID              =>  l_batch_id,
	   P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	   x_return_status         =>  x_return_status,
	   x_msg_count             =>  x_msg_count,
	   x_msg_data              =>  x_msg_data
	);
      --
      IF x_return_status = 'W' THEN -- Warning from OKS
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
	    x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE
		      );
	    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	    l_msg_index := l_msg_index + 1;
	    l_msg_count := l_msg_count - 1;
	 END LOOP;
	 FND_MSG_PUB.Count_And_Get
	 ( p_encoded => FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
	   p_data                  =>      x_msg_data
	 );
      ELSIF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
	    x_msg_data := FND_MSG_PUB.GET
		    (  l_msg_index,
		       FND_API.G_FALSE        );
	    csi_gen_utility_pvt.put_line( 'Error from OKS_IBINT_PUB.IB_interface..');
	    csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	    l_msg_index := l_msg_index + 1;
	    l_msg_count := l_msg_count - 1;
	 END LOOP;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   -- End of API body
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_flag = 'Y') THEN
         dbms_session.set_sql_trace(FALSE);
    END IF;
        -- End disable trace
    ****/
    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
       (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
        p_data         =>      x_msg_data
       );

 -- Call Post Vertical user Hook
  BEGIN

       IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V' ) THEN
          csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_VUHK.Update_Item_Instance_Post ..');
          CSI_ITEM_INSTANCE_VUHK.Update_Item_Instance_Post
          (
           p_api_version           =>  1.0
          ,p_commit                =>  fnd_api.g_false
	      ,p_init_msg_list         =>  fnd_api.g_false
	      ,p_validation_level      =>  fnd_api.g_valid_level_full
	      ,p_instance_rec          =>  p_instance_rec
	      ,p_ext_attrib_values_tbl =>  p_ext_attrib_values_tbl
	      ,p_party_tbl             =>  p_party_tbl
	      ,p_account_tbl           =>  p_account_tbl
	      ,p_pricing_attrib_tbl    =>  p_pricing_attrib_tbl
	      ,p_org_assignments_tbl   =>  p_org_assignments_tbl
	      ,p_asset_assignment_tbl  =>  p_asset_assignment_tbl
	      ,p_txn_rec               =>  p_txn_rec
	      ,x_instance_id_lst       =>  x_instance_id_lst
	      ,x_return_status         =>  x_return_status
	      ,x_msg_count             =>  x_msg_count
	      ,x_msg_data              =>  x_msg_data
	      );
      --
          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;
              WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                             (  l_msg_index,
                               FND_API.G_FALSE );
                     csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Update_Item_Instance_Post API ');
                     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
              END LOOP;
             RAISE FND_API.G_EXC_ERROR;
	       END IF;
       END IF;

  EXCEPTION
    WHEN OTHERS THEN
       csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Update Post Vertical');
       RAISE FND_API.G_EXC_ERROR;
  END;
   x_return_status := l_tmp_return_status;
   -- End of POST User Hooks
   --

  -- Begin Add Code for Siebel Genesis Project
  csi_gen_utility_pvt.put_line('Source code = '||l_instance_csr.source_code);
  csi_gen_utility_pvt.put_line('p_instance_rec.instance_id = '||to_char(p_instance_rec.instance_id));
  csi_gen_utility_pvt.put_line('p_instance_rec.source_code = '||p_instance_rec.source_code);

  l_instance_id := p_instance_rec.instance_id;
  IF (l_instance_id = NULL OR l_instance_id = FND_API.G_MISS_NUM) THEN
    IF p_party_tbl.count > 0 THEN
      l_instance_id := p_party_tbl(1).instance_id;
    END IF;
  END IF;

  BEGIN
     SELECT source_code, owner_party_id
     INTO   l_source_code, l_owner_party_id
     FROM   csi_item_instances
     WHERE  instance_id = l_instance_id;
  EXCEPTION
     WHEN OTHERS THEN NULL;
  END;

  IF l_raise_bes_event = 'Y' THEN
     csi_gen_utility_pvt.put_line('l_internal_party_id = '||to_char(l_internal_party_id));
     csi_gen_utility_pvt.put_line('l_owner_party_id = '||to_char(l_owner_party_id));
     csi_gen_utility_pvt.put_line('Before calling update instance event');
     IF (l_internal_party_id <> l_owner_party_id OR
        (p_txn_rec.transaction_type_id IN (53,54) AND l_create_event_called = 'Y')) THEN -- Bug 7156553, base bug 7155591
        csi_gen_utility_pvt.put_line('Before last_oe_order_line_id');
        csi_gen_utility_pvt.put_line('last_oe_order_line_id = '||to_char(p_instance_rec.last_oe_order_line_id));
        IF l_create_event_called = 'N' THEN
           csi_gen_utility_pvt.put_line('Calling Create Instance Event');
           CSI_BUSINESS_EVENT_PVT.CREATE_INSTANCE_EVENT
              ( p_api_version         => p_api_version
               ,p_commit              => fnd_api.g_false
               ,p_init_msg_list       => p_init_msg_list
               ,p_validation_level    => p_validation_level
               ,p_instance_id         => l_instance_id
               ,p_subject_instance_id => null
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
              );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;

              WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
                 csi_gen_utility_pvt.put_line(' Error from CSI_BUSINESS_EVENT.CREATE_INSTANCE_EVENT');
                 csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
              END LOOP;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        ELSE
           csi_gen_utility_pvt.put_line('Calling Update Instance Event');
           CSI_BUSINESS_EVENT_PVT.UPDATE_INSTANCE_EVENT
              ( p_api_version         => p_api_version
               ,p_commit              => fnd_api.g_false
               ,p_init_msg_list       => p_init_msg_list
               ,p_validation_level    => p_validation_level
               ,p_instance_id         => l_instance_id
               ,p_subject_instance_id => null
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
              );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_msg_index := 1;
              l_msg_count := x_msg_count;

              WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET(l_msg_index, FND_API.G_FALSE);
                 csi_gen_utility_pvt.put_line(' Error from CSI_BUSINESS_EVENT.UPDATE_INSTANCE_EVENT');
                 csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
              END LOOP;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
     END IF;
  END IF;
  -- End Add Code for Siebel Genesis Project

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO update_item_instance;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
                (p_encoded               =>      FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
                 p_data                  =>      x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO update_item_instance;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
         ( p_encoded => FND_API.G_FALSE,
                 p_count => x_msg_count,
           p_data  => x_msg_data
         );
    WHEN OTHERS THEN
       ROLLBACK TO update_item_instance;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg
             ( G_PKG_NAME,
               l_api_name
             );
       END IF;
       FND_MSG_PUB.Count_And_Get
          ( p_encoded => FND_API.G_FALSE,
                 p_count => x_msg_count,
            p_data  => x_msg_data
          );
END update_item_instance;

/*----------------------------------------------------*/
/* Procedure name: expire_item_instance               */
/* Description :   procedure for                      */
/*                 Expiring an Item Instance          */
/*----------------------------------------------------*/

PROCEDURE expire_item_instance
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2
     ,p_init_msg_list       IN      VARCHAR2
     ,p_validation_level    IN      NUMBER
     ,p_instance_rec        IN      csi_datastructures_pub.instance_rec
     ,p_expire_children     IN      VARCHAR2
     ,p_txn_rec             IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT     NOCOPY csi_datastructures_pub.id_tbl
     ,x_return_status       OUT     NOCOPY VARCHAR2
     ,x_msg_count           OUT     NOCOPY NUMBER
     ,x_msg_data            OUT     NOCOPY VARCHAR2
 )
IS
     l_api_name              CONSTANT VARCHAR2(30)     := 'EXPIRE_ITEM_INSTANCE';
     l_api_version           CONSTANT NUMBER           := 1.0;
     l_debug_level                    NUMBER;
     l_flag                           VARCHAR2(1);
     l_msg_index                      NUMBER;
     l_msg_count                      NUMBER;
    -- The following were added for att
    l_component_ins_type     VARCHAR2(1):=NULL;
    l_config_hdr_id          NUMBER;
    l_config_rev_nbr         NUMBER;
    l_config_key             csi_utility_grp.config_instance_key;
    l_config_valid_status    VARCHAR2(10);
    l_no_config_keys         BOOLEAN := FALSE;
    l_return_message         VARCHAR2(100);
    -- end addition
    CURSOR config_ins_key (p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) is
      SELECT instance_hdr_id
            ,config_item_id
            ,has_failures
      FROM   cz_config_details_v d
            ,cz_config_hdrs_v h
      WHERE d.instance_hdr_id = h.config_hdr_id
      AND   d.instance_rev_nbr = h.config_rev_nbr
      AND   d.component_instance_type = 'I'
      AND   d.config_hdr_id = p_config_hdr_id
      AND   d.config_rev_nbr = p_config_rev_nbr;

    CURSOR instance_key (p_config_inst_hdr_id NUMBER, p_config_inst_item_id NUMBER)is
      SELECT instance_id
            ,object_version_number
            ,config_valid_status
      FROM   csi_item_instances
      WHERE  config_inst_hdr_id=p_config_inst_hdr_id
      AND    config_inst_item_id=p_config_inst_item_id;

    CURSOR new_config_ins_key (p_config_ins_hdr_id NUMBER, p_config_ins_rev_nbr NUMBER) is
      SELECT has_failures
            ,config_status
      FROM   cz_config_details_v d
            ,cz_config_hdrs h
      WHERE d.instance_hdr_id = p_config_ins_hdr_id
      AND   d.instance_rev_nbr = p_config_ins_rev_nbr
     -- AND   d.component_instance_type = 'I'
      AND   d.config_hdr_id = h.config_hdr_id
      AND   d.config_rev_nbr = h.config_rev_nbr;

    CURSOR new_instance_key (p_config_inst_hdr_id NUMBER, p_config_inst_item_id NUMBER)is
      SELECT instance_id
            ,object_version_number
            ,config_valid_status
      FROM   csi_item_instances
      WHERE  config_inst_hdr_id=p_config_inst_hdr_id
      AND    config_inst_item_id=p_config_inst_item_id;

      l_config_instance_rec           csi_datastructures_pub.instance_rec ;
      l_config_temp_rec               csi_datastructures_pub.instance_rec ;
      l_batch_hdr_id                  NUMBER;
      l_batch_rev_nbr                 NUMBER;
      l_instance_id_lst               csi_datastructures_pub.id_tbl;
      l_item_attribute_tbl            csi_item_instance_pvt.item_attribute_tbl;
      l_location_tbl                  csi_item_instance_pvt.location_tbl;
      l_generic_id_tbl                csi_item_instance_pvt.generic_id_tbl;
      l_lookup_tbl                    csi_item_instance_pvt.lookup_tbl;
      l_ins_count_rec                 csi_item_instance_pvt.ins_count_rec;
      l_config_ins_rec                csi_datastructures_pub.instance_rec;
      l_config_tmp_rec                csi_datastructures_pub.instance_rec;
      --
      px_oks_txn_inst_tbl             OKS_IBINT_PUB.TXN_INSTANCE_TBL;
      px_child_inst_tbl               csi_item_instance_grp.child_inst_tbl;
      l_batch_type                    VARCHAR2(50);
      l_batch_id                      NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  expire_item_instance;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y'

   csi_utility_grp.check_ib_active;

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
   l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (l_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line( 'expire_item_instance');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (l_debug_level > 1) THEN
      csi_gen_utility_pvt.put_line( 'expire_item_instance:'  ||
					     p_api_version      ||'-'||
					     p_commit           ||'-'||
					     p_init_msg_list    ||'-'||
					     p_validation_level      );
      -- Dump the records in the log file
      csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
      csi_gen_utility_pvt.dump_instance_rec(p_instance_rec);
   END IF;
   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and enable trace
   l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
   -- End enable trace
   ****/
   -- Start API body
   --
        -- Call Pre Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C' ) THEN
	 csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_CUHK.Expire_Item_Instance_Pre ..');
	 CSI_ITEM_INSTANCE_CUHK.Expire_Item_Instance_Pre
	  (
              p_api_version         => 1.0
	     ,p_commit              => fnd_api.g_false
	     ,p_init_msg_list       => fnd_api.g_false
	     ,p_validation_level    => fnd_api.g_valid_level_full
	     ,p_instance_rec        => p_instance_rec
	     ,p_expire_children     => fnd_api.g_false
	     ,p_txn_rec             => p_txn_rec
	     ,x_instance_id_lst     => x_instance_id_lst
	     ,x_return_status       => x_return_status
	     ,x_msg_count           => x_msg_count
	     ,x_msg_data            => x_msg_data
	  );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
		    x_msg_data := FND_MSG_PUB.GET
			    (  l_msg_index,
			       FND_API.G_FALSE );
		  csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Expire_Item_Instance_Pre API ');
		  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Expire Pre Customer');
         RAISE FND_API.G_EXC_ERROR;
   END;
   --
   -- Call Pre Vertical User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V' ) THEN
	 csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_VUHK.Expire_Item_Instance_Pre ..');
	 CSI_ITEM_INSTANCE_VUHK.Expire_Item_Instance_Pre
	  (
	      p_api_version         => 1.0
	     ,p_commit              => fnd_api.g_false
	     ,p_init_msg_list       => fnd_api.g_false
	     ,p_validation_level    => fnd_api.g_valid_level_full
	     ,p_instance_rec        => p_instance_rec
	     ,p_expire_children     => fnd_api.g_false
	     ,p_txn_rec             => p_txn_rec
	     ,x_instance_id_lst     => x_instance_id_lst
	     ,x_return_status       => x_return_status
	     ,x_msg_count           => x_msg_count
	     ,x_msg_data            => x_msg_data
	  );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
	       x_msg_data := FND_MSG_PUB.GET
			    (  l_msg_index,
			       FND_API.G_FALSE );
	       csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Expire_Item_Instance_Pre API ');
	       csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	       l_msg_index := l_msg_index + 1;
	       l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Expire Pre Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End PRE User Hooks
   --
   csi_item_instance_pvt.expire_item_instance
      (
        p_api_version      => p_api_version
        ,p_commit           => fnd_api.g_false
        ,p_init_msg_list    => p_init_msg_list
        ,p_validation_level => p_validation_level
        ,p_instance_rec     => p_instance_rec
        ,p_expire_children  => p_expire_children
        ,p_txn_rec          => p_txn_rec
        ,x_instance_id_lst  => x_instance_id_lst
        ,p_oks_txn_inst_tbl => px_oks_txn_inst_tbl
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
      );
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
                       x_msg_data := FND_MSG_PUB.GET(
                                        l_msg_index,
                                        FND_API.G_FALSE
                                                );
         csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
         l_msg_index := l_msg_index + 1;
         l_msg_count := l_msg_count - 1;
      END LOOP;
               RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   -- Call Post Customer User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
	 csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_CUHK.Expire_Item_Instance_Post ..');
	 CSI_ITEM_INSTANCE_CUHK.Expire_Item_Instance_Post
	  (
	      p_api_version         => 1.0
	     ,p_commit              => fnd_api.g_false
	     ,p_init_msg_list       => fnd_api.g_false
	     ,p_validation_level    => fnd_api.g_valid_level_full
	     ,p_instance_rec        => p_instance_rec
	     ,p_expire_children     => fnd_api.g_false
	     ,p_txn_rec             => p_txn_rec
	     ,x_instance_id_lst     => x_instance_id_lst
	     ,x_return_status       => x_return_status
	     ,x_msg_count           => x_msg_count
	     ,x_msg_data            => x_msg_data
	  );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
		    x_msg_data := FND_MSG_PUB.GET
			    (  l_msg_index,
			       FND_API.G_FALSE );
		  csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Expire_Item_Instance_Post API ');
		  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Expire Post Customer');
         RAISE FND_API.G_EXC_ERROR;
   END;
   --

   --
   -- Start att enhancements
  IF p_instance_rec.call_batch_validation<>fnd_api.g_false
  THEN
    IF p_instance_rec.instance_id IS NOT NULL AND
       p_instance_rec.instance_id <> fnd_api.g_miss_num
    THEN
       IF    ((p_instance_rec.config_inst_hdr_id IS NULL OR p_instance_rec.config_inst_hdr_id = fnd_api.g_miss_num)
         AND  (p_instance_rec.config_inst_item_id IS NULL OR p_instance_rec.config_inst_item_id = fnd_api.g_miss_num)
             )
       THEN
               l_no_config_keys:=TRUE;
		       csi_gen_utility_pvt.put_line( 'Config keys were not provided. So no batch validation will be performed');
       END IF;

      IF NOT l_no_config_keys
      THEN
       IF   (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_rev_num IS NOT NULL AND p_instance_rec.config_inst_rev_num <> fnd_api.g_miss_num)
       THEN

          IF NOT csi_item_instance_vld_pvt.is_unique_config_key ( p_config_inst_hdr_id  => p_instance_rec.config_inst_hdr_id
                                                                 ,p_config_inst_item_id => p_instance_rec.config_inst_item_id
                                                                 ,p_instance_id         => p_instance_rec.instance_id
                                                                 ,p_validation_mode     => 'UPDATE'
                                                                 )
          THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_KEY_EXISTS');
           FND_MSG_PUB.Add;
           RAISE fnd_api.g_exc_error;
          END IF;

          BEGIN
              SELECT component_instance_type
                    ,config_hdr_id
                    ,config_rev_nbr
              INTO   l_component_ins_type
                    ,l_config_hdr_id
                    ,l_config_rev_nbr
              FROM   cz_config_items_v
              WHERE  instance_hdr_id = p_instance_rec.config_inst_hdr_id
              AND    instance_rev_nbr = p_instance_rec.config_inst_rev_num
              AND    config_item_id = p_instance_rec.config_inst_item_id;
          EXCEPTION
              WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_NOT_IN_CZ');
               FND_MESSAGE.SET_TOKEN('INSTANCE_HDR_ID',p_instance_rec.config_inst_hdr_id);
               FND_MESSAGE.SET_TOKEN('INSTANCE_REV_NBR',p_instance_rec.config_inst_rev_num);
               FND_MESSAGE.SET_TOKEN('CONFIG_ITEM_ID',p_instance_rec.config_inst_item_id);

               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
          END;

          IF l_component_ins_type='I'
          THEN

            Csi_item_instance_vld_pvt.Call_batch_validate
              ( p_instance_rec    => p_instance_rec
               ,p_config_hdr_id   => l_config_hdr_id
               ,p_config_rev_nbr  => l_config_rev_nbr
               ,x_config_hdr_id   => l_batch_hdr_id
               ,x_config_rev_nbr  => l_batch_rev_nbr
               ,x_return_status   => x_return_status);

            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               FND_MESSAGE.SET_NAME('CSI','CSI_CONFIG_ERROR');
               FND_MSG_PUB.Add;
               csi_gen_utility_pvt.put_line('Call to batch validation has errored ');
               RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
            -- Commenting the following code in order to maintain status history.
       ELSIF (  (p_instance_rec.config_inst_hdr_id IS NULL OR p_instance_rec.config_inst_hdr_id = fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num))
          OR (  (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NULL OR p_instance_rec.config_inst_item_id = fnd_api.g_miss_num))
          OR (  (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
            AND (p_instance_rec.config_inst_rev_num IS NULL OR p_instance_rec.config_inst_rev_num = fnd_api.g_miss_num))
       THEN
		       FND_MESSAGE.SET_NAME('CSI','CSI_INVALID_CONFIG_COMB');
		       FND_MSG_PUB.Add;
		       RAISE fnd_api.g_exc_error;
       END IF;
      END IF;
    END IF;
  END IF;
-- End att enhancements
-- Adding new changes for bug 3799694
    IF   (p_instance_rec.config_inst_hdr_id IS NOT NULL AND p_instance_rec.config_inst_hdr_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_item_id IS NOT NULL AND p_instance_rec.config_inst_item_id <> fnd_api.g_miss_num)
        AND (p_instance_rec.config_inst_rev_num IS NOT NULL AND p_instance_rec.config_inst_rev_num <> fnd_api.g_miss_num)
    THEN
       FOR l_config_ins_key IN new_config_ins_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_rev_num)
       LOOP
          IF l_config_ins_key.has_failures ='1'
          OR nvl(l_config_ins_key.config_status,'0') <> '2'
          THEN
             FOR l_instance_key IN new_instance_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_item_id)
             LOOP
                l_config_instance_rec:=l_config_temp_rec;
                IF (l_instance_key.instance_id IS NOT NULL AND
                   l_instance_key.instance_id <> fnd_api.g_miss_num) AND
                   ( l_instance_key.config_valid_status IS NULL OR
                   (l_instance_key.config_valid_status IS NOT NULL AND
                   l_instance_key.config_valid_status <> '1'))
                THEN
                   l_config_instance_rec.instance_id:=l_instance_key.instance_id;
                   l_config_instance_rec.object_version_number:=l_instance_key.object_version_number;
                   l_config_instance_rec.config_valid_status:='1'; --INVALID
                   --
                   csi_item_instance_pvt.update_item_instance
                          (
                            p_api_version        => p_api_version
                           ,p_commit             => fnd_api.g_false
                           ,p_init_msg_list      => p_init_msg_list
                           ,p_validation_level   => p_validation_level
                           ,p_instance_rec       => l_config_instance_rec
                           ,p_txn_rec            => p_txn_rec
                           ,x_instance_id_lst    => l_instance_id_lst
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                           ,p_item_attribute_tbl => l_item_attribute_tbl
                           ,p_location_tbl       => l_location_tbl
                           ,p_generic_id_tbl     => l_generic_id_tbl
                           ,p_lookup_tbl         => l_lookup_tbl
                           ,p_ins_count_rec      => l_ins_count_rec
                           ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
                           ,p_child_inst_tbl     => px_child_inst_tbl
                         );

                   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                      l_msg_index := 1;
                      l_msg_count := x_msg_count;
                      WHILE l_msg_count > 0 LOOP
                             x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                             csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
                             csi_gen_utility_pvt.put_line( 'while updating config status');
                             csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                              l_msg_index := l_msg_index + 1;
                              l_msg_count := l_msg_count - 1;
                      END LOOP;
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                END IF;
             END LOOP;
          ELSE
             FOR l_instance_key IN new_instance_key(p_instance_rec.config_inst_hdr_id,p_instance_rec.config_inst_item_id)
             LOOP
                l_config_instance_rec:=l_config_temp_rec;
                IF (l_instance_key.instance_id IS NOT NULL AND
                    l_instance_key.instance_id <> fnd_api.g_miss_num) AND
                    ( l_instance_key.config_valid_status IS NULL OR
                    (l_instance_key.config_valid_status IS NOT NULL AND
                    l_instance_key.config_valid_status <> '0'))
                THEN
                   l_config_instance_rec.instance_id:=l_instance_key.instance_id;
                   l_config_instance_rec.object_version_number:=l_instance_key.object_version_number;
                   l_config_instance_rec.config_valid_status:='0'; --VALID
                   csi_item_instance_pvt.update_item_instance
                          (
                            p_api_version        => p_api_version
                           ,p_commit             => fnd_api.g_false
                           ,p_init_msg_list      => p_init_msg_list
                           ,p_validation_level   => p_validation_level
                           ,p_instance_rec       => l_config_instance_rec
                           ,p_txn_rec            => p_txn_rec
                           ,x_instance_id_lst    => l_instance_id_lst
                           ,x_return_status      => x_return_status
                           ,x_msg_count          => x_msg_count
                           ,x_msg_data           => x_msg_data
                           ,p_item_attribute_tbl => l_item_attribute_tbl
                           ,p_location_tbl       => l_location_tbl
                           ,p_generic_id_tbl     => l_generic_id_tbl
                           ,p_lookup_tbl         => l_lookup_tbl
                           ,p_ins_count_rec      => l_ins_count_rec
                           ,p_oks_txn_inst_tbl   => px_oks_txn_inst_tbl
                           ,p_child_inst_tbl     => px_child_inst_tbl
                         );

                   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                      l_msg_index := 1;
                      l_msg_count := x_msg_count;
                      WHILE l_msg_count > 0 LOOP
                             x_msg_data := FND_MSG_PUB.GET
                                    (  l_msg_index,
                                       FND_API.G_FALSE        );
                             csi_gen_utility_pvt.put_line( 'Error from UPDATE_ITEM_INSTANCE_PVT..');
                             csi_gen_utility_pvt.put_line( 'while updating config status');
                             csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                              l_msg_index := l_msg_index + 1;
                              l_msg_count := l_msg_count - 1;
                      END LOOP;
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                END IF;
             END LOOP;
          END IF;
       END LOOP;
    END IF;
    -- End addition of changes for bug 3799694
    IF px_oks_txn_inst_tbl.count > 0 THEN
       csi_gen_utility_pvt.dump_oks_txn_inst_tbl(px_oks_txn_inst_tbl);
       csi_gen_utility_pvt.put_line('Calling OKS Core API...');
       --
       IF p_txn_rec.transaction_type_id = 3 THEN
	  l_batch_id := p_txn_rec.source_header_ref_id;
	  l_batch_type := p_txn_rec.source_group_ref;
       ELSE
	  l_batch_id := NULL;
	  l_batch_type := NULL;
       END IF;
       --
       UPDATE CSI_TRANSACTIONS
       set contracts_invoked = 'Y'
       where transaction_id = p_txn_rec.transaction_id;
       --
       OKS_IBINT_PUB.IB_interface
	  (
	    P_Api_Version           =>  1.0,
	    P_init_msg_list         =>  p_init_msg_list,
	    P_single_txn_date_flag  =>  'Y',
	    P_Batch_type            =>  l_batch_type,
	    P_Batch_ID              =>  l_batch_id,
	    P_OKS_Txn_Inst_tbl      =>  px_oks_txn_inst_tbl,
	    x_return_status         =>  x_return_status,
	    x_msg_count             =>  x_msg_count,
	    x_msg_data              =>  x_msg_data
	 );
       --
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	  l_msg_index := 1;
	  l_msg_count := x_msg_count;
	  WHILE l_msg_count > 0 LOOP
	     x_msg_data := FND_MSG_PUB.GET
		     (  l_msg_index,
			FND_API.G_FALSE        );
	     csi_gen_utility_pvt.put_line( 'Error from OKS_IBINT_PUB.IB_interface..');
	     csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	     l_msg_index := l_msg_index + 1;
	     l_msg_count := l_msg_count - 1;
	  END LOOP;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- End of API body
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;
    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_flag = 'Y') THEN
       dbms_session.set_sql_trace(FALSE);
    END IF;
    -- End disable trace
    ****/
    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );
  -- Call Post Vertical User Hook
   BEGIN
      IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V' ) THEN
	 csi_gen_utility_pvt.put_line('Calling  CSI_ITEM_INSTANCE_VUHK.Expire_Item_Instance_Post ..');
	 CSI_ITEM_INSTANCE_VUHK.Expire_Item_Instance_Post
	  (
	      p_api_version         => 1.0
	     ,p_commit              => fnd_api.g_false
	     ,p_init_msg_list       => fnd_api.g_false
	     ,p_validation_level    => fnd_api.g_valid_level_full
	     ,p_instance_rec        => p_instance_rec
	     ,p_expire_children     => fnd_api.g_false
	     ,p_txn_rec             => p_txn_rec
	     ,x_instance_id_lst     => x_instance_id_lst
	     ,x_return_status       => x_return_status
	     ,x_msg_count           => x_msg_count
	     ,x_msg_data            => x_msg_data
	  );
	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    l_msg_index := 1;
	    l_msg_count := x_msg_count;
	    WHILE l_msg_count > 0 LOOP
		    x_msg_data := FND_MSG_PUB.GET
			    (  l_msg_index,
			       FND_API.G_FALSE );
		  csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_VUHK.Expire_Item_Instance_Post API ');
		  csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		  l_msg_index := l_msg_index + 1;
		  l_msg_count := l_msg_count - 1;
	    END LOOP;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         csi_gen_utility_pvt.put_line('ERROR FROM JTF_USR_HKS.Ok_to_execute API Expire Post Vertical');
         RAISE FND_API.G_EXC_ERROR;
   END;
   -- End of POST User Hooks

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO expire_item_instance;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO expire_item_instance;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (  p_encoded => FND_API.G_FALSE,
                 p_count     =>      x_msg_count,
                   p_data      =>      x_msg_data  );

        WHEN OTHERS THEN
                ROLLBACK TO expire_item_instance;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_encoded => FND_API.G_FALSE,
                 p_count    =>      x_msg_count,
                   p_data     =>      x_msg_data  );

END  expire_item_instance;

/*----------------------------------------------------*/
/* Procedure name: get_item_instances                 */
/* Description :   procedure to                       */
/*                 get an Item Instance               */
/*----------------------------------------------------*/

PROCEDURE get_item_instances
 (
      p_api_version          IN  NUMBER
     ,p_commit               IN  VARCHAR2
     ,p_init_msg_list        IN  VARCHAR2
     ,p_validation_level     IN  NUMBER
     ,p_instance_query_rec   IN  csi_datastructures_pub.instance_query_rec
     ,p_party_query_rec      IN  csi_datastructures_pub.party_query_rec
     ,p_account_query_rec    IN  csi_datastructures_pub.party_account_query_rec
     ,p_transaction_id       IN  NUMBER
     ,p_resolve_id_columns   IN  VARCHAR2
     ,p_active_instance_only IN  VARCHAR2
     ,x_instance_header_tbl  OUT NOCOPY csi_datastructures_pub.instance_header_tbl
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
    )IS

    l_api_name               CONSTANT VARCHAR2(30)   := 'GET_ITEM_INSTANCES';
    l_api_version            CONSTANT NUMBER                 := 1.0;
    l_debug_level            NUMBER;
    l_instance_rec           csi_datastructures_pub.instance_rec;
    l_descriptions_rec       csi_datastructures_pub.instance_rec;
    l_txn_rec                csi_datastructures_pub.transaction_rec;
    l_flag                   VARCHAR2(1)  :='N';
    l_error_code             VARCHAR2(10);
    l_return_status          NUMBER;
    l_msg_count              NUMBER;
    l_txn_id                 NUMBER;
    l_msg_index              NUMBER;
    l_line_count             NUMBER;
    l_cur_get_inst_rel       NUMBER;
    l_where_clause           VARCHAR2(20000) := '';
    l_instance_header_rec    csi_datastructures_pub.instance_header_rec;
    l_party_rec              csi_datastructures_pub.party_rec;
    l_party_account_rec      csi_datastructures_pub.party_account_rec;
    l_instance_id_list       VARCHAR2(2000):= '';
    l_instance_id            NUMBER;
    l_rows_processed         NUMBER;
    l_count                  NUMBER := 0;
    l_select_stmt            VARCHAR2(20000) := '';


 BEGIN
        -- Standard Start of API savepoint
        --SAVEPOINT       get_item_instances;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                    p_api_version,
                                                l_api_name       ,
                                                G_PKG_NAME       )
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
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
         csi_gen_utility_pvt.put_line( 'get_item_instances');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
                   csi_gen_utility_pvt.put_line( 'get_item_instances'          ||
                                                 p_api_version           ||'-'||
                                                 p_commit                ||'-'||
                                                 p_init_msg_list         ||'-'||
                                                 p_validation_level            );
    --dump the query records into a log file
    csi_gen_utility_pvt.dump_instance_query_rec(p_instance_query_rec);
    csi_gen_utility_pvt.dump_party_query_rec(p_party_query_rec);
    csi_gen_utility_pvt.dump_account_query_rec(p_account_query_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
    -- End enable trace
    ****/
    -- Start API body

    IF   (p_party_query_rec.instance_party_id                       =  FND_API.G_MISS_NUM)
          AND (p_party_query_rec.instance_id                        =  FND_API.G_MISS_NUM)
          AND (p_party_query_rec.party_id                           =  FND_API.G_MISS_NUM)
          AND (p_party_query_rec.relationship_type_code             =  FND_API.G_MISS_CHAR)
          AND (p_account_query_rec.ip_account_id                    =  FND_API.G_MISS_NUM)
          AND (p_account_query_rec.instance_party_id                =  FND_API.G_MISS_NUM)
          AND (p_account_query_rec.party_account_id                 =  FND_API.G_MISS_NUM)
          AND (p_account_query_rec.relationship_type_code           =  FND_API.G_MISS_CHAR)
          AND (p_transaction_id IS NULL)
          AND (p_instance_query_rec.INSTANCE_ID                     =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.INVENTORY_ITEM_ID               =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.INVENTORY_REVISION              =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.INV_MASTER_ORGANIZATION_ID      =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.SERIAL_NUMBER                   =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.LOT_NUMBER                      =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.UNIT_OF_MEASURE                 =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.INSTANCE_CONDITION_ID           =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.INSTANCE_STATUS_ID              =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.SYSTEM_ID                       =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.INSTANCE_TYPE_CODE              =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.LOCATION_TYPE_CODE              =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.LOCATION_ID                     =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.INV_ORGANIZATION_ID             =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.INV_SUBINVENTORY_NAME           =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.INV_LOCATOR_ID                  =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.PA_PROJECT_ID                   =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.PA_PROJECT_TASK_ID              =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.IN_TRANSIT_ORDER_LINE_ID        =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.WIP_JOB_ID                      =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.PO_ORDER_LINE_ID                =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.LAST_OE_ORDER_LINE_ID           =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.LAST_OE_RMA_LINE_ID             =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.LAST_PO_PO_LINE_ID              =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.LAST_OE_PO_NUMBER               =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.LAST_WIP_JOB_ID                 =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.LAST_PA_PROJECT_ID              =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.LAST_PA_TASK_ID                 =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.LAST_OE_AGREEMENT_ID            =  FND_API.G_MISS_NUM)
          AND (p_instance_query_rec.INSTALL_DATE                    =  FND_API.G_MISS_DATE)
          AND (p_instance_query_rec.MANUALLY_CREATED_FLAG           =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.RETURN_BY_DATE                  =  FND_API.G_MISS_DATE)
          AND (p_instance_query_rec.ACTUAL_RETURN_DATE              =  FND_API.G_MISS_DATE)
          AND (p_instance_query_rec.CONTRACT_NUMBER                 =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.INSTANCE_USAGE_CODE             =  FND_API.G_MISS_CHAR)
          AND (p_instance_query_rec.CONFIG_INST_HDR_ID              =  FND_API.G_MISS_NUM)  -- sguthiva added for att
          AND (p_instance_query_rec.CONFIG_INST_REV_NUM             =  FND_API.G_MISS_NUM)  -- sguthiva added for att
          AND (p_instance_query_rec.CONFIG_INST_ITEM_ID             =  FND_API.G_MISS_NUM)  -- sguthiva added for att
          AND (p_instance_query_rec.INSTANCE_DESCRIPTION            =  FND_API.G_MISS_CHAR) -- sguthiva added for att
          AND (p_instance_query_rec.OPERATIONAL_STATUS_CODE         =  FND_API.G_MISS_CHAR) -- Addition of columns for FA Integration
     THEN

           FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
           FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;

     END IF;

     -- Generate the where clause
     csi_item_instance_pvt.Gen_Inst_Where_Clause
       (    p_instance_query_rec    =>  p_instance_query_rec,
            p_party_query_rec       =>  p_party_query_rec,
            p_pty_acct_query_rec    =>  p_account_query_rec,
            p_transaction_id        =>  p_transaction_id,
            x_select_stmt           =>  l_select_stmt ,
            p_active_instance_only  =>  p_active_instance_only);

     -- Open the cursor
     l_cur_get_inst_rel := dbms_sql.open_cursor;

     --Parse the select statement
     dbms_sql.parse(l_cur_get_inst_rel, l_select_stmt , dbms_sql.native);

     -- Bind the variables
     csi_item_instance_pvt.Bind_inst_variable(p_instance_query_rec,
                                                p_party_query_rec,
                                                p_account_query_rec,
                                                p_transaction_id,
                                                l_cur_get_inst_rel);

     -- Define output variables
     csi_item_instance_pvt.Define_Inst_Columns(l_cur_get_inst_rel,
                                               p_instance_query_rec );

     -- execute the select statement
     l_rows_processed := dbms_sql.execute(l_cur_get_inst_rel);
     -- srramakr Bug # 2636868. Construct_inst_header_rec is called within the loop and
     -- x_instance_header_tbl is constructed. This is basically to l_instance_id_list
     -- with the bind variable p_instance_id.
     LOOP
       EXIT WHEN DBMS_SQL.FETCH_ROWS(l_cur_get_inst_rel) = 0;
       csi_item_instance_pvt.Get_Inst_Column_Values(l_cur_get_inst_rel,
                                                    l_instance_id  );
       l_count := l_count + 1;
       csi_item_instance_pvt.Construct_inst_header_rec(l_instance_id,
                                                       x_instance_header_tbl);
      /***** COMMENTED FOR Bug # 2636868 IF l_instance_id_list IS NULL THEN
               l_instance_id_list := to_char(l_instance_id);
             ELSE
               l_instance_id_list := l_instance_id_list||' , '||to_char(l_instance_id);
             END IF; *****/
     END LOOP;

   -- Close the cursor
   DBMS_SQL.CLOSE_CURSOR(l_cur_get_inst_rel);

  /***** COMMENTED FOR Bug # 2636868 IF l_instance_id_list IS NOT NULL THEN
         csi_item_instance_pvt.Construct_inst_header_rec(l_instance_id_list,
                                                         x_instance_header_tbl);
   END IF; *****/
   --
   -- srramakr Get_Item_Instances is a frequently called API. Unless there is a requirement,
   -- no need to get the version label for each of the item instance retreived.
   -- If there is a need, call csi_ietm_instance_vld_pvt.Get_Version_label by passing the instance_id
   -- and p_time_stamp as null (because this routine gets the current image of item instance).
   -- Resolve_id routine has already been modified to get the version label meaning.
   --
   IF p_resolve_id_columns = fnd_api.g_true THEN
      IF x_instance_header_tbl.count > 0 THEN
         csi_item_instance_pvt.resolve_id_columns
                            (p_instance_header_tbl      =>   x_instance_header_tbl);

  -- Added by sguthiva for att enhancements
       csi_Item_Instance_Vld_pvt.get_link_locations
                            (p_instance_header_tbl => x_instance_header_tbl,
                             x_return_status       => x_return_status
                            );
       IF NOT x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	  RAISE FND_API.G_EXC_ERROR;
       END IF;
  -- End addition by sguthiva for att enhancements

      END IF;
   END IF;

   -- End of API body
   -- Standard check of p_commit.
   /*
   IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
   END IF;
   */

   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and disable the trace
   IF (l_flag = 'Y') THEN
          dbms_session.set_sql_trace(FALSE);
   END IF;
   -- End disable trace
   ****/

   -- Standard call to get message count and if count is  get message info.
   FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
         p_data         =>      x_msg_data
                );

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
              --  ROLLBACK TO get_item_instances;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              --  ROLLBACK TO get_item_instances;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (  p_encoded => FND_API.G_FALSE,
                 p_count     =>      x_msg_count,
                   p_data      =>      x_msg_data  );

        WHEN OTHERS THEN
             --   ROLLBACK TO get_item_instances;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_encoded => FND_API.G_FALSE,
                 p_count    =>      x_msg_count,
                   p_data     =>      x_msg_data  );

END get_item_instances;

/*----------------------------------------------------*/
/* Procedure name: get_item_instance_details          */
/* Description :   procedure to                       */
/*                 get an Item Instance details       */
/*----------------------------------------------------*/

 PROCEDURE get_item_instance_details
 (
      p_api_version              IN      NUMBER
     ,p_commit                   IN      VARCHAR2
     ,p_init_msg_list            IN      VARCHAR2
     ,p_validation_level         IN      NUMBER
     ,p_instance_rec             IN OUT  NOCOPY csi_datastructures_pub.instance_header_rec
     ,p_get_parties              IN      VARCHAR2
     ,p_party_header_tbl         OUT     NOCOPY csi_datastructures_pub.party_header_tbl
     ,p_get_accounts             IN      VARCHAR2
     ,p_account_header_tbl       OUT     NOCOPY csi_datastructures_pub.party_account_header_tbl
     ,p_get_org_assignments      IN      VARCHAR2
     ,p_org_header_tbl           OUT     NOCOPY csi_datastructures_pub.org_units_header_tbl
     ,p_get_pricing_attribs      IN      VARCHAR2
     ,p_pricing_attrib_tbl       OUT     NOCOPY csi_datastructures_pub.pricing_attribs_tbl
     ,p_get_ext_attribs          IN      VARCHAR2
     ,p_ext_attrib_tbl           OUT     NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
     ,p_ext_attrib_def_tbl       OUT     NOCOPY csi_datastructures_pub.extend_attrib_tbl --added
     ,p_get_asset_assignments    IN      VARCHAR2
     ,p_asset_header_tbl         OUT     NOCOPY csi_datastructures_pub.instance_asset_header_tbl
     ,p_resolve_id_columns       IN      VARCHAR2
     ,p_time_stamp               IN      DATE
     ,x_return_status            OUT     NOCOPY VARCHAR2
     ,x_msg_count                OUT     NOCOPY NUMBER
     ,x_msg_data                 OUT     NOCOPY VARCHAR2
)
 IS
     l_api_name                 CONSTANT VARCHAR2(30)   := 'GET_ITEM_INSTANCE_DETAILS';
     l_api_version              CONSTANT NUMBER         := 1.0;
     l_debug_level                       NUMBER;
     l_party_query_rec          csi_datastructures_pub.party_query_rec;
     l_account_query_rec        csi_datastructures_pub.party_account_query_rec;
     l_org_unit_query_rec       csi_datastructures_pub.organization_unit_query_rec;
     l_pricing_attrib_query_rec csi_datastructures_pub.pricing_attribs_query_rec;
     l_extend_attrib_query_rec  csi_datastructures_pub.extend_attrib_query_rec;
     l_instance_asset_query_rec csi_datastructures_pub.instance_asset_query_rec;
     l_version_label_query_rec  csi_datastructures_pub.version_label_query_rec;
     l_account_header_tbl       csi_datastructures_pub.party_account_header_tbl;
     l_acct_header_row          NUMBER;
     l_flag                     VARCHAR2(1)  :='N';
     l_msg_data                 VARCHAR2(100);
     l_msg_count                NUMBER;
     l_msg_index                NUMBER;
     l_cur_get_instance_rel     NUMBER;
     l_where_clause             VARCHAR2(20000)         := '';
     l_instance_rec             csi_datastructures_pub.instance_header_rec;
     l_instance_header_tbl      csi_datastructures_pub.instance_header_tbl;
     l_rows_processed           NUMBER;
     l_count                    NUMBER                  := 0;
     l_instance_query_rec       csi_datastructures_pub.instance_query_rec;
     --Modified the select for R12 build to resolve column sequencing issue in table--
     l_select_stmt              VARCHAR2(20000) := ' select instance_id,instance_number, external_reference, '||
                                'inventory_item_id,inventory_revision,inv_master_organization_id,serial_number, '||
                                'mfg_serial_number_flag,lot_number,quantity,unit_of_measure,accounting_class_code, '||
                                'instance_condition_id,instance_status_id,customer_view_flag,merchant_view_flag, '||
                                'sellable_flag,system_id,instance_type_code,active_start_date,active_end_date, '||
                                'location_type_code,location_id,inv_organization_id,inv_subinventory_name,inv_locator_id, '||
                                'pa_project_id,pa_project_task_id,in_transit_order_line_id,wip_job_id,po_order_line_id, '||
                                'last_oe_order_line_id,last_oe_rma_line_id,last_po_po_line_id,last_oe_po_number, '||
                                'last_wip_job_id,last_pa_project_id,last_pa_task_id,last_oe_agreement_id,install_date, '||
                                'manually_created_flag,return_by_date,actual_return_date,creation_complete_flag, '||
                                'completeness_flag,context,attribute1,attribute2,attribute3,attribute4,attribute5, '||
                                'attribute6,attribute7,attribute8,attribute9,attribute10,attribute11,attribute12, '||
                                'attribute13,attribute14,attribute15,object_version_number,last_txn_line_detail_id, '||
                                'install_location_type_code,install_location_id,instance_usage_code,last_vld_organization_id, '||
                                'config_inst_hdr_id,config_inst_rev_num,config_inst_item_id,config_valid_status, '||
                                'instance_description,network_asset_flag,maintainable_flag,pn_location_id, '||
                                'asset_criticality_code,category_id,equipment_gen_object_id,instantiation_flag, '||
                                'linear_location_id,operational_log_flag,checkin_status,supplier_warranty_exp_date,attribute16, '||
                                'attribute17,attribute18,attribute19,attribute20,attribute21,attribute22,attribute23, '||
                                'attribute24,attribute25,attribute26,attribute27,attribute28,attribute29,attribute30, '||
                                 -- Addition of columns for FA Integration
                                'purchase_unit_price, purchase_currency_code, payables_unit_price, payables_currency_code, '||
                                'sales_unit_price, sales_currency_code, operational_status_code '||
                                 -- End addition of columns for FA Integration
                                'from csi_item_instances where instance_id = :instance_id ';
     l_last_purge_date          DATE;
     l_time_stamp               DATE;

BEGIN

        -- Standard Start of API savepoint
       -- SAVEPOINT       get_item_instance_details;


        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                    p_api_version,
                                                l_api_name       ,
                                                G_PKG_NAME       )
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
        l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If debug_level = 1 then dump the procedure name
        IF (l_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_item_instance_details');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line( 'get_item_instance_details:'  ||
                                          p_api_version           ||'-'||
                                                          p_commit                ||'-'||
                                                          p_init_msg_list         ||'-'||
                                          p_validation_level            );
        --dump the queried records into a log file
        csi_gen_utility_pvt.dump_instance_header_rec(p_instance_rec);
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/
        -- Start API body

       -- Open the cursor
       l_cur_get_instance_rel := dbms_sql.open_cursor;

       --Parse the select statement
       dbms_sql.parse(l_cur_get_instance_rel, l_select_stmt , dbms_sql.native);

       -- Bind the variables
       csi_item_instance_pvt.Bind_instance_variable(p_instance_rec,
                                                    l_cur_get_instance_rel);

       -- Define output variables
       csi_item_instance_pvt.Define_Instance_Columns(l_cur_get_instance_rel);

       -- execute the select statement
       l_rows_processed := dbms_sql.execute(l_cur_get_instance_rel);

       LOOP
       EXIT WHEN DBMS_SQL.FETCH_ROWS(l_cur_get_instance_rel) = 0;
             csi_item_instance_pvt.Get_Instance_Col_Values(l_cur_get_instance_rel,
                                                           l_instance_rec
                                                           );
             p_instance_rec := l_instance_rec;
       END LOOP;

       -- Close the cursor
       DBMS_SQL.CLOSE_CURSOR(l_cur_get_instance_rel);

      --
      -- Get the last purge date from csi_item_instances table
      --
      BEGIN
        SELECT last_purge_date
        INTO   l_last_purge_date
        FROM   CSI_ITEM_INSTANCES
        WHERE  instance_id = p_instance_rec.instance_id;
      EXCEPTION
        WHEN no_data_found THEN
             null;
        WHEN others THEN
             null;
      END;

      l_time_stamp := p_time_stamp;
      --call to get the history data
      IF ((p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE))
      THEN
          IF ((l_last_purge_date IS NOT NULL) AND (p_time_stamp <= l_last_purge_date))
          THEN
               -- If the user is requesting the instance history before the purge date
               -- then display a warning message
                  csi_gen_utility_pvt.put_line('Warning! History for this entity has already been purged for the datetime stamp passed. ' ||
                  'Please provide a valid datetime stamp.');
                  FND_MESSAGE.Set_Name('CSI', 'CSI_API_HIST_AFTER_PURGE_REQ');
                  FND_MESSAGE.Set_Token('LAST_PURGE_DATE', l_last_purge_date);
                  FND_MSG_PUB.ADD;
           END IF;
           IF     (p_time_stamp <= sysdate) THEN
               -- construct from the history if the p_time_stamp
               -- is < than sysdate
                  csi_item_instance_pvt.Construct_inst_from_hist(p_instance_rec, l_time_stamp);
           ELSE
                  FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_HIST_PARAMS');
                  FND_MSG_PUB.ADD;
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
      END IF;
      --
      -- srramakr Bug 4558115
      p_instance_rec.version_label := csi_item_instance_vld_pvt.Get_Version_Label
                                             ( p_instance_id      =>  p_instance_rec.instance_id,
                                               p_time_stamp       =>  p_time_stamp
                                             );
      --Resolve the id columns, get the corresponding descriptions for the passed ids

      IF p_resolve_id_columns = fnd_api.g_true THEN

         l_instance_header_tbl(1) := p_instance_rec;

              csi_item_instance_pvt.resolve_id_columns
                            (p_instance_header_tbl      =>   l_instance_header_tbl);

                 p_instance_rec := l_instance_header_tbl(1);
      END IF;

      IF p_get_parties = fnd_api.g_true THEN

        l_party_query_rec.instance_id := p_instance_rec.instance_id;
        csi_party_relationships_pub.get_inst_party_relationships
         (
          p_api_version             => p_api_version
         ,p_commit                  => fnd_api.g_false
         ,p_init_msg_list           => fnd_api.g_false
         ,p_validation_level        => fnd_api.g_valid_level_full
         ,p_party_query_rec         => l_party_query_rec
         ,p_resolve_id_columns      => p_resolve_id_columns --fnd_api.g_true
         ,p_time_stamp              => l_time_stamp
         ,x_party_header_tbl        => p_party_header_tbl
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
         );
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from csi_party_relationships_pub.get_inst_party_relationships.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

      IF p_get_accounts = fnd_api.g_true AND
         p_party_header_tbl.count > 0 THEN -- without this condition if p_party_header_tbl is blindly
                                           -- accessed, we will get an unhandled exception.

       FOR tab_row IN p_party_header_tbl.FIRST..p_party_header_tbl.LAST LOOP
          IF p_party_header_tbl.EXISTS(tab_row) THEN
             l_account_query_rec.instance_party_id  := p_party_header_tbl(tab_row).instance_party_id;
          END IF;

         csi_party_relationships_pub.get_inst_party_accounts
         (
          p_api_version             => p_api_version
         ,p_commit                  => fnd_api.g_false
         ,p_init_msg_list           => fnd_api.g_false
         ,p_validation_level        => fnd_api.g_valid_level_full
         ,p_account_query_rec       => l_account_query_rec
         ,p_resolve_id_columns      => p_resolve_id_columns --fnd_api.g_true
         ,p_time_stamp              => l_time_stamp
         ,x_account_header_tbl      => l_account_header_tbl
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data         );
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from csi_party_relationships_pub.get_inst_party_accounts.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
            IF (l_account_header_tbl.count > 0) THEN
                IF (p_account_header_tbl.count = 0) THEN
                  l_acct_header_row := 1;
                ELSE
                  l_acct_header_row := p_account_header_tbl.LAST + 1;
                END IF;

                FOR acct_header_row  IN l_account_header_tbl.FIRST .. l_account_header_tbl.LAST
                LOOP
                      IF l_account_header_tbl.EXISTS(acct_header_row) THEN
                         p_account_header_tbl(l_acct_header_row) := l_account_header_tbl(acct_header_row);
                         l_acct_header_row := l_acct_header_row  + 1;
                      END IF;
                END LOOP;
             END IF;

       END LOOP;
      END IF;

      IF p_get_org_assignments = fnd_api.g_true THEN

       l_org_unit_query_rec.instance_id := p_instance_rec.instance_id;
       csi_organization_unit_pub.get_organization_unit
         (
          p_api_version             => p_api_version
         ,p_commit                  => fnd_api.g_false
         ,p_init_msg_list           => fnd_api.g_false
         ,p_validation_level        => fnd_api.g_valid_level_full
         ,p_ou_query_rec            => l_org_unit_query_rec
         ,p_resolve_id_columns      => p_resolve_id_columns --fnd_api.g_true
         ,p_time_stamp              => l_time_stamp
         ,x_org_unit_tbl            => p_org_header_tbl
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
         );
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from csi_organization_unit_pub.get_organization_unit.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

      IF p_get_pricing_attribs = fnd_api.g_true THEN

       l_pricing_attrib_query_rec.instance_id := p_instance_rec.instance_id;
       csi_pricing_attribs_pub.get_pricing_attribs
         (
          p_api_version                 => p_api_version
         ,p_commit                      => fnd_api.g_false
         ,p_init_msg_list               => fnd_api.g_false
         ,p_validation_level            => fnd_api.g_valid_level_full
         ,p_pricing_attribs_query_rec   => l_pricing_attrib_query_rec
         ,p_time_stamp                  => l_time_stamp
         ,x_pricing_attribs_tbl         => p_pricing_attrib_tbl
         ,x_return_status               => x_return_status
         ,x_msg_count                   => x_msg_count
         ,x_msg_data                    => x_msg_data
         );
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from csi_pricing_attribs_pub.get_pricing_attribs.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

      IF p_get_ext_attribs = fnd_api.g_true THEN

       l_extend_attrib_query_rec.instance_id := p_instance_rec.instance_id;
        get_extended_attrib_values
        (
          p_api_version                 => p_api_version
         ,p_commit                      => fnd_api.g_false
         ,p_init_msg_list               => fnd_api.g_false
         ,p_validation_level            => fnd_api.g_valid_level_full
         ,p_ext_attribs_query_rec       => l_extend_attrib_query_rec
         ,p_time_stamp                  => l_time_stamp
         ,x_ext_attrib_tbl              => p_ext_attrib_tbl
         ,x_ext_attrib_def_tbl          => p_ext_attrib_def_tbl  -- added
         ,x_return_status               => x_return_status
         ,x_msg_count                   => x_msg_count
         ,x_msg_data                    => x_msg_data
        );
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from get_extended_attrib_values.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

      IF p_get_asset_assignments = fnd_api.g_true THEN

       l_instance_asset_query_rec.instance_id := p_instance_rec.instance_id;
        csi_asset_pvt.get_instance_assets
        (
          p_api_version                 => p_api_version
         ,p_commit                      => fnd_api.g_false
         ,p_init_msg_list               => fnd_api.g_false
         ,p_validation_level            => fnd_api.g_valid_level_full
         ,p_instance_asset_query_rec    => l_instance_asset_query_rec
         ,p_resolve_id_columns          => p_resolve_id_columns --fnd_api.g_true
         ,p_time_stamp                  => l_time_stamp
         ,x_instance_asset_tbl          => p_asset_header_tbl
         ,x_return_status               => x_return_status
         ,x_msg_count                   => x_msg_count
         ,x_msg_data                    => x_msg_data
        );
       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
         WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                        FND_API.G_FALSE );
          csi_gen_utility_pvt.put_line( ' Error from csi_asset_pvt.get_instance_assets.. ');
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              l_msg_index := l_msg_index + 1;
              l_msg_count := l_msg_count - 1;
             END LOOP;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

        -- End of API body

    -- Standard check of p_commit.
    /*
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;
        */

   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and disable the trace
    IF (l_flag = 'Y') THEN
          dbms_session.set_sql_trace(FALSE);
    END IF;
    -- End disable trace
    ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
         p_data         =>      x_msg_data
                );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

               -- ROLLBACK TO get_item_instance_details;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

               -- ROLLBACK TO get_item_instance_details;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
    WHEN OTHERS THEN

        IF DBMS_SQL.IS_OPEN(l_cur_get_instance_rel) THEN
           DBMS_SQL.CLOSE_CURSOR(l_cur_get_instance_rel);
        END IF;
       -- ROLLBACK TO get_item_instance_details;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME  ,
                l_api_name  );
          END IF;
              FND_MSG_PUB.Count_And_Get
              ( p_encoded => FND_API.G_FALSE,
                 p_count     =>      x_msg_count,
                p_data      =>      x_msg_data  );

END get_item_instance_details;

/*----------------------------------------------------*/
/* Pocedure name:  get_version_label                  */
/* Description :   procedure for creating             */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE get_version_labels
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2
     ,p_init_msg_list           IN  VARCHAR2
     ,p_validation_level        IN  NUMBER
     ,p_version_label_query_rec IN  csi_datastructures_pub.version_label_query_rec
     ,p_time_stamp              IN  DATE
     ,x_version_label_tbl       OUT NOCOPY csi_datastructures_pub.version_label_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
    )IS

      l_api_name                CONSTANT VARCHAR2(30)   := 'GET_VERSION_LABEL';
      l_api_version             CONSTANT NUMBER             := 1.0;
      l_debug_level             NUMBER;
      l_version_label_id    NUMBER;
      l_version_label_tbl   csi_datastructures_pub.version_label_tbl;
      l_line_count          NUMBER;
      l_msg_index           NUMBER;
      l_count               NUMBER := 0;
      l_where_clause        VARCHAR2(2000) ;
      l_get_ver_cursor_id   NUMBER ;
      l_flag                VARCHAR2(1)              :='N';
      l_rows_processed      NUMBER ;
      l_version_label_rec   csi_datastructures_pub.version_label_rec;
      l_select_stmt         VARCHAR2(20000) := ' SELECT * FROM CSI_I_VERSION_LABELS  ';

BEGIN
        -- Standard Start of API savepoint
        -- SAVEPOINT  get_version_label_pub;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                                    p_api_version       ,
                                                l_api_name              ,
                                                G_PKG_NAME              )
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
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
         csi_gen_utility_pvt.put_line( 'get_version_label');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'get_version_label:'   ||
                                                                     p_api_version         ||'-'||
                                                                 p_commit              ||'-'||
                                                                     p_init_msg_list       ||'-'||
                                     p_validation_level          );

    END IF;

     /***** srramakr commented for bug # 3304439
     -- Check for the profile option and enable trace
     l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
     -- End enable trace
     ****/

    -- Start API body
    IF    (p_version_label_query_rec.version_label_id  = FND_API.G_MISS_NUM)
     AND  (p_version_label_query_rec.instance_id       = FND_API.G_MISS_NUM)
     AND  (p_version_label_query_rec.version_label     = FND_API.G_MISS_CHAR)
     AND  (p_version_label_query_rec.date_time_stamp = FND_API.G_MISS_DATE) THEN

           FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
           FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

       -- Generate the where clause
       csi_item_instance_pvt.Gen_Ver_Where_Clause
       (   p_ver_label_query_rec  =>  p_version_label_query_rec,
           x_where_clause         =>  l_where_clause    );

       -- Build the select statement
       l_select_stmt := l_select_stmt || ' where '||l_where_clause;

       -- Open the cursor
       l_get_ver_cursor_id := dbms_sql.open_cursor;

       --Parse the select statement
       dbms_sql.parse(l_get_ver_cursor_id, l_select_stmt , dbms_sql.native);

       -- Bind the variables
       csi_item_instance_pvt.Bind_Ver_variable(p_version_label_query_rec, l_get_ver_cursor_id);

       -- Define output variables
       csi_item_instance_pvt.Define_Ver_Columns(l_get_ver_cursor_id);

        -- execute the select statement
       l_rows_processed := dbms_sql.execute(l_get_ver_cursor_id);

    LOOP
       EXIT WHEN DBMS_SQL.FETCH_ROWS(l_get_ver_cursor_id) = 0;
             csi_item_instance_pvt.Get_Ver_Column_Values(l_get_ver_cursor_id, l_version_label_rec);
             l_count := l_count + 1;
             x_version_label_tbl(l_count) := l_version_label_rec;
    END LOOP;

    -- Close the cursor
    DBMS_SQL.CLOSE_CURSOR(l_get_ver_cursor_id);

     IF p_time_stamp < sysdate THEN
          csi_item_instance_pvt.Construct_ver_from_hist(x_version_label_tbl, p_time_stamp);
     ELSE
      If (p_time_stamp <> fnd_api.g_miss_date and p_time_stamp > sysdate) THEN
            FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_HIST_PARAMS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;

        --
        -- End of API body

        -- Standard check of p_commit.
        /*
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;
        */

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_flag = 'Y') THEN
        dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
               -- ROLLBACK TO get_version_label_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               -- ROLLBACK TO get_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data );
        WHEN OTHERS THEN
               -- ROLLBACK TO get_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data);
END get_version_labels;

/*----------------------------------------------------*/
/* Pocedure name: Create_version_label                */
/* Description :   procedure for creating             */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE create_version_label
 (    p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2
     ,p_init_msg_list       IN     VARCHAR2
     ,p_validation_level    IN     NUMBER
     ,p_version_label_tbl   IN OUT NOCOPY csi_datastructures_pub.version_label_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT    NOCOPY VARCHAR2
     ,x_msg_count           OUT    NOCOPY NUMBER
     ,x_msg_data            OUT    NOCOPY VARCHAR2
 ) IS
      l_api_name           CONSTANT VARCHAR2(30)   := 'CREATE_VERSION_LABEL';
      l_api_version        CONSTANT NUMBER                 := 1.0                   ;
      l_debug_level             NUMBER                             ;
      l_line_count              NUMBER                                  ;
      l_version_label_rec       csi_datastructures_pub.version_label_rec;
      l_msg_index               NUMBER                                  ;
      l_flag                    VARCHAR2(1)  :='N'                      ;
      l_msg_count               NUMBER;
BEGIN

    -- Standard Start of API savepoint
        SAVEPOINT  create_version_label_pub;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version  ,
                                                     p_api_version  ,
                                                 l_api_name     ,
                                                 G_PKG_NAME     )
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
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
         csi_gen_utility_pvt.put_line( 'create_version_label');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'create_version_label:'||
                                                                   p_api_version           ||'-'||
                                                               p_commit                ||'-'||
                                                               p_init_msg_list         ||'-'||
                                   p_validation_level           );

        -- Dump the records in the log file
        csi_gen_utility_pvt.dump_version_label_tbl(p_version_label_tbl);
        csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
    -- End enable trace
    ****/

    -- Start API body
    --
    IF p_version_label_tbl.count > 0 THEN
          FOR l_count IN p_version_label_tbl.FIRST..p_version_label_tbl.LAST
      LOOP
         IF p_version_label_tbl.EXISTS(l_count) THEN

            csi_item_instance_pvt.create_version_label
           (  p_api_version         => p_api_version
             ,p_commit              => p_commit
             ,p_init_msg_list       => p_init_msg_list
             ,p_validation_level    => p_validation_level
             ,p_version_label_rec   => p_version_label_tbl(l_count)
             ,p_txn_rec             => p_txn_rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data       );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                      l_msg_index := 1;
              l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                            x_msg_data := FND_MSG_PUB.GET(
                                              l_msg_index,
                                              FND_API.G_FALSE);
                        csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                            l_msg_count := l_msg_count - 1;
                  END LOOP;
                ROLLBACK TO create_version_label_pub;
              RETURN;
           END IF;
         END IF;
      END LOOP;
    END IF;
    --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_flag = 'Y') THEN
         dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
         p_data         =>      x_msg_data      );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_version_label_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                        FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data );
        WHEN OTHERS THEN
                ROLLBACK TO create_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
        FND_MSG_PUB.Add_Exc_Msg
                   ( G_PKG_NAME, l_api_name );
                END IF;
        FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count =>      x_msg_count,
                        p_data  =>      x_msg_data);
END create_version_label;

/*----------------------------------------------------*/
/* Procedure name: Update_version_label               */
/* Description :   procedure for Update               */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE update_version_label
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2
     ,p_init_msg_list               IN     VARCHAR2
     ,p_validation_level            IN     NUMBER
     ,p_version_label_tbl           IN     csi_datastructures_pub.version_label_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT    NOCOPY VARCHAR2
     ,x_msg_count                   OUT    NOCOPY NUMBER
     ,x_msg_data                    OUT    NOCOPY VARCHAR2
   ) IS

   l_api_name       CONSTANT VARCHAR2(30)   := 'UPDATE_VERSION_LABEL';
   l_api_version        CONSTANT NUMBER             := 1.0;
   l_debug_level             NUMBER;
   l_version_label_rec       csi_datastructures_pub.version_label_rec;
   l_msg_index               NUMBER;
   l_line_count              NUMBER ;
   l_flag                    VARCHAR2(1)    :='N';
   l_msg_count               NUMBER;

BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT  update_version_label_pub;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                                    p_api_version       ,
                                                l_api_name              ,
                                                G_PKG_NAME              )
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
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'update_version_label');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'update_version_label:'||
                                                                 p_api_version           ||'-'||
                                                             p_commit                ||'-'||
                                                                 p_init_msg_list               );

         -- Dump the records in the log file
         csi_gen_utility_pvt.dump_version_label_tbl(p_version_label_tbl);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

        END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
    -- End enable trace
    ****/
    -- Start API body
        --
    IF p_version_label_tbl.count > 0 THEN
       FOR l_count IN p_version_label_tbl.FIRST..p_version_label_tbl.LAST
       LOOP
          IF p_version_label_tbl.EXISTS(l_count) THEN

             csi_item_instance_pvt.update_version_label
             ( p_api_version             => p_api_version
              ,p_commit                  => p_commit
              ,p_init_msg_list           => p_init_msg_list
              ,p_validation_level        => p_validation_level
              ,p_version_label_rec       => p_version_label_tbl(l_count)
              ,p_txn_rec                 => p_txn_rec
              ,x_return_status           => x_return_status
              ,x_msg_count               => x_msg_count
              ,x_msg_data                => x_msg_data     );


              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                     l_msg_index := 1;
                 l_msg_count := x_msg_count;
                     WHILE l_msg_count > 0 LOOP
                           x_msg_data := FND_MSG_PUB.GET(
                                                         l_msg_index,
                                                         FND_API.G_FALSE        );
                           csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                               l_msg_index := l_msg_index + 1;
                               l_msg_count := l_msg_count - 1;
                     END LOOP;
              END IF;
            END IF;
        END LOOP;
    END IF;
        --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
                   dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/

    -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
         p_data         =>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_version_label_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK TO update_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data);

END update_version_label;

/*----------------------------------------------------*/
/* Procedure name: expire_version_label               */
/* Description :   procedure for expire               */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE expire_version_label
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2
     ,p_init_msg_list               IN     VARCHAR2
     ,p_validation_level            IN     NUMBER
     ,p_version_label_tbl           IN     csi_datastructures_pub.version_label_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT    NOCOPY VARCHAR2
     ,x_msg_count                   OUT    NOCOPY NUMBER
     ,x_msg_data                    OUT    NOCOPY VARCHAR2
   ) IS
     l_api_name             CONSTANT VARCHAR2(30)   := 'UPDATE_VERSION_LABEL';
     l_api_version              CONSTANT NUMBER         := 1.0;
     l_debug_level                  NUMBER;
     l_version_label_rec    csi_datastructures_pub.version_label_rec;
     l_msg_index            NUMBER;
     l_line_count           NUMBER;
     l_version_label_id     NUMBER;
     l_flag                 VARCHAR2(1)  :='N';
     l_msg_count               NUMBER;

BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT  expire_version_label_pub;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                                    p_api_version       ,
                                                l_api_name              ,
                                                G_PKG_NAME              )
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
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
         csi_gen_utility_pvt.put_line( 'expire_version_label');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'expire_version_label:'||
                                                                  p_api_version           ||'-'||
                                                              p_commit                ||'-'||
                                                                  p_init_msg_list            );
         -- Dump the records in the log file
         csi_gen_utility_pvt.dump_version_label_tbl(p_version_label_tbl);
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
     END IF;
     /***** srramakr commented for bug # 3304439
     -- Check for the profile option and enable trace
     l_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_flag);
     -- End enable trace
     ****/
     -- Start API body
         --
     IF p_version_label_tbl.count > 0 THEN
       FOR l_count IN p_version_label_tbl.FIRST..p_version_label_tbl.LAST
       LOOP
         IF p_version_label_tbl.EXISTS(l_count) THEN

            csi_item_instance_pvt.expire_version_label
            (  p_api_version             =>  p_api_version
              ,p_commit                  =>  p_commit
              ,p_init_msg_list           =>  p_init_msg_list
              ,p_validation_level        =>  p_validation_level
              ,p_version_label_rec       =>  p_version_label_tbl(l_count)
              ,p_txn_rec                 =>  p_txn_rec
              ,x_return_status           =>  x_return_status
              ,x_msg_count               =>  x_msg_count
              ,x_msg_data                =>  x_msg_data      );

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                     l_msg_index := 1;
                 l_msg_count := x_msg_count;
                     WHILE l_msg_count > 0 LOOP
                           x_msg_data := FND_MSG_PUB.GET(
                                                 l_msg_index,
                                                         FND_API.G_FALSE );
                           csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                               l_msg_index := l_msg_index + 1;
                               l_msg_count := l_msg_count - 1;
                     END LOOP;
              END IF;
          END IF;
       END LOOP;
     END IF;
        --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
        IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
                   dbms_session.set_sql_trace(false);
    END IF;
        -- End disable trace
    ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_encoded => FND_API.G_FALSE,
                 p_count        =>      x_msg_count ,
         p_data         =>      x_msg_data      );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO expire_version_label_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count =>      x_msg_count,
                        p_data  =>      x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO expire_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count =>      x_msg_count,
                        p_data  =>      x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK TO expire_version_label_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_encoded => FND_API.G_FALSE,
                 p_count  =>      x_msg_count,
                        p_data   =>      x_msg_data);
END expire_version_label;

/*----------------------------------------------------*/
/* procedure name: get_extended_attrib_values         */
/* description :   Gets the extended attribute        */
/*                 values of an item instance         */
/*----------------------------------------------------*/

PROCEDURE get_extended_attrib_values
 (    p_api_version           IN     NUMBER
     ,p_commit                IN     VARCHAR2
     ,p_init_msg_list         IN     VARCHAR2
     ,p_validation_level      IN     NUMBER
     ,p_ext_attribs_query_rec IN     csi_datastructures_pub.extend_attrib_query_rec
     ,p_time_stamp            IN     DATE
     ,x_ext_attrib_tbl           OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
     ,x_ext_attrib_def_tbl       OUT NOCOPY csi_datastructures_pub.extend_attrib_tbl  -- added
     ,x_return_status            OUT NOCOPY VARCHAR2
     ,x_msg_count                OUT NOCOPY NUMBER
     ,x_msg_data                 OUT NOCOPY VARCHAR2
 )

IS
    l_api_name          CONSTANT VARCHAR2(30)    := 'get_extended_attrib_values';
    l_api_version       CONSTANT NUMBER          := 1.0;
    l_debug_level                NUMBER;
    l_ext_rec                    csi_datastructures_pub.extend_attrib_values_rec;
    l_rows_processed             NUMBER;
    l_where_clause               VARCHAR2(2000)  := ''  ;
    l_select_stmt                VARCHAR2(20000);
    l_cur_get_ext                NUMBER;
    l_count                      NUMBER          := 0;
    l_trace_enable_flag          VARCHAR2(1)     :='N';
    l_row                        NUMBER          := 0;

    CURSOR ext_attrib_csr (p_instance_id NUMBER) IS
    SELECT  /*+ INDEX(iea CSI_I_EXTENDED_ATTRIBS_N04)*/    -- Added by sguthiva for bug 2367664
            iea.attribute_id            attribute_id
           ,iea.attribute_level         attribute_level
           ,iea.master_organization_id  master_organization_id
           ,iea.inventory_item_id       inventory_item_id
           ,iea.item_category_id        item_category_id
           ,iea.instance_id             instance_id
           ,iea.attribute_code          attribute_code
           ,iea.attribute_name          attribute_name
           ,iea.attribute_category      attribute_category
           ,iea.description             description
           ,iea.active_start_date       active_start_date
           ,iea.active_end_date         active_end_date
           ,iea.context                 context
           ,iea.attribute1              attribute1
           ,iea.attribute2              attribute2
           ,iea.attribute3              attribute3
           ,iea.attribute4              attribute4
           ,iea.attribute5              attribute5
           ,iea.attribute6              attribute6
           ,iea.attribute7              attribute7
           ,iea.attribute8              attribute8
           ,iea.attribute9              attribute9
           ,iea.attribute10             attribute10
           ,iea.attribute11             attribute11
           ,iea.attribute12             attribute12
           ,iea.attribute13             attribute13
           ,iea.attribute14             attribute14
           ,iea.attribute15             attribute15
           ,iea.object_version_number   object_version_number
    FROM   csi_i_extended_attribs iea
    WHERE  attribute_level = 'GLOBAL'
    UNION ALL
    SELECT  /*+ INDEX(iea CSI_I_EXTENDED_ATTRIBS_N01)*/    -- Added by sguthiva for bug 2367664
            iea.attribute_id            attribute_id
           ,iea.attribute_level         attribute_level
           ,iea.master_organization_id  master_organization_id
           ,iea.inventory_item_id       inventory_item_id
           ,iea.item_category_id        item_category_id
           ,iea.instance_id             instance_id
           ,iea.attribute_code          attribute_code
           ,iea.attribute_name          attribute_name
           ,iea.attribute_category      attribute_category
           ,iea.description             description
           ,iea.active_start_date       active_start_date
           ,iea.active_end_date         active_end_date
           ,iea.context                 context
           ,iea.attribute1              attribute1
           ,iea.attribute2              attribute2
           ,iea.attribute3              attribute3
           ,iea.attribute4              attribute4
           ,iea.attribute5              attribute5
           ,iea.attribute6              attribute6
           ,iea.attribute7              attribute7
           ,iea.attribute8              attribute8
           ,iea.attribute9              attribute9
           ,iea.attribute10             attribute10
           ,iea.attribute11             attribute11
           ,iea.attribute12             attribute12
           ,iea.attribute13             attribute13
           ,iea.attribute14             attribute14
           ,iea.attribute15             attribute15
           ,iea.object_version_number   object_version_number
    FROM   csi_i_extended_attribs iea
    WHERE  attribute_level = 'INSTANCE'
    AND    instance_id = p_instance_id
    UNION ALL
    SELECT  /*+ INDEX(ia CSI_ITEM_INSTANCES_U01)
                INDEX(iea CSI_I_EXTENDED_ATTRIBS_N01)
            */                                             -- Added by sguthiva for bug 2367664
            iea.attribute_id            attribute_id
           ,iea.attribute_level         attribute_level
           ,iea.master_organization_id  master_organization_id
           ,iea.inventory_item_id       inventory_item_id
           ,iea.item_category_id        item_category_id
           ,iea.instance_id             instance_id
           ,iea.attribute_code          attribute_code
           ,iea.attribute_name          attribute_name
           ,iea.attribute_category      attribute_category
           ,iea.description             description
           ,iea.active_start_date       active_start_date
           ,iea.active_end_date         active_end_date
           ,iea.context                 context
           ,iea.attribute1              attribute1
           ,iea.attribute2              attribute2
           ,iea.attribute3              attribute3
           ,iea.attribute4              attribute4
           ,iea.attribute5              attribute5
           ,iea.attribute6              attribute6
           ,iea.attribute7              attribute7
           ,iea.attribute8              attribute8
           ,iea.attribute9              attribute9
           ,iea.attribute10             attribute10
           ,iea.attribute11             attribute11
           ,iea.attribute12             attribute12
           ,iea.attribute13             attribute13
           ,iea.attribute14             attribute14
           ,iea.attribute15             attribute15
           ,iea.object_version_number   object_version_number
    FROM   csi_i_extended_attribs iea, csi_item_instances ia
    WHERE  iea.attribute_level = 'ITEM'
    AND    iea.inventory_item_id = ia.inventory_item_id  --p_inv_item_id
    AND    iea.master_organization_id = ia.inv_master_organization_id --p_org_id;
    AND    ia.instance_id = p_instance_id
    UNION ALL
    SELECT  /*+ INDEX(ia CSI_ITEM_INSTANCES_U01)
                INDEX(iea CSI_I_EXTENDED_ATTRIBS_N01)
                INDEX(ic MTL_ITEM_CATEGORIES_U1)
            */                                             -- Added by sguthiva for bug 2367664
            iea.attribute_id            attribute_id
           ,iea.attribute_level         attribute_level
           ,iea.master_organization_id  master_organization_id
           ,iea.inventory_item_id       inventory_item_id
           ,iea.item_category_id        item_category_id
           ,iea.instance_id             instance_id
           ,iea.attribute_code          attribute_code
           ,iea.attribute_name          attribute_name
           ,iea.attribute_category      attribute_category
           ,iea.description             description
           ,iea.active_start_date       active_start_date
           ,iea.active_end_date         active_end_date
           ,iea.context                 context
           ,iea.attribute1              attribute1
           ,iea.attribute2              attribute2
           ,iea.attribute3              attribute3
           ,iea.attribute4              attribute4
           ,iea.attribute5              attribute5
           ,iea.attribute6              attribute6
           ,iea.attribute7              attribute7
           ,iea.attribute8              attribute8
           ,iea.attribute9              attribute9
           ,iea.attribute10             attribute10
           ,iea.attribute11             attribute11
           ,iea.attribute12             attribute12
           ,iea.attribute13             attribute13
           ,iea.attribute14             attribute14
           ,iea.attribute15             attribute15
           ,iea.object_version_number   object_version_number
    FROM   csi_i_extended_attribs iea
          ,csi_item_instances ia
          ,mtl_item_categories ic
    WHERE  iea.attribute_level = 'CATEGORY'
  --  AND    iea.inventory_item_id = ia.inventory_item_id  -- commented for Bug # 3189494
  --  AND    iea.master_organization_id = ia.inv_master_organization_id -- commented for Bug # 3189494
    AND    ic.organization_id = ia.inv_master_organization_id
    AND    ic.inventory_item_id = ia.inventory_item_id
    AND    ic.category_id = iea.item_category_id
    AND    ia.instance_id = p_instance_id;

BEGIN

    -- Standard Start of API savepoint
   -- SAVEPOINT    get_extended_attrib_values;

    -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
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
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'get_extended_attrib_values');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
      csi_gen_utility_pvt.put_line( p_api_version ||'-'
                     || p_commit                     ||'-'
                     || p_init_msg_list              ||'-'
                     || p_validation_level           ||'-'
                     || p_time_stamp);

      -- Dump extended attribs
      csi_gen_utility_pvt.dump_ext_attrib_query_rec(p_ext_attribs_query_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/

    -- Start API body
    -- Check if atleast one query parameters are passed
    IF (p_ext_attribs_query_rec.attribute_value_id  = FND_API.G_MISS_NUM)
         AND ( p_ext_attribs_query_rec.instance_id = FND_API.G_MISS_NUM)
         AND ( p_ext_attribs_query_rec.attribute_id = FND_API.G_MISS_NUM)
    THEN

          FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
          FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Generate the where clause
    csi_item_instance_pvt.Gen_ext_Where_Clause
      (    p_ext_query_rec      =>   p_ext_attribs_query_rec,
           x_where_clause       =>  l_where_clause    );

    -- Build the select statement
    l_select_stmt := 'SELECT  cv.attribute_value_id attribute_value_id'        ||
                            ',cv.attribute_id attribute_id'                    ||
                            ',cv.instance_id instance_id'                      ||
                            ',ca.attribute_code attribute_code'                ||
                            ',cv.attribute_value attribute_value'              ||
                            ',cv.active_start_date active_start_date'          ||
                            ',cv.active_end_date active_end_date'              ||
                            ',cv.context context'                              ||
                            ',cv.attribute1 attribute1'                        ||
                            ',cv.attribute2 attribute2'                        ||
                            ',cv.attribute3 attribute3'                        ||
                            ',cv.attribute4 attribute4'                        ||
                            ',cv.attribute5 attribute5'                        ||
                            ',cv.attribute6 attribute6'                        ||
                            ',cv.attribute7 attribute7'                        ||
                            ',cv.attribute8 attribute8'                        ||
                            ',cv.attribute9 attribute9'                        ||
                            ',cv.attribute10 attribute10'                      ||
                            ',cv.attribute11 attribute11'                      ||
                            ',cv.attribute12 attribute12'                      ||
                            ',cv.attribute13 attribute13'                      ||
                            ',cv.attribute14 attribute14'                      ||
                            ',cv.attribute15 attribute15'                      ||
                            ',cv.object_version_number object_version_number  '||
                     'FROM csi_iea_values cv, csi_i_extended_attribs ca  '     ||
                     'WHERE cv.attribute_id = ca.attribute_id' ;

    l_select_stmt := l_select_stmt || ' AND '||l_where_clause;

    -- Open the cursor
    l_cur_get_ext := dbms_sql.open_cursor;


    --Parse the select statement
    dbms_sql.parse(l_cur_get_ext, l_select_stmt , dbms_sql.native);

    -- Bind the variables
    csi_item_instance_pvt.Bind_ext_variable
           ( p_ext_attribs_query_rec,
             l_cur_get_ext );

    -- Define output variables
    csi_item_instance_pvt.Define_ext_Columns(l_cur_get_ext);

    -- execute the select statement
    l_rows_processed := dbms_sql.execute(l_cur_get_ext);


    LOOP
    EXIT WHEN DBMS_SQL.FETCH_ROWS(l_cur_get_ext) = 0;
            csi_item_instance_pvt.Get_ext_Column_Values(l_cur_get_ext, l_ext_rec);
            l_count := l_count + 1;
            x_ext_attrib_tbl(l_count) := l_ext_rec;
    END LOOP;

    -- Close the cursor
    DBMS_SQL.CLOSE_CURSOR(l_cur_get_ext);

    IF (p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE) THEN
      IF p_time_stamp <= sysdate THEN
           csi_item_instance_pvt.Construct_ext_From_Hist(x_ext_attrib_tbl, p_time_stamp);
      ELSE
            FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_HIST_PARAMS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    IF (p_ext_attribs_query_rec.instance_id IS NOT NULL AND p_ext_attribs_query_rec.instance_id <> fnd_api.g_miss_num)
    THEN

       FOR attrib_csr IN ext_attrib_csr(p_ext_attribs_query_rec.instance_id)
       LOOP
           l_row:=l_row+1;
           x_ext_attrib_def_tbl(l_row).attribute_id           := attrib_csr.attribute_id;
           x_ext_attrib_def_tbl(l_row).attribute_level        := attrib_csr.attribute_level;
           x_ext_attrib_def_tbl(l_row).master_organization_id := attrib_csr.master_organization_id;
           x_ext_attrib_def_tbl(l_row).inventory_item_id      := attrib_csr.inventory_item_id;
           x_ext_attrib_def_tbl(l_row).item_category_id       := attrib_csr.item_category_id;
           x_ext_attrib_def_tbl(l_row).instance_id            := attrib_csr.instance_id;
           x_ext_attrib_def_tbl(l_row).attribute_code         := attrib_csr.attribute_code;
           x_ext_attrib_def_tbl(l_row).attribute_name         := attrib_csr.attribute_name;
           x_ext_attrib_def_tbl(l_row).attribute_category     := attrib_csr.attribute_category;
           x_ext_attrib_def_tbl(l_row).description            := attrib_csr.description;
           x_ext_attrib_def_tbl(l_row).active_start_date      := attrib_csr.active_start_date;
           x_ext_attrib_def_tbl(l_row).active_end_date        := attrib_csr.active_end_date;
           x_ext_attrib_def_tbl(l_row).context                := attrib_csr.context;
           x_ext_attrib_def_tbl(l_row).attribute1             := attrib_csr.attribute1;
           x_ext_attrib_def_tbl(l_row).attribute2             := attrib_csr.attribute2;
           x_ext_attrib_def_tbl(l_row).attribute3             := attrib_csr.attribute3;
           x_ext_attrib_def_tbl(l_row).attribute4             := attrib_csr.attribute4;
           x_ext_attrib_def_tbl(l_row).attribute5             := attrib_csr.attribute5;
           x_ext_attrib_def_tbl(l_row).attribute6             := attrib_csr.attribute6;
           x_ext_attrib_def_tbl(l_row).attribute7             := attrib_csr.attribute7;
           x_ext_attrib_def_tbl(l_row).attribute8             := attrib_csr.attribute8;
           x_ext_attrib_def_tbl(l_row).attribute9             := attrib_csr.attribute9;
           x_ext_attrib_def_tbl(l_row).attribute10            := attrib_csr.attribute10;
           x_ext_attrib_def_tbl(l_row).attribute11            := attrib_csr.attribute11;
           x_ext_attrib_def_tbl(l_row).attribute12            := attrib_csr.attribute12;
           x_ext_attrib_def_tbl(l_row).attribute13            := attrib_csr.attribute13;
           x_ext_attrib_def_tbl(l_row).attribute14            := attrib_csr.attribute14;
           x_ext_attrib_def_tbl(l_row).attribute15            := attrib_csr.attribute15;
           x_ext_attrib_def_tbl(l_row).object_version_number  := attrib_csr.object_version_number;

       END LOOP;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    /*
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    */

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_trace_enable_flag = 'Y') THEN
       dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_encoded => FND_API.G_FALSE,
                 p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
        );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --  ROLLBACK TO get_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (  p_encoded => FND_API.G_FALSE,
                 p_count     =>      x_msg_count,
               p_data      =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --  ROLLBACK TO get_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

    WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(l_cur_get_ext) THEN
              DBMS_SQL.CLOSE_CURSOR(l_cur_get_ext);
        END IF;

      --  ROLLBACK TO  get_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (    g_pkg_name,
                    l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
             );

END get_extended_attrib_values;

/*----------------------------------------------------*/
/* procedure name: create_extended_attrib_values      */
/* description :  Associates extended attribute       */
/*                values to an item instance          */
/*----------------------------------------------------*/

PROCEDURE create_extended_attrib_values
 (    p_api_version        IN     NUMBER
     ,p_commit             IN     VARCHAR2
     ,p_init_msg_list      IN     VARCHAR2
     ,p_validation_level   IN     NUMBER
     ,p_ext_attrib_tbl     IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
     ,p_txn_rec            IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
 )

IS
     l_api_name       CONSTANT VARCHAR2(30)   := 'create_extended_attrib_values';
     l_api_version    CONSTANT NUMBER         := 1.0;
     l_debug_level             NUMBER;
     l_msg_index               NUMBER;
     l_msg_count               NUMBER;
     l_trace_enable_flag       VARCHAR2(1)    :='N';
     l_ext_id_tbl              csi_item_instance_pvt.ext_id_tbl;
     l_ext_count_rec           csi_item_instance_pvt.ext_count_rec;
     l_ext_attr_tbl            csi_item_instance_pvt.ext_attr_tbl;
     l_ext_cat_tbl             csi_item_instance_pvt.ext_cat_tbl;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    create_extended_attrib_values;

    -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
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

    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'create_extended_attrib_values');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
     csi_gen_utility_pvt.put_line( p_api_version ||'-'
                     || p_commit                    ||'-'
                     || p_init_msg_list             ||'-'
                     || p_validation_level );

     -- Dump extended attribs tbl
     csi_gen_utility_pvt.dump_ext_attrib_values_tbl(p_ext_attrib_tbl);
     -- Dump txn_rec
     csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
        l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/


    -- Start API body

    IF p_ext_attrib_tbl.COUNT > 0 THEN
         FOR tab_row IN p_ext_attrib_tbl.FIRST .. p_ext_attrib_tbl.LAST
         LOOP
            IF p_ext_attrib_tbl.EXISTS(tab_row) THEN
               csi_item_instance_pvt.create_extended_attrib_values
                ( p_api_version         => p_api_version
                 ,p_commit              => fnd_api.g_false
                 ,p_init_msg_list       => p_init_msg_list
                 ,p_validation_level    => p_validation_level
                 ,p_ext_attrib_rec      => p_ext_attrib_tbl(tab_row)
                 ,p_txn_rec             => p_txn_rec
                 ,x_return_status       => x_return_status
                 ,x_msg_count           => x_msg_count
                 ,x_msg_data            => x_msg_data
                 ,p_ext_id_tbl          => l_ext_id_tbl
                 ,p_ext_count_rec       => l_ext_count_rec
                 ,p_ext_attr_tbl        => l_ext_attr_tbl
                 ,p_ext_cat_tbl         => l_ext_cat_tbl
                );

               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                   l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                                      (l_msg_index,
                                     FND_API.G_FALSE      );

                     csi_gen_utility_pvt.put_line( ' Failed Pub:create_extended_attrib_values..');
                     csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
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

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
         dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/


    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_encoded => FND_API.G_FALSE,
                 p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
            );

    WHEN OTHERS THEN

        ROLLBACK TO  create_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF     FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   g_pkg_name,
                    l_api_name
                );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
            );

END create_extended_attrib_values;

/*----------------------------------------------------*/
/* procedure name: update_extended_attrib_values      */
/* description :  Updates extended attrib values for  */
/*                for an item instance                */
/*----------------------------------------------------*/

PROCEDURE update_extended_attrib_values
 (    p_api_version        IN     NUMBER
     ,p_commit             IN     VARCHAR2
     ,p_init_msg_list      IN     VARCHAR2
     ,p_validation_level   IN     NUMBER
     ,p_ext_attrib_tbl     IN     csi_datastructures_pub.extend_attrib_values_tbl
     ,p_txn_rec            IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
 )

IS
    l_api_name          CONSTANT VARCHAR2(30)   := 'update_extended_attrib_values';
    l_api_version       CONSTANT NUMBER         := 1.0;
    l_debug_level                NUMBER;
    l_msg_index                  NUMBER;
    l_msg_count                  NUMBER;
    l_trace_enable_flag          VARCHAR2(1)    :='N';
    l_ext_id_tbl                 csi_item_instance_pvt.ext_id_tbl;
    l_ext_count_rec              csi_item_instance_pvt.ext_count_rec;
    l_ext_attr_tbl               csi_item_instance_pvt.ext_attr_tbl;
    l_ext_cat_tbl                csi_item_instance_pvt.ext_cat_tbl;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    update_extended_attrib_values;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
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
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'update_extended_attrib_values');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line( p_api_version ||'-'
                     || p_commit                    ||'-'
                     || p_init_msg_list             ||'-'
                     || p_validation_level );

       -- Dump extended attribs tbl
       csi_gen_utility_pvt.dump_ext_attrib_values_tbl(p_ext_attrib_tbl);
       -- Dump txn_rec
       csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
        l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/


    -- Start API body
     IF p_ext_attrib_tbl.COUNT > 0 THEN
         FOR tab_row IN p_ext_attrib_tbl.FIRST .. p_ext_attrib_tbl.LAST
         LOOP
          IF p_ext_attrib_tbl.EXISTS(tab_row) THEN
             csi_item_instance_pvt.update_extended_attrib_values
             (p_api_version       => p_api_version
             ,p_commit            => fnd_api.g_false
             ,p_init_msg_list     => p_init_msg_list
             ,p_validation_level  => p_validation_level
             ,p_ext_attrib_rec    => p_ext_attrib_tbl(tab_row)
             ,p_txn_rec           => p_txn_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
--             ,p_ext_id_tbl        => l_ext_id_tbl
--             ,p_ext_count_rec     => l_ext_count_rec
--             ,p_ext_attr_tbl      => l_ext_attr_tbl
--             ,p_ext_cat_tbl       => l_ext_cat_tbl
             );

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                   l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                          (l_msg_index,
                           FND_API.G_FALSE      );

                     csi_gen_utility_pvt.put_line( ' Failed Pub:update_extended_attrib_values..');
                     csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
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

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_trace_enable_flag = 'Y') THEN
       dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_encoded => FND_API.G_FALSE,
                 p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
             (  p_encoded => FND_API.G_FALSE,
                 p_count      =>      x_msg_count,
                p_data       =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count      =>      x_msg_count,
                p_data       =>      x_msg_data
            );

    WHEN OTHERS THEN
        ROLLBACK TO  update_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF     FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   g_pkg_name          ,
                    l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count      =>      x_msg_count,
                p_data       =>      x_msg_data
             );

END update_extended_attrib_values;

/*----------------------------------------------------*/
/* procedure name: Expire_extended_attrib_values      */
/* description :  Expires extended attribute values   */
/*                for an item instance                */
/*----------------------------------------------------*/

PROCEDURE expire_extended_attrib_values
 (    p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2
     ,p_init_msg_list       IN     VARCHAR2
     ,p_validation_level    IN     NUMBER
     ,p_ext_attrib_tbl      IN     csi_datastructures_pub.extend_attrib_values_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2
 )

IS
    l_api_name          CONSTANT VARCHAR2(30)  := 'delete_extended_attrib_values';
    l_api_version       CONSTANT NUMBER        := 1.0;
    l_debug_level                NUMBER;
    l_msg_index                  NUMBER;
    l_msg_count                  NUMBER;
    l_trace_enable_flag          VARCHAR2(1)   :='N';
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    delete_extended_attrib_values;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
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

    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'delete_extended_attrib_values');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
      csi_gen_utility_pvt.put_line( p_api_version ||'-'
                     || p_commit                    ||'-'
                     || p_init_msg_list             ||'-'
                     || p_validation_level     );
      -- Dump extended attribs tbl
      csi_gen_utility_pvt.dump_ext_attrib_values_tbl(p_ext_attrib_tbl);
      -- Dump txn_rec
      csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
        l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/


     -- Start API body

     IF p_ext_attrib_tbl.COUNT > 0 THEN
         FOR tab_row IN p_ext_attrib_tbl.FIRST .. p_ext_attrib_tbl.LAST
         LOOP
            IF p_ext_attrib_tbl.EXISTS(tab_row) THEN

               csi_item_instance_pvt.expire_extended_attrib_values
                ( p_api_version      => p_api_version
                 ,p_commit           => fnd_api.g_false
                 ,p_init_msg_list    => p_init_msg_list
                 ,p_validation_level => p_validation_level
                 ,p_ext_attrib_rec   => p_ext_attrib_tbl(tab_row)
                 ,p_txn_rec          => p_txn_rec
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
                                     FND_API.G_FALSE      );

                     csi_gen_utility_pvt.put_line( ' Failed Pub:expire_extended_attrib_values..');
                     csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
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

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_trace_enable_flag = 'Y') THEN
       dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/


    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_encoded => FND_API.G_FALSE,
                 p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count      =>      x_msg_count,
                p_data       =>      x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count      =>      x_msg_count,
                p_data       =>      x_msg_data
            );

    WHEN OTHERS THEN
        ROLLBACK TO  delete_extended_attrib_values;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                FND_MSG_PUB.Add_Exc_Msg
                (    g_pkg_name ,
                     l_api_name
                 );
          END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_encoded => FND_API.G_FALSE,
                 p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );

END expire_extended_attrib_values;




/*------------------------------------------------------*/
/* procedure name: copy_item_instance                   */
/* description :  Copies an instace from an instance    */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE copy_item_instance
 (
   p_api_version            IN         NUMBER
  ,p_commit                 IN         VARCHAR2
  ,p_init_msg_list          IN         VARCHAR2
  ,p_validation_level       IN         NUMBER
  ,p_source_instance_rec    IN         csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs       IN         VARCHAR2
  ,p_copy_org_assignments   IN         VARCHAR2
  ,p_copy_parties           IN         VARCHAR2
  ,p_copy_party_contacts    IN         VARCHAR2
  ,p_copy_accounts          IN         VARCHAR2
  ,p_copy_asset_assignments IN         VARCHAR2
  ,p_copy_pricing_attribs   IN         VARCHAR2
  ,p_copy_inst_children     IN         VARCHAR2
  ,p_txn_rec                IN  OUT    NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl           OUT    NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status              OUT    NOCOPY VARCHAR2
  ,x_msg_count                  OUT    NOCOPY NUMBER
  ,x_msg_data                   OUT    NOCOPY VARCHAR2
 )
 IS

    l_api_name                         CONSTANT VARCHAR2(30) := 'copy_item_instance';
    l_api_version                     CONSTANT NUMBER      := 1.0;
    l_debug_level                                NUMBER;

    l_msg_index                             NUMBER;
    l_msg_count                             NUMBER;
    x_msg_index_out                         NUMBER;
BEGIN

    -- Standard Start of API savepoint
          SAVEPOINT      copy_item_instance;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

        csi_utility_grp.check_ib_active;

    -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name ,
                                          G_PKG_NAME)
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
          l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
   IF (l_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line('copy_item_instance ');
   END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
         csi_gen_utility_pvt.put_line('copy_item_instance '||
                              p_api_version ||'-'
                           || p_commit ||'-'
                           || p_init_msg_list ||'-'
                           || p_validation_level ||'-'
                           || p_copy_ext_attribs ||'-'
                           || p_copy_org_assignments ||'-'
                           || p_copy_parties  ||'-'
                           || p_copy_party_contacts  ||'-'
                           || p_copy_accounts  ||'-'
                           || p_copy_asset_assignments ||'-'
                           || p_copy_pricing_attribs
                            );

     -- Dump item instanc red
         csi_gen_utility_pvt.dump_instance_rec(p_source_instance_rec);
     -- Dump txn_rec
         csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    -- Start API body

     csi_item_instance_pvt.copy_item_instance
           ( p_api_version                 => p_api_version
            ,p_commit                      => fnd_api.g_false
            ,p_init_msg_list               => p_init_msg_list
            ,p_validation_level            => p_validation_level
            ,p_source_instance_rec         => p_source_instance_rec
            ,p_copy_ext_attribs            => p_copy_ext_attribs
            ,p_copy_org_assignments        => p_copy_org_assignments
            ,p_copy_parties                => p_copy_parties
            ,p_copy_contacts               => p_copy_party_contacts
            ,p_copy_accounts               => p_copy_accounts
            ,p_copy_asset_assignments      => p_copy_asset_assignments
            ,p_copy_pricing_attribs        => p_copy_pricing_attribs
            ,p_copy_inst_children          => p_copy_inst_children
            ,p_call_from_split             => fnd_api.g_false
            ,p_txn_rec                     => p_txn_rec
            ,x_new_instance_tbl            => x_new_instance_tbl
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data
           );

       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          FOR i in 1..x_msg_Count LOOP
            FND_MSG_PUB.Get(p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => x_msg_data,
                            p_msg_index_out => x_msg_index_out );

            csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
         End LOOP;
         RAISE fnd_api.g_exc_error;
       END IF;

       -- End of API body

       -- Standard check of p_commit
       IF FND_API.To_Boolean( p_commit ) THEN
               COMMIT WORK;
       END IF;


       -- Standard call to get message count and if count is  get message info.

          FND_MSG_PUB.Count_And_Get
          (p_encoded => FND_API.G_FALSE,
                 p_count       =>       x_msg_count ,
         p_data       =>       x_msg_data
           );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO copy_item_instance;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (        p_encoded => FND_API.G_FALSE,
                 p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                 );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO copy_item_instance;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (        p_encoded => FND_API.G_FALSE,
                 p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                 );

      WHEN OTHERS THEN
            ROLLBACK TO  copy_item_instance;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF       FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                    (      G_PKG_NAME            ,
                          l_api_name
                     );
            END IF;

            FND_MSG_PUB.Count_And_Get
                (        p_encoded => FND_API.G_FALSE,
                 p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                );


END  copy_item_instance;

PROCEDURE get_oks_txn_types (
         p_api_version            IN                    NUMBER
        ,p_commit                 IN                    VARCHAR2
        ,p_init_msg_list          IN                    VARCHAR2
        ,p_instance_rec           IN                    CSI_DATASTRUCTURES_PUB.INSTANCE_REC
        ,p_check_contracts_yn     IN                    VARCHAR2
        ,p_txn_type               IN                    VARCHAR2
        ,x_txn_type_tbl                OUT    NOCOPY    CSI_ITEM_INSTANCE_PUB.TXN_OKS_TYPE_TBL
        ,x_configflag                  OUT    NOCOPY    VARCHAR2
        ,px_txn_date              IN   OUT    NOCOPY    DATE
        ,x_imp_contracts_flag          OUT    NOCOPY    VARCHAR2
        ,x_return_status               OUT    NOCOPY    VARCHAR2
        ,x_msg_count                   OUT    NOCOPY    NUMBER
        ,x_msg_data                    OUT    NOCOPY    VARCHAR2
        ) IS

   CURSOR old_instance_rec ( cp_instance_id NUMBER) is
   SELECT quantity, install_date, active_end_date
     FROM csi_item_instances
    WHERE instance_id = cp_instance_id;

    l_curr_instance_rec     old_instance_rec%ROWTYPE;
    l_row_index             NUMBER := 0;
    l_exists                VARCHAR(1);
    l_msg_count             NUMBER;
    l_msg_index             NUMBER;
    l_oks_txn_tbl           oks_ibint_pub.txn_tbl_type;

  BEGIN
    SAVEPOINT  get_oks_txn_types;

    OPEN  old_instance_rec(p_instance_rec.INSTANCE_ID);
    FETCH old_instance_rec INTO l_curr_instance_rec;
    CLOSE old_instance_rec;

    IF p_txn_type IS NULL THEN

      IF l_curr_instance_rec.quantity <> p_instance_rec.quantity THEN
        x_txn_type_tbl(l_row_index) := 'UPD';
        l_row_index := l_row_index + 1;
      END IF;

      IF NVL(l_curr_instance_rec.install_date,FND_API.G_MISS_DATE) <>
          NVL(p_instance_rec.install_date,FND_API.G_MISS_DATE) THEN
        x_txn_type_tbl(l_row_index) := 'IDC';
        l_row_index := l_row_index + 1;
      END IF;

      IF p_instance_rec.active_end_date IS NOT NULL AND
         p_instance_rec.active_end_date <> FND_API.G_MISS_DATE AND
         p_instance_rec.active_end_date <= SYSDATE THEN
         x_txn_type_tbl(l_row_index) := 'TRM';
         l_row_index := l_row_index + 1;
      END IF;

/*
      IF l_curr_instance_rec.active_end_date IS NOT NULL AND
         l_curr_instance_rec.active_end_date <= SYSDATE AND
         (p_instance_rec.active_end_date IS NULL OR
          (p_instance_rec.active_end_date IS NOT NULL AND
           p_instance_rec.active_end_date <> FND_API.G_MISS_DATE AND
           p_instance_rec.active_end_date > SYSDATE) ) THEN
*/
      IF (l_curr_instance_rec.active_end_date IS NOT NULL
         AND ( p_instance_rec.active_end_date <> FND_API.G_MISS_DATE or p_instance_rec.active_end_date is null))
         AND ((l_curr_instance_rec.active_end_date < p_instance_rec.active_end_date
         AND p_instance_rec.active_end_date > SYSDATE)
         OR (p_instance_rec.active_end_date IS NULL)) THEN
         x_txn_type_tbl(l_row_index) := 'RIN';
        l_row_index := l_row_index + 1;
      END IF;

    ELSE
      x_txn_type_tbl(l_row_index) := p_txn_type;
      l_row_index := l_row_index + 1;
    END IF;

    l_exists := NULL;
    Begin
      -- Commenting the following code for bug 4775959
      /*
       SELECT 'x' INTO l_exists
       FROM dual
       WHERE EXISTS (SELECT 'x'
                     FROM csi_ii_relationships
                     WHERE object_id = p_instance_rec.instance_id
                     AND relationship_type_code = 'COMPONENT-OF'
                     AND NVL (active_end_date,(sysdate+1)) > sysdate);
      */
        SELECT 'x'
          INTO l_exists
          FROM csi_ii_relationships
         WHERE object_id = p_instance_rec.instance_id
           AND relationship_type_code = 'COMPONENT-OF'
           AND NVL (active_end_date,(sysdate+1)) > sysdate
           AND ROWNUM=1;
    Exception
       when no_data_found then
          l_exists := null;
    End;

    IF l_exists IS NULL THEN
      x_configflag := 'N';
    ELSE
      x_configflag := 'Y';
    END IF;

    IF px_txn_date IS NULL THEN
      px_txn_date := sysdate;
    END IF;

    IF x_txn_type_tbl.count > 0 THEN
       FOR i in x_txn_type_tbl.FIRST..x_txn_type_tbl.LAST
       LOOP
          l_oks_txn_tbl(i) := x_txn_type_tbl(i);
       END LOOP;
    END IF;

    IF p_check_contracts_yn = 'Y' THEN
         OKS_IBINT_PUB.CHECK_CONTRACTS_IMPACTED(
           p_api_version        =>  1.0,
           P_instance_id        =>  p_instance_rec.INSTANCE_ID,
           p_parent_instance_yn =>  x_configflag,
           p_transaction_date   =>  px_txn_date,
           p_new_install_date   =>  p_instance_rec.install_date,
           P_txn_tbl            =>  l_oks_txn_tbl,
           x_contract_exists_yn =>  x_imp_contracts_flag,
           X_msg_Count          =>  x_msg_count,
           X_msg_Data           =>  x_msg_data,
           x_return_status      =>  x_return_status
           );

           IF l_oks_txn_tbl.count > 0 THEN
             FOR i in l_oks_txn_tbl.FIRST..l_oks_txn_tbl.LAST
             LOOP
                 x_txn_type_tbl(i) := l_oks_txn_tbl(i);
             END LOOP;
           END IF;

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS)
        THEN
    	 csi_gen_utility_pvt.put_line('Error from Call_to_contracts...');
    	 l_msg_index := 1;
	     l_msg_count := x_msg_count;
    	 WHILE l_msg_count > 0 LOOP
	      x_msg_data := FND_MSG_PUB.GET
		       (  l_msg_index,
			  FND_API.G_FALSE
	       		);
          csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	      l_msg_index := l_msg_index + 1;
	      l_msg_count := l_msg_count - 1;
    	 END LOOP;
    	 RAISE FND_API.G_EXC_ERROR;
      END IF;

     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO get_oks_txn_types;
            x_return_status := FND_API.G_RET_STS_ERROR ;

 END get_oks_txn_types;


END CSI_ITEM_INSTANCE_PUB;

/
