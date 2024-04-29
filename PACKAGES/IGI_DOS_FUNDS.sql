--------------------------------------------------------
--  DDL for Package IGI_DOS_FUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_FUNDS" AUTHID CURRENT_USER AS
-- $Header: igidoses.pls 120.3.12000000.2 2007/06/14 06:56:43 pshivara ship $

  FUNCTION REJECT
     ( p_trx_number in varchar2,
       p_user_id    in varchar2,
       p_responsibility_id in varchar2,
       p_sob_id in varchar2
      )
     RETURN  boolean;
  FUNCTION APPROVE
     ( p_trx_number in varchar2,
       p_user_id    in varchar2,
       p_responsibility_id in varchar2,
       p_sob_id in varchar2
      )
     RETURN  boolean;

END; -- Package Specification IGI_DOS_FUNDS

 

/
