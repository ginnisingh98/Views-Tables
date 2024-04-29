--------------------------------------------------------
--  DDL for Package Body BOMPCFGI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPCFGI" as
/* $Header: BOMCFGIB.pls 115.2 2002/07/01 18:16:55 ssawant ship $ */

function user_item_number (
          model_line_id   in   number )
return varchar2
is

  item_num    VARCHAR2(40);

  begin

    /* Remove this dummy assignment line */

       item_num := 'MyItem';

    /* Add code here */

    return   item_num;

  end user_item_number;

end BOMPCFGI;


/
