--------------------------------------------------------
--  DDL for Package FEM_INTG_BAL_ENG_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_INTG_BAL_ENG_LOAD_PKG" AUTHID CURRENT_USER as
/* $Header: fem_intg_be_load.pls 120.0 2005/06/06 21:44:18 appldev noship $ */
--
-- Package
--   fem_intg_bal_eng_load_pkg
-- Purpose
--   Balances engine program for OGL-FEM integration
-- History
--   11-NOV-04  M Ward          Created
--

  --
  -- Procedure
  --   Load_Std_Balances
  -- Purpose
  --   Load standard balances into the FEM_BAL_POST_INTERIM_GT table. This
  --   handles both the snapshot and incremental loads.
  -- Arguments
  --   x_completion_code	0 (Success), 1 (Warning), or 2 (Failure)
  --   x_num_rows_inserted	Total number of rows inserted
  --   p_bsv_range_low		Low value for the range of balancing segment
  --				values to be filtered in
  --   p_bsv_range_high		High value for the range of balancing segment
  --				values to be filtered in
  --   p_maintain_qtd		Whether or not to track QTD balances
  -- Example
  --   FEM_INTG_BAL_ENG_LOAD_PKG.Load_Std_Balances(completion_code, num_rows, list);
  -- Notes
  --
  PROCEDURE Load_Std_Balances(	x_completion_code	OUT NOCOPY NUMBER,
				x_num_rows_inserted	OUT NOCOPY NUMBER,
				p_bsv_range_low		VARCHAR2,
				p_bsv_range_high	VARCHAR2,
				p_maintain_qtd		VARCHAR2);

  --
  -- Procedure
  --   Load_Avg_Balances
  -- Purpose
  --   Load average balances into the FEM_BAL_POST_INTERIM_GT table.
  -- Arguments
  --   x_completion_code	0 (Success), 1 (Warning), or 2 (Failure)
  --   x_num_rows_inserted	Total number of rows inserted
  --   p_bsv_range_low		Low value for the range of balancing segment
  --				values to be filtered in
  --   p_bsv_range_high		High value for the range of balancing segment
  --				values to be filtered in
  -- Example
  --   FEM_INTG_BAL_ENG_LOAD_PKG.Load_Avg_Balances(completion_code, num_rows,
  --                                               sysdate);
  -- Notes
  --
  PROCEDURE Load_Avg_Balances(	x_completion_code	OUT NOCOPY NUMBER,
				x_num_rows_inserted	OUT NOCOPY NUMBER,
				p_effective_date	DATE,
				p_bsv_range_low		VARCHAR2,
				p_bsv_range_high	VARCHAR2);

  --
  -- Procedure
  --   Load_Post_Process
  -- Purpose
  --   A post-process for loading which will back out functional converted
  --   amounts to get the correct functional entered amounts.
  -- Arguments
  --   x_completion_code	0 (Success), 1 (Warning), or 2 (Failure)
  -- Example
  --   FEM_INTG_BAL_ENG_LOAD_PKG.Load_Post_Process(completion_code);
  -- Notes
  --
  PROCEDURE Load_Post_Process(x_completion_code	OUT NOCOPY NUMBER);

  --
  -- Procedure
  --   Map_Adv_LI_FE
  -- Purpose
  --   Using the natural account, override the amount in the line item and
  --   financial element columns if an override is specified.
  -- Arguments
  --   x_completion_code	0 (Success), 1 (Warning), or 2 (Failure)
  -- Example
  --   FEM_INTG_BAL_ENG_LOAD_PKG.Map_Adv_LI_FE(completion_code);
  -- Notes
  --
  PROCEDURE Map_Adv_LI_FE(x_completion_code	OUT NOCOPY NUMBER);

  --
  -- Procedure
  --   Mark_Posted_Incr_Bal
  -- Purpose
  --   Mark GL and FEM tables with information regarding the incremental runs
  --   that have or have not been uploaded.
  -- Arguments
  --   x_completion_code	0 (Success), 1 (Warning), or 2 (Failure)
  --   p_bsv_range_low		Low value for the range of balancing segment
  --				values to be filtered in
  --   p_bsv_range_high		High value for the range of balancing segment
  --				values to be filtered in
  -- Example
  --   FEM_INTG_BAL_ENG_LOAD_PKG.Mark_Posted_Incr_Bal(completion_code);
  -- Notes
  --
  PROCEDURE Mark_Posted_Incr_Bal(x_completion_code	OUT NOCOPY NUMBER,
				 p_bsv_range_low	VARCHAR2,
				 p_bsv_range_high	VARCHAR2);


END FEM_INTG_BAL_ENG_LOAD_PKG;

 

/
