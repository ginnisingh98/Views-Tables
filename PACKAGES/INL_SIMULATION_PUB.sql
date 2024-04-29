--------------------------------------------------------
--  DDL for Package INL_SIMULATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_SIMULATION_PUB" AUTHID CURRENT_USER AS
/* $Header: INLPSIMS.pls 120.0.12010000.1 2010/04/14 22:03:22 aicosta noship $ */

g_module_name VARCHAR2(100) := 'INL_SIMULATION_PUB';
g_pkg_name CONSTANT VARCHAR2(30) := 'INL_SIMULATION_PUB';


PROCEDURE Purge_Simulations(p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                            p_commit IN VARCHAR2 := FND_API.G_FALSE,
                            p_org_id IN NUMBER,
                            p_simulation_table IN INL_SIMULATION_PVT.simulation_id_tbl,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2);


END INL_SIMULATION_PUB;

/
