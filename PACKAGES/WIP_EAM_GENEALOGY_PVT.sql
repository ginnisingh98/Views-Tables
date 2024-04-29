--------------------------------------------------------
--  DDL for Package WIP_EAM_GENEALOGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_GENEALOGY_PVT" AUTHID CURRENT_USER AS
/* $Header: WIPVEGNS.pls 120.0.12010000.2 2008/12/23 10:17:31 smrsharm ship $*/

/*--------------------------------------------------------------------------+
 | This package contains the Genealogy specs for rebuilds. These APIs will  |
 | be used to call the transaction API to do a miscellaneous transaction    |
 | before calling the genealogy API                                         |
 | History:                                                                 |
 | July 10, 2000       hkarmach         Created package spec.               |
 +--------------------------------------------------------------------------*/

PROCEDURE create_eam_genealogy(
                        p_api_version              IN  NUMBER,
                        p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
                        p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,
                        p_validation_level         IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                        p_subinventory             IN  VARCHAR2 := NULL,
                        p_locator_id               IN  NUMBER   := NULL,
                        p_object_id                IN  number   := null,
                        p_serial_number            IN  VARCHAR2 := NULL,
                        p_organization_id          IN  NUMBER   := NULL,
                        p_inventory_item_id        IN  NUMBER   := NULL,
                        p_parent_object_id         IN  NUMBER   := NULL,
                        p_parent_serial_number     IN  VARCHAR2 := NULL,
                        p_parent_inventory_item_id IN  NUMBER   := NULL,
                        p_parent_organization_id   IN  NUMBER   := NULL,
                        p_start_date_active        IN  DATE     := SYSDATE,
                        p_end_date_active          IN  DATE     := NULL,
			p_origin_txn_id                 IN  NUMBER   := NULL,
			p_update_txn_id                 IN  NUMBER   := NULL,
                        p_from_eam                 IN  VARCHAR2 := NULL,
                        x_msg_count                OUT NOCOPY NUMBER,
                        x_msg_data                 OUT NOCOPY VARCHAR2,
                        x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE update_eam_genealogy(
                        p_api_version              IN  NUMBER,
                        p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
                        p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,
                        p_validation_level         IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                        p_object_type              IN  NUMBER,
                        p_object_id                IN  NUMBER   := NULL,
                        p_serial_number            IN  VARCHAR2 := NULL,
                        p_inventory_item_id        IN  NUMBER   := NULL,
                        p_organization_id          IN  NUMBER   := NULL,
                        p_subinventory             IN  VARCHAR2 := NULL,
                        p_locator_id               IN  NUMBER   := NULL,
                        p_genealogy_origin         IN  NUMBER   := NULL,
                        p_genealogy_type           IN  NUMBER   := NULL,
                        p_end_date_active          IN  DATE     := NULL,
                        p_from_eam                 IN  VARCHAR2 := NULL,
                        x_return_status            OUT NOCOPY VARCHAR2,
                        x_msg_count                OUT NOCOPY NUMBER,
                        x_msg_data                 OUT NOCOPY VARCHAR2);

Procedure Get_LocatorControl_Code(
                          p_org      IN NUMBER,
                          p_subinv   IN VARCHAR2,
                          p_item_id  IN NUMBER,
                          p_action   IN NUMBER,
                          x_locator_ctrl     OUT NOCOPY NUMBER,
                          x_error_flag       OUT NOCOPY NUMBER, -- returns 0 if no error ,1 if any error .
                          x_error_mssg       OUT NOCOPY VARCHAR2) ;

Function Dynamic_Entry_Not_Allowed(
                          p_restrict_flag IN NUMBER,
                          p_neg_flag      IN NUMBER,
                          p_action        IN NUMBER) return Boolean ;


END WIP_EAM_GENEALOGY_PVT;

/
