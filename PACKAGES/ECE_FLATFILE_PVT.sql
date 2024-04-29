--------------------------------------------------------
--  DDL for Package ECE_FLATFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_FLATFILE_PVT" AUTHID CURRENT_USER AS
-- $Header: ECVFILES.pls 120.2 2005/09/30 06:53:13 arsriniv ship $

   G_MAXCOLWIDTH              NUMBER      :=  400;       -- ****** IMPORTANT ********
   G_TRANSLATOR_CODE          VARCHAR2(35):= 'TP_TRANSLATOR_CODE';
   G_TRANSACTION_DATE         VARCHAR2(35):= 'TRANSACTION_DATE';
   G_RUN_ID                   VARCHAR2(35):= 'RUN_ID';
   G_COMMON_KEY_LENGTH        NUMBER      :=  100;
   G_RECORD_NUM_START         NUMBER      :=  92;
   G_RECORD_NUM_LENGTH        NUMBER      :=  4;

   TYPE attribute_rec_type IS RECORD(
      key_column_name         VARCHAR2(50),
      value                   VARCHAR2(400),
      position                NUMBER);

   TYPE attribute_tbl_type IS TABLE OF attribute_rec_type
      INDEX BY BINARY_INTEGER;

   -- This is the global attribute table...
   t_tran_attribute_tbl       attribute_tbl_type;

   TYPE interface_rec_type IS RECORD(
      base_table_name         VARCHAR2(50),
      base_column_name        VARCHAR2(50),
      interface_table_name    VARCHAR2(50),
      interface_column_name   VARCHAR2(50),
      Record_num              NUMBER,
      Position                NUMBER,
      data_type               VARCHAR2(50),
      data_length             NUMBER,
      value                   VARCHAR2(32767),
      layout_code             VARCHAR2(2),
      record_qualifier        VARCHAR2(3),
      interface_column_id     NUMBER,
      conversion_seq          NUMBER,
      xref_category_id        NUMBER,
      conversion_group_id     NUMBER,
      xref_key1_source_column VARCHAR2(50),
      xref_key2_source_column VARCHAR2(50),
      xref_key3_source_column VARCHAR2(50),
      xref_key4_source_column VARCHAR2(50),
      xref_key5_source_column VARCHAR2(50),
      ext_val1                VARCHAR2(500),
      ext_val2                VARCHAR2(500),
      ext_val3                VARCHAR2(500),
      ext_val4                VARCHAR2(500),
      ext_val5                VARCHAR2(500),
      ext_column_name         VARCHAR2(50));  -- bug 2823215

   TYPE interface_tbl_type IS TABLE OF interface_rec_type
      INDEX BY BINARY_INTEGER;

   PROCEDURE get_tran_attributes(p_transaction_type IN VARCHAR2);

   PROCEDURE print_attributes;

   PROCEDURE select_clause(
      cTransaction_Type       IN       VARCHAR2,
      cCommunication_Method   IN       VARCHAR2,
      cInterface_Table        IN       VARCHAR2,
      cExt_Table              OUT NOCOPY    VARCHAR2,
      p_Interface_tbl         OUT NOCOPY  interface_tbl_type,
      p_common_key_name       OUT NOCOPY    VARCHAR2,
      cSelect_string          OUT NOCOPY    VARCHAR2,
      cFrom_string            OUT NOCOPY    VARCHAR2,
      cWhere_string           OUT NOCOPY    VARCHAR2,
      p_output_level          IN       VARCHAR2 DEFAULT NULL,
      cMapCode                IN       VARCHAR2 DEFAULT NULL);

   PROCEDURE write_to_ece_output(
      cTransaction_Type       IN       VARCHAR2,
      cCommunication_Method   IN       VARCHAR2,
      cInterface_Table        IN       VARCHAR2,
      p_Interface_tbl         IN       interface_tbl_type,
      iOutput_width           IN       INTEGER,
      iRun_id                 IN       INTEGER,
      p_common_key            IN       VARCHAR2);

   PROCEDURE find_pos(
      p_Interface_tbl         IN       Interface_tbl_type,
      cSearch_text            IN       VARCHAR2,
      nPos                    IN OUT NOCOPY  NUMBER);

   FUNCTION match_xref_conv_seq(
      p_gateway_tbl           IN       Interface_tbl_type,
      p_conversion_group      IN       NUMBER,
      p_sequence_num          IN       NUMBER,
      p_Pos                   OUT NOCOPY    NUMBER) RETURN BOOLEAN;

   FUNCTION match_xref_conv_seq(
      p_level                 IN       NUMBER,
      p_conversion_group      IN       NUMBER,
      p_sequence_num          IN       NUMBER,
      p_Pos                   OUT NOCOPY    NUMBER) RETURN BOOLEAN;

/*
   PROCEDURE match_data_loc_id(
      p_Interface_tbl         IN       interface_tbl_type,
      p_data_loc_id           IN       NUMBER,
      p_Pos                   OUT NOCOPY      NUMBER);
*/

   PROCEDURE match_interface_column_id(
      p_Interface_tbl         IN       interface_tbl_type,
      p_Interface_column_id   IN       NUMBER,
      p_Pos                   OUT NOCOPY     NUMBER);

   FUNCTION match_conversion_group_id(
      p_gateway_tbl           IN       interface_tbl_type,
      p_conversion_id         IN       NUMBER,
      p_sequence_num          IN       NUMBER,
      p_pos                   OUT NOCOPY     NUMBER) RETURN BOOLEAN;

   FUNCTION match_record_num(
      p_gateway_tbl           IN       interface_tbl_type,
      p_Record_num            IN       NUMBER,
      p_Pos                   OUT NOCOPY     NUMBER,
      p_total_unit            OUT NOCOPY     NUMBER) RETURN BOOLEAN;
/* Bug 1759234.
   Changed the acess modifier of the parameter ckey_tbl
   of procedure init_table to IN OUT to preserve  the
   value in ckey_tbl
*/

   PROCEDURE init_table(
      cTransaction_Type       IN       VARCHAR2,
      cInt_tbl_name           IN       VARCHAR2,
      cOutput_level           IN       VARCHAR2,
      bKey_exist              IN       BOOLEAN,
      cInterface_tbl          OUT NOCOPY     ece_flatfile_pvt.interface_tbl_type,
      cKey_tbl                IN OUT NOCOPY ece_flatfile_pvt.interface_tbl_type,
      cMapCode                IN       VARCHAR2 DEFAULT NULL);

   PROCEDURE define_interface_column_type(
      c                       IN       INTEGER,
      cCol                    IN       VARCHAR2,
      iCol_size               IN       INTEGER,
      p_tbl                   IN       ece_flatfile_pvt.interface_tbl_type);

   PROCEDURE assign_column_value_to_tbl(
      c                       IN       INTEGER,
      p_tbl                   IN OUT NOCOPY  ece_flatfile_pvt.interface_tbl_type);

   PROCEDURE assign_column_value_to_tbl(
      c                       IN       INTEGER,
      iCount                  IN       INTEGER,
      p_tbl                   IN OUT NOCOPY  ece_flatfile_pvt.interface_tbl_type,
      p_key_tbl               IN OUT NOCOPY  ece_flatfile_pvt.interface_tbl_type);

   FUNCTION pos_of(
      pInterface_Tbl          IN       ece_flatfile_pvt.interface_tbl_type,
      cCol_name               IN       VARCHAR2) RETURN NUMBER;

END ECE_FLATFILE_PVT;


 

/
