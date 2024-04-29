--------------------------------------------------------
--  DDL for Package FEM_DIM_CAL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_CAL_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: fem_dimcal_pkh.pls 120.0 2005/06/06 19:30:39 appldev noship $

------------------------
--  Package Constants --
------------------------

c_fem_ledger       CONSTANT  VARCHAR2(30) := 'FEM_LEDGER';
c_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;
c_success          CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp            CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
c_api_version      CONSTANT  NUMBER       := 1.0;

------------------
--  Subprograms --
------------------
PROCEDURE New_Calendar (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_calendar_id    OUT NOCOPY NUMBER,
   p_cal_disp_code   IN VARCHAR2,
   p_calendar_name   IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_period_set_name IN VARCHAR2,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_calendar_desc   IN VARCHAR2,
   p_include_adj_per_flg IN VARCHAR2,
   p_default_cal_per IN NUMBER DEFAULT NULL,
   p_default_member  IN NUMBER DEFAULT NULL,
   p_default_load_member IN NUMBER DEFAULT NULL,
   p_default_hier    IN NUMBER DEFAULT NULL
);

PROCEDURE New_Time_Group_Type (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_time_grp_type_code  IN VARCHAR2,
   p_time_grp_type_name  IN VARCHAR2,
   p_time_grp_type_desc  IN VARCHAR2  DEFAULT NULL,
   p_periods_in_year     IN NUMBER,
   p_ver_name            IN VARCHAR2,
   p_ver_disp_cd         IN VARCHAR2,
   p_read_only_flag      IN VARCHAR2  DEFAULT 'N'
);

PROCEDURE New_Time_Dimension_Group (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_dim_grp_id     OUT NOCOPY NUMBER,
   p_time_grp_type_code  IN VARCHAR2,
   p_dim_grp_name    IN VARCHAR2,
   p_dim_grp_disp_cd IN VARCHAR2,
   p_dim_grp_desc    IN VARCHAR2  DEFAULT NULL,
   p_read_only_flag  IN VARCHAR2  DEFAULT 'N'
);

END FEM_DIM_CAL_UTIL_PKG;

 

/
