--------------------------------------------------------
--  DDL for Package Body IGI_PCANCEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_PCANCEL" as
/* $Header: igiexpjb.pls 115.11 2003/08/09 11:45:54 rgopalan ship $ */

   PROCEDURE cancel_dial_unit(du_id IN number)
    IS
       l_cancel_number number;
       pprefix varchar2(100);
       pseq_num number;
       psuffix varchar2(100);


BEGIN
NULL;
END cancel_dial_unit;
END IGI_PCANCEL ;

/
