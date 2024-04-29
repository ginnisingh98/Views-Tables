--------------------------------------------------------
--  DDL for Package Body OE_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LOCATION" AS
/* $Header: OEXHLOCB.pls 115.0 99/07/16 08:12:38 porting shi $ */
--
  --
  PROCEDURE OE_PREDEL_VALIDATION (p_location_id   number)
  IS

  l_delete_permitted    varchar2(1) := 'N';
  l_msg 		varchar2(30);
  BEGIN
     --
     hr_utility.set_location('OE_LOCATION.OE_PREDEL_VALIDATION', 1);
      --
      BEGIN

        l_msg := 'OE_LOC_TRANSACTIONS_TEMP';

        select 'Y'
        into    l_delete_permitted
        from    sys.dual
        where   not exists (
		select  null
                from    SO_HEADERS_ALL SH
                where   SH.HEADER_ID IN (select header_id
                                         from   so_drop_ship_sources
                                         where  line_location_id =
                                                p_location_id)
                and     SH.OPEN_FLAG = 'Y');


      EXCEPTION
        WHEN NO_DATA_FOUND then
                 null;
        /*        hr_utility.set_message (300, l_msg); */
        /*        hr_utility.raise_error; */
      END;
      --
      --
  END OE_PREDEL_VALIDATION;
--
END OE_LOCATION;

/
