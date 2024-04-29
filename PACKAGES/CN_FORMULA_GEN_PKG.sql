--------------------------------------------------------
--  DDL for Package CN_FORMULA_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_FORMULA_GEN_PKG" AUTHID CURRENT_USER AS
-- $Header: cnfmgens.pls 120.3 2005/12/01 15:22:49 ymao noship $

  -- API name 	: generate_formula
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	: create a formula package and store in cn_sources, then submit a concurrent
  --              spool the code to a file and get it compiled against the database.
  --
  --
  --+
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:  p_formula_id        NUMBER(15)  Require
  --
  --  OUT       :  x_process_audit_id  NUMBER(15)
  --  +
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE generate_formula
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_formula_id            IN  NUMBER,
      p_org_id                IN  NUMBER,
      x_process_audit_id      OUT NOCOPY NUMBER
      );

  -- Procedure Name
  --   create_formula
  -- Scope
  --   local to cn_formula_gen_pkg, make it open for debugging purpose
  -- Purpose
  --   invoke all formula component constructors to create formula
  -- History
  --   02-March 1999	Richard Jin	Created
  --+
  FUNCTION create_formula (p_formula_id	number) RETURN BOOLEAN;

  PROCEDURE generate_formula_conc(errbuf       OUT NOCOPY     VARCHAR2,
		                          retcode      OUT NOCOPY     NUMBER,
                                  p_org_id     NUMBER := NULL);

END cn_formula_gen_pkg;
 

/
