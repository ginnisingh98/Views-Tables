--------------------------------------------------------
--  DDL for Package FV_FACTS_TBAL_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS_TBAL_TRX" AUTHID CURRENT_USER AS
 /* $Header: FVFCTBPS.pls 120.0.12010000.1 2008/07/28 06:30:54 appldev ship $ */

     -- Main Procedure that is called for the FACTS Process Execution
 /* Bug No :1702796 Added the parameter "currency_code  */
 -- CF04 Added pagebreak parameter
    Procedure MAIN(
                Errbuf          OUT NOCOPY     Varchar2,
                retcode         OUT NOCOPY     Varchar2,
                Set_Of_Books_Id         Number,
		COA_Id			Number,
                Fund_Low                Varchar2,
                Fund_High               Varchar2,
                currency_code           Varchar2,
                Period		        Varchar2 ,
                report_id		NUMBER ,
                attribute_set		VARCHAR2 ,
                output_format		VARCHAR2);

END FV_FACTS_TBAL_TRX ;

/
