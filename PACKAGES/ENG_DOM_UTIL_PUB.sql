--------------------------------------------------------
--  DDL for Package ENG_DOM_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DOM_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: ENGPDUTS.pls 120.1 2005/07/06 11:10:07 dedatta noship $ */

FUNCTION check_floating_attachments (
                                        p_inventory_item_id     IN NUMBER
                                       ,p_revision_id       IN NUMBER
                                       ,p_organization_id       IN NUMBER
                                       ,p_lifecycle_id          IN NUMBER
                                       ,p_new_phase_id       IN NUMBER
) RETURN VARCHAR2;

END ENG_DOM_UTIL_PUB;


 

/
