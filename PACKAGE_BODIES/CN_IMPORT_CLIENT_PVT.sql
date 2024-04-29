--------------------------------------------------------
--  DDL for Package Body CN_IMPORT_CLIENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMPORT_CLIENT_PVT" AS
/* $Header: cnvimpcb.pls 115.9 2002/11/21 21:13:39 hlchen ship $ */

-- Global variables and constants.
G_PKG_NAME        CONSTANT VARCHAR2(30) := 'CN_IMPORT_CLIENT_PVT';
G_DEBUG_FLAG      VARCHAR2(1)  := 'N';
G_COL_NUM         NUMBER := 40;
G_ARC_IMPORT_HEADER  CONSTANT VARCHAR2(30) := 'IMPH';

--
-- Private utility modules for this package
--
PROCEDURE Init_Col_Data (
  p_data                         IN      CN_IMPORT_PVT.char_data_set_type,
  p_start_index                  IN      NUMBER,
  p_end_index                    IN      NUMBER,
  p_insert_flag                  IN      VARCHAR2 := FND_API.G_FALSE, --TRUE for insertion
  p_col_data                     IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000
);

PROCEDURE Append_More_Data (
  p_str_col_names                IN      CN_IMPORT_PVT.char_data_set_type,
  p_str_data                     IN      CN_IMPORT_PVT.char_data_set_type,
  p_num_col_names                IN      CN_IMPORT_PVT.char_data_set_type,
  p_num_data                     IN      CN_IMPORT_PVT.num_data_set_type,
  p_col_clause                   IN OUT NOCOPY  VARCHAR2,
  p_val_clause                   IN OUT NOCOPY  VARCHAR2
);

PROCEDURE Init_All_Col_Data (
  p_start_index                  IN      NUMBER,
  p_col_count                    IN      NUMBER,
  p_row_count                    IN      NUMBER,
  p_data                         IN      CN_IMPORT_PVT.char_data_set_type,
  p_insert_flag                  IN      VARCHAR2 := FND_API.G_FALSE, --TRUE for insertion
  p_col1_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col2_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col3_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col4_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col5_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col6_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col7_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col8_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col9_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col10_data                   IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

  p_col11_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col12_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col13_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col14_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col15_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col16_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col17_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col18_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col19_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col20_data                   IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

  p_col21_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col22_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col23_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col24_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col25_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col26_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col27_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col28_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col29_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col30_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

  p_col31_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col32_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col33_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col34_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col35_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col36_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col37_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col38_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col39_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col40_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

  p_act_col_num                  OUT NOCOPY NUMBER

);

PROCEDURE Insert_To_DB (
  p_prim_keys                    IN      JTF_NUMBER_TABLE,
  p_col_count                    IN      NUMBER, --actual column count
  p_row_count                    IN      NUMBER,

  p_tab_name_clause              IN      VARCHAR2,
  p_col_clause                   IN      VARCHAR2,
  p_value_clause                 IN      VARCHAR2,
  p_col_names                    IN      CN_IMPORT_PVT.char_data_set_type,
  p_imp_header_id                IN    NUMBER,
  p_import_type_code             IN    VARCHAR2,

  p_col1_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col2_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col3_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col4_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col5_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col6_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col7_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col8_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col9_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col10_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col11_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col12_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col13_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col14_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col15_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col16_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col17_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col18_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col19_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col20_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col21_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col22_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col23_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col24_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col25_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col26_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col27_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col28_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col29_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col30_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col31_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col32_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col33_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col34_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col35_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col36_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col37_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col38_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col39_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col40_data                   IN      JTF_VARCHAR2_TABLE_2000,

  x_return_status              OUT NOCOPY       VARCHAR2,
  x_msg_count                  OUT NOCOPY       NUMBER,
  x_msg_data                   OUT NOCOPY       VARCHAR2
);

PROCEDURE Update_DB (
  p_prim_keys                    IN      JTF_NUMBER_TABLE,
  p_col_count                    IN      NUMBER,
  p_row_count                    IN      NUMBER,

  p_tab_name_name                IN      VARCHAR2,
  p_col_names                    IN      CN_IMPORT_PVT.char_data_set_type,
  p_col_start_count              IN      NUMBER,

  p_col1_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col2_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col3_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col4_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col5_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col6_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col7_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col8_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col9_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col10_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col11_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col12_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col13_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col14_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col15_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col16_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col17_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col18_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col19_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col20_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col21_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col22_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col23_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col24_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col25_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col26_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col27_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col28_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col29_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col30_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col31_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col32_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col33_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col34_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col35_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col36_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col37_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col38_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col39_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col40_data                   IN      JTF_VARCHAR2_TABLE_2000,

  x_return_status                OUT NOCOPY       VARCHAR2,
  x_msg_count                    OUT NOCOPY       NUMBER,
  x_msg_data                     OUT NOCOPY       VARCHAR2
);
--- End forward modules

-- PROCEDURE
--     Insert_Data
--
-- PURPOSE
--     The procedure insert a collection of data into a table whose name is
--     specified by the "p_table_name" field. It uses native dynamic SQL to
--     bulk insert records using binding tables.
--     p_table_name must be a view on top of cn_imp_lines
--
--     The "p_col_names" field contains a collection of the column names.
--     The "p_data" contains all data needed to be inserted, assuming all data
--     types are "VARCHAR2". For example, if the data to be inserted are the
--     followings:
--
--     Row Number   1        2        3        4
--     Column1      Frank    Smith    Scott    Marry
--     Column2      Amos     Anderson Baber    Beier
--     Column3      75039    77002    23060    03062
--
--     The data is stored in the "p_data" as: "Frank", "Smith", "Scott", "Marry",
--     "Amos", "Anderson", "Baber", "Beier", "75039", "77002", "23060", "03062".
--     Both "p_col_names" and "p_data" are consecutive.
--     we need these fields or not. The "p_row_count" field is redundant since
--     we do not want to invoke the "COUNT" on "p_data" since this table is
--     supposed to be huge.
--
-- NOTES

PROCEDURE Insert_Data
  (p_api_version                 IN    NUMBER,
   p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
   p_commit                      IN    VARCHAR2 := FND_API.G_FALSE,
   p_imp_header_id               IN    NUMBER,
   p_import_type_code            IN    VARCHAR2,
   p_table_name                  IN    VARCHAR2,
   p_col_names                   IN    CN_IMPORT_PVT.char_data_set_type,
   p_data                        IN    CN_IMPORT_PVT.char_data_set_type,
   p_row_count                   IN    NUMBER,
   x_return_status               OUT NOCOPY   VARCHAR2,
   x_msg_count                   OUT NOCOPY   NUMBER,
   x_msg_data                    OUT NOCOPY   VARCHAR2
   ) IS

  --
  -- Standard API information constants.
  --
  L_API_VERSION       CONSTANT NUMBER := 1.0;
  L_API_NAME          CONSTANT VARCHAR2(30) := 'Insert_Data';
  L_FULL_NAME         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

  --
  -- "FORALL i IN 1 .. :row_count
  --  INSERT INTO CN_IMP_LINES"
  --
  l_tab_name_clause     VARCHAR2(8000) := 'BEGIN FORALL i IN 1 .. :row_count
                                            INSERT INTO ';

  --
  -- "(IMP_LINE_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY)"
  --
  l_col_clause        VARCHAR2(8000) := ' (';

  --
  -- "VALUES (  :p_tab1(i), :p_tab2(i))
  --
  l_value_clause      VARCHAR2(8000) := ' VALUES (';

  l_col_count         NUMBER;
  l_orig_col_count    NUMBER;
  l_start_index       NUMBER := 1;
  l_act_col_count     NUMBER; --actual col count for each initialization

  l_prim_keys         JTF_NUMBER_TABLE := JTF_NUMBER_TABLE(0);
  l_curr_seq_num     NUMBER;
  l_start_seq_num     NUMBER;

  --
  -- Just pick up data for 10 column data
  --
  l_col1_data          JTF_VARCHAR2_TABLE_2000;
  l_col2_data          JTF_VARCHAR2_TABLE_2000;
  l_col3_data          JTF_VARCHAR2_TABLE_2000;
  l_col4_data          JTF_VARCHAR2_TABLE_2000;
  l_col5_data          JTF_VARCHAR2_TABLE_2000;
  l_col6_data          JTF_VARCHAR2_TABLE_2000;
  l_col7_data          JTF_VARCHAR2_TABLE_2000;
  l_col8_data          JTF_VARCHAR2_TABLE_2000;
  l_col9_data          JTF_VARCHAR2_TABLE_2000;
  l_col10_data         JTF_VARCHAR2_TABLE_2000;

  l_col11_data         JTF_VARCHAR2_TABLE_2000;
  l_col12_data         JTF_VARCHAR2_TABLE_2000;
  l_col13_data         JTF_VARCHAR2_TABLE_2000;
  l_col14_data         JTF_VARCHAR2_TABLE_2000;
  l_col15_data         JTF_VARCHAR2_TABLE_2000;
  l_col16_data         JTF_VARCHAR2_TABLE_2000;
  l_col17_data         JTF_VARCHAR2_TABLE_2000;
  l_col18_data         JTF_VARCHAR2_TABLE_2000;
  l_col19_data         JTF_VARCHAR2_TABLE_2000;
  l_col20_data         JTF_VARCHAR2_TABLE_2000;

  l_col21_data         JTF_VARCHAR2_TABLE_2000;
  l_col22_data         JTF_VARCHAR2_TABLE_2000;
  l_col23_data         JTF_VARCHAR2_TABLE_2000;
  l_col24_data         JTF_VARCHAR2_TABLE_2000;
  l_col25_data         JTF_VARCHAR2_TABLE_2000;
  l_col26_data         JTF_VARCHAR2_TABLE_2000;
  l_col27_data         JTF_VARCHAR2_TABLE_2000;
  l_col28_data         JTF_VARCHAR2_TABLE_2000;
  l_col29_data         JTF_VARCHAR2_TABLE_2000;
  l_col30_data         JTF_VARCHAR2_TABLE_2000;

  l_col31_data         JTF_VARCHAR2_TABLE_2000;
  l_col32_data         JTF_VARCHAR2_TABLE_2000;
  l_col33_data         JTF_VARCHAR2_TABLE_2000;
  l_col34_data         JTF_VARCHAR2_TABLE_2000;
  l_col35_data         JTF_VARCHAR2_TABLE_2000;
  l_col36_data         JTF_VARCHAR2_TABLE_2000;
  l_col37_data         JTF_VARCHAR2_TABLE_2000;
  l_col38_data         JTF_VARCHAR2_TABLE_2000;
  l_col39_data         JTF_VARCHAR2_TABLE_2000;
  l_col40_data         JTF_VARCHAR2_TABLE_2000;
BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Insert_Data;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
   cn_message_pkg.debug('Insert Data : Start Inserting Data');

   l_orig_col_count := p_col_names.COUNT;

   IF l_orig_col_count < 1 THEN
      cn_message_pkg.set_error(l_api_name,'Column count < 1');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   cn_message_pkg.debug('Insert Data : Start Copy Data from p_data');

   -- copy data from p_data into local variables l_col*_data
   Init_All_Col_Data
     (p_start_index                  => 1,
      p_col_count                    => l_orig_col_count,
      p_row_count                    => p_row_count,
      p_data                         => p_data,
      p_col1_data                    => l_col1_data,
      p_col2_data                    => l_col2_data,
      p_col3_data                    => l_col3_data,
      p_col4_data                    => l_col4_data,
      p_col5_data                    => l_col5_data,
      p_col6_data                    => l_col6_data,
      p_col7_data                    => l_col7_data,
      p_col8_data                    => l_col8_data,
      p_col9_data                    => l_col9_data,
      p_col10_data                   => l_col10_data,
      p_col11_data                   => l_col11_data,
      p_col12_data                   => l_col12_data,
      p_col13_data                   => l_col13_data,
      p_col14_data                   => l_col14_data,
      p_col15_data                   => l_col15_data,
     p_col16_data                   => l_col16_data,
     p_col17_data                   => l_col17_data,
     p_col18_data                   => l_col18_data,
     p_col19_data                   => l_col19_data,
     p_col20_data                   => l_col20_data,
     p_col21_data                   => l_col21_data,
     p_col22_data                   => l_col22_data,
     p_col23_data                   => l_col23_data,
     p_col24_data                   => l_col24_data,
     p_col25_data                   => l_col25_data,
     p_col26_data                   => l_col26_data,
     p_col27_data                   => l_col27_data,
     p_col28_data                   => l_col28_data,
     p_col29_data                   => l_col29_data,
     p_col30_data                   => l_col30_data,
     p_col31_data                   => l_col31_data,
     p_col32_data                   => l_col32_data,
     p_col33_data                   => l_col33_data,
     p_col34_data                   => l_col34_data,
     p_col35_data                   => l_col35_data,
     p_col36_data                   => l_col36_data,
     p_col37_data                   => l_col37_data,
     p_col38_data                   => l_col38_data,
     p_col39_data                   => l_col39_data,
     p_col40_data                   => l_col40_data,
     p_insert_flag                  => FND_API.G_TRUE,
     p_act_col_num                  => l_act_col_count);

   cn_message_pkg.debug('Insert Data : Finish Copy Data from p_data');

   -- get table name
   l_tab_name_clause := l_tab_name_clause || p_table_name;

   -- primary key column
   l_col_clause := l_col_clause || 'IMP_LINE_ID' || ',';
   l_value_clause := l_value_clause || ':p_keys(i),';

   -- WHO columns , use bind variable
   l_col_clause := l_col_clause || 'LAST_UPDATE_DATE,';
   l_value_clause := l_value_clause || ':l_last_update_date, ';

   l_col_clause := l_col_clause || 'LAST_UPDATED_BY,';
   l_value_clause := l_value_clause || ':l_last_updated_by, ';

   l_col_clause := l_col_clause || ' CREATION_DATE,';
   l_value_clause := l_value_clause || ':l_creation_date, ';

   l_col_clause := l_col_clause || 'CREATED_BY,';
   l_value_clause := l_value_clause || ':l_created_by, ';

   l_col_clause := l_col_clause || 'LAST_UPDATE_LOGIN,';
   l_value_clause := l_value_clause || ':l_last_update_login, ';

   l_col_clause := l_col_clause || 'OBJECT_VERSION_NUMBER,';
   l_value_clause := l_value_clause || ':l_obj_ver_num, ';

   -- imp_header_id,import_type_code,status_code column
   l_col_clause := l_col_clause || 'IMP_HEADER_ID,';
   l_value_clause := l_value_clause || ':p_imp_header_id, ';

   l_col_clause := l_col_clause || 'IMPORT_TYPE_CODE,';
   l_value_clause := l_value_clause || ':p_import_type_code, ';

   l_col_clause := l_col_clause || 'STATUS_CODE,';
   l_value_clause := l_value_clause || ':p_status, ';

   -- Build sequence collection
   -- initialize "l_prim_keys" table
   l_prim_keys.EXTEND(p_row_count, 1);
   FOR i IN 1 .. p_row_count LOOP
      SELECT CN_IMP_LINES_S.NEXTVAL
	INTO l_prim_keys(i) FROM dual;
   END LOOP;

   cn_message_pkg.debug('Insert Data : Start insert into DB');

   -- insert into DB
   Insert_To_DB
     (p_prim_keys            => l_prim_keys,
      p_col_count            => l_act_col_count,
      p_row_count            => p_row_count,
      p_tab_name_clause      => l_tab_name_clause,
      p_col_clause           => l_col_clause,
      p_value_clause         => l_value_clause,
      p_col_names            => p_col_names,
      p_imp_header_id        => p_imp_header_id,
      p_import_type_code     => p_import_type_code,
      p_col1_data            => l_col1_data,
      p_col2_data            => l_col2_data,
      p_col3_data            => l_col3_data,
      p_col4_data            => l_col4_data,
      p_col5_data            => l_col5_data,
      p_col6_data            => l_col6_data,
      p_col7_data            => l_col7_data,
      p_col8_data            => l_col8_data,
      p_col9_data            => l_col9_data,
      p_col10_data           => l_col10_data,
      p_col11_data           => l_col11_data,
      p_col12_data           => l_col12_data,
      p_col13_data           => l_col13_data,
      p_col14_data           => l_col14_data,
      p_col15_data           => l_col15_data,
     p_col16_data           => l_col16_data,
     p_col17_data           => l_col17_data,
     p_col18_data           => l_col18_data,
     p_col19_data           => l_col19_data,
     p_col20_data           => l_col20_data,
     p_col21_data           => l_col21_data,
     p_col22_data           => l_col22_data,
     p_col23_data           => l_col23_data,
     p_col24_data           => l_col24_data,
     p_col25_data           => l_col25_data,
     p_col26_data           => l_col26_data,
     p_col27_data           => l_col27_data,
     p_col28_data           => l_col28_data,
     p_col29_data           => l_col29_data,
     p_col30_data           => l_col30_data,
     p_col31_data           => l_col31_data,
     p_col32_data           => l_col32_data,
     p_col33_data           => l_col33_data,
     p_col34_data           => l_col34_data,
     p_col35_data           => l_col35_data,
     p_col36_data           => l_col36_data,
     p_col37_data           => l_col37_data,
     p_col38_data           => l_col38_data,
     p_col39_data           => l_col39_data,
     p_col40_data           => l_col40_data,
     x_return_status        => x_return_status,
     x_msg_count            => x_msg_count,
     x_msg_data             => x_msg_data);

  -- If any errors happen abort API.
   IF x_return_status  <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   cn_message_pkg.debug('Insert Data : Finish insert into DB');

   l_col_count := l_act_col_count;

  -- Still have more columns
  WHILE l_col_count < l_orig_col_count
    LOOP
       cn_message_pkg.debug('Insert Data : Copy more data from p_data.');

       Init_All_Col_Data
	 (p_start_index                  => l_col_count * p_row_count + 1,
	  p_col_count                    => l_orig_col_count - l_col_count,
	  p_row_count                    => p_row_count,
	  p_data                         => p_data,
	  p_col1_data                    => l_col1_data,
	  p_col2_data                    => l_col2_data,
	  p_col3_data                    => l_col3_data,
	  p_col4_data                    => l_col4_data,
	  p_col5_data                    => l_col5_data,
	  p_col6_data                    => l_col6_data,
	  p_col7_data                    => l_col7_data,
	  p_col8_data                    => l_col8_data,
	  p_col9_data                    => l_col9_data,
	  p_col10_data                   => l_col10_data,
	  p_col11_data                   => l_col11_data,
	  p_col12_data                   => l_col12_data,
	  p_col13_data                   => l_col13_data,
	  p_col14_data                   => l_col14_data,
	  p_col15_data                   => l_col15_data,
	  p_col16_data                   => l_col16_data,
	 p_col17_data                   => l_col17_data,
	 p_col18_data                   => l_col18_data,
	 p_col19_data                   => l_col19_data,
	 p_col20_data                   => l_col20_data,
	 p_col21_data                   => l_col21_data,
	 p_col22_data                   => l_col22_data,
	 p_col23_data                   => l_col23_data,
	 p_col24_data                   => l_col24_data,
	 p_col25_data                   => l_col25_data,
	 p_col26_data                   => l_col26_data,
	 p_col27_data                   => l_col27_data,
	 p_col28_data                   => l_col28_data,
	 p_col29_data                   => l_col29_data,
	 p_col30_data                   => l_col30_data,
	 p_col31_data                   => l_col31_data,
	 p_col32_data                   => l_col32_data,
	 p_col33_data                   => l_col33_data,
	 p_col34_data                   => l_col34_data,
	 p_col35_data                   => l_col35_data,
	 p_col36_data                   => l_col36_data,
	 p_col37_data                   => l_col37_data,
	 p_col38_data                   => l_col38_data,
	 p_col39_data                   => l_col39_data,
	 p_col40_data                   => l_col40_data,
	 p_insert_flag                  => FND_API.G_FALSE,
	 p_act_col_num                  => l_act_col_count);

       cn_message_pkg.debug('Insert Data : Update more data from p_data.');

       Update_DB
	 (p_prim_keys                    => l_prim_keys,
	  p_col_count                    => l_act_col_count,
	  p_row_count                    => p_row_count,

	  p_tab_name_name                => p_table_name,
	  p_col_names                    => p_col_names,
	  p_col_start_count              => l_col_count,

	  p_col1_data                    => l_col1_data,
	  p_col2_data                    => l_col2_data,
	  p_col3_data                    => l_col3_data,
	  p_col4_data                    => l_col4_data,
	  p_col5_data                    => l_col5_data,
	  p_col6_data                    => l_col6_data,
	  p_col7_data                    => l_col7_data,
	  p_col8_data                    => l_col8_data,
	  p_col9_data                    => l_col9_data,
	  p_col10_data                   => l_col10_data,
	  p_col11_data                   => l_col11_data,
	  p_col12_data                   => l_col12_data,
	  p_col13_data                   => l_col13_data,
	 p_col14_data                   => l_col14_data,
	 p_col15_data                   => l_col15_data,
	 p_col16_data                   => l_col16_data,
	 p_col17_data                   => l_col17_data,
	 p_col18_data                   => l_col18_data,
	 p_col19_data                   => l_col19_data,
	 p_col20_data                   => l_col20_data,
	 p_col21_data                   => l_col21_data,
	 p_col22_data                   => l_col22_data,
	 p_col23_data                   => l_col23_data,
	 p_col24_data                   => l_col24_data,
	 p_col25_data                   => l_col25_data,
	 p_col26_data                   => l_col26_data,
	 p_col27_data                   => l_col27_data,
	 p_col28_data                   => l_col28_data,
	 p_col29_data                   => l_col29_data,
	 p_col30_data                   => l_col30_data,
	 p_col31_data                   => l_col31_data,
	 p_col32_data                   => l_col32_data,
	 p_col33_data                   => l_col33_data,
	 p_col34_data                   => l_col34_data,
	 p_col35_data                   => l_col35_data,
	 p_col36_data                   => l_col36_data,
	 p_col37_data                   => l_col37_data,
	 p_col38_data                   => l_col38_data,
	 p_col39_data                   => l_col39_data,
	 p_col40_data                   => l_col40_data,

	 x_return_status                => x_return_status,
	 x_msg_count                    => x_msg_count,
	 x_msg_data                     => x_msg_data
	 );

       -- If any errors happen abort API.
      IF x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_col_count := l_col_count + l_act_col_count;

      cn_message_pkg.debug('Insert Data : Finish update to DB.');

    END LOOP;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_Data;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get
	(p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_Data;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
	 );
   WHEN OTHERS THEN
      ROLLBACK TO Insert_Data;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      cn_message_pkg.set_error(l_api_name,'Unexpected Error.');
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END Insert_Data;


-- NAME
--     Append_More_Data
--
-- PURPOSE
-- NOTES
--
-- HISTORY
--
PROCEDURE Append_More_Data (
  p_str_col_names                IN      CN_IMPORT_PVT.char_data_set_type,
  p_str_data                     IN      CN_IMPORT_PVT.char_data_set_type,
  p_num_col_names                IN      CN_IMPORT_PVT.char_data_set_type,
  p_num_data                     IN      CN_IMPORT_PVT.num_data_set_type,
  p_col_clause                   IN OUT NOCOPY  VARCHAR2,
  p_val_clause                   IN OUT NOCOPY  VARCHAR2
)
IS
BEGIN
  FOR i IN p_str_col_names.FIRST .. p_str_col_names.LAST
  LOOP
    p_col_clause := p_col_clause || p_str_col_names(i) || ', ';
    p_val_clause := p_val_clause || '''' || p_str_data(i) || ''', ';
  END LOOP;

  FOR j IN p_num_col_names.FIRST .. p_num_col_names.LAST
  LOOP
    p_col_clause := p_col_clause || p_num_col_names(j) || ', ';
    p_val_clause := p_val_clause || '''' || p_num_data(j) || ''', ';
  END LOOP;
END Append_More_Data;


-- NAME
--     Init_Col_Data
--
-- PURPOSE
--     Copy data from "p_data" to "p_col_data"
-- NOTES
--
-- HISTORY
--
PROCEDURE Init_Col_Data (
  p_data                         IN      CN_IMPORT_PVT.char_data_set_type,
  p_start_index                  IN      NUMBER,
  p_end_index                    IN      NUMBER,
  p_insert_flag                  IN      VARCHAR2 := FND_API.G_FALSE, --TRUE for insertion
  p_col_data                     IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000
)
IS
   l_count NUMBER := 1;
BEGIN
   IF p_insert_flag = FND_API.G_TRUE THEN
      p_col_data := JTF_VARCHAR2_TABLE_2000 ('t');
      p_col_data.EXTEND (p_end_index - p_start_index, 1);
   END IF;
   FOR i IN p_start_index .. p_end_index - 1 LOOP
      p_col_data (l_count) := trim(p_data(i));
      l_count := l_count + 1;
   END LOOP;
END Init_Col_Data;

-- NAME
--     Init_All_Col_Data
--
-- PURPOSE
--     Initialize all columns
-- NOTES
--
-- HISTORY
--
PROCEDURE Init_All_Col_Data
  (p_start_index                  IN      NUMBER,
   p_col_count                    IN      NUMBER,
   p_row_count                    IN      NUMBER,
   p_data                         IN      CN_IMPORT_PVT.char_data_set_type,
   p_insert_flag                  IN      VARCHAR2 := FND_API.G_FALSE, --TRUE for insertion
   p_col1_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col2_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col3_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col4_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col5_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col6_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col7_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col8_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col9_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
   p_col10_data                   IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

   p_col11_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col12_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col13_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col14_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col15_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col16_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col17_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col18_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col19_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col20_data                   IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

  p_col21_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col22_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col23_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col24_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col25_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col26_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col27_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col28_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col29_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col30_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

  p_col31_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col32_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col33_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col34_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col35_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col36_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col37_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col38_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col39_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,
  p_col40_data                    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_2000,

  p_act_col_num                  OUT NOCOPY NUMBER

  )
  IS
     l_start_index NUMBER;
     l_index NUMBER := 1;
BEGIN
   l_start_index := p_start_index;

   IF p_col_count >= G_COL_NUM THEN
      p_act_col_num := G_COL_NUM;
    ELSE
      p_act_col_num := p_col_count;
   END IF;

   IF p_col_count > 0 THEN
      Init_Col_Data
	(p_data                         => p_data,
	 p_start_index                  => l_start_index,
	 p_end_index                    => l_start_index + p_row_count,
	 p_col_data                     => p_col1_data,
	 p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
   END IF;
  IF p_col_count > 1 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col2_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 2 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col3_data,
      p_insert_flag                  => p_insert_flag);
  l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 3 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col4_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 4 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col5_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 5 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col6_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 6 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col7_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 7 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col8_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 8 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col9_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 9 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col10_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;

  IF p_col_count > 10 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col11_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 11 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col12_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 12 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col13_data,
      p_insert_flag                  => p_insert_flag);
  l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 13 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col14_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 14 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col15_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 15 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col16_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 16 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col17_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 17 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col18_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 18 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col19_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 19 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col20_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;

  IF p_col_count > 20 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col21_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 21 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col22_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 22 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col23_data,
      p_insert_flag                  => p_insert_flag);
  l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 23 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col24_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 24 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col25_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 25 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col26_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 26 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col27_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 27 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col28_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 28 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col29_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 29 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col30_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;

  IF p_col_count > 30 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col31_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 31 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col32_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 32 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col33_data,
      p_insert_flag                  => p_insert_flag);
  l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 33 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col34_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 34 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col35_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 35 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col36_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 36 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col37_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 37 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col38_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 38 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col39_data,
      p_insert_flag                  => p_insert_flag);
      l_start_index := l_start_index + p_row_count;
  END IF;
  IF p_col_count > 39 THEN
    Init_Col_Data (
      p_data                         => p_data,
      p_start_index                  => l_start_index,
      p_end_index                    => l_start_index + p_row_count,
      p_col_data                     => p_col40_data,
      p_insert_flag                  => p_insert_flag);
    l_start_index := l_start_index + p_row_count;
  END IF;
END Init_All_Col_Data;

-- NAME
--     Insert_To_DB
--
-- PURPOSE
--     Insert data to database
-- NOTES
--
-- HISTORY
--
PROCEDURE Insert_To_DB (
  p_prim_keys                    IN      JTF_NUMBER_TABLE,
  p_col_count                    IN      NUMBER, --actual column count
  p_row_count                    IN      NUMBER,

  p_tab_name_clause              IN      VARCHAR2,
  p_col_clause                   IN      VARCHAR2,
  p_value_clause                 IN      VARCHAR2,
  p_col_names                    IN      CN_IMPORT_PVT.char_data_set_type,
  p_imp_header_id                IN    NUMBER,
  p_import_type_code             IN    VARCHAR2,

  p_col1_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col2_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col3_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col4_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col5_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col6_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col7_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col8_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col9_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col10_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col11_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col12_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col13_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col14_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col15_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col16_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col17_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col18_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col19_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col20_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col21_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col22_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col23_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col24_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col25_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col26_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col27_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col28_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col29_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col30_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col31_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col32_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col33_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col34_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col35_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col36_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col37_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col38_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col39_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col40_data                   IN      JTF_VARCHAR2_TABLE_2000,
  x_return_status              OUT NOCOPY       VARCHAR2,
  x_msg_count                  OUT NOCOPY       NUMBER,
  x_msg_data                   OUT NOCOPY       VARCHAR2
)
IS

  --
  -- Standard API information constants.
  --
  L_API_VERSION        CONSTANT NUMBER := 1.0;
  L_API_NAME           CONSTANT VARCHAR2(30) := 'INSERT_TO_DB';
  L_FULL_NAME                            CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

  l_col_clause         VARCHAR2(8000);
  l_value_clause       VARCHAR2(8000);
  l_col_count          NUMBER := p_col_count;
  l_index              NUMBER := 1;

  -- only calculate system date once
  l_date              DATE    := SYSDATE;
  l_user_id           NUMBER  := FND_GLOBAL.User_ID;
  l_login_id          NUMBER  := FND_GLOBAL.Login_ID;
  l_objvernum         NUMBER  := 1;
  l_status             cn_imp_lines.status_code%TYPE := 'STAGE';

BEGIN

  IF p_col_count >= G_COL_NUM THEN
    l_col_count := G_COL_NUM;
  END IF;

  l_col_clause         := p_col_clause;
  l_value_clause       := p_value_clause;

  WHILE l_index < l_col_count
  LOOP
    l_col_clause := l_col_clause || p_col_names(l_index) || ',';
    l_value_clause := l_value_clause || ':val' || l_index || '(i),';
    l_index := l_index + 1;
  END LOOP;

  l_col_clause := l_col_clause || p_col_names( l_col_count) || ') ';
  l_value_clause := l_value_clause || ':val' || l_col_count || '(i)); END;';

  cn_message_pkg.debug('Insert TO DB : ' || p_tab_name_clause );
  cn_message_pkg.debug('Insert TO DB : ' || l_col_clause);
  cn_message_pkg.debug('Insert TO DB : ' || l_value_clause);

  --
  -- Done for all command
  --
  IF l_col_count = 1 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data;
   ELSIF l_col_count = 2 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data;
   ELSIF l_col_count = 3 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data;
   ELSIF l_col_count = 4 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data;
   ELSIF l_col_count = 5 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data;
   ELSIF l_col_count = 6 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data;
   ELSIF l_col_count = 7 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data;
   ELSIF l_col_count = 8 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data;
   ELSIF l_col_count = 9 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data;
   ELSIF l_col_count = 10 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data;
   ELSIF l_col_count = 11 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data;
   ELSIF l_col_count = 12 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data;
   ELSIF l_col_count = 13 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data;
   ELSIF l_col_count = 14 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data;
   ELSIF l_col_count = 15 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data;
   ELSIF l_col_count = 16 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data;
   ELSIF l_col_count = 17 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data;
   ELSIF l_col_count = 18 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data;
   ELSIF l_col_count = 19 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data;
   ELSIF l_col_count = 20 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data;
   ELSIF l_col_count = 21 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data;
   ELSIF l_col_count = 22 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data;
   ELSIF l_col_count = 23 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data;
   ELSIF l_col_count = 24 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data;
   ELSIF l_col_count = 25 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data;
   ELSIF l_col_count = 26 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data;
   ELSIF l_col_count = 27 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data;
   ELSIF l_col_count = 28 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data;
   ELSIF l_col_count = 29 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data;
   ELSIF l_col_count = 30 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data;
   ELSIF l_col_count = 31 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data;
   ELSIF l_col_count = 32 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data;
   ELSIF l_col_count = 33 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data;
   ELSIF l_col_count = 34 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data,
       p_col34_data;
   ELSIF l_col_count = 35 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data,
       p_col34_data, p_col35_data;
   ELSIF l_col_count = 36 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data,
       p_col34_data, p_col35_data, p_col36_data;
   ELSIF l_col_count = 37 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data,
       p_col34_data, p_col35_data, p_col36_data, p_col37_data;
   ELSIF l_col_count = 38 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data,
       p_col34_data, p_col35_data, p_col36_data, p_col37_data, p_col38_data;
   ELSIF l_col_count = 39 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum, p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data,
       p_col34_data, p_col35_data, p_col36_data, p_col37_data, p_col38_data,
       p_col39_data;
   ELSIF l_col_count = 40 THEN
     EXECUTE IMMEDIATE
       p_tab_name_clause || l_col_clause  || l_value_clause
       USING p_row_count, p_prim_keys, l_date, l_user_id, l_date, l_user_id,
       l_login_id, l_objvernum , p_imp_header_id, p_import_type_code, l_status,
       p_col1_data, p_col2_data, p_col3_data,
       p_col4_data, p_col5_data, p_col6_data, p_col7_data, p_col8_data,
       p_col9_data, p_col10_data, p_col11_data, p_col12_data, p_col13_data,
       p_col14_data, p_col15_data, p_col16_data, p_col17_data, p_col18_data,
       p_col19_data, p_col20_data, p_col21_data, p_col22_data, p_col23_data,
       p_col24_data, p_col25_data, p_col26_data, p_col27_data, p_col28_data,
       p_col29_data, p_col30_data, p_col31_data, p_col32_data, p_col33_data,
       p_col34_data, p_col35_data, p_col36_data, p_col37_data, p_col38_data,
       p_col39_data, p_col40_data;
  END IF;


   -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
    (p_count           =>    x_msg_count,
     p_data            =>    x_msg_data,
     p_encoded         =>    FND_API.G_FALSE
     );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      cn_message_pkg.set_error(l_api_name,'Unexpected Error.');
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Insert_To_DB;

-- NAME
--     Update_DB
--
-- PURPOSE
--     Inser more data to DB by updating the existing rows inserted
-- NOTES
--
-- HISTORY
--
PROCEDURE Update_DB (
  p_prim_keys                    IN      JTF_NUMBER_TABLE,
  p_col_count                    IN      NUMBER,
  p_row_count                    IN      NUMBER,

  p_tab_name_name                IN      VARCHAR2,
  p_col_names                    IN      CN_IMPORT_PVT.char_data_set_type,
  p_col_start_count              IN      NUMBER,

  p_col1_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col2_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col3_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col4_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col5_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col6_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col7_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col8_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col9_data                    IN      JTF_VARCHAR2_TABLE_2000,
  p_col10_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col11_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col12_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col13_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col14_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col15_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col16_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col17_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col18_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col19_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col20_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col21_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col22_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col23_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col24_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col25_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col26_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col27_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col28_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col29_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col30_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col31_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col32_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col33_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col34_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col35_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col36_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col37_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col38_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col39_data                   IN      JTF_VARCHAR2_TABLE_2000,
  p_col40_data                   IN      JTF_VARCHAR2_TABLE_2000,

  x_return_status                OUT NOCOPY     VARCHAR2,
  x_msg_count                    OUT NOCOPY     NUMBER,
  x_msg_data                     OUT NOCOPY     VARCHAR2
)
IS

   --
   -- Standard API information constants.
   --
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'UPDATE_DB';
   L_FULL_NAME                            CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

   l_update_sql         VARCHAR2(8000) := 'BEGIN FORALL i IN 1 .. :row_count UPDATE ';
   l_col_count          NUMBER;
   l_index              NUMBER := 1;
BEGIN

  l_update_sql := l_update_sql || p_tab_name_name || ' SET ';

  --
  -- max 40 columns
  --
  IF p_col_count <= G_COL_NUM THEN
    l_col_count := p_col_count;
  ELSE
    l_col_count := G_COL_NUM;
  END IF;

  WHILE l_index < l_col_count  LOOP
     l_update_sql := l_update_sql || p_col_names (p_col_start_count + l_index)
       || '=:val' || l_index || '(i), ';
     l_index := l_index + 1;
  END LOOP;

  l_update_sql := l_update_sql || p_col_names (p_col_start_count + l_index)
    || '= :val' || l_index || '(i) ';

  l_update_sql := l_update_sql || ' WHERE IMP_LINE_ID = :p_keys(i); END;';

  cn_message_pkg.debug('Update TO DB : ' || l_update_sql );

  --
  -- Done for all command
  --
  IF l_col_count = 1 THEN
    EXECUTE IMMEDIATE
      l_update_sql
    USING p_row_count, p_col1_data, p_prim_keys;
  ELSIF l_col_count = 2 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_prim_keys;
  ELSIF l_col_count = 3 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_prim_keys;
  ELSIF l_col_count = 4 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
        p_prim_keys;
  ELSIF l_col_count = 5 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_prim_keys;
  ELSIF l_col_count = 6 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
        p_col5_data, p_col6_data, p_prim_keys;
  ELSIF l_col_count = 7 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
        p_col5_data, p_col6_data, p_col7_data, p_prim_keys;
  ELSIF l_col_count = 8 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
        p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_prim_keys;
  ELSIF l_col_count = 9 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
        p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
        p_prim_keys;
  ELSIF l_col_count = 10 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_prim_keys;
  ELSIF l_col_count = 11 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_prim_keys;
  ELSIF l_col_count = 12 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_prim_keys;
  ELSIF l_col_count = 13 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data,p_prim_keys;
  ELSIF l_col_count = 14 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_prim_keys;
  ELSIF l_col_count = 15 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_prim_keys;
  ELSIF l_col_count = 16 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_prim_keys;
  ELSIF l_col_count = 17 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_prim_keys;
  ELSIF l_col_count = 18 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_prim_keys;
  ELSIF l_col_count = 19 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_prim_keys;
  ELSIF l_col_count = 20 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_prim_keys;
  ELSIF l_col_count = 21 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_prim_keys;
  ELSIF l_col_count = 22 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_prim_keys;
  ELSIF l_col_count = 23 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_prim_keys;
  ELSIF l_col_count = 24 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_prim_keys;
  ELSIF l_col_count = 25 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_prim_keys;
  ELSIF l_col_count = 26 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_prim_keys;
  ELSIF l_col_count = 27 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_prim_keys;
  ELSIF l_col_count = 28 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_prim_keys;
  ELSIF l_col_count = 29 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_prim_keys;
  ELSIF l_col_count = 30 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_prim_keys;
  ELSIF l_col_count = 31 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_prim_keys;
  ELSIF l_col_count = 32 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_prim_keys;
  ELSIF l_col_count = 33 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_prim_keys;
  ELSIF l_col_count = 34 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_col34_data,
          p_prim_keys;
  ELSIF l_col_count = 35 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_col34_data,
          p_col35_data, p_prim_keys;
  ELSIF l_col_count = 36 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_col34_data,
          p_col35_data, p_col36_data, p_prim_keys;
  ELSIF l_col_count = 37 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_col34_data,
          p_col35_data, p_col36_data, p_col37_data, p_prim_keys;
  ELSIF l_col_count = 38 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_col34_data,
          p_col35_data, p_col36_data, p_col37_data, p_col38_data, p_prim_keys;
  ELSIF l_col_count = 39 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_col34_data,
          p_col35_data, p_col36_data, p_col37_data, p_col38_data, p_col39_data,
          p_prim_keys;
  ELSIF l_col_count = 40 THEN
    EXECUTE IMMEDIATE
        l_update_sql
    USING p_row_count, p_col1_data, p_col2_data, p_col3_data, p_col4_data,
          p_col5_data, p_col6_data, p_col7_data, p_col8_data, p_col9_data,
          p_col10_data, p_col11_data, p_col12_data, p_col13_data, p_col14_data,
          p_col15_data, p_col16_data, p_col17_data, p_col18_data, p_col19_data,
          p_col20_data, p_col21_data, p_col22_data, p_col23_data, p_col24_data,
          p_col25_data, p_col26_data, p_col27_data, p_col28_data, p_col29_data,
          p_col30_data, p_col31_data, p_col32_data, p_col33_data, p_col34_data,
          p_col35_data, p_col36_data, p_col37_data, p_col38_data, p_col39_data,
          p_col40_data, p_prim_keys;
  END IF;

   -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
  );

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     cn_message_pkg.set_error(l_api_name,'Unexpected Error.');
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Update_DB;

END CN_IMPORT_CLIENT_PVT;

/
