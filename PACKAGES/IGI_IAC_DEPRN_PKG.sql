--------------------------------------------------------
--  DDL for Package IGI_IAC_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_DEPRN_PKG" AUTHID CURRENT_USER AS
-- $Header: igiiaprs.pls 120.5.12000000.2 2007/10/16 14:22:07 sharoy ship $

   FUNCTION Do_Depreciation(
   	p_book_type_code	  in varchar2 ,
   	p_period_counter	  in number ,
   	p_calling_function        in varchar2
   ) return BOOLEAN ;

   FUNCTION Synchronize_Calendars(
    p_book_type_code      in varchar2) RETURN BOOLEAN ;

   FUNCTION Periodic_Reval_of_Deprn(
   	p_book_type_code	  in varchar2 ,
   	p_period_counter	  in number  ) RETURN BOOLEAN;

   FUNCTION Synchronize_Accounts(
        p_book_type_code    IN VARCHAR2,
        p_period_counter    IN NUMBER,
        p_calling_function  IN VARCHAR2
        ) return BOOLEAN ;

    /* Bug 2906034 vgadde 25/04/2003 Start(1) */
   /*FUNCTION Process_non_Deprn_Assets(
        p_book_type_code    IN VARCHAR2,
        p_calling_function  IN VARCHAR2
        ) return BOOLEAN ;*/
    /* Bug 2906034 vgadde 25/04/2003 End(1) */

END; -- Package spec

 

/
