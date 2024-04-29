--------------------------------------------------------
--  DDL for Package BEN_CPE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPE_SHD" AUTHID CURRENT_USER as
/* $Header: becperhi.pkh 120.0 2005/05/28 01:12:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (copy_entity_result_id           number(15)
  ,copy_entity_txn_id              number(15)
  ,src_copy_entity_result_id       number(15)
  ,result_type_cd                  varchar2(30)
  ,number_of_copies                number(10)
  ,mirror_entity_result_id         number(15)
  ,mirror_src_entity_result_id     number(15)
  ,parent_entity_result_id         number(15)
  ,pd_mirror_src_entity_result_id  number(15)
  ,pd_parent_entity_result_id      number(15)
  ,gs_mirror_src_entity_result_id  number(15)
  ,gs_parent_entity_result_id      number(15)
  ,table_name                      varchar2(30)
  ,table_alias                     varchar2(30)
  ,table_route_id                  number(15)
  ,status                          varchar2(30)
  ,dml_operation                   varchar2(30)
  ,information_category            varchar2(30)
  ,information1                    number(15)
  ,information2                    date
  ,information3                    date
  ,information4                    number(15)
  ,information5                    varchar2(600)
  ,information6                    varchar2(240)
  ,information7                    varchar2(240)
  ,information8                    varchar2(30)
  ,information9                    varchar2(240)
  ,information10                   date
  ,information11                   varchar2(30)
  ,information12                   varchar2(30)
  ,information13                   varchar2(30)
  ,information14                   varchar2(30)
  ,information15                   varchar2(30)
  ,information16                   varchar2(30)
  ,information17                   varchar2(30)
  ,information18                   varchar2(30)
  ,information19                   varchar2(30)
  ,information20                   varchar2(30)
  ,information21                   varchar2(30)
  ,information22                   varchar2(30)
  ,information23                   varchar2(30)
  ,information24                   varchar2(30)
  ,information25                   varchar2(30)
  ,information26                   varchar2(30)
  ,information27                   varchar2(30)
  ,information28                   varchar2(30)
  ,information29                   varchar2(30)
  ,information30                   varchar2(30)
  ,information31                   varchar2(30)
  ,information32                   varchar2(30)
  ,information33                   varchar2(30)
  ,information34                   varchar2(30)
  ,information35                   varchar2(30)
  ,information36                   varchar2(30)
  ,information37                   varchar2(30)
  ,information38                   varchar2(30)
  ,information39                   varchar2(30)
  ,information40                   varchar2(30)
  ,information41                   varchar2(30)
  ,information42                   varchar2(30)
  ,information43                   varchar2(30)
  ,information44                   varchar2(30)
  ,information45                   varchar2(30)
  ,information46                   varchar2(30)
  ,information47                   varchar2(30)
  ,information48                   varchar2(30)
  ,information49                   varchar2(30)
  ,information50                   varchar2(30)
  ,information51                   varchar2(30)
  ,information52                   varchar2(30)
  ,information53                   varchar2(30)
  ,information54                   varchar2(30)
  ,information55                   varchar2(30)
  ,information56                   varchar2(30)
  ,information57                   varchar2(30)
  ,information58                   varchar2(30)
  ,information59                   varchar2(30)
  ,information60                   varchar2(30)
  ,information61                   varchar2(30)
  ,information62                   varchar2(30)
  ,information63                   varchar2(30)
  ,information64                   varchar2(30)
  ,information65                   varchar2(30)
  ,information66                   varchar2(30)
  ,information67                   varchar2(30)
  ,information68                   varchar2(30)
  ,information69                   varchar2(30)
  ,information70                   varchar2(30)
  ,information71                   varchar2(30)
  ,information72                   varchar2(30)
  ,information73                   varchar2(30)
  ,information74                   varchar2(30)
  ,information75                   varchar2(30)
  ,information76                   varchar2(30)
  ,information77                   varchar2(30)
  ,information78                   varchar2(30)
  ,information79                   varchar2(30)
  ,information80                   varchar2(30)
  ,information81                   varchar2(30)
  ,information82                   varchar2(30)
  ,information83                   varchar2(30)
  ,information84                   varchar2(30)
  ,information85                   varchar2(30)
  ,information86                   varchar2(30)
  ,information87                   varchar2(30)
  ,information88                   varchar2(30)
  ,information89                   varchar2(30)
  ,information90                   varchar2(30)
  ,information91                   varchar2(30)
  ,information92                   varchar2(30)
  ,information93                   varchar2(30)
  ,information94                   varchar2(30)
  ,information95                   varchar2(30)
  ,information96                   varchar2(30)
  ,information97                   varchar2(30)
  ,information98                   varchar2(30)
  ,information99                   varchar2(30)
  ,information100                  varchar2(30)
  ,information101                  varchar2(30)
  ,information102                  varchar2(30)
  ,information103                  varchar2(30)
  ,information104                  varchar2(30)
  ,information105                  varchar2(30)
  ,information106                  varchar2(30)
  ,information107                  varchar2(30)
  ,information108                  varchar2(30)
  ,information109                  varchar2(30)
  ,information110                  varchar2(30)
  ,information111                  varchar2(150)
  ,information112                  varchar2(150)
  ,information113                  varchar2(150)
  ,information114                  varchar2(150)
  ,information115                  varchar2(150)
  ,information116                  varchar2(150)
  ,information117                  varchar2(150)
  ,information118                  varchar2(150)
  ,information119                  varchar2(150)
  ,information120                  varchar2(150)
  ,information121                  varchar2(150)
  ,information122                  varchar2(150)
  ,information123                  varchar2(150)
  ,information124                  varchar2(150)
  ,information125                  varchar2(150)
  ,information126                  varchar2(150)
  ,information127                  varchar2(150)
  ,information128                  varchar2(150)
  ,information129                  varchar2(150)
  ,information130                  varchar2(150)
  ,information131                  varchar2(150)
  ,information132                  varchar2(150)
  ,information133                  varchar2(150)
  ,information134                  varchar2(150)
  ,information135                  varchar2(150)
  ,information136                  varchar2(150)
  ,information137                  varchar2(150)
  ,information138                  varchar2(150)
  ,information139                  varchar2(150)
  ,information140                  varchar2(150)
  ,information141                  varchar2(150)
  ,information142                  varchar2(150)

  /* Extra Reserved Columns
  ,information143                  varchar2(150)
  ,information144                  varchar2(150)
  ,information145                  varchar2(150)
  ,information146                  varchar2(150)
  ,information147                  varchar2(150)
  ,information148                  varchar2(150)
  ,information149                  varchar2(150)
  ,information150                  varchar2(150)
  */
  ,information151                  varchar2(240)
  ,information152                  varchar2(240)
  ,information153                  varchar2(240)

  /* Extra Reserved Columns
  ,information154                  varchar2(240)
  ,information155                  varchar2(240)
  ,information156                  varchar2(240)
  ,information157                  varchar2(240)
  ,information158                  varchar2(240)
  ,information159                  varchar2(240)
  */
  ,information160                  number(15)
  ,information161                  number(15)
  ,information162                  number(15)

  /* Extra Reserved Columns
  ,information163                  number(15)
  ,information164                  number(15)
  ,information165                  number(15)
  */
  ,information166                  date
  ,information167                  date
  ,information168                  date
  ,information169                  number(15)
  ,information170                  varchar2(240)

  /* Extra Reserved Columns
  ,information171                  varchar2(240)
  ,information172                  varchar2(240)
  */
  ,information173                  varchar2(240)
  ,information174                  number(15)
  ,information175                  varchar2(240)
  ,information176                  number(15)
  ,information177                  varchar2(240)
  ,information178                  number(15)
  ,information179                  varchar2(240)
  ,information180                  number(15)
  ,information181                  varchar2(240)
  ,information182                  varchar2(240)

  /* Extra Reserved Columns
  ,information183                  varchar2(240)
  ,information184                  varchar2(240)
  */
  ,information185                  varchar2(240)
  ,information186                  varchar2(240)
  ,information187                  varchar2(240)
  ,information188                  varchar2(240)

  /* Extra Reserved Columns
  ,information189                  varchar2(240)
  */
  ,information190                  varchar2(240)
  ,information191                  varchar2(240)
  ,information192                  varchar2(240)
  ,information193                  varchar2(240)
  ,information194                  varchar2(240)
  ,information195                  varchar2(240)
  ,information196                  varchar2(240)
  ,information197                  varchar2(240)
  ,information198                  varchar2(240)
  ,information199                  varchar2(240)

  /* Extra Reserved Columns
  ,information200                  varchar2(240)
  ,information201                  varchar2(240)
  ,information202                  varchar2(240)
  ,information203                  varchar2(240)
  ,information204                  varchar2(240)
  ,information205                  varchar2(240)
  ,information206                  varchar2(240)
  ,information207                  varchar2(240)
  ,information208                  varchar2(240)
  ,information209                  varchar2(240)
  ,information210                  varchar2(240)
  ,information211                  varchar2(240)
  ,information212                  varchar2(240)
  ,information213                  varchar2(240)
  ,information214                  varchar2(240)
  ,information215                  varchar2(240)
  */
  ,information216                  varchar2(600)
  ,information217                  varchar2(600)
  ,information218                  varchar2(600)
  ,information219                  varchar2(2000)
  ,information220                  varchar2(2000)
  ,information221                  number(15)
  ,information222                  number(15)
  ,information223                  number(15)
  ,information224                  number(15)
  ,information225                  number(15)
  ,information226                  number(15)
  ,information227                  number(15)
  ,information228                  number(15)
  ,information229                  number(15)
  ,information230                  number(15)
  ,information231                  number(15)
  ,information232                  number(15)
  ,information233                  number(15)
  ,information234                  number(15)
  ,information235                  number(15)
  ,information236                  number(15)
  ,information237                  number(15)
  ,information238                  number(15)
  ,information239                  number(15)
  ,information240                  number(15)
  ,information241                  number(15)
  ,information242                  number(15)
  ,information243                  number(15)
  ,information244                  number(15)
  ,information245                  number(15)
  ,information246                  number(15)
  ,information247                  number(15)
  ,information248                  number(15)
  ,information249                  number(15)
  ,information250                  number(15)
  ,information251                  number(15)
  ,information252                  number(15)
  ,information253                  number(15)
  ,information254                  number(15)
  ,information255                  number(15)
  ,information256                  number(15)
  ,information257                  number(15)
  ,information258                  number(15)
  ,information259                  number(15)
  ,information260                  number(15)
  ,information261                  number(15)
  ,information262                  number(15)
  ,information263                  number(15)
  ,information264                  number(15)
  ,information265                  number(15)
  ,information266                  number(15)
  ,information267                  number(15)
  ,information268                  number(15)
  ,information269                  number(15)
  ,information270                  number(15)
  ,information271                  number(15)
  ,information272                  number(15)
  ,information273                  number(15)
  ,information274                  number(15)
  ,information275                  number(15)
  ,information276                  number(15)
  ,information277                  number(15)
  ,information278                  number(15)
  ,information279                  number(15)
  ,information280                  number(15)
  ,information281                  number(15)
  ,information282                  number(15)
  ,information283                  number(15)
  ,information284                  number(15)
  ,information285                  number(15)
  ,information286                  number(15)
  ,information287                  number(22,9)
  ,information288                  number(22,9)
  ,information289                  number(22,9)
  ,information290                  number(22,9)
  ,information291                  number(22,9)
  ,information292                  number(22,9)
  ,information293                  number(38,15)
  ,information294                  number(38,15)
  ,information295                  number(38,15)
  ,information296                  number(38,15)
  ,information297                  number(38,15)
  ,information298                  number(38,15)
  ,information299                  number(38,15)
  ,information300                  number(38,15)
  ,information301                  number(38,15)
  ,information302                  number(38,15)
  ,information303                  number(38,15)
  ,information304                  number(38,15)

  /* Extra Reserved Columns
  ,information305                  number(38,15)
  */
  ,information306                  date
  ,information307                  date
  ,information308                  date
  ,information309                  date
  ,information310                  date
  ,information311                  date
  ,information312                  date
  ,information313                  date
  ,information314                  date
  ,information315                  date
  ,information316                  date
  ,information317                  date
  ,information318                  date
  ,information319                  date
  ,information320                  date

  /* Extra Reserved Columns
  ,information321                  date
  ,information322                  date
  */
  ,information323                  long
  ,datetrack_mode                  varchar2(30)
  ,object_version_number           number(9)
  -- ,datetrack_mode                  varchar2(30)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
-- Global table name
g_tab_nam  constant varchar2(30) := 'BEN_COPY_ENTITY_RESULTS';
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
--  {Start Of Comments}
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
  (p_copy_entity_result_id                in     number
  ,p_object_version_number                in     number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from
--   the server to be available to the api.
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
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (p_copy_entity_result_id                in     number
  ,p_object_version_number                in     number
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
--   No direct error handling is required within this function.  Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
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
  (p_copy_entity_result_id          in number
  ,p_copy_entity_txn_id             in number
  ,p_src_copy_entity_result_id      in number
  ,p_result_type_cd                 in varchar2
  ,p_number_of_copies               in number
  ,p_mirror_entity_result_id        in number
  ,p_mirror_src_entity_result_id    in number
  ,p_parent_entity_result_id        in number
  ,p_pd_mr_src_entity_result_id     in number
  ,p_pd_parent_entity_result_id     in number
  ,p_gs_mr_src_entity_result_id     in number
  ,p_gs_parent_entity_result_id     in number
  ,p_table_name                     in varchar2
  ,p_table_alias                    in varchar2
  ,p_table_route_id                 in number
  ,p_status                         in varchar2
  ,p_dml_operation                  in varchar2
  ,p_information_category           in varchar2
  ,p_information1                   in number
  ,p_information2                   in date
  ,p_information3                   in date
  ,p_information4                   in number
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in date
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
  ,p_information31                  in varchar2
  ,p_information32                  in varchar2
  ,p_information33                  in varchar2
  ,p_information34                  in varchar2
  ,p_information35                  in varchar2
  ,p_information36                  in varchar2
  ,p_information37                  in varchar2
  ,p_information38                  in varchar2
  ,p_information39                  in varchar2
  ,p_information40                  in varchar2
  ,p_information41                  in varchar2
  ,p_information42                  in varchar2
  ,p_information43                  in varchar2
  ,p_information44                  in varchar2
  ,p_information45                  in varchar2
  ,p_information46                  in varchar2
  ,p_information47                  in varchar2
  ,p_information48                  in varchar2
  ,p_information49                  in varchar2
  ,p_information50                  in varchar2
  ,p_information51                  in varchar2
  ,p_information52                  in varchar2
  ,p_information53                  in varchar2
  ,p_information54                  in varchar2
  ,p_information55                  in varchar2
  ,p_information56                  in varchar2
  ,p_information57                  in varchar2
  ,p_information58                  in varchar2
  ,p_information59                  in varchar2
  ,p_information60                  in varchar2
  ,p_information61                  in varchar2
  ,p_information62                  in varchar2
  ,p_information63                  in varchar2
  ,p_information64                  in varchar2
  ,p_information65                  in varchar2
  ,p_information66                  in varchar2
  ,p_information67                  in varchar2
  ,p_information68                  in varchar2
  ,p_information69                  in varchar2
  ,p_information70                  in varchar2
  ,p_information71                  in varchar2
  ,p_information72                  in varchar2
  ,p_information73                  in varchar2
  ,p_information74                  in varchar2
  ,p_information75                  in varchar2
  ,p_information76                  in varchar2
  ,p_information77                  in varchar2
  ,p_information78                  in varchar2
  ,p_information79                  in varchar2
  ,p_information80                  in varchar2
  ,p_information81                  in varchar2
  ,p_information82                  in varchar2
  ,p_information83                  in varchar2
  ,p_information84                  in varchar2
  ,p_information85                  in varchar2
  ,p_information86                  in varchar2
  ,p_information87                  in varchar2
  ,p_information88                  in varchar2
  ,p_information89                  in varchar2
  ,p_information90                  in varchar2
  ,p_information91                  in varchar2
  ,p_information92                  in varchar2
  ,p_information93                  in varchar2
  ,p_information94                  in varchar2
  ,p_information95                  in varchar2
  ,p_information96                  in varchar2
  ,p_information97                  in varchar2
  ,p_information98                  in varchar2
  ,p_information99                  in varchar2
  ,p_information100                 in varchar2
  ,p_information101                 in varchar2
  ,p_information102                 in varchar2
  ,p_information103                 in varchar2
  ,p_information104                 in varchar2
  ,p_information105                 in varchar2
  ,p_information106                 in varchar2
  ,p_information107                 in varchar2
  ,p_information108                 in varchar2
  ,p_information109                 in varchar2
  ,p_information110                 in varchar2
  ,p_information111                 in varchar2
  ,p_information112                 in varchar2
  ,p_information113                 in varchar2
  ,p_information114                 in varchar2
  ,p_information115                 in varchar2
  ,p_information116                 in varchar2
  ,p_information117                 in varchar2
  ,p_information118                 in varchar2
  ,p_information119                 in varchar2
  ,p_information120                 in varchar2
  ,p_information121                 in varchar2
  ,p_information122                 in varchar2
  ,p_information123                 in varchar2
  ,p_information124                 in varchar2
  ,p_information125                 in varchar2
  ,p_information126                 in varchar2
  ,p_information127                 in varchar2
  ,p_information128                 in varchar2
  ,p_information129                 in varchar2
  ,p_information130                 in varchar2
  ,p_information131                 in varchar2
  ,p_information132                 in varchar2
  ,p_information133                 in varchar2
  ,p_information134                 in varchar2
  ,p_information135                 in varchar2
  ,p_information136                 in varchar2
  ,p_information137                 in varchar2
  ,p_information138                 in varchar2
  ,p_information139                 in varchar2
  ,p_information140                 in varchar2
  ,p_information141                 in varchar2
  ,p_information142                 in varchar2

  /* Extra Reserved Columns
  ,p_information143                 in varchar2
  ,p_information144                 in varchar2
  ,p_information145                 in varchar2
  ,p_information146                 in varchar2
  ,p_information147                 in varchar2
  ,p_information148                 in varchar2
  ,p_information149                 in varchar2
  ,p_information150                 in varchar2
  */
  ,p_information151                 in varchar2
  ,p_information152                 in varchar2
  ,p_information153                 in varchar2

  /* Extra Reserved Columns
  ,p_information154                 in varchar2
  ,p_information155                 in varchar2
  ,p_information156                 in varchar2
  ,p_information157                 in varchar2
  ,p_information158                 in varchar2
  ,p_information159                 in varchar2
  */
  ,p_information160                 in number
  ,p_information161                 in number
  ,p_information162                 in number

  /* Extra Reserved Columns
  ,p_information163                 in number
  ,p_information164                 in number
  ,p_information165                 in number
  */
  ,p_information166                 in date
  ,p_information167                 in date
  ,p_information168                 in date
  ,p_information169                 in number
  ,p_information170                 in varchar2

  /* Extra Reserved Columns
  ,p_information171                 in varchar2
  ,p_information172                 in varchar2
  */
  ,p_information173                 in varchar2
  ,p_information174                 in number
  ,p_information175                 in varchar2
  ,p_information176                 in number
  ,p_information177                 in varchar2
  ,p_information178                 in number
  ,p_information179                 in varchar2
  ,p_information180                 in number
  ,p_information181                 in varchar2
  ,p_information182                 in varchar2

  /* Extra Reserved Columns
  ,p_information183                 in varchar2
  ,p_information184                 in varchar2
  */
  ,p_information185                 in varchar2
  ,p_information186                 in varchar2
  ,p_information187                 in varchar2
  ,p_information188                 in varchar2

  /* Extra Reserved Columns
  ,p_information189                 in varchar2
  */
  ,p_information190                 in varchar2
  ,p_information191                 in varchar2
  ,p_information192                 in varchar2
  ,p_information193                 in varchar2
  ,p_information194                 in varchar2
  ,p_information195                 in varchar2
  ,p_information196                 in varchar2
  ,p_information197                 in varchar2
  ,p_information198                 in varchar2
  ,p_information199                 in varchar2

  /* Extra Reserved Columns
  ,p_information200                 in varchar2
  ,p_information201                 in varchar2
  ,p_information202                 in varchar2
  ,p_information203                 in varchar2
  ,p_information204                 in varchar2
  ,p_information205                 in varchar2
  ,p_information206                 in varchar2
  ,p_information207                 in varchar2
  ,p_information208                 in varchar2
  ,p_information209                 in varchar2
  ,p_information210                 in varchar2
  ,p_information211                 in varchar2
  ,p_information212                 in varchar2
  ,p_information213                 in varchar2
  ,p_information214                 in varchar2
  ,p_information215                 in varchar2
  */
  ,p_information216                 in varchar2
  ,p_information217                 in varchar2
  ,p_information218                 in varchar2
  ,p_information219                 in varchar2
  ,p_information220                 in varchar2
  ,p_information221                 in number
  ,p_information222                 in number
  ,p_information223                 in number
  ,p_information224                 in number
  ,p_information225                 in number
  ,p_information226                 in number
  ,p_information227                 in number
  ,p_information228                 in number
  ,p_information229                 in number
  ,p_information230                 in number
  ,p_information231                 in number
  ,p_information232                 in number
  ,p_information233                 in number
  ,p_information234                 in number
  ,p_information235                 in number
  ,p_information236                 in number
  ,p_information237                 in number
  ,p_information238                 in number
  ,p_information239                 in number
  ,p_information240                 in number
  ,p_information241                 in number
  ,p_information242                 in number
  ,p_information243                 in number
  ,p_information244                 in number
  ,p_information245                 in number
  ,p_information246                 in number
  ,p_information247                 in number
  ,p_information248                 in number
  ,p_information249                 in number
  ,p_information250                 in number
  ,p_information251                 in number
  ,p_information252                 in number
  ,p_information253                 in number
  ,p_information254                 in number
  ,p_information255                 in number
  ,p_information256                 in number
  ,p_information257                 in number
  ,p_information258                 in number
  ,p_information259                 in number
  ,p_information260                 in number
  ,p_information261                 in number
  ,p_information262                 in number
  ,p_information263                 in number
  ,p_information264                 in number
  ,p_information265                 in number
  ,p_information266                 in number
  ,p_information267                 in number
  ,p_information268                 in number
  ,p_information269                 in number
  ,p_information270                 in number
  ,p_information271                 in number
  ,p_information272                 in number
  ,p_information273                 in number
  ,p_information274                 in number
  ,p_information275                 in number
  ,p_information276                 in number
  ,p_information277                 in number
  ,p_information278                 in number
  ,p_information279                 in number
  ,p_information280                 in number
  ,p_information281                 in number
  ,p_information282                 in number
  ,p_information283                 in number
  ,p_information284                 in number
  ,p_information285                 in number
  ,p_information286                 in number
  ,p_information287                 in number
  ,p_information288                 in number
  ,p_information289                 in number
  ,p_information290                 in number
  ,p_information291                 in number
  ,p_information292                 in number
  ,p_information293                 in number
  ,p_information294                 in number
  ,p_information295                 in number
  ,p_information296                 in number
  ,p_information297                 in number
  ,p_information298                 in number
  ,p_information299                 in number
  ,p_information300                 in number
  ,p_information301                 in number
  ,p_information302                 in number
  ,p_information303                 in number
  ,p_information304                 in number

  /* Extra Reserved Columns
  ,p_information305                 in number
  */
  ,p_information306                 in date
  ,p_information307                 in date
  ,p_information308                 in date
  ,p_information309                 in date
  ,p_information310                 in date
  ,p_information311                 in date
  ,p_information312                 in date
  ,p_information313                 in date
  ,p_information314                 in date
  ,p_information315                 in date
  ,p_information316                 in date
  ,p_information317                 in date
  ,p_information318                 in date
  ,p_information319                 in date
  ,p_information320                 in date

  /* Extra Reserved Columns
  ,p_information321                 in date
  ,p_information322                 in date
  */
  ,p_information323                 in long
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type;
--
end ben_cpe_shd;

 

/
