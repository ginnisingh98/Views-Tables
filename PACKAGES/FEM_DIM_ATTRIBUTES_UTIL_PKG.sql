--------------------------------------------------------
--  DDL for Package FEM_DIM_ATTRIBUTES_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_ATTRIBUTES_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_dimattr_utl.pls 120.4 2006/08/16 22:09:36 rflippo ship $ */

------------------------
--  Package Constants --
------------------------
pc_pkg_name            CONSTANT VARCHAR2(30) := 'fem_dim_attributes_util_pkg';

pc_ret_sts_success        CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_success;
pc_ret_sts_error          CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_error;
pc_ret_sts_unexp_error    CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_unexp_error;

pc_resp_app_id            CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;
pc_last_update_login      CONSTANT NUMBER := FND_GLOBAL.Login_Id;
pc_user_id                CONSTANT NUMBER := FND_GLOBAL.USER_ID;

pc_object_version_number  CONSTANT NUMBER := 1;

pc_log_level_statement    CONSTANT  NUMBER  := fnd_log.level_statement;
pc_log_level_procedure    CONSTANT  NUMBER  := fnd_log.level_procedure;
pc_log_level_event        CONSTANT  NUMBER  := fnd_log.level_event;
pc_log_level_exception    CONSTANT  NUMBER  := fnd_log.level_exception;
pc_log_level_error        CONSTANT  NUMBER  := fnd_log.level_error;
pc_log_level_unexpected   CONSTANT  NUMBER  := fnd_log.level_unexpected;

pc_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
pc_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;

------------------
--  Subprograms --
------------------

PROCEDURE create_attribute (x_attribute_id                  OUT NOCOPY NUMBER
                           ,x_msg_count                     OUT NOCOPY NUMBER
                           ,x_msg_data                      OUT NOCOPY VARCHAR2
                           ,x_return_status                 OUT NOCOPY VARCHAR2
                           ,p_api_version                   IN  NUMBER
                           ,p_commit                        IN  VARCHAR2
                           ,p_attr_varchar_label            IN  VARCHAR2
                           ,p_attr_name                     IN  VARCHAR2
                           ,p_attr_description              IN  VARCHAR2
                           ,p_dimension_varchar_label       IN  VARCHAR2
                           ,p_allow_mult_versions_flag      IN  VARCHAR2
                           ,p_queryable_for_reporting_flag  IN  VARCHAR2
                           ,p_use_inheritance_flag          IN  VARCHAR2
                           ,p_attr_order_type_code          IN  VARCHAR2
                           ,p_allow_mult_assign_flag        IN  VARCHAR2
                           ,p_personal_flag                 IN  VARCHAR2
                           ,p_attr_data_type_code           IN  VARCHAR2
                           ,p_attr_dimension_varchar_label  IN  VARCHAR2
                           ,p_version_display_code          IN  VARCHAR2
                           ,p_version_name                  IN  VARCHAR2
                           ,p_version_description           IN  VARCHAR2);

FUNCTION Get_Dim_Attribute_Value (
   p_api_version                 IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2   DEFAULT pc_false,
   p_commit                      IN  VARCHAR2   DEFAULT pc_false,
   p_encoded                     IN  VARCHAR2   DEFAULT pc_true,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_attribute_varchar_label     IN  VARCHAR2,
   p_member_id                   IN  NUMBER,
   p_value_set_id                IN  NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN  VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_mbr_id   IN  VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2;

FUNCTION Get_Dim_Attribute_Value (
   p_dimension_varchar_label     IN  VARCHAR2,
   p_attribute_varchar_label     IN  VARCHAR2,
   p_member_id                   IN  NUMBER,
   p_value_set_id                IN  NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN  VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_mbr_id   IN  VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2;


FUNCTION Get_Dim_Attr_Value_Set (
   p_api_version                 IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2   DEFAULT pc_false,
   p_commit                      IN  VARCHAR2   DEFAULT pc_false,
   p_encoded                     IN  VARCHAR2   DEFAULT pc_true,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_attribute_varchar_label     IN  VARCHAR2,
   p_member_id                   IN  NUMBER,
   p_value_set_id                IN  NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN  VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_vs_id    IN  VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2;

PROCEDURE New_Dim_Attr_Version (
   p_api_version                 IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2   DEFAULT pc_false,
   p_commit                      IN  VARCHAR2   DEFAULT pc_false,
   p_encoded                     IN  VARCHAR2   DEFAULT pc_true,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_attribute_varchar_label     IN  VARCHAR2,
   p_version_display_code        IN  VARCHAR2,
   p_version_name                IN  VARCHAR2,
   p_version_desc                IN  VARCHAR2   DEFAULT NULL,
   p_default_version_flag        IN  VARCHAR2   DEFAULT 'N'
);

PROCEDURE New_Dim_Attr_Default (
   p_api_version                 IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2   DEFAULT pc_false,
   p_commit                      IN  VARCHAR2   DEFAULT pc_false,
   p_encoded                     IN  VARCHAR2   DEFAULT pc_true,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_attribute_varchar_label     IN  VARCHAR2,
   p_version_display_code        IN  VARCHAR2
);

END FEM_DIM_ATTRIBUTES_UTIL_PKG;

 

/