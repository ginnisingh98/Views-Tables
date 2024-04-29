--------------------------------------------------------
--  DDL for Package CZMLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZMLS" AUTHID CURRENT_USER as
/*	$Header: czmlss.pls 115.10 2002/11/27 17:05:59 askhacha ship $ */
	procedure Set_Windows_Client_Info (Code_Page in NUMBER, Language in NUMBER,
		OracleCharset in OUT NOCOPY VARCHAR2, db_client_language OUT NOCOPY VARCHAR2,
		db_base_language OUT NOCOPY VARCHAR2, Status OUT NOCOPY NUMBER);

	procedure Set_Oracle_Charset (to_charset in varchar2);
	function client_charset return varchar2;
	function check_language(Language in NUMBER, db_client_language OUT NOCOPY VARCHAR2,
					db_base_language OUT NOCOPY VARCHAR2 ) return number;

end czmls;

 

/
