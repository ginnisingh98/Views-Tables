--------------------------------------------------------
--  DDL for Package QA_SS_LOV_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_LOV_UI" AUTHID CURRENT_USER as
/* $Header: qltsslub.pls 115.5 2002/11/27 19:32:43 jezheng ship $ */


procedure Draw_Lov_Values (
		Code IN qa_ss_const.var150_table,
		Description IN qa_ss_const.var150_table,
		heading1 IN VARCHAR2,
		heading2 IN VARCHAR2 );

end qa_ss_lov_ui;


 

/
