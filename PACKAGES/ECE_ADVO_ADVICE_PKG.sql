--------------------------------------------------------
--  DDL for Package ECE_ADVO_ADVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_ADVO_ADVICE_PKG" AUTHID CURRENT_USER AS
-- $Header: ECADVOS.pls 120.3 2005/09/28 11:00:44 arsriniv ship $

/*===========================================================================

  PROCEDURE NAME:      Extract_DSNO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible deliveires on a dparture.

===========================================================================*/
/*Bug 1854866
Assigned default values to the parameter
v_debug_mode of the procedure extract_advo_outbound
since the default values are assigned to these parameters
in the package body
*/

  PROCEDURE Extract_ADVO_Outbound (errbuf OUT NOCOPY VARCHAR2,
                                   retcode OUT  NOCOPY VARCHAR2,
                                   cOutput_Path  IN VARCHAR2,
                                   cOutput_Filename IN VARCHAR2,
                                   p_TP_Group IN VARCHAR2,
                                   p_TP IN VARCHAR2,
                                   p_Response_to_doc IN VARCHAR2,
                                   cDate_From IN VARCHAR2,
                                   cDate_To IN VARCHAR2,
                                   p_ext_ref1 IN VARCHAR2,
                                   p_ext_ref2 IN VARCHAR2,
                                   p_ext_ref3 IN VARCHAR2,
                                   p_ext_ref4 IN VARCHAR2,
                                   p_ext_ref5 IN VARCHAR2,
                                   p_ext_ref6 IN VARCHAR2,
                                   v_debug_mode IN NUMBER DEFAULT 0);


PROCEDURE EXTRACT_FROM_BASE_APPS(
				cCommunication_Method	IN VARCHAR2,
				cTransaction_Type	IN VARCHAR2,
				iOutput_width		IN INTEGER,
				dTransaction_date	IN DATE,
				iRun_id			IN INTEGER,
				cHeader_Interface	IN VARCHAR2,
				cLine_Interface		IN VARCHAR2,
				p_TP_Group		IN VARCHAR2,
				p_TP			IN VARCHAR2,
				p_Response_to_doc	IN VARCHAR2,
				p_Date_From		IN DATE,
				p_Date_To		IN DATE,
				p_ext_ref1		IN VARCHAR2,
				p_ext_ref2		IN VARCHAR2,
				p_ext_ref3		IN VARCHAR2,
				p_ext_ref4		IN VARCHAR2,
				p_ext_ref5		IN VARCHAR2,
				p_ext_ref6		IN VARCHAR2);

PROCEDURE PUT_DATA_TO_OUTPUT_TABLE(
				cCommunication_Method	IN VARCHAR2,
				cTransaction_Type	IN VARCHAR2,
				iOutput_width		IN INTEGER,
				iRun_id			IN INTEGER,
				cHeader_Interface	IN VARCHAR2,
				cLine_Interface		IN VARCHAR2);

END;


 

/
