--------------------------------------------------------
--  DDL for Package JAI_ARRA_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_ARRA_TRG_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_arra_trg.pls 120.1.12000000.1 2007/07/24 06:55:45 rallamse noship $ */


/***************************************************************************************************
CREATED BY       : CSahoo
CREATED DATE     : 01-FEB-2007
ENHANCEMENT BUG  : 5631784
PURPOSE          : NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES

-- #
-- # Change History -


1.  01/02/2007   CSahoo for bug#5631784. File Version 120.0
								 Forward Porting of 11i BUG#4742259 (TAX COLLECTION AT SOURCE IN RECEIVABLES)

*******************************************************************************************************/
  PROCEDURE process_app  ( r_new               IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE    ,
                           r_old               IN              AR_RECEIVABLE_APPLICATIONS_ALL%ROWTYPE    ,
                           p_process_flag      OUT NOCOPY      VARCHAR2                                  ,
                           p_process_message   OUT NOCOPY      VARCHAR2
                         ) ;
END jai_arra_trg_pkg ;
 

/
