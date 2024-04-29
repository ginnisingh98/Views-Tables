--------------------------------------------------------
--  DDL for Package GMO_DISPENSE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DISPENSE_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGDSPS.pls 120.2.12000000.3 2007/04/17 07:18:16 achawla ship $ */


G_PKG_NAME             CONSTANT VARCHAR2(16) := 'GMO_DISPENSE_GRP';

G_MATERIAL_LINE_ENTITY CONSTANT VARCHAR2(30) := 'MATERIAL_DETAILS_ID';

-- Start of comments
-- API name   : MAINTAIN_RESERVATION
-- Type       : Group.
-- Function   : Synch the reservation ID in dispensing tables
--              for all dispensed and reverse dispensed rows.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_api_version            IN NUMBER   Required
--              p_init_msg_list	         IN VARCHAR2 Required
--              p_commit	         IN VARCHAR2 Required
--              p_batch_id               IN NUMBER   Required
--              p_old_reservation_id     IN NUMBER   Required
--              p_new_reservation_id     IN NUMBER   Required
--              p_batchstep_id           IN NUMBER
--              p_item_id                IN NUMBER   Required
--              p_material_detail_id     IN NUMBER   Required
--    .
-- OUT        : x_return_status  OUT VARCHAR2(1)
--              x_msg_count   OUT NUMBER
--              x_msg_data   OUT VARCHAR2(2000)
--    .
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE MAINTAIN_RESERVATION(p_api_version        NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               p_commit	       IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data  OUT NOCOPY VARCHAR2,
                               p_batch_id           NUMBER,
                               p_old_reservation_id NUMBER,
                               p_new_reservation_id NUMBER,
                               p_batchstep_id       NUMBER,
                               p_item_id            NUMBER,
                               p_material_detail_id NUMBER
                               );

-- Start of comments
-- API name   : CHANGE_DISPENSE_STATUS
-- Type       : Group.
-- Function   : To mark the dispensed rows as 'consumed' or not consumed
--              rows to 'only for reverse dispense' or consumed rows
--              as 'not consumed. This API gets called by GME material
--              transaction.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_api_version            IN NUMBER   Required
--              p_init_msg_list	         IN VARCHAR2 Required
--              p_commit	         IN VARCHAR2 Required
--              p_dispense_id            IN NUMBER   Required
--              p_status_code            IN VARCHAR2   Required
--              p_transaction_id         IN NUMBER   Required
--    .
-- OUT        : x_return_status  OUT VARCHAR2(1)
--              x_msg_count   OUT NUMBER
--              x_msg_data   OUT VARCHAR2(2000)
--    .
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE CHANGE_DISPENSE_STATUS(p_api_version    NUMBER,
                                 p_init_msg_list IN VARCHAR2,
                                 p_commit	 IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY     NUMBER,
                                 x_msg_data  OUT NOCOPY     VARCHAR2,
                                 p_dispense_id    NUMBER,
                                 p_status_code    VARCHAR2,
                                 p_transaction_id NUMBER
                                 );

-- Start of comments
-- API name   : IS_DISPENSE_ITEM
-- Type       : Group.
-- Function   : To check if dispense setup is configured
--              as dispense required for given item , item - org
--              and item-org-recipe level.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_api_version            IN NUMBER   Required
--              p_init_msg_list          IN VARCHAR2 Required
--              p_inventory_item_id      IN NUMBER   Required
--              p_organization_id        IN NUMBER   Required
--              p_recipe_id              IN NUMBER   Required
--    .
-- OUT        : x_return_status  OUT VARCHAR2(1)
--              x_msg_count   OUT NUMBER
--              x_msg_data   OUT VARCHAR2(2000)
--              x_dispense_required  OUT VARHCHAR2(1)
--              x_dispense_config_id OUT NUMBER
--    .
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- Note       : x_dispense_required will either be FND_API.G_TRUE
--              or FND_API.G_FALSE.
-- End of comments
PROCEDURE IS_DISPENSE_ITEM (p_api_version     NUMBER,
                            p_init_msg_list   IN      VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_inventory_item_id    NUMBER,
                            p_organization_id      NUMBER,
                            p_recipe_id            NUMBER,
                            x_dispense_required   OUT NOCOPY VARCHAR2,
			    x_dispense_config_id  OUT NOCOPY NUMBER);



-- Start of comments
-- API name   : GET_MATERIAL_DISPENSE_DATA
-- Type       : Group.
-- Function   : Returns dispensed and consumed rows for the
--              requested material. All the quantity data
--              are in dispense UOM , read from dispense setup tables.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : p_api_version            IN NUMBER   Required
--              p_material_detail_id     IN NUMBER   Required
--    .
-- OUT        : x_return_status  OUT VARCHAR2(1)
--              x_msg_count   OUT NUMBER
--              x_msg_data   OUT VARCHAR2(2000)
--              x_dispense_data OUT  DISPENSE_TBL_TYPE Dispense Items to be consumed.
--    .
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE GET_MATERIAL_DISPENSE_DATA (p_api_version     IN NUMBER,
                                      p_init_msg_list   IN      VARCHAR2,
                                      x_return_status   OUT NOCOPY VARCHAR2,
                                      x_msg_count       OUT NOCOPY NUMBER,
                                      x_msg_data        OUT NOCOPY VARCHAR2,
                                      p_material_detail_id   IN NUMBER,
                                      x_dispense_data    OUT NOCOPY GME_COMMON_PVT.reservations_tab
                                      );


-- Start of comments
-- API name   : INSTANTIATE_DISPENSE_SETUP
-- Type       : Group API
-- Function   : This procedure is used to instantiate the dispense setup identified by the specified
--              dispense config ID, entity name and entity key.

-- Pre-reqs   : None.
-- Parameters :
-- IN         : P_API_VERSION            IN NUMBER   Required
--              P_DISPENSE_CONFIG_ID     IN NUMBER   The dispense config ID.
--              P_ENTITY_NAME            IN VARCHAR2 The entity name.
--              P_ENTITY_KEY             IN VARCHAR2 The entity key.
--              P_INIT_MSG_LIST          IN VARCHAR2 Whether the message list should be initialized.
--    .
-- OUT        : X_RETURN_STATUS  OUT VARCHAR2 The return status.
--              X_MSG_COUNT      OUT NUMBER   The message count.
--              X_MSG_DATA       OUT VARCHAR2 Error message if any.
--    .
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE INSTANTIATE_DISPENSE_SETUP
(P_API_VERSION        IN  NUMBER,
 P_DISPENSE_CONFIG_ID IN  NUMBER,
 P_ENTITY_NAME        IN  VARCHAR2,
 P_ENTITY_KEY         IN  VARCHAR2,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 P_AUTO_COMMIT        IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2);

Function isDispenseOccuredAtDispBooth(disp_booth_id number) return varchar2;
Function isDispenseOccuredAtDispArea(disp_area_id number) return varchar2;
END GMO_DISPENSE_GRP;

 

/
