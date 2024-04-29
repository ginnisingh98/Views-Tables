--------------------------------------------------------
--  DDL for Package EGO_DOM_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DOM_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPDUTS.pls 120.2 2005/07/06 11:04:26 dedatta noship $ */

PROCEDURE check_floating_attachments (
                                        p_inventory_item_id     IN NUMBER
                                       ,p_revision_id           IN NUMBER
                                       ,p_organization_id       IN NUMBER
                                       ,p_lifecycle_id          IN NUMBER
                                       ,p_new_phase_id          IN NUMBER
                                       ,x_return_status         OUT NOCOPY  VARCHAR2
                                       ,x_msg_count             OUT NOCOPY  NUMBER
                                       ,x_msg_data              OUT NOCOPY VARCHAR2
);

END ego_dom_util_pub;

 

/
