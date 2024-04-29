--------------------------------------------------------
--  DDL for Package OE_INLINE_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INLINE_FLEX" AUTHID CURRENT_USER as
/* $Header: OEXFILFS.pls 120.0 2005/06/01 01:50:10 appldev noship $ */


procedure initialize;

procedure setup_flexfield( flex_code in varchar2,
                          structure_id    in number );


function token_expand( word        in varchar2,
                       i           in number ) return varchar2;

function delimit( word in varchar2 ) return varchar2;

procedure add_to_list( list in out NOCOPY /* file.sql.39 change */ varchar2, value in varchar2 );

function qualifier_list( qualifiers in varchar2 ) return varchar2;

procedure expand( qualifiers  in varchar2,
                 separator   in varchar2,
                 word        in varchar2,
			  structure  out NOCOPY /* file.sql.39 change */ varchar2);


function active_segments return number;

end oe_inline_flex;


 

/
