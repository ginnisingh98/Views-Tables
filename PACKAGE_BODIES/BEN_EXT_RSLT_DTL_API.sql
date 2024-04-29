--------------------------------------------------------
--  DDL for Package Body BEN_EXT_RSLT_DTL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_RSLT_DTL_API" as
/* $Header: bexrdapi.pkb 120.0 2005/05/28 12:38:34 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_RSLT_DTL_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RSLT_DTL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RSLT_DTL
  (p_validate                       in  boolean   default false
  ,p_ext_rslt_dtl_id                out nocopy number
  ,p_prmy_sort_val                  in  varchar2  default null
  ,p_scnd_sort_val                  in  varchar2  default null
  ,p_thrd_sort_val                  in  varchar2  default null
  ,p_trans_seq_num                  in  number    default null
  ,p_rcrd_seq_num                   in  number    default null
  ,p_ext_rslt_id                    in  number    default null
  ,p_ext_rcd_id                     in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ext_per_bg_id                  in  number    default null
  ,p_val_01                         in  varchar2  default null
  ,p_val_02                         in  varchar2  default null
  ,p_val_03                         in  varchar2  default null
  ,p_val_04                         in  varchar2  default null
  ,p_val_05                         in  varchar2  default null
  ,p_val_06                         in  varchar2  default null
  ,p_val_07                         in  varchar2  default null
  ,p_val_08                         in  varchar2  default null
  ,p_val_09                         in  varchar2  default null
  ,p_val_10                         in  varchar2  default null
  ,p_val_11                         in  varchar2  default null
  ,p_val_12                         in  varchar2  default null
  ,p_val_13                         in  varchar2  default null
  ,p_val_14                         in  varchar2  default null
  ,p_val_15                         in  varchar2  default null
  ,p_val_16                         in  varchar2  default null
  ,p_val_17                         in  varchar2  default null
  ,p_val_19                         in  varchar2  default null
  ,p_val_18                         in  varchar2  default null
  ,p_val_20                         in  varchar2  default null
  ,p_val_21                         in  varchar2  default null
  ,p_val_22                         in  varchar2  default null
  ,p_val_23                         in  varchar2  default null
  ,p_val_24                         in  varchar2  default null
  ,p_val_25                         in  varchar2  default null
  ,p_val_26                         in  varchar2  default null
  ,p_val_27                         in  varchar2  default null
  ,p_val_28                         in  varchar2  default null
  ,p_val_29                         in  varchar2  default null
  ,p_val_30                         in  varchar2  default null
  ,p_val_31                         in  varchar2  default null
  ,p_val_32                         in  varchar2  default null
  ,p_val_33                         in  varchar2  default null
  ,p_val_34                         in  varchar2  default null
  ,p_val_35                         in  varchar2  default null
  ,p_val_36                         in  varchar2  default null
  ,p_val_37                         in  varchar2  default null
  ,p_val_38                         in  varchar2  default null
  ,p_val_39                         in  varchar2  default null
  ,p_val_40                         in  varchar2  default null
  ,p_val_41                         in  varchar2  default null
  ,p_val_42                         in  varchar2  default null
  ,p_val_43                         in  varchar2  default null
  ,p_val_44                         in  varchar2  default null
  ,p_val_45                         in  varchar2  default null
  ,p_val_46                         in  varchar2  default null
  ,p_val_47                         in  varchar2  default null
  ,p_val_48                         in  varchar2  default null
  ,p_val_49                         in  varchar2  default null
  ,p_val_50                         in  varchar2  default null
  ,p_val_51                         in  varchar2  default null
  ,p_val_52                         in  varchar2  default null
  ,p_val_53                         in  varchar2  default null
  ,p_val_54                         in  varchar2  default null
  ,p_val_55                         in  varchar2  default null
  ,p_val_56                         in  varchar2  default null
  ,p_val_57                         in  varchar2  default null
  ,p_val_58                         in  varchar2  default null
  ,p_val_59                         in  varchar2  default null
  ,p_val_60                         in  varchar2  default null
  ,p_val_61                         in  varchar2  default null
  ,p_val_62                         in  varchar2  default null
  ,p_val_63                         in  varchar2  default null
  ,p_val_64                         in  varchar2  default null
  ,p_val_65                         in  varchar2  default null
  ,p_val_66                         in  varchar2  default null
  ,p_val_67                         in  varchar2  default null
  ,p_val_68                         in  varchar2  default null
  ,p_val_69                         in  varchar2  default null
  ,p_val_70                         in  varchar2  default null
  ,p_val_71                         in  varchar2  default null
  ,p_val_72                         in  varchar2  default null
  ,p_val_73                         in  varchar2  default null
  ,p_val_74                         in  varchar2  default null
  ,p_val_75                         in  varchar2  default null
  ,p_val_76                         in  varchar2  default null
  ,p_val_77                         in  varchar2  default null
  ,p_val_78                         in  varchar2  default null
  ,p_val_79                         in  varchar2  default null
  ,p_val_80                         in  varchar2  default null
  ,p_val_81                         in  varchar2  default null
  ,p_val_82                         in  varchar2  default null
  ,p_val_83                         in  varchar2  default null
  ,p_val_84                         in  varchar2  default null
  ,p_val_85                         in  varchar2  default null
  ,p_val_86                         in  varchar2  default null
  ,p_val_87                         in  varchar2  default null
  ,p_val_88                         in  varchar2  default null
  ,p_val_89                         in  varchar2  default null
  ,p_val_90                         in  varchar2  default null
  ,p_val_91                         in  varchar2  default null
  ,p_val_92                         in  varchar2  default null
  ,p_val_93                         in  varchar2  default null
  ,p_val_94                         in  varchar2  default null
  ,p_val_95                         in  varchar2  default null
  ,p_val_96                         in  varchar2  default null
  ,p_val_97                         in  varchar2  default null
  ,p_val_98                         in  varchar2  default null
  ,p_val_99                         in  varchar2  default null
  ,p_val_100                        in  varchar2  default null
  ,p_val_101                         in  varchar2  default null
  ,p_val_102                         in  varchar2  default null
  ,p_val_103                         in  varchar2  default null
  ,p_val_104                         in  varchar2  default null
  ,p_val_105                         in  varchar2  default null
  ,p_val_106                         in  varchar2  default null
  ,p_val_107                         in  varchar2  default null
  ,p_val_108                         in  varchar2  default null
  ,p_val_109                         in  varchar2  default null
  ,p_val_110                         in  varchar2  default null
  ,p_val_111                         in  varchar2  default null
  ,p_val_112                         in  varchar2  default null
  ,p_val_113                         in  varchar2  default null
  ,p_val_114                         in  varchar2  default null
  ,p_val_115                         in  varchar2  default null
  ,p_val_116                         in  varchar2  default null
  ,p_val_117                         in  varchar2  default null
  ,p_val_119                         in  varchar2  default null
  ,p_val_118                         in  varchar2  default null
  ,p_val_120                         in  varchar2  default null
  ,p_val_121                         in  varchar2  default null
  ,p_val_122                         in  varchar2  default null
  ,p_val_123                         in  varchar2  default null
  ,p_val_124                         in  varchar2  default null
  ,p_val_125                         in  varchar2  default null
  ,p_val_126                         in  varchar2  default null
  ,p_val_127                         in  varchar2  default null
  ,p_val_128                         in  varchar2  default null
  ,p_val_129                         in  varchar2  default null
  ,p_val_130                         in  varchar2  default null
  ,p_val_131                         in  varchar2  default null
  ,p_val_132                         in  varchar2  default null
  ,p_val_133                         in  varchar2  default null
  ,p_val_134                         in  varchar2  default null
  ,p_val_135                         in  varchar2  default null
  ,p_val_136                         in  varchar2  default null
  ,p_val_137                         in  varchar2  default null
  ,p_val_138                         in  varchar2  default null
  ,p_val_139                         in  varchar2  default null
  ,p_val_140                         in  varchar2  default null
  ,p_val_141                         in  varchar2  default null
  ,p_val_142                         in  varchar2  default null
  ,p_val_143                         in  varchar2  default null
  ,p_val_144                         in  varchar2  default null
  ,p_val_145                         in  varchar2  default null
  ,p_val_146                         in  varchar2  default null
  ,p_val_147                         in  varchar2  default null
  ,p_val_148                         in  varchar2  default null
  ,p_val_149                         in  varchar2  default null
  ,p_val_150                         in  varchar2  default null
  ,p_val_151                         in  varchar2  default null
  ,p_val_152                         in  varchar2  default null
  ,p_val_153                         in  varchar2  default null
  ,p_val_154                         in  varchar2  default null
  ,p_val_155                         in  varchar2  default null
  ,p_val_156                         in  varchar2  default null
  ,p_val_157                         in  varchar2  default null
  ,p_val_158                         in  varchar2  default null
  ,p_val_159                         in  varchar2  default null
  ,p_val_160                         in  varchar2  default null
  ,p_val_161                         in  varchar2  default null
  ,p_val_162                         in  varchar2  default null
  ,p_val_163                         in  varchar2  default null
  ,p_val_164                         in  varchar2  default null
  ,p_val_165                         in  varchar2  default null
  ,p_val_166                         in  varchar2  default null
  ,p_val_167                         in  varchar2  default null
  ,p_val_168                         in  varchar2  default null
  ,p_val_169                         in  varchar2  default null
  ,p_val_170                         in  varchar2  default null
  ,p_val_171                         in  varchar2  default null
  ,p_val_172                         in  varchar2  default null
  ,p_val_173                         in  varchar2  default null
  ,p_val_174                         in  varchar2  default null
  ,p_val_175                         in  varchar2  default null
  ,p_val_176                         in  varchar2  default null
  ,p_val_177                         in  varchar2  default null
  ,p_val_178                         in  varchar2  default null
  ,p_val_179                         in  varchar2  default null
  ,p_val_180                         in  varchar2  default null
  ,p_val_181                         in  varchar2  default null
  ,p_val_182                         in  varchar2  default null
  ,p_val_183                         in  varchar2  default null
  ,p_val_184                         in  varchar2  default null
  ,p_val_185                         in  varchar2  default null
  ,p_val_186                         in  varchar2  default null
  ,p_val_187                         in  varchar2  default null
  ,p_val_188                         in  varchar2  default null
  ,p_val_189                         in  varchar2  default null
  ,p_val_190                         in  varchar2  default null
  ,p_val_191                         in  varchar2  default null
  ,p_val_192                         in  varchar2  default null
  ,p_val_193                         in  varchar2  default null
  ,p_val_194                         in  varchar2  default null
  ,p_val_195                         in  varchar2  default null
  ,p_val_196                         in  varchar2  default null
  ,p_val_197                         in  varchar2  default null
  ,p_val_198                         in  varchar2  default null
  ,p_val_199                         in  varchar2  default null
  ,p_val_200                         in  varchar2  default null
  ,p_val_201                         in  varchar2  default null
  ,p_val_202                         in  varchar2  default null
  ,p_val_203                         in  varchar2  default null
  ,p_val_204                         in  varchar2  default null
  ,p_val_205                         in  varchar2  default null
  ,p_val_206                         in  varchar2  default null
  ,p_val_207                         in  varchar2  default null
  ,p_val_208                         in  varchar2  default null
  ,p_val_209                         in  varchar2  default null
  ,p_val_210                         in  varchar2  default null
  ,p_val_211                         in  varchar2  default null
  ,p_val_212                         in  varchar2  default null
  ,p_val_213                         in  varchar2  default null
  ,p_val_214                         in  varchar2  default null
  ,p_val_215                         in  varchar2  default null
  ,p_val_216                         in  varchar2  default null
  ,p_val_217                         in  varchar2  default null
  ,p_val_219                         in  varchar2  default null
  ,p_val_218                         in  varchar2  default null
  ,p_val_220                         in  varchar2  default null
  ,p_val_221                         in  varchar2  default null
  ,p_val_222                         in  varchar2  default null
  ,p_val_223                         in  varchar2  default null
  ,p_val_224                         in  varchar2  default null
  ,p_val_225                         in  varchar2  default null
  ,p_val_226                         in  varchar2  default null
  ,p_val_227                         in  varchar2  default null
  ,p_val_228                         in  varchar2  default null
  ,p_val_229                         in  varchar2  default null
  ,p_val_230                         in  varchar2  default null
  ,p_val_231                         in  varchar2  default null
  ,p_val_232                         in  varchar2  default null
  ,p_val_233                         in  varchar2  default null
  ,p_val_234                         in  varchar2  default null
  ,p_val_235                         in  varchar2  default null
  ,p_val_236                         in  varchar2  default null
  ,p_val_237                         in  varchar2  default null
  ,p_val_238                         in  varchar2  default null
  ,p_val_239                         in  varchar2  default null
  ,p_val_240                         in  varchar2  default null
  ,p_val_241                         in  varchar2  default null
  ,p_val_242                         in  varchar2  default null
  ,p_val_243                         in  varchar2  default null
  ,p_val_244                         in  varchar2  default null
  ,p_val_245                         in  varchar2  default null
  ,p_val_246                         in  varchar2  default null
  ,p_val_247                         in  varchar2  default null
  ,p_val_248                         in  varchar2  default null
  ,p_val_249                         in  varchar2  default null
  ,p_val_250                         in  varchar2  default null
  ,p_val_251                         in  varchar2  default null
  ,p_val_252                         in  varchar2  default null
  ,p_val_253                         in  varchar2  default null
  ,p_val_254                         in  varchar2  default null
  ,p_val_255                         in  varchar2  default null
  ,p_val_256                         in  varchar2  default null
  ,p_val_257                         in  varchar2  default null
  ,p_val_258                         in  varchar2  default null
  ,p_val_259                         in  varchar2  default null
  ,p_val_260                         in  varchar2  default null
  ,p_val_261                         in  varchar2  default null
  ,p_val_262                         in  varchar2  default null
  ,p_val_263                         in  varchar2  default null
  ,p_val_264                         in  varchar2  default null
  ,p_val_265                         in  varchar2  default null
  ,p_val_266                         in  varchar2  default null
  ,p_val_267                         in  varchar2  default null
  ,p_val_268                         in  varchar2  default null
  ,p_val_269                         in  varchar2  default null
  ,p_val_270                         in  varchar2  default null
  ,p_val_271                         in  varchar2  default null
  ,p_val_272                         in  varchar2  default null
  ,p_val_273                         in  varchar2  default null
  ,p_val_274                         in  varchar2  default null
  ,p_val_275                         in  varchar2  default null
  ,p_val_276                         in  varchar2  default null
  ,p_val_277                         in  varchar2  default null
  ,p_val_278                         in  varchar2  default null
  ,p_val_279                         in  varchar2  default null
  ,p_val_280                         in  varchar2  default null
  ,p_val_281                         in  varchar2  default null
  ,p_val_282                         in  varchar2  default null
  ,p_val_283                         in  varchar2  default null
  ,p_val_284                         in  varchar2  default null
  ,p_val_285                         in  varchar2  default null
  ,p_val_286                         in  varchar2  default null
  ,p_val_287                         in  varchar2  default null
  ,p_val_288                         in  varchar2  default null
  ,p_val_289                         in  varchar2  default null
  ,p_val_290                         in  varchar2  default null
  ,p_val_291                         in  varchar2  default null
  ,p_val_292                         in  varchar2  default null
  ,p_val_293                         in  varchar2  default null
  ,p_val_294                         in  varchar2  default null
  ,p_val_295                         in  varchar2  default null
  ,p_val_296                         in  varchar2  default null
  ,p_val_297                         in  varchar2  default null
  ,p_val_298                         in  varchar2  default null
  ,p_val_299                         in  varchar2  default null
  ,p_val_300                         in  varchar2  default null
  ,p_group_val_01                    in  varchar2  default null
  ,p_group_val_02                    in  varchar2  default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_request_id                     in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_ext_rcd_in_file_id             in  number    default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_rslt_dtl_id ben_ext_rslt_dtl.ext_rslt_dtl_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_RSLT_DTL';
  l_object_version_number ben_ext_rslt_dtl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_RSLT_DTL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_RSLT_DTL
    --
    ben_EXT_RSLT_DTL_bk1.create_EXT_RSLT_DTL_b
      (
       p_prmy_sort_val                  =>  p_prmy_sort_val
      ,p_scnd_sort_val                  =>  p_scnd_sort_val
      ,p_thrd_sort_val                  =>  p_thrd_sort_val
      ,p_trans_seq_num                  =>  p_trans_seq_num
      ,p_rcrd_seq_num                   =>  p_rcrd_seq_num
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ext_per_bg_id                  =>  p_ext_per_bg_id
      ,p_val_01                         =>  p_val_01
      ,p_val_02                         =>  p_val_02
      ,p_val_03                         =>  p_val_03
      ,p_val_04                         =>  p_val_04
      ,p_val_05                         =>  p_val_05
      ,p_val_06                         =>  p_val_06
      ,p_val_07                         =>  p_val_07
      ,p_val_08                         =>  p_val_08
      ,p_val_09                         =>  p_val_09
      ,p_val_10                         =>  p_val_10
      ,p_val_11                         =>  p_val_11
      ,p_val_12                         =>  p_val_12
      ,p_val_13                         =>  p_val_13
      ,p_val_14                         =>  p_val_14
      ,p_val_15                         =>  p_val_15
      ,p_val_16                         =>  p_val_16
      ,p_val_17                         =>  p_val_17
      ,p_val_19                         =>  p_val_19
      ,p_val_18                         =>  p_val_18
      ,p_val_20                         =>  p_val_20
      ,p_val_21                         =>  p_val_21
      ,p_val_22                         =>  p_val_22
      ,p_val_23                         =>  p_val_23
      ,p_val_24                         =>  p_val_24
      ,p_val_25                         =>  p_val_25
      ,p_val_26                         =>  p_val_26
      ,p_val_27                         =>  p_val_27
      ,p_val_28                         =>  p_val_28
      ,p_val_29                         =>  p_val_29
      ,p_val_30                         =>  p_val_30
      ,p_val_31                         =>  p_val_31
      ,p_val_32                         =>  p_val_32
      ,p_val_33                         =>  p_val_33
      ,p_val_34                         =>  p_val_34
      ,p_val_35                         =>  p_val_35
      ,p_val_36                         =>  p_val_36
      ,p_val_37                         =>  p_val_37
      ,p_val_38                         =>  p_val_38
      ,p_val_39                         =>  p_val_39
      ,p_val_40                         =>  p_val_40
      ,p_val_41                         =>  p_val_41
      ,p_val_42                         =>  p_val_42
      ,p_val_43                         =>  p_val_43
      ,p_val_44                         =>  p_val_44
      ,p_val_45                         =>  p_val_45
      ,p_val_46                         =>  p_val_46
      ,p_val_47                         =>  p_val_47
      ,p_val_48                         =>  p_val_48
      ,p_val_49                         =>  p_val_49
      ,p_val_50                         =>  p_val_50
      ,p_val_51                         =>  p_val_51
      ,p_val_52                         =>  p_val_52
      ,p_val_53                         =>  p_val_53
      ,p_val_54                         =>  p_val_54
      ,p_val_55                         =>  p_val_55
      ,p_val_56                         =>  p_val_56
      ,p_val_57                         =>  p_val_57
      ,p_val_58                         =>  p_val_58
      ,p_val_59                         =>  p_val_59
      ,p_val_60                         =>  p_val_60
      ,p_val_61                         =>  p_val_61
      ,p_val_62                         =>  p_val_62
      ,p_val_63                         =>  p_val_63
      ,p_val_64                         =>  p_val_64
      ,p_val_65                         =>  p_val_65
      ,p_val_66                         =>  p_val_66
      ,p_val_67                         =>  p_val_67
      ,p_val_68                         =>  p_val_68
      ,p_val_69                         =>  p_val_69
      ,p_val_70                         =>  p_val_70
      ,p_val_71                         =>  p_val_71
      ,p_val_72                         =>  p_val_72
      ,p_val_73                         =>  p_val_73
      ,p_val_74                         =>  p_val_74
      ,p_val_75                         =>  p_val_75
      ,p_val_76                         =>  p_val_76
      ,p_val_77                         =>  p_val_77
      ,p_val_78                         =>  p_val_78
      ,p_val_79                         =>  p_val_79
      ,p_val_80                         =>  p_val_80
      ,p_val_81                         =>  p_val_81
      ,p_val_82                         =>  p_val_82
      ,p_val_83                         =>  p_val_83
      ,p_val_84                         =>  p_val_84
      ,p_val_85                         =>  p_val_85
      ,p_val_86                         =>  p_val_86
      ,p_val_87                         =>  p_val_87
      ,p_val_88                         =>  p_val_88
      ,p_val_89                         =>  p_val_89
      ,p_val_90                         =>  p_val_90
      ,p_val_91                         =>  p_val_91
      ,p_val_92                         =>  p_val_92
      ,p_val_93                         =>  p_val_93
      ,p_val_94                         =>  p_val_94
      ,p_val_95                         =>  p_val_95
      ,p_val_96                         =>  p_val_96
      ,p_val_97                         =>  p_val_97
      ,p_val_98                         =>  p_val_98
      ,p_val_99                         =>  p_val_99
      ,p_val_100                        =>  p_val_100
      ,p_val_101                        =>  p_val_101
      ,p_val_102                         =>  p_val_102
      ,p_val_103                         =>  p_val_103
      ,p_val_104                         =>  p_val_104
      ,p_val_105                         =>  p_val_105
      ,p_val_106                         =>  p_val_106
      ,p_val_107                         =>  p_val_107
      ,p_val_108                         =>  p_val_108
      ,p_val_109                         =>  p_val_109
      ,p_val_110                         =>  p_val_110
      ,p_val_111                         =>  p_val_111
      ,p_val_112                         =>  p_val_112
      ,p_val_113                         =>  p_val_113
      ,p_val_114                         =>  p_val_114
      ,p_val_115                         =>  p_val_115
      ,p_val_116                         =>  p_val_116
      ,p_val_117                         =>  p_val_117
      ,p_val_119                         =>  p_val_119
      ,p_val_118                         =>  p_val_118
      ,p_val_120                         =>  p_val_120
      ,p_val_121                         =>  p_val_121
      ,p_val_122                         =>  p_val_122
      ,p_val_123                         =>  p_val_123
      ,p_val_124                         =>  p_val_124
      ,p_val_125                         =>  p_val_125
      ,p_val_126                         =>  p_val_126
      ,p_val_127                         =>  p_val_127
      ,p_val_128                         =>  p_val_128
      ,p_val_129                         =>  p_val_129
      ,p_val_130                         =>  p_val_130
      ,p_val_131                         =>  p_val_131
      ,p_val_132                         =>  p_val_132
      ,p_val_133                         =>  p_val_133
      ,p_val_134                         =>  p_val_134
      ,p_val_135                         =>  p_val_135
      ,p_val_136                         =>  p_val_136
      ,p_val_137                         =>  p_val_137
      ,p_val_138                         =>  p_val_138
      ,p_val_139                         =>  p_val_139
      ,p_val_140                         =>  p_val_140
      ,p_val_141                         =>  p_val_141
      ,p_val_142                         =>  p_val_142
      ,p_val_143                         =>  p_val_143
      ,p_val_144                         =>  p_val_144
      ,p_val_145                         =>  p_val_145
      ,p_val_146                         =>  p_val_146
      ,p_val_147                         =>  p_val_147
      ,p_val_148                         =>  p_val_148
      ,p_val_149                         =>  p_val_149
      ,p_val_150                         =>  p_val_150
      ,p_val_151                         =>  p_val_151
      ,p_val_152                         =>  p_val_152
      ,p_val_153                         =>  p_val_153
      ,p_val_154                         =>  p_val_154
      ,p_val_155                         =>  p_val_155
      ,p_val_156                         =>  p_val_156
      ,p_val_157                         =>  p_val_157
      ,p_val_158                         =>  p_val_158
      ,p_val_159                         =>  p_val_159
      ,p_val_160                         =>  p_val_160
      ,p_val_161                         =>  p_val_161
      ,p_val_162                         =>  p_val_162
      ,p_val_163                         =>  p_val_163
      ,p_val_164                         =>  p_val_164
      ,p_val_165                         =>  p_val_165
      ,p_val_166                         =>  p_val_166
      ,p_val_167                         =>  p_val_167
      ,p_val_168                         =>  p_val_168
      ,p_val_169                         =>  p_val_169
      ,p_val_170                         =>  p_val_170
      ,p_val_171                         =>  p_val_171
      ,p_val_172                         =>  p_val_172
      ,p_val_173                         =>  p_val_173
      ,p_val_174                         =>  p_val_174
      ,p_val_175                         =>  p_val_175
      ,p_val_176                         =>  p_val_176
      ,p_val_177                         =>  p_val_177
      ,p_val_178                         =>  p_val_178
      ,p_val_179                         =>  p_val_179
      ,p_val_180                         =>  p_val_180
      ,p_val_181                         =>  p_val_181
      ,p_val_182                         =>  p_val_182
      ,p_val_183                         =>  p_val_183
      ,p_val_184                         =>  p_val_184
      ,p_val_185                         =>  p_val_185
      ,p_val_186                         =>  p_val_186
      ,p_val_187                         =>  p_val_187
      ,p_val_188                         =>  p_val_188
      ,p_val_189                         =>  p_val_189
      ,p_val_190                         =>  p_val_190
      ,p_val_191                         =>  p_val_191
      ,p_val_192                         =>  p_val_192
      ,p_val_193                         =>  p_val_193
      ,p_val_194                         =>  p_val_194
      ,p_val_195                         =>  p_val_195
      ,p_val_196                         =>  p_val_196
      ,p_val_197                         =>  p_val_197
      ,p_val_198                         =>  p_val_198
      ,p_val_199                         =>  p_val_199
      ,p_val_200                         =>  p_val_200
      ,p_val_201                         =>  p_val_201
      ,p_val_202                         =>  p_val_202
      ,p_val_203                         =>  p_val_203
      ,p_val_204                         =>  p_val_204
      ,p_val_205                         =>  p_val_205
      ,p_val_206                         =>  p_val_206
      ,p_val_207                         =>  p_val_207
      ,p_val_208                         =>  p_val_208
      ,p_val_209                         =>  p_val_209
      ,p_val_210                         =>  p_val_210
      ,p_val_211                         =>  p_val_211
      ,p_val_212                         =>  p_val_212
      ,p_val_213                         =>  p_val_213
      ,p_val_214                         =>  p_val_214
      ,p_val_215                         =>  p_val_215
      ,p_val_216                         =>  p_val_216
      ,p_val_217                         =>  p_val_217
      ,p_val_219                         =>  p_val_219
      ,p_val_218                         =>  p_val_218
      ,p_val_220                         =>  p_val_220
      ,p_val_221                         =>  p_val_221
      ,p_val_222                         =>  p_val_222
      ,p_val_223                         =>  p_val_223
      ,p_val_224                         =>  p_val_224
      ,p_val_225                         =>  p_val_225
      ,p_val_226                         =>  p_val_226
      ,p_val_227                         =>  p_val_227
      ,p_val_228                         =>  p_val_228
      ,p_val_229                         =>  p_val_229
      ,p_val_230                         =>  p_val_230
      ,p_val_231                         =>  p_val_231
      ,p_val_232                         =>  p_val_232
      ,p_val_233                         =>  p_val_233
      ,p_val_234                         =>  p_val_234
      ,p_val_235                         =>  p_val_235
      ,p_val_236                         =>  p_val_236
      ,p_val_237                         =>  p_val_237
      ,p_val_238                         =>  p_val_238
      ,p_val_239                         =>  p_val_239
      ,p_val_240                         =>  p_val_240
      ,p_val_241                         =>  p_val_241
      ,p_val_242                         =>  p_val_242
      ,p_val_243                         =>  p_val_243
      ,p_val_244                         =>  p_val_244
      ,p_val_245                         =>  p_val_245
      ,p_val_246                         =>  p_val_246
      ,p_val_247                         =>  p_val_247
      ,p_val_248                         =>  p_val_248
      ,p_val_249                         =>  p_val_249
      ,p_val_250                         =>  p_val_250
      ,p_val_251                         =>  p_val_251
      ,p_val_252                         =>  p_val_252
      ,p_val_253                         =>  p_val_253
      ,p_val_254                         =>  p_val_254
      ,p_val_255                         =>  p_val_255
      ,p_val_256                         =>  p_val_256
      ,p_val_257                         =>  p_val_257
      ,p_val_258                         =>  p_val_258
      ,p_val_259                         =>  p_val_259
      ,p_val_260                         =>  p_val_260
      ,p_val_261                         =>  p_val_261
      ,p_val_262                         =>  p_val_262
      ,p_val_263                         =>  p_val_263
      ,p_val_264                         =>  p_val_264
      ,p_val_265                         =>  p_val_265
      ,p_val_266                         =>  p_val_266
      ,p_val_267                         =>  p_val_267
      ,p_val_268                         =>  p_val_268
      ,p_val_269                         =>  p_val_269
      ,p_val_270                         =>  p_val_270
      ,p_val_271                         =>  p_val_271
      ,p_val_272                         =>  p_val_272
      ,p_val_273                         =>  p_val_273
      ,p_val_274                         =>  p_val_274
      ,p_val_275                         =>  p_val_275
      ,p_val_276                         =>  p_val_276
      ,p_val_277                         =>  p_val_277
      ,p_val_278                         =>  p_val_278
      ,p_val_279                         =>  p_val_279
      ,p_val_280                         =>  p_val_280
      ,p_val_281                         =>  p_val_281
      ,p_val_282                         =>  p_val_282
      ,p_val_283                         =>  p_val_283
      ,p_val_284                         =>  p_val_284
      ,p_val_285                         =>  p_val_285
      ,p_val_286                         =>  p_val_286
      ,p_val_287                         =>  p_val_287
      ,p_val_288                         =>  p_val_288
      ,p_val_289                         =>  p_val_289
      ,p_val_290                         =>  p_val_290
      ,p_val_291                         =>  p_val_291
      ,p_val_292                         =>  p_val_292
      ,p_val_293                         =>  p_val_293
      ,p_val_294                         =>  p_val_294
      ,p_val_295                         =>  p_val_295
      ,p_val_296                         =>  p_val_296
      ,p_val_297                         =>  p_val_297
      ,p_val_298                         =>  p_val_298
      ,p_val_299                         =>  p_val_299
      ,p_val_300                         =>  p_val_300
      ,p_group_val_01                    =>  p_group_val_01
      ,p_group_val_02                    =>  p_group_val_02
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_RSLT_DTL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_RSLT_DTL
    --
  end;
  --
  ben_xrd_ins.ins
    (
     p_ext_rslt_dtl_id               => l_ext_rslt_dtl_id
    ,p_prmy_sort_val                 => p_prmy_sort_val
    ,p_scnd_sort_val                 => p_scnd_sort_val
    ,p_thrd_sort_val                 => p_thrd_sort_val
    ,p_trans_seq_num                 => p_trans_seq_num
    ,p_rcrd_seq_num                  => p_rcrd_seq_num
    ,p_ext_rslt_id                   => p_ext_rslt_id
    ,p_ext_rcd_id                    => p_ext_rcd_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_ext_per_bg_id                 => p_ext_per_bg_id
    ,p_val_01                        => p_val_01
    ,p_val_02                        => p_val_02
    ,p_val_03                        => p_val_03
    ,p_val_04                        => p_val_04
    ,p_val_05                        => p_val_05
    ,p_val_06                        => p_val_06
    ,p_val_07                        => p_val_07
    ,p_val_08                        => p_val_08
    ,p_val_09                        => p_val_09
    ,p_val_10                        => p_val_10
    ,p_val_11                        => p_val_11
    ,p_val_12                        => p_val_12
    ,p_val_13                        => p_val_13
    ,p_val_14                        => p_val_14
    ,p_val_15                        => p_val_15
    ,p_val_16                        => p_val_16
    ,p_val_17                        => p_val_17
    ,p_val_19                        => p_val_19
    ,p_val_18                        => p_val_18
    ,p_val_20                        => p_val_20
    ,p_val_21                        => p_val_21
    ,p_val_22                        => p_val_22
    ,p_val_23                        => p_val_23
    ,p_val_24                        => p_val_24
    ,p_val_25                        => p_val_25
    ,p_val_26                        => p_val_26
    ,p_val_27                        => p_val_27
    ,p_val_28                        => p_val_28
    ,p_val_29                        => p_val_29
    ,p_val_30                        => p_val_30
    ,p_val_31                        => p_val_31
    ,p_val_32                        => p_val_32
    ,p_val_33                        => p_val_33
    ,p_val_34                        => p_val_34
    ,p_val_35                        => p_val_35
    ,p_val_36                        => p_val_36
    ,p_val_37                        => p_val_37
    ,p_val_38                        => p_val_38
    ,p_val_39                        => p_val_39
    ,p_val_40                        => p_val_40
    ,p_val_41                        => p_val_41
    ,p_val_42                        => p_val_42
    ,p_val_43                        => p_val_43
    ,p_val_44                        => p_val_44
    ,p_val_45                        => p_val_45
    ,p_val_46                        => p_val_46
    ,p_val_47                        => p_val_47
    ,p_val_48                        => p_val_48
    ,p_val_49                        => p_val_49
    ,p_val_50                        => p_val_50
    ,p_val_51                        => p_val_51
    ,p_val_52                        => p_val_52
    ,p_val_53                        => p_val_53
    ,p_val_54                        => p_val_54
    ,p_val_55                        => p_val_55
    ,p_val_56                        => p_val_56
    ,p_val_57                        => p_val_57
    ,p_val_58                        => p_val_58
    ,p_val_59                        => p_val_59
    ,p_val_60                        => p_val_60
    ,p_val_61                        => p_val_61
    ,p_val_62                        => p_val_62
    ,p_val_63                        => p_val_63
    ,p_val_64                        => p_val_64
    ,p_val_65                        => p_val_65
    ,p_val_66                        => p_val_66
    ,p_val_67                        => p_val_67
    ,p_val_68                        => p_val_68
    ,p_val_69                        => p_val_69
    ,p_val_70                        => p_val_70
    ,p_val_71                        => p_val_71
    ,p_val_72                        => p_val_72
    ,p_val_73                        => p_val_73
    ,p_val_74                        => p_val_74
    ,p_val_75                        => p_val_75
    ,p_val_76                         =>  p_val_76
    ,p_val_77                         =>  p_val_77
    ,p_val_78                         =>  p_val_78
    ,p_val_79                         =>  p_val_79
    ,p_val_80                         =>  p_val_80
    ,p_val_81                         =>  p_val_81
    ,p_val_82                         =>  p_val_82
    ,p_val_83                         =>  p_val_83
    ,p_val_84                         =>  p_val_84
    ,p_val_85                         =>  p_val_85
    ,p_val_86                         =>  p_val_86
    ,p_val_87                         =>  p_val_87
    ,p_val_88                         =>  p_val_88
    ,p_val_89                         =>  p_val_89
    ,p_val_90                         =>  p_val_90
    ,p_val_91                         =>  p_val_91
    ,p_val_92                         =>  p_val_92
    ,p_val_93                         =>  p_val_93
    ,p_val_94                         =>  p_val_94
    ,p_val_95                         =>  p_val_95
    ,p_val_96                         =>  p_val_96
    ,p_val_97                         =>  p_val_97
    ,p_val_98                         =>  p_val_98
    ,p_val_99                         =>  p_val_99
    ,p_val_100                        =>  p_val_100
    ,p_val_101                        =>  p_val_101
    ,p_val_102                         =>  p_val_102
    ,p_val_103                         =>  p_val_103
    ,p_val_104                         =>  p_val_104
    ,p_val_105                         =>  p_val_105
    ,p_val_106                         =>  p_val_106
    ,p_val_107                         =>  p_val_107
    ,p_val_108                         =>  p_val_108
    ,p_val_109                         =>  p_val_109
    ,p_val_110                         =>  p_val_110
    ,p_val_111                         =>  p_val_111
    ,p_val_112                         =>  p_val_112
    ,p_val_113                         =>  p_val_113
    ,p_val_114                         =>  p_val_114
    ,p_val_115                         =>  p_val_115
    ,p_val_116                         =>  p_val_116
    ,p_val_117                         =>  p_val_117
    ,p_val_119                         =>  p_val_119
    ,p_val_118                         =>  p_val_118
    ,p_val_120                         =>  p_val_120
    ,p_val_121                         =>  p_val_121
    ,p_val_122                         =>  p_val_122
    ,p_val_123                         =>  p_val_123
    ,p_val_124                         =>  p_val_124
    ,p_val_125                         =>  p_val_125
    ,p_val_126                         =>  p_val_126
    ,p_val_127                         =>  p_val_127
    ,p_val_128                         =>  p_val_128
    ,p_val_129                         =>  p_val_129
    ,p_val_130                         =>  p_val_130
    ,p_val_131                         =>  p_val_131
    ,p_val_132                         =>  p_val_132
    ,p_val_133                         =>  p_val_133
    ,p_val_134                         =>  p_val_134
    ,p_val_135                         =>  p_val_135
    ,p_val_136                         =>  p_val_136
    ,p_val_137                         =>  p_val_137
    ,p_val_138                         =>  p_val_138
    ,p_val_139                         =>  p_val_139
    ,p_val_140                         =>  p_val_140
    ,p_val_141                         =>  p_val_141
    ,p_val_142                         =>  p_val_142
    ,p_val_143                         =>  p_val_143
    ,p_val_144                         =>  p_val_144
    ,p_val_145                         =>  p_val_145
    ,p_val_146                         =>  p_val_146
    ,p_val_147                         =>  p_val_147
    ,p_val_148                         =>  p_val_148
    ,p_val_149                         =>  p_val_149
    ,p_val_150                         =>  p_val_150
    ,p_val_151                         =>  p_val_151
    ,p_val_152                         =>  p_val_152
    ,p_val_153                         =>  p_val_153
    ,p_val_154                         =>  p_val_154
    ,p_val_155                         =>  p_val_155
    ,p_val_156                         =>  p_val_156
    ,p_val_157                         =>  p_val_157
    ,p_val_158                         =>  p_val_158
    ,p_val_159                         =>  p_val_159
    ,p_val_160                         =>  p_val_160
    ,p_val_161                         =>  p_val_161
    ,p_val_162                         =>  p_val_162
    ,p_val_163                         =>  p_val_163
    ,p_val_164                         =>  p_val_164
    ,p_val_165                         =>  p_val_165
    ,p_val_166                         =>  p_val_166
    ,p_val_167                         =>  p_val_167
    ,p_val_168                         =>  p_val_168
    ,p_val_169                         =>  p_val_169
    ,p_val_170                         =>  p_val_170
    ,p_val_171                         =>  p_val_171
    ,p_val_172                         =>  p_val_172
    ,p_val_173                         =>  p_val_173
    ,p_val_174                         =>  p_val_174
    ,p_val_175                         =>  p_val_175
    ,p_val_176                         =>  p_val_176
    ,p_val_177                         =>  p_val_177
    ,p_val_178                         =>  p_val_178
    ,p_val_179                         =>  p_val_179
    ,p_val_180                         =>  p_val_180
    ,p_val_181                         =>  p_val_181
    ,p_val_182                         =>  p_val_182
    ,p_val_183                         =>  p_val_183
    ,p_val_184                         =>  p_val_184
    ,p_val_185                         =>  p_val_185
    ,p_val_186                         =>  p_val_186
    ,p_val_187                         =>  p_val_187
    ,p_val_188                         =>  p_val_188
    ,p_val_189                         =>  p_val_189
    ,p_val_190                         =>  p_val_190
    ,p_val_191                         =>  p_val_191
    ,p_val_192                         =>  p_val_192
    ,p_val_193                         =>  p_val_193
    ,p_val_194                         =>  p_val_194
    ,p_val_195                         =>  p_val_195
    ,p_val_196                         =>  p_val_196
    ,p_val_197                         =>  p_val_197
    ,p_val_198                         =>  p_val_198
    ,p_val_199                         =>  p_val_199
    ,p_val_200                         =>  p_val_200
    ,p_val_201                         =>  p_val_201
    ,p_val_202                         =>  p_val_202
    ,p_val_203                         =>  p_val_203
    ,p_val_204                         =>  p_val_204
    ,p_val_205                         =>  p_val_205
    ,p_val_206                         =>  p_val_206
    ,p_val_207                         =>  p_val_207
    ,p_val_208                         =>  p_val_208
    ,p_val_209                         =>  p_val_209
    ,p_val_210                         =>  p_val_210
    ,p_val_211                         =>  p_val_211
    ,p_val_212                         =>  p_val_212
    ,p_val_213                         =>  p_val_213
    ,p_val_214                         =>  p_val_214
    ,p_val_215                         =>  p_val_215
    ,p_val_216                         =>  p_val_216
    ,p_val_217                         =>  p_val_217
    ,p_val_219                         =>  p_val_219
    ,p_val_218                         =>  p_val_218
    ,p_val_220                         =>  p_val_220
    ,p_val_221                         =>  p_val_221
    ,p_val_222                         =>  p_val_222
    ,p_val_223                         =>  p_val_223
    ,p_val_224                         =>  p_val_224
    ,p_val_225                         =>  p_val_225
    ,p_val_226                         =>  p_val_226
    ,p_val_227                         =>  p_val_227
    ,p_val_228                         =>  p_val_228
    ,p_val_229                         =>  p_val_229
    ,p_val_230                         =>  p_val_230
    ,p_val_231                         =>  p_val_231
    ,p_val_232                         =>  p_val_232
    ,p_val_233                         =>  p_val_233
    ,p_val_234                         =>  p_val_234
    ,p_val_235                         =>  p_val_235
    ,p_val_236                         =>  p_val_236
    ,p_val_237                         =>  p_val_237
    ,p_val_238                         =>  p_val_238
    ,p_val_239                         =>  p_val_239
    ,p_val_240                         =>  p_val_240
    ,p_val_241                         =>  p_val_241
    ,p_val_242                         =>  p_val_242
    ,p_val_243                         =>  p_val_243
    ,p_val_244                         =>  p_val_244
    ,p_val_245                         =>  p_val_245
    ,p_val_246                         =>  p_val_246
    ,p_val_247                         =>  p_val_247
    ,p_val_248                         =>  p_val_248
    ,p_val_249                         =>  p_val_249
    ,p_val_250                         =>  p_val_250
    ,p_val_251                         =>  p_val_251
    ,p_val_252                         =>  p_val_252
    ,p_val_253                         =>  p_val_253
    ,p_val_254                         =>  p_val_254
    ,p_val_255                         =>  p_val_255
    ,p_val_256                         =>  p_val_256
    ,p_val_257                         =>  p_val_257
    ,p_val_258                         =>  p_val_258
    ,p_val_259                         =>  p_val_259
    ,p_val_260                         =>  p_val_260
    ,p_val_261                         =>  p_val_261
    ,p_val_262                         =>  p_val_262
    ,p_val_263                         =>  p_val_263
    ,p_val_264                         =>  p_val_264
    ,p_val_265                         =>  p_val_265
    ,p_val_266                         =>  p_val_266
    ,p_val_267                         =>  p_val_267
    ,p_val_268                         =>  p_val_268
    ,p_val_269                         =>  p_val_269
    ,p_val_270                         =>  p_val_270
    ,p_val_271                         =>  p_val_271
    ,p_val_272                         =>  p_val_272
    ,p_val_273                         =>  p_val_273
    ,p_val_274                         =>  p_val_274
    ,p_val_275                         =>  p_val_275
    ,p_val_276                         =>  p_val_276
    ,p_val_277                         =>  p_val_277
    ,p_val_278                         =>  p_val_278
    ,p_val_279                         =>  p_val_279
    ,p_val_280                         =>  p_val_280
    ,p_val_281                         =>  p_val_281
    ,p_val_282                         =>  p_val_282
    ,p_val_283                         =>  p_val_283
    ,p_val_284                         =>  p_val_284
    ,p_val_285                         =>  p_val_285
    ,p_val_286                         =>  p_val_286
    ,p_val_287                         =>  p_val_287
    ,p_val_288                         =>  p_val_288
    ,p_val_289                         =>  p_val_289
    ,p_val_290                         =>  p_val_290
    ,p_val_291                         =>  p_val_291
    ,p_val_292                         =>  p_val_292
    ,p_val_293                         =>  p_val_293
    ,p_val_294                         =>  p_val_294
    ,p_val_295                         =>  p_val_295
    ,p_val_296                         =>  p_val_296
    ,p_val_297                         =>  p_val_297
    ,p_val_298                         =>  p_val_298
    ,p_val_299                         =>  p_val_299
    ,p_val_300                         =>  p_val_300
    ,p_group_val_01                    =>  p_group_val_01
    ,p_group_val_02                    =>  p_group_val_02
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_request_id                    => p_request_id
    ,p_object_version_number         => l_object_version_number
    ,p_ext_rcd_in_file_id            => p_ext_rcd_in_file_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_RSLT_DTL
    --
    ben_EXT_RSLT_DTL_bk1.create_EXT_RSLT_DTL_a
      (
       p_ext_rslt_dtl_id                =>  l_ext_rslt_dtl_id
      ,p_prmy_sort_val                  =>  p_prmy_sort_val
      ,p_scnd_sort_val                  =>  p_scnd_sort_val
      ,p_thrd_sort_val                  =>  p_thrd_sort_val
      ,p_trans_seq_num                  =>  p_trans_seq_num
      ,p_rcrd_seq_num                   =>  p_rcrd_seq_num
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ext_per_bg_id                  =>  p_ext_per_bg_id
      ,p_val_01                         =>  p_val_01
      ,p_val_02                         =>  p_val_02
      ,p_val_03                         =>  p_val_03
      ,p_val_04                         =>  p_val_04
      ,p_val_05                         =>  p_val_05
      ,p_val_06                         =>  p_val_06
      ,p_val_07                         =>  p_val_07
      ,p_val_08                         =>  p_val_08
      ,p_val_09                         =>  p_val_09
      ,p_val_10                         =>  p_val_10
      ,p_val_11                         =>  p_val_11
      ,p_val_12                         =>  p_val_12
      ,p_val_13                         =>  p_val_13
      ,p_val_14                         =>  p_val_14
      ,p_val_15                         =>  p_val_15
      ,p_val_16                         =>  p_val_16
      ,p_val_17                         =>  p_val_17
      ,p_val_19                         =>  p_val_19
      ,p_val_18                         =>  p_val_18
      ,p_val_20                         =>  p_val_20
      ,p_val_21                         =>  p_val_21
      ,p_val_22                         =>  p_val_22
      ,p_val_23                         =>  p_val_23
      ,p_val_24                         =>  p_val_24
      ,p_val_25                         =>  p_val_25
      ,p_val_26                         =>  p_val_26
      ,p_val_27                         =>  p_val_27
      ,p_val_28                         =>  p_val_28
      ,p_val_29                         =>  p_val_29
      ,p_val_30                         =>  p_val_30
      ,p_val_31                         =>  p_val_31
      ,p_val_32                         =>  p_val_32
      ,p_val_33                         =>  p_val_33
      ,p_val_34                         =>  p_val_34
      ,p_val_35                         =>  p_val_35
      ,p_val_36                         =>  p_val_36
      ,p_val_37                         =>  p_val_37
      ,p_val_38                         =>  p_val_38
      ,p_val_39                         =>  p_val_39
      ,p_val_40                         =>  p_val_40
      ,p_val_41                         =>  p_val_41
      ,p_val_42                         =>  p_val_42
      ,p_val_43                         =>  p_val_43
      ,p_val_44                         =>  p_val_44
      ,p_val_45                         =>  p_val_45
      ,p_val_46                         =>  p_val_46
      ,p_val_47                         =>  p_val_47
      ,p_val_48                         =>  p_val_48
      ,p_val_49                         =>  p_val_49
      ,p_val_50                         =>  p_val_50
      ,p_val_51                         =>  p_val_51
      ,p_val_52                         =>  p_val_52
      ,p_val_53                         =>  p_val_53
      ,p_val_54                         =>  p_val_54
      ,p_val_55                         =>  p_val_55
      ,p_val_56                         =>  p_val_56
      ,p_val_57                         =>  p_val_57
      ,p_val_58                         =>  p_val_58
      ,p_val_59                         =>  p_val_59
      ,p_val_60                         =>  p_val_60
      ,p_val_61                         =>  p_val_61
      ,p_val_62                         =>  p_val_62
      ,p_val_63                         =>  p_val_63
      ,p_val_64                         =>  p_val_64
      ,p_val_65                         =>  p_val_65
      ,p_val_66                         =>  p_val_66
      ,p_val_67                         =>  p_val_67
      ,p_val_68                         =>  p_val_68
      ,p_val_69                         =>  p_val_69
      ,p_val_70                         =>  p_val_70
      ,p_val_71                         =>  p_val_71
      ,p_val_72                         =>  p_val_72
      ,p_val_73                         =>  p_val_73
      ,p_val_74                         =>  p_val_74
      ,p_val_75                         =>  p_val_75
      ,p_val_76                         =>  p_val_76
      ,p_val_77                         =>  p_val_77
      ,p_val_78                         =>  p_val_78
      ,p_val_79                         =>  p_val_79
      ,p_val_80                         =>  p_val_80
      ,p_val_81                         =>  p_val_81
      ,p_val_82                         =>  p_val_82
      ,p_val_83                         =>  p_val_83
      ,p_val_84                         =>  p_val_84
      ,p_val_85                         =>  p_val_85
      ,p_val_86                         =>  p_val_86
      ,p_val_87                         =>  p_val_87
      ,p_val_88                         =>  p_val_88
      ,p_val_89                         =>  p_val_89
      ,p_val_90                         =>  p_val_90
      ,p_val_91                         =>  p_val_91
      ,p_val_92                         =>  p_val_92
      ,p_val_93                         =>  p_val_93
      ,p_val_94                         =>  p_val_94
      ,p_val_95                         =>  p_val_95
      ,p_val_96                         =>  p_val_96
      ,p_val_97                         =>  p_val_97
      ,p_val_98                         =>  p_val_98
      ,p_val_99                         =>  p_val_99
      ,p_val_100                        =>  p_val_100
      ,p_val_101                        =>  p_val_101
      ,p_val_102                         =>  p_val_102
      ,p_val_103                         =>  p_val_103
      ,p_val_104                         =>  p_val_104
      ,p_val_105                         =>  p_val_105
      ,p_val_106                         =>  p_val_106
      ,p_val_107                         =>  p_val_107
      ,p_val_108                         =>  p_val_108
      ,p_val_109                         =>  p_val_109
      ,p_val_110                         =>  p_val_110
      ,p_val_111                         =>  p_val_111
      ,p_val_112                         =>  p_val_112
      ,p_val_113                         =>  p_val_113
      ,p_val_114                         =>  p_val_114
      ,p_val_115                         =>  p_val_115
      ,p_val_116                         =>  p_val_116
      ,p_val_117                         =>  p_val_117
      ,p_val_119                         =>  p_val_119
      ,p_val_118                         =>  p_val_118
      ,p_val_120                         =>  p_val_120
      ,p_val_121                         =>  p_val_121
      ,p_val_122                         =>  p_val_122
      ,p_val_123                         =>  p_val_123
      ,p_val_124                         =>  p_val_124
      ,p_val_125                         =>  p_val_125
      ,p_val_126                         =>  p_val_126
      ,p_val_127                         =>  p_val_127
      ,p_val_128                         =>  p_val_128
      ,p_val_129                         =>  p_val_129
      ,p_val_130                         =>  p_val_130
      ,p_val_131                         =>  p_val_131
      ,p_val_132                         =>  p_val_132
      ,p_val_133                         =>  p_val_133
      ,p_val_134                         =>  p_val_134
      ,p_val_135                         =>  p_val_135
      ,p_val_136                         =>  p_val_136
      ,p_val_137                         =>  p_val_137
      ,p_val_138                         =>  p_val_138
      ,p_val_139                         =>  p_val_139
      ,p_val_140                         =>  p_val_140
      ,p_val_141                         =>  p_val_141
      ,p_val_142                         =>  p_val_142
      ,p_val_143                         =>  p_val_143
      ,p_val_144                         =>  p_val_144
      ,p_val_145                         =>  p_val_145
      ,p_val_146                         =>  p_val_146
      ,p_val_147                         =>  p_val_147
      ,p_val_148                         =>  p_val_148
      ,p_val_149                         =>  p_val_149
      ,p_val_150                         =>  p_val_150
      ,p_val_151                         =>  p_val_151
      ,p_val_152                         =>  p_val_152
      ,p_val_153                         =>  p_val_153
      ,p_val_154                         =>  p_val_154
      ,p_val_155                         =>  p_val_155
      ,p_val_156                         =>  p_val_156
      ,p_val_157                         =>  p_val_157
      ,p_val_158                         =>  p_val_158
      ,p_val_159                         =>  p_val_159
      ,p_val_160                         =>  p_val_160
      ,p_val_161                         =>  p_val_161
      ,p_val_162                         =>  p_val_162
      ,p_val_163                         =>  p_val_163
      ,p_val_164                         =>  p_val_164
      ,p_val_165                         =>  p_val_165
      ,p_val_166                         =>  p_val_166
      ,p_val_167                         =>  p_val_167
      ,p_val_168                         =>  p_val_168
      ,p_val_169                         =>  p_val_169
      ,p_val_170                         =>  p_val_170
      ,p_val_171                         =>  p_val_171
      ,p_val_172                         =>  p_val_172
      ,p_val_173                         =>  p_val_173
      ,p_val_174                         =>  p_val_174
      ,p_val_175                         =>  p_val_175
      ,p_val_176                         =>  p_val_176
      ,p_val_177                         =>  p_val_177
      ,p_val_178                         =>  p_val_178
      ,p_val_179                         =>  p_val_179
      ,p_val_180                         =>  p_val_180
      ,p_val_181                         =>  p_val_181
      ,p_val_182                         =>  p_val_182
      ,p_val_183                         =>  p_val_183
      ,p_val_184                         =>  p_val_184
      ,p_val_185                         =>  p_val_185
      ,p_val_186                         =>  p_val_186
      ,p_val_187                         =>  p_val_187
      ,p_val_188                         =>  p_val_188
      ,p_val_189                         =>  p_val_189
      ,p_val_190                         =>  p_val_190
      ,p_val_191                         =>  p_val_191
      ,p_val_192                         =>  p_val_192
      ,p_val_193                         =>  p_val_193
      ,p_val_194                         =>  p_val_194
      ,p_val_195                         =>  p_val_195
      ,p_val_196                         =>  p_val_196
      ,p_val_197                         =>  p_val_197
      ,p_val_198                         =>  p_val_198
      ,p_val_199                         =>  p_val_199
      ,p_val_200                         =>  p_val_200
      ,p_val_201                         =>  p_val_201
      ,p_val_202                         =>  p_val_202
      ,p_val_203                         =>  p_val_203
      ,p_val_204                         =>  p_val_204
      ,p_val_205                         =>  p_val_205
      ,p_val_206                         =>  p_val_206
      ,p_val_207                         =>  p_val_207
      ,p_val_208                         =>  p_val_208
      ,p_val_209                         =>  p_val_209
      ,p_val_210                         =>  p_val_210
      ,p_val_211                         =>  p_val_211
      ,p_val_212                         =>  p_val_212
      ,p_val_213                         =>  p_val_213
      ,p_val_214                         =>  p_val_214
      ,p_val_215                         =>  p_val_215
      ,p_val_216                         =>  p_val_216
      ,p_val_217                         =>  p_val_217
      ,p_val_219                         =>  p_val_219
      ,p_val_218                         =>  p_val_218
      ,p_val_220                         =>  p_val_220
      ,p_val_221                         =>  p_val_221
      ,p_val_222                         =>  p_val_222
      ,p_val_223                         =>  p_val_223
      ,p_val_224                         =>  p_val_224
      ,p_val_225                         =>  p_val_225
      ,p_val_226                         =>  p_val_226
      ,p_val_227                         =>  p_val_227
      ,p_val_228                         =>  p_val_228
      ,p_val_229                         =>  p_val_229
      ,p_val_230                         =>  p_val_230
      ,p_val_231                         =>  p_val_231
      ,p_val_232                         =>  p_val_232
      ,p_val_233                         =>  p_val_233
      ,p_val_234                         =>  p_val_234
      ,p_val_235                         =>  p_val_235
      ,p_val_236                         =>  p_val_236
      ,p_val_237                         =>  p_val_237
      ,p_val_238                         =>  p_val_238
      ,p_val_239                         =>  p_val_239
      ,p_val_240                         =>  p_val_240
      ,p_val_241                         =>  p_val_241
      ,p_val_242                         =>  p_val_242
      ,p_val_243                         =>  p_val_243
      ,p_val_244                         =>  p_val_244
      ,p_val_245                         =>  p_val_245
      ,p_val_246                         =>  p_val_246
      ,p_val_247                         =>  p_val_247
      ,p_val_248                         =>  p_val_248
      ,p_val_249                         =>  p_val_249
      ,p_val_250                         =>  p_val_250
      ,p_val_251                         =>  p_val_251
      ,p_val_252                         =>  p_val_252
      ,p_val_253                         =>  p_val_253
      ,p_val_254                         =>  p_val_254
      ,p_val_255                         =>  p_val_255
      ,p_val_256                         =>  p_val_256
      ,p_val_257                         =>  p_val_257
      ,p_val_258                         =>  p_val_258
      ,p_val_259                         =>  p_val_259
      ,p_val_260                         =>  p_val_260
      ,p_val_261                         =>  p_val_261
      ,p_val_262                         =>  p_val_262
      ,p_val_263                         =>  p_val_263
      ,p_val_264                         =>  p_val_264
      ,p_val_265                         =>  p_val_265
      ,p_val_266                         =>  p_val_266
      ,p_val_267                         =>  p_val_267
      ,p_val_268                         =>  p_val_268
      ,p_val_269                         =>  p_val_269
      ,p_val_270                         =>  p_val_270
      ,p_val_271                         =>  p_val_271
      ,p_val_272                         =>  p_val_272
      ,p_val_273                         =>  p_val_273
      ,p_val_274                         =>  p_val_274
      ,p_val_275                         =>  p_val_275
      ,p_val_276                         =>  p_val_276
      ,p_val_277                         =>  p_val_277
      ,p_val_278                         =>  p_val_278
      ,p_val_279                         =>  p_val_279
      ,p_val_280                         =>  p_val_280
      ,p_val_281                         =>  p_val_281
      ,p_val_282                         =>  p_val_282
      ,p_val_283                         =>  p_val_283
      ,p_val_284                         =>  p_val_284
      ,p_val_285                         =>  p_val_285
      ,p_val_286                         =>  p_val_286
      ,p_val_287                         =>  p_val_287
      ,p_val_288                         =>  p_val_288
      ,p_val_289                         =>  p_val_289
      ,p_val_290                         =>  p_val_290
      ,p_val_291                         =>  p_val_291
      ,p_val_292                         =>  p_val_292
      ,p_val_293                         =>  p_val_293
      ,p_val_294                         =>  p_val_294
      ,p_val_295                         =>  p_val_295
      ,p_val_296                         =>  p_val_296
      ,p_val_297                         =>  p_val_297
      ,p_val_298                         =>  p_val_298
      ,p_val_299                         =>  p_val_299
      ,p_val_300                         =>  p_val_300
      ,p_group_val_01                    =>  p_group_val_01
      ,p_group_val_02                    =>  p_group_val_02
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_RSLT_DTL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_RSLT_DTL
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_ext_rslt_dtl_id := l_ext_rslt_dtl_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_EXT_RSLT_DTL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_rslt_dtl_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_RSLT_DTL;
    p_ext_rslt_dtl_id := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_EXT_RSLT_DTL;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RSLT_DTL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_RSLT_DTL
  (p_validate                       in  boolean   default false
  ,p_ext_rslt_dtl_id                in  number
  ,p_prmy_sort_val                  in  varchar2  default hr_api.g_varchar2
  ,p_scnd_sort_val                  in  varchar2  default hr_api.g_varchar2
  ,p_thrd_sort_val                  in  varchar2  default hr_api.g_varchar2
  ,p_trans_seq_num                  in  number    default hr_api.g_number
  ,p_rcrd_seq_num                   in  number    default hr_api.g_number
  ,p_ext_rslt_id                    in  number    default hr_api.g_number
  ,p_ext_rcd_id                     in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ext_per_bg_id                  in  number    default hr_api.g_number
  ,p_val_01                         in  varchar2  default hr_api.g_varchar2
  ,p_val_02                         in  varchar2  default hr_api.g_varchar2
  ,p_val_03                         in  varchar2  default hr_api.g_varchar2
  ,p_val_04                         in  varchar2  default hr_api.g_varchar2
  ,p_val_05                         in  varchar2  default hr_api.g_varchar2
  ,p_val_06                         in  varchar2  default hr_api.g_varchar2
  ,p_val_07                         in  varchar2  default hr_api.g_varchar2
  ,p_val_08                         in  varchar2  default hr_api.g_varchar2
  ,p_val_09                         in  varchar2  default hr_api.g_varchar2
  ,p_val_10                         in  varchar2  default hr_api.g_varchar2
  ,p_val_11                         in  varchar2  default hr_api.g_varchar2
  ,p_val_12                         in  varchar2  default hr_api.g_varchar2
  ,p_val_13                         in  varchar2  default hr_api.g_varchar2
  ,p_val_14                         in  varchar2  default hr_api.g_varchar2
  ,p_val_15                         in  varchar2  default hr_api.g_varchar2
  ,p_val_16                         in  varchar2  default hr_api.g_varchar2
  ,p_val_17                         in  varchar2  default hr_api.g_varchar2
  ,p_val_19                         in  varchar2  default hr_api.g_varchar2
  ,p_val_18                         in  varchar2  default hr_api.g_varchar2
  ,p_val_20                         in  varchar2  default hr_api.g_varchar2
  ,p_val_21                         in  varchar2  default hr_api.g_varchar2
  ,p_val_22                         in  varchar2  default hr_api.g_varchar2
  ,p_val_23                         in  varchar2  default hr_api.g_varchar2
  ,p_val_24                         in  varchar2  default hr_api.g_varchar2
  ,p_val_25                         in  varchar2  default hr_api.g_varchar2
  ,p_val_26                         in  varchar2  default hr_api.g_varchar2
  ,p_val_27                         in  varchar2  default hr_api.g_varchar2
  ,p_val_28                         in  varchar2  default hr_api.g_varchar2
  ,p_val_29                         in  varchar2  default hr_api.g_varchar2
  ,p_val_30                         in  varchar2  default hr_api.g_varchar2
  ,p_val_31                         in  varchar2  default hr_api.g_varchar2
  ,p_val_32                         in  varchar2  default hr_api.g_varchar2
  ,p_val_33                         in  varchar2  default hr_api.g_varchar2
  ,p_val_34                         in  varchar2  default hr_api.g_varchar2
  ,p_val_35                         in  varchar2  default hr_api.g_varchar2
  ,p_val_36                         in  varchar2  default hr_api.g_varchar2
  ,p_val_37                         in  varchar2  default hr_api.g_varchar2
  ,p_val_38                         in  varchar2  default hr_api.g_varchar2
  ,p_val_39                         in  varchar2  default hr_api.g_varchar2
  ,p_val_40                         in  varchar2  default hr_api.g_varchar2
  ,p_val_41                         in  varchar2  default hr_api.g_varchar2
  ,p_val_42                         in  varchar2  default hr_api.g_varchar2
  ,p_val_43                         in  varchar2  default hr_api.g_varchar2
  ,p_val_44                         in  varchar2  default hr_api.g_varchar2
  ,p_val_45                         in  varchar2  default hr_api.g_varchar2
  ,p_val_46                         in  varchar2  default hr_api.g_varchar2
  ,p_val_47                         in  varchar2  default hr_api.g_varchar2
  ,p_val_48                         in  varchar2  default hr_api.g_varchar2
  ,p_val_49                         in  varchar2  default hr_api.g_varchar2
  ,p_val_50                         in  varchar2  default hr_api.g_varchar2
  ,p_val_51                         in  varchar2  default hr_api.g_varchar2
  ,p_val_52                         in  varchar2  default hr_api.g_varchar2
  ,p_val_53                         in  varchar2  default hr_api.g_varchar2
  ,p_val_54                         in  varchar2  default hr_api.g_varchar2
  ,p_val_55                         in  varchar2  default hr_api.g_varchar2
  ,p_val_56                         in  varchar2  default hr_api.g_varchar2
  ,p_val_57                         in  varchar2  default hr_api.g_varchar2
  ,p_val_58                         in  varchar2  default hr_api.g_varchar2
  ,p_val_59                         in  varchar2  default hr_api.g_varchar2
  ,p_val_60                         in  varchar2  default hr_api.g_varchar2
  ,p_val_61                         in  varchar2  default hr_api.g_varchar2
  ,p_val_62                         in  varchar2  default hr_api.g_varchar2
  ,p_val_63                         in  varchar2  default hr_api.g_varchar2
  ,p_val_64                         in  varchar2  default hr_api.g_varchar2
  ,p_val_65                         in  varchar2  default hr_api.g_varchar2
  ,p_val_66                         in  varchar2  default hr_api.g_varchar2
  ,p_val_67                         in  varchar2  default hr_api.g_varchar2
  ,p_val_68                         in  varchar2  default hr_api.g_varchar2
  ,p_val_69                         in  varchar2  default hr_api.g_varchar2
  ,p_val_70                         in  varchar2  default hr_api.g_varchar2
  ,p_val_71                         in  varchar2  default hr_api.g_varchar2
  ,p_val_72                         in  varchar2  default hr_api.g_varchar2
  ,p_val_73                         in  varchar2  default hr_api.g_varchar2
  ,p_val_74                         in  varchar2  default hr_api.g_varchar2
  ,p_val_75                         in  varchar2  default hr_api.g_varchar2
  ,p_val_76                         in  varchar2  default hr_api.g_varchar2
  ,p_val_77                         in  varchar2  default hr_api.g_varchar2
  ,p_val_78                         in  varchar2  default hr_api.g_varchar2
  ,p_val_79                         in  varchar2  default hr_api.g_varchar2
  ,p_val_80                         in  varchar2  default hr_api.g_varchar2
  ,p_val_81                         in  varchar2  default hr_api.g_varchar2
  ,p_val_82                         in  varchar2  default hr_api.g_varchar2
  ,p_val_83                         in  varchar2  default hr_api.g_varchar2
  ,p_val_84                         in  varchar2  default hr_api.g_varchar2
  ,p_val_85                         in  varchar2  default hr_api.g_varchar2
  ,p_val_86                         in  varchar2  default hr_api.g_varchar2
  ,p_val_87                         in  varchar2  default hr_api.g_varchar2
  ,p_val_88                         in  varchar2  default hr_api.g_varchar2
  ,p_val_89                         in  varchar2  default hr_api.g_varchar2
  ,p_val_90                         in  varchar2  default hr_api.g_varchar2
  ,p_val_91                         in  varchar2  default hr_api.g_varchar2
  ,p_val_92                         in  varchar2  default hr_api.g_varchar2
  ,p_val_93                         in  varchar2  default hr_api.g_varchar2
  ,p_val_94                         in  varchar2  default hr_api.g_varchar2
  ,p_val_95                         in  varchar2  default hr_api.g_varchar2
  ,p_val_96                         in  varchar2  default hr_api.g_varchar2
  ,p_val_97                         in  varchar2  default hr_api.g_varchar2
  ,p_val_98                         in  varchar2  default hr_api.g_varchar2
  ,p_val_99                         in  varchar2  default hr_api.g_varchar2
  ,p_val_100                        in  varchar2  default hr_api.g_varchar2
  ,p_val_101                         in  varchar2  default hr_api.g_varchar2
  ,p_val_102                         in  varchar2  default hr_api.g_varchar2
  ,p_val_103                         in  varchar2  default hr_api.g_varchar2
  ,p_val_104                         in  varchar2  default hr_api.g_varchar2
  ,p_val_105                         in  varchar2  default hr_api.g_varchar2
  ,p_val_106                         in  varchar2  default hr_api.g_varchar2
  ,p_val_107                         in  varchar2  default hr_api.g_varchar2
  ,p_val_108                         in  varchar2  default hr_api.g_varchar2
  ,p_val_109                         in  varchar2  default hr_api.g_varchar2
  ,p_val_110                         in  varchar2  default hr_api.g_varchar2
  ,p_val_111                         in  varchar2  default hr_api.g_varchar2
  ,p_val_112                         in  varchar2  default hr_api.g_varchar2
  ,p_val_113                         in  varchar2  default hr_api.g_varchar2
  ,p_val_114                         in  varchar2  default hr_api.g_varchar2
  ,p_val_115                         in  varchar2  default hr_api.g_varchar2
  ,p_val_116                         in  varchar2  default hr_api.g_varchar2
  ,p_val_117                         in  varchar2  default hr_api.g_varchar2
  ,p_val_119                         in  varchar2  default hr_api.g_varchar2
  ,p_val_118                         in  varchar2  default hr_api.g_varchar2
  ,p_val_120                         in  varchar2  default hr_api.g_varchar2
  ,p_val_121                         in  varchar2  default hr_api.g_varchar2
  ,p_val_122                         in  varchar2  default hr_api.g_varchar2
  ,p_val_123                         in  varchar2  default hr_api.g_varchar2
  ,p_val_124                         in  varchar2  default hr_api.g_varchar2
  ,p_val_125                         in  varchar2  default hr_api.g_varchar2
  ,p_val_126                         in  varchar2  default hr_api.g_varchar2
  ,p_val_127                         in  varchar2  default hr_api.g_varchar2
  ,p_val_128                         in  varchar2  default hr_api.g_varchar2
  ,p_val_129                         in  varchar2  default hr_api.g_varchar2
  ,p_val_130                         in  varchar2  default hr_api.g_varchar2
  ,p_val_131                         in  varchar2  default hr_api.g_varchar2
  ,p_val_132                         in  varchar2  default hr_api.g_varchar2
  ,p_val_133                         in  varchar2  default hr_api.g_varchar2
  ,p_val_134                         in  varchar2  default hr_api.g_varchar2
  ,p_val_135                         in  varchar2  default hr_api.g_varchar2
  ,p_val_136                         in  varchar2  default hr_api.g_varchar2
  ,p_val_137                         in  varchar2  default hr_api.g_varchar2
  ,p_val_138                         in  varchar2  default hr_api.g_varchar2
  ,p_val_139                         in  varchar2  default hr_api.g_varchar2
  ,p_val_140                         in  varchar2  default hr_api.g_varchar2
  ,p_val_141                         in  varchar2  default hr_api.g_varchar2
  ,p_val_142                         in  varchar2  default hr_api.g_varchar2
  ,p_val_143                         in  varchar2  default hr_api.g_varchar2
  ,p_val_144                         in  varchar2  default hr_api.g_varchar2
  ,p_val_145                         in  varchar2  default hr_api.g_varchar2
  ,p_val_146                         in  varchar2  default hr_api.g_varchar2
  ,p_val_147                         in  varchar2  default hr_api.g_varchar2
  ,p_val_148                         in  varchar2  default hr_api.g_varchar2
  ,p_val_149                         in  varchar2  default hr_api.g_varchar2
  ,p_val_150                         in  varchar2  default hr_api.g_varchar2
  ,p_val_151                         in  varchar2  default hr_api.g_varchar2
  ,p_val_152                         in  varchar2  default hr_api.g_varchar2
  ,p_val_153                         in  varchar2  default hr_api.g_varchar2
  ,p_val_154                         in  varchar2  default hr_api.g_varchar2
  ,p_val_155                         in  varchar2  default hr_api.g_varchar2
  ,p_val_156                         in  varchar2  default hr_api.g_varchar2
  ,p_val_157                         in  varchar2  default hr_api.g_varchar2
  ,p_val_158                         in  varchar2  default hr_api.g_varchar2
  ,p_val_159                         in  varchar2  default hr_api.g_varchar2
  ,p_val_160                         in  varchar2  default hr_api.g_varchar2
  ,p_val_161                         in  varchar2  default hr_api.g_varchar2
  ,p_val_162                         in  varchar2  default hr_api.g_varchar2
  ,p_val_163                         in  varchar2  default hr_api.g_varchar2
  ,p_val_164                         in  varchar2  default hr_api.g_varchar2
  ,p_val_165                         in  varchar2  default hr_api.g_varchar2
  ,p_val_166                         in  varchar2  default hr_api.g_varchar2
  ,p_val_167                         in  varchar2  default hr_api.g_varchar2
  ,p_val_168                         in  varchar2  default hr_api.g_varchar2
  ,p_val_169                         in  varchar2  default hr_api.g_varchar2
  ,p_val_170                         in  varchar2  default hr_api.g_varchar2
  ,p_val_171                         in  varchar2  default hr_api.g_varchar2
  ,p_val_172                         in  varchar2  default hr_api.g_varchar2
  ,p_val_173                         in  varchar2  default hr_api.g_varchar2
  ,p_val_174                         in  varchar2  default hr_api.g_varchar2
  ,p_val_175                         in  varchar2  default hr_api.g_varchar2
  ,p_val_176                         in  varchar2  default hr_api.g_varchar2
  ,p_val_177                         in  varchar2  default hr_api.g_varchar2
  ,p_val_178                         in  varchar2  default hr_api.g_varchar2
  ,p_val_179                         in  varchar2  default hr_api.g_varchar2
  ,p_val_180                         in  varchar2  default hr_api.g_varchar2
  ,p_val_181                         in  varchar2  default hr_api.g_varchar2
  ,p_val_182                         in  varchar2  default hr_api.g_varchar2
  ,p_val_183                         in  varchar2  default hr_api.g_varchar2
  ,p_val_184                         in  varchar2  default hr_api.g_varchar2
  ,p_val_185                         in  varchar2  default hr_api.g_varchar2
  ,p_val_186                         in  varchar2  default hr_api.g_varchar2
  ,p_val_187                         in  varchar2  default hr_api.g_varchar2
  ,p_val_188                         in  varchar2  default hr_api.g_varchar2
  ,p_val_189                         in  varchar2  default hr_api.g_varchar2
  ,p_val_190                         in  varchar2  default hr_api.g_varchar2
  ,p_val_191                         in  varchar2  default hr_api.g_varchar2
  ,p_val_192                         in  varchar2  default hr_api.g_varchar2
  ,p_val_193                         in  varchar2  default hr_api.g_varchar2
  ,p_val_194                         in  varchar2  default hr_api.g_varchar2
  ,p_val_195                         in  varchar2  default hr_api.g_varchar2
  ,p_val_196                         in  varchar2  default hr_api.g_varchar2
  ,p_val_197                         in  varchar2  default hr_api.g_varchar2
  ,p_val_198                         in  varchar2  default hr_api.g_varchar2
  ,p_val_199                         in  varchar2  default hr_api.g_varchar2
  ,p_val_200                         in  varchar2  default hr_api.g_varchar2
  ,p_val_201                         in  varchar2  default hr_api.g_varchar2
  ,p_val_202                         in  varchar2  default hr_api.g_varchar2
  ,p_val_203                         in  varchar2  default hr_api.g_varchar2
  ,p_val_204                         in  varchar2  default hr_api.g_varchar2
  ,p_val_205                         in  varchar2  default hr_api.g_varchar2
  ,p_val_206                         in  varchar2  default hr_api.g_varchar2
  ,p_val_207                         in  varchar2  default hr_api.g_varchar2
  ,p_val_208                         in  varchar2  default hr_api.g_varchar2
  ,p_val_209                         in  varchar2  default hr_api.g_varchar2
  ,p_val_210                         in  varchar2  default hr_api.g_varchar2
  ,p_val_211                         in  varchar2  default hr_api.g_varchar2
  ,p_val_212                         in  varchar2  default hr_api.g_varchar2
  ,p_val_213                         in  varchar2  default hr_api.g_varchar2
  ,p_val_214                         in  varchar2  default hr_api.g_varchar2
  ,p_val_215                         in  varchar2  default hr_api.g_varchar2
  ,p_val_216                         in  varchar2  default hr_api.g_varchar2
  ,p_val_217                         in  varchar2  default hr_api.g_varchar2
  ,p_val_219                         in  varchar2  default hr_api.g_varchar2
  ,p_val_218                         in  varchar2  default hr_api.g_varchar2
  ,p_val_220                         in  varchar2  default hr_api.g_varchar2
  ,p_val_221                         in  varchar2  default hr_api.g_varchar2
  ,p_val_222                         in  varchar2  default hr_api.g_varchar2
  ,p_val_223                         in  varchar2  default hr_api.g_varchar2
  ,p_val_224                         in  varchar2  default hr_api.g_varchar2
  ,p_val_225                         in  varchar2  default hr_api.g_varchar2
  ,p_val_226                         in  varchar2  default hr_api.g_varchar2
  ,p_val_227                         in  varchar2  default hr_api.g_varchar2
  ,p_val_228                         in  varchar2  default hr_api.g_varchar2
  ,p_val_229                         in  varchar2  default hr_api.g_varchar2
  ,p_val_230                         in  varchar2  default hr_api.g_varchar2
  ,p_val_231                         in  varchar2  default hr_api.g_varchar2
  ,p_val_232                         in  varchar2  default hr_api.g_varchar2
  ,p_val_233                         in  varchar2  default hr_api.g_varchar2
  ,p_val_234                         in  varchar2  default hr_api.g_varchar2
  ,p_val_235                         in  varchar2  default hr_api.g_varchar2
  ,p_val_236                         in  varchar2  default hr_api.g_varchar2
  ,p_val_237                         in  varchar2  default hr_api.g_varchar2
  ,p_val_238                         in  varchar2  default hr_api.g_varchar2
  ,p_val_239                         in  varchar2  default hr_api.g_varchar2
  ,p_val_240                         in  varchar2  default hr_api.g_varchar2
  ,p_val_241                         in  varchar2  default hr_api.g_varchar2
  ,p_val_242                         in  varchar2  default hr_api.g_varchar2
  ,p_val_243                         in  varchar2  default hr_api.g_varchar2
  ,p_val_244                         in  varchar2  default hr_api.g_varchar2
  ,p_val_245                         in  varchar2  default hr_api.g_varchar2
  ,p_val_246                         in  varchar2  default hr_api.g_varchar2
  ,p_val_247                         in  varchar2  default hr_api.g_varchar2
  ,p_val_248                         in  varchar2  default hr_api.g_varchar2
  ,p_val_249                         in  varchar2  default hr_api.g_varchar2
  ,p_val_250                         in  varchar2  default hr_api.g_varchar2
  ,p_val_251                         in  varchar2  default hr_api.g_varchar2
  ,p_val_252                         in  varchar2  default hr_api.g_varchar2
  ,p_val_253                         in  varchar2  default hr_api.g_varchar2
  ,p_val_254                         in  varchar2  default hr_api.g_varchar2
  ,p_val_255                         in  varchar2  default hr_api.g_varchar2
  ,p_val_256                         in  varchar2  default hr_api.g_varchar2
  ,p_val_257                         in  varchar2  default hr_api.g_varchar2
  ,p_val_258                         in  varchar2  default hr_api.g_varchar2
  ,p_val_259                         in  varchar2  default hr_api.g_varchar2
  ,p_val_260                         in  varchar2  default hr_api.g_varchar2
  ,p_val_261                         in  varchar2  default hr_api.g_varchar2
  ,p_val_262                         in  varchar2  default hr_api.g_varchar2
  ,p_val_263                         in  varchar2  default hr_api.g_varchar2
  ,p_val_264                         in  varchar2  default hr_api.g_varchar2
  ,p_val_265                         in  varchar2  default hr_api.g_varchar2
  ,p_val_266                         in  varchar2  default hr_api.g_varchar2
  ,p_val_267                         in  varchar2  default hr_api.g_varchar2
  ,p_val_268                         in  varchar2  default hr_api.g_varchar2
  ,p_val_269                         in  varchar2  default hr_api.g_varchar2
  ,p_val_270                         in  varchar2  default hr_api.g_varchar2
  ,p_val_271                         in  varchar2  default hr_api.g_varchar2
  ,p_val_272                         in  varchar2  default hr_api.g_varchar2
  ,p_val_273                         in  varchar2  default hr_api.g_varchar2
  ,p_val_274                         in  varchar2  default hr_api.g_varchar2
  ,p_val_275                         in  varchar2  default hr_api.g_varchar2
  ,p_val_276                         in  varchar2  default hr_api.g_varchar2
  ,p_val_277                         in  varchar2  default hr_api.g_varchar2
  ,p_val_278                         in  varchar2  default hr_api.g_varchar2
  ,p_val_279                         in  varchar2  default hr_api.g_varchar2
  ,p_val_280                         in  varchar2  default hr_api.g_varchar2
  ,p_val_281                         in  varchar2  default hr_api.g_varchar2
  ,p_val_282                         in  varchar2  default hr_api.g_varchar2
  ,p_val_283                         in  varchar2  default hr_api.g_varchar2
  ,p_val_284                         in  varchar2  default hr_api.g_varchar2
  ,p_val_285                         in  varchar2  default hr_api.g_varchar2
  ,p_val_286                         in  varchar2  default hr_api.g_varchar2
  ,p_val_287                         in  varchar2  default hr_api.g_varchar2
  ,p_val_288                         in  varchar2  default hr_api.g_varchar2
  ,p_val_289                         in  varchar2  default hr_api.g_varchar2
  ,p_val_290                         in  varchar2  default hr_api.g_varchar2
  ,p_val_291                         in  varchar2  default hr_api.g_varchar2
  ,p_val_292                         in  varchar2  default hr_api.g_varchar2
  ,p_val_293                         in  varchar2  default hr_api.g_varchar2
  ,p_val_294                         in  varchar2  default hr_api.g_varchar2
  ,p_val_295                         in  varchar2  default hr_api.g_varchar2
  ,p_val_296                         in  varchar2  default hr_api.g_varchar2
  ,p_val_297                         in  varchar2  default hr_api.g_varchar2
  ,p_val_298                         in  varchar2  default hr_api.g_varchar2
  ,p_val_299                         in  varchar2  default hr_api.g_varchar2
  ,p_val_300                         in  varchar2  default hr_api.g_varchar2
  ,p_group_val_01                    in  varchar2  default hr_api.g_varchar2
  ,p_group_val_02                    in  varchar2  default hr_api.g_varchar2
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_ext_rcd_in_file_id             in  number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RSLT_DTL';
  l_object_version_number ben_ext_rslt_dtl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_RSLT_DTL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_RSLT_DTL
    --
    ben_EXT_RSLT_DTL_bk2.update_EXT_RSLT_DTL_b
      (
       p_ext_rslt_dtl_id                =>  p_ext_rslt_dtl_id
      ,p_prmy_sort_val                  =>  p_prmy_sort_val
      ,p_scnd_sort_val                  =>  p_scnd_sort_val
      ,p_thrd_sort_val                  =>  p_thrd_sort_val
      ,p_trans_seq_num                  =>  p_trans_seq_num
      ,p_rcrd_seq_num                   =>  p_rcrd_seq_num
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ext_per_bg_id                  =>  p_ext_per_bg_id
      ,p_val_01                         =>  p_val_01
      ,p_val_02                         =>  p_val_02
      ,p_val_03                         =>  p_val_03
      ,p_val_04                         =>  p_val_04
      ,p_val_05                         =>  p_val_05
      ,p_val_06                         =>  p_val_06
      ,p_val_07                         =>  p_val_07
      ,p_val_08                         =>  p_val_08
      ,p_val_09                         =>  p_val_09
      ,p_val_10                         =>  p_val_10
      ,p_val_11                         =>  p_val_11
      ,p_val_12                         =>  p_val_12
      ,p_val_13                         =>  p_val_13
      ,p_val_14                         =>  p_val_14
      ,p_val_15                         =>  p_val_15
      ,p_val_16                         =>  p_val_16
      ,p_val_17                         =>  p_val_17
      ,p_val_19                         =>  p_val_19
      ,p_val_18                         =>  p_val_18
      ,p_val_20                         =>  p_val_20
      ,p_val_21                         =>  p_val_21
      ,p_val_22                         =>  p_val_22
      ,p_val_23                         =>  p_val_23
      ,p_val_24                         =>  p_val_24
      ,p_val_25                         =>  p_val_25
      ,p_val_26                         =>  p_val_26
      ,p_val_27                         =>  p_val_27
      ,p_val_28                         =>  p_val_28
      ,p_val_29                         =>  p_val_29
      ,p_val_30                         =>  p_val_30
      ,p_val_31                         =>  p_val_31
      ,p_val_32                         =>  p_val_32
      ,p_val_33                         =>  p_val_33
      ,p_val_34                         =>  p_val_34
      ,p_val_35                         =>  p_val_35
      ,p_val_36                         =>  p_val_36
      ,p_val_37                         =>  p_val_37
      ,p_val_38                         =>  p_val_38
      ,p_val_39                         =>  p_val_39
      ,p_val_40                         =>  p_val_40
      ,p_val_41                         =>  p_val_41
      ,p_val_42                         =>  p_val_42
      ,p_val_43                         =>  p_val_43
      ,p_val_44                         =>  p_val_44
      ,p_val_45                         =>  p_val_45
      ,p_val_46                         =>  p_val_46
      ,p_val_47                         =>  p_val_47
      ,p_val_48                         =>  p_val_48
      ,p_val_49                         =>  p_val_49
      ,p_val_50                         =>  p_val_50
      ,p_val_51                         =>  p_val_51
      ,p_val_52                         =>  p_val_52
      ,p_val_53                         =>  p_val_53
      ,p_val_54                         =>  p_val_54
      ,p_val_55                         =>  p_val_55
      ,p_val_56                         =>  p_val_56
      ,p_val_57                         =>  p_val_57
      ,p_val_58                         =>  p_val_58
      ,p_val_59                         =>  p_val_59
      ,p_val_60                         =>  p_val_60
      ,p_val_61                         =>  p_val_61
      ,p_val_62                         =>  p_val_62
      ,p_val_63                         =>  p_val_63
      ,p_val_64                         =>  p_val_64
      ,p_val_65                         =>  p_val_65
      ,p_val_66                         =>  p_val_66
      ,p_val_67                         =>  p_val_67
      ,p_val_68                         =>  p_val_68
      ,p_val_69                         =>  p_val_69
      ,p_val_70                         =>  p_val_70
      ,p_val_71                         =>  p_val_71
      ,p_val_72                         =>  p_val_72
      ,p_val_73                         =>  p_val_73
      ,p_val_74                         =>  p_val_74
      ,p_val_75                         =>  p_val_75
      ,p_val_76                         =>  p_val_76
      ,p_val_77                         =>  p_val_77
      ,p_val_78                         =>  p_val_78
      ,p_val_79                         =>  p_val_79
      ,p_val_80                         =>  p_val_80
      ,p_val_81                         =>  p_val_81
      ,p_val_82                         =>  p_val_82
      ,p_val_83                         =>  p_val_83
      ,p_val_84                         =>  p_val_84
      ,p_val_85                         =>  p_val_85
      ,p_val_86                         =>  p_val_86
      ,p_val_87                         =>  p_val_87
      ,p_val_88                         =>  p_val_88
      ,p_val_89                         =>  p_val_89
      ,p_val_90                         =>  p_val_90
      ,p_val_91                         =>  p_val_91
      ,p_val_92                         =>  p_val_92
      ,p_val_93                         =>  p_val_93
      ,p_val_94                         =>  p_val_94
      ,p_val_95                         =>  p_val_95
      ,p_val_96                         =>  p_val_96
      ,p_val_97                         =>  p_val_97
      ,p_val_98                         =>  p_val_98
      ,p_val_99                         =>  p_val_99
      ,p_val_100                        =>  p_val_100
      ,p_val_101                        =>  p_val_101
      ,p_val_102                         =>  p_val_102
      ,p_val_103                         =>  p_val_103
      ,p_val_104                         =>  p_val_104
      ,p_val_105                         =>  p_val_105
      ,p_val_106                         =>  p_val_106
      ,p_val_107                         =>  p_val_107
      ,p_val_108                         =>  p_val_108
      ,p_val_109                         =>  p_val_109
      ,p_val_110                         =>  p_val_110
      ,p_val_111                         =>  p_val_111
      ,p_val_112                         =>  p_val_112
      ,p_val_113                         =>  p_val_113
      ,p_val_114                         =>  p_val_114
      ,p_val_115                         =>  p_val_115
      ,p_val_116                         =>  p_val_116
      ,p_val_117                         =>  p_val_117
      ,p_val_119                         =>  p_val_119
      ,p_val_118                         =>  p_val_118
      ,p_val_120                         =>  p_val_120
      ,p_val_121                         =>  p_val_121
      ,p_val_122                         =>  p_val_122
      ,p_val_123                         =>  p_val_123
      ,p_val_124                         =>  p_val_124
      ,p_val_125                         =>  p_val_125
      ,p_val_126                         =>  p_val_126
      ,p_val_127                         =>  p_val_127
      ,p_val_128                         =>  p_val_128
      ,p_val_129                         =>  p_val_129
      ,p_val_130                         =>  p_val_130
      ,p_val_131                         =>  p_val_131
      ,p_val_132                         =>  p_val_132
      ,p_val_133                         =>  p_val_133
      ,p_val_134                         =>  p_val_134
      ,p_val_135                         =>  p_val_135
      ,p_val_136                         =>  p_val_136
      ,p_val_137                         =>  p_val_137
      ,p_val_138                         =>  p_val_138
      ,p_val_139                         =>  p_val_139
      ,p_val_140                         =>  p_val_140
      ,p_val_141                         =>  p_val_141
      ,p_val_142                         =>  p_val_142
      ,p_val_143                         =>  p_val_143
      ,p_val_144                         =>  p_val_144
      ,p_val_145                         =>  p_val_145
      ,p_val_146                         =>  p_val_146
      ,p_val_147                         =>  p_val_147
      ,p_val_148                         =>  p_val_148
      ,p_val_149                         =>  p_val_149
      ,p_val_150                         =>  p_val_150
      ,p_val_151                         =>  p_val_151
      ,p_val_152                         =>  p_val_152
      ,p_val_153                         =>  p_val_153
      ,p_val_154                         =>  p_val_154
      ,p_val_155                         =>  p_val_155
      ,p_val_156                         =>  p_val_156
      ,p_val_157                         =>  p_val_157
      ,p_val_158                         =>  p_val_158
      ,p_val_159                         =>  p_val_159
      ,p_val_160                         =>  p_val_160
      ,p_val_161                         =>  p_val_161
      ,p_val_162                         =>  p_val_162
      ,p_val_163                         =>  p_val_163
      ,p_val_164                         =>  p_val_164
      ,p_val_165                         =>  p_val_165
      ,p_val_166                         =>  p_val_166
      ,p_val_167                         =>  p_val_167
      ,p_val_168                         =>  p_val_168
      ,p_val_169                         =>  p_val_169
      ,p_val_170                         =>  p_val_170
      ,p_val_171                         =>  p_val_171
      ,p_val_172                         =>  p_val_172
      ,p_val_173                         =>  p_val_173
      ,p_val_174                         =>  p_val_174
      ,p_val_175                         =>  p_val_175
      ,p_val_176                         =>  p_val_176
      ,p_val_177                         =>  p_val_177
      ,p_val_178                         =>  p_val_178
      ,p_val_179                         =>  p_val_179
      ,p_val_180                         =>  p_val_180
      ,p_val_181                         =>  p_val_181
      ,p_val_182                         =>  p_val_182
      ,p_val_183                         =>  p_val_183
      ,p_val_184                         =>  p_val_184
      ,p_val_185                         =>  p_val_185
      ,p_val_186                         =>  p_val_186
      ,p_val_187                         =>  p_val_187
      ,p_val_188                         =>  p_val_188
      ,p_val_189                         =>  p_val_189
      ,p_val_190                         =>  p_val_190
      ,p_val_191                         =>  p_val_191
      ,p_val_192                         =>  p_val_192
      ,p_val_193                         =>  p_val_193
      ,p_val_194                         =>  p_val_194
      ,p_val_195                         =>  p_val_195
      ,p_val_196                         =>  p_val_196
      ,p_val_197                         =>  p_val_197
      ,p_val_198                         =>  p_val_198
      ,p_val_199                         =>  p_val_199
      ,p_val_200                         =>  p_val_200
      ,p_val_201                         =>  p_val_201
      ,p_val_202                         =>  p_val_202
      ,p_val_203                         =>  p_val_203
      ,p_val_204                         =>  p_val_204
      ,p_val_205                         =>  p_val_205
      ,p_val_206                         =>  p_val_206
      ,p_val_207                         =>  p_val_207
      ,p_val_208                         =>  p_val_208
      ,p_val_209                         =>  p_val_209
      ,p_val_210                         =>  p_val_210
      ,p_val_211                         =>  p_val_211
      ,p_val_212                         =>  p_val_212
      ,p_val_213                         =>  p_val_213
      ,p_val_214                         =>  p_val_214
      ,p_val_215                         =>  p_val_215
      ,p_val_216                         =>  p_val_216
      ,p_val_217                         =>  p_val_217
      ,p_val_219                         =>  p_val_219
      ,p_val_218                         =>  p_val_218
      ,p_val_220                         =>  p_val_220
      ,p_val_221                         =>  p_val_221
      ,p_val_222                         =>  p_val_222
      ,p_val_223                         =>  p_val_223
      ,p_val_224                         =>  p_val_224
      ,p_val_225                         =>  p_val_225
      ,p_val_226                         =>  p_val_226
      ,p_val_227                         =>  p_val_227
      ,p_val_228                         =>  p_val_228
      ,p_val_229                         =>  p_val_229
      ,p_val_230                         =>  p_val_230
      ,p_val_231                         =>  p_val_231
      ,p_val_232                         =>  p_val_232
      ,p_val_233                         =>  p_val_233
      ,p_val_234                         =>  p_val_234
      ,p_val_235                         =>  p_val_235
      ,p_val_236                         =>  p_val_236
      ,p_val_237                         =>  p_val_237
      ,p_val_238                         =>  p_val_238
      ,p_val_239                         =>  p_val_239
      ,p_val_240                         =>  p_val_240
      ,p_val_241                         =>  p_val_241
      ,p_val_242                         =>  p_val_242
      ,p_val_243                         =>  p_val_243
      ,p_val_244                         =>  p_val_244
      ,p_val_245                         =>  p_val_245
      ,p_val_246                         =>  p_val_246
      ,p_val_247                         =>  p_val_247
      ,p_val_248                         =>  p_val_248
      ,p_val_249                         =>  p_val_249
      ,p_val_250                         =>  p_val_250
      ,p_val_251                         =>  p_val_251
      ,p_val_252                         =>  p_val_252
      ,p_val_253                         =>  p_val_253
      ,p_val_254                         =>  p_val_254
      ,p_val_255                         =>  p_val_255
      ,p_val_256                         =>  p_val_256
      ,p_val_257                         =>  p_val_257
      ,p_val_258                         =>  p_val_258
      ,p_val_259                         =>  p_val_259
      ,p_val_260                         =>  p_val_260
      ,p_val_261                         =>  p_val_261
      ,p_val_262                         =>  p_val_262
      ,p_val_263                         =>  p_val_263
      ,p_val_264                         =>  p_val_264
      ,p_val_265                         =>  p_val_265
      ,p_val_266                         =>  p_val_266
      ,p_val_267                         =>  p_val_267
      ,p_val_268                         =>  p_val_268
      ,p_val_269                         =>  p_val_269
      ,p_val_270                         =>  p_val_270
      ,p_val_271                         =>  p_val_271
      ,p_val_272                         =>  p_val_272
      ,p_val_273                         =>  p_val_273
      ,p_val_274                         =>  p_val_274
      ,p_val_275                         =>  p_val_275
      ,p_val_276                         =>  p_val_276
      ,p_val_277                         =>  p_val_277
      ,p_val_278                         =>  p_val_278
      ,p_val_279                         =>  p_val_279
      ,p_val_280                         =>  p_val_280
      ,p_val_281                         =>  p_val_281
      ,p_val_282                         =>  p_val_282
      ,p_val_283                         =>  p_val_283
      ,p_val_284                         =>  p_val_284
      ,p_val_285                         =>  p_val_285
      ,p_val_286                         =>  p_val_286
      ,p_val_287                         =>  p_val_287
      ,p_val_288                         =>  p_val_288
      ,p_val_289                         =>  p_val_289
      ,p_val_290                         =>  p_val_290
      ,p_val_291                         =>  p_val_291
      ,p_val_292                         =>  p_val_292
      ,p_val_293                         =>  p_val_293
      ,p_val_294                         =>  p_val_294
      ,p_val_295                         =>  p_val_295
      ,p_val_296                         =>  p_val_296
      ,p_val_297                         =>  p_val_297
      ,p_val_298                         =>  p_val_298
      ,p_val_299                         =>  p_val_299
      ,p_val_300                         =>  p_val_300
      ,p_group_val_01                    =>  p_group_val_01
      ,p_group_val_02                    =>  p_group_val_02
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RSLT_DTL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_RSLT_DTL
    --
  end;
  --
  ben_xrd_upd.upd
    (
     p_ext_rslt_dtl_id               => p_ext_rslt_dtl_id
    ,p_prmy_sort_val                 => p_prmy_sort_val
    ,p_scnd_sort_val                 => p_scnd_sort_val
    ,p_thrd_sort_val                 => p_thrd_sort_val
    ,p_trans_seq_num                 => p_trans_seq_num
    ,p_rcrd_seq_num                  => p_rcrd_seq_num
    ,p_ext_rslt_id                   => p_ext_rslt_id
    ,p_ext_rcd_id                    => p_ext_rcd_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_ext_per_bg_id                 => p_ext_per_bg_id
    ,p_val_01                        => p_val_01
    ,p_val_02                        => p_val_02
    ,p_val_03                        => p_val_03
    ,p_val_04                        => p_val_04
    ,p_val_05                        => p_val_05
    ,p_val_06                        => p_val_06
    ,p_val_07                        => p_val_07
    ,p_val_08                        => p_val_08
    ,p_val_09                        => p_val_09
    ,p_val_10                        => p_val_10
    ,p_val_11                        => p_val_11
    ,p_val_12                        => p_val_12
    ,p_val_13                        => p_val_13
    ,p_val_14                        => p_val_14
    ,p_val_15                        => p_val_15
    ,p_val_16                        => p_val_16
    ,p_val_17                        => p_val_17
    ,p_val_19                        => p_val_19
    ,p_val_18                        => p_val_18
    ,p_val_20                        => p_val_20
    ,p_val_21                        => p_val_21
    ,p_val_22                        => p_val_22
    ,p_val_23                        => p_val_23
    ,p_val_24                        => p_val_24
    ,p_val_25                        => p_val_25
    ,p_val_26                        => p_val_26
    ,p_val_27                        => p_val_27
    ,p_val_28                        => p_val_28
    ,p_val_29                        => p_val_29
    ,p_val_30                        => p_val_30
    ,p_val_31                        => p_val_31
    ,p_val_32                        => p_val_32
    ,p_val_33                        => p_val_33
    ,p_val_34                        => p_val_34
    ,p_val_35                        => p_val_35
    ,p_val_36                        => p_val_36
    ,p_val_37                        => p_val_37
    ,p_val_38                        => p_val_38
    ,p_val_39                        => p_val_39
    ,p_val_40                        => p_val_40
    ,p_val_41                        => p_val_41
    ,p_val_42                        => p_val_42
    ,p_val_43                        => p_val_43
    ,p_val_44                        => p_val_44
    ,p_val_45                        => p_val_45
    ,p_val_46                        => p_val_46
    ,p_val_47                        => p_val_47
    ,p_val_48                        => p_val_48
    ,p_val_49                        => p_val_49
    ,p_val_50                        => p_val_50
    ,p_val_51                        => p_val_51
    ,p_val_52                        => p_val_52
    ,p_val_53                        => p_val_53
    ,p_val_54                        => p_val_54
    ,p_val_55                        => p_val_55
    ,p_val_56                        => p_val_56
    ,p_val_57                        => p_val_57
    ,p_val_58                        => p_val_58
    ,p_val_59                        => p_val_59
    ,p_val_60                        => p_val_60
    ,p_val_61                        => p_val_61
    ,p_val_62                        => p_val_62
    ,p_val_63                        => p_val_63
    ,p_val_64                        => p_val_64
    ,p_val_65                        => p_val_65
    ,p_val_66                        => p_val_66
    ,p_val_67                        => p_val_67
    ,p_val_68                        => p_val_68
    ,p_val_69                        => p_val_69
    ,p_val_70                        => p_val_70
    ,p_val_71                        => p_val_71
    ,p_val_72                        => p_val_72
    ,p_val_73                        => p_val_73
    ,p_val_74                        => p_val_74
    ,p_val_75                        => p_val_75
    ,p_val_76                         =>  p_val_76
    ,p_val_77                         =>  p_val_77
    ,p_val_78                         =>  p_val_78
    ,p_val_79                         =>  p_val_79
    ,p_val_80                         =>  p_val_80
    ,p_val_81                         =>  p_val_81
    ,p_val_82                         =>  p_val_82
    ,p_val_83                         =>  p_val_83
    ,p_val_84                         =>  p_val_84
    ,p_val_85                         =>  p_val_85
    ,p_val_86                         =>  p_val_86
    ,p_val_87                         =>  p_val_87
    ,p_val_88                         =>  p_val_88
    ,p_val_89                         =>  p_val_89
    ,p_val_90                         =>  p_val_90
    ,p_val_91                         =>  p_val_91
    ,p_val_92                         =>  p_val_92
    ,p_val_93                         =>  p_val_93
    ,p_val_94                         =>  p_val_94
    ,p_val_95                         =>  p_val_95
    ,p_val_96                         =>  p_val_96
    ,p_val_97                         =>  p_val_97
    ,p_val_98                         =>  p_val_98
    ,p_val_99                         =>  p_val_99
    ,p_val_100                        =>  p_val_100
    ,p_val_101                        =>  p_val_101
    ,p_val_102                         =>  p_val_102
    ,p_val_103                         =>  p_val_103
    ,p_val_104                         =>  p_val_104
    ,p_val_105                         =>  p_val_105
    ,p_val_106                         =>  p_val_106
    ,p_val_107                         =>  p_val_107
    ,p_val_108                         =>  p_val_108
    ,p_val_109                         =>  p_val_109
    ,p_val_110                         =>  p_val_110
    ,p_val_111                         =>  p_val_111
    ,p_val_112                         =>  p_val_112
    ,p_val_113                         =>  p_val_113
    ,p_val_114                         =>  p_val_114
    ,p_val_115                         =>  p_val_115
    ,p_val_116                         =>  p_val_116
    ,p_val_117                         =>  p_val_117
    ,p_val_119                         =>  p_val_119
    ,p_val_118                         =>  p_val_118
    ,p_val_120                         =>  p_val_120
    ,p_val_121                         =>  p_val_121
    ,p_val_122                         =>  p_val_122
    ,p_val_123                         =>  p_val_123
    ,p_val_124                         =>  p_val_124
    ,p_val_125                         =>  p_val_125
    ,p_val_126                         =>  p_val_126
    ,p_val_127                         =>  p_val_127
    ,p_val_128                         =>  p_val_128
    ,p_val_129                         =>  p_val_129
    ,p_val_130                         =>  p_val_130
    ,p_val_131                         =>  p_val_131
    ,p_val_132                         =>  p_val_132
    ,p_val_133                         =>  p_val_133
    ,p_val_134                         =>  p_val_134
    ,p_val_135                         =>  p_val_135
    ,p_val_136                         =>  p_val_136
    ,p_val_137                         =>  p_val_137
    ,p_val_138                         =>  p_val_138
    ,p_val_139                         =>  p_val_139
    ,p_val_140                         =>  p_val_140
    ,p_val_141                         =>  p_val_141
    ,p_val_142                         =>  p_val_142
    ,p_val_143                         =>  p_val_143
    ,p_val_144                         =>  p_val_144
    ,p_val_145                         =>  p_val_145
    ,p_val_146                         =>  p_val_146
    ,p_val_147                         =>  p_val_147
    ,p_val_148                         =>  p_val_148
    ,p_val_149                         =>  p_val_149
    ,p_val_150                         =>  p_val_150
    ,p_val_151                         =>  p_val_151
    ,p_val_152                         =>  p_val_152
    ,p_val_153                         =>  p_val_153
    ,p_val_154                         =>  p_val_154
    ,p_val_155                         =>  p_val_155
    ,p_val_156                         =>  p_val_156
    ,p_val_157                         =>  p_val_157
    ,p_val_158                         =>  p_val_158
    ,p_val_159                         =>  p_val_159
    ,p_val_160                         =>  p_val_160
    ,p_val_161                         =>  p_val_161
    ,p_val_162                         =>  p_val_162
    ,p_val_163                         =>  p_val_163
    ,p_val_164                         =>  p_val_164
    ,p_val_165                         =>  p_val_165
    ,p_val_166                         =>  p_val_166
    ,p_val_167                         =>  p_val_167
    ,p_val_168                         =>  p_val_168
    ,p_val_169                         =>  p_val_169
    ,p_val_170                         =>  p_val_170
    ,p_val_171                         =>  p_val_171
    ,p_val_172                         =>  p_val_172
    ,p_val_173                         =>  p_val_173
    ,p_val_174                         =>  p_val_174
    ,p_val_175                         =>  p_val_175
    ,p_val_176                         =>  p_val_176
    ,p_val_177                         =>  p_val_177
    ,p_val_178                         =>  p_val_178
    ,p_val_179                         =>  p_val_179
    ,p_val_180                         =>  p_val_180
    ,p_val_181                         =>  p_val_181
    ,p_val_182                         =>  p_val_182
    ,p_val_183                         =>  p_val_183
    ,p_val_184                         =>  p_val_184
    ,p_val_185                         =>  p_val_185
    ,p_val_186                         =>  p_val_186
    ,p_val_187                         =>  p_val_187
    ,p_val_188                         =>  p_val_188
    ,p_val_189                         =>  p_val_189
    ,p_val_190                         =>  p_val_190
    ,p_val_191                         =>  p_val_191
    ,p_val_192                         =>  p_val_192
    ,p_val_193                         =>  p_val_193
    ,p_val_194                         =>  p_val_194
    ,p_val_195                         =>  p_val_195
    ,p_val_196                         =>  p_val_196
    ,p_val_197                         =>  p_val_197
    ,p_val_198                         =>  p_val_198
    ,p_val_199                         =>  p_val_199
    ,p_val_200                         =>  p_val_200
    ,p_val_201                         =>  p_val_201
    ,p_val_202                         =>  p_val_202
    ,p_val_203                         =>  p_val_203
    ,p_val_204                         =>  p_val_204
    ,p_val_205                         =>  p_val_205
    ,p_val_206                         =>  p_val_206
    ,p_val_207                         =>  p_val_207
    ,p_val_208                         =>  p_val_208
    ,p_val_209                         =>  p_val_209
    ,p_val_210                         =>  p_val_210
    ,p_val_211                         =>  p_val_211
    ,p_val_212                         =>  p_val_212
    ,p_val_213                         =>  p_val_213
    ,p_val_214                         =>  p_val_214
    ,p_val_215                         =>  p_val_215
    ,p_val_216                         =>  p_val_216
    ,p_val_217                         =>  p_val_217
    ,p_val_219                         =>  p_val_219
    ,p_val_218                         =>  p_val_218
    ,p_val_220                         =>  p_val_220
    ,p_val_221                         =>  p_val_221
    ,p_val_222                         =>  p_val_222
    ,p_val_223                         =>  p_val_223
    ,p_val_224                         =>  p_val_224
    ,p_val_225                         =>  p_val_225
    ,p_val_226                         =>  p_val_226
    ,p_val_227                         =>  p_val_227
    ,p_val_228                         =>  p_val_228
    ,p_val_229                         =>  p_val_229
    ,p_val_230                         =>  p_val_230
    ,p_val_231                         =>  p_val_231
    ,p_val_232                         =>  p_val_232
    ,p_val_233                         =>  p_val_233
    ,p_val_234                         =>  p_val_234
    ,p_val_235                         =>  p_val_235
    ,p_val_236                         =>  p_val_236
    ,p_val_237                         =>  p_val_237
    ,p_val_238                         =>  p_val_238
    ,p_val_239                         =>  p_val_239
    ,p_val_240                         =>  p_val_240
    ,p_val_241                         =>  p_val_241
    ,p_val_242                         =>  p_val_242
    ,p_val_243                         =>  p_val_243
    ,p_val_244                         =>  p_val_244
    ,p_val_245                         =>  p_val_245
    ,p_val_246                         =>  p_val_246
    ,p_val_247                         =>  p_val_247
    ,p_val_248                         =>  p_val_248
    ,p_val_249                         =>  p_val_249
    ,p_val_250                         =>  p_val_250
    ,p_val_251                         =>  p_val_251
    ,p_val_252                         =>  p_val_252
    ,p_val_253                         =>  p_val_253
    ,p_val_254                         =>  p_val_254
    ,p_val_255                         =>  p_val_255
    ,p_val_256                         =>  p_val_256
    ,p_val_257                         =>  p_val_257
    ,p_val_258                         =>  p_val_258
    ,p_val_259                         =>  p_val_259
    ,p_val_260                         =>  p_val_260
    ,p_val_261                         =>  p_val_261
    ,p_val_262                         =>  p_val_262
    ,p_val_263                         =>  p_val_263
    ,p_val_264                         =>  p_val_264
    ,p_val_265                         =>  p_val_265
    ,p_val_266                         =>  p_val_266
    ,p_val_267                         =>  p_val_267
    ,p_val_268                         =>  p_val_268
    ,p_val_269                         =>  p_val_269
    ,p_val_270                         =>  p_val_270
    ,p_val_271                         =>  p_val_271
    ,p_val_272                         =>  p_val_272
    ,p_val_273                         =>  p_val_273
    ,p_val_274                         =>  p_val_274
    ,p_val_275                         =>  p_val_275
    ,p_val_276                         =>  p_val_276
    ,p_val_277                         =>  p_val_277
    ,p_val_278                         =>  p_val_278
    ,p_val_279                         =>  p_val_279
    ,p_val_280                         =>  p_val_280
    ,p_val_281                         =>  p_val_281
    ,p_val_282                         =>  p_val_282
    ,p_val_283                         =>  p_val_283
    ,p_val_284                         =>  p_val_284
    ,p_val_285                         =>  p_val_285
    ,p_val_286                         =>  p_val_286
    ,p_val_287                         =>  p_val_287
    ,p_val_288                         =>  p_val_288
    ,p_val_289                         =>  p_val_289
    ,p_val_290                         =>  p_val_290
    ,p_val_291                         =>  p_val_291
    ,p_val_292                         =>  p_val_292
    ,p_val_293                         =>  p_val_293
    ,p_val_294                         =>  p_val_294
    ,p_val_295                         =>  p_val_295
    ,p_val_296                         =>  p_val_296
    ,p_val_297                         =>  p_val_297
    ,p_val_298                         =>  p_val_298
    ,p_val_299                         =>  p_val_299
    ,p_val_300                         =>  p_val_300
    ,p_group_val_01                    =>  p_group_val_01
    ,p_group_val_02                    =>  p_group_val_02
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_request_id                    => p_request_id
    ,p_object_version_number         => l_object_version_number
    ,p_ext_rcd_in_file_id            => p_ext_rcd_in_file_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_RSLT_DTL
    --
    ben_EXT_RSLT_DTL_bk2.update_EXT_RSLT_DTL_a
      (
       p_ext_rslt_dtl_id                =>  p_ext_rslt_dtl_id
      ,p_prmy_sort_val                  =>  p_prmy_sort_val
      ,p_scnd_sort_val                  =>  p_scnd_sort_val
      ,p_thrd_sort_val                  =>  p_thrd_sort_val
      ,p_trans_seq_num                  =>  p_trans_seq_num
      ,p_rcrd_seq_num                   =>  p_rcrd_seq_num
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ext_per_bg_id                  =>  p_ext_per_bg_id
      ,p_val_01                         =>  p_val_01
      ,p_val_02                         =>  p_val_02
      ,p_val_03                         =>  p_val_03
      ,p_val_04                         =>  p_val_04
      ,p_val_05                         =>  p_val_05
      ,p_val_06                         =>  p_val_06
      ,p_val_07                         =>  p_val_07
      ,p_val_08                         =>  p_val_08
      ,p_val_09                         =>  p_val_09
      ,p_val_10                         =>  p_val_10
      ,p_val_11                         =>  p_val_11
      ,p_val_12                         =>  p_val_12
      ,p_val_13                         =>  p_val_13
      ,p_val_14                         =>  p_val_14
      ,p_val_15                         =>  p_val_15
      ,p_val_16                         =>  p_val_16
      ,p_val_17                         =>  p_val_17
      ,p_val_19                         =>  p_val_19
      ,p_val_18                         =>  p_val_18
      ,p_val_20                         =>  p_val_20
      ,p_val_21                         =>  p_val_21
      ,p_val_22                         =>  p_val_22
      ,p_val_23                         =>  p_val_23
      ,p_val_24                         =>  p_val_24
      ,p_val_25                         =>  p_val_25
      ,p_val_26                         =>  p_val_26
      ,p_val_27                         =>  p_val_27
      ,p_val_28                         =>  p_val_28
      ,p_val_29                         =>  p_val_29
      ,p_val_30                         =>  p_val_30
      ,p_val_31                         =>  p_val_31
      ,p_val_32                         =>  p_val_32
      ,p_val_33                         =>  p_val_33
      ,p_val_34                         =>  p_val_34
      ,p_val_35                         =>  p_val_35
      ,p_val_36                         =>  p_val_36
      ,p_val_37                         =>  p_val_37
      ,p_val_38                         =>  p_val_38
      ,p_val_39                         =>  p_val_39
      ,p_val_40                         =>  p_val_40
      ,p_val_41                         =>  p_val_41
      ,p_val_42                         =>  p_val_42
      ,p_val_43                         =>  p_val_43
      ,p_val_44                         =>  p_val_44
      ,p_val_45                         =>  p_val_45
      ,p_val_46                         =>  p_val_46
      ,p_val_47                         =>  p_val_47
      ,p_val_48                         =>  p_val_48
      ,p_val_49                         =>  p_val_49
      ,p_val_50                         =>  p_val_50
      ,p_val_51                         =>  p_val_51
      ,p_val_52                         =>  p_val_52
      ,p_val_53                         =>  p_val_53
      ,p_val_54                         =>  p_val_54
      ,p_val_55                         =>  p_val_55
      ,p_val_56                         =>  p_val_56
      ,p_val_57                         =>  p_val_57
      ,p_val_58                         =>  p_val_58
      ,p_val_59                         =>  p_val_59
      ,p_val_60                         =>  p_val_60
      ,p_val_61                         =>  p_val_61
      ,p_val_62                         =>  p_val_62
      ,p_val_63                         =>  p_val_63
      ,p_val_64                         =>  p_val_64
      ,p_val_65                         =>  p_val_65
      ,p_val_66                         =>  p_val_66
      ,p_val_67                         =>  p_val_67
      ,p_val_68                         =>  p_val_68
      ,p_val_69                         =>  p_val_69
      ,p_val_70                         =>  p_val_70
      ,p_val_71                         =>  p_val_71
      ,p_val_72                         =>  p_val_72
      ,p_val_73                         =>  p_val_73
      ,p_val_74                         =>  p_val_74
      ,p_val_75                         =>  p_val_75
      ,p_val_76                         =>  p_val_76
      ,p_val_77                         =>  p_val_77
      ,p_val_78                         =>  p_val_78
      ,p_val_79                         =>  p_val_79
      ,p_val_80                         =>  p_val_80
      ,p_val_81                         =>  p_val_81
      ,p_val_82                         =>  p_val_82
      ,p_val_83                         =>  p_val_83
      ,p_val_84                         =>  p_val_84
      ,p_val_85                         =>  p_val_85
      ,p_val_86                         =>  p_val_86
      ,p_val_87                         =>  p_val_87
      ,p_val_88                         =>  p_val_88
      ,p_val_89                         =>  p_val_89
      ,p_val_90                         =>  p_val_90
      ,p_val_91                         =>  p_val_91
      ,p_val_92                         =>  p_val_92
      ,p_val_93                         =>  p_val_93
      ,p_val_94                         =>  p_val_94
      ,p_val_95                         =>  p_val_95
      ,p_val_96                         =>  p_val_96
      ,p_val_97                         =>  p_val_97
      ,p_val_98                         =>  p_val_98
      ,p_val_99                         =>  p_val_99
      ,p_val_100                        =>  p_val_100
      ,p_val_101                        =>  p_val_101
      ,p_val_102                         =>  p_val_102
      ,p_val_103                         =>  p_val_103
      ,p_val_104                         =>  p_val_104
      ,p_val_105                         =>  p_val_105
      ,p_val_106                         =>  p_val_106
      ,p_val_107                         =>  p_val_107
      ,p_val_108                         =>  p_val_108
      ,p_val_109                         =>  p_val_109
      ,p_val_110                         =>  p_val_110
      ,p_val_111                         =>  p_val_111
      ,p_val_112                         =>  p_val_112
      ,p_val_113                         =>  p_val_113
      ,p_val_114                         =>  p_val_114
      ,p_val_115                         =>  p_val_115
      ,p_val_116                         =>  p_val_116
      ,p_val_117                         =>  p_val_117
      ,p_val_119                         =>  p_val_119
      ,p_val_118                         =>  p_val_118
      ,p_val_120                         =>  p_val_120
      ,p_val_121                         =>  p_val_121
      ,p_val_122                         =>  p_val_122
      ,p_val_123                         =>  p_val_123
      ,p_val_124                         =>  p_val_124
      ,p_val_125                         =>  p_val_125
      ,p_val_126                         =>  p_val_126
      ,p_val_127                         =>  p_val_127
      ,p_val_128                         =>  p_val_128
      ,p_val_129                         =>  p_val_129
      ,p_val_130                         =>  p_val_130
      ,p_val_131                         =>  p_val_131
      ,p_val_132                         =>  p_val_132
      ,p_val_133                         =>  p_val_133
      ,p_val_134                         =>  p_val_134
      ,p_val_135                         =>  p_val_135
      ,p_val_136                         =>  p_val_136
      ,p_val_137                         =>  p_val_137
      ,p_val_138                         =>  p_val_138
      ,p_val_139                         =>  p_val_139
      ,p_val_140                         =>  p_val_140
      ,p_val_141                         =>  p_val_141
      ,p_val_142                         =>  p_val_142
      ,p_val_143                         =>  p_val_143
      ,p_val_144                         =>  p_val_144
      ,p_val_145                         =>  p_val_145
      ,p_val_146                         =>  p_val_146
      ,p_val_147                         =>  p_val_147
      ,p_val_148                         =>  p_val_148
      ,p_val_149                         =>  p_val_149
      ,p_val_150                         =>  p_val_150
      ,p_val_151                         =>  p_val_151
      ,p_val_152                         =>  p_val_152
      ,p_val_153                         =>  p_val_153
      ,p_val_154                         =>  p_val_154
      ,p_val_155                         =>  p_val_155
      ,p_val_156                         =>  p_val_156
      ,p_val_157                         =>  p_val_157
      ,p_val_158                         =>  p_val_158
      ,p_val_159                         =>  p_val_159
      ,p_val_160                         =>  p_val_160
      ,p_val_161                         =>  p_val_161
      ,p_val_162                         =>  p_val_162
      ,p_val_163                         =>  p_val_163
      ,p_val_164                         =>  p_val_164
      ,p_val_165                         =>  p_val_165
      ,p_val_166                         =>  p_val_166
      ,p_val_167                         =>  p_val_167
      ,p_val_168                         =>  p_val_168
      ,p_val_169                         =>  p_val_169
      ,p_val_170                         =>  p_val_170
      ,p_val_171                         =>  p_val_171
      ,p_val_172                         =>  p_val_172
      ,p_val_173                         =>  p_val_173
      ,p_val_174                         =>  p_val_174
      ,p_val_175                         =>  p_val_175
      ,p_val_176                         =>  p_val_176
      ,p_val_177                         =>  p_val_177
      ,p_val_178                         =>  p_val_178
      ,p_val_179                         =>  p_val_179
      ,p_val_180                         =>  p_val_180
      ,p_val_181                         =>  p_val_181
      ,p_val_182                         =>  p_val_182
      ,p_val_183                         =>  p_val_183
      ,p_val_184                         =>  p_val_184
      ,p_val_185                         =>  p_val_185
      ,p_val_186                         =>  p_val_186
      ,p_val_187                         =>  p_val_187
      ,p_val_188                         =>  p_val_188
      ,p_val_189                         =>  p_val_189
      ,p_val_190                         =>  p_val_190
      ,p_val_191                         =>  p_val_191
      ,p_val_192                         =>  p_val_192
      ,p_val_193                         =>  p_val_193
      ,p_val_194                         =>  p_val_194
      ,p_val_195                         =>  p_val_195
      ,p_val_196                         =>  p_val_196
      ,p_val_197                         =>  p_val_197
      ,p_val_198                         =>  p_val_198
      ,p_val_199                         =>  p_val_199
      ,p_val_200                         =>  p_val_200
      ,p_val_201                         =>  p_val_201
      ,p_val_202                         =>  p_val_202
      ,p_val_203                         =>  p_val_203
      ,p_val_204                         =>  p_val_204
      ,p_val_205                         =>  p_val_205
      ,p_val_206                         =>  p_val_206
      ,p_val_207                         =>  p_val_207
      ,p_val_208                         =>  p_val_208
      ,p_val_209                         =>  p_val_209
      ,p_val_210                         =>  p_val_210
      ,p_val_211                         =>  p_val_211
      ,p_val_212                         =>  p_val_212
      ,p_val_213                         =>  p_val_213
      ,p_val_214                         =>  p_val_214
      ,p_val_215                         =>  p_val_215
      ,p_val_216                         =>  p_val_216
      ,p_val_217                         =>  p_val_217
      ,p_val_219                         =>  p_val_219
      ,p_val_218                         =>  p_val_218
      ,p_val_220                         =>  p_val_220
      ,p_val_221                         =>  p_val_221
      ,p_val_222                         =>  p_val_222
      ,p_val_223                         =>  p_val_223
      ,p_val_224                         =>  p_val_224
      ,p_val_225                         =>  p_val_225
      ,p_val_226                         =>  p_val_226
      ,p_val_227                         =>  p_val_227
      ,p_val_228                         =>  p_val_228
      ,p_val_229                         =>  p_val_229
      ,p_val_230                         =>  p_val_230
      ,p_val_231                         =>  p_val_231
      ,p_val_232                         =>  p_val_232
      ,p_val_233                         =>  p_val_233
      ,p_val_234                         =>  p_val_234
      ,p_val_235                         =>  p_val_235
      ,p_val_236                         =>  p_val_236
      ,p_val_237                         =>  p_val_237
      ,p_val_238                         =>  p_val_238
      ,p_val_239                         =>  p_val_239
      ,p_val_240                         =>  p_val_240
      ,p_val_241                         =>  p_val_241
      ,p_val_242                         =>  p_val_242
      ,p_val_243                         =>  p_val_243
      ,p_val_244                         =>  p_val_244
      ,p_val_245                         =>  p_val_245
      ,p_val_246                         =>  p_val_246
      ,p_val_247                         =>  p_val_247
      ,p_val_248                         =>  p_val_248
      ,p_val_249                         =>  p_val_249
      ,p_val_250                         =>  p_val_250
      ,p_val_251                         =>  p_val_251
      ,p_val_252                         =>  p_val_252
      ,p_val_253                         =>  p_val_253
      ,p_val_254                         =>  p_val_254
      ,p_val_255                         =>  p_val_255
      ,p_val_256                         =>  p_val_256
      ,p_val_257                         =>  p_val_257
      ,p_val_258                         =>  p_val_258
      ,p_val_259                         =>  p_val_259
      ,p_val_260                         =>  p_val_260
      ,p_val_261                         =>  p_val_261
      ,p_val_262                         =>  p_val_262
      ,p_val_263                         =>  p_val_263
      ,p_val_264                         =>  p_val_264
      ,p_val_265                         =>  p_val_265
      ,p_val_266                         =>  p_val_266
      ,p_val_267                         =>  p_val_267
      ,p_val_268                         =>  p_val_268
      ,p_val_269                         =>  p_val_269
      ,p_val_270                         =>  p_val_270
      ,p_val_271                         =>  p_val_271
      ,p_val_272                         =>  p_val_272
      ,p_val_273                         =>  p_val_273
      ,p_val_274                         =>  p_val_274
      ,p_val_275                         =>  p_val_275
      ,p_val_276                         =>  p_val_276
      ,p_val_277                         =>  p_val_277
      ,p_val_278                         =>  p_val_278
      ,p_val_279                         =>  p_val_279
      ,p_val_280                         =>  p_val_280
      ,p_val_281                         =>  p_val_281
      ,p_val_282                         =>  p_val_282
      ,p_val_283                         =>  p_val_283
      ,p_val_284                         =>  p_val_284
      ,p_val_285                         =>  p_val_285
      ,p_val_286                         =>  p_val_286
      ,p_val_287                         =>  p_val_287
      ,p_val_288                         =>  p_val_288
      ,p_val_289                         =>  p_val_289
      ,p_val_290                         =>  p_val_290
      ,p_val_291                         =>  p_val_291
      ,p_val_292                         =>  p_val_292
      ,p_val_293                         =>  p_val_293
      ,p_val_294                         =>  p_val_294
      ,p_val_295                         =>  p_val_295
      ,p_val_296                         =>  p_val_296
      ,p_val_297                         =>  p_val_297
      ,p_val_298                         =>  p_val_298
      ,p_val_299                         =>  p_val_299
      ,p_val_300                         =>  p_val_300
      ,p_group_val_01                    =>  p_group_val_01
      ,p_group_val_02                    =>  p_group_val_02
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RSLT_DTL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_RSLT_DTL
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_EXT_RSLT_DTL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_EXT_RSLT_DTL;
    raise;
    --
end update_EXT_RSLT_DTL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RSLT_DTL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_DTL
  (p_validate                       in  boolean  default false
  ,p_ext_rslt_dtl_id                in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RSLT_DTL';
  l_object_version_number ben_ext_rslt_dtl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_RSLT_DTL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_EXT_RSLT_DTL
    --
    ben_EXT_RSLT_DTL_bk3.delete_EXT_RSLT_DTL_b
      (
       p_ext_rslt_dtl_id                =>  p_ext_rslt_dtl_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RSLT_DTL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_RSLT_DTL
    --
  end;
  --
  ben_xrd_del.del
    (
     p_ext_rslt_dtl_id               => p_ext_rslt_dtl_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_RSLT_DTL
    --
    ben_EXT_RSLT_DTL_bk3.delete_EXT_RSLT_DTL_a
      (
       p_ext_rslt_dtl_id                =>  p_ext_rslt_dtl_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RSLT_DTL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_RSLT_DTL
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_EXT_RSLT_DTL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_EXT_RSLT_DTL;
    raise;
    --
end delete_EXT_RSLT_DTL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_rslt_dtl_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_xrd_shd.lck
    (
      p_ext_rslt_dtl_id                 => p_ext_rslt_dtl_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_RSLT_DTL_api;

/
