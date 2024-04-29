--------------------------------------------------------
--  DDL for Package FEM_DIM_SNAPSHOT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_SNAPSHOT_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: fem_dimsnap_utl.pls 120.0 2005/10/19 19:25:10 appldev noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_dim_snapshot_utl.pls
 |
 | NAME fem_dim_snapshot_utl_pkg
 |
 | DESCRIPTION
 |
 |   Package Spec for fem_dim_snapshot_utl_pkg. This package provides functions
 |   and procedures that support the Dimension Snapshot data model.
 |
 | HISTORY
 |
 |    01-JUL-05  Created
 |
 |
 +=========================================================================*/


------------------------
--  Package Constants --
------------------------

c_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version      CONSTANT  NUMBER       := 1.0;

c_user_id          CONSTANT NUMBER := FND_GLOBAL.USER_ID;
c_login_id         CONSTANT NUMBER := FND_GLOBAL.Login_Id;


PROCEDURE Add_Dimension (
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   p_api_version               IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list             IN VARCHAR2   DEFAULT c_false,
   p_commit                    IN VARCHAR2   DEFAULT c_false,
   p_encoded                   IN VARCHAR2   DEFAULT c_true,
   p_dim_snapshot_obj_def_id   IN NUMBER,
   p_dimension_varchar_label   IN VARCHAR2
);


PROCEDURE Remove_Dimension (
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   p_api_version               IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list             IN VARCHAR2   DEFAULT c_false,
   p_commit                    IN VARCHAR2   DEFAULT c_false,
   p_encoded                   IN VARCHAR2   DEFAULT c_true,
   p_dim_snapshot_obj_def_id   IN NUMBER,
   p_dimension_varchar_label   IN VARCHAR2
);

END fem_dim_snapshot_util_pkg;




 

/
