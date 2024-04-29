--------------------------------------------------------
--  DDL for Package FV_RECEIVABLES_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_RECEIVABLES_ACTIVITY_PKG" AUTHID CURRENT_USER AS
/* $Header: FVXDCDFS.pls 120.1 2006/01/19 14:52:54 sbobba noship $  */
PROCEDURE Main(
        errbuf          OUT NOCOPY     VARCHAR2,
        retcode         OUT NOCOPY     NUMBER,
        p_set_of_books_id  NUMBER,
        p_reporting_entity_code VARCHAR2,
        p_fiscal_year NUMBER,
        p_quarter NUMBER,
        p_reported_by VARCHAR2,
        p_type_of_receivable VARCHAR2,
        p_write_off_activity_1 VARCHAR2,
        p_write_off_activity_2 VARCHAR2,
        p_write_off_activity_3 VARCHAR2,
		p_nonfed_customer_class VARCHAR2,
        p_footnotes VARCHAR2,
        p_preparer_name VARCHAR2,
        p_preparer_phone VARCHAR2,
        p_preparer_fax_number VARCHAR2,
        p_preparer_email VARCHAR2,
        p_supervisor_name VARCHAR2,
        p_supervisor_phone VARCHAR2,
        p_supervisor_email VARCHAR2,
        p_address_line_1 VARCHAR2,
        p_address_line_2 VARCHAR2,
        p_address_line_3 VARCHAR2,
        p_city VARCHAR2,
        p_state VARCHAR2,
        p_postal_code VARCHAR2) ;
PROCEDURE Populate_IB_IIAB ;
PROCEDURE Populate_IA_IIC;
PROCEDURE insert_row (
		p_line_num VARCHAR2,
		p_descpription VARCHAR2,
		p_count NUMBER,
		p_amount NUMBER);
PROCEDURE Submit_Report (
     	p_set_of_books_id NUMBER,
	p_reporting_entity_code VARCHAR2,
	    p_fiscal_year NUMBER,
		p_quarter NUMBER,
		p_reported_by VARCHAR2,
		p_type_of_receivable VARCHAR2,
	    p_footnotes VARCHAR2,
		p_preparer_name VARCHAR2,
		p_preparer_phone VARCHAR2,
		p_preparer_fax_number VARCHAR2,
		p_preparer_email VARCHAR2,
		p_supervisor_name VARCHAR2,
		p_supervisor_phone VARCHAR2,
		p_supervisor_email VARCHAR2,
	    p_address_line_1 VARCHAR2,
	    p_address_line_2 VARCHAR2,
	    p_address_line_3 VARCHAR2,
	    p_city VARCHAR2,
	    p_state VARCHAR2,
	    p_postal_code VARCHAR2  );
----------------------------------------------------------------------
--                              END OF PACKAGE SPEC
----------------------------------------------------------------------
END fv_receivables_activity_pkg;

 

/
