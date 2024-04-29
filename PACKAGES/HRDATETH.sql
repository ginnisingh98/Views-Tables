--------------------------------------------------------
--  DDL for Package HRDATETH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDATETH" AUTHID CURRENT_USER as
/* $Header: dtdateth.pkh 115.1 2002/12/06 16:47:24 apholt ship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
     dtdateth.pkh
--
   DESCRIPTION
     Package header for the Date Track History PL/SQL procedures.
--
  MODIFIED (DD-MON-YYYY)
     mwcallag   13-JUL-1993 - created.
     A.Holt     06-Dec-2002   NOCOPY Performance Changes for 11.5.9
*/
--
procedure get_view
(
    p_base_table   in out nocopy varchar2,
    p_out_title       out nocopy varchar2
);
--
end hrdateth;

 

/
