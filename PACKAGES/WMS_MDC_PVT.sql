--------------------------------------------------------
--  DDL for Package WMS_MDC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_MDC_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVMDCS.pls 120.3.12010000.1 2008/07/28 18:37:51 appldev ship $ */

TYPE number_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Procedure to check if multiple LPNs LPN1, LPN2, ... can be packed into LPN0
PROCEDURE validate_to_lpn(p_from_lpn_ids             IN  number_table_type,  -- LPN1, LPN2,...
                          p_from_delivery_ids        IN  number_table_type,  -- Delivery1, Delivery2,...
                          p_to_lpn_id                IN  NUMBER,             -- LPN0
                          p_to_sub                   IN  VARCHAR2 DEFAULT NULL,
                          p_to_locator_id            IN  NUMBER DEFAULT NULL,
                          x_allow_packing            OUT nocopy VARCHAR2,
                          x_return_status            OUT nocopy VARCHAR2,
                          x_msg_count                OUT nocopy NUMBER,
                          x_msg_data                 OUT nocopy VARCHAR2);

-- API to check if an LPN1 (delivery D1) can be packed into another LPN2
-- p_local_caller  DEFAULT 'N', It will be passed as 'Y' when called from the overloaded
--                 validate_to_lpn (used for mass_move functionality ). No one else should ever use it
-- x_allow_packing = Y, N, C, V
--                 Y: Allow Packing
--                 N: Do not Allow Packing
--                 C: It is a consol Delivery. Next step in the calling module
--                    is to Check the locator type of the staging locator or the TOLPNs locator.
--                    This status is returned to lpn_mass_move API in WMSCONSB.pls
--                 V: Needs further validations
--                    This status is returned to overloaded API validate_to_lpn
--                    The caller further validates the list of from LPNs and
--                    TOLPN for AD/WD and aclls shipping API
--

PROCEDURE validate_to_lpn
          (p_from_lpn_id              IN  NUMBER,               -- LPN1
           p_from_delivery_id         IN  NUMBER DEFAULT NULL,  -- delivery ID for material in LPN1
           p_to_lpn_id                IN  NUMBER,               -- LPN2
           p_is_from_to_delivery_same IN  VARCHAR2,             -- Y,N,U
           p_is_from_lpn_mdc          IN  VARCHAR2 DEFAULT 'U',
           p_is_to_lpn_mdc            IN  VARCHAR2 DEFAULT 'U',
           p_to_sub                   IN  VARCHAR2 DEFAULT NULL,
           p_to_locator_id            IN  NUMBER DEFAULT NULL,
           p_local_caller             IN  VARCHAR2 DEFAULT 'N',
           x_allow_packing            OUT nocopy VARCHAR2,
           x_return_status            OUT nocopy VARCHAR2,
           x_msg_count                OUT nocopy NUMBER,
           x_msg_data                 OUT nocopy VARCHAR2);


-- API to suggest drop LPN, Subinventory and Locator
PROCEDURE suggest_to_lpn(p_lpn_id               IN NUMBER,           -- The LPN that is being dropped (from LPN)
                         p_delivery_id          IN NUMBER,           -- The delivery associated with the LPN
                         x_to_lpn_id            OUT nocopy NUMBER,   -- The LPN that is being dropped
                         x_to_subinventory_code OUT nocopy VARCHAR2, -- The subinventory of the suggested LPN
                         x_to_locator_id        OUT nocopy NUMBER,   -- The locator of the suggested LPN
                         x_return_status        OUT nocopy VARCHAR2,
                         x_msg_count            OUT nocopy NUMBER,
                         x_msg_data             OUT nocopy VARCHAR2);

-- check if a delivery D1 can be shipped out
PROCEDURE can_ship_delivery(p_delivery_id    NUMBER,
                            x_allow_shipping OUT nocopy VARCHAR2,
                            x_return_status  OUT nocopy VARCHAR2,
                            x_msg_count      OUT nocopy NUMBER,
                            x_msg_data       OUT nocopy VARCHAR2);

-- Check if p_lpn_id belongs to a consolidation_delivery, if yes then It
-- returns consolidation delivery_id else it returns NULL

FUNCTION get_consol_delivery_id(p_lpn_id IN NUMBER) RETURN NUMBER ;

END wms_mdc_pvt;

/
