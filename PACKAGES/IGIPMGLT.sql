--------------------------------------------------------
--  DDL for Package IGIPMGLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIPMGLT" AUTHID CURRENT_USER AS
-- $Header: igipmgts.pls 115.5 2002/11/18 13:45:36 panaraya ship $
   SUBTYPE   GLINT  IS gl_interface%ROWTYPE;
   SUBTYPE   GLINT_CONTROL is gl_interface_control%ROWTYPE;
   SUBTYPE   MPP_SUBLGR    is igi_mpp_subledger%ROWTYPE;

   PROCEDURE   SubLedgerTxfrtoGL (  errbuf  out NOCOPY varchar2
                                 ,  retcode out NOCOPY number
                                 ,  p_set_of_books_id      in number
                                 ,  p_start_period_eff_num in number
                                 ,  p_end_period_eff_num   in number
                                 ,  p_run_gl_import        in varchar2
                                 );

END IGIPMGLT ;

 

/
