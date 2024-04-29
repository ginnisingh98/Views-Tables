--------------------------------------------------------
--  DDL for Package PAY_COSTING_SUMMARY_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COSTING_SUMMARY_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: pyrpcsrp.pkh 120.0.12000000.1 2007/01/18 01:09:35 appldev noship $ */

/************************************************************
   ** Procedure: costing_summary
   **
   ** Purpose  : This procedure is the one that is called from
   **            the concurrent program
  ************************************************************/

  procedure costing_summary (
                             errbuf                out nocopy varchar2
                            ,retcode               out nocopy number
                            ,p_business_group_id    in number
                            ,p_start_date           in varchar2
                            ,p_dummy_start          in varchar2
                            ,p_end_date             in varchar2
                            ,p_costing              in varchar2
                            ,p_dummy_end            in varchar2
                            ,p_payroll_id           in number
                            ,p_consolidation_set_id in number
                            ,p_tax_unit_id          in number
                            ,p_cost_type            in varchar2
                            ,p_sort_order1          in varchar2
                            ,p_sort_order2          in varchar2
                            ,p_output_file_type     in varchar2
                           ) ;


  /**************************************************************
  ** PL/SQL table of records to store Costing Segment Label and
  ** Application Column used.
  ***************************************************************/
  TYPE costing_rec  IS RECORD (segment_label  varchar2(100),
                               column_name    varchar2(100));
  TYPE costing_tab IS TABLE OF costing_rec INDEX BY BINARY_INTEGER;

end pay_costing_summary_rep_pkg;

 

/
