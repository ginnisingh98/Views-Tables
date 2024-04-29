--------------------------------------------------------
--  DDL for Package FEM_DIM_HIER_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_HIER_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: fem_dimhier_pkh.pls 120.0 2005/06/06 19:02:40 appldev noship $

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
PROCEDURE New_Hier_Object (
   p_api_version           IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list         IN VARCHAR2   DEFAULT c_false,
   p_commit                IN VARCHAR2   DEFAULT c_false,
   p_encoded               IN VARCHAR2   DEFAULT c_true,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_hier_obj_id          OUT NOCOPY NUMBER,
   x_hier_obj_def_id      OUT NOCOPY NUMBER,
   p_folder_id             IN NUMBER,
   p_global_vs_combo_id    IN NUMBER,
   p_object_access_code    IN VARCHAR2,
   p_object_origin_code    IN VARCHAR2,
   p_object_name           IN VARCHAR2,
   p_description           IN VARCHAR2,
   p_effective_start_date  IN DATE   DEFAULT sysdate,
   p_effective_end_date    IN DATE   DEFAULT to_date
                                     ('9999/01/01','YYYY/MM/DD'),
   p_obj_def_name          IN VARCHAR2,
   p_dimension_id          IN NUMBER,
   p_hier_type_code        IN VARCHAR2,
   p_grp_seq_code          IN VARCHAR2,
   p_multi_top_flg         IN VARCHAR2,
   p_fin_ctg_flg           IN VARCHAR2,
   p_multi_vs_flg          IN VARCHAR2,
   p_hier_usage_code       IN VARCHAR2,
   p_flat_rows_flag        IN VARCHAR2  DEFAULT 'N',
   p_gl_period_type        IN VARCHAR2  DEFAULT NULL,
   p_calendar_id           IN NUMBER    DEFAULT NULL,
   p_val_set_id1           IN NUMBER    DEFAULT NULL,
   p_val_set_id2           IN NUMBER    DEFAULT NULL,
   p_val_set_id3           IN NUMBER    DEFAULT NULL,
   p_val_set_id4           IN NUMBER    DEFAULT NULL,
   p_val_set_id5           IN NUMBER    DEFAULT NULL,
   p_val_set_id6           IN NUMBER    DEFAULT NULL,
   p_val_set_id7           IN NUMBER    DEFAULT NULL,
   p_val_set_id8           IN NUMBER    DEFAULT NULL,
   p_val_set_id9           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id1           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id2           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id3           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id4           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id5           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id6           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id7           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id8           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id9           IN NUMBER    DEFAULT NULL
);

PROCEDURE New_Hier_Object_Def (
   p_api_version           IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list         IN VARCHAR2   DEFAULT c_false,
   p_commit                IN VARCHAR2   DEFAULT c_false,
   p_encoded               IN VARCHAR2   DEFAULT c_true,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_hier_obj_def_id      OUT NOCOPY NUMBER,
   p_hier_obj_id           IN NUMBER,
   p_obj_def_name          IN VARCHAR2,
   p_effective_start_date  IN DATE,
   p_effective_end_date    IN DATE,
   p_object_origin_code    IN VARCHAR2
);

PROCEDURE New_GL_Cal_Period_Hier (
   p_api_version           IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list         IN VARCHAR2   DEFAULT c_false,
   p_commit                IN VARCHAR2   DEFAULT c_false,
   p_encoded               IN VARCHAR2   DEFAULT c_true,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_hier_obj_id          OUT NOCOPY NUMBER,
   x_hier_obj_def_id      OUT NOCOPY NUMBER,
   p_folder_id             IN NUMBER,
   p_object_access_code    IN VARCHAR2,
   p_object_origin_code    IN VARCHAR2,
   p_object_name           IN VARCHAR2,
   p_description           IN VARCHAR2,
   p_effective_start_date  IN DATE   DEFAULT sysdate,
   p_effective_end_date    IN DATE   DEFAULT to_date
                                     ('9999/01/01','YYYY/MM/DD'),
   p_obj_def_name          IN VARCHAR2,
   p_grp_seq_code          IN VARCHAR2,
   p_multi_top_flg         IN VARCHAR2,
   p_gl_period_type        IN VARCHAR2,
   p_dim_grp_id            IN NUMBER,
   p_calendar_id           IN NUMBER
);

END FEM_Dim_Hier_Util_Pkg;


 

/
