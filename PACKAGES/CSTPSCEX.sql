--------------------------------------------------------
--  DDL for Package CSTPSCEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSCEX" AUTHID CURRENT_USER as
/* $Header: CSTSCEXS.pls 115.10 2003/08/11 20:17:29 rzhu ship $ */


-- This procedure expects that top level assemblies to be inserted
-- into CST_SC_LISTS with the appropriate rollup_id first.  This
-- is the same rollup_id that is expected by the procedure call.

procedure supply_chain_rollup (
  i_rollup_id          in  number,   -- rollup ID, CST_LISTS_S
  i_explosion_levels   in  number,   -- levels to explode, NULL for all levels
  i_report_levels      in  number,   -- levels in report, NULL for no report
  i_assignment_set_id  in  number,   -- MRP assignment_set_id, NULL for none
  i_conversion_type    in  varchar2, -- GL_DAILY_CONVERSION_TYPES
  i_cost_type_id       in  number,   -- rollup cost type
  i_buy_cost_type_id   in  number,   -- buy cost cost type
  i_effective_date     in  date,     -- BIC.effectivity_date
  i_exclude_unimpl_eco in  number,   -- 1 = exclude unimplemented, 2 = include
  i_exclude_eng        in  number,   -- 1 = exclude eng items, 2 = include
  i_alt_bom_desg       in  varchar2, -- alternate BOM designator
  i_alt_rtg_desg       in  varchar2, -- alternate routing designator
  i_lock_flag          in  number,   -- 1 = wait for locks, 2 = no
  i_user_id            in  number,
  i_login_id           in  number,
  i_request_id         in  number,
  i_prog_id            in  number,
  i_prog_appl_id       in  number,
  o_error_code         out NOCOPY number,
  o_error_msg          out NOCOPY varchar2,
  i_lot_size_option    in  number := null,  -- SCAPI: dynamic lot size
  i_lot_size_setting   in  number := null,
  i_report_option_type in  number := null,
  i_report_type_type   in  number := null,
  i_buy_cost_detail    in  number := null
);



procedure snapshot_sc_bom_structures (
  i_rollup_id         in  number,
  i_cost_type_id      in  number,
  i_report_levels     in  number,
  i_effective_date    in  date,
  i_user_id           in  number,
  i_login_id          in  number,
  i_request_id        in  number,
  i_prog_id           in  number,
  i_prog_appl_id      in  number,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2,
  i_report_type_type  in  number := null   -- SCAPI: support consolidated report
);



end CSTPSCEX;

 

/
