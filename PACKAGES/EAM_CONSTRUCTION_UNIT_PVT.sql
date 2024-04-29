--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_UNIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_UNIT_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVCUS.pls 120.0.12010000.3 2008/11/20 10:18:11 dsingire noship $*/

g_debug_flag            VARCHAR2(1) := 'N';

PROCEDURE create_construction_unit(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      );

PROCEDURE update_construction_unit(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      );

PROCEDURE copy_construction_unit(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,p_source_cu_id_tbl        IN    EAM_CONSTRUCTION_UNIT_PUB.CU_ID_tbl
     ,x_cu_id                   OUT   NOCOPY  NUMBER
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      );

PROCEDURE validate_cu_details(
      p_api_version             IN    NUMBER
     ,p_commit                  IN    VARCHAR2
     ,p_cu_rec			            IN    EAM_CONSTRUCTION_UNIT_PUB.CU_rec
     ,p_cu_activity_tbl         IN    EAM_CONSTRUCTION_UNIT_PUB.CU_Activity_tbl
     ,p_action                  IN    VARCHAR2
     ,x_return_status           OUT   NOCOPY VARCHAR2
     ,x_msg_count               OUT   NOCOPY NUMBER
     ,x_msg_data                OUT   NOCOPY VARCHAR2
      );

--Procedures and functions used for debug purpose
PROCEDURE set_debug;
FUNCTION get_debug RETURN VARCHAR2;
PROCEDURE debug(p_message IN varchar2);

FUNCTION dump_error_stack RETURN VARCHAR2;

End EAM_CONSTRUCTION_UNIT_PVT;

/
