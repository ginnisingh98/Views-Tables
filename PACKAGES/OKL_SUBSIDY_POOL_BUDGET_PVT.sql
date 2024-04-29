--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_POOL_BUDGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_POOL_BUDGET_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRSIBS.pls 120.1 2005/10/30 03:17:04 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME                  CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT   VARCHAR2(200) := 'OKL_SUBSIDY_POOL_BUDGET_PVT';
  G_API_TYPE		            CONSTANT VARCHAR2(4) := '_PVT';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

SUBTYPE budget_line_rec IS okl_sib_pvt.sibv_rec_type ;
SUBTYPE budget_line_tbl IS okl_sib_pvt.sibv_tbl_type ;
---------------------------------------------------------------------------
-- Procedures and Functions
---------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE create_budget_line
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_budget_line
  -- Description     : procedure for inserting the records in
  --                   table OKL_SUBSIDY_POOL_BUDGETS
  -- Business Rules  : This procedure creates budget lines for a subsidy pool
  --                   where subsidy pool id of table OKL_SUBSIDY_POOL_BUDGETS
  --                   represents that pool id.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count
  --                   x_msg_data, p_budget_line_tbl, x_budget_line_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE create_budget_line  ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_budget_line_tbl  IN  budget_line_tbl
                                 ,x_budget_line_tbl  OUT NOCOPY budget_line_tbl
                                );
 ---------------------------------------------------------------------------
 -- PROCEDURE update_budget_line
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_budget_line
  -- Description     : procedure for updating the records in
  --                   table OKL_SUBSIDY_POOL_BUDGETS
  -- Business Rules  : This procedure updates the existing budget lines
  --                   only when the budget line status is "new".
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_budget_line_tbl, x_budget_line_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_budget_line  ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_budget_line_tbl  IN  budget_line_tbl
                                 ,x_budget_line_tbl  OUT NOCOPY budget_line_tbl
                                );
 ---------------------------------------------------------------------------
 -- PROCEDURE set_decision_status_code
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_decision_status_code
  -- Description     : procedure for updating the decision status code
  --                   table OKL_SUBSIDY_POOL_BUDGETS_B.
  -- Business Rules  : This procedure sets the value of column desicion_status_code
  --                   with the value passed to this procedure for the given line id.
  --                   decision_status_code is a status of the corresponding budget line.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_budget_id, p_decision_status_code.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE set_decision_status_code ( p_api_version                  IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_sub_pool_budget_id           IN  okl_subsidy_pool_budgets_b.id%TYPE,
                                     p_decision_status_code         IN OUT NOCOPY okl_subsidy_pool_budgets_b.decision_status_code%TYPE);

 ---------------------------------------------------------------------------
 -- PROCEDURE validate_budget_line
 ---------------------------------------------------------------------------
  -- Start of comments

  -- Procedure Name  : validate_budget_line
  -- Description     : procedure for validating the records in

  --                   table OKL_SUBSIDY_POOL_BUDGETS
  -- Business Rules  : Validates the attributes.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_budget_line_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE validate_budget_line( p_api_version       IN  NUMBER,
                                p_init_msg_list     IN  VARCHAR2,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2,
                                p_budget_line_tbl   IN  budget_line_tbl
                              );

END OKL_SUBSIDY_POOL_BUDGET_PVT;


 

/
