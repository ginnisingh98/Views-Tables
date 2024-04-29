--------------------------------------------------------
--  DDL for Package FEM_LOADER_ENG_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_LOADER_ENG_UTIL_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_ldr_eng_utl.pls 120.0 2006/02/08 11:54:13 gcheng noship $

--
-- Public package constants
--
G_API_VERSION             CONSTANT NUMBER       := 1.0;
G_FALSE                   CONSTANT VARCHAR2(1)  := FND_API.G_FALSE;
G_TRUE                    CONSTANT VARCHAR2(1)  := FND_API.G_TRUE;

PROCEDURE Get_Dim_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_dimension_id    IN NUMBER,
   x_exec_mode       OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Hier_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_dimension_id    IN NUMBER,
   p_hierarchy_name  IN VARCHAR2,
   x_exec_mode       OUT NOCOPY VARCHAR2
);

PROCEDURE Get_XGL_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_cal_period_id   IN NUMBER,
   p_ledger_id       IN NUMBER,
   p_dataset_code    IN NUMBER,
   x_exec_mode       OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Fact_Loader_Exec_Mode(
   p_api_version     IN NUMBER     DEFAULT G_API_VERSION,
   p_init_msg_list   IN VARCHAR2   DEFAULT G_FALSE,
   p_commit          IN VARCHAR2   DEFAULT G_FALSE,
   p_encoded         IN VARCHAR2   DEFAULT G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_cal_period_id   IN NUMBER,
   p_ledger_id       IN NUMBER,
   p_dataset_code    IN NUMBER,
   p_source_system_code IN NUMBER,
   p_table_name      IN VARCHAR2,
   x_exec_mode       OUT NOCOPY VARCHAR2
);


END FEM_LOADER_ENG_UTIL_PKG;

 

/
