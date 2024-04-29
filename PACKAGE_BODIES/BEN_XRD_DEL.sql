--------------------------------------------------------
--  DDL for Package Body BEN_XRD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRD_DEL" as
/* $Header: bexrdrhi.pkb 120.1 2006/02/06 11:28:36 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrd_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_xrd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_xrd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_ext_rslt_dtl row.
  --
  delete from ben_ext_rslt_dtl
  where ext_rslt_dtl_id = p_rec.ext_rslt_dtl_id;
  --
  ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xrd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_xrd_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ben_xrd_shd.g_rec_type) is
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
    ben_xrd_rkd.after_delete
      (
  p_ext_rslt_dtl_id               =>p_rec.ext_rslt_dtl_id
 ,p_prmy_sort_val_o               =>ben_xrd_shd.g_old_rec.prmy_sort_val
 ,p_scnd_sort_val_o               =>ben_xrd_shd.g_old_rec.scnd_sort_val
 ,p_thrd_sort_val_o               =>ben_xrd_shd.g_old_rec.thrd_sort_val
 ,p_trans_seq_num_o               =>ben_xrd_shd.g_old_rec.trans_seq_num
 ,p_rcrd_seq_num_o                =>ben_xrd_shd.g_old_rec.rcrd_seq_num
 ,p_ext_rslt_id_o                 =>ben_xrd_shd.g_old_rec.ext_rslt_id
 ,p_ext_rcd_id_o                  =>ben_xrd_shd.g_old_rec.ext_rcd_id
 ,p_person_id_o                   =>ben_xrd_shd.g_old_rec.person_id
 ,p_business_group_id_o           =>ben_xrd_shd.g_old_rec.business_group_id
 ,p_ext_per_bg_id_o               =>ben_xrd_shd.g_old_rec.ext_per_bg_id
 ,p_val_01_o                      =>ben_xrd_shd.g_old_rec.val_01
 ,p_val_02_o                      =>ben_xrd_shd.g_old_rec.val_02
 ,p_val_03_o                      =>ben_xrd_shd.g_old_rec.val_03
 ,p_val_04_o                      =>ben_xrd_shd.g_old_rec.val_04
 ,p_val_05_o                      =>ben_xrd_shd.g_old_rec.val_05
 ,p_val_06_o                      =>ben_xrd_shd.g_old_rec.val_06
 ,p_val_07_o                      =>ben_xrd_shd.g_old_rec.val_07
 ,p_val_08_o                      =>ben_xrd_shd.g_old_rec.val_08
 ,p_val_09_o                      =>ben_xrd_shd.g_old_rec.val_09
 ,p_val_10_o                      =>ben_xrd_shd.g_old_rec.val_10
 ,p_val_11_o                      =>ben_xrd_shd.g_old_rec.val_11
 ,p_val_12_o                      =>ben_xrd_shd.g_old_rec.val_12
 ,p_val_13_o                      =>ben_xrd_shd.g_old_rec.val_13
 ,p_val_14_o                      =>ben_xrd_shd.g_old_rec.val_14
 ,p_val_15_o                      =>ben_xrd_shd.g_old_rec.val_15
 ,p_val_16_o                      =>ben_xrd_shd.g_old_rec.val_16
 ,p_val_17_o                      =>ben_xrd_shd.g_old_rec.val_17
 ,p_val_19_o                      =>ben_xrd_shd.g_old_rec.val_19
 ,p_val_18_o                      =>ben_xrd_shd.g_old_rec.val_18
 ,p_val_20_o                      =>ben_xrd_shd.g_old_rec.val_20
 ,p_val_21_o                      =>ben_xrd_shd.g_old_rec.val_21
 ,p_val_22_o                      =>ben_xrd_shd.g_old_rec.val_22
 ,p_val_23_o                      =>ben_xrd_shd.g_old_rec.val_23
 ,p_val_24_o                      =>ben_xrd_shd.g_old_rec.val_24
 ,p_val_25_o                      =>ben_xrd_shd.g_old_rec.val_25
 ,p_val_26_o                      =>ben_xrd_shd.g_old_rec.val_26
 ,p_val_27_o                      =>ben_xrd_shd.g_old_rec.val_27
 ,p_val_28_o                      =>ben_xrd_shd.g_old_rec.val_28
 ,p_val_29_o                      =>ben_xrd_shd.g_old_rec.val_29
 ,p_val_30_o                      =>ben_xrd_shd.g_old_rec.val_30
 ,p_val_31_o                      =>ben_xrd_shd.g_old_rec.val_31
 ,p_val_32_o                      =>ben_xrd_shd.g_old_rec.val_32
 ,p_val_33_o                      =>ben_xrd_shd.g_old_rec.val_33
 ,p_val_34_o                      =>ben_xrd_shd.g_old_rec.val_34
 ,p_val_35_o                      =>ben_xrd_shd.g_old_rec.val_35
 ,p_val_36_o                      =>ben_xrd_shd.g_old_rec.val_36
 ,p_val_37_o                      =>ben_xrd_shd.g_old_rec.val_37
 ,p_val_38_o                      =>ben_xrd_shd.g_old_rec.val_38
 ,p_val_39_o                      =>ben_xrd_shd.g_old_rec.val_39
 ,p_val_40_o                      =>ben_xrd_shd.g_old_rec.val_40
 ,p_val_41_o                      =>ben_xrd_shd.g_old_rec.val_41
 ,p_val_42_o                      =>ben_xrd_shd.g_old_rec.val_42
 ,p_val_43_o                      =>ben_xrd_shd.g_old_rec.val_43
 ,p_val_44_o                      =>ben_xrd_shd.g_old_rec.val_44
 ,p_val_45_o                      =>ben_xrd_shd.g_old_rec.val_45
 ,p_val_46_o                      =>ben_xrd_shd.g_old_rec.val_46
 ,p_val_47_o                      =>ben_xrd_shd.g_old_rec.val_47
 ,p_val_48_o                      =>ben_xrd_shd.g_old_rec.val_48
 ,p_val_49_o                      =>ben_xrd_shd.g_old_rec.val_49
 ,p_val_50_o                      =>ben_xrd_shd.g_old_rec.val_50
 ,p_val_51_o                      =>ben_xrd_shd.g_old_rec.val_51
 ,p_val_52_o                      =>ben_xrd_shd.g_old_rec.val_52
 ,p_val_53_o                      =>ben_xrd_shd.g_old_rec.val_53
 ,p_val_54_o                      =>ben_xrd_shd.g_old_rec.val_54
 ,p_val_55_o                      =>ben_xrd_shd.g_old_rec.val_55
 ,p_val_56_o                      =>ben_xrd_shd.g_old_rec.val_56
 ,p_val_57_o                      =>ben_xrd_shd.g_old_rec.val_57
 ,p_val_58_o                      =>ben_xrd_shd.g_old_rec.val_58
 ,p_val_59_o                      =>ben_xrd_shd.g_old_rec.val_59
 ,p_val_60_o                      =>ben_xrd_shd.g_old_rec.val_60
 ,p_val_61_o                      =>ben_xrd_shd.g_old_rec.val_61
 ,p_val_62_o                      =>ben_xrd_shd.g_old_rec.val_62
 ,p_val_63_o                      =>ben_xrd_shd.g_old_rec.val_63
 ,p_val_64_o                      =>ben_xrd_shd.g_old_rec.val_64
 ,p_val_65_o                      =>ben_xrd_shd.g_old_rec.val_65
 ,p_val_66_o                      =>ben_xrd_shd.g_old_rec.val_66
 ,p_val_67_o                      =>ben_xrd_shd.g_old_rec.val_67
 ,p_val_68_o                      =>ben_xrd_shd.g_old_rec.val_68
 ,p_val_69_o                      =>ben_xrd_shd.g_old_rec.val_69
 ,p_val_70_o                      =>ben_xrd_shd.g_old_rec.val_70
 ,p_val_71_o                      =>ben_xrd_shd.g_old_rec.val_71
 ,p_val_72_o                      =>ben_xrd_shd.g_old_rec.val_72
 ,p_val_73_o                      =>ben_xrd_shd.g_old_rec.val_73
 ,p_val_74_o                      =>ben_xrd_shd.g_old_rec.val_74
 ,p_val_75_o                      =>ben_xrd_shd.g_old_rec.val_75
 ,p_val_76_o                      =>ben_xrd_shd.g_old_rec.val_76
 ,p_val_77_o                      =>ben_xrd_shd.g_old_rec.val_77
 ,p_val_78_o                      =>ben_xrd_shd.g_old_rec.val_78
 ,p_val_79_o                      =>ben_xrd_shd.g_old_rec.val_79
 ,p_val_80_o                      =>ben_xrd_shd.g_old_rec.val_80
 ,p_val_81_o                      =>ben_xrd_shd.g_old_rec.val_81
 ,p_val_82_o                      =>ben_xrd_shd.g_old_rec.val_82
 ,p_val_83_o                      =>ben_xrd_shd.g_old_rec.val_83
 ,p_val_84_o                      =>ben_xrd_shd.g_old_rec.val_84
 ,p_val_85_o                      =>ben_xrd_shd.g_old_rec.val_85
 ,p_val_86_o                      =>ben_xrd_shd.g_old_rec.val_86
 ,p_val_87_o                      =>ben_xrd_shd.g_old_rec.val_87
 ,p_val_88_o                      =>ben_xrd_shd.g_old_rec.val_88
 ,p_val_89_o                      =>ben_xrd_shd.g_old_rec.val_89
 ,p_val_90_o                      =>ben_xrd_shd.g_old_rec.val_90
 ,p_val_91_o                      =>ben_xrd_shd.g_old_rec.val_91
 ,p_val_92_o                      =>ben_xrd_shd.g_old_rec.val_92
 ,p_val_93_o                      =>ben_xrd_shd.g_old_rec.val_93
 ,p_val_94_o                      =>ben_xrd_shd.g_old_rec.val_94
 ,p_val_95_o                      =>ben_xrd_shd.g_old_rec.val_95
 ,p_val_96_o                      =>ben_xrd_shd.g_old_rec.val_96
 ,p_val_97_o                      =>ben_xrd_shd.g_old_rec.val_97
 ,p_val_98_o                      =>ben_xrd_shd.g_old_rec.val_98
 ,p_val_99_o                      =>ben_xrd_shd.g_old_rec.val_99
 ,p_val_100_o                     =>ben_xrd_shd.g_old_rec.val_100
 ,p_val_101_o                     =>ben_xrd_shd.g_old_rec.val_101
 ,p_val_102_o                      =>ben_xrd_shd.g_old_rec.val_102
 ,p_val_103_o                      =>ben_xrd_shd.g_old_rec.val_103
 ,p_val_104_o                      =>ben_xrd_shd.g_old_rec.val_104
 ,p_val_105_o                      =>ben_xrd_shd.g_old_rec.val_105
 ,p_val_106_o                      =>ben_xrd_shd.g_old_rec.val_106
 ,p_val_107_o                      =>ben_xrd_shd.g_old_rec.val_107
 ,p_val_108_o                      =>ben_xrd_shd.g_old_rec.val_108
 ,p_val_109_o                      =>ben_xrd_shd.g_old_rec.val_109
 ,p_val_110_o                      =>ben_xrd_shd.g_old_rec.val_110
 ,p_val_111_o                      =>ben_xrd_shd.g_old_rec.val_111
 ,p_val_112_o                      =>ben_xrd_shd.g_old_rec.val_112
 ,p_val_113_o                      =>ben_xrd_shd.g_old_rec.val_113
 ,p_val_114_o                      =>ben_xrd_shd.g_old_rec.val_114
 ,p_val_115_o                      =>ben_xrd_shd.g_old_rec.val_115
 ,p_val_116_o                      =>ben_xrd_shd.g_old_rec.val_116
 ,p_val_117_o                      =>ben_xrd_shd.g_old_rec.val_117
 ,p_val_119_o                      =>ben_xrd_shd.g_old_rec.val_119
 ,p_val_118_o                      =>ben_xrd_shd.g_old_rec.val_118
 ,p_val_120_o                      =>ben_xrd_shd.g_old_rec.val_120
 ,p_val_121_o                      =>ben_xrd_shd.g_old_rec.val_121
 ,p_val_122_o                      =>ben_xrd_shd.g_old_rec.val_122
 ,p_val_123_o                      =>ben_xrd_shd.g_old_rec.val_123
 ,p_val_124_o                      =>ben_xrd_shd.g_old_rec.val_124
 ,p_val_125_o                      =>ben_xrd_shd.g_old_rec.val_125
 ,p_val_126_o                      =>ben_xrd_shd.g_old_rec.val_126
 ,p_val_127_o                      =>ben_xrd_shd.g_old_rec.val_127
 ,p_val_128_o                      =>ben_xrd_shd.g_old_rec.val_128
 ,p_val_129_o                      =>ben_xrd_shd.g_old_rec.val_129
 ,p_val_130_o                      =>ben_xrd_shd.g_old_rec.val_130
 ,p_val_131_o                      =>ben_xrd_shd.g_old_rec.val_131
 ,p_val_132_o                      =>ben_xrd_shd.g_old_rec.val_132
 ,p_val_133_o                      =>ben_xrd_shd.g_old_rec.val_133
 ,p_val_134_o                      =>ben_xrd_shd.g_old_rec.val_134
 ,p_val_135_o                      =>ben_xrd_shd.g_old_rec.val_135
 ,p_val_136_o                      =>ben_xrd_shd.g_old_rec.val_136
 ,p_val_137_o                      =>ben_xrd_shd.g_old_rec.val_137
 ,p_val_138_o                      =>ben_xrd_shd.g_old_rec.val_138
 ,p_val_139_o                      =>ben_xrd_shd.g_old_rec.val_139
 ,p_val_140_o                      =>ben_xrd_shd.g_old_rec.val_140
 ,p_val_141_o                      =>ben_xrd_shd.g_old_rec.val_141
 ,p_val_142_o                      =>ben_xrd_shd.g_old_rec.val_142
 ,p_val_143_o                      =>ben_xrd_shd.g_old_rec.val_143
 ,p_val_144_o                      =>ben_xrd_shd.g_old_rec.val_144
 ,p_val_145_o                      =>ben_xrd_shd.g_old_rec.val_145
 ,p_val_146_o                      =>ben_xrd_shd.g_old_rec.val_146
 ,p_val_147_o                      =>ben_xrd_shd.g_old_rec.val_147
 ,p_val_148_o                      =>ben_xrd_shd.g_old_rec.val_148
 ,p_val_149_o                      =>ben_xrd_shd.g_old_rec.val_149
 ,p_val_150_o                      =>ben_xrd_shd.g_old_rec.val_150
 ,p_val_151_o                      =>ben_xrd_shd.g_old_rec.val_151
 ,p_val_152_o                      =>ben_xrd_shd.g_old_rec.val_152
 ,p_val_153_o                      =>ben_xrd_shd.g_old_rec.val_153
 ,p_val_154_o                      =>ben_xrd_shd.g_old_rec.val_154
 ,p_val_155_o                      =>ben_xrd_shd.g_old_rec.val_155
 ,p_val_156_o                      =>ben_xrd_shd.g_old_rec.val_156
 ,p_val_157_o                      =>ben_xrd_shd.g_old_rec.val_157
 ,p_val_158_o                      =>ben_xrd_shd.g_old_rec.val_158
 ,p_val_159_o                      =>ben_xrd_shd.g_old_rec.val_159
 ,p_val_160_o                      =>ben_xrd_shd.g_old_rec.val_160
 ,p_val_161_o                      =>ben_xrd_shd.g_old_rec.val_161
 ,p_val_162_o                      =>ben_xrd_shd.g_old_rec.val_162
 ,p_val_163_o                      =>ben_xrd_shd.g_old_rec.val_163
 ,p_val_164_o                      =>ben_xrd_shd.g_old_rec.val_164
 ,p_val_165_o                      =>ben_xrd_shd.g_old_rec.val_165
 ,p_val_166_o                      =>ben_xrd_shd.g_old_rec.val_166
 ,p_val_167_o                      =>ben_xrd_shd.g_old_rec.val_167
 ,p_val_168_o                      =>ben_xrd_shd.g_old_rec.val_168
 ,p_val_169_o                      =>ben_xrd_shd.g_old_rec.val_169
 ,p_val_170_o                      =>ben_xrd_shd.g_old_rec.val_170
 ,p_val_171_o                      =>ben_xrd_shd.g_old_rec.val_171
 ,p_val_172_o                      =>ben_xrd_shd.g_old_rec.val_172
 ,p_val_173_o                      =>ben_xrd_shd.g_old_rec.val_173
 ,p_val_174_o                      =>ben_xrd_shd.g_old_rec.val_174
 ,p_val_175_o                      =>ben_xrd_shd.g_old_rec.val_175
 ,p_val_176_o                      =>ben_xrd_shd.g_old_rec.val_176
 ,p_val_177_o                      =>ben_xrd_shd.g_old_rec.val_177
 ,p_val_178_o                      =>ben_xrd_shd.g_old_rec.val_178
 ,p_val_179_o                      =>ben_xrd_shd.g_old_rec.val_179
 ,p_val_180_o                      =>ben_xrd_shd.g_old_rec.val_180
 ,p_val_181_o                      =>ben_xrd_shd.g_old_rec.val_181
 ,p_val_182_o                      =>ben_xrd_shd.g_old_rec.val_182
 ,p_val_183_o                      =>ben_xrd_shd.g_old_rec.val_183
 ,p_val_184_o                      =>ben_xrd_shd.g_old_rec.val_184
 ,p_val_185_o                      =>ben_xrd_shd.g_old_rec.val_185
 ,p_val_186_o                      =>ben_xrd_shd.g_old_rec.val_186
 ,p_val_187_o                      =>ben_xrd_shd.g_old_rec.val_187
 ,p_val_188_o                      =>ben_xrd_shd.g_old_rec.val_188
 ,p_val_189_o                      =>ben_xrd_shd.g_old_rec.val_189
 ,p_val_190_o                      =>ben_xrd_shd.g_old_rec.val_190
 ,p_val_191_o                      =>ben_xrd_shd.g_old_rec.val_191
 ,p_val_192_o                      =>ben_xrd_shd.g_old_rec.val_192
 ,p_val_193_o                      =>ben_xrd_shd.g_old_rec.val_193
 ,p_val_194_o                      =>ben_xrd_shd.g_old_rec.val_194
 ,p_val_195_o                      =>ben_xrd_shd.g_old_rec.val_195
 ,p_val_196_o                      =>ben_xrd_shd.g_old_rec.val_196
 ,p_val_197_o                      =>ben_xrd_shd.g_old_rec.val_197
 ,p_val_198_o                      =>ben_xrd_shd.g_old_rec.val_198
 ,p_val_199_o                      =>ben_xrd_shd.g_old_rec.val_199
 ,p_val_200_o                      =>ben_xrd_shd.g_old_rec.val_200
 ,p_val_201_o                      =>ben_xrd_shd.g_old_rec.val_201
 ,p_val_202_o                      =>ben_xrd_shd.g_old_rec.val_202
 ,p_val_203_o                      =>ben_xrd_shd.g_old_rec.val_203
 ,p_val_204_o                      =>ben_xrd_shd.g_old_rec.val_204
 ,p_val_205_o                      =>ben_xrd_shd.g_old_rec.val_205
 ,p_val_206_o                      =>ben_xrd_shd.g_old_rec.val_206
 ,p_val_207_o                      =>ben_xrd_shd.g_old_rec.val_207
 ,p_val_208_o                      =>ben_xrd_shd.g_old_rec.val_208
 ,p_val_209_o                      =>ben_xrd_shd.g_old_rec.val_209
 ,p_val_210_o                      =>ben_xrd_shd.g_old_rec.val_210
 ,p_val_211_o                      =>ben_xrd_shd.g_old_rec.val_211
 ,p_val_212_o                      =>ben_xrd_shd.g_old_rec.val_212
 ,p_val_213_o                      =>ben_xrd_shd.g_old_rec.val_213
 ,p_val_214_o                      =>ben_xrd_shd.g_old_rec.val_214
 ,p_val_215_o                      =>ben_xrd_shd.g_old_rec.val_215
 ,p_val_216_o                      =>ben_xrd_shd.g_old_rec.val_216
 ,p_val_217_o                      =>ben_xrd_shd.g_old_rec.val_217
 ,p_val_219_o                      =>ben_xrd_shd.g_old_rec.val_219
 ,p_val_218_o                      =>ben_xrd_shd.g_old_rec.val_218
 ,p_val_220_o                      =>ben_xrd_shd.g_old_rec.val_220
 ,p_val_221_o                      =>ben_xrd_shd.g_old_rec.val_221
 ,p_val_222_o                      =>ben_xrd_shd.g_old_rec.val_222
 ,p_val_223_o                      =>ben_xrd_shd.g_old_rec.val_223
 ,p_val_224_o                      =>ben_xrd_shd.g_old_rec.val_224
 ,p_val_225_o                      =>ben_xrd_shd.g_old_rec.val_225
 ,p_val_226_o                      =>ben_xrd_shd.g_old_rec.val_226
 ,p_val_227_o                      =>ben_xrd_shd.g_old_rec.val_227
 ,p_val_228_o                      =>ben_xrd_shd.g_old_rec.val_228
 ,p_val_229_o                      =>ben_xrd_shd.g_old_rec.val_229
 ,p_val_230_o                      =>ben_xrd_shd.g_old_rec.val_230
 ,p_val_231_o                      =>ben_xrd_shd.g_old_rec.val_231
 ,p_val_232_o                      =>ben_xrd_shd.g_old_rec.val_232
 ,p_val_233_o                      =>ben_xrd_shd.g_old_rec.val_233
 ,p_val_234_o                      =>ben_xrd_shd.g_old_rec.val_234
 ,p_val_235_o                      =>ben_xrd_shd.g_old_rec.val_235
 ,p_val_236_o                      =>ben_xrd_shd.g_old_rec.val_236
 ,p_val_237_o                      =>ben_xrd_shd.g_old_rec.val_237
 ,p_val_238_o                      =>ben_xrd_shd.g_old_rec.val_238
 ,p_val_239_o                      =>ben_xrd_shd.g_old_rec.val_239
 ,p_val_240_o                      =>ben_xrd_shd.g_old_rec.val_240
 ,p_val_241_o                      =>ben_xrd_shd.g_old_rec.val_241
 ,p_val_242_o                      =>ben_xrd_shd.g_old_rec.val_242
 ,p_val_243_o                      =>ben_xrd_shd.g_old_rec.val_243
 ,p_val_244_o                      =>ben_xrd_shd.g_old_rec.val_244
 ,p_val_245_o                      =>ben_xrd_shd.g_old_rec.val_245
 ,p_val_246_o                      =>ben_xrd_shd.g_old_rec.val_246
 ,p_val_247_o                      =>ben_xrd_shd.g_old_rec.val_247
 ,p_val_248_o                      =>ben_xrd_shd.g_old_rec.val_248
 ,p_val_249_o                      =>ben_xrd_shd.g_old_rec.val_249
 ,p_val_250_o                      =>ben_xrd_shd.g_old_rec.val_250
 ,p_val_251_o                      =>ben_xrd_shd.g_old_rec.val_251
 ,p_val_252_o                      =>ben_xrd_shd.g_old_rec.val_252
 ,p_val_253_o                      =>ben_xrd_shd.g_old_rec.val_253
 ,p_val_254_o                      =>ben_xrd_shd.g_old_rec.val_254
 ,p_val_255_o                      =>ben_xrd_shd.g_old_rec.val_255
 ,p_val_256_o                      =>ben_xrd_shd.g_old_rec.val_256
 ,p_val_257_o                      =>ben_xrd_shd.g_old_rec.val_257
 ,p_val_258_o                      =>ben_xrd_shd.g_old_rec.val_258
 ,p_val_259_o                      =>ben_xrd_shd.g_old_rec.val_259
 ,p_val_260_o                      =>ben_xrd_shd.g_old_rec.val_260
 ,p_val_261_o                      =>ben_xrd_shd.g_old_rec.val_261
 ,p_val_262_o                      =>ben_xrd_shd.g_old_rec.val_262
 ,p_val_263_o                      =>ben_xrd_shd.g_old_rec.val_263
 ,p_val_264_o                      =>ben_xrd_shd.g_old_rec.val_264
 ,p_val_265_o                      =>ben_xrd_shd.g_old_rec.val_265
 ,p_val_266_o                      =>ben_xrd_shd.g_old_rec.val_266
 ,p_val_267_o                      =>ben_xrd_shd.g_old_rec.val_267
 ,p_val_268_o                      =>ben_xrd_shd.g_old_rec.val_268
 ,p_val_269_o                      =>ben_xrd_shd.g_old_rec.val_269
 ,p_val_270_o                      =>ben_xrd_shd.g_old_rec.val_270
 ,p_val_271_o                      =>ben_xrd_shd.g_old_rec.val_271
 ,p_val_272_o                      =>ben_xrd_shd.g_old_rec.val_272
 ,p_val_273_o                      =>ben_xrd_shd.g_old_rec.val_273
 ,p_val_274_o                      =>ben_xrd_shd.g_old_rec.val_274
 ,p_val_275_o                      =>ben_xrd_shd.g_old_rec.val_275
 ,p_val_276_o                      =>ben_xrd_shd.g_old_rec.val_276
 ,p_val_277_o                      =>ben_xrd_shd.g_old_rec.val_277
 ,p_val_278_o                      =>ben_xrd_shd.g_old_rec.val_278
 ,p_val_279_o                      =>ben_xrd_shd.g_old_rec.val_279
 ,p_val_280_o                      =>ben_xrd_shd.g_old_rec.val_280
 ,p_val_281_o                      =>ben_xrd_shd.g_old_rec.val_281
 ,p_val_282_o                      =>ben_xrd_shd.g_old_rec.val_282
 ,p_val_283_o                      =>ben_xrd_shd.g_old_rec.val_283
 ,p_val_284_o                      =>ben_xrd_shd.g_old_rec.val_284
 ,p_val_285_o                      =>ben_xrd_shd.g_old_rec.val_285
 ,p_val_286_o                      =>ben_xrd_shd.g_old_rec.val_286
 ,p_val_287_o                      =>ben_xrd_shd.g_old_rec.val_287
 ,p_val_288_o                      =>ben_xrd_shd.g_old_rec.val_288
 ,p_val_289_o                      =>ben_xrd_shd.g_old_rec.val_289
 ,p_val_290_o                      =>ben_xrd_shd.g_old_rec.val_290
 ,p_val_291_o                      =>ben_xrd_shd.g_old_rec.val_291
 ,p_val_292_o                      =>ben_xrd_shd.g_old_rec.val_292
 ,p_val_293_o                      =>ben_xrd_shd.g_old_rec.val_293
 ,p_val_294_o                      =>ben_xrd_shd.g_old_rec.val_294
 ,p_val_295_o                      =>ben_xrd_shd.g_old_rec.val_295
 ,p_val_296_o                      =>ben_xrd_shd.g_old_rec.val_296
 ,p_val_297_o                      =>ben_xrd_shd.g_old_rec.val_297
 ,p_val_298_o                      =>ben_xrd_shd.g_old_rec.val_298
 ,p_val_299_o                      =>ben_xrd_shd.g_old_rec.val_299
 ,p_val_300_o                      =>ben_xrd_shd.g_old_rec.val_300
 ,p_group_val_01_o                 =>ben_xrd_shd.g_old_rec.group_val_01
 ,p_group_val_02_o                 =>ben_xrd_shd.g_old_rec.group_val_02
 ,p_program_application_id_o      =>ben_xrd_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_xrd_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_xrd_shd.g_old_rec.program_update_date
 ,p_request_id_o                  =>ben_xrd_shd.g_old_rec.request_id
 ,p_object_version_number_o       =>ben_xrd_shd.g_old_rec.object_version_number
 ,p_ext_rcd_in_file_id_o          =>ben_xrd_shd.g_old_rec.ext_rcd_in_file_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_rslt_dtl'
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
  p_rec	      in ben_xrd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_xrd_shd.lck
	(
	p_rec.ext_rslt_dtl_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_xrd_bus.delete_validate(p_rec);
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
  post_delete(p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_ext_rslt_dtl_id                    in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_xrd_shd.g_rec_type;
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
  l_rec.ext_rslt_dtl_id:= p_ext_rslt_dtl_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_xrd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_xrd_del;

/
