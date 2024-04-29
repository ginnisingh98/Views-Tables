--------------------------------------------------------
--  DDL for Package CSI_PRICING_ATTRIBS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PRICING_ATTRIBS_PUB" AUTHID CURRENT_USER AS
/* $Header: csippas.pls 115.20 2003/09/04 00:57:38 sguthiva ship $ */

/*------------------------------------------------------*/
/* procedure name: get_pricing_attribs                  */
/* description :   Gets the pricing attributes of an    */
/*                 item instance                        */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE get_pricing_attribs
 (    p_api_version               IN      NUMBER
     ,p_commit                    IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_pricing_attribs_query_rec IN      csi_datastructures_pub.pricing_attribs_query_rec
     ,p_time_stamp                IN      DATE
     ,x_pricing_attribs_tbl           OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
     ,x_return_status                 OUT NOCOPY VARCHAR2
     ,x_msg_count                     OUT NOCOPY NUMBER
     ,x_msg_data                      OUT NOCOPY VARCHAR2
 );



/*------------------------------------------------------*/
/* procedure name: create_pricing_attribs               */
/* description :  Associates pricing attributes to an   */
/*                item instance                         */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE create_pricing_attribs
 (    p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_pricing_attribs_tbl IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2
 );




/*------------------------------------------------------*/
/* procedure name: update_pricing_attribs               */
/* description :  Updates the existing pricing          */
/*                attributes for an item instance       */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE update_pricing_attribs
 (    p_api_version             IN     NUMBER
     ,p_commit                  IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_pricing_attribs_tbl     IN     csi_datastructures_pub.pricing_attribs_tbl
     ,p_txn_rec                 IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status              OUT NOCOPY VARCHAR2
     ,x_msg_count                  OUT NOCOPY NUMBER
     ,x_msg_data                   OUT NOCOPY VARCHAR2
 );





/*------------------------------------------------------*/
/* procedure name: expire_pricing_attribs               */
/* description :  Expires the existing pricing          */
/*                attributes for an item instance       */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE expire_pricing_attribs
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_pricing_attribs_tbl         IN     csi_datastructures_pub.pricing_attribs_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                  OUT NOCOPY VARCHAR2
     ,x_msg_count                      OUT NOCOPY NUMBER
     ,x_msg_data                       OUT NOCOPY VARCHAR2
 );





END csi_pricing_attribs_pub;

 

/
