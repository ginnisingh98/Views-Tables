--------------------------------------------------------
--  DDL for Package QP_UPDATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UPDATE_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXQINDS.pls 120.1 2006/08/14 22:32:12 jhkuo noship $ */

  PROCEDURE Update_Qualification_Ind
		  (p_worker            NUMBER,
                   p_line_type         VARCHAR2,
                   p_List_Line_Id_Low  NUMBER default null,
		   p_List_Line_Id_High NUMBER default null,
                   p_last_proc_line    NUMBER := 0);

  PROCEDURE Update_pricing_attributes
		  (p_start_rowid       ROWID default null,
		   p_end_rowid         ROWID default null);

  PROCEDURE create_parallel_slabs
                  (l_workers IN number := 5,
                   p_batchsize in number := 5000);

END QP_Update_Util;

 

/
