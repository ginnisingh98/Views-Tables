--------------------------------------------------------
--  DDL for Package WSH_FTE_COMP_CONSTRAINT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FTE_COMP_CONSTRAINT_GRP" AUTHID CURRENT_USER as
/* $Header: WSHFTGPS.pls 120.0 2005/05/26 18:22:21 appldev noship $ */

-- Global Variables

g_package_name               CONSTANT        VARCHAR2(50) := 'WSH_FTE_COMP_CONSTRAINT_GRP';

G_ACTION_CREATE          VARCHAR2(30) := 'CREATE';
G_ACTION_UPDATE          VARCHAR2(30) := 'UPDATE';


G_DELIVERY               VARCHAR2(30) := 'DLVY';
G_TRIP                   VARCHAR2(30) := 'TRIP';

--   p_action_code  can be    G_ACTION_CREATE or G_ACTION_UPDATE

  TYPE wshfte_ccin_rec_type IS RECORD (
             p_action_code                      VARCHAR2(30),                --  CREATE  /  UPDATE
             p_entity_type                      VARCHAR2(30), -- DLVY /  TRIP
             p_entity_id                        NUMBER ,
             p_organization_id                  NUMBER ,
             p_customer_id                      NUMBER ,
             p_shipmethod_code                  VARCHAR(30) ,
             p_carrier_id                       NUMBER ,
             p_mode_code                        VARCHAR2(30) ,
             p_service_level                    VARCHAR2(30) ,
             p_veh_item_id                      NUMBER ,
             p_sequence_num                     NUMBER ,
             p_ship_from_location_id            NUMBER ,
             p_ship_to_location_id              NUMBER ,
             p_intmed_location_id               NUMBER , -- Only for delivery
             p_planned_flag                     VARCHAR2(1) ,
             p_status_code                      VARCHAR2(30),
             x_validate_status                  VARCHAR2(1)  );  -- S / F for the record

  TYPE wshfte_ccin_tab_type IS TABLE OF wshfte_ccin_rec_type INDEX BY BINARY_INTEGER;

-- Currently only supports UPDATE / CREATE for Delivery and TRIP
-- Is it required to support validation of constraints when no specific entity is passed
-- and only some attributes are passed ?
-- Though it is possible to validate WHATEVER has been passed against each other, it is
-- difficult to conceptualize that as without a context lot of validations are not required.

PROCEDURE validate_constraint(
             p_api_version_number     IN   NUMBER,
             p_init_msg_list          IN   VARCHAR2,
             p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_entity_tab             IN OUT NOCOPY  wshfte_ccin_tab_type,
             x_msg_count                OUT  NOCOPY  NUMBER,   -- Standard FND functionality
             x_msg_data                 OUT  NOCOPY  VARCHAR2,  -- Will return message text only if number of messages = 1
             x_return_status            OUT  NOCOPY   VARCHAR2);

--***************************************************************************--
--========================================================================
-- PROCEDURE : is_valid_consol
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_input_delivery_id_tab     Table of delivery records to process
--
--             p_target_consol_delivery_id Table of delivery ids to process
--             x_deconsolidation_location  deconsolidation location
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is to find if a set of deliveries can be assigned to a consol delivery.
--             This procedure is called from WMS.
--
--========================================================================
PROCEDURE is_valid_consol(  p_init_msg_list             IN  VARCHAR2 DEFAULT fnd_api.g_false,
                            p_input_delivery_id_tab     IN  WSH_UTIL_CORE.id_tab_type,
                            p_target_consol_delivery_id IN  NUMBER,
                            p_caller                    IN  VARCHAR2 DEFAULT NULL,
                            x_deconsolidation_location  OUT NOCOPY NUMBER,
                            x_return_status             OUT  NOCOPY VARCHAR2,
                            x_msg_count                 OUT  NOCOPY NUMBER,
                            x_msg_data                  OUT  NOCOPY VARCHAR2);
END WSH_FTE_COMP_CONSTRAINT_GRP;


 

/
