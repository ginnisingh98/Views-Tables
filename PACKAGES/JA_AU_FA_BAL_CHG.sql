--------------------------------------------------------
--  DDL for Package JA_AU_FA_BAL_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_AU_FA_BAL_CHG" AUTHID CURRENT_USER AS
/* $Header: jaaufass.pls 115.4 2002/11/12 22:12:39 thwon ship $ */

   PROCEDURE Schedule32
          (P_Book_type_code     VARCHAR2,
           P_From_Period        VARCHAR2,
           P_To_Period          VARCHAR2,
           P_Category_ID	  NUMBER );

   PROCEDURE JAAUFRET
          (ERRBUF 	OUT NOCOPY 	VARCHAR2,
           RETCODE 	OUT NOCOPY 	VARCHAR2,
           BOOK 		VARCHAR2,
           PERIOD 		VARCHAR2);

   PROCEDURE Calc_Bal_Chg (ERRBUF 	OUT NOCOPY 	VARCHAR2,
           RETCODE 	OUT NOCOPY 	VARCHAR2,
           BOOK 		VARCHAR2,
           PERIOD 		VARCHAR2 ) ;
END JA_AU_FA_BAL_CHG;

 

/
