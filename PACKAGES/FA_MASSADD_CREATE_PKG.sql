--------------------------------------------------------
--  DDL for Package FA_MASSADD_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSADD_CREATE_PKG" AUTHID CURRENT_USER as
/* $Header: FAMADCS.pls 120.3.12010000.3 2009/07/19 09:43:12 glchen ship $ */

  -- This procedure is called by AP's create mass additions process.
  -- It is assumed that FA_MASS_ADDITIONS_GT is populated first before
  -- this procedure is called. This procedure process transactions for
  -- the given corporate book

  -- For internal development use only
  PROCEDURE create_lines(
              p_book_type_code    IN             VARCHAR2,
              p_api_version       IN             NUMBER,
              p_init_msg_list     IN             VARCHAR2 := FND_API.G_FALSE,
              p_commit            IN             VARCHAR2 := FND_API.G_FALSE,
              p_validation_level  IN             NUMBER   := FND_API.G_VALID_LEVEL_FULL,
              p_calling_fn        IN             VARCHAR2,
              x_return_status        OUT NOCOPY  VARCHAR2,
              x_msg_count            OUT NOCOPY  NUMBER,
              x_msg_data             OUT NOCOPY  VARCHAR2 );


END FA_MASSADD_CREATE_PKG;

/
