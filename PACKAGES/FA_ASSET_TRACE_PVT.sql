--------------------------------------------------------
--  DDL for Package FA_ASSET_TRACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_TRACE_PVT" AUTHID CURRENT_USER AS
  /* $Header: faxtrcvs.pls 120.0.12010000.4 2009/07/19 08:25:07 glchen noship $ */

  --Type declarations

  TYPE t_asset_tbl IS TABLE OF VARCHAR2(32767)
     INDEX BY BINARY_INTEGER;

  TYPE c_stmt IS REF CURSOR;

  Type t_cc_cols_rec IS RECORD (cTbl VARCHAR2(100), cCol VARCHAR2(100));
  Type t_cc_cols IS TABLE OF t_cc_cols_rec INDEX BY BINARY_INTEGER;

  TYPE t_num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  --req_id => request id
  --param_column => table column corresponding to the cp param
  --nValue => parameter value if param is number
  --cValue => parameter value if param is char.
  Type t_param_rec IS RECORD (param_column VARCHAR2(50), nValue NUMBER, cValue VARCHAR2(100));
  Type t_param_tbl IS TABLE OF t_param_rec INDEX BY BINARY_INTEGER;

  --Globals
  g_param_tbl        t_param_tbl; --holds primary/secondary columns driving the trace
  g_dyn_head         VARCHAR2(32767);
  g_no_header        VARCHAR2(1) DEFAULT 'N';
  g_sel_tbl          t_asset_tbl;
  g_hdr_tbl          t_asset_tbl;
  g_mrc_enabled      VARCHAR2(1);
  g_jx_enabled       VARCHAR2(1);
  g_temp_head        VARCHAR2(2000); --holds banner area content

  g_use_utl_file      VARCHAR2(1) := 'N';
  g_outfile           UTL_FILE.FILE_TYPE;
  g_logfile           UTL_FILE.FILE_TYPE;

  PROCEDURE initialize_globals (p_opt_tbl        IN         FA_ASSET_TRACE_PUB.t_options_tbl,
                                p_exc_tbl        IN         FA_ASSET_TRACE_PUB.t_excl_tbl,
                                p_schema         OUT NOCOPY VARCHAR2,
                                p_debug_flag     IN         BOOLEAN,
                                p_log_level_rec  IN         FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE do_primary;

  PROCEDURE do_col_exclusions (p_tbl            IN         VARCHAR2,
                               p_schema         IN         VARCHAR2,
                               x_stmt           OUT NOCOPY VARCHAR2,
                               p_log_level_rec  IN         FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE exec_sql (p_table          IN  VARCHAR2,
                      p_sel_clause     IN  VARCHAR2,
                      p_stmt           IN  VARCHAR2,
                      p_schema         IN  VARCHAR2 DEFAULT 'FA',
                      p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE get_final_sql (p_table          IN OUT NOCOPY VARCHAR2,
			                     p_sel_clause     IN            VARCHAR2,
                           x_header         OUT NOCOPY    VARCHAR2,
                           px_sql           IN OUT NOCOPY VARCHAR2,
			                     p_schema         IN            VARCHAR2,
                           p_log_level_rec  IN            FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE get_options (p_table          IN     VARCHAR2,
                         p_opt_tbl        IN OUT NOCOPY FA_ASSET_TRACE_PUB.t_options_tbl,
                         p_sv_col         IN OUT NOCOPY NUMBER,
                         p_mode           IN     VARCHAR2 default null,
                         p_log_level_rec  IN     FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE get_system_options (p_sys_opt_tbl    IN  VARCHAR2,
                                p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  FUNCTION get_param (p_numcol         IN  number,
                      p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) return VARCHAR2;

  FUNCTION get_tbl_cnt (p_table          IN  VARCHAR2,
                        p_stmt           IN  VARCHAR2,
			p_schema         IN  VARCHAR2,
                        p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;

  FUNCTION check_column (p_table          IN  VARCHAR2,
                         p_schema         IN  VARCHAR2 DEFAULT 'FA',
			                   p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN NUMBER;

  FUNCTION fafsc (p_col	           IN  VARCHAR2,
                  p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN VARCHAR2;

  FUNCTION fparse_header(p_in_str         IN  VARCHAR2,
                         p_add_html       IN  VARCHAR2 DEFAULT 'Y',
                         p_break_size     IN  NUMBER DEFAULT 14,
                         p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) RETURN VARCHAR2;

  PROCEDURE build_stmt(p_t_tbl          IN  FA_ASSET_TRACE_PKG.t_col_tbl,
                       p_col_tbl        IN  FA_ASSET_TRACE_PKG.t_col_tbl,
                       p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE col_order (x_table          IN            VARCHAR2,
                       x_col_tbl        IN OUT NOCOPY FA_ASSET_TRACE_PKG.t_col_tbl,
                       x_t_tbl          IN OUT NOCOPY FA_ASSET_TRACE_PKG.t_col_tbl,
                       p_log_level_rec  IN            FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE build_anchors (p_t_tbl          IN  FA_ASSET_TRACE_PKG.t_col_tbl,
                           p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE save_output (p_calling_prog   IN  VARCHAR2,  --i.e. FATRACE
                         p_use_utl_file   IN  VARCHAR2,
                         p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE log(p_calling_fn     IN  VARCHAR2,
                p_msg            IN  VARCHAR2 default null,
                p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE ocfile (p_handle IN OUT NOCOPY utl_file.file_type,
                    p_file   IN            VARCHAR2,
                    p_mode   IN            VARCHAR2); --C(lose) or O(pen)

END FA_ASSET_TRACE_PVT;

/
