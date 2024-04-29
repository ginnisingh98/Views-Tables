--------------------------------------------------------
--  DDL for Package RRS_HIERARCHY_CRUD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_HIERARCHY_CRUD_PKG" AUTHID CURRENT_USER AS
/* $Header: RRSHRCRS.pls 120.1.12010000.4 2009/08/07 21:23:23 pochang noship $ */
procedure Update_Hierarchy_Header(
        p_api_version IN NUMBER DEFAULT 1,
        p_name IN VARCHAR2,
        p_new_name IN VARCHAR2 DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL,
        p_nullify_flag IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Update_Hierarchy_Node(
        p_api_version IN NUMBER DEFAULT 1,
        p_number IN VARCHAR2,
        p_name IN VARCHAR2 DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_nullify_flag IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Create_Hierarchy_Node(
        p_api_version IN NUMBER DEFAULT 1,
        p_number IN VARCHAR2,
        p_name IN VARCHAR2 DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Create_Hierarchy_Coarse(
        p_api_version IN NUMBER DEFAULT 1,
        p_hier_name IN VARCHAR2,
        p_hier_description IN VARCHAR2 DEFAULT NULL,
        p_hier_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_hier_start_date IN DATE DEFAULT NULL,
        p_hier_end_date IN DATE DEFAULT NULL,
        p_hier_members_tab IN RRS_HIER_MEMBERS_COARSE_TAB DEFAULT NULL,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Update_Hierarchy_Coarse(
        p_api_version IN NUMBER DEFAULT 1,
        p_hier_name IN VARCHAR2,
        p_hier_new_name IN VARCHAR2 DEFAULT NULL,
        p_hier_description IN VARCHAR2 DEFAULT NULL,
        p_hier_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_hier_start_date IN DATE DEFAULT NULL,
        p_hier_end_date IN DATE DEFAULT NULL,
        p_hier_members_tab IN RRS_HIER_MEMBERS_COARSE_TAB DEFAULT NULL,
        p_nullify_flag IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Create_Hierarchy_Members(
        p_hier_version_id IN NUMBER,
        p_hier_id IN NUMBER,
        p_root_id IN NUMBER,
        p_root_number IN VARCHAR2,
        p_hier_purpose_code IN VARCHAR2,
        p_hier_members_tab IN RRS_HIER_MEMBERS_COARSE_TAB,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Update_Hierarchy_Fine(
        p_api_version IN NUMBER DEFAULT 1,
        p_hier_members_rec IN RRS_HIER_MEMBERS_FINE_REC,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Validate_Rules_For_Members(
        p_hier_purpose_code IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Validate_Rules_For_Child(
        p_hier_purpose_code IN VARCHAR2,
        p_parent_id_number IN VARCHAR2,
        p_parent_object_type IN VARCHAR2,
        p_parent_purpose_code IN VARCHAR2,
        p_child_id_number IN VARCHAR2,
        p_child_object_type IN VARCHAR2,
        p_child_purpose_code IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_data OUT NOCOPY VARCHAR2
);

-- Hierarchy and Hierarchy Association Validation API
procedure Validate_Hierarchy_Status(
        p_hier_id IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);

procedure Validate_Hierarchy_Association(
        p_hier_id IN VARCHAR2,
        p_parent_id IN VARCHAR2,
        p_parent_object_type IN VARCHAR2,
        p_child_id IN VARCHAR2,
        p_child_object_type IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
);


/*
procedure Update_Hierarchy_Header_Test;

procedure Update_Hierarchy_Node_Test;

procedure Create_Hierarchy_Node_Test;

procedure Create_Hierarchy_Coarse_Test;

procedure Update_Hierarchy_Coarse_Test;

procedure Update_Hierarchy_Fine_Test;
*/

END;

/
