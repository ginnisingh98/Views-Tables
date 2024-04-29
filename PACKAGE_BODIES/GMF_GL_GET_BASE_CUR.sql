--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_BASE_CUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_BASE_CUR" as
/* $Header: gmfbascb.pls 115.0 99/07/16 04:14:54 porting shi $ */
	function GET_BASE_CUR ( PORG_ID NUMBER) return varchar2 is

		base_currency	varchar2(15);

		begin
			select currency_code
			into base_currency
			from gl_sets_of_books sob,
			     ar_system_parameters_all ars
			where sob.set_of_books_id = ars.set_of_books_id
			and   nvl(ars.org_id,0) = nvl(porg_id, nvl(ars.org_id,0));

			return (base_currency);
            exception
		when NO_DATA_FOUND then
		     base_currency := -2;
		     return (base_currency);

	 	when OTHERS then
		     base_currency := -2;
		     return (base_currency);

		end;

END GMF_GL_GET_BASE_CUR;

/
