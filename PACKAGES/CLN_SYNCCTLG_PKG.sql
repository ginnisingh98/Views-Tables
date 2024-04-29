--------------------------------------------------------
--  DDL for Package CLN_SYNCCTLG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_SYNCCTLG_PKG" AUTHID CURRENT_USER AS
   /* $Header: CLNSYCTS.pls 115.5 2004/07/16 23:07:07 cshih noship $ */

   /*=======================================================================+
   | FILENAME
   |   CLNSYCTS.sql
   |
   | DESCRIPTION
   |   PL/SQL spec for package:  CLN_SYNCCTLG_PKG
   |
   | NOTES
   |   Created 6/03/03 chiung-fu.shih
   *=====================================================================*/

   PROCEDURE Syncctlg_Raise_Event(errbuf            OUT NOCOPY      VARCHAR2,
                                  retcode           OUT NOCOPY      VARCHAR2,
                                  p_tp_header_id    IN              NUMBER,
                                  p_list_header_id  IN              NUMBER,
                                  p_category_id     IN              NUMBER,
                                  p_from_items      IN              VARCHAR2,
                                  p_to_items        IN              VARCHAR2,
                                  p_currency_detail_id   IN         NUMBER,
                                  p_numitems_per_oag     IN         NUMBER
);

END CLN_SYNCCTLG_PKG;

 

/
