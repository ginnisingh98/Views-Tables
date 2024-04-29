--------------------------------------------------------
--  DDL for Package Body INL_SIMULATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_SIMULATION_PUB" AS
/* $Header: INLPSIMB.pls 120.0.12010000.1 2010/04/14 21:48:41 aicosta noship $ */

-- Utility name   : Purge_Simulations
-- Type       : Group
-- Function   : Purge Simulations and its Shipments
--
-- Pre-reqs   : None
-- Parameters :
-- IN         : p_api_version IN NUMBER
--              p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
--              p_commit IN VARCHAR2 := FND_API.G_FALSE
--              p_org_id IN NUMBER
--              p_simulation_table INL_SIMULATION_PVT.simulation_id_tbl
--
-- OUT        : x_return_status OUT NOCOPY VARCHAR2
--              x_msg_count OUT NOCOPY NUMBER
--              x_msg_data OUT NOCOPY VARCHAR2
--
--
-- Version    : Current version 1.0
--
-- Notes      :

PROCEDURE Purge_Simulations(p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                            p_commit IN VARCHAR2 := FND_API.G_FALSE,
                            p_org_id IN NUMBER,
                            p_simulation_table IN INL_SIMULATION_PVT.simulation_id_tbl,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2) IS
BEGIN

    INL_SIMULATION_PVT.Purge_Simulations(
                               p_api_version=> p_api_version,
                               p_init_msg_list => p_init_msg_list,
                               p_commit => p_commit,
                               p_org_id => p_org_id,
                               p_simulation_table => p_simulation_table,
                               x_return_status => x_return_status,
                               x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data);


END Purge_Simulations;

END INL_SIMULATION_PUB;

/
