--------------------------------------------------------
--  DDL for Package MST_COPY_PLAN_OPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_COPY_PLAN_OPTIONS" AUTHID CURRENT_USER AS
/* $Header: MSTCPPOS.pls 115.2 2004/01/09 00:43:06 jnhuang noship $  */
PROCEDURE copy_plan_options (
                     p_source_plan_id     IN number,
                     p_dest_plan_name     IN varchar2,
                     p_dest_plan_desc     IN varchar2,
                     p_plan_dates_source  IN number,
                     p_dest_start_date    IN date DEFAULT NULL,
                     p_dest_end_date      IN date DEFAULT NULL);
PROCEDURE copy_default_plan_options(p_plan_id NUMBER, p_created_by NUMBER);

END mst_copy_plan_options;

 

/
