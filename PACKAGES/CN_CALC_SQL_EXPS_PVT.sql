--------------------------------------------------------
--  DDL for Package CN_CALC_SQL_EXPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SQL_EXPS_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvcexps.pls 120.6 2007/03/14 12:56:42 kjayapau ship $*/

TYPE parent_expression_tbl_type IS TABLE OF VARCHAR2(30)
  INDEX BY BINARY_INTEGER;

TYPE calc_expression_rec_type IS RECORD
  (CALC_SQL_EXP_ID                CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
   NAME                           CN_CALC_SQL_EXPS.NAME%TYPE,
   DESCRIPTION                    CN_CALC_SQL_EXPS.DESCRIPTION%TYPE,
   STATUS                         CN_CALC_SQL_EXPS.STATUS%TYPE,
   EXP_TYPE_CODE                  CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE);

TYPE calc_expression_tbl_type IS TABLE OF calc_expression_rec_type
  INDEX BY BINARY_INTEGER;

TYPE expr_type_rec_type IS RECORD
  (node_value                     VARCHAR2(80), -- not based off any table
   node_label                     VARCHAR2(80),
   parent_node_value              VARCHAR2(80),
   element                        VARCHAR2(4000));
   -- 500 should be long enough... some elements are CLOBs

TYPE expr_type_tbl_type IS TABLE OF expr_type_rec_type
  INDEX BY BINARY_INTEGER;

TYPE num_tbl_type IS TABLE OF number
  INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name        : Create_Expression
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN      NUMBER       Required
--                      p_init_msg_list       IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN      NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_name                IN      VARCHAR2     Required
--                      p_description         IN      VARCHAR2     Optional
--                        Default = null
--                      p_expression_disp     IN      VARCHAR2     Optional
--                        Default = null
--                      p_sql_select          IN      VARCHAR2     Optional
--                        Default = null
--                      p_sql_from            IN      VARCHAR2     Optional
--                        Default = null
--                      p_piped_expression_disp IN    VARCHAR2     Optional
--                        Default = null
--                      p_piped_sql_select    IN      VARCHAR2     Optional
--                        Default = null
--                      p_piped_sql_from      IN      VARCHAR2     Optional
--                        Default = null
--    OUT             : x_calc_sql_exp_id     OUT     NUMBER
--                      x_exp_type_code       OUT     VARCHAR2(30)
--                      x_status              OUT     VARCHAR2(30)
--                      x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Create SQL expressions that will be used in
--                      calculation.
--                      1) Validate the expression and return the result in
--                         x_status (Valid or Invalid)
--                      2) Classify expressions into sub types for formula
--                         validation and dynamic rate table validation
--                      3) If there are embedded expressions, record the
--                         embedding relations in cn_calc_edges
--
-- End of comments

PROCEDURE Create_Expression
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_org_id			IN	CN_CALC_SQL_EXPS.ORG_ID%TYPE,
   p_name                       IN      CN_CALC_SQL_EXPS.NAME%TYPE,
   p_description                IN      CN_CALC_SQL_EXPS.DESCRIPTION%TYPE           := NULL,
   p_expression_disp            IN      VARCHAR2                                    := NULL, -- CLOBs
   p_sql_select                 IN      VARCHAR2                                    := NULL,
   p_sql_from                   IN      VARCHAR2                                    := NULL,
   p_piped_expression_disp      IN      VARCHAR2                                    := NULL,
   p_piped_sql_select           IN      VARCHAR2                                    := NULL,
   p_piped_sql_from             IN      VARCHAR2                                    := NULL,
   x_calc_sql_exp_id            IN OUT NOCOPY     CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
   x_exp_type_code              OUT NOCOPY     CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE,
   x_status                     OUT NOCOPY     CN_CALC_SQL_EXPS.STATUS%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        ,
   x_object_version_number	OUT NOCOPY     CN_CALC_SQL_EXPS.OBJECT_VERSION_NUMBER%TYPE);

-- Start of comments
--    API name        : Update_Expressions
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN      NUMBER       Required
--                      p_init_msg_list       IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN      NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_update_parent_also  IN      VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_calc_sql_exp_id     IN      NUMBER       Required
--                      p_name                IN      VARCHAR2     Required
--                      p_description         IN      VARCHAR2     Optional
--                        Default = null
--                      p_expression_disp     IN      VARCHAR2     Optional
--                        Default = null
--                      p_sql_select          IN      VARCHAR2     Optional
--                        Default = null
--                      p_sql_from            IN      VARCHAR2     Optional
--                        Default = null
--                      p_piped_expression_disp IN    VARCHAR2     Optional
--                        Default = null
--                      p_piped_sql_select    IN      VARCHAR2     Optional
--                        Default = null
--                      p_piped_sql_from      IN      VARCHAR2     Optional
--                        Default = null
--                      p_ovn                 IN      NUMBER       Required
--    OUT             : x_exp_type_code       OUT     VARCHAR2(30)
--                      x_status              OUT     VARCHAR2(30)
--                      x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Update SQL expressions that will be used in
--                      calculation.
--                      1) validate the expression and return the result in
--                         x_status (Valid or Invalid)
--                      2) re-classify expressions into sub types for formula
--                         validation and dynamic rate table validation
--                      3) adjust the corresponding embedding relations in
--                         cn_calc_edges
--                      4) if the expression is used, update the parent
--                         expressions, formulas accordingly
--
-- End of comments

PROCEDURE Update_Expression
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_update_parent_also         IN      VARCHAR2 := fnd_api.g_false     ,
   p_org_id			IN	CN_CALC_SQL_EXPS.ORG_ID%TYPE,
   p_calc_sql_exp_id            IN      CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
   p_name                       IN      CN_CALC_SQL_EXPS.NAME%TYPE,
   p_description                IN      CN_CALC_SQL_EXPS.DESCRIPTION%TYPE           := NULL,
   p_expression_disp            IN      VARCHAR2                                    := NULL, -- CLOBs
   p_sql_select                 IN      VARCHAR2                                    := NULL,
   p_sql_from                   IN      VARCHAR2                                    := NULL,
   p_piped_expression_disp      IN      VARCHAR2                                    := NULL,
   p_piped_sql_select           IN      VARCHAR2                                    := NULL,
   p_piped_sql_from             IN      VARCHAR2                                    := NULL,
   p_ovn                        IN OUT NOCOPY    CN_CALC_SQL_EXPS.OBJECT_VERSION_NUMBER%TYPE,
   x_exp_type_code              OUT NOCOPY     CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE,
   x_status                     OUT NOCOPY     CN_CALC_SQL_EXPS.STATUS%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

-- Start of comments
--      API name        : Delete_Expression
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version        IN      NUMBER       Required
--                        p_init_msg_list      IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit             IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level   IN      NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_calc_sql_exp_id    IN      NUMBER
--      OUT             : x_return_status      OUT     VARCHAR2(1)
--                        x_msg_count          OUT     NUMBER
--                        x_msg_data           OUT     VARCHAR2(2000)
--      Version :         Current version      1.0
--                        Initial version      1.0
--
--      Notes           : Delete an expression
--                        1) if it is used, it can not be deleted
--                        2) delete the embedding relations in cn_calc_edges
--                           if there is any
--
-- End of comments

PROCEDURE Delete_Expression
  (p_api_version                  IN    NUMBER                          ,
   p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                       IN    VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level             IN    NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
   p_calc_sql_exp_id              IN    CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
   x_return_status                OUT NOCOPY   VARCHAR2                        ,
   x_msg_count                    OUT NOCOPY   NUMBER                          ,
   x_msg_data                     OUT NOCOPY   VARCHAR2                        );

-- Start of comments
--      API name        : Get_Parent_Expressions
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version        IN      NUMBER       Required
--                        p_init_msg_list      IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit             IN      VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level   IN      NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_calc_sql_exp_id    IN      NUMBER
--      OUT             : x_parents_tbl        OUT     expression_tbl_type
--                        x_return_status      OUT     VARCHAR2(1)
--                        x_msg_count          OUT     NUMBER
--                        x_msg_data           OUT     VARCHAR2(2000)
--      Version :         Current version      1.0
--                        Initial version      1.0
--
--      Notes           : Get parent expressions if there is any
--
-- End of comments
/*PROCEDURE Get_Parent_Expressions
  (p_api_version                  IN    NUMBER                          ,
   p_init_msg_list                IN    VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                       IN    VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level             IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_calc_sql_exp_id              IN    CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
   x_parents_tbl                  OUT NOCOPY   parent_expression_tbl_type      ,
   x_return_status                OUT NOCOPY   VARCHAR2                        ,
   x_msg_count                    OUT NOCOPY   NUMBER                          ,
   x_msg_data                     OUT NOCOPY   VARCHAR2                        );*/

-- determine the expression type given its SQL statement.
PROCEDURE classify_expression
  (p_org_id		          IN	CN_CALC_SQL_EXPS.ORG_ID%TYPE,
   p_sql_select                   IN      VARCHAR2,  -- CLOBs
   p_sql_from                     IN      VARCHAR2,
   p_piped_sql_select             IN      VARCHAR2,
   p_piped_sql_from               IN      VARCHAR2,
   x_status                       IN OUT NOCOPY  CN_CALC_SQL_EXPS.STATUS%TYPE,
   x_exp_type_code                IN OUT NOCOPY  CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE,
   x_msg_count                    OUT NOCOPY     NUMBER,
   x_msg_data                     OUT NOCOPY     VARCHAR2);

-- translate the usage code of an expression to get its meaning
PROCEDURE get_usage_info
  (p_exp_type_code                IN      CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE,
   x_usage_info                   OUT NOCOPY     VARCHAR2);

-- populate the summary screen
/*PROCEDURE get_expr_summary
  (p_first                        IN      NUMBER,
   p_last                         IN      NUMBER,
   p_srch_name                    IN      VARCHAR2 := '%',
   x_total_rows                   OUT NOCOPY     NUMBER,
   x_result_tbl                   OUT NOCOPY     calc_expression_tbl_type);*/

-- populate the details for an expression
/*PROCEDURE get_expr_detail
  (p_calc_sql_exp_id              IN     CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
   x_name                         OUT NOCOPY    CN_CALC_SQL_EXPS.NAME%TYPE,
   x_description                  OUT NOCOPY    CN_CALC_SQL_EXPS.DESCRIPTION%TYPE,
   x_status                       OUT NOCOPY    CN_CALC_SQL_EXPS.STATUS%TYPE,
   x_exp_type_code                OUT NOCOPY    CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE,
   x_expression_disp              OUT NOCOPY    VARCHAR2, -- CLOBs
   x_sql_select                   OUT NOCOPY    VARCHAR2,
   x_sql_from                     OUT NOCOPY    VARCHAR2,
   x_piped_sql_select             OUT NOCOPY    VARCHAR2,
   x_piped_sql_from               OUT NOCOPY    VARCHAR2,
   x_piped_expression_disp        OUT NOCOPY    VARCHAR2,
   x_ovn                          OUT NOCOPY    CN_CALC_SQL_EXPS.OBJECT_VERSION_NUMBER%TYPE);*/

-- get all the types of elements that can be included in expressions.  the
-- types are arranged in a tree structure.  each type has a value, a label
-- and a parent value, as well as the element that gets included in the
-- expression value and SQL statement.
/*PROCEDURE get_type_tree
  (x_types                        OUT NOCOPY    expr_type_tbl_type);*/

-- parse a sql select statement looking for included plan elements
-- of the form (1234PE.COLUMN_NAME).  if any are found, include them in
-- the x_plan_elt_tbl and provide a parsed version of the sql select.
PROCEDURE parse_plan_elements
  (p_sql_select                   IN     VARCHAR2,
   x_plan_elt_tbl                 OUT NOCOPY    num_tbl_type,
   x_parsed_sql_select            OUT NOCOPY    VARCHAR2);

-- given a plan element, formula, or expression, determine all the plan
-- elements referenced directly or indirectly
-- pass in a node type (formula=F, plan element=P, expression=E), and the ID
PROCEDURE get_dependent_plan_elts
  (p_api_version               IN      NUMBER                          ,
   p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                    IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level          IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL ,
   p_node_type                 IN      VARCHAR2,
   p_node_id                   IN      NUMBER,
   x_plan_elt_id_tbl           OUT NOCOPY     num_tbl_type,
   x_return_status             OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                 OUT NOCOPY     NUMBER                          ,
   x_msg_data                  OUT NOCOPY     VARCHAR2                        );

-- given a plan element, formula, or expression, determine all the plan
-- elements that reference it directly or indirectly
-- pass in a node type (formula=F, plan element=P, expression=E), and the ID
PROCEDURE get_parent_plan_elts
  (p_api_version               IN      NUMBER                          ,
   p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                    IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level          IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL ,
   p_node_type                 IN      VARCHAR2,
   p_node_id                   IN      NUMBER,
   x_plan_elt_id_tbl           OUT  NOCOPY   num_tbl_type,
   x_return_status             OUT  NOCOPY   VARCHAR2                        ,
   x_msg_count                 OUT  NOCOPY  NUMBER                          ,
   x_msg_data                  OUT  NOCOPY  VARCHAR2                        );


-- import expressions
PROCEDURE import
  (errbuf                    OUT NOCOPY   VARCHAR2,
   retcode                   OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   p_org_id                  IN NUMBER);

-- export
PROCEDURE Export
  (errbuf                    OUT NOCOPY   VARCHAR2,
   retcode                   OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   p_org_id                  IN NUMBER);

PROCEDURE duplicate_expression
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_old_expr_id                IN      NUMBER,
   x_new_expr_id                OUT NOCOPY    NUMBER,
   x_new_expr_name              OUT NOCOPY     CN_CALC_SQL_EXPS.NAME%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

END CN_CALC_SQL_EXPS_PVT;

/
