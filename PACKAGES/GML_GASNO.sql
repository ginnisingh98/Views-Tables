--------------------------------------------------------
--  DDL for Package GML_GASNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_GASNO" AUTHID CURRENT_USER as
/*$Header: GMLSNOS.pls 115.7 2002/11/08 16:04:02 gmangari ship $*/
/*==============================  GML_GASNO  =================================*/
/*===========================================================================
  PACKAGE NAME:         GML_GASNO

  DESCRIPTION:          Contains all server side procedures to export
                        Ship Notice data to a flat file.

  CLIENT/SERVER:        Server

  LIBRARY NAME:         None

  OWNER:                OPM Logistics

  PROCEDURE/FUNCTIONS:  Extract_GASNO_Outbound()
                        Populate_Interface_Tables()
                        Put_Data_To_Output_Table()


  NOTES:                To run the script:

                        sql> start GMLSNOS.pls

  HISTORY               01/11/99  mmacary   Created.
                        04/05/99 Sining Wang  Modified for 11.5.
                        05/12/99  dgrailic  For 11i, modified names from ECE_ to GML_
  Bug 2411796           06/17/2002 Added default value for parameter p_debug_mode.
  Bug#2642152           26-OCT-2002   RajaSekhar    Added NOCOPY hint
===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:      Extract_GASNO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the OPM Advanced Ship Notice

===========================================================================*/

  PROCEDURE Extract_GASNO_Outbound (errbuf                     OUT NOCOPY VARCHAR2,
                                    retcode                    OUT NOCOPY VARCHAR2,
                                    p_OutputPath               IN VARCHAR2,
                                    p_Filename                 IN VARCHAR2,
                                    p_Orgn_Code                IN VARCHAR2,
                                    p_BOL_No_From              IN VARCHAR2,
                                    p_BOL_No_To                IN VARCHAR2,
                                    p_Creation_Date_From       IN VARCHAR2,
                                    p_Creation_Date_To         IN VARCHAR2,
                                    p_Customer_Name            IN VARCHAR2,
                                    p_debug_mode               IN NUMBER default 0);

/*===========================================================================
  PROCEDURE NAME:       Populate_Interface_Tables

  DESCRIPTION:          Initiate export process OPM Advanced Ship Notice

  DESIGN REFERENCES:    gasnomap.xls

 ===========================================================================*/

 PROCEDURE Populate_Interface_Tables ( p_CommunicationMethod      IN VARCHAR2,
                                       p_TransactionType          IN VARCHAR2,
                                       p_Orgn_Code                IN VARCHAR2,
                                       p_BOL_No_From              IN VARCHAR2,
                                       p_BOL_No_To                IN VARCHAR2,
                                       p_Creation_Date_From       IN VARCHAR2,
                                       p_Creation_Date_To         IN VARCHAR2,
                                       p_Customer_Name            IN VARCHAR2,
                                       p_RunID                    IN INTEGER,
                                       p_SHP_Interface            IN VARCHAR2,
                                       p_STX_Interface            IN VARCHAR2,
                                       p_ORD_Interface            IN VARCHAR2,
                                       p_OAC_Interface            IN VARCHAR2,
                                       p_OTX_Interface            IN VARCHAR2,
                                       p_DTL_Interface            IN VARCHAR2,
                                       p_DAC_Interface            IN VARCHAR2,
                                       p_DTX_Interface            IN VARCHAR2,
                                       p_ALL_Interface            IN VARCHAR2 );

/*===========================================================================
  PROCEDURE NAME:       Put_Data_To_Output_Table

  DESCRIPTION:          Extracts, sequences and formats data from the interface
                        tables and writes it to the output table.  The output
                        file is then written by spooling the data from the
                        output table.  Upon successful completion, purges
                        interface tables.

  DESIGN REFERENCES:    gasnomap.xls

 ===========================================================================*/

 PROCEDURE Put_Data_To_Output_Table (  p_CommunicationMethod      IN VARCHAR2,
                                       p_TransactionType          IN VARCHAR2,
                                       p_Orgn_Code                IN VARCHAR2,
                                       p_BOL_No_From              IN VARCHAR2,
                                       p_BOL_No_To                IN VARCHAR2,
                                       p_Creation_Date_From       IN VARCHAR2,
                                       p_Creation_Date_To         IN VARCHAR2,
                                       p_Customer_Name            IN VARCHAR2,
                                       p_RunID                    IN INTEGER,
                                       p_OutputWidth              IN INTEGER,
	                               p_SHP_Interface            IN VARCHAR2,
                                       p_STX_Interface            IN VARCHAR2,
                                       p_ORD_Interface            IN VARCHAR2,
                                       p_OAC_Interface            IN VARCHAR2,
                                       p_OTX_Interface            IN VARCHAR2,
                                       p_DTL_Interface            IN VARCHAR2,
                                       p_DAC_Interface            IN VARCHAR2,
                                       p_DTX_Interface            IN VARCHAR2,
                                       p_ALL_Interface            IN VARCHAR2 );

/*=========================================================================*/

END GML_GASNO;

 

/
