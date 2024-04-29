--------------------------------------------------------
--  DDL for Package ECE_ADVO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_ADVO_X" AUTHID CURRENT_USER AS
-- $Header: ECADVOXS.pls 115.1 99/07/17 05:16:04 porting shi $

Procedure populate_extension_headers(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);

Procedure populate_extension_details(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type);


end ECE_ADVO_X;

 

/
