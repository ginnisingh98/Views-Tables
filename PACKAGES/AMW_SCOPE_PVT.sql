--------------------------------------------------------
--  DDL for Package AMW_SCOPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_SCOPE_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvscps.pls 120.1 2008/02/08 14:26:41 adhulipa ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_SCOPE_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
TYPE sub_rec_type IS RECORD
(
    subsidiary_code	VARCHAR2(150) := null
);

TYPE  sub_tbl_type      IS TABLE OF sub_rec_type INDEX BY BINARY_INTEGER;


TYPE sub_new_rec_type IS RECORD
(
    subsidiary_id	NUMBER
);

TYPE  sub_new_tbl_type      IS TABLE OF sub_new_rec_type INDEX BY BINARY_INTEGER;

TYPE LOB_rec_type IS RECORD
(
   lob_code	VARCHAR2(150) := null
);

TYPE  lob_tbl_type      IS TABLE OF lob_rec_type INDEX BY BINARY_INTEGER;


TYPE lob_new_rec_type IS RECORD
(
    lob_id	NUMBER
);

TYPE  lob_new_tbl_type      IS TABLE OF lob_new_rec_type INDEX BY BINARY_INTEGER;


TYPE org_rec_type IS RECORD
(
    org_id   NUMBER
);

TYPE  org_tbl_type      IS TABLE OF org_rec_type INDEX BY BINARY_INTEGER;


TYPE process_rec_type IS RECORD
(
    process_id	NUMBER
);

TYPE  process_tbl_type      IS TABLE OF process_rec_type INDEX BY BINARY_INTEGER;

TYPE proc_hier_rec_type IS RECORD
(
    top_process_id	NUMBER,
    parent_process_id	NUMBER,
    process_id		NUMBER,
    level_id		NUMBER
);

TYPE proc_hier_tbl_type IS TABLE OF proc_hier_rec_type INDEX BY BINARY_INTEGER;

g_org_tbl          org_tbl_type;
g_process_tbl      process_tbl_type;

PROCEDURE add_scope
(
    p_api_version_number        IN   NUMBER   := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_id			IN   NUMBER,
    p_entity_type		IN   VARCHAR2,
    p_sub_vs		        IN   VARCHAR2,
    p_LOB_vs			IN   VARCHAR2,
    p_subsidiary_tbl	        IN   SUB_TBL_TYPE,
    p_lob_tbl			IN   LOB_TBL_TYPE,
    p_org_tbl			IN   ORG_TBL_TYPE,
    p_process_tbl               IN   PROCESS_TBL_TYPE,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE populate_custom_hierarchy
(
    p_org_tbl	    IN 	ORG_TBL_TYPE,
    p_entity_id     IN  NUMBER,
    p_entity_type   IN  VARCHAR2
);

PROCEDURE generate_organization_list
(
    p_entity_id                 IN   NUMBER,
    p_entity_type               IN   VARCHAR2,
    p_org_tbl	            	IN   ORG_TBL_TYPE,
    p_org_new_tbl               OUT  nocopy ORG_TBL_TYPE
);

PROCEDURE generate_subsidiary_list
(
    p_entity_id                 IN   NUMBER,
    p_entity_type               IN   VARCHAR2,
    p_org_new_tbl            	IN   ORG_TBL_TYPE,
    p_subsidiary_tbl            IN   sub_tbl_type,
    p_sub_vs                    IN   VARCHAR2,
    p_sub_new_tbl               OUT  nocopy  sub_new_tbl_type
);

PROCEDURE generate_lob_list
(
    p_entity_id                 IN   NUMBER,
    p_entity_type               IN   VARCHAR2,
    p_org_new_tbl            	IN   ORG_TBL_TYPE,
    p_subsidiary_tbl            IN   sub_tbl_type,
    p_sub_vs                    IN   VARCHAR2,
    p_lob_tbl                   IN   lob_tbl_type,
    p_lob_vs                    IN   VARCHAR2,
    p_lob_new_tbl               OUT  nocopy  lob_new_tbl_type
);

PROCEDURE populate_process_hierarchy
(
    p_api_version_number        IN       NUMBER := 1.0,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_entity_type               IN       VARCHAR2,
    p_entity_id		            IN	     NUMBER,
    p_org_tbl                   IN       org_tbl_type,
    p_process_tbl               IN       process_tbl_type,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
);

PROCEDURE insert_process
(
    p_level_id            IN NUMBER,
    p_parent_process_id   IN NUMBER,
    p_top_process_id      IN NUMBER,
    p_process_org_rev_id  IN NUMBER,
    p_subsidiary_vs       IN VARCHAR2,
    p_subsidiary_code     IN VARCHAR2,
    p_lob_vs              IN VARCHAR2,
    p_lob_code            IN VARCHAR2,
    p_organization_id     IN NUMBER,
    p_entity_type         IN VARCHAR2,
    p_entity_id           IN NUMBER
);

PROCEDURE build_project_audit_task
(
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_audit_project_id		IN	 NUMBER,
        l_ineff_controls        IN   BOOLEAN := false,
    p_source_project_id		IN	 NUMBER := 0,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
);

PROCEDURE populate_denormalized_tables
(
    p_entity_type IN VARCHAR2,
    p_entity_id   IN NUMBER,
    p_org_tbl     IN org_tbl_type,
    p_process_tbl IN process_tbl_type,
    p_mode        IN VARCHAR2
);

PROCEDURE populate_association_tables
(
    p_api_version_number        IN   NUMBER := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_type               IN   VARCHAR2,
    p_entity_id                 IN   NUMBER,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE populate_scope
(
    p_api_version_number        IN   NUMBER := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_id			IN   NUMBER,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE manage_processes
(
    p_api_version_number        IN   NUMBER,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER := fnd_api.g_valid_level_full,
    p_entity_type		IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_organization_id		IN   NUMBER,
    p_proc_hier_tbl		IN   PROC_HIER_TBL_TYPE,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);

PROCEDURE remove_from_scope
(
    p_api_version_number        IN   NUMBER := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    p_object_type		IN   VARCHAR2,
    p_subsidiary_vs		IN   VARCHAR2,
    p_subsidiary_code	        IN   VARCHAR2,
    p_LOB_vs			IN   VARCHAR2,
    p_LOB_code			IN   VARCHAR2,
    p_organization_id		IN   NUMBER,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);


PROCEDURE remove_orgs_from_scope
(
    p_api_version_number        IN   NUMBER := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
);


FUNCTION find_child_orgs
(
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    p_object_tbl                IN   org_tbl_type
)
RETURN org_tbl_type;

FUNCTION find_child_objects
(
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    p_object_type               IN   VARCHAR2,
    p_object_tbl                IN   org_tbl_type
)
RETURN org_tbl_type;

function get_assoc_task_id(p_project_id in number,  p_task_id in number)
	 return number;
pragma restrict_references(get_assoc_task_id, WNDS);

PROCEDURE populate_proj_denorm_tables
(
    p_audit_project_id IN NUMBER
);



PROCEDURE get_accessible_root_orgs (
	 p_entity_id		   IN  NUMBER,
	 p_entity_type		   IN  VARCHAR2,
	 x_org_ids		   OUT NOCOPY VARCHAR2);


FUNCTION Has_Org_Access_in_hier (
	 p_is_global_owner	IN VARCHAR2,
	 p_org_id		IN NUMBER)
RETURN VARCHAR2;

PROCEDURE get_accessible_root_procs (
	 p_entity_id		   IN  NUMBER,
	 p_entity_type		   IN  VARCHAR2,
	 p_org_id		   IN  NUMBER,
	 x_proc_ids		   OUT NOCOPY VARCHAR2);

END amw_scope_pvt;




/
