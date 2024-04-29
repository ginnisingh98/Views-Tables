--------------------------------------------------------
--  DDL for Package CLN_SHOWSHIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_SHOWSHIP_UTILS" AUTHID CURRENT_USER AS
   /* $Header: CLNSHSUS.pls 115.5 2003/06/28 09:27:07 kkram noship $ */

   /*=======================================================================+
   | FILENAME
   |   CLNSHSUS.sql
   |
   | DESCRIPTION
   |   PL/SQL spec for package:  CLN_SHOWSHIP_UTILS
   |
   | NOTES
   |   Created 4/08/03 chiung-fu.shih
   *=====================================================================*/

   PROCEDURE getPurchaseOrderNum(PoAndRel        IN   VARCHAR2,
                                 PoNum           OUT  NOCOPY   VARCHAR2);

   PROCEDURE getRelNum(PoAndRel        IN   VARCHAR2,
                       RelNum          OUT  NOCOPY   VARCHAR2);



END CLN_SHOWSHIP_UTILS;

 

/
