--------------------------------------------------------
--  DDL for Package FA_ASSET_TRACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_TRACE_PUB" AUTHID CURRENT_USER AS
/*   $Header: faxtrcps.pls 120.1.12010000.4 2010/04/26 15:22:49 hhafid noship $ */

  Type t_col_exclusions_rec IS RECORD (cType VARCHAR2(1), cValue VARCHAR2(100));
  Type t_excl_tbl IS TABLE OF t_col_exclusions_rec INDEX BY BINARY_INTEGER;

  TYPE t_tbl_rec IS RECORD (l_tbl          varchar2(100),  --table_name
                            l_schema       varchar2(50),   --schema if <> calling app schema
                            l_lcs          varchar2(500),  --leading column(s)
                            l_leading_cols varchar2(500),  --html-formatted l_lcs
                            l_order_by     varchar2(500),  --order by column(s)
                            l_lc_header    varchar2(1000), --html-formatted heading of l_lcs
                            l_num_cols     number,         --# of leading columns
                            l_col_order    varchar2(2000), --prefered col order
                            l_fullcol_list varchar2(1),    --'Y' if l_col_order is the entire select list
                            l_gen_select   varchar2(1),    --Generate select column list
                            l_no_header    varchar2(1),    --no row header generated when 'Y'
                            l_no_anchor    varchar2(1),    --no anchor generated when set to 'Y''
                            l_add_clause   varchar2(32767), --additional where-clause.  could also include from-clause
                            l_cnt_stmt     varchar2(32767)  --count stmt to check tbl count
                           );
  TYPE t_options_tbl IS TABLE of t_tbl_rec INDEX BY BINARY_INTEGER;

  TYPE t_vchar_tbl IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

  TYPE t_num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  g_req_tbl           t_num_tbl;

  g_submit_subreq  VARCHAR2(1) DEFAULT 'N';
  g_submit_counter number DEFAULT 0;

  PROCEDURE run_trace (p_opt_tbl        IN     t_options_tbl,
                       p_exc_tbl        IN     t_excl_tbl,
                       p_tdyn_head      IN     VARCHAR2,
                       p_stmt           IN     VARCHAR2,
                       p_sys_opt_tbl    IN     VARCHAR2 DEFAULT NULL,
                       p_use_utl_file   IN     VARCHAR2 DEFAULT 'N',
                       p_debug_flag     IN     BOOLEAN,
                       p_calling_prog   IN     VARCHAR2,
                       p_retcode        OUT NOCOPY NUMBER,
                       p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE wait_for_req;

  PROCEDURE set_temp_head (p_temp_head      IN  VARCHAR2,
                           p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE do_top_section (p_tdyn_head      IN  VARCHAR2,
                            p_stmt           IN  VARCHAR2,
                            p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  FUNCTION start_queue (p_qtable         IN  varchar2,
                        p_qpayload_type  IN  varchar2,
                        p_qname          IN  varchar2) RETURN VARCHAR2;

  FUNCTION add_subscriber (p_qname       IN  varchar2,
                           p_subscriber  IN  varchar2,
                           p_sub_rule    IN  varchar2) RETURN BOOLEAN;

  PROCEDURE log(p_calling_fn     IN  VARCHAR2,
                p_msg            IN  VARCHAR2 default null,
                p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

END FA_ASSET_TRACE_PUB;

/
