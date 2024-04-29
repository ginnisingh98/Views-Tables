--------------------------------------------------------
--  DDL for Package FEM_MIR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_MIR_PKG" AUTHID CURRENT_USER AS
-- $Header: FEM_MIRS.pls 120.6 2007/05/04 05:52:47 pkakkar ship $


------------------------------------------------------------
-- Global constants definitions
-----------------------------------------------------------
g_unexpected_exception EXCEPTION;

G_ZIP_FILE_NAME      CONSTANT VARCHAR2(15) := 'ZIP_FILE_NAME';
G_SELECTION_SET_NAME CONSTANT VARCHAR2(30) := 'SELECTION_SET_NAME';
G_API_NAME           CONSTANT VARCHAR2(15) := 'API_NAME';
G_PRODUCT_NAME       CONSTANT VARCHAR2(15) := 'PRODUCT_NAME';
G_DESCRIPTION        CONSTANT VARCHAR2(15) := 'DESCRIPTION';
G_URL                CONSTANT VARCHAR2(4)  := 'URL';
G_IN_AGENT           CONSTANT VARCHAR2(15) := 'IN_AGENT';
G_OUT_AGENT          CONSTANT VARCHAR2(15) := 'OUT_AGENT';
G_USER_ID            CONSTANT VARCHAR2(15) := 'USER_ID';
G_USER_NAME          CONSTANT VARCHAR2(15) := 'USER_NAME';
G_CONFIG_ID          CONSTANT VARCHAR2(15) := 'CONFIG_ID';
G_REQUEST_ID         CONSTANT VARCHAR2(15) := 'REQUEST_ID';
G_EVENT_KEY          CONSTANT VARCHAR2(15) := 'EVENT_KEY';
G_RESP_ID            CONSTANT VARCHAR2(15) := 'RESP_ID';
G_RESP_APPL_ID       CONSTANT VARCHAR2(15) := 'RESP_APPL_ID';
G_IMPORT_DATA        CONSTANT VARCHAR2(15) := 'IMPORT_DATA';
G_DB_HOST            CONSTANT VARCHAR2(30) := 'DB_HOST';
G_TWOTASK            CONSTANT VARCHAR2(30) := 'TWO_TASK';
G_FEM                CONSTANT  VARCHAR2(3) := 'FEM';
c_fem_ledger         CONSTANT  VARCHAR2(30) := 'FEM_LEDGER';
c_false              CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true               CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error              CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp              CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_log_level_1        CONSTANT  NUMBER       := fnd_log.level_statement;
c_log_level_2        CONSTANT  NUMBER       := fnd_log.level_procedure;
c_log_level_3        CONSTANT  NUMBER       := fnd_log.level_event;
c_log_level_4        CONSTANT  NUMBER       := fnd_log.level_exception;
c_log_level_5        CONSTANT  NUMBER       := fnd_log.level_error;
c_log_level_6        CONSTANT  NUMBER       := fnd_log.level_unexpected;
c_api_version        CONSTANT  NUMBER       := 1.0;
-----------------------------------------------------------

FUNCTION Get_Dim_Group_Display_Code(
   p_dimension_varchar_label     IN  VARCHAR2,
   p_dimension_group_id          IN  NUMBER
) RETURN VARCHAR2 ;

FUNCTION Get_Dim_Group_Display_Code(
  p_dimension_id                IN  NUMBER,
  p_dimension_group_id          IN  NUMBER
) RETURN VARCHAR2 ;

FUNCTION Get_Dim_Group_ID(
   p_api_version                  IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list                IN  VARCHAR2   DEFAULT c_false,
   p_commit                       IN  VARCHAR2   DEFAULT c_false,
   p_encoded                      IN  VARCHAR2   DEFAULT c_true,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label      IN  VARCHAR2,
   p_dim_group_display_code       IN  VARCHAR2
) RETURN NUMBER ;

FUNCTION Get_Dim_Group_ID(
   p_api_version                  IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list                IN  VARCHAR2   DEFAULT c_false,
   p_commit                       IN  VARCHAR2   DEFAULT c_false,
   p_encoded                      IN  VARCHAR2   DEFAULT c_true,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_dimension_id                 IN  NUMBER,
   p_dim_group_display_code       IN  VARCHAR2
) RETURN NUMBER ;

FUNCTION Hier_Dim_Grp_Exists(
   p_api_version                  IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list                IN  VARCHAR2   DEFAULT c_false,
   p_commit                       IN  VARCHAR2   DEFAULT c_false,
   p_encoded                      IN  VARCHAR2   DEFAULT c_true,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label      IN  VARCHAR2,
   p_hierarchy_name               IN  VARCHAR2,
   p_dim_group_display_code       IN  VARCHAR2
) RETURN VARCHAR2 ;

FUNCTION Validate_Hier_Dim_Grps_Order(
   p_api_version                          IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list                        IN  VARCHAR2   DEFAULT c_false,
   p_commit                               IN  VARCHAR2   DEFAULT c_false,
   p_encoded                              IN  VARCHAR2   DEFAULT c_true,
   x_return_status                        OUT NOCOPY VARCHAR2,
   x_msg_count                            OUT NOCOPY NUMBER,
   x_msg_data                             OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label              IN  VARCHAR2,
   p_hierarchy_name                       IN  VARCHAR2,
   p_parent_dim_grp_dsp_code  IN  VARCHAR2,
   p_child_dim_grp_dsp_code   IN  VARCHAR2
) RETURN VARCHAR2 ;

FUNCTION Get_Dim_Attr_Varchar_label (
  p_attribute_id                IN  NUMBER
) RETURN VARCHAR2;


FUNCTION Get_Dim_Attribute_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_varchar_label      IN  VARCHAR2
  ,p_dim_attribute_varchar_label  IN  VARCHAR2
) RETURN NUMBER;

FUNCTION Get_Dim_Attribute_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_id                 IN  NUMBER
  ,p_dim_attribute_varchar_label  IN  VARCHAR2
) RETURN NUMBER;

FUNCTION Get_Dim_Attr_Ver_Display_Code (
  p_attribute_id                IN  NUMBER
  ,p_version_id                 IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Dim_Attr_Ver_Display_Code (
  p_dim_attr_varchar_label        IN  VARCHAR2
  ,p_version_id                   IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Dim_Attr_Version_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dim_attr_varchar_label       IN  VARCHAR2
  ,p_dim_attr_ver_display_code    IN  VARCHAR2
) RETURN NUMBER;


FUNCTION Get_Dim_Attr_Version_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dim_attribute_id             IN  NUMBER
  ,p_dim_attr_ver_display_code    IN  VARCHAR2
) RETURN NUMBER;

FUNCTION Get_Dim_Member_Display_Code (
  p_dimension_id                  IN  NUMBER
  ,p_member_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Dim_Member_Display_Code (
  p_dimension_varchar_label       IN  VARCHAR2
  ,p_member_id                    IN  NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Dim_Member_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_varchar_label      IN  VARCHAR2
  ,p_member_display_code          IN  VARCHAR2
  ) RETURN NUMBER;

FUNCTION Get_Dim_Member_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_id                 IN  NUMBER
  ,p_member_display_code          IN  VARCHAR2
  ) RETURN NUMBER ;

FUNCTION Get_Value_Set_Display_Code (
  p_value_set_id                  IN  NUMBER
   ) RETURN VARCHAR2;

FUNCTION Get_Value_Set_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_value_set_display_code       IN  VARCHAR2
   ) RETURN NUMBER;

FUNCTION Get_Gl_Period_Num(
  p_cal_period_id                 IN NUMBER
   ) RETURN NUMBER;

FUNCTION Get_Cal_Period_End_Date(
  p_cal_period_id                 IN NUMBER
   ) RETURN DATE;

FUNCTION Get_Object_ID (
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_object_def_id                IN  NUMBER
   ) RETURN NUMBER;

FUNCTION Get_Dimension_Id(
  p_api_version                   IN  NUMBER     DEFAULT 1.0
  ,p_init_msg_list                IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_commit                       IN  VARCHAR2   DEFAULT FND_API.G_FALSE
  ,p_encoded                      IN  VARCHAR2   DEFAULT FND_API.G_TRUE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_dimension_varchar_label     IN  VARCHAR2
) RETURN NUMBER;

END FEM_MIR_PKG;

/
