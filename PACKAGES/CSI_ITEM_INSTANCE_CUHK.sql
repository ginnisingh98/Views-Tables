--------------------------------------------------------
--  DDL for Package CSI_ITEM_INSTANCE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ITEM_INSTANCE_CUHK" AUTHID CURRENT_USER AS
/* $Header: csichiis.pls 120.0 2005/05/25 02:39:33 appldev noship $ */
--
PROCEDURE create_item_instance_pre
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT NOCOPY    VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2
 );
--
PROCEDURE create_item_instance_post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT NOCOPY   VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2
 );
--
PROCEDURE update_item_instance_pre
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_instance_id_lst       OUT NOCOPY   csi_datastructures_pub.id_tbl
    ,x_return_status         OUT NOCOPY   VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2
 );
--
PROCEDURE update_item_instance_post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_instance_id_lst       OUT NOCOPY   csi_datastructures_pub.id_tbl
    ,x_return_status         OUT NOCOPY   VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2
 );
--
PROCEDURE expire_item_instance_pre
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_rec        IN      csi_datastructures_pub.instance_rec
     ,p_expire_children     IN      VARCHAR2 := fnd_api.g_false
     ,p_txn_rec             IN      csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT NOCOPY    csi_datastructures_pub.id_tbl
     ,x_return_status       OUT NOCOPY    VARCHAR2
     ,x_msg_count           OUT NOCOPY    NUMBER
     ,x_msg_data            OUT NOCOPY    VARCHAR2
 );
--
PROCEDURE expire_item_instance_post
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_rec        IN      csi_datastructures_pub.instance_rec
     ,p_expire_children     IN      VARCHAR2 := fnd_api.g_false
     ,p_txn_rec             IN      csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT NOCOPY    csi_datastructures_pub.id_tbl
     ,x_return_status       OUT NOCOPY    VARCHAR2
     ,x_msg_count           OUT NOCOPY    NUMBER
     ,x_msg_data            OUT NOCOPY    VARCHAR2
 );
--
END CSI_ITEM_INSTANCE_CUHK;

 

/
