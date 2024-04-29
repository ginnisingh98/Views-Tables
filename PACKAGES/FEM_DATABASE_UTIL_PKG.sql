--------------------------------------------------------
--  DDL for Package FEM_DATABASE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DATABASE_UTIL_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_db_utl.pls 120.3 2007/02/20 03:09:36 gcheng ship $

/***************************************************************************
                    Copyright (c) 2003 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
 FILENAME
    fem_db_utl.pls

 DESCRIPTION
    FEM Database Utilities Package

 HISTORY
    Tim Moore    14-Oct-2003   Original script
    Greg Hall    23-May-2005   Bug# 4301983 Added procedures for creating
                               temporary DB objects.
    Gordon Cheng 19-Feb-2007   Bug 5873766: Added p_pb_object_id
                 v120.3        parameter to the following procedures:
                                 Create_Temp_Table
                                 Create_Temp_Index
                                 Create_Temp_View
                                 Drop_Temp_DB_Objects
 **************************************************************************/

c_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success      CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version  CONSTANT  NUMBER       := 1.0;

PROCEDURE Get_Table_Owner (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_false,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_syn_name         IN         VARCHAR2,
   x_tab_name         OUT NOCOPY VARCHAR2,
   x_tab_owner        OUT NOCOPY VARCHAR2);

PROCEDURE Get_Unique_Temp_Name (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_false,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_temp_type        IN         VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_table_seq        IN         NUMBER     DEFAULT NULL,
   p_index_seq        IN         NUMBER     DEFAULT NULL,
   x_temp_name        OUT NOCOPY VARCHAR2);

PROCEDURE Create_Temp_Table (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_table_name       IN         VARCHAR2,
   p_table_def        IN         VARCHAR2,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL');

PROCEDURE Create_Temp_Index (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_table_name       IN         VARCHAR2,
   p_index_name       IN         VARCHAR2,
   p_index_columns    IN         VARCHAR2,
   p_unique_flag      IN         VARCHAR2,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL');

PROCEDURE Create_Temp_View (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_view_name        IN         VARCHAR2,
   p_view_def         IN         VARCHAR2,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL');

PROCEDURE Drop_Temp_DB_Objects (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL');

END FEM_Database_Util_Pkg;

/
