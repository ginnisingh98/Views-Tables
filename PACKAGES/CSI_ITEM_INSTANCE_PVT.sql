--------------------------------------------------------
--  DDL for Package CSI_ITEM_INSTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ITEM_INSTANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: csiviis.pls 120.7.12010000.1 2008/07/25 08:15:58 appldev ship $ */

/*------------------------------------------------------*/
/* Declare the PL/SQL tables used by the validation API */
/*------------------------------------------------------*/
TYPE ITEM_ATTRIBUTE_REC IS RECORD
  (
    inventory_item_id           NUMBER      := FND_API.G_MISS_NUM
   ,organization_id	            NUMBER      := FND_API.G_MISS_NUM
   ,master_organization_id      NUMBER      := FND_API.G_MISS_NUM
   ,serial_number_control_code  NUMBER      := FND_API.G_MISS_NUM
   ,lot_control_code            NUMBER      := FND_API.G_MISS_NUM
   ,revision_control_code       NUMBER      := FND_API.G_MISS_NUM
   ,Uom_code                    VARCHAR2(3) := FND_API.G_MISS_CHAR
   ,Trackable_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR
   ,shelf_life_code             NUMBER      := FND_API.G_MISS_NUM
   ,valid_flag                  VARCHAR2(1) := FND_API.G_MISS_CHAR
   ,eam_item_type               NUMBER      := FND_API.G_MISS_NUM
   ,equipment_type              NUMBER      := FND_API.G_MISS_NUM
  );

TYPE ITEM_ATTRIBUTE_TBL IS TABLE OF ITEM_ATTRIBUTE_REC INDEX BY BINARY_INTEGER;
--
TYPE GENERIC_ID_REC IS RECORD
  (
     generic_id 	NUMBER	     := FND_API.G_MISS_NUM
    ,id_type		VARCHAR2(30) := FND_API.G_MISS_CHAR
    ,terminated_flag    VARCHAR2(30) := FND_API.G_MISS_CHAR
    ,valid_flag         VARCHAR2(1)  := FND_API.G_MISS_CHAR
  );

TYPE GENERIC_ID_TBL IS TABLE OF GENERIC_ID_REC INDEX BY BINARY_INTEGER;
--
TYPE LOOKUP_REC IS RECORD
  (
    lookup_code		VARCHAR2(30)	:= FND_API.G_MISS_CHAR
   ,lookup_type		VARCHAR2(30)	:= FND_API.G_MISS_CHAR
   ,valid_flag		VARCHAR2(1)	:= FND_API.G_MISS_CHAR
  );

TYPE LOOKUP_TBL IS TABLE OF LOOKUP_REC INDEX BY BINARY_INTEGER;
--
TYPE LOCATION_REC IS RECORD
   (
     location_type_code	VARCHAR2(30)		:= FND_API.G_MISS_CHAR
    ,location_id 	NUMBER			:= FND_API.G_MISS_NUM
    ,valid_flag		VARCHAR2(1)		:= FND_API.G_MISS_CHAR
   );
TYPE LOCATION_TBL IS TABLE OF LOCATION_REC INDEX BY BINARY_INTEGER;
--
TYPE INS_COUNT_REC IS RECORD
  (
     inv_count         	NUMBER   	:= FND_API.G_MISS_NUM
    ,generic_count 	NUMBER       	:= FND_API.G_MISS_NUM
    ,location_count	NUMBER       	:= FND_API.G_MISS_NUM
    ,lookup_count	NUMBER       	:= FND_API.G_MISS_NUM
  );
-- PL/SQL tables used by Explode_BOM API.
--
TYPE PARENT_CHILD_REC IS RECORD
   (
     parent_sort_order        VARCHAR2(2000)
    ,child_sort_order         VARCHAR2(2000)
   );
TYPE PARENT_CHILD_TBL IS TABLE OF PARENT_CHILD_REC INDEX BY BINARY_INTEGER;
--
TYPE BOM_SORT_ORDER_REC IS RECORD
   (
     parent_sort_order    VARCHAR2(2000),
     child_sort_order     VARCHAR2(2000),
     mark_flag            VARCHAR2(1),
     child_occurance      NUMBER
   );
--
TYPE BOM_SORT_ORDER_TBL IS TABLE OF BOM_SORT_ORDER_REC INDEX BY BINARY_INTEGER;
--
FUNCTION Is_Parent(
		    p_child_sort_order   VARCHAR2
		   ,p_parent_child_tbl   csi_item_instance_pvt.parent_child_tbl
		  )
RETURN BOOLEAN;
--
PROCEDURE Get_parent_sort_order
   (
     p_parent_sort_order   IN OUT NOCOPY VARCHAR2
    ,p_parent_child_tbl    IN csi_item_instance_pvt.parent_child_tbl
    ,p_bom_sort_order_tbl  IN csi_item_instance_pvt.bom_sort_order_tbl
   );
--
FUNCTION Has_Trackable_Component
   (
     p_inventory_item_id   IN NUMBER
    ,p_organization_id     IN NUMBER
    ,p_explosion_level     IN NUMBER
   ) RETURN BOOLEAN;
--
TYPE MAP_INST_REC IS RECORD
   (
     old_instance_id        NUMBER
    ,new_instance_id        NUMBER
   );
TYPE MAP_INST_TBL IS TABLE OF MAP_INST_REC INDEX BY BINARY_INTEGER;
--
TYPE OWNER_PTY_ACCT_REC IS RECORD
   ( instance_id            NUMBER
    ,party_source_table     VARCHAR2(30)
    ,party_id               NUMBER
    ,account_id             NUMBER
    ,vld_organization_id    NUMBER
   );
TYPE OWNER_PTY_ACCT_TBL IS TABLE OF OWNER_PTY_ACCT_REC INDEX BY BINARY_INTEGER;
--
TYPE T_NUM IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE T_V30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
--
TYPE OWNER_PTY_ACCT_REC_TAB IS RECORD
   (
     instance_id             T_NUM
    ,party_source_table      T_V30
    ,party_id                T_NUM
    ,account_id              T_NUM
   );
--
/*--------------------------------------------------*/
/* procedure name: create_item_instance             */
/* description :   procedure used to                */
/*                 create item instances            */
/*                                                  */
/*--------------------------------------------------*/

TYPE lock_instances_rec IS RECORD
  (
     instance_id             NUMBER  := fnd_api.g_miss_num
    ,root_instance_id        NUMBER  := fnd_api.g_miss_num
    ,lock_id                 NUMBER  := fnd_api.g_miss_num
    ,lock_status             NUMBER  := fnd_api.g_miss_num
    ,source_application_id   NUMBER  := fnd_api.g_miss_num
    ,source_txn_header_ref   VARCHAR2(30) := fnd_api.g_miss_char
    ,source_txn_line_ref1    VARCHAR2(30) := fnd_api.g_miss_char
    ,source_txn_line_ref2    VARCHAR2(30) := fnd_api.g_miss_char
    ,source_txn_line_ref3    VARCHAR2(30) := fnd_api.g_miss_char
    ,config_inst_hdr_id      NUMBER := fnd_api.g_miss_num
    ,config_inst_item_id     NUMBER := fnd_api.g_miss_num
    ,config_inst_rev_num     NUMBER := fnd_api.g_miss_num
    ,root_config_inst_hdr_id NUMBER := fnd_api.g_miss_num
    ,root_config_inst_item_id NUMBER := fnd_api.g_miss_num
    ,root_config_inst_rev_num NUMBER := fnd_api.g_miss_num
  );

TYPE lock_instances_tbl IS TABLE OF lock_instances_rec INDEX BY BINARY_INTEGER;

TYPE lock_config_rec IS RECORD
  (
     config_inst_hdr_id      NUMBER := fnd_api.g_miss_num
    ,config_inst_item_id     NUMBER := fnd_api.g_miss_num
    ,config_inst_rev_num     NUMBER := fnd_api.g_miss_num
  );

FUNCTION check_item_instance_lock
(    p_instance_id         IN      NUMBER :=fnd_api.g_miss_num,
     p_config_inst_hdr_id  IN      NUMBER :=fnd_api.g_miss_num,
     p_config_inst_item_id IN      NUMBER :=fnd_api.g_miss_num,
     p_config_inst_rev_num IN      NUMBER :=fnd_api.g_miss_num
) RETURN BOOLEAN;

PROCEDURE get_instance_lock_status
(    p_instance_id         IN   NUMBER ,
     p_lock_status         OUT  NOCOPY NUMBER
);
PROCEDURE lock_item_instances
 (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER := fnd_api.g_valid_level_full
    ,px_config_tbl           IN   OUT NOCOPY csi_cz_int.config_tbl
--    ,p_txn_rec               IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
 );

PROCEDURE unlock_item_instances
 (
     p_api_version           IN   NUMBER
    ,p_commit                IN   VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN   VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN   NUMBER := fnd_api.g_valid_level_full
    ,p_config_tbl            IN   csi_cz_int.config_tbl
    ,p_unlock_all            IN   VARCHAR2 :=fnd_api.g_false
--    ,p_txn_rec               IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
 );

PROCEDURE create_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN OUT NOCOPY csi_datastructures_pub.instance_rec
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_asset_tbl             IN OUT NOCOPY csi_datastructures_pub.instance_asset_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
    ,p_item_attribute_tbl    IN OUT NOCOPY csi_item_instance_pvt.item_attribute_tbl
    ,p_location_tbl          IN OUT NOCOPY csi_item_instance_pvt.location_tbl
    ,p_generic_id_tbl        IN OUT NOCOPY csi_item_instance_pvt.generic_id_tbl
    ,p_lookup_tbl            IN OUT NOCOPY csi_item_instance_pvt.lookup_tbl
    ,p_ins_count_rec         IN OUT NOCOPY csi_item_instance_pvt.ins_count_rec
    ,p_called_from_grp       IN     VARCHAR2 DEFAULT fnd_api.g_false
    ,p_internal_party_id     IN     NUMBER DEFAULT -9999
 );

/*---------------------------------------------------*/
/* Procedure name: update_item_instance              */
/* Description :   procedure used to update an Item  */
/*                 Instance                          */
/*---------------------------------------------------*/

PROCEDURE update_item_instance
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_rec        IN OUT  NOCOPY csi_datastructures_pub.instance_rec
     ,p_txn_rec             IN OUT  NOCOPY csi_datastructures_pub.transaction_rec

     ,x_instance_id_lst     OUT     NOCOPY csi_datastructures_pub.id_tbl
     ,x_return_status       OUT     NOCOPY VARCHAR2
     ,x_msg_count           OUT     NOCOPY NUMBER
     ,x_msg_data            OUT     NOCOPY VARCHAR2
     ,p_item_attribute_tbl  IN OUT NOCOPY csi_item_instance_pvt.item_attribute_tbl

     ,p_location_tbl        IN OUT NOCOPY csi_item_instance_pvt.location_tbl
     ,p_generic_id_tbl      IN OUT NOCOPY csi_item_instance_pvt.generic_id_tbl
     ,p_lookup_tbl          IN OUT NOCOPY csi_item_instance_pvt.lookup_tbl
     ,p_ins_count_rec       IN OUT NOCOPY csi_item_instance_pvt.ins_count_rec
     ,p_called_from_rel     IN     VARCHAR2 DEFAULT fnd_api.g_false
     ,p_validation_mode     IN     VARCHAR2 DEFAULT 'A'
     ,p_oks_txn_inst_tbl    IN OUT NOCOPY oks_ibint_pub.txn_instance_tbl
     ,p_child_inst_tbl      IN OUT NOCOPY csi_item_instance_grp.child_inst_tbl
 );

/*---------------------------------------------------*/
/* Procedure name: expire_item_instance              */
/* Description :   procedure for                     */
/*                 Expiring an Item Instance         */
/*---------------------------------------------------*/

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
     ,p_oks_txn_inst_tbl    IN OUT NOCOPY oks_ibint_pub.txn_instance_tbl
     ,x_return_status       OUT     NOCOPY VARCHAR2
     ,x_msg_count           OUT     NOCOPY NUMBER
     ,x_msg_data            OUT     NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* Procedure name:  Get_Inst_Column_Values           */
/* Description   :  This procedure gets the column   */
/*                  values for the Dynamic SQL       */
/*---------------------------------------------------*/

PROCEDURE Get_Inst_Column_Values
(
    p_get_inst_cursor_id      IN   NUMBER,
    x_instance_id             OUT  NOCOPY NUMBER  );

/*---------------------------------------------------*/
/* Procedure name:  Initialize_inst_rec              */
/* Description :    This procudure recontructs the   */
/*                  record from the history          */
/*---------------------------------------------------*/

PROCEDURE Initialize_inst_rec
(
  x_instance_rec                IN OUT NOCOPY csi_datastructures_pub.instance_header_rec,
  p_instance_hist_id            IN     NUMBER ,
  x_nearest_full_dump           IN OUT NOCOPY DATE  ) ;

/*---------------------------------------------------*/
/* Procedure name:  Construct_inst_from_hist         */
/* Description :    This procudure recontructs the   */
/*                  record from the history          */
/*---------------------------------------------------*/

PROCEDURE Construct_inst_from_hist
(
  x_instance_rec           IN OUT NOCOPY csi_datastructures_pub.instance_header_rec,
  p_time_stamp             IN     DATE                                      ) ;

/*---------------------------------------------------*/
/* Procedure name:  Construct_inst_header_rec        */
/* Description   :  This procedure defines the       */
/*                  columns for the Dynamic SQL      */
/*---------------------------------------------------*/

PROCEDURE Construct_inst_header_rec
(
  p_inst_id                 IN   NUMBER,
  x_instance_header_tbl     IN OUT NOCOPY  csi_datastructures_pub.instance_header_tbl );

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_Id_Columns                      */
/* Description   :  This procedure gets the column values   */
/*                  for the Dynamic SQL                     */
/*----------------------------------------------------------*/

PROCEDURE Resolve_id_columns
           (p_instance_header_tbl  IN OUT NOCOPY csi_datastructures_pub.instance_header_tbl);

/*---------------------------------------------------*/
/* Procedure name:  Define_Inst_Columns              */
/* Description   :  This procedure defines the       */
/*                  columns for the Dynamic SQL      */
/*---------------------------------------------------*/

PROCEDURE Define_Inst_Columns
(
  p_get_inst_cursor_id      IN   NUMBER,
  p_instance_query_rec      IN   csi_datastructures_pub.instance_query_rec );

/*---------------------------------------------------*/
/* Procedure name:  Bind_Inst_variable               */
/* Description :    Procedure used to generate the   */
/*                  where clause for the Dynamic SQL */
/*---------------------------------------------------*/

PROCEDURE Bind_Inst_variable
(
    p_instance_query_rec        IN   csi_datastructures_pub.instance_query_rec,
    p_party_query_rec           IN   csi_datastructures_pub.party_query_rec,
    p_pty_acct_query_rec        IN   csi_datastructures_pub.party_account_query_rec,
    p_transaction_id            IN   NUMBER,
    p_cur_get_inst_rel          IN   NUMBER
);

/*---------------------------------------------------*/
/* Procedure name:  Gen_Inst_Where_Clause            */
/* Description :    Procedure used to  build the     */
/*                  where clause  Dynamic SQL        */
/*---------------------------------------------------*/

PROCEDURE Gen_Inst_Where_Clause
(
    p_instance_query_rec    IN      csi_datastructures_pub.instance_query_rec,
    p_party_query_rec       IN      csi_datastructures_pub.party_query_rec,
    p_pty_acct_query_rec    IN      csi_datastructures_pub.party_account_query_rec,
    p_transaction_id        IN      NUMBER,
    x_select_stmt           OUT     NOCOPY VARCHAR2,
    p_active_instance_only  IN      VARCHAR2
);

/*---------------------------------------------------*/
/* Procedure name:  Get_Instance_Column_Values       */
/* Description   :  This procedure gets the column   */
/*                  values for the Dynamic SQL       */
/*---------------------------------------------------*/

PROCEDURE Get_Instance_Col_Values
(
    p_get_instance_cur_id      IN       NUMBER,
    x_instance_rec             IN OUT   NOCOPY csi_datastructures_pub.instance_header_rec
);

/*---------------------------------------------------*/
/* Procedure name:  Define_Instance_Columns          */
/* Description   :  This procedure defines the       */
/*                  columns for the Dynamic SQL      */
/*---------------------------------------------------*/

PROCEDURE Define_Instance_Columns
(
  p_get_instance_cur_id      IN   NUMBER
);

/*---------------------------------------------------*/
/* Procedure name:  Anything_To_Update               */
/* Description   :  This function  checks if any of  */
/*                  the columns related to instance  */
/*                  are changing                     */
/*---------------------------------------------------*/

FUNCTION Anything_To_Update
(
 p_instance_rec    csi_datastructures_pub.instance_rec
)
RETURN BOOLEAN;

/*----------------------------------------------------*/
/*  This Procedure validates the accounting class code*/
/*  depending upon the location type code             */
/*----------------------------------------------------*/

PROCEDURE get_and_update_acct_class
( p_api_version          IN      NUMBER
 ,p_commit               IN      VARCHAR2 := fnd_api.g_false
 ,p_init_msg_list        IN      VARCHAR2 := fnd_api.g_false
 ,p_validation_level     IN      NUMBER   := fnd_api.g_valid_level_full
 ,p_instance_id          IN      NUMBER
 ,p_instance_expiry_flag IN      VARCHAR2 :=  fnd_api.g_true
 ,p_txn_rec              IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
 ,x_acct_class_code      OUT     NOCOPY VARCHAR2
 ,x_return_status        OUT     NOCOPY VARCHAR2
 ,x_msg_count            OUT     NOCOPY NUMBER
 ,x_msg_data             OUT     NOCOPY VARCHAR2
);

/*---------------------------------------------------*/
/* Procedure name:  Bind_Instance_variable           */
/* Description :    Procedure used to generate the   */
/*                  where clause for Item Instances  */
/*---------------------------------------------------*/

PROCEDURE Bind_Instance_variable
(
    p_instance_rec              IN   csi_datastructures_pub.instance_header_rec,
    p_cur_get_instance_rel      IN   NUMBER
);

/*---------------------------------------------------*/
/* Procedure name:  Split_Item_Instance              */
/* Description   :  This procedure is used to create */
/*                  split lines for instance         */
/*---------------------------------------------------*/

PROCEDURE Split_Item_Instance
 (
   p_api_version                  IN      NUMBER
  ,p_commit                       IN      VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list                IN      VARCHAR2 := fnd_api.g_false
  ,p_validation_level             IN      NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec          IN OUT  NOCOPY csi_datastructures_pub.instance_rec
  ,p_quantity1                    IN      NUMBER
  ,p_quantity2                    IN      NUMBER
  ,p_copy_ext_attribs             IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_org_assignments         IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_parties                 IN      VARCHAR2 := fnd_api.g_true
--  ,p_copy_contacts                IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_accounts                IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_asset_assignments       IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_pricing_attribs         IN      VARCHAR2 := fnd_api.g_true
  ,p_txn_rec                      IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_rec             OUT     NOCOPY csi_datastructures_pub.instance_rec
  ,x_return_status                OUT     NOCOPY VARCHAR2
  ,x_msg_count                    OUT     NOCOPY NUMBER
  ,x_msg_data                     OUT     NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* Procedure name:  Split_Item_Instance_lines        */
/* Description   :  This procedure is used to create */
/*                  split lines for instance         */
/*---------------------------------------------------*/
 PROCEDURE Split_Item_Instance_Lines
 (
   p_api_version                 IN      NUMBER
  ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
  ,p_validation_level            IN      NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec         IN OUT  NOCOPY csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs            IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_org_assignments        IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_parties                IN      VARCHAR2 := fnd_api.g_true
--  ,p_copy_contacts               IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_accounts               IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_asset_assignments      IN      VARCHAR2 := fnd_api.g_true
  ,p_copy_pricing_attribs        IN      VARCHAR2 := fnd_api.g_true
  ,p_txn_rec                     IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl            OUT     NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status               OUT     NOCOPY VARCHAR2
  ,x_msg_count                   OUT     NOCOPY NUMBER
  ,x_msg_data                    OUT     NOCOPY VARCHAR2
 );

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_ver_rec_no_dump              */
/* Description : This procedure initializes the first       */
/*                 record from the history                  */
/*----------------------------------------------------------*/

PROCEDURE Initialize_ver_rec_no_dump
(
  x_version_label_rec      IN OUT NOCOPY csi_datastructures_pub.version_label_rec,
  p_version_label_id       IN NUMBER ,
  x_no_dump                IN OUT NOCOPY DATE
  );

/*---------------------------------------------------*/
/* Procedure name:  Initialize_ver_rec               */
/* Description :    This procudure recontructs the   */
/*                  record from the history          */
/*---------------------------------------------------*/

PROCEDURE Initialize_ver_rec
(
  x_version_label_rec           IN OUT NOCOPY csi_datastructures_pub.version_label_rec,
  p_version_label_hist_id       IN     NUMBER ,
  x_nearest_full_dump           IN OUT NOCOPY DATE  ) ;

/*---------------------------------------------------*/
/* Procedure name:  Construct_ver_from_hist          */
/* Description :    This procudure recontructs the   */
/*                  record from the history          */
/*---------------------------------------------------*/

PROCEDURE Construct_ver_from_hist
(
  x_version_label_tbl      IN OUT NOCOPY csi_datastructures_pub.version_label_tbl,
  p_time_stamp             IN     DATE                                ) ;

/*---------------------------------------------------*/
/* Procedure name:  Get_Ver_Column_Values            */
/* Description :    This procudure gets the column   */
/*                  values for the Dynamic SQL       */
/*---------------------------------------------------*/

PROCEDURE Get_Ver_Column_Values
(
    p_get_ver_cursor_id    IN   NUMBER      ,
    x_ver_label_query_rec  OUT  NOCOPY csi_datastructures_pub.version_label_rec );

/*---------------------------------------------------*/
/* Procedure name:  Define_Ver_Columns               */
/* Description :    This procudure defines the       */
/*                  columns for the Dynamic SQL      */
/*---------------------------------------------------*/

PROCEDURE Define_Ver_Columns
(
    p_get_ver_cursor_id      IN   NUMBER             ) ;

/*---------------------------------------------------*/
/* Procedure name:Bind_Ver_variable                  */
/* Description : Procedure used to  generate the     */
/*               where clause for Party relationship */
/*---------------------------------------------------*/

PROCEDURE Bind_Ver_variable
(
    p_ver_label_query_rec  IN    csi_datastructures_pub.version_label_query_rec,
    p_get_ver_cursor_id    IN    NUMBER             );

/*---------------------------------------------------*/
/* Procedure name:Gen_Ver_Where_Clause               */
/* Description : Procedure used to  generate the     */
/*               where cluase for Party relationship */
/*---------------------------------------------------*/

PROCEDURE Gen_Ver_Where_Clause
(   p_ver_label_query_rec      IN    csi_datastructures_pub.version_label_query_rec
   ,x_where_clause             OUT   NOCOPY VARCHAR2           );

/*---------------------------------------------------*/
/* Pocedure name:  Create_version_label              */
/* Description :   procedure for creating            */
/*                 version label for                 */
/*                 an Item Instance                  */
/*---------------------------------------------------*/

PROCEDURE create_version_label
 (    p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_version_label_rec   IN OUT  NOCOPY csi_datastructures_pub.version_label_rec
     ,p_txn_rec             IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT     NOCOPY VARCHAR2
     ,x_msg_count           OUT     NOCOPY NUMBER
     ,x_msg_data            OUT     NOCOPY VARCHAR2         );

/*---------------------------------------------------*/
/* Procedure name: Update_version_label              */
/* Description :   procedure for Update              */
/*                 version label for                 */
/*                 an Item Instance                  */
/*---------------------------------------------------*/

PROCEDURE update_version_label
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_version_label_rec           IN      csi_datastructures_pub.version_label_rec
     ,p_txn_rec                     IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
     ,p_call_transaction            IN      VARCHAR2 := fnd_api.g_true
     ,x_return_status               OUT     NOCOPY VARCHAR2
     ,x_msg_count                   OUT     NOCOPY NUMBER
     ,x_msg_data                    OUT     NOCOPY VARCHAR2    );

/*---------------------------------------------------*/
/* Procedure name: expire_version_label              */
/* Description :   procedure for expire              */
/*                 version label for                 */
/*                 an Item Instance                  */
/*---------------------------------------------------*/

PROCEDURE expire_version_label
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_version_label_rec           IN      csi_datastructures_pub.version_label_rec
     ,p_txn_rec                     IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT     NOCOPY VARCHAR2
     ,x_msg_count                   OUT     NOCOPY NUMBER
     ,x_msg_data                    OUT     NOCOPY VARCHAR2    );

--
TYPE EXT_COUNT_REC IS RECORD
  (
     ext_count         NUMBER   	:= FND_API.G_MISS_NUM
    ,ext_attr_count    NUMBER       := FND_API.G_MISS_NUM
    ,ext_cat_count     NUMBER       := FND_API.G_MISS_NUM
  );
--
TYPE EXT_ID_REC IS RECORD
  (
     instance_id	   NUMBER	    := FND_API.G_MISS_NUM
    ,inv_item_id       NUMBER       := FND_API.G_MISS_NUM
    ,inv_mast_org_id   NUMBER       := FND_API.G_MISS_NUM
    ,valid_flag		   VARCHAR2(1)	:= FND_API.G_MISS_CHAR
  );
TYPE EXT_ID_TBL IS TABLE OF EXT_ID_REC INDEX BY BINARY_INTEGER;
--
TYPE EXT_ATTR_REC IS RECORD
  (
     instance_id	   NUMBER	    := FND_API.G_MISS_NUM
    ,inv_item_id       NUMBER       := FND_API.G_MISS_NUM
    ,inv_mast_org_id   NUMBER       := FND_API.G_MISS_NUM
    ,attribute_id      NUMBER       := FND_API.G_MISS_NUM
    ,attribute_level   VARCHAR2(15) := FND_API.G_MISS_CHAR
    ,item_category_id  NUMBER       := FND_API.G_MISS_NUM
    ,valid_flag		   VARCHAR2(1)	:= FND_API.G_MISS_CHAR
  );
TYPE EXT_ATTR_TBL IS TABLE OF EXT_ATTR_REC INDEX BY BINARY_INTEGER;
--
TYPE EXT_CAT_REC IS RECORD
  (
     inv_item_id       NUMBER      := FND_API.G_MISS_NUM
    ,inv_mast_org_id   NUMBER      := FND_API.G_MISS_NUM
    ,item_cat_id       NUMBER      := FND_API.G_MISS_NUM
    ,valid_flag        VARCHAR2(1) := FND_API.G_MISS_CHAR
  );
TYPE EXT_CAT_TBL IS TABLE OF EXT_CAT_REC INDEX BY BINARY_INTEGER;
--

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_ext_rec_no_dump              */
/* Description : This procedure initialises the first       */
/*                  record from the history                 */
/*----------------------------------------------------------*/

PROCEDURE Initialize_ext_rec_no_dump
(
 x_ext_rec               IN OUT  NOCOPY csi_datastructures_pub.extend_attrib_values_rec,
 p_ext_id              IN      NUMBER,
 x_no_dump     IN OUT  NOCOPY DATE
);

/*---------------------------------------------------*/
/* Procedure name:  Initialize_ext_rec               */
/* Description : This procudure recontructs the      */
/*               record from the history             */
/*---------------------------------------------------*/

PROCEDURE Initialize_ext_rec
(x_ext_rec            IN OUT  NOCOPY csi_datastructures_pub.extend_attrib_values_rec,
 p_ext_h_id           IN      NUMBER,
x_nearest_full_dump   IN OUT  NOCOPY DATE
);

/*---------------------------------------------------*/
/* Procedure name:  Construct_ext_from_hist          */
/* Description : This procudure recontructs the      */
/*               record from the history             */
/*---------------------------------------------------*/

PROCEDURE Construct_ext_from_hist
( x_ext_tbl      IN OUT   NOCOPY csi_datastructures_pub.extend_attrib_values_tbl,
  p_time_stamp   IN       DATE
 );

/*---------------------------------------------------*/
/* Procedure name:  Define_ext_Columns               */
/* Description : This procudure defines the columns  */
/*                        for the Dynamic SQL        */
/*---------------------------------------------------*/

PROCEDURE Define_ext_Columns
(  p_get_ext_cursor_id      IN   NUMBER);

/*---------------------------------------------------*/
/* Procedure name:  Get_ext_Column_Values            */
/* Description : This procudure gets the column      */
/*               values for the Dynamic SQL          */
/*---------------------------------------------------*/

PROCEDURE Get_ext_Column_Values
   ( p_get_ext_cursor_id   IN       NUMBER,
     x_ext_rec                OUT  NOCOPY csi_datastructures_pub.extend_attrib_values_rec
    );

/*---------------------------------------------------*/
/* Procedure name:  Bind_ext_variable                */
/* Description : This procudure binds the column     */
/*               values for the Dynamic SQL          */
/*---------------------------------------------------*/

PROCEDURE Bind_ext_variable
  ( p_ext_query_rec    IN    csi_datastructures_pub.extend_attrib_query_rec,
    p_cur_get_ext      IN    NUMBER
   );

/*---------------------------------------------------*/
/* Procedure name:  Gen_ext_Where_Clause             */
/* Description : Procedure used to generate the      */
/*               where clause for Extended           */
/*               Attribute units                     */
/*---------------------------------------------------*/

PROCEDURE Gen_ext_Where_Clause
 (  p_ext_query_rec   IN   csi_datastructures_pub.extend_attrib_query_rec
   ,x_where_clause    OUT  NOCOPY VARCHAR2
  );

/*---------------------------------------------------*/
/* procedure name: create_extended_attrib_values     */
/* description :  Associates extended attributes to  */
/*                an item instance                   */
/*                                                   */
/*---------------------------------------------------*/

PROCEDURE create_extended_attrib_values
 (    p_api_version        IN     NUMBER
     ,p_commit             IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_ext_attrib_rec     IN OUT NOCOPY csi_datastructures_pub.extend_attrib_values_rec
     ,p_txn_rec            IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
     ,p_ext_id_tbl         IN OUT NOCOPY csi_item_instance_pvt.ext_id_tbl
     ,p_ext_count_rec      IN OUT NOCOPY csi_item_instance_pvt.ext_count_rec
     ,p_ext_attr_tbl       IN OUT NOCOPY csi_item_instance_pvt.ext_attr_tbl
     ,p_ext_cat_tbl        IN OUT NOCOPY csi_item_instance_pvt.ext_cat_tbl
     ,p_called_from_grp    IN     VARCHAR2 DEFAULT fnd_api.g_false
 );

/*---------------------------------------------------*/
/* procedure name: update_extended_attrib_values     */
/* description :  Updates the existing extended      */
/*                attributes for an item instance    */
/*                                                   */
/*---------------------------------------------------*/

PROCEDURE update_extended_attrib_values
 (    p_api_version        IN       NUMBER
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
     ,p_ext_attrib_rec     IN       csi_datastructures_pub.extend_attrib_values_rec
     ,p_txn_rec            IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* procedure name: expire_extended_attrib_values     */
/* description :  Expires the existing extended      */
/*                attributes for an item instance    */
/*                                                   */
/*---------------------------------------------------*/

PROCEDURE expire_extended_attrib_values
 (    p_api_version        IN       NUMBER
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
     ,p_ext_attrib_rec     IN       csi_datastructures_pub.extend_attrib_values_rec
     ,p_txn_rec            IN   OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* procedure name: copy_item_instance_old            */
/* description :  Copies an instace from an instance */
/*                                                   */
/*---------------------------------------------------*/

PROCEDURE copy_single_item_instance
 (
   p_api_version            IN         NUMBER
  ,p_commit                 IN         VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec    IN         csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs       IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_org_assignments   IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_parties           IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_contacts          IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_accounts          IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_asset_assignments IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_pricing_attribs   IN         VARCHAR2 := fnd_api.g_false
  ,p_call_from_split        IN         VARCHAR2 := fnd_api.g_false
  ,p_call_from_bom_expl     IN         VARCHAR2 DEFAULT fnd_api.g_false -- should be passed only from Explode BOM
  ,p_txn_rec                IN  OUT    NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl           OUT    NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status              OUT    NOCOPY VARCHAR2
  ,x_msg_count                  OUT    NOCOPY NUMBER
  ,x_msg_data                   OUT    NOCOPY VARCHAR2
 );

/*-------------------------------------------------------------*/
/* Procedure name:  Explode_Bom                                */
/* Description :    This procudure explodes the BOM and        */
/*                  creates instances and relationships        */
/*                  The parameter p_create_instance determines */
/*                  whether to create instances or not.        */
/* Author      :    Srinivasan Ramakrishnan                    */
/*-------------------------------------------------------------*/

PROCEDURE Explode_Bom
 (
   p_api_version            IN     NUMBER
  ,p_commit                 IN     VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list          IN     VARCHAR2 := fnd_api.g_false
  ,p_validation_level       IN     NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec    IN     csi_datastructures_pub.instance_rec
  ,p_explosion_level        IN     NUMBER
  ,p_item_tbl               OUT    NOCOPY csi_datastructures_pub.instance_tbl
  ,p_item_relation_tbl      OUT    NOCOPY csi_datastructures_pub.ii_relationship_tbl
  ,p_create_instance        IN     VARCHAR2 DEFAULT FND_API.G_FALSE
  ,p_txn_rec                IN OUT NOCOPY csi_datastructures_pub.transaction_rec
  ,x_return_status          OUT    NOCOPY VARCHAR2
  ,x_msg_count              OUT    NOCOPY NUMBER
  ,x_msg_data               OUT    NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* procedure name: get_instance_hist                 */
/* description   : Retreive history transactions     */
/*                 for an instance                   */
/*---------------------------------------------------*/

PROCEDURE get_instance_hist
( p_api_version           IN  NUMBER
 ,p_commit                IN  VARCHAR2 := fnd_api.g_false
 ,p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false
 ,p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full
 ,p_transaction_id        IN  NUMBER
 ,x_instance_history_tbl  OUT NOCOPY csi_datastructures_pub.instance_history_tbl
 ,x_return_status         OUT NOCOPY VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
 );

/*---------------------------------------------------*/
/* procedure name: call_to_contracts                 */
/* description   : call_to_contracts                 */
/*                                                   */
/*---------------------------------------------------*/


PROCEDURE Call_to_Contracts
(  p_transaction_type         IN   VARCHAR2
  ,p_instance_id              IN   NUMBER
  ,p_new_instance_id          IN   NUMBER
  ,p_vld_org_id               IN   NUMBER
  ,p_quantity                 IN   NUMBER
  ,p_party_account_id1        IN   NUMBER
  ,p_party_account_id2        IN   NUMBER
  ,p_transaction_date         IN   DATE   := fnd_api.g_miss_date
  ,p_source_transaction_date  IN   DATE   := fnd_api.g_miss_date  -- Added by jpwilson
  ,p_transaction_id           IN   NUMBER := fnd_api.g_miss_num  -- Added by sguthiva for TRF(HTML)
  ,p_grp_call_contracts       IN   VARCHAR2 DEFAULT fnd_api.g_false
  ,p_txn_type_id              IN   NUMBER DEFAULT fnd_api.g_miss_num
  ,p_system_id                IN   NUMBER DEFAULT fnd_api.g_miss_num -- OKS Enhancement
  ,p_order_line_id            IN   NUMBER DEFAULT fnd_api.g_miss_num -- should be passed only when un-expiring an Instance
  ,p_call_from_bom_expl       IN   VARCHAR2 DEFAULT fnd_api.g_false
  ,p_oks_txn_inst_tbl         IN OUT NOCOPY oks_ibint_pub.txn_instance_tbl
  ,x_return_status            OUT  NOCOPY VARCHAR2
  ,x_msg_count                OUT  NOCOPY NUMBER
  ,x_msg_data                 OUT  NOCOPY VARCHAR2
  );

/*---------------------------------------------------*/
/* procedure name: get_ext_attrib_val_hist           */
/* description   : Retreive history transactions     */
/*                 for extended attribute values     */
/*---------------------------------------------------*/

PROCEDURE get_ext_attrib_val_hist
( p_api_version             IN  NUMBER
 ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
 ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
 ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
 ,p_transaction_id          IN  NUMBER
 ,x_ext_attrib_val_hist_tbl OUT NOCOPY csi_datastructures_pub.ext_attrib_val_history_tbl
 ,x_return_status           OUT NOCOPY VARCHAR2
 ,x_msg_count               OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
 );

/*------------------------------------------------------*/
/* procedure name: copy_item_instance                   */
/* description :  Copies an instace from an instance.   */
/*                It has the configuration parameter    */
/*------------------------------------------------------*/


PROCEDURE copy_item_instance
 ( p_api_version            IN         NUMBER
  ,p_commit                 IN         VARCHAR2 := fnd_api.g_false
  ,p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
  ,p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
  ,p_source_instance_rec    IN         csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs       IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_org_assignments   IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_parties           IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_contacts          IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_accounts          IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_asset_assignments IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_pricing_attribs   IN         VARCHAR2 := fnd_api.g_false
  ,p_copy_inst_children     IN         VARCHAR2 := fnd_api.g_false
  ,p_call_from_split        IN         VARCHAR2 := fnd_api.g_false
  ,p_txn_rec                IN  OUT    NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl           OUT    NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status              OUT    NOCOPY VARCHAR2
  ,x_msg_count                  OUT    NOCOPY NUMBER
  ,x_msg_data                   OUT    NOCOPY VARCHAR2
 );



/*------------------------------------------------------------*/
/* Procedure name:   get_version_label_history                */
/* Description :     Procedure used to  get version lables    */
/*                   from history given a transaction_id      */
/*------------------------------------------------------------*/

PROCEDURE get_version_label_history
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_transaction_id          IN  NUMBER
     ,x_version_label_hist_tbl  OUT NOCOPY csi_datastructures_pub.version_label_history_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
    );

/*----------------------------------------------------*/
/* Procedure name: get_instance_link_locations        */
/* Description :   procedure to                       */
/*                 get an Item Instance               */
/*----------------------------------------------------*/

PROCEDURE get_instance_link_locations
 (
      p_api_version          IN  NUMBER
     ,p_commit               IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level     IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_id          IN  NUMBER
     ,x_instance_link_rec    OUT NOCOPY csi_datastructures_pub.instance_link_rec
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
    );

PROCEDURE Update_version_time
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT NOCOPY   VARCHAR2
    ,x_msg_count             OUT NOCOPY   NUMBER
    ,x_msg_data              OUT NOCOPY   VARCHAR2);

END CSI_ITEM_INSTANCE_PVT;

/
