--------------------------------------------------------
--  DDL for Package ICX_OWA_PARMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_OWA_PARMS" AUTHID CURRENT_USER as
/* $Header: ICXOWPAS.pls 115.1 99/07/17 03:19:48 porting ship $ */
    pragma restrict_references( icx_owa_parms, wnds, rnds, wnps, rnps );
    type array is table of varchar2(2000) index by binary_integer;
    empty array;
    procedure register( p_names  in array);
    function get( p_num in number) return varchar2;
    pragma restrict_references(get,rnds,wnds,wnps);
end icx_owa_parms;

 

/
