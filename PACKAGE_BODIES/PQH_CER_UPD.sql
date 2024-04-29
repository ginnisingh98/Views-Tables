--------------------------------------------------------
--  DDL for Package Body PQH_CER_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CER_UPD" as
/* $Header: pqcerrhi.pkb 115.6 2002/11/27 04:43:16 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cer_upd.';  -- Global package name
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
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
Procedure update_dml(p_rec in out nocopy pqh_cer_shd.g_rec_type) is
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
  -- Update the pqh_copy_entity_results Row
  --
  update pqh_copy_entity_results
  set
  copy_entity_txn_id                = p_rec.copy_entity_txn_id,
  result_type_cd                    = p_rec.result_type_cd,
  number_of_copies                  = p_rec.number_of_copies,
  status                            = p_rec.status,
  src_copy_entity_result_id         = p_rec.src_copy_entity_result_id,
  information_category              = p_rec.information_category,
  information1                      = p_rec.information1,
  information2                      = p_rec.information2,
  information3                      = p_rec.information3,
  information4                      = p_rec.information4,
  information5                      = p_rec.information5,
  information6                      = p_rec.information6,
  information7                      = p_rec.information7,
  information8                      = p_rec.information8,
  information9                      = p_rec.information9,
  information10                     = p_rec.information10,
  information11                     = p_rec.information11,
  information12                     = p_rec.information12,
  information13                     = p_rec.information13,
  information14                     = p_rec.information14,
  information15                     = p_rec.information15,
  information16                     = p_rec.information16,
  information17                     = p_rec.information17,
  information18                     = p_rec.information18,
  information19                     = p_rec.information19,
  information20                     = p_rec.information20,
  information21                     = p_rec.information21,
  information22                     = p_rec.information22,
  information23                     = p_rec.information23,
  information24                     = p_rec.information24,
  information25                     = p_rec.information25,
  information26                     = p_rec.information26,
  information27                     = p_rec.information27,
  information28                     = p_rec.information28,
  information29                     = p_rec.information29,
  information30                     = p_rec.information30,
  information31                     = p_rec.information31,
  information32                     = p_rec.information32,
  information33                     = p_rec.information33,
  information34                     = p_rec.information34,
  information35                     = p_rec.information35,
  information36                     = p_rec.information36,
  information37                     = p_rec.information37,
  information38                     = p_rec.information38,
  information39                     = p_rec.information39,
  information40                     = p_rec.information40,
  information41                     = p_rec.information41,
  information42                     = p_rec.information42,
  information43                     = p_rec.information43,
  information44                     = p_rec.information44,
  information45                     = p_rec.information45,
  information46                     = p_rec.information46,
  information47                     = p_rec.information47,
  information48                     = p_rec.information48,
  information49                     = p_rec.information49,
  information50                     = p_rec.information50,
  information51                     = p_rec.information51,
  information52                     = p_rec.information52,
  information53                     = p_rec.information53,
  information54                     = p_rec.information54,
  information55                     = p_rec.information55,
  information56                     = p_rec.information56,
  information57                     = p_rec.information57,
  information58                     = p_rec.information58,
  information59                     = p_rec.information59,
  information60                     = p_rec.information60,
  information61                     = p_rec.information61,
  information62                     = p_rec.information62,
  information63                     = p_rec.information63,
  information64                     = p_rec.information64,
  information65                     = p_rec.information65,
  information66                     = p_rec.information66,
  information67                     = p_rec.information67,
  information68                     = p_rec.information68,
  information69                     = p_rec.information69,
  information70                     = p_rec.information70,
  information71                     = p_rec.information71,
  information72                     = p_rec.information72,
  information73                     = p_rec.information73,
  information74                     = p_rec.information74,
  information75                     = p_rec.information75,
  information76                     = p_rec.information76,
  information77                     = p_rec.information77,
  information78                     = p_rec.information78,
  information79                     = p_rec.information79,
  information80                     = p_rec.information80,
  information81                     = p_rec.information81,
  information82                     = p_rec.information82,
  information83                     = p_rec.information83,
  information84                     = p_rec.information84,
  information85                     = p_rec.information85,
  information86                     = p_rec.information86,
  information87                     = p_rec.information87,
  information88                     = p_rec.information88,
  information89                     = p_rec.information89,
  information90                     = p_rec.information90,
  information91                     = p_rec.information91,
  information92                     = p_rec.information92,
  information93                     = p_rec.information93,
  information94                     = p_rec.information94,
  information95                     = p_rec.information95,
  information96                     = p_rec.information96,
  information97                     = p_rec.information97,
  information98                     = p_rec.information98,
  information99                     = p_rec.information99,
  information100                    = p_rec.information100,
  information101                    = p_rec.information101,
  information102                    = p_rec.information102 ,
  information103                    = p_rec.information103,
  information104                    = p_rec.information104,
  information105                    = p_rec.information105,
  information106                    = p_rec.information106,
  information107                    = p_rec.information107,
  information108                    = p_rec.information108,
  information109                    = p_rec.information109,
  information110                    = p_rec.information110,
  information111                    = p_rec.information111,
  information112                    = p_rec.information112 ,
  information113                    = p_rec.information113,
  information114                    = p_rec.information114,
  information115                    = p_rec.information115,
  information116                    = p_rec.information116,
  information117                    = p_rec.information117,
  information118                    = p_rec.information118,
  information119                    = p_rec.information119,
  information120                    = p_rec.information120,
  information121                    = p_rec.information121,
  information122                    = p_rec.information122 ,
  information123                    = p_rec.information123,
  information124                    = p_rec.information124,
  information125                    = p_rec.information125,
  information126                    = p_rec.information126,
  information127                    = p_rec.information127,
  information128                    = p_rec.information128,
  information129                    = p_rec.information129,
  information130                    = p_rec.information130,
  information131                    = p_rec.information131,
  information132                    = p_rec.information132 ,
  information133                    = p_rec.information133,
  information134                    = p_rec.information134,
  information135                    = p_rec.information135,
  information136                    = p_rec.information136,
  information137                    = p_rec.information137,
  information138                    = p_rec.information138,
  information139                    = p_rec.information139,
  information140                    = p_rec.information140,
  information141                    = p_rec.information141,
  information142                    = p_rec.information142 ,
  information143                    = p_rec.information143,
  information144                    = p_rec.information144,
  information145                    = p_rec.information145,
  information146                    = p_rec.information146,
  information147                    = p_rec.information147,
  information148                    = p_rec.information148,
  information149                    = p_rec.information149,
  information150                    = p_rec.information150,
  information151                    = p_rec.information151,
  information152                    = p_rec.information152 ,
  information153                    = p_rec.information153,
  information154                    = p_rec.information154,
  information155                    = p_rec.information155,
  information156                    = p_rec.information156,
  information157                    = p_rec.information157,
  information158                    = p_rec.information158,
  information159                    = p_rec.information159,
  information160                    = p_rec.information160,
  information161                    = p_rec.information161,
  information162                    = p_rec.information162 ,
  information163                    = p_rec.information163,
  information164                    = p_rec.information164,
  information165                    = p_rec.information165,
  information166                    = p_rec.information166,
  information167                    = p_rec.information167,
  information168                    = p_rec.information168,
  information169                    = p_rec.information169,
  information170                    = p_rec.information170,
  information171                    = p_rec.information171,
  information172                    = p_rec.information172,
  information173                    = p_rec.information173,
  information174                    = p_rec.information174,
  information175                    = p_rec.information175,
  information176                    = p_rec.information176,
  information177                    = p_rec.information177,
  information178                    = p_rec.information178,
  information179                    = p_rec.information179,
  information180                    = p_rec.information180,
  information181                    = p_rec.information181,
  information182                    = p_rec.information182,
  information183                    = p_rec.information183,
  information184                    = p_rec.information184,
  information185                    = p_rec.information185,
  information186                    = p_rec.information186,
  information187                    = p_rec.information187,
  information188                    = p_rec.information188,
  information189                    = p_rec.information189,
  information190                    = p_rec.information190,
  mirror_entity_result_id           = p_rec.mirror_entity_result_id,
  mirror_src_entity_result_id       = p_rec.mirror_src_entity_result_id,
  parent_entity_result_id           = p_rec.parent_entity_result_id,
  table_route_id                    = p_rec.table_route_id,
  long_attribute1                   = p_rec.long_attribute1,
  object_version_number             = p_rec.object_version_number
  where copy_entity_result_id = p_rec.copy_entity_result_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_cer_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_cer_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_cer_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_update(p_rec in pqh_cer_shd.g_rec_type) is
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
Procedure post_update(
p_effective_date in date,p_rec in pqh_cer_shd.g_rec_type) is
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
    pqh_cer_rku.after_update
      (
  p_copy_entity_result_id         =>p_rec.copy_entity_result_id
 ,p_copy_entity_txn_id            =>p_rec.copy_entity_txn_id
 ,p_result_type_cd                =>p_rec.result_type_cd
 ,p_number_of_copies              =>p_rec.number_of_copies
 ,p_status                        =>p_rec.status
 ,p_src_copy_entity_result_id     =>p_rec.src_copy_entity_result_id
 ,p_information_category          =>p_rec.information_category
 ,p_information1                  =>p_rec.information1
 ,p_information2                  =>p_rec.information2
 ,p_information3                  =>p_rec.information3
 ,p_information4                  =>p_rec.information4
 ,p_information5                  =>p_rec.information5
 ,p_information6                  =>p_rec.information6
 ,p_information7                  =>p_rec.information7
 ,p_information8                  =>p_rec.information8
 ,p_information9                  =>p_rec.information9
 ,p_information10                 =>p_rec.information10
 ,p_information11                 =>p_rec.information11
 ,p_information12                 =>p_rec.information12
 ,p_information13                 =>p_rec.information13
 ,p_information14                 =>p_rec.information14
 ,p_information15                 =>p_rec.information15
 ,p_information16                 =>p_rec.information16
 ,p_information17                 =>p_rec.information17
 ,p_information18                 =>p_rec.information18
 ,p_information19                 =>p_rec.information19
 ,p_information20                 =>p_rec.information20
 ,p_information21                 =>p_rec.information21
 ,p_information22                 =>p_rec.information22
 ,p_information23                 =>p_rec.information23
 ,p_information24                 =>p_rec.information24
 ,p_information25                 =>p_rec.information25
 ,p_information26                 =>p_rec.information26
 ,p_information27                 =>p_rec.information27
 ,p_information28                 =>p_rec.information28
 ,p_information29                 =>p_rec.information29
 ,p_information30                 =>p_rec.information30
 ,p_information31                 =>p_rec.information31
 ,p_information32                 =>p_rec.information32
 ,p_information33                 =>p_rec.information33
 ,p_information34                 =>p_rec.information34
 ,p_information35                 =>p_rec.information35
 ,p_information36                 =>p_rec.information36
 ,p_information37                 =>p_rec.information37
 ,p_information38                 =>p_rec.information38
 ,p_information39                 =>p_rec.information39
 ,p_information40                 =>p_rec.information40
 ,p_information41                 =>p_rec.information41
 ,p_information42                 =>p_rec.information42
 ,p_information43                 =>p_rec.information43
 ,p_information44                 =>p_rec.information44
 ,p_information45                 =>p_rec.information45
 ,p_information46                 =>p_rec.information46
 ,p_information47                 =>p_rec.information47
 ,p_information48                 =>p_rec.information48
 ,p_information49                 =>p_rec.information49
 ,p_information50                 =>p_rec.information50
 ,p_information51                 =>p_rec.information51
 ,p_information52                 =>p_rec.information52
 ,p_information53                 =>p_rec.information53
 ,p_information54                 =>p_rec.information54
 ,p_information55                 =>p_rec.information55
 ,p_information56                 =>p_rec.information56
 ,p_information57                 =>p_rec.information57
 ,p_information58                 =>p_rec.information58
 ,p_information59                 =>p_rec.information59
 ,p_information60                 =>p_rec.information60
 ,p_information61                 =>p_rec.information61
 ,p_information62                 =>p_rec.information62
 ,p_information63                 =>p_rec.information63
 ,p_information64                 =>p_rec.information64
 ,p_information65                 =>p_rec.information65
 ,p_information66                 =>p_rec.information66
 ,p_information67                 =>p_rec.information67
 ,p_information68                 =>p_rec.information68
 ,p_information69                 =>p_rec.information69
 ,p_information70                 =>p_rec.information70
 ,p_information71                 =>p_rec.information71
 ,p_information72                 =>p_rec.information72
 ,p_information73                 =>p_rec.information73
 ,p_information74                 =>p_rec.information74
 ,p_information75                 =>p_rec.information75
 ,p_information76                 =>p_rec.information76
 ,p_information77                 =>p_rec.information77
 ,p_information78                 =>p_rec.information78
 ,p_information79                 =>p_rec.information79
 ,p_information80                 =>p_rec.information80
 ,p_information81                 =>p_rec.information81
 ,p_information82                 =>p_rec.information82
 ,p_information83                 =>p_rec.information83
 ,p_information84                 =>p_rec.information84
 ,p_information85                 =>p_rec.information85
 ,p_information86                 =>p_rec.information86
 ,p_information87                 =>p_rec.information87
 ,p_information88                 =>p_rec.information88
 ,p_information89                 =>p_rec.information89
 ,p_information90                 =>p_rec.information90
 ,p_information91                 =>p_rec.information91
 ,p_information92                 =>p_rec.information92
 ,p_information93                 =>p_rec.information93
 ,p_information94                 =>p_rec.information94
 ,p_information95                 =>p_rec.information95
 ,p_information96                 =>p_rec.information96
 ,p_information97                 =>p_rec.information97
 ,p_information98                 =>p_rec.information98
 ,p_information99                 =>p_rec.information99
 ,p_information100                =>p_rec.information100
 ,p_information101                =>p_rec.information101
 ,p_information102                =>p_rec.information102
 ,p_information103                =>p_rec.information103
 ,p_information104                =>p_rec.information104
 ,p_information105                =>p_rec.information105
 ,p_information106                =>p_rec.information106
 ,p_information107                =>p_rec.information107
 ,p_information108                =>p_rec.information108
 ,p_information109                =>p_rec.information109
 ,p_information110                =>p_rec.information110
 ,p_information111                =>p_rec.information111
 ,p_information112                =>p_rec.information112
 ,p_information113                =>p_rec.information113
 ,p_information114                =>p_rec.information114
 ,p_information115                =>p_rec.information115
 ,p_information116                =>p_rec.information116
 ,p_information117                =>p_rec.information117
 ,p_information118                =>p_rec.information118
 ,p_information119                =>p_rec.information119
 ,p_information120                =>p_rec.information120
 ,p_information121                =>p_rec.information121
 ,p_information122                =>p_rec.information122
 ,p_information123                =>p_rec.information123
 ,p_information124                =>p_rec.information124
 ,p_information125                =>p_rec.information125
 ,p_information126                =>p_rec.information126
 ,p_information127                =>p_rec.information127
 ,p_information128                =>p_rec.information128
 ,p_information129                =>p_rec.information129
 ,p_information130                =>p_rec.information130
 ,p_information131                =>p_rec.information131
 ,p_information132                =>p_rec.information132
 ,p_information133                =>p_rec.information133
 ,p_information134                =>p_rec.information134
 ,p_information135                =>p_rec.information135
 ,p_information136                =>p_rec.information136
 ,p_information137                =>p_rec.information137
 ,p_information138                =>p_rec.information138
 ,p_information139                =>p_rec.information139
 ,p_information140                =>p_rec.information140
 ,p_information141                =>p_rec.information141
 ,p_information142                =>p_rec.information142
 ,p_information143                =>p_rec.information143
 ,p_information144                =>p_rec.information144
 ,p_information145                =>p_rec.information145
 ,p_information146                =>p_rec.information146
 ,p_information147                =>p_rec.information147
 ,p_information148                =>p_rec.information148
 ,p_information149                =>p_rec.information149
 ,p_information150                =>p_rec.information150
 ,p_information151                =>p_rec.information151
 ,p_information152                =>p_rec.information152
 ,p_information153                =>p_rec.information153
 ,p_information154                =>p_rec.information154
 ,p_information155                =>p_rec.information155
 ,p_information156                =>p_rec.information156
 ,p_information157                =>p_rec.information157
 ,p_information158                =>p_rec.information158
 ,p_information159                =>p_rec.information159
 ,p_information160                =>p_rec.information160
 ,p_information161                =>p_rec.information161
 ,p_information162                =>p_rec.information162
 ,p_information163                =>p_rec.information163
 ,p_information164                =>p_rec.information164
 ,p_information165                =>p_rec.information165
 ,p_information166                =>p_rec.information166
 ,p_information167                =>p_rec.information167
 ,p_information168                =>p_rec.information168
 ,p_information169                =>p_rec.information169
 ,p_information170                =>p_rec.information170
 ,p_information171                =>p_rec.information171
 ,p_information172                =>p_rec.information172
 ,p_information173                =>p_rec.information173
 ,p_information174                =>p_rec.information174
 ,p_information175                =>p_rec.information175
 ,p_information176                =>p_rec.information176
 ,p_information177                =>p_rec.information177
 ,p_information178                =>p_rec.information178
 ,p_information179                =>p_rec.information179
 ,p_information180                =>p_rec.information180
 ,p_information181                =>p_rec.information181
 ,p_information182                =>p_rec.information182
 ,p_information183                =>p_rec.information183
 ,p_information184                =>p_rec.information184
 ,p_information185                =>p_rec.information185
 ,p_information186                =>p_rec.information186
 ,p_information187                =>p_rec.information187
 ,p_information188                =>p_rec.information188
 ,p_information189                =>p_rec.information189
 ,p_information190                =>p_rec.information190
 ,p_mirror_entity_result_id       =>p_rec.mirror_entity_result_id
 ,p_mirror_src_entity_result_id   =>p_rec.mirror_src_entity_result_id
 ,p_parent_entity_result_id       =>p_rec.parent_entity_result_id
 ,p_table_route_id                =>p_rec.table_route_id
 ,p_long_attribute1               =>p_rec.long_attribute1
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
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
 ,p_object_version_number_o        =>pqh_cer_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_copy_entity_results'
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
Procedure convert_defs(p_rec in out nocopy pqh_cer_shd.g_rec_type) is
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
  If (p_rec.copy_entity_txn_id = hr_api.g_number) then
    p_rec.copy_entity_txn_id :=
    pqh_cer_shd.g_old_rec.copy_entity_txn_id;
  End If;
  If (p_rec.result_type_cd = hr_api.g_varchar2) then
    p_rec.result_type_cd :=
    pqh_cer_shd.g_old_rec.result_type_cd;
  End If;
  If (p_rec.number_of_copies = hr_api.g_number) then
    p_rec.number_of_copies :=
    pqh_cer_shd.g_old_rec.number_of_copies;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    pqh_cer_shd.g_old_rec.status;
  End If;
  If (p_rec.src_copy_entity_result_id = hr_api.g_number) then
    p_rec.src_copy_entity_result_id :=
    pqh_cer_shd.g_old_rec.src_copy_entity_result_id;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    pqh_cer_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    pqh_cer_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    pqh_cer_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    pqh_cer_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    pqh_cer_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    pqh_cer_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    pqh_cer_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    pqh_cer_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    pqh_cer_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    pqh_cer_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    pqh_cer_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    pqh_cer_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    pqh_cer_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    pqh_cer_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    pqh_cer_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    pqh_cer_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    pqh_cer_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    pqh_cer_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    pqh_cer_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    pqh_cer_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    pqh_cer_shd.g_old_rec.information20;
  End If;
  If (p_rec.information21 = hr_api.g_varchar2) then
    p_rec.information21 :=
    pqh_cer_shd.g_old_rec.information21;
  End If;
  If (p_rec.information22 = hr_api.g_varchar2) then
    p_rec.information22 :=
    pqh_cer_shd.g_old_rec.information22;
  End If;
  If (p_rec.information23 = hr_api.g_varchar2) then
    p_rec.information23 :=
    pqh_cer_shd.g_old_rec.information23;
  End If;
  If (p_rec.information24 = hr_api.g_varchar2) then
    p_rec.information24 :=
    pqh_cer_shd.g_old_rec.information24;
  End If;
  If (p_rec.information25 = hr_api.g_varchar2) then
    p_rec.information25 :=
    pqh_cer_shd.g_old_rec.information25;
  End If;
  If (p_rec.information26 = hr_api.g_varchar2) then
    p_rec.information26 :=
    pqh_cer_shd.g_old_rec.information26;
  End If;
  If (p_rec.information27 = hr_api.g_varchar2) then
    p_rec.information27 :=
    pqh_cer_shd.g_old_rec.information27;
  End If;
  If (p_rec.information28 = hr_api.g_varchar2) then
    p_rec.information28 :=
    pqh_cer_shd.g_old_rec.information28;
  End If;
  If (p_rec.information29 = hr_api.g_varchar2) then
    p_rec.information29 :=
    pqh_cer_shd.g_old_rec.information29;
  End If;
  If (p_rec.information30 = hr_api.g_varchar2) then
    p_rec.information30 :=
    pqh_cer_shd.g_old_rec.information30;
  End If;
  If (p_rec.information31 = hr_api.g_varchar2) then
    p_rec.information31 :=
    pqh_cer_shd.g_old_rec.information31;
  End If;
  If (p_rec.information32 = hr_api.g_varchar2) then
    p_rec.information32 :=
    pqh_cer_shd.g_old_rec.information32;
  End If;
  If (p_rec.information33 = hr_api.g_varchar2) then
    p_rec.information33 :=
    pqh_cer_shd.g_old_rec.information33;
  End If;
  If (p_rec.information34 = hr_api.g_varchar2) then
    p_rec.information34 :=
    pqh_cer_shd.g_old_rec.information34;
  End If;
  If (p_rec.information35 = hr_api.g_varchar2) then
    p_rec.information35 :=
    pqh_cer_shd.g_old_rec.information35;
  End If;
  If (p_rec.information36 = hr_api.g_varchar2) then
    p_rec.information36 :=
    pqh_cer_shd.g_old_rec.information36;
  End If;
  If (p_rec.information37 = hr_api.g_varchar2) then
    p_rec.information37 :=
    pqh_cer_shd.g_old_rec.information37;
  End If;
  If (p_rec.information38 = hr_api.g_varchar2) then
    p_rec.information38 :=
    pqh_cer_shd.g_old_rec.information38;
  End If;
  If (p_rec.information39 = hr_api.g_varchar2) then
    p_rec.information39 :=
    pqh_cer_shd.g_old_rec.information39;
  End If;
  If (p_rec.information40 = hr_api.g_varchar2) then
    p_rec.information40 :=
    pqh_cer_shd.g_old_rec.information40;
  End If;
  If (p_rec.information41 = hr_api.g_varchar2) then
    p_rec.information41 :=
    pqh_cer_shd.g_old_rec.information41;
  End If;
  If (p_rec.information42 = hr_api.g_varchar2) then
    p_rec.information42 :=
    pqh_cer_shd.g_old_rec.information42;
  End If;
  If (p_rec.information43 = hr_api.g_varchar2) then
    p_rec.information43 :=
    pqh_cer_shd.g_old_rec.information43;
  End If;
  If (p_rec.information44 = hr_api.g_varchar2) then
    p_rec.information44 :=
    pqh_cer_shd.g_old_rec.information44;
  End If;
  If (p_rec.information45 = hr_api.g_varchar2) then
    p_rec.information45 :=
    pqh_cer_shd.g_old_rec.information45;
  End If;
  If (p_rec.information46 = hr_api.g_varchar2) then
    p_rec.information46 :=
    pqh_cer_shd.g_old_rec.information46;
  End If;
  If (p_rec.information47 = hr_api.g_varchar2) then
    p_rec.information47 :=
    pqh_cer_shd.g_old_rec.information47;
  End If;
  If (p_rec.information48 = hr_api.g_varchar2) then
    p_rec.information48 :=
    pqh_cer_shd.g_old_rec.information48;
  End If;
  If (p_rec.information49 = hr_api.g_varchar2) then
    p_rec.information49 :=
    pqh_cer_shd.g_old_rec.information49;
  End If;
  If (p_rec.information50 = hr_api.g_varchar2) then
    p_rec.information50 :=
    pqh_cer_shd.g_old_rec.information50;
  End If;
  If (p_rec.information51 = hr_api.g_varchar2) then
    p_rec.information51 :=
    pqh_cer_shd.g_old_rec.information51;
  End If;
  If (p_rec.information52 = hr_api.g_varchar2) then
    p_rec.information52 :=
    pqh_cer_shd.g_old_rec.information52;
  End If;
  If (p_rec.information53 = hr_api.g_varchar2) then
    p_rec.information53 :=
    pqh_cer_shd.g_old_rec.information53;
  End If;
  If (p_rec.information54 = hr_api.g_varchar2) then
    p_rec.information54 :=
    pqh_cer_shd.g_old_rec.information54;
  End If;
  If (p_rec.information55 = hr_api.g_varchar2) then
    p_rec.information55 :=
    pqh_cer_shd.g_old_rec.information55;
  End If;
  If (p_rec.information56 = hr_api.g_varchar2) then
    p_rec.information56 :=
    pqh_cer_shd.g_old_rec.information56;
  End If;
  If (p_rec.information57 = hr_api.g_varchar2) then
    p_rec.information57 :=
    pqh_cer_shd.g_old_rec.information57;
  End If;
  If (p_rec.information58 = hr_api.g_varchar2) then
    p_rec.information58 :=
    pqh_cer_shd.g_old_rec.information58;
  End If;
  If (p_rec.information59 = hr_api.g_varchar2) then
    p_rec.information59 :=
    pqh_cer_shd.g_old_rec.information59;
  End If;
  If (p_rec.information60 = hr_api.g_varchar2) then
    p_rec.information60 :=
    pqh_cer_shd.g_old_rec.information60;
  End If;
  If (p_rec.information61 = hr_api.g_varchar2) then
    p_rec.information61 :=
    pqh_cer_shd.g_old_rec.information61;
  End If;
  If (p_rec.information62 = hr_api.g_varchar2) then
    p_rec.information62 :=
    pqh_cer_shd.g_old_rec.information62;
  End If;
  If (p_rec.information63 = hr_api.g_varchar2) then
    p_rec.information63 :=
    pqh_cer_shd.g_old_rec.information63;
  End If;
  If (p_rec.information64 = hr_api.g_varchar2) then
    p_rec.information64 :=
    pqh_cer_shd.g_old_rec.information64;
  End If;
  If (p_rec.information65 = hr_api.g_varchar2) then
    p_rec.information65 :=
    pqh_cer_shd.g_old_rec.information65;
  End If;
  If (p_rec.information66 = hr_api.g_varchar2) then
    p_rec.information66 :=
    pqh_cer_shd.g_old_rec.information66;
  End If;
  If (p_rec.information67 = hr_api.g_varchar2) then
    p_rec.information67 :=
    pqh_cer_shd.g_old_rec.information67;
  End If;
  If (p_rec.information68 = hr_api.g_varchar2) then
    p_rec.information68 :=
    pqh_cer_shd.g_old_rec.information68;
  End If;
  If (p_rec.information69 = hr_api.g_varchar2) then
    p_rec.information69 :=
    pqh_cer_shd.g_old_rec.information69;
  End If;
  If (p_rec.information70 = hr_api.g_varchar2) then
    p_rec.information70 :=
    pqh_cer_shd.g_old_rec.information70;
  End If;
  If (p_rec.information71 = hr_api.g_varchar2) then
    p_rec.information71 :=
    pqh_cer_shd.g_old_rec.information71;
  End If;
  If (p_rec.information72 = hr_api.g_varchar2) then
    p_rec.information72 :=
    pqh_cer_shd.g_old_rec.information72;
  End If;
  If (p_rec.information73 = hr_api.g_varchar2) then
    p_rec.information73 :=
    pqh_cer_shd.g_old_rec.information73;
  End If;
  If (p_rec.information74 = hr_api.g_varchar2) then
    p_rec.information74 :=
    pqh_cer_shd.g_old_rec.information74;
  End If;
  If (p_rec.information75 = hr_api.g_varchar2) then
    p_rec.information75 :=
    pqh_cer_shd.g_old_rec.information75;
  End If;
  If (p_rec.information76 = hr_api.g_varchar2) then
    p_rec.information76 :=
    pqh_cer_shd.g_old_rec.information76;
  End If;
  If (p_rec.information77 = hr_api.g_varchar2) then
    p_rec.information77 :=
    pqh_cer_shd.g_old_rec.information77;
  End If;
  If (p_rec.information78 = hr_api.g_varchar2) then
    p_rec.information78 :=
    pqh_cer_shd.g_old_rec.information78;
  End If;
  If (p_rec.information79 = hr_api.g_varchar2) then
    p_rec.information79 :=
    pqh_cer_shd.g_old_rec.information79;
  End If;
  If (p_rec.information80 = hr_api.g_varchar2) then
    p_rec.information80 :=
    pqh_cer_shd.g_old_rec.information80;
  End If;
  If (p_rec.information81 = hr_api.g_varchar2) then
    p_rec.information81 :=
    pqh_cer_shd.g_old_rec.information81;
  End If;
  If (p_rec.information82 = hr_api.g_varchar2) then
    p_rec.information82 :=
    pqh_cer_shd.g_old_rec.information82;
  End If;
  If (p_rec.information83 = hr_api.g_varchar2) then
    p_rec.information83 :=
    pqh_cer_shd.g_old_rec.information83;
  End If;
  If (p_rec.information84 = hr_api.g_varchar2) then
    p_rec.information84 :=
    pqh_cer_shd.g_old_rec.information84;
  End If;
  If (p_rec.information85 = hr_api.g_varchar2) then
    p_rec.information85 :=
    pqh_cer_shd.g_old_rec.information85;
  End If;
  If (p_rec.information86 = hr_api.g_varchar2) then
    p_rec.information86 :=
    pqh_cer_shd.g_old_rec.information86;
  End If;
  If (p_rec.information87 = hr_api.g_varchar2) then
    p_rec.information87 :=
    pqh_cer_shd.g_old_rec.information87;
  End If;
  If (p_rec.information88 = hr_api.g_varchar2) then
    p_rec.information88 :=
    pqh_cer_shd.g_old_rec.information88;
  End If;
  If (p_rec.information89 = hr_api.g_varchar2) then
    p_rec.information89 :=
    pqh_cer_shd.g_old_rec.information89;
  End If;
  If (p_rec.information90 = hr_api.g_varchar2) then
    p_rec.information90 :=
    pqh_cer_shd.g_old_rec.information90;
  End If;
  If (p_rec.information91 = hr_api.g_varchar2) then
    p_rec.information91 :=
    pqh_cer_shd.g_old_rec.information91;
  End If;
  If (p_rec.information92 = hr_api.g_varchar2) then
    p_rec.information92 :=
    pqh_cer_shd.g_old_rec.information92;
  End If;
  If (p_rec.information93 = hr_api.g_varchar2) then
    p_rec.information93 :=
    pqh_cer_shd.g_old_rec.information93;
  End If;
  If (p_rec.information94 = hr_api.g_varchar2) then
    p_rec.information94 :=
    pqh_cer_shd.g_old_rec.information94;
  End If;
  If (p_rec.information95 = hr_api.g_varchar2) then
    p_rec.information95 :=
    pqh_cer_shd.g_old_rec.information95;
  End If;
  If (p_rec.information96 = hr_api.g_varchar2) then
    p_rec.information96 :=
    pqh_cer_shd.g_old_rec.information96;
  End If;
  If (p_rec.information97 = hr_api.g_varchar2) then
    p_rec.information97 :=
    pqh_cer_shd.g_old_rec.information97;
  End If;
  If (p_rec.information98 = hr_api.g_varchar2) then
    p_rec.information98 :=
    pqh_cer_shd.g_old_rec.information98;
  End If;
  If (p_rec.information99 = hr_api.g_varchar2) then
    p_rec.information99 :=
    pqh_cer_shd.g_old_rec.information99;
  End If;
  If (p_rec.information100 = hr_api.g_varchar2) then
    p_rec.information100 :=
    pqh_cer_shd.g_old_rec.information100;
  End If;
  If (p_rec.information101 = hr_api.g_varchar2) then
    p_rec.information101 :=
    pqh_cer_shd.g_old_rec.information101;
  End If;
  If (p_rec.information102 = hr_api.g_varchar2) then
    p_rec.information102 :=
    pqh_cer_shd.g_old_rec.information102;
  End If;
  If (p_rec.information103 = hr_api.g_varchar2) then
    p_rec.information103 :=
    pqh_cer_shd.g_old_rec.information103;
  End If;
  If (p_rec.information104 = hr_api.g_varchar2) then
    p_rec.information104 :=
    pqh_cer_shd.g_old_rec.information104;
  End If;
  If (p_rec.information105 = hr_api.g_varchar2) then
    p_rec.information105 :=
    pqh_cer_shd.g_old_rec.information105;
  End If;
  If (p_rec.information106 = hr_api.g_varchar2) then
    p_rec.information106 :=
    pqh_cer_shd.g_old_rec.information106;
  End If;
  If (p_rec.information107 = hr_api.g_varchar2) then
    p_rec.information107 :=
    pqh_cer_shd.g_old_rec.information107;
  End If;
  If (p_rec.information108 = hr_api.g_varchar2) then
    p_rec.information108 :=
    pqh_cer_shd.g_old_rec.information108;
  End If;
  If (p_rec.information109 = hr_api.g_varchar2) then
    p_rec.information109 :=
    pqh_cer_shd.g_old_rec.information109;
  End If;
  If (p_rec.information110 = hr_api.g_varchar2) then
    p_rec.information110 :=
    pqh_cer_shd.g_old_rec.information110;
  End If;
  If (p_rec.information111 = hr_api.g_varchar2) then
    p_rec.information111 :=
    pqh_cer_shd.g_old_rec.information111;
  End If;
  If (p_rec.information112 = hr_api.g_varchar2) then
    p_rec.information112 :=
    pqh_cer_shd.g_old_rec.information112;
  End If;
  If (p_rec.information113 = hr_api.g_varchar2) then
    p_rec.information113 :=
    pqh_cer_shd.g_old_rec.information113;
  End If;
  If (p_rec.information114 = hr_api.g_varchar2) then
    p_rec.information114 :=
    pqh_cer_shd.g_old_rec.information114;
  End If;
  If (p_rec.information115 = hr_api.g_varchar2) then
    p_rec.information115 :=
    pqh_cer_shd.g_old_rec.information115;
  End If;
  If (p_rec.information116 = hr_api.g_varchar2) then
    p_rec.information116 :=
    pqh_cer_shd.g_old_rec.information116;
  End If;
  If (p_rec.information117 = hr_api.g_varchar2) then
    p_rec.information117 :=
    pqh_cer_shd.g_old_rec.information117;
  End If;
  If (p_rec.information118 = hr_api.g_varchar2) then
    p_rec.information118 :=
    pqh_cer_shd.g_old_rec.information118;
  End If;
  If (p_rec.information119 = hr_api.g_varchar2) then
    p_rec.information119 :=
    pqh_cer_shd.g_old_rec.information119;
  End If;
  If (p_rec.information120 = hr_api.g_varchar2) then
    p_rec.information120 :=
    pqh_cer_shd.g_old_rec.information120;
  End If;
  If (p_rec.information121 = hr_api.g_varchar2) then
    p_rec.information121 :=
    pqh_cer_shd.g_old_rec.information121;
  End If;
  If (p_rec.information122 = hr_api.g_varchar2) then
    p_rec.information122 :=
    pqh_cer_shd.g_old_rec.information122;
  End If;
  If (p_rec.information123 = hr_api.g_varchar2) then
    p_rec.information123 :=
    pqh_cer_shd.g_old_rec.information123;
  End If;
  If (p_rec.information124 = hr_api.g_varchar2) then
    p_rec.information124 :=
    pqh_cer_shd.g_old_rec.information124;
  End If;
  If (p_rec.information125 = hr_api.g_varchar2) then
    p_rec.information125 :=
    pqh_cer_shd.g_old_rec.information125;
  End If;
  If (p_rec.information126 = hr_api.g_varchar2) then
    p_rec.information126 :=
    pqh_cer_shd.g_old_rec.information126;
  End If;
  If (p_rec.information127 = hr_api.g_varchar2) then
    p_rec.information127 :=
    pqh_cer_shd.g_old_rec.information127;
  End If;
  If (p_rec.information128 = hr_api.g_varchar2) then
    p_rec.information128 :=
    pqh_cer_shd.g_old_rec.information128;
  End If;
  If (p_rec.information129 = hr_api.g_varchar2) then
    p_rec.information129 :=
    pqh_cer_shd.g_old_rec.information129;
  End If;
  If (p_rec.information130 = hr_api.g_varchar2) then
    p_rec.information130 :=
    pqh_cer_shd.g_old_rec.information130;
  End If;
  If (p_rec.information131 = hr_api.g_varchar2) then
    p_rec.information131 :=
    pqh_cer_shd.g_old_rec.information131;
  End If;
  If (p_rec.information132 = hr_api.g_varchar2) then
    p_rec.information132 :=
    pqh_cer_shd.g_old_rec.information132;
  End If;
  If (p_rec.information133 = hr_api.g_varchar2) then
    p_rec.information133 :=
    pqh_cer_shd.g_old_rec.information133;
  End If;
  If (p_rec.information134 = hr_api.g_varchar2) then
    p_rec.information134 :=
    pqh_cer_shd.g_old_rec.information134;
  End If;
  If (p_rec.information135 = hr_api.g_varchar2) then
    p_rec.information135 :=
    pqh_cer_shd.g_old_rec.information135;
  End If;
  If (p_rec.information136 = hr_api.g_varchar2) then
    p_rec.information136 :=
    pqh_cer_shd.g_old_rec.information136;
  End If;
  If (p_rec.information137 = hr_api.g_varchar2) then
    p_rec.information137 :=
    pqh_cer_shd.g_old_rec.information137;
  End If;
  If (p_rec.information138 = hr_api.g_varchar2) then
    p_rec.information138 :=
    pqh_cer_shd.g_old_rec.information138;
  End If;
  If (p_rec.information139 = hr_api.g_varchar2) then
    p_rec.information139 :=
    pqh_cer_shd.g_old_rec.information139;
  End If;
  If (p_rec.information140 = hr_api.g_varchar2) then
    p_rec.information140 :=
    pqh_cer_shd.g_old_rec.information140;
  End If;
  If (p_rec.information141 = hr_api.g_varchar2) then
    p_rec.information141 :=
    pqh_cer_shd.g_old_rec.information141;
  End If;
  If (p_rec.information142 = hr_api.g_varchar2) then
    p_rec.information142 :=
    pqh_cer_shd.g_old_rec.information142;
  End If;
  If (p_rec.information143 = hr_api.g_varchar2) then
    p_rec.information143 :=
    pqh_cer_shd.g_old_rec.information143;
  End If;
  If (p_rec.information144 = hr_api.g_varchar2) then
    p_rec.information144 :=
    pqh_cer_shd.g_old_rec.information144;
  End If;
  If (p_rec.information145 = hr_api.g_varchar2) then
    p_rec.information145 :=
    pqh_cer_shd.g_old_rec.information145;
  End If;
  If (p_rec.information146 = hr_api.g_varchar2) then
    p_rec.information146 :=
    pqh_cer_shd.g_old_rec.information146;
  End If;
  If (p_rec.information147 = hr_api.g_varchar2) then
    p_rec.information147 :=
    pqh_cer_shd.g_old_rec.information147;
  End If;
  If (p_rec.information148 = hr_api.g_varchar2) then
    p_rec.information148 :=
    pqh_cer_shd.g_old_rec.information148;
  End If;
  If (p_rec.information149 = hr_api.g_varchar2) then
    p_rec.information149 :=
    pqh_cer_shd.g_old_rec.information149;
  End If;
  If (p_rec.information150 = hr_api.g_varchar2) then
    p_rec.information150 :=
    pqh_cer_shd.g_old_rec.information150;
  End If;
  If (p_rec.information151 = hr_api.g_varchar2) then
    p_rec.information151 :=
    pqh_cer_shd.g_old_rec.information151;
  End If;
  If (p_rec.information152 = hr_api.g_varchar2) then
    p_rec.information152 :=
    pqh_cer_shd.g_old_rec.information152;
  End If;
  If (p_rec.information153 = hr_api.g_varchar2) then
    p_rec.information153 :=
    pqh_cer_shd.g_old_rec.information153;
  End If;
  If (p_rec.information154 = hr_api.g_varchar2) then
    p_rec.information154 :=
    pqh_cer_shd.g_old_rec.information154;
  End If;
  If (p_rec.information155 = hr_api.g_varchar2) then
    p_rec.information155 :=
    pqh_cer_shd.g_old_rec.information155;
  End If;
  If (p_rec.information156 = hr_api.g_varchar2) then
    p_rec.information156 :=
    pqh_cer_shd.g_old_rec.information156;
  End If;
  If (p_rec.information157 = hr_api.g_varchar2) then
    p_rec.information157 :=
    pqh_cer_shd.g_old_rec.information157;
  End If;
  If (p_rec.information158 = hr_api.g_varchar2) then
    p_rec.information158 :=
    pqh_cer_shd.g_old_rec.information158;
  End If;
  If (p_rec.information159 = hr_api.g_varchar2) then
    p_rec.information159 :=
    pqh_cer_shd.g_old_rec.information159;
  End If;
  If (p_rec.information160 = hr_api.g_varchar2) then
    p_rec.information160 :=
    pqh_cer_shd.g_old_rec.information160;
  End If;
  If (p_rec.information161 = hr_api.g_varchar2) then
    p_rec.information161 :=
    pqh_cer_shd.g_old_rec.information161;
  End If;
  If (p_rec.information162 = hr_api.g_varchar2) then
    p_rec.information162 :=
    pqh_cer_shd.g_old_rec.information162;
  End If;
  If (p_rec.information163 = hr_api.g_varchar2) then
    p_rec.information163 :=
    pqh_cer_shd.g_old_rec.information163;
  End If;
  If (p_rec.information164 = hr_api.g_varchar2) then
    p_rec.information164 :=
    pqh_cer_shd.g_old_rec.information164;
  End If;
  If (p_rec.information165 = hr_api.g_varchar2) then
    p_rec.information165 :=
    pqh_cer_shd.g_old_rec.information165;
  End If;
  If (p_rec.information166 = hr_api.g_varchar2) then
    p_rec.information166 :=
    pqh_cer_shd.g_old_rec.information166;
  End If;
  If (p_rec.information167 = hr_api.g_varchar2) then
    p_rec.information167 :=
    pqh_cer_shd.g_old_rec.information167;
  End If;
  If (p_rec.information168 = hr_api.g_varchar2) then
    p_rec.information168 :=
    pqh_cer_shd.g_old_rec.information168;
  End If;
  If (p_rec.information169 = hr_api.g_varchar2) then
    p_rec.information169 :=
    pqh_cer_shd.g_old_rec.information169;
  End If;
  If (p_rec.information170 = hr_api.g_varchar2) then
    p_rec.information170 :=
    pqh_cer_shd.g_old_rec.information170;
  End If;
  If (p_rec.information171 = hr_api.g_varchar2) then
    p_rec.information171 :=
    pqh_cer_shd.g_old_rec.information171;
  End If;
  If (p_rec.information172 = hr_api.g_varchar2) then
    p_rec.information172 :=
    pqh_cer_shd.g_old_rec.information172;
  End If;
  If (p_rec.information173 = hr_api.g_varchar2) then
    p_rec.information173 :=
    pqh_cer_shd.g_old_rec.information173;
  End If;
  If (p_rec.information174 = hr_api.g_varchar2) then
    p_rec.information174 :=
    pqh_cer_shd.g_old_rec.information174;
  End If;
  If (p_rec.information175 = hr_api.g_varchar2) then
    p_rec.information175 :=
    pqh_cer_shd.g_old_rec.information175;
  End If;
  If (p_rec.information176 = hr_api.g_varchar2) then
    p_rec.information176 :=
    pqh_cer_shd.g_old_rec.information176;
  End If;
  If (p_rec.information177 = hr_api.g_varchar2) then
    p_rec.information177 :=
    pqh_cer_shd.g_old_rec.information177;
  End If;
  If (p_rec.information178 = hr_api.g_varchar2) then
    p_rec.information178 :=
    pqh_cer_shd.g_old_rec.information178;
  End If;
  If (p_rec.information179 = hr_api.g_varchar2) then
    p_rec.information179 :=
    pqh_cer_shd.g_old_rec.information179;
  End If;
  If (p_rec.information180 = hr_api.g_varchar2) then
    p_rec.information180 :=
    pqh_cer_shd.g_old_rec.information180;
  End If;

  If (p_rec.information181 = hr_api.g_varchar2) then
    p_rec.information181 :=
    pqh_cer_shd.g_old_rec.information181;
  End If;
  If (p_rec.information182 = hr_api.g_varchar2) then
    p_rec.information182 :=
    pqh_cer_shd.g_old_rec.information182;
  End If;
  If (p_rec.information183 = hr_api.g_varchar2) then
    p_rec.information183 :=
    pqh_cer_shd.g_old_rec.information183;
  End If;
  If (p_rec.information184 = hr_api.g_varchar2) then
    p_rec.information184 :=
    pqh_cer_shd.g_old_rec.information184;
  End If;
  If (p_rec.information185 = hr_api.g_varchar2) then
    p_rec.information185 :=
    pqh_cer_shd.g_old_rec.information185;
  End If;
  If (p_rec.information186 = hr_api.g_varchar2) then
    p_rec.information186 :=
    pqh_cer_shd.g_old_rec.information186;
  End If;
  If (p_rec.information187 = hr_api.g_varchar2) then
    p_rec.information187 :=
    pqh_cer_shd.g_old_rec.information187;
  End If;
  If (p_rec.information188 = hr_api.g_varchar2) then
    p_rec.information188 :=
    pqh_cer_shd.g_old_rec.information188;
  End If;
  If (p_rec.information189 = hr_api.g_varchar2) then
    p_rec.information189 :=
    pqh_cer_shd.g_old_rec.information189;
  End If;
  If (p_rec.information190 = hr_api.g_varchar2) then
    p_rec.information190 :=
    pqh_cer_shd.g_old_rec.information190;
  End If;
  If (p_rec.mirror_entity_result_id = hr_api.g_number) then
    p_rec.mirror_entity_result_id :=
    pqh_cer_shd.g_old_rec.mirror_entity_result_id;
  End If;
  If (p_rec.mirror_src_entity_result_id = hr_api.g_number) then
    p_rec.mirror_src_entity_result_id :=
    pqh_cer_shd.g_old_rec.mirror_src_entity_result_id;
  End If;
  If (p_rec.parent_entity_result_id = hr_api.g_number) then
    p_rec.parent_entity_result_id :=
    pqh_cer_shd.g_old_rec.parent_entity_result_id;
  End If;
  If (p_rec.table_route_id = hr_api.g_number) then
    p_rec.table_route_id :=
    pqh_cer_shd.g_old_rec.table_route_id;
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
  p_effective_date in date,
  p_rec        in out nocopy pqh_cer_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pqh_cer_shd.lck
	(
	p_rec.copy_entity_result_id,
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
  pqh_cer_bus.update_validate(p_rec
  ,p_effective_date);
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
  post_update(
p_effective_date,p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_copy_entity_result_id        in number,
  p_copy_entity_txn_id           in number           default hr_api.g_number,
  p_result_type_cd               in varchar2         default hr_api.g_varchar2,
  p_number_of_copies             in number           default hr_api.g_number  ,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_src_copy_entity_result_id    in number           default hr_api.g_number,
  p_information_category         in varchar2         default hr_api.g_varchar2,
  p_information1                 in varchar2         default hr_api.g_varchar2,
  p_information2                 in varchar2         default hr_api.g_varchar2,
  p_information3                 in varchar2         default hr_api.g_varchar2,
  p_information4                 in varchar2         default hr_api.g_varchar2,
  p_information5                 in varchar2         default hr_api.g_varchar2,
  p_information6                 in varchar2         default hr_api.g_varchar2,
  p_information7                 in varchar2         default hr_api.g_varchar2,
  p_information8                 in varchar2         default hr_api.g_varchar2,
  p_information9                 in varchar2         default hr_api.g_varchar2,
  p_information10                in varchar2         default hr_api.g_varchar2,
  p_information11                in varchar2         default hr_api.g_varchar2,
  p_information12                in varchar2         default hr_api.g_varchar2,
  p_information13                in varchar2         default hr_api.g_varchar2,
  p_information14                in varchar2         default hr_api.g_varchar2,
  p_information15                in varchar2         default hr_api.g_varchar2,
  p_information16                in varchar2         default hr_api.g_varchar2,
  p_information17                in varchar2         default hr_api.g_varchar2,
  p_information18                in varchar2         default hr_api.g_varchar2,
  p_information19                in varchar2         default hr_api.g_varchar2,
  p_information20                in varchar2         default hr_api.g_varchar2,
  p_information21                in varchar2         default hr_api.g_varchar2,
  p_information22                in varchar2         default hr_api.g_varchar2,
  p_information23                in varchar2         default hr_api.g_varchar2,
  p_information24                in varchar2         default hr_api.g_varchar2,
  p_information25                in varchar2         default hr_api.g_varchar2,
  p_information26                in varchar2         default hr_api.g_varchar2,
  p_information27                in varchar2         default hr_api.g_varchar2,
  p_information28                in varchar2         default hr_api.g_varchar2,
  p_information29                in varchar2         default hr_api.g_varchar2,
  p_information30                in varchar2         default hr_api.g_varchar2,
  p_information31                in varchar2         default hr_api.g_varchar2,
  p_information32                in varchar2         default hr_api.g_varchar2,
  p_information33                in varchar2         default hr_api.g_varchar2,
  p_information34                in varchar2         default hr_api.g_varchar2,
  p_information35                in varchar2         default hr_api.g_varchar2,
  p_information36                in varchar2         default hr_api.g_varchar2,
  p_information37                in varchar2         default hr_api.g_varchar2,
  p_information38                in varchar2         default hr_api.g_varchar2,
  p_information39                in varchar2         default hr_api.g_varchar2,
  p_information40                in varchar2         default hr_api.g_varchar2,
  p_information41                in varchar2         default hr_api.g_varchar2,
  p_information42                in varchar2         default hr_api.g_varchar2,
  p_information43                in varchar2         default hr_api.g_varchar2,
  p_information44                in varchar2         default hr_api.g_varchar2,
  p_information45                in varchar2         default hr_api.g_varchar2,
  p_information46                in varchar2         default hr_api.g_varchar2,
  p_information47                in varchar2         default hr_api.g_varchar2,
  p_information48                in varchar2         default hr_api.g_varchar2,
  p_information49                in varchar2         default hr_api.g_varchar2,
  p_information50                in varchar2         default hr_api.g_varchar2,
  p_information51                in varchar2         default hr_api.g_varchar2,
  p_information52                in varchar2         default hr_api.g_varchar2,
  p_information53                in varchar2         default hr_api.g_varchar2,
  p_information54                in varchar2         default hr_api.g_varchar2,
  p_information55                in varchar2         default hr_api.g_varchar2,
  p_information56                in varchar2         default hr_api.g_varchar2,
  p_information57                in varchar2         default hr_api.g_varchar2,
  p_information58                in varchar2         default hr_api.g_varchar2,
  p_information59                in varchar2         default hr_api.g_varchar2,
  p_information60                in varchar2         default hr_api.g_varchar2,
  p_information61                in varchar2         default hr_api.g_varchar2,
  p_information62                in varchar2         default hr_api.g_varchar2,
  p_information63                in varchar2         default hr_api.g_varchar2,
  p_information64                in varchar2         default hr_api.g_varchar2,
  p_information65                in varchar2         default hr_api.g_varchar2,
  p_information66                in varchar2         default hr_api.g_varchar2,
  p_information67                in varchar2         default hr_api.g_varchar2,
  p_information68                in varchar2         default hr_api.g_varchar2,
  p_information69                in varchar2         default hr_api.g_varchar2,
  p_information70                in varchar2         default hr_api.g_varchar2,
  p_information71                in varchar2         default hr_api.g_varchar2,
  p_information72                in varchar2         default hr_api.g_varchar2,
  p_information73                in varchar2         default hr_api.g_varchar2,
  p_information74                in varchar2         default hr_api.g_varchar2,
  p_information75                in varchar2         default hr_api.g_varchar2,
  p_information76                in varchar2         default hr_api.g_varchar2,
  p_information77                in varchar2         default hr_api.g_varchar2,
  p_information78                in varchar2         default hr_api.g_varchar2,
  p_information79                in varchar2         default hr_api.g_varchar2,
  p_information80                in varchar2         default hr_api.g_varchar2,
  p_information81                in varchar2         default hr_api.g_varchar2,
  p_information82                in varchar2         default hr_api.g_varchar2,
  p_information83                in varchar2         default hr_api.g_varchar2,
  p_information84                in varchar2         default hr_api.g_varchar2,
  p_information85                in varchar2         default hr_api.g_varchar2,
  p_information86                in varchar2         default hr_api.g_varchar2,
  p_information87                in varchar2         default hr_api.g_varchar2,
  p_information88                in varchar2         default hr_api.g_varchar2,
  p_information89                in varchar2         default hr_api.g_varchar2,
  p_information90                in varchar2         default hr_api.g_varchar2,
  p_information91                 in varchar2     default hr_api.g_varchar2,
  p_information92                 in varchar2     default hr_api.g_varchar2,
  p_information93                 in varchar2     default hr_api.g_varchar2,
  p_information94                 in varchar2     default hr_api.g_varchar2,
  p_information95                 in varchar2     default hr_api.g_varchar2,
  p_information96                 in varchar2     default hr_api.g_varchar2,
  p_information97                 in varchar2     default hr_api.g_varchar2,
  p_information98                 in varchar2     default hr_api.g_varchar2,
  p_information99                 in varchar2     default hr_api.g_varchar2,
  p_information100                in varchar2     default hr_api.g_varchar2,
  p_information101                in varchar2     default hr_api.g_varchar2,
  p_information102                in varchar2     default hr_api.g_varchar2,
  p_information103                in varchar2     default hr_api.g_varchar2,
  p_information104                in varchar2     default hr_api.g_varchar2,
  p_information105                in varchar2     default hr_api.g_varchar2,
  p_information106                in varchar2     default hr_api.g_varchar2,
  p_information107                in varchar2     default hr_api.g_varchar2,
  p_information108                in varchar2     default hr_api.g_varchar2,
  p_information109                in varchar2     default hr_api.g_varchar2,
  p_information110                in varchar2     default hr_api.g_varchar2,
  p_information111                in varchar2     default hr_api.g_varchar2,
  p_information112                in varchar2     default hr_api.g_varchar2,
  p_information113                in varchar2     default hr_api.g_varchar2,
  p_information114                in varchar2     default hr_api.g_varchar2,
  p_information115                in varchar2     default hr_api.g_varchar2,
  p_information116                in varchar2     default hr_api.g_varchar2,
  p_information117                in varchar2     default hr_api.g_varchar2,
  p_information118                in varchar2     default hr_api.g_varchar2,
  p_information119                in varchar2     default hr_api.g_varchar2,
  p_information120                in varchar2     default hr_api.g_varchar2,
  p_information121                in varchar2     default hr_api.g_varchar2,
  p_information122                in varchar2     default hr_api.g_varchar2,
  p_information123                in varchar2     default hr_api.g_varchar2,
  p_information124                in varchar2     default hr_api.g_varchar2,
  p_information125                in varchar2     default hr_api.g_varchar2,
  p_information126                in varchar2     default hr_api.g_varchar2,
  p_information127                in varchar2     default hr_api.g_varchar2,
  p_information128                in varchar2     default hr_api.g_varchar2,
  p_information129                in varchar2     default hr_api.g_varchar2,
  p_information130                in varchar2     default hr_api.g_varchar2,
  p_information131                in varchar2     default hr_api.g_varchar2,
  p_information132                in varchar2     default hr_api.g_varchar2,
  p_information133                in varchar2     default hr_api.g_varchar2,
  p_information134                in varchar2     default hr_api.g_varchar2,
  p_information135                in varchar2     default hr_api.g_varchar2,
  p_information136                in varchar2     default hr_api.g_varchar2,
  p_information137                in varchar2     default hr_api.g_varchar2,
  p_information138                in varchar2     default hr_api.g_varchar2,
  p_information139                in varchar2     default hr_api.g_varchar2,
  p_information140                in varchar2     default hr_api.g_varchar2,
  p_information141                in varchar2     default hr_api.g_varchar2,
  p_information142                in varchar2     default hr_api.g_varchar2,
  p_information143                in varchar2     default hr_api.g_varchar2,
  p_information144                in varchar2     default hr_api.g_varchar2,
  p_information145                in varchar2     default hr_api.g_varchar2,
  p_information146                in varchar2     default hr_api.g_varchar2,
  p_information147                in varchar2     default hr_api.g_varchar2,
  p_information148                in varchar2     default hr_api.g_varchar2,
  p_information149                in varchar2     default hr_api.g_varchar2,
  p_information150                in varchar2     default hr_api.g_varchar2,
  p_information151                in varchar2     default hr_api.g_varchar2,
  p_information152                in varchar2     default hr_api.g_varchar2,
  p_information153                in varchar2     default hr_api.g_varchar2,
  p_information154                in varchar2     default hr_api.g_varchar2,
  p_information155                in varchar2     default hr_api.g_varchar2,
  p_information156                in varchar2     default hr_api.g_varchar2,
  p_information157                in varchar2     default hr_api.g_varchar2,
  p_information158                in varchar2     default hr_api.g_varchar2,
  p_information159                in varchar2     default hr_api.g_varchar2,
  p_information160                in varchar2     default hr_api.g_varchar2,
  p_information161                in varchar2     default hr_api.g_varchar2,
  p_information162                in varchar2     default hr_api.g_varchar2,
  p_information163                in varchar2     default hr_api.g_varchar2,
  p_information164                in varchar2     default hr_api.g_varchar2,
  p_information165                in varchar2     default hr_api.g_varchar2,
  p_information166                in varchar2     default hr_api.g_varchar2,
  p_information167                in varchar2     default hr_api.g_varchar2,
  p_information168                in varchar2     default hr_api.g_varchar2,
  p_information169                in varchar2     default hr_api.g_varchar2,
  p_information170                in varchar2     default hr_api.g_varchar2,
  p_information171                in varchar2     default hr_api.g_varchar2,
  p_information172                in varchar2     default hr_api.g_varchar2,
  p_information173                in varchar2     default hr_api.g_varchar2,
  p_information174                in varchar2     default hr_api.g_varchar2,
  p_information175                in varchar2     default hr_api.g_varchar2,
  p_information176                in varchar2     default hr_api.g_varchar2,
  p_information177                in varchar2     default hr_api.g_varchar2,
  p_information178                in varchar2     default hr_api.g_varchar2,
  p_information179                in varchar2     default hr_api.g_varchar2,
  p_information180                in varchar2     default hr_api.g_varchar2,
  p_information181                in varchar2     default hr_api.g_varchar2,
  p_information182                in varchar2     default hr_api.g_varchar2,
  p_information183                in varchar2     default hr_api.g_varchar2,
  p_information184                in varchar2     default hr_api.g_varchar2,
  p_information185                in varchar2     default hr_api.g_varchar2,
  p_information186                in varchar2     default hr_api.g_varchar2,
  p_information187                in varchar2     default hr_api.g_varchar2,
  p_information188                in varchar2     default hr_api.g_varchar2,
  p_information189                in varchar2     default hr_api.g_varchar2,
  p_information190                in varchar2     default hr_api.g_varchar2,
  p_mirror_entity_result_id       in number       default hr_api.g_number,
  p_mirror_src_entity_result_id   in number       default hr_api.g_number,
  p_parent_entity_result_id       in number       default hr_api.g_number,
  p_table_route_id                in number       default hr_api.g_number,
  p_long_attribute1               in long,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  pqh_cer_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_cer_shd.convert_args
  (
  p_copy_entity_result_id,
  p_copy_entity_txn_id,
  p_result_type_cd,
  p_number_of_copies,
  p_status,
  p_src_copy_entity_result_id,
  p_information_category,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_information21,
  p_information22,
  p_information23,
  p_information24,
  p_information25,
  p_information26,
  p_information27,
  p_information28,
  p_information29,
  p_information30,
  p_information31,
  p_information32,
  p_information33,
  p_information34,
  p_information35,
  p_information36,
  p_information37,
  p_information38,
  p_information39,
  p_information40,
  p_information41,
  p_information42,
  p_information43,
  p_information44,
  p_information45,
  p_information46,
  p_information47,
  p_information48,
  p_information49,
  p_information50,
  p_information51,
  p_information52,
  p_information53,
  p_information54,
  p_information55,
  p_information56,
  p_information57,
  p_information58,
  p_information59,
  p_information60,
  p_information61,
  p_information62,
  p_information63,
  p_information64,
  p_information65,
  p_information66,
  p_information67,
  p_information68,
  p_information69,
  p_information70,
  p_information71,
  p_information72,
  p_information73,
  p_information74,
  p_information75,
  p_information76,
  p_information77,
  p_information78,
  p_information79,
  p_information80,
  p_information81,
  p_information82,
  p_information83,
  p_information84,
  p_information85,
  p_information86,
  p_information87,
  p_information88,
  p_information89,
  p_information90,
  p_information91   ,
  p_information92   ,
  p_information93   ,
  p_information94   ,
  p_information95   ,
  p_information96   ,
  p_information97   ,
  p_information98   ,
  p_information99   ,
  p_information100  ,
  p_information101  ,
  p_information102  ,
  p_information103  ,
  p_information104  ,
  p_information105  ,
  p_information106  ,
  p_information107  ,
  p_information108  ,
  p_information109  ,
  p_information110  ,
  p_information111  ,
  p_information112  ,
  p_information113  ,
  p_information114  ,
  p_information115  ,
  p_information116  ,
  p_information117  ,
  p_information118  ,
  p_information119  ,
  p_information120  ,
  p_information121  ,
  p_information122  ,
  p_information123  ,
  p_information124  ,
  p_information125  ,
  p_information126  ,
  p_information127  ,
  p_information128  ,
  p_information129  ,
  p_information130  ,
  p_information131  ,
  p_information132  ,
  p_information133  ,
  p_information134  ,
  p_information135  ,
  p_information136  ,
  p_information137  ,
  p_information138  ,
  p_information139  ,
  p_information140  ,
  p_information141  ,
  p_information142  ,
  p_information143  ,
  p_information144  ,
  p_information145  ,
  p_information146  ,
  p_information147  ,
  p_information148  ,
  p_information149  ,
  p_information150  ,
  p_information151  ,
  p_information152  ,
  p_information153  ,
  p_information154  ,
  p_information155  ,
  p_information156  ,
  p_information157  ,
  p_information158  ,
  p_information159  ,
  p_information160  ,
  p_information161  ,
  p_information162  ,
  p_information163  ,
  p_information164  ,
  p_information165  ,
  p_information166  ,
  p_information167  ,
  p_information168  ,
  p_information169  ,
  p_information170  ,
  p_information171  ,
  p_information172  ,
  p_information173  ,
  p_information174  ,
  p_information175  ,
  p_information176  ,
  p_information177  ,
  p_information178  ,
  p_information179  ,
  p_information180  ,
  p_information181  ,
  p_information182  ,
  p_information183  ,
  p_information184  ,
  p_information185  ,
  p_information186  ,
  p_information187  ,
  p_information188  ,
  p_information189  ,
  p_information190  ,
  p_mirror_entity_result_id    ,
  p_mirror_src_entity_result_id,
  p_parent_entity_result_id    ,
  p_table_route_id             ,
  p_long_attribute1            ,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_cer_upd;

/
