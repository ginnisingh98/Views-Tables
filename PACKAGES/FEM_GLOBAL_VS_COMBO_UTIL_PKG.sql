--------------------------------------------------------
--  DDL for Package FEM_GLOBAL_VS_COMBO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_GLOBAL_VS_COMBO_UTIL_PKG" AUTHID CURRENT_USER as
--$Header: fem_globvs_utl.pls 120.1 2008/02/20 06:57:33 jcliving ship $

c_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version      CONSTANT  NUMBER       := 1.0;


PROCEDURE refresh_ledger_vs_maps (
   p_global_vs_combo_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2);




END fem_global_vs_combo_util_pkg;

/
