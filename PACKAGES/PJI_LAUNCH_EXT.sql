--------------------------------------------------------
--  DDL for Package PJI_LAUNCH_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_LAUNCH_EXT" AUTHID CURRENT_USER as
  /* $Header: PJILN02S.pls 120.0.12010000.2 2009/08/28 07:19:56 dlella noship $ */
TYPE prg_proj_tbl IS
TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE PROJ_LIST (p_prg_proj_tbl OUT  NOCOPY prg_proj_tbl,
                     p_context OUT NOCOPY  varchar2,
                     p_budget_lines_count OUT NOCOPY  number);

end PJI_LAUNCH_EXT;

/
