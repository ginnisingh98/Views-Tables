--------------------------------------------------------
--  DDL for Package Body BEN_XRD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRD_SHD" as
/* $Header: bexrdrhi.pkb 120.1 2006/02/06 11:28:36 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrd_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_EXT_RSLT_DTL_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RSLT_DTL_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RSLT_DTL_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RSLT_DTL_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_ext_rslt_dtl_id                    in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	ext_rslt_dtl_id,
	prmy_sort_val,
	scnd_sort_val,
	thrd_sort_val,
	trans_seq_num,
	rcrd_seq_num,
	ext_rslt_id,
	ext_rcd_id,
	person_id,
	business_group_id,
	ext_per_bg_id,
	val_01,
	val_02,
	val_03,
	val_04,
	val_05,
	val_06,
	val_07,
	val_08,
	val_09,
	val_10,
	val_11,
	val_12,
	val_13,
	val_14,
	val_15,
	val_16,
	val_17,
	val_19,
	val_18,
	val_20,
	val_21,
	val_22,
	val_23,
	val_24,
	val_25,
	val_26,
	val_27,
	val_28,
	val_29,
	val_30,
	val_31,
	val_32,
	val_33,
	val_34,
	val_35,
	val_36,
	val_37,
	val_38,
	val_39,
	val_40,
	val_41,
	val_42,
	val_43,
	val_44,
	val_45,
	val_46,
	val_47,
	val_48,
	val_49,
	val_50,
	val_51,
	val_52,
	val_53,
	val_54,
	val_55,
	val_56,
	val_57,
	val_58,
	val_59,
	val_60,
	val_61,
	val_62,
	val_63,
	val_64,
	val_65,
	val_66,
	val_67,
	val_68,
	val_69,
	val_70,
	val_71,
	val_72,
	val_73,
	val_74,
	val_75,
      val_76,
      val_77,
      val_78,
      val_79,
      val_80,
      val_81,
      val_82,
      val_83,
      val_84,
      val_85,
      val_86,
      val_87,
      val_88,
      val_89,
      val_90,
      val_91,
      val_92,
      val_93,
      val_94,
      val_95,
      val_96,
      val_97,
      val_98,
      val_99,
      val_100,
      val_101,
      val_102,
      val_103,
      val_104,
      val_105,
      val_106,
      val_107,
      val_108,
      val_109,
      val_110,
      val_111,
      val_112,
      val_113,
      val_114,
      val_115,
      val_116,
      val_117,
      val_119,
      val_118,
      val_120,
      val_121,
      val_122,
      val_123,
      val_124,
      val_125,
      val_126,
      val_127,
      val_128,
      val_129,
      val_130,
      val_131,
      val_132,
      val_133,
      val_134,
      val_135,
      val_136,
      val_137,
      val_138,
      val_139,
      val_140,
      val_141,
      val_142,
      val_143,
      val_144,
      val_145,
      val_146,
      val_147,
      val_148,
      val_149,
      val_150,
      val_151,
      val_152,
      val_153,
      val_154,
      val_155,
      val_156,
      val_157,
      val_158,
      val_159,
      val_160,
      val_161,
      val_162,
      val_163,
      val_164,
      val_165,
      val_166,
      val_167,
      val_168,
      val_169,
      val_170,
      val_171,
      val_172,
      val_173,
      val_174,
      val_175,
      val_176,
      val_177,
      val_178,
      val_179,
      val_180,
      val_181,
      val_182,
      val_183,
      val_184,
      val_185,
      val_186,
      val_187,
      val_188,
      val_189,
      val_190,
      val_191,
      val_192,
      val_193,
      val_194,
      val_195,
      val_196,
      val_197,
      val_198,
      val_199,
      val_200,
      val_201,
      val_202,
      val_203,
      val_204,
      val_205,
      val_206,
      val_207,
      val_208,
      val_209,
      val_210,
      val_211,
      val_212,
      val_213,
      val_214,
      val_215,
      val_216,
      val_217,
      val_219,
      val_218,
      val_220,
      val_221,
      val_222,
      val_223,
      val_224,
      val_225,
      val_226,
      val_227,
      val_228,
      val_229,
      val_230,
      val_231,
      val_232,
      val_233,
      val_234,
      val_235,
      val_236,
      val_237,
      val_238,
      val_239,
      val_240,
      val_241,
      val_242,
      val_243,
      val_244,
      val_245,
      val_246,
      val_247,
      val_248,
      val_249,
      val_250,
      val_251,
      val_252,
      val_253,
      val_254,
      val_255,
      val_256,
      val_257,
      val_258,
      val_259,
      val_260,
      val_261,
      val_262,
      val_263,
      val_264,
      val_265,
      val_266,
      val_267,
      val_268,
      val_269,
      val_270,
      val_271,
      val_272,
      val_273,
      val_274,
      val_275,
      val_276,
      val_277,
      val_278,
      val_279,
      val_280,
      val_281,
      val_282,
      val_283,
      val_284,
      val_285,
      val_286,
      val_287,
      val_288,
      val_289,
      val_290,
      val_291,
      val_292,
      val_293,
      val_294,
      val_295,
      val_296,
      val_297,
      val_298,
      val_299,
      val_300,
      group_val_01 ,
      group_val_02 ,
	program_application_id,
	program_id,
	program_update_date,
	request_id,
	object_version_number,
        ext_rcd_in_file_id
    from	ben_ext_rslt_dtl
    where	ext_rslt_dtl_id = p_ext_rslt_dtl_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_rslt_dtl_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_rslt_dtl_id = g_old_rec.ext_rslt_dtl_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_ext_rslt_dtl_id                    in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ext_rslt_dtl_id,
	prmy_sort_val,
	scnd_sort_val,
	thrd_sort_val,
	trans_seq_num,
	rcrd_seq_num,
	ext_rslt_id,
	ext_rcd_id,
	person_id,
	business_group_id,
	ext_per_bg_id,
	val_01,
	val_02,
	val_03,
	val_04,
	val_05,
	val_06,
	val_07,
	val_08,
	val_09,
	val_10,
	val_11,
	val_12,
	val_13,
	val_14,
	val_15,
	val_16,
	val_17,
	val_19,
	val_18,
	val_20,
	val_21,
	val_22,
	val_23,
	val_24,
	val_25,
	val_26,
	val_27,
	val_28,
	val_29,
	val_30,
	val_31,
	val_32,
	val_33,
	val_34,
	val_35,
	val_36,
	val_37,
	val_38,
	val_39,
	val_40,
	val_41,
	val_42,
	val_43,
	val_44,
	val_45,
	val_46,
	val_47,
	val_48,
	val_49,
	val_50,
	val_51,
	val_52,
	val_53,
	val_54,
	val_55,
	val_56,
	val_57,
	val_58,
	val_59,
	val_60,
	val_61,
	val_62,
	val_63,
	val_64,
	val_65,
	val_66,
	val_67,
	val_68,
	val_69,
	val_70,
	val_71,
	val_72,
	val_73,
	val_74,
 	val_75,
      val_76,
      val_77,
      val_78,
      val_79,
      val_80,
      val_81,
      val_82,
      val_83,
      val_84,
      val_85,
      val_86,
      val_87,
      val_88,
      val_89,
      val_90,
      val_91,
      val_92,
      val_93,
      val_94,
      val_95,
      val_96,
      val_97,
      val_98,
      val_99,
      val_100,
      val_101,
      val_102,
      val_103,
      val_104,
      val_105,
      val_106,
      val_107,
      val_108,
      val_109,
      val_110,
      val_111,
      val_112,
      val_113,
      val_114,
      val_115,
      val_116,
      val_117,
      val_119,
      val_118,
      val_120,
      val_121,
      val_122,
      val_123,
      val_124,
      val_125,
      val_126,
      val_127,
      val_128,
      val_129,
      val_130,
      val_131,
      val_132,
      val_133,
      val_134,
      val_135,
      val_136,
      val_137,
      val_138,
      val_139,
      val_140,
      val_141,
      val_142,
      val_143,
      val_144,
      val_145,
      val_146,
      val_147,
      val_148,
      val_149,
      val_150,
      val_151,
      val_152,
      val_153,
      val_154,
      val_155,
      val_156,
      val_157,
      val_158,
      val_159,
      val_160,
      val_161,
      val_162,
      val_163,
      val_164,
      val_165,
      val_166,
      val_167,
      val_168,
      val_169,
      val_170,
      val_171,
      val_172,
      val_173,
      val_174,
      val_175,
      val_176,
      val_177,
      val_178,
      val_179,
      val_180,
      val_181,
      val_182,
      val_183,
      val_184,
      val_185,
      val_186,
      val_187,
      val_188,
      val_189,
      val_190,
      val_191,
      val_192,
      val_193,
      val_194,
      val_195,
      val_196,
      val_197,
      val_198,
      val_199,
      val_200,
      val_201,
      val_202,
      val_203,
      val_204,
      val_205,
      val_206,
      val_207,
      val_208,
      val_209,
      val_210,
      val_211,
      val_212,
      val_213,
      val_214,
      val_215,
      val_216,
      val_217,
      val_219,
      val_218,
      val_220,
      val_221,
      val_222,
      val_223,
      val_224,
      val_225,
      val_226,
      val_227,
      val_228,
      val_229,
      val_230,
      val_231,
      val_232,
      val_233,
      val_234,
      val_235,
      val_236,
      val_237,
      val_238,
      val_239,
      val_240,
      val_241,
      val_242,
      val_243,
      val_244,
      val_245,
      val_246,
      val_247,
      val_248,
      val_249,
      val_250,
      val_251,
      val_252,
      val_253,
      val_254,
      val_255,
      val_256,
      val_257,
      val_258,
      val_259,
      val_260,
      val_261,
      val_262,
      val_263,
      val_264,
      val_265,
      val_266,
      val_267,
      val_268,
      val_269,
      val_270,
      val_271,
      val_272,
      val_273,
      val_274,
      val_275,
      val_276,
      val_277,
      val_278,
      val_279,
      val_280,
      val_281,
      val_282,
      val_283,
      val_284,
      val_285,
      val_286,
      val_287,
      val_288,
      val_289,
      val_290,
      val_291,
      val_292,
      val_293,
      val_294,
      val_295,
      val_296,
      val_297,
      val_298,
      val_299,
      val_300,
      group_val_01 ,
      group_val_02 ,
	program_application_id,
	program_id,
	program_update_date,
	request_id,
	object_version_number,
        ext_rcd_in_file_id
    from	ben_ext_rslt_dtl
    where	ext_rslt_dtl_id = p_ext_rslt_dtl_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ben_ext_rslt_dtl');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_rslt_dtl_id               in number,
	p_prmy_sort_val                 in varchar2,
	p_scnd_sort_val                 in varchar2,
	p_thrd_sort_val                 in varchar2,
	p_trans_seq_num                 in number,
	p_rcrd_seq_num                  in number,
	p_ext_rslt_id                   in number,
	p_ext_rcd_id                    in number,
	p_person_id                     in number,
	p_business_group_id             in number,
	p_ext_per_bg_id                  in number,
	p_val_01                        in varchar2,
	p_val_02                        in varchar2,
	p_val_03                        in varchar2,
	p_val_04                        in varchar2,
	p_val_05                        in varchar2,
	p_val_06                        in varchar2,
	p_val_07                        in varchar2,
	p_val_08                        in varchar2,
	p_val_09                        in varchar2,
	p_val_10                        in varchar2,
	p_val_11                        in varchar2,
	p_val_12                        in varchar2,
	p_val_13                        in varchar2,
	p_val_14                        in varchar2,
	p_val_15                        in varchar2,
	p_val_16                        in varchar2,
	p_val_17                        in varchar2,
	p_val_19                        in varchar2,
	p_val_18                        in varchar2,
	p_val_20                        in varchar2,
	p_val_21                        in varchar2,
	p_val_22                        in varchar2,
	p_val_23                        in varchar2,
	p_val_24                        in varchar2,
	p_val_25                        in varchar2,
	p_val_26                        in varchar2,
	p_val_27                        in varchar2,
	p_val_28                        in varchar2,
	p_val_29                        in varchar2,
	p_val_30                        in varchar2,
	p_val_31                        in varchar2,
	p_val_32                        in varchar2,
	p_val_33                        in varchar2,
	p_val_34                        in varchar2,
	p_val_35                        in varchar2,
	p_val_36                        in varchar2,
	p_val_37                        in varchar2,
	p_val_38                        in varchar2,
	p_val_39                        in varchar2,
	p_val_40                        in varchar2,
	p_val_41                        in varchar2,
	p_val_42                        in varchar2,
	p_val_43                        in varchar2,
	p_val_44                        in varchar2,
	p_val_45                        in varchar2,
	p_val_46                        in varchar2,
	p_val_47                        in varchar2,
	p_val_48                        in varchar2,
	p_val_49                        in varchar2,
	p_val_50                        in varchar2,
	p_val_51                        in varchar2,
	p_val_52                        in varchar2,
	p_val_53                        in varchar2,
	p_val_54                        in varchar2,
	p_val_55                        in varchar2,
	p_val_56                        in varchar2,
	p_val_57                        in varchar2,
	p_val_58                        in varchar2,
	p_val_59                        in varchar2,
	p_val_60                        in varchar2,
	p_val_61                        in varchar2,
	p_val_62                        in varchar2,
	p_val_63                        in varchar2,
	p_val_64                        in varchar2,
	p_val_65                        in varchar2,
	p_val_66                        in varchar2,
	p_val_67                        in varchar2,
	p_val_68                        in varchar2,
	p_val_69                        in varchar2,
	p_val_70                        in varchar2,
	p_val_71                        in varchar2,
	p_val_72                        in varchar2,
	p_val_73                        in varchar2,
	p_val_74                        in varchar2,
	p_val_75                        in varchar2,
      p_val_76                        in  varchar2,
      p_val_77                        in  varchar2,
      p_val_78                        in  varchar2,
      p_val_79                        in  varchar2,
      p_val_80                        in  varchar2,
      p_val_81                        in  varchar2,
      p_val_82                        in  varchar2,
      p_val_83                        in  varchar2,
      p_val_84                        in  varchar2,
      p_val_85                        in  varchar2,
      p_val_86                        in  varchar2,
      p_val_87                        in  varchar2,
      p_val_88                        in  varchar2,
      p_val_89                        in  varchar2,
      p_val_90                        in  varchar2,
      p_val_91                        in  varchar2,
      p_val_92                        in  varchar2,
      p_val_93                        in  varchar2,
      p_val_94                        in  varchar2,
      p_val_95                        in  varchar2,
      p_val_96                        in  varchar2,
      p_val_97                        in  varchar2,
      p_val_98                        in  varchar2,
      p_val_99                        in  varchar2,
      p_val_100                       in  varchar2,
      p_val_101                        in  varchar2,
      p_val_102                        in  varchar2,
      p_val_103                        in  varchar2,
      p_val_104                        in  varchar2,
      p_val_105                        in  varchar2,
      p_val_106                        in  varchar2,
      p_val_107                        in  varchar2,
      p_val_108                        in  varchar2,
      p_val_109                        in  varchar2,
      p_val_110                        in  varchar2,
      p_val_111                        in  varchar2,
      p_val_112                        in  varchar2,
      p_val_113                        in  varchar2,
      p_val_114                        in  varchar2,
      p_val_115                        in  varchar2,
      p_val_116                        in  varchar2,
      p_val_117                        in  varchar2,
      p_val_119                        in  varchar2,
      p_val_118                        in  varchar2,
      p_val_120                        in  varchar2,
      p_val_121                        in  varchar2,
      p_val_122                        in  varchar2,
      p_val_123                        in  varchar2,
      p_val_124                        in  varchar2,
      p_val_125                        in  varchar2,
      p_val_126                        in  varchar2,
      p_val_127                        in  varchar2,
      p_val_128                        in  varchar2,
      p_val_129                        in  varchar2,
      p_val_130                        in  varchar2,
      p_val_131                        in  varchar2,
      p_val_132                        in  varchar2,
      p_val_133                        in  varchar2,
      p_val_134                        in  varchar2,
      p_val_135                        in  varchar2,
      p_val_136                        in  varchar2,
      p_val_137                        in  varchar2,
      p_val_138                        in  varchar2,
      p_val_139                        in  varchar2,
      p_val_140                        in  varchar2,
      p_val_141                        in  varchar2,
      p_val_142                        in  varchar2,
      p_val_143                        in  varchar2,
      p_val_144                        in  varchar2,
      p_val_145                        in  varchar2,
      p_val_146                        in  varchar2,
      p_val_147                        in  varchar2,
      p_val_148                        in  varchar2,
      p_val_149                        in  varchar2,
      p_val_150                        in  varchar2,
      p_val_151                        in  varchar2,
      p_val_152                        in  varchar2,
      p_val_153                        in  varchar2,
      p_val_154                        in  varchar2,
      p_val_155                        in  varchar2,
      p_val_156                        in  varchar2,
      p_val_157                        in  varchar2,
      p_val_158                        in  varchar2,
      p_val_159                        in  varchar2,
      p_val_160                        in  varchar2,
      p_val_161                        in  varchar2,
      p_val_162                        in  varchar2,
      p_val_163                        in  varchar2,
      p_val_164                        in  varchar2,
      p_val_165                        in  varchar2,
      p_val_166                        in  varchar2,
      p_val_167                        in  varchar2,
      p_val_168                        in  varchar2,
      p_val_169                        in  varchar2,
      p_val_170                        in  varchar2,
      p_val_171                        in  varchar2,
      p_val_172                        in  varchar2,
      p_val_173                        in  varchar2,
      p_val_174                        in  varchar2,
      p_val_175                        in  varchar2,
      p_val_176                        in  varchar2,
      p_val_177                        in  varchar2,
      p_val_178                        in  varchar2,
      p_val_179                        in  varchar2,
      p_val_180                        in  varchar2,
      p_val_181                        in  varchar2,
      p_val_182                        in  varchar2,
      p_val_183                        in  varchar2,
      p_val_184                        in  varchar2,
      p_val_185                        in  varchar2,
      p_val_186                        in  varchar2,
      p_val_187                        in  varchar2,
      p_val_188                        in  varchar2,
      p_val_189                        in  varchar2,
      p_val_190                        in  varchar2,
      p_val_191                        in  varchar2,
      p_val_192                        in  varchar2,
      p_val_193                        in  varchar2,
      p_val_194                        in  varchar2,
      p_val_195                        in  varchar2,
      p_val_196                        in  varchar2,
      p_val_197                        in  varchar2,
      p_val_198                        in  varchar2,
      p_val_199                        in  varchar2,
      p_val_200                        in  varchar2,
      p_val_201                        in  varchar2,
      p_val_202                        in  varchar2,
      p_val_203                        in  varchar2,
      p_val_204                        in  varchar2,
      p_val_205                        in  varchar2,
      p_val_206                        in  varchar2,
      p_val_207                        in  varchar2,
      p_val_208                        in  varchar2,
      p_val_209                        in  varchar2,
      p_val_210                        in  varchar2,
      p_val_211                        in  varchar2,
      p_val_212                        in  varchar2,
      p_val_213                        in  varchar2,
      p_val_214                        in  varchar2,
      p_val_215                        in  varchar2,
      p_val_216                        in  varchar2,
      p_val_217                        in  varchar2,
      p_val_219                        in  varchar2,
      p_val_218                        in  varchar2,
      p_val_220                        in  varchar2,
      p_val_221                        in  varchar2,
      p_val_222                        in  varchar2,
      p_val_223                        in  varchar2,
      p_val_224                        in  varchar2,
      p_val_225                        in  varchar2,
      p_val_226                        in  varchar2,
      p_val_227                        in  varchar2,
      p_val_228                        in  varchar2,
      p_val_229                        in  varchar2,
      p_val_230                        in  varchar2,
      p_val_231                        in  varchar2,
      p_val_232                        in  varchar2,
      p_val_233                        in  varchar2,
      p_val_234                        in  varchar2,
      p_val_235                        in  varchar2,
      p_val_236                        in  varchar2,
      p_val_237                        in  varchar2,
      p_val_238                        in  varchar2,
      p_val_239                        in  varchar2,
      p_val_240                        in  varchar2,
      p_val_241                        in  varchar2,
      p_val_242                        in  varchar2,
      p_val_243                        in  varchar2,
      p_val_244                        in  varchar2,
      p_val_245                        in  varchar2,
      p_val_246                        in  varchar2,
      p_val_247                        in  varchar2,
      p_val_248                        in  varchar2,
      p_val_249                        in  varchar2,
      p_val_250                        in  varchar2,
      p_val_251                        in  varchar2,
      p_val_252                        in  varchar2,
      p_val_253                        in  varchar2,
      p_val_254                        in  varchar2,
      p_val_255                        in  varchar2,
      p_val_256                        in  varchar2,
      p_val_257                        in  varchar2,
      p_val_258                        in  varchar2,
      p_val_259                        in  varchar2,
      p_val_260                        in  varchar2,
      p_val_261                        in  varchar2,
      p_val_262                        in  varchar2,
      p_val_263                        in  varchar2,
      p_val_264                        in  varchar2,
      p_val_265                        in  varchar2,
      p_val_266                        in  varchar2,
      p_val_267                        in  varchar2,
      p_val_268                        in  varchar2,
      p_val_269                        in  varchar2,
      p_val_270                        in  varchar2,
      p_val_271                        in  varchar2,
      p_val_272                        in  varchar2,
      p_val_273                        in  varchar2,
      p_val_274                        in  varchar2,
      p_val_275                        in  varchar2,
      p_val_276                        in  varchar2,
      p_val_277                        in  varchar2,
      p_val_278                        in  varchar2,
      p_val_279                        in  varchar2,
      p_val_280                        in  varchar2,
      p_val_281                        in  varchar2,
      p_val_282                        in  varchar2,
      p_val_283                        in  varchar2,
      p_val_284                        in  varchar2,
      p_val_285                        in  varchar2,
      p_val_286                        in  varchar2,
      p_val_287                        in  varchar2,
      p_val_288                        in  varchar2,
      p_val_289                        in  varchar2,
      p_val_290                        in  varchar2,
      p_val_291                        in  varchar2,
      p_val_292                        in  varchar2,
      p_val_293                        in  varchar2,
      p_val_294                        in  varchar2,
      p_val_295                        in  varchar2,
      p_val_296                        in  varchar2,
      p_val_297                        in  varchar2,
      p_val_298                        in  varchar2,
      p_val_299                        in  varchar2,
      p_val_300                        in  varchar2,
      p_group_val_01                   in  varchar2,
      p_group_val_02                   in  varchar2 ,
      p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_request_id                    in number,
	p_object_version_number         in number,
	p_ext_rcd_in_file_id            in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.ext_rslt_dtl_id                  := p_ext_rslt_dtl_id;
  l_rec.prmy_sort_val                    := p_prmy_sort_val;
  l_rec.scnd_sort_val                    := p_scnd_sort_val;
  l_rec.thrd_sort_val                    := p_thrd_sort_val;
  l_rec.trans_seq_num                    := p_trans_seq_num;
  l_rec.rcrd_seq_num                     := p_rcrd_seq_num;
  l_rec.ext_rslt_id                      := p_ext_rslt_id;
  l_rec.ext_rcd_id                       := p_ext_rcd_id;
  l_rec.person_id                        := p_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.ext_per_bg_id                    := p_ext_per_bg_id   ;
  l_rec.val_01                           := p_val_01;
  l_rec.val_02                           := p_val_02;
  l_rec.val_03                           := p_val_03;
  l_rec.val_04                           := p_val_04;
  l_rec.val_05                           := p_val_05;
  l_rec.val_06                           := p_val_06;
  l_rec.val_07                           := p_val_07;
  l_rec.val_08                           := p_val_08;
  l_rec.val_09                           := p_val_09;
  l_rec.val_10                           := p_val_10;
  l_rec.val_11                           := p_val_11;
  l_rec.val_12                           := p_val_12;
  l_rec.val_13                           := p_val_13;
  l_rec.val_14                           := p_val_14;
  l_rec.val_15                           := p_val_15;
  l_rec.val_16                           := p_val_16;
  l_rec.val_17                           := p_val_17;
  l_rec.val_19                           := p_val_19;
  l_rec.val_18                           := p_val_18;
  l_rec.val_20                           := p_val_20;
  l_rec.val_21                           := p_val_21;
  l_rec.val_22                           := p_val_22;
  l_rec.val_23                           := p_val_23;
  l_rec.val_24                           := p_val_24;
  l_rec.val_25                           := p_val_25;
  l_rec.val_26                           := p_val_26;
  l_rec.val_27                           := p_val_27;
  l_rec.val_28                           := p_val_28;
  l_rec.val_29                           := p_val_29;
  l_rec.val_30                           := p_val_30;
  l_rec.val_31                           := p_val_31;
  l_rec.val_32                           := p_val_32;
  l_rec.val_33                           := p_val_33;
  l_rec.val_34                           := p_val_34;
  l_rec.val_35                           := p_val_35;
  l_rec.val_36                           := p_val_36;
  l_rec.val_37                           := p_val_37;
  l_rec.val_38                           := p_val_38;
  l_rec.val_39                           := p_val_39;
  l_rec.val_40                           := p_val_40;
  l_rec.val_41                           := p_val_41;
  l_rec.val_42                           := p_val_42;
  l_rec.val_43                           := p_val_43;
  l_rec.val_44                           := p_val_44;
  l_rec.val_45                           := p_val_45;
  l_rec.val_46                           := p_val_46;
  l_rec.val_47                           := p_val_47;
  l_rec.val_48                           := p_val_48;
  l_rec.val_49                           := p_val_49;
  l_rec.val_50                           := p_val_50;
  l_rec.val_51                           := p_val_51;
  l_rec.val_52                           := p_val_52;
  l_rec.val_53                           := p_val_53;
  l_rec.val_54                           := p_val_54;
  l_rec.val_55                           := p_val_55;
  l_rec.val_56                           := p_val_56;
  l_rec.val_57                           := p_val_57;
  l_rec.val_58                           := p_val_58;
  l_rec.val_59                           := p_val_59;
  l_rec.val_60                           := p_val_60;
  l_rec.val_61                           := p_val_61;
  l_rec.val_62                           := p_val_62;
  l_rec.val_63                           := p_val_63;
  l_rec.val_64                           := p_val_64;
  l_rec.val_65                           := p_val_65;
  l_rec.val_66                           := p_val_66;
  l_rec.val_67                           := p_val_67;
  l_rec.val_68                           := p_val_68;
  l_rec.val_69                           := p_val_69;
  l_rec.val_70                           := p_val_70;
  l_rec.val_71                           := p_val_71;
  l_rec.val_72                           := p_val_72;
  l_rec.val_73                           := p_val_73;
  l_rec.val_74                           := p_val_74;
  l_rec.val_75                           := p_val_75;
  l_rec.val_76                           :=  p_val_76;
  l_rec.val_77                           :=  p_val_77;
  l_rec.val_78                           :=  p_val_78;
  l_rec.val_79                           :=  p_val_79;
  l_rec.val_80                           :=  p_val_80;
  l_rec.val_81                           :=  p_val_81;
  l_rec.val_82                           :=  p_val_82;
  l_rec.val_83                           :=  p_val_83;
  l_rec.val_84                           :=  p_val_84;
  l_rec.val_85                           :=  p_val_85;
  l_rec.val_86                           :=  p_val_86;
  l_rec.val_87                           :=  p_val_87;
  l_rec.val_88                           :=  p_val_88;
  l_rec.val_89                           :=  p_val_89;
  l_rec.val_90                           :=  p_val_90;
  l_rec.val_91                           :=  p_val_91;
  l_rec.val_92                           :=  p_val_92;
  l_rec.val_93                           :=  p_val_93;
  l_rec.val_94                           :=  p_val_94;
  l_rec.val_95                           :=  p_val_95;
  l_rec.val_96                           :=  p_val_96;
  l_rec.val_97                           :=  p_val_97;
  l_rec.val_98                           :=  p_val_98;
  l_rec.val_99                           :=  p_val_99;
  l_rec.val_100                          :=  p_val_100;
  l_rec.val_101                          :=  p_val_101;
  l_rec.val_102                           :=  p_val_102;
  l_rec.val_103                           :=  p_val_103;
  l_rec.val_104                           :=  p_val_104;
  l_rec.val_105                           :=  p_val_105;
  l_rec.val_106                           :=  p_val_106;
  l_rec.val_107                           :=  p_val_107;
  l_rec.val_108                           :=  p_val_108;
  l_rec.val_109                           :=  p_val_109;
  l_rec.val_110                           :=  p_val_110;
  l_rec.val_111                           :=  p_val_111;
  l_rec.val_112                           :=  p_val_112;
  l_rec.val_113                           :=  p_val_113;
  l_rec.val_114                           :=  p_val_114;
  l_rec.val_115                           :=  p_val_115;
  l_rec.val_116                           :=  p_val_116;
  l_rec.val_117                           :=  p_val_117;
  l_rec.val_119                           :=  p_val_119;
  l_rec.val_118                           :=  p_val_118;
  l_rec.val_120                           :=  p_val_120;
  l_rec.val_121                           :=  p_val_121;
  l_rec.val_122                           :=  p_val_122;
  l_rec.val_123                           :=  p_val_123;
  l_rec.val_124                           :=  p_val_124;
  l_rec.val_125                           :=  p_val_125;
  l_rec.val_126                           :=  p_val_126;
  l_rec.val_127                           :=  p_val_127;
  l_rec.val_128                           :=  p_val_128;
  l_rec.val_129                           :=  p_val_129;
  l_rec.val_130                           :=  p_val_130;
  l_rec.val_131                           :=  p_val_131;
  l_rec.val_132                           :=  p_val_132;
  l_rec.val_133                           :=  p_val_133;
  l_rec.val_134                           :=  p_val_134;
  l_rec.val_135                           :=  p_val_135;
  l_rec.val_136                           :=  p_val_136;
  l_rec.val_137                           :=  p_val_137;
  l_rec.val_138                           :=  p_val_138;
  l_rec.val_139                           :=  p_val_139;
  l_rec.val_140                           :=  p_val_140;
  l_rec.val_141                           :=  p_val_141;
  l_rec.val_142                           :=  p_val_142;
  l_rec.val_143                           :=  p_val_143;
  l_rec.val_144                           :=  p_val_144;
  l_rec.val_145                           :=  p_val_145;
  l_rec.val_146                           :=  p_val_146;
  l_rec.val_147                           :=  p_val_147;
  l_rec.val_148                           :=  p_val_148;
  l_rec.val_149                           :=  p_val_149;
  l_rec.val_150                           :=  p_val_150;
  l_rec.val_151                           :=  p_val_151;
  l_rec.val_152                           :=  p_val_152;
  l_rec.val_153                           :=  p_val_153;
  l_rec.val_154                           :=  p_val_154;
  l_rec.val_155                           :=  p_val_155;
  l_rec.val_156                           :=  p_val_156;
  l_rec.val_157                           :=  p_val_157;
  l_rec.val_158                           :=  p_val_158;
  l_rec.val_159                           :=  p_val_159;
  l_rec.val_160                           :=  p_val_160;
  l_rec.val_161                           :=  p_val_161;
  l_rec.val_162                           :=  p_val_162;
  l_rec.val_163                           :=  p_val_163;
  l_rec.val_164                           :=  p_val_164;
  l_rec.val_165                           :=  p_val_165;
  l_rec.val_166                           :=  p_val_166;
  l_rec.val_167                           :=  p_val_167;
  l_rec.val_168                           :=  p_val_168;
  l_rec.val_169                           :=  p_val_169;
  l_rec.val_170                           :=  p_val_170;
  l_rec.val_171                           :=  p_val_171;
  l_rec.val_172                           :=  p_val_172;
  l_rec.val_173                           :=  p_val_173;
  l_rec.val_174                           :=  p_val_174;
  l_rec.val_175                           :=  p_val_175;
  l_rec.val_176                           :=  p_val_176;
  l_rec.val_177                           :=  p_val_177;
  l_rec.val_178                           :=  p_val_178;
  l_rec.val_179                           :=  p_val_179;
  l_rec.val_180                           :=  p_val_180;
  l_rec.val_181                           :=  p_val_181;
  l_rec.val_182                           :=  p_val_182;
  l_rec.val_183                           :=  p_val_183;
  l_rec.val_184                           :=  p_val_184;
  l_rec.val_185                           :=  p_val_185;
  l_rec.val_186                           :=  p_val_186;
  l_rec.val_187                           :=  p_val_187;
  l_rec.val_188                           :=  p_val_188;
  l_rec.val_189                           :=  p_val_189;
  l_rec.val_190                           :=  p_val_190;
  l_rec.val_191                           :=  p_val_191;
  l_rec.val_192                           :=  p_val_192;
  l_rec.val_193                           :=  p_val_193;
  l_rec.val_194                           :=  p_val_194;
  l_rec.val_195                           :=  p_val_195;
  l_rec.val_196                           :=  p_val_196;
  l_rec.val_197                           :=  p_val_197;
  l_rec.val_198                           :=  p_val_198;
  l_rec.val_199                           :=  p_val_199;
  l_rec.val_200                           :=  p_val_200;
  l_rec.val_201                           :=  p_val_201 ;
  l_rec.val_202                           :=  p_val_202 ;
  l_rec.val_203                           :=  p_val_203 ;
  l_rec.val_204                           :=  p_val_204 ;
  l_rec.val_205                           :=  p_val_205 ;
  l_rec.val_206                           :=  p_val_206 ;
  l_rec.val_207                           :=  p_val_207 ;
  l_rec.val_208                           :=  p_val_208 ;
  l_rec.val_209                           :=  p_val_209 ;
  l_rec.val_210                           :=  p_val_210 ;
  l_rec.val_211                           :=  p_val_211 ;
  l_rec.val_212                           :=  p_val_212 ;
  l_rec.val_213                           :=  p_val_213 ;
  l_rec.val_214                           :=  p_val_214 ;
  l_rec.val_215                           :=  p_val_215 ;
  l_rec.val_216                           :=  p_val_216 ;
  l_rec.val_217                           :=  p_val_217 ;
  l_rec.val_219                           :=  p_val_219 ;
  l_rec.val_218                           :=  p_val_218 ;
  l_rec.val_220                           :=  p_val_220 ;
  l_rec.val_221                           :=  p_val_221 ;
  l_rec.val_222                           :=  p_val_222 ;
  l_rec.val_223                           :=  p_val_223 ;
  l_rec.val_224                           :=  p_val_224 ;
  l_rec.val_225                           :=  p_val_225 ;
  l_rec.val_226                           :=  p_val_226 ;
  l_rec.val_227                           :=  p_val_227 ;
  l_rec.val_228                           :=  p_val_228 ;
  l_rec.val_229                           :=  p_val_229 ;
  l_rec.val_230                           :=  p_val_230 ;
  l_rec.val_231                           :=  p_val_231 ;
  l_rec.val_232                           :=  p_val_232 ;
  l_rec.val_233                           :=  p_val_233 ;
  l_rec.val_234                           :=  p_val_234 ;
  l_rec.val_235                           :=  p_val_235 ;
  l_rec.val_236                           :=  p_val_236 ;
  l_rec.val_237                           :=  p_val_237 ;
  l_rec.val_238                           :=  p_val_238 ;
  l_rec.val_239                           :=  p_val_239 ;
  l_rec.val_240                           :=  p_val_240 ;
  l_rec.val_241                           :=  p_val_241 ;
  l_rec.val_242                           :=  p_val_242 ;
  l_rec.val_243                           :=  p_val_243 ;
  l_rec.val_244                           :=  p_val_244 ;
  l_rec.val_245                           :=  p_val_245 ;
  l_rec.val_246                           :=  p_val_246 ;
  l_rec.val_247                           :=  p_val_247 ;
  l_rec.val_248                           :=  p_val_248 ;
  l_rec.val_249                           :=  p_val_249 ;
  l_rec.val_250                           :=  p_val_250 ;
  l_rec.val_251                           :=  p_val_251 ;
  l_rec.val_252                           :=  p_val_252 ;
  l_rec.val_253                           :=  p_val_253 ;
  l_rec.val_254                           :=  p_val_254 ;
  l_rec.val_255                           :=  p_val_255 ;
  l_rec.val_256                           :=  p_val_256 ;
  l_rec.val_257                           :=  p_val_257 ;
  l_rec.val_258                           :=  p_val_258 ;
  l_rec.val_259                           :=  p_val_259 ;
  l_rec.val_260                           :=  p_val_260 ;
  l_rec.val_261                           :=  p_val_261 ;
  l_rec.val_262                           :=  p_val_262 ;
  l_rec.val_263                           :=  p_val_263 ;
  l_rec.val_264                           :=  p_val_264 ;
  l_rec.val_265                           :=  p_val_265 ;
  l_rec.val_266                           :=  p_val_266 ;
  l_rec.val_267                           :=  p_val_267 ;
  l_rec.val_268                           :=  p_val_268 ;
  l_rec.val_269                           :=  p_val_269 ;
  l_rec.val_270                           :=  p_val_270 ;
  l_rec.val_271                           :=  p_val_271 ;
  l_rec.val_272                           :=  p_val_272 ;
  l_rec.val_273                           :=  p_val_273 ;
  l_rec.val_274                           :=  p_val_274 ;
  l_rec.val_275                           :=  p_val_275 ;
  l_rec.val_276                           :=  p_val_276 ;
  l_rec.val_277                           :=  p_val_277 ;
  l_rec.val_278                           :=  p_val_278 ;
  l_rec.val_279                           :=  p_val_279 ;
  l_rec.val_280                           :=  p_val_280 ;
  l_rec.val_281                           :=  p_val_281 ;
  l_rec.val_282                           :=  p_val_282 ;
  l_rec.val_283                           :=  p_val_283 ;
  l_rec.val_284                           :=  p_val_284 ;
  l_rec.val_285                           :=  p_val_285 ;
  l_rec.val_286                           :=  p_val_286 ;
  l_rec.val_287                           :=  p_val_287 ;
  l_rec.val_288                           :=  p_val_288 ;
  l_rec.val_289                           :=  p_val_289 ;
  l_rec.val_290                           :=  p_val_290 ;
  l_rec.val_291                           :=  p_val_291 ;
  l_rec.val_292                           :=  p_val_292 ;
  l_rec.val_293                           :=  p_val_293 ;
  l_rec.val_294                           :=  p_val_294 ;
  l_rec.val_295                           :=  p_val_295 ;
  l_rec.val_296                           :=  p_val_296 ;
  l_rec.val_297                           :=  p_val_297 ;
  l_rec.val_298                           :=  p_val_298 ;
  l_rec.val_299                           :=  p_val_299 ;
  l_rec.val_300                           :=  p_val_300;
  l_rec.group_val_01                      :=  p_group_val_01;
  l_rec.group_val_02                      :=  p_group_val_02;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.request_id                       := p_request_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.ext_rcd_in_file_id               := p_ext_rcd_in_file_id;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_xrd_shd;

/