--------------------------------------------------------
--  DDL for Package HZ_TAX_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_TAX_ASSIGNMENT_PUB" AUTHID CURRENT_USER as
/*$Header: ARHTLASS.pls 115.7 2003/09/08 18:14:28 acng ship $ */

procedure create_loc_assignment(
        p_api_version                  IN      NUMBER,
        p_init_msg_list                IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                       IN      VARCHAR2:= FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        x_return_status                IN OUT  NOCOPY VARCHAR2, /* Changed from OUT to IN OUT*/
        x_msg_count                    OUT     NOCOPY NUMBER,
        x_msg_data                     OUT     NOCOPY VARCHAR2,
        x_loc_id                       OUT     NOCOPY NUMBER,
        p_lock_flag                    IN      VARCHAR2 :=FND_API.G_FALSE
);


procedure update_loc_assignment(
        p_api_version                  IN      NUMBER,
        p_init_msg_list                IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                       IN      VARCHAR2:= FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        x_return_status                IN OUT  NOCOPY VARCHAR2, /* Changed from OUT to IN OUT*/
        x_msg_count                    OUT     NOCOPY NUMBER,
        x_msg_data                     OUT     NOCOPY VARCHAR2,
        x_loc_id                       OUT     NOCOPY NUMBER,
        p_lock_flag                    IN      VARCHAR2 :=FND_API.G_TRUE
);


end HZ_TAX_ASSIGNMENT_PUB;

 

/
