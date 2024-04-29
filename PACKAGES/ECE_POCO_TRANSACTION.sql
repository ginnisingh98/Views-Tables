--------------------------------------------------------
--  DDL for Package ECE_POCO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_POCO_TRANSACTION" AUTHID CURRENT_USER AS
-- $Header: ECPOCOS.pls 120.2.12010000.1 2008/07/25 07:25:47 appldev ship $


/*===========================================================================

  PROCEDURE NAME:      Extract_POCO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible deliveires on a dparture.

===========================================================================*/
/*Bug 1854866
Assigned default values to the parameter
v_debug_mode of the procedure extract_poco_outbound
since the default values are assigned to these parameters
in the package body
*/

   PROCEDURE extract_poco_outbound(
      errbuf                  OUT NOCOPY VARCHAR2,
      retcode                 OUT NOCOPY VARCHAR2,
      cOutput_Path            IN VARCHAR2,
      cOutput_Filename        IN VARCHAR2,
      cPO_Number_From         IN VARCHAR2,
      cPO_Number_To           IN VARCHAR2,
      cRDate_From             IN VARCHAR2,
      cRDate_To               IN VARCHAR2,
      cPC_Type                IN VARCHAR2,
      cVendor_Name            IN VARCHAR2,
      cVendor_Site_Code       IN VARCHAR2,
      v_debug_mode            IN NUMBER DEFAULT 0);

   PROCEDURE populate_poco_trx(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_Width           IN INTEGER,
      dTransaction_date       IN DATE,
      iRun_Id                 IN INTEGER,
      cHeader_Interface       IN VARCHAR2,
      cLine_Interface         IN VARCHAR2,
      cShipment_Interface     IN VARCHAR2,
      cProject_Interface      IN VARCHAR2,
      cRevised_Date_From      IN DATE,
      cRevised_Date_To        IN DATE,
      cSupplier_Name          IN VARCHAR2,
      cSupplier_Site          IN VARCHAR2,
      cDocument_Type          IN VARCHAR2,
      cPO_Number_From         IN VARCHAR2,
      cPO_Number_To           IN VARCHAR2);

   PROCEDURE put_data_to_output_table(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_width           IN INTEGER,
      iRun_id                 IN INTEGER,
      cHeader_Interface       IN VARCHAR2,
      cLine_Interface         IN VARCHAR2,
      cShipment_Interface     IN VARCHAR2,
      cProject_Interface      IN VARCHAR2);

END;


/
