--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_POOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_POOL_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRSIPS.pls 120.1 2005/10/30 03:17:12 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  G_APP_NAME                  CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT   VARCHAR2(200) := 'OKL_SUBSIDY_POOL_PVT';
  G_API_TYPE		            CONSTANT VARCHAR2(4) := '_PVT';
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;


SUBTYPE subsidy_pool_rec IS okl_sip_pvt.sipv_rec_type ;
---------------------------------------------------------------------------
-- Procedures and Functions
---------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE create_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_sub_pool
  -- Description     : procedure for inserting the records in
  --                   table OKL_SUBSIDY_POOLS_B AND OKL_SUBSIDY_POOLS_TL
  -- Business Rules  : This procedure creates a subsidy pool with the status "new"
  --                   in the table OKL_SUBSIDY_POOLS_B.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_rec, x_sub_pool_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE create_sub_pool     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_sub_pool_rec     IN  subsidy_pool_rec
                                 ,x_sub_pool_rec     OUT NOCOPY subsidy_pool_rec
                                );

 ---------------------------------------------------------------------------
 -- PROCEDURE update_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_sub_pool
  -- Description     : procedure for updating the records in
  --                   table OKL_SUBSIDY_POOLS_B AND OKL_SUBSIDY_POOLS_TL
  -- Business Rules  : Procedure to update the subsidy pool.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_rec, x_sub_pool_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_sub_pool     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_sub_pool_rec     IN  subsidy_pool_rec
                                 ,x_sub_pool_rec     OUT NOCOPY subsidy_pool_rec
                                );
 ---------------------------------------------------------------------------
 -- PROCEDURE expire_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : expire_sub_pool
  -- Description     : procedure for validating that if the records exist in the
  --                   table OKL_SUBSIDY_POOLS_B then set its status to expire.
  -- Business Rules  : This procedure sets the pool status to "expire"and this is
  --                   an autonomous transaction.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 PROCEDURE expire_sub_pool ( p_api_version                  IN  NUMBER,
                             p_init_msg_list                IN  VARCHAR2,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE);

 ---------------------------------------------------------------------------
 -- PROCEDURE update_total_budget
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_total_budget
  -- Description     : procedure for updating the total budget amount
  --                   table OKL_SUBSIDY_POOLS_B.
  -- Business Rules  : As soon as any of the budget line attached to a subsisy pool gets
  --                   approved this procedure is called to update the total budgets of the pool
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id,p_total_budget_amt.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE update_total_budget ( p_api_version                  IN  NUMBER,
                                p_init_msg_list                IN  VARCHAR2,
                                x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_count                    OUT NOCOPY NUMBER,
                                x_msg_data                     OUT NOCOPY VARCHAR2,
                                p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE,
                                p_total_budget_amt             IN  okl_subsidy_pools_b.total_budgets%TYPE );

 ---------------------------------------------------------------------------
 -- PROCEDURE update_subsidy_amount
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_subsidy_amount
  -- Description     : procedure for updating the total subsidy amount
  --                   table OKL_SUBSIDY_POOLS_B.
  -- Business Rules  : subsidy amount is updated when the contract is booked, rebooked or a
  --                   quote is created, or a contract is reversed.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id, p_total_subsidy_amt.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE update_subsidy_amount ( p_api_version            IN  NUMBER,
                                  p_init_msg_list                IN  VARCHAR2,
                                  x_return_status                OUT NOCOPY VARCHAR2,
                                  x_msg_count                    OUT NOCOPY NUMBER,
                                  x_msg_data                     OUT NOCOPY VARCHAR2,
                                  p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE,
                                  p_total_subsidy_amt            IN  okl_subsidy_pools_b.total_subsidy_amount%TYPE);

 ---------------------------------------------------------------------------
 -- PROCEDURE set_decision_status_code
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_decision_status_code
  -- Description     : procedure for updating the decision status code
  --                   table OKL_SUBSIDY_POOLS_B.
  -- Business Rules  : Procedure sets the decision_status_code to the value passed to this procedure.
  --                   this is a status of a pool.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id,p_decision_status_code.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE set_decision_status_code ( p_api_version            IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE,
                                     p_decision_status_code         IN OUT NOCOPY okl_subsidy_pools_b.decision_status_code%TYPE);

 ---------------------------------------------------------------------------
 -- PROCEDURE validate_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_sub_pool
  -- Description     : procedure for validating the records in
  --                   table OKL_SUBSIDY_POOLS_B AND OKL_SUBSIDY_POOLS_TL
  -- Business Rules  : Validates the record passed to it.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE validate_sub_pool( p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_sub_pool_rec                 IN  subsidy_pool_rec);

END OKL_SUBSIDY_POOL_PVT;

 

/
