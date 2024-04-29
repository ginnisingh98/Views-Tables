--------------------------------------------------------
--  DDL for Package ECE_MVSTO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_MVSTO_TRANSACTION" AUTHID CURRENT_USER AS
-- $Header: ECEMVSOS.pls 120.2 2005/09/28 11:38:46 arsriniv ship $

  PROCEDURE Extract_MVSTO_Outbound (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT NOCOPY VARCHAR2,
                                   cOutput_Path  IN VARCHAR2,
                                   cOutput_Filename IN VARCHAR2,
                                   cLegal_Entity IN    VARCHAR2,
                                   cZone_Code  IN    VARCHAR2,
                                   cStat_Type  IN    VARCHAR2,
                                   cPeriod_Name IN    VARCHAR2,
                                   cMovement_Type IN    VARCHAR2,
                                   cInclude_Address IN    VARCHAR2 DEFAULT 'N',
                                   v_debug_mode IN NUMBER DEFAULT 0);



PROCEDURE POPULATE_MVSTO_TRX( cCommunication_Method   IN VARCHAR2,
                                cTransaction_Type       IN VARCHAR2,
                                iOutput_Width           IN INTEGER,
				dTransaction_date	IN DATE,
                                iRun_Id                 IN INTEGER,
                                cHeader_Interface       IN VARCHAR2,
                                cLine_Interface         IN VARCHAR2,
                                cLocation_Interface       IN VARCHAR2,
                                cLegal_Entity           IN    VARCHAR2,
                                cZone_Code          IN    VARCHAR2,
                                cStat_Type          IN    VARCHAR2,
                                cPeriod_Name        IN    VARCHAR2,
                                cMovement_Type      IN    VARCHAR2,
                                cInclude_Address    IN    VARCHAR2);

PROCEDURE PUT_DATA_TO_OUTPUT_TABLE(
				cCommunication_Method	IN VARCHAR2,
				cTransaction_Type	IN VARCHAR2,
				iOutput_width		IN INTEGER,
				iRun_id			IN INTEGER,
				cHeader_Interface	IN VARCHAR2,
				cLine_Interface		IN VARCHAR2,
				cLocation_Interface	IN VARCHAR2);

END;


 

/
