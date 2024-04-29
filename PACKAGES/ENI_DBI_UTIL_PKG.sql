--------------------------------------------------------
--  DDL for Package ENI_DBI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_DBI_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIUTILS.pls 120.0 2005/05/26 19:37:11 appldev noship $*/

  FUNCTION GetXTDLabel( p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
    RETURN VARCHAR2;

  FUNCTION Rolling_Lab(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL)
    RETURN VARCHAR2; -- Returns the Rolling Period Labels

  PROCEDURE get_time_clauses
    (
     p_measure_type IN VARCHAR2,
     p_summary_alias in VARCHAR2,
     p_period_type IN VARCHAR2,
     p_period_bitand IN NUMBER,
     p_as_of_date  IN DATE,
     p_prev_as_of_date IN DATE,
     p_report_start IN DATE,
     p_cur_period IN NUMBER,
     p_days_into_period IN NUMBER,
     p_comp_type IN VARCHAR2,
     p_id_column IN VARCHAR2,
     p_from_clause OUT NOCOPY VARCHAR2,
     p_where_clause OUT NOCOPY VARCHAR2,
     p_group_by_clause OUT NOCOPY VARCHAR2,
     -- Added this default parameter for Rolling periods implementation.
     p_rolling VARCHAR2 DEFAULT 'ENTERPRISE'
    );

  PROCEDURE get_parameters
    (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
     p_period_type        OUT NOCOPY VARCHAR2,
     p_period_bitand      OUT NOCOPY NUMBER,
     p_view_by            OUT NOCOPY VARCHAR2,
     p_as_of_date           OUT NOCOPY DATE,
     p_prev_as_of_date      OUT NOCOPY DATE,
     p_report_start         OUT NOCOPY DATE,
     p_cur_period           OUT NOCOPY NUMBER,
     p_days_into_period     OUT NOCOPY NUMBER,
     p_comp_type            OUT NOCOPY VARCHAR2,
     p_category             OUT NOCOPY VARCHAR2,
     p_item                 OUT NOCOPY VARCHAR2,
     p_org                  OUT NOCOPY VARCHAR2,
     p_id_column            OUT NOCOPY VARCHAR2,
     p_order_by             OUT NOCOPY VARCHAR2,
     p_drill                OUT NOCOPY VARCHAR2,
     p_status   OUT NOCOPY VARCHAR2,
     p_priority   OUT NOCOPY VARCHAR2,
     p_reason   OUT NOCOPY VARCHAR2,
     p_lifecycle_phase  OUT NOCOPY VARCHAR2,
     p_currency   OUT NOCOPY VARCHAR2,
     p_bom_type   OUT NOCOPY VARCHAR2,
     p_type   OUT NOCOPY VARCHAR2,
     p_manager   OUT NOCOPY VARCHAR2,
     p_lob                  OUT NOCOPY VARCHAR2
    );

  -- This procedure provides a level of indirection between
  -- the standard DBI logging procedure and the ENI collection
  -- packages.
  PROCEDURE log(p_message VARCHAR2,
       p_indenting NUMBER DEFAULT 0);

  -- This procedure provides a level of indirection between
  -- the standard DBI logging procedure and the ENI collection
  -- packages.
  PROCEDURE debug(p_message VARCHAR2,
           p_indenting NUMBER DEFAULT 0);

  -- This procedure initializes the debug logging for our
  -- PL/SQL report packages.
  --
  -- Parameters
  -- p_rpt_name: The FND function name of the report
  --             which is to be debugged
  PROCEDURE init_rpt(p_rpt_func_name VARCHAR2);

  -- This procedure writes a debug message to the
  -- file previously opened by the init procedure
  --
  -- Parameters
  -- p_message: The string which is to be written into
  --            the log
  PROCEDURE debug_rpt(p_message VARCHAR2);

  --   This wrapper function supplies the mandatory time dimension parameters
  --   in addition to those returned by the bil_bi_util_pkg.get_dbi_params.
  --   Form function for the page has been modified to call
  --   this function instead of bil_bi_util_pkg.get_dbi_params
  --   Created to fix bug - bug# 3771850
  FUNCTION get_all_dbi_params(p_region_code varchar2) return varchar2;

  -- Returns the primary currency identifier
  FUNCTION get_curr_prim RETURN VARCHAR2;

  -- Returns the secondary currency identifier
  FUNCTION get_curr_sec RETURN VARCHAR2;

END;

 

/
