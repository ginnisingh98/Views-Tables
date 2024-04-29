--------------------------------------------------------
--  DDL for Package IGI_ITR_GL_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_ITR_GL_INTERFACE_PKG" AUTHID CURRENT_USER AS
-- $Header: igiitrps.pls 120.3.12000000.2 2007/09/17 16:29:30 smannava ship $
PROCEDURE Create_Actuals(
    errbuf            OUT NOCOPY varchar2,
    retcode           OUT NOCOPY number,
    p_set_of_books_id IN  igi_itr_charge_headers.set_of_books_id%type,
    p_start_period    IN  igi_itr_charge_headers.it_period_name%type,
    p_end_period      IN  igi_itr_charge_headers.it_period_name%type);
  subtype glcontrol   IS gl_interface_control%rowtype;
  subtype glinterface IS gl_interface%rowtype;
END IGI_ITR_GL_INTERFACE_PKG;

 

/
