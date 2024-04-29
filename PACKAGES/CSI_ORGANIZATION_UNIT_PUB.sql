--------------------------------------------------------
--  DDL for Package CSI_ORGANIZATION_UNIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ORGANIZATION_UNIT_PUB" AUTHID CURRENT_USER AS
/* $Header: csipous.pls 115.21 2003/09/04 00:57:21 sguthiva ship $ */

/*-------------------------------------------------------*/
/* procedure name: get_organization_unit                 */
/* description :   Get information about the org unit(s) */
/*                 associated with an item  instance.    */
/*-------------------------------------------------------*/


PROCEDURE get_organization_unit
 (    p_api_version             IN      NUMBER
     ,p_commit                  IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list           IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level        IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_ou_query_rec            IN      csi_datastructures_pub.organization_unit_query_rec
     ,p_resolve_id_columns      IN      VARCHAR2 := fnd_api.g_false
     ,p_time_stamp              IN      DATE
     ,x_org_unit_tbl                OUT NOCOPY csi_datastructures_pub.org_units_header_tbl
     ,x_return_status               OUT NOCOPY VARCHAR2
     ,x_msg_count                   OUT NOCOPY NUMBER
     ,x_msg_data                    OUT NOCOPY VARCHAR2
 );

/*-------------------------------------------------------*/
/* procedure name: create_organization_unit              */
/* description :  Creates new association between an     */
/*                organization unit and an item instance */
/*-------------------------------------------------------*/


PROCEDURE create_organization_unit
 (
      p_api_version       IN      NUMBER
     ,p_commit            IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level  IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_org_unit_tbl      IN  OUT NOCOPY csi_datastructures_pub.organization_units_tbl
     ,p_txn_rec           IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status         OUT NOCOPY VARCHAR2
     ,x_msg_count             OUT NOCOPY NUMBER
     ,x_msg_data              OUT NOCOPY VARCHAR2
);

/*-------------------------------------------------------*/
/* procedure name: update_organization_unit              */
/* description :  Updates an existing instance-org       */
/*                association                            */
/*-------------------------------------------------------*/

PROCEDURE update_organization_unit
 (
      p_api_version            IN     NUMBER
     ,p_commit                 IN     VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list          IN     VARCHAR2 := fnd_api.g_false
     ,p_validation_level       IN     NUMBER   := fnd_api.g_valid_level_full
     ,p_org_unit_tbl           IN     csi_datastructures_pub.organization_units_tbl
     ,p_txn_rec                IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status             OUT NOCOPY VARCHAR2
     ,x_msg_count                 OUT NOCOPY NUMBER
     ,x_msg_data                  OUT NOCOPY VARCHAR2
 );


/*------------------------------------------------------*/
/* procedure name: expire_organization_unit             */
/* description :  Expires an existing instance-org      */
/*                association                           */
/*------------------------------------------------------*/

PROCEDURE expire_organization_unit
 (
      p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level            IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_org_unit_tbl                IN      csi_datastructures_pub.organization_units_tbl
     ,p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
  );

END csi_organization_unit_pub;

 

/
