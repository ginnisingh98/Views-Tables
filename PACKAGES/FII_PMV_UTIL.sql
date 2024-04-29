--------------------------------------------------------
--  DDL for Package FII_PMV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PMV_UTIL" AUTHID CURRENT_USER AS
/* $Header: FIIPMVUS.pls 120.2 2005/07/01 06:20:57 sajgeo ship $ */
FUNCTION get_msg (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2;
FUNCTION get_msg1 (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2;
FUNCTION get_curr RETURN VARCHAR2;
FUNCTION get_manager RETURN NUMBER;
FUNCTION get_dbi_params(region_id IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_sec_profile RETURN NUMBER;
FUNCTION get_prim_global_currency_code RETURN VARCHAR2;
FUNCTION get_sec_global_currency_code RETURN VARCHAR2;
FUNCTION get_display_currency(p_selected_operating_unit IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE get_parameters (p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_as_of_date  OUT NOCOPY Date,
                            p_operating_unit  OUT NOCOPY Varchar2,
                            p_supplier  OUT NOCOPY Varchar2,
                            p_invoice_number  OUT NOCOPY Number,
                            p_period_type OUT NOCOPY Varchar2,
                            p_record_type_id OUT NOCOPY NUMBER,
                            p_view_by OUT NOCOPY Varchar2,
                            p_currency OUT NOCOPY Varchar2,
                            p_column_name OUT NOCOPY VARCHAR2,
                            p_table_name OUT NOCOPY VARCHAR2,
                            p_gid OUT NOCOPY NUMBER,
                            p_org_where OUT NOCOPY Varchar2,
                            p_supplier_where OUT NOCOPY Varchar2
                        );
PROCEDURE Bind_Variable
             ( p_sqlstmt IN Varchar2, p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
             p_sql_output OUT NOCOPY Varchar2, p_bind_output_table OUT BIS_QUERY_ATTRIBUTES_TBL,
              p_invoice_number IN Varchar2 Default null,
               p_record_type_id IN Number Default Null,
               p_view_by IN Varchar2 Default Null, p_gid IN Number Default Null,
                 p_period_start   IN Date     Default null,
               p_check_id IN Number Default null,
               p_created        IN Varchar2 Default null,
               p_stopped        IN Varchar2 Default null,
               p_stop_released  IN Varchar2 Default null,
               p_cleared        IN Varchar2 Default null,
               p_reconciled     IN Varchar2 Default null,
               p_unreconciled   IN Varchar2 Default null,
               p_uncleared      IN Varchar2 Default null,
               p_voided         IN Varchar2 Default null,
               p_entry          IN Varchar2 Default null,
               p_hold_placed    IN Varchar2 Default null,
               p_hold_released  IN Varchar2 Default null,
               p_prepay_applied IN Varchar2 Default null,
               p_prepay_unapplied IN Varchar2 Default null,
               p_payment        IN Varchar2 Default null,
               p_paymt_void     IN Varchar2 Default null,
               p_paymt_stop     IN Varchar2 Default null,
               p_paymt_release  IN Varchar2 Default null,
	       p_line_number   IN Number   Default null,
               p_fiibind1       IN Varchar2 Default null,
               p_fiibind2       IN Varchar2 Default null,
               p_fiibind3       IN Varchar2 Default null,
               p_fiibind4       IN Varchar2 Default null,
               p_fiibind5       IN Varchar2 Default null,
               p_fiibind6       IN Varchar2 Default null
              );
PROCEDURE get_invoice_id(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_invoice_id OUT NOCOPY Number) ;
PROCEDURE get_period_start(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                           p_period_start OUT NOCOPY Date,
                           p_days_into_period OUT NOCOPY Number,
                           p_cur_period OUT NOCOPY Number,
                           p_id_column OUT NOCOPY Varchar2);
PROCEDURE get_period_strt(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_period_start OUT NOCOPY Date,
                           p_days_into_period OUT NOCOPY Number,
                           p_cur_period OUT NOCOPY Number,
                           p_id_column OUT NOCOPY Varchar2);
PROCEDURE get_report_source(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                           p_report_source OUT NOCOPY Varchar2);
PROCEDURE get_check_id(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_check_id OUT NOCOPY Number) ;
FUNCTION get_base_curr_colname(p_currency IN Varchar2, p_column_name IN Varchar2) return Varchar2;
FUNCTION get_period_type_suffix (p_period_type IN Varchar2) return Varchar2;
PROCEDURE get_yes_no_msg(p_yes OUT NOCOPY Varchar2, p_no OUT NOCOPY Varchar2);
PROCEDURE get_format_mask(p_date_format_mask OUT NOCOPY Varchar2);
FUNCTION determine_OU_LOV RETURN NUMBER;
FUNCTION get_business_group RETURN NUMBER;


END FII_PMV_Util;

 

/
