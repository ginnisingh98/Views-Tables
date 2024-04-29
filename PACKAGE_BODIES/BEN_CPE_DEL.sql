--------------------------------------------------------
--  DDL for Package Body BEN_CPE_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPE_DEL" as
/* $Header: becperhi.pkb 120.0 2005/05/28 01:12:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpe_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_cpe_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_copy_entity_results row.
  --
  delete from ben_copy_entity_results
  where copy_entity_result_id = p_rec.copy_entity_result_id;
  --
  ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpe_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ben_cpe_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in ben_cpe_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cpe_rkd.after_delete
      (p_copy_entity_result_id
      => p_rec.copy_entity_result_id
      ,p_copy_entity_txn_id_o
      => ben_cpe_shd.g_old_rec.copy_entity_txn_id
      ,p_src_copy_entity_result_id_o
      => ben_cpe_shd.g_old_rec.src_copy_entity_result_id
      ,p_result_type_cd_o
      => ben_cpe_shd.g_old_rec.result_type_cd
      ,p_number_of_copies_o
      => ben_cpe_shd.g_old_rec.number_of_copies
      ,p_mirror_entity_result_id_o
      => ben_cpe_shd.g_old_rec.mirror_entity_result_id
      ,p_mirror_src_entity_result_i_o
      => ben_cpe_shd.g_old_rec.mirror_src_entity_result_id
      ,p_parent_entity_result_id_o
      => ben_cpe_shd.g_old_rec.parent_entity_result_id
      ,p_pd_mr_src_entity_result_id_o
      => ben_cpe_shd.g_old_rec.pd_mirror_src_entity_result_id
      ,p_pd_parent_entity_result_id_o
      => ben_cpe_shd.g_old_rec.pd_parent_entity_result_id
      ,p_gs_mr_src_entity_result_id_o
      => ben_cpe_shd.g_old_rec.gs_mirror_src_entity_result_id
      ,p_gs_parent_entity_result_id_o
      => ben_cpe_shd.g_old_rec.gs_parent_entity_result_id
      ,p_table_name_o
      => ben_cpe_shd.g_old_rec.table_name
      ,p_table_alias_o
      => ben_cpe_shd.g_old_rec.table_alias
      ,p_table_route_id_o
      => ben_cpe_shd.g_old_rec.table_route_id
      ,p_status_o
      => ben_cpe_shd.g_old_rec.status
      ,p_dml_operation_o
      => ben_cpe_shd.g_old_rec.dml_operation
      ,p_information_category_o
      => ben_cpe_shd.g_old_rec.information_category
      ,p_information1_o
      => ben_cpe_shd.g_old_rec.information1
      ,p_information2_o
      => ben_cpe_shd.g_old_rec.information2
      ,p_information3_o
      => ben_cpe_shd.g_old_rec.information3
      ,p_information4_o
      => ben_cpe_shd.g_old_rec.information4
      ,p_information5_o
      => ben_cpe_shd.g_old_rec.information5
      ,p_information6_o
      => ben_cpe_shd.g_old_rec.information6
      ,p_information7_o
      => ben_cpe_shd.g_old_rec.information7
      ,p_information8_o
      => ben_cpe_shd.g_old_rec.information8
      ,p_information9_o
      => ben_cpe_shd.g_old_rec.information9
      ,p_information10_o
      => ben_cpe_shd.g_old_rec.information10
      ,p_information11_o
      => ben_cpe_shd.g_old_rec.information11
      ,p_information12_o
      => ben_cpe_shd.g_old_rec.information12
      ,p_information13_o
      => ben_cpe_shd.g_old_rec.information13
      ,p_information14_o
      => ben_cpe_shd.g_old_rec.information14
      ,p_information15_o
      => ben_cpe_shd.g_old_rec.information15
      ,p_information16_o
      => ben_cpe_shd.g_old_rec.information16
      ,p_information17_o
      => ben_cpe_shd.g_old_rec.information17
      ,p_information18_o
      => ben_cpe_shd.g_old_rec.information18
      ,p_information19_o
      => ben_cpe_shd.g_old_rec.information19
      ,p_information20_o
      => ben_cpe_shd.g_old_rec.information20
      ,p_information21_o
      => ben_cpe_shd.g_old_rec.information21
      ,p_information22_o
      => ben_cpe_shd.g_old_rec.information22
      ,p_information23_o
      => ben_cpe_shd.g_old_rec.information23
      ,p_information24_o
      => ben_cpe_shd.g_old_rec.information24
      ,p_information25_o
      => ben_cpe_shd.g_old_rec.information25
      ,p_information26_o
      => ben_cpe_shd.g_old_rec.information26
      ,p_information27_o
      => ben_cpe_shd.g_old_rec.information27
      ,p_information28_o
      => ben_cpe_shd.g_old_rec.information28
      ,p_information29_o
      => ben_cpe_shd.g_old_rec.information29
      ,p_information30_o
      => ben_cpe_shd.g_old_rec.information30
      ,p_information31_o
      => ben_cpe_shd.g_old_rec.information31
      ,p_information32_o
      => ben_cpe_shd.g_old_rec.information32
      ,p_information33_o
      => ben_cpe_shd.g_old_rec.information33
      ,p_information34_o
      => ben_cpe_shd.g_old_rec.information34
      ,p_information35_o
      => ben_cpe_shd.g_old_rec.information35
      ,p_information36_o
      => ben_cpe_shd.g_old_rec.information36
      ,p_information37_o
      => ben_cpe_shd.g_old_rec.information37
      ,p_information38_o
      => ben_cpe_shd.g_old_rec.information38
      ,p_information39_o
      => ben_cpe_shd.g_old_rec.information39
      ,p_information40_o
      => ben_cpe_shd.g_old_rec.information40
      ,p_information41_o
      => ben_cpe_shd.g_old_rec.information41
      ,p_information42_o
      => ben_cpe_shd.g_old_rec.information42
      ,p_information43_o
      => ben_cpe_shd.g_old_rec.information43
      ,p_information44_o
      => ben_cpe_shd.g_old_rec.information44
      ,p_information45_o
      => ben_cpe_shd.g_old_rec.information45
      ,p_information46_o
      => ben_cpe_shd.g_old_rec.information46
      ,p_information47_o
      => ben_cpe_shd.g_old_rec.information47
      ,p_information48_o
      => ben_cpe_shd.g_old_rec.information48
      ,p_information49_o
      => ben_cpe_shd.g_old_rec.information49
      ,p_information50_o
      => ben_cpe_shd.g_old_rec.information50
      ,p_information51_o
      => ben_cpe_shd.g_old_rec.information51
      ,p_information52_o
      => ben_cpe_shd.g_old_rec.information52
      ,p_information53_o
      => ben_cpe_shd.g_old_rec.information53
      ,p_information54_o
      => ben_cpe_shd.g_old_rec.information54
      ,p_information55_o
      => ben_cpe_shd.g_old_rec.information55
      ,p_information56_o
      => ben_cpe_shd.g_old_rec.information56
      ,p_information57_o
      => ben_cpe_shd.g_old_rec.information57
      ,p_information58_o
      => ben_cpe_shd.g_old_rec.information58
      ,p_information59_o
      => ben_cpe_shd.g_old_rec.information59
      ,p_information60_o
      => ben_cpe_shd.g_old_rec.information60
      ,p_information61_o
      => ben_cpe_shd.g_old_rec.information61
      ,p_information62_o
      => ben_cpe_shd.g_old_rec.information62
      ,p_information63_o
      => ben_cpe_shd.g_old_rec.information63
      ,p_information64_o
      => ben_cpe_shd.g_old_rec.information64
      ,p_information65_o
      => ben_cpe_shd.g_old_rec.information65
      ,p_information66_o
      => ben_cpe_shd.g_old_rec.information66
      ,p_information67_o
      => ben_cpe_shd.g_old_rec.information67
      ,p_information68_o
      => ben_cpe_shd.g_old_rec.information68
      ,p_information69_o
      => ben_cpe_shd.g_old_rec.information69
      ,p_information70_o
      => ben_cpe_shd.g_old_rec.information70
      ,p_information71_o
      => ben_cpe_shd.g_old_rec.information71
      ,p_information72_o
      => ben_cpe_shd.g_old_rec.information72
      ,p_information73_o
      => ben_cpe_shd.g_old_rec.information73
      ,p_information74_o
      => ben_cpe_shd.g_old_rec.information74
      ,p_information75_o
      => ben_cpe_shd.g_old_rec.information75
      ,p_information76_o
      => ben_cpe_shd.g_old_rec.information76
      ,p_information77_o
      => ben_cpe_shd.g_old_rec.information77
      ,p_information78_o
      => ben_cpe_shd.g_old_rec.information78
      ,p_information79_o
      => ben_cpe_shd.g_old_rec.information79
      ,p_information80_o
      => ben_cpe_shd.g_old_rec.information80
      ,p_information81_o
      => ben_cpe_shd.g_old_rec.information81
      ,p_information82_o
      => ben_cpe_shd.g_old_rec.information82
      ,p_information83_o
      => ben_cpe_shd.g_old_rec.information83
      ,p_information84_o
      => ben_cpe_shd.g_old_rec.information84
      ,p_information85_o
      => ben_cpe_shd.g_old_rec.information85
      ,p_information86_o
      => ben_cpe_shd.g_old_rec.information86
      ,p_information87_o
      => ben_cpe_shd.g_old_rec.information87
      ,p_information88_o
      => ben_cpe_shd.g_old_rec.information88
      ,p_information89_o
      => ben_cpe_shd.g_old_rec.information89
      ,p_information90_o
      => ben_cpe_shd.g_old_rec.information90
      ,p_information91_o
      => ben_cpe_shd.g_old_rec.information91
      ,p_information92_o
      => ben_cpe_shd.g_old_rec.information92
      ,p_information93_o
      => ben_cpe_shd.g_old_rec.information93
      ,p_information94_o
      => ben_cpe_shd.g_old_rec.information94
      ,p_information95_o
      => ben_cpe_shd.g_old_rec.information95
      ,p_information96_o
      => ben_cpe_shd.g_old_rec.information96
      ,p_information97_o
      => ben_cpe_shd.g_old_rec.information97
      ,p_information98_o
      => ben_cpe_shd.g_old_rec.information98
      ,p_information99_o
      => ben_cpe_shd.g_old_rec.information99
      ,p_information100_o
      => ben_cpe_shd.g_old_rec.information100
      ,p_information101_o
      => ben_cpe_shd.g_old_rec.information101
      ,p_information102_o
      => ben_cpe_shd.g_old_rec.information102
      ,p_information103_o
      => ben_cpe_shd.g_old_rec.information103
      ,p_information104_o
      => ben_cpe_shd.g_old_rec.information104
      ,p_information105_o
      => ben_cpe_shd.g_old_rec.information105
      ,p_information106_o
      => ben_cpe_shd.g_old_rec.information106
      ,p_information107_o
      => ben_cpe_shd.g_old_rec.information107
      ,p_information108_o
      => ben_cpe_shd.g_old_rec.information108
      ,p_information109_o
      => ben_cpe_shd.g_old_rec.information109
      ,p_information110_o
      => ben_cpe_shd.g_old_rec.information110
      ,p_information111_o
      => ben_cpe_shd.g_old_rec.information111
      ,p_information112_o
      => ben_cpe_shd.g_old_rec.information112
      ,p_information113_o
      => ben_cpe_shd.g_old_rec.information113
      ,p_information114_o
      => ben_cpe_shd.g_old_rec.information114
      ,p_information115_o
      => ben_cpe_shd.g_old_rec.information115
      ,p_information116_o
      => ben_cpe_shd.g_old_rec.information116
      ,p_information117_o
      => ben_cpe_shd.g_old_rec.information117
      ,p_information118_o
      => ben_cpe_shd.g_old_rec.information118
      ,p_information119_o
      => ben_cpe_shd.g_old_rec.information119
      ,p_information120_o
      => ben_cpe_shd.g_old_rec.information120
      ,p_information121_o
      => ben_cpe_shd.g_old_rec.information121
      ,p_information122_o
      => ben_cpe_shd.g_old_rec.information122
      ,p_information123_o
      => ben_cpe_shd.g_old_rec.information123
      ,p_information124_o
      => ben_cpe_shd.g_old_rec.information124
      ,p_information125_o
      => ben_cpe_shd.g_old_rec.information125
      ,p_information126_o
      => ben_cpe_shd.g_old_rec.information126
      ,p_information127_o
      => ben_cpe_shd.g_old_rec.information127
      ,p_information128_o
      => ben_cpe_shd.g_old_rec.information128
      ,p_information129_o
      => ben_cpe_shd.g_old_rec.information129
      ,p_information130_o
      => ben_cpe_shd.g_old_rec.information130
      ,p_information131_o
      => ben_cpe_shd.g_old_rec.information131
      ,p_information132_o
      => ben_cpe_shd.g_old_rec.information132
      ,p_information133_o
      => ben_cpe_shd.g_old_rec.information133
      ,p_information134_o
      => ben_cpe_shd.g_old_rec.information134
      ,p_information135_o
      => ben_cpe_shd.g_old_rec.information135
      ,p_information136_o
      => ben_cpe_shd.g_old_rec.information136
      ,p_information137_o
      => ben_cpe_shd.g_old_rec.information137
      ,p_information138_o
      => ben_cpe_shd.g_old_rec.information138
      ,p_information139_o
      => ben_cpe_shd.g_old_rec.information139
      ,p_information140_o
      => ben_cpe_shd.g_old_rec.information140
      ,p_information141_o
      => ben_cpe_shd.g_old_rec.information141
      ,p_information142_o
      => ben_cpe_shd.g_old_rec.information142

      /* Extra Reserved Columns
      ,p_information143_o
      => ben_cpe_shd.g_old_rec.information143
      ,p_information144_o
      => ben_cpe_shd.g_old_rec.information144
      ,p_information145_o
      => ben_cpe_shd.g_old_rec.information145
      ,p_information146_o
      => ben_cpe_shd.g_old_rec.information146
      ,p_information147_o
      => ben_cpe_shd.g_old_rec.information147
      ,p_information148_o
      => ben_cpe_shd.g_old_rec.information148
      ,p_information149_o
      => ben_cpe_shd.g_old_rec.information149
      ,p_information150_o
      => ben_cpe_shd.g_old_rec.information150
      */

      ,p_information151_o
      => ben_cpe_shd.g_old_rec.information151
      ,p_information152_o
      => ben_cpe_shd.g_old_rec.information152
      ,p_information153_o
      => ben_cpe_shd.g_old_rec.information153

      /* Extra Reserved Columns
      ,p_information154_o
      => ben_cpe_shd.g_old_rec.information154
      ,p_information155_o
      => ben_cpe_shd.g_old_rec.information155
      ,p_information156_o
      => ben_cpe_shd.g_old_rec.information156
      ,p_information157_o
      => ben_cpe_shd.g_old_rec.information157
      ,p_information158_o
      => ben_cpe_shd.g_old_rec.information158
      ,p_information159_o
      => ben_cpe_shd.g_old_rec.information159
      */

      ,p_information160_o
      => ben_cpe_shd.g_old_rec.information160
      ,p_information161_o
      => ben_cpe_shd.g_old_rec.information161
      ,p_information162_o
      => ben_cpe_shd.g_old_rec.information162

      /* Extra Reserved Columns
      ,p_information163_o
      => ben_cpe_shd.g_old_rec.information163
      ,p_information164_o
      => ben_cpe_shd.g_old_rec.information164
      ,p_information165_o
      => ben_cpe_shd.g_old_rec.information165
      */

      ,p_information166_o
      => ben_cpe_shd.g_old_rec.information166
      ,p_information167_o
      => ben_cpe_shd.g_old_rec.information167
      ,p_information168_o
      => ben_cpe_shd.g_old_rec.information168
      ,p_information169_o
      => ben_cpe_shd.g_old_rec.information169
      ,p_information170_o
      => ben_cpe_shd.g_old_rec.information170

      /* Extra Reserved Columns
      ,p_information171_o
      => ben_cpe_shd.g_old_rec.information171
      ,p_information172_o
      => ben_cpe_shd.g_old_rec.information172
      */

      ,p_information173_o
      => ben_cpe_shd.g_old_rec.information173
      ,p_information174_o
      => ben_cpe_shd.g_old_rec.information174
      ,p_information175_o
      => ben_cpe_shd.g_old_rec.information175
      ,p_information176_o
      => ben_cpe_shd.g_old_rec.information176
      ,p_information177_o
      => ben_cpe_shd.g_old_rec.information177
      ,p_information178_o
      => ben_cpe_shd.g_old_rec.information178
      ,p_information179_o
      => ben_cpe_shd.g_old_rec.information179
      ,p_information180_o
      => ben_cpe_shd.g_old_rec.information180
      ,p_information181_o
      => ben_cpe_shd.g_old_rec.information181
      ,p_information182_o
      => ben_cpe_shd.g_old_rec.information182

      /* Extra Reserved Columns
      ,p_information183_o
      => ben_cpe_shd.g_old_rec.information183
      ,p_information184_o
      => ben_cpe_shd.g_old_rec.information184
      */

      ,p_information185_o
      => ben_cpe_shd.g_old_rec.information185
      ,p_information186_o
      => ben_cpe_shd.g_old_rec.information186
      ,p_information187_o
      => ben_cpe_shd.g_old_rec.information187
      ,p_information188_o
      => ben_cpe_shd.g_old_rec.information188

      /* Extra Reserved Columns
      ,p_information189_o
      => ben_cpe_shd.g_old_rec.information189
      */
      ,p_information190_o
      => ben_cpe_shd.g_old_rec.information190
      ,p_information191_o
      => ben_cpe_shd.g_old_rec.information191
      ,p_information192_o
      => ben_cpe_shd.g_old_rec.information192
      ,p_information193_o
      => ben_cpe_shd.g_old_rec.information193
      ,p_information194_o
      => ben_cpe_shd.g_old_rec.information194
      ,p_information195_o
      => ben_cpe_shd.g_old_rec.information195
      ,p_information196_o
      => ben_cpe_shd.g_old_rec.information196
      ,p_information197_o
      => ben_cpe_shd.g_old_rec.information197
      ,p_information198_o
      => ben_cpe_shd.g_old_rec.information198
      ,p_information199_o
      => ben_cpe_shd.g_old_rec.information199

      /* Extra Reserved Columns
      ,p_information200_o
      => ben_cpe_shd.g_old_rec.information200
      ,p_information201_o
      => ben_cpe_shd.g_old_rec.information201
      ,p_information202_o
      => ben_cpe_shd.g_old_rec.information202
      ,p_information203_o
      => ben_cpe_shd.g_old_rec.information203
      ,p_information204_o
      => ben_cpe_shd.g_old_rec.information204
      ,p_information205_o
      => ben_cpe_shd.g_old_rec.information205
      ,p_information206_o
      => ben_cpe_shd.g_old_rec.information206
      ,p_information207_o
      => ben_cpe_shd.g_old_rec.information207
      ,p_information208_o
      => ben_cpe_shd.g_old_rec.information208
      ,p_information209_o
      => ben_cpe_shd.g_old_rec.information209
      ,p_information210_o
      => ben_cpe_shd.g_old_rec.information210
      ,p_information211_o
      => ben_cpe_shd.g_old_rec.information211
      ,p_information212_o
      => ben_cpe_shd.g_old_rec.information212
      ,p_information213_o
      => ben_cpe_shd.g_old_rec.information213
      ,p_information214_o
      => ben_cpe_shd.g_old_rec.information214
      ,p_information215_o
      => ben_cpe_shd.g_old_rec.information215
      */

      ,p_information216_o
      => ben_cpe_shd.g_old_rec.information216
      ,p_information217_o
      => ben_cpe_shd.g_old_rec.information217
      ,p_information218_o
      => ben_cpe_shd.g_old_rec.information218
      ,p_information219_o
      => ben_cpe_shd.g_old_rec.information219
      ,p_information220_o
      => ben_cpe_shd.g_old_rec.information220

      ,p_information221_o
      => ben_cpe_shd.g_old_rec.information221
      ,p_information222_o
      => ben_cpe_shd.g_old_rec.information222
      ,p_information223_o
      => ben_cpe_shd.g_old_rec.information223
      ,p_information224_o
      => ben_cpe_shd.g_old_rec.information224
      ,p_information225_o
      => ben_cpe_shd.g_old_rec.information225
      ,p_information226_o
      => ben_cpe_shd.g_old_rec.information226
      ,p_information227_o
      => ben_cpe_shd.g_old_rec.information227
      ,p_information228_o
      => ben_cpe_shd.g_old_rec.information228
      ,p_information229_o
      => ben_cpe_shd.g_old_rec.information229
      ,p_information230_o
      => ben_cpe_shd.g_old_rec.information230
      ,p_information231_o
      => ben_cpe_shd.g_old_rec.information231
      ,p_information232_o
      => ben_cpe_shd.g_old_rec.information232
      ,p_information233_o
      => ben_cpe_shd.g_old_rec.information233
      ,p_information234_o
      => ben_cpe_shd.g_old_rec.information234
      ,p_information235_o
      => ben_cpe_shd.g_old_rec.information235
      ,p_information236_o
      => ben_cpe_shd.g_old_rec.information236
      ,p_information237_o
      => ben_cpe_shd.g_old_rec.information237
      ,p_information238_o
      => ben_cpe_shd.g_old_rec.information238
      ,p_information239_o
      => ben_cpe_shd.g_old_rec.information239
      ,p_information240_o
      => ben_cpe_shd.g_old_rec.information240
      ,p_information241_o
      => ben_cpe_shd.g_old_rec.information241
      ,p_information242_o
      => ben_cpe_shd.g_old_rec.information242
      ,p_information243_o
      => ben_cpe_shd.g_old_rec.information243
      ,p_information244_o
      => ben_cpe_shd.g_old_rec.information244
      ,p_information245_o
      => ben_cpe_shd.g_old_rec.information245
      ,p_information246_o
      => ben_cpe_shd.g_old_rec.information246
      ,p_information247_o
      => ben_cpe_shd.g_old_rec.information247
      ,p_information248_o
      => ben_cpe_shd.g_old_rec.information248
      ,p_information249_o
      => ben_cpe_shd.g_old_rec.information249
      ,p_information250_o
      => ben_cpe_shd.g_old_rec.information250
      ,p_information251_o
      => ben_cpe_shd.g_old_rec.information251
      ,p_information252_o
      => ben_cpe_shd.g_old_rec.information252
      ,p_information253_o
      => ben_cpe_shd.g_old_rec.information253
      ,p_information254_o
      => ben_cpe_shd.g_old_rec.information254
      ,p_information255_o
      => ben_cpe_shd.g_old_rec.information255
      ,p_information256_o
      => ben_cpe_shd.g_old_rec.information256
      ,p_information257_o
      => ben_cpe_shd.g_old_rec.information257
      ,p_information258_o
      => ben_cpe_shd.g_old_rec.information258
      ,p_information259_o
      => ben_cpe_shd.g_old_rec.information259
      ,p_information260_o
      => ben_cpe_shd.g_old_rec.information260
      ,p_information261_o
      => ben_cpe_shd.g_old_rec.information261
      ,p_information262_o
      => ben_cpe_shd.g_old_rec.information262
      ,p_information263_o
      => ben_cpe_shd.g_old_rec.information263
      ,p_information264_o
      => ben_cpe_shd.g_old_rec.information264
      ,p_information265_o
      => ben_cpe_shd.g_old_rec.information265
      ,p_information266_o
      => ben_cpe_shd.g_old_rec.information266
      ,p_information267_o
      => ben_cpe_shd.g_old_rec.information267
      ,p_information268_o
      => ben_cpe_shd.g_old_rec.information268
      ,p_information269_o
      => ben_cpe_shd.g_old_rec.information269
      ,p_information270_o
      => ben_cpe_shd.g_old_rec.information270
      ,p_information271_o
      => ben_cpe_shd.g_old_rec.information271
      ,p_information272_o
      => ben_cpe_shd.g_old_rec.information272
      ,p_information273_o
      => ben_cpe_shd.g_old_rec.information273
      ,p_information274_o
      => ben_cpe_shd.g_old_rec.information274
      ,p_information275_o
      => ben_cpe_shd.g_old_rec.information275
      ,p_information276_o
      => ben_cpe_shd.g_old_rec.information276
      ,p_information277_o
      => ben_cpe_shd.g_old_rec.information277
      ,p_information278_o
      => ben_cpe_shd.g_old_rec.information278
      ,p_information279_o
      => ben_cpe_shd.g_old_rec.information279
      ,p_information280_o
      => ben_cpe_shd.g_old_rec.information280
      ,p_information281_o
      => ben_cpe_shd.g_old_rec.information281
      ,p_information282_o
      => ben_cpe_shd.g_old_rec.information282
      ,p_information283_o
      => ben_cpe_shd.g_old_rec.information283
      ,p_information284_o
      => ben_cpe_shd.g_old_rec.information284
      ,p_information285_o
      => ben_cpe_shd.g_old_rec.information285
      ,p_information286_o
      => ben_cpe_shd.g_old_rec.information286
      ,p_information287_o
      => ben_cpe_shd.g_old_rec.information287
      ,p_information288_o
      => ben_cpe_shd.g_old_rec.information288
      ,p_information289_o
      => ben_cpe_shd.g_old_rec.information289
      ,p_information290_o
      => ben_cpe_shd.g_old_rec.information290
      ,p_information291_o
      => ben_cpe_shd.g_old_rec.information291
      ,p_information292_o
      => ben_cpe_shd.g_old_rec.information292
      ,p_information293_o
      => ben_cpe_shd.g_old_rec.information293
      ,p_information294_o
      => ben_cpe_shd.g_old_rec.information294
      ,p_information295_o
      => ben_cpe_shd.g_old_rec.information295
      ,p_information296_o
      => ben_cpe_shd.g_old_rec.information296
      ,p_information297_o
      => ben_cpe_shd.g_old_rec.information297
      ,p_information298_o
      => ben_cpe_shd.g_old_rec.information298
      ,p_information299_o
      => ben_cpe_shd.g_old_rec.information299
      ,p_information300_o
      => ben_cpe_shd.g_old_rec.information300
      ,p_information301_o
      => ben_cpe_shd.g_old_rec.information301
      ,p_information302_o
      => ben_cpe_shd.g_old_rec.information302
      ,p_information303_o
      => ben_cpe_shd.g_old_rec.information303
      ,p_information304_o
      => ben_cpe_shd.g_old_rec.information304

      /* Extra Reserved Columns
      ,p_information305_o
      => ben_cpe_shd.g_old_rec.information305
      */
      ,p_information306_o
      => ben_cpe_shd.g_old_rec.information306
      ,p_information307_o
      => ben_cpe_shd.g_old_rec.information307
      ,p_information308_o
      => ben_cpe_shd.g_old_rec.information308
      ,p_information309_o
      => ben_cpe_shd.g_old_rec.information309
      ,p_information310_o
      => ben_cpe_shd.g_old_rec.information310
      ,p_information311_o
      => ben_cpe_shd.g_old_rec.information311
      ,p_information312_o
      => ben_cpe_shd.g_old_rec.information312
      ,p_information313_o
      => ben_cpe_shd.g_old_rec.information313
      ,p_information314_o
      => ben_cpe_shd.g_old_rec.information314
      ,p_information315_o
      => ben_cpe_shd.g_old_rec.information315
      ,p_information316_o
      => ben_cpe_shd.g_old_rec.information316
      ,p_information317_o
      => ben_cpe_shd.g_old_rec.information317
      ,p_information318_o
      => ben_cpe_shd.g_old_rec.information318
      ,p_information319_o
      => ben_cpe_shd.g_old_rec.information319
      ,p_information320_o
      => ben_cpe_shd.g_old_rec.information320

      /* Extra Reserved Columns
      ,p_information321_o
      => ben_cpe_shd.g_old_rec.information321
      ,p_information322_o
      => ben_cpe_shd.g_old_rec.information322
      */
      ,p_information323_o
      => ben_cpe_shd.g_old_rec.information323

      ,p_datetrack_mode_o
      => ben_cpe_shd.g_old_rec.datetrack_mode
      ,p_object_version_number_o
      => ben_cpe_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_COPY_ENTITY_RESULTS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ben_cpe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_cpe_shd.lck
    (p_rec.copy_entity_result_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_cpe_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_cpe_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_cpe_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_cpe_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_copy_entity_result_id                in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_cpe_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.copy_entity_result_id := p_copy_entity_result_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_cpe_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_cpe_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_cpe_del;

/
