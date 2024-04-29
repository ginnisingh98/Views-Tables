--------------------------------------------------------
--  DDL for Package INV_COST_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COST_GROUP_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPDCGS.pls 120.1 2005/06/17 17:25:03 appldev  $ */

-- Glbal constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_COST_GROUP_PUB';
G_INPUT_MMTT                  CONSTANT VARCHAR2(6) :=  'MMTT';
G_INPUT_MOLINE                CONSTANT VARCHAR2(6)  := 'MTRL';
G_COST_GROUP_ID	      NUMBER;
G_TRANSFER_COST_GROUP_ID NUMBER;

procedure set_globals(p_cost_group_id IN NUMBER,
		      p_transfer_cost_group_id IN NUMBER);

procedure get_globals(x_cost_group_id OUT NOCOPY NUMBER,
		      x_transfer_cost_group_id OUT NOCOPY NUMBER);

PROCEDURE Assign_Cost_Group
(
    p_api_version_number	    IN  NUMBER
,   p_init_msg_list	 	    IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit			    IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_msg_count			    OUT NOCOPY NUMBER
,   x_msg_data			    OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_input_type                    IN  VARCHAR2
,   x_cost_Group_id                 OUT NOCOPY NUMBER
,   x_transfer_cost_Group_id	    OUT NOCOPY NUMBER
);
END INV_COST_GROUP_PUB;

 

/
