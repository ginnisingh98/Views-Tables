--------------------------------------------------------
--  DDL for Package PJM_USERPROJECTLOCATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_USERPROJECTLOCATOR_PUB" AUTHID CURRENT_USER as
/* $Header: PJMPULCS.pls 115.4 2002/10/29 20:14:03 alaw ship $ */

    PROCEDURE Get_UserProjectSupply(P_item_id IN NUMBER,
                   P_org_id IN NUMBER,
                   P_wip_entity_id IN NUMBER,
                   P_loc_id IN OUT NOCOPY NUMBER);

 end  PJM_UserProjectLocator_Pub;

 

/
