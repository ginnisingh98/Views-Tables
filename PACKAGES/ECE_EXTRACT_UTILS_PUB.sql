--------------------------------------------------------
--  DDL for Package ECE_EXTRACT_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_EXTRACT_UTILS_PUB" AUTHID CURRENT_USER AS
-- $Header: ECPEXTUS.pls 120.2 2005/09/29 11:38:58 arsriniv ship $
   g_maxcolwidth                 NUMBER         := 400;       -- ****** IMPORTANT ********
   g_transaction_date            VARCHAR2(35)   := 'TRANSACTION_DATE';
   g_pkg_name           CONSTANT VARCHAR2(30)   := 'ece_extract_utils_pub';
   g_file_name          CONSTANT VARCHAR2(12)   := 'ECPEXTUB.pls';

   TYPE source_rec_type IS RECORD(
      data_loc_id             NUMBER,
      table_name              VARCHAR2(50),
      column_name             VARCHAR2(50),
      base_table_name         VARCHAR2(50),
      base_column_name        VARCHAR2(50),
      xref_category_id        NUMBER,
      xref_key1_source_column VARCHAR2(50),
      xref_key2_source_column VARCHAR2(50),
      xref_key3_source_column VARCHAR2(50),
      xref_key4_source_column VARCHAR2(50),
      xref_key5_source_column VARCHAR2(50),
      data_type               VARCHAR2(50),
      data_length             NUMBER,
      int_val                 VARCHAR2(400),
      ext_val1                VARCHAR2(80),
      ext_val2                VARCHAR2(80),
      ext_val3                VARCHAR2(80),
      ext_val4                VARCHAR2(80),
      ext_val5                VARCHAR2(80));

   TYPE Source_tbl_type IS TABLE OF Source_rec_type
      INDEX BY BINARY_INTEGER;

   PROCEDURE select_clause(
      cTransaction_Type       IN       VARCHAR2,
      cCommunication_Method   IN       VARCHAR2,
      cInterface_Table        IN       VARCHAR2,
      p_source_tbl            IN       ece_flatfile_pvt.interface_tbl_type,
      cSelect_string          OUT NOCOPY      VARCHAR2,
      cFrom_string            OUT NOCOPY     VARCHAR2,
      cWhere_string           OUT NOCOPY     VARCHAR2);

   PROCEDURE insert_into_interface_tbl(
      iRun_id                 IN       NUMBER,
      cTransaction_Type       IN       VARCHAR2,
      cCommunication_Method   IN       VARCHAR2,
      cInterface_Table        IN       VARCHAR2,
      p_source_tbl            IN       ece_flatfile_pvt.Interface_tbl_type,
      p_foreign_key           IN       NUMBER);

   PROCEDURE insert_into_prod_interface(
      p_Interface_Table       IN       VARCHAR2,
      p_Insert_cur            IN OUT NOCOPY   INTEGER,
      p_apps_tbl              IN       ece_flatfile_pvt.Interface_tbl_type);

/*Bug 1854866
Assigned default values to the parameters
p_init_msg_list,p_simulate,p_commit,p_validation_level
of the procedure insert_prod_interface_pvt
since the default values are assigned to these parameters
in the package body
*/

   PROCEDURE insert_into_prod_interface_pvt(
      p_api_version_number    IN       NUMBER,
      p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false,
      p_simulate              IN       VARCHAR2 := fnd_api.g_false,
      p_commit                IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status         OUT   NOCOPY VARCHAR2,
      x_msg_count             OUT   NOCOPY NUMBER,
      x_msg_data              OUT   NOCOPY VARCHAR2,
      p_interface_table       IN       VARCHAR2,
      p_insert_cur            IN OUT  NOCOPY INTEGER,
      p_apps_tbl              IN       ece_flatfile_pvt.Interface_tbl_type);

   PROCEDURE find_pos(
      p_source_tbl            IN       ece_flatfile_pvt.Interface_tbl_type,
      p_in_text               IN       VARCHAR2,
      p_Pos                   IN OUT NOCOPY  NUMBER);

   FUNCTION pos_of(
      pInterface_tbl          IN       ece_flatfile_pvt.Interface_tbl_type,
      cCol_name               IN       VARCHAR2)
      RETURN NUMBER;

   -- 2823215
   PROCEDURE ext_get_value(
        l_plsql_tbl             IN       ece_flatfile_pvt.Interface_tbl_type,
        p_in_text               IN       VARCHAR2,
        p_Position              IN OUT NOCOPY   NUMBER,
        o_value           	OUT NOCOPY     varchar2);

   PROCEDURE ext_insert_value(
        l_plsql_tbl       IN OUT NOCOPY   ece_flatfile_pvt.Interface_tbl_type,
        p_position        IN      number,
        p_value           IN     varchar2);

END ece_extract_utils_pub;


 

/
