--------------------------------------------------------
--  DDL for Package BEN_TCS_STMT_VALID_HRCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TCS_STMT_VALID_HRCHY" 
/* $Header: bentcshg.pkh 120.1 2006/04/12 04:44 srangasa noship $ */
AUTHID CURRENT_USER AS
TYPE item_hrchy IS
   RECORD(   item_id NUMBER,
             stmt_id NUMBER ,
             subcat_id NUMBER,
             cntr_cd  VARCHAR2(2));

   TYPE item_hrchy_table IS TABLE OF item_hrchy
   INDEX BY BINARY_INTEGER;

TYPE cat_item_hrchy_rec IS
   RECORD(   cat_id NUMBER ,
             item_id NUMBER,
             stmt_id NUMBER ,
             lvl_num NUMBER,
             cntr_cd VARCHAR2(10),
             perd_id NUMBER,
             row_cat_id NUMBER,
             all_objects_id NUMBER);

TYPE cat_item_hrchy_table IS TABLE OF cat_item_hrchy_rec
   INDEX BY BINARY_INTEGER;

TYPE cat_subcat_hrchy_rec IS
   RECORD(   cat_id NUMBER ,
             subcat_id NUMBER,
             stmt_id NUMBER ,
             lvl_num NUMBER,
             perd_id NUMBER,
             row_cat_id NUMBER);

TYPE cat_subcat_hrchy_table IS TABLE OF cat_subcat_hrchy_rec
   INDEX BY BINARY_INTEGER;


   PROCEDURE stmt_gen_valid_process (p_stmt_id IN NUMBER, p_bg_id IN NUMBER , p_period_id IN NUMBER  ,
   p_item_hrchy_values IN OUT NOCOPY cat_item_hrchy_table ,p_subcat_hrchy_values IN OUT NOCOPY cat_subcat_hrchy_table ,
   p_status OUT NOCOPY Boolean );

END BEN_TCS_STMT_VALID_HRCHY;


 

/
