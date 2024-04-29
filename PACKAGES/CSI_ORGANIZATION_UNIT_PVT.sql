--------------------------------------------------------
--  DDL for Package CSI_ORGANIZATION_UNIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ORGANIZATION_UNIT_PVT" AUTHID CURRENT_USER AS
/* $Header: csivous.pls 115.19 2003/09/04 00:47:39 sguthiva ship $ */

--
TYPE LOOKUP_REC IS RECORD
  (
    lookup_code		VARCHAR2(30)	:= FND_API.G_MISS_CHAR
   ,valid_flag		VARCHAR2(1)	    := FND_API.G_MISS_CHAR
  );

TYPE LOOKUP_TBL IS TABLE OF LOOKUP_REC INDEX BY BINARY_INTEGER;
--
TYPE OU_COUNT_REC IS RECORD
  (
     ou_count       NUMBER   	    := FND_API.G_MISS_NUM
    ,lookup_count	NUMBER       	:= FND_API.G_MISS_NUM
  );
--
TYPE OU_ID_REC IS RECORD
  (
    ou_id		    NUMBER	        := FND_API.G_MISS_NUM
   ,valid_flag		VARCHAR2(1)	    := FND_API.G_MISS_CHAR
  );

TYPE OU_ID_TBL IS TABLE OF OU_ID_REC INDEX BY BINARY_INTEGER;
--
/*----------------------------------------------------------*/
/* Procedure name:  Initialize_ou_rec_no_dump               */
/* Description : This gets the first record from history    */
/*                                                          */
/*----------------------------------------------------------*/

PROCEDURE Initialize_ou_rec_no_dump
(
 x_ou_rec               IN OUT NOCOPY  csi_datastructures_pub.org_units_header_rec,
 p_ou_id                IN      NUMBER,
 x_first_no_dump        IN OUT NOCOPY  DATE
);


/*----------------------------------------------------------*/
/* Procedure name:  Initialize_ou_rec                       */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_ou_rec
  ( x_ou_rec                IN OUT NOCOPY  csi_datastructures_pub.org_units_header_rec,
    p_ou_h_id               IN      NUMBER,
    x_nearest_full_dump     IN OUT NOCOPY  DATE
  );


/*----------------------------------------------------------*/
/* Procedure name:  Construct_ou_from_hist                  */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_ou_from_hist
  ( x_ou_tbl           IN OUT NOCOPY  csi_datastructures_pub.org_units_header_tbl,
    p_time_stamp       IN      DATE
   );


/*----------------------------------------------------------*/
/* Procedure name:  Define_ou_Columns                      */
/* Description : This procudure defines the columns         */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Define_ou_Columns
  ( p_get_ou_cursor_id      IN   NUMBER
   );

/*----------------------------------------------------------*/
/* Procedure name:  Resolve_id_columns                      */
/* Description : This procudure gets the descriptions for   */
/*               id columns                                 */
/*----------------------------------------------------------*/

PROCEDURE  Resolve_id_columns
            (p_org_units_header_tbl  IN OUT NOCOPY   csi_datastructures_pub.org_units_header_tbl);


/*----------------------------------------------------------*/
/* Procedure name:  Get_ou_Column_Values                    */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_ou_Column_Values
   (p_get_ou_cursor_id      IN       NUMBER,
    x_ou_rec                    OUT NOCOPY  csi_datastructures_pub.org_units_header_rec
    );




/*----------------------------------------------------------*/
/* Procedure name:  Bind_ou_variable                        */
/* Description : Procedure used to  generate the where      */
/*                cluase  for organization assignments      */
/*----------------------------------------------------------*/

PROCEDURE Bind_ou_variable
  ( p_ou_query_rec    IN    csi_datastructures_pub.organization_unit_query_rec,
    p_cur_get_ou      IN    NUMBER
   );



/*----------------------------------------------------------*/
/* Procedure name:  Gen_ou_Where_Clause                     */
/* Description : Procedure used to  generate the where      */
/*                clause  for Organization units            */
/*----------------------------------------------------------*/

PROCEDURE Gen_ou_Where_Clause
  ( p_ou_query_rec       IN       csi_datastructures_pub.organization_unit_query_rec
   ,x_where_clause          OUT NOCOPY   VARCHAR2
  );



/*-------------------------------------------------------*/
/* procedure name: create_organization_unit                */
/* description :  Creates new association between an     */
/*                organization unit and an item instance */
/*                                                    */
/*-------------------------------------------------------*/

PROCEDURE create_organization_unit
 (    p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER := fnd_api.g_valid_level_full
     ,p_org_unit_rec        IN  OUT NOCOPY  csi_datastructures_pub.organization_units_rec
     ,p_txn_rec             IN  OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
     ,p_lookup_tbl          IN  OUT NOCOPY  csi_organization_unit_pvt.lookup_tbl
     ,p_ou_count_rec        IN  OUT NOCOPY  csi_organization_unit_pvt.ou_count_rec
     ,p_ou_id_tbl           IN  OUT NOCOPY  csi_organization_unit_pvt.ou_id_tbl
     ,p_called_from_grp     IN  VARCHAR2 DEFAULT fnd_api.g_false
 );



/*-------------------------------------------------------*/
/* procedure name: update_organization_unit              */
/* description :  Updates an existing instance-org       */
/*                association                              */
/*                                                   */
/*-------------------------------------------------------*/

PROCEDURE update_organization_unit
 (    p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER := fnd_api.g_valid_level_full
     ,p_org_unit_rec        IN      csi_datastructures_pub.organization_units_rec
     ,p_txn_rec             IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY     VARCHAR2
     ,x_msg_count           OUT NOCOPY     NUMBER
     ,x_msg_data            OUT NOCOPY     VARCHAR2
     ,p_lookup_tbl          IN  OUT NOCOPY csi_organization_unit_pvt.lookup_tbl
     ,p_ou_count_rec        IN  OUT NOCOPY csi_organization_unit_pvt.ou_count_rec
     ,p_ou_id_tbl           IN  OUT NOCOPY csi_organization_unit_pvt.ou_id_tbl
 );




/*--------------------------------------------------*/
/* procedure name: expire_organization_unit         */
/* description :  Expires an existing instance-org  */
/*                association                          */
/*                                               */
/*--------------------------------------------------*/

PROCEDURE expire_organization_unit
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN      NUMBER := fnd_api.g_valid_level_full
     ,p_org_unit_rec                IN      csi_datastructures_pub.organization_units_rec
     ,p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
 );






/*--------------------------------------------------*/
/* procedure name: get_org_unit_history             */
/* description :  Gets organization history         */
/*                                                  */
/*--------------------------------------------------*/

PROCEDURE get_org_unit_history
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN      NUMBER := fnd_api.g_valid_level_full
     ,p_transaction_id              IN      NUMBER
     ,x_org_unit_history_tbl            OUT NOCOPY csi_datastructures_pub.org_units_history_tbl
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
 );


END csi_organization_unit_pvt;








 

/
