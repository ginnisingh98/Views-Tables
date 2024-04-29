--------------------------------------------------------
--  DDL for Package FII_AR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_UTIL" AUTHID CURRENT_USER AS
/* $Header: FIIARPMV1S.pls 120.1 2005/06/07 11:57:26 sgautam noship $ */


p_as_of_date  DATE;
p_period_type VARCHAR2(100);
p_view_by     VARCHAR2(100);
p_sgid	      VARCHAR2(100);
p_prod_cat    VARCHAR2(100);
p_cust	      VARCHAR2(100);
p_curr	      VARCHAR2(100);
p_record_type_id NUMBER;


PROCEDURE reset_globals;

PROCEDURE get_parameters(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL


                        );
FUNCTION get_label(sequence IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE Bind_Variable
	(	p_sqlstmt IN VARCHAR2,
		p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
		p_sql_output OUT NOCOPY VARCHAR2,
		p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
                p_record_type_id IN NUMBER DEFAULT NULL,
                p_view_by IN VARCHAR2 DEFAULT NULL,
                p_fiibind1 IN VARCHAR2 DEFAULT NULL,
                p_fiibind2 IN VARCHAR2 DEFAULT NULL

              );

END FII_AR_Util;

 

/
