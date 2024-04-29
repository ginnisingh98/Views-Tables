--------------------------------------------------------
--  DDL for Package BEN_XRD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XRD_INS" AUTHID CURRENT_USER as
/* $Header: bexrdrhi.pkh 120.0 2005/05/28 12:39:21 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ben_xrd_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_ext_rslt_dtl_id              out nocopy number,
  p_prmy_sort_val                in varchar2         default null,
  p_scnd_sort_val                in varchar2         default null,
  p_thrd_sort_val                in varchar2         default null,
  p_trans_seq_num                in number           default null,
  p_rcrd_seq_num                 in number           default null,
  p_ext_rslt_id                  in number,
  p_ext_rcd_id                   in number,
  p_person_id                    in number,
  p_business_group_id            in number,
  p_ext_per_bg_id                in number           default null,
  p_val_01                       in varchar2         default null,
  p_val_02                       in varchar2         default null,
  p_val_03                       in varchar2         default null,
  p_val_04                       in varchar2         default null,
  p_val_05                       in varchar2         default null,
  p_val_06                       in varchar2         default null,
  p_val_07                       in varchar2         default null,
  p_val_08                       in varchar2         default null,
  p_val_09                       in varchar2         default null,
  p_val_10                       in varchar2         default null,
  p_val_11                       in varchar2         default null,
  p_val_12                       in varchar2         default null,
  p_val_13                       in varchar2         default null,
  p_val_14                       in varchar2         default null,
  p_val_15                       in varchar2         default null,
  p_val_16                       in varchar2         default null,
  p_val_17                       in varchar2         default null,
  p_val_19                       in varchar2         default null,
  p_val_18                       in varchar2         default null,
  p_val_20                       in varchar2         default null,
  p_val_21                       in varchar2         default null,
  p_val_22                       in varchar2         default null,
  p_val_23                       in varchar2         default null,
  p_val_24                       in varchar2         default null,
  p_val_25                       in varchar2         default null,
  p_val_26                       in varchar2         default null,
  p_val_27                       in varchar2         default null,
  p_val_28                       in varchar2         default null,
  p_val_29                       in varchar2         default null,
  p_val_30                       in varchar2         default null,
  p_val_31                       in varchar2         default null,
  p_val_32                       in varchar2         default null,
  p_val_33                       in varchar2         default null,
  p_val_34                       in varchar2         default null,
  p_val_35                       in varchar2         default null,
  p_val_36                       in varchar2         default null,
  p_val_37                       in varchar2         default null,
  p_val_38                       in varchar2         default null,
  p_val_39                       in varchar2         default null,
  p_val_40                       in varchar2         default null,
  p_val_41                       in varchar2         default null,
  p_val_42                       in varchar2         default null,
  p_val_43                       in varchar2         default null,
  p_val_44                       in varchar2         default null,
  p_val_45                       in varchar2         default null,
  p_val_46                       in varchar2         default null,
  p_val_47                       in varchar2         default null,
  p_val_48                       in varchar2         default null,
  p_val_49                       in varchar2         default null,
  p_val_50                       in varchar2         default null,
  p_val_51                       in varchar2         default null,
  p_val_52                       in varchar2         default null,
  p_val_53                       in varchar2         default null,
  p_val_54                       in varchar2         default null,
  p_val_55                       in varchar2         default null,
  p_val_56                       in varchar2         default null,
  p_val_57                       in varchar2         default null,
  p_val_58                       in varchar2         default null,
  p_val_59                       in varchar2         default null,
  p_val_60                       in varchar2         default null,
  p_val_61                       in varchar2         default null,
  p_val_62                       in varchar2         default null,
  p_val_63                       in varchar2         default null,
  p_val_64                       in varchar2         default null,
  p_val_65                       in varchar2         default null,
  p_val_66                       in varchar2         default null,
  p_val_67                       in varchar2         default null,
  p_val_68                       in varchar2         default null,
  p_val_69                       in varchar2         default null,
  p_val_70                       in varchar2         default null,
  p_val_71                       in varchar2         default null,
  p_val_72                       in varchar2         default null,
  p_val_73                       in varchar2         default null,
  p_val_74                       in varchar2         default null,
  p_val_75                       in varchar2         default null,
  p_val_76                       in  varchar2  default null,
  p_val_77                       in  varchar2  default null,
  p_val_78                       in  varchar2  default null,
  p_val_79                       in  varchar2  default null,
  p_val_80                         in  varchar2  default null,
  p_val_81                         in  varchar2  default null,
  p_val_82                         in  varchar2  default null,
  p_val_83                         in  varchar2  default null,
  p_val_84                         in  varchar2  default null,
  p_val_85                         in  varchar2  default null,
  p_val_86                         in  varchar2  default null,
  p_val_87                         in  varchar2  default null,
  p_val_88                         in  varchar2  default null,
  p_val_89                         in  varchar2  default null,
  p_val_90                         in  varchar2  default null,
  p_val_91                         in  varchar2  default null,
  p_val_92                         in  varchar2  default null,
  p_val_93                         in  varchar2  default null,
  p_val_94                         in  varchar2  default null,
  p_val_95                         in  varchar2  default null,
  p_val_96                         in  varchar2  default null,
  p_val_97                         in  varchar2  default null,
  p_val_98                         in  varchar2  default null,
  p_val_99                         in  varchar2  default null,
  p_val_100                        in  varchar2  default null,
  p_val_101                         in  varchar2  default null,
  p_val_102                         in  varchar2  default null,
  p_val_103                         in  varchar2  default null,
  p_val_104                         in  varchar2  default null,
  p_val_105                         in  varchar2  default null,
  p_val_106                         in  varchar2  default null,
  p_val_107                         in  varchar2  default null,
  p_val_108                         in  varchar2  default null,
  p_val_109                         in  varchar2  default null,
  p_val_110                         in  varchar2  default null,
  p_val_111                         in  varchar2  default null,
  p_val_112                         in  varchar2  default null,
  p_val_113                         in  varchar2  default null,
  p_val_114                         in  varchar2  default null,
  p_val_115                         in  varchar2  default null,
  p_val_116                         in  varchar2  default null,
  p_val_117                         in  varchar2  default null,
  p_val_119                         in  varchar2  default null,
  p_val_118                         in  varchar2  default null,
  p_val_120                         in  varchar2  default null,
  p_val_121                         in  varchar2  default null,
  p_val_122                         in  varchar2  default null,
  p_val_123                         in  varchar2  default null,
  p_val_124                         in  varchar2  default null,
  p_val_125                         in  varchar2  default null,
  p_val_126                         in  varchar2  default null,
  p_val_127                         in  varchar2  default null,
  p_val_128                         in  varchar2  default null,
  p_val_129                         in  varchar2  default null,
  p_val_130                         in  varchar2  default null,
  p_val_131                         in  varchar2  default null,
  p_val_132                         in  varchar2  default null,
  p_val_133                         in  varchar2  default null,
  p_val_134                         in  varchar2  default null,
  p_val_135                         in  varchar2  default null,
  p_val_136                         in  varchar2  default null,
  p_val_137                         in  varchar2  default null,
  p_val_138                         in  varchar2  default null,
  p_val_139                         in  varchar2  default null,
  p_val_140                         in  varchar2  default null,
  p_val_141                         in  varchar2  default null,
  p_val_142                         in  varchar2  default null,
  p_val_143                         in  varchar2  default null,
  p_val_144                         in  varchar2  default null,
  p_val_145                         in  varchar2  default null,
  p_val_146                         in  varchar2  default null,
  p_val_147                         in  varchar2  default null,
  p_val_148                         in  varchar2  default null,
  p_val_149                         in  varchar2  default null,
  p_val_150                         in  varchar2  default null,
  p_val_151                         in  varchar2  default null,
  p_val_152                         in  varchar2  default null,
  p_val_153                         in  varchar2  default null,
  p_val_154                         in  varchar2  default null,
  p_val_155                         in  varchar2  default null,
  p_val_156                         in  varchar2  default null,
  p_val_157                         in  varchar2  default null,
  p_val_158                         in  varchar2  default null,
  p_val_159                         in  varchar2  default null,
  p_val_160                         in  varchar2  default null,
  p_val_161                         in  varchar2  default null,
  p_val_162                         in  varchar2  default null,
  p_val_163                         in  varchar2  default null,
  p_val_164                         in  varchar2  default null,
  p_val_165                         in  varchar2  default null,
  p_val_166                         in  varchar2  default null,
  p_val_167                         in  varchar2  default null,
  p_val_168                         in  varchar2  default null,
  p_val_169                         in  varchar2  default null,
  p_val_170                         in  varchar2  default null,
  p_val_171                         in  varchar2  default null,
  p_val_172                         in  varchar2  default null,
  p_val_173                         in  varchar2  default null,
  p_val_174                         in  varchar2  default null,
  p_val_175                         in  varchar2  default null,
  p_val_176                         in  varchar2  default null,
  p_val_177                         in  varchar2  default null,
  p_val_178                         in  varchar2  default null,
  p_val_179                         in  varchar2  default null,
  p_val_180                         in  varchar2  default null,
  p_val_181                         in  varchar2  default null,
  p_val_182                         in  varchar2  default null,
  p_val_183                         in  varchar2  default null,
  p_val_184                         in  varchar2  default null,
  p_val_185                         in  varchar2  default null,
  p_val_186                         in  varchar2  default null,
  p_val_187                         in  varchar2  default null,
  p_val_188                         in  varchar2  default null,
  p_val_189                         in  varchar2  default null,
  p_val_190                         in  varchar2  default null,
  p_val_191                         in  varchar2  default null,
  p_val_192                         in  varchar2  default null,
  p_val_193                         in  varchar2  default null,
  p_val_194                         in  varchar2  default null,
  p_val_195                         in  varchar2  default null,
  p_val_196                         in  varchar2  default null,
  p_val_197                         in  varchar2  default null,
  p_val_198                         in  varchar2  default null,
  p_val_199                         in  varchar2  default null,
  p_val_200                         in  varchar2  default null,
  p_val_201                         in  varchar2  default null,
  p_val_202                         in  varchar2  default null,
  p_val_203                         in  varchar2  default null,
  p_val_204                         in  varchar2  default null,
  p_val_205                         in  varchar2  default null,
  p_val_206                         in  varchar2  default null,
  p_val_207                         in  varchar2  default null,
  p_val_208                         in  varchar2  default null,
  p_val_209                         in  varchar2  default null,
  p_val_210                         in  varchar2  default null,
  p_val_211                         in  varchar2  default null,
  p_val_212                         in  varchar2  default null,
  p_val_213                         in  varchar2  default null,
  p_val_214                         in  varchar2  default null,
  p_val_215                         in  varchar2  default null,
  p_val_216                         in  varchar2  default null,
  p_val_217                         in  varchar2  default null,
  p_val_219                         in  varchar2  default null,
  p_val_218                         in  varchar2  default null,
  p_val_220                         in  varchar2  default null,
  p_val_221                         in  varchar2  default null,
  p_val_222                         in  varchar2  default null,
  p_val_223                         in  varchar2  default null,
  p_val_224                         in  varchar2  default null,
  p_val_225                         in  varchar2  default null,
  p_val_226                         in  varchar2  default null,
  p_val_227                         in  varchar2  default null,
  p_val_228                         in  varchar2  default null,
  p_val_229                         in  varchar2  default null,
  p_val_230                         in  varchar2  default null,
  p_val_231                         in  varchar2  default null,
  p_val_232                         in  varchar2  default null,
  p_val_233                         in  varchar2  default null,
  p_val_234                         in  varchar2  default null,
  p_val_235                         in  varchar2  default null,
  p_val_236                         in  varchar2  default null,
  p_val_237                         in  varchar2  default null,
  p_val_238                         in  varchar2  default null,
  p_val_239                         in  varchar2  default null,
  p_val_240                         in  varchar2  default null,
  p_val_241                         in  varchar2  default null,
  p_val_242                         in  varchar2  default null,
  p_val_243                         in  varchar2  default null,
  p_val_244                         in  varchar2  default null,
  p_val_245                         in  varchar2  default null,
  p_val_246                         in  varchar2  default null,
  p_val_247                         in  varchar2  default null,
  p_val_248                         in  varchar2  default null,
  p_val_249                         in  varchar2  default null,
  p_val_250                         in  varchar2  default null,
  p_val_251                         in  varchar2  default null,
  p_val_252                         in  varchar2  default null,
  p_val_253                         in  varchar2  default null,
  p_val_254                         in  varchar2  default null,
  p_val_255                         in  varchar2  default null,
  p_val_256                         in  varchar2  default null,
  p_val_257                         in  varchar2  default null,
  p_val_258                         in  varchar2  default null,
  p_val_259                         in  varchar2  default null,
  p_val_260                         in  varchar2  default null,
  p_val_261                         in  varchar2  default null,
  p_val_262                         in  varchar2  default null,
  p_val_263                         in  varchar2  default null,
  p_val_264                         in  varchar2  default null,
  p_val_265                         in  varchar2  default null,
  p_val_266                         in  varchar2  default null,
  p_val_267                         in  varchar2  default null,
  p_val_268                         in  varchar2  default null,
  p_val_269                         in  varchar2  default null,
  p_val_270                         in  varchar2  default null,
  p_val_271                         in  varchar2  default null,
  p_val_272                         in  varchar2  default null,
  p_val_273                         in  varchar2  default null,
  p_val_274                         in  varchar2  default null,
  p_val_275                         in  varchar2  default null,
  p_val_276                         in  varchar2  default null,
  p_val_277                         in  varchar2  default null,
  p_val_278                         in  varchar2  default null,
  p_val_279                         in  varchar2  default null,
  p_val_280                         in  varchar2  default null,
  p_val_281                         in  varchar2  default null,
  p_val_282                         in  varchar2  default null,
  p_val_283                         in  varchar2  default null,
  p_val_284                         in  varchar2  default null,
  p_val_285                         in  varchar2  default null,
  p_val_286                         in  varchar2  default null,
  p_val_287                         in  varchar2  default null,
  p_val_288                         in  varchar2  default null,
  p_val_289                         in  varchar2  default null,
  p_val_290                         in  varchar2  default null,
  p_val_291                         in  varchar2  default null,
  p_val_292                         in  varchar2  default null,
  p_val_293                         in  varchar2  default null,
  p_val_294                         in  varchar2  default null,
  p_val_295                         in  varchar2  default null,
  p_val_296                         in  varchar2  default null,
  p_val_297                         in  varchar2  default null,
  p_val_298                         in  varchar2  default null,
  p_val_299                         in  varchar2  default null,
  p_val_300                         in  varchar2  default null,
  p_group_val_01                    in  varchar2  default null,
  p_group_val_02                    in  varchar2  default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_request_id                   in number           default null,
  p_object_version_number        out nocopy number               ,
  p_ext_rcd_in_file_id         in number           default null
  );
--
end ben_xrd_ins;

 

/
