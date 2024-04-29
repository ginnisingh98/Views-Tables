--------------------------------------------------------
--  DDL for Package Body BEN_XRD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRD_UPD" as
/* $Header: bexrdrhi.pkb 120.1 2006/02/06 11:28:36 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrd_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ben_xrd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_xrd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_ext_rslt_dtl Row
  --
  update ben_ext_rslt_dtl
  set
  ext_rslt_dtl_id                   = p_rec.ext_rslt_dtl_id,
  prmy_sort_val                     = p_rec.prmy_sort_val,
  scnd_sort_val                     = p_rec.scnd_sort_val,
  thrd_sort_val                     = p_rec.thrd_sort_val,
  trans_seq_num                     = p_rec.trans_seq_num,
  rcrd_seq_num                      = p_rec.rcrd_seq_num,
  ext_rslt_id                       = p_rec.ext_rslt_id,
  ext_rcd_id                        = p_rec.ext_rcd_id,
  person_id                         = p_rec.person_id,
  business_group_id                 = p_rec.business_group_id,
  ext_per_bg_id                     = p_rec.ext_per_bg_id,
  val_01                            = p_rec.val_01,
  val_02                            = p_rec.val_02,
  val_03                            = p_rec.val_03,
  val_04                            = p_rec.val_04,
  val_05                            = p_rec.val_05,
  val_06                            = p_rec.val_06,
  val_07                            = p_rec.val_07,
  val_08                            = p_rec.val_08,
  val_09                            = p_rec.val_09,
  val_10                            = p_rec.val_10,
  val_11                            = p_rec.val_11,
  val_12                            = p_rec.val_12,
  val_13                            = p_rec.val_13,
  val_14                            = p_rec.val_14,
  val_15                            = p_rec.val_15,
  val_16                            = p_rec.val_16,
  val_17                            = p_rec.val_17,
  val_19                            = p_rec.val_19,
  val_18                            = p_rec.val_18,
  val_20                            = p_rec.val_20,
  val_21                            = p_rec.val_21,
  val_22                            = p_rec.val_22,
  val_23                            = p_rec.val_23,
  val_24                            = p_rec.val_24,
  val_25                            = p_rec.val_25,
  val_26                            = p_rec.val_26,
  val_27                            = p_rec.val_27,
  val_28                            = p_rec.val_28,
  val_29                            = p_rec.val_29,
  val_30                            = p_rec.val_30,
  val_31                            = p_rec.val_31,
  val_32                            = p_rec.val_32,
  val_33                            = p_rec.val_33,
  val_34                            = p_rec.val_34,
  val_35                            = p_rec.val_35,
  val_36                            = p_rec.val_36,
  val_37                            = p_rec.val_37,
  val_38                            = p_rec.val_38,
  val_39                            = p_rec.val_39,
  val_40                            = p_rec.val_40,
  val_41                            = p_rec.val_41,
  val_42                            = p_rec.val_42,
  val_43                            = p_rec.val_43,
  val_44                            = p_rec.val_44,
  val_45                            = p_rec.val_45,
  val_46                            = p_rec.val_46,
  val_47                            = p_rec.val_47,
  val_48                            = p_rec.val_48,
  val_49                            = p_rec.val_49,
  val_50                            = p_rec.val_50,
  val_51                            = p_rec.val_51,
  val_52                            = p_rec.val_52,
  val_53                            = p_rec.val_53,
  val_54                            = p_rec.val_54,
  val_55                            = p_rec.val_55,
  val_56                            = p_rec.val_56,
  val_57                            = p_rec.val_57,
  val_58                            = p_rec.val_58,
  val_59                            = p_rec.val_59,
  val_60                            = p_rec.val_60,
  val_61                            = p_rec.val_61,
  val_62                            = p_rec.val_62,
  val_63                            = p_rec.val_63,
  val_64                            = p_rec.val_64,
  val_65                            = p_rec.val_65,
  val_66                            = p_rec.val_66,
  val_67                            = p_rec.val_67,
  val_68                            = p_rec.val_68,
  val_69                            = p_rec.val_69,
  val_70                            = p_rec.val_70,
  val_71                            = p_rec.val_71,
  val_72                            = p_rec.val_72,
  val_73                            = p_rec.val_73,
  val_74                            = p_rec.val_74,
  val_75                            = p_rec.val_75,
  val_76                            = p_rec.val_76,
  val_77                            = p_rec.val_77,
  val_78                            = p_rec.val_78,
  val_79                            = p_rec.val_79,
  val_80                            = p_rec.val_80,
  val_81                            = p_rec.val_81,
  val_82                            = p_rec.val_82,
  val_83                            = p_rec.val_83,
  val_84                            = p_rec.val_84,
  val_85                            = p_rec.val_85,
  val_86                            = p_rec.val_86,
  val_87                            = p_rec.val_87,
  val_88                            = p_rec.val_88,
  val_89                            = p_rec.val_89,
  val_90                            = p_rec.val_90,
  val_91                            = p_rec.val_91,
  val_92                            = p_rec.val_92,
  val_93                            = p_rec.val_93,
  val_94                            = p_rec.val_94,
  val_95                            = p_rec.val_95,
  val_96                            = p_rec.val_96,
  val_97                            = p_rec.val_97,
  val_98                            = p_rec.val_98,
  val_99                            = p_rec.val_99,
  val_100                           = p_rec.val_100,
  val_101                           = p_rec.val_101,
  val_102                            = p_rec.val_102,
  val_103                            = p_rec.val_103,
  val_104                            = p_rec.val_104,
  val_105                            = p_rec.val_105,
  val_106                            = p_rec.val_106,
  val_107                            = p_rec.val_107,
  val_108                            = p_rec.val_108,
  val_109                            = p_rec.val_109,
  val_110                            = p_rec.val_110,
  val_111                            = p_rec.val_111,
  val_112                            = p_rec.val_112,
  val_113                            = p_rec.val_113,
  val_114                            = p_rec.val_114,
  val_115                            = p_rec.val_115,
  val_116                            = p_rec.val_116,
  val_117                            = p_rec.val_117,
  val_119                            = p_rec.val_119,
  val_118                            = p_rec.val_118,
  val_120                            = p_rec.val_120,
  val_121                            = p_rec.val_121,
  val_122                            = p_rec.val_122,
  val_123                            = p_rec.val_123,
  val_124                            = p_rec.val_124,
  val_125                            = p_rec.val_125,
  val_126                            = p_rec.val_126,
  val_127                            = p_rec.val_127,
  val_128                            = p_rec.val_128,
  val_129                            = p_rec.val_129,
  val_130                            = p_rec.val_130,
  val_131                            = p_rec.val_131,
  val_132                            = p_rec.val_132,
  val_133                            = p_rec.val_133,
  val_134                            = p_rec.val_134,
  val_135                            = p_rec.val_135,
  val_136                            = p_rec.val_136,
  val_137                            = p_rec.val_137,
  val_138                            = p_rec.val_138,
  val_139                            = p_rec.val_139,
  val_140                            = p_rec.val_140,
  val_141                            = p_rec.val_141,
  val_142                            = p_rec.val_142,
  val_143                            = p_rec.val_143,
  val_144                            = p_rec.val_144,
  val_145                            = p_rec.val_145,
  val_146                            = p_rec.val_146,
  val_147                            = p_rec.val_147,
  val_148                            = p_rec.val_148,
  val_149                            = p_rec.val_149,
  val_150                            = p_rec.val_150,
  val_151                            = p_rec.val_151,
  val_152                            = p_rec.val_152,
  val_153                            = p_rec.val_153,
  val_154                            = p_rec.val_154,
  val_155                            = p_rec.val_155,
  val_156                            = p_rec.val_156,
  val_157                            = p_rec.val_157,
  val_158                            = p_rec.val_158,
  val_159                            = p_rec.val_159,
  val_160                            = p_rec.val_160,
  val_161                            = p_rec.val_161,
  val_162                            = p_rec.val_162,
  val_163                            = p_rec.val_163,
  val_164                            = p_rec.val_164,
  val_165                            = p_rec.val_165,
  val_166                            = p_rec.val_166,
  val_167                            = p_rec.val_167,
  val_168                            = p_rec.val_168,
  val_169                            = p_rec.val_169,
  val_170                            = p_rec.val_170,
  val_171                            = p_rec.val_171,
  val_172                            = p_rec.val_172,
  val_173                            = p_rec.val_173,
  val_174                            = p_rec.val_174,
  val_175                            = p_rec.val_175,
  val_176                            = p_rec.val_176,
  val_177                            = p_rec.val_177,
  val_178                            = p_rec.val_178,
  val_179                            = p_rec.val_179,
  val_180                            = p_rec.val_180,
  val_181                            = p_rec.val_181,
  val_182                            = p_rec.val_182,
  val_183                            = p_rec.val_183,
  val_184                            = p_rec.val_184,
  val_185                            = p_rec.val_185,
  val_186                            = p_rec.val_186,
  val_187                            = p_rec.val_187,
  val_188                            = p_rec.val_188,
  val_189                            = p_rec.val_189,
  val_190                            = p_rec.val_190,
  val_191                            = p_rec.val_191,
  val_192                            = p_rec.val_192,
  val_193                            = p_rec.val_193,
  val_194                            = p_rec.val_194,
  val_195                            = p_rec.val_195,
  val_196                            = p_rec.val_196,
  val_197                            = p_rec.val_197,
  val_198                            = p_rec.val_198,
  val_199                            = p_rec.val_199,
  val_200                            = p_rec.val_200,
  val_201                            = p_rec.val_201,
  val_202                            = p_rec.val_202,
  val_203                            = p_rec.val_203,
  val_204                            = p_rec.val_204,
  val_205                            = p_rec.val_205,
  val_206                            = p_rec.val_206,
  val_207                            = p_rec.val_207,
  val_208                            = p_rec.val_208,
  val_209                            = p_rec.val_209,
  val_210                            = p_rec.val_210,
  val_211                            = p_rec.val_211,
  val_212                            = p_rec.val_212,
  val_213                            = p_rec.val_213,
  val_214                            = p_rec.val_214,
  val_215                            = p_rec.val_215,
  val_216                            = p_rec.val_216,
  val_217                            = p_rec.val_217,
  val_219                            = p_rec.val_219,
  val_218                            = p_rec.val_218,
  val_220                            = p_rec.val_220,
  val_221                            = p_rec.val_221,
  val_222                            = p_rec.val_222,
  val_223                            = p_rec.val_223,
  val_224                            = p_rec.val_224,
  val_225                            = p_rec.val_225,
  val_226                            = p_rec.val_226,
  val_227                            = p_rec.val_227,
  val_228                            = p_rec.val_228,
  val_229                            = p_rec.val_229,
  val_230                            = p_rec.val_230,
  val_231                            = p_rec.val_231,
  val_232                            = p_rec.val_232,
  val_233                            = p_rec.val_233,
  val_234                            = p_rec.val_234,
  val_235                            = p_rec.val_235,
  val_236                            = p_rec.val_236,
  val_237                            = p_rec.val_237,
  val_238                            = p_rec.val_238,
  val_239                            = p_rec.val_239,
  val_240                            = p_rec.val_240,
  val_241                            = p_rec.val_241,
  val_242                            = p_rec.val_242,
  val_243                            = p_rec.val_243,
  val_244                            = p_rec.val_244,
  val_245                            = p_rec.val_245,
  val_246                            = p_rec.val_246,
  val_247                            = p_rec.val_247,
  val_248                            = p_rec.val_248,
  val_249                            = p_rec.val_249,
  val_250                            = p_rec.val_250,
  val_251                            = p_rec.val_251,
  val_252                            = p_rec.val_252,
  val_253                            = p_rec.val_253,
  val_254                            = p_rec.val_254,
  val_255                            = p_rec.val_255,
  val_256                            = p_rec.val_256,
  val_257                            = p_rec.val_257,
  val_258                            = p_rec.val_258,
  val_259                            = p_rec.val_259,
  val_260                            = p_rec.val_260,
  val_261                            = p_rec.val_261,
  val_262                            = p_rec.val_262,
  val_263                            = p_rec.val_263,
  val_264                            = p_rec.val_264,
  val_265                            = p_rec.val_265,
  val_266                            = p_rec.val_266,
  val_267                            = p_rec.val_267,
  val_268                            = p_rec.val_268,
  val_269                            = p_rec.val_269,
  val_270                            = p_rec.val_270,
  val_271                            = p_rec.val_271,
  val_272                            = p_rec.val_272,
  val_273                            = p_rec.val_273,
  val_274                            = p_rec.val_274,
  val_275                            = p_rec.val_275,
  val_276                            = p_rec.val_276,
  val_277                            = p_rec.val_277,
  val_278                            = p_rec.val_278,
  val_279                            = p_rec.val_279,
  val_280                            = p_rec.val_280,
  val_281                            = p_rec.val_281,
  val_282                            = p_rec.val_282,
  val_283                            = p_rec.val_283,
  val_284                            = p_rec.val_284,
  val_285                            = p_rec.val_285,
  val_286                            = p_rec.val_286,
  val_287                            = p_rec.val_287,
  val_288                            = p_rec.val_288,
  val_289                            = p_rec.val_289,
  val_290                            = p_rec.val_290,
  val_291                            = p_rec.val_291,
  val_292                            = p_rec.val_292,
  val_293                            = p_rec.val_293,
  val_294                            = p_rec.val_294,
  val_295                            = p_rec.val_295,
  val_296                            = p_rec.val_296,
  val_297                            = p_rec.val_297,
  val_298                            = p_rec.val_298,
  val_299                            = p_rec.val_299,
  val_300                            = p_rec.val_300,
  group_val_01                       = p_rec.group_val_01,
  group_val_02                       = p_rec.group_val_02,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  request_id                        = p_rec.request_id,
  object_version_number             = p_rec.object_version_number,
  ext_rcd_in_file_id                = p_rec.ext_rcd_in_file_id
  where ext_rslt_dtl_id = p_rec.ext_rslt_dtl_id;
  --
  ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xrd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xrd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xrd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xrd_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ben_xrd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ben_xrd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_xrd_rku.after_update
      (
  p_ext_rslt_dtl_id               =>p_rec.ext_rslt_dtl_id
 ,p_prmy_sort_val                 =>p_rec.prmy_sort_val
 ,p_scnd_sort_val                 =>p_rec.scnd_sort_val
 ,p_thrd_sort_val                 =>p_rec.thrd_sort_val
 ,p_trans_seq_num                 =>p_rec.trans_seq_num
 ,p_rcrd_seq_num                  =>p_rec.rcrd_seq_num
 ,p_ext_rslt_id                   =>p_rec.ext_rslt_id
 ,p_ext_rcd_id                    =>p_rec.ext_rcd_id
 ,p_person_id                     =>p_rec.person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_ext_per_bg_id                 =>p_rec.ext_per_bg_id
 ,p_val_01                        =>p_rec.val_01
 ,p_val_02                        =>p_rec.val_02
 ,p_val_03                        =>p_rec.val_03
 ,p_val_04                        =>p_rec.val_04
 ,p_val_05                        =>p_rec.val_05
 ,p_val_06                        =>p_rec.val_06
 ,p_val_07                        =>p_rec.val_07
 ,p_val_08                        =>p_rec.val_08
 ,p_val_09                        =>p_rec.val_09
 ,p_val_10                        =>p_rec.val_10
 ,p_val_11                        =>p_rec.val_11
 ,p_val_12                        =>p_rec.val_12
 ,p_val_13                        =>p_rec.val_13
 ,p_val_14                        =>p_rec.val_14
 ,p_val_15                        =>p_rec.val_15
 ,p_val_16                        =>p_rec.val_16
 ,p_val_17                        =>p_rec.val_17
 ,p_val_19                        =>p_rec.val_19
 ,p_val_18                        =>p_rec.val_18
 ,p_val_20                        =>p_rec.val_20
 ,p_val_21                        =>p_rec.val_21
 ,p_val_22                        =>p_rec.val_22
 ,p_val_23                        =>p_rec.val_23
 ,p_val_24                        =>p_rec.val_24
 ,p_val_25                        =>p_rec.val_25
 ,p_val_26                        =>p_rec.val_26
 ,p_val_27                        =>p_rec.val_27
 ,p_val_28                        =>p_rec.val_28
 ,p_val_29                        =>p_rec.val_29
 ,p_val_30                        =>p_rec.val_30
 ,p_val_31                        =>p_rec.val_31
 ,p_val_32                        =>p_rec.val_32
 ,p_val_33                        =>p_rec.val_33
 ,p_val_34                        =>p_rec.val_34
 ,p_val_35                        =>p_rec.val_35
 ,p_val_36                        =>p_rec.val_36
 ,p_val_37                        =>p_rec.val_37
 ,p_val_38                        =>p_rec.val_38
 ,p_val_39                        =>p_rec.val_39
 ,p_val_40                        =>p_rec.val_40
 ,p_val_41                        =>p_rec.val_41
 ,p_val_42                        =>p_rec.val_42
 ,p_val_43                        =>p_rec.val_43
 ,p_val_44                        =>p_rec.val_44
 ,p_val_45                        =>p_rec.val_45
 ,p_val_46                        =>p_rec.val_46
 ,p_val_47                        =>p_rec.val_47
 ,p_val_48                        =>p_rec.val_48
 ,p_val_49                        =>p_rec.val_49
 ,p_val_50                        =>p_rec.val_50
 ,p_val_51                        =>p_rec.val_51
 ,p_val_52                        =>p_rec.val_52
 ,p_val_53                        =>p_rec.val_53
 ,p_val_54                        =>p_rec.val_54
 ,p_val_55                        =>p_rec.val_55
 ,p_val_56                        =>p_rec.val_56
 ,p_val_57                        =>p_rec.val_57
 ,p_val_58                        =>p_rec.val_58
 ,p_val_59                        =>p_rec.val_59
 ,p_val_60                        =>p_rec.val_60
 ,p_val_61                        =>p_rec.val_61
 ,p_val_62                        =>p_rec.val_62
 ,p_val_63                        =>p_rec.val_63
 ,p_val_64                        =>p_rec.val_64
 ,p_val_65                        =>p_rec.val_65
 ,p_val_66                        =>p_rec.val_66
 ,p_val_67                        =>p_rec.val_67
 ,p_val_68                        =>p_rec.val_68
 ,p_val_69                        =>p_rec.val_69
 ,p_val_70                        =>p_rec.val_70
 ,p_val_71                        =>p_rec.val_71
 ,p_val_72                        =>p_rec.val_72
 ,p_val_73                        =>p_rec.val_73
 ,p_val_74                        =>p_rec.val_74
 ,p_val_75                        =>p_rec.val_75
 ,p_val_76                        =>p_rec.val_76
 ,p_val_77                        =>p_rec.val_77
 ,p_val_78                        =>p_rec.val_78
 ,p_val_79                        =>p_rec.val_79
 ,p_val_80                        =>p_rec.val_80
 ,p_val_81                        =>p_rec.val_81
 ,p_val_82                        =>p_rec.val_82
 ,p_val_83                        =>p_rec.val_83
 ,p_val_84                        =>p_rec.val_84
 ,p_val_85                        =>p_rec.val_85
 ,p_val_86                        =>p_rec.val_86
 ,p_val_87                        =>p_rec.val_87
 ,p_val_88                        =>p_rec.val_88
 ,p_val_89                        =>p_rec.val_89
 ,p_val_90                        =>p_rec.val_90
 ,p_val_91                        =>p_rec.val_91
 ,p_val_92                        =>p_rec.val_92
 ,p_val_93                        =>p_rec.val_93
 ,p_val_94                        =>p_rec.val_94
 ,p_val_95                        =>p_rec.val_95
 ,p_val_96                        =>p_rec.val_96
 ,p_val_97                        =>p_rec.val_97
 ,p_val_98                        =>p_rec.val_98
 ,p_val_99                        =>p_rec.val_99
 ,p_val_100                       =>p_rec.val_100
 ,p_val_101                       =>p_rec.val_101
 ,p_val_102                        =>p_rec.val_102
 ,p_val_103                        =>p_rec.val_103
 ,p_val_104                        =>p_rec.val_104
 ,p_val_105                        =>p_rec.val_105
 ,p_val_106                        =>p_rec.val_106
 ,p_val_107                        =>p_rec.val_107
 ,p_val_108                        =>p_rec.val_108
 ,p_val_109                        =>p_rec.val_109
 ,p_val_110                        =>p_rec.val_110
 ,p_val_111                        =>p_rec.val_111
 ,p_val_112                        =>p_rec.val_112
 ,p_val_113                        =>p_rec.val_113
 ,p_val_114                        =>p_rec.val_114
 ,p_val_115                        =>p_rec.val_115
 ,p_val_116                        =>p_rec.val_116
 ,p_val_117                        =>p_rec.val_117
 ,p_val_119                        =>p_rec.val_119
 ,p_val_118                        =>p_rec.val_118
 ,p_val_120                        =>p_rec.val_120
 ,p_val_121                        =>p_rec.val_121
 ,p_val_122                        =>p_rec.val_122
 ,p_val_123                        =>p_rec.val_123
 ,p_val_124                        =>p_rec.val_124
 ,p_val_125                        =>p_rec.val_125
 ,p_val_126                        =>p_rec.val_126
 ,p_val_127                        =>p_rec.val_127
 ,p_val_128                        =>p_rec.val_128
 ,p_val_129                        =>p_rec.val_129
 ,p_val_130                        =>p_rec.val_130
 ,p_val_131                        =>p_rec.val_131
 ,p_val_132                        =>p_rec.val_132
 ,p_val_133                        =>p_rec.val_133
 ,p_val_134                        =>p_rec.val_134
 ,p_val_135                        =>p_rec.val_135
 ,p_val_136                        =>p_rec.val_136
 ,p_val_137                        =>p_rec.val_137
 ,p_val_138                        =>p_rec.val_138
 ,p_val_139                        =>p_rec.val_139
 ,p_val_140                        =>p_rec.val_140
 ,p_val_141                        =>p_rec.val_141
 ,p_val_142                        =>p_rec.val_142
 ,p_val_143                        =>p_rec.val_143
 ,p_val_144                        =>p_rec.val_144
 ,p_val_145                        =>p_rec.val_145
 ,p_val_146                        =>p_rec.val_146
 ,p_val_147                        =>p_rec.val_147
 ,p_val_148                        =>p_rec.val_148
 ,p_val_149                        =>p_rec.val_149
 ,p_val_150                        =>p_rec.val_150
 ,p_val_151                        =>p_rec.val_151
 ,p_val_152                        =>p_rec.val_152
 ,p_val_153                        =>p_rec.val_153
 ,p_val_154                        =>p_rec.val_154
 ,p_val_155                        =>p_rec.val_155
 ,p_val_156                        =>p_rec.val_156
 ,p_val_157                        =>p_rec.val_157
 ,p_val_158                        =>p_rec.val_158
 ,p_val_159                        =>p_rec.val_159
 ,p_val_160                        =>p_rec.val_160
 ,p_val_161                        =>p_rec.val_161
 ,p_val_162                        =>p_rec.val_162
 ,p_val_163                        =>p_rec.val_163
 ,p_val_164                        =>p_rec.val_164
 ,p_val_165                        =>p_rec.val_165
 ,p_val_166                        =>p_rec.val_166
 ,p_val_167                        =>p_rec.val_167
 ,p_val_168                        =>p_rec.val_168
 ,p_val_169                        =>p_rec.val_169
 ,p_val_170                        =>p_rec.val_170
 ,p_val_171                        =>p_rec.val_171
 ,p_val_172                        =>p_rec.val_172
 ,p_val_173                        =>p_rec.val_173
 ,p_val_174                        =>p_rec.val_174
 ,p_val_175                        =>p_rec.val_175
 ,p_val_176                        =>p_rec.val_176
 ,p_val_177                        =>p_rec.val_177
 ,p_val_178                        =>p_rec.val_178
 ,p_val_179                        =>p_rec.val_179
 ,p_val_180                        =>p_rec.val_180
 ,p_val_181                        =>p_rec.val_181
 ,p_val_182                        =>p_rec.val_182
 ,p_val_183                        =>p_rec.val_183
 ,p_val_184                        =>p_rec.val_184
 ,p_val_185                        =>p_rec.val_185
 ,p_val_186                        =>p_rec.val_186
 ,p_val_187                        =>p_rec.val_187
 ,p_val_188                        =>p_rec.val_188
 ,p_val_189                        =>p_rec.val_189
 ,p_val_190                        =>p_rec.val_190
 ,p_val_191                        =>p_rec.val_191
 ,p_val_192                        =>p_rec.val_192
 ,p_val_193                        =>p_rec.val_193
 ,p_val_194                        =>p_rec.val_194
 ,p_val_195                        =>p_rec.val_195
 ,p_val_196                        =>p_rec.val_196
 ,p_val_197                        =>p_rec.val_197
 ,p_val_198                        =>p_rec.val_198
 ,p_val_199                        =>p_rec.val_199
 ,p_val_200                        =>p_rec.val_200
 ,p_val_201                        =>p_rec.val_201
 ,p_val_202                        =>p_rec.val_202
 ,p_val_203                        =>p_rec.val_203
 ,p_val_204                        =>p_rec.val_204
 ,p_val_205                        =>p_rec.val_205
 ,p_val_206                        =>p_rec.val_206
 ,p_val_207                        =>p_rec.val_207
 ,p_val_208                        =>p_rec.val_208
 ,p_val_209                        =>p_rec.val_209
 ,p_val_210                        =>p_rec.val_210
 ,p_val_211                        =>p_rec.val_211
 ,p_val_212                        =>p_rec.val_212
 ,p_val_213                        =>p_rec.val_213
 ,p_val_214                        =>p_rec.val_214
 ,p_val_215                        =>p_rec.val_215
 ,p_val_216                        =>p_rec.val_216
 ,p_val_217                        =>p_rec.val_217
 ,p_val_219                        =>p_rec.val_219
 ,p_val_218                        =>p_rec.val_218
 ,p_val_220                        =>p_rec.val_220
 ,p_val_221                        =>p_rec.val_221
 ,p_val_222                        =>p_rec.val_222
 ,p_val_223                        =>p_rec.val_223
 ,p_val_224                        =>p_rec.val_224
 ,p_val_225                        =>p_rec.val_225
 ,p_val_226                        =>p_rec.val_226
 ,p_val_227                        =>p_rec.val_227
 ,p_val_228                        =>p_rec.val_228
 ,p_val_229                        =>p_rec.val_229
 ,p_val_230                        =>p_rec.val_230
 ,p_val_231                        =>p_rec.val_231
 ,p_val_232                        =>p_rec.val_232
 ,p_val_233                        =>p_rec.val_233
 ,p_val_234                        =>p_rec.val_234
 ,p_val_235                        =>p_rec.val_235
 ,p_val_236                        =>p_rec.val_236
 ,p_val_237                        =>p_rec.val_237
 ,p_val_238                        =>p_rec.val_238
 ,p_val_239                        =>p_rec.val_239
 ,p_val_240                        =>p_rec.val_240
 ,p_val_241                        =>p_rec.val_241
 ,p_val_242                        =>p_rec.val_242
 ,p_val_243                        =>p_rec.val_243
 ,p_val_244                        =>p_rec.val_244
 ,p_val_245                        =>p_rec.val_245
 ,p_val_246                        =>p_rec.val_246
 ,p_val_247                        =>p_rec.val_247
 ,p_val_248                        =>p_rec.val_248
 ,p_val_249                        =>p_rec.val_249
 ,p_val_250                        =>p_rec.val_250
 ,p_val_251                        =>p_rec.val_251
 ,p_val_252                        =>p_rec.val_252
 ,p_val_253                        =>p_rec.val_253
 ,p_val_254                        =>p_rec.val_254
 ,p_val_255                        =>p_rec.val_255
 ,p_val_256                        =>p_rec.val_256
 ,p_val_257                        =>p_rec.val_257
 ,p_val_258                        =>p_rec.val_258
 ,p_val_259                        =>p_rec.val_259
 ,p_val_260                        =>p_rec.val_260
 ,p_val_261                        =>p_rec.val_261
 ,p_val_262                        =>p_rec.val_262
 ,p_val_263                        =>p_rec.val_263
 ,p_val_264                        =>p_rec.val_264
 ,p_val_265                        =>p_rec.val_265
 ,p_val_266                        =>p_rec.val_266
 ,p_val_267                        =>p_rec.val_267
 ,p_val_268                        =>p_rec.val_268
 ,p_val_269                        =>p_rec.val_269
 ,p_val_270                        =>p_rec.val_270
 ,p_val_271                        =>p_rec.val_271
 ,p_val_272                        =>p_rec.val_272
 ,p_val_273                        =>p_rec.val_273
 ,p_val_274                        =>p_rec.val_274
 ,p_val_275                        =>p_rec.val_275
 ,p_val_276                        =>p_rec.val_276
 ,p_val_277                        =>p_rec.val_277
 ,p_val_278                        =>p_rec.val_278
 ,p_val_279                        =>p_rec.val_279
 ,p_val_280                        =>p_rec.val_280
 ,p_val_281                        =>p_rec.val_281
 ,p_val_282                        =>p_rec.val_282
 ,p_val_283                        =>p_rec.val_283
 ,p_val_284                        =>p_rec.val_284
 ,p_val_285                        =>p_rec.val_285
 ,p_val_286                        =>p_rec.val_286
 ,p_val_287                        =>p_rec.val_287
 ,p_val_288                        =>p_rec.val_288
 ,p_val_289                        =>p_rec.val_289
 ,p_val_290                        =>p_rec.val_290
 ,p_val_291                        =>p_rec.val_291
 ,p_val_292                        =>p_rec.val_292
 ,p_val_293                        =>p_rec.val_293
 ,p_val_294                        =>p_rec.val_294
 ,p_val_295                        =>p_rec.val_295
 ,p_val_296                        =>p_rec.val_296
 ,p_val_297                        =>p_rec.val_297
 ,p_val_298                        =>p_rec.val_298
 ,p_val_299                        =>p_rec.val_299
 ,p_val_300                        =>p_rec.val_300
 ,p_group_val_01                   => p_rec.group_val_01
 ,p_group_val_02                   => p_rec.group_val_02
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_request_id                    =>p_rec.request_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_ext_rcd_in_file_id            =>p_rec.ext_rcd_in_file_id
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
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_xrd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.prmy_sort_val = hr_api.g_varchar2) then
    p_rec.prmy_sort_val :=
    ben_xrd_shd.g_old_rec.prmy_sort_val;
  End If;
  If (p_rec.scnd_sort_val = hr_api.g_varchar2) then
    p_rec.scnd_sort_val :=
    ben_xrd_shd.g_old_rec.scnd_sort_val;
  End If;
  If (p_rec.thrd_sort_val = hr_api.g_varchar2) then
    p_rec.thrd_sort_val :=
    ben_xrd_shd.g_old_rec.thrd_sort_val;
  End If;
  If (p_rec.trans_seq_num = hr_api.g_number) then
    p_rec.trans_seq_num :=
    ben_xrd_shd.g_old_rec.trans_seq_num;
  End If;
  If (p_rec.rcrd_seq_num = hr_api.g_number) then
    p_rec.rcrd_seq_num :=
    ben_xrd_shd.g_old_rec.rcrd_seq_num;
  End If;
  If (p_rec.ext_rslt_id = hr_api.g_number) then
    p_rec.ext_rslt_id :=
    ben_xrd_shd.g_old_rec.ext_rslt_id;
  End If;
  If (p_rec.ext_rcd_id = hr_api.g_number) then
    p_rec.ext_rcd_id :=
    ben_xrd_shd.g_old_rec.ext_rcd_id;
  End If;

  If (p_rec.ext_rcd_in_file_id = hr_api.g_number) then
    p_rec.ext_rcd_in_file_id :=
    ben_xrd_shd.g_old_rec.ext_rcd_in_file_id;
  End If;

  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_xrd_shd.g_old_rec.person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_xrd_shd.g_old_rec.business_group_id;
  End If;

  If (p_rec.ext_per_bg_id = hr_api.g_number) then
    p_rec.ext_per_bg_id :=
    ben_xrd_shd.g_old_rec.ext_per_bg_id;
  End If;

  If (p_rec.val_01 = hr_api.g_varchar2) then
    p_rec.val_01 :=
    ben_xrd_shd.g_old_rec.val_01;
  End If;
  If (p_rec.val_02 = hr_api.g_varchar2) then
    p_rec.val_02 :=
    ben_xrd_shd.g_old_rec.val_02;
  End If;
  If (p_rec.val_03 = hr_api.g_varchar2) then
    p_rec.val_03 :=
    ben_xrd_shd.g_old_rec.val_03;
  End If;
  If (p_rec.val_04 = hr_api.g_varchar2) then
    p_rec.val_04 :=
    ben_xrd_shd.g_old_rec.val_04;
  End If;
  If (p_rec.val_05 = hr_api.g_varchar2) then
    p_rec.val_05 :=
    ben_xrd_shd.g_old_rec.val_05;
  End If;
  If (p_rec.val_06 = hr_api.g_varchar2) then
    p_rec.val_06 :=
    ben_xrd_shd.g_old_rec.val_06;
  End If;
  If (p_rec.val_07 = hr_api.g_varchar2) then
    p_rec.val_07 :=
    ben_xrd_shd.g_old_rec.val_07;
  End If;
  If (p_rec.val_08 = hr_api.g_varchar2) then
    p_rec.val_08 :=
    ben_xrd_shd.g_old_rec.val_08;
  End If;
  If (p_rec.val_09 = hr_api.g_varchar2) then
    p_rec.val_09 :=
    ben_xrd_shd.g_old_rec.val_09;
  End If;
  If (p_rec.val_10 = hr_api.g_varchar2) then
    p_rec.val_10 :=
    ben_xrd_shd.g_old_rec.val_10;
  End If;
  If (p_rec.val_11 = hr_api.g_varchar2) then
    p_rec.val_11 :=
    ben_xrd_shd.g_old_rec.val_11;
  End If;
  If (p_rec.val_12 = hr_api.g_varchar2) then
    p_rec.val_12 :=
    ben_xrd_shd.g_old_rec.val_12;
  End If;
  If (p_rec.val_13 = hr_api.g_varchar2) then
    p_rec.val_13 :=
    ben_xrd_shd.g_old_rec.val_13;
  End If;
  If (p_rec.val_14 = hr_api.g_varchar2) then
    p_rec.val_14 :=
    ben_xrd_shd.g_old_rec.val_14;
  End If;
  If (p_rec.val_15 = hr_api.g_varchar2) then
    p_rec.val_15 :=
    ben_xrd_shd.g_old_rec.val_15;
  End If;
  If (p_rec.val_16 = hr_api.g_varchar2) then
    p_rec.val_16 :=
    ben_xrd_shd.g_old_rec.val_16;
  End If;
  If (p_rec.val_17 = hr_api.g_varchar2) then
    p_rec.val_17 :=
    ben_xrd_shd.g_old_rec.val_17;
  End If;
  If (p_rec.val_19 = hr_api.g_varchar2) then
    p_rec.val_19 :=
    ben_xrd_shd.g_old_rec.val_19;
  End If;
  If (p_rec.val_18 = hr_api.g_varchar2) then
    p_rec.val_18 :=
    ben_xrd_shd.g_old_rec.val_18;
  End If;
  If (p_rec.val_20 = hr_api.g_varchar2) then
    p_rec.val_20 :=
    ben_xrd_shd.g_old_rec.val_20;
  End If;
  If (p_rec.val_21 = hr_api.g_varchar2) then
    p_rec.val_21 :=
    ben_xrd_shd.g_old_rec.val_21;
  End If;
  If (p_rec.val_22 = hr_api.g_varchar2) then
    p_rec.val_22 :=
    ben_xrd_shd.g_old_rec.val_22;
  End If;
  If (p_rec.val_23 = hr_api.g_varchar2) then
    p_rec.val_23 :=
    ben_xrd_shd.g_old_rec.val_23;
  End If;
  If (p_rec.val_24 = hr_api.g_varchar2) then
    p_rec.val_24 :=
    ben_xrd_shd.g_old_rec.val_24;
  End If;
  If (p_rec.val_25 = hr_api.g_varchar2) then
    p_rec.val_25 :=
    ben_xrd_shd.g_old_rec.val_25;
  End If;
  If (p_rec.val_26 = hr_api.g_varchar2) then
    p_rec.val_26 :=
    ben_xrd_shd.g_old_rec.val_26;
  End If;
  If (p_rec.val_27 = hr_api.g_varchar2) then
    p_rec.val_27 :=
    ben_xrd_shd.g_old_rec.val_27;
  End If;
  If (p_rec.val_28 = hr_api.g_varchar2) then
    p_rec.val_28 :=
    ben_xrd_shd.g_old_rec.val_28;
  End If;
  If (p_rec.val_29 = hr_api.g_varchar2) then
    p_rec.val_29 :=
    ben_xrd_shd.g_old_rec.val_29;
  End If;
  If (p_rec.val_30 = hr_api.g_varchar2) then
    p_rec.val_30 :=
    ben_xrd_shd.g_old_rec.val_30;
  End If;
  If (p_rec.val_31 = hr_api.g_varchar2) then
    p_rec.val_31 :=
    ben_xrd_shd.g_old_rec.val_31;
  End If;
  If (p_rec.val_32 = hr_api.g_varchar2) then
    p_rec.val_32 :=
    ben_xrd_shd.g_old_rec.val_32;
  End If;
  If (p_rec.val_33 = hr_api.g_varchar2) then
    p_rec.val_33 :=
    ben_xrd_shd.g_old_rec.val_33;
  End If;
  If (p_rec.val_34 = hr_api.g_varchar2) then
    p_rec.val_34 :=
    ben_xrd_shd.g_old_rec.val_34;
  End If;
  If (p_rec.val_35 = hr_api.g_varchar2) then
    p_rec.val_35 :=
    ben_xrd_shd.g_old_rec.val_35;
  End If;
  If (p_rec.val_36 = hr_api.g_varchar2) then
    p_rec.val_36 :=
    ben_xrd_shd.g_old_rec.val_36;
  End If;
  If (p_rec.val_37 = hr_api.g_varchar2) then
    p_rec.val_37 :=
    ben_xrd_shd.g_old_rec.val_37;
  End If;
  If (p_rec.val_38 = hr_api.g_varchar2) then
    p_rec.val_38 :=
    ben_xrd_shd.g_old_rec.val_38;
  End If;
  If (p_rec.val_39 = hr_api.g_varchar2) then
    p_rec.val_39 :=
    ben_xrd_shd.g_old_rec.val_39;
  End If;
  If (p_rec.val_40 = hr_api.g_varchar2) then
    p_rec.val_40 :=
    ben_xrd_shd.g_old_rec.val_40;
  End If;
  If (p_rec.val_41 = hr_api.g_varchar2) then
    p_rec.val_41 :=
    ben_xrd_shd.g_old_rec.val_41;
  End If;
  If (p_rec.val_42 = hr_api.g_varchar2) then
    p_rec.val_42 :=
    ben_xrd_shd.g_old_rec.val_42;
  End If;
  If (p_rec.val_43 = hr_api.g_varchar2) then
    p_rec.val_43 :=
    ben_xrd_shd.g_old_rec.val_43;
  End If;
  If (p_rec.val_44 = hr_api.g_varchar2) then
    p_rec.val_44 :=
    ben_xrd_shd.g_old_rec.val_44;
  End If;
  If (p_rec.val_45 = hr_api.g_varchar2) then
    p_rec.val_45 :=
    ben_xrd_shd.g_old_rec.val_45;
  End If;
  If (p_rec.val_46 = hr_api.g_varchar2) then
    p_rec.val_46 :=
    ben_xrd_shd.g_old_rec.val_46;
  End If;
  If (p_rec.val_47 = hr_api.g_varchar2) then
    p_rec.val_47 :=
    ben_xrd_shd.g_old_rec.val_47;
  End If;
  If (p_rec.val_48 = hr_api.g_varchar2) then
    p_rec.val_48 :=
    ben_xrd_shd.g_old_rec.val_48;
  End If;
  If (p_rec.val_49 = hr_api.g_varchar2) then
    p_rec.val_49 :=
    ben_xrd_shd.g_old_rec.val_49;
  End If;
  If (p_rec.val_50 = hr_api.g_varchar2) then
    p_rec.val_50 :=
    ben_xrd_shd.g_old_rec.val_50;
  End If;
  If (p_rec.val_51 = hr_api.g_varchar2) then
    p_rec.val_51 :=
    ben_xrd_shd.g_old_rec.val_51;
  End If;
  If (p_rec.val_52 = hr_api.g_varchar2) then
    p_rec.val_52 :=
    ben_xrd_shd.g_old_rec.val_52;
  End If;
  If (p_rec.val_53 = hr_api.g_varchar2) then
    p_rec.val_53 :=
    ben_xrd_shd.g_old_rec.val_53;
  End If;
  If (p_rec.val_54 = hr_api.g_varchar2) then
    p_rec.val_54 :=
    ben_xrd_shd.g_old_rec.val_54;
  End If;
  If (p_rec.val_55 = hr_api.g_varchar2) then
    p_rec.val_55 :=
    ben_xrd_shd.g_old_rec.val_55;
  End If;
  If (p_rec.val_56 = hr_api.g_varchar2) then
    p_rec.val_56 :=
    ben_xrd_shd.g_old_rec.val_56;
  End If;
  If (p_rec.val_57 = hr_api.g_varchar2) then
    p_rec.val_57 :=
    ben_xrd_shd.g_old_rec.val_57;
  End If;
  If (p_rec.val_58 = hr_api.g_varchar2) then
    p_rec.val_58 :=
    ben_xrd_shd.g_old_rec.val_58;
  End If;
  If (p_rec.val_59 = hr_api.g_varchar2) then
    p_rec.val_59 :=
    ben_xrd_shd.g_old_rec.val_59;
  End If;
  If (p_rec.val_60 = hr_api.g_varchar2) then
    p_rec.val_60 :=
    ben_xrd_shd.g_old_rec.val_60;
  End If;
  If (p_rec.val_61 = hr_api.g_varchar2) then
    p_rec.val_61 :=
    ben_xrd_shd.g_old_rec.val_61;
  End If;
  If (p_rec.val_62 = hr_api.g_varchar2) then
    p_rec.val_62 :=
    ben_xrd_shd.g_old_rec.val_62;
  End If;
  If (p_rec.val_63 = hr_api.g_varchar2) then
    p_rec.val_63 :=
    ben_xrd_shd.g_old_rec.val_63;
  End If;
  If (p_rec.val_64 = hr_api.g_varchar2) then
    p_rec.val_64 :=
    ben_xrd_shd.g_old_rec.val_64;
  End If;
  If (p_rec.val_65 = hr_api.g_varchar2) then
    p_rec.val_65 :=
    ben_xrd_shd.g_old_rec.val_65;
  End If;
  If (p_rec.val_66 = hr_api.g_varchar2) then
    p_rec.val_66 :=
    ben_xrd_shd.g_old_rec.val_66;
  End If;
  If (p_rec.val_67 = hr_api.g_varchar2) then
    p_rec.val_67 :=
    ben_xrd_shd.g_old_rec.val_67;
  End If;
  If (p_rec.val_68 = hr_api.g_varchar2) then
    p_rec.val_68 :=
    ben_xrd_shd.g_old_rec.val_68;
  End If;
  If (p_rec.val_69 = hr_api.g_varchar2) then
    p_rec.val_69 :=
    ben_xrd_shd.g_old_rec.val_69;
  End If;
  If (p_rec.val_70 = hr_api.g_varchar2) then
    p_rec.val_70 :=
    ben_xrd_shd.g_old_rec.val_70;
  End If;
  If (p_rec.val_71 = hr_api.g_varchar2) then
    p_rec.val_71 :=
    ben_xrd_shd.g_old_rec.val_71;
  End If;
  If (p_rec.val_72 = hr_api.g_varchar2) then
    p_rec.val_72 :=
    ben_xrd_shd.g_old_rec.val_72;
  End If;
  If (p_rec.val_73 = hr_api.g_varchar2) then
    p_rec.val_73 :=
    ben_xrd_shd.g_old_rec.val_73;
  End If;
  If (p_rec.val_74 = hr_api.g_varchar2) then
    p_rec.val_74 :=
    ben_xrd_shd.g_old_rec.val_74;
  End If;
  If (p_rec.val_75 = hr_api.g_varchar2) then
    p_rec.val_75 :=
    ben_xrd_shd.g_old_rec.val_75;
  End If;
  If (p_rec.val_76 = hr_api.g_varchar2) then
    p_rec.val_76 :=
    ben_xrd_shd.g_old_rec.val_76;
  End If;
  If (p_rec.val_77 = hr_api.g_varchar2) then
    p_rec.val_77 :=
    ben_xrd_shd.g_old_rec.val_77;
  End If;
  If (p_rec.val_78 = hr_api.g_varchar2) then
    p_rec.val_78 :=
    ben_xrd_shd.g_old_rec.val_78;
  End If;
  If (p_rec.val_79 = hr_api.g_varchar2) then
    p_rec.val_79 :=
    ben_xrd_shd.g_old_rec.val_79;
  End If;
  If (p_rec.val_80 = hr_api.g_varchar2) then
    p_rec.val_80 :=
    ben_xrd_shd.g_old_rec.val_80;
  End If;
  If (p_rec.val_81 = hr_api.g_varchar2) then
    p_rec.val_81 :=
    ben_xrd_shd.g_old_rec.val_81;
  End If;
  If (p_rec.val_82 = hr_api.g_varchar2) then
    p_rec.val_82 :=
    ben_xrd_shd.g_old_rec.val_82;
  End If;
  If (p_rec.val_83 = hr_api.g_varchar2) then
    p_rec.val_83 :=
    ben_xrd_shd.g_old_rec.val_83;
  End If;
  If (p_rec.val_84 = hr_api.g_varchar2) then
    p_rec.val_84 :=
    ben_xrd_shd.g_old_rec.val_84;
  End If;
  If (p_rec.val_85 = hr_api.g_varchar2) then
    p_rec.val_85 :=
    ben_xrd_shd.g_old_rec.val_85;
  End If;
  If (p_rec.val_86 = hr_api.g_varchar2) then
    p_rec.val_86 :=
    ben_xrd_shd.g_old_rec.val_86;
  End If;
  If (p_rec.val_87 = hr_api.g_varchar2) then
    p_rec.val_87 :=
    ben_xrd_shd.g_old_rec.val_87;
  End If;
  If (p_rec.val_88 = hr_api.g_varchar2) then
    p_rec.val_88 :=
    ben_xrd_shd.g_old_rec.val_88;
  End If;
  If (p_rec.val_89 = hr_api.g_varchar2) then
    p_rec.val_89 :=
    ben_xrd_shd.g_old_rec.val_89;
  End If;
  If (p_rec.val_90 = hr_api.g_varchar2) then
    p_rec.val_90 :=
    ben_xrd_shd.g_old_rec.val_90;
  End If;
  If (p_rec.val_91 = hr_api.g_varchar2) then
    p_rec.val_91 :=
    ben_xrd_shd.g_old_rec.val_91;
  End If;
  If (p_rec.val_92 = hr_api.g_varchar2) then
    p_rec.val_92 :=
    ben_xrd_shd.g_old_rec.val_92;
  End If;
  If (p_rec.val_93 = hr_api.g_varchar2) then
    p_rec.val_93 :=
    ben_xrd_shd.g_old_rec.val_93;
  End If;
  If (p_rec.val_94 = hr_api.g_varchar2) then
    p_rec.val_94 :=
    ben_xrd_shd.g_old_rec.val_94;
  End If;
  If (p_rec.val_95 = hr_api.g_varchar2) then
    p_rec.val_95 :=
    ben_xrd_shd.g_old_rec.val_95;
  End If;
  If (p_rec.val_96 = hr_api.g_varchar2) then
    p_rec.val_96 :=
    ben_xrd_shd.g_old_rec.val_96;
  End If;
  If (p_rec.val_97 = hr_api.g_varchar2) then
    p_rec.val_97 :=
    ben_xrd_shd.g_old_rec.val_97;
  End If;
  If (p_rec.val_98 = hr_api.g_varchar2) then
    p_rec.val_98 :=
    ben_xrd_shd.g_old_rec.val_98;
  End If;
  If (p_rec.val_99 = hr_api.g_varchar2) then
    p_rec.val_99 :=
    ben_xrd_shd.g_old_rec.val_99;
  End If;
  If (p_rec.val_100 = hr_api.g_varchar2) then
    p_rec.val_100 :=
    ben_xrd_shd.g_old_rec.val_100;
  End If;
  ---
  If (p_rec.val_101 = hr_api.g_varchar2) then
    p_rec.val_101 :=
    ben_xrd_shd.g_old_rec.val_101;
  End If;
  If (p_rec.val_102 = hr_api.g_varchar2) then
    p_rec.val_102 :=
    ben_xrd_shd.g_old_rec.val_102;
  End If;
  If (p_rec.val_103 = hr_api.g_varchar2) then
    p_rec.val_103 :=
    ben_xrd_shd.g_old_rec.val_103;
  End If;
  If (p_rec.val_104 = hr_api.g_varchar2) then
    p_rec.val_104 :=
    ben_xrd_shd.g_old_rec.val_104;
  End If;
  If (p_rec.val_105 = hr_api.g_varchar2) then
    p_rec.val_105 :=
    ben_xrd_shd.g_old_rec.val_105;
  End If;
  If (p_rec.val_106 = hr_api.g_varchar2) then
    p_rec.val_106 :=
    ben_xrd_shd.g_old_rec.val_106;
  End If;
  If (p_rec.val_107 = hr_api.g_varchar2) then
    p_rec.val_107 :=
    ben_xrd_shd.g_old_rec.val_107;
  End If;
  If (p_rec.val_108 = hr_api.g_varchar2) then
    p_rec.val_108 :=
    ben_xrd_shd.g_old_rec.val_108;
  End If;
  If (p_rec.val_109 = hr_api.g_varchar2) then
    p_rec.val_109 :=
    ben_xrd_shd.g_old_rec.val_109;
  End If;
  If (p_rec.val_110 = hr_api.g_varchar2) then
    p_rec.val_110 :=
    ben_xrd_shd.g_old_rec.val_110;
  End If;
  If (p_rec.val_111 = hr_api.g_varchar2) then
    p_rec.val_111 :=
    ben_xrd_shd.g_old_rec.val_111;
  End If;
  If (p_rec.val_112 = hr_api.g_varchar2) then
    p_rec.val_112 :=
    ben_xrd_shd.g_old_rec.val_112;
  End If;
  If (p_rec.val_113 = hr_api.g_varchar2) then
    p_rec.val_113 :=
    ben_xrd_shd.g_old_rec.val_113;
  End If;
  If (p_rec.val_114 = hr_api.g_varchar2) then
    p_rec.val_114 :=
    ben_xrd_shd.g_old_rec.val_114;
  End If;
  If (p_rec.val_115 = hr_api.g_varchar2) then
    p_rec.val_115 :=
    ben_xrd_shd.g_old_rec.val_115;
  End If;
  If (p_rec.val_116 = hr_api.g_varchar2) then
    p_rec.val_116 :=
    ben_xrd_shd.g_old_rec.val_116;
  End If;
  If (p_rec.val_117 = hr_api.g_varchar2) then
    p_rec.val_117 :=
    ben_xrd_shd.g_old_rec.val_117;
  End If;
  If (p_rec.val_119 = hr_api.g_varchar2) then
    p_rec.val_119 :=
    ben_xrd_shd.g_old_rec.val_119;
  End If;
  If (p_rec.val_118 = hr_api.g_varchar2) then
    p_rec.val_118 :=
    ben_xrd_shd.g_old_rec.val_118;
  End If;
  If (p_rec.val_120 = hr_api.g_varchar2) then
    p_rec.val_120 :=
    ben_xrd_shd.g_old_rec.val_120;
  End If;
  If (p_rec.val_121 = hr_api.g_varchar2) then
    p_rec.val_121 :=
    ben_xrd_shd.g_old_rec.val_121;
  End If;
  If (p_rec.val_122 = hr_api.g_varchar2) then
    p_rec.val_122 :=
    ben_xrd_shd.g_old_rec.val_122;
  End If;
  If (p_rec.val_123 = hr_api.g_varchar2) then
    p_rec.val_123 :=
    ben_xrd_shd.g_old_rec.val_123;
  End If;
  If (p_rec.val_124 = hr_api.g_varchar2) then
    p_rec.val_124 :=
    ben_xrd_shd.g_old_rec.val_124;
  End If;
  If (p_rec.val_125 = hr_api.g_varchar2) then
    p_rec.val_125 :=
    ben_xrd_shd.g_old_rec.val_125;
  End If;
  If (p_rec.val_126 = hr_api.g_varchar2) then
    p_rec.val_126 :=
    ben_xrd_shd.g_old_rec.val_126;
  End If;
  If (p_rec.val_127 = hr_api.g_varchar2) then
    p_rec.val_127 :=
    ben_xrd_shd.g_old_rec.val_127;
  End If;
  If (p_rec.val_128 = hr_api.g_varchar2) then
    p_rec.val_128 :=
    ben_xrd_shd.g_old_rec.val_128;
  End If;
  If (p_rec.val_129 = hr_api.g_varchar2) then
    p_rec.val_129 :=
    ben_xrd_shd.g_old_rec.val_129;
  End If;
  If (p_rec.val_130 = hr_api.g_varchar2) then
    p_rec.val_130 :=
    ben_xrd_shd.g_old_rec.val_130;
  End If;
  If (p_rec.val_131 = hr_api.g_varchar2) then
    p_rec.val_131 :=
    ben_xrd_shd.g_old_rec.val_131;
  End If;
  If (p_rec.val_132 = hr_api.g_varchar2) then
    p_rec.val_132 :=
    ben_xrd_shd.g_old_rec.val_132;
  End If;
  If (p_rec.val_133 = hr_api.g_varchar2) then
    p_rec.val_133 :=
    ben_xrd_shd.g_old_rec.val_133;
  End If;
  If (p_rec.val_134 = hr_api.g_varchar2) then
    p_rec.val_134 :=
    ben_xrd_shd.g_old_rec.val_134;
  End If;
  If (p_rec.val_135 = hr_api.g_varchar2) then
    p_rec.val_135 :=
    ben_xrd_shd.g_old_rec.val_135;
  End If;
  If (p_rec.val_136 = hr_api.g_varchar2) then
    p_rec.val_136 :=
    ben_xrd_shd.g_old_rec.val_136;
  End If;
  If (p_rec.val_137 = hr_api.g_varchar2) then
    p_rec.val_137 :=
    ben_xrd_shd.g_old_rec.val_137;
  End If;
  If (p_rec.val_138 = hr_api.g_varchar2) then
    p_rec.val_138 :=
    ben_xrd_shd.g_old_rec.val_138;
  End If;
  If (p_rec.val_139 = hr_api.g_varchar2) then
    p_rec.val_139 :=
    ben_xrd_shd.g_old_rec.val_139;
  End If;
  If (p_rec.val_140 = hr_api.g_varchar2) then
    p_rec.val_140 :=
    ben_xrd_shd.g_old_rec.val_140;
  End If;
  If (p_rec.val_141 = hr_api.g_varchar2) then
    p_rec.val_141 :=
    ben_xrd_shd.g_old_rec.val_141;
  End If;
  If (p_rec.val_142 = hr_api.g_varchar2) then
    p_rec.val_142 :=
    ben_xrd_shd.g_old_rec.val_142;
  End If;
  If (p_rec.val_143 = hr_api.g_varchar2) then
    p_rec.val_143 :=
    ben_xrd_shd.g_old_rec.val_143;
  End If;
  If (p_rec.val_144 = hr_api.g_varchar2) then
    p_rec.val_144 :=
    ben_xrd_shd.g_old_rec.val_144;
  End If;
  If (p_rec.val_145 = hr_api.g_varchar2) then
    p_rec.val_145 :=
    ben_xrd_shd.g_old_rec.val_145;
  End If;
  If (p_rec.val_146 = hr_api.g_varchar2) then
    p_rec.val_146 :=
    ben_xrd_shd.g_old_rec.val_146;
  End If;
  If (p_rec.val_147 = hr_api.g_varchar2) then
    p_rec.val_147 :=
    ben_xrd_shd.g_old_rec.val_147;
  End If;
  If (p_rec.val_148 = hr_api.g_varchar2) then
    p_rec.val_148 :=
    ben_xrd_shd.g_old_rec.val_148;
  End If;
  If (p_rec.val_149 = hr_api.g_varchar2) then
    p_rec.val_149 :=
    ben_xrd_shd.g_old_rec.val_149;
  End If;
  If (p_rec.val_150 = hr_api.g_varchar2) then
    p_rec.val_150 :=
    ben_xrd_shd.g_old_rec.val_150;
  End If;
  If (p_rec.val_151 = hr_api.g_varchar2) then
    p_rec.val_151 :=
    ben_xrd_shd.g_old_rec.val_151;
  End If;
  If (p_rec.val_152 = hr_api.g_varchar2) then
    p_rec.val_152 :=
    ben_xrd_shd.g_old_rec.val_152;
  End If;
  If (p_rec.val_153 = hr_api.g_varchar2) then
    p_rec.val_153 :=
    ben_xrd_shd.g_old_rec.val_153;
  End If;
  If (p_rec.val_154 = hr_api.g_varchar2) then
    p_rec.val_154 :=
    ben_xrd_shd.g_old_rec.val_154;
  End If;
  If (p_rec.val_155 = hr_api.g_varchar2) then
    p_rec.val_155 :=
    ben_xrd_shd.g_old_rec.val_155;
  End If;
  If (p_rec.val_156 = hr_api.g_varchar2) then
    p_rec.val_156 :=
    ben_xrd_shd.g_old_rec.val_156;
  End If;
  If (p_rec.val_157 = hr_api.g_varchar2) then
    p_rec.val_157 :=
    ben_xrd_shd.g_old_rec.val_157;
  End If;
  If (p_rec.val_158 = hr_api.g_varchar2) then
    p_rec.val_158 :=
    ben_xrd_shd.g_old_rec.val_158;
  End If;
  If (p_rec.val_159 = hr_api.g_varchar2) then
    p_rec.val_159 :=
    ben_xrd_shd.g_old_rec.val_159;
  End If;
  If (p_rec.val_160 = hr_api.g_varchar2) then
    p_rec.val_160 :=
    ben_xrd_shd.g_old_rec.val_160;
  End If;
  If (p_rec.val_161 = hr_api.g_varchar2) then
    p_rec.val_161 :=
    ben_xrd_shd.g_old_rec.val_161;
  End If;
  If (p_rec.val_162 = hr_api.g_varchar2) then
    p_rec.val_162 :=
    ben_xrd_shd.g_old_rec.val_162;
  End If;
  If (p_rec.val_163 = hr_api.g_varchar2) then
    p_rec.val_163 :=
    ben_xrd_shd.g_old_rec.val_163;
  End If;
  If (p_rec.val_164 = hr_api.g_varchar2) then
    p_rec.val_164 :=
    ben_xrd_shd.g_old_rec.val_164;
  End If;
  If (p_rec.val_165 = hr_api.g_varchar2) then
    p_rec.val_165 :=
    ben_xrd_shd.g_old_rec.val_165;
  End If;
  If (p_rec.val_166 = hr_api.g_varchar2) then
    p_rec.val_166 :=
    ben_xrd_shd.g_old_rec.val_166;
  End If;
  If (p_rec.val_167 = hr_api.g_varchar2) then
    p_rec.val_167 :=
    ben_xrd_shd.g_old_rec.val_167;
  End If;
  If (p_rec.val_168 = hr_api.g_varchar2) then
    p_rec.val_168 :=
    ben_xrd_shd.g_old_rec.val_168;
  End If;
  If (p_rec.val_169 = hr_api.g_varchar2) then
    p_rec.val_169 :=
    ben_xrd_shd.g_old_rec.val_169;
  End If;
  If (p_rec.val_170 = hr_api.g_varchar2) then
    p_rec.val_170 :=
    ben_xrd_shd.g_old_rec.val_170;
  End If;
  If (p_rec.val_171 = hr_api.g_varchar2) then
    p_rec.val_171 :=
    ben_xrd_shd.g_old_rec.val_171;
  End If;
  If (p_rec.val_172 = hr_api.g_varchar2) then
    p_rec.val_172 :=
    ben_xrd_shd.g_old_rec.val_172;
  End If;
  If (p_rec.val_173 = hr_api.g_varchar2) then
    p_rec.val_173 :=
    ben_xrd_shd.g_old_rec.val_173;
  End If;
  If (p_rec.val_174 = hr_api.g_varchar2) then
    p_rec.val_174 :=
    ben_xrd_shd.g_old_rec.val_174;
  End If;
  If (p_rec.val_175 = hr_api.g_varchar2) then
    p_rec.val_175 :=
    ben_xrd_shd.g_old_rec.val_175;
  End If;
  If (p_rec.val_176 = hr_api.g_varchar2) then
    p_rec.val_176 :=
    ben_xrd_shd.g_old_rec.val_176;
  End If;
  If (p_rec.val_177 = hr_api.g_varchar2) then
    p_rec.val_177 :=
    ben_xrd_shd.g_old_rec.val_177;
  End If;
  If (p_rec.val_178 = hr_api.g_varchar2) then
    p_rec.val_178 :=
    ben_xrd_shd.g_old_rec.val_178;
  End If;
  If (p_rec.val_179 = hr_api.g_varchar2) then
    p_rec.val_179 :=
    ben_xrd_shd.g_old_rec.val_179;
  End If;
  If (p_rec.val_180 = hr_api.g_varchar2) then
    p_rec.val_180 :=
    ben_xrd_shd.g_old_rec.val_180;
  End If;
  If (p_rec.val_181 = hr_api.g_varchar2) then
    p_rec.val_181 :=
    ben_xrd_shd.g_old_rec.val_181;
  End If;
  If (p_rec.val_182 = hr_api.g_varchar2) then
    p_rec.val_182 :=
    ben_xrd_shd.g_old_rec.val_182;
  End If;
  If (p_rec.val_183 = hr_api.g_varchar2) then
    p_rec.val_183 :=
    ben_xrd_shd.g_old_rec.val_183;
  End If;
  If (p_rec.val_184 = hr_api.g_varchar2) then
    p_rec.val_184 :=
    ben_xrd_shd.g_old_rec.val_184;
  End If;
  If (p_rec.val_185 = hr_api.g_varchar2) then
    p_rec.val_185 :=
    ben_xrd_shd.g_old_rec.val_185;
  End If;
  If (p_rec.val_186 = hr_api.g_varchar2) then
    p_rec.val_186 :=
    ben_xrd_shd.g_old_rec.val_186;
  End If;
  If (p_rec.val_187 = hr_api.g_varchar2) then
    p_rec.val_187 :=
    ben_xrd_shd.g_old_rec.val_187;
  End If;
  If (p_rec.val_188 = hr_api.g_varchar2) then
    p_rec.val_188 :=
    ben_xrd_shd.g_old_rec.val_188;
  End If;
  If (p_rec.val_189 = hr_api.g_varchar2) then
    p_rec.val_189 :=
    ben_xrd_shd.g_old_rec.val_189;
  End If;
  If (p_rec.val_190 = hr_api.g_varchar2) then
    p_rec.val_190 :=
    ben_xrd_shd.g_old_rec.val_190;
  End If;
  If (p_rec.val_191 = hr_api.g_varchar2) then
    p_rec.val_191 :=
    ben_xrd_shd.g_old_rec.val_191;
  End If;
  If (p_rec.val_192 = hr_api.g_varchar2) then
    p_rec.val_192 :=
    ben_xrd_shd.g_old_rec.val_192;
  End If;
  If (p_rec.val_193 = hr_api.g_varchar2) then
    p_rec.val_193 :=
    ben_xrd_shd.g_old_rec.val_193;
  End If;
  If (p_rec.val_194 = hr_api.g_varchar2) then
    p_rec.val_194 :=
    ben_xrd_shd.g_old_rec.val_194;
  End If;
  If (p_rec.val_195 = hr_api.g_varchar2) then
    p_rec.val_195 :=
    ben_xrd_shd.g_old_rec.val_195;
  End If;
  If (p_rec.val_196 = hr_api.g_varchar2) then
    p_rec.val_196 :=
    ben_xrd_shd.g_old_rec.val_196;
  End If;
  If (p_rec.val_197 = hr_api.g_varchar2) then
    p_rec.val_197 :=
    ben_xrd_shd.g_old_rec.val_197;
  End If;
  If (p_rec.val_198 = hr_api.g_varchar2) then
    p_rec.val_198 :=
    ben_xrd_shd.g_old_rec.val_198;
  End If;
  If (p_rec.val_199 = hr_api.g_varchar2) then
    p_rec.val_199 :=
    ben_xrd_shd.g_old_rec.val_199;
  End If;
  If (p_rec.val_200 = hr_api.g_varchar2) then
    p_rec.val_200 :=
    ben_xrd_shd.g_old_rec.val_200;
  End If;
  If (p_rec.val_201 = hr_api.g_varchar2) then
    p_rec.val_201 :=
    ben_xrd_shd.g_old_rec.val_201;
  End If;
  If (p_rec.val_202 = hr_api.g_varchar2) then
    p_rec.val_202 :=
    ben_xrd_shd.g_old_rec.val_202;
  End If;
  If (p_rec.val_203 = hr_api.g_varchar2) then
    p_rec.val_203 :=
    ben_xrd_shd.g_old_rec.val_203;
  End If;
  If (p_rec.val_204 = hr_api.g_varchar2) then
    p_rec.val_204 :=
    ben_xrd_shd.g_old_rec.val_204;
  End If;
  If (p_rec.val_205 = hr_api.g_varchar2) then
    p_rec.val_205 :=
    ben_xrd_shd.g_old_rec.val_205;
  End If;
  If (p_rec.val_206 = hr_api.g_varchar2) then
    p_rec.val_206 :=
    ben_xrd_shd.g_old_rec.val_206;
  End If;
  If (p_rec.val_207 = hr_api.g_varchar2) then
    p_rec.val_207 :=
    ben_xrd_shd.g_old_rec.val_207;
  End If;
  If (p_rec.val_208 = hr_api.g_varchar2) then
    p_rec.val_208 :=
    ben_xrd_shd.g_old_rec.val_208;
  End If;
  If (p_rec.val_209 = hr_api.g_varchar2) then
    p_rec.val_209 :=
    ben_xrd_shd.g_old_rec.val_209;
  End If;
  If (p_rec.val_210 = hr_api.g_varchar2) then
    p_rec.val_210 :=
    ben_xrd_shd.g_old_rec.val_210;
  End If;
  If (p_rec.val_211 = hr_api.g_varchar2) then
    p_rec.val_211 :=
    ben_xrd_shd.g_old_rec.val_211;
  End If;
  If (p_rec.val_212 = hr_api.g_varchar2) then
    p_rec.val_212 :=
    ben_xrd_shd.g_old_rec.val_212;
  End If;
  If (p_rec.val_213 = hr_api.g_varchar2) then
    p_rec.val_213 :=
    ben_xrd_shd.g_old_rec.val_213;
  End If;
  If (p_rec.val_214 = hr_api.g_varchar2) then
    p_rec.val_214 :=
    ben_xrd_shd.g_old_rec.val_214;
  End If;
  If (p_rec.val_215 = hr_api.g_varchar2) then
    p_rec.val_215 :=
    ben_xrd_shd.g_old_rec.val_215;
  End If;
  If (p_rec.val_216 = hr_api.g_varchar2) then
    p_rec.val_216 :=
    ben_xrd_shd.g_old_rec.val_216;
  End If;
  If (p_rec.val_217 = hr_api.g_varchar2) then
    p_rec.val_217 :=
    ben_xrd_shd.g_old_rec.val_217;
  End If;
  If (p_rec.val_219 = hr_api.g_varchar2) then
    p_rec.val_219 :=
    ben_xrd_shd.g_old_rec.val_219;
  End If;
  If (p_rec.val_218 = hr_api.g_varchar2) then
    p_rec.val_218 :=
    ben_xrd_shd.g_old_rec.val_218;
  End If;
  If (p_rec.val_220 = hr_api.g_varchar2) then
    p_rec.val_220 :=
    ben_xrd_shd.g_old_rec.val_220;
  End If;
  If (p_rec.val_221 = hr_api.g_varchar2) then
    p_rec.val_221 :=
    ben_xrd_shd.g_old_rec.val_221;
  End If;
  If (p_rec.val_222 = hr_api.g_varchar2) then
    p_rec.val_222 :=
    ben_xrd_shd.g_old_rec.val_222;
  End If;
  If (p_rec.val_223 = hr_api.g_varchar2) then
    p_rec.val_223 :=
    ben_xrd_shd.g_old_rec.val_223;
  End If;
  If (p_rec.val_224 = hr_api.g_varchar2) then
    p_rec.val_224 :=
    ben_xrd_shd.g_old_rec.val_224;
  End If;
  If (p_rec.val_225 = hr_api.g_varchar2) then
    p_rec.val_225 :=
    ben_xrd_shd.g_old_rec.val_225;
  End If;
  If (p_rec.val_226 = hr_api.g_varchar2) then
    p_rec.val_226 :=
    ben_xrd_shd.g_old_rec.val_226;
  End If;
  If (p_rec.val_227 = hr_api.g_varchar2) then
    p_rec.val_227 :=
    ben_xrd_shd.g_old_rec.val_227;
  End If;
  If (p_rec.val_228 = hr_api.g_varchar2) then
    p_rec.val_228 :=
    ben_xrd_shd.g_old_rec.val_228;
  End If;
  If (p_rec.val_229 = hr_api.g_varchar2) then
    p_rec.val_229 :=
    ben_xrd_shd.g_old_rec.val_229;
  End If;
  If (p_rec.val_230 = hr_api.g_varchar2) then
    p_rec.val_230 :=
    ben_xrd_shd.g_old_rec.val_230;
  End If;
  If (p_rec.val_231 = hr_api.g_varchar2) then
    p_rec.val_231 :=
    ben_xrd_shd.g_old_rec.val_231;
  End If;
  If (p_rec.val_232 = hr_api.g_varchar2) then
    p_rec.val_232 :=
    ben_xrd_shd.g_old_rec.val_232;
  End If;
  If (p_rec.val_233 = hr_api.g_varchar2) then
    p_rec.val_233 :=
    ben_xrd_shd.g_old_rec.val_233;
  End If;
  If (p_rec.val_234 = hr_api.g_varchar2) then
    p_rec.val_234 :=
    ben_xrd_shd.g_old_rec.val_234;
  End If;
  If (p_rec.val_235 = hr_api.g_varchar2) then
    p_rec.val_235 :=
    ben_xrd_shd.g_old_rec.val_235;
  End If;
  If (p_rec.val_236 = hr_api.g_varchar2) then
    p_rec.val_236 :=
    ben_xrd_shd.g_old_rec.val_236;
  End If;
  If (p_rec.val_237 = hr_api.g_varchar2) then
    p_rec.val_237 :=
    ben_xrd_shd.g_old_rec.val_237;
  End If;
  If (p_rec.val_238 = hr_api.g_varchar2) then
    p_rec.val_238 :=
    ben_xrd_shd.g_old_rec.val_238;
  End If;
  If (p_rec.val_239 = hr_api.g_varchar2) then
    p_rec.val_239 :=
    ben_xrd_shd.g_old_rec.val_239;
  End If;
  If (p_rec.val_240 = hr_api.g_varchar2) then
    p_rec.val_240 :=
    ben_xrd_shd.g_old_rec.val_240;
  End If;
  If (p_rec.val_241 = hr_api.g_varchar2) then
    p_rec.val_241 :=
    ben_xrd_shd.g_old_rec.val_241;
  End If;
  If (p_rec.val_242 = hr_api.g_varchar2) then
    p_rec.val_242 :=
    ben_xrd_shd.g_old_rec.val_242;
  End If;
  If (p_rec.val_243 = hr_api.g_varchar2) then
    p_rec.val_243 :=
    ben_xrd_shd.g_old_rec.val_243;
  End If;
  If (p_rec.val_244 = hr_api.g_varchar2) then
    p_rec.val_244 :=
    ben_xrd_shd.g_old_rec.val_244;
  End If;
  If (p_rec.val_245 = hr_api.g_varchar2) then
    p_rec.val_245 :=
    ben_xrd_shd.g_old_rec.val_245;
  End If;
  If (p_rec.val_246 = hr_api.g_varchar2) then
    p_rec.val_246 :=
    ben_xrd_shd.g_old_rec.val_246;
  End If;
  If (p_rec.val_247 = hr_api.g_varchar2) then
    p_rec.val_247 :=
    ben_xrd_shd.g_old_rec.val_247;
  End If;
  If (p_rec.val_248 = hr_api.g_varchar2) then
    p_rec.val_248 :=
    ben_xrd_shd.g_old_rec.val_248;
  End If;
  If (p_rec.val_249 = hr_api.g_varchar2) then
    p_rec.val_249 :=
    ben_xrd_shd.g_old_rec.val_249;
  End If;
  If (p_rec.val_250 = hr_api.g_varchar2) then
    p_rec.val_250 :=
    ben_xrd_shd.g_old_rec.val_250;
  End If;
  If (p_rec.val_251 = hr_api.g_varchar2) then
    p_rec.val_251 :=
    ben_xrd_shd.g_old_rec.val_251;
  End If;
  If (p_rec.val_252 = hr_api.g_varchar2) then
    p_rec.val_252 :=
    ben_xrd_shd.g_old_rec.val_252;
  End If;
  If (p_rec.val_253 = hr_api.g_varchar2) then
    p_rec.val_253 :=
    ben_xrd_shd.g_old_rec.val_253;
  End If;
  If (p_rec.val_254 = hr_api.g_varchar2) then
    p_rec.val_254 :=
    ben_xrd_shd.g_old_rec.val_254;
  End If;
  If (p_rec.val_255 = hr_api.g_varchar2) then
    p_rec.val_255 :=
    ben_xrd_shd.g_old_rec.val_255;
  End If;
  If (p_rec.val_256 = hr_api.g_varchar2) then
    p_rec.val_256 :=
    ben_xrd_shd.g_old_rec.val_256;
  End If;
  If (p_rec.val_257 = hr_api.g_varchar2) then
    p_rec.val_257 :=
    ben_xrd_shd.g_old_rec.val_257;
  End If;
  If (p_rec.val_258 = hr_api.g_varchar2) then
    p_rec.val_258 :=
    ben_xrd_shd.g_old_rec.val_258;
  End If;
  If (p_rec.val_259 = hr_api.g_varchar2) then
    p_rec.val_259 :=
    ben_xrd_shd.g_old_rec.val_259;
  End If;
  If (p_rec.val_260 = hr_api.g_varchar2) then
    p_rec.val_260 :=
    ben_xrd_shd.g_old_rec.val_260;
  End If;
  If (p_rec.val_261 = hr_api.g_varchar2) then
    p_rec.val_261 :=
    ben_xrd_shd.g_old_rec.val_261;
  End If;
  If (p_rec.val_262 = hr_api.g_varchar2) then
    p_rec.val_262 :=
    ben_xrd_shd.g_old_rec.val_262;
  End If;
  If (p_rec.val_263 = hr_api.g_varchar2) then
    p_rec.val_263 :=
    ben_xrd_shd.g_old_rec.val_263;
  End If;
  If (p_rec.val_264 = hr_api.g_varchar2) then
    p_rec.val_264 :=
    ben_xrd_shd.g_old_rec.val_264;
  End If;
  If (p_rec.val_265 = hr_api.g_varchar2) then
    p_rec.val_265 :=
    ben_xrd_shd.g_old_rec.val_265;
  End If;
  If (p_rec.val_266 = hr_api.g_varchar2) then
    p_rec.val_266 :=
    ben_xrd_shd.g_old_rec.val_266;
  End If;
  If (p_rec.val_267 = hr_api.g_varchar2) then
    p_rec.val_267 :=
    ben_xrd_shd.g_old_rec.val_267;
  End If;
  If (p_rec.val_268 = hr_api.g_varchar2) then
    p_rec.val_268 :=
    ben_xrd_shd.g_old_rec.val_268;
  End If;
  If (p_rec.val_269 = hr_api.g_varchar2) then
    p_rec.val_269 :=
    ben_xrd_shd.g_old_rec.val_269;
  End If;
  If (p_rec.val_270 = hr_api.g_varchar2) then
    p_rec.val_270 :=
    ben_xrd_shd.g_old_rec.val_270;
  End If;
  If (p_rec.val_271 = hr_api.g_varchar2) then
    p_rec.val_271 :=
    ben_xrd_shd.g_old_rec.val_271;
  End If;
  If (p_rec.val_272 = hr_api.g_varchar2) then
    p_rec.val_272 :=
    ben_xrd_shd.g_old_rec.val_272;
  End If;
  If (p_rec.val_273 = hr_api.g_varchar2) then
    p_rec.val_273 :=
    ben_xrd_shd.g_old_rec.val_273;
  End If;
  If (p_rec.val_274 = hr_api.g_varchar2) then
    p_rec.val_274 :=
    ben_xrd_shd.g_old_rec.val_274;
  End If;
  If (p_rec.val_275 = hr_api.g_varchar2) then
    p_rec.val_275 :=
    ben_xrd_shd.g_old_rec.val_275;
  End If;
  If (p_rec.val_276 = hr_api.g_varchar2) then
    p_rec.val_276 :=
    ben_xrd_shd.g_old_rec.val_276;
  End If;
  If (p_rec.val_277 = hr_api.g_varchar2) then
    p_rec.val_277 :=
    ben_xrd_shd.g_old_rec.val_277;
  End If;
  If (p_rec.val_278 = hr_api.g_varchar2) then
    p_rec.val_278 :=
    ben_xrd_shd.g_old_rec.val_278;
  End If;
  If (p_rec.val_279 = hr_api.g_varchar2) then
    p_rec.val_279 :=
    ben_xrd_shd.g_old_rec.val_279;
  End If;
  If (p_rec.val_280 = hr_api.g_varchar2) then
    p_rec.val_280 :=
    ben_xrd_shd.g_old_rec.val_280;
  End If;
  If (p_rec.val_281 = hr_api.g_varchar2) then
    p_rec.val_281 :=
    ben_xrd_shd.g_old_rec.val_281;
  End If;
  If (p_rec.val_282 = hr_api.g_varchar2) then
    p_rec.val_282 :=
    ben_xrd_shd.g_old_rec.val_282;
  End If;
  If (p_rec.val_283 = hr_api.g_varchar2) then
    p_rec.val_283 :=
    ben_xrd_shd.g_old_rec.val_283;
  End If;
  If (p_rec.val_284 = hr_api.g_varchar2) then
    p_rec.val_284 :=
    ben_xrd_shd.g_old_rec.val_284;
  End If;
  If (p_rec.val_285 = hr_api.g_varchar2) then
    p_rec.val_285 :=
    ben_xrd_shd.g_old_rec.val_285;
  End If;
  If (p_rec.val_286 = hr_api.g_varchar2) then
    p_rec.val_286 :=
    ben_xrd_shd.g_old_rec.val_286;
  End If;
  If (p_rec.val_287 = hr_api.g_varchar2) then
    p_rec.val_287 :=
    ben_xrd_shd.g_old_rec.val_287;
  End If;
  If (p_rec.val_288 = hr_api.g_varchar2) then
    p_rec.val_288 :=
    ben_xrd_shd.g_old_rec.val_288;
  End If;
  If (p_rec.val_289 = hr_api.g_varchar2) then
    p_rec.val_289 :=
    ben_xrd_shd.g_old_rec.val_289;
  End If;
  If (p_rec.val_290 = hr_api.g_varchar2) then
    p_rec.val_290 :=
    ben_xrd_shd.g_old_rec.val_290;
  End If;
  If (p_rec.val_291 = hr_api.g_varchar2) then
    p_rec.val_291 :=
    ben_xrd_shd.g_old_rec.val_291;
  End If;
  If (p_rec.val_292 = hr_api.g_varchar2) then
    p_rec.val_292 :=
    ben_xrd_shd.g_old_rec.val_292;
  End If;
  If (p_rec.val_293 = hr_api.g_varchar2) then
    p_rec.val_293 :=
    ben_xrd_shd.g_old_rec.val_293;
  End If;
  If (p_rec.val_294 = hr_api.g_varchar2) then
    p_rec.val_294 :=
    ben_xrd_shd.g_old_rec.val_294;
  End If;
  If (p_rec.val_295 = hr_api.g_varchar2) then
    p_rec.val_295 :=
    ben_xrd_shd.g_old_rec.val_295;
  End If;
  If (p_rec.val_296 = hr_api.g_varchar2) then
    p_rec.val_296 :=
    ben_xrd_shd.g_old_rec.val_296;
  End If;
  If (p_rec.val_297 = hr_api.g_varchar2) then
    p_rec.val_297 :=
    ben_xrd_shd.g_old_rec.val_297;
  End If;
  If (p_rec.val_298 = hr_api.g_varchar2) then
    p_rec.val_298 :=
    ben_xrd_shd.g_old_rec.val_298;
  End If;
  If (p_rec.val_299 = hr_api.g_varchar2) then
    p_rec.val_299 :=
    ben_xrd_shd.g_old_rec.val_299;
  End If;
  If (p_rec.val_300 = hr_api.g_varchar2) then
    p_rec.val_300 :=
    ben_xrd_shd.g_old_rec.val_300;
  End If;

  If (p_rec.group_val_01 = hr_api.g_varchar2) then
    p_rec.group_val_01 :=
    ben_xrd_shd.g_old_rec.group_val_01;
  End If;

  If (p_rec.group_val_02 = hr_api.g_varchar2) then
    p_rec.group_val_02 :=
    ben_xrd_shd.g_old_rec.group_val_02;
  End If;

  --
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_xrd_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_xrd_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_xrd_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_xrd_shd.g_old_rec.request_id;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy ben_xrd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_xrd_shd.lck
	(
	p_rec.ext_rslt_dtl_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_xrd_bus.update_validate(p_rec);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_ext_rslt_dtl_id              in number,
  p_prmy_sort_val                in varchar2         default hr_api.g_varchar2,
  p_scnd_sort_val                in varchar2         default hr_api.g_varchar2,
  p_thrd_sort_val                in varchar2         default hr_api.g_varchar2,
  p_trans_seq_num                in number           default hr_api.g_number,
  p_rcrd_seq_num                 in number           default hr_api.g_number,
  p_ext_rslt_id                  in number           default hr_api.g_number,
  p_ext_rcd_id                   in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_ext_per_bg_id                in number           default hr_api.g_number,
  p_val_01                       in varchar2         default hr_api.g_varchar2,
  p_val_02                       in varchar2         default hr_api.g_varchar2,
  p_val_03                       in varchar2         default hr_api.g_varchar2,
  p_val_04                       in varchar2         default hr_api.g_varchar2,
  p_val_05                       in varchar2         default hr_api.g_varchar2,
  p_val_06                       in varchar2         default hr_api.g_varchar2,
  p_val_07                       in varchar2         default hr_api.g_varchar2,
  p_val_08                       in varchar2         default hr_api.g_varchar2,
  p_val_09                       in varchar2         default hr_api.g_varchar2,
  p_val_10                       in varchar2         default hr_api.g_varchar2,
  p_val_11                       in varchar2         default hr_api.g_varchar2,
  p_val_12                       in varchar2         default hr_api.g_varchar2,
  p_val_13                       in varchar2         default hr_api.g_varchar2,
  p_val_14                       in varchar2         default hr_api.g_varchar2,
  p_val_15                       in varchar2         default hr_api.g_varchar2,
  p_val_16                       in varchar2         default hr_api.g_varchar2,
  p_val_17                       in varchar2         default hr_api.g_varchar2,
  p_val_19                       in varchar2         default hr_api.g_varchar2,
  p_val_18                       in varchar2         default hr_api.g_varchar2,
  p_val_20                       in varchar2         default hr_api.g_varchar2,
  p_val_21                       in varchar2         default hr_api.g_varchar2,
  p_val_22                       in varchar2         default hr_api.g_varchar2,
  p_val_23                       in varchar2         default hr_api.g_varchar2,
  p_val_24                       in varchar2         default hr_api.g_varchar2,
  p_val_25                       in varchar2         default hr_api.g_varchar2,
  p_val_26                       in varchar2         default hr_api.g_varchar2,
  p_val_27                       in varchar2         default hr_api.g_varchar2,
  p_val_28                       in varchar2         default hr_api.g_varchar2,
  p_val_29                       in varchar2         default hr_api.g_varchar2,
  p_val_30                       in varchar2         default hr_api.g_varchar2,
  p_val_31                       in varchar2         default hr_api.g_varchar2,
  p_val_32                       in varchar2         default hr_api.g_varchar2,
  p_val_33                       in varchar2         default hr_api.g_varchar2,
  p_val_34                       in varchar2         default hr_api.g_varchar2,
  p_val_35                       in varchar2         default hr_api.g_varchar2,
  p_val_36                       in varchar2         default hr_api.g_varchar2,
  p_val_37                       in varchar2         default hr_api.g_varchar2,
  p_val_38                       in varchar2         default hr_api.g_varchar2,
  p_val_39                       in varchar2         default hr_api.g_varchar2,
  p_val_40                       in varchar2         default hr_api.g_varchar2,
  p_val_41                       in varchar2         default hr_api.g_varchar2,
  p_val_42                       in varchar2         default hr_api.g_varchar2,
  p_val_43                       in varchar2         default hr_api.g_varchar2,
  p_val_44                       in varchar2         default hr_api.g_varchar2,
  p_val_45                       in varchar2         default hr_api.g_varchar2,
  p_val_46                       in varchar2         default hr_api.g_varchar2,
  p_val_47                       in varchar2         default hr_api.g_varchar2,
  p_val_48                       in varchar2         default hr_api.g_varchar2,
  p_val_49                       in varchar2         default hr_api.g_varchar2,
  p_val_50                       in varchar2         default hr_api.g_varchar2,
  p_val_51                       in varchar2         default hr_api.g_varchar2,
  p_val_52                       in varchar2         default hr_api.g_varchar2,
  p_val_53                       in varchar2         default hr_api.g_varchar2,
  p_val_54                       in varchar2         default hr_api.g_varchar2,
  p_val_55                       in varchar2         default hr_api.g_varchar2,
  p_val_56                       in varchar2         default hr_api.g_varchar2,
  p_val_57                       in varchar2         default hr_api.g_varchar2,
  p_val_58                       in varchar2         default hr_api.g_varchar2,
  p_val_59                       in varchar2         default hr_api.g_varchar2,
  p_val_60                       in varchar2         default hr_api.g_varchar2,
  p_val_61                       in varchar2         default hr_api.g_varchar2,
  p_val_62                       in varchar2         default hr_api.g_varchar2,
  p_val_63                       in varchar2         default hr_api.g_varchar2,
  p_val_64                       in varchar2         default hr_api.g_varchar2,
  p_val_65                       in varchar2         default hr_api.g_varchar2,
  p_val_66                       in varchar2         default hr_api.g_varchar2,
  p_val_67                       in varchar2         default hr_api.g_varchar2,
  p_val_68                       in varchar2         default hr_api.g_varchar2,
  p_val_69                       in varchar2         default hr_api.g_varchar2,
  p_val_70                       in varchar2         default hr_api.g_varchar2,
  p_val_71                       in varchar2         default hr_api.g_varchar2,
  p_val_72                       in varchar2         default hr_api.g_varchar2,
  p_val_73                       in varchar2         default hr_api.g_varchar2,
  p_val_74                       in varchar2         default hr_api.g_varchar2,
  p_val_75                       in varchar2         default hr_api.g_varchar2,
  p_val_76                       in  varchar2  default hr_api.g_varchar2 ,
  p_val_77                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_78                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_79                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_80                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_81                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_82                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_83                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_84                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_85                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_86                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_87                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_88                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_89                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_90                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_91                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_92                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_93                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_94                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_95                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_96                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_97                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_98                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_99                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_100                        in  varchar2  default hr_api.g_varchar2 ,
  p_val_101                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_102                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_103                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_104                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_105                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_106                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_107                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_108                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_109                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_110                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_111                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_112                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_113                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_114                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_115                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_116                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_117                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_119                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_118                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_120                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_121                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_122                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_123                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_124                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_125                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_126                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_127                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_128                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_129                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_130                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_131                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_132                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_133                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_134                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_135                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_136                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_137                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_138                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_139                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_140                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_141                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_142                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_143                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_144                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_145                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_146                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_147                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_148                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_149                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_150                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_151                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_152                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_153                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_154                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_155                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_156                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_157                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_158                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_159                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_160                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_161                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_162                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_163                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_164                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_165                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_166                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_167                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_168                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_169                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_170                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_171                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_172                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_173                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_174                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_175                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_176                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_177                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_178                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_179                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_180                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_181                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_182                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_183                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_184                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_185                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_186                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_187                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_188                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_189                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_190                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_191                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_192                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_193                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_194                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_195                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_196                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_197                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_198                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_199                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_200                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_201                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_202                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_203                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_204                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_205                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_206                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_207                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_208                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_209                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_210                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_211                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_212                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_213                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_214                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_215                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_216                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_217                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_219                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_218                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_220                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_221                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_222                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_223                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_224                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_225                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_226                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_227                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_228                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_229                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_230                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_231                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_232                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_233                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_234                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_235                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_236                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_237                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_238                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_239                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_240                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_241                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_242                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_243                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_244                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_245                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_246                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_247                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_248                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_249                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_250                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_251                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_252                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_253                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_254                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_255                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_256                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_257                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_258                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_259                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_260                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_261                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_262                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_263                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_264                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_265                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_266                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_267                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_268                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_269                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_270                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_271                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_272                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_273                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_274                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_275                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_276                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_277                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_278                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_279                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_280                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_281                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_282                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_283                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_284                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_285                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_286                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_287                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_288                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_289                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_290                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_291                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_292                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_293                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_294                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_295                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_296                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_297                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_298                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_299                         in  varchar2  default hr_api.g_varchar2 ,
  p_val_300                         in  varchar2  default hr_api.g_varchar2 ,
  p_group_val_01                    in  varchar2  default hr_api.g_varchar2 ,
  p_group_val_02                    in  varchar2  default hr_api.g_varchar2 ,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_request_id                   in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number                       ,
  p_ext_rcd_in_file_id           in number           default hr_api.g_number
  ) is
--
  l_rec	  ben_xrd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_xrd_shd.convert_args
  (
  p_ext_rslt_dtl_id,
  p_prmy_sort_val,
  p_scnd_sort_val,
  p_thrd_sort_val,
  p_trans_seq_num,
  p_rcrd_seq_num,
  p_ext_rslt_id,
  p_ext_rcd_id,
  p_person_id,
  p_business_group_id,
  p_ext_per_bg_id,
  p_val_01,
  p_val_02,
  p_val_03,
  p_val_04,
  p_val_05,
  p_val_06,
  p_val_07,
  p_val_08,
  p_val_09,
  p_val_10,
  p_val_11,
  p_val_12,
  p_val_13,
  p_val_14,
  p_val_15,
  p_val_16,
  p_val_17,
  p_val_19,
  p_val_18,
  p_val_20,
  p_val_21,
  p_val_22,
  p_val_23,
  p_val_24,
  p_val_25,
  p_val_26,
  p_val_27,
  p_val_28,
  p_val_29,
  p_val_30,
  p_val_31,
  p_val_32,
  p_val_33,
  p_val_34,
  p_val_35,
  p_val_36,
  p_val_37,
  p_val_38,
  p_val_39,
  p_val_40,
  p_val_41,
  p_val_42,
  p_val_43,
  p_val_44,
  p_val_45,
  p_val_46,
  p_val_47,
  p_val_48,
  p_val_49,
  p_val_50,
  p_val_51,
  p_val_52,
  p_val_53,
  p_val_54,
  p_val_55,
  p_val_56,
  p_val_57,
  p_val_58,
  p_val_59,
  p_val_60,
  p_val_61,
  p_val_62,
  p_val_63,
  p_val_64,
  p_val_65,
  p_val_66,
  p_val_67,
  p_val_68,
  p_val_69,
  p_val_70,
  p_val_71,
  p_val_72,
  p_val_73,
  p_val_74,
  p_val_75,
  p_val_76,
  p_val_77,
  p_val_78,
  p_val_79,
  p_val_80,
  p_val_81,
  p_val_82,
  p_val_83,
  p_val_84,
  p_val_85,
  p_val_86,
  p_val_87,
  p_val_88,
  p_val_89,
  p_val_90,
  p_val_91,
  p_val_92,
  p_val_93,
  p_val_94,
  p_val_95,
  p_val_96,
  p_val_97,
  p_val_98,
  p_val_99,
  p_val_100,
  p_val_101,
  p_val_102,
  p_val_103,
  p_val_104,
  p_val_105,
  p_val_106,
  p_val_107,
  p_val_108,
  p_val_109,
  p_val_110,
  p_val_111,
  p_val_112,
  p_val_113,
  p_val_114,
  p_val_115,
  p_val_116,
  p_val_117,
  p_val_119,
  p_val_118,
  p_val_120,
  p_val_121,
  p_val_122,
  p_val_123,
  p_val_124,
  p_val_125,
  p_val_126,
  p_val_127,
  p_val_128,
  p_val_129,
  p_val_130,
  p_val_131,
  p_val_132,
  p_val_133,
  p_val_134,
  p_val_135,
  p_val_136,
  p_val_137,
  p_val_138,
  p_val_139,
  p_val_140,
  p_val_141,
  p_val_142,
  p_val_143,
  p_val_144,
  p_val_145,
  p_val_146,
  p_val_147,
  p_val_148,
  p_val_149,
  p_val_150,
  p_val_151,
  p_val_152,
  p_val_153,
  p_val_154,
  p_val_155,
  p_val_156,
  p_val_157,
  p_val_158,
  p_val_159,
  p_val_160,
  p_val_161,
  p_val_162,
  p_val_163,
  p_val_164,
  p_val_165,
  p_val_166,
  p_val_167,
  p_val_168,
  p_val_169,
  p_val_170,
  p_val_171,
  p_val_172,
  p_val_173,
  p_val_174,
  p_val_175,
  p_val_176,
  p_val_177,
  p_val_178,
  p_val_179,
  p_val_180,
  p_val_181,
  p_val_182,
  p_val_183,
  p_val_184,
  p_val_185,
  p_val_186,
  p_val_187,
  p_val_188,
  p_val_189,
  p_val_190,
  p_val_191,
  p_val_192,
  p_val_193,
  p_val_194,
  p_val_195,
  p_val_196,
  p_val_197,
  p_val_198,
  p_val_199,
  p_val_200,
  p_val_201,
  p_val_202,
  p_val_203,
  p_val_204,
  p_val_205,
  p_val_206,
  p_val_207,
  p_val_208,
  p_val_209,
  p_val_210,
  p_val_211,
  p_val_212,
  p_val_213,
  p_val_214,
  p_val_215,
  p_val_216,
  p_val_217,
  p_val_219,
  p_val_218,
  p_val_220,
  p_val_221,
  p_val_222,
  p_val_223,
  p_val_224,
  p_val_225,
  p_val_226,
  p_val_227,
  p_val_228,
  p_val_229,
  p_val_230,
  p_val_231,
  p_val_232,
  p_val_233,
  p_val_234,
  p_val_235,
  p_val_236,
  p_val_237,
  p_val_238,
  p_val_239,
  p_val_240,
  p_val_241,
  p_val_242,
  p_val_243,
  p_val_244,
  p_val_245,
  p_val_246,
  p_val_247,
  p_val_248,
  p_val_249,
  p_val_250,
  p_val_251,
  p_val_252,
  p_val_253,
  p_val_254,
  p_val_255,
  p_val_256,
  p_val_257,
  p_val_258,
  p_val_259,
  p_val_260,
  p_val_261,
  p_val_262,
  p_val_263,
  p_val_264,
  p_val_265,
  p_val_266,
  p_val_267,
  p_val_268,
  p_val_269,
  p_val_270,
  p_val_271,
  p_val_272,
  p_val_273,
  p_val_274,
  p_val_275,
  p_val_276,
  p_val_277,
  p_val_278,
  p_val_279,
  p_val_280,
  p_val_281,
  p_val_282,
  p_val_283,
  p_val_284,
  p_val_285,
  p_val_286,
  p_val_287,
  p_val_288,
  p_val_289,
  p_val_290,
  p_val_291,
  p_val_292,
  p_val_293,
  p_val_294,
  p_val_295,
  p_val_296,
  p_val_297,
  p_val_298,
  p_val_299,
  p_val_300,
  p_group_val_01,
  p_group_val_02,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_request_id,
  p_object_version_number,
  p_ext_rcd_in_file_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_xrd_upd;

/
