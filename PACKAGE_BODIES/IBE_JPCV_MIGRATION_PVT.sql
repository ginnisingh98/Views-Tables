--------------------------------------------------------
--  DDL for Package Body IBE_JPCV_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_JPCV_MIGRATION_PVT" AS
/* $Header: IBEVJMGB.pls 120.1 2005/08/09 22:39:09 appldev ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_JPCV_MIGRATION_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBEVJMGB.pls';

TYPE GENERIC_CSR IS REF CURSOR;

PROCEDURE Migrate_Sequence
  (
   p_old_seq IN VARCHAR2,
   p_new_seq IN VARCHAR2
  )
IS
  cv1 GENERIC_CSR;
  l_old_num NUMBER;
  l_new_num NUMBER;

  l_seq_sql1 VARCHAR2(200);
  l_seq_sql2 VARCHAR2(200);
BEGIN
  IF (p_old_seq = 'jtf_dsp_sections_b_s1')
    AND (p_new_seq = 'ibe_dsp_sections_b_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_sections_b_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_sections_b_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_dsp_section_items_s1')
    AND (p_new_seq = 'ibe_dsp_section_items_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_section_items_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_section_items_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_dsp_msite_sct_sects_s1')
    AND (p_new_seq = 'ibe_dsp_msite_sct_sects_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_msite_sct_sects_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_msite_sct_sects_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_dsp_msite_sct_items_s1')
    AND (p_new_seq = 'ibe_dsp_msite_sct_items_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_msite_sct_items_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_msite_sct_items_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_msites_b_s1')
    AND (p_new_seq = 'ibe_msites_b_s1') THEN
    l_seq_sql1 := 'SELECT jtf_msites_b_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_msites_b_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_msite_resps_b_s1')
    AND (p_new_seq = 'ibe_msite_resps_b_s1') THEN
    l_seq_sql1 := 'SELECT jtf_msite_resps_b_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_msite_resps_b_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_msite_prty_accss_s1')
    AND (p_new_seq = 'ibe_msite_prty_accss_s1') THEN
    l_seq_sql1 := 'SELECT jtf_msite_prty_accss_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_msite_prty_accss_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_msite_currencies_s1')
    AND (p_new_seq = 'ibe_msite_currencies_s1') THEN
    l_seq_sql1 := 'SELECT jtf_msite_currencies_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_msite_currencies_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_msite_languages_s1')
    AND (p_new_seq = 'ibe_msite_languages_s1') THEN
    l_seq_sql1 := 'SELECT jtf_msite_languages_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_msite_languages_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_msite_orgs_s1')
    AND (p_new_seq = 'ibe_msite_orgs_s1') THEN
    l_seq_sql1 := 'SELECT jtf_msite_orgs_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_msite_orgs_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_dsp_context_b_s1')
    AND (p_new_seq = 'ibe_dsp_context_b_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_context_b_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_context_b_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_dsp_obj_lgl_ctnt_s1')
    AND (p_new_seq = 'ibe_dsp_obj_lgl_ctnt_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_obj_lgl_ctnt_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_obj_lgl_ctnt_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_dsp_lgl_phys_map_s1')
    AND (p_new_seq = 'ibe_dsp_lgl_phys_map_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_lgl_phys_map_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_lgl_phys_map_s1.nextval FROM dual';
  ELSIF (p_old_seq = 'jtf_dsp_tpl_ctg_s1')
    AND (p_new_seq = 'ibe_dsp_tpl_ctg_s1') THEN
    l_seq_sql1 := 'SELECT jtf_dsp_tpl_ctg_s1.nextval FROM dual';
    l_seq_sql2 := 'SELECT ibe_dsp_tpl_ctg_s1.nextval FROM dual';
  END IF;
  --
  -- Do first nextval for the old sequence
  --
  OPEN cv1 FOR l_seq_sql1;
  FETCH cv1 INTO l_old_num;
  CLOSE cv1;

  --
  -- Do first nextval for the new sequence
  --
  OPEN cv1 FOR l_seq_sql2;
  FETCH cv1 INTO l_new_num;
  CLOSE cv1;

  WHILE (l_new_num <= l_old_num) LOOP

    -- increment the value of new sequence number
    OPEN cv1 FOR l_seq_sql2;
    FETCH cv1 INTO l_new_num;
    CLOSE cv1;

  END LOOP;

END Migrate_Sequence;

--
-- Return 0 if the table specified by p_table_name has no rows in it
-- Return 1 if the table specified by p_table_name has at least has 1 row in it
--
PROCEDURE Does_Row_Exists
  (
   p_table_name       IN VARCHAR2,
   p_primary_col_name IN VARCHAR2,
   x_count            OUT NOCOPY NUMBER
  )
IS
  cv1 GENERIC_CSR;
BEGIN

  OPEN cv1 FOR 'SELECT 1 FROM ' || p_table_name ||
    ' WHERE ' || p_primary_col_name || ' >= 10000 AND rownum = 1';
  FETCH cv1 INTO x_count;
  IF (cv1%NOTFOUND) THEN
    x_count := 0;
  ELSE
    x_count := 1;
  END IF;
  CLOSE cv1;

END Does_Row_Exists;

PROCEDURE Log_Table_Migration_Start
  (
   p_module_name          IN VARCHAR2,
   p_src_table_name       IN VARCHAR2,
   p_dst_table_name       IN VARCHAR2
  )
IS
BEGIN
 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_MESSAGE.Set_Name('IBE', 'IBE_MIG_TABLE_INSERT_SELECT_ST');
  FND_MESSAGE.Set_Token('DST_TABLE_NAME', p_dst_table_name);
  FND_MESSAGE.Set_Token('SRC_TABLE_NAME', p_src_table_name);
  FND_LOG.Message(FND_LOG.LEVEL_EVENT, p_module_name, TRUE);
 END IF;
END Log_Table_Migration_Start;

PROCEDURE Log_Table_Migration_Finish
  (
   p_module_name          IN VARCHAR2,
   p_src_table_name       IN VARCHAR2,
   p_dst_table_name       IN VARCHAR2
  )
IS
BEGIN
 IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  FND_MESSAGE.Set_Name('IBE', 'IBE_MIG_TABLE_INSERT_SELECT_FN');
  FND_MESSAGE.Set_Token('DST_TABLE_NAME', p_dst_table_name);
  FND_MESSAGE.Set_Token('SRC_TABLE_NAME', p_src_table_name);
  FND_LOG.Message(FND_LOG.LEVEL_EVENT, p_module_name, TRUE);
 END IF;
END Log_Table_Migration_Finish;

END ibe_jpcv_migration_pvt;

/
