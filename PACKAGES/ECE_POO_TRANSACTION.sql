--------------------------------------------------------
--  DDL for Package ECE_POO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_POO_TRANSACTION" AUTHID CURRENT_USER AS
-- $Header: ECEPOOS.pls 120.4.12010000.1 2008/07/25 07:23:32 appldev ship $

   G_MAX_ATT_SEG_SIZE      CONSTANT NUMBER := 900;
   G_DEFAULT_ATT_SEG_SIZE  CONSTANT NUMBER := 400;
/*Bug 1854866
Assigned default values to the parameter
v_debug_mode of the procedure extract_poo_outbound
since the default values are assigned to these parameters
in the package body
*/

/* Bug 1891291
   Replaced project interface table name
   by distribution interface table name
   in procedure specification.
   Also renamed populate_project_info
   to populate_distribution_info and
   put_project_data_to_output_tbl to
   put_distdata_to_out_tbl
*/

/* Bug 2490109
   Defined variables which will be accessed by POO and POCO program
*/

project_sel_c              INTEGER:=0;
project_del_c1             INTEGER;
project_del_c2             INTEGER;
l_project_tbl              ece_flatfile_pvt.Interface_tbl_type;
uFile_type                 utl_file.file_type;
/* BUG:5367903 */
C_ANY_VALUE                VARCHAR2(120):= '_ANY_VALUE_';
   PROCEDURE extract_poo_outbound(
      errbuf                  OUT NOCOPY VARCHAR2,
      retcode                 OUT NOCOPY VARCHAR2,
      cOutput_Path            IN VARCHAR2,
      cOutput_Filename        IN VARCHAR2,
      cPO_Number_From         IN VARCHAR2,
      cPO_Number_To           IN VARCHAR2,
      cCDate_From             IN VARCHAR2,
      cCDate_To               IN VARCHAR2,
      cPC_Type                IN VARCHAR2,
      cVendor_Name            IN VARCHAR2,
      cVendor_Site_Code       IN VARCHAR2,
      v_debug_mode            IN NUMBER DEFAULT 0);

   PROCEDURE populate_poo_trx(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_Width           IN INTEGER,
      dTransaction_date       IN DATE,
      iRun_Id                 IN INTEGER,
      cHeader_Interface       IN VARCHAR2,
      cLine_Interface         IN VARCHAR2,
      cShipment_Interface     IN VARCHAR2,
      cDistribution_Interface      IN VARCHAR2,
      cCreate_Date_From       IN DATE,
      cCreate_Date_To         IN DATE,
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
      cDistribution_Interface      IN VARCHAR2);

   PROCEDURE update_po(
      document_type           IN VARCHAR2,
      po_number               IN VARCHAR2,
      po_type                 IN VARCHAR2,
      release_number          IN VARCHAR2);

   PROCEDURE POPULATE_DISTRIBUTION_INFO(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iRun_id                 IN INTEGER,
      cDistribution_Interface      IN VARCHAR2,
      l_key_tbl               IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      cPO_Header_ID           IN NUMBER,
      cPO_Release_ID          IN NUMBER,
      cPO_Line_ID             IN NUMBER,
      cPO_Line_Location_ID    IN NUMBER,
      cFile_Common_Key        IN VARCHAR2);  --bug 2823215

   PROCEDURE PUT_DISTDATA_TO_OUT_TBL(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_width           IN INTEGER,
      iRun_id                 IN INTEGER,
      cDistribution_Interface      IN VARCHAR2,
      cPO_Header_ID           IN NUMBER,
      cPO_Release_ID          IN NUMBER,
      cPO_Line_ID             IN NUMBER,
      cPO_Line_Location_ID    IN NUMBER,
      cFile_Common_Key        IN VARCHAR2);

   PROCEDURE populate_text_attachment(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iRun_id                 IN INTEGER,
      cHeader_Output_Level    IN NUMBER,
      cDetail_Output_Level    IN NUMBER,
      cAtt_Header_Interface   IN VARCHAR2,
      cAtt_Detail_Interface   IN VARCHAR2,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cSegment_Size           IN NUMBER,
      l_key_tbl               IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      cFile_Common_Key        IN VARCHAR2,
      l_att_header_tbl        IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      l_att_detail_tbl        IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      l_key_count             IN OUT NOCOPY NUMBER); -- bug 2823215

   PROCEDURE populate_text_att_detail(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iRun_id                 IN INTEGER,
      cDetail_Output_Level    IN NUMBER,
      cAtt_Detail_Interface   IN VARCHAR2,
      cAtt_Seq_Num            IN NUMBER,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cData_Type_ID           IN NUMBER,
      cSegment_Size           IN NUMBER,
      l_key_tbl               IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      cAtt_doc_id             IN NUMBER,  -- bug 2187958
      cFile_Common_Key        IN VARCHAR2,
      l_att_detail_tbl        IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type); -- bug 2823215

   PROCEDURE put_att_to_output_table(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_Width           IN INTEGER,
      iRun_id                 IN INTEGER,
      cHeader_Output_Level    IN NUMBER,
      cDetail_Output_Level    IN NUMBER,
      cHeader_Interface       IN VARCHAR2,
      cDetail_Interface       IN VARCHAR2,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cFile_Common_Key        IN VARCHAR2);

   PROCEDURE put_att_detail_to_output_table(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_Width           IN INTEGER,
      iRun_id                 IN INTEGER,
      cDetail_Output_Level    IN NUMBER,
      cHeader_Interface       IN VARCHAR2,
      cDetail_Interface       IN VARCHAR2,
      cAtt_Seq_Num            IN NUMBER,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cFile_Common_Key        IN VARCHAR2,
      cAtt_Doc_ID             IN NUMBER);    --Bug 2187958

      PROCEDURE write_to_file(
      cTransaction_Type       IN VARCHAR2,
      cCommunication_Method   IN VARCHAR2,
      cInterface_Table        IN VARCHAR2,
      p_Interface_tbl         IN ece_flatfile_pvt.Interface_tbl_type,
      iOutput_width           IN INTEGER,
      iRun_id                 IN INTEGER,
      p_common_key            IN VARCHAR2,
      p_foreign_key           IN NUMBER);


END;


/
