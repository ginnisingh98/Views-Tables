--------------------------------------------------------
--  DDL for Package FEM_DIM_GROUPS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_GROUPS_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_dimgrp_utl.pls 120.1 2005/07/20 14:41:05 appldev ship $ */
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_dimgrp_utl.pls
 |
 | DESCRIPTION
 |   Utility package for Dimension Groups (also known as "levels")
 |
 | MODIFICATION HISTORY
 |   Robert Flippo  06/03/2005 Created
 |   Robert Flippo  07/20/2005 Bug#4504983 Add dim_group_sequence as
 |                             OUT parm;  Add NULL default for
 |                             p_dimension_group_seq
 |
 *=======================================================================*/
------------------------
--  Package Constants --
------------------------
pc_pkg_name            CONSTANT VARCHAR2(30) := 'fem_dim_groups_util_pkg';

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

PROCEDURE create_dim_group (x_dimension_group_id            OUT NOCOPY NUMBER
                           ,x_dim_group_sequence            OUT NOCOPY NUMBER
                           ,x_msg_count                     OUT NOCOPY NUMBER
                           ,x_msg_data                      OUT NOCOPY VARCHAR2
                           ,x_return_status                 OUT NOCOPY VARCHAR2
                           ,p_api_version                   IN  NUMBER     DEFAULT 1.0
                           ,p_init_msg_list                 IN  VARCHAR2   DEFAULT pc_false
                           ,p_commit                        IN  VARCHAR2   DEFAULT pc_false
                           ,p_encoded                       IN  VARCHAR2   DEFAULT pc_true
                           ,p_dimension_varchar_label       IN  VARCHAR2
                           ,p_dim_group_display_code        IN  VARCHAR2
                           ,p_dim_group_name                IN  VARCHAR2
                           ,p_dim_group_description         IN  VARCHAR2
                           ,p_dim_group_sequence            IN  NUMBER DEFAULT NULL
                           ,p_time_group_type_code          IN  VARCHAR2 DEFAULT NULL);


END FEM_DIM_GROUPS_UTIL_PKG;


 

/
