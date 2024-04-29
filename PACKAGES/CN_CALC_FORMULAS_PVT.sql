--------------------------------------------------------
--  DDL for Package CN_CALC_FORMULAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_FORMULAS_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvforms.pls 120.4 2006/05/26 00:49:40 jxsingh ship $*/
TYPE input_rec_type IS RECORD
  (formula_input_id      CN_FORMULA_INPUTS.FORMULA_INPUT_ID%TYPE := NULL,
   calc_sql_exp_id       CN_FORMULA_INPUTS.CALC_SQL_EXP_ID%TYPE,
   f_calc_sql_exp_id     CN_FORMULA_INPUTS.F_CALC_SQL_EXP_ID%TYPE,
   rate_dim_sequence     CN_FORMULA_INPUTS.RATE_DIM_SEQUENCE%TYPE,
   calc_exp_name         CN_CALC_SQL_EXPS.NAME%TYPE,
   calc_exp_status       CN_CALC_SQL_EXPS.STATUS%TYPE,
   f_calc_exp_name       CN_CALC_SQL_EXPS.NAME%TYPE,
   f_calc_exp_status     CN_CALC_SQL_EXPS.STATUS%TYPE,
   object_version_number CN_FORMULA_INPUTS.OBJECT_VERSION_NUMBER%TYPE,
   cumulative_flag       CN_FORMULA_INPUTS.CUMULATIVE_FLAG%TYPE,
   split_flag            CN_FORMULA_INPUTS.SPLIT_FLAG%TYPE);

TYPE rt_assign_rec_type IS RECORD
  (rt_formula_asgn_id    CN_RT_FORMULA_ASGNS.RT_FORMULA_ASGN_ID%TYPE := NULL,
   rate_schedule_id      CN_RT_FORMULA_ASGNS.RATE_SCHEDULE_ID%TYPE,
   start_date            CN_RT_FORMULA_ASGNS.START_DATE%TYPE,
   end_date              CN_RT_FORMULA_ASGNS.END_DATE%TYPE,
   rate_schedule_name    CN_RATE_SCHEDULES.NAME%TYPE,
   rate_schedule_type    CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   object_version_number CN_RT_FORMULA_ASGNS.OBJECT_VERSION_NUMBER%TYPE);

TYPE formula_rec_type IS RECORD
  (calc_formula_id         CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   name                    CN_CALC_FORMULAS.NAME%TYPE,
   description             CN_CALC_FORMULAS.DESCRIPTION%TYPE,
   formula_type            CN_CALC_FORMULAS.FORMULA_TYPE%TYPE,
   formula_status          CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   trx_group_code          CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE,
   number_dim              CN_CALC_FORMULAS.NUMBER_DIM%TYPE,
   cumulative_flag         CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE,
   itd_flag                CN_CALC_FORMULAS.ITD_FLAG%TYPE,
   split_flag              CN_CALC_FORMULAS.SPLIT_FLAG%TYPE,
   threshold_all_tier_flag CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE,
   modeling_flag           CN_CALC_FORMULAS.MODELING_FLAG%TYPE,
   perf_measure_id         CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE,
   output_exp_id           CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE,
   f_output_exp_id         CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE,
   object_version_number   CN_CALC_FORMULAS.OBJECT_VERSION_NUMBER%TYPE);

TYPE input_tbl_type             IS TABLE OF input_rec_type
  INDEX BY BINARY_INTEGER;
TYPE rt_assign_tbl_type         IS TABLE OF rt_assign_rec_type
  INDEX BY BINARY_INTEGER;
TYPE parent_expression_tbl_type IS TABLE OF VARCHAR2(30)
  INDEX BY BINARY_INTEGER;
TYPE formula_tbl_type           IS TABLE OF formula_rec_type
  INDEX BY BINARY_INTEGER;

g_miss_input_tbl     input_tbl_type;
g_miss_rt_assign_tbl rt_assign_tbl_type;

--    Notes    : Create calculation formula and generate formula packages
--               1) Validate formula name (should be unique)
--               2) Validate the combination of flags (cumulative_flag,
--                  itd_flag, etc.)
--               3) Validate performance measure, inputs, and output assignment
--               4) Validate rate table assignment (number of dimensions
--                  should match number of inputs)
--               5) If all validations are passed, generate formula packages
--                  and return the result in x_formula_status
--                  (Complete or Incomplete)
--
-- End of comments
PROCEDURE Create_Formula
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_generate_packages          IN      VARCHAR2 := FND_API.G_TRUE      ,
   p_name                       IN      CN_CALC_FORMULAS.NAME%TYPE,
   p_description                IN      CN_CALC_FORMULAS.DESCRIPTION%TYPE
                                        := null,
   p_formula_type               IN      CN_CALC_FORMULAS.FORMULA_TYPE%TYPE,
   p_trx_group_code             IN      CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE,
   p_number_dim                 IN      CN_CALC_FORMULAS.NUMBER_DIM%TYPE,
   p_cumulative_flag            IN      CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE,
   p_itd_flag                   IN      CN_CALC_FORMULAS.ITD_FLAG%TYPE,
   p_split_flag                 IN      CN_CALC_FORMULAS.SPLIT_FLAG%TYPE,
   p_threshold_all_tier_flag    IN      CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE,
   p_modeling_flag              IN      CN_CALC_FORMULAS.MODELING_FLAG%TYPE,
   p_perf_measure_id            IN      CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE,
   p_output_exp_id              IN      CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE,
   p_f_output_exp_id            IN      CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE
                                        := NULL,
   p_input_tbl                  IN      input_tbl_type     := g_miss_input_tbl,
   p_rt_assign_tbl              IN      rt_assign_tbl_type := g_miss_rt_assign_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_CALC_FORMULAS.ORG_ID%TYPE,   --new
   x_calc_formula_id            IN OUT NOCOPY     CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_formula_status             OUT NOCOPY     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

--    Notes     : Update calculation formula and generate formula packages
--                1) Validate formula name (should be unique)
--                2) Validate the combination of flags (cumulative_flag,
--                   itd_flag, etc.)
--                3) Validate performance measure, inputs, and output assignment
--                4) Validate rate table assignment (number of dimensions
--                   should match number of inputs)
--                5) If all validations are passed, generate formula packages
--                   and return the result in x_formula_status
--                   (Complete or Incomplete)
--
-- End of comments
PROCEDURE Update_Formula
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_generate_packages          IN      VARCHAR2 := FND_API.G_TRUE      ,
   p_calc_formula_id            IN      CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   p_name                       IN      CN_CALC_FORMULAS.NAME%TYPE,
   p_description                IN      CN_CALC_FORMULAS.DESCRIPTION%TYPE
                                        := null,
   p_formula_type               IN      CN_CALC_FORMULAS.FORMULA_TYPE%TYPE,
   p_formula_status             IN      CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   p_trx_group_code             IN      CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE,
   p_number_dim                 IN      CN_CALC_FORMULAS.NUMBER_DIM%TYPE,
   p_cumulative_flag            IN      CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE,
   p_itd_flag                   IN      CN_CALC_FORMULAS.ITD_FLAG%TYPE,
   p_split_flag                 IN      CN_CALC_FORMULAS.SPLIT_FLAG%TYPE,
   p_threshold_all_tier_flag    IN      CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE,
   p_modeling_flag              IN      CN_CALC_FORMULAS.MODELING_FLAG%TYPE,
   p_perf_measure_id            IN      CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE,
   p_output_exp_id              IN      CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE,
   p_f_output_exp_id            IN      CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE
                                        := NULL,
   p_input_tbl                  IN      input_tbl_type     := g_miss_input_tbl,
   p_rt_assign_tbl              IN      rt_assign_tbl_type := g_miss_rt_assign_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_CALC_FORMULAS.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY CN_CALC_FORMULAS.OBJECT_VERSION_NUMBER%TYPE, --Changed
   --R12 MOAC Changes--End
   x_formula_status             OUT NOCOPY     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

--      Notes     : Delete a formula
--                  1) if it is used, it can not be deleted
--
-- End of comments
PROCEDURE Delete_Formula
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                       IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level             IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL ,
   p_calc_formula_id              IN      CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   p_org_id                       IN      CN_CALC_FORMULAS.ORG_ID%TYPE,  --SFP related change
   --R12 MOAC Changes--Start
   p_object_version_number        IN      CN_CALC_FORMULAS.OBJECT_VERSION_NUMBER%TYPE, --new
   --R12 MOAC Changes--End
   x_return_status                OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                    OUT NOCOPY     NUMBER                          ,
   x_msg_data                     OUT NOCOPY     VARCHAR2                        );



--      Notes     : Generate the PL/SQL packages for the given formula
--
-- End of comments
PROCEDURE generate_formula
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_calc_formula_id            IN      CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   p_formula_type               IN      CN_CALC_FORMULAS.FORMULA_TYPE%TYPE
                                        := fnd_api.g_miss_char ,
   p_trx_group_code             IN      CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE
                                        := fnd_api.g_miss_char ,
   p_number_dim                 IN      CN_CALC_FORMULAS.NUMBER_DIM%TYPE
                                        := fnd_api.g_miss_num  ,
   p_itd_flag                   IN      CN_CALC_FORMULAS.ITD_FLAG%TYPE
                                        := fnd_api.g_miss_char ,
   p_perf_measure_id            IN      CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE
                                        := fnd_api.g_miss_num  ,
   p_output_exp_id              IN      CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE
                                        := fnd_api.g_miss_num  ,
   p_f_output_exp_id            IN      CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE
                                        := fnd_api.g_miss_num  ,
   x_formula_status             OUT NOCOPY     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_CALC_FORMULAS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );



END CN_CALC_FORMULAS_PVT;

 

/
