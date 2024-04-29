--------------------------------------------------------
--  DDL for Package IGI_CIS2007_IGIPMTHR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_IGIPMTHR_PKG" AUTHID CURRENT_USER AS
-- $Header: igipmthrs.pls 120.2.12010000.6 2011/10/20 07:44:25 dramired ship $
   PROCEDURE Populate_Vendors(p_in_vendor_from IN VARCHAR2,
                                p_in_vendor_to IN VARCHAR2,
                                p_in_period    in varchar2,
                                p_in_start_date in varchar2,
                                p_in_end_date  in varchar2,
                                p_out_no_of_rows OUT NOCOPY integer);
   PROCEDURE GET_PAYMENT_CIS_DETAILS( p_inv_pay_id in number,
                                p_inv_id in number,
				p_tax_mth_start_date in date,
				p_tax_mth_end_date in date,
                                p_pay_amount in out nocopy number,
				p_discount_amount in number,
     				p_labour_cost out nocopy number,
				p_material_cost out nocopy number,
				p_awt_amount out nocopy number,
                                p_cis_tax out nocopy number);
   PROCEDURE POPULATE_MTH_RET_DETAILS(errbuf OUT NOCOPY VARCHAR2,
				retcode OUT NOCOPY NUMBER,
				p_nil_return_flag IN varchar2,
                                p_info_crct_flag IN varchar2,
                                p_subcont_verify_flag IN varchar2,
                                p_emp_status_flag IN varchar2,
                                p_inact_indicat_flag IN varchar2,
                                p_period_name IN varchar2,
                                p_mth_ret_mode IN varchar2,
				p_mth_ret_amt_type IN varchar2,
				p_mth_report_template IN varchar2,
                                p_mth_report_format IN varchar2,
                                p_mth_sort_by IN varchar2);
   PROCEDURE MOVE_TO_HISTORY(p_header_id IN number,
                            p_request_status_code IN varchar2);
   PROCEDURE RUN_MTH_RET_REPORT(p_period_name IN varchar2,
                                p_orig_dub IN varchar2,
                                p_sort_by IN varchar2,
                                p_ret_mode IN varchar2,
                                p_del_preview IN varchar2,
                                p_report_lev IN varchar2, --bug 5620621
                                p_request_id OUT NOCOPY integer);
   /*PROCEDURE POST_REPORT_DELETE(p_request_id in number,
                                p_header_id in number);*/
END IGI_CIS2007_IGIPMTHR_PKG;

/
