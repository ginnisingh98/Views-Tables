--------------------------------------------------------
--  DDL for Package Body PQH_CER_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CER_INS" as
/* $Header: pqcerrhi.pkb 115.6 2002/11/27 04:43:16 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_cer_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   If a check, unique or parent integrity constraint violation is raised the
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
Procedure insert_dml(p_rec in out nocopy pqh_cer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: pqh_copy_entity_results
  --
  insert into pqh_copy_entity_results
  (	copy_entity_result_id,
	copy_entity_txn_id,
	result_type_cd,
	number_of_copies,
	status,
	src_copy_entity_result_id,
	information_category,
	information1,
	information2,
	information3,
	information4,
	information5,
	information6,
	information7,
	information8,
	information9,
	information10,
	information11,
	information12,
	information13,
	information14,
	information15,
	information16,
	information17,
	information18,
	information19,
	information20,
	information21,
	information22,
	information23,
	information24,
	information25,
	information26,
	information27,
	information28,
	information29,
	information30,
	information31,
	information32,
	information33,
	information34,
	information35,
	information36,
	information37,
	information38,
	information39,
	information40,
	information41,
	information42,
	information43,
	information44,
	information45,
	information46,
	information47,
	information48,
	information49,
	information50,
	information51,
	information52,
	information53,
	information54,
	information55,
	information56,
	information57,
	information58,
	information59,
	information60,
	information61,
	information62,
	information63,
	information64,
	information65,
	information66,
	information67,
	information68,
	information69,
	information70,
	information71,
	information72,
	information73,
	information74,
	information75,
	information76,
	information77,
	information78,
	information79,
	information80,
	information81,
	information82,
	information83,
	information84,
	information85,
	information86,
	information87,
	information88,
	information89,
	information90,
        information91,
        information92,
        information93,
        information94,
        information95,
        information96,
        information97,
        information98,
        information99,
        information100,
        information101,
        information102,
        information103,
        information104,
        information105,
        information106,
        information107,
        information108,
        information109,
        information110,
        information111,
        information112,
        information113,
        information114,
        information115,
        information116,
        information117,
        information118,
        information119,
        information120,
        information121,
        information122,
        information123,
        information124,
        information125,
        information126,
        information127,
        information128,
        information129,
        information130,
        information131,
        information132,
        information133,
        information134,
        information135,
        information136,
        information137,
        information138,
        information139,
        information140,
        information141,
        information142,
        information143,
        information144,
        information145,
        information146,
        information147,
        information148,
        information149,
        information150,
        information151,
        information152,
        information153,
        information154,
        information155,
        information156,
        information157,
        information158,
        information159,
        information160,
        information161,
        information162,
        information163,
        information164,
        information165,
        information166,
        information167,
        information168,
        information169,
        information170,
        information171,
        information172,
        information173,
        information174,
        information175,
        information176,
        information177,
        information178,
        information179,
        information180,
        information181,
        information182,
        information183,
        information184,
        information185,
        information186,
        information187,
        information188,
        information189,
        information190,
        mirror_entity_result_id,
        mirror_src_entity_result_id,
        parent_entity_result_id,
        table_route_id,
        long_attribute1,
	object_version_number
  )
  Values
  (	p_rec.copy_entity_result_id,
	p_rec.copy_entity_txn_id,
	p_rec.result_type_cd,
	p_rec.number_of_copies,
	p_rec.status,
	p_rec.src_copy_entity_result_id,
	p_rec.information_category,
	p_rec.information1,
	p_rec.information2,
	p_rec.information3,
	p_rec.information4,
	p_rec.information5,
	p_rec.information6,
	p_rec.information7,
	p_rec.information8,
	p_rec.information9,
	p_rec.information10,
	p_rec.information11,
	p_rec.information12,
	p_rec.information13,
	p_rec.information14,
	p_rec.information15,
	p_rec.information16,
	p_rec.information17,
	p_rec.information18,
	p_rec.information19,
	p_rec.information20,
	p_rec.information21,
	p_rec.information22,
	p_rec.information23,
	p_rec.information24,
	p_rec.information25,
	p_rec.information26,
	p_rec.information27,
	p_rec.information28,
	p_rec.information29,
	p_rec.information30,
	p_rec.information31,
	p_rec.information32,
	p_rec.information33,
	p_rec.information34,
	p_rec.information35,
	p_rec.information36,
	p_rec.information37,
	p_rec.information38,
	p_rec.information39,
	p_rec.information40,
	p_rec.information41,
	p_rec.information42,
	p_rec.information43,
	p_rec.information44,
	p_rec.information45,
	p_rec.information46,
	p_rec.information47,
	p_rec.information48,
	p_rec.information49,
	p_rec.information50,
	p_rec.information51,
	p_rec.information52,
	p_rec.information53,
	p_rec.information54,
	p_rec.information55,
	p_rec.information56,
	p_rec.information57,
	p_rec.information58,
	p_rec.information59,
	p_rec.information60,
	p_rec.information61,
	p_rec.information62,
	p_rec.information63,
	p_rec.information64,
	p_rec.information65,
	p_rec.information66,
	p_rec.information67,
	p_rec.information68,
	p_rec.information69,
	p_rec.information70,
	p_rec.information71,
	p_rec.information72,
	p_rec.information73,
	p_rec.information74,
	p_rec.information75,
	p_rec.information76,
	p_rec.information77,
	p_rec.information78,
	p_rec.information79,
	p_rec.information80,
	p_rec.information81,
	p_rec.information82,
	p_rec.information83,
	p_rec.information84,
	p_rec.information85,
	p_rec.information86,
	p_rec.information87,
	p_rec.information88,
	p_rec.information89,
	p_rec.information90,
        p_rec.information91,
        p_rec.information92,
        p_rec.information93,
        p_rec.information94,
        p_rec.information95,
        p_rec.information96,
        p_rec.information97,
        p_rec.information98,
        p_rec.information99,
        p_rec.information100,
        p_rec.information101,
        p_rec.information102,
        p_rec.information103,
        p_rec.information104,
        p_rec.information105,
        p_rec.information106,
        p_rec.information107,
        p_rec.information108,
        p_rec.information109,
        p_rec.information110,
        p_rec.information111,
        p_rec.information112,
        p_rec.information113,
        p_rec.information114,
        p_rec.information115,
        p_rec.information116,
        p_rec.information117,
        p_rec.information118,
        p_rec.information119,
        p_rec.information120,
        p_rec.information121,
        p_rec.information122,
        p_rec.information123,
        p_rec.information124,
        p_rec.information125,
        p_rec.information126,
        p_rec.information127,
        p_rec.information128,
        p_rec.information129,
        p_rec.information130,
        p_rec.information131,
        p_rec.information132,
        p_rec.information133,
        p_rec.information134,
        p_rec.information135,
        p_rec.information136,
        p_rec.information137,
        p_rec.information138,
        p_rec.information139,
        p_rec.information140,
        p_rec.information141,
        p_rec.information142,
        p_rec.information143,
        p_rec.information144,
        p_rec.information145,
        p_rec.information146,
        p_rec.information147,
        p_rec.information148,
        p_rec.information149,
        p_rec.information150,
        p_rec.information151,
        p_rec.information152,
        p_rec.information153,
        p_rec.information154,
        p_rec.information155,
        p_rec.information156,
        p_rec.information157,
        p_rec.information158,
        p_rec.information159,
        p_rec.information160,
        p_rec.information161,
        p_rec.information162,
        p_rec.information163,
        p_rec.information164,
        p_rec.information165,
        p_rec.information166,
        p_rec.information167,
        p_rec.information168,
        p_rec.information169,
        p_rec.information170,
        p_rec.information171,
        p_rec.information172,
        p_rec.information173,
        p_rec.information174,
        p_rec.information175,
        p_rec.information176,
        p_rec.information177,
        p_rec.information178,
        p_rec.information179,
        p_rec.information180,
        p_rec.information181,
        p_rec.information182,
        p_rec.information183,
        p_rec.information184,
        p_rec.information185,
        p_rec.information186,
        p_rec.information187,
        p_rec.information188,
        p_rec.information189,
        p_rec.information190,
        nvl(p_rec.mirror_entity_result_id, p_rec.copy_entity_result_id),
        p_rec.mirror_src_entity_result_id,
        p_rec.parent_entity_result_id,
        p_rec.table_route_id,
        p_rec.long_attribute1,
	p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy pqh_cer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_copy_entity_results_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.copy_entity_result_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(
p_effective_date in date,p_rec in pqh_cer_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pqh_cer_rki.after_insert
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_copy_entity_results'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_rec        in out nocopy pqh_cer_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_cer_bus.insert_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_copy_entity_result_id        out nocopy number,
  p_copy_entity_txn_id           in number,
  p_result_type_cd               in varchar2         default null,
  p_number_of_copies             in number           default null,
  p_status                       in varchar2         default null,
  p_src_copy_entity_result_id    in number           default null,
  p_information_category         in varchar2         default null,
  p_information1                 in varchar2         default null,
  p_information2                 in varchar2         default null,
  p_information3                 in varchar2         default null,
  p_information4                 in varchar2         default null,
  p_information5                 in varchar2         default null,
  p_information6                 in varchar2         default null,
  p_information7                 in varchar2         default null,
  p_information8                 in varchar2         default null,
  p_information9                 in varchar2         default null,
  p_information10                in varchar2         default null,
  p_information11                in varchar2         default null,
  p_information12                in varchar2         default null,
  p_information13                in varchar2         default null,
  p_information14                in varchar2         default null,
  p_information15                in varchar2         default null,
  p_information16                in varchar2         default null,
  p_information17                in varchar2         default null,
  p_information18                in varchar2         default null,
  p_information19                in varchar2         default null,
  p_information20                in varchar2         default null,
  p_information21                in varchar2         default null,
  p_information22                in varchar2         default null,
  p_information23                in varchar2         default null,
  p_information24                in varchar2         default null,
  p_information25                in varchar2         default null,
  p_information26                in varchar2         default null,
  p_information27                in varchar2         default null,
  p_information28                in varchar2         default null,
  p_information29                in varchar2         default null,
  p_information30                in varchar2         default null,
  p_information31                in varchar2         default null,
  p_information32                in varchar2         default null,
  p_information33                in varchar2         default null,
  p_information34                in varchar2         default null,
  p_information35                in varchar2         default null,
  p_information36                in varchar2         default null,
  p_information37                in varchar2         default null,
  p_information38                in varchar2         default null,
  p_information39                in varchar2         default null,
  p_information40                in varchar2         default null,
  p_information41                in varchar2         default null,
  p_information42                in varchar2         default null,
  p_information43                in varchar2         default null,
  p_information44                in varchar2         default null,
  p_information45                in varchar2         default null,
  p_information46                in varchar2         default null,
  p_information47                in varchar2         default null,
  p_information48                in varchar2         default null,
  p_information49                in varchar2         default null,
  p_information50                in varchar2         default null,
  p_information51                in varchar2         default null,
  p_information52                in varchar2         default null,
  p_information53                in varchar2         default null,
  p_information54                in varchar2         default null,
  p_information55                in varchar2         default null,
  p_information56                in varchar2         default null,
  p_information57                in varchar2         default null,
  p_information58                in varchar2         default null,
  p_information59                in varchar2         default null,
  p_information60                in varchar2         default null,
  p_information61                in varchar2         default null,
  p_information62                in varchar2         default null,
  p_information63                in varchar2         default null,
  p_information64                in varchar2         default null,
  p_information65                in varchar2         default null,
  p_information66                in varchar2         default null,
  p_information67                in varchar2         default null,
  p_information68                in varchar2         default null,
  p_information69                in varchar2         default null,
  p_information70                in varchar2         default null,
  p_information71                in varchar2         default null,
  p_information72                in varchar2         default null,
  p_information73                in varchar2         default null,
  p_information74                in varchar2         default null,
  p_information75                in varchar2         default null,
  p_information76                in varchar2         default null,
  p_information77                in varchar2         default null,
  p_information78                in varchar2         default null,
  p_information79                in varchar2         default null,
  p_information80                in varchar2         default null,
  p_information81                in varchar2         default null,
  p_information82                in varchar2         default null,
  p_information83                in varchar2         default null,
  p_information84                in varchar2         default null,
  p_information85                in varchar2         default null,
  p_information86                in varchar2         default null,
  p_information87                in varchar2         default null,
  p_information88                in varchar2         default null,
  p_information89                in varchar2         default null,
  p_information90                in varchar2         default null,
  p_information91                 in varchar2 default null,
  p_information92                 in varchar2 default null,
  p_information93                 in varchar2 default null,
  p_information94                 in varchar2 default null,
  p_information95                 in varchar2 default null,
  p_information96                 in varchar2 default null,
  p_information97                 in varchar2 default null,
  p_information98                 in varchar2 default null,
  p_information99                 in varchar2 default null,
  p_information100                in varchar2 default null,
  p_information101                in varchar2 default null,
  p_information102                in varchar2 default null,
  p_information103                in varchar2 default null,
  p_information104                in varchar2 default null,
  p_information105                in varchar2 default null,
  p_information106                in varchar2 default null,
  p_information107                in varchar2 default null,
  p_information108                in varchar2 default null,
  p_information109                in varchar2 default null,
  p_information110                in varchar2 default null,
  p_information111                in varchar2 default null,
  p_information112                in varchar2 default null,
  p_information113                in varchar2 default null,
  p_information114                in varchar2 default null,
  p_information115                in varchar2 default null,
  p_information116                in varchar2 default null,
  p_information117                in varchar2 default null,
  p_information118                in varchar2 default null,
  p_information119                in varchar2 default null,
  p_information120                in varchar2 default null,
  p_information121                in varchar2 default null,
  p_information122                in varchar2 default null,
  p_information123                in varchar2 default null,
  p_information124                in varchar2 default null,
  p_information125                in varchar2 default null,
  p_information126                in varchar2 default null,
  p_information127                in varchar2 default null,
  p_information128                in varchar2 default null,
  p_information129                in varchar2 default null,
  p_information130                in varchar2 default null,
  p_information131                in varchar2 default null,
  p_information132                in varchar2 default null,
  p_information133                in varchar2 default null,
  p_information134                in varchar2 default null,
  p_information135                in varchar2 default null,
  p_information136                in varchar2 default null,
  p_information137                in varchar2 default null,
  p_information138                in varchar2 default null,
  p_information139                in varchar2 default null,
  p_information140                in varchar2 default null,
  p_information141                in varchar2 default null,
  p_information142                in varchar2 default null,
  p_information143                in varchar2 default null,
  p_information144                in varchar2 default null,
  p_information145                in varchar2 default null,
  p_information146                in varchar2 default null,
  p_information147                in varchar2 default null,
  p_information148                in varchar2 default null,
  p_information149                in varchar2 default null,
  p_information150                in varchar2 default null,
  p_information151                in varchar2 default null,
  p_information152                in varchar2 default null,
  p_information153                in varchar2 default null,
  p_information154                in varchar2 default null,
  p_information155                in varchar2 default null,
  p_information156                in varchar2 default null,
  p_information157                in varchar2 default null,
  p_information158                in varchar2 default null,
  p_information159                in varchar2 default null,
  p_information160                in varchar2 default null,
  p_information161                in varchar2 default null,
  p_information162                in varchar2 default null,
  p_information163                in varchar2 default null,
  p_information164                in varchar2 default null,
  p_information165                in varchar2 default null,
  p_information166                in varchar2 default null,
  p_information167                in varchar2 default null,
  p_information168                in varchar2 default null,
  p_information169                in varchar2 default null,
  p_information170                in varchar2 default null,
  p_information171                in varchar2 default null,
  p_information172                in varchar2 default null,
  p_information173                in varchar2 default null,
  p_information174                in varchar2 default null,
  p_information175                in varchar2 default null,
  p_information176                in varchar2 default null,
  p_information177                in varchar2 default null,
  p_information178                in varchar2 default null,
  p_information179                in varchar2 default null,
  p_information180                in varchar2 default null,
  p_information181                in varchar2 default null,
  p_information182                in varchar2 default null,
  p_information183                in varchar2 default null,
  p_information184                in varchar2 default null,
  p_information185                in varchar2 default null,
  p_information186                in varchar2 default null,
  p_information187                in varchar2 default null,
  p_information188                in varchar2 default null,
  p_information189                in varchar2 default null,
  p_information190                in varchar2 default null,
  p_mirror_entity_result_id       in number default null,
  p_mirror_src_entity_result_id   in number default null,
  p_parent_entity_result_id       in number default null,
  p_table_route_id                in number default null,
  p_long_attribute1               in long default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  pqh_cer_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_cer_shd.convert_args
  (
  null,
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
  p_information91,
  p_information92,
  p_information93,
  p_information94,
  p_information95,
  p_information96,
  p_information97,
  p_information98,
  p_information99,
  p_information100,
  p_information101,
  p_information102,
  p_information103,
  p_information104,
  p_information105,
  p_information106,
  p_information107,
  p_information108,
  p_information109,
  p_information110,
  p_information111,
  p_information112,
  p_information113,
  p_information114,
  p_information115,
  p_information116,
  p_information117,
  p_information118,
  p_information119,
  p_information120,
  p_information121,
  p_information122,
  p_information123,
  p_information124,
  p_information125,
  p_information126,
  p_information127,
  p_information128,
  p_information129,
  p_information130,
  p_information131,
  p_information132,
  p_information133,
  p_information134,
  p_information135,
  p_information136,
  p_information137,
  p_information138,
  p_information139,
  p_information140,
  p_information141,
  p_information142,
  p_information143,
  p_information144,
  p_information145,
  p_information146,
  p_information147,
  p_information148,
  p_information149,
  p_information150,
  p_information151,
  p_information152,
  p_information153,
  p_information154,
  p_information155,
  p_information156,
  p_information157,
  p_information158,
  p_information159,
  p_information160,
  p_information161,
  p_information162,
  p_information163,
  p_information164,
  p_information165,
  p_information166,
  p_information167,
  p_information168,
  p_information169,
  p_information170,
  p_information171,
  p_information172,
  p_information173,
  p_information174,
  p_information175,
  p_information176,
  p_information177,
  p_information178,
  p_information179,
  p_information180,
  p_information181,
  p_information182,
  p_information183,
  p_information184,
  p_information185,
  p_information186,
  p_information187,
  p_information188,
  p_information189,
  p_information190,
  p_mirror_entity_result_id,
  p_mirror_src_entity_result_id,
  p_parent_entity_result_id,
  p_table_route_id,
  p_long_attribute1,
  null
  );
  --
  -- Having converted the arguments into the pqh_cer_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_copy_entity_result_id := l_rec.copy_entity_result_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_cer_ins;

/
