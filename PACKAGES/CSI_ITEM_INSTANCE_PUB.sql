--------------------------------------------------------
--  DDL for Package CSI_ITEM_INSTANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ITEM_INSTANCE_PUB" AUTHID CURRENT_USER as
/* $Header: csipiis.pls 120.5.12010000.1 2008/07/25 08:11:14 appldev ship $ */
/*#
 * This is a public API for Item Instances Management.
 * It contains routines to Create, Update, Copy and Get Item Instances.
 * @rep:scope public
 * @rep:product CSI
 * @rep:displayname Manage Item Instances
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CSI_ITEM_INSTANCE
*/

/*----------------------------------------------------*/
/* procedure name: create_item_instance               */
/* description :   procedure used to                  */
/*                 create item instances              */
/*----------------------------------------------------*/

/*#
 * This procedure creates an Item Instance in Install Base along with its child entities.
 * The child entities include associated parties, accounts, organization units,
 * extended attributes, pricing attributes and asset assignments.
 * The child entities are optional except for the owner party and owner account if the
 * instance is owned by an external party.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_instance_rec Instance Record containing the attributes of the instance to be created
 * @param p_ext_attrib_values_tbl Extended Attributes to be associated with the item instance
 * @param p_party_tbl Parties to be associated with the item instance
 * @param p_account_tbl Party Accounts to be associated with the Parties
 * @param p_pricing_attrib_tbl Pricing Attributes to be associated with the item instance
 * @param p_org_assignments_tbl Organization Assignments to be associated with the item instance
 * @param p_asset_assignment_tbl Asset Attributes to be associated with the item instance
 * @param p_txn_rec Transaction Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Item Instance
 */
PROCEDURE create_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
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
 );

/*----------------------------------------------------*/
/* Procedure name: update_item_instance               */
/* Description :   procedure used to update an Item   */
/*                 Instance                           */
/*----------------------------------------------------*/

/*#
 * This procedure updates an existing item instance and its child entities in Install Base.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_instance_rec Instance Record structure containing the instance that needs to be updated
 * @param p_ext_attrib_values_tbl Extended Attributes to be updated
 * @param p_party_tbl Parties to be updated
 * @param p_account_tbl Party Accounts to be updated
 * @param p_pricing_attrib_tbl Pricing Attributes to be updated
 * @param p_org_assignments_tbl Organization Assignments to be updated
 * @param p_asset_assignment_tbl Asset Attributes to be updated
 * @param p_txn_rec Transaction Record structure
 * @param x_instance_id_lst List of instances
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Item Instance
 */
PROCEDURE update_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
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
 );

/*----------------------------------------------------*/
/* Procedure name: expire_item_instance               */
/* Description :   procedure for                      */
/*                 Expiring an Item Instance          */
/*----------------------------------------------------*/

PROCEDURE expire_item_instance
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_rec        IN      csi_datastructures_pub.instance_rec
     ,p_expire_children     IN      VARCHAR2 := fnd_api.g_false
     ,p_txn_rec             IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT     NOCOPY csi_datastructures_pub.id_tbl
     ,x_return_status       OUT     NOCOPY VARCHAR2
     ,x_msg_count           OUT     NOCOPY NUMBER
     ,x_msg_data            OUT     NOCOPY VARCHAR2
 );

/*----------------------------------------------------*/
/* Procedure name: get_item_instances                 */
/* Description :   procedure to                       */
/*                 get an Item Instance               */
/*----------------------------------------------------*/

/*#
 * This procedure gets a list of item instances in Oracle Install Base satisfying the
 * query criteria provided by the calling application.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_instance_query_rec Instance query criteria record structure
 * @param p_party_query_rec Party query criteria record structure
 * @param p_account_query_rec Party Account query criteria record structure
 * @param p_transaction_id Transaction ID based query
 * @param p_resolve_id_columns Resolve ID Columns to get corresponding description
 * @param p_active_instance_only Get only active instances
 * @param x_instance_header_tbl Output table structure containing the instance information
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Item Instances
 */
PROCEDURE get_item_instances
 (
      p_api_version          IN  NUMBER
     ,p_commit               IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_query_rec   IN  csi_datastructures_pub.instance_query_rec
     ,p_party_query_rec      IN  csi_datastructures_pub.party_query_rec
     ,p_account_query_rec    IN  csi_datastructures_pub.party_account_query_rec
     ,p_transaction_id       IN  NUMBER
     ,p_resolve_id_columns   IN  VARCHAR2 := fnd_api.g_false
     ,p_active_instance_only IN  VARCHAR2 := fnd_api.g_true
     ,x_instance_header_tbl  OUT NOCOPY csi_datastructures_pub.instance_header_tbl
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
);

/*#
 * This procedure gets the details of an Item Instance at a given point of time along with other
 * entities if needed. It uses only the instance query criteria to get the instances and the
 * information is constructed from history if a time stamp is passed. If the time stamp is not
 * passed then the current information would be retreived. The other entities are retreived if the
 * corresponding p_get's are set to fnd_api.g_true.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_instance_rec Instance record structure containing the instance_id to be queried and the output
 * @param p_get_parties  Decides whether to get Party information
 * @param p_party_header_tbl Contains the output of Party for the instance
 * @param p_get_accounts Decides whether to get Party Account information
 * @param p_account_header_tbl Contains the output of Party Account for the instance
 * @param p_get_org_assignments Decides whether to get Org Assignments information
 * @param p_org_header_tbl Contains the output of Org Assignments for the instance
 * @param p_get_pricing_attribs Decides whether to get Pricing Attributes information
 * @param p_pricing_attrib_tbl Contains the output of pricing attributes for the instance
 * @param p_get_ext_attribs Decides whether to get Extended Attributes information
 * @param p_ext_attrib_tbl Contains the output of extended attributes values for the instance
 * @param p_ext_attrib_def_tbl Contains the output of extended attributes definition
 * @param p_get_asset_assignments Decides whether to get Assets
 * @param p_asset_header_tbl Contains the output Assets for the instance
 * @param p_resolve_id_columns Resolve ID Columns to get corresponding description
 * @param p_time_stamp Instance information as of given time
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Item Instance Details
 */
/*----------------------------------------------------*/
/* Procedure name: get_item_instance_details          */
/* Description :   procedure to                       */
/*                 get an Item Instance details       */
/*----------------------------------------------------*/

 PROCEDURE get_item_instance_details
 (
      p_api_version              IN      NUMBER
     ,p_commit                   IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list            IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level         IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_rec             IN OUT  NOCOPY csi_datastructures_pub.instance_header_rec
     ,p_get_parties              IN      VARCHAR2 := fnd_api.g_false
     ,p_party_header_tbl         OUT     NOCOPY csi_datastructures_pub.party_header_tbl
     ,p_get_accounts             IN      VARCHAR2 := fnd_api.g_false
     ,p_account_header_tbl       OUT     NOCOPY csi_datastructures_pub.party_account_header_tbl
     ,p_get_org_assignments      IN      VARCHAR2 := fnd_api.g_false
     ,p_org_header_tbl           OUT     NOCOPY csi_datastructures_pub.org_units_header_tbl
     ,p_get_pricing_attribs      IN      VARCHAR2 := fnd_api.g_false
     ,p_pricing_attrib_tbl       OUT     NOCOPY csi_datastructures_pub.pricing_attribs_tbl
     ,p_get_ext_attribs          IN      VARCHAR2 := fnd_api.g_false
     ,p_ext_attrib_tbl           OUT     NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
     ,p_ext_attrib_def_tbl       OUT     NOCOPY csi_datastructures_pub.extend_attrib_tbl --added
     ,p_get_asset_assignments    IN      VARCHAR2 := fnd_api.g_false
     ,p_asset_header_tbl         OUT     NOCOPY csi_datastructures_pub.instance_asset_header_tbl
     ,p_resolve_id_columns       IN      VARCHAR2 := fnd_api.g_false
     ,p_time_stamp               IN      DATE
     ,x_return_status            OUT     NOCOPY VARCHAR2
     ,x_msg_count                OUT     NOCOPY NUMBER
     ,x_msg_data                 OUT     NOCOPY VARCHAR2
);

/*----------------------------------------------------*/
/* Pocedure name:  get_version_label                  */
/* Description :   procedure for creating             */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE get_version_labels
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_version_label_query_rec IN  csi_datastructures_pub.version_label_query_rec
     ,p_time_stamp              IN  DATE
     ,x_version_label_tbl       OUT NOCOPY csi_datastructures_pub.version_label_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2        );

/*----------------------------------------------------*/
/* Pocedure name: Create_version_label                */
/* Description :   procedure for creating             */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE create_version_label
 (    p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_version_label_tbl   IN OUT NOCOPY csi_datastructures_pub.version_label_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT    NOCOPY VARCHAR2
     ,x_msg_count           OUT    NOCOPY NUMBER
     ,x_msg_data            OUT    NOCOPY VARCHAR2              );

/*----------------------------------------------------*/
/* Procedure name: Update_version_label               */
/* Description :   procedure for Update               */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE update_version_label
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_version_label_tbl           IN     csi_datastructures_pub.version_label_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT    NOCOPY VARCHAR2
     ,x_msg_count                   OUT    NOCOPY NUMBER
     ,x_msg_data                    OUT    NOCOPY VARCHAR2    );

/*----------------------------------------------------*/
/* Procedure name: expire_version_label               */
/* Description :   procedure for expire               */
/*                 version label for                  */
/*                 an Item Instance                   */
/*----------------------------------------------------*/

PROCEDURE expire_version_label
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_version_label_tbl           IN     csi_datastructures_pub.version_label_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT    NOCOPY VARCHAR2
     ,x_msg_count                   OUT    NOCOPY NUMBER
     ,x_msg_data                    OUT    NOCOPY VARCHAR2      );

/*----------------------------------------------------*/
/* procedure name: get_extended_attrib_values         */
/* description :   Gets the extended attribute        */
/*                 values of an item instance         */
/*----------------------------------------------------*/

PROCEDURE get_extended_attrib_values
 (    p_api_version           IN     NUMBER
     ,p_commit                IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_ext_attribs_query_rec IN     csi_datastructures_pub.extend_attrib_query_rec
     ,p_time_stamp            IN     DATE
     ,x_ext_attrib_tbl           OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
     ,x_ext_attrib_def_tbl       OUT NOCOPY csi_datastructures_pub.extend_attrib_tbl  -- added
     ,x_return_status            OUT NOCOPY VARCHAR2
     ,x_msg_count                OUT NOCOPY NUMBER
     ,x_msg_data                 OUT NOCOPY VARCHAR2
 );

/*----------------------------------------------------*/
/* procedure name: create_extended_attrib_values      */
/* description :  Associates extended attribute       */
/*                values to an item instance          */
/*----------------------------------------------------*/

PROCEDURE create_extended_attrib_values
 (    p_api_version        IN     NUMBER
     ,p_commit             IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_ext_attrib_tbl     IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_tbl
     ,p_txn_rec            IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
 );

/*----------------------------------------------------*/
/* procedure name: update_extended_attrib_values      */
/* description :  Updates extended attrib values for  */
/*                for an item instance                */
/*----------------------------------------------------*/

PROCEDURE update_extended_attrib_values
 (   p_api_version         IN     NUMBER
     ,p_commit             IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_ext_attrib_tbl     IN     csi_datastructures_pub.extend_attrib_values_tbl
     ,p_txn_rec            IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
 );

/*----------------------------------------------------*/
/* procedure name: Expire_extended_attrib_values      */
/* description :  Expires extended attribute values   */
/*                for an item instance                */
/*----------------------------------------------------*/

PROCEDURE expire_extended_attrib_values
 (   p_api_version          IN     NUMBER
     ,p_commit              IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_ext_attrib_tbl      IN     csi_datastructures_pub.extend_attrib_values_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* procedure name: copy_item_instance                */
/* description :  Copies an instace from an instance */
/*                                                   */
/*                                                   */
/*---------------------------------------------------*/

/*#
 * This procedure creates a new item instance and its child entities by copying an existing
 * item instance in Oracle Install Base.
 * The child instances underneath the source instance would be copied if the parameter p_copy_inst_children
 * is set to fnd_api.g_true.
 * @param p_api_version API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_source_instance_rec Contains the source instance record that needs to be copied
 * @param p_copy_ext_attribs Determines whether to copy Extended Attributes for the instance
 * @param p_copy_org_assignments Determines whether to copy Org Assignments for the instance
 * @param p_copy_parties Determines whether to copy Parties for the instance
 * @param p_copy_party_contacts Determines whether to copy Contact Parties for the instance
 * @param p_copy_accounts Determines whether to copy Party Accounts for the instance
 * @param p_copy_asset_assignments Determines whether to copy Assets for the instance
 * @param p_copy_pricing_attribs Determines whether to copy Pricing Attributes for the instance
 * @param p_copy_inst_children Determines whether to copy child instances underneath this instance
 * @param p_txn_rec Transaction Record structure
 * @param x_new_instance_tbl Contains the new instance information
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy Item Instance
 */
PROCEDURE copy_item_instance
 (
   p_api_version            IN         NUMBER
  ,p_commit                 IN         VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec    IN         csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs       IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_org_assignments   IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_parties           IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_party_contacts    IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_accounts          IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_asset_assignments IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_pricing_attribs   IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_inst_children     IN         VARCHAR2 := fnd_api.g_false
  ,p_txn_rec                IN  OUT    NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl           OUT    NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status              OUT    NOCOPY VARCHAR2
  ,x_msg_count                  OUT    NOCOPY NUMBER
  ,x_msg_data                   OUT    NOCOPY VARCHAR2
 );

TYPE txn_oks_type_tbl is TABLE of VARCHAR2(3) INDEX BY BINARY_INTEGER;

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
        );


END CSI_ITEM_INSTANCE_PUB;

/
