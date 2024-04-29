--------------------------------------------------------
--  DDL for Package ICX_ON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ON" AUTHID CURRENT_USER as
/* $Header: ICXONMS.pls 120.0 2005/10/07 12:16:22 gjimenez noship $ */

type number_table is table of number
        index by binary_integer;

type v30_table is table of varchar2(30)
        index by binary_integer;

type v50_table is table of varchar2(50)
        index by binary_integer;

type v240_table is table of varchar2(240)
        index by binary_integer;

type v2000_table is table of varchar2(2000)
        index by binary_integer;

type rowid_table is table of rowid
        index by binary_integer;

procedure get_page(p_attributes in icx_on_utilities.v80_table,
		   p_conditions in icx_on_utilities.v80_table,
		   p_inputs	in icx_on_utilities.v80_table,
		   p_match      in varchar2,
		   p_and_or	in varchar2);

procedure create_file(S in number,
		      c_delimiter in varchar2);

c_ampersand constant varchar2(1) := '&';
c_percent   constant varchar2(1) := '%';

end icx_on;

 

/
