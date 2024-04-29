--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_POOL_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_POOL_APPROVAL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSICS.pls 120.1 2005/10/30 03:17:07 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SUBSIDY_POOL_APPROVAL_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                     CONSTANT VARCHAR2(30)  := '_PVT';
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

  -------------------------------------------------------------------------------
  -- PROCEDURE submit_pool_for_approval
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_pool_for_approval
  -- Description     : This procedure is a wrapper that invokes a subsidy pool
  --                 : for initial pool approval
  --
  -- Business Rules  : for initial pool to be approved, the pool should have exactly
  --                   one budget line of type ADDITION with a  positive amount.
  --                   the pool and the line status should be NEW
  --
  -- Parameters      : required parameters are p_subsidy_pool_id
  -- Version         : 1.0
  -- History         : 01-FEB-2005 SJALASUT created
  -- End of comments

  PROCEDURE submit_pool_for_approval(p_api_version     IN 	NUMBER
                                    ,p_init_msg_list   IN  VARCHAR2
                                    ,x_return_status   OUT NOCOPY VARCHAR2
                                    ,x_msg_count       OUT NOCOPY NUMBER
                                    ,x_msg_data        OUT NOCOPY VARCHAR2
                                    ,p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                                    ,x_pool_status     OUT NOCOPY okl_subsidy_pools_b.decision_status_code%TYPE
                                    ,x_total_budgets  OUT NOCOPY okl_subsidy_pools_b.total_budgets%TYPE);

  -------------------------------------------------------------------------------
  -- PROCEDURE submit_budget_for_approval
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : submit_budget_for_approval
  -- Description     : This procedure is a wrapper that invokes a subsidy pool
  --                 : budget line for approval after the pool has been approved
  --
  -- Business Rules  : for the budget line to be approved, the pool must be in
  --                   status ACTIVE. the new budget line that is being submitted
  --                   for approval should be in status NEW. this api updates the
  --                   statuses appropriately
  --
  -- Parameters      : required parameters are p_subsidy_pool_budget_id
  -- Version         : 1.0
  -- History         : 01-FEB-2005 SJALASUT created
  -- End of comments

  PROCEDURE submit_budget_for_approval(p_api_version     IN 	NUMBER
                                    ,p_init_msg_list   IN  VARCHAR2
                                    ,x_return_status   OUT NOCOPY VARCHAR2
                                    ,x_msg_count       OUT NOCOPY NUMBER
                                    ,x_msg_data        OUT NOCOPY VARCHAR2
                                    ,p_subsidy_pool_budget_id IN okl_subsidy_pool_budgets_b.id%TYPE
                                    ,x_pool_budget_status OUT NOCOPY okl_subsidy_pool_budgets_b.decision_status_code%TYPE);

END okl_subsidy_pool_approval_pvt;

 

/
