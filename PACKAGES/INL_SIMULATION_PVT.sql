--------------------------------------------------------
--  DDL for Package INL_SIMULATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_SIMULATION_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVSIMS.pls 120.0.12010000.2 2011/01/05 16:54:07 acferrei noship $ */

g_module_name VARCHAR2(100) := 'INL_SIMULATION_PVT';
g_pkg_name CONSTANT VARCHAR2(30) := 'INL_SIMULATION_PVT';

TYPE from_association_rec IS RECORD(
     from_parent_table_name VARCHAR2(30),
     from_parent_table_id NUMBER);

TYPE from_association_tbl IS TABLE OF from_association_rec INDEX BY BINARY_INTEGER;

TYPE simulation_rec IS RECORD(
     simulation_id NUMBER,
     firmed_flag VARCHAR2(1),
     parent_table_name VARCHAR2(30),
     parent_table_id NUMBER,
     parent_table_revision_num NUMBER,
     version_num NUMBER,
     vendor_id NUMBER,
     vendor_site_id NUMBER,
     freight_code VARCHAR2(25),
     org_id NUMBER,
     attribute_category VARCHAR2(30),
     attribute1 VARCHAR2(150),
     attribute2 VARCHAR2(150),
     attribute3 VARCHAR2(150),
     attribute4 VARCHAR2(150),
     attribute5 VARCHAR2(150),
     attribute6 VARCHAR2(150),
     attribute7 VARCHAR2(150),
     attribute8 VARCHAR2(150),
     attribute9 VARCHAR2(150),
     attribute10 VARCHAR2(150),
     attribute11 VARCHAR2(150),
     attribute12 VARCHAR2(150),
     attribute13 VARCHAR2(150),
     attribute14 VARCHAR2(150),
     attribute15 VARCHAR2(150));

TYPE simulation_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE Create_Simulation (p_api_version IN NUMBER,
                             p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                             p_commit IN VARCHAR2 := FND_API.G_FALSE,
                             p_simulation_rec IN OUT NOCOPY simulation_rec,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE Copy_Simulation (p_api_version   IN NUMBER,
                           p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                           p_commit        IN VARCHAR2 := FND_API.G_FALSE,
                           p_simulation_id IN  NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2);


PROCEDURE Purge_Simulations(p_api_version IN NUMBER,
                            p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                            p_commit IN VARCHAR2 := FND_API.G_FALSE,
                            p_org_id IN NUMBER,
                            p_simulation_table IN simulation_id_tbl,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2);

END INL_SIMULATION_PVT;

/
