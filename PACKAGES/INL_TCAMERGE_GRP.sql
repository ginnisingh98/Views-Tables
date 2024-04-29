--------------------------------------------------------
--  DDL for Package INL_TCAMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_TCAMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: INLGMRGS.pls 120.2.12010000.2 2013/09/09 14:53:46 acferrei ship $ */
   G_MODULE_NAME           CONSTANT VARCHAR2(200)  := 'INL.PLSQL.INL_TCAMERGE_GRP.';
   G_PKG_NAME              CONSTANT VARCHAR2(30)   := 'INL_TCAMERGE_GRP';

--========================================================================
-- PROCEDURE :Merge_VendorParties
-- PARAMETERS:
--              p_from_vendor_id               Merge from vendor ID
--              p_to_vendor_id                 Merge to vendor ID
--              p_from_party_id                Merge from party ID
--              p_to_party_id                  Merge to party ID
--              p_from_vendor_site_id          Merge from vendor site ID
--              p_to_vendor_site_id            Merge to vendor site ID
--              p_from_party_site_id           Merge from party site ID
--              p_to_party_site_id             Merge to party site ID
--              p_calling_mode                 Mode in which AP calls us
--                                             'INVOICE' or 'PO'
--              x_return_status                Return status
--              x_msg_count                    Return count message
--              x_msg_data                     Return message data
--
-- COMMENTS
--         This is the API that is called by APXINUPD.rdf.  This in turn
--         will call the core Merge_Vendors() procedure to
--         perform all the necessary updates to LCM data.
--
--========================================================================

PROCEDURE Merge_VendorParties
             (
               p_from_vendor_id          IN         NUMBER,
               p_to_vendor_id            IN         NUMBER,
               p_from_party_id           IN         NUMBER,
               p_to_party_id             IN         NUMBER,
               p_from_vendor_site_id     IN         NUMBER,
               p_to_vendor_site_id       IN         NUMBER,
               p_from_party_site_id      IN         NUMBER,
               p_to_party_site_id        IN         NUMBER,
               p_calling_mode            IN         VARCHAR2 DEFAULT 'INVOICE',
               x_return_status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2
             );

--========================================================================
-- PROCEDURE :Merge_Parties
-- PARAMETERS:
--            p_entity_name                   Name of Entity Being Merged
--            p_from_id                       Primary Key Id of the entity that is being merged
--            p_to_id                         The record under the 'To Parent' that is being merged
--            p_from_fk_id                    Foreign Key id of the Old Parent Record
--            p_to_fk_id                      Foreign  Key id of the New Parent Record
--            p_parent_entity_name            Name of Parent Entity
--            p_batch_id                      Id of the Batch
--            p_batch_party_id                Id uniquely identifies the batch and party record that is being merged
--            x_return_status                 Returns the status of call
--
-- COMMENT   :
--
--========================================================================

PROCEDURE Merge_Parties
             (
               p_entity_name         IN             VARCHAR2,
               p_from_id             IN             NUMBER,
               p_to_id               IN  OUT NOCOPY NUMBER,
               p_from_fk_id          IN             NUMBER,
               p_to_fk_id            IN             NUMBER,
               p_parent_entity_name  IN             VARCHAR2,
               p_batch_id            IN             NUMBER,
               p_batch_party_id      IN             NUMBER,
               x_return_status       IN  OUT NOCOPY VARCHAR2
             );

--========================================================================
-- PROCEDURE :Merge_PartySites
-- PARAMETERS:
--            p_entity_name                   Name of Entity Being Merged
--            p_from_id                       Primary Key Id of the entity that is being merged
--            p_to_id                         The record under the 'To Parent' that is being merged
--            p_from_fk_id                    Foreign Key id of the Old Parent Record
--            p_to_fk_id                      Foreign  Key id of the New Parent Record
--            p_parent_entity_name            Name of Parent Entity
--            p_batch_id                      Id of the Batch
--            p_batch_party_id                Id uniquely identifies the batch and party record that is being merged
--            x_return_status                 Returns the status of call
--
-- COMMENT   :
--
--========================================================================

PROCEDURE Merge_PartySites
             (
               p_entity_name         IN             VARCHAR2,
               p_from_id             IN             NUMBER,
               p_to_id               IN  OUT NOCOPY NUMBER,
               p_from_fk_id          IN             NUMBER,
               p_to_fk_id            IN             NUMBER,
               p_parent_entity_name  IN             VARCHAR2,
               p_batch_id            IN             NUMBER,
               p_batch_party_id      IN             NUMBER,
               x_return_status       IN  OUT NOCOPY VARCHAR2
             );


END INL_TCAMERGE_GRP;

/
