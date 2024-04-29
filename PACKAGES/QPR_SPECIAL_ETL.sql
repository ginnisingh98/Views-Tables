--------------------------------------------------------
--  DDL for Package QPR_SPECIAL_ETL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_SPECIAL_ETL" AUTHID CURRENT_USER AS
/* $Header: QPRUSPLS.pls 120.2 2007/12/13 05:37:23 bhuchand noship $ */
   TYPE num_type      IS TABLE OF Number         INDEX BY BINARY_INTEGER;
   TYPE char240_type  IS TABLE OF Varchar2(240)  INDEX BY BINARY_INTEGER;
   TYPE char1000_type  IS TABLE OF Varchar2(1000)  INDEX BY BINARY_INTEGER;
   TYPE real_type     IS TABLE OF Number(32,10)  INDEX BY BINARY_INTEGER;
   TYPE date_type     IS TABLE OF Date           INDEX BY BINARY_INTEGER;

   TYPE QPRREFCUR IS REF CURSOR;

TYPE OFFADJ_REC_TYPE IS RECORD
(
LEVEL1_VALUE                         char240_type,
LEVEL2_VALUE                         char240_type,
LEVEL3_VALUE                         char240_type,
LEVEL4_VALUE                         char240_type,
LEVEL5_VALUE                         char240_type,
LEVEL6_VALUE                         char240_type,
LEVEL7_VALUE                         char240_type,
LEVEL8_VALUE                         char240_type,
LEVEL9_VALUE                         char240_type,
LEVEL10_VALUE                         char240_type,
DATE_VALUE                            date_type,
MEASURE1_VALUE				num_type,
MEASURE2_VALUE				num_type,
MEASURE3_VALUE				num_type,
MEASURE4_VALUE				num_type,
MEASURE5_VALUE				num_type,
MEASURE6_VALUE				num_type,
MEASURE7_VALUE				num_type,
MEASURE8_VALUE				num_type,
MEASURE9_VALUE				num_type,
MEASURE10_VALUE				num_type
);

TYPE COST_REC_TYPE IS RECORD
(
ORD_LEVEL_VALUE                 char240_type,
BOOKED_DATE                     date_type,
COS_LEVEL_VALUE                 char240_type,
COST_VALUE	    	        num_type,
UNIT_LIST_PRICE                   num_type,
TOP_MODEL_LINE_ID               num_type,
LINK_TO_LINE_ID                 num_type,
ITEM_TYPE_CODE                  char240_type,
INVENTORY_ITEM_ID               num_type,
COMPONENT_CODE                  char1000_type,
ATO_LINE_ID                     num_type,
ORD_QUANTITY                    num_type,
MEASURE_VAL_ID			num_type
);
/* Public Procedures */
procedure collect_offadj(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_TRX_TYP_NAME        VARCHAR2,
--			P_TRX_TYPE 	    VARCHAR2,
			P_h_reason_code 	    VARCHAR2,
			P_l_reason_code 	    VARCHAR2,
			p_from_trx_date	 VARCHAR2,
			p_to_trx_date VARCHAR2,
			p_from_date VARCHAR2,
			p_to_date VARCHAR2,
			p_instance_id number );

--Transaction Type (Class)
--Reason Code
--Transaction Date from and to
--Order (booking) date from and to


procedure collect_cost(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_from_date	    varchar2,
			p_to_date	    varchar2,
			p_instance_id number );

procedure allocate_offinvoice_adj(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_from_date	    date,
			p_to_date	    date,
			p_instance_id number );

procedure consolidate_upd_sales_meas(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id in number,
			p_from_date in varchar2,
			p_to_date in varchar2);

procedure update_pr_segment(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id in number,
			p_from_date in varchar2,
			p_to_date in varchar2);
END QPR_SPECIAL_ETL;

/
