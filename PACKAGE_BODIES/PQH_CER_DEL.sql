--------------------------------------------------------
--  DDL for Package Body PQH_CER_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CER_DEL" as
/* $Header: pqcerrhi.pkb 115.6 2002/11/27 04:43:16 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cer_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in pqh_cer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the pqh_copy_entity_results row.
  --
  delete from pqh_copy_entity_results
  where copy_entity_result_id = p_rec.copy_entity_result_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_cer_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_delete(p_rec in pqh_cer_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   delete dml.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(
p_effective_date in date,p_rec in pqh_cer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pqh_cer_rkd.after_delete
      (
  p_copy_entity_result_id         =>p_rec.copy_entity_result_id
 ,p_copy_entity_txn_id_o          =>pqh_cer_shd.g_old_rec.copy_entity_txn_id
 ,p_result_type_cd_o              =>pqh_cer_shd.g_old_rec.result_type_cd
 ,p_number_of_copies_o            =>pqh_cer_shd.g_old_rec.number_of_copies
 ,p_status_o                      =>pqh_cer_shd.g_old_rec.status
 ,p_src_copy_entity_result_id_o   =>pqh_cer_shd.g_old_rec.src_copy_entity_result_id
 ,p_information_category_o        =>pqh_cer_shd.g_old_rec.information_category
 ,p_information1_o                =>pqh_cer_shd.g_old_rec.information1
 ,p_information2_o                =>pqh_cer_shd.g_old_rec.information2
 ,p_information3_o                =>pqh_cer_shd.g_old_rec.information3
 ,p_information4_o                =>pqh_cer_shd.g_old_rec.information4
 ,p_information5_o                =>pqh_cer_shd.g_old_rec.information5
 ,p_information6_o                =>pqh_cer_shd.g_old_rec.information6
 ,p_information7_o                =>pqh_cer_shd.g_old_rec.information7
 ,p_information8_o                =>pqh_cer_shd.g_old_rec.information8
 ,p_information9_o                =>pqh_cer_shd.g_old_rec.information9
 ,p_information10_o               =>pqh_cer_shd.g_old_rec.information10
 ,p_information11_o               =>pqh_cer_shd.g_old_rec.information11
 ,p_information12_o               =>pqh_cer_shd.g_old_rec.information12
 ,p_information13_o               =>pqh_cer_shd.g_old_rec.information13
 ,p_information14_o               =>pqh_cer_shd.g_old_rec.information14
 ,p_information15_o               =>pqh_cer_shd.g_old_rec.information15
 ,p_information16_o               =>pqh_cer_shd.g_old_rec.information16
 ,p_information17_o               =>pqh_cer_shd.g_old_rec.information17
 ,p_information18_o               =>pqh_cer_shd.g_old_rec.information18
 ,p_information19_o               =>pqh_cer_shd.g_old_rec.information19
 ,p_information20_o               =>pqh_cer_shd.g_old_rec.information20
 ,p_information21_o               =>pqh_cer_shd.g_old_rec.information21
 ,p_information22_o               =>pqh_cer_shd.g_old_rec.information22
 ,p_information23_o               =>pqh_cer_shd.g_old_rec.information23
 ,p_information24_o               =>pqh_cer_shd.g_old_rec.information24
 ,p_information25_o               =>pqh_cer_shd.g_old_rec.information25
 ,p_information26_o               =>pqh_cer_shd.g_old_rec.information26
 ,p_information27_o               =>pqh_cer_shd.g_old_rec.information27
 ,p_information28_o               =>pqh_cer_shd.g_old_rec.information28
 ,p_information29_o               =>pqh_cer_shd.g_old_rec.information29
 ,p_information30_o               =>pqh_cer_shd.g_old_rec.information30
 ,p_information31_o               =>pqh_cer_shd.g_old_rec.information31
 ,p_information32_o               =>pqh_cer_shd.g_old_rec.information32
 ,p_information33_o               =>pqh_cer_shd.g_old_rec.information33
 ,p_information34_o               =>pqh_cer_shd.g_old_rec.information34
 ,p_information35_o               =>pqh_cer_shd.g_old_rec.information35
 ,p_information36_o               =>pqh_cer_shd.g_old_rec.information36
 ,p_information37_o               =>pqh_cer_shd.g_old_rec.information37
 ,p_information38_o               =>pqh_cer_shd.g_old_rec.information38
 ,p_information39_o               =>pqh_cer_shd.g_old_rec.information39
 ,p_information40_o               =>pqh_cer_shd.g_old_rec.information40
 ,p_information41_o               =>pqh_cer_shd.g_old_rec.information41
 ,p_information42_o               =>pqh_cer_shd.g_old_rec.information42
 ,p_information43_o               =>pqh_cer_shd.g_old_rec.information43
 ,p_information44_o               =>pqh_cer_shd.g_old_rec.information44
 ,p_information45_o               =>pqh_cer_shd.g_old_rec.information45
 ,p_information46_o               =>pqh_cer_shd.g_old_rec.information46
 ,p_information47_o               =>pqh_cer_shd.g_old_rec.information47
 ,p_information48_o               =>pqh_cer_shd.g_old_rec.information48
 ,p_information49_o               =>pqh_cer_shd.g_old_rec.information49
 ,p_information50_o               =>pqh_cer_shd.g_old_rec.information50
 ,p_information51_o               =>pqh_cer_shd.g_old_rec.information51
 ,p_information52_o               =>pqh_cer_shd.g_old_rec.information52
 ,p_information53_o               =>pqh_cer_shd.g_old_rec.information53
 ,p_information54_o               =>pqh_cer_shd.g_old_rec.information54
 ,p_information55_o               =>pqh_cer_shd.g_old_rec.information55
 ,p_information56_o               =>pqh_cer_shd.g_old_rec.information56
 ,p_information57_o               =>pqh_cer_shd.g_old_rec.information57
 ,p_information58_o               =>pqh_cer_shd.g_old_rec.information58
 ,p_information59_o               =>pqh_cer_shd.g_old_rec.information59
 ,p_information60_o               =>pqh_cer_shd.g_old_rec.information60
 ,p_information61_o               =>pqh_cer_shd.g_old_rec.information61
 ,p_information62_o               =>pqh_cer_shd.g_old_rec.information62
 ,p_information63_o               =>pqh_cer_shd.g_old_rec.information63
 ,p_information64_o               =>pqh_cer_shd.g_old_rec.information64
 ,p_information65_o               =>pqh_cer_shd.g_old_rec.information65
 ,p_information66_o               =>pqh_cer_shd.g_old_rec.information66
 ,p_information67_o               =>pqh_cer_shd.g_old_rec.information67
 ,p_information68_o               =>pqh_cer_shd.g_old_rec.information68
 ,p_information69_o               =>pqh_cer_shd.g_old_rec.information69
 ,p_information70_o               =>pqh_cer_shd.g_old_rec.information70
 ,p_information71_o               =>pqh_cer_shd.g_old_rec.information71
 ,p_information72_o               =>pqh_cer_shd.g_old_rec.information72
 ,p_information73_o               =>pqh_cer_shd.g_old_rec.information73
 ,p_information74_o               =>pqh_cer_shd.g_old_rec.information74
 ,p_information75_o               =>pqh_cer_shd.g_old_rec.information75
 ,p_information76_o               =>pqh_cer_shd.g_old_rec.information76
 ,p_information77_o               =>pqh_cer_shd.g_old_rec.information77
 ,p_information78_o               =>pqh_cer_shd.g_old_rec.information78
 ,p_information79_o               =>pqh_cer_shd.g_old_rec.information79
 ,p_information80_o               =>pqh_cer_shd.g_old_rec.information80
 ,p_information81_o               =>pqh_cer_shd.g_old_rec.information81
 ,p_information82_o               =>pqh_cer_shd.g_old_rec.information82
 ,p_information83_o               =>pqh_cer_shd.g_old_rec.information83
 ,p_information84_o               =>pqh_cer_shd.g_old_rec.information84
 ,p_information85_o               =>pqh_cer_shd.g_old_rec.information85
 ,p_information86_o               =>pqh_cer_shd.g_old_rec.information86
 ,p_information87_o               =>pqh_cer_shd.g_old_rec.information87
 ,p_information88_o               =>pqh_cer_shd.g_old_rec.information88
 ,p_information89_o               =>pqh_cer_shd.g_old_rec.information89
 ,p_information90_o               =>pqh_cer_shd.g_old_rec.information90
 ,p_information91_o               =>pqh_cer_shd.g_old_rec.information91
 ,p_information92_o               =>pqh_cer_shd.g_old_rec.information92
 ,p_information93_o               =>pqh_cer_shd.g_old_rec.information93
 ,p_information94_o               =>pqh_cer_shd.g_old_rec.information94
 ,p_information95_o               =>pqh_cer_shd.g_old_rec.information95
 ,p_information96_o               =>pqh_cer_shd.g_old_rec.information96
 ,p_information97_o               =>pqh_cer_shd.g_old_rec.information97
 ,p_information98_o               =>pqh_cer_shd.g_old_rec.information98
 ,p_information99_o               =>pqh_cer_shd.g_old_rec.information99
 ,p_information100_o               =>pqh_cer_shd.g_old_rec.information100
 ,p_information101_o               =>pqh_cer_shd.g_old_rec.information101
 ,p_information102_o               =>pqh_cer_shd.g_old_rec.information102
 ,p_information103_o               =>pqh_cer_shd.g_old_rec.information103
 ,p_information104_o               =>pqh_cer_shd.g_old_rec.information104
 ,p_information105_o               =>pqh_cer_shd.g_old_rec.information105
 ,p_information106_o               =>pqh_cer_shd.g_old_rec.information106
 ,p_information107_o               =>pqh_cer_shd.g_old_rec.information107
 ,p_information108_o               =>pqh_cer_shd.g_old_rec.information108
 ,p_information109_o               =>pqh_cer_shd.g_old_rec.information109
 ,p_information110_o               =>pqh_cer_shd.g_old_rec.information110
 ,p_information111_o               =>pqh_cer_shd.g_old_rec.information111
 ,p_information112_o               =>pqh_cer_shd.g_old_rec.information112
 ,p_information113_o               =>pqh_cer_shd.g_old_rec.information113
 ,p_information114_o               =>pqh_cer_shd.g_old_rec.information114
 ,p_information115_o               =>pqh_cer_shd.g_old_rec.information115
 ,p_information116_o               =>pqh_cer_shd.g_old_rec.information116
 ,p_information117_o               =>pqh_cer_shd.g_old_rec.information117
 ,p_information118_o               =>pqh_cer_shd.g_old_rec.information118
 ,p_information119_o               =>pqh_cer_shd.g_old_rec.information119
 ,p_information120_o               =>pqh_cer_shd.g_old_rec.information120
 ,p_information121_o               =>pqh_cer_shd.g_old_rec.information121
 ,p_information122_o               =>pqh_cer_shd.g_old_rec.information122
 ,p_information123_o               =>pqh_cer_shd.g_old_rec.information123
 ,p_information124_o               =>pqh_cer_shd.g_old_rec.information124
 ,p_information125_o               =>pqh_cer_shd.g_old_rec.information125
 ,p_information126_o               =>pqh_cer_shd.g_old_rec.information126
 ,p_information127_o               =>pqh_cer_shd.g_old_rec.information127
 ,p_information128_o               =>pqh_cer_shd.g_old_rec.information128
 ,p_information129_o               =>pqh_cer_shd.g_old_rec.information129
 ,p_information130_o               =>pqh_cer_shd.g_old_rec.information130
 ,p_information131_o               =>pqh_cer_shd.g_old_rec.information131
 ,p_information132_o               =>pqh_cer_shd.g_old_rec.information132
 ,p_information133_o               =>pqh_cer_shd.g_old_rec.information133
 ,p_information134_o               =>pqh_cer_shd.g_old_rec.information134
 ,p_information135_o               =>pqh_cer_shd.g_old_rec.information135
 ,p_information136_o               =>pqh_cer_shd.g_old_rec.information136
 ,p_information137_o               =>pqh_cer_shd.g_old_rec.information137
 ,p_information138_o               =>pqh_cer_shd.g_old_rec.information138
 ,p_information139_o               =>pqh_cer_shd.g_old_rec.information139
 ,p_information140_o               =>pqh_cer_shd.g_old_rec.information140
 ,p_information141_o               =>pqh_cer_shd.g_old_rec.information141
 ,p_information142_o               =>pqh_cer_shd.g_old_rec.information142
 ,p_information143_o               =>pqh_cer_shd.g_old_rec.information143
 ,p_information144_o               =>pqh_cer_shd.g_old_rec.information144
 ,p_information145_o               =>pqh_cer_shd.g_old_rec.information145
 ,p_information146_o               =>pqh_cer_shd.g_old_rec.information146
 ,p_information147_o               =>pqh_cer_shd.g_old_rec.information147
 ,p_information148_o               =>pqh_cer_shd.g_old_rec.information148
 ,p_information149_o               =>pqh_cer_shd.g_old_rec.information149
 ,p_information150_o               =>pqh_cer_shd.g_old_rec.information150
 ,p_information151_o               =>pqh_cer_shd.g_old_rec.information151
 ,p_information152_o               =>pqh_cer_shd.g_old_rec.information152
 ,p_information153_o               =>pqh_cer_shd.g_old_rec.information153
 ,p_information154_o               =>pqh_cer_shd.g_old_rec.information154
 ,p_information155_o               =>pqh_cer_shd.g_old_rec.information155
 ,p_information156_o               =>pqh_cer_shd.g_old_rec.information156
 ,p_information157_o               =>pqh_cer_shd.g_old_rec.information157
 ,p_information158_o               =>pqh_cer_shd.g_old_rec.information158
 ,p_information159_o               =>pqh_cer_shd.g_old_rec.information159
 ,p_information160_o               =>pqh_cer_shd.g_old_rec.information160
 ,p_information161_o               =>pqh_cer_shd.g_old_rec.information161
 ,p_information162_o               =>pqh_cer_shd.g_old_rec.information162
 ,p_information163_o               =>pqh_cer_shd.g_old_rec.information163
 ,p_information164_o               =>pqh_cer_shd.g_old_rec.information164
 ,p_information165_o               =>pqh_cer_shd.g_old_rec.information165
 ,p_information166_o               =>pqh_cer_shd.g_old_rec.information166
 ,p_information167_o               =>pqh_cer_shd.g_old_rec.information167
 ,p_information168_o               =>pqh_cer_shd.g_old_rec.information168
 ,p_information169_o               =>pqh_cer_shd.g_old_rec.information169
 ,p_information170_o               =>pqh_cer_shd.g_old_rec.information170
 ,p_information171_o               =>pqh_cer_shd.g_old_rec.information171
 ,p_information172_o               =>pqh_cer_shd.g_old_rec.information172
 ,p_information173_o               =>pqh_cer_shd.g_old_rec.information173
 ,p_information174_o               =>pqh_cer_shd.g_old_rec.information174
 ,p_information175_o               =>pqh_cer_shd.g_old_rec.information175
 ,p_information176_o               =>pqh_cer_shd.g_old_rec.information176
 ,p_information177_o               =>pqh_cer_shd.g_old_rec.information177
 ,p_information178_o               =>pqh_cer_shd.g_old_rec.information178
 ,p_information179_o               =>pqh_cer_shd.g_old_rec.information179
 ,p_information180_o               =>pqh_cer_shd.g_old_rec.information180
 ,p_information181_o               =>pqh_cer_shd.g_old_rec.information181
 ,p_information182_o               =>pqh_cer_shd.g_old_rec.information182
 ,p_information183_o               =>pqh_cer_shd.g_old_rec.information183
 ,p_information184_o               =>pqh_cer_shd.g_old_rec.information184
 ,p_information185_o               =>pqh_cer_shd.g_old_rec.information185
 ,p_information186_o               =>pqh_cer_shd.g_old_rec.information186
 ,p_information187_o               =>pqh_cer_shd.g_old_rec.information187
 ,p_information188_o               =>pqh_cer_shd.g_old_rec.information188
 ,p_information189_o               =>pqh_cer_shd.g_old_rec.information189
 ,p_information190_o               =>pqh_cer_shd.g_old_rec.information190
 ,p_mirror_entity_result_id_o      =>pqh_cer_shd.g_old_rec.mirror_entity_result_id
 ,p_mirror_src_entity_result_ido   =>pqh_cer_shd.g_old_rec.mirror_src_entity_result_id
 ,p_parent_entity_result_id_o      =>pqh_cer_shd.g_old_rec.parent_entity_result_id
 ,p_table_route_id_o               =>pqh_cer_shd.g_old_rec.table_route_id
 ,p_long_attribute1_o              =>pqh_cer_shd.g_old_rec.long_attribute1
 ,p_object_version_number_o       =>pqh_cer_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_copy_entity_results'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec	      in pqh_cer_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_cer_shd.lck
	(
	p_rec.copy_entity_result_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqh_cer_bus.delete_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_copy_entity_result_id              in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqh_cer_shd.g_rec_type;
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
  l_rec.copy_entity_result_id:= p_copy_entity_result_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_cer_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_cer_del;

/
