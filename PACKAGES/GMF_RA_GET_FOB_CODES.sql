--------------------------------------------------------
--  DDL for Package GMF_RA_GET_FOB_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_RA_GET_FOB_CODES" AUTHID CURRENT_USER AS
/* $Header: gmffobcs.pls 115.0 99/07/16 04:17:41 porting shi $ */
/* SIERRA changed the datatypes of start_date and end_date to date */
/*  PROCEDURE ra_get_fob_codes(  startdate in varchar2,
    enddate in varchar2,  */
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
    inactive_status out number);
   function get_name(usr_id  number) return varchar2;
END GMF_RA_GET_FOB_CODES;

 

/
