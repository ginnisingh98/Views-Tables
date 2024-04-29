--------------------------------------------------------
--  DDL for Package CSI_PRICING_ATTRIBS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PRICING_ATTRIBS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivpas.pls 115.19 2003/09/04 00:48:07 sguthiva ship $ */

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_pri_rec_no_dump              */
/* Description : This procudure gets the first record       */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_pri_rec_no_dump
(
 x_pri_rec              IN OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec,
 p_pri_hist_id          IN      NUMBER,
 x_first_no_dump        IN OUT NOCOPY  DATE
);

/*----------------------------------------------------------*/
/* Procedure name:  Initialize_pri_rec                      */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_pri_rec
( x_pri_rec               IN OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec,
  p_pri_h_id              IN      NUMBER,
  x_nearest_full_dump     IN OUT NOCOPY  DATE
 );



/*----------------------------------------------------------*/
/* Procedure name:  Construct_pri_from_hist                 */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_pri_from_hist
( x_pri_tbl           IN OUT NOCOPY   csi_datastructures_pub.pricing_attribs_tbl,
  p_time_stamp        IN       DATE
 );



/*----------------------------------------------------------*/
/* Procedure name:  Define_pri_Columns                      */
/* Description : This procudure defines column values       */
/*                        for Dynamic SQL                   */
/*----------------------------------------------------------*/

PROCEDURE Define_pri_Columns
   (    p_get_pri_cursor_id      IN   NUMBER
    );




/*----------------------------------------------------------*/
/* Procedure name:  Get_pri_Column_Values                   */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_pri_Column_Values
   ( p_get_pri_cursor_id      IN       NUMBER,
     x_pri_rec                    OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec
    );




/*----------------------------------------------------------*/
/* Procedure name:  Bind_pri_variable                       */
/* Description : This procudure binds the column values     */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Bind_pri_variable
(   p_pri_query_rec    IN    csi_datastructures_pub.pricing_attribs_query_rec,
    p_cur_get_pri      IN    NUMBER
   );



/*----------------------------------------------------------*/
/* Procedure name:  Gen_pri_Where_Clause                    */
/* Description : Procedure used to  generate the where      */
/*                clause  for Extended Attributes units     */
/*----------------------------------------------------------*/

PROCEDURE Gen_pri_Where_Clause
(   p_pri_query_rec       IN        csi_datastructures_pub.pricing_attribs_query_rec
   ,x_where_clause            OUT NOCOPY   VARCHAR2
 );


/*------------------------------------------------------*/
/* procedure name: create_pricing_attribs		*/
/* description :  Associates pricing attributes to an   */
/*                item instance				*/
/*               					*/
/*------------------------------------------------------*/

PROCEDURE create_pricing_attribs
 (    p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_pricing_attribs_rec IN  OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec
     ,p_txn_rec             IN  OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
     ,p_called_from_grp     IN  VARCHAR2 DEFAULT fnd_api.g_false
 );


/*------------------------------------------------------*/
/* procedure name: update_pricing_attribs		*/
/* description :  Updates the existing pricing 		*/
/*                attributes for an item instance	*/
/*               					*/
/*------------------------------------------------------*/


PROCEDURE update_pricing_attribs
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN      NUMBER := fnd_api.g_valid_level_full
     ,p_pricing_attribs_rec         IN      csi_datastructures_pub.pricing_attribs_rec
     ,p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
 );


/*------------------------------------------------------*/
/* procedure name: expire_pricing_attribs	        */
/* description :  Deletes the existing pricing 		*/
/*                attributes for an item instance	*/
/*               					*/
/*------------------------------------------------------*/


PROCEDURE expire_pricing_attribs
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN      NUMBER := fnd_api.g_valid_level_full
     ,p_pricing_attribs_rec         IN      csi_datastructures_pub.pricing_attribs_rec
     ,p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
 );




END csi_pricing_attribs_pvt;

 

/
