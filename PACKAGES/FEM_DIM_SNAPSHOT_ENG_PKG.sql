--------------------------------------------------------
--  DDL for Package FEM_DIM_SNAPSHOT_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_SNAPSHOT_ENG_PKG" AUTHID CURRENT_USER AS
--$Header: fem_dimsnap_eng.pls 120.0 2005/10/19 19:22:43 appldev noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_dim_snapshot_eng.pls
 |
 | NAME fem_dim_snapshot_eng_pkg
 |
 | DESCRIPTION
 |
 |   Package Spec for fem_dim_snapshot_eng_pkg. This package provides functions
 |   and procedures required for creating Dimension Snapshots.  A Dimension
 |   Snapshot is a capture of the member "state" of a set of designated
 |   dimensions.  Only information for "shared" members is captured - information
 |   for personal members is ignored.  Information for each member (such as the
 |   attribute assignments) is copied into the Dimension Snapshot
 |   repository so that they can be accessed by applications (such as EPB)
 |   while the dimension state information in FEM continues to evolve.
 |
 |   Currently the engine only captures the following information:
 |     -- version translatable names and descriptions
 |     -- attribute assignments
 |
 |   The engine captures the above information for each dimension
 |   specified in the Dimension Snapshot rule.  The attribute information is
 |   copied into a seperate DNSP ATTR table for each specified attributed
 |   dimension while the version information is copied into a single
 |   shared table FEM_DSNP_DIM_ATTR_VRS_TL.
 |
 |   In both cases, the engine only captures those versions designated as the
 |   "default" version for each attribute of that dimension.
 |
 | HISTORY
 |
 |    29-JUN-05  Created
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


PROCEDURE Main (
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_api_version                   IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list                 IN VARCHAR2   DEFAULT c_false,
   p_commit                        IN VARCHAR2   DEFAULT c_true,
   p_encoded                       IN VARCHAR2   DEFAULT c_true,
   p_dim_snapshot_obj_def_id       IN NUMBER
);

END fem_dim_snapshot_eng_pkg;


 

/
