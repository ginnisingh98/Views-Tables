--------------------------------------------------------
--  DDL for Package CN_CALC_SUBLEDGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SUBLEDGER_PVT" AUTHID CURRENT_USER as
/* $Header: cnvcsubs.pls 120.1 2005/07/06 18:56:01 appldev ship $ */

  TYPE srp_subledger_rec_type IS RECORD
    (  physical_batch_id   NUMBER(15));

  TYPE srp_pe_subledger_rec_type IS RECORD
     ( salesrep_id         NUMBER(15),
       quota_id            NUMBER(15),
       accu_period_id      NUMBER(15),
       srp_plan_assign_id  NUMBER(15),
       input_ptd           cn_formula_common_pkg.num_table_type,
       input_itd           cn_formula_common_pkg.num_table_type,
       output_ptd          NUMBER,
       output_itd          NUMBER,
       perf_ptd            NUMBER,
       perf_itd            NUMBER,
       rollover            NUMBER,
       calc_type           VARCHAR2(30));

  TYPE je_batch_rec_type IS RECORD
    (  ledger_je_batch_id   NUMBER(15));

  -- API name 	: update_srp_subledger
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --
  -- Desc 	:
  --
  --
  --
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:  p_srp_subledger     srp_subledger_rec_type Require
  --
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	:
  --
  -- End of comments

  PROCEDURE update_srp_subledger
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_srp_subledger         IN srp_subledger_rec_type
      );

  -- API name 	: update_srp_pe_subledger
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --
  -- Desc 	:
  --
  --
  --
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:  p_srp_pe_subledger     srp_pe_subledger_rec_type Require
  --		   p_mode                  IN VARCHAR2 := 'A'
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	:
  --
  -- End of comments

  PROCEDURE update_srp_pe_subledger
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_srp_pe_subledger      IN srp_pe_subledger_rec_type,
      p_mode                  IN VARCHAR2 := 'A'
      );

  -- API name 	: post_je_batch
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --
  -- Desc 	:
  --
  --
  --
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:  p_je_batch          je_batch_rec_type Require
  --
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	:
  --
  -- End of comments

  PROCEDURE post_je_batch
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_je_batch             IN je_batch_rec_type
      );


  PROCEDURE roll_quotas_forecast(p_salesrep_id NUMBER,
				p_period_id   NUMBER,
				p_quota_id    NUMBER,
				p_srp_plan_assign_id NUMBER);

END cn_calc_subledger_pvt;

 

/
