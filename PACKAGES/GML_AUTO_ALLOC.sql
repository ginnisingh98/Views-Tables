--------------------------------------------------------
--  DDL for Package GML_AUTO_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_AUTO_ALLOC" AUTHID CURRENT_USER AS
/*$Header: GMLALLCS.pls 115.2 2002/11/08 15:43:37 gmangari noship $*/

  P_session_id		NUMBER;
  P_default_loct	VARCHAR2(40);

  FUNCTION Get_Available_Lots (V_session_id NUMBER, V_alloc_mode VARCHAR2, V_line_id NUMBER, V_item_id NUMBER, V_shipcust_id NUMBER,
                           V_whse_code VARCHAR2, V_qty NUMBER, V_order_um1 VARCHAR2, V_qty2 NUMBER,
                           V_grade_wanted VARCHAR2, V_sched_shipdate DATE) RETURN NUMBER;

  PROCEDURE Get_Alloc_Parameters(V_shipcust_id NUMBER, V_alloc_class VARCHAR2, V_alloc_method IN OUT NOCOPY NUMBER,
  				    V_shelf_days IN OUT NOCOPY NUMBER, V_alloc_horizon IN OUT NOCOPY NUMBER,
  				    V_alloc_type IN OUT NOCOPY NUMBER, V_lot_qty IN OUT NOCOPY NUMBER,
  				    V_partial_ind IN OUT NOCOPY NUMBER, V_prefqc_grade IN OUT NOCOPY VARCHAR2);

  FUNCTION fetch_lots (V_item_id NUMBER, V_whse_code VARCHAR2, V_qc_grade VARCHAR2,
                       V_trans_date DATE, V_alloc_method NUMBER, V_qty NUMBER, V_qty2 NUMBER,
                       V_lot_ctl NUMBER, V_loct_ctl NUMBER, V_lot_indivisible NUMBER, V_lot_alloc NUMBER,
                       V_order_um1 VARCHAR2, V_item_um VARCHAR2, V_item_um2 VARCHAR2, V_dualum_ind NUMBER) RETURN NUMBER;

  PROCEDURE insert_temp_rows (V_item_id NUMBER, V_whse_code VARCHAR2, V_qc_grade VARCHAR2,
                              V_trans_date DATE);
  PROCEDURE clear_table;

END GML_AUTO_ALLOC;

 

/
