--------------------------------------------------------
--  DDL for Package CSI_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ASSET_PVT" AUTHID CURRENT_USER AS
/* $Header: csivaas.pls 120.5 2006/11/17 06:38:09 sumathur noship $ */

--
TYPE LOOKUP_REC IS RECORD
  (
    lookup_code		   VARCHAR2(30)	:= FND_API.G_MISS_CHAR
   ,valid_flag		   VARCHAR2(1)	:= FND_API.G_MISS_CHAR
  );

TYPE LOOKUP_TBL IS TABLE OF LOOKUP_REC INDEX BY BINARY_INTEGER;
--
TYPE ASSET_COUNT_REC IS RECORD
  (
     asset_count       NUMBER       := FND_API.G_MISS_NUM
    ,lookup_count      NUMBER       := FND_API.G_MISS_NUM
    ,loc_count         NUMBER       := FND_API.G_MISS_NUM
  );
--
TYPE ASSET_ID_REC IS RECORD
  (
     asset_id          NUMBER       := FND_API.G_MISS_NUM
    ,asset_book_type   VARCHAR2(15) := FND_API.G_MISS_CHAR
    ,valid_flag        VARCHAR2(1)  := FND_API.G_MISS_CHAR
  );

TYPE ASSET_ID_TBL IS TABLE OF ASSET_ID_REC INDEX BY BINARY_INTEGER;
--
TYPE ASSET_LOC_REC IS RECORD
  (
     asset_loc_id      NUMBER       := FND_API.G_MISS_NUM
    ,valid_flag        VARCHAR2(1)  := FND_API.G_MISS_CHAR
  );

TYPE ASSET_LOC_TBL IS TABLE OF ASSET_LOC_REC INDEX BY BINARY_INTEGER;
--

/*-- These datastructures are added to implement asset sync --*/
TYPE instance_asset_sync_rec IS RECORD
  (
    instance_id           NUMBER  := FND_API.G_MISS_NUM,
    inst_interface_id     NUMBER  := FND_API.G_MISS_NUM,
    fa_asset_id           NUMBER  := FND_API.G_MISS_NUM,
    fa_location_id        NUMBER  := FND_API.G_MISS_NUM,
    inst_asset_quantity   NUMBER  := FND_API.G_MISS_NUM
  );
TYPE instance_asset_sync_tbl IS TABLE OF instance_asset_sync_rec INDEX BY BINARY_INTEGER;

TYPE fa_asset_sync_rec IS RECORD
  (
    fa_asset_id        NUMBER  := FND_API.G_MISS_NUM,
    fa_location_id     NUMBER  := FND_API.G_MISS_NUM,
    fa_asset_quantity  NUMBER  := FND_API.G_MISS_NUM,
    sync_up_quantity   NUMBER  := FND_API.G_MISS_NUM
  );
TYPE fa_asset_sync_tbl IS TABLE OF fa_asset_sync_rec INDEX BY BINARY_INTEGER;

TYPE instance_sync_rec IS RECORD
  (
    instance_id         NUMBER      := FND_API.G_MISS_NUM,
    inst_interface_id   NUMBER      := FND_API.G_MISS_NUM,
    instance_quantity   NUMBER      := FND_API.G_MISS_NUM,
    sync_up_quantity    NUMBER      := FND_API.G_MISS_NUM,
    vld_status          VARCHAR2(1) := FND_API.G_MISS_CHAR,
    hop                 NUMBER      := FND_API.G_MISS_NUM,
    location_id         NUMBER       := FND_API.G_MISS_NUM,
    location_type_code  VARCHAR2(30) := FND_API.G_MISS_CHAR
  );
 TYPE instance_sync_tbl IS TABLE OF instance_sync_rec INDEX BY BINARY_INTEGER;

/*--End These datastructures are added for implement asset sync --*/

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_asset_rec                    */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_asset_rec
(
  x_instance_asset_rec          IN OUT NOCOPY csi_datastructures_pub.instance_asset_header_rec,
  p_inst_asset_hist_id          IN NUMBER ,
  x_nearest_full_dump           IN OUT NOCOPY DATE
);

/*----------------------------------------------------------*/
/* Procedure name:  Construct_asset_from_hist               */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_asset_from_hist
(
  x_instance_asset_tbl      IN OUT NOCOPY csi_datastructures_pub.instance_asset_header_tbl,
  p_time_stamp              IN DATE
);

/*----------------------------------------------------------*/
/* Procedure name:  Get_Asset_Column_Values                 */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_Asset_Column_Values
(
    p_get_asset_cursor_id    IN   NUMBER      ,
    x_inst_asset_rec         OUT NOCOPY  csi_datastructures_pub.instance_asset_header_rec );

/*----------------------------------------------------------*/
/* Procedure name:  Define_Asset_Columns                    */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_Asset_Columns
(
    p_get_asset_cursor_id      IN   NUMBER             ) ;

/*----------------------------------------------------------*/
/* Procedure name:  Bind_asset_variable                     */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Bind_asset_variable
(
    p_inst_asset_query_rec   IN    csi_datastructures_pub.instance_asset_query_rec,
    p_get_asset_cursor_id    IN    NUMBER             );

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
(  p_asset_header_tbl  IN OUT NOCOPY   csi_datastructures_pub.instance_asset_header_tbl);

/*----------------------------------------------------------*/
/* Procedure name:  Gen_Asset_Where_Clause                  */
/* Description : Procedure used to  generate the where      */
/*                cluase  for Party relationship            */
/*----------------------------------------------------------*/

PROCEDURE Gen_Asset_Where_Clause
(   p_inst_asset_query_rec     IN    csi_datastructures_pub.instance_asset_query_rec
   ,x_where_clause             OUT NOCOPY   VARCHAR2           );

/*-------------------------------------------------------*/
/* procedure name: Get_instance_assets                   */
/* description :   Get information about the assets      */
/*                 associated with an item instance.     */
/*-------------------------------------------------------*/

PROCEDURE get_instance_assets
 (
      p_api_version               IN  NUMBER
     ,p_commit                    IN  VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false
     ,p_validation_level          IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_asset_query_rec  IN  csi_datastructures_pub.instance_asset_query_rec
     ,p_resolve_id_columns        IN  VARCHAR2 := fnd_api.g_false
     ,p_time_stamp                IN  DATE
     ,x_instance_asset_tbl        OUT NOCOPY csi_datastructures_pub.instance_asset_header_tbl
     ,x_return_status             OUT NOCOPY VARCHAR2
     ,x_msg_count                 OUT NOCOPY NUMBER
     ,x_msg_data                  OUT NOCOPY VARCHAR2
 );

/*-------------------------------------------------------*/
/* procedure name: Create_instance_asset                 */
/* description :  Creates new association between an     */
/*                asset and an item instance             */
/*-------------------------------------------------------*/

PROCEDURE create_instance_asset
 (
      p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN  NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_asset_rec  IN OUT NOCOPY  csi_datastructures_pub.instance_asset_rec
     ,p_txn_rec             IN OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY    VARCHAR2
     ,x_msg_count           OUT NOCOPY    NUMBER
     ,x_msg_data            OUT NOCOPY    VARCHAR2
     ,p_lookup_tbl          IN OUT NOCOPY  csi_asset_pvt.lookup_tbl
     ,p_asset_count_rec     IN OUT NOCOPY  csi_asset_pvt.asset_count_rec
     ,p_asset_id_tbl        IN OUT NOCOPY  csi_asset_pvt.asset_id_tbl
     ,p_asset_loc_tbl       IN OUT NOCOPY  csi_asset_pvt.asset_loc_tbl
     ,p_called_from_grp     IN VARCHAR2 DEFAULT fnd_api.g_false
 );

/*-------------------------------------------------------*/
/* procedure name: Update_instance_asset                 */
/* description :  Updates an existing instance-asset     */
/*                association                            */
/*-------------------------------------------------------*/

PROCEDURE update_instance_asset
 (
      p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_asset_rec  IN OUT NOCOPY csi_datastructures_pub.instance_asset_rec
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY    VARCHAR2
     ,x_msg_count           OUT NOCOPY    NUMBER
     ,x_msg_data            OUT NOCOPY    VARCHAR2
     ,p_lookup_tbl          IN OUT NOCOPY csi_asset_pvt.lookup_tbl
     ,p_asset_count_rec     IN OUT NOCOPY csi_asset_pvt.asset_count_rec
     ,p_asset_id_tbl        IN OUT NOCOPY csi_asset_pvt.asset_id_tbl
     ,p_asset_loc_tbl       IN OUT NOCOPY csi_asset_pvt.asset_loc_tbl
 );

/*-------------------------------------------------------*/
/* procedure name: get_instance_asset_hist               */
/* description :  Retreives asset history for            */
/*                a given transaction                    */
/*-------------------------------------------------------*/


PROCEDURE get_instance_asset_hist
( p_api_version         IN  NUMBER
 ,p_commit              IN  VARCHAR2 := fnd_api.g_false
 ,p_init_msg_list       IN  VARCHAR2 := fnd_api.g_false
 ,p_validation_level    IN  NUMBER   := fnd_api.g_valid_level_full
 ,p_transaction_id      IN  NUMBER
 ,x_ins_asset_hist_tbl  OUT NOCOPY csi_datastructures_pub.ins_asset_history_tbl
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
 ) ;

/*-- These procedures are added to implement asset sync --*/

PROCEDURE asset_syncup_validation
     (     px_instance_sync_tbl       IN OUT NOCOPY CSI_ASSET_PVT.instance_sync_tbl,
           px_instance_asset_sync_tbl IN OUT NOCOPY CSI_ASSET_PVT.instance_asset_sync_tbl,
           px_fa_asset_sync_tbl       IN OUT NOCOPY CSI_ASSET_PVT.fa_asset_sync_tbl,
           x_error_msg              OUT NOCOPY VARCHAR2,
           x_return_status          OUT NOCOPY VARCHAR2
     );

PROCEDURE get_attached_item_instances
     (     p_api_version                IN  NUMBER,
           p_init_msg_list              IN  VARCHAR2,
           p_instance_asset_sync_tbl    IN  CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_instance_sync_tbl          OUT NOCOPY CSI_ASSET_PVT.instance_sync_tbl,
           x_return_status              OUT NOCOPY    VARCHAR2,
           x_msg_count                  OUT NOCOPY    NUMBER,
           x_msg_data                   OUT NOCOPY    VARCHAR2,
           p_source_system_name         IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp            IN  VARCHAR2 DEFAULT fnd_api.g_false
     );

PROCEDURE get_attached_asset_links

     (     p_api_version              IN  NUMBER,
           p_init_msg_list            IN  VARCHAR2,
           p_instance_sync_tbl        IN  CSI_ASSET_PVT.instance_sync_tbl,
           x_instance_asset_sync_tbl  OUT NOCOPY CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_return_status            OUT NOCOPY    VARCHAR2,
           x_msg_count                OUT NOCOPY    NUMBER,
           x_msg_data                 OUT NOCOPY    VARCHAR2,
           p_source_system_name       IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp          IN  VARCHAR2 DEFAULT fnd_api.g_false
    );

PROCEDURE get_fa_asset_details
     (     p_api_version                IN  NUMBER,
           p_init_msg_list              IN  VARCHAR2,
           p_instance_asset_sync_tbl    IN  CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_fa_asset_sync_tab          OUT NOCOPY CSI_ASSET_PVT.fa_asset_sync_tbl,
           x_return_status              OUT NOCOPY    VARCHAR2,
           x_msg_count                  OUT NOCOPY    NUMBER,
           x_msg_data                   OUT NOCOPY    VARCHAR2,
           p_source_system_name         IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp            IN  VARCHAR2 DEFAULT fnd_api.g_false
     );

PROCEDURE Get_syncup_tree
     (     px_instance_sync_tbl          IN OUT NOCOPY CSI_ASSET_PVT.instance_sync_tbl,
           px_instance_asset_sync_tbl    IN OUT NOCOPY CSI_ASSET_PVT.instance_asset_sync_tbl,
           x_fa_asset_sync_tbl           IN OUT NOCOPY CSI_ASSET_PVT.fa_asset_sync_tbl,
           x_return_status               OUT NOCOPY    VARCHAR2,
           x_error_msg                   OUT NOCOPY    VARCHAR2,
           p_source_system_name          IN  VARCHAR2 DEFAULT NULL,
           p_called_from_grp             IN  VARCHAR2 DEFAULT fnd_api.g_false
     );
/*-- End These procedures are added to implement asset sync --*/

  PROCEDURE create_instance_assets (
    p_api_version         IN     number,
    p_commit              IN     varchar2,
    p_init_msg_list       IN     varchar2,
    p_validation_level    IN     number,
    p_instance_asset_tbl  IN OUT nocopy csi_datastructures_pub.instance_asset_tbl,
    p_txn_rec             IN OUT nocopy csi_datastructures_pub.transaction_rec,
    p_lookup_tbl          IN OUT nocopy csi_asset_pvt.lookup_tbl,
    p_asset_count_rec     IN OUT nocopy csi_asset_pvt.asset_count_rec,
    p_asset_id_tbl        IN OUT nocopy csi_asset_pvt.asset_id_tbl,
    p_asset_loc_tbl       IN OUT nocopy csi_asset_pvt.asset_loc_tbl,
    x_return_status          OUT nocopy varchar2,
    x_msg_count              OUT nocopy number,
    x_msg_data               OUT nocopy varchar2);
  --
  PROCEDURE set_fa_sync_flag (
    px_instance_asset_rec IN OUT NOCOPY csi_datastructures_pub.instance_asset_rec,
    p_location_id         IN NUMBER DEFAULT -9999, -- should be passed only from GRP API (Create)
    x_return_status       OUT NOCOPY VARCHAR2,
    x_error_msg           OUT NOCOPY VARCHAR2);
END csi_asset_pvt;

 

/
