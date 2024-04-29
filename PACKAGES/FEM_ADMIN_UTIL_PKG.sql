--------------------------------------------------------
--  DDL for Package FEM_ADMIN_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_ADMIN_UTIL_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_adm_utl.pls 120.4 2008/02/06 23:14:06 ghall ship $

c_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_api_version  CONSTANT  NUMBER       := 1.0;

PROCEDURE Delete_Obj_Tuning_Options (
p_api_version     IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
p_commit          IN         VARCHAR2   DEFAULT c_false,
p_encoded         IN         VARCHAR2   DEFAULT c_true,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2,
p_object_id       IN         NUMBER
);

PROCEDURE New_Local_VS_Combo_ID (
p_api_version     IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
p_commit          IN         VARCHAR2   DEFAULT c_false,
p_encoded         IN         VARCHAR2   DEFAULT c_true,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2,
p_gvsc_id         IN         NUMBER
);

PROCEDURE Validate_Tab_Class_Assignmt (
p_api_version       IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list     IN         VARCHAR2   DEFAULT c_false,
p_commit            IN         VARCHAR2   DEFAULT c_false,
p_encoded           IN         VARCHAR2   DEFAULT c_true,
x_return_status     OUT NOCOPY VARCHAR2,
x_msg_count         OUT NOCOPY NUMBER,
x_msg_data          OUT NOCOPY VARCHAR2,
p_tab_name          IN         VARCHAR2
);

PROCEDURE Validate_Tab_Class (
p_tab_name          IN         VARCHAR2,
p_tab_class_cd      IN         VARCHAR2,
x_passed_validation OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_View_Class (
p_view_name         IN         VARCHAR2,
p_tab_class_cd      IN         VARCHAR2,
x_passed_validation OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_obj_Class_Assignmt (
p_api_version       IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list     IN         VARCHAR2   DEFAULT c_false,
p_commit            IN         VARCHAR2   DEFAULT c_false,
p_encoded           IN         VARCHAR2   DEFAULT c_true,
x_return_status     OUT NOCOPY VARCHAR2,
x_msg_count         OUT NOCOPY NUMBER,
x_msg_data          OUT NOCOPY VARCHAR2,
p_obj_name          IN         VARCHAR2,
p_obj_type          IN         VARCHAR2
);

PROCEDURE Get_Table_Owner_for_View (
            p_api_version     IN         NUMBER     DEFAULT c_api_version,
            p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
            p_commit          IN         VARCHAR2   DEFAULT c_false,
            p_encoded         IN         VARCHAR2   DEFAULT c_true,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_view_name       IN         VARCHAR2,
            x_tab_name        OUT NOCOPY VARCHAR2,
            x_tab_owner       OUT NOCOPY VARCHAR2
);
PROCEDURE Get_Index_Owner_for_View (
            p_api_version     IN         NUMBER     DEFAULT c_api_version,
            p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
            p_commit          IN         VARCHAR2   DEFAULT c_false,
            p_encoded         IN         VARCHAR2   DEFAULT c_true,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_view_name       IN         VARCHAR2,
			p_index_name      IN         VARCHAR2,
            x_tab_name        OUT NOCOPY VARCHAR2,
            x_tab_owner       OUT NOCOPY VARCHAR2 );

END FEM_Admin_Util_Pkg;

/
