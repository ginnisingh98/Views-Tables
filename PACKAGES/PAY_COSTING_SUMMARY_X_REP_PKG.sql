--------------------------------------------------------
--  DDL for Package PAY_COSTING_SUMMARY_X_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COSTING_SUMMARY_X_REP_PKG" AUTHID CURRENT_USER AS
/* $Header: pyprxcsr.pkh 120.0 2005/05/29 07:53:43 appldev noship $ */

/***************************************************************
   ** Procedure: costing_summary			      **
   **                                                         **
   ** Purpose  : This procedure is the one that is called from**
   **            the concurrent program.It's going to populate**
   **            the report output in XML format into the     **
   **            global variable and then to the out variable.**
  *************************************************************/

  PROCEDURE  costing_summary (p_xml                   OUT NOCOPY CLOB
                            ,p_business_group_id    IN NUMBER
                            ,p_start_date           IN VARCHAR2
                            ,p_dummy_start          IN VARCHAR2
                            ,p_end_date             IN VARCHAR2
                            ,p_costing              IN VARCHAR2
			    ,p_dummy_costing        IN VARCHAR2
                            ,p_payroll_id           IN NUMBER
                            ,p_consolidation_set_id IN NUMBER
                            ,p_tax_unit_id          IN NUMBER
                            ,p_cost_type            IN VARCHAR2
                            ,p_sort_order1          IN VARCHAR2
                            ,p_sort_order2          IN VARCHAR2
			    ,p_template_name        IN VARCHAR2
			    );

 /**************************************************************
  ** PL/SQL table of records to store Costing Segment Label and
  ** Application Column used.
  ***************************************************************/
  TYPE costing_rec  IS RECORD (segment_label  VARCHAR2(100),
                               column_name    VARCHAR2(100));
  TYPE costing_tab IS TABLE OF costing_rec INDEX BY BINARY_INTEGER;

END pay_costing_summary_x_rep_pkg;

 

/
