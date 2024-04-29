--------------------------------------------------------
--  DDL for Package Body GMF_RA_GET_FOB_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_RA_GET_FOB_CODES" AS
/* $Header: gmffobcb.pls 115.0 99/07/16 04:17:36 porting shi $ */
/*  CURSOR fob_codes(  startdate varchar2,
        enddate varchar2,  */
    CURSOR fob_codes(  startdate date,
        enddate date,
        lookupcode varchar2) IS
     SELECT    lookup_code,
        description,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
	inactive_date
    FROM  po_lookup_codes
    WHERE   lookup_type = 'FOB'  AND
      lookup_code like lookupcode AND
      last_update_date  BETWEEN
        nvl(startdate,last_update_date)  AND
        nvl(enddate,last_update_date);

   function get_name(usr_id  number) return varchar2 is
      usr_name varchar2(100);
  begin
        select user_name into usr_name from fnd_user where
        user_id=usr_id;
        return(usr_name);
  end;
/* SIERRA COMMENTED datatype changed to date */
/*  PROCEDURE ra_get_fob_codes(  startdate in varchar2,
      enddate in varchar2, */
    PROCEDURE ra_get_fob_codes(  startdate in date,
      enddate in date,
      lookupcode in out varchar2,
      description out varchar2,
      creation_date out varchar2,
      created_by out number,
      last_update_date out varchar2,
      last_updated_by out number,
      row_to_fetch in out number,
      statuscode out number,
      inactive_status out number) is
/*  ad_by  number;*/
/*  mod_by  number;*/
  inactive_date date;
  BEGIN
    inactive_status := 0;
    IF NOT fob_codes%ISOPEN THEN
      OPEN fob_codes(startdate,enddate,lookupcode);
    END IF;
    FETCH   fob_codes
    INTO  lookupcode ,
      description ,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      inactive_date;
    IF fob_codes%NOTFOUND THEN
      CLOSE fob_codes;
      statuscode := 100;
    END IF;
    IF row_to_fetch = 1 and fob_codes%ISOPEN THEN
      CLOSE fob_codes;
    END IF;
/*    added_by := get_name( ad_by);*/
/*    modified_by := get_name( mod_by);*/
    IF inactive_date <= SYSDATE THEN
	inactive_status := 1;
    END IF;
    EXCEPTION
      WHEN  OTHERS THEN
        statuscode := SQLCODE;
  END ra_get_fob_codes;
END GMF_RA_GET_FOB_CODES;

/
