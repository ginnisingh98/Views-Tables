--------------------------------------------------------
--  DDL for Package Body ICX_OWA_PARMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_OWA_PARMS" as
/* $Header: ICXOWPAB.pls 115.1 99/07/17 03:19:46 porting ship $ */
--
    l_names     array;
    l_values    array;
    l_cnt       number;
--
    procedure register( p_names   in array)
--                        p_values  in array )
    is
    begin
        for i in 1 .. 100000 loop
            begin
                l_names(i) := p_names(i);
                l_cnt := i;

            exception
                when no_data_found then exit;
            end;
        end loop;
--        l_values := p_values;
    end register;
--
    function get( p_num in number) return varchar2
    is
    begin

          return l_names(p_num);
    end get;
--
end icx_owa_parms;

/
