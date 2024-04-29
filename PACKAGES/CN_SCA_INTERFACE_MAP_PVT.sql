--------------------------------------------------------
--  DDL for Package CN_SCA_INTERFACE_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_INTERFACE_MAP_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvmpgns.pls 120.2 2005/10/24 02:47:23 vensrini noship $


PROCEDURE GENERATE (
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_org_id            IN NUMBER, -- MOAC Change
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2);

END cn_sca_interface_map_pvt;
 

/
