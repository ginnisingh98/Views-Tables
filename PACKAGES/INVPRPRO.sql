--------------------------------------------------------
--  DDL for Package INVPRPRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPRPRO" AUTHID CURRENT_USER AS
/* $Header: INVPRPRS.pls 120.2 2005/06/20 09:13:22 appldev ship $ */

function project_where (
	order_line_id 			IN	number,
	add_where_clause IN OUT NOCOPY /* file.sql.39 change */ varchar2) return number;

END INVPRPRO;

 

/
