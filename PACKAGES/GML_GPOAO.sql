--------------------------------------------------------
--  DDL for Package GML_GPOAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_GPOAO" AUTHID CURRENT_USER as
/* $Header: GMLPAOS.pls 115.5 2002/11/08 06:33:46 gmangari ship $     */
/*===========================================================================
  PACKAGE NAME:         GML_GPOAO

  DESCRIPTION:          Contains all server side procedures to export
                        PO Ack to a flat file.  One flat file
                        will be created for all PO Acks

  CLIENT/SERVER:        Server

  LIBRARY NAME:         None

  PROCEDURE/FUNCTIONS:
                        Populate_Interface_Tables()
                        Put_Data_To_Output_Table()


  NOTES:                To run the script:

                        sql> start GMLPAOS.pls

  HISTORY               02/14/99  dgrailic  Created.
            05/17/99 dgrailic Modified to use GML_ prefix
            26-OCT-2002   Bug#2642152  RajaSekhar    Added NOCOPY hint

===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:      Extract_GPOAO_Outbound

  PURPOSE:  This PLSQL procedure produces an ASCII file containing
            an OPM PO Ack Outbound
            This ASCII file may then be processed by
            third-party EDI translation software to generate and send
            the EDI Outbound Ship Notice transaction.

  NOTES:    This script takes nine parameters:
               1.  The output path
               2.  The output file name
               3.  Required field, OPM organization code
               4.  Optional Order Number from
               5.  Optional Order Number to
               6.  Optional Creation Date from
               7.  Optional Creation Date to
               8.  Optional OF Customer Name
               9.  debug

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/15/99  dgrailic  Created.

 ============================================================================ */
PROCEDURE Extract_GPOAO_Outbound ( errbuf              OUT NOCOPY VARCHAR2,
                                  retcode              OUT NOCOPY VARCHAR2,
                                  v_OutputPath         IN  VARCHAR2,
                                  v_Filename           IN  VARCHAR2,
                                  v_Orgn_Code          IN  VARCHAR2,
                                  v_Order_No_From      IN  VARCHAR2,
                                  v_Order_No_To        IN  VARCHAR2,
                                  v_Creation_Date_From IN  VARCHAR2,
                                  v_Creation_Date_To   IN  VARCHAR2,
                                  v_Customer_Name      IN  VARCHAR2,
                                  v_debug_mode         IN  NUMBER default 0 );

/*===========================================================================
  PROCEDURE NAME:       Populate_Interface_Tables

  DESCRIPTION:          Initiate export process for all PO Acks

  DESIGN REFERENCES:    gpoao_hld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/15/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Populate_Interface_Tables ( p_CommunicationMethod      IN VARCHAR2,
                                       p_TransactionType          IN VARCHAR2,
                                       p_Orgn_Code                IN VARCHAR2,
                                       p_Order_No_From            IN VARCHAR2,
                                       p_Order_No_To              IN VARCHAR2,
                                       p_Creation_Date_From       IN DATE,
                                       p_Creation_Date_To         IN DATE,
                                       p_Customer_Name            IN VARCHAR2,
                                       p_RunID                    IN INTEGER,
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

  DESIGN REFERENCES:    gpoao_hld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       02/15/99  dgrailic  Created.

 ===========================================================================*/

 PROCEDURE Put_Data_To_Output_Table (  p_CommunicationMethod      IN VARCHAR2,
                                       p_TransactionType          IN VARCHAR2,
                                       p_Orgn_Code                IN VARCHAR2,
                                       p_Order_No_From            IN VARCHAR2,
                                       p_Order_No_To              IN VARCHAR2,
                                       p_Creation_Date_From       IN DATE,
                                       p_Creation_Date_To         IN DATE,
                                       p_Customer_Name            IN VARCHAR2,
                                       p_RunID                    IN INTEGER,
                                       p_OutputWidth              IN INTEGER,
                                       p_ORD_Interface            IN VARCHAR2,
                                       p_OAC_Interface            IN VARCHAR2,
                                       p_OTX_Interface            IN VARCHAR2,
                                       p_DTL_Interface            IN VARCHAR2,
                                       p_DAC_Interface            IN VARCHAR2,
                                       p_DTX_Interface            IN VARCHAR2,
                                       p_ALL_Interface            IN VARCHAR2 );


/*=========================================================================*/

END GML_GPOAO;

 

/
