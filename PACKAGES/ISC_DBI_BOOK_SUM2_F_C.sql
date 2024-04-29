--------------------------------------------------------
--  DDL for Package ISC_DBI_BOOK_SUM2_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_BOOK_SUM2_F_C" AUTHID CURRENT_USER AS
/* $Header: ISCSCF7S.pls 115.6 2004/05/04 23:32:23 mbourget ship $ */

--------------------------
--  PROCEDURE REFRESH_FACT
--------------------------

 PROCEDURE LOAD_FACT(errbuf      		IN OUT NOCOPY VARCHAR2,
                     retcode     		IN OUT NOCOPY VARCHAR2);

 PROCEDURE UPDATE_FACT(errbuf      		IN OUT NOCOPY VARCHAR2,
                       retcode     		IN OUT NOCOPY VARCHAR2);

 PROCEDURE LOAD_SALES_FACT(errbuf      		IN OUT NOCOPY VARCHAR2,
                           retcode     		IN OUT NOCOPY VARCHAR2);

 PROCEDURE UPDATE_SALES_FACT_DUMMY(errbuf      	IN OUT NOCOPY VARCHAR2,
                           retcode     		IN OUT NOCOPY VARCHAR2);


-------------------------------------
--  FUNCTION GET_CUST_PRODUCT_LINE_ID
-------------------------------------

  FUNCTION GET_CUST_PRODUCT_LINE_ID(p_sold_to_org_id   			IN NUMBER,
        			    p_service_reference_line_id 	IN NUMBER) RETURN NUMBER;


END ISC_DBI_BOOK_SUM2_F_C;

 

/
