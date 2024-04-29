--------------------------------------------------------
--  DDL for Package WSH_VENDOR_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_VENDOR_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHVMRGS.pls 120.6 2005/08/24 10:04:13 rlanka noship $ */

--========================================================================
-- PROCEDURE :Vendor_Merge
-- PARAMETERS:
--              P_from_id             Merge from vendor ID
--              P_to_id               Merge to vendor ID
--              P_from_party_id       Merge from party ID
--              P_to_party_id         Merge to party ID
--              P_from_site_id        Merge from vendor site ID
--              P_to_site_id          Merge to vendor site ID
--              p_Calling_mode        Mode to indicate what data to update
--                                    Possible values :
--                                      - 'INVOICE' and 'PO'
--              X_return_status       Return status
--
-- COMMENT :
--           This is the core WSH merge routine and will be called from the
--           Vendor_Party_Merge() API.
--
--           This procedure can be divided into two portions, merge validation and merge.
--           In the first portion, it will determine if the vendor merge is allowed.
--           In the second portion, it will update all the affected tables if merge is allowed
--
--           Parameter p_calling_mode indicates what updates to perform.
--           'INVOICE' ==> Update only non-PO entities
--           'PO'      ==> Update PO related entities

--========================================================================

PROCEDURE Vendor_Merge (
                        p_from_id        IN   NUMBER,
                        p_to_id          IN   NUMBER,
                        p_from_party_id  IN   NUMBER,
                        p_to_party_id    IN   NUMBER,
                        p_from_site_id   IN   NUMBER,
                        p_to_site_id     IN   NUMBER,
                        p_calling_mode   IN   VARCHAR2,
                        x_return_status  OUT NOCOPY VARCHAR2 );



--========================================================================
-- PROCEDURE :Vendor_Party_Merge
-- PARAMETERS:
--              P_from_vendor_id               Merge from vendor ID
--              P_to_vendor_id                 Merge to vendor ID
--              P_from_party_id                Merge from party ID
--              P_to_party_id                  Merge to party ID
--              P_from_vendor_site_id          Merge from vendor site ID
--              P_to_vendor_site_id            Merge to vendor site ID
--              P_from_party_site_id           Merge from party site ID
--              P_to_party_site_id             Merge to party site ID
--              p_calling_mode                 Mode in which AP calls us
--                                             'INVOICE' or 'PO'
--              X_return_status                Return status
--
-- COMMENTS
--         This is the API that is called by APXINUPD.rdf.  This in turn
--         will call the core Vendor_Merge() procedure to
--         perform all the necessary updates to WSH data.
--
-- HISTORY
--         rlanka      7/27/2005     Created
--         rlanka      8/09/2005     Added new parameter p_calling_mode
--                                   to track the phase in which
--                                   APXINUPD.rdf calls us.
--
--========================================================================

PROCEDURE Vendor_Party_Merge
             (
               p_from_vendor_id          IN         NUMBER,
               p_to_vendor_id            IN         NUMBER,
               p_from_party_id           IN         NUMBER,
               p_to_party_id             IN         NUMBER,
               p_from_vendor_site_id     IN         NUMBER,
               p_to_vendor_site_id       IN         NUMBER,
               p_from_party_site_id      IN         NUMBER,
               p_to_partysite_id         IN         NUMBER,
               p_calling_mode            IN         VARCHAR2 DEFAULT 'INVOICE',
               x_return_status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2
             );




--========================================================================
-- PROCEDURE :  Create_Site
-- PARAMETERS:
--                 P_from_id              Merge from party ID
--                 P_to_id                Merge to party ID
--                 P_to_vendor_id         Merge to vendor ID
--                 P_delivery_id          Delivery ID
--                 P_delivery_name        Delivery Name
--                 P_location_id          SF Location ID
--                 X_return_status        Return status
--
-- COMMENT : This is a procedure to create a new party site.
--           It also creates a corresponding party site use record and
--           calls Process_Locations() to update information in WSH
--           location tables.
--========================================================================
PROCEDURE Create_Site(
                     p_from_id            IN   NUMBER,
                     p_to_id              IN   NUMBER,
                     p_to_vendor_id       IN   NUMBER,
                     p_delivery_id        IN   NUMBER,
                     p_delivery_name      IN   VARCHAR2,
                     p_location_id        IN   NUMBER,
                     x_return_status      OUT  NOCOPY VARCHAR2
                     );

END WSH_VENDOR_PARTY_MERGE_PKG;

 

/
