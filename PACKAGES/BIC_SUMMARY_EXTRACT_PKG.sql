--------------------------------------------------------
--  DDL for Package BIC_SUMMARY_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIC_SUMMARY_EXTRACT_PKG" AUTHID CURRENT_USER as
/* $Header: bicsumms.pls 115.13 2004/05/14 08:15:24 vsegu ship $ */

  -- Procedure Name: extract_main
  --    Parameters:
  --       P_start_date   : Start date of the start period for for extraction
  --       p_end_date     : Start date of the end period for extraction e.g. if
  --                        the extraction is from jan 99 to july 99,
  --                        p_start_date=1-jan-1999 and p_end_date 1-july-1999
  --                        extracted
  --       p_delete_flag  : default value - 'N'
  --                        if 'Y', first delete existing records for the date
  --                        range, measure and org
  --       p_measure_code : default null
  --                        if specified, extract data only for that measure.
  --                        Valid measure codes are 'SATISFACTION', 'LOYALTY',
  --                        'RETENTION', 'LIFECYCLE', 'ACTIVATION' and
  --                        'ACQUISITION'.
  --       p_org_id       : default null
  --                        if specified, extract data only for that org

 g_proc_name            varchar2(50);
  procedure extract_main (  errbuf    out NOCOPY varchar2,
					        retcode   out NOCOPY number,
					        p_start_date    varchar2 default null,
                            p_end_date      varchar2 default null,
                            p_delete_flag   varchar2 default null,
                            p_measure_code  varchar2 default null,
                            p_org_id        number   default null);
  --
  -- This variable g_log_output can be set to not null value to print messages
  -- using dbms_output instead of fnd_file.put_line. This is used only for
  -- testing and developement by developer. Developer can set this variable
  -- in SQL script before calling extract_main procedure. In this w_log
  -- procedure will use DBMS_OUTPUT to print message instead of
  -- fnd_file.put_line
  g_log_output           varchar2( 1) := null;
  g_measure_code         bic_measures_all.measure_code % type;
  g_period_start_date        date;
  g_to_currency_code varchar2(30) ;
  g_conversion_type  varchar2(30) ;

  -- This procedure gets records from gl_period and inserts them in bic_period
  procedure extract_calendar(   errbuf    out NOCOPY varchar2,
			                    retcode   out NOCOPY number);
  procedure extract_sales(      p_period_start_date date,
                                p_period_end_date date,
                                p_org_id number,
                                p_lf_flag varchar2 default null);
  procedure write_log(          p_msg varchar2);
  procedure get_sql_sttmnt(     p_measure_code          varchar2,
					            p_sttmnt         in out nocopy varchar2,
					            p_operation_type in out nocopy varchar2,
					            p_mult_factor    in out nocopy number);
  procedure run_sql(            p_sttmnt       varchar2);
  procedure	extract_periods(	p_start_date	date,
			                	p_end_date	date,
				                p_measure_code	varchar2,
				                p_org_flag	varchar2,
				                p_delete_flag	varchar2,
				                p_org_id	number );
  procedure extract_all_periods(p_start_date	date,
				                p_end_date	date ) ;
  procedure generate_error(     p_measure_code varchar2 default null,
                                msg varchar2);
  function convert_amt(         p_from_currency_code varchar2,
				                p_date               date,
				                p_amt                number) return number ;
  procedure debug( debug_str VARCHAR2);
end bic_summary_extract_pkg;




 

/
