--------------------------------------------------------
--  DDL for Package BEN_XRD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XRD_SHD" AUTHID CURRENT_USER as
/* $Header: bexrdrhi.pkh 120.0 2005/05/28 12:39:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--

Type g_rec_type Is Record
  (
  ext_rslt_dtl_id                   number(15),
  prmy_sort_val                     varchar2(600),
  scnd_sort_val                     varchar2(600),
  thrd_sort_val                     varchar2(600),
  trans_seq_num                     number(15),
  rcrd_seq_num                      number(15),
  ext_rslt_id                       number(15),
  ext_rcd_id                        number(15),
  person_id                         number(15),
  business_group_id                 number(15),
  ext_per_bg_id                   number(15),
  val_01                            varchar2(600),
  val_02                            varchar2(600),
  val_03                            varchar2(600),
  val_04                            varchar2(600),
  val_05                            varchar2(600),
  val_06                            varchar2(600),
  val_07                            varchar2(600),
  val_08                            varchar2(600),
  val_09                            varchar2(600),
  val_10                            varchar2(600),
  val_11                            varchar2(600),
  val_12                            varchar2(600),
  val_13                            varchar2(600),
  val_14                            varchar2(600),
  val_15                            varchar2(600),
  val_16                            varchar2(600),
  val_17                            varchar2(600),
  val_19                            varchar2(600),
  val_18                            varchar2(600),
  val_20                            varchar2(600),
  val_21                            varchar2(600),
  val_22                            varchar2(600),
  val_23                            varchar2(600),
  val_24                            varchar2(600),
  val_25                            varchar2(600),
  val_26                            varchar2(600),
  val_27                            varchar2(600),
  val_28                            varchar2(600),
  val_29                            varchar2(600),
  val_30                            varchar2(600),
  val_31                            varchar2(600),
  val_32                            varchar2(600),
  val_33                            varchar2(600),
  val_34                            varchar2(600),
  val_35                            varchar2(600),
  val_36                            varchar2(600),
  val_37                            varchar2(600),
  val_38                            varchar2(600),
  val_39                            varchar2(600),
  val_40                            varchar2(600),
  val_41                            varchar2(600),
  val_42                            varchar2(600),
  val_43                            varchar2(600),
  val_44                            varchar2(600),
  val_45                            varchar2(600),
  val_46                            varchar2(600),
  val_47                            varchar2(600),
  val_48                            varchar2(600),
  val_49                            varchar2(600),
  val_50                            varchar2(600),
  val_51                            varchar2(600),
  val_52                            varchar2(600),
  val_53                            varchar2(600),
  val_54                            varchar2(600),
  val_55                            varchar2(600),
  val_56                            varchar2(600),
  val_57                            varchar2(600),
  val_58                            varchar2(600),
  val_59                            varchar2(600),
  val_60                            varchar2(600),
  val_61                            varchar2(600),
  val_62                            varchar2(600),
  val_63                            varchar2(600),
  val_64                            varchar2(600),
  val_65                            varchar2(600),
  val_66                            varchar2(600),
  val_67                            varchar2(600),
  val_68                            varchar2(600),
  val_69                            varchar2(600),
  val_70                            varchar2(600),
  val_71                            varchar2(600),
  val_72                            varchar2(600),
  val_73                            varchar2(600),
  val_74                            varchar2(600),
  val_75                            varchar2(600),
  val_76                            varchar2(600),
  val_77                            varchar2(600),
  val_78                            varchar2(600),
  val_79                            varchar2(600),
  val_80                            varchar2(600),
  val_81                            varchar2(600),
  val_82                            varchar2(600),
  val_83                            varchar2(600),
  val_84                            varchar2(600),
  val_85                            varchar2(600),
  val_86                            varchar2(600),
  val_87                            varchar2(600),
  val_88                            varchar2(600),
  val_89                            varchar2(600),
  val_90                            varchar2(600),
  val_91                            varchar2(600),
  val_92                            varchar2(600),
  val_93                            varchar2(600),
  val_94                            varchar2(600),
  val_95                            varchar2(600),
  val_96                            varchar2(600),
  val_97                            varchar2(600),
  val_98                            varchar2(600),
  val_99                            varchar2(600),
  val_100                           varchar2(600),
  val_101                            varchar2(600),
  val_102                            varchar2(600),
  val_103                            varchar2(600),
  val_104                            varchar2(600),
  val_105                            varchar2(600),
  val_106                            varchar2(600),
  val_107                            varchar2(600),
  val_108                            varchar2(600),
  val_109                            varchar2(600),
  val_110                            varchar2(600),
  val_111                            varchar2(600),
  val_112                            varchar2(600),
  val_113                            varchar2(600),
  val_114                            varchar2(600),
  val_115                            varchar2(600),
  val_116                            varchar2(600),
  val_117                            varchar2(600),
  val_119                            varchar2(600),
  val_118                            varchar2(600),
  val_120                            varchar2(600),
  val_121                            varchar2(600),
  val_122                            varchar2(600),
  val_123                            varchar2(600),
  val_124                            varchar2(600),
  val_125                            varchar2(600),
  val_126                            varchar2(600),
  val_127                            varchar2(600),
  val_128                            varchar2(600),
  val_129                            varchar2(600),
  val_130                            varchar2(600),
  val_131                            varchar2(600),
  val_132                            varchar2(600),
  val_133                            varchar2(600),
  val_134                            varchar2(600),
  val_135                            varchar2(600),
  val_136                            varchar2(600),
  val_137                            varchar2(600),
  val_138                            varchar2(600),
  val_139                            varchar2(600),
  val_140                            varchar2(600),
  val_141                            varchar2(600),
  val_142                            varchar2(600),
  val_143                            varchar2(600),
  val_144                            varchar2(600),
  val_145                            varchar2(600),
  val_146                            varchar2(600),
  val_147                            varchar2(600),
  val_148                            varchar2(600),
  val_149                            varchar2(600),
  val_150                            varchar2(600),
  val_151                            varchar2(600),
  val_152                            varchar2(600),
  val_153                            varchar2(600),
  val_154                            varchar2(600),
  val_155                            varchar2(600),
  val_156                            varchar2(600),
  val_157                            varchar2(600),
  val_158                            varchar2(600),
  val_159                            varchar2(600),
  val_160                            varchar2(600),
  val_161                            varchar2(600),
  val_162                            varchar2(600),
  val_163                            varchar2(600),
  val_164                            varchar2(600),
  val_165                            varchar2(600),
  val_166                            varchar2(600),
  val_167                            varchar2(600),
  val_168                            varchar2(600),
  val_169                            varchar2(600),
  val_170                            varchar2(600),
  val_171                            varchar2(600),
  val_172                            varchar2(600),
  val_173                            varchar2(600),
  val_174                            varchar2(600),
  val_175                            varchar2(600),
  val_176                            varchar2(600),
  val_177                            varchar2(600),
  val_178                            varchar2(600),
  val_179                            varchar2(600),
  val_180                            varchar2(600),
  val_181                            varchar2(600),
  val_182                            varchar2(600),
  val_183                            varchar2(600),
  val_184                            varchar2(600),
  val_185                            varchar2(600),
  val_186                            varchar2(600),
  val_187                            varchar2(600),
  val_188                            varchar2(600),
  val_189                            varchar2(600),
  val_190                            varchar2(600),
  val_191                            varchar2(600),
  val_192                            varchar2(600),
  val_193                            varchar2(600),
  val_194                            varchar2(600),
  val_195                            varchar2(600),
  val_196                            varchar2(600),
  val_197                            varchar2(600),
  val_198                            varchar2(600),
  val_199                            varchar2(600),
  val_200                            varchar2(600),
  val_201                            varchar2(600),
  val_202                            varchar2(600),
  val_203                            varchar2(600),
  val_204                            varchar2(600),
  val_205                            varchar2(600),
  val_206                            varchar2(600),
  val_207                            varchar2(600),
  val_208                            varchar2(600),
  val_209                            varchar2(600),
  val_210                            varchar2(600),
  val_211                            varchar2(600),
  val_212                            varchar2(600),
  val_213                            varchar2(600),
  val_214                            varchar2(600),
  val_215                            varchar2(600),
  val_216                            varchar2(600),
  val_217                            varchar2(600),
  val_219                            varchar2(600),
  val_218                            varchar2(600),
  val_220                            varchar2(600),
  val_221                            varchar2(600),
  val_222                            varchar2(600),
  val_223                            varchar2(600),
  val_224                            varchar2(600),
  val_225                            varchar2(600),
  val_226                            varchar2(600),
  val_227                            varchar2(600),
  val_228                            varchar2(600),
  val_229                            varchar2(600),
  val_230                            varchar2(600),
  val_231                            varchar2(600),
  val_232                            varchar2(600),
  val_233                            varchar2(600),
  val_234                            varchar2(600),
  val_235                            varchar2(600),
  val_236                            varchar2(600),
  val_237                            varchar2(600),
  val_238                            varchar2(600),
  val_239                            varchar2(600),
  val_240                            varchar2(600),
  val_241                            varchar2(600),
  val_242                            varchar2(600),
  val_243                            varchar2(600),
  val_244                            varchar2(600),
  val_245                            varchar2(600),
  val_246                            varchar2(600),
  val_247                            varchar2(600),
  val_248                            varchar2(600),
  val_249                            varchar2(600),
  val_250                            varchar2(600),
  val_251                            varchar2(600),
  val_252                            varchar2(600),
  val_253                            varchar2(600),
  val_254                            varchar2(600),
  val_255                            varchar2(600),
  val_256                            varchar2(600),
  val_257                            varchar2(600),
  val_258                            varchar2(600),
  val_259                            varchar2(600),
  val_260                            varchar2(600),
  val_261                            varchar2(600),
  val_262                            varchar2(600),
  val_263                            varchar2(600),
  val_264                            varchar2(600),
  val_265                            varchar2(600),
  val_266                            varchar2(600),
  val_267                            varchar2(600),
  val_268                            varchar2(600),
  val_269                            varchar2(600),
  val_270                            varchar2(600),
  val_271                            varchar2(600),
  val_272                            varchar2(600),
  val_273                            varchar2(600),
  val_274                            varchar2(600),
  val_275                            varchar2(600),
  val_276                            varchar2(600),
  val_277                            varchar2(600),
  val_278                            varchar2(600),
  val_279                            varchar2(600),
  val_280                            varchar2(600),
  val_281                            varchar2(600),
  val_282                            varchar2(600),
  val_283                            varchar2(600),
  val_284                            varchar2(600),
  val_285                            varchar2(600),
  val_286                            varchar2(600),
  val_287                            varchar2(600),
  val_288                            varchar2(600),
  val_289                            varchar2(600),
  val_290                            varchar2(600),
  val_291                            varchar2(600),
  val_292                            varchar2(600),
  val_293                            varchar2(600),
  val_294                            varchar2(600),
  val_295                            varchar2(600),
  val_296                            varchar2(600),
  val_297                            varchar2(600),
  val_298                            varchar2(600),
  val_299                            varchar2(600),
  val_300                            varchar2(600),
  group_val_01                       varchar2(600),
  group_val_02                       varchar2(600),
  program_application_id            number(15),
  program_id                        number(15),
  program_update_date               date,
  request_id                        number(15),
  object_version_number             number(9) ,
  ext_rcd_in_file_id                number(15)
  );
--



--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Prerequisites:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which corresponds with a constraint error.
--
-- In Parameter:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_ext_rslt_dtl_id                    in number,
  p_object_version_number              in number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Prerequisites:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Parameters:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_ext_rslt_dtl_id                    in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute parameters into the record
--   structure parameter g_rec_type.
--
-- Prerequisites:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Parameters:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
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
	p_ext_per_bg_id                 in number,
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
      p_group_val_02                   in  varchar2,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_request_id                    in number,
	p_object_version_number         in number,
        p_ext_rcd_in_file_id            in number
	)
	Return g_rec_type;
--
end ben_xrd_shd;

 

/
