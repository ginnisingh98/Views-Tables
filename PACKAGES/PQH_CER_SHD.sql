--------------------------------------------------------
--  DDL for Package PQH_CER_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CER_SHD" AUTHID CURRENT_USER as
/* $Header: pqcerrhi.pkh 120.0 2005/05/29 01:41:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  copy_entity_result_id             number(15),
  copy_entity_txn_id                number(15),
  result_type_cd                    varchar2(30),
  number_of_copies                  number(15),
  status                            varchar2(255),
  src_copy_entity_result_id         number,
  information_category              varchar2(30),
  information1                      varchar2(2000),
  information2                      varchar2(255),
  information3                      varchar2(255),
  information4                      varchar2(255),
  information5                      varchar2(255),
  information6                      varchar2(255),
  information7                      varchar2(255),
  information8                      varchar2(255),
  information9                      varchar2(255),
  information10                     varchar2(255),
  information11                     varchar2(255),
  information12                     varchar2(255),
  information13                     varchar2(255),
  information14                     varchar2(255),
  information15                     varchar2(255),
  information16                     varchar2(255),
  information17                     varchar2(255),
  information18                     varchar2(255),
  information19                     varchar2(255),
  information20                     varchar2(255),
  information21                     varchar2(255),
  information22                     varchar2(255),
  information23                     varchar2(255),
  information24                     varchar2(255),
  information25                     varchar2(255),
  information26                     varchar2(255),
  information27                     varchar2(255),
  information28                     varchar2(255),
  information29                     varchar2(255),
  information30                     varchar2(255),
  information31                     varchar2(255),
  information32                     varchar2(255),
  information33                     varchar2(255),
  information34                     varchar2(255),
  information35                     varchar2(255),
  information36                     varchar2(255),
  information37                     varchar2(255),
  information38                     varchar2(255),
  information39                     varchar2(255),
  information40                     varchar2(255),
  information41                     varchar2(255),
  information42                     varchar2(255),
  information43                     varchar2(255),
  information44                     varchar2(255),
  information45                     varchar2(255),
  information46                     varchar2(255),
  information47                     varchar2(255),
  information48                     varchar2(255),
  information49                     varchar2(255),
  information50                     varchar2(255),
  information51                     varchar2(255),
  information52                     varchar2(2000),
  information53                     varchar2(255),
  information54                     varchar2(255),
  information55                     varchar2(255),
  information56                     varchar2(255),
  information57                     varchar2(255),
  information58                     varchar2(255),
  information59                     varchar2(255),
  information60                     varchar2(255),
  information61                     varchar2(255),
  information62                     varchar2(255),
  information63                     varchar2(255),
  information64                     varchar2(255),
  information65                     varchar2(255),
  information66                     varchar2(255),
  information67                     varchar2(255),
  information68                     varchar2(255),
  information69                     varchar2(255),
  information70                     varchar2(255),
  information71                     varchar2(255),
  information72                     varchar2(255),
  information73                     varchar2(255),
  information74                     varchar2(255),
  information75                     varchar2(255),
  information76                     varchar2(255),
  information77                     varchar2(255),
  information78                     varchar2(255),
  information79                     varchar2(255),
  information80                     varchar2(255),
  information81                     varchar2(255),
  information82                     varchar2(255),
  information83                     varchar2(255),
  information84                     varchar2(255),
  information85                     varchar2(255),
  information86                     varchar2(255),
  information87                     varchar2(255),
  information88                     varchar2(255),
  information89                     varchar2(255),
  information90                     varchar2(255),
  information91                     varchar2(255),
  information92                     varchar2(255),
  information93                     varchar2(255),
  information94                     varchar2(255),
  information95                     varchar2(255),
  information96                     varchar2(255),
  information97                     varchar2(255),
  information98                     varchar2(2000),
  information99                     varchar2(255),
  information100                    varchar2(255),
  information101                    varchar2(255),
  information102                    varchar2(255),
  information103                    varchar2(255),
  information104                    varchar2(255),
  information105                    varchar2(255),
  information106                    varchar2(255),
  information107                    varchar2(255),
  information108                    varchar2(255),
  information109                    varchar2(255),
  information110                    varchar2(255),
  information111                    varchar2(255),
  information112                    varchar2(255),
  information113                    varchar2(255),
  information114                    varchar2(255),
  information115                    varchar2(255),
  information116                    varchar2(255),
  information117                    varchar2(255),
  information118                    varchar2(255),
  information119                    varchar2(255),
  information120                    varchar2(255),
  information121                    varchar2(255),
  information122                    varchar2(255),
  information123                    varchar2(255),
  information124                    varchar2(255),
  information125                    varchar2(255),
  information126                    varchar2(255),
  information127                    varchar2(255),
  information128                    varchar2(255),
  information129                    varchar2(255),
  information130                    varchar2(255),
  information131                    varchar2(255),
  information132                    varchar2(255),
  information133                    varchar2(255),
  information134                    varchar2(255),
  information135                    varchar2(255),
  information136                    varchar2(255),
  information137                    varchar2(255),
  information138                    varchar2(255),
  information139                    varchar2(255),
  information140                    varchar2(255),
  information141                    varchar2(255),
  information142                    varchar2(255),
  information143                    varchar2(255),
  information144                    varchar2(255),
  information145                    varchar2(255),
  information146                    varchar2(255),
  information147                    varchar2(255),
  information148                    varchar2(255),
  information149                    varchar2(255),
  information150                    varchar2(255),
  information151                    varchar2(255),
  information152                    varchar2(255),
  information153                    varchar2(255),
  information154                    varchar2(255),
  information155                    varchar2(255),
  information156                    varchar2(255),
  information157                    varchar2(255),
  information158                    varchar2(255),
  information159                    varchar2(255),
  information160                    varchar2(255),
  information161                    varchar2(255),
  information162                    varchar2(255),
  information163                    varchar2(255),
  information164                    varchar2(255),
  information165                    varchar2(255),
  information166                    varchar2(255),
  information167                    varchar2(255),
  information168                    varchar2(255),
  information169                    varchar2(255),
  information170                    varchar2(255),
  information171                    varchar2(255),
  information172                    varchar2(255),
  information173                    varchar2(255),
  information174                    varchar2(255),
  information175                    varchar2(255),
  information176                    varchar2(255),
  information177                    varchar2(255),
  information178                    varchar2(255),
  information179                    varchar2(255),
  information180                    varchar2(255),
  information181                    varchar2(2000),
  information182                    varchar2(2000),
  information183                    varchar2(2000),
  information184                    varchar2(2000),
  information185                    varchar2(2000),
  information186                    varchar2(2000),
  information187                    varchar2(2000),
  information188                    varchar2(2000),
  information189                    varchar2(2000),
  information190                    varchar2(2000),
  mirror_entity_result_id           number(15),
  mirror_src_entity_result_id       number(15),
  parent_entity_result_id           number(15),
  table_route_id                    number(15),
  long_attribute1                   long,
  object_version_number             number(9)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
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
  p_copy_entity_result_id              in number,
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
  p_copy_entity_result_id              in number,
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
	p_copy_entity_result_id         in number,
	p_copy_entity_txn_id            in number,
	p_result_type_cd                in varchar2,
	p_number_of_copies              in number,
	p_status                        in varchar2,
	p_src_copy_entity_result_id     in number,
	p_information_category          in varchar2,
	p_information1                  in varchar2,
	p_information2                  in varchar2,
	p_information3                  in varchar2,
	p_information4                  in varchar2,
	p_information5                  in varchar2,
	p_information6                  in varchar2,
	p_information7                  in varchar2,
	p_information8                  in varchar2,
	p_information9                  in varchar2,
	p_information10                 in varchar2,
	p_information11                 in varchar2,
	p_information12                 in varchar2,
	p_information13                 in varchar2,
	p_information14                 in varchar2,
	p_information15                 in varchar2,
	p_information16                 in varchar2,
	p_information17                 in varchar2,
	p_information18                 in varchar2,
	p_information19                 in varchar2,
	p_information20                 in varchar2,
	p_information21                 in varchar2,
	p_information22                 in varchar2,
	p_information23                 in varchar2,
	p_information24                 in varchar2,
	p_information25                 in varchar2,
	p_information26                 in varchar2,
	p_information27                 in varchar2,
	p_information28                 in varchar2,
	p_information29                 in varchar2,
	p_information30                 in varchar2,
	p_information31                 in varchar2,
	p_information32                 in varchar2,
	p_information33                 in varchar2,
	p_information34                 in varchar2,
	p_information35                 in varchar2,
	p_information36                 in varchar2,
	p_information37                 in varchar2,
	p_information38                 in varchar2,
	p_information39                 in varchar2,
	p_information40                 in varchar2,
	p_information41                 in varchar2,
	p_information42                 in varchar2,
	p_information43                 in varchar2,
	p_information44                 in varchar2,
	p_information45                 in varchar2,
	p_information46                 in varchar2,
	p_information47                 in varchar2,
	p_information48                 in varchar2,
	p_information49                 in varchar2,
	p_information50                 in varchar2,
	p_information51                 in varchar2,
	p_information52                 in varchar2,
	p_information53                 in varchar2,
	p_information54                 in varchar2,
	p_information55                 in varchar2,
	p_information56                 in varchar2,
	p_information57                 in varchar2,
	p_information58                 in varchar2,
	p_information59                 in varchar2,
	p_information60                 in varchar2,
	p_information61                 in varchar2,
	p_information62                 in varchar2,
	p_information63                 in varchar2,
	p_information64                 in varchar2,
	p_information65                 in varchar2,
	p_information66                 in varchar2,
	p_information67                 in varchar2,
	p_information68                 in varchar2,
	p_information69                 in varchar2,
	p_information70                 in varchar2,
	p_information71                 in varchar2,
	p_information72                 in varchar2,
	p_information73                 in varchar2,
	p_information74                 in varchar2,
	p_information75                 in varchar2,
	p_information76                 in varchar2,
	p_information77                 in varchar2,
	p_information78                 in varchar2,
	p_information79                 in varchar2,
	p_information80                 in varchar2,
	p_information81                 in varchar2,
	p_information82                 in varchar2,
	p_information83                 in varchar2,
	p_information84                 in varchar2,
	p_information85                 in varchar2,
	p_information86                 in varchar2,
	p_information87                 in varchar2,
	p_information88                 in varchar2,
	p_information89                 in varchar2,
	p_information90                 in varchar2,
	p_information91                 in varchar2,
	p_information92                 in varchar2,
	p_information93                 in varchar2,
	p_information94                 in varchar2,
	p_information95                 in varchar2,
	p_information96                 in varchar2,
	p_information97                 in varchar2,
	p_information98                 in varchar2,
	p_information99                 in varchar2,
	p_information100                in varchar2,
	p_information101                in varchar2,
	p_information102                in varchar2,
	p_information103                in varchar2,
	p_information104                in varchar2,
	p_information105                in varchar2,
	p_information106                in varchar2,
	p_information107                in varchar2,
	p_information108                in varchar2,
	p_information109                in varchar2,
	p_information110                in varchar2,
	p_information111                in varchar2,
	p_information112                in varchar2,
	p_information113                in varchar2,
	p_information114                in varchar2,
	p_information115                in varchar2,
	p_information116                in varchar2,
	p_information117                in varchar2,
	p_information118                in varchar2,
	p_information119                in varchar2,
	p_information120                in varchar2,
	p_information121                in varchar2,
	p_information122                in varchar2,
	p_information123                in varchar2,
	p_information124                in varchar2,
	p_information125                in varchar2,
	p_information126                in varchar2,
	p_information127                in varchar2,
	p_information128                in varchar2,
	p_information129                in varchar2,
	p_information130                in varchar2,
	p_information131                in varchar2,
	p_information132                in varchar2,
	p_information133                in varchar2,
	p_information134                in varchar2,
	p_information135                in varchar2,
	p_information136                in varchar2,
	p_information137                in varchar2,
	p_information138                in varchar2,
	p_information139                in varchar2,
	p_information140                in varchar2,
	p_information141                in varchar2,
	p_information142                in varchar2,
	p_information143                in varchar2,
	p_information144                in varchar2,
	p_information145                in varchar2,
	p_information146                in varchar2,
	p_information147                in varchar2,
	p_information148                in varchar2,
	p_information149                in varchar2,
	p_information150                in varchar2,
	p_information151                in varchar2,
	p_information152                in varchar2,
	p_information153                in varchar2,
	p_information154                in varchar2,
	p_information155                in varchar2,
	p_information156                in varchar2,
	p_information157                in varchar2,
	p_information158                in varchar2,
	p_information159                in varchar2,
	p_information160                in varchar2,
	p_information161                in varchar2,
	p_information162                in varchar2,
	p_information163                in varchar2,
	p_information164                in varchar2,
	p_information165                in varchar2,
	p_information166                in varchar2,
	p_information167                in varchar2,
	p_information168                in varchar2,
	p_information169                in varchar2,
	p_information170                in varchar2,
	p_information171                in varchar2,
	p_information172                in varchar2,
	p_information173                in varchar2,
	p_information174                in varchar2,
	p_information175                in varchar2,
	p_information176                in varchar2,
	p_information177                in varchar2,
	p_information178                in varchar2,
	p_information179                in varchar2,
	p_information180                in varchar2,
        p_information181                in varchar2,
        p_information182                in varchar2,
        p_information183                in varchar2,
        p_information184                in varchar2,
        p_information185                in varchar2,
        p_information186                in varchar2,
        p_information187                in varchar2,
        p_information188                in varchar2,
        p_information189                in varchar2,
        p_information190                in varchar2,
        p_mirror_entity_result_id       in number,
        p_mirror_src_entity_result_id   in number,
        p_parent_entity_result_id       in number,
        p_table_route_id                in number,
        p_long_attribute1               in long,
	p_object_version_number         in number
	)
	Return g_rec_type;
--
end pqh_cer_shd;

 

/
