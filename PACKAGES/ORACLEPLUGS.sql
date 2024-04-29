--------------------------------------------------------
--  DDL for Package ORACLEPLUGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORACLEPLUGS" AUTHID CURRENT_USER as
/* $Header: ICXSEPS.pls 120.1 2005/10/07 14:22:29 gjimenez noship $ */

procedure plugRename(Z in varchar2);

procedure Customize(p_session_id pls_integer default null,
                    p_page_id    pls_integer default null);

procedure updateCustomization(X in varchar2,
                              Y in varchar2,
			      Z in pls_integer,
                              N in varchar2 default NULL,
                              O in pls_integer default 0);

c_ampersand constant varchar2(1) := '&';

end OraclePlugs;

 

/
